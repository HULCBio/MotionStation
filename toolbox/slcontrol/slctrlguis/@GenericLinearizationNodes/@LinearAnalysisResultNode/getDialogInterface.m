function panel = getDialogInterface(this, manager)
%%  GETDIALOGINTERFACE  Construct the dialog panel

%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.

%% Get the dialog, create it if needed.
if isempty(this.Dialog)
    this.Dialog = getDialogSchema(this);
else
    if ~isempty(this.ModelJacobian)
        %% Set the selected node on the block linearization panel.
        exp = this.Dialog.getLinearizationInspectPanel;
        exp.setSelected(this.InspectorNode.getTreeNodeInterface);
    end
end
panel = this.Dialog;