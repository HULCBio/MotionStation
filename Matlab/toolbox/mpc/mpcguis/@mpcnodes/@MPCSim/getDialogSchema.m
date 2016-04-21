function DialogPanel = getDialogSchema(this,manager)

% DialogPanel = getDialogSchema(this,manager)
%
%  Construct the MPCSim dialog panel

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.8.10 $ $Date: 2004/04/19 01:16:29 $

import java.awt.*;
S=this.getMPCStructure;
if isempty(this.Dialog)
    % Create new panel.
    mpcCursor(S.Frame, 'wait');
	DialogPanel = LocalDialogPanel(this);
    this.Dialog = DialogPanel;
    % Force creation of MPCSims panel
    MPCSims = this.up;
    if isempty(MPCSims.Dialog)
        MPCSims.getDialogInterface(S.TreeManager);
    end
    mpcCursor(S.Frame, 'default');
else
    % Use existing panel.  Update tabular displays 
    % if necessary.
    if this.updateTables
        mpcCursor(S.Frame, 'wait');
        this.SignalLabelUpdate;
        mpcCursor(S.Frame, 'default');
    end
    % Also possible update in the sampling period display, which might
    % trigger an mpc object update:
    LocalRefreshTsLabel(this);
    DialogPanel = this.Dialog;
    % Now return the dialog panel for display.
end

% Update combo boxes
MPCModels = this.getMPCModels;
mpc_combo_updater(this.Handles.ModelCombo, MPCModels.Labels, ...
    this.PlantName);
MPCControllers = this.getMPCControllers;
mpc_combo_updater(this.Handles.ControllerCombo, ...
    MPCControllers.Controllers, this.ControllerName);

% Indicate that this is the current scenario
this.up.CurrentScenario = this.Label;

% ----------------------------------------------------------------------- %

function DialogPanel = LocalDialogPanel(this)

% Details of MPCSim dialog panel construction

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

MPCStructure = this.getMPCStructure;
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(MPCStructure);

% Name of this node
Name = this.label;

% Sizing dimensions
nHor = 450;
nVer = 130;
LabelDimension = Dimension(110,20);

% Simulation parameter controls
ControllerLabel = MJLabel('Controller');
ControllerLabel.setPreferredSize(LabelDimension);
ControllerLabel.setHorizontalAlignment(SwingConstants.RIGHT);
ModelLabel = MJLabel('Plant');
ModelLabel.setPreferredSize(LabelDimension);
ModelLabel.setHorizontalAlignment(SwingConstants.RIGHT);
LoopLabel = MJLabel('Close loops');
LoopLabel.setPreferredSize(LabelDimension);
LoopLabel.setHorizontalAlignment(SwingConstants.RIGHT);
ConstraintLabel = MJLabel('Enforce constraints');
ConstraintLabel.setPreferredSize(LabelDimension);
ConstraintLabel.setHorizontalAlignment(SwingConstants.RIGHT);

ComboDimension = Dimension(130,20);
ControllerCombo = MJComboBox;
ControllerCombo.addItem('Dummy');
ControllerCombo.setEditable(false);
ControllerCombo.setSelectedIndex(0);
ControllerCombo.setPreferredSize(ComboDimension);
ModelCombo = MJComboBox;
ModelCombo.addItem('Dummy');
ModelCombo.setEditable(false);
ModelCombo.setSelectedIndex(0);
ModelCombo.setPreferredSize(ComboDimension);
LoopCheckBox = MJCheckBox('', this.ClosedLoop);
ConstraintCheckBox = MJCheckBox('', this.ConstraintsEnforced);

TsLabel = MJLabel('Control interval');
TsLabel.setPreferredSize(LabelDimension);
TsLabel.setHorizontalAlignment(SwingConstants.RIGHT);
TsValue = MJLabel('1.0');
TsValue.setPreferredSize(Dimension(50,20));
TendLabel = MJLabel('Duration');
TendLabel.setPreferredSize(LabelDimension);
TendLabel.setHorizontalAlignment(SwingConstants.RIGHT);
TendField = MJTextField(5);
TendField.setText(this.Tend);

