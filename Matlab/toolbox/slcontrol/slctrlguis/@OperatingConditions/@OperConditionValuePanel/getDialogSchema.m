function DialogPanel = getDialogSchema(this, manager)
%%  GETDIALOGSCHEMA  Construct the dialog panel

%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.7 $  $Date: 2004/04/11 00:36:34 $

import com.mathworks.toolbox.slcontrol.GenericSimulinkSettingsObjects.*;

%% Add the settings pane to the frame
DialogPanel = OperatingConditionsValuePanel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% State Condition Table
%% Set the action callback for the state condition table model and store its
%% handle
StateCondTableModelUDD = DialogPanel.getStateCondTableModel;
this.StateCondTableModelUDD = StateCondTableModelUDD;

%% Set the callback for when the user double clicks to inspect a block
h = handle(DialogPanel.getStateCondTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalStateTableClick this};

%% Get the initial state table data
if isempty(this.StateTableData)
    table_data = this.getStateTableData;
    this.StateTableData = table_data(1);
    this.StateIndecies = table_data(2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input Condition Table
%% Set the action callback for the input condition table model and store its
%% handle
InputCondTableModelUDD = DialogPanel.getInputCondTableModel;
this.InputCondTableModelUDD = InputCondTableModelUDD;

%% Set the callback for when the user double clicks to inspect a block
h = handle(DialogPanel.getInputCondTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalInputTableClick this};

%% Get the initial input table data
if isempty(this.InputTableData)
    table_data = this.getInputTableData;
    this.InputTableData = table_data(1);
    this.InputIndecies = table_data(2);
end

%% Update the tables with fresh data
this.updateTables;

%% Set the table changed callbacks
h = handle(StateCondTableModelUDD, 'callbackproperties');
h.TableChangedCallback = {@LocalsetStateTableData,this};
h = handle(InputCondTableModelUDD, 'callbackproperties');
h.TableChangedCallback = {@LocalsetInputTableData,this};

%% Make the frame visible
DialogPanel.setVisible(1);

%% Configure the import initial value for operating spec button
h = handle(DialogPanel.getSyncButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalSyncOpSpec this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalsetStateTableData - Callback for when a user changes a table
function LocalsetStateTableData(es,ed,this)

%% Get the row and column indecies
row = ed.getFirstRow;
col = ed.getColumn;
setStateTableData(this,row,col);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalsetInputTableData - Callback for when a user changes a table
function LocalsetInputTableData(es,ed,this)

%% Get the row and column indecies
row = ed.getFirstRow;
col = ed.getColumn;
setInputTableData(this,row,col);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalStateTableClick - Callback for when a user clicks on a table
function LocalStateTableClick(es,ed,this)

if ed.getClickCount == 2
    %% es is the table
    row = es.getSelectedRow;
    %% Get the valid rows to click on
    blocks = cell(this.StateIndecies);
    %% Determine if a block was selected
    ind = find([blocks{:}] == row);

    if ~isempty(ind)
        block = this.StateCondTableModelUDD.data(blocks{ind}+1,1);
        try
            hilite_system(block,'find');pause(0.5);hilite_system(block,'none')
        catch
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalInputTableClick - Callback for when a user clicks on a table
function LocalInputTableClick(es,ed,this)

if ed.getClickCount == 2
    %% es is the table
    row = es.getSelectedRow;
    %% Get the valid rows to click on
    blocks = cell(this.InputIndecies);
    %% Determine if a block was selected
    ind = find([blocks{:}] == row);

    if ~isempty(ind)
        block = this.InputCondTableModelUDD.data(blocks{ind}+1,1);
        try
            hilite_system(block,'find');pause(0.5);hilite_system(block,'none')
        catch
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSyncOpSpec
function LocalSyncOpSpec(es,ed,this)

%% Update the operating point data    
try
    this.OpPoint.update;
catch
    lastmsg = lasterr; 
    str = sprintf(['The operating point could not be could '...
        'not be synchronized with the model %s due to the following error:\n\n',...
        '%s'],this.Model,lastmsg);
    errordlg(str,'Operating Points Synchronization Error')
end

table_data = this.getInputTableData;
this.InputTableData = table_data(1);
this.InputIndecies = table_data(2);

table_data = this.getStateTableData;
this.StateTableData = table_data(1);
this.StateIndecies = table_data(2);

%% Update the tables
this.updateTables;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetStateCondTableData - Callback for updating the information
%% from the state condition table
function LocalUpdateSetStateCondTableData(es,ed,this)

StateIndecies = this.StateIndecies;
row = ed.getFirstRow;
col = ed.getColumn;
this.setStateTableData(this.StateCondTableModelUDD.data,StateIndecies,row,col);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetInputCondTableData - Callback for updating the information
%% from the input condition table
function LocalUpdateSetInputCondTableData(es,ed,this)

InputIndecies = this.InputIndecies;
row = ed.getFirstRow;
col = ed.getColumn;
this.setInputTableData(this.InputCondTableModelUDD.data,InputIndecies,row,col);

%%----------------------------------------------------------------------
%% CreateCellAttrib(indecies, nrows, ncols) - Creates cell attributes for 
%% the results tables
function cellAtt = CreateCellAttrib(indecies, nrows, ncols)

import com.mathworks.toolbox.slcontrol.AdvTableObjects.*;

%% Create the new color and font objects for the cell attributes;
color = java.awt.Color(int16(255),int16(238),int16(204));
font = java.awt.Font('',1,12);

%% Create the cell attributes
col_combine = 0:ncols-1;
cellAtt = DefaultCellAttribute(nrows,ncols);
%% Combine rows and columns
for ct = 1:size(indecies,1);
    row_combine = indecies(ct,1).intValue;
    cellAtt.combine(row_combine,col_combine);
    cellAtt.setBackground(color,row_combine,col_combine);
    cellAtt.setFont(font,row_combine,col_combine);
end
