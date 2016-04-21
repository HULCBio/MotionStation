function result = is_eml_chart(chartId)

% Copyright 2002 The MathWorks, Inc.

    result = ~isempty(sf('find', chartId, 'chart.type', 2));
