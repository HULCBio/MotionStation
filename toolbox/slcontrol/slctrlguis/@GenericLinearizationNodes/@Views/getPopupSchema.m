function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:36:13 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Custom Views');

item1 = JMenuItem('Add View');

Menu.add(item1);
Handles.PopupMenuItems = [item1;];
set(item1, 'ActionPerformedCallback', {@LocalAction, this});
set(item1, 'MouseClickedCallback',    {@LocalAction, this});


% --------------------------------------------------------------------------- %
function LocalAction(eventSrc, eventData, this)
data = get(eventSrc, 'ActionPerformedCallbackData');

%% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

%% Clear the status area
ExplorerFrame.clearText;

%% Create the view settings node
ViewSettingsNode = GenericLinearizationNodes.ViewSettings(length(this.getChildren)+1);

%% Add the view settings node to the tree
this.addNode(ViewSettingsNode);
%% Expand the views nodes so the user sees the new result
ExplorerFrame.expandNode(this.getTreeNodeInterface);

ExplorerFrame.postText(sprintf(' - A new view has been added.'))