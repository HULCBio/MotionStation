function postLoad(this, manager)

%  POSTLOAD
%
%  Restore gui state after load

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2004/04/10 23:36:22 $

%% If the task belongs to a Simulink project open the Simulink model
if ~isempty(this.Block)
    I = strfind(this.Block,'/');
    try
        if ~isempty(I)
            thismodel = this.Block(1:I(1)-1);
        else
            thismodel = this.Block;      
        end
        open_system(thismodel);
    catch
        localAbort(this, manager)
        return
    end
end

% Force creation of the MPCGUI dialog panel
this.getDialogInterface(manager);
manager.Explorer.setSelected(this.getTreeNodeInterface);
this.TreeManager = manager;
this.Frame = manager.Explorer;
% Also wake up the MPCModels, MPCControllers, and MPCSims nodes
if this.ModelImported
    MPCModels = this.getMPCModels;
    MPCModels.getDialogInterface(manager);
    MPCControllers = this.getMPCControllers;
    MPCControllers.getDialogInterface(manager);
    MPCSims = this.getMPCSims;
    MPCSims.getDialogInterface(manager);
end

% If this is a Simulink task build the connection between the right block
% and the newly loaded task
if ~isempty(this.Block)
    mpcobj = MPCControllers.getController(MPCControllers.CurrentController);
    % MPC GUI needs to have the mpc object used by the block in the
    % workspace. If a var of that name is there already check that its ok
    % to overwrite
    if any(strcmp(MPCControllers.CurrentController,evalin('base','who'))) 
           ButtonOverWrite = questdlg(sprintf( ...
             'There is already a variable %s in the workspace. Overwrite?', ...
             MPCControllers.CurrentController), 'MPC Toolbox','Yes','No','Yes');
        if strcmp(ButtonOverWrite,'No')
             localAbort(this, manager)
             return
        end
    end
    % Overwrite
    assignin('base',MPCControllers.CurrentController,mpcobj);
    try
        mpc_mask('openhidden',thismodel,[],this.Block, ...
            MPCControllers.CurrentController);  
    catch
        msg = 'There is a mismatch between the saved project and the associated Simulink model.';
        errordlg(msg,'MPC Toolbox','modal')
        return
    end
end

% Set Dirty flag to false (in case it hasn't been done automatically).
this.Dirty = false;


function localAbort(this,manager)

msg = sprintf('Cannot open the Simulink model containing %s', ...
    this.Block);
manager.Explorer.postText(msg);
this.up.removeNode(this);