% Simulation parameter panel assembly
pLoop = MJPanel(GridBagLayout);
c = GridBagConstraints;
In1 = Insets(2,5,2,5);
In2 = Insets(2,50,2,5);
c.insets = In1;
c.gridy = 0;
c.gridx = GridBagConstraints.RELATIVE;
pLoop.add(ControllerLabel, c);
c.gridwidth = 2;
pLoop.add(ControllerCombo, c);
c.gridwidth = 1;
c.insets = In2;
pLoop.add(LoopLabel, c);
c.insets = In1;
pLoop.add(LoopCheckBox, c);
c.gridy = 1;
c.gridx = GridBagConstraints.RELATIVE;
pLoop.add(ModelLabel, c);
c.gridwidth = 2;
pLoop.add(ModelCombo, c);
c.gridwidth = 1;
c.insets = In2;
pLoop.add(ConstraintLabel, c);
c.insets = In1;
pLoop.add(ConstraintCheckBox, c);
c.gridy = 2;
c.gridx = GridBagConstraints.RELATIVE;
pLoop.add(TendLabel, c);
pLoop.add(TendField, c);
c.gridx = 3;
c.insets = In2;
pLoop.add(TsLabel, c);
c.insets = In1;
c.gridx = 4;
c.gridwidth = 3;
pLoop.add(TsValue, c);

% Signal controls

% Table constants
SignalCombo = MJComboBox;
SignalCombo.setEditable(0);
SignalCombo.addItem('Constant');
SignalCombo.addItem('Step');
SignalCombo.addItem('Ramp');
SignalCombo.addItem('Sine');
SignalCombo.addItem('Pulse');
SignalCombo.addItem('Gaussian');
ViewportSize = [nHor-50, round(0.70*nVer)];
ColumnSizes=50*ones(1,8);
ResizePolicy = '';
isEditable = [false false true true false false false true];
Str = 'String';
javaClass = logical([ones(1,7) 0]);
CellData = {' ',' ',' ',' ',' ',' ',' ', false};
% Setpoint definition table
ColNames = {'Name','Units','Type','Initial value','Size', ...
    'Time', 'Period', 'Look ahead'};
if isempty(this.SaveData)
    Setpoints = mpcobjects.TableObject(ColNames, isEditable, ...
        javaClass, CellData, @SignalCheckFcn);
else
    Saved = this.SaveData{1};
    Setpoints = mpcobjects.TableObject(ColNames, Saved.isEditable, ...
        javaClass, Saved.CellData, @SignalCheckFcn);
end
Setpoints.Table = MPCTable(Setpoints, ColNames, ...
    Setpoints.isEditable', Setpoints.CellData', javaClass);
Col4 = Setpoints.Table.getColumnModel.getColumn(2);
Col4.setCellEditor(DefaultCellEditor(SignalCombo));
Setpoints.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);

% Measured disturbance definition table
if NumMD > 0
    if isempty(this.SaveData)
        MeasDist = mpcobjects.TableObject(ColNames, isEditable, ...
            javaClass, CellData, @SignalCheckFcn);
    else
        Saved = this.SaveData{2};
        MeasDist = mpcobjects.TableObject(ColNames, Saved.isEditable, ...
            javaClass, Saved.CellData, @SignalCheckFcn);
    end
    MeasDist.Table = MPCTable(MeasDist, ColNames, ...
        MeasDist.isEditable', MeasDist.CellData', javaClass);
    Col4 = MeasDist.Table.getColumnModel.getColumn(2);
    Col4.setCellEditor(DefaultCellEditor(SignalCombo));
    MeasDist.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);
end

% Unmeasured disturbance definition table
if isempty(this.SaveData)
    UnMeasDist = mpcobjects.TableObject(ColNames(1,1:7), isEditable(1,1:7), ...
        javaClass(1,1:7), CellData(1,1:7), @SignalCheckFcn);
else
    Saved = this.SaveData{3};
    UnMeasDist = mpcobjects.TableObject(ColNames(1,1:7), Saved.isEditable, ...
        javaClass(1,1:7), Saved.CellData, @SignalCheckFcn);
end
UnMeasDist.Table = MPCTable(UnMeasDist, ColNames(1,1:7), ...
    UnMeasDist.isEditable', UnMeasDist.CellData', javaClass(1,1:7));
