function ComputeOpCondSim(this)
%% Method to compute the operating conditions of a Simulink model.

%%  Author(s): John Glass
%%  Copyright 1986-2004 The MathWorks, Inc.

import java.lang.*;

%% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

%% Clear the status area
ExplorerFrame.clearText;

%% Get the settings node and its dialog interface
di = this.OpCondSpecPanelUDD;
SnapShotTimes_str = char(di.SimLinearizationPanel.LinearizationTimesTextField.getText);

if ~isempty(SnapShotTimes_str)
    SnapShotTimes = str2num(SnapShotTimes_str);
    if isempty(SnapShotTimes)
        try
            SnapShotTimes = evalin('base',SnapShotTimes_str);
        catch
            errordlg('Please enter valid snaphot times.','Operating Points Computation Error');
            return
        end
    end
else
    errordlg('Please enter valid snaphot times.','Operating Points Computation Error');
    return
end

if ~isa(SnapShotTimes,'double')
    errordlg('Snapshot times must be a vector of doubles.','Operating Points Computation Error');
    return
end

if any(SnapShotTimes < 0)
    errordlg('All snapshot times must be greater then zero.','Operating Points Computation Error');
    return
end

%% Check for infinite snapshot times
if any(isinf(SnapShotTimes)) 
    SnapShotTimes(find(isinf(SnapShotTimes))) = [];
elseif any(isnan(SnapShotTimes))
    SnapShotTimes(find(isnan(SnapShotTimes))) = [];
end

if ~isempty(SnapShotTimes)
    ExplorerFrame.postText(sprintf(' - Computing the operating point(s) of the model via simulation: %s.',this.Model))

    %% Compute operating conditions at snapshot times
    try
        oppoint = opsnapshot(linevent(this.Model,SnapShotTimes(:)));
        OperatingConditionSummary = cell(length(oppoint),1);
        for ct = 1:length(oppoint)
            OperatingConditionSummary{ct} = sprintf('Operating Point at t = %d ',oppoint(ct).Time);
        end
    catch
        lsterr = lasterror;
        str = sprintf(['The model %s could not be simulated due to the following error:\n',...
                '%s'],this.Model,lsterr.message);
        errordlg(str,'Operating Points Computation Error')
        return
    end
else
    errordlg('No valid snapshot times selected.','Operating Points Computation Error')
    return
end

%% Create the linearization settings object
for ct = 1:length(oppoint)
    %% Create the operating conditions result node
    children = this.getChildren;
    nchars = length(OperatingConditionSummary{ct});
    matches = sum(strncmp(get(children,'Label'),OperatingConditionSummary{ct},nchars));

    if matches
        Label = sprintf('%s(%d)',OperatingConditionSummary{ct},matches);
    else
        Label = OperatingConditionSummary{ct};
    end
    node = OperatingConditions.OperConditionValuePanel(oppoint(ct),Label);
    node.Description = OperatingConditionSummary{ct};

    %% Add it to the node
    this.addNode(node);

    %% Expand the analysis nodes so the user sees the new result
    ExplorerFrame.expandNode(this.getTreeNodeInterface);

    %% Send update to tell the user that a node has been added
    ExplorerFrame.postText(sprintf(' - An operating point %s has been added to the node Operating Points.', Label))
end
