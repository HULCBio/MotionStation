function name = createDefaultName(this, defaultname, parent)
% CREATEDEFAULTNAME Creates a default name for the node based on the name
% passed in DEFAULTNAME and unique under the PARENT level.
%
% PARENT is required since this.up == [] before this node is connected to a
% hierarchy.
%
% NAME = DEFAULTNAME + (idx), where idx is a suitable, unique integer.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:38 $

% Initial name & numeric suffix of next name.
name = defaultname;
idx  = 2;

% Get all the children under the parent
children = parent.getChildren;

if ~isempty(children)
  % Get all siblings
  siblings = children(children ~= this);
  allnames = get( siblings, {'Label'} );
  
  % Find first unused name.
  while any( strcmp(allnames, name) )
    name = sprintf( '%s (%d)', defaultname, idx );
    idx  = idx + 1;
  end
end