Col4 = UnMeasDist.Table.getColumnModel.getColumn(2);
Col4.setCellEditor(DefaultCellEditor(SignalCombo));
UnMeasDist.sizeTable(ViewportSize,ColumnSizes(1,1:7),ResizePolicy);

% Signal panel assembly

vSB = MJScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED;
hSB = MJScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED;
c.fill = GridBagConstraints.BOTH;
c.gridx = 0;
c.gridy = 0;
c.weightx = 1;
c.weighty = 1;
c.insets = Insets(2, 2, 2, 2);
pSetpoints = MJPanel(GridBagLayout);
pSetpoints.add(MJScrollPane(Setpoints.Table, vSB, hSB), c);
pUDisturbances = MJPanel(GridBagLayout); 
pUDisturbances.add(MJScrollPane(UnMeasDist.Table, vSB, hSB), c);

Title = TitledBorder(' Simulation settings ');
Title.setTitleFont(Font('Dialog',Font.PLAIN,12));
pLoop.setBorder(Title);
Title = TitledBorder(' Setpoints ');
Title.setTitleFont(Font('Dialog',Font.PLAIN,12));
pSetpoints.setBorder(Title);
Title = TitledBorder(' Unmeasured disturbances ');
Title.setTitleFont(Font('Dialog',Font.PLAIN,12));
pUDisturbances.setBorder(Title);

if NumMD > 0
    pDisturbances = MJPanel(GridBagLayout); 
    pDisturbances.add(MJScrollPane(MeasDist.Table, vSB, hSB), c);
    Title = TitledBorder(' Measured disturbances ');
    Title.setTitleFont(Font('Dialog',Font.PLAIN,12));
    pDisturbances.setBorder(Title);
end

% Run button
RunButton = MJButton('Simulate');
HelpButton = MJButton('Help');
RunPanel = MJPanel;
RunPanel.add(RunButton);
RunPanel.add(HelpButton);

% Dialog panel assembly
DialogPanel = MJPanel;
DialogPanel.setLayout(GridBagLayout);
c.fill = GridBagConstraints.HORIZONTAL;
c.insets = Insets(5, 5, 5, 5);
c.gridy = GridBagConstraints.RELATIVE;
c.weighty = 0;
DialogPanel.add(pLoop, c);
c.weighty = 0.5;
c.fill = GridBagConstraints.BOTH;
DialogPanel.add(pSetpoints, c);
% Add measured disturbances table if they are part of the structure
if NumMD > 0
    DialogPanel.add(pDisturbances, c);
end
DialogPanel.add(pUDisturbances, c);
c.weighty = 0;
c.fill = GridBagConstraints.HORIZONTAL;
DialogPanel.add(RunPanel, c);

% Save handles

this.Handles.RunButton = RunButton;
this.Handles.ControllerCombo = ControllerCombo;
this.Handles.ModelCombo = ModelCombo;
this.Handles.LoopCheckBox = LoopCheckBox;
this.Handles.ConstraintCheckBox = ConstraintCheckBox;
this.Handles.Setpoints = Setpoints;
this.Handles.UnMeasDist = UnMeasDist;
this.Handles.TsValue = TsValue;
this.Handles.TendField = TendField;
this.Handles.SignalCombo = SignalCombo;  % Cell editor for signal type column

% Define callbacks
set(handle(RunButton,'callbackproperties'),'ActionPerformedCallback',{@LocalCBs, this, 'RunButton', RunButton});
set(TendField,'ActionPerformedCallback',{@LocalCBs, this, 'Tend', TendField});
set(TendField,'FocusLostCallback',{@LocalCBs, this, 'Tend', TendField});
set(LoopCheckBox,'ActionPerformedCallback',{@LocalCBs, this, 'Loops', LoopCheckBox});
set(ConstraintCheckBox,'ActionPerformedCallback', ...
    {@LocalCBs, this, 'Constraints', ConstraintCheckBox});
set(ModelCombo, 'ActionPerformedCallback', {@LocalModelSelection, this});
set(ControllerCombo, 'ActionPerformedCallback', ...
    {@LocalControllerSelection, this});
set(handle(HelpButton, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@mpcCSHelp, 'MPCSIMMAIN'});

% Define listeners

this.addListeners(handle.listener(this, this.findprop('Tend'), ...
    'PropertyPostSet',{@localPanelListener, this, TendField}));
