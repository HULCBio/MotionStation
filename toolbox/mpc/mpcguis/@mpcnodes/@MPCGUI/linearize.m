function newNodeName = linearize(mpcnode,opcondtask,M,constrSrcNode,varargin)

% Copyright 2003-2004 The MathWorks, Inc.

% Callback for the "OK" button in the linearization import
% dialog.constrSrcNode
% Also used by the MPC mask to build a linearized plant model from scratch
% If constrSrcNode is empty the mpcnode i/o table is used to supply 
% i/o constrained values.

thisExplorer =  M.Explorer;
if nargin<=4
    progress = [];
else
    progress = varargin{1};
end
newNodeName = '';

%% Set the optimization method to nonlinear least squares which seems to be
%% more robust when the trim problem is overdetermined
opt = linoptions;
if license('test','Optimization_Toolbox')
    opt.OptimizerType = 'lsqnonlin';
end
opt.DisplayReport = 'off'; % None verbose mode

%% Check that the MPC block will compile
if isempty(get_param(mpcnode.Block,'mpcobj')) && ...
        get_param(mpcnode.Block,'n_mv')==0
    prompt= {['Specify number of Manipulated Variables (MVs) for ' mpcnode.Block]};
    answer = inputdlg(prompt,'Open loop MPC block',1,{'0'});
    if isempty(answer)
        return
    else
        try
            nu = str2num(answer{1});
        catch
            errordlg('Invalid entry','Model Predictive Control Toolbox', ...
                'modal')
            return
        end
        if ~isscalar(nu) || nu<1
            errordlg('Invalid entry','Model Predictive Control Toolbox',...
                'modal')
            return 
        end
    end
    set_param(mpcnode.Block,'n_mv',sprintf('%d',nu));
end
    

localsetprogress(thisExplorer,progress,1,40,...
    'Setting up linearization i/o points and output contraints...','')

%% Sync the mpc linearization dialog with the model which may have been
%% changed manually by the user prior to hitting the "OK" button
mpcnode.Linearization.refresh;

%% Store the current io object
thislinio = getlinio(opcondtask.Model);
modelio = [];
if ~isempty(thislinio)
    modelio = copy(thislinio); % Remember model i/o
end

%% Assign linearized model inputs not at the MPC block output to the MD grp
try
    mdrows = mpcblockiotable(mpcnode.Linearization.IOdata, ...
        mpcnode.Block,opcondtask.Model);
catch
    setlinio(opcondtask.Model,modelio); % Revert model i/o
    msg = ['Could not assign linearization i/o. Message returned was: ' lasterr];
    errordlg(msg,'Model Predictive Control Toolbox','modal')
    return
end

%% Update the linearization table again in case any nodes have been added or
%% de-activated by the call to mpcblockiotable
mpcnode.Linearization.refresh

%% Grab new name string
newname = char(mpcnode.linearization.LinearizationDialog.nameTxt.getText);

%% Refresh opspec at constraint node in case the user 
%% has modifified the number of states in the model
localRefreshOpCondNodes(opcondtask,M)

localsetprogress(thisExplorer,progress,2,60,...
    'Trimming the model...','')

%% Create/get new operating point and report either using nominal values in
%% the MPCGUI table or using an existing operating condition node 
if isempty(constrSrcNode)

%% Update the states table in case the number of model states has changed
    if ~isempty(opcondtask.Dialog)
        opcondtask.configureStateConstraintTable
    end

%% Assign output constraints to nominal table values
    if strcmp(get_param(opcondtask.Model, 'SimulationStatus'),'stopped')
       feval(opcondtask.Model,[],[],[],'compile');
    end
    newOpSpecData = mpcnode.getNominal(opcondtask.OpSpecData);
    feval(opcondtask.Model,[],[],[],'term');

%%  If no opspec object was created the getNominal failed
    if isempty(newOpSpecData)
        return
    else
        opcondtask.OpSpecData = newOpSpecData;
    end
   
%% Trim the model. When this is done from the MPC GUI the controller will
%% always be forced into an open loop state. In cases where there is
%% sufficient integral action in the controller, the resulting op cond will
%% also be valid for the closed loop system but there will eb one less
%% non-linearity in the loop and better optimization performance.
    thismpcobj = '';
    if ~isempty(get_param(mpcnode.Block,'mpcobj'))
        thismpcobj = get_param(mpcnode.Block,'mpcobj');  
        tempopdata = copy(opcondtask.OpSpecData);
        set_param(mpcnode.Block,'n_mv',sprintf('%d',length(mpcnode.iMV)));
        set_param(mpcnode.Block,'mpcobj','');
        tempopdata.update;
        [mpcnode.Linearization.OPPoint,mpcnode.Linearization.OPReport] = ...
             findop(opcondtask.Model,tempopdata,opt);    
    else
        [mpcnode.Linearization.OPPoint,mpcnode.Linearization.OPReport] = ...
            findop(opcondtask.Model,opcondtask.OpSpecData,opt);   
    end
    
    %% Create a new operating condition node at the level of the op cond task
    newopcondnode = OperatingConditions.OperConditionResultPanel(newname);
    set(newopcondnode,'OpPoint', copy(mpcnode.Linearization.OPPoint),...
        'OpReport',mpcnode.Linearization.OPReport);
    opcondtask.addNode(newopcondnode);
    
    %% Linearize model and create linearized model node
    node = LinearizeModel(mpcnode.Linearization);
    
    %% Linearize model and create linearized model node
    node = LinearizeModel(mpcnode.Linearization); 
    
    %% Set back the previous MPC object
    set_param(mpcnode.Block,'mpcobj', thismpcobj);
