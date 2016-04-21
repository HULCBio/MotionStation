function DialogPanel = getDialogSchema(this, manager)
%  Construct the MPCController dialog panel


%	Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.8.12 $  $Date: 2004/04/16 22:09:29 $
%       Author:  Larry Ricker

import java.awt.*;
import javax.swing.*;

S=this.getMPCStructure;
Frame = S.Frame;
if isempty(this.Dialog)
    % Create new panel.
    mpcCursor(Frame, 'wait');
    LocalUpdateStatus(S, sprintf('Initializing "%s" controller settings.', ...
        this.Label));
	DialogPanel = LocalDialogPanel(this);
    this.Dialog = DialogPanel;
    this.setIOdata(S);
    % Make sure the MPCControllers panel is created
    MPCControllers = this.up;
    if isempty(MPCControllers.Dialog)
        MPCControllers.getDialogInterface(MPCControllers.up.TreeManager);
    end
    mpcCursor(Frame, 'default');
else
    % Use existing panel.  Update tabular displays 
    % if necessary.
    if this.updateTables
        mpcCursor(Frame, 'wait');
        this.SignalLabelUpdate;
        mpcCursor(Frame, 'default');
    end
    DialogPanel = this.Dialog;
end
MPCControllers = this.up;
MPCControllers.CurrentController = this.Label;
mpcExporter = S.Handles.mpcExporter;
mpcExporter.CurrentController = this;

if isfield(S.Handles,'ExportMenu')  % Might not exist yet ...
    setJavaLogical(S.Handles.ExportMenu.getAction,'setEnabled',1);
end
% Update model combo box
MPCModels = this.getMPCModels;
mpc_combo_updater(this.Handles.ModelCombo, MPCModels.Labels, ...
    this.ModelName);
LocalUpdateStatus(S, '')

% --------------------------------------------------------------------------- %

function DialogPanel = LocalDialogPanel(this)

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

MyTitleFont = Font('Dialog',Font.PLAIN,12);

% Name of this node
Name = this.label;

% Start defining its dialog panel
DialogPanel = MJPanel(BorderLayout(0,0));

% Sizing dimensions
nHor = 570;
nVer = 450;

% Content is a tabbed panel
Content = MJTabbedPane;

% Models and horizons tab
ComboDimension = Dimension(120,25);
% Model combo box
ModelLabel = MJLabel('Plant model:  ');
ModelLabel.setFont(MyTitleFont);
ModelCombo = MJComboBox;
ModelCombo.addItem('Dummy');
ModelCombo.setEditable(false);
ModelCombo.setSelectedIndex(0);
ModelCombo.setPreferredSize(ComboDimension);
p1 = MJPanel;
p1.add(ModelLabel);
p1.add(ModelCombo);

% Horizons panel
p2 = MJPanel;
p2.setLayout(GridBagLayout);
Title2 = TitledBorder(' Horizons ');
Title2.setTitleFont(MyTitleFont);
p2.setBorder(Title2);
c = GridBagConstraints;
c.insets = Insets(5,3,5,3);
c.gridx = 0;
c.gridheight = 1;
c.gridy = GridBagConstraints.RELATIVE;
LabelDimension = Dimension(240, 20);
TextDimension = Dimension(100,20);
tsLabel = MJLabel('Control interval (time units):');
 pLabel = MJLabel('Prediction horizon (intervals):');
 mLabel = MJLabel('Control horizon (intervals):');
tsLabel.setPreferredSize(LabelDimension);
 pLabel.setPreferredSize(LabelDimension);
 mLabel.setPreferredSize(LabelDimension);
p2.add(tsLabel, c);
p2.add( pLabel, c);
p2.add( mLabel, c);

tsText = MJTextField(this.Ts);
 pText = MJTextField(this.P);
 mText = MJTextField(this.M);
c.gridx = 1;
c.gridy = GridBagConstraints.RELATIVE;
tsText.setPreferredSize(TextDimension);
pText.setPreferredSize(TextDimension);
mText.setPreferredSize(TextDimension);
p2.add(tsText, c);
p2.add(pText, c);
p2.add(mText, c);

% NOTE:  these handles are enabled when blocking is off:
noBlocks = [mLabel mText]; 

blockingCB = MJCheckBox('Blocking',this.Blocking);
c.gridx = 0;
c.gridy = 3;
c.gridwidth = 2;
%p2.add(blockingCB, c);

% Blocking panel
LabelDimension = Dimension(240, 20);
p3 = MJPanel;
p3.setLayout(GridBagLayout);
Title3 = TitledBorder(' Blocking ');
Title3.setTitleFont(MyTitleFont);
p3.setBorder(Title3);
       nbLabel = MJLabel('Number of moves computed per step:');
 blkComboLabel = MJLabel('Blocking allocation within prediction horizon:');
blkVectorLabel = MJLabel('Custom move allocation vector:');
       nbLabel.setPreferredSize(LabelDimension);
 blkComboLabel.setPreferredSize(LabelDimension);
blkVectorLabel.setPreferredSize(LabelDimension);
c.gridx = 0;
c.gridwidth = 1;
c.gridy = GridBagConstraints.RELATIVE;
p3.add(blkComboLabel, c);
p3.add(nbLabel, c);
p3.add(blkVectorLabel, c);

nbText = MJTextField;
nbText.setPreferredSize(TextDimension);
blkCombo = MJComboBox;
blkCombo.addItem('Beginning');
blkCombo.addItem('Uniform');
blkCombo.addItem('End');
blkCombo.addItem('Custom');
blkCombo.setEditable(0);
blkCombo.setSelectedIndex(0);
blkCombo.setPreferredSize(TextDimension);
blkVector = MJTextField;
blkVector.setPreferredSize(TextDimension);

c.gridx = 1;
c.gridy = GridBagConstraints.RELATIVE;
c.gridwidth = 3;
p3.add(blkCombo, c);
c.gridwidth = 1;
p3.add(nbText, c);
c.gridwidth = 3;
p3.add(blkVector, c);

p4 = javax.swing.Box(BoxLayout.X_AXIS);
helpHorPane = MJButton('Help');
p4.add(p4.createHorizontalStrut(300));
p4.add(helpHorPane);


% NOTE:  these handles are disabled when blocking is off:
yesBlocks = [nbLabel, nbText, blkComboLabel, blkCombo, ...
        blkVectorLabel, blkVector];

% ** Finish this tab **
mhTab = MJPanel;
Bx = javax.swing.Box(BoxLayout.Y_AXIS);
Bx.add(Bx.createVerticalStrut(50));
Bx.add(p1);
Bx.add(Bx.createVerticalStrut(15));
Bx.add(p2);
Bx.add(Bx.createVerticalStrut(10));
Bx.add(blockingCB);
Bx.add(Bx.createVerticalStrut(10));
Bx.add(p3);
Bx.add(Bx.createVerticalStrut(30));
Bx.add(p4);
Bx.add(Bx.createVerticalGlue);
mhTab.add(Bx);
Content.addTab('Model and Horizons', mhTab);

