function configureComputeOpCondButton(this,DialogPanel)
%  configureComputeOpCondButton  Construct the compute operating condition
%  button

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

%% Set the action callback to compute the operating condition
ComputeOpCondButtonUDD = this.OpCondSpecPanelUDD.getComputeOpCondButton;
h = handle(ComputeOpCondButtonUDD, 'callbackproperties');
h.ActionPerformedCallback = {@LocalComputeOpCond, this};
this.ComputeOpCondButtonUDD = ComputeOpCondButtonUDD;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalComputeOpCond - Callback for computing the operating conditions
function LocalComputeOpCond(es,ed,this)

if this.ComputeOpCondButtonUDD.isSelected
    %% Get the handle to the explorer frame
    ExplorerFrame = slctrlexplorer;

    %% Clear the status area
    ExplorerFrame.clearText;
    
    %% Find the mode that the operating conditions panel is in
    if (this.OpCondSpecPanelUDD.OpCondComputeCombo.getSelectedIndex == 0)
        this.ComputeOpCond;
    else
        awtinvoke(this.ComputeOpCondButtonUDD,'setEnabled',false);
        this.ComputeOpCondSim;
        awtinvoke(this.ComputeOpCondButtonUDD,'setEnabled',true);
    end
    
    %% Set the toggle button to be false
    this.ComputeOpCondButtonUDD.toggleButton(false)
end
