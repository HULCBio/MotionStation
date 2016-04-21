function this = opcondimport(task,validprojects)
% Builds the dialog

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:37:17 $

import java.awt.*;
import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.page.utils.VertFlowLayout;
import javax.swing.table.*;
import javax.swing.border.*;

%% Construct the object
this = jDialogs.OpcondImport;

%% Store the task handle
this.Task = task;

%% Get the operating spec object
opspec = task.OpSpecData;
nStates = 0;
for ct = 1:length(opspec.States)
    nStates = nStates + opspec.States(ct).Nx;
end
this.NxDesired = nStates;

%% Dialog Container
Frame = MJDialog;
Frame.setModal(1);
Frame.setTitle('Operating Point Import');
set(Frame, 'Resizable', 'off');

MainPanel = MJPanel(BorderLayout(0,5));
MainPanel.setBorder(EmptyBorder(10,10,5,10));
Frame.getContentPane.add(MainPanel);

%% Top Panel
Panel2 = MJPanel(BorderLayout);
Label1 = MJLabel('Import from:');

%% Create button group, 
%% This allows only one radio buttonin the group selected at a time
RadioBtnGroup = ButtonGroup;

%% Put all radiobutton panels together
SubPanel2b=MJPanel(VertFlowLayout(VertFlowLayout.LEFT));
SubPanel2b.setBorder(EmptyBorder(0,15,0,0));

%% Project Panel
if ~isempty(validprojects)
    this.Projects = validprojects;
    RadioButton1 = MJRadioButton('Select from project:');
    h = handle(RadioButton1, 'callbackproperties');
    h.ActionPerformedCallback = {@LocalGetProjectVars this};
    RadioBtnGroup.add(RadioButton1);
    ProjectCombo = MJComboBox(get(validprojects,{'Label'}));
    this.Handles.ProjectCombo = ProjectCombo;
    h = handle(ProjectCombo, 'callbackproperties');
    h.ItemStateChangedCallback = {@LocalGetProjectVars this};
    ProjectPanel = MJPanel;
    ProjectPanel.add(RadioButton1);
    ProjectPanel.add(ProjectCombo);
    SubPanel2b.add(ProjectPanel);
end

%% Workspace Panel
RadioButton2 = MJRadioButton('Workspace');
h = handle(RadioButton2, 'callbackproperties');
h.ActionPerformedCallback = {@LocalGetWorkspaceVars this};
RadioBtnGroup.add(RadioButton2);
WSPanel = MJPanel;
WSPanel.add(RadioButton2);
SubPanel2b.add(WSPanel);

%% File Panel
RadioButton3 = MJRadioButton('MAT-file: ');
h = handle(RadioButton3, 'callbackproperties');
h.ActionPerformedCallback = {@LocalGetMatFileVars this};
RadioBtnGroup.add(RadioButton3);
FileEdit = MJTextField(15);
FileEdit.setName('FileName');
set(FileEdit, 'ActionPerformedCallback', {@LocalSetFileName this})

% Browse button
BrowseButton = this.browsebutton;
FilePanel = MJPanel(FlowLayout(FlowLayout.LEFT));
FilePanel.add(RadioButton3);
FilePanel.add(FileEdit);
FilePanel.add(BrowseButton);
SubPanel2b.add(FilePanel);

SubPanel2 = MJPanel(FlowLayout(FlowLayout.LEFT));
SubPanel2.add(SubPanel2b);

Panel2.add(Label1,BorderLayout.NORTH);
Panel2.add(SubPanel2,BorderLayout.CENTER);

%% Initialize the table columns
tc = javaArray('java.lang.Object',3);
tc(1) = java.lang.String('Available Data');
tc(2) = java.lang.String('Type');
tc(3) = java.lang.String('Size');
this.TableColumnNames = tc;

%% Create the table panel
TblPanel = this.tablepanel;
%% Create the button panel
BtnPanel = this.buttonpanel;

%% Panel
panel = MJPanel(BorderLayout(0,10));
panel.add(Panel2,BorderLayout.CENTER);
panel.add(TblPanel,BorderLayout.SOUTH);

MainPanel.add(panel,BorderLayout.CENTER);
MainPanel.add(BtnPanel, BorderLayout.SOUTH);

%% Store the handles for later use
this.Frame = Frame;
this.Handles.FileEdit = FileEdit;
this.Handles.BrowseButton = BrowseButton;

%% Set default state of radiobuttons to workspace(RadioButton1)
if ~isempty(validprojects)
    RadioButton1.doClick;
else
    RadioButton2.doClick;
end

%% ------------------------------------------------------------------------%
%% Function: LocalGetWorkSpaceVars
%% Purpose:  Generates the variable list from workspace 
%% ------------------------------------------------------------------------%
function LocalGetWorkspaceVars(hSrc, event, this)

awtinvoke(this.Handles.FileEdit,'setEnabled',false);
awtinvoke(this.Handles.BrowseButton,'setEnabled',false);
if ~isempty(this.Projects)
    awtinvoke(this.Handles.ProjectCombo,'setEnabled',false);
end

Vars = evalin('base','whos');
[VarNames, DataModels] = getmodels(this,Vars,'base');
this.updatetable(VarNames,DataModels);

%% ------------------------------------------------------------------------%
%% Function: LocalGetProjectVars
%% Purpose:  Generates the variable list from workspace 
%% ------------------------------------------------------------------------%
function LocalGetProjectVars(hSrc, event, this)

awtinvoke(this.Handles.FileEdit,'setEnabled',false);
awtinvoke(this.Handles.BrowseButton,'setEnabled',false);
if ~isempty(this.Projects)
    awtinvoke(this.Handles.ProjectCombo,'setEnabled',true);
end

ind = this.Handles.ProjectCombo.getSelectedIndex + 1;
project = this.Projects(ind);
validconditions = project.OperatingConditions.getChildren;

VarNames = get(validconditions,{'Label'});
DataModels = get(validconditions,{'OpPoint'});
this.updatetable(VarNames,DataModels);

%% ------------------------------------------------------------------------%
%% Function: LocalSetFileName
%% Purpose:  Updates Filename
%% ------------------------------------------------------------------------%
function LocalSetFileName(hsrc,event,this)

this.FileName=get(hsrc,'Text');
this.getmatfilevars;

%% ------------------------------------------------------------------------%
%% Function: LocalGetMatFileVars
%% Purpose:  Updates 
%% ------------------------------------------------------------------------
function LocalGetMatFileVars(hsrc,event,this)

awtinvoke(this.Handles.FileEdit,'setEnabled',true);
awtinvoke(this.Handles.BrowseButton,'setEnabled',true);
if ~isempty(this.Projects)
    awtinvoke(this.Handles.ProjectCombo,'setEnabled',false);
end

this.getmatfilevars
