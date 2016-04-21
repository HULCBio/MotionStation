function result = is_sf_chart(chartId)

% Copyright 2002 The MathWorks, Inc.

    result = ~isempty(sf('find', chartId, 'chart.type', 0));
