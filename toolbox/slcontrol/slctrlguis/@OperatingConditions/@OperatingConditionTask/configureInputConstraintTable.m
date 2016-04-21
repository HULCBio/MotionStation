function configureInputConstraintTable(this,OpCondSpecPanelUDD)
%  configureInputConstraintTable  Construct the input constraint table panel

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:36:46 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input Constraint Table
%% Set the action callback for the input constraint table model and store its
%% handle
InputConstrTableModelUDD = this.OpCondSpecPanelUDD.getInputConstrTableModel;
set(InputConstrTableModelUDD,'TableChangedCallback',{@LocalUpdateSetInputConstrTableData,this})
this.InputConstrTableModelUDD = InputConstrTableModelUDD;

%% Set the callback for when the user double clicks to inspect a block
h = handle(this.OpCondSpecPanelUDD.getInputConstrTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalTableClick this};

%% Get the table data for the input constraint table data
if isempty(this.InputSpecTableData)
    table_data = this.getInputConstrTableData;
    %% Store the initial table data
    this.InputSpecTableData = table_data(1);
    %% Store the input indecies
    this.InputIndecies = table_data(2);
end

%% Create the cell attributes
cellAtt = CreateCellAttrib(this.InputIndecies, size(this.InputSpecTableData,1), 5);
InputConstrTableModelUDD.cellAtt = cellAtt;
InputConstrTableModelUDD.data = this.InputSpecTableData;

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.InputConstrTableModelUDD);
InputConstrTableModelUDD.fireTableChanged(evt);

%% Set the action callback for the input constraint table fixed column
%% header.
InputConstrTableFixedCheckBoxUDD = this.OpCondSpecPanelUDD.getInputFixedColumnCheckBox;
set(InputConstrTableFixedCheckBoxUDD,'ActionPerformedCallback',{@LocalUpdateSetInputConstrTableFixedCheckBox,this})
this.InputConstrTableFixedCheckBoxUDD = InputConstrTableFixedCheckBoxUDD;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalTableClick - Callback for when a user clicks on a table
function LocalTableClick(es,ed,this)

if ed.getClickCount == 2
    %% es is the table
    row = es.getSelectedRow;
    %% Get the valid rows to click on
    blocks = cell(this.InputIndecies);
    %% Determine if a block was selected
    ind = find([blocks{:}] == row);

    if ~isempty(ind)
        block = this.InputSpecTableData(blocks{ind}+1,1);
        try
            hilite_system(block,'find');pause(0.5);hilite_system(block,'none')
        catch
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetInputConstrTableData - Callback for updating the information
%% from the input constraint table
function LocalUpdateSetInputConstrTableData(es,ed,this)

%% Get the row and column indecies
row = ed.getFirstRow;
col = ed.getColumn;

%% Call the linearize model method only if the row > 0
if (row > 0)
    InputIndecies = this.InputIndecies;

    this.setInputConstrTableData(this.InputConstrTableModelUDD.data,InputIndecies,row,col);
    %% Uncheck the Fixed column if one of the rows in the fixed column has been
    %% checked.
    if (col == 2 && row ~= 0)
        this.OpCondSpecPanelUDD.setInputFixedColumnCheckBoxSelected(false)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetInputConstrTableFixedCheckBox - Callback for updating the information
%% from the input constraint table fixed column checkbox
function LocalUpdateSetInputConstrTableFixedCheckBox(es,ed,this)

inputs = this.OpSpecData.inputs;
data = this.InputConstrTableModelUDD.data;
%% Get the value of the checkbox
if (this.InputConstrTableFixedCheckBoxUDD.isSelected)
    %% Update the operating condition constraint object
    for ct = 1:length(inputs)
        inputs(ct).Known = ones(inputs(ct).PortWidth,1);
    end
    %% Update the Java table model.  This is the 3rd column.
    for ct = 1:size(data,1)
        data(ct,3) = java.lang.Boolean(1);
    end
else
    %% Update the operatation condition constraint object
    for ct = 1:length(inputs)
        inputs(ct).Known = zeros(inputs(ct).PortWidth,1);
    end    
    %% Update the Java table model.  This is the 3rd column.
    for ct = 1:size(data,1)
        data(ct,3) = java.lang.Boolean(0);
    end
end

%% Fire the Table Update evwnt
nrows = size(this.InputConstrTableModelUDD.data,1);
evt = javax.swing.event.TableModelEvent(this.InputConstrTableModelUDD,0,nrows-1,2);
this.InputConstrTableModelUDD.fireTableChanged(evt)