this.addListeners(handle.listener(this, this.findprop('ClosedLoop'), ...
    'PropertyPostSet',{@localPanelListener, this, LoopCheckBox}));
this.addListeners(handle.listener(this, this.findprop('ConstraintsEnforced'), ...
    'PropertyPostSet',{@localPanelListener, this, ConstraintCheckBox}));

% These react to a change in the MPCStructures node tabular data
S = this.getMPCStructure;
this.addListeners(handle.listener(S, S.findprop('InData'), ...
    'PropertyPostSet',{@StructureDataListener, this}));
this.addListeners(handle.listener(S, S.findprop('OutData'), ...
    'PropertyPostSet',{@StructureDataListener, this}));

% These listen for changes that require the scenario to be recalculated
this.addListeners(handle.listener(this, this.findprop('Ts'), ...
    'PropertyPostSet',{@localUpdateListener, this}));
this.addListeners(handle.listener(this, this.findprop('Tend'), ...
    'PropertyPostSet',{@localUpdateListener, this}));
this.addListeners(handle.listener(Setpoints, Setpoints.findprop('CellData'), ...
    'PropertyPostSet',{@localTableListener, this, Setpoints, true}));
if NumMD > 0
    this.Handles.MeasDist = MeasDist;
    this.addListeners(handle.listener(MeasDist, MeasDist.findprop('CellData'), ...
        'PropertyPostSet',{@localTableListener, this, MeasDist, false}));
else
    this.Handles.MeasDist = {};
end
this.addListeners(handle.listener(UnMeasDist, UnMeasDist.findprop('CellData'), ...
    'PropertyPostSet',{@localTableListener, this, UnMeasDist, false}));

% Listen for an update in scenario property
this.addListeners(handle.listener(this, this.findprop('Scenario'), ...
    'PropertyPostSet',{@ScenarioUpdateListener, this}));

% Set default values
if isempty(this.SaveData)
    setDefaultValues(this);
end
LocalRefreshTsLabel(this);

% ------------------------------------------------------

function StructureDataListener(eventSrc, eventData, this)

% Respond to a user modification to the tabular data on the 
% MPCStructure node.  Only affects the non-editable columns
% in the MPCController tables.

this.updateTables = 1;

% ------------------------------------------------------

function localUpdateListener(eventSrc, eventData, this)

% Responds to a change in the scenario data.  Set the flag
% that causes the scenario to be updated when next used in
% a simulation.

Root = this.getRoot;
this.HasUpdated = 1;
Root.Dirty = true;

% ------------------------------------------------------

function localTableListener(eventSrc, eventData, this, UTable, isRef)

% Responds to a change in the tablular data.

% Update notification
localUpdateListener(eventSrc, eventData, this);

% Initialization
hasChanged = false;
Data = UTable.CellData;
[Rows,Cols]=size(Data);

% Force look-ahead to be same for all signals in this table
if Cols == 8
    if isRef
        Test = this.rLookAhead;
    else
        Test = this.vLookAhead;
    end
    for i = 1:Rows
        if Data{i,8} ~= Test
            hasChanged = true;
            break
        end
    end
    if hasChanged
        if isRef
            this.rLookAhead = ~Test;
        else
            this.vLookAhead = ~Test;
        end
        for i = 1:Rows
            UTable.CellData{i,8} = logical(~Test);
        end
    end
end

% Possible update of editable status
isEditable = UTable.isEditable;
ix = [5:7];  % These are the columns that depend on signal type
newDefaults = false;
if all(size(isEditable) == [Rows, Cols])
    % isEditable is correct size, so check row contents.
    for i = 1:Rows
        Correct = localGetIsEditable(Data(i,3));
        if any(isEditable(i,ix) ~= Correct)
            isEditable(i,ix) = Correct;
            hasChanged = true;
            newDefaults = true;
        end
    end
else
    % isEditable is wrong size, so update
    isEditable = logical(ones(Rows,1)*isEditable(1,:));
    for i = 1:Rows
        isEditable(i,ix)= localGetIsEditable(Data(i,3));
    end
    hasChanged = true;
    newDefaults = true;
end

