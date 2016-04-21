function [controldesignerhandle,uddhandle] = simcontdesigner(varargin);
%% SIMCONTDESIGNER - Function used as a gateway to launch the simulink
%% control design GUI

%%  Author(s): John Glass
%%  Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.12 $  $Date: 2004/04/11 00:37:22 $

%% Switch yard for GUI interaction with Simulink
%% Get the simulink model name
try
    if isa(varargin{2},'char')
        diagram_name = varargin{2};
    else
        diagram_name=get_param(varargin{2},'Name');
    end
catch
    if isa(varargin{2},'char')
        diagram_name = varargin{2};
        open_system(diagram_name);
        diagram_name = gcs;
    else
        try
            diagram_name=get_param(varargin{2},'Name');
            open_system(diagram_name);
        catch
            error('Invalid Simulink diagram handle.');
        end
    end
end

switch varargin{1}
    case 'initialize_linearize'
        %% Get the handle to the project
        if ((nargin > 2) && isa(varargin{3},'explorer.Project'))
            project = varargin{3};
            FRAME = slctrlexplorer;
            addoptask(diagram_name,project);
        else
            [project, FRAME] = getvalidproject(diagram_name,true);
            if isempty(project)
                return
            end
        end
        
        %% Create the waitbar
        wb = waitbar(0,'Please Wait, Opening linearization task','Name',...
                                    'Control and Estimation Tools Manager');
        
        %% Update the waitbar
        waitbar(0.25,wb,sprintf('Gathering information from: %s',diagram_name));
        
        %% Get the default nodes
        SettingsNode = ModelLinearizationNodes.ModelLinearizationSettings(diagram_name);
        %% Add the clean up listener
        SettingsNode.createRemoveProjectListener(project)
        
        %% Update the waitbar
        waitbar(0.75,wb,'Rendering the linearization task')
        
        %% Add it to the Workspace first a unique label
        SettingsNode.Label = SettingsNode.createDefaultName(SettingsNode.Label, project);
        project.addNode(SettingsNode);
        node = SettingsNode.getTreeNodeInterface;
        FRAME.setSelected(SettingsNode.getTreeNodeInterface);
        
        %% Expand by default to show the default operating
        %% conditions, analysis results and views
%         FRAME.expandNode(SettingsNode.down.getTreeNodeInterface);
        
        %% Update and close the waitbar
        waitbar(1,wb);
        close(wb)

        %% Show the explorer frame
        if ~FRAME.isVisible
            FRAME.setVisible(true);
        end
        
        %% Set the project dirty flag
        project.Dirty = 1;
        
        %% Search for linearization point blocks
        outpoints = find_system(diagram_name,'ReferenceBlock','slctrlobsolete/Output Point');
        inpoints = find_system(diagram_name,'ReferenceBlock','slctrlobsolete/Input Point');
        
        if ~isempty(outpoints) || ~isempty(inpoints)
            warndlg(sprintf(['There are linearization input and/or output blocks in the model %s that are no ',...
                'longer supported for linearization.  Please remove these blocks and right click on a signal ',...
                'to specify these linearization points.'],diagram_name),'Simulink Control Design','modal');
        end
        
    case 'initialize_controller_design'
        %% Get the handle to the project
        if ((nargin > 2) && isa(varargin{3},'explorer.Project'))
            project = varargin{3};
            FRAME = slctrlexplorer;
        else
            [project, FRAME] = getvalidproject(diagram_name,true);
            if isempty(project)
                return
            end
        end
        %% Create the waitbar
%         wb = waitbar(0,'Please Wait, Opening compensator design task','Name','Control and Estimation Tools Manager');
        
        %% Create a SISO Design Session Node
        SettingsNode = SISODesignNodes.SISODesignSettings(diagram_name);
        
        %% Add it to the Workspace first a unique label
        SettingsNode.Label = SettingsNode.createDefaultName(SettingsNode.Label, project);
        project.addNode(SettingsNode);
        FRAME.setSelected(SettingsNode.getTreeNodeInterface);
        
        %% Close the waitbar
