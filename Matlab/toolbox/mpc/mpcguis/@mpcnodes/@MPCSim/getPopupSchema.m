function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2003/12/04 01:35:03 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Scenario');

item2 = JMenuItem('Copy Scenario');
item3 = JMenuItem('Delete Scenario');
item4 = JMenuItem('Rename Scenario');

Menu.add(item2);
Menu.add(item3);
Menu.add(item4);

Handles.PopupMenuItems = [item2; item3; item4];
set(item2, 'ActionPerformedCallback', {@LocalAction, this});
set(item2, 'MouseClickedCallback',    {@LocalAction, this});
set(item3, 'ActionPerformedCallback', {@LocalAction, this});
set(item3, 'MouseClickedCallback',    {@LocalAction, this});
set(item4, 'ActionPerformedCallback', {@LocalAction, this});
set(item4, 'MouseClickedCallback',    {@LocalAction, this});

% --------------------------------------------------------------------------- %
function LocalAction(eventSrc, eventData, this)
data = get(eventSrc, 'ActionPerformedCallbackData');

if strcmpi(data.actionCommand, 'Copy Scenario')
    this.up.copyScenario(this.Label);
elseif strcmpi(data.actionCommand, 'Delete Scenario')
    this.up.deleteScenario(this.Label);
elseif strcmpi(data.actionCommand, 'Rename Scenario')
    OldName = this.Label;
    NewName = this.up.getNewSimName({OldName});
    if length(deblank(NewName)) > 0
        this.renameScenario(OldName, NewName);
    end
end
