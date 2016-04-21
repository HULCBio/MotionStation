function configureFolderPanel(this, manager)
% CONFIGUREFOLDERPANEL 

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:01 $

% Get panel handle
Panel = this.Panel;

% Get the handles
Handles = this.Handles;

% Ancestor added callback
h = handle( Panel, 'callbackproperties' );
h.AncestorAddedCallback = { @LocalUpdatePanel, this };

% New button callback
h = handle( Panel.getNewButton, 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewButton, this, manager };

% Delete button callback
h = handle( Panel.getDeleteButton, 'callbackproperties' );
h.ActionPerformedCallback = { @LocalDeleteButton, this };

% Edit button callback
h = handle( Panel.getEditButton, 'callbackproperties' );
h.ActionPerformedCallback = { @LocalEditButton, this, manager };

% Description field callback
h = handle( Panel.getDescriptionArea, 'callbackproperties' );
h.FocusLostCallback = { @LocalDescriptionUpdate, this };

% Table model callback
h = handle( Panel.getFolderTable.getModel, 'callbackproperties' );
h.TableChangedCallback = { @LocalTableChanged, this };
Handles.TableModel = h;

% Store the handles
this.Handles = Handles;

% Child added/removed listener
L = [ handle.listener( this.Node, 'ObjectChildAdded',   @LocalListChanged); ...
      handle.listener( this.Node, 'ObjectChildRemoved', @LocalListChanged) ];

set(L, 'CallbackTarget', this);
this.Listeners = [ this.Listeners; L(:)];

% ---------------------------------------------------------------------------- %
% Initialize & update components when the panel is shown
function LocalUpdatePanel(hSrc, hData, this)
children = LocalGetAllowedChildren(this);
LocalTableUpdate(this, children);
model = this.Handles.TableModel;
model.tableRowsUpdated( 0, java.lang.Integer.MAX_VALUE );

this.Panel.getDescriptionArea.setText( this.Node.Description );

% ----------------------------------------------------------------------------- %
function LocalNewButton(hSrc, hData, this, manager)
node = this.Node.addNode;

% Expand the tree nodes so the user sees the new node
manager.Explorer.expandNode( this.Node.getTreeNodeInterface );
str = sprintf('- %s node has been added to %s.', node.Label, this.Node.Label );
manager.Explorer.postText( str );

% ---------------------------------------------------------------------------- %
function LocalDeleteButton(hSrc, hData, this)
rows     = this.Panel.getFolderTable.getSelectedRows + 1;
children = LocalGetAllowedChildren(this);

for ct = length(rows):-1:1
  this.Node.removeNode( children( rows(ct) ) );
end

% ---------------------------------------------------------------------------- %
function LocalEditButton(hSrc, hData, this, manager)
row      = this.Panel.getFolderTable.getSelectedRow + 1;
children = LocalGetAllowedChildren(this);

Leaf = children(row).getTreeNodeInterface;
manager.Explorer.setSelected( Leaf );

% ----------------------------------------------------------------------------- %
function LocalDescriptionUpdate(hSrc, hData, this)
this.Node.Description = char( hData.getSource.getText );

% ----------------------------------------------------------------------------- %
% Handle JAVA -> UDD changes
function LocalTableChanged(hSrc, hData, this)
row = hData.getFirstRow;
col = hData.getColumn;

% React only to fireTableCellUpdated(row, col);
if (col < 0) 
  return
end

children = LocalGetAllowedChildren(this);
model    = hData.getSource;

switch col
case 0
  children(row+1).Label = model.getValueAt(row, col);
  
  % Update the table row in case Label change hasn't been accepted.
  if ~strcmp(model.getValueAt(row,col), children(row+1).Label)
    LocalTableUpdate(this, children);
    model.tableRowsUpdated( row, row );
  end
case 1
  children(row+1).Description = model.getValueAt(row, col);
end

% ---------------------------------------------------------------------------- %
% Handle UDD -> JAVA changes
function LocalListChanged(this, hEvent)
child    = hEvent.Child;
children = LocalGetAllowedChildren(this);

if any( strcmp( class(child), this.ExcludeList ) )
  return
end

idx = find( children == child );

if strcmp( hEvent.Type, 'ObjectChildRemoved' )
  children(idx) = [];
  type = javax.swing.event.TableModelEvent.DELETE;
else
  type = javax.swing.event.TableModelEvent.INSERT;
end

LocalTableUpdate(this, children);
model = this.Handles.TableModel;
model.tableChanged( idx-1, idx-1, ...
                    javax.swing.event.TableModelEvent.ALL_COLUMNS, type );

% ----------------------------------------------------------------------------- %
% Updata JAVA table model data
function LocalTableUpdate(this, children)
model = this.Handles.TableModel;

if ~isempty( children )
  table = javaArray('java.lang.Object', length(children), 2);
  
  for ct = 1:length(children)
    current = children(ct);
    table(ct,1) = java.lang.String( current.Label );
    table(ct,2) = java.lang.String( current.Description );
  end
else
  table = {};
end
model.setData( table );

% ----------------------------------------------------------------------------- %
% Get all children that are not excluded
function children = LocalGetAllowedChildren(this)
children = this.Node.getChildren;

% Remove excluded children from bottom
for ct = length(children):-1:1
  cls = class( children(ct) );
  
  if any( strcmp( cls, this.ExcludeList ) )
    children(ct) = [];
  end
end
