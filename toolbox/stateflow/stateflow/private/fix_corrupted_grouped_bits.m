function fixed = fix_corrupted_grouped_bits(machineId)
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/15 00:57:48 $
% Fix for G94175
% Usage: fix_corrupted_grouped_bits(machineId)
% This function detects and fixes certain 
% model corruptions involving super transitions
% if the message displayed after running the script
% says it detected and fixed the corruptions, 
% then save, close and reopen the model before using it.
%

sf('flag','transition.isGrouped','save/show/write');
fixed = 0;
charts = sf('get',machineId,'machine.charts');
modelName = sf('get',machineId,'machine.name');
for i=1:length(charts)
	chart = charts(i);
	%if(sf('get',chart,'chart.visible')==0)
		%sf('Open',chart);
		%sf('set',chart,'chart.visible',0);
    %end
	transitions = sf('get',chart,'chart.transitions');
	groupedSuperTrans = sf('find',transitions,'transition.isGrouped',1);
	for j = 1:length(groupedSuperTrans)
		t = groupedSuperTrans(j);
		if(~is_grouped(t))
			sf('set',t,'.isGrouped',0);
			fixed = 1;
		end
	end
end
if(fixed)
	disp(sprintf('Warning: Detected and fixed corrupted grouped super transitions'))
	disp(sprintf('         in model %s. Please resave this model immediately,',modelName));
	disp(sprintf('         close and reopen the model before using it.'));
end


function isGrouped = is_grouped(t)

parent = sf('get',t,'.linkNode.parent');
isGrouped = 0;

if(~isempty(sf('get',parent,'chart.id')))
	isGrouped = 0;
	return;
end

if(sf('get',parent,'.isGrouped'))
	isGrouped = 1;
	return;
end

if(~isempty(sf('find',parent,'.superState','GROUPED')))
	isGrouped = 1;
	return;
end

if(~isempty(sf('find',parent,'.superState','SUBCHART')))
	if(sf('get',parent,'.subgrouped'))
		isGrouped = 1;
		return;
	end
end


