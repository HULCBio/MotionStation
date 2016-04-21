function DialogPanel = getDialogSchema(this, manager)
%  BUILD  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

import com.mathworks.toolbox.slcontrol.ModelLinearizationProject.*

%% Add the settings pane to the frame
DialogPanel = ModelLinearizationSettingsPanel;

%% Make the panel visible
DialogPanel.setVisible(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Linear Analysis Button
%% Set the action callback for the linearization button and store its
%% handle
LinearizeButtonUDD = DialogPanel.getLinearizeButton;
set(LinearizeButtonUDD,'ActionPerformedCallback',{@LocalLinearizeModelCallback,this})
this.LinearizeButtonUDD = LinearizeButtonUDD;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configure the operation condition selection panel
this.ConfigureOperatingConditionSelectionPanel(DialogPanel);                           
                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configure the analysis result summary panel
ConfigureAnalysisResultsPanel(this,DialogPanel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IO Table Model
%% Set the action callback for the analysis IO table model and store its
%% handle
AnalysisIOTableModelUDD = DialogPanel.IOPanel.IOTableModel;
set(AnalysisIOTableModelUDD,'TableChangedCallback',{@LocalUpdateSetIOTableData,this})
this.AnalysisIOTableModelUDD = AnalysisIOTableModelUDD;

%% Set the table data for the linearization ios
table_data = this.getIOTableData;
AnalysisIOTableModelUDD.data = table_data;

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.AnalysisIOTableModelUDD);
this.AnalysisIOTableModelUDD.fireTableChanged(evt);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalLinearizeModelCallback - Callback for the linearize button to 
%% activate the linearization process.
function LocalLinearizeModelCallback(es,ed,this)

%% Call the linearize model method
this.LinearizeModel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetIOTableData - Callback for the linearize button to 
%% activate the linearization process.
function LocalUpdateSetIOTableData(es,ed,this)

%% Make sure the model is loaded
if ~isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',this.model))
    %% Call the linearize model method
    this.setIOTableData(this.AnalysisIOTableModelUDD.data);
end

