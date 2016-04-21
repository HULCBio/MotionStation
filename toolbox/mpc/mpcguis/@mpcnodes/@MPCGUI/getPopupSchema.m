function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2004/04/10 23:36:19 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Models');

item1 = JMenuItem('Import Plant Model');
item1a = JMenuItem('Import Controller');
item2 = JMenuItem('Clear Project');
item3 = JMenuItem('Delete Project');

Menu.add(item1);
Menu.add(item1a);
Menu.add(item2);
Menu.add(item3);

Handles.PopupMenuItems = [item1; item2];
set(item1, 'ActionPerformedCallback', {@LocalImportAction, this});
set(item1, 'MouseClickedCallback',    {@LocalImportAction, this});
set(item1a, 'ActionPerformedCallback', {@LocalImportMPCAction, this});
set(item1a, 'MouseClickedCallback',    {@LocalImportMPCAction, this});
set(item2, 'ActionPerformedCallback', {@LocalClearAction, this});
set(item2, 'MouseClickedCallback',    {@LocalClearAction, this});
set(item3, 'ActionPerformedCallback', {@LocalDeleteAction, this});
set(item3, 'MouseClickedCallback',    {@LocalDeleteAction, this});

% --------------------------------------------------------------------------- %
function LocalImportAction(eventSrc, eventData, this)

I = this.Handles.ImportLTI;
I.javasend('Show' ,'dummy', I);

% --------------------------------------------------------------------------- %
function LocalImportMPCAction(eventSrc, eventData, this)

I = this.Handles.ImportMPC;
I.javasend('Show' ,'dummy', I);

% --------------------------------------------------------------------------- %
function LocalClearAction(eventSrc, eventData, this)

Msg = sprintf(['Clearing will erase all models, controllers, ', ...
    'and scenarios in this design.  You might want to save', ...
    ' the design before clearing.\n\n', ...
    'Clear "%s" now?'], this.Label);
ButtonName = questdlg(Msg, 'Confirm to Clear Design', 'Yes', 'No', 'No');
switch ButtonName
case 'No'
    % Return without doing anything
    return
case 'Yes'
    % Clear the design
    this.clearTool;
end

% --------------------------------------------------------------------------- %

function LocalDeleteAction(eventSrc, eventData, this)
Msg = sprintf('Are you sure you want to delete project "%s"?', ...
    this.Label);
Button = questdlg(Msg, 'Confirm to Delete Project', 'Yes', 'No', 'No');
Parent = this.up;
Manager = this.TreeManager;
Frame = this.Frame;
if strcmpi(Button, 'Yes')
    Parent.removeNode(this);
end
% Select an existing project, if any.
% Also make sure the window closing event points to a valid project.
Projects = Parent.getChildren;
if ~isempty(Projects)
    P = Projects(1);
else
    P = Parent;
end
Manager.Explorer.setSelected(P.getTreeNodeInterface);
if isa(P, 'mpcnodes.MPCGUI') && ~P.ModelImported
    P.TreeManager.Explorer.collapseNode(P.TreeNode);
end

set(Frame,'WindowClosingCallback',{@ClosingMPCGUI, P});
