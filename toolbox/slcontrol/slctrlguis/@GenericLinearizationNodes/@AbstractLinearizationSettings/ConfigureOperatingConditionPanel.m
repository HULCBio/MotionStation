function ConfigureOperatingConditionPanel(this,DialogPanel)
%%  ConfigureOperatingConditionPanel  Configure the operating conditions
%%  selection panel

%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2003 The MathWorks, Inc.

%% Get the operating condition node
OpCondNode = this.getOpCondNode;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Operating Condition Selection Table
%% Get the handle to the operating condition selection table
this.OpCondTableModelUDD = DialogPanel.getOpCondTableModel;

%% Set the table data get it from the operating conditions below
LocalUpdateAvailableOperatingConditionsAdded(OpCondNode,[],this)

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.OpCondTableModelUDD);
this.OpCondTableModelUDD.fireTableChanged(evt);
%% Set the first row to be selected
DialogPanel.OpCondPanel.OpCondTable.setRowSelectionInterval(0,0)

%% Add a listener to the operating condition table node
this.OperatingConditionsListeners = [...
        handle.listener(OpCondNode,'ObjectChildAdded',{@LocalUpdateAvailableOperatingConditionsAdded, this});...
        handle.listener(OpCondNode,'ObjectChildRemoved',{@LocalUpdateAvailableOperatingConditionsDeleted, this})];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDeleteOpCondCallback - Callback to delete an operating condition.
function LocalDeleteOpCondCallback(es,ed,this,OpCondNode)

%% Get the children of the operating conditions
Children = OpCondNode.getChildren;

%% Get the selected indecies
rows = this.Dialog.OpCondPanel.OpCondTable.getSelectedRows+1;

%% Delete the appropriate nodes
if (rows == 0)
    errordlg('Please select an operating point to delete.','Simulink Control Design')
elseif (any(find(rows == 1)))
    errordlg('The Default Operating Point node cannot be deleted.','Simulink Control Design')
else
    for ct = 1:length(rows)
        OpCondNode.removeNode(Children(double(rows(ct))));    
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateAvailableOperatingConditionsAdded - Update the available operating
%% conditions table
function LocalUpdateAvailableOperatingConditionsAdded(OpCondNode,ed,this)

%% Get the handle to the operating conditions node children
Children = OpCondNode.getChildren;

%% Set the table data get it from the operating conditions below
OpCondTableModelUDD = this.OpCondTableModelUDD;
OpCondTableModelUDD.data = LocalCreateOperatingConditionsTable(Children);
this.OpCondTableModelUDD = OpCondTableModelUDD;

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.OpCondTableModelUDD);
OpCondTableModelUDD.fireTableChanged(evt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateAvailableOperatingConditionsDeleted - Update the available operating
%% conditions table
function LocalUpdateAvailableOperatingConditionsDeleted(OpCondNode,ed,this)

%% Get the handle to the operating conditions node children
Children = OpCondNode.getChildren;

%% Get the chilren that were deleted
ChildrenDeleted = ed.Child;

%% Remove the children from the list for the table
for ct = 1:length(ChildrenDeleted)
    Children(find(ChildrenDeleted(ct) == Children)) = [];
end

%% Set the table data get it from the operating conditions below
OpCondTableModelUDD = this.OpCondTableModelUDD;
OpCondTableModelUDD.data = LocalCreateOperatingConditionsTable(Children);
this.OpCondTableModelUDD = OpCondTableModelUDD;

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.OpCondTableModelUDD);
OpCondTableModelUDD.fireTableChanged(evt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalCreateOperatingConditionsTable - Create a table containing a list
%% of the available operating conditions
function table_data = LocalCreateOperatingConditionsTable(Children)

import java.lang.*; 

if ~isempty(Children)
    table_data = javaArray('java.lang.Object',length(Children),2);
    for ct = 1:length(Children)
        table_data(ct,1) = String(Children(ct).Label);
        table_data(ct,2) = String(Children(ct).Description);
    end
else
    table_data = javaArray('java.lang.Object',1,2);
    table_data(1,1) = String('No operating points available');
    table_data(1,2) = String('');
end