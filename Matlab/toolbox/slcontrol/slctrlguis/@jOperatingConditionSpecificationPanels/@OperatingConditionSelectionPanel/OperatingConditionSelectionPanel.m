function this = OperatingConditionSelectionPanel(DialogPanel,OpCondNode)
%%  OperatingConditionSelectionPanel Constructor for @OperatingConditionSelectionPanel class
%%
%%  Author(s): John Glass
%%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:37:20 $

%% Create class instance
this = jOperatingConditionSpecificationPanels.OperatingConditionSelectionPanel;
%% Store the operating conditions node
this.OpCondNode = OpCondNode;
%% Store the java panel handle
this.JavaPanel = DialogPanel;

%% Configure the panel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Operating Condition Selection Table
%% Get the handle to the operating condition selection table
OpCondTableModelUDD = DialogPanel.getOpCondTableModel;
this.OpCondTableModelUDD = OpCondTableModelUDD;

%% Set the table data get it from the operating conditions below
LocalUpdateAvailableOperatingConditionsAdded(OpCondNode,[],this)

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.OpCondTableModelUDD);
awtinvoke(this.OpCondTableModelUDD,'fireTableChanged',evt);

%% Add a listener to the operating condition table node
this.OperatingConditionsListeners = [...
        handle.listener(OpCondNode,'ObjectChildAdded',{@LocalUpdateAvailableOperatingConditionsAdded, this});...
        handle.listener(OpCondNode,'ObjectChildRemoved',{@LocalUpdateAvailableOperatingConditionsDeleted, this});...
        handle.listener(OpCondNode,'OpPointDataChanged',{@LocalUpdateData, this});...
        ];

%% Set the callback for the AnalysisResultsTableModel
set(OpCondTableModelUDD,'TableChangedCallback',{@LocalOpCondTableModelCallback,this})
this.OpCondTableModelUDD = OpCondTableModelUDD;

%% Set the first row to be selected
awtinvoke(DialogPanel.OpCondTable,'setRowSelectionInterval',0,0)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LocalUpdateData(OpCondNode,ed,this)

%% Get the handle to the operating conditions node children
Children = this.OpCondNode.getChildren;

%% Disable the table data callback
oldcallback = get(this.OpCondTableModelUDD,'TableChangedCallback');
set(this.OpCondTableModelUDD,'TableChangedCallback',[]);

%% Set the table data get it from the operating conditions below
OpCondTableModelUDD = this.OpCondTableModelUDD;
OpCondTableModelUDD.data = LocalCreateOperatingConditionsTable(Children);
this.OpCondTableModelUDD = OpCondTableModelUDD;

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.OpCondTableModelUDD);
OpCondTableModelUDD.fireTableChanged(evt);

%% Re-enable table data callback
set(this.OpCondTableModelUDD,'TableChangedCallback',oldcallback);

%% Set the first row to be selected
awtinvoke(this.JavaPanel.OpCondTable,'setRowSelectionInterval',0,0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalOpCondTableModelCallback
function LocalOpCondTableModelCallback(es,ed,this)

%% Get the view children
if isa(this.OpCondNode,'OperatingConditions.OperatingConditionTask')
    ch = this.OpCondNode.getChildren;

    %% Get the row and colum information
    row = ed.getFirstRow+1;
    col = ed.getColumn+1;

    switch col
        case 1
            ch(row).Label = this.OpCondTableModelUDD.data(row,col);
        case 2
            ch(row).Description = this.OpCondTableModelUDD.data(row,col);            
    end
    send(this.OpCondNode, 'OpPointDataChanged');
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

%% Set the first row to be selected
% DialogPanel.OpCondTable.setRowSelectionInterval(0,0)

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

%% Set the first row to be selected
% DialogPanel.OpCondTable.setRowSelectionInterval(0,0)

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
    table_data(1,1) = String('No operating point available');
    table_data(1,2) = String('');
end
