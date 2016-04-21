function DialogPanel = getDialogSchema(this, manager)
%  getDialogSchema  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

import com.mathworks.toolbox.slcontrol.SISODesignGUI.*

%% Add the settings pane to the frame
DialogPanel = SISOControlDesignSettings;

%% Make the frame visible
DialogPanel.setVisible(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ValidElementsTableModel Table Model
%% Set the action callback for the ValidElementsTableModel table model 
%% and store its handle
ValidElementsTableModelUDD = DialogPanel.ControlPanel.getValidBlocksTableModel;
set(ValidElementsTableModelUDD,'TableChangedCallback',{@LocalUpdateSetValidElementsTable,this})
this.ValidElementsTableModelUDD = ValidElementsTableModelUDD;

%% Set the table data for the linearization ios
table_data = this.getValidBlocks;
ValidElementsTableModelUDD.data = table_data;
%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.ValidElementsTableModelUDD);
this.ValidElementsTableModelUDD.fireTableChanged(evt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DesignToolButton
%% Set the action callback for the DesignToolButton and store its handle
DesignToolButtonUDD = DialogPanel.getDesignToolButton;
set(DesignToolButtonUDD,'ActionPerformedCallback',{@LocalDesignToolButtonClicked,this})
this.DesignToolButtonUDD = DesignToolButtonUDD;
this.DesignToolButtonUDD.setEnabled(0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ClosedLoopRespButton
%% Set the action callback for the ClosedLoopRespButton and store its
%% handle
ClosedLoopRespButtonUDD = DialogPanel.getClosedLoopRespButton;
set(ClosedLoopRespButtonUDD,'ActionPerformedCallback',{@LocalClosedLoopButtonPressed,this})
this.ClosedLoopRespButtonUDD = ClosedLoopRespButtonUDD;
this.ClosedLoopRespButtonUDD.setEnabled(0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configure the operation condition selection panel
this.ConfigureOperatingConditionSelectionPanel(DialogPanel);     
                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configure the menus
this.ConfigureDefaultMenus;
this.ConfigureMenus;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UpdateSimulinkModelButton
%% Set the action callback to update the Simulink model
UpdateSimulinkModelButtonUDD = DialogPanel.getUpdateSimulinkModelButton;
set(UpdateSimulinkModelButtonUDD,'ActionPerformedCallback',{@LocalUpdateSimulinkModelButtonPressed,this})
this.UpdateSimulinkModelButtonUDD = UpdateSimulinkModelButtonUDD;
this.UpdateSimulinkModelButtonUDD.setEnabled(0);

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
DialogPanel.IOPanel.UpdateTable;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetValidElementsTable - Callback for the updating of the
%% valid blocks table
function LocalUpdateSetValidElementsTable(es,ed,this)

%% Get the valid elements table model
TableModel = this.ValidElementsTableModelUDD;
data = TableModel.data;

%% Determine if any of the checkboxes have been checked
%% TODO: Optimize
check = 0;
for ct = 1:size(data,1)
     check = check + data(ct,1);   
end

%% Enable the buttons if there is a control element selected
this.DesignToolButtonUDD.setEnabled(check >= 1);
this.ClosedLoopRespButtonUDD.setEnabled(check >= 1);
if ~isempty(this.UpdateSimulinkModelButtonUDD)
    this.UpdateSimulinkModelButtonUDD.setEnabled(check >= 1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDesignToolButtonClicked - Callback for the design tool button to 
%% launch the SISOTool.
function LocalDesignToolButtonClicked(es,ed,this)

%% Call the linearize model method
this.SISODesignGUI = LaunchSisoTool(this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSimulinkModelButtonPressed - Callback for the updating of the Simulink
%% block diagram
function LocalUpdateSimulinkModelButtonPressed(es,ed,this)

%% Write to the Simulink model the new block settings
ValidBlocks = this.ValidBlocks;
for ct = 1:size(ValidBlocks,1)
    if ~isempty(ValidBlocks{ct,2})
        LocalUpdateBlock(ValidBlocks{ct,1}, ValidBlocks{ct,2});
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateBlock
function LocalUpdateBlock(blockhandle,system)

%% Determine the type of block
blocktype = get_param(blockhandle,'BlockType');

switch blocktype
    case 'TransferFcn'
        sys = tf(system);
        set_param(blockhandle, 'Numerator', mat2str(sys.num{:},5),...
                             'Denominator', mat2str(sys.den{:},5));
    case 'StateSpace'
        sys = ss(system);
        set_param(blockhandle, 'A', mat2str(sys.a,5),...
                             'B', mat2str(sys.b,5),...        
                             'C', mat2str(sys.c,5),...
                             'D', mat2str(sys.d,5));        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateSetIOTableData - Callback for updating the closed loop IO
%% data.
function LocalUpdateSetIOTableData(es,ed,this)

%% Update the IO data with a change
this.setIOTableData(this.AnalysisIOTableModelUDD.data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalClosedLoopButtonPressed - Callback to launch the ltiviewer.
function LocalClosedLoopButtonPressed(es,ed,this)

%% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

%% Clear the status area
ExplorerFrame.clearText;

%% Post to status
ExplorerFrame.postText(' - Launching the LTI Viewer...')

if ((isempty(this.SISODesignGUI)) || (~isa(this.SISODesignGUI.UserData,'sisogui.sisotool')))
    this.SISODesignGUI = this.LaunchSisoTool;
end

PlotContents = struct(...
    'PlotType',{'step';'step';'bode';'bode';'nyquist'},...
    'VisibleModels',{[1:this.NumberResponses];[3 4];1;7;6});

sisodb = get(this.SISODesignGUI,'UserData');
if isempty(sisodb.AnalysisView)  % first selection
    % Create view
    ViewerContents = getViewerContents(sisodb);
    sisodb.setViewerContents([ViewerContents;PlotContents(1)]);
end
figure(double(sisodb.AnalysisView.Figure))
ExplorerFrame.postText(' - Launch of the LTI Viewer Complete')
