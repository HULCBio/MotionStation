function result = rmiSFPath2Handle(sfPathName)

% Copyright 2004 The MathWorks, Inc.

	% Assume path invalid
	result = -1;

	% Try to resolve as a state
	sfObj = resolveState(sfPathName);

	% If not state, try to resolve as transition
	if isempty(sfObj)
		sfObj = resolveTransition(sfPathName);
	end;

	% If object resolved, return respective ID
	if ~isempty(sfObj)
		result = sfObj.Id;
	end;


function result = resolveTransition(transPath)

	% Assume transition invalid
	result = -1;

	% Extract label string.  1st get '<label str> from "' then filter out ' from "'
	labelStr = regexp(transPath, '.*?from \"', 'match', 'once');
	labelStr = strrep(labelStr, ' from "', '');

	% Extract 'from "<obj>"' and 'to "<obj>"' strings
	fromStr = regexp(transPath, 'from \".*?\"', 'match', 'once');
	toStr   = regexp(transPath, 'to \".*?\"',   'match', 'once');

	% Extract obj from "from" and "to" strings, 1st quoted, then unquoted
	fromStr = regexp(fromStr,      '\".*?\"', 'match', 'once');
	toStr   = regexp(toStr,        '\".*?\"', 'match', 'once');	
	fromStr = strrep(fromStr, '"', '');
	toStr   = strrep(toStr,   '"', '');

	% Try to resolve src and dst as states 
	fromObj = resolveState(fromStr);
	toObj   = resolveState(toStr);

	% Resolve objects to IDs
	fromID = -1;
	toID   = -1;
	if ~isempty(fromObj)
		fromID = fromObj.Id;
	end;
	if ~isempty(toObj)
		toID = toObj.Id;
	end;

	% Try to resolve which chart
	resolvedChart = [];
	if ~isempty(fromObj)
		resolvedChart = fromObj.Chart;
	elseif ~isempty(toObj)
		resolvedChart = toObj.Chart;
	end;

	% Where to search from
	if isempty(resolvedChart)
		searchRoot = sfroot;
	else
		searchRoot = resolvedChart;
	end;

	% Find transition
	func   = @(obj) transFindFunc(obj, labelStr, fromID, toID);
	result = find(searchRoot, '-isa','Stateflow.Transition', '-and', '-function', func);


function result = transFindFunc(obj, labelStr, fromID, toID)

	% Assume transition disconnected
	objFromID = -1;
	objToID   = -1;

	% Get IDs of source and destination, if available
	if ~isempty(obj.Source) && ~isa(obj.Source, 'Stateflow.Junction')
		objFromID = obj.Source.Id;
	end;
	if ~isempty(obj.Destination) && ~isa(obj.Destination, 'Stateflow.Junction')
		objToID = obj.Destination.Id;
	end;

	% Get label string
	objLabelStr = strrep(obj.LabelString, char(10), ' ');

	% Determine if source and destinations match.
	% NOTE: If transition is disconnected the respective
	%       "from" or "to" id will be -1.
	% NOTE: If incident to junction, respective endpoint
	%       will be -1.
	fromMatch  = objFromID == fromID;
	toMatch    = objToID   == toID;
	labelMatch = strcmp(objLabelStr, labelStr);

	result = fromMatch && toMatch && labelMatch;


function result = resolveState(statePath)

	% Assume not found
	result = [];

	% Get Stateflow root
	rt = sfroot;

	% Get Stateflow machine for this model
	[sfMachineName] = strtok(statePath, '/');
	sfMachine = rt.find('-isa', 'Stateflow.Machine', '-and', 'Name', sfMachineName);
	if isempty(sfMachine)
		return;
	end;

	% Resolve chart object.
	% If full path to Stateflow chart is the prefix of our
	% state path, then we have found the chart in question.
	sfCharts      = sfMachine.find('-isa', 'Stateflow.Chart');
	resolvedChart = [];
	i             = 1;
	while isempty(resolvedChart) && (i <= length(sfCharts))
		if strfind(statePath, sfCharts(i).getFullName) == 1
			resolvedChart = sfCharts(i);
		else
			i = i + 1;
		end;
	end;

	% If we can't find the chart, the state path is invalid
	if isempty(resolvedChart)
		return;
	end;

	func   = @(obj) (strcmp(obj.getFullName, statePath));
	result = resolvedChart.find('-function', func);

