function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2003/12/04 01:35:10 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Scenarios');

item1 = JMenuItem('New Scenario');

Menu.add(item1);

Handles.PopupMenuItems = [item1];
set(item1, 'ActionPerformedCallback', {@LocalAction, this});
set(item1, 'MouseClickedCallback',    {@LocalAction, this});

% --------------------------------------------------------------------------- %
function LocalAction(eventSrc, eventData, this)

this.addScenario;