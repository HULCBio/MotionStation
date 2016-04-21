function addListeners( this )
% ADDLISTENERS Add UDD related listeners

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:22 $

% Add property listeners
L = [ handle.listener(this.Root, 'PropertyChange', @LocalTreeUpdate), ...
      handle.listener(this,'ObjectBeingDestroyed', @LocalObjectBeingDestroyed) ];

set(L, 'CallbackTarget', this);
this.Listeners = L;

% ---------------------------------------------------------------------------- %
% Clean up @node and java objects
function LocalObjectBeingDestroyed(this, hData)
% Delete JAVA frame
this.Explorer.dispose;

% Delete UDD nodes
delete( this.Root );

% ---------------------------------------------------------------------------- %
% Update the Java tree when nodes are added or removed
function LocalTreeUpdate(this, hEvent)
Tree  = this.ExplorerPanel.getSelector.getTree;
Model = Tree.getModel;

switch hEvent.propertyName
case 'NODES_WERE_INSERTED'
  newData = hEvent.newValue;
  Model.insertNodes( newData{1}, newData{2} );
case 'NODES_WERE_REMOVED'
  oldData = hEvent.oldValue;
  Model.removeNodes( oldData{1}, oldData{2}, oldData(3)  );
  
  % Select the closest relative if the removed leaf was selected
  %if ~isempty(this.ExplorerPanel.getSelected)
  %  this.ExplorerPanel.setSelected( LocalGetClosestRelative( oldData ) );
  %end
case 'NODE_CHANGED'
  newData = hEvent.newValue;
  Model.changeNode( newData{1} );
end

% Flush the event queue
drawnow;
  
% -----------------------------------------------------------------------------
function Leaf = LocalGetClosestRelative( LeafData )
Folder = LeafData{1};
idx    = LeafData{2}; % Java indexing

ChildCount = Folder.getChildCount;
if ( ChildCount == 0 ) 
  Leaf = Folder;
elseif ( ChildCount > idx )
  Leaf = Folder.getChildAt(idx);
else
  Leaf = Folder.getChildAt(idx-1);
end
