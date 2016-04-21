function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2004/04/10 23:35:49 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Controller');

item2 = JMenuItem('Copy Controller');
item3 = JMenuItem('Delete Controller');
item4 = JMenuItem('Rename Controller');
item5 = JMenuItem('Export Controller');

Menu.add(item2);
Menu.add(item3);
Menu.add(item4);
Menu.add(item5);

Handles.PopupMenuItems = [item2; item3; item4; item5];
set(item2, 'ActionPerformedCallback', {@LocalAction, this});
set(item2, 'MouseClickedCallback',    {@LocalAction, this});
set(item3, 'ActionPerformedCallback', {@LocalAction, this});
set(item3, 'MouseClickedCallback',    {@LocalAction, this});
set(item4, 'ActionPerformedCallback', {@LocalAction, this});
set(item4, 'MouseClickedCallback',    {@LocalAction, this});
set(item5, 'ActionPerformedCallback', {@LocalAction, this});
set(item5, 'MouseClickedCallback',    {@LocalAction, this});

% --------------------------------------------------------------------------- %
function LocalAction(eventSrc, eventData, this)
data = get(eventSrc, 'ActionPerformedCallbackData');

if strcmpi(data.actionCommand, 'Copy controller')
    this.up.copyController(this.Label);
elseif strcmpi(data.actionCommand, 'Delete controller')
    this.up.deleteController(this.Label);
elseif strcmpi(data.actionCommand, 'Rename controller')
    OldName = this.Label;
    NewName = this.up.getNewControllerName({OldName});
    if length(deblank(NewName)) > 0
        OK = this.renameController(OldName, NewName);
    end
elseif strcmpi(data.actionCommand, 'Export controller')
    this.getRoot.Handles.mpcExporter.show;
end
