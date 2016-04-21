function this = NewProjectDialog(workspace,varargin)
%NEWPROJECTDIALOG
% PROJECTDIALOG = NEWPROJECTDIALOG(WORSPACE) Create and configure the new 
% project dialog.  WORKSPACE is the handle to the Control and Estimation Tools
% Manager root workspace.
%
% PROJECTDIALOG = NEWPROJECTDIALOG(WORSPACE, TASK) Create and configure the new 
% project dialog and checks the task specified by the variable TASK.

% Author(s): John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $

%% Create the object
this = explorer.NewProjectDialog;

if (nargin == 1)
    this.Workspace = workspace;
    this.Task = [];
else
    this.Workspace = workspace;
    this.Task = varargin{1};
end

%% Create the dialog
dialog = com.mathworks.toolbox.control.dialogs.NewProjectDialog;
%% Set its size and location
dialog.setSize(580,422);
dialog.setLocationRelativeTo(slctrlexplorer)
this.Dialog = dialog;

%% Get the handles to the Java objects and configure them
%% ProjectNameTextField
jhand.ProjectNameTextField = dialog.getProjectNameTextField;

%% ModelList
jhand.ModelList = dialog.getModelList;
%% Populate the model list
this.getLoadedModels;

%% New Task Table Model
jhand.TaskTableModel = dialog.getTaskTableModel;
%% Populated the table model
jhand.TaskTableModel.data = LocalGetValidTasks(this);

%% OKButton
jhand.OKButton = dialog.getOKButton;
set(jhand.OKButton,'ActionPerformedCallback',{@LocalOKButtonCallback,this})

%% CancelButton
jhand.CancelButton = dialog.getCancelButton;
set(jhand.CancelButton,'ActionPerformedCallback',{@LocalCancelButtonCallback,this})

%% Store the JAVA handles
this.JavaHandles = jhand;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalGetValidTasks
function table_data = LocalGetValidTasks(this)

tasks = {};
%% If Simulink Control Designer exists add it to the list
if license('test','Simulink_Control_Design')
  tasks{end+1} = 'Linearization Task';
%   tasks{end+1} = 'Controller Design Task';
end

%% If Simulink Parameter Estimator exists add the project types to the list
if exist( 'slparamestim' )
  tasks{end+1} = 'Parameter Estimation Task';
end

%% If MPC GUI exists add the project types to the list
if exist( 'slmpctool' )
  tasks{end+1} = 'Model Predictive Control Task';
end

table_data = javaArray('java.lang.Object',length(tasks),2);

for ct = 1:length(tasks)
    table_data(ct,1) = java.lang.String(tasks{ct});
    if strcmp(tasks{ct},this.Task)
        table_data(ct,2) = java.lang.Boolean(true);
    else
        table_data(ct,2) = java.lang.Boolean(false);
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalOKButtonCallback
function LocalOKButtonCallback(es,ed,this)

data = this.JavaHandles.TaskTableModel.data;
%% Check to see that any of the tasks have been selected
for ct=size(data,1):-1:1
    taskselected(ct) = data(ct,2);
end

%% Get the selected model
model = this.JavaHandles.ModelList.getSelectedValue;

if ~isempty(model) && any(taskselected)
    awtinvoke(this.Dialog,'dispose')
    %% Put up the waitbar
    wb = waitbar(0,'Creating a new project','Name','Control and Estimation Manager');
    %% Open the model
    open_system(model);waitbar(0.2,wb);
    %% Get the model name to be used by set_params later instead of the
    %% path name.
    model = gcs;
    %% Create a new project
    projectname = char(this.JavaHandles.ProjectNameTextField.getText);
    project = getvalidproject(model,false,projectname);waitbar(0.8,wb);   
    
    for ct = 1:size(data,1)
        if data(ct,2)
            switch char(data(ct,1))
                case 'Linearization Task'
                    fcnhndl = {@simcontdesigner,'initialize_linearize',model,project};
%               case 'Controller Design Task'
%                   fcnhndl = {@simcontdesigner,'initialize_controller_design',model,project};
                case 'Parameter Estimation Task'
                    fcnhndl = {@slparamestim,'initialize', model, project};
                case 'Model Predictive Control Task'
                    fcnhndl = {@mpc_mask, 'openhidden', model, project, '' , ''};  
            end
            feval(fcnhndl{:});
        end
    end
   
    %% Connect the project to the Workspace, select and expand it
    this.Workspace.addNode(project);
    Frame = slctrlexplorer; waitbar(0.9,wb);
    Frame.setSelected(project.getTreeNodeInterface);waitbar(0.95,wb);
    Frame.expandNode(project.getTreeNodeInterface);waitbar(1,wb);close(wb)
else
    import javax.swing.*;
    JOptionPane.showMessageDialog(this.Dialog,'Please select a model and a task for the new project.',...
                        'Control and Estimation Tools Manager',JOptionPane.ERROR_MESSAGE);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalCancelButtonCallback - Close the dialog
function LocalCancelButtonCallback(es,ed,this)

%% Dispose of the dialog
awtinvoke(this.Dialog,'dispose');
