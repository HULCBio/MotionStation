function chaos2das
    % get the Stateflow root object

    sfr = Stateflow.Root;

    % get a list of charts
    charts = sfr.find('-isa', 'Stateflow.Chart');

    % loop through the charts
    for i = 1:length(charts)
        chart = charts(i);

        % get the block for this chart
        block = get_param(sf('Private', 'chart2block', chart.id), 'uddobject');

        % save the connections
        left = block.left;
        right = block.right;

        % disconnect the block
        block.disconnect;

        % connect the chart
        if (~isempty(left))
            chart.connect(left, 'left')
        end
        if (~isempty(right))
            chart.connect(right, 'right')
        end
    end

    % get a list of models
    models = listModels;

    % connect the models to the workspace
    workspace = getDAWorkspace;
    for i = 1:length(models)
        models(i).connect(workspace, 'up');
    end

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:58 $
