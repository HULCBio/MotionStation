function varargout = get_stateflow_path_to_parent( id, varargin )
% returns the stateflow path of an object
% format:
%  [parentPath, objName] = get_stateflow_path_to_parent( id, pathSeparator )
%  the pathSeparator argument is optional, in which case
%  it defaults to '/'

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $  $Date: 2004/04/15 00:58:08 $

slashChar = '/';
parent = sf('ParentOf', id );
if parent == 0, 
   ancestors = [];
else
   if sf('get', parent, '.isa' )== sf('get', 'default', 'machine.isa' )
      ancestors = parent;
   else
      ancestors = [ parent, sf('AncestorsOf', parent ) ];
   end
end

if nargin >= 2
   pathSep = varargin{1};
else
   pathSep = '/';
end

path = '';
for i = length( ancestors ):-1:1
   path = [path pathSep get_name( ancestors(i) )];
end

if ~isempty(path), path(1) = []; end % get rid of leading path separator
varargout{1} = path;

if nargout > 1
   % return this object's name
   % first, initialize object types
   MACHINE_ISA = sf('get', 'default', 'machine.isa' );
   CHART_ISA = sf('get', 'default', 'chart.isa' );
   TARGET_ISA = sf('get', 'default', 'target.isa' );
   INSTANCE_ISA = sf('get', 'default', 'instance.isa' );
   STATE_ISA = sf('get', 'default', 'state.isa' );
   TRANSITION_ISA = sf('get', 'default', 'transition.isa' );
   JUNCTION_ISA = sf('get', 'default', 'junction.isa' );
   EVENT_ISA = sf('get', 'default', 'event.isa' );
   DATA_ISA = sf('get', 'default', 'data.isa' );
   
   switch sf('get',id,'.isa' )
   case {CHART_ISA, INSTANCE_ISA}
      varargout{2} = get_name( id );
   case {MACHINE_ISA, TARGET_ISA, STATE_ISA, EVENT_ISA, DATA_ISA}
      varargout{2} = sf('get', id, '.name' );
   case TRANSITION_ISA
      varargout{2} = ['Transition ', sf_scalar2str( id )];
   case JUNCTION_ISA
      varargout{2} = ['Junction ', sf_scalar2str( id )];   
   otherwise
      error ('Unexpected object type' );
   end 
end

% this function takes an argument of the id of a hierarchy
% object (i.e. one that can parent and has a .name property)
% and returns its name stripped of path
function name = get_name (id)
CHART_ISA = sf('get', 'default', 'chart.isa' );
INSTANCE_ISA = sf('get', 'default', 'instance.isa' );
switch sf( 'get', id, '.isa')
case CHART_ISA, 
   instanceId = sf( 'get', id, 'chart.instance' );
   blk = sf( 'get', instanceId, 'instance.simulinkBlock' );
   name = get_param( blk, 'Name' );
case INSTANCE_ISA,
   blk = sf( 'get', id, 'instance.simulinkBlock' );
   name = get_param( blk, 'Name' );
otherwise
   % just return the name
   name = sf('get', id, '.name' );
end
