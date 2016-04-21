function panel = getDialogInterface(this, manager)

% GETDIALOGINTERFACE  Define pointer to dialog panel
 
%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2004/04/10 23:36:12 $

% This version is specific to the root node.
if this.Reset
    % We're resetting to accommodate a new structure.
    % Clear the Controllers and Scenarios nodes
    this.getMPCControllers.clearNode;
    this.getMPCSims.clearNode;
    % Recreate initial state for Controllers
    this.addNode(mpcnodes.MPCControllers('Controllers'));
    MPCControllers = this.getMPCControllers;
    MPCControllers.addNode(mpcnodes.MPCController('MPC1'));
    MPCControllers.Controllers = {'MPC1'};
    ModelName = this.getMPCModels.Models(1).Name;
    MPCControllers.getChildren.ModelName = ModelName;
    % Also initial state for Scenarios
    this.addNode(mpcnodes.MPCSims('Scenarios'));
    MPCSims = this.getMPCSims;
    MPCSims.addNode(mpcnodes.MPCSim('Scenario1'));
    Sim = MPCSims.getChildren;
    Sim.PlantName = ModelName;
    Sim.ControllerName = 'MPC1';
    % Toggle reset indicator
    this.Reset = false;
end
this.Dialog = this.getDialogSchema(manager);
panel = this.Dialog;
% Inform dialogs that this node has been selected.
this.setDialogHandles;

