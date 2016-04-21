function DialogPanel = getDialogSchema(this,manager)

%  Construct the MPCControllers dialog panel view 

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.9 $ $Date: 2004/04/10 23:36:00 $

import javax.swing.*;
import java.awt.*;

% Make sure at least one controller node has a panel
C = this.getChildren;
if isempty(C) 
    error('MPCControllers:  No controller nodes defined.')
    return
end
if isempty(C(1).Dialog)
    C(1).getDialogInterface(this.up.TreeManager);
end

S = this.up;
mpcCursor(S.Frame, 'wait');
if isempty(this.Dialog)
    % Create a new panel
	DialogPanel = LocalDialogPanel(this);
else
    % Use existing panel
    DialogPanel = this.Dialog;
end
% Make sure controller list is current
this.RefreshControllerList;
LocalRefreshModelList(this);
mpcCursor(S.Frame, 'default');

% --------------------------------------------------------------------------- %
function DialogPanel = LocalDialogPanel(this)

% Generate the MPCControllers panel

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

% Create the list table
javaClass = logical(ones(1,5));
Header = {'Name','Plant Model',htmlText('Control<BR>Interval'), ...
        htmlText('Prediction<BR>Horizon'),'Last Update'};
Data = {'','','','',''};
Editable = [true true true true false];
t=mpcobjects.TableObject(Header,Editable,javaClass,Data, ...
    @LocalTableCheckFcn, this);
t.Table = MPCTable(t, Header, Editable', Data', javaClass);
ModelCombo = MJComboBox;
ModelCombo.setEditable(0);

UTitle = ' Controllers defined in this project ';
LTitle = ' Controller details ';
NTitle = ' Additional notes ';
SummaryText = MJTextArea;
SummaryText.setEditable(false);
Label = MJLabel;
SummaryText.setBackground(Label.getBackground);
LContent = MJScrollPane(SummaryText);
LContent.setViewportBorder(BorderFactory.createLoweredBevelBorder);

Width = 500;
Labels = {'Import ...', 'Export ...', 'New', 'Copy', 'Display', ...
    'Delete', 'Help'};
[DialogPanel, Buttons, NotesArea] = ComponentListPanel( Width, ...
    UTitle, LTitle, NTitle, t, Labels, Labels, LContent);

ViewportSize=[Width, 100];
ColumnSizes=[100, 100, 60, 60, 140];
ResizePolicy = '';
t.sizeTable(ViewportSize,ColumnSizes,ResizePolicy);

% Callbacks
set(handle(Buttons.Import,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalImportButtonCB, this});
set(handle(Buttons.Export,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalExportButtonCB, this});
set(handle(Buttons.New,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalAddButtonCB, this});
set(handle(Buttons.Copy,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalCopyButtonCB, this});
set(handle(Buttons.Display,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalDisplayButtonCB, this});
set(handle(Buttons.Delete,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalDeleteButtonCB, this});
set(handle(Buttons.Help,'callbackproperties'),'ActionPerformedCallback',...
    {@mpcCSHelp, 'MPCCONTROLLERS'});
set(NotesArea,'FocusLostCallback',{@LocalNotesCB, this});

% This listens for a controller to be selected.
this.addListeners(handle.listener(t, t.findprop('selectedRow'), ...
    'PropertyPostSet', {@LocalControllerSummaryCB, this}));

% This listens for a change in the list of controllers.
this.addListeners(handle.listener(this, this.findprop('Controllers'), ...
    'PropertyPostSet', {@LocalControllerListChanged, this}));

% Save the handles
Handles.Buttons = Buttons;
Handles.UDDtable = t;
Handles.SummaryText = SummaryText;
Handles.TextArea = LContent;
Handles.NotesArea = NotesArea;
Handles.ModelCombo = ModelCombo;

Handles.PopupMenuItems = [];

this.Handles = Handles;

Col2 = t.Table.getColumnModel.getColumn(1);
Col2.setCellEditor(DefaultCellEditor(ModelCombo));

% --------------------------------------------------------------

function LocalControllerSummaryCB(eventSrc, eventData, this)
this.RefreshControllerSummary;

