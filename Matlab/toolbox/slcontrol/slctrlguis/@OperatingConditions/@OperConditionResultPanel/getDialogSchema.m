function DialogPanel = getDialogSchema(this, manager)
%%  GETDIALOGSCHEMA  Construct the dialog panel

%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.

import com.mathworks.toolbox.slcontrol.GenericSimulinkSettingsObjects.*;

%% Add the settings pane to the frame
DialogPanel = OperatingConditionResultsPanel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the table model for the input results table
InputResultsTableModelUDD = DialogPanel.getInputResultsTableModel;
this.InputResultsTableModelUDD = InputResultsTableModelUDD;

%% Set the callback for when the user double clicks to inspect a block
h = handle(DialogPanel.getInputResultsTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalInputTableClick this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Output Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the table model for the output results table
OutputResultsTableModelUDD = DialogPanel.getOutputResultsTableModel;
this.OutputResultsTableModelUDD = OutputResultsTableModelUDD;

%% Set the callback for when the user double clicks to inspect a block
h = handle(DialogPanel.getOutputResultsTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalOutputTableClick this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% State Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the table model for the state results table
StateResultsTableModelUDD = DialogPanel.getStateResultsTableModel;
this.StateResultsTableModelUDD = StateResultsTableModelUDD;

%% Set the callback for when the user double clicks to inspect a block
h = handle(DialogPanel.getStateResultsTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalStateTableClick this};

%% Update the tables with fresh data
LocalUpdateTables(this)

%% Make the frame visible
DialogPanel.setVisible(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        block = this.StateResultsTableModelUDD.data(blocks{ind}+1,1);
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
        block = this.InputResultsTableModelUDD.data(blocks{ind}+1,1);
        try
            hilite_system(block,'find');pause(0.5);hilite_system(block,'none')
        catch
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalOutputTableClick - Callback for when a user clicks on a table
function LocalOutputTableClick(es,ed,this)

if ed.getClickCount == 2
    %% es is the table
    row = es.getSelectedRow;
    %% Get the valid rows to click on
    blocks = cell(this.OutputIndecies);
    %% Determine if a block was selected
    ind = find([blocks{:}] == row);

    if ~isempty(ind)
        block = this.OutputResultsTableModelUDD.data(blocks{ind}+1,1);
        try
            hilite_system(block,'find');pause(0.5);hilite_system(block,'none')
        catch
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end


%% LOCALUPDATETABLES - Function to update the results tables with the new
%% data.
function LocalUpdateTables(this)

%%%%%% INPUT TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the table data for the input results table
table_data = this.getInputResultsTableData;

%% Create the cell attributes
cellAtt = CreateCellAttrib(table_data(2), size(table_data(1),1), 3);
this.InputResultsTableModelUDD.cellAtt = cellAtt;
this.InputResultsTableModelUDD.data = table_data(1);
this.InputIndecies = table_data(2);

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.InputResultsTableModelUDD);
this.InputResultsTableModelUDD.fireTableChanged(evt);

%%%%%% OUTPUT TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the table data for the output results table
table_data = this.getOutputResultsTableData;

%% Create the cell attributes
cellAtt = CreateCellAttrib(table_data(2), size(table_data(1),1), 3);
this.OutputResultsTableModelUDD.cellAtt = cellAtt;
this.OutputResultsTableModelUDD.data = table_data(1);
this.OutputIndecies = table_data(2);

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.OutputResultsTableModelUDD);
this.OutputResultsTableModelUDD.fireTableChanged(evt);

%%%%%% STATE TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the table data for the state results table
table_data = this.getStateResultsTableData;

%% Create the cell attributes
cellAtt = CreateCellAttrib(table_data(2), size(table_data(1),1), 5);
this.StateResultsTableModelUDD.cellAtt = cellAtt;
this.StateResultsTableModelUDD.data = table_data(1);
this.StateIndecies = table_data(2);

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.StateResultsTableModelUDD);
this.StateResultsTableModelUDD.fireTableChanged(evt);
