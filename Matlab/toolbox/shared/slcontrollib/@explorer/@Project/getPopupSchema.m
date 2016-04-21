function menu = getPopupSchema(this, manager)
% GETPOPUPSCHEMA Constructs the default popup menu

% Author(s): John Glass, Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:18 $

menu  = com.mathworks.mwswing.MJPopupMenu('Default Menu');
item1 = com.mathworks.mwswing.MJMenuItem('Save...');
item2 = com.mathworks.mwswing.MJMenuItem('Delete');
item3 = com.mathworks.mwswing.MJMenuItem('Rename');

menu.add( item1 );
menu.add( item2 );
menu.addSeparator;
menu.add( item2 );
menu.add( item3 );

h = handle( item1, 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSave, this, manager };
h.MouseClickedCallback    = { @LocalSave, this, manager };

h = handle( item2, 'callbackproperties' );
h.ActionPerformedCallback = { @LocalDelete, this, manager };
h.MouseClickedCallback    = { @LocalDelete, this, manager };

h = handle( item3, 'callbackproperties' );
h.ActionPerformedCallback = { @LocalRename, this, manager };
h.MouseClickedCallback    = { @LocalRename, this, manager };

% --------------------------------------------------------------------------- %
function LocalSave(hSrc, hData, this, manager)
manager.saveas(this)

% --------------------------------------------------------------------------- %
function LocalDelete(hSrc, hData, this, manager)
parent = this.up;
parent.removeNode(this);
manager.Explorer.setSelected(parent.getTreeNodeInterface);

% --------------------------------------------------------------------------- %
function LocalRename(hSrc, hData, this, manager)
Tree = manager.ExplorerPanel.getSelector.getTree;
Tree.startEditingAtPath(Tree.getSelectionPath);
