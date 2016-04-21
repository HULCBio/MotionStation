function y = getfield(node, fieldname)
%GETFIELD Get a field value of VRNODE.
%   Y = GETFIELD(NODE, 'fieldname') returns the value of the specified
%   field for the node referenced by the VRNODE handle NODE. If
%   NODE is a vector of VRNODE handles, then GETFIELD will return
%   an M-by-1 cell array of values where M is equal to LENGTH(NODE).
%   If 'fieldname' is a 1-by-N or N-by-1 cell array of strings containing
%   field names, then GETFIELD will return an M-by-N cell array of
%   values.
%
%   GETFIELD(NODE) displays all field names and their current values for
%   the VRML node with handle NODE.
%
%   Y = GETFIELD(NODE) where NODE is a scalar, returns a structure where
%   each field name is the name of a field of NODE and each field contains
%   the value of that field.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.2.4.3 $ $Date: 2004/03/15 22:35:28 $ $Author: batserve $


% use this overloaded GETFIELD only if the first argument is VRNODE
if ~isa(node, 'vrnode')
  builtin('getfield',node,fieldname);
  return;
end

% if no name given return all fields
if nargin<2
  if length(node)>1
    error('VR:invalidinarg', 'Vector of nodes not allowed if field name not given.');
  end
  
  % get the list of fields, select only the readable fields
  fieldstruct = fields(node);
  fieldlist = fields(fieldstruct);
  filtered_fieldlist = {};
  for i=1:numel(fieldlist)
    acc = fieldstruct.(fieldlist{i}).Access;
    if strcmp(acc, 'exposedField') || strcmp(acc, 'eventOut')
      filtered_fieldlist = {filtered_fieldlist{:} fieldlist{i}};
    end
  end
  
  % use the whole list as field names
  fieldname = filtered_fieldlist;
end

% validate FIELDNAME
if ischar(fieldname) 
  fieldname = {fieldname};
elseif ~iscellstr(fieldname)
  error('VR:invalidinarg', 'Field name must be a string or a cell array of strings.');
end

% initialize variables
y = cell(numel(node), numel(fieldname));

% loop through nodes
for i=1:size(y, 1)
  wid = getparentid(node(i));
  
  % loop through fieldnames
  for j=1:size(y, 2)

    % read the field value
    y(i,j) = vrsfunc('VRT3GetField', wid, {node(i).Name}, fieldname(j));

  end
end

% convert to structure if getting all the fields
if nargin < 2
  y = cell2struct(y, fieldname, 2);

  % if no output arguments just print the result
  if nargout == 0
    vrprintval(y);
    clear y;
  end

% handle the scalar case
elseif numel(y) == 1
  y = y{1};
end
