function DialogPanel = getDialogInterface(this, manager)
%  GETDIALOGINTERFACE  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/11 00:35:53 $

%% Get a handle to the singleton linearization inspector Java Panel
DialogPanel = com.mathworks.toolbox.slcontrol.LinearizationInspector.InspectorPanel.getInstance;

%% Get a handle to the singleton linearization inspector UDD object
LinearizationInspectorUDD = GenericLinearizationNodes.LinearizationInspector;

if ~isempty(LinearizationInspectorUDD.SystemListBoxUDD)
    %% Disable the listbox callback and plot block button
    %% Get the handle to the plot block linearization button
    PlotBlockLinearizationButtonUDD = LinearizationInspectorUDD.PlotBlockLinearizationButtonUDD;
    set(PlotBlockLinearizationButtonUDD,'ActionPerformedCallback',[])
    LinearizationInspectorUDD.PlotBlockLinearizationButtonUDD = PlotBlockLinearizationButtonUDD;
    %% Get the handle to System Selected Listbox
    SystemListBoxUDD = LinearizationInspectorUDD.SystemListBoxUDD;
    set(SystemListBoxUDD,'ValueChangedCallback',[])
    LinearizationInspectorUDD.SystemListBoxUDD = SystemListBoxUDD;
end
    
%% Get the object registry for the property inspector
ObjectRegistry = DialogPanel.getBlockPropertiesRegistry;

%% Renable the listbox callback and push button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot Block Linearization Button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the handle to the plot block linearization button
PlotBlockLinearizationButtonUDD = DialogPanel.getPlotBlockLinearizationButton;
%% Set the call back for the show block button
h = handle( PlotBlockLinearizationButtonUDD, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalPlotBlockLinearizationButtonCallback,this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% System ListBox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the handle to System Selected Listbox
SystemListBoxUDD = DialogPanel.getSystemListBox;
set(SystemListBoxUDD,'ValueChangedCallback',[])

%% Set the new listmodel
awtinvoke(SystemListBoxUDD,'setModel',this.BlockList);
DialogPanel.setVisible(true)
%% Get the data for the object registry
BlockInfo = javaArray('java.lang.Object',1);
if ~isempty(this.Blocks)
    %% Set the listbox model with the data from the subsystem
    awtinvoke(SystemListBoxUDD,'setSelectedIndex',0);
    %% Get the model node.
    frame=slctrlexplorer;
    model = handle(getObject(getSelected(frame)));
    %% Get the operating point combobox element
    if isempty(model.Dialog)
        combo_index = 1;
    else
        combo_index = model.Dialog.getSelectedModelIndex;
    end
    %% Set the data
    block = this.Blocks(1);
    updateABCD(block,combo_index);
    BlockInfo(1) = java(block);
    ObjectRegistry.setSelected(BlockInfo,true);
else
    DummyData = GenericLinearizationNodes.BlockInspectorLinearization;
    DummyData.FullBlockName = 'No blocks';
    BlockInfo(1) = java(DummyData);
    ObjectRegistry.setSelected(BlockInfo,true);
end

%% Restore the callback
set(SystemListBoxUDD,'ValueChangedCallback',{@LocalSystemListBoxCallback,this})
LinearizationInspectorUDD.SystemListBoxUDD = SystemListBoxUDD;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Show selected block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the call back for the show block button
h = handle( DialogPanel.getShowBlockButton, 'callbackproperties' );
h.ActionPerformedCallback = { @LocalShowBlock, this };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------------------------------
%% LocalShowBlock - Highlight the selected block
function LocalShowBlock(es,ed,this)

%% Get a handle to the singleton linearization inspector Java Panel
LinearizationInspectPanel = com.mathworks.toolbox.slcontrol.LinearizationInspector.InspectorPanel.getInstance;

%% Get the selected system index
idx = LinearizationInspectPanel.getSystemListBox.getSelectedIndex;

%% Get the full block name
if idx >= 0
    block = this.Blocks(idx+1).getFullBlockName;
    try
        hilite_system(block,'find');pause(0.5);hilite_system(block,'none')
    catch
        str = sprintf('The block %s is no longer in the model.',block);
        errordlg(str,'Simulink Control Design')
    end
else
    errordlg('There are no blocks currently selected','Simulink Control Design')
end

%%----------------------------------------------------------------------
%% LocalPlotBlockLinearizationButtonCallback - Callback to plot a block
%% linearization
function LocalPlotBlockLinearizationButtonCallback(es,ed,this)

%% Call the plot block linearization method
this.plotBlockLinearization;

%%----------------------------------------------------------------------
%% LocalSystemListBoxCallback - Callback to update the property inspector
function LocalSystemListBoxCallback(es,ed,this)

%% Get a handle to the singleton linearization inspector Java Panel
DialogPanel = com.mathworks.toolbox.slcontrol.LinearizationInspector.InspectorPanel.getInstance;

if ~ed.getValueIsAdjusting
    %% Get the object registry for the property inspector
    ObjectRegistry = DialogPanel.getBlockPropertiesRegistry;

    %% Get the handle to the System ListBox
    SystemListBoxUDD = DialogPanel.getSystemListBox;

    %% Get the selected index and conver to MATLAB indecies
    list_index = SystemListBoxUDD.getSelectedIndex + 1;

    %% Get the data for the object registry
    BlockInfo = javaArray('java.lang.Object',1);
    if ~isempty(this.Blocks)
        %% Get the model node.
        frame=slctrlexplorer; 
        model = handle(getObject(getSelected(frame)));
        %% Get the operating point combobox element
        combo_index = model.Dialog.getSelectedModelIndex;
        %% Set the data
        block = this.Blocks(list_index);
        updateABCD(block,combo_index);
        BlockInfo(1) = java(block);
        %% Set the data
        ObjectRegistry.setSelected(BlockInfo,true);
    else
        DummyData = GenericLinearizationNodes.BlockInspectorLinearization;
        DummyData.FullBlockName = 'No blocks';
        BlockInfo(1) = java(DummyData);
        ObjectRegistry.setSelected(BlockInfo,true);
    end
end
