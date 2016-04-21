function DialogPanel = getDialogSchema(this,manager)

% DialogPanel = getDialogSchema(this,manager)
%
%  Construct the MPCSims dialog panel

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.9 $ $Date: 2004/04/10 23:36:59 $

import javax.swing.*;
import java.awt.*;

h = this.Handles;

% Make sure at least one scenario node has a panel
S = this.getChildren;
if isempty(S) 
    error('MPCSims:  No scenario nodes defined.')
    return
end
if isempty(S(1).Dialog)
    S(1).getDialogInterface(this.up.TreeManager);
end

S = this.up;
mpcCursor(S.Frame, 'wait');
if isempty(this.Dialog)
    % Create a new panel
	DialogPanel = LocalDialogPanel(this);
else
    % Use existing panel
    %disp('Using existing MPCSims panel');
    DialogPanel = this.Dialog;
end
% Make sure scenario list is current
this.RefreshSimList;
LocalRefreshControllerList(this);
LocalRefreshPlantList(this);
mpcCursor(S.Frame, 'default');
if isfield(S.Handles,'SimulateMenu')  % Might not be created yet
    setJavaLogical(S.Handles.SimulateMenu.getAction,'setEnabled',1);
end

% --------------------------------------------------------------------------- %
function DialogPanel = LocalDialogPanel(this)

% Generate the MPCControllers panel

import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

% Create the list table
javaClass = logical([1 1 1 0 0 1]);
Header = {'Name','Controller','Plant','Closed Loop','Constrained','Duration'};
Data = {'','','', java.lang.Boolean(true), java.lang.Boolean(true), ''};
Enabled = [ true true true true true true ];
t=mpcobjects.TableObject(Header,Enabled,javaClass,Data, ...
    @LocalTableCheckFcn, this);
t.Table = com.mathworks.toolbox.mpc.MPCTable(t, Header, Enabled', ...
    Data', javaClass);

UTitle = ' Simulation scenarios defined in this project ';
LTitle = ' Scenario details ';
NTitle = ' Additional notes ';
SummaryText = MJLabel;
LContent = MJScrollPane(SummaryText);
LContent.setViewportBorder(BorderFactory.createLoweredBevelBorder);

Width = 500;
Labels = {'New', 'Copy', 'Delete', 'Help'};
[DialogPanel, Buttons, NotesArea] = ComponentListPanel( Width, ...
    UTitle, LTitle, NTitle, t, Labels, Labels, LContent);

ViewportSize=[Width, 100];
ColumnSizes=[80, 80, 60, 60, 60, 60];
ResizePolicy = '';
t.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);

MPCCombo = MJComboBox;
MPCCombo.setEditable(0);
PlantCombo = MJComboBox;
PlantCombo.setEditable(0);

% Callbacks
set(handle(Buttons.New, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@LocalAddButtonCB, this});
set(handle(Buttons.Copy, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@LocalCopyButtonCB, this});
set(handle(Buttons.Delete, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@LocalDeleteButtonCB, this});
set(handle(Buttons.Help, 'callbackproperties'), 'ActionPerformedCallback', ...
    {@mpcCSHelp, 'MPCSIMSMAIN'});
set(NotesArea,'FocusLostCallback',{@LocalNotesCB, this});

% This listens for a scenario to be selected.
this.addListeners(handle.listener(t, t.findprop('selectedRow'), ...
    'PropertyPostSet', {@LocalRefreshSimCB, this}));

% Save the handles
Handles.Buttons = Buttons;
Handles.UDDtable = t;
Handles.SummaryText = SummaryText;
Handles.TextArea = LContent;
Handles.NotesArea = NotesArea;
Handles.MPCCombo = MPCCombo;
Handles.PlantCombo = PlantCombo;

Handles.PopupMenuItems = [];

this.Handles = Handles;

% --------------------------------------------------------------

function LocalRefreshSimCB(eventSrc, eventData, this)
this.RefreshSimList;

% --------------------------------------------------------------

function OK = LocalTableCheckFcn(String, row, col, Args)

% Check validity of user update in table.  "this" is the
% MPCSims node.


OK = true;
this = Args{1};
Scenarios = this.getChildren;
Node = Scenarios(row);
ScenarioName = Node.Label;

if col == 1
    % User is renaming the scenario.  Check for another with
    % same name
    if length(deblank(String)) > 0
        OK = Node.renameScenario(ScenarioName, String);
    else
        OK = false;
    end
elseif col == 2
    % Changing controller name.
    Node.ControllerName = String;
elseif col == 3
    % Changing plant name.
    Node.PlantName = String;
elseif col == 4
    % Changing loop status
    Node.ClosedLoop = String;
elseif col == 5
    % Changing constraint status
    Node.ConstraintsEnforced = String;
elseif col == 6
    % Changing duration.  Must be positive, finite
    Num = LocalStr2Double(String);
    if ~isnan(Num) && Num > 0 && Num < Inf
        Node.Tend = String;
    else
        waitfor(errordlg('Duration must be positive, finite.', ...
            'MPC Error','modal'));
        OK = false;
    end
else
    error(sprintf('Unexpected table column "%i"', col));
end
if OK
    Node.HasUpdated = 1;
    Node.setNewDate;
    this.RefreshSimSummary;
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

% --------------------------------------------------------------

function LocalNotesCB(eventSrc, eventData, this)

UDDtable = this.Handles.UDDtable;
row = UDDtable.selectedRow;
Item = UDDtable.CellData{row,1};
MPCSimNode = this.getChildren.find('Label', Item);
if ~isempty(MPCSimNode)
    MPCSimNode.Notes = char(this.Handles.NotesArea.getText);
end

% --------------------------------------------------------------------------- %

function LocalCopyButtonCB(eventSrc, eventData, this)

% React to user push of Copy button on MPCSims panel.

%disp('In CopyButton')
% Locate the node to be copied
UDDtable = this.Handles.UDDtable;
Sim = UDDtable.CellData{UDDtable.selectedRow,1};
this.copyScenario(Sim);

% --------------------------------------------------------------------------- %

function LocalAddButtonCB(eventSrc, eventData, this)

% React to user push of New button on MPCSims panel.
this.addScenario;

% --------------------------------------------------------------

function LocalDeleteButtonCB(eventSrc, eventData, this)

UDDtable = this.Handles.UDDtable;
row = UDDtable.selectedRow;
Item = UDDtable.CellData{row,1};
this.deleteScenario(Item);

% ------------------------------------------------------------------------

function LocalRefreshControllerList(this)

import com.mathworks.mwswing.*;
import javax.swing.*;

MPCCombo = this.Handles.MPCCombo;
mpc_combo_updater(MPCCombo, this.up.getMPCControllers.Controllers);
t=this.Handles.UDDtable;
Col2 = t.Table.getColumnModel.getColumn(1);
Col2.setCellEditor(DefaultCellEditor(MPCCombo));


% ------------------------------------------------------------------------

function LocalRefreshPlantList(this)

import com.mathworks.mwswing.*;
import javax.swing.*;

PlantCombo = this.Handles.PlantCombo;
mpc_combo_updater(PlantCombo, this.up.getMPCModels.Labels);
t=this.Handles.UDDtable;
Col3 = t.Table.getColumnModel.getColumn(2);
Col3.setCellEditor(DefaultCellEditor(PlantCombo));
