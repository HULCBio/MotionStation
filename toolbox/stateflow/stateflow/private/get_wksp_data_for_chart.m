function wkspData = get_wksp_data_for_chart(chartId)
% returns all data in the chart that are
% init from workspace. Skip those that have ml datatype.
% These should not be registered as simulink params
% for two reasons: 1. these are used only for simulation
% 2. the init values for the ml vars can be any MATLAB 
% data, not just matrices allowed by Simulink.

% Copyright 2002-2003 The MathWorks, Inc.

allData = sf('DataIn',chartId);
wkspData = unique([sf('find',allData,'data.initFromWorkspace',1) sf('find',allData,'data.scope','PARAMETER_DATA')]);
wkspData = sf('find',wkspData,'~data.dataType','ml');