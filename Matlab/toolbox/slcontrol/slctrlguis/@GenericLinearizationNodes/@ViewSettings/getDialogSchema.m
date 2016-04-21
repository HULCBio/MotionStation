function DialogPanel = getDialogSchema(this, manager)
%%  getDialogSchema  Construct the dialog panel

%%  Author(s): John Glass
%%  Revised:
%% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2004/04/11 00:36:02 $

import com.mathworks.toolbox.slcontrol.LinearizationViewConfiguration.*;

%% Create the panel
DialogPanel = MainConfigurationInterface;

%% Set the callback for the FigureSetupTableModel
PlotSetupTableModelUDD = DialogPanel.getPlotSetupTableModel;

%% Get the data if it exists, otherwise store the initial state
if isempty(this.PlotSetupTableData)
    this.PlotSetupTableData = PlotSetupTableModelUDD.data;
else
    PlotSetupTableModelUDD.data = this.PlotSetupTableData;
end
set(PlotSetupTableModelUDD,'TableChangedCallback',{@LocalPlotSetupTableModelCallback,this})
this.PlotSetupTableModelUDD = PlotSetupTableModelUDD;

%% Get the handle to the FigureSetupTable
this.PlotSetupTableUDD = DialogPanel.getPlotSetupTable;

%% Set the callback for the VisibleResultTableModel
VisibleResultTableModelUDD = DialogPanel.getVisibleResultTableModel;

%% Get the data if it exists, otherwise store the initial state
if isempty(this.VisibleResultTableData)
    this.VisibleResultTableData = VisibleResultTableModelUDD.data;
else
    VisibleResultTableModelUDD.data = this.VisibleResultTableData;
end
set(VisibleResultTableModelUDD,'TableChangedCallback',{@LocalVisibleResultTableModelCallback,this})
this.VisibleResultTableModelUDD = VisibleResultTableModelUDD;

%% Get the handle to the VisibleResultTable
this.VisibleResultTableUDD = DialogPanel.getVisibleResultTable;

%% Set the callback for the UpdateViewButton
UpdateViewButtonUDD = DialogPanel.getUpdateViewButton;
set(UpdateViewButtonUDD, 'ActionPerformedCallback', {@LocalUpdateViewButtonCallback,this});
this.UpdateViewButtonUDD = UpdateViewButtonUDD;

%% Get the handle to the auto add checkbox
this.AutoAddCheckboxUDD = DialogPanel.getAutoAddCheckBox;

%% Add listener to the analysis results above
ResultsNode = this.up.up;
this.LinearizationResultsListeners = [...
    handle.listener(ResultsNode,'ObjectChildAdded',{@LocalUpdateLinearizationResultsAdded,this});...
    handle.listener(ResultsNode,'ObjectChildRemoved',{@LocalUpdateLinearizationResultsDeleted,this});...
    handle.listener(ResultsNode,'AnalysisLabelChanged',{@LocalUpdateLinearizationResultLabel, this})];

%% Initialize the table
if length(ResultsNode.getChildren) > 0
    LocalUpdateLinearizationResultsAdded(ResultsNode,[],this);
end

%% Get the visible system table column handles to be hidden
ColumnModel = this.VisibleResultTableUDD.getColumnModel;
TableColumns = this.VisibleTableColumns;
for ct = 6:-1:1
    TableColumns{ct,1} = ColumnModel.getColumn(ct);
    if strcmpi(this.PlotConfigurations(ct,2),'None')
        TableColumns{ct,2} = false;
        ColumnModel.removeColumn(TableColumns{ct,1});
    else
        TableColumns{ct,2} = true;
    end    
end
this.VisibleTableColumns = TableColumns;

%% Create a listener to delete the ltiplot
createDeleteListener(this)

%% Create the right click menus
this.getPopupInterface(manager);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions 
%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateLinearizationResultLabel
function LocalUpdateLinearizationResultLabel(ResultNode,ed,this)

%% Get the children of the analysis results
ch = ResultNode.getChildren;
%% Get the element that has been updated
row = ed.Data;
%% Update the table data.  This is always the first column.
this.VisibleResultTableModelUDD.setValueAt(java.lang.String(ch(row).Label),row-1,0);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalPlotSetupTableModelCallback
function LocalPlotSetupTableModelCallback(es,ed,this)

%% Call the set plot configuration data method to update the ltiviewer
this.setPlotConfigurationData(this.PlotSetupTableModelUDD.data,...
                                        ed.getFirstRow,ed.getColumn);

%% Set the dirty flag
this.setDirty

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateLinearizationResultsAdded - Callback for when the available
%% analysis results are added.
function LocalUpdateLinearizationResultsAdded(ResultsNode,ed,this)

%% Get the children
Children = LocalFindAnalysisResultsChildren(ResultsNode.getChildren);

