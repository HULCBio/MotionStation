function plotBlockLinearization(this)
%% Plot a block linearization.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.

import java.lang.*;

%% Get a handle to the singleton linearization inspector Java Panel
LinearizationInspectPanel = com.mathworks.toolbox.slcontrol.LinearizationInspector.InspectorPanel.getInstance;

%% Get the selected system index
idx = LinearizationInspectPanel.getSystemListBox.getSelectedIndex;

if (idx==-1)
    errordlg('Please select a block to plot.','Simulink Control Design')
else
    %% Get the plot type combo box
    PlotTypeComboBox = LinearizationInspectPanel.getPlotTypeComboBox;

    %% Get the plot type
    switch lower(PlotTypeComboBox.getSelectedItem)
        case 'step response plot'
            LtiPlotType = 'step';
        case 'bode magnitude plot'
            LtiPlotType = 'bodemag';
        case 'bode response plot'
            LtiPlotType = 'bode';
        case 'nichols plot'
            LtiPlotType = 'nichols';
        case 'nyquist plot'
            LtiPlotType = 'nyquist';
        case 'singular value plot'
            LtiPlotType = 'sigma';
        case 'pole zero map'
            LtiPlotType = 'pzmap';
        case 'io pole zero map'
            LtiPlotType = 'iopzmap';
        otherwise
            LtiPlotType = 'impulse';
    end

    %% Get the linear model
    block = this.Blocks(idx+1);

    if strcmp(block.InLinearizationPath,'Yes')
        %% Create an ltiviewer if needed
        Tag = sprintf('LTIView%s',block.FullBlockName);
        Viewer = findall(0,'Tag',Tag);

        if ~any(block.SampleTimes) || isempty(block.SampleTimes)
            sys = ss(block.A,block.B,block.C,block.D);
        else
            sys = ss(block.A,block.B,block.C,block.D,block.SampleTimes(1));
        end

        %% Plot the result
        if isempty(Viewer)
            [Viewer,vh] = ltiview(LtiPlotType);
            vh.importsys(sprintf('%s_Linearization_1',block.FullBlockName),sys);
            set(Viewer,'Tag',Tag);
        else
            vh = get(Viewer,'UserData');
            %% Get the current available views and add a new view if needed
            currentviews = get(vh.getCurrentViews,{'Tag'});
            if ~any(strcmp(currentviews,LtiPlotType))
                currentviews = {LtiPlotType};
                vh.setCurrentViews(currentviews);
            end
            nsystems = length(vh.Systems);
            vh.importsys(sprintf('%s_Linearization_%d',block.FullBlockName,nsystems+1),sys);
        end
    else
        errordlg('Please select a block that is in the linearization path.',...
                    'Simulink Control Design')
    end
end