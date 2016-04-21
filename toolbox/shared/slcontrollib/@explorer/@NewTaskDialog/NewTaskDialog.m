function this = NewTaskDialog(varargin)
% NewTaskDialog Create and configure the new task dialog

% Author(s): John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $ $

%% Create the object
this = explorer.NewTaskDialog;

if isa(varargin{1},'explorer.Project')
    %% Store the project node
    this.CurrentProject = varargin{1};
    this.CurrentWorkspace = varargin{1}.up;
elseif isa(varargin{1},'explorer.Workspace')
    this.CurrentProject = [];
    this.CurrentWorkspace = varargin{1};
end

%% Create the dialog
dialog = com.mathworks.toolbox.control.dialogs.NewTaskDialog;
%% Set its size and location
dialog.setSize(580,165);
dialog.setLocationRelativeTo(slctrlexplorer)

%% Get the handles to the Java objects and configure them
%% TaskTypeCombo
jhand.TaskTypeCombo = dialog.getTaskTypeCombo;    
jhand.TaskTypeCombo.setModel(getValidProjects(this));

%% ProjectSelectionCombo
jhand.ProjectSelectionCombo = dialog.getProjectSelectionCombo;
[ProjectComboObject,projind] = LocalGetProjectList(this);
jhand.ProjectSelectionCombo.setModel(ProjectComboObject)
jhand.ProjectSelectionCombo.setSelectedIndex(projind);

%% OKButton
jhand.OKButton = dialog.getOKButton;
set(jhand.OKButton,'ActionPerformedCallback',{@LocalOKButtonCallback,this})

%% CancelButton
jhand.CancelButton = dialog.getCancelButton;
set(jhand.CancelButton,'ActionPerformedCallback',{@LocalCancelButtonCallback,this})

%% Store the appropriate handles
this.JavaHandles = jhand;
this.Dialog = dialog;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalOKButtonCallback
function LocalOKButtonCallback(es,ed,this)


%% Get the task type
tasktype = this.JavaHandles.TaskTypeCombo.getSelectedItem;

%% Prototype fcn('flag',model,project)
switch tasktype
    case 'Linearization Task'
        fcnhndl = {@simcontdesigner,'initialize_linearize',[],[]};
        %% Remove for R14
%     case 'Controller Design Task'
%          fcnhndl = {@simcontdesigner,'initialize_controller_design',[],[]};
    case 'Parameter Estimation Task'
        fcnhndl = {@slparamestim,'initialize', [], []};
    case 'Model Predictive Control Task'
        fcnhndl = {@mpc_mask,'openhidden','','','',''};
end

if this.CreateNewProject
    %% Create the new task dialog and let it handle the rest
    newdlg = explorer.NewProjectDialog(this.CurrentWorkspace,tasktype);
    awtinvoke(newdlg.Dialog,'setVisible',true);    
else
    project = this.Projects(this.JavaHandles.ProjectSelectionCombo.getSelectedIndex + 1);
    %% Set the model name
    fcnhndl{3} = project.model;
    %% Set the selected project
    fcnhndl{4} = project;
    %% Evaluate the task creation function
    feval(fcnhndl{:});
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalCancelButtonCallback - Close the dialog
function LocalCancelButtonCallback(es,ed,this)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalGetProjectList
function [ComboBoxObject,ind] = LocalGetProjectList(this)

import java.lang.* java.awt.* javax.swing.*;

%% Create an empty default list model
ComboBoxObject = DefaultComboBoxModel;

%% If Simulink Control Designer exists add it to the list
if isa(this.CurrentProject,'explorer.Project')
    Workspace = this.CurrentProject.up;
    
    % Find non-MPC projects
    this.Projects = setdiff(Workspace.getChildren, ...
        Workspace.find('-class','mpcnodes.MPCGUI','-depth',1));
    for ct = 1:length(this.Projects)
        ComboBoxObject.addElement(this.Projects(ct).Label);
    end
    %% Find the project index
    ind = find(this.CurrentProject == this.Projects) - 1;
    if length(ind) ~= 1
        error('Incorrect number of matching projects')
    end
else
    % Find non-MPC projects
    theseChildren = setdiff(this.CurrentWorkspace.getChildren, ...
        this.CurrentWorkspace.find('-class','mpcnodes.MPCGUI','-depth',1));    
    if length(theseChildren)
        this.Projects = theseChildren;
        for ct = 1:length(this.Projects)
            ComboBoxObject.addElement(this.Projects(ct).Label);
        end
    else
        ComboBoxObject.addElement('A new project will be created');
        this.CreateNewProject = true;
    end    
    %% Set the project index = 0
    ind = 0;
end
