function result = is_sf_fixpt_autoscale(model)

% Copyright 2003 The MathWorks, Inc.

result = 0;

% Don't call sfroot (and thus load Stateflow), unless we are sure model has Stateflow block
if model_contains_stateflow(model)
	rt      = sfroot;
	machine = rt.find('-isa', 'Stateflow.Machine', '-and', 'Name', model);
	if ~isempty(machine)
	
		% Get Stateflow blocks
		chartsObjs = machine.findDeep('Chart');
		chartIds   = [];
		for i = 1:length(chartsObjs)
			chartIds = [chartIds chartsObjs(i).Id];
		end;
		blocks = sf('Private', 'chart2block', chartIds);
	
		% Get compiled fixpt autoscale log setting
		logs = get_param(blocks, 'MinMaxOverflowLogging_Compiled');
	
		% Determine if any block should be logged
		isMinMaxOver = strcmp(logs, 'MinMaxAndOverflow');
		isOverOnly   = strcmp(logs, 'OverflowOnly');
		result       = any([isMinMaxOver isOverOnly]);
	end;
end;

function result = model_contains_stateflow(model)

	% NOTE: Do not recurse into library blocks as we are not
	%       interested in logging them.  That is the only thing
	%       that allows us to do this.
	result = ~isempty(find_system(model, 'LookUnderMasks', 'all', 'MaskType', 'Stateflow'));