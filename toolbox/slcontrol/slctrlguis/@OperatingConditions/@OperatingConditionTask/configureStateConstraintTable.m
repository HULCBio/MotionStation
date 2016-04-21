function configureStateConstraintTable(this,DialogPanel)
%  configureStateConstraintTable  Construct the output constraint table panel

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:36:48 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% State Constraint Table
%% Set the action callback for the state constraint table model and store its
%% handle
StateConstrTableModelUDD = this.OpCondSpecPanelUDD.getStateConstrTableModel;
set(StateConstrTableModelUDD,'TableChangedCallback',{@LocalUpdateSetStateConstrTableData,this})
this.StateConstrTableModelUDD = StateConstrTableModelUDD;

%% Set the callback for when the user double clicks to inspect a block
h = handle(this.OpCondSpecPanelUDD.getStateConstrTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalTableClick this};

%% Get the table data for the input constraint table data
if isempty(this.StateSpecTableData)
    table_data = this.getStateConstrTableData;
    %% Store the initial table data
    this.StateSpecTableData = table_data(1);
    %% Store the input indecies
    this.StateIndecies = table_data(2);
end

%% Create the cell attributes
cellAtt = CreateCellAttrib(this.StateIndecies, size(this.StateSpecTableData,1), 6);
StateConstrTableModelUDD.cellAtt = cellAtt;
StateConstrTableModelUDD.data = this.StateSpecTableData;

%% Store the state indecies
this.StateIndecies = this.StateIndecies;

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.StateConstrTableModelUDD);
StateConstrTableModelUDD.fireTableChanged(evt);

%% Set the action callback for the state constraint table fixed column
%% header.
StateConstrTableFixedCheckBoxUDD = this.OpCondSpecPanelUDD.getStateFixedColumnCheckBox;
set(StateConstrTableFixedCheckBoxUDD,'ActionPerformedCallback',{@LocalUpdateSetStateConstrTableFixedCheckBox,this})
this.StateConstrTableFixedCheckBoxUDD = StateConstrTableFixedCheckBoxUDD;

%% Set the action callback for the output constraint table steady state
%% column header.
StateConstrTableSteadyStateCheckBoxUDD = this.OpCondSpecPanelUDD.getStateSteadyStateColumnCheckBox;
set(StateConstrTableSteadyStateCheckBoxUDD,'ActionPerformedCallback',{@LocalUpdateSetStateConstrTableSteadyStateCheckBox,this})
this.StateConstrTableSteadyStateCheckBoxUDD = StateConstrTableSteadyStateCheckBoxUDD;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalTableClick - Callback for when a user clicks on a table
function LocalTableClick(es,ed,this)

if ed.getClickCount == 2
    %% es is the table
    row = es.getSelectedRow;
    %% Get the valid rows to click on
    blocks = cell(this.StateIndecies);
    %% Determine if a block was selected
    ind = find([blocks{:}] == row);

    if ~isempty(ind)
        block = this.StateSpecTableData(blocks{ind}+1,1);
        try
            hilite_system(block,'find');pause(0.5);hilite_system(block,'none')
        catch
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetStateConstrTableData - Callback for updating the information
%% from the state constraint table
function LocalUpdateSetStateConstrTableData(es,ed,this)

%% Get the row and column indecies
row = ed.getFirstRow;
col = ed.getColumn;

%% Call the linearize model method only if the row > 0
if (row > 0)
    StateIndecies = this.StateIndecies;

    this.setStateConstrTableData(this.StateConstrTableModelUDD.data,StateIndecies,row,col);
    %% Uncheck the Fixed column if one of the rows in the fixed column has
    %% been checked.  Do the same for the steady state column.
    if (col == 2 && row ~= 0)
        this.OpCondSpecPanelUDD.setStateFixedColumnCheckBoxSelected(false)
    elseif (col == 3 && row ~= 0)
        this.OpCondSpecPanelUDD.setStateSteadyStateColumnCheckBoxSelected(false)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetStateConstrTableFixedCheckBox - Callback for updating the information
%% from the state constraint table fixed column checkbox
function LocalUpdateSetStateConstrTableFixedCheckBox(es,ed,this)

states = this.OpSpecData.states;
data = this.StateConstrTableModelUDD.data;
%% Get the value of the checkbox
if (this.StateConstrTableFixedCheckBoxUDD.isSelected)
    %% Update the operating condition constraint object
    for ct = 1:length(states)
        states(ct).Known = ones(states(ct).Nx,1);
    end
    %% Update the Java table model.  This is the 3rd column.
    for ct = 1:size(data,1)
        data(ct,3) = java.lang.Boolean(1);
    end
else
    %% Update the operatation condition constraint object
    for ct = 1:length(states)
        states(ct).Known = zeros(states(ct).Nx,1);
    end    
    %% Update the Java table model.  This is the 3rd column.
    for ct = 1:size(data,1)
        data(ct,3) = java.lang.Boolean(0);
    end
end

%% Fire the Table Update evwnt
nrows = size(this.StateConstrTableModelUDD.data,1);
evt = javax.swing.event.TableModelEvent(this.StateConstrTableModelUDD,0,nrows-1,2);
this.StateConstrTableModelUDD.fireTableChanged(evt) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetStateConstrTableSteadyStateCheckBox - Callback for updating the information
%% from the state constraint table fixed column checkbox
function LocalUpdateSetStateConstrTableSteadyStateCheckBox(es,ed,this)

states = this.OpSpecData.states;
data = this.StateConstrTableModelUDD.data;
%% Get the value of the checkbox
if (this.StateConstrTableSteadyStateCheckBoxUDD.isSelected)
    %% Update the operating condition constraint object
    for ct = 1:length(states)
        states(ct).SteadyState = ones(states(ct).Nx,1);
    end
    %% Update the Java table model.  This is the 4th column.
    for ct = 1:size(data,1)
        data(ct,4) = java.lang.Boolean(1);
    end
else
    %% Update the operatation condition constraint object
    for ct = 1:length(states)
        states(ct).SteadyState = zeros(states(ct).Nx,1);
    end    
    %% Update the Java table model.  This is the 4th column.
    for ct = 1:size(data,1)
        data(ct,4) = java.lang.Boolean(0);
    end
end

%% Fire the Table Update evwnt
nrows = size(this.StateConstrTableModelUDD.data,1);
evt = javax.swing.event.TableModelEvent(this.StateConstrTableModelUDD,0,nrows-1,3);
this.StateConstrTableModelUDD.fireTableChanged(evt) 
