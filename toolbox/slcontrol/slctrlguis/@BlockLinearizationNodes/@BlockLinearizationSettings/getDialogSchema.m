function DialogPanel = getDialogSchema(this, manager)
%  BUILD  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.6 $  $Date: 2004/04/11 00:35:21 $
import com.mathworks.toolbox.slcontrol.BlockLinearizationProject.*

%% Add the settings pane to the frame
DialogPanel = BlockLinearizationSettingsPanel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Linearize Block Button
%% Set the action callback for the linearization button and store its
%% handle
LinearizeButtonUDD = DialogPanel.getLinearizeButton;
set(LinearizeButtonUDD,'ActionPerformedCallback',{@LocalLinearizeBlockCallback,this})
this.LinearizeButtonUDD = LinearizeButtonUDD;

%% Make the panel visible
DialogPanel.setVisible(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configure the operation condition selection panel
this.ConfigureOperatingConditionSelectionPanel(DialogPanel);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configure the analysis result summary panel
ConfigureAnalysisResultsPanel(this,DialogPanel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions 
%%

%% LocalLinearizeModelCallback - Callback for the linearize button to 
%% activate the linearization process.
function LocalLinearizeBlockCallback(es,ed,this)

%% Call the linearize model method
this.LinearizeBlock;
