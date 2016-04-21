function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2004/04/10 23:36:02 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Scenarios');

item1 = JMenuItem('New Controller');
item2 = JMenuItem('Import Controller');
item3 = JMenuItem('Export Controller');

Menu.add(item1);
Menu.add(item2);
Menu.add(item3);

Handles.PopupMenuItems = [item1; item2; item3];
set(item1, 'ActionPerformedCallback', {@LocalNewAction, this});
set(item1, 'MouseClickedCallback',    {@LocalNewAction, this});
set(item2, 'ActionPerformedCallback', {@LocalImportAction, this});
set(item2, 'MouseClickedCallback',    {@LocalImportAction, this});
set(item3, 'ActionPerformedCallback', {@LocalExportAction, this});
set(item3, 'MouseClickedCallback',    {@LocalExportAction, this});

% --------------------------------------------------------------------------- %

function LocalNewAction(eventSrc, eventData, this)
% Respond to New Controller menu item
this.addController;

% --------------------------------------------------------------------------- %

function LocalImportAction(eventSrc, eventData, this)
% Respond to Import Controller menu item
I = this.up.Handles.ImportMPC;
I.javasend('Show', 'dummy', I);

% --------------------------------------------------------------------------- %

function LocalExportAction(eventSrc, eventData, this)
% Respond to Export Controller menu item
this.up.Handles.mpcExporter.show;
