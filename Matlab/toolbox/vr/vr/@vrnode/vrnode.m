function n = vrnode(world, nodename, nodetype, newtype)
%VRNODE Create a VRNODE handle to an existing or a new node.
%   N = VRNODE(W, NODENAME) creates a new VRNODE handle for an existing
%   named node from a virtual world associated with the VRWORLD handle W.
%
%   N = VRNODE creates an empty VRNODE handle which does not
%   reference any node.
%
%   N = VRNODE([]) creates an empty array of VRNODE handles.
%
%   N = VRNODE(W, NODENAME, NODETYPE) creates a new named node of name
%   NODENAME and type NODETYPE on root of the world W and returns the VRNODE
%   handle to the newly created node.
%
%   N = VRNODE(PARENTNODE, PARENTFIELD, NODENAME, NODETYPE) creates a new
%   named node of name NODENAME and type NODETYPE which is a child of node
%   PARENTNODE and resides in field PARENTFIELD. The VRNODE handle to the newly
%   created node is returned.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.10.2.4 $ $Date: 2003/07/11 16:01:51 $ $Author: batserve $


% if no arguments create an empty VRNODE
if nargin==0
  This = struct('World', vrworld, 'Name', '');
  n = class(This, 'vrnode');
  return;
end;

% return VRNODE 0x0 array for VRNODE([]) or for VRNODE(W, [])
if isempty(world) || isempty(nodename)
  This = struct('World', {}, 'Name', {});
  n = class(This, 'vrnode');
  return;
end;

% check WORLD argument - must be a world unless we have 4 arguments when it is a node
if nargin<4
  if ~isa(world, 'vrworld')
    error('VR:invalidinarg', 'WORLD must be of type VRWORLD.');
  end
  if numel(world)>1
    error('VR:invalidinarg', 'WORLD cannot be an array.');
  end
  sw = struct(world);
  wid = sw.id;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<3       % create reference to existing nodes
        
% if node names are strings validate them
if ~ischar(nodename) && ~iscellstr(nodename)
  error('VR:invalidinarg', 'NAME must be a string or a cell array of strings.');
end

% convert a simple string to cell array containing a single string
if ischar(nodename)
  nodename = { nodename };
end

% check if the nodes exist
for i=1:numel(nodename)
  sw = struct(world);
  wid = sw.id;
  if ~vrsfunc('VRT3NodeExists', wid, nodename{i})
    error('VR:nodenotfound', ['Node ''' nodename{i} ''' not found.']);
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif nargin == 3   % create new nodes on root

% validate arguments
[nodename, nodetype] = checknewnode(nodename, nodetype);

% create the nodes
for i=1:numel(nodename)
  vrsfunc('AddNode', wid, '', '', nodename{i}, nodetype{i});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else   % nargin == 4  : create new nodes parented by another node

% reshuffle arguments to assign meaningful names
parentnode = world;
parentfield = nodename;
nodename = nodetype;
nodetype = newtype;
world = parentnode.World;

% validate arguments
if ~isa(parentnode, 'vrnode')
  error('VR:invalidinarg', 'PARENTNODE must be of type VRNODE.');
end
if numel(parentnode)>1
  error('VR:invalidinarg', 'PARENTNODE cannot be an array.');
end
if ~ischar(parentfield)
  error('VR:invalidinarg', 'PARENTFIELD must be a string.');
end
[nodename, nodetype] = checknewnode(nodename, nodetype);

% create the node
wid = getparentid(parentnode);
for i=1:numel(nodename)
  vrsfunc('AddNode', wid, parentnode.Name, parentfield, nodename{i}, nodetype{i});
end

end

% finally create the VRNODE handles to the validated or created nodes
This = struct('World', world, 'Name', nodename);
n = class(This, 'vrnode');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check new node and type validity
function [nodename, nodetype] = checknewnode(nodename, nodetype)

if ischar(nodename) && ischar(nodetype)
  nodename = {nodename};
  nodetype = {nodetype};
elseif ~(iscellstr(nodename) && iscellstr(nodetype) && numel(nodename)==numel(nodetype))
  error('VR:invalidinarg', 'NODENAME and NODETYPE must be either strings or equally sized cell arrays of strings.');
end