else
 
    try % First, assume the oppt agrees with the current model
        mpcnode.Linearization.OPPoint = constrSrcNode.OpPoint.update(1);
        thisoprep = constrSrcNode.OpReport;
        openloop = false;
    catch % If this fails, modify the oppt to represent an open loop system
        try
            [thisoprep,mpcnode.Linearization.OPPoint] = ...
               localOpenLoopOpCond(constrSrcNode.OpPoint,constrSrcNode.OpReport, ...
               mpcnode.Block);
            openloop = true;            
        catch % If this fails tell the user to rebuild the op pt
            if ~isempty(opcondtask.Dialog)
                 opcondtask.configureStateConstraintTable;
            end
            msg = ['The structure of the Simulink model has changed ',...
                   'since the operating point was computed. The most ',...
                   'likely cause is that a previously empty MPC block ',...
                   'was replaced by a valid MPC object, which has changed ',...
                   'the number of states in the model. Create a ',...
                   'new operating point for this model before linearizing.'];
            if isempty(progress)
                msgbox(msg,'MPC Toolbox','modal')
            end
            localsetprogress(thisExplorer,progress,3,80,'Cannot linearize model',msg)
            setlinio(opcondtask.Model,modelio); % Revert model i/o
            return
        end
    end

%% Cannot use an OperCondValuePanel node to export nominal consitions since
%% there is no available opreport.  
    if isa(constrSrcNode,'OperatingConditions.OperConditionResultPanel')
        mpcnode.Linearization.OPReport = thisoprep; %constrSrcNode.OpReport;
    elseif ~mpcnode.linearization.LinearizationDialog.overwriteNominalChk.isSelected
        mpcnode.Linearization.OPReport = [];
    else
        msg = ['The selected operating point node does not contain ',...
               'the output constraint data information needed to ',...
               'define the nominal i/o values. '];
        errordlg(msg, 'Model Prodictive Control Toolbox','modal')
        setlinio(opcondtask.Model,modelio); % Revert model i/o
        return
    end
     
    %% Linearize model and create linearized model node
    if openloop
         thismpcobj = get_param(mpcnode.Block,'mpcobj');
         set_param(mpcnode.Block,'mpcobj','');
    end
    node = LinearizeModel(mpcnode.Linearization);
    if openloop
         set_param(mpcnode.Block,'mpcobj',thismpcobj);
    end  
end

%% Write trimmed outputs back to table
mpcnode.Linearization.SyncSimulinkIO;

%% Sycronize operating specification node table
if ~isempty(opcondtask.Dialog)
    opcondtask.configureOutputConstraintTable
end

localsetprogress(thisExplorer,progress,3,80,...
    'Linearizing the plant model seen by the MPC block...','')

%% Linearize model and create linearized model node
node.Label = newname;
obs = obsv(node.LinearizedModel);
if rank(obs)<size(node.LinearizedModel,'order')
    node.LinearizedModel = sminreal(node.LinearizedModel);
end
if ~isempty(mdrows)
    node.LinearizedModel = setmpcsignals(node.LinearizedModel,'MD', mdrows);
end
localsetprogress(thisExplorer,progress,4,100,...
    'Adding linearized plant model to the project...','')

%% Add linearization result to MPC project
mpcnodes = mpcnode.getChildren;  
mpcnodes(1).addModelToList(struct('name',node.Label),node.LinearizedModel);
mpcnodes(1).addNode(node);
newNodeName = node.Label;

%% Add a listeners which keep the the @MPCControllers summary table
%% syncronized with the model table if a node is deleted/renamed
node.addListeners(handle.listener(node,'ObjectParentChanged',...
    {@localDeleteModel mpcnode.getMPCModels}));
node.addListeners(handle.listener(node,node.findprop('Label'),'PropertyPreSet',...
    {@localRenameModel mpcnode.getMPCModels}));

%% Turn off the selector panel
thisExplorer.setSelected(node.getTreeNodeInterface) 
% Linearization node must be selected for getSelectorPanel to work 
node.getDialogInterface.getSelectorPanel.setVisible(false);
node.customizeView(M);

