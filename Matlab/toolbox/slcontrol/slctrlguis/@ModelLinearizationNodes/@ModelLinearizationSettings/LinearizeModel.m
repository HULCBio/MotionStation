function LinearizeModel(this)
%% Method to linearize the Simulink model from the linearixation GUI.

%  Author(s): John Glass
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.10 $ $Date: 2004/04/19 01:32:46 $

import java.lang.*;

%% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

%% Clear the status area
ExplorerFrame.clearText;

%% Get the settings node and its dialog interface
di = this.Dialog;

%% Get the selected rows for the operating condition
if ~isempty(di)
    indecies = di.OpCondPanel.getOpCondSelectPanel.OpCondTable.getSelectedRows + 1;
else
    indecies = 1;
end

%% Error out if the user has not selected an operating condition
if ((isempty(indecies)) || (~any(indecies))) 
    errordlg('Please select an operating point for linearization','Simulink Control Design')
    return
end

%% Get the handle to the operating conditions object
OpCondNode = getOpCondNode(this);
%% Update the linoptions
try
    OpCondNode.updatelinearizateoptions
catch
    lsterror = lasterror;
    errordlg(lsterror.message,'Simulink Control Design')
    return    
end

OpCondResults = OpCondNode.getChildren;
StateOrderList = OpCondNode.StateOrderList;

%% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',this.model))
    preloaded = 0;
    load_system(this.model);
else 
    preloaded = 1;
end 

%% Linearize the model
io = this.IOData;
ExplorerFrame.postText(sprintf(' - Linearizing the model: %s.',this.Model))
%% Check to make sure that the user has selected linearization I/O
if isempty(this.IOData)
    ExplorerFrame.postText(sprintf(' - Linearizing using root level ports for linearization inputs and outputs.'))
else
    iotypes = get(this.IOData, 'type');
    if ~((any(strcmp(iotypes,'in')) && any(strcmp(iotypes,'out'))) || ...
         (any(strcmp(iotypes,'inout')) || any(strcmp(iotypes,'outin'))))
        ExplorerFrame.postText(sprintf(' - Warning, the resulting linearized model will either have no input or output.'))
     end
end

%% Add the result as a node in the GUI
Frame = slctrlexplorer;
SessionChildren = this.getChildren;

%% Create a new analysis node
LinearAnalysis = GenericLinearizationNodes.LinearAnalysisResultNode('Model');
LinearAnalysis.Label = LinearAnalysis.createDefaultName('Model', this);
LinearAnalysis.Model = this.Model;

SysNotes = cell(length(indecies),1);
J =[];
opstorage = [];
for ct = 1:length(indecies)
    %% Get the operating condition
    OpNode = OpCondResults(indecies(ct));
    
    %% Update the operating condition object
    if isa(OpNode,'OperatingConditions.OperConditionValuePanel')
        try
            if ~isempty(OpNode.Dialog)
                lasterr('');
                OpNode.updateopcond;
            end
        catch
            errordlg(lasterr,'Simulink Control Design');
            return
        end
    end
        
    %% Get the operating point object    
    op = copy(OpNode.OpPoint);
    %% Sort the states first get the states in the operating point
    OpStates = cell(length(op.States),1);
    for ct2 = 1:length(op.States)
        if isa(op.States(ct2),'opcond.StatePointSimMech')
            OpStates{ct2} = op.States(ct2).SimMechBlock;
        else
            OpStates{ct2} = op.States(ct2).Block;
        end
    end

    StateOrderList = OpCondNode.StateOrderList;
    ind = [];
    indState = [1:length(StateOrderList)]';

    %% Loop over the state objects
    for ct2 = 1:length(StateOrderList)
        stateind = find(strcmp(StateOrderList(ct2),OpStates));
        if isempty(stateind)
            errordlg(sprintf(['The state sorting order contains states that are not ',...
                'in the operating point %s.  Please go to the Tools menu and select ',...
                'the Options dialog to synchronize the state ordering with the Simulink Model.'],...
                OpNode.Label));
            return
        end
        indState(stateind) = 0;
        ind = [ind;stateind];
    end
    if any(indState) || (length(ind) ~= length(op.States))
            errordlg(sprintf(['The operating point %s contains states that are not ',...
                'in the state sorting order.  Please sync this operating point.'],...
                OpNode.Label));
        return
    end
    %% Sort the operating point states
    op.States = op.States(ind);

    %% Linearize the model
    try
        if strcmp(OpCondNode.Options.LinearizationAlgorithm,'blockbyblock')
            if isempty(io)
                [sys_ct,J_ct] = linearize(op.Model,op,OpCondNode.Options);
            else
                [sys_ct,J_ct] = linearize(op.Model,op,io,OpCondNode.Options);
            end
        else
            sys_ct = linearize(op.Model,op,OpCondNode.Options);
            J_ct = [];
        end
    catch
        lsterror = lasterror;
        if strcmp(lsterror.identifier,'slcontrol:operpoint:NeedsUpdate')
            str = sprintf(['Your Simulink model %s is out of sync with your operating ',...
                      'condition point %s.  Please sync before linearizing.'],...
                      this.Model,OpNode.Label);
            errordlg(str, 'Simulink Control Design')
            return
        else
            str = sprintf(['Your Simulink model %s could not be linearized due ',...
                    'to the following error: \n\n %s'],this.Model,lsterror.message);
            errordlg(str, 'Simulink Control Design')    
            return
        end
    end
    
    if (ct == 1)
        sys = sys_ct;
        J = J_ct;
        opstorage = copy(op);
    else
        sys(:,:,ct) = sys_ct;
        if ~isempty(J_ct)
            J(ct) = J_ct;
        end
        opstorage(end+1) = copy(op);
    end
    SysNotes{ct} = OpCondResults(indecies(ct)).Label;
    
    if isa(OpNode,'OperatingConditions.OperConditionValuePanel')
        %% Create the new operating conditions node
        node = OperatingConditions.OperConditionValuePanel(copy(op),OpNode.Label);
    else
        %% Create the new operating conditions node
        node = OperatingConditions.OperConditionResultPanel(OpNode.Label);

        %% Store the linearization operating condition results and settings
        node.OpPoint = copy(op);
        node.OpReport = copy(OpNode.OpReport);

        %% Store the operating condition constraints if we are trimming
        if isa(OpCondNode,'OperatingConditions.OperConditionResultPanel')
            node.OpConstrData = OpNode.OpConstrData;
            node.OperatingConditionSummary = OpNode.OperatingConditionSummary;
        end
    end

    %% Add it to the Linearization Result node
    LinearAnalysis.addNode(node);     
