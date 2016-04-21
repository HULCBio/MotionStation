function hout = LinOptionsDialog(TaskNode)
%%  LinOptionsDialog Constructor for @LinOptionsDialog class
%%
%%  Author(s): John Glass
%%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/16 22:20:29 $

mlock
persistent this

if isempty(this)
%% Create class instance
    this = jDialogs.LinOptionsDialog;
    LocalConfigureDialog(this);
end

%% Store the linearization node
this.TaskNode = TaskNode;

%% Update the GUI with the new data from the linearization task
LocalUpdateDialog(this)
hout = this;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateDialog - Update the dialog with the new node data
function LocalUpdateDialog(this)

import java.lang.*;

%% Get the linoptions for the project.
OpCondNode = getOpCondNode(this.TaskNode);
linoptions = OpCondNode.Options;
OptimizationOptions = linoptions.OptimizationOptions;

%% Get the handle to the Java object handles
jhand = this.JavaHandles;

%% Get the visibility of the options dialog this will determine whether
%% awtinvoke is needed.
vis = this.JavaPanel.isVisible;

%% Sample Rate
if isa(linoptions.SampleTime,'double')
    ts = String(num2str(linoptions.SampleTime));
else
    ts = String(linoptions.SampleTime);
end

if vis
    awtinvoke(jhand.SampleTimeEditField,'setText',ts);
else
    jhand.SampleTimeEditField.setText(ts);
end

%% Block Reduction
if vis
    awtinvoke(jhand.EnableBlockReductionCheckbox,'setSelected',strcmp(linoptions.BlockReduction,'on'));
else
    jhand.EnableBlockReductionCheckbox.setSelected(strcmp(linoptions.BlockReduction,'on'));
end

%% Linearization Algorithm
if strcmp(linoptions.LinearizationAlgorithm,'blockbyblock')
    algo = 0;
else
    algo = 1;
end

if vis
    awtinvoke(jhand.LinearizationAlgoCombo,'setSelectedIndex',algo);
else
    jhand.LinearizationAlgoCombo.setSelectedIndex(algo);
end

%% Perturbation Parameters
if vis
    awtinvoke(jhand.NumericalPertRelEditField,'setText',String(OpCondNode.OptimChars.NumericalPertRel));
    awtinvoke(jhand.NumericalXPertEditField,'setText',String(OpCondNode.OptimChars.NumericalXPert));
    awtinvoke(jhand.NumericalUPertEditField,'setText',String(OpCondNode.OptimChars.NumericalUPert));
else
    jhand.NumericalPertRelEditField.setText(String(OpCondNode.OptimChars.NumericalPertRel));
    jhand.NumericalXPertEditField.setText(String(OpCondNode.OptimChars.NumericalXPert));
    jhand.NumericalUPertEditField.setText(String(OpCondNode.OptimChars.NumericalUPert));
end

%% Ignore Discrete States
if vis
    awtinvoke(jhand.IgnoreDiscreteStatesCheckBox,'setSelected',strcmp(linoptions.IgnoreDiscreteStates,'on'));
else
    jhand.IgnoreDiscreteStatesCheckBox.setSelected(strcmp(linoptions.IgnoreDiscreteStates,'on'));
end

%% Set the values in the optimization settings structure
if vis
    awtinvoke(jhand.maxchangeField,'setText',String(OpCondNode.OptimChars.DiffMaxChange));
    awtinvoke(jhand.minchangeField,'setText',String(OpCondNode.OptimChars.DiffMinChange));
    awtinvoke(jhand.maxfunevalField,'setText',String(OpCondNode.OptimChars.MaxFunEvals));
    awtinvoke(jhand.maxiterField,'setText',String(OpCondNode.OptimChars.MaxIter));
    awtinvoke(jhand.functolField,'setText',String(OpCondNode.OptimChars.TolFun));
    awtinvoke(jhand.paramtolField,'setText',String(OpCondNode.OptimChars.TolX));
    awtinvoke(jhand.jacobianCheckBox,'setSelected',strcmp(OptimizationOptions.Jacobian,'on'));