%% Update the default linearization name text field
nodenames = get(mpcnodes(1).getChildren,{'Label'});
k = 1;
while any(strcmp(['MPC open loop plant ' sprintf('%d',k)],nodenames))
    k=k+1;
end
mpcnode.linearization.LinearizationDialog.nameTxt.setText( ...
    ['MPC open loop plant ' sprintf('%d',k)]);

%% Revert the Simulink model i/o to the state it was in at initialization
%% of the callback and sync the linearization i/i table in the
%% lienarization dialog
setlinio(opcondtask.Model,modelio);
mpcnode.Linearization.refresh

%% Make sure we are in the right state
if ~strcmp(get_param(opcondtask.Model, 'SimulationStatus'),'stopped')
    feval(opcondtask.Model,[],[],[],'term')
end
    

function localsetprogress(explorer, progress, position, completion, status, details)

if ~isempty(progress) && ishandle(progress)
    progress.setDetails(details); % Clear details
    progress.setStatus(status);
    progress.setValue(completion);
    progress.setDone(position,1);
    pause(0.5);
    drawnow % Let the repaint show the check marks
end
if nargin>=6 && ~isempty(details) && ishandle(explorer)
   explorer.postText(details)
end

function localRefreshOpCondNodes(opcondtask,M)

%% Update the operating point data since the number of states may have changed 
opcondtask.getDialogInterface(M);
try
    opcondtask.updateopcond;
catch
    str = sprintf(['The operating condition specifications could not be could '...
        'not be synchronized with the model %s due to the following error:\n\n',...
        '%s'],opcondtask.Model,lasterr);
    errordlg(str,'Model Predictive Control Toolbox','modal')
end

%% Update the operating specification data    
opcondtask.OpSpecData.update;

%% Repopulate spec node table data with the data from the operating point
opcondtask.InputSpecTableData = [];
configureInputConstraintTable(opcondtask,opcondtask.OpCondSpecPanelUDD)
opcondtask.OutputSpecTableData = [];
configureOutputConstraintTable(opcondtask,opcondtask.OpCondSpecPanelUDD)
opcondtask.StateSpecTableData = [];
configureStateConstraintTable(opcondtask,opcondtask.OpCondSpecPanelUDD)

%% Update the default op cond
defaultOpValueNode = opcondtask.find('-class', ...
    'OperatingConditions.OperConditionValuePanel','Label', ...
    'Default Operating Point');
if ~isempty(defaultOpValueNode)
    defaultOpValueNode.getDialogInterface(M);
    %% Update the operating specification data    
    defaultOpValueNode.OpPoint.update;
    %% Update the tables
    defaultOpValueNode.updateTables;
end


function localDeleteModel(eventSrc, eventData, modelsnode)

% Listener callback when a linearized result node is deleted

I = find(strcmp(eventSrc.Label,get(modelsnode.Models,{'Name'})));
if ~isempty(I)
    modelsnode.deleteSelectedModel(modelsnode.Models(I(1)));
end

function localRenameModel(eventSrc, eventData, modelsnode)

% Listener callback which updates the model list when a model
% node name is chnaged
thisModel = modelsnode.getModel(eventData.AffectedObject.Label);
I = find(ismember(modelsnode.Models,thisModel));
if ~isempty(I)
    modelsnode.renameModel(eventData.NewValue,I(1));
end
if ~isempty(thisModel)
    thisModel.Name = eventData.NewValue;
    thisModel.Label = eventData.NewValue;
end


function [h,g] = localOpenLoopOpCond(oppt,oprep,blockname)

%% This function converts an op-report, op-value pair defined for a 
%% a Simulink model with an MPC block 'blockname' into copies of
%% these objects which are valid when the MPC block is converted to open
%% loop. If the op-report does not have outputs defined by the MPC block
%% output this function performs a direct copy.

h = copy(oprep);
g = copy(oppt);
I = find(strcmp(blockname,get(h.outputs(1),{'Block'})));
if length(I)>0
     Istate = find(strcmp([blockname '/sfunction'],get(h.States,{'Block'})));
     if length(Istate)>0
         thisStateReport = opcond.StateReport;
         s = size(h.outputs(I(1)).y);
         % Create new state report for the open loop MPC
         set(thisStateReport,'x',h.outputs(I(1)).y,'dx',zeros(s),...
            'Block',[blockname '/sfunction'],'Nx',max(s),'Known',zeros(s),...
            'SteadyState',ones(s),'Min',-inf*ones(s),'Max',inf*ones(s));
         h.States(Istate(1)) = thisStateReport;
         g.States = h.States;
     else
         error('localOpenLoopOpCond:mismatch',...
             'Cannot modify op pt to open loop state')
     end
else
     error('localOpenLoopOpCond:mismatch',...
         'Cannot modify op pt to open loop state')
end


