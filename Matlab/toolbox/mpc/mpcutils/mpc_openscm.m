function [status, FRAME, WSHANDLE, MANAGER, hGUI, hProj, mpcNode] = ...
    mpc_openscm(mpcblock,varargin)

%   Authors: James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/04/16 22:09:48 $

import com.mathworks.toolbox.mpc.*
status = false;
[FRAME,WSHANDLE,MANAGER,hGUI,hProj,mpcNode] = deal([]);

%% Check block name
n = max(strfind(mpcblock,'/'));
if ~isempty(n) && n>1 && n<length(mpcblock)
    model = mpcblock(1:n-1);
else
    return % Invalid path
end

%% Build progress dialog
drawnow
actions = {'Configuring the Control & Estimation Manager';
    'Setting up linearization i/o points and output constraints';
    'Finding operating point';
    'Linearizing the plant';
    'Building MPC controller'};
progress = ProgressTable.getProgressTable(actions, ...
    'Building MPC Design Project...',slctrlexplorer('initialize'));
localsetprogress(progress,0,20, ...
    'Configuring Simulink Control Manager for MPC...','')
progress.setHeader(...
    'Building a new MPC controller by deriving a plant model from Simulink');
awtinvoke(progress,'setVisible',true)

%% Build or get CETM GUI
proj = [];
if nargin==2
    proj = varargin{1};
end
[FRAME,WSHANDLE,MANAGER,hGUI, hProj] = slmpctool('initialize',model,proj, ...
    get_param(mpcblock,'Name'),mpcblock, [],progress);
if isempty(hGUI) || isempty(hProj)
    errordlg('Could not create MPC task', ...
        'Model Predictive Control Toolbox','modal')
    status = false;
    return
end

%% Assign the linearization I/O and get port widths
drawnow
[nmo,nmv,nr,nmd,inwidth] = mpcportsizes(mpcblock);
thisopspec = mpc_linoppoints(mpcblock,model,zeros(nmv,1),zeros(nmo,1));
if isempty(thisopspec)
    msg = 'Cannot define operating condition spec';
    localsetprogress(progress,[],[], 'Cannot trim...',msg)
    return
end

%% Search for MPC task with the model
%mpcnode = WSHANDLE.find('-class','mpcnodes.MPCGUI','Block',mpcblock);
mpcnode = hGUI;

%% Find the operating condition node and define the output constraint for
%% trim
opcondnode = mpcnode.up.find('-class', ...
    'OperatingConditions.OperatingConditionTask');
if isempty(opcondnode)
    msg = 'Cannot set up linearization since there is no operating condition constraint task';
    localsetprogress(progress,[],[], 'Cannot trim...',msg)
    hProj.removeNode(mpcnode);
    return
end
opcondnode.OpSpecData = thisopspec;

%% Set the optimization method to nonlinear least squares which seems to be
%% more robust when the trim problem is overdetermined
opt = linoptions;
if license('test','Optimization_Toolbox')
    opt.OptimizerType = 'lsqnonlin';
end
opt.DisplayReport = 'off'; % None verbose mode

%% Trim the operating condition constraint object
try
    progress.setStatus('Trimming the model...');
    drawnow
    [thisOPPoint, thisOPReport] = findop(model,opcondnode.OpSpecData,opt);
    mpcnode.Linearization.OPPoint = thisOPPoint;
    mpcnode.Linearization.OPReport = thisOPReport;   
catch
    msg = 'findop failed to find an operating condition';
    localsetprogress(progress,[],[], 'Cannot trim...',msg)
    hProj.removeNode(mpcnode);
    return
end

%% Create a new operating condition node at the level of the op cond task
mpcopcond = ...
    OperatingConditions.OperConditionResultPanel('MPC open loop plant 1');
set(mpcopcond,'OpPoint', copy(mpcnode.Linearization.OPPoint),...
    'OpReport',copy(mpcnode.Linearization.OPReport));
newopptnode = opcondnode.addNode(mpcopcond);

%% Store the controller node list
MPCControlList = hGUI.getMPCControllers.find('-class','mpcnodes.MPCController');

%% Programmatically hit the "OK" button in the linearization dialog
%% based on selection of the newly added operating pt node
newModelName = mpcnode.linearize(opcondnode,MANAGER,newopptnode,progress);

%% Report unsucessful completion
if isempty(newModelName)
   msg = 'Could not linearize. Try manually assigning lienarization points';
   localsetprogress(progress,[],[], 'Cannot linearize...',msg)
   hProj.removeNode(mpcnode);
   return
end


%% Has a new MPC controller been added?
mpcNode = setdiff(hGUI.getMPCControllers.find('-class', ...
     'mpcnodes.MPCController'),MPCControlList);
if isempty(mpcNode)
    theseNames = get(hGUI.getMPCControllers.find('-class', ...
        'mpcnodes.MPCController'),{'Label'});
    k = 1;
    while any(strcmp(sprintf('%s%d','MPC',k),theseNames))
        k = k+1;
    end
    hGUI.getMPCControllers.addController(sprintf('%s%d','MPC',k));
    mpcNode = hGUI.getMPCControllers.find('Label',sprintf('%s%d','MPC',k));
end

%% The new (linearized) model node becomes the internal model for the new ctrl
set(mpcNode,'Model',hGUI.getMPCModels.getModel(newModelName),...
   'ModelName',newModelName);
mpcNode.getDialogInterface(MANAGER); % Refresh internal model

%% Rebuild MPC object which may have changed since the model may have chnaged
mpcNode.MPCObject = [];
mpcNode.getController;

progress.setStatus('Project build successfully completed. Hit OK');
status = true;   
   
function localsetprogress(progress,position,completion,status,details)

if ~isempty(progress)
    progress.setDetails(details);
    progress.setStatus(status);
    if ~isempty(completion)
        progress.setValue(completion);
    end
    if ~isempty(position)
        progress.setDone(position,1);
        progress.repaint; % Let the repaint show the ckeck marks
    end
    drawnow
end
