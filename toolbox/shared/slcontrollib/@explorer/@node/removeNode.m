function removeNode(this, leaf)
% REMOVENODE Removes the LEAF node from THIS node.  Note that this will not
% destroy the LEAF node unless there is no reference left to it somewhere else.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:51 $

children = this.getChildren;

% Is leaf really a child of this?
if any( children == leaf )
  % Disconnect from the tree
  disconnect( leaf )
  
  % Remove all listeners
  delete( leaf.TreeListeners( ishandle(leaf.TreeListeners) ) )
  leaf.TreeListeners = [];
  
  delete( leaf.Listeners( ishandle(leaf.Listeners) ) )
  leaf.Listeners = [];
  
  % Delete leaf node
  delete( leaf );
elseif isa( leaf, 'explorer.node' )
  warning( '%s is not a leaf node of %s', leaf.Label, this.Label )
else
  error( '%s is not of type @explorer/@node', class(leaf) )
end
