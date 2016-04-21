function ConfigureAnalysisResultsPanel(this,DialogPanel)
%  ConfigureAnalysisResultsPanel  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:35:26 $

this.AnalysisResultsPanelUDD = DialogPanel.AnalysisResultsPanel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Delete Result Button
%% Set the action callback for the delete button and store its
%% handle
AnalysisResultsDeleteButtonUDD = this.AnalysisResultsPanelUDD.getDeleteButton;
set(AnalysisResultsDeleteButtonUDD,'ActionPerformedCallback',{@LocalDeleteResultCallback,this})
this.AnalysisResultsDeleteButtonUDD = AnalysisResultsDeleteButtonUDD;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Table Model and Table
%% Get and store the handle to the table model
AnalysisResultsTableModelUDD = this.AnalysisResultsPanelUDD.getTableModel;
%% Set the callback for the AnalysisResultsTableModel
set(AnalysisResultsTableModelUDD,'TableChangedCallback',{@LocalAnalysisResultsTableModelCallback,this})
this.AnalysisResultsTableModelUDD = AnalysisResultsTableModelUDD;

AnalysisResultsTableUDD = this.AnalysisResultsPanelUDD.getTable;
%% Add a listener to the mouse clicked callback
set(AnalysisResultsTableUDD, 'MouseClickedCallback', {@LocalResultTableClicked, this});
this.AnalysisResultsTableUDD = AnalysisResultsTableUDD;

%% Add a listener to the operating condition table node
this.LinearizationResultsListeners = [...
        handle.listener(this,'ObjectChildAdded',{@LocalUpdateLinearizationResultsAdded,this});...
        handle.listener(this,'ObjectChildRemoved',{@LocalUpdateLinearizationResultsRemoved,this});...
        handle.listener(this,'AnalysisLabelChanged',{@LocalUpdateLinearizationResultLabel, this})];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateLinearizationResultLabel - Update the linearization table
function LocalUpdateLinearizationResultLabel(es,ed,this)

import java.lang.*; 

%% Set the table data get it from the linearization results
AnalysisResultsTableModelUDD = this.AnalysisResultsTableModelUDD;

%% Disable the TableChangedCallback
TableChanged = get(AnalysisResultsTableModelUDD,'TableChangedCallback');
set(AnalysisResultsTableModelUDD,'TableChangedCallback',[]);

%% Recreate the table
Children = this.getChildren;

%% Loop over all the elements to remove the not of the class
%% GenericLinearizationNodes.LinearAnalysisResultNode
Children = LocalFindAnalysisResultsChildren(Children);

if ~isempty(Children)
    AnalysisResultsTableModelUDD.data = LocalCreateAnalysisResultTable(Children);
    this.AnalysisResultsPanelUDD.UpdateTable;
end

%% Restore the TableChangedCallback
set(AnalysisResultsTableModelUDD,'TableChangedCallback',TableChanged);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalAnalysisResultsTableModelCallback
function LocalAnalysisResultsTableModelCallback(es,ed,this)

%% Get the view children
ch = this.getChildren;

%% Get the row and colum information
row = ed.getFirstRow+1;
col = ed.getColumn+1;

switch col
    case 1
        ch(row).Label = this.AnalysisResultsTableModelUDD.data(row,col);
        eventData = ctrluis.dataevent(this,'AnalysisLabelChanged',row);
        send(this, 'AnalysisLabelChanged',eventData);
    case 2
        ch(row).Description = this.AnalysisResultsTableModelUDD.data(row,col);    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalResultTableClicked - Callback the clicking of the table
function LocalResultTableClicked(es,ed,this)

rows = this.AnalysisResultsTableUDD.getSelectedRows + 1;

if (ed.getClickCount == 2)
    Children = LocalFindAnalysisResultsChildren(this.getChildren);
    if (length(Children) > 0) && (length(rows) == 1)
        %% Get the frame and workspace handles
        [FRAME,WSHANDLE] = slctrlexplorer;   
        %% Expand by default to show the default operating condition
        FRAME.setSelected(Children(rows).getTreeNodeInterface);        
    end    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDeleteResultCallback - Callback for the delete button to 
%% delete the selected linearization.
function LocalDeleteResultCallback(es,ed,this)

rows = this.AnalysisResultsTableUDD.getSelectedRows;
%% Call the delete result method on each node in a backwards fashion to
%% deal with the new indexing
Children = this.getChildren;
for ct = length(rows):-1:1
    this.removeNode(Children(double(rows(ct))+1));
end

%% Set the project dirty flag
this.setDirty

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateLinearizationResultsAdded - Update the linearization results
function LocalUpdateLinearizationResultsAdded(es,ed,this)

import java.lang.*; 

%% Set the table data get it from the linearization results
AnalysisResultsTableModelUDD = this.AnalysisResultsTableModelUDD;

%% Recreate the table
Children = this.getChildren;

%% Loop over all the elements to remove the not of the class
%% GenericLinearizationNodes.LinearAnalysisResultNode
Children = LocalFindAnalysisResultsChildren(Children);

AnalysisResultsTableModelUDD.data = LocalCreateAnalysisResultTable(Children);
this.AnalysisResultsPanelUDD.UpdateTable;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateLinearizationResultsRemoved - Update the linearization results
function LocalUpdateLinearizationResultsRemoved(es,ed,this)

import java.lang.*; 

%% Set the table data get it from the linearization results
AnalysisResultsTableModelUDD = this.AnalysisResultsTableModelUDD;

%% Get the chilren that were deleted
ChildrenDeleted = ed.Child;
%% Recreate the table
Children = this.getChildren;

%% Remove the children from the list for the table
for ct = 1:length(ChildrenDeleted)
    Children(find(ChildrenDeleted(ct) == Children)) = [];
end

%% Loop over all the elements to remove the not of the class
%% GenericLinearizationNodes.LinearAnalysisResultNode
Children = LocalFindAnalysisResultsChildren(Children);

if ~isempty(Children)
    AnalysisResultsTableModelUDD.data = LocalCreateAnalysisResultTable(Children);
    this.AnalysisResultsPanelUDD.UpdateTable;
else
    AnalysisResultsTableModelUDD.clearRows;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalCreateAnalysisResultTable - Update the linearization results table
function table_data = LocalCreateAnalysisResultTable(Children)

import java.lang.*; 

table_data = javaArray('java.lang.Object',length(Children),2);
for ct = 1:length(Children)
    table_data(ct,1) = String(Children(ct).Label);
    table_data(ct,2) = String(Children(ct).Description);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalFindAnalysisResultsChildren
function Children = LocalFindAnalysisResultsChildren(Children);

%% Loop over all the elements to remove the not of the class
%% GenericLinearizationNodes.LinearAnalysisResultNode
for ct = length(Children):-1:1
    if ~isa(Children(ct),'GenericLinearizationNodes.LinearAnalysisResultNode')
        Children(ct) = [];    
    end
end