if length(Children) > 0
    %% Find the children that have been added
    old_table_data = this.VisibleResultTableModelUDD.data;

    %% Get the number of new elements
    n_new_elements = length(Children) - size(old_table_data,1);

    if n_new_elements > 0
        %% Create data for a new row for each new child
        new_table_data = javaArray('java.lang.Object', n_new_elements, 7);

        %% Determine if the new result should be added
        showplot = this.AutoAddCheckboxUDD.isSelected;

        %% Get the new children
        NewChildren = Children(length(Children)-n_new_elements+1:end);

        %% Get the storage of the analysis results pointers
        AnalysisResultPointers = this.AnalysisResultPointers;

        %% Add the results to the new table data
        for ct = 1:n_new_elements
            new_table_data(ct,1) = java.lang.String(NewChildren(ct).Label);
            %% Store a pointer to the analysis result node
            AnalysisResultPointers{end+1,1} = NewChildren(ct);
            %% Add the system to the viewer if needed
            if (isa(this.LTIViewer,'viewgui.ltiviewer') && showplot)
                this.DeleteViewListeners.Enabled = 'off';
                this.LTIViewer.importsys(sprintf('%s',NewChildren(ct).Label),NewChildren(ct).LinearizedModel);
                %% Store a pointer to the ltisource for tracking later
                AnalysisResultPointers{end,2} = this.LTIViewer.Systems(end);
                this.DeleteViewListeners.Enabled = 'on';
            else
                AnalysisResultPointers{end,2} = handle(0);
            end
        end

        %% Set the storage of the analysis results pointers
        this.AnalysisResultPointers = AnalysisResultPointers;

        %% Set the new data visible boolean values
        new_table_data(:,2:7) = java.lang.Boolean(showplot);

        %% Concatinate the table data
        this.VisibleResultTableModelUDD.data = [old_table_data; new_table_data];
        
        %% Update the listeners for the visible systems
        if isa(this.LTIViewer,'viewgui.ltiviewer')
            createVisibilityListeners(this)
        end
    end
end

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.VisibleResultTableModelUDD);
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(this.VisibleResultTableModelUDD, 'fireTableChanged',...
                {evt}, 'javax.swing.event.TableModelEvent');
javax.swing.SwingUtilities.invokeLater(thr);
            
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateLinearizationResultsDeleted - Callback for when the available
%% analysis results are deleted.
function LocalUpdateLinearizationResultsDeleted(ResultsNode,ed,this)

%% Get the children
Children = LocalFindAnalysisResultsChildren(ResultsNode.getChildren);

%% Get the child the has been deleted
DeletedChild = ed.Child;

%% Get the number of current Children
nChildren = length(Children);

%% Find the index of the row that has been deleted
index = find(DeletedChild == Children);

%% Delete the result from the pointer storage
this.AnalysisResultPointers = this.AnalysisResultPointers([1:index-1,index+1:end],:);

%% Remove the system to the viewer if needed
if isa(this.LTIViewer,'viewgui.ltiviewer')
    this.DeleteViewListeners.Enabled = 'off';
    this.LTIViewer.deletesys(sprintf('%s',DeletedChild.Label));
    this.DeleteViewListeners.Enabled = 'on';
end

%% Get the old table data
old_table_data = this.VisibleResultTableModelUDD.data;

%% Create a new java.lang.Object for the table
if (nChildren-1) > 0
    new_table_data = javaArray('java.lang.Object', nChildren-1, 7);
    
    %% Populate the table data.  Need to handle the case where indexing a
    %% single row of a java.lang.Object[][] returns a java.lang.Object[]
    %% where the vector is now a column vector.
    if (nChildren-1 == 1)
        new_table_data(1) = old_table_data([1:index-1,index+1:nChildren],:);    
    else
        new_table_data(:,:) = old_table_data([1:index-1,index+1:nChildren],:);
    end
    % Store the data in the table model
    this.VisibleResultTableModelUDD.data = new_table_data;
else
    % Clear the rows
    this.VisibleResultTableModelUDD.clearRows;
end

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.VisibleResultTableModelUDD);
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(this.VisibleResultTableModelUDD, 'fireTableChanged',...
                {evt}, 'javax.swing.event.TableModelEvent');
javax.swing.SwingUtilities.invokeLater(thr);

%% Update the listeners for the visible systems
if isa(this.LTIViewer,'viewgui.ltiviewer')
    createVisibilityListeners(this)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalFigureSetupTableModelCallback - Callback for the figure setup changes.
function LocalFigureSetupTableModelCallback(es,ed,this)

%% Call the set plot configuration data method to update the ltiviewer
this.setPlotConfigurationData(this.PlotSetupTableModelUDD.data,...
                                        ed.getFirstRow,ed.getColumn);

%% Set the dirty flag
this.setDirty

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                        
%% LocalUpdateViewButtonCallback - Callback for the update view button
function LocalUpdateViewButtonCallback(es,ed,this)   

this.DisplayView;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                        
%% LocalVisibleResultTableModelCallback - Callback for the visible result
%% table.
function LocalVisibleResultTableModelCallback(es,ed,this)

this.setVisibleSystemTableData(ed.getFirstRow, ed.getColumn);

%% Set the dirty flag
this.setDirty

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