else
    jhand.maxchangeField.setText(String(OpCondNode.OptimChars.DiffMaxChange));
    jhand.minchangeField.setText(String(OpCondNode.OptimChars.DiffMinChange));
    jhand.maxfunevalField.setText(String(OpCondNode.OptimChars.MaxFunEvals));
    jhand.maxiterField.setText(String(OpCondNode.OptimChars.MaxIter));
    jhand.functolField.setText(String(OpCondNode.OptimChars.TolFun));
    jhand.paramtolField.setText(String(OpCondNode.OptimChars.TolX));
    jhand.jacobianCheckBox.setSelected(strcmp(OptimizationOptions.Jacobian,'on'));
end

%% Set the display property
switch linoptions.DisplayReport
    case 'off'
        display = 0;
    case 'iter'
        display = 1;
end

if vis
    awtinvoke(jhand.displayCombo,'setSelectedIndex',display);
else
    jhand.displayCombo.setSelectedIndex(display);
end

%% Set the optimizer type
switch linoptions.OptimizerType
    case 'graddescent_elim'
        optimtype = 0;
    case 'graddescent'
        optimtype = 1;
    case 'simplex'
        optimtype = 2;
    case 'lsqnonlin'
        optimtype = 3;
end

if vis
    awtinvoke(jhand.methodCombo,'setSelectedIndex',optimtype);
else
    jhand.methodCombo.setSelectedIndex(optimtype);
end

%% Set the scale of the optimization algorithm
switch OptimizationOptions.LargeScale
    case 'off'
        scale = 0;
    case 'on'
        scale = 1;
end

if vis 
    awtinvoke(jhand.algorithmCombo,'setSelectedIndex',scale);
else
    jhand.algorithmCombo.setSelectedIndex(scale);
end

%% Set the state order
StateOrderList = OpCondNode.StateOrderList;
StateOrderModel = javax.swing.DefaultListModel;
for ct = 1:length(StateOrderList)
    StateOrderModel.addElement(StateOrderList{ct});
end
if vis
    awtinvoke(jhand.StateOrderList,'setModel',StateOrderModel);
    %% Select the first element
    if ~isempty(StateOrderList)
        awtinvoke(this.JavaHandles.StateOrderList,'setSelectedIndex',0);
    end
else
    jhand.StateOrderList.setModel(StateOrderModel);
    %% Select the first element
    if ~isempty(StateOrderList)
        this.JavaHandles.StateOrderList.setSelectedIndex(0);
    end
end

%% Put the dialog on top of the explorer
if vis
    awtinvoke(this.JavaPanel,'setLocationRelativeTo',slctrlexplorer);
else
    this.JavaPanel.setLocationRelativeTo(slctrlexplorer);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalConfigureDialog - Configure the dialog for the first time
function LocalConfigureDialog(this)

%% Create the dialog panel
import com.mathworks.toolbox.slcontrol.Dialogs.*;
Dialog = LinOptionsDialog;
Dialog.setSize(450,400);

%% Store the java panel handle
this.JavaPanel = Dialog;

%% Configure the panel
jhand.HelpButton = Dialog.getHelpButton;
set(jhand.HelpButton,'ActionPerformedCallback', {@LocalHelpButtonCallback, this})
jhand.OKButton = Dialog.getOKButton;
set(jhand.OKButton,'ActionPerformedCallback', {@LocalOKButtonCallback, this})
jhand.ApplyButton = Dialog.getApplyButton;
set(jhand.ApplyButton,'ActionPerformedCallback', {@LocalApplyButtonCallback, this})
jhand.CancelButton = Dialog.getCancelButton;
set(jhand.CancelButton,'ActionPerformedCallback', {@LocalCancelButtonCallback, this})

%% These Java widgets do not need to have callbacks since the data is read
%% when the Apply and OK buttons are presed
jhand.LinearizationPanel = Dialog.getLinearizationPanel;
jhand.SampleTimeEditField = jhand.LinearizationPanel.getSampleTimeEditField;
jhand.EnableBlockReductionCheckbox = jhand.LinearizationPanel.getEnableBlockReductionCheckbox;
jhand.LinearizationAlgoCombo = jhand.LinearizationPanel.getLinearizationAlgoCombo;
jhand.IgnoreDiscreteStatesCheckBox = jhand.LinearizationPanel.getIgnoreDiscreteStatesCheckBox;
jhand.NumericalPertRelEditField = jhand.LinearizationPanel.getNumericalPertRelEditField;
jhand.NumericalXPertEditField = jhand.LinearizationPanel.getNumericalXPertEditField;
jhand.NumericalUPertEditField = jhand.LinearizationPanel.getNumericalUPertEditField;

