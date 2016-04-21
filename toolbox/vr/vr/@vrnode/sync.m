function x = sync(node, varargin)
%SYNC Synchronize a VRML field with clients.
%   SYNC(NODE, FIELDNAME, 'on') enables synchronization of the given
%   virtual reality node's field with the clients.
%   When the field synchronization is enabled, the field value will be
%   updated every time it's changed on client. When it is disabled,
%   the field value will only reflect settings from MATLAB or Simulink.
%
%   Synchronization is meaningful only for readable fields,
%   i.e. eventOuts and exposedFields. It is not possible to enable
%   synchronization for eventIns or non-exposed fields.
%
%   SYNC(NODE, FIELDNAME, 'off') disables the synchronization.
%   X = SYNC(NODE, FIELDNAME) returns the synchronization status.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.10.4.4 $ $Date: 2004/03/15 22:35:29 $ $Author: batserve $


% initialize variables
offon = {'off', 'on'};


%%%%%%%%%
%% GET %%
%%%%%%%%%

% return status if we have less than three arguments
if nargin<3

  % sync status for all fields of a node
  if nargin<2
    if length(node)>1
      error('VR:invalidinarg', 'Vector of nodes not allowed if field name not given.');
    end
    fieldname = get(node, 'Fields');
  else
    fieldname = varargin{1};
  end

  % check arguments
  if ischar(fieldname)
    fieldname = {fieldname};
  elseif ~iscellstr(fieldname)
    error('VR:invalidinarg', 'Field name must be a string or a cell array of strings.');
  end

  % scalar expansion
  if numel(node) == 1
    node(1:numel(fieldname)) = node;
  elseif numel(node) ~= numel(fieldname)
    error('VR:invalidinarg', 'There must be a field name for each node.');
  end

  % read all the nodes in a loop
  x = cell(1,numel(node));
  for i=1:numel(node)
    wid = getparentid(node(i));
    x(i) = offon(vrsfunc('GetWatch', wid, node(i).Name, fieldname{i}) + 1);
  end

  % convert to structure if getting status for all the fields
  if nargin < 2
    x = cell2struct(x, fieldname, 2);

    % if no output arguments just print the result
    if nargout == 0
      vrprintval(x);
      clear x;
    end

  % handle the scalar case
  elseif numel(x) == 1
    x = x{1};
  end

  return;
end



%%%%%%%%%
%% SET %%
%%%%%%%%%

% prepare cell array pair of names and arguments
[fieldname, fieldval] = vrpreparesetargs(numel(node), varargin, 'field');

% loop through nodes
for i=1:size(fieldval, 1)
  wid = getparentid(node(i));

  % loop through fieldnames
  for j=1:size(fieldval, 2)
    val = fieldval{i,j};
    if ischar(val)
      val = logical(find(strcmpi(val,offon))-1);
    end
    if ~islogical(val) || isempty(val)
      error('VR:invpropval', 'Value for SYNC must be either ''on'' or ''off''.');
    end

    % set the field value
    vrsfunc('SetWatch', wid, node(i).Name, fieldname{j}, double(val));
    
  end
end