%         close(wb)
        
        %% Show the explorer frame
        if ~FRAME.isVisible
            FRAME.setVisible(true);
        end
        
        %% Set the project dirty flag
        project.Dirty = 1;
        
    case 'linearizeblock'            
        %% Get the handle to the project
        [project, FRAME] = getvalidproject(diagram_name,true);
        if isempty(project)
            return
        end
        
        %% Create the waitbar
        wb = waitbar(0,'Please Wait, Opening block linearization task','Name','Control and Estimation Tools Manager');
        
        %% Update the waitbar
        waitbar(0.25,wb,sprintf('Gathering information from: %s',diagram_name));
        
        %% Get the default nodes
        SettingsNode = BlockLinearizationNodes.BlockLinearizationSettings(diagram_name,varargin{3});
        %% Add the clean up listener
        SettingsNode.createRemoveProjectListener(project)
                
        %% Update the waitbar
        waitbar(0.75,wb,'Rendering the linearization task')
        
        %% Add it to the Workspace first a unique label
        SettingsNode.Label = SettingsNode.createDefaultName(SettingsNode.Label, project);
        project.addNode(SettingsNode);
        FRAME.setSelected(SettingsNode.getTreeNodeInterface);
        
        %% Expand by default to show the default operating
        %% conditions, analysis results and views
        FRAME.expandNode(SettingsNode.getTreeNodeInterface);
        
        %% Update and close the waitbar
        waitbar(1,wb);
        close(wb)
        
        %% Show the explorer frame
        if ~FRAME.isVisible
            FRAME.setVisible(true);
        end
        
        %% Set the project dirty flag
        project.Dirty = 1;
        
    case 'updateio'
        %% Get the frame and workspace handles
        [FRAME,WSHANDLE] = slctrlexplorer;
        %% Update the IO panel if valid
        if (isa(FRAME,'com.mathworks.toolbox.control.explorer.Explorer'))
            jSelected = FRAME.getSelected;
            if ~isempty(jSelected)
                SelectedNode = handle(getObject(FRAME.getSelected));
                SettingsNode = [];
                %% Loop up until we reach the top of the tree
                while ~isempty(SelectedNode)
                    if (isa(SelectedNode,'ModelLinearizationNodes.ModelLinearizationSettings') ||...
                            isa(SelectedNode,'SISODesignNodes.SISODesignSettings'))
                        SettingsNode = SelectedNode;
                        break
                    end
                    SelectedNode = SelectedNode.up;
                end
                %% Make sure that we are updating a project with the
                %% same model
                if ~isempty(SettingsNode) && strcmpi(SettingsNode.Model,diagram_name)
                    %% Get the selected settings object
                    SettingsNode.SyncSimulinkIO(1);
                    %% Set the table data for the linearization ios
                    table_data = SettingsNode.getIOTableData;
                    AnalysisIOTableModelUDD = SettingsNode.AnalysisIOTableModelUDD;
                    AnalysisIOTableModelUDD.data = table_data;

                    %% Create a table model event to update the table
                    evt = javax.swing.event.TableModelEvent(AnalysisIOTableModelUDD);
                    AnalysisIOTableModelUDD.fireTableChanged(evt);
                    %% Set the project dirty flag
                    SettingsNode.up.Dirty = 1;
                end
            end
        end
        
    case 'updatetrim'
        %% Get the frame and workspace handles
        [FRAME,WSHANDLE] = slctrlexplorer;
        %% Update the IO panel if valid
        if (isa(FRAME,'com.mathworks.toolbox.control.explorer.Explorer'))
            SelectedNode = handle(getObject(FRAME.getSelected));
            if isa(SelectedNode,'explorer.Project')
                SelectedRoot = SelectedNode;
            elseif isa(SelectedNode,'explorer.Workspace')
                return
            else
                SelectedRoot = SelectedNode.getRoot.up;
            end
            ProjectChildren = SelectedRoot.getChildren;
            OpCondSpecNode = handle(ProjectChildren(1));
            %% Make sure that we are updating a project with the
            %% same model
            if strcmpi(OpCondSpecNode.Model,diagram_name)
                %% Get the operating conditions node for the project
                OpCondSpecNode.SyncSimulinkOpCond;
                %% Set the table data for the output constraint table data
                table_data = OpCondSpecNode.getOutputConstrTableData;
                OutputConstrTableModelUDD = OpCondSpecNode.OutputConstrTableModelUDD;
                OutputConstrTableModelUDD.data = table_data(1);
                if ~isa(OpCondSpecNode,'OperatingConditions.OperatingConditionTask')
                    warning('SimulinkControlDesignerGUIUpdate','Cannot find the root project operating points node')
                end
                
                if ~isempty(OpCondSpecNode.OpCondSpecPanelUDD)
                    OpCondSpecNode.OutputIndecies = table_data(2);
                    OpCondSpecNode.OpCondSpecPanelUDD.setOutputConstrTableIndecies(table_data(2));
                    OpCondSpecNode.OpCondSpecPanelUDD.OutputConstrTable.UpdateTable;
                    %% Set the project dirty flag
                    SelectedRoot.Dirty = 1;
                end
            end
        end
end

controldesignerhandle = FRAME;

if nargout > 1     
    uddhandle = WSHANDLE;
end
