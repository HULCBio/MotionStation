function this = MPCLinearizationSettings(model)
%%  MPCLINEARIZATIONSETTINGS Constructor for @MPCLinearizationSettings class
%%
%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.

%% Create class instance
this = mpcnodes.MPCLinearizationSettings;
%% Store the model name
this.Model = model;
%% Get the linearization settings
open_system(model); % If constructor is called during a load the model may not be open
this.IOData = getlinio(model);

%% Create the panel
import com.mathworks.toolbox.slcontrol.GenericLinearizationObjects.*

%% Add the settings pane to the frame
this.IOPanel = AnalysisIOPanel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IO Table Model
%% Set the action callback for the analysis IO table model and store its
%% handle
AnalysisIOTableModelUDD = this.IOPanel.IOTableModel;
set(AnalysisIOTableModelUDD,'TableChangedCallback',{@LocalUpdateSetIOTableData,this})
this.AnalysisIOTableModelUDD = AnalysisIOTableModelUDD;

%% Set the table data for the linearization ios
table_data = this.getIOTableData;
AnalysisIOTableModelUDD.data = table_data;

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.AnalysisIOTableModelUDD);
this.AnalysisIOTableModelUDD.fireTableChanged(evt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetIOTableData - Callback for the linearize button to 
%% activate the linearization process.
function LocalUpdateSetIOTableData(es,ed,this)

%% Call the linearize model method
this.setIOTableData(this.AnalysisIOTableModelUDD.data);