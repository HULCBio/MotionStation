function DialogPanel = getDialogSchema(this, manager)
%  GETDIALOGSCHEMA  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2003 The MathWorks, Inc.

%% Get the handle to the dialog panel
DialogPanel = com.mathworks.toolbox.slcontrol.LinearizationInspector.InspectorPanel.getInstance;

%% Get a handle to the singleton linearization inspector UDD object
LinearizationInspectorUDD = GenericLinearizationNodes.LinearizationInspector;

if isempty(LinearizationInspectorUDD.SystemListBoxUDD)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Plot Block Linearization Button
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get the handle to the plot block linearization button
    PlotBlockLinearizationButtonUDD = DialogPanel.getPlotBlockLinearizationButton;
    set(PlotBlockLinearizationButtonUDD,'ActionPerformedCallback',{@LocalPlotBlockLinearizationButtonCallback,this})
    LinearizationInspectorUDD.PlotBlockLinearizationButtonUDD = PlotBlockLinearizationButtonUDD;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% System ListBox
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get the handle to System Selected Listbox
    SystemListBoxUDD = DialogPanel.getSystemListBox;
    set(SystemListBoxUDD,'ActionPerformedCallback',{@LocalSystemListBoxCallback,this})
    LinearizationInspectorUDD.SystemListBoxUDD = SystemListBoxUDD;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------------------------------
%% LocalPlotBlockLinearizationButtonCallback - Callback to plot a block
%% linearization
function LocalPlotBlockLinearizationButtonCallback(es,ed,this)

%% Call the plot block linearization method
this.plotBlockLinearization;

%%----------------------------------------------------------------------
%% LocalSystemListBoxCallback - Callback to update the property inspector
function LocalSystemListBoxCallback(es,ed,this)

%% Get the object registry for the property inspector
ObjectRegistry = this.Dialog.getBlockPropertiesRegistry

%% Get the handle to the System ListBox
SystemListBoxUDD = this.Dialog.getSystemListBox;

%% Get the selected index and conver to MATLAB indecies
idx = SystemListBoxUDD.getSelectedIndex + 1;

%% Get the data for the object registry
BlockInfo = javaArray('java.lang.Object',1);
BlockInfo(1) = java(this.Blocks(idx));

%% Set the data
ObjectRegistry.setSelected(BlockInfo,true);