% Constraints & sensitivities tab

% Tables

Str = 'String';  % Dummy for use in javaClass definition
% Input constraints
ColNames = {'Name','Units','Minimum','Maximum','Max Down Rate','Max Up Rate'};
javaClass = logical(ones(1,6));
isEditable = [false false true true true true];
ULimits=mpcobjects.TableObject(ColNames, isEditable, javaClass, ...
    cell(0,6), @LimitsCheckFcn, this);
ULimits.Table = MPCTable(ULimits, ColNames, isEditable', cell(6,0), javaClass);

% Output constraints
ColNames = {'Name','Units','Minimum','Maximum'};
javaClass = [true true true true];
isEditable = [false false true true];
YLimits=mpcobjects.TableObject(ColNames, isEditable, javaClass, ...
    cell(0,4), @LimitsCheckFcn, this);
YLimits.Table = MPCTable(YLimits, ColNames, isEditable', cell(4,0), javaClass);

% Input sensitivities
ColNames = {'Name','Description','Units','Weight','Rate weight'};
isEditable = [false false false true true];
javaClass = [true true true true true];
Uwts=mpcobjects.TableObject(ColNames, isEditable, javaClass, ...
    cell(0,5), @WtsCheckFcn, this);
Uwts.Table = MPCTable(Uwts, ColNames, isEditable', cell(5,0), javaClass);

% Output sensitivities
ColNames = {'Name','Description','Units','Weight'};
isEditable = [false false false true];
javaClass = [true true true true];
Ywts=mpcobjects.TableObject(ColNames, isEditable, javaClass, ...
    cell(0,4), @WtsCheckFcn, this);
Ywts.Table = MPCTable(Ywts, ColNames, isEditable', cell(4,0), javaClass);

% Input softening
ColNames = {'Name','Units','Minimum','Min Band','Maximum','Max Band', ...
        'Max Down Rate','Max Down Band','Max Up Rate','Max Up Band'};
isEditable = [false false true true true true true true true true];
javaClass = logical(ones(1,10));
Usoft=mpcobjects.TableObject(ColNames, isEditable, javaClass, ...
    cell(0,10), @UsoftCheckFcn, this);
Usoft.Table = MPCTable(Usoft, ColNames, isEditable', cell(10,0), javaClass);

% Output softening
ColNames = {'Name','Units','Minimum','Min Band','Maximum','Max Band'};
isEditable = [false false true true true true];
javaClass = logical(ones(1,6));
Ysoft=mpcobjects.TableObject(ColNames, isEditable, javaClass, ...
    cell(0,6), @YsoftCheckFcn, this);
Ysoft.Table = MPCTable(Ysoft, ColNames, isEditable', cell(6,0), javaClass);

% Layout parameters

vSB = MJScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED;
hSB = MJScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED;

% Constraints tab
% Input region
c.fill = GridBagConstraints.BOTH;
c.gridx = 0;
c.gridy = 0;
c.weightx = 1;
c.weighty = 1;
c.insets = Insets(0, 0, 0, 0);
inPanel = MJPanel;
inPanel.setLayout(GridBagLayout);
Title8 = TitledBorder(' Constraints on manipulated variables ');
Title8.setTitleFont(MyTitleFont);
inPanel.setBorder(Title8);
inPanel.add(MJScrollPane(ULimits.Table, vSB, hSB), c);
% Output region
outPanel = MJPanel;
outPanel.setLayout(GridBagLayout);
Title9 = TitledBorder(' Constraints on output variables');
Title9.setTitleFont(MyTitleFont);
outPanel.setBorder(Title9);
outPanel.add(MJScrollPane(YLimits.Table, vSB, hSB), c);
% Button region
butPanel = MJPanel;
softButton = MJButton('Constraint Softening');
helpConPane = MJButton('Help');
butPanel.add(softButton);
butPanel.add(helpConPane);

% Assembly
pConstraints = MJPanel;
pConstraints.setLayout(GridBagLayout);
c.gridy = 0;
c.weighty = 0.5;
c.insets = Insets(5, 0, 5, 0);
pConstraints.add(inPanel, c);
c.gridy = 1;
pConstraints.add(outPanel, c);
c.gridy = 2;
c.weighty = 0;
pConstraints.add(butPanel, c);
Content.addTab('Constraints', pConstraints);


% Weight Tuning tab

c = GridBagConstraints;
c.gridx = 0;
c.gridy = 0;
c.weightx = 1;

% Overall tracking/robustness
TrackingUDD = mpcobjects.SliderObject(0.8,0,1,false);
TPanel=TrackingUDD.Panel;
TPanel.MinLabel.setText('More robust');
TPanel.MaxLabel.setText('Faster response');
oPanel = MJPanel;
Title6 = TitledBorder(' Overall ');
Title6.setTitleFont(MyTitleFont);
oPanel.setBorder(Title6);
oPanel.setLayout(GridBagLayout);
c.weighty = 0;
c.fill = GridBagConstraints.HORIZONTAL;
oPanel.add(TPanel, c);

% Input region
inPanel = MJPanel;
inPanel.setLayout(GridBagLayout);
Title4 = TitledBorder(' Input weights ');
Title4.setTitleFont(MyTitleFont);
inPanel.setBorder(Title4);
c.weighty = 1;
c.fill = GridBagConstraints.BOTH;
inPanel.add(MJScrollPane(Uwts.Table, vSB, hSB), c);
% Output region
outPanel = MJPanel;
outPanel.setLayout(GridBagLayout);
Title5 = TitledBorder(' Output weights ');
Title5.setTitleFont(MyTitleFont);
outPanel.setBorder(Title5);
outPanel.add(MJScrollPane(Ywts.Table, vSB, hSB), c);
pSensitivities = MJPanel;
pSensitivities.setLayout(GridBagLayout);
pSensitivities.setPreferredSize(Dimension(nHor,nVer));
c.insets = Insets(5, 0, 5, 0);
c.weighty = 0;
c.fill = GridBagConstraints.HORIZONTAL;
pSensitivities.add(oPanel, c);
c.gridy = 1;
c.weighty = 0.5;
c.fill = GridBagConstraints.BOTH;
pSensitivities.add(inPanel, c);
c.gridy = 2;
pSensitivities.add(outPanel, c);
% Help
p4 = javax.swing.Box(BoxLayout.X_AXIS);
helpWtPane = MJButton('Help');
p4.add(p4.createHorizontalStrut(nHor-60));
p4.add(helpWtPane);
c.gridy = 3;
c.weighty = 0;
pSensitivities.add(p4, c);


Content.addTab('Weight Tuning', pSensitivities);

% Estimation tab

% Status

StatusMessage = MJLabel;
RestoreButton = MJButton('Use MPC Defaults');
helpEstPane = MJButton('Help');
pStatus = MJPanel(GridBagLayout);
c = GridBagConstraints;
c.fill = GridBagConstraints.HORIZONTAL;
c.weighty = 1;
c.insets = Insets(0, 15, 0, 15);
c.gridx = 0;
c.gridy = 0;
pStatus.add(StatusMessage, c);
c.gridx =1;
pStatus.add(RestoreButton, c);
c.gridx =2;
pStatus.add(helpEstPane, c);

% Gain slider
GainUDD = mpcobjects.SliderObject(0.5,0,1,false);
pGain = GainUDD.Panel;
pGain.MinLabel.setText('Low gain');
pGain.MaxLabel.setText('High gain');
TitleG = TitledBorder(' Overall estimator gain ');
TitleG.setTitleFont(MyTitleFont);
pGain.setBorder(TitleG);

% Graphics
IDmGraph = MJLabel(ImageIcon(which('UDinputmodel.gif')));
ODmGraph = MJLabel(ImageIcon(which('UDoutputmodel.gif')));
NmGraph = MJLabel(ImageIcon(which('NoiseModel.gif')));
IDsGraph = MJLabel(ImageIcon(which('UDinputsignal.gif')));
ODsGraph = MJLabel(ImageIcon(which('UDoutputsignal.gif')));
NsGraph = MJLabel(ImageIcon(which('NoiseSignal.gif')));

% disp('Creating estimation panels')
% Output disturbance tab
[OutPanel, OutHandles] = createEstimationPanel(this,  ... 
    ODmGraph, ODsGraph, {'Steps','Ramps','White'}, 1);
% Input disturbance tab
[InPanel, InHandles] = createEstimationPanel(this,  ... 
    IDmGraph, IDsGraph, {'Steps','Ramps','White'}, 2);
% Noise tab
[NoisePanel, NoiseHandles] = createEstimationPanel(this,  ... 
    NmGraph, NsGraph, {'White','Steps'}, 3);

% Assemble tabs
EstTabs = MJTabbedPane;
EstTabs.addTab('Output Disturbances', OutPanel);
EstTabs.addTab('Input Disturbances', InPanel);
EstTabs.addTab('Measurement Noise', NoisePanel);
S = this.getMPCStructure;
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S);
if NumUD <=0
    awtinvoke(EstTabs,'setEnabledAt',1,false);
end

% Estimation tab assembly
eTab = MJPanel(GridBagLayout);
c = GridBagConstraints;
c.fill = GridBagConstraints.HORIZONTAL;
c.insets = Insets(5, 0, 5, 0);
c.gridx = 0;
c.gridy = GridBagConstraints.RELATIVE;
c.weighty = 0;
c.weightx = 1;
eTab.add(pGain, c);
c.weightx = 1;
c.weighty = 1;
c.fill = GridBagConstraints.BOTH;
eTab.add(EstTabs, c);
c.fill = GridBagConstraints.HORIZONTAL;
c.weighty = 0;
c.weightx = 1;
eTab.add(pStatus, c);
Content.addTab('Estimation (advanced)', eTab);


% Constraint hardness slider

HardnessUDD = mpcobjects.SliderObject(0.75,0,1,false);

% Save handles.

DialogPanel.add(Content, BorderLayout.CENTER);
this.Handles.Buttons = struct('tsText',{tsText}, ...
     'pText',{pText}, 'mText',{mText}, ...
    'blockingCB',{blockingCB}, 'noBlocks',{noBlocks}, ...
    'yesBlocks',{yesBlocks}, 'blkCombo',{blkCombo}, ...
    'nbText',{nbText}, 'blkVector',{blkVector}, ...
    'softButton',{softButton});
this.Handles.ModelCombo = ModelCombo;
this.Handles.GainUDD = GainUDD;
this.Handles.EstTabs = EstTabs;
this.Handles.eHandles(1) = OutHandles;
this.Handles.eHandles(2) = InHandles;
this.Handles.eHandles(3) = NoiseHandles;
this.Handles.softButton = softButton;
this.Handles.ULimits = ULimits;
this.Handles.YLimits = YLimits;
this.Handles.Uwts = Uwts;
this.Handles.Ywts = Ywts;
this.Handles.Usoft = Usoft;
this.Handles.Ysoft = Ysoft;
this.Handles.TrackingUDD = TrackingUDD;
this.Handles.HardnessUDD = HardnessUDD;
this.Handles.StatusMessage = StatusMessage;
this.Handles.RestoreButton = RestoreButton;

% Now initialize everything ...
this.setBlockingEnabledState;

% Define callbacks
set(blockingCB,'ActionPerformedCallback',{@ModelnHorizonCBs, this, ...
    'Blocking', blockingCB});
set(blkCombo,'ActionPerformedCallback',{@ModelnHorizonCBs, this, ...
    'BlockAllocation', blkCombo});
set(ModelCombo, 'ActionPerformedCallback', {@LocalModelSelection, this});
TextFields = {tsText, pText, mText, nbText, blkVector};
Properties = {'Ts','P','M','BlockMoves','CustomAllocation'};
for i=1:length(TextFields)
    set(TextFields{i}, ...
        'ActionPerformedCallback',{@ModelnHorizonCBs, this, ...
        Properties{i}, TextFields{i}}, ...
        'FocusLostCallback',{@ModelnHorizonCBs, this, ...
        Properties{i}, TextFields{i}});
end
set(softButton, 'ActionPerformedCallback',{@MPCrelaxationBands, this, ...
        Usoft, Ysoft, HardnessUDD, vSB, hSB});
set(handle(eTab,'callbackproperties'), ...
    'ComponentShownCallback',{@EstimationCBs, this, 'EstTab', 1});
set(RestoreButton, 'ActionPerformedCallback', ...
    {@EstimationCBs, this, 'Defaults', 1});
set(handle(helpHorPane, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@mpcCSHelp, 'MPCCONHORIZON'});
set(handle(helpConPane, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@mpcCSHelp, 'MPCCONCONSTRAINT'});
set(handle(helpWtPane, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@mpcCSHelp, 'MPCCONWEIGHT'});
set(handle(helpEstPane, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@mpcCSHelp, 'MPCCONESTIMATOR'});

% Listeners

% These react to a change in an MPCController UDD property.  
% The listener updates the display.
this.addListeners(handle.listener(this, this.findprop('Ts'), ...
    'PropertyPostSet',{@localPanelListener, this, tsText}));
this.addListeners(handle.listener(this, this.findprop('P'), ...
    'PropertyPostSet',{@localPanelListener, this, pText}));
this.addListeners(handle.listener(this, this.findprop('M'), ...
    'PropertyPostSet',{@localPanelListener, this, mText}));
this.addListeners(handle.listener(this, this.findprop('Blocking'), ...
    'PropertyPostSet',{@localPanelListener, this, blockingCB}));
this.addListeners(handle.listener(this, this.findprop('BlockMoves'), ...
    'PropertyPostSet',{@localPanelListener, this, nbText}));
this.addListeners(handle.listener(this, this.findprop('BlockAllocation'), ...
    'PropertyPostSet',{@localPanelListener, this, blkCombo}));
this.addListeners(handle.listener(this, this.findprop('CustomAllocation'), ...
    'PropertyPostSet',{@localPanelListener, this, blkVector}));
this.addListeners(handle.listener(this, this.findprop('DefaultEstimator'), ...
    'PropertyPostSet',{@LocalRefreshEstimStates, this}));

% These react to a change in the MPCStructures node tabular data
S = this.getMPCStructure;
this.addListeners(handle.listener(S, S.findprop('InData'), ...
    'PropertyPostSet',{@StructureDataListener, this}));
this.addListeners(handle.listener(S, S.findprop('OutData'), ...
    'PropertyPostSet',{@StructureDataListener, this}));

% This reacts to changes in estimator parameters
this.addListeners(handle.listener(this, this.findprop('EstimData'), ...
    'PropertyPostSet',{@LocalRefreshEstimStates, this, 'Update'}));

% Add listeners that react to a change in the node label
this.addListeners(handle.listener(this, this.findprop('Label'), ...
    'PropertyPreSet',{@LocalLabelListenerPreSet, this}));
this.addListeners(handle.listener(this, this.findprop('Label'), ...
    'PropertyPostSet',{@LocalLabelListenerPostSet, this}));

% Initial conditions
if isempty(this.SaveData)
    LocalInitialState(this);
else
    LocalRestoreState(this);
end
this.RefreshEstimStates;

this.HasUpdated = 1;  % Signals that there's new data in tables.
this.getRoot.Dirty = true;
this.ExportNeeded = 1;
addChangeListeners(this);

% ------------------------------------------------------

function LocalInitialState(this)

% Locate the root and models nodes

S = this.getMPCStructure;
MPCModels = this.getMPCModels;

% If no mpc object was supplied ...
LTImodel = this.getSelectedLTImodel;
if LTImodel.Ts > 0
    this.Ts = num2str(LTImodel.Ts);
end
this.BlockMoves = '3';
this.BlockAllocation = 'Beginning';
this.CustomAllocation = '[ 2 3 5 ]';

% When initializing, we want to change table CellData property once.
% Otherwise the listeners will fire multiple events.
% So first initialize temporary variables
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S);
ULimits = cell(NumMV,6);
YLimits = cell(NumOut,4);
Uwts = cell(NumMV,5);
Ywts = cell(NumOut,4);
Usoft = cell(NumMV,10);
Ysoft = cell(NumOut,6);
Nsize = cell(NumMO,4);
IDsize = cell(NumUD,4);
ODsize = cell(NumOut,4);

% Default values
ULimits(:,:) = {''};
Uwts(:,:) = {''};
Usoft(:,:) = {''};
Uwts(:,4) = {'0'};        
Uwts(:,5) = {'0.1'};
YLimits(:,:) = {''};
Ywts(:,:) = {''};
Ysoft(:,:) = {''};
Ywts(:,4) = {'1.0'};

% Now make the changes
this.Handles.ULimits.setCellData(ULimits);
this.Handles.YLimits.setCellData(YLimits);
this.Handles.Uwts.setCellData(Uwts);
this.Handles.Ywts.setCellData(Ywts);
this.Handles.Usoft.setCellData(Usoft);
this.Handles.Ysoft.setCellData(Ysoft);
this.Handles.eHandles(1).UDD.setCellData(ODsize);
this.Handles.eHandles(2).UDD.setCellData(IDsize);
this.Handles.eHandles(3).UDD.setCellData(Nsize);

% Also initialize from the MPCStructure tables
this.SignalLabelUpdate;

% ------------------------------------------------------

function LocalRestoreState(this)

% Restore the panel state after a load -- overwrites the default values

H = this.Handles.Buttons;
H.nbText.setText(this.BlockMoves);
H.blkVector.setText(this.CustomAllocation);
H.blkCombo.setSelectedItem(this.BlockAllocation);
H=this.Handles;
H.GainUDD.Value = this.SaveData{1};
H.eHandles(1).UDD.setCellData(this.SaveData{2});
H.eHandles(2).UDD.setCellData(this.SaveData{3});
H.eHandles(3).UDD.setCellData(this.SaveData{4});
H.ULimits.setCellData(this.SaveData{5});
H.YLimits.setCellData(this.SaveData{6});
H.Uwts.setCellData(this.SaveData{7});
H.Ywts.setCellData(this.SaveData{8});
H.Usoft.setCellData(this.SaveData{9});
H.Ysoft.setCellData(this.SaveData{10});
H.TrackingUDD.Value = this.SaveData{11};
H.HardnessUDD.Value = this.SaveData{12};

this.SaveData = [];
this.setBlockingEnabledState;

% -----------------------------------------------------

function [Panel, Handles] = createEstimationPanel(this, ... 
    ModelGraph, SignalGraph, Choices, Index)

% Sets up one of the three identical panels for the estimation tab

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

% Graphics (2 layers in card layout)
PanelSize = Dimension(550, 180);
GraphLayers = MJPanel;
GraphLayout = CardLayout;
GraphLayers.setLayout(GraphLayout);
GraphLayers.setPreferredSize(PanelSize);
%GraphLayers.setMinimumSize(PanelSize);
pSignal = MJPanel;
pSignal.setPreferredSize(PanelSize);
pModel = MJPanel;
pModel.setPreferredSize(PanelSize);
pSignal.add(SignalGraph);
pModel.add(ModelGraph);
GraphLayers.add(pSignal, 'Signal');
GraphLayers.add(pModel, 'Model');

% Model/signal option radio buttons
rbGroup = ButtonGroup;
ModelUsed = this.EstimData(Index).ModelUsed;
rbSignal = MJRadioButton('Signal-by-signal', ~ModelUsed);
rbModel = MJRadioButton('LTI model in Workspace', ModelUsed);
rbGroup.add(rbSignal);
rbGroup.add(rbModel);
rbSignal.setPreferredSize(rbModel.getPreferredSize);

% Model browser
TextField = MJTextField(24);
Button = MJButton('Browse ... ');
BrowserPanel = MJPanel(GridBagLayout);
c = GridBagConstraints;
c.fill = GridBagConstraints.HORIZONTAL;
c.weightx = 1;
BrowserPanel.add(TextField, c);
c.weightx = 0;
c.gridx = 1;
c.insets = Insets(20, 5, 20, 0);
BrowserPanel.add(Button, c);

% Table section
Str = 'String'; 
ColNames = {'Name','Units','Type','Magnitude'};
javaClass = [true true true true];
isEditable = [false false true true];
if Index == 1
    UDD = mpcobjects.TableObject(ColNames, isEditable, javaClass, ...
        cell(0,4), @NoiseCheckFcnOD, this);
else
    UDD = mpcobjects.TableObject(ColNames, isEditable, javaClass, ...
        cell(0,4), @NoiseCheckFcn, this);
end
UDD.Table = MPCTable(UDD, ColNames, isEditable', cell(4,0), javaClass);
Col3 = UDD.Table.getColumnModel.getColumn(2);
ComboEditor=MJComboBox;
for i = 1:length(Choices)
    ComboEditor.addItem(Choices{i});
end
Col3.setCellEditor(DefaultCellEditor(ComboEditor));
ViewportSize = [350, 100];
ColumnSizes = [100, 100, 70, 70];
ResizePolicy = '';
UDD.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);
TablePanel = MJPanel;
TablePanel.setLayout(GridBagLayout);
c = GridBagConstraints;
c.insets = Insets(10, 0, 0, 0);
c.weighty = 1;
c.weightx = 1;
c.fill = GridBagConstraints.BOTH;
TablePanel.add(MJScrollPane(UDD.Table), c);

% Final panel assembly
c = GridBagConstraints;
jPanel = MJPanel(GridBagLayout);
c.gridx = 0;
c.gridy = 0;
c.weighty = 1;
c.weightx = 0;
c.fill = GridBagConstraints.BOTH;
c.insets = Insets(0, 0, 0, 5);
jPanel.add(rbSignal, c);
c.gridx = 1;
c.weightx = 1;
jPanel.add(TablePanel, c);
c.weighty = 0;
c.weightx = 0;
c.gridx = 0;
c.gridy = 1;
jPanel.add(rbModel, c);
c.gridx = 1;
c.weightx = 1;
jPanel.add(BrowserPanel, c);
c.gridx = 0;
c.gridy = 2;
c.gridwidth = 2;
jPanel.add(GraphLayers, c);
Panel = MJScrollPane;
Panel.setViewportView(jPanel);

% Save handles
Handles = struct( 'pSignal', {pSignal}, ...
    'pModel', {pModel}, ...
    'GraphLayers', {GraphLayers}, ...
    'GraphLayout', {GraphLayout}, ...
    'UDD', {UDD}, ...
    'ComboEditor', {ComboEditor}, ...
    'TextField', {TextField}, ...
    'rbModel', {rbModel}, ...
    'rbSignal', {rbSignal}, ...
    'Button', {Button} );

% Callbacks
set(handle(TextField,'callbackproperties'), ...
    'FocusLostCallback',{@EstimationCBs, this, 'TextField', Index});
set(handle(TextField,'callbackproperties'), ...
    'ActionPerformedCallback',{@EstimationCBs, this, 'TextField', Index});
set(handle(rbModel,'callbackproperties'), ...
    'ActionPerformedCallback',{@EstimationCBs, this, 'Radio', Index});
set(handle(rbSignal,'callbackproperties'), ...
    'ActionPerformedCallback',{@EstimationCBs, this, 'Radio', Index});
set(handle(Button,'callbackproperties'), ...
    'ActionPerformedCallback',{@EstimationCBs, this, 'Button', Index});

% -----------------------------------------------------

function EstimationCBs(eventSrc, eventData, this, Source, Index)

% Handles callbacks for option controls on the estimation panels.

import com.mathworks.mwswing.*;

Handles = this.Handles.eHandles(Index);
switch Source
    case 'Radio'
        State = Handles.rbModel.isSelected;
        if xor(State, this.EstimData(Index).ModelUsed)
            this.EstimData(Index).ModelUsed = State;
            DataChangeListener(this, this, this);
        end
    case 'TextField'
        Name = char(Handles.TextField.getText);
        if length(Name) <= 0
            % Ignore blank text field entry
            return
        end
        EstimModelLoader(this, Index, Name);
    case 'Button'
        EstimModelBrowser(this, Index);
    case 'EstTab'
        if (this.DefaultEstimator & isempty(this.MPCobject)) ||  ...
                isempty(char(this.Handles.eHandles(1).UDD.CellData{1,4}))
            % The user has selected the estimation tab.  If there is no
            % MPC object we need to create one and initialize the data
            % tables to display the default strategy.
            this.setDefaultEstimator;
        end
    case 'Defaults'
        this.setDefaultEstimator;
end

% -----------------------------------------------------

function EstimModelBrowser(this, Index);

global MPC_DIST_BROWSER MPC_DIST_LISTENER

import com.mathworks.mwswing.*;
import java.awt.*;
import javax.swing.*;

% Constants
nHor = 350;
nVer = 225;

% Panel
Dialog = MJDialog;
Dialog.setModal(true);
Dialog.setSize(Dimension(nHor,nVer));
Dialog.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
Dialog.setTitle('MPC Disturbance Model Selection');
Frame = this.getRoot.Frame;
Loc = Frame.getLocation;
Size = Frame.getSize;
DiaLoc = java.awt.Point(Loc.getX + (Size.getWidth - nHor)/2, ...
    Loc.getY + (Size.getHeight - nVer)/2);
Dialog.setLocation(DiaLoc);

% Panel label

broLabel = MJLabel('LTI models in your Workspace');

% LTI object browser

browser = mpcobjects.mpcbrowser;
browser.typesallowed={'ss','tf','zpk'};
browser.javahandle.setSize(Dimension(nHor-20, nVer-70));

% Buttons

OK = MJButton('OK');
Cancel = MJButton('Cancel');
Help = MJButton('Help');
butPanel = MJPanel;
butPanel.add(OK);
butPanel.add(Cancel);
butPanel.add(Help);

% Final panel assembly

p = Dialog.getContentPane;
p.setLayout(GridBagLayout);
c = GridBagConstraints;
c.fill = GridBagConstraints.BOTH;
c.weightx = 1;
c.weighty = 0;
c.insets = Insets(5, 10, 5, 10);
c.gridx = 0;
c.gridy = 0;
p.add(broLabel, c);
c.weighty = 1;
c.gridy = 1;
p.add(browser.javahandle, c);
c.gridy = 2;
c.weighty = 0;
p.add(butPanel, c);

% Define callbacks
set(handle(OK,'callbackproperties'),'ActionPerformedCallback', ...
    {@LocalEstButtons, Dialog, 'OK', this, Index});
set(handle(Cancel,'callbackproperties'),'ActionPerformedCallback', ...
    {@LocalEstButtons, Dialog, 'Cancel', this, Index});
set(handle(Help,'callbackproperties'),'ActionPerformedCallback', ...
    {@mpcCSHelp, 'MPCCONESTBROWSER', Dialog});

% Make it visible
MPC_DIST_BROWSER = browser;
browser.open;
if browser.javahandle.getItemCount > 0
    browser.javahandle.setSelectedIndex(0);
end
browser.javahandle.setActionCommand('OK');
MPC_DIST_LISTENER = handle.listener(browser, 'rightmenuselect', ...
    {@LocalEstButtons, Dialog, 'OK', this, Index});
awtinvoke(Dialog,'setVisible',true);

% ------------------------------------------------------

function LocalEstButtons(eventSource, eventData, Dialog, Action, ...
            this, Index)

% Handle callbacks for estimator browser
global MPC_DIST_BROWSER

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;
import java.awt.*;

switch Action
    case 'OK'
        % Close the dialog, accepting all input.
        Handles = this.Handles.eHandles(Index);
        Struc = MPC_DIST_BROWSER.getSelectedVarInfo;
        if ~isempty(Struc)
            ModelName = Struc.name;
            if EstimModelLoader(this, Index, ModelName)
                Handles.TextField.setText(ModelName);
            end
        end
        awtinvoke(Dialog,'dispose');
    case 'Cancel'
        % Close the dialog without changing the stored tables
        awtinvoke(Dialog,'dispose');
end

% -----------------------------------------------------

function OK = EstimModelLoader(this, Index, ModelName);

% Ignore name if model is from an imported MPC object
if strncmp(ModelName, 'From:', 5), return, end  
OK = false;
Model = evalin('base', ModelName, '[]');
if isempty(Model)
    Tab = char(this.Handles.EstTabs.getTitleAt(Index-1));
    Msg = sprintf(['You have chosen "%s" to model', ...
        ' %s, but "%s" is an illegal MATLAB expression or refers to a', ...
        ' variable not defined in your MATLAB workspace.', ...
        '  Please try again.'], ...
        ModelName, Tab, ModelName);
    LocalEstimError(this, Index, Msg);
    return
end

ModelClass = class(Model);
if ~strcmp(ModelClass,'ss') && ~strcmp(ModelClass,'tf') && ...
        ~strcmp(ModelClass,'zpk')
    Msg = sprintf(['You have chosen "%s" to model disturbances', ...
        ' or noise, but the model is not an LTI object of type', ...
        ' ss, tf, or zpk.'], ModelName);
    LocalEstimError(this, Index, Msg);
    return
end

% Verify that model being loaded has correct number of outputs.
% If so, complete loading process.

S = this.getRoot;
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S);
Sizes = [NumOut, NumUD, NumMO];
Num = Sizes(Index);
ny = length(Model.OutputName);

if Num == ny
    this.EstimData(Index).ModelName = ModelName;
    this.EstimData(Index).Model = Model;
    DataChangeListener(this, this, this);
else
    Msg = sprintf(['Chosen model "%s" has %i outputs.  ', ...
            'The required number is %i.'], ModelName, ny, Num);
    LocalEstimError(this, Index, Msg);
    return
end
this.RefreshEstimStates;
OK = true;

% ---------------------------------------------------

function LocalEstimError(this, Index, Msg)

Tab = char(this.Handles.EstTabs.getTitleAt(Index-1));
errordlg(sprintf(['Bad entry on estimation tab "%s" of ', ...
    'controller "%s".\n\n%s'], Tab, this.Label, Msg), ...
    'MPC Error', 'modal');
this.getRoot.TreeManager.Explorer.setSelected(this.getTreeNodeInterface);

% -----------------------------------------------------

function LocalRefreshEstimStates(eventSource, eventData, this, UpdtFlag)

if nargin >= 4 
    if ischar(UpdtFlag) && strcmp(UpdtFlag, 'Update')
        this.DefaultEstimator = false;
    end
end
this.RefreshEstimStates;

% -----------------------------------------------------

function LocalConstraintUpdate(this, Mode)

% Copy the bounds from the Ulimits and Ylimits tables to the
% corresponding Usoft and Ysoft tables, or vice-versa.

Ucon = this.Handles.ULimits;
Ycon = this.Handles.YLimits;
ULimits = Ucon.CellData;
YLimits = Ycon.CellData;
Usoft = this.Handles.Usoft;
Ysoft = this.Handles.Ysoft;
Udata = Usoft.CellData;
Ydata = Ysoft.CellData;
switch Mode
    case 'Initialize'
        % Move latest constraint values into the constraint softening
        % tables
        Udata(:,[3,5,7,9]) = ULimits(:,3:6);
        Ydata(:,[3,5]) = YLimits(:,3:4);
        Usoft.setCellData(Udata);
        Ysoft.setCellData(Ydata);
    case 'Finalize'
        % Possible update of contstraint values from the constraint
        % softening tables
        ULimits(:,3:6) = Udata(:,[3,5,7,9]);
        YLimits(:,3:4) = Ydata(:,[3,5]);
        Ucon.setCellData(ULimits);
        Ycon.setCellData(YLimits);
end
% -----------------------------------------------------

function MPCrelaxationBands(eventSource, eventData, this, ...
                Usoft, Ysoft, HardnessUDD, vSB, hSB)

% Create the modal dialog that handles the relaxation band input.
% "this" is the calling MPCController node.

% Larry Ricker

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

% Constants
nHor = 700;
nVer = 500;
MyTitleFont = Font('Dialog',Font.PLAIN,12); 

% Panel
Dialog = MJDialog;
Dialog.setModal(1);
Dialog.setSize(Dimension(nHor,nVer));
Dialog.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
Dialog.setTitle('MPC Constraint Softening');
if ~isempty(this.SofteningWindowLocation)
    Dialog.setLocation(this.SofteningWindowLocation);
end

% Panel title
PanelTitle = JLabel('Specify relaxation bands', JLabel.CENTER);
PanelTitle.setFont(Font('Dialog',Font.PLAIN,18));
PanelTitle.setPreferredSize(Dimension(nHor-20,40));
PanelTitle.setVerticalTextPosition(SwingConstants.CENTER);

% Table assembly
ViewportSize = [nHor-50, round(0.25*nVer)];
ResizePolicy = '';
ColumnSizes=50*ones(1,10);
Usoft.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);
ColumnSizes=50*ones(1,6);
Ysoft.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);

c = GridBagConstraints;
c.fill = GridBagConstraints.BOTH;
c.weightx = 1;
c.weighty = 1;
inPanel = MJPanel;
inPanel.setLayout(GridBagLayout);
UTitle = TitledBorder(' Input constraints ');
UTitle.setTitleFont(MyTitleFont);
inPanel.setBorder(UTitle);
inPanel.add(MJScrollPane(Usoft.Table, vSB, hSB), c);

outPanel = MJPanel;
outPanel.setLayout(GridBagLayout);
YTitle = TitledBorder(' Output constraints ');
YTitle.setTitleFont(MyTitleFont);
outPanel.setBorder(YTitle);
outPanel.add(MJScrollPane(Ysoft.Table, vSB, hSB), c);

% Buttons

OK = MJButton('OK');
Cancel = MJButton('Cancel');
Help = MJButton('Help');
butPanel = MJPanel;
butPanel.add(OK);
butPanel.add(Cancel);
butPanel.add(Help);

% Slider
HPanel = HardnessUDD.Panel;
HPanel.MinLabel.setText('Soft constraints');
HPanel.MaxLabel.setText('Hard constraints');
hPanel = MJPanel;
Title7 = TitledBorder(' Overall constraint softness ');
Title7.setTitleFont(MyTitleFont);
hPanel.setBorder(Title7);
hPanel.setLayout(GridBagLayout);
c.fill = GridBagConstraints.HORIZONTAL;
c.weightx = 1;
c.weighty = 0;
hPanel.add(HPanel, c);

% Final panel assembly

p = Dialog.getContentPane;
p.setLayout(GridBagLayout);
c.fill = GridBagConstraints.BOTH;
c.weighty = 0.1;
c.insets = Insets(5, 0, 5, 0);
c.gridx = 0;
c.gridy = 0;
p.add(PanelTitle, c);
c.weighty = 0.35;
c.gridy = 1;
p.add(inPanel, c);
c.gridy = 2;
p.add(outPanel, c);
c.gridy = 3;
c.weighty = 0;
p.add(hPanel, c);
c.gridy = 4;
p.add(butPanel, c);

% Make sure the limits are up-to-date
LocalConstraintUpdate(this, 'Initialize');

% Save the table data so we can restore if the user cancels
UsoftData = Usoft.CellData;
YsoftData = Ysoft.CellData;
Hvalue = HardnessUDD.Value;

% Define callbacks
set(handle(OK, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@SoftButtons, Dialog, 'OK', this});
set(handle(Cancel, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@SoftButtons, Dialog, 'Cancel', ...
    this, Usoft, Ysoft, UsoftData, YsoftData, HardnessUDD, Hvalue});
set(handle(Help, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@mpcCSHelp, 'MPCCONSOFT', Dialog});

% Make it visible
Dialog.setLocation(java.awt.Point(5,5));
awtinvoke(Dialog,'setVisible',true);

% ------------------------------------------------------

function SoftButtons(eventSource, eventData, Dialog, Action, ...
            this, Usoft, Ysoft, UsoftData, YsoftData, Slider, Value)

% Handle callbacks for constraint softening buttons

import javax.swing.*;
import java.awt.*;

% Save window location for next time ...
this.SofteningWindowLocation = Dialog.getLocation;
switch Action
    case 'OK'
        % Close the dialog, accepting all input.
        LocalConstraintUpdate(this, 'Finalize');
        awtinvoke(Dialog,'dispose');
    case 'Cancel'
        % Close the dialog without changing the stored tables
        Usoft.setCellData(UsoftData);
        Ysoft.setCellData(YsoftData);
        Slider.Value = Value;
        awtinvoke(Dialog,'dispose');
end

% ------------------------------------------------------

function StructureDataListener(eventSrc, eventData, this)

% Respond to a user modification to the tabular data on the 
% MPCStructure node.  Only affects the non-editable columns
% in the MPCController tables.  However, these data are used
% in the MPC object, so also signal need for an object update.

this.updateTables = 1;
DataChangeListener(eventSrc, eventData, this);

% ------------------------------------------------------

function EstimChangeListener(eventSrc, eventData, this)

% Respond to modification of any data that would require
% the MPC object to be updated.

this.DefaultEstimator = false;
DataChangeListener(eventSrc, eventData, this)

% ------------------------------------------------------

function DataChangeListener(eventSrc, eventData, this)

% Respond to modification of any data that would require
% the MPC object to be updated.

this.HasUpdated = 1;
this.getRoot.Dirty = true;
this.ExportNeeded = 1;
this.setNewDate;
%this.Status = sprintf('Controller settings for "%s" have been changed', ...
%    this.Label);

% ------------------------------------------------------

function localPanelListener(eventSrc, eventData, this, thisJava)

% Updates the dialog panel in response to changes in the underlying UDD
% object.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

Prop = eventSrc.Name;
Val = get(this,Prop);
switch Prop
    case {'Ts','P','M','BlockMoves','CustomAllocation'}
        % Source is a JTextField
        this.HasUpdated = 1;
        this.getRoot.Dirty = true;
        this.ExportNeeded = 1;
        Str=java.lang.String(Val);
        thisJava.setText(Str);
    case 'Blocking'
        % The checkbox.
        this.HasUpdated = 1;
        this.getRoot.Dirty = true;
        this.ExportNeeded = 1;
        setJavaLogical(thisJava,'setSelected',Val)
        this.setBlockingEnabledState;
    case 'BlockAllocation'
        % The block allocation ComboBox
        this.HasUpdated = 1;
        this.getRoot.Dirty = true;
        this.ExportNeeded = 1;
        thisJava.setSelectedItem(Val);
    otherwise
        errordlg(['Unexpected property code "',Prop,'" in localPanelListener']);
end

% ------------------------------------------------------

function LocalModelSelection(eventSrc, eventData, this)

% Callback when user selects a model in the combo box.
NewModel = this.Handles.ModelCombo.getSelectedItem;
if ~isempty(NewModel)
    this.ModelName = NewModel;
    this.Model = this.getMPCModels.getModel(NewModel);
end

% ------------------------------------------------------

function ModelnHorizonCBs(eventSrc, eventData, this, thisProp, thisJava)

% Handles callbacks for standard java controls.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;


% First verify that the user has actually changed something.
switch thisProp
    case 'Blocking'
        % The checkbox, so it must have changed.  Update
        % the blocking state and return.
        this.setBlockingEnabledState;
        return
    case {'Model', 'BlockAllocation'}
        % Source is a JComboBox
        Item = get(eventSrc,'SelectedItem');
    case {'Ts','P','M','BlockMoves','CustomAllocation'}
        % Source is a JTextField
        Item = get(eventSrc,'Text');
    otherwise
        errordlg(['Unexpected property code "',thisProp,'" in ModelnHorizonCBs']);
        return
end
Prop = get(this,thisProp);
if length(Prop) == length(Item)
    if strcmp(Item,Prop)
        % Old and new are same, so return
        return
    end
end

% Changed, so verify the value supplied.  If OK, update the UDD property.
% If not, reset to previous value.
Valid = true;
isCustom = false;
switch thisProp
    case {'Model', 'BlockAllocation'}
        % These are non-editable combo boxes, so entry must be valid
        set(this,thisProp,Item);
        this.setBlockingEnabledState;
        return
    case 'Ts'
        % Sampling period -- must be greater than zero
        Num = LocalStr2Double(Item);
        if isnan(Num) || Num <= 0
            Valid = TextFieldError(thisJava,'Interval must be positive, finite');
        end
    case {'P','M','BlockMoves'}
        % Must be scalar integer, > 0
        Num = LocalStr2Double(Item);
        if isnan(Num) || Num <= 0 || Num == Inf || ...
                abs(round(Num)-Num) > 10*eps
            Valid = TextFieldError(thisJava,'Horizon must be positive, finite integer');
        end
    otherwise
        % Custom move allocation vector.
        try
            Vector = evalin('base', Item);
        catch
            Vector = NaN;
        end
        if min(size(Vector)) > 1 || any(isnan(Vector)) || ...
                max(abs(round(Vector) - Vector)) > 10*eps
            Valid = TextFieldError(thisJava,['Custom move allocation must',...
                ' be an integer or a row vector of integers']);
        end
end
% For text fields, make sure the dialog and object are identical

if Valid
    % Change was valid, so update the UDD object
    set(this,thisProp,Item);
else
    % Change wasn't valid, so reset the panel to the UDD value
    PropS = java.lang.String(Prop);
    thisJava.setText(PropS);
%     rw = MLthread(thisJava,'setText',{PropS});
%     SwingUtilities.invokeLater(rw);
end

% --------------------------------------------------------------------------- %

function Valid = TextFieldError(thisJava,Message)
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

% -------------------------------------------------------------------------

% Following functions check validity of table input
% -------------------------------------------------------------------------
function OK = LimitsCheckFcn(String, row, col, this)
% Always accept a null string.
if length(String) == 0
    OK = true;
    return
end
% Otherwise, only requirement is a valid scalar
if isnan(LocalStr2Double(String))
    errordlg('Entry was not a scalar number')
    OK = false;
else
    OK = true;
end
% -------------------------------------------------------------------------
function OK = WtsCheckFcn(String, row, col, this)
% Always accept a null string.
if length(String) == 0
    OK = true;
    return
end
% Otherwise, must be non-negative
Number = LocalStr2Double(String);
if isnan(Number) || Number < 0
    %errordlg('Entry was not a non-negative, scalar value')
    OK = false;
else
    OK = true;
end
% -------------------------------------------------------------------------
function OK = UsoftCheckFcn(String, row, col, this)
if any(col == [4 6 8 10])
    OK = WtsCheckFcn(String, row, col, this);
else
    OK = LimitsCheckFcn(String, row, col, this);
end
% -------------------------------------------------------------------------
function OK = YsoftCheckFcn(String, row, col, this)
if any(col == [4 6])
    OK = WtsCheckFcn(String, row, col, this);
else
    OK = LimitsCheckFcn(String, row, col, this);
end
% -------------------------------------------------------------------------
function OK = NoiseCheckFcn(String, row, col, this)
% Always accept a null string.
if length(String) == 0
    OK = true;
    return
end
% Column 4 should evaluate to a 
% non-negative scalar.
if col ~= 4
    OK = true;
else
    OK = WtsCheckFcn(String, row, col, this);
end
% -------------------------------------------------------------------------
function OK = NoiseCheckFcnOD(String, row, col, this)
% Special version for output disturbance table
OK = NoiseCheckFcn(String, row, col, this);
if OK && col == 3
    % Check to verify that user hasn't put a non-white disturbance on
    % an unmeasured output
    S=this{1}.getRoot;
    if any(row == S.iUO)
        % This output is unmeasured.
        if ~strcmp(String, 'White')
            errordlg('Disturbance to unmeasured output must be white.');
            OK = false;
        end
    end
end
% -------------------------------------------------------------------------
function Value = LocalStr2Double(String)
try
    Value = evalin('base', String);
    if ~isreal(Value) || length(Value) > 1
        Value = NaN;
    end
catch
    Value = NaN;
end

% --------------------------------------------------------

function addChangeListeners(this)

% Attach listeners that catch any change to the data that
% would require an MPC object update.  This includes most 
% of this node's properties, as well as the associated UDD
% objects.


h = this.Handles;

% Properties of the node:

% NOTE:  localPanelListener catches the following:
% Ts, P, M, Blocking, BlockMoves, BlockAllocation, CustomAllocation.
% Thus, we only need to listen for changes in the following:

this.addListeners(handle.listener(this, this.findprop('Model'), ...
    'PropertyPostSet',{@DataChangeListener, this}));

% Associated UDD objects:

this.addListeners(handle.listener(h.ULimits, h.ULimits.findprop('CellData'), ...
    'PropertyPostSet',{@DataChangeListener, this}));
this.addListeners(handle.listener(h.YLimits, h.YLimits.findprop('CellData'), ...
    'PropertyPostSet',{@DataChangeListener, this}));
this.addListeners(handle.listener(h.Uwts, h.Uwts.findprop('CellData'), ...
    'PropertyPostSet',{@DataChangeListener, this}));
this.addListeners(handle.listener(h.Ywts, h.Ywts.findprop('CellData'), ...
    'PropertyPostSet',{@DataChangeListener, this}));
this.addListeners(handle.listener(h.Usoft, h.Usoft.findprop('CellData'), ...
    'PropertyPostSet',{@DataChangeListener, this}));
this.addListeners(handle.listener(h.Ysoft, h.Ysoft.findprop('CellData'), ...
    'PropertyPostSet',{@DataChangeListener, this}));
this.addListeners(handle.listener(h.eHandles(1).UDD, ...
    h.eHandles(1).UDD.findprop('CellData'), ...
    'PropertyPostSet',{@EstimChangeListener, this}));
this.addListeners(handle.listener(h.eHandles(2).UDD, ...
    h.eHandles(2).UDD.findprop('CellData'), ...
    'PropertyPostSet',{@EstimChangeListener, this}));
this.addListeners(handle.listener(h.eHandles(3).UDD, ...
    h.eHandles(3).UDD.findprop('CellData'), ...
    'PropertyPostSet',{@EstimChangeListener, this}));
this.addListeners(handle.listener(h.GainUDD, ...
    h.GainUDD.findprop('Value'), ...
    'PropertyPostSet',{@EstimChangeListener, this}));
this.addListeners(handle.listener(h.TrackingUDD, h.TrackingUDD.findprop('Value'), ...
    'PropertyPostSet',{@DataChangeListener, this}));
this.addListeners(handle.listener(h.HardnessUDD, h.HardnessUDD.findprop('Value'), ...
    'PropertyPostSet',{@DataChangeListener, this}));
this.addListeners(handle.listener(this, this.findprop('ModelName'), ...
    'PropertyPostSet',{@DataChangeListener, this}));

% -----------------------------------------------------------

function LocalLabelListenerPreSet(varargin)

% Node is going to be renamed.  Save the current name.

global MPC_OLD_NAME

this = varargin{end};
MPC_OLD_NAME = this.Label;

% -----------------------------------------------------------

function LocalLabelListenerPostSet(varargin)

% Complete the rename process started in the PreSet listener

global MPC_OLD_NAME

this = varargin{end};  % Points to the controller node being renamed
% Update the list of controller names maintained by the MPCControllers node
ControllerList = this.up.Controllers;
NewName = this.Label;
ControllerCount = length(ControllerList);
for i = 1:ControllerCount
    if strcmp(MPC_OLD_NAME,ControllerList{i})
        ControllerList{i} = NewName;
        break
    end
end
this.up.Controllers = ControllerList;
Scenarios = this.getMPCSims.getChildren;
if ~isempty(Scenarios)
    Scenarios = Scenarios.find('ControllerName', MPC_OLD_NAME);
    for i = 1:length(Scenarios)
        Scenarios(i).ControllerName = NewName;
    end
    MPC_OLD_NAME = [];
end
% --------------------------------------------------------------------

function LocalUpdateStatus(Root, Message)

if isa(Root, 'mpcnodes.MPCGUI')
    if isempty(Message) || ~ischar(Message)
        Root.Frame.clearStatus;
    else
        Root.Frame.postStatus(Message);
    end
end


