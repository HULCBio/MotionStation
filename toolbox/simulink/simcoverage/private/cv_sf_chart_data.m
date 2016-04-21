function [fullNames,widths,numbers,ids] = cv_sf_chart_data(chartId)
%CV_SF_CHART_DATA - Get information used to report signal
%                   range coverage for stateflow

% Copyright 2003 The MathWorks, Inc.

    % DataOf returns the objects in a well sorted
    % format sorted by scope/parent/name
    chartDataIds = sf('DataOf',chartId);
    dataCnt = length(chartDataIds);
    
    fullNames = cell(dataCnt, 1);
    [baseNames, parents, numbers] = sf('get',chartDataIds ...
                                        ,'data.name' ...
                                        ,'data.linkNode.parent' ...
                                        ,'data.number');
    
    if all(numbers==0)
        machineId = sf('get',chartId,'chart.machine');
        sf('Private','autobuild',machineId,'sfun','parse','no','no',chartId);
        numbers = sf('get',chartDataIds,'data.number');
    end
    
    
    widths = ones(dataCnt, 1);
    % quick and dirty for loop for fullNames
    for i=1:dataCnt
        if (parents(i)==chartId)
            fullNames{i} = deblank(baseNames(i,baseNames(i,:)~=0));
        else
            fullNames{i} = sf('FullNameOf',chartDataIds(i),'.',chartId);
        end
    end

	ids = chartDataIds;