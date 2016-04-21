function result = is_truth_table_chart(chartId)

% Copyright 2003 The MathWorks, Inc.

    result = ~isempty(sf('find', chartId, 'chart.type', 1));
