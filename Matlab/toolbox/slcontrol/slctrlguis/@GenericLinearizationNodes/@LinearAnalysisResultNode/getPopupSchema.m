function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/11 00:35:43 $

[menu, Handles] = LocalDialogPanel(this,manager );
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

%% Configure a listener to the label changed event
this.addListeners(handle.listener(this,this.findprop('Label'),'PropertyPostSet',...
                        {@LocalLabelChanged, this}));

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this,manager)
import javax.swing.*;

Menu = JPopupMenu('Linear Analysis Result');

item1 = JMenuItem('Delete');
item2 = JMenuItem('Rename');
item3 = JMenuItem('Export');
item4 = JMenuItem('Highlight Blocks in Linearization');
item5 = JMenuItem('Remove Highlighting');

Menu.add(item1);
Menu.add(item2);
Menu.add(item3);
Menu.add(item4);
Menu.add(item5);
Handles.PopupMenuItems = [item1; item2; item3; item4; item5];
set(item1, 'ActionPerformedCallback', {@LocalDelete, this});
set(item1, 'MouseClickedCallback',    {@LocalDelete, this});
set(item2, 'ActionPerformedCallback', {@LocalRename, this, manager});
set(item2, 'MouseClickedCallback',    {@LocalRename, this, manager});
set(item3, 'ActionPerformedCallback', {@LocalExportAction, this});
set(item3, 'MouseClickedCallback',    {@LocalExportAction, this});
set(item4, 'ActionPerformedCallback', {@LocalHiliteAction, this});
set(item4, 'MouseClickedCallback',    {@LocalHiliteAction, this});
set(item5, 'ActionPerformedCallback', {@LocalRemoveHiliteAction, this});
set(item5, 'MouseClickedCallback',    {@LocalRemoveHiliteAction, this});

% --------------------------------------------------------------------------- %
function LocalDelete(eventSrc, eventData, this)
data = get(eventSrc, 'ActionPerformedCallbackData');

%% Delete the current node
parent = this.up;
parent.removeNode(this);

%% Make the parent node the selected node
F = slctrlexplorer;
F.setSelected(parent.getTreeNodeInterface);


% --------------------------------------------------------------------------- %
function LocalExportAction(eventSrc, eventData, this)
data = get(eventSrc, 'ActionPerformedCallbackData');

%% Export the lti object to the workspace
Label = regexprep(this.Label,' ','');
Label = regexprep(Label,'(','');
Label = regexprep(Label,')','');
defaultnames = {sprintf('%s_sys',Label),sprintf('%s_op',Label)};
exporteddata = {this.LinearizedModel,this.OpCondData};
export2wsdlg({'Linearized Model','Operating Point'},defaultnames,exporteddata)

% --------------------------------------------------------------------------- %
function LocalHiliteAction(eventSrc, eventData, this)

this.HiliteBlocksInLinearization

% --------------------------------------------------------------------------- %
function LocalRemoveHiliteAction(eventSrc, eventData, this)

blocks = find_system(this.OpCondData.Model);
hilite_system(blocks,'none')

% --------------------------------------------------------------------------- %
function LocalRename(hSrc, hData, this, manager)
Tree = manager.ExplorerPanel.getSelector.getTree;
Tree.startEditingAtPath(Tree.getSelectionPath);

% --------------------------------------------------------------------------- %
function LocalLabelChanged(es,ed,this)
%% Get the parent node
parent = this.up;
if isa(parent,'ModelLinearizationNodes.ModelLinearizationSettings') ||...
        isa(parent,'BlockLinearizationNodes.BlockLinearizationSettings')
    %% Get all the analysis results
    ch = parent.getChildren;
    row = find(this == ch);
    eventData = ctrluis.dataevent(parent,'AnalysisLabelChanged',row);
    send(parent, 'AnalysisLabelChanged', eventData);
end