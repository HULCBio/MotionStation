function DialogPanel = getDialogSchema(this, manager)
%  BUILD  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

import com.mathworks.toolbox.slcontrol.GenericLinearizationObjects.*;

%% Add the settings pane to the frame
if ~isempty(this.ModelJacobian)
    node = this.InspectorNode;
    DialogPanel = AnalysisResultsPanel(node.getTreeNodeInterface);
    %% Get the explorer panel
    panel = DialogPanel.getLinearizationInspectPanel;
    this.ExplorerTreeManager = explorer.ExplorerPanelTreeManager(node,panel);
    InspectorInterface = this.InspectorNode(1).getDialogInterface;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Selector ComboBox
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get the selected system combobox
    SelectorComboUDD = DialogPanel.getSelectorCombo;
    %% Set the data model for the combobox
    SelectorComboUDD.setModel(this.getAnalysisResultsComboModel);
    set(SelectorComboUDD,'ActionPerformedCallback',{@LocalSelectorComboCallback,this})
    this.SelectorComboUDD = SelectorComboUDD;
    
    %% Tab selection event
    h = handle( DialogPanel.getTabbedPanel, 'callbackproperties' );
    h.StateChangedCallback = { @LocalTabChange, InspectorInterface };
else
    DialogPanel = AnalysisResultsPanel;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SummaryArea Text Area
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the Java handle
SummaryAreaUDD = DialogPanel.getLinearAnalysisSummaryPanel.getSummaryArea;
this.SummaryAreaUDD = SummaryAreaUDD;
editor = SummaryAreaUDD.getEditor;
h = handle(editor, 'callbackproperties');
h.HyperlinkUpdateCallback = { @LocalEvaluateHyperlinkUpdate, this };
%% Set the data
updateResultSummary(this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Export model button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ExportButtonUDD = DialogPanel.getLinearAnalysisSummaryPanel.getExportButton;
%% Set the callback
set(ExportButtonUDD,'ActionPerformedCallback', {@LocalExportAction, this})
this.ExportButtonUDD = ExportButtonUDD;

%% Make the frame visible
DialogPanel.setVisible(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%----------------------------------------------------------------------
%% LocalEvaluateHyperlinkUpdate
function LocalEvaluateHyperlinkUpdate(hSrc, hData,this)
if strcmp(hData.getEventType.toString, 'ACTIVATED')
    Description = char(hData.getDescription);
    typeind = findstr(Description,':');
    switch Description(1:typeind(1)-1)
        case 'block'
            block = char(Description(typeind(1)+1:end));
            feval( 'hilite_system', block, 'find' )
            pause(1);
            feval( 'hilite_system', block, 'none' )
    end
end

%%----------------------------------------------------------------------
%% LocalTabChange - Callback for when a tab selection is made
function LocalTabChange(es,ed,InspectorInterface)

if (es.getSelectedIndex == 1)
    %% Update the property view object in the linearization inspector
    awtinvoke(InspectorInterface.pv,'triggerRefresh')
end

%%----------------------------------------------------------------------
%% LocalSelectorComboCallback - Callback for the linearization selector combobox
function LocalSelectorComboCallback(es,ed,this)

%% Get the selected subsystem node handle
node = this.InspectorNode;
%% Get the inspector panel
panel = this.Dialog.getLinearizationInspectPanel;

%% Get the selected node and update the block data
selected = getSelected(panel);
if ~isempty(selected)
    %% Get the operating point combobox element
    combo_index = this.Dialog.getSelectedModelIndex;
    
    %% Get the selected node
    node = handle(getObject(selected));
    
    %% Get a handle to the singleton linearization inspector Java Panel
    inspectorpanel = com.mathworks.toolbox.slcontrol.LinearizationInspector.InspectorPanel.getInstance;

    %% Get the handle to the System ListBox
    SystemListBoxUDD = inspectorpanel.getSystemListBox;

    %% Get the selected index and conver to MATLAB indecies
    idx = SystemListBoxUDD.getSelectedIndex + 1;
    %% Get the selected block object
    block = node.Blocks(idx);
    %% Update the ABCD matricies
    updateABCD(block,combo_index);
    %% Get the data for the object registry
    BlockInfo = javaArray('java.lang.Object',1);
    BlockInfo(1) = java(block);
    %% Get the object registry for the property inspector
    ObjectRegistry = inspectorpanel.getBlockPropertiesRegistry;
    %% Set the data
    ObjectRegistry.setSelected(BlockInfo,true);
end

%%----------------------------------------------------------------------
%% LocalExportAction - Callback for the export analysis button
function LocalExportAction(eventSrc, eventData, this)

%% Export the lti object to the workspace
Label = regexprep(this.Label,' ','');
Label = regexprep(Label,'(','');
Label = regexprep(Label,')','');
defaultnames = {sprintf('%s_sys',Label),sprintf('%s_op',Label)};
exporteddata = {this.LinearizedModel,this.OpCondData};
export2wsdlg({'Linearized Model','Operating Point'},defaultnames,exporteddata)

%%----------------------------------------------------------------------
%% LocalHiliteBlocksallback - Callback for the hilite blocks pushbutton
function LocalHiliteBlocksallback(es,ed,this)

this.HiliteBlocksInLinearization
