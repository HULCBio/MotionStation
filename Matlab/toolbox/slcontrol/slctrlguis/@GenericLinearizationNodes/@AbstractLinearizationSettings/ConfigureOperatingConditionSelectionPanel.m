function ConfigureOperatingConditionSelectionPanel(this,DialogPanel);
% ConfigureOperatingConditionSelectionPanel

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/04 02:37:14 $

this.OpCondSelectionPanelUDD = jOperatingConditionSpecificationPanels.OperatingConditionSelectionPanel(...
                                    DialogPanel.getOpCondSelectPanel,this.getOpCondNode);
                                

CreateConditionButtonUDD = DialogPanel.OpCondPanel.getCreateConditionButton;
set(CreateConditionButtonUDD,'ActionPerformedCallback',{@LocalCreateConditionCallback,this})
this.CreateConditionButtonUDD = CreateConditionButtonUDD;

ViewConditionButtonUDD = DialogPanel.OpCondPanel.getViewConditionButton;
set(ViewConditionButtonUDD,'ActionPerformedCallback',{@LocalViewConditionCallback,this})
this.ViewConditionButtonUDD = ViewConditionButtonUDD;    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalCreateConditionCallback - Callback to select the operating
%% conditions creation node
function LocalCreateConditionCallback(es,ed,this)

%% Get the operating conditions node
OperCondNode = this.getOpCondNode;

%% If the dialog panel has not been created then create it
if isempty(OperCondNode.Dialog)
    [Frame,Worspace,Manager] = slctrlexplorer;
    OperCondNode.getDialogInterface(Manager);
end

%% Set the operating condition creation tab as selected
OperCondNode.Dialog.getTabbedPane.setSelectedIndex(1);

%% Select the operating condition node
Frame = slctrlexplorer;
Frame.setSelected(OperCondNode.getTreeNodeInterface);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalViewConditionCallback - Callback to view the selected operating
%% condition.
function LocalViewConditionCallback(es,ed,this)

%% Get the first selected row
idx = this.OpCondSelectionPanelUDD.JavaPanel.OpCondTable.getSelectedRow + 1;

%% Get the operating conditions node
OperCondNode = this.getOpCondNode;

%% Get the operating condition children
Children = OperCondNode.getChildren;

%% Set the selected node
Frame = slctrlexplorer;
Frame.setSelected(Children(idx).getTreeNodeInterface);