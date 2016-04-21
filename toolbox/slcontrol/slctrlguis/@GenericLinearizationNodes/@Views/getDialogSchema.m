function DialogPanel = getDialogSchema(this, manager)
%%  getDialogSchema  Construct the dialog panel

%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.

import com.mathworks.toolbox.slcontrol.GenericLinearizationObjects.*;

DialogPanel = AllViewsPanel;

%% Get and configure the table for the available views
ViewTableUDD = DialogPanel.getViewTable;
this.ViewTableUDD = ViewTableUDD;
ViewTableModelUDD = DialogPanel.getViewTableModel;
%% Get the data if it exists, otherwise store the initial state
if isempty(this.ViewTableData)
    this.ViewTableData = ViewTableModelUDD.data;
else
    ViewTableModelUDD.data = this.ViewTableData;
end

%% Set the callback for the ViewTableModel
set(ViewTableModelUDD,'TableChangedCallback',{@LocalViewTableModelCallback,this})
this.ViewTableModelUDD = ViewTableModelUDD;

%% Update the list
LocalUpdateAvailableViewsAdded([],[],this);

%% Get and configure the new button for the new view callback
NewViewButtonUDD = DialogPanel.getNewViewButton;
set(NewViewButtonUDD,'ActionPerformedCallback',{@LocalNewViewCallback,this})
this.NewViewButtonUDD = NewViewButtonUDD;

%% Get and configure the new button for the new view callback
DeleteViewButtonUDD = DialogPanel.getDeleteViewButton;
set(DeleteViewButtonUDD,'ActionPerformedCallback',{@LocalDeleteViewCallback,this})
this.DeleteViewButtonUDD = DeleteViewButtonUDD;

%% Add a listener to the children below
this.ChildListListeners = [...
        handle.listener(this,'ObjectChildAdded',{@LocalUpdateAvailableViewsAdded, this});...
        handle.listener(this,'ObjectChildRemoved',{@LocalUpdateAvailableViewsDeleted, this})];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalPlotSetupTableModelCallback
function LocalViewTableModelCallback(es,ed,this)

%% Get the view children
ch = this.getChildren;

%% Get the row and colum information
row = ed.getFirstRow+1;
col = ed.getColumn+1;

if (col == 2)
    ch(row).Description = this.ViewTableModelUDD.data(row,col);  
    this.ViewTableData(row,col) = java.lang.String(this.ViewTableModelUDD.data(row,col));
end

%% Set the project dirty flag
this.setDirty;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateAvailableViewsAdded - Update the ViewTable 
%%
function LocalUpdateAvailableViewsAdded(es,ed,this)

%% Get the handle to the view children
Children = this.getChildren;

%% Set the table data get it from the views
LocalUpdateTableData(Children,this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateAvailableViewsDeleted
function LocalUpdateAvailableViewsDeleted(es,ed,this)

%% Get the handle to the operating conditions node children
Children = this.getChildren;

%% Get the chilren that were deleted
ChildrenDeleted = ed.Child;

%% Remove the children from the list for the table
for ct = 1:length(ChildrenDeleted)
    Children(find(ChildrenDeleted(ct) == Children)) = [];
end

%% Set the table data get it from the views
LocalUpdateTableData(Children,this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateTableData - Create a object array for the talbe
%% 
function LocalUpdateTableData(Children,this);

import java.lang.*; 

if length(Children) > 0
    table_data = javaArray('java.lang.Object',length(Children),2);
    for ct = 1:length(Children)
        table_data(ct,1) = String(Children(ct).Label);
        table_data(ct,2) = String(Children(ct).Description);
    end
    this.ViewTableModelUDD.data = table_data;
    this.ViewTableData = table_data;
else
    this.ViewTableModelUDD.clearRows    
    this.ViewTableData = this.ViewTableModelUDD.data;
end

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.ViewTableModelUDD);
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(this.ViewTableModelUDD, 'fireTableChanged',...
                {evt}, 'javax.swing.event.TableModelEvent');
javax.swing.SwingUtilities.invokeLater(thr);

%% Set the project dirty flag
this.setDirty;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalNewViewCallback - Create a new view
%% 
function LocalNewViewCallback(es,ed,this)

%% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

%% Clear the status area
ExplorerFrame.clearText;

%% Create the view settings node
ViewSettingsNode = GenericLinearizationNodes.ViewSettings(length(this.getChildren)+1);
ViewSettingsNode.Label = ViewSettingsNode.createDefaultName('View', this);

%% Add the view settings node to the tree
this.addNode(ViewSettingsNode);
%% Expand the views nodes so the user sees the new result
ExplorerFrame.expandNode(this.getTreeNodeInterface);

ExplorerFrame.postText(sprintf(' - A new view has been added.'))

%% Set the project dirty flag
this.setDirty;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDeleteViewCallback - Delete the selected views
%% 
function LocalDeleteViewCallback(es,ed,this)

rows = this.ViewTableUDD.getSelectedRows;
%% Call the delete view node method on each node in a backwards fashion to
%% deal with the new indexing
Children = this.getChildren;
for ct = length(rows):-1:1
    this.removeNode(Children(double(rows(ct))+1));
end

%% Set the project dirty flag
this.setDirty;