if hasChanged
    if newDefaults
        UTable.CellData = localResetDefaultValues(Data);
    end
    UTable.isEditable = isEditable;
    UTable.Table.getModel.updateTableData(UTable.Table, UTable, ...
        UTable.isEditable', UTable.CellData');
end

% ------------------------------------------------------

function CellData = localResetDefaultValues(Data)

% Resets defaults when signal types change.
[Rows,Cols] = size(Data);
CellData = Data;
jNullStr = java.lang.String('');
jOne = java.lang.String('1.0');
jZero = java.lang.String('0.0');
for i = 1:Rows
    Type = CellData{i,3};
    switch Type
        case {'Constant'}
            Defaults = {jNullStr, jNullStr, jNullStr};
        case {'Step', 'Ramp'}
            Defaults = {jOne, jOne, jNullStr};
        case {'Sine', 'Pulse'}
            Defaults = {jOne, jZero, jOne};
        case {'Gaussian'}
            Defaults = {jOne, jOne, jNullStr};
        otherwise
            error(sprintf('Unexpected signal type "%s"',Type));
    end
    CellData(i,5:7) = Defaults;
end

% ------------------------------------------------------

function Settings = localGetIsEditable(Type)

% Get appropriate isEditable settings for given signal type
SignalTypes = {'Constant','Step','Ramp','Sine','Pulse','Gaussian'};
itype = find(strcmp(SignalTypes,Type) == 1);
if isempty(itype)
    error(sprintf('Unable to match signal type "%s"',Type{1}));
end
Settings = [false, false, false
    true, true, false
    true, true, false
    true, true, true
    true, true, true
    true, true, false];
Settings = Settings(itype,:);


% ------------------------------------------------------

function LocalModelSelection(eventSrc, eventData, this)

% Callback when user selects a model in the combo box.
NewModel = this.Handles.ModelCombo.getSelectedItem;
if ischar(NewModel) && ~isempty(NewModel)
    this.PlantName = NewModel;
end

% ------------------------------------------------------

function LocalControllerSelection(eventSrc, eventData, this)

% Callback when user selects a controller in the combo box.
NewController = this.Handles.ControllerCombo.getSelectedItem;
if ischar(NewController) && ~isempty(NewController)
    this.ControllerName = NewController;
    LocalRefreshTsLabel(this);
end

% ------------------------------------------------------

function ScenarioUpdateListener(varargin)

this = varargin{end};
this.setNewDate;

% ------------------------------------------------------

function LocalRefreshTsLabel(varargin)

% Refreshes the controller sampling period label.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;
        
%disp('In LocalRefreshTsLabel')
this = varargin{end};
Controller = this.ControllerName;
ControllerNode = this.getMPCControllers.find('Label',Controller);
Ts = ControllerNode.Ts;        % String format
if isempty(Ts)
    Ts = '1';   % Default if controller node hasn't been opened yet.
end
this.Ts = evalin('base', Ts);  % Double
TsValue = this.Handles.TsValue;
Str = java.lang.String(num2str(this.Ts));
SwingUtilities.invokeLater(MLthread(TsValue,'setText',{Str}, ...
    'java.lang.String'));

% ------------------------------------------------------

function setDefaultValues(this)

% Sets default values and initial conditions.

S = this.getRoot;
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S);

% Initialize tabular data
Setpoints = cell(NumOut,8);
NumUMD = NumUD + NumMO + NumMV;
UnMeasDist = cell(NumUMD, 7);
Setpoints(:,:) = {java.lang.String(' ')};
Setpoints(:,3) = {'Constant'};
Setpoints(:,4) = {java.lang.String('0.0')};
Setpoints(:,8) = {false};
ix = [1 2 4];
jx = [1 4 5];
Setpoints(:,ix) = S.OutData(:,jx);
if NumMD > 0
    MeasDist = cell(NumMD, 8);
    MeasDist(:,:) = {java.lang.String(' ')};
    MeasDist(:,3) = {'Constant'};
    MeasDist(:,4) = {java.lang.String('0.0')};
    MeasDist(:,8) = {false};
    MeasDist(:,ix) = S.InData(S.iMD,jx);
    this.Handles.MeasDist.setCellData(MeasDist);
end
UnMeasDist(:,:) = {java.lang.String(' ')};
UnMeasDist(:,3) = {'Constant'};
UnMeasDist(:,4) = {java.lang.String('0.0')};