end
set(sys,'Notes',SysNotes);

%% Add the data the linearization results node
LinearAnalysis.LinearizedModel = sys;
LinearAnalysis.ModelJacobian = J;
LinearAnalysis.Description = sprintf('%d - Linear Model(s)',length(indecies));
LinearAnalysis.OpCondData = opstorage;

%% Store the IO data to be used later to recalculate linearizations
if ~isempty(J) && ~isempty(io)
    inports = J(1).Mi.InputPorts;
    outports = J(1).Mi.OutputPorts;
    %% Logic to get the proper names and dimensions for each IO.
    [input_ind,output_ind,input_name,output_name] = getIOIndecies(io,inports,outports);  
    LinearAnalysis.LinearizationIOData = struct('input_ind',{input_ind},...
                                                'output_ind',{output_ind},...
                                                'input_name',{input_name},...
                                                'output_name',{output_name});
    LinearAnalysis.LinearizationOptions = copy(OpCondNode.Options);
    %% Get the indecies of the blocks that should be removed.
    %% Get the model sample rates and block dimensions
    [ny,nu] = size(J(1).D);
    nxz = size(J(1).A,1);
    %% Removing blocks that are not part of the linearization
    blocks = find(~(J(1).Mi.ForwardMark & J(1).Mi.BackwardMark));
    nblocks = length(blocks);
    
    %% Get the block handles
    bh = J(1).Mi.BlockHandles;
    
    %% Extract index elements, tack on the number of states, inputs, and
    %% outputs to account for the last block in the list.  Convert from
    %% C-indexing to Matlab-indexing.
    StateIdx = [J(1).Mi.StateIdx+1;nxz+1];
    InputIdx = [J(1).Mi.InputIdx+1;nu+1];
    OutputIdx = [J(1).Mi.OutputIdx+1;ny+1];
    StateName = J(1).StateName;
    
    indx = [];indu = [];indy = [];
    for ct = 1:nblocks
        %% Get the block handle
        try
            state_ind = find(strcmp(getfullname(bh(blocks(ct))),StateName));
            if ~isempty(state_ind)
                indx = [indx;state_ind];
            end
        end
        if (InputIdx(blocks(ct)) ~= InputIdx(blocks(ct)+1))
            indu = [indu,InputIdx(blocks(ct)):(InputIdx(blocks(ct)+1)-1)];
        end
        if (OutputIdx(blocks(ct)) ~= OutputIdx(blocks(ct)+1))
            indy = [indy,OutputIdx(blocks(ct)):(OutputIdx(blocks(ct)+1)-1)];
        end
    end
    %% Store the states, inputs, and outputs that will not be part of the 
    %% linearization for later use.
    LinearAnalysis.indx = indx;
    LinearAnalysis.indu = indu;
    LinearAnalysis.indy = indy;
end
        
%% Add it to the this node above the views folder
connect(LinearAnalysis,SessionChildren(end),'right');

%% Call getInspectorPanelData since the meaning of the block handles will go away
%% if the model is closed
if strcmp(OpCondNode.Options.LinearizationAlgorithm,'blockbyblock')
    ExplorerFrame.postText(sprintf(' - Generating linearization inspector information.'))
    LinearAnalysis.getInspectorPanelData;
end

%% Send update to tell the user that a node has been added
ExplorerFrame.postText(sprintf(' - A linearization result %s has been added to the current Task.', LinearAnalysis.Label))

%% Get the user selected lti plot type
plottype = char(di.getLtiPlotType);

%% Check to see if a new view is needed to be added
if (~strcmp(plottype,'None')) && (~isa(this.LTIViewer,'viewgui.ltiviewer'))
    ExplorerFrame.postText(sprintf(' - Launching the LTI Viewer...'))
    [Viewer,vh] = ltiview(plottype,sys);
    %% Set the title
    set(Viewer,'Name','LTI Viewer: Linearization Quick Plot')
    %% Store the viewer handle
    this.LTIViewer = vh;
    ExplorerFrame.postText(sprintf(' - LTI Viewer is ready...'))    
elseif isa(this.LTIViewer,'viewgui.ltiviewer') && (~strcmp(plottype,'None'))
    %% Get the current available views and add a new view if needed
    currentviews = get(this.LTIViewer.getCurrentViews,{'Tag'});
    ExplorerFrame.postText(sprintf(' - Updating the LTI Viewer...'))
    if ~any(strcmp(currentviews,plottype))
        currentviews = {plottype};
        this.LTIViewer.setCurrentViews(currentviews);
    end
    this.LTIViewer.importsys(sprintf('%s',LinearAnalysis.Label),sys);
    ExplorerFrame.postText(sprintf(' - LTI Viewer is ready...')) 
end

if preloaded == 0
    close_system(model,0);
end

%% Set the dirty flag
this.setDirty
