function isSfChartBlock = is_sf_chart_block(blockH)

% Copyright 2002 The MathWorks, Inc.

isSfChartBlock =0;
chartId = block2chart(blockH);
if(~isempty(chartId))
    isSfChartBlock = is_sf_chart(chartId);
end
