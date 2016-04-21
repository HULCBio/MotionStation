function generic_listeners(this)
% GENERIC_LISTENERS Installs generic listeners for @node objects.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:40 $

% Add property listeners
L = [ handle.listener(this, 'ObjectChildAdded',     @LocalChildAdded); ...
      handle.listener(this, 'ObjectChildRemoved',   @LocalChildRemoved); ...
      handle.listener(this, 'ObjectBeingDestroyed', @LocalObjectBeingDestroyed)];

set(L, 'CallbackTarget', this);
this.TreeListeners = [ this.TreeListeners; L(:) ];

% ---------------------------------------------------------------------------- %
% Child added to the UDD tree
function LocalChildAdded(this, hData)
child    = hData.Child;
children = this.getChildren;

Folder =  this.getTreeNodeInterface;
Leaf   = child.getTreeNodeInterface;

% Find location in UDD tree and insert into same location in the Java tree.
idx = find( children == child );
Folder.insert(Leaf, idx - 1);

% Get top node and fire event.
wksp = handle( Folder.getRoot.getObject );
wksp.firePropertyChange( 'NODES_WERE_INSERTED', [], { Folder, idx - 1, Leaf } );

% Send notification to listening objects.
oldchildren      = children;
oldchildren(idx) = [];
this.firePropertyChange( 'CHILD_LIST_CHANGED', oldchildren, children );

child.generic_listeners;
LocalAddListeners(child);

% ---------------------------------------------------------------------------- %
% Child removed from the UDD tree
function LocalChildRemoved(this, hData)
child    = hData.Child;
children = this.getChildren;

Folder =  this.getTreeNodeInterface;
Leaf   = child.getTreeNodeInterface;

% Remove leaf from  the Java tree and find location in UDD tree.
idx = Folder.getIndex(Leaf) + 1;
Folder.remove(Leaf);

% Get top node and fire event.
wksp = handle( Folder.getRoot.getObject );
wksp.firePropertyChange( 'NODES_WERE_REMOVED', { Folder, idx - 1, Leaf }, [] );

% Send notification to listening objects.
newchildren      = children;
newchildren(idx) = [];
this.firePropertyChange( 'CHILD_LIST_CHANGED', children, newchildren );

% Hide the Dialog panel
if ~isempty( child.Dialog )
  awtinvoke( child.Dialog, 'setVisible', false );
end

% ---------------------------------------------------------------------------- %
% Clean up java objects
function LocalObjectBeingDestroyed(this, hData)
% do nothing

% ---------------------------------------------------------------------------- %
% Add listeners to all children of this node
function LocalAddListeners(node)
children = node.getChildren;

for ct = 1:length(children)
  hData.Child = children(ct);
  LocalChildAdded( node, hData )
end