% --------------------------------------------------------------

function LocalControllerListChanged(eventSrc, eventData, this)
this.getRoot.send('ControllerListUpdated', eventData)

% --------------------------------------------------------------

function OK = LocalTableCheckFcn(String, row, col, Args)

% Check validity of user update in table.  "this" is the
% MPCControllers node.

OK = true;
this = Args{1};
Controllers = this.getChildren;
Node = Controllers(row);
ControllerName = Node.Label;
if col == 1
    % User is renaming the controller.  Check for another with
    % same name.  Also make sure name was actually changed.
    if ~strcmp(ControllerName, String) && length(deblank(String)) > 0
        OK = Node.renameController(ControllerName, String);
    else
        OK = false;
    end
elseif col == 2
    % Changing model name.  Make sure it actually changed.
    if strcmp(Node.ModelName, String)
        OK = false;
    else
        OK = true;
        Node.ModelName = String;
        Node.Model = Node.getMPCModels.getModel(String);
    end
elseif col == 3
    % Changing control interval
    % Must be positive, finite
    Value = LocalStr2Double(String);
    if isnan(Value) || Value <= 0 || Value == Inf
        waitfor(errordlg('Interval must be positive and finite.', ...
            'MPC Error','modal'));
        OK = false;
    else
        % Make sure it really changed
        if abs(Value - str2double(Node.Ts)) < 1000*eps
            OK = false;
        else
            OK = true;
            Node.Ts = String;
        end
    end
elseif col == 4
    % Changing prediction horizon
    % Must be positive, finite, integer
    Num = LocalStr2Double(String);
    if ~isnan(Num) && Num > 0 && Num < Inf && abs(Num - round(Num)) < eps
        if str2double(Node.P) ~= Num
            Node.P = String;
        else
            OK = false;
        end
    else
        waitfor(errordlg('Horizon must be a positive, finite integer.', ...
            'MPC Error','modal'));
        OK = false;
    end
else
    error(sprintf('Unexpected table column "%i"', col));
end
if OK
    Node.HasUpdated = 1;
    Node.setNewDate;
    RefreshControllerSummary(this);
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
Controller = UDDtable.CellData{row,1};
MPCControllerNode = this.getChildren.find('Label',Controller);
if ~isempty(MPCControllerNode)
    MPCControllerNode.Notes = char(this.Handles.NotesArea.getText);
    MPCControllerNode.HasUpdated = 1;
end

% --------------------------------------------------------------------------- %

function LocalImportButtonCB(eventSrc, eventData, this)

% React to user push of Import button on MPCControllers panel.
I = this.up.Handles.ImportMPC;
I.javasend('Show', 'dummy', I);

% --------------------------------------------------------------------------- %

function LocalExportButtonCB(eventSrc, eventData, this)

% React to user push of Export button on MPCControllers panel.
this.up.Handles.mpcExporter.show;

% --------------------------------------------------------------------------- %

function LocalDisplayButtonCB(eventSrc, eventData, this)

% React to user push of Display button on MPCControllers panel.
this.getController;
this.RefreshControllerSummary;

% --------------------------------------------------------------------------- %

function LocalCopyButtonCB(eventSrc, eventData, this)

% React to user push of Copy button on MPCControllers panel.
% Locate the node to be copied
UDDtable = this.Handles.UDDtable;
Controller = UDDtable.CellData{UDDtable.selectedRow,1};
this.copyController(Controller);

% --------------------------------------------------------------------------- %

function LocalAddButtonCB(eventSrc, eventData, this)

% React to user push of New button on MPCControllers panel.
this.addController;

% --------------------------------------------------------------

function LocalDeleteButtonCB(eventSrc, eventData, this)

UDDtable = this.Handles.UDDtable;
row = UDDtable.selectedRow;
Controller = UDDtable.CellData{row,1};
this.deleteController(Controller);

% --------------------------------------------------------------------------- %

function LocalRefreshModelList(this)

import com.mathworks.mwswing.*;
import javax.swing.*;

ModelCombo = this.Handles.ModelCombo;
mpc_combo_updater(ModelCombo, this.up.getMPCModels.Labels);
