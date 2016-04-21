function addListeners( this )
% ADDLISTENERS Add UDD related listeners

% Author(s): John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:05 $

% Add property listeners
L = [ handle.listener(this.Root, 'PropertyChange', @LocalTreeUpdate), ...
      handle.listener(this,'ObjectBeingDestroyed', @LocalObjectBeingDestroyed) ];

set(L, 'CallbackTarget', this);
this.Listeners = L;

% ---------------------------------------------------------------------------- %
% Clean up @node and java objects
function LocalObjectBeingDestroyed(this, hData)
% disp('TreeManager is being destroyed.')

% Delete UDD nodes
delete( this.Root );

% ---------------------------------------------------------------------------- %
% Update the Java tree when nodes are added or removed
function LocalTreeUpdate(this, hEvent)
Tree  = this.ExplorerPanel.getSelector.getTree;
Model = Tree.getModel;

newData = hEvent.newValue;
if strcmp( hEvent.propertyName, 'TREE_NODES_INSERTED')
  Model.nodesWereInserted( newData{1}, newData{2} );
elseif strcmp( hEvent.propertyName, 'TREE_NODES_REMOVED')
  Model.nodesWereRemoved( newData{1}, newData{2}, newData(3)  );
end