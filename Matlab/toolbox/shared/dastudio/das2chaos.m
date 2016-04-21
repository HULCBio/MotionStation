function das2chaos
    % get a list of models

    models = listModels;

    % get a list of charts
    charts = models.find('-isa', 'Stateflow.Chart');

    % loop through the charts
    for i = 1:length(charts)
        chart = charts(i);

        % get the block for this chart
        block = get_param(sf('Private', 'chart2block', chart.id), 'uddobject');

        % save the connections
        left = chart.left;
        right = chart.right;

        % attach the chart to it's machine
        chart.connect(chart.machine, 'up');

        % connect the block
        if (~isempty(left))
            block.connect(left, 'left')
        end
        if (~isempty(right))
            block.connect(right, 'right')
        end
    end

    % disconnect the workspace
    for i = 1:length(models)
        models(i).disconnect;
    end


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:03 $
