function [uniqueLinkMachines,uniqueLinkChartFileNumbers] = get_link_chart_file_numbers(machineName)
% [uniqueLinkMachines,uniqueLinkChartFileNumbers] = get_link_chart_file_numbers(machineName)
%
% This function is used by toolbox/rtw/sf_rtw.m for SF-RTW interface. It takes a main machine name
% and returns a cell array of link machines whose charts are in this main machine and for each 
% link machine, an array of relevant chart file numbers (i.e., for the charts that are used in the
% main machine)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.6.2.2 $  $Date: 2004/04/15 00:58:04 $

uniqueLinkMachines = {};
uniqueLinkChartFileNumbers = {};

if ~ischar(machineName)
   machineId = machineName;
   machineName = sf('get',machineId,'machine.name');
else
   machineId = sf('find','all','machine.name',machineName);
end

linkCharts = machine_bind_sflinks(machineId);

linkChartSfunctions = find_system(linkCharts,'LookUnderMasks','on','FollowLinks','On','BlockType','S-Function');


if(length(linkChartSfunctions)==1) 
   linkChartSfunTags{1} = get_param(linkChartSfunctions,'Tag');
else
   linkChartSfunTags = get_param(linkChartSfunctions,'Tag'); 
   linkChartSfunTags = unique(linkChartSfunTags);
end

linkMachines = cell(1,length(linkChartSfunTags));
linkChartFileNumbers = zeros(1,length(linkChartSfunTags));
headerLength = length('Stateflow S-Function');
for i=1:length(linkChartSfunTags)
   infoTag = linkChartSfunTags{i}(headerLength+2:end);
   firstSpace = find(infoTag==32);
   linkMachines{i} = infoTag(1:firstSpace-1);
   chartFileNumber = sscanf(infoTag(firstSpace+1:end),'%d');
   if(isempty(chartFileNumber))
      error(['Please run sfconv20 in this directory containing ',linkMachines{i},' to convert all old ', ...
            'library models.']);
   end
   linkChartFileNumbers(i) = chartFileNumber;
end

[uniqueLinkMachines,index1,index2] = unique(linkMachines);

for i=1:length(uniqueLinkMachines)
   uniqueLinkChartFileNumbers{i} = linkChartFileNumbers(find(index2==i));
end


