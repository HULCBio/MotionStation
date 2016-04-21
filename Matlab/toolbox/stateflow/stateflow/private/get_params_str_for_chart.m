function str = get_params_str_for_chart(chartId)
% This function is called from instance.c
% this returns a string which is
% comma separated list of names of data that belong
% to this chart and are init from wksp.
% the string returned is set as Parameters property
% of the sfunction block under neath the chart mask
% the string does not contain duplicates.

% Copyright 2002 The MathWorks, Inc.

str = '';
wkspDataNames = get_wksp_data_names_for_chart(chartId);
if(length(wkspDataNames)>0)
    str = wkspDataNames{1};
    if(length(wkspDataNames)>1)
        str = [str,sprintf(',%s',wkspDataNames{2:end})];
    end
end
