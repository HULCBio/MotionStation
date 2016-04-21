function setfield(node, varargin)
%SETFIELD Change a field value of VRNODE.
%   SETFIELD(NODE, FIELDNAME, FIELDVALUE) changes a field of the node
%   associated with the given VRNODE object.
%
%   SETFIELD(N, FIELDNAME, FIELDVALUE, FIELDNAME, FIELDVALUE, ...)
%   sets multiple property/value or field/value pairs.
%
%   VRML field names are case-sensitive, while property names
%   are not.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2003/04/12 23:21:03 $ $Author: batserve $


% use this overloaded SETFIELD only if the first argument is VRNODE
if ~isa(node, 'vrnode')
  builtin('setfield',node,varargin{:});
  return;
end

% check for invalid nodes
if ~all(isvalid(node))
  error('VR:invalidnode', 'Invalid node.');
end

% prepare cell array pair of names and arguments
[fieldname, fieldval] = vrpreparesetargs(numel(node), varargin, 'field');

% loop through nodes
for i=1:size(fieldval, 1)

  % loop through fieldnames
  for j=1:size(fieldval, 2)
    vrsfunc('VRT3SetField', getparentid(node(i)), {node(i).Name}, fieldname(j), {fieldval{i,j}});
  end
end
