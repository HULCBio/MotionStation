function [fullname, shortname] = chart2name(chartId)
% Given a chart returns its name.
%
% If the chart is a library chart, returns the name of the active
% instance.
%

% Copyright 2004 The MathWorks, Inc.

activeInstance = sf('get',chartId,'.activeInstance');
if isequal(activeInstance,0) || ~ishandle(activeInstance)
  fullname = sf('FullNameOf',chartId, '.');
  shortname = sf('get',chartId,'.name');
else
  relevantHandle = activeInstance;

  machineId = actual_machine_referred_by(chartId);
  linkChartId = sf('find',sf('get',machineId,'.linkCharts'),'.handle',relevantHandle);
  
  if isempty(linkChartId)  
    linkChartId = get_param(relevantHandle,'userdata');
  end
  
  if isempty(linkChartId)
      linkChartId = chartId;
  end
  
  fullname = sf('FullNameOf',linkChartId,'.');
  shortname = get_param(relevantHandle,'name');
end