ix = [1 2];
jx = [1 4];
if NumUD > 0
    UnMeasDist(1:NumUD,ix) = S.InData(S.iUD,jx);
end
UnMeasDist(NumUD+1:NumUD+NumMO,ix) = S.OutData(S.iMO,jx);
UnMeasDist(NumUD+NumMO+1:end,ix) = S.InData(S.iMV,jx);

% Move local data to permanent storage
this.Handles.Setpoints.setCellData(Setpoints);
this.Handles.UnMeasDist.setCellData(UnMeasDist);

% -----------------------------------------------------

function localPanelListener(eventSrc, eventData, this, thisJava)

% Updates the dialog panel in response to changes in the underlying UDD
% objects.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

Prop = eventSrc.Name;
Val = get(this,Prop);
switch Prop
    case 'Tend'
        % Source is a JTextField
        Str=java.lang.String(Val);
        thisJava.setText(Str);
%         SwingUtilities.invokeLater(MLthread(thisJava,'setText', ...
%             {Str},'java.lang.String'));
    case {'ClosedLoop', 'ConstraintsEnforced'}
        % Source is a check box
        setJavaLogical(thisJava,'setSelected',Val);
    otherwise
        errordlg(['Unexpected property code "',Prop,'" in localPanelListener']);
end

% ---------------------------------------------

function LocalCBs(eventSrc, eventData, this, thisProp, thisJava)

% Handles callbacks for standard java controls.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

switch thisProp
    case 'Tend'
        % Store if valid.  Must be scalar >0 0.
        Num = char(thisJava.getText);
        Value = LocalStr2Double(Num);
        if ~isnan(Value) == 1 && Value > 0
            this.Tend = Num;
        else
            % Invalid, so replace java display with UDD value
            localFieldError(thisJava, 'Duration must be positive, finite.');
            PropS = java.lang.String(this.Tend);
            rw = MLthread(thisJava,'setText',{PropS},'java.lang.String');
            SwingUtilities.invokeLater(rw);
        end
    case 'Loops'
        % Source is a check box
        this.ClosedLoop = thisJava.isSelected;
    case 'Constraints'
        % Source is a check box
        this.ConstraintsEnforced = thisJava.isSelected;
    case 'RunButton'
        % User has pushed the run button
        this.runSimulation;
    otherwise
        errordlg(sprintf('Unexpected property code "%s" in LocalCBs', ...
            thisProp));
end

% --------------------------------------------------------------

function Value = LocalStr2Double(String)
try
    Value = evalin('base', String);
    if ~isreal(Value) || length(Value) > 1
        Value = NaN;
    end
catch
    Value = NaN;
end

% --------------------------------------------------------------------------- %

function Valid = localFieldError(thisJava,Message)
% Temporarily disable the field's loss of focus callback and display an
% error message.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

CB=get(thisJava,'FocusLostCallback');
set(thisJava,'FocusLostCallback',[]);
waitfor(errordlg(Message,'MPC Error','modal'));
set(thisJava,'FocusLostCallback',CB,'Selected','on');
rw = MLthread(thisJava,'requestFocus',{true},'boolean');
SwingUtilities.invokeLater(rw);
Valid = false;

% ---------------------------------------------

function OK = SignalCheckFcn(String, row, col)
% Check validity of user input.  Always accept a null string.
if col == 8
    % Editor is a checkbox, so must be OK
    OK = 1;
    return
end
String = char(String);
if length(String) == 0
    OK = 1;
    return
end
switch col
    case {3}
        % String controlled by a combo box, must be OK
        OK = 1;
    case {4, 5}
        % Any finite number is OK
        Value = LocalStr2Double(String);
        if isnan(Value) || abs(Value) == Inf
            waitfor(errordlg('Initial value & Size must be finite.', ...
                'MPC Error','modal'));
            OK = 0;
        else
            OK = 1;
        end
    otherwise
        % Must be non-negative, finite
        Value = LocalStr2Double(String);
        if isnan(Value) || Value < 0 || abs(Value) == Inf
            waitfor(errordlg('Time & Period must be positive, finite.', ...
                'MPC Error','modal'));
            OK = 0;
        else
            OK = 1;
        end
end
