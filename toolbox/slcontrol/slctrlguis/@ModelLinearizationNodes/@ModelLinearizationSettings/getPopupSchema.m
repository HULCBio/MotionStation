function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:36:22 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Task Options');
item1 = JMenuItem('Delete');

Menu.add(item1);
Handles.PopupMenuItems = [item1;];
set(item1, 'ActionPerformedCallback', {@LocalAction, this});
set(item1, 'MouseClickedCallback',    {@LocalAction, this});


% --------------------------------------------------------------------------- %
function LocalAction(eventSrc, eventData, this)
data = get(eventSrc, 'ActionPerformedCallbackData');

%% Get the parent
parent = this.up;

%% Clean up
this.cleanuptask;

%% Remove the node
parent.removeNode(this);

%% Make the parent node the selected node
F = slctrlexplorer;
F.setSelected(parent.getTreeNodeInterface);