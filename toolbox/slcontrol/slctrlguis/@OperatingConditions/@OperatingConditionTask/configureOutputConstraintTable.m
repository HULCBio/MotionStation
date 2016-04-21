function configureOutputConstraintTable(this,DialogPanel)
%  configureOutputConstraintTable  Construct the output constraint table panel

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:36:47 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Output Constraint Table
%% Set the action callback for the output constraint table model and store its
%% handle
OutputConstrTableModelUDD = this.OpCondSpecPanelUDD.getOutputConstrTableModel;
set(OutputConstrTableModelUDD,'TableChangedCallback',{@LocalUpdateSetOutputConstrTableData,this})
this.OutputConstrTableModelUDD = OutputConstrTableModelUDD;

%% Set the callback for when the user double clicks to inspect a block
h = handle(this.OpCondSpecPanelUDD.getOutputConstrTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalTableClick this};

%% Get the table data for the input constraint table data
if isempty(this.OutputSpecTableData)
    table_data = this.getOutputConstrTableData;
    %% Store the initial table data
    this.OutputSpecTableData = table_data(1);
    %% Store the input indecies
    this.OutputIndecies = table_data(2);
end

%% Create the cell attributes
cellAtt = CreateCellAttrib(this.OutputIndecies, size(this.OutputSpecTableData,1), 5);
OutputConstrTableModelUDD.cellAtt = cellAtt;
OutputConstrTableModelUDD.data = this.OutputSpecTableData;

%% Store the output indecies
this.OutputIndecies = this.OutputIndecies;

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.OutputConstrTableModelUDD);
OutputConstrTableModelUDD.fireTableChanged(evt);

%% Set the action callback for the output constraint table fixed column
%% header.
OutputConstrTableFixedCheckBoxUDD = this.OpCondSpecPanelUDD.getOutputFixedColumnCheckBox;
set(OutputConstrTableFixedCheckBoxUDD,'ActionPerformedCallback',{@LocalUpdateSetOutputConstrTableFixedCheckBox,this})
this.OutputConstrTableFixedCheckBoxUDD = OutputConstrTableFixedCheckBoxUDD;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalTableClick - Callback for when a user clicks on a table
function LocalTableClick(es,ed,this)

if ed.getClickCount == 2
    %% es is the table
    row = es.getSelectedRow;
    %% Get the valid rows to click on
    blocks = cell(this.OutputIndecies);
    %% Determine if a block was selected
    ind = find([blocks{:}] == row);
    
    if ~isempty(ind)
        block = this.OutputSpecTableData(blocks{ind}+1,1);
        try
            hilite_system(block,'find');pause(0.5);hilite_system(block,'none')
        catch
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetOutputConstrTableData - Callback for updating the information
%% from the output constraint table
function LocalUpdateSetOutputConstrTableData(es,ed,this)

%% Get the row and column indecies
row = ed.getFirstRow;
col = ed.getColumn;

%% Call the linearize model method only if the row > 0
if (row > 0)
    OutputIndecies = this.OutputIndecies;

    this.setOutputConstrTableData(this.OutputConstrTableModelUDD.data,OutputIndecies,row,col);
    %% Uncheck the Fixed column if one of the rows in the fixed column has
    %% been checked.
    if (col == 2 && row ~= 0)
        this.OpCondSpecPanelUDD.setOutputFixedColumnCheckBoxSelected(false)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetOutputConstrTableFixedCheckBox - Callback for updating the information
%% from the output constraint table fixed column checkbox
function LocalUpdateSetOutputConstrTableFixedCheckBox(es,ed,this)

outputs = this.OpSpecData.outputs;
data = this.OutputConstrTableModelUDD.data;
%% Get the value of the checkbox
if (this.OutputConstrTableFixedCheckBoxUDD.isSelected)
    %% Update the operating condition constraint object
    for ct = 1:length(outputs)
        outputs(ct).Known = ones(outputs(ct).PortWidth,1);
    end
    %% Update the Java table model.  This is the 3rd column.
    for ct = 1:size(data,1)
        data(ct,3) = java.lang.Boolean(1);
    end
else
    %% Update the operatation condition constraint object
    for ct = 1:length(outputs)
        outputs(ct).Known = zeros(outputs(ct).PortWidth,1);
    end    
    %% Update the Java table model.  This is the 3rd column.
    for ct = 1:size(data,1)
        data(ct,3) = java.lang.Boolean(0);
    end
end

%% Fire the Table Update evwnt
nrows = size(this.OutputConstrTableModelUDD.data,1);
evt = javax.swing.event.TableModelEvent(this.OutputConstrTableModelUDD,0,nrows-1,2);
this.OutputConstrTableModelUDD.fireTableChanged(evt)   
