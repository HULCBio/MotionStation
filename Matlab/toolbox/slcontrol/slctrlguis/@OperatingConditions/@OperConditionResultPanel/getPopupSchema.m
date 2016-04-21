function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $$ $Date: 2004/04/11 00:36:29 $

[menu, Handles] = LocalDialogPanel(this,manager);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

%% Configure a listener to the label changed event
this.addListeners(handle.listener(this,this.findprop('Label'),'PropertyPostSet',...
                        {@LocalLabelChanged, this}));

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this,manager)
import javax.swing.*;

Menu = JPopupMenu('Operating Point Result');

item1 = JMenuItem('Export');
item2 = JMenuItem('Rename');
Menu.add(item1);
Menu.add(item2);

Handles.PopupMenuItems = [item1;item2];
set(item1, 'ActionPerformedCallback', {@LocalExportAction, this});
set(item1, 'MouseClickedCallback',    {@LocalExportAction, this});
set(item2, 'ActionPerformedCallback', {@LocalRename, this, manager});
set(item2, 'MouseClickedCallback',    {@LocalRename, this, manager});

% --------------------------------------------------------------------------- %
function LocalExportAction(eventSrc, eventData, this)
data = get(eventSrc, 'ActionPerformedCallbackData');

%% Export the lti object to the workspace
defaultnames = {sprintf('oppoint_%s',this.up.Model),sprintf('opreport_%s',this.up.Model)};
exporteddata = {this.OpPoint,this.OpReport};
export2wsdlg({'Operating Point','Operating Report'},defaultnames,exporteddata)

% --------------------------------------------------------------------------- %
function LocalRename(hSrc, hData, this, manager)
Tree = manager.ExplorerPanel.getSelector.getTree;
Tree.startEditingAtPath(Tree.getSelectionPath);

% --------------------------------------------------------------------------- %
function LocalLabelChanged(es,ed,this)
%% Get the parent node
parent = this.up;
if isa(parent,'OperatingConditions.OperatingConditionTask');
    send(parent, 'OpPointDataChanged');
end