%% These Java widgets do not need to have callbacks since the data is read
%% when the Apply and OK buttons are presed
jhand.OptimizationPanel = Dialog.getOptimizationPanel;
jhand.maxchangeField = jhand.OptimizationPanel.getmaxchangeField;
jhand.minchangeField = jhand.OptimizationPanel.getminchangeField;
jhand.maxfunevalField = jhand.OptimizationPanel.getmaxfunevalField;
jhand.maxiterField = jhand.OptimizationPanel.getmaxiterField;
jhand.functolField = jhand.OptimizationPanel.getfunctolField;
jhand.paramtolField = jhand.OptimizationPanel.getparamtolField;
jhand.jacobianCheckBox = jhand.OptimizationPanel.getjacobianCheckBox;
jhand.displayCombo = jhand.OptimizationPanel.getdisplayCombo;
jhand.methodCombo = jhand.OptimizationPanel.getmethodCombo;
jhand.algorithmCombo = jhand.OptimizationPanel.getalgorithmCombo;
jhand.comboitems = jhand.OptimizationPanel.getComboItems;
jhand.scalecomboitems = jhand.OptimizationPanel.getScaleComboItems;

%% Configure the state ordering panel
jhand.StateOrderPanel = Dialog.getStateOrderingPanel;
jhand.StateOrderList = jhand.StateOrderPanel.getStateOrderList;
jhand.MoveUpButton = jhand.StateOrderPanel.getMoveUpButton;
set(jhand.MoveUpButton,'ActionPerformedCallback', {@LocalMoveUpButtonCallback, this})
jhand.MoveDownButton = jhand.StateOrderPanel.getMoveDownButton;
set(jhand.MoveDownButton,'ActionPerformedCallback', {@LocalMoveDownButtonCallback, this})
jhand.SyncWithModelButton = jhand.StateOrderPanel.getSyncWithModelButton;
h = handle(jhand.SyncWithModelButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalSyncWithModelButtonCallback, this};

%% Store the java handles
this.JavaHandles = jhand;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalMoveUpButtonCallback - Moves the selected state upwards
function LocalMoveUpButtonCallback(es,ed,this)

%% Get the selected index
ind = this.JavaHandles.StateOrderList.getSelectedIndex;

if ind > 0
    %% Get the operating point task node
    OpCondNode = getOpCondNode(this.TaskNode);
    %% Set the selected index
    awtinvoke(this.JavaHandles.StateOrderList,'setSelectedIndex',ind-1);
    len = length(OpCondNode.StateOrderList);
    %% Get the list model
    Model = this.JavaHandles.StateOrderList.getModel;
    %% Get the selected element and the one above it
    Selected = Model.get(ind);
    AboveSelected = Model.get(ind-1);
    %% Flip the list elements
    awtinvoke(Model,'set',ind-1,java.lang.String(Selected));
    awtinvoke(Model,'set',ind,java.lang.String(AboveSelected));
    %% Set the selected index
    awtinvoke(this.JavaHandles.StateOrderList,'setSelectedIndex',ind-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalMoveDownButtonCallback - Moves the selected state downwards
function LocalMoveDownButtonCallback(es,ed,this)

%% Get the selected index
ind = this.JavaHandles.StateOrderList.getSelectedIndex;
%% Get the operating point task node
OpCondNode = getOpCondNode(this.TaskNode);
%% Get the number of state elements
len = length(OpCondNode.StateOrderList);

if ind < len-1 && ind > -1 
    %% Set the selected index
    awtinvoke(this.JavaHandles.StateOrderList,'setSelectedIndex',ind+1);
    %% Get the list model
    Model = this.JavaHandles.StateOrderList.getModel;
    %% Get the selected element and the one below it
    Selected = Model.get(ind);
    BelowSelected = Model.get(ind+1);
    %% Flip the list elements
    awtinvoke(Model,'set',ind,java.lang.String(BelowSelected));
    awtinvoke(Model,'set',ind+1,java.lang.String(Selected));
    %% Set the selected index
    awtinvoke(this.JavaHandles.StateOrderList,'setSelectedIndex',ind+1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSyncWithModelButtonCallback - Syncs with the Simulink model
function LocalSyncWithModelButtonCallback(es,ed,this)

%% Get the current order in the list
StateOrderModel = this.JavaHandles.StateOrderList.getModel;
len = StateOrderModel.getSize;
xstr = cell(len,1);

%% Get the data from the list model
for ct = 0:len-1
    xstr{ct+1} = StateOrderModel.get(ct);
end

%% Get the operating point task node
OpCondNode = getOpCondNode(this.TaskNode);
%% Get the operating point node
OpNode = OpCondNode.down;
%% Update the operating point data    
try
    op = update(copy(OpNode.OpPoint));
catch
    lastmsg = lasterr; 
    str = sprintf(['The model states could not be '...
        'synchronized with the model %s due to the following error:\n\n',...
        '%s'],OpNode.Model,lastmsg);
    errordlg(str,'Operating Points Synchronization Error')
    return
end

%% Sort the states
sortstates(op,xstr);
%% Update the operating condition object
update(op);
%% Set the state ordering cell array
StateOrderList = cell(length(op.States),1);
for ct = 1:length(op.States)
   if isa(op.States(ct),'opcond.StatePointSimMech')
       StateOrderList{ct} = op.States(ct).SimMechBlock;
   else
       StateOrderList{ct} = op.States(ct).Block;
   end
end
%% Create a new list model
StateOrderModel = javax.swing.DefaultListModel;
for ct = 1:length(StateOrderList)
    StateOrderModel.addElement(StateOrderList{ct});
end
%% Set the new list model
awtinvoke(this.JavaHandles.StateOrderList,'setModel',StateOrderModel);
%% Select the first element
if ~isempty(StateOrderList)
    awtinvoke(this.JavaHandles.StateOrderList,'setSelectedIndex',0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalHelpButtonCallback - Evaluate the help button callback
function LocalHelpButtonCallback(es,ed,this)

%% Launch the help browser
if (this.JavaPanel.getTabbedPane.getSelectedIndex==0);
    helpview([docroot '/toolbox/slcontrol/slcontrol.map'], 'lin_settings')
elseif (this.JavaPanel.getTabbedPane.getSelectedIndex==1);
    helpview([docroot '/toolbox/slcontrol/slcontrol.map'], 'optim_settings')
else
    helpview([docroot '/toolbox/slcontrol/slcontrol.map'], 'state_ordering')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalOKButtonCallback - Evaluate the OK button callback
function LocalOKButtonCallback(es,ed,this)

%% Call the apply callback
error = LocalApplyButtonCallback([],[],this);

%% Dispose of the dialog
if ~error 
    awtinvoke(this.JavaPanel,'dispose');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalApplyButtonCallback - Evaluate the apply button callback
function error = LocalApplyButtonCallback(es,ed,this)

import com.mathworks.mwswing.*;

%% Initialize the error flag
error = false;

%% Get the linoptions for the project.
OpCondNode = getOpCondNode(this.TaskNode);
linoptions = OpCondNode.Options;
OptimizationOptions = linoptions.OptimizationOptions;

%% Get the Java handles
jhand = this.JavaHandles;

%% Store the results
%% Block Reduction
if jhand.EnableBlockReductionCheckbox.isSelected
     linoptions.BlockReduction = 'on';
else linoptions.BlockReduction = 'off';
end
%% Ignore Discrete States
if jhand.IgnoreDiscreteStatesCheckBox.isSelected
     linoptions.IgnoreDiscreteStates = 'on';
else linoptions.IgnoreDiscreteStates = 'off';
end

%% Use Model Perturbation disable for block linearization
if isa(this.TaskNode,'ModelLinearizationNodes.ModelLinearizationSettings')
    if (jhand.LinearizationAlgoCombo.getSelectedIndex == 1)
        linoptions.LinearizationAlgorithm = 'numericalpert';
        this.TaskNode.Dialog.IOPanel.IOTable.setEnabled(0);
        this.TaskNode.Dialog.IOPanel.Instruct.setText(['Linearization annotations are not valid for ',...
            'perturbation based linearization.  Using top level inport and outports.']);
        this.TaskNode.Dialog.IOPanel.IOTable.setForeground(javax.swing.plaf.ColorUIResource(0.5,0.5,0.5));
    else
        linoptions.LinearizationAlgorithm = 'blockbyblock';
        this.TaskNode.Dialog.IOPanel.IOTable.setEnabled(1);
        this.TaskNode.Dialog.IOPanel.Instruct.setText(['Select linearization I/Os by right clicking on ',...
            'the desired line in your Simulink model.'])
        this.TaskNode.Dialog.IOPanel.IOTable.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
    end
end

%% Sample Time
linoptions.SampleTime = char(jhand.SampleTimeEditField.getText);

%% Store the results
val = char(jhand.maxchangeField.getText);
if isempty(val)
   errordlg('Please enter a value for the dialog parameter for Maximum change.',...
                 'Simulink Control Design','modal')
    error = true;
    return
end
OpCondNode.OptimChars.DiffMaxChange = val;
val = char(jhand.minchangeField.getText);
if isempty(val)
    errordlg('Please enter a value for the dialog parameter for Minimum change.',...
             'Simulink Control Design','modal')
    error = true;
    return
end
OpCondNode.OptimChars.DiffMinChange = val;
val = char(jhand.maxfunevalField.getText);
if isempty(val)
    errordlg('Please enter a value for the dialog parameter for Maximum fcn evals.',...
             'Simulink Control Design','modal')
    error = true;
    return
end
OpCondNode.OptimChars.MaxFunEvals   = val;
val = char(jhand.maxiterField.getText);
if isempty(val)
    errordlg('Please enter a value for the dialog parameter for Maximum iterations.',...
             'Simulink Control Design','modal')
    error = true;     
    return
end
OpCondNode.OptimChars.MaxIter       = val;
val = char(jhand.functolField.getText);
if isempty(val)
    errordlg('Please enter a value for the dialog parameter for Function tolerance.',...
             'Simulink Control Design','modal')
    error = true;     
    return
end
OpCondNode.OptimChars.TolFun        = val;
val = char(jhand.paramtolField.getText);
if isempty(val)
    errordlg('Please enter a value for the dialog parameter for Parameter tolerance.',...
             'Simulink Control Design','modal')
    error = true;     
    return
end
OpCondNode.OptimChars.TolX          = val;

%% Store perturbation options
OpCondNode.OptimChars.NumericalPertRel = char(jhand.NumericalPertRelEditField.getText);
OpCondNode.OptimChars.NumericalXPert = char(jhand.NumericalXPertEditField.getText);
OpCondNode.OptimChars.NumericalUPert = char(jhand.NumericalUPertEditField.getText);

%% Jacobian checkbox
if jhand.jacobianCheckBox.isSelected
     OptimizationOptions.Jacobian = 'on';
else OptimizationOptions.Jacobian = 'off';
end

switch lower(char(jhand.displayCombo.getSelectedItem.toString))
    case 'off'
        linoptions.DisplayReport = 'off';
    case 'iterations'
        linoptions.DisplayReport = 'iter';
end

switch lower(char(jhand.methodCombo.getSelectedItem.toString))
    case 'nonlinear least squares'
        if ~license('test','Optimization_Toolbox')
            errordlg(['The Optimization Toolbox is required to use the nonlinear ',...
                       'least squares algorithm'],'Simulink Control Design','modal')
            error = true;
            return
        else
            linoptions.OptimizerType = 'lsqnonlin';
        end
    case 'gradient descent with elimination'
        linoptions.OptimizerType = 'graddescent_elim';
    case 'gradient descent'
        linoptions.OptimizerType = 'graddescent';
    case 'simplex search'
        linoptions.OptimizerType = 'simplex';
end

switch lower(char(jhand.algorithmCombo.getSelectedItem.toString))
    case 'large scale'
        if ~license('test','Optimization_Toolbox')
            errordlg(['The Optimization Toolbox is required to use the large ',...
                'scale algorithm'],'Simulink Control Design','modal')
            error = true;
            return
        else
            OptimizationOptions.LargeScale = 'on';
        end
    case 'medium scale'
        OptimizationOptions.LargeScale = 'off';
end

%% Get the number of state elements and create an empty cell array
StateOrderModel = this.JavaHandles.StateOrderList.getModel;
len = StateOrderModel.getSize;
xstr = cell(len,1);

%% Get the data from the list model
for ct = 0:len-1
    xstr{ct+1} = StateOrderModel.get(ct);
end

%% Store the state string
OpCondNode.StateOrderList = xstr;

%% Get the optimization settings structure
OpCondNode.Options = linoptions;
linoptions.OptimizationOptions = OptimizationOptions;

%% Set the dirty flag
this.setDirty

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalCancelButtonCallback - Evaluate the cancel button callback
function LocalCancelButtonCallback(es,ed,this)

%% Dispose of the dialog
awtinvoke(this.JavaPanel,'dispose');
