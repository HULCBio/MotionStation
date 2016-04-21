function [uniqueWkspDataNames,wkspData,II,JJ] = get_wksp_data_names_for_chart(chartId)
% names of the data in the chart that are
% init from wksp. this list is uniquified so there
% are no duplicates. for every data init from wksp
% we set its .paramIndex property to the index
% in this uniquified list (zeo-based indexing)

% Copyright 2002 The MathWorks, Inc.

wkspData = get_wksp_data_for_chart(chartId);
wkspDataNames = cell(1,length(wkspData));
for i=1:length(wkspData)
    wkspDataNames{i} = sf('get',wkspData(i),'data.name');
end
[uniqueWkspDataNames,II,JJ] = unique(wkspDataNames);
paramIndices = (JJ-1);
sf('set',wkspData,'data.paramIndex',paramIndices(:));



