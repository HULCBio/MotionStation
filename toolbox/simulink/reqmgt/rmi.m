function [varargout] = rmi(method, obj, varargin)
% RMI Requirements Management Interface API
%   RESULT = RMI(METHOD, OBJ) is the basic form of
%   all Requirements Management API calls.  METHOD is one of
%   the methods defined below.  OBJ is the handle of the
%   Simulink or Stateflow object.
%
%   RESULT = RMI('hasRequirements', OBJ) returns
%   true if OBJ is an object that has requirements.
%
%   RESULT = RMI('get', OBJ) returns
%   requirements associated with OBJ in a structural
%   form.  The format of RESULT is as follows:
%
%   RESULT.descriptions - Requirement descriptions.
%   RESULT.docs         - Document names.
%   RESULT.ids          - Locations within the above document.
%   RESULT.keywords     - Requirement keywords.
%   RESULT.linked       - True if requirement is linked.  All
%                         non-DOORS requirements are linked.
%   RESULT.reqsys       - Either 'doors' or 'other'
%
%   Each of the structure fields listed above is a cell array.
%   Data corresponding to the i'th requirement would be stored
%   in the i'th element of each of the above cell arrays.
%
%   RESULT = RMI('set', OBJ, REQS) sets the
%   requirements for OBJ to REQS.  See the help for 'get'
%   for the format of REQS.
%
%   RESULT = RMI('cat', OBJ, REQS) concatinate REQS to
%   requirements for OBJ.
%
%   RESULT = RMI('count', OBJ) returns number of OBJs requirements
%
%   RMI('clearall', OBJ) deletes all requirements for OBJ.
%
%   RESULT = RMI('view', OBJ, INDEX) navigate to
%   the INDEX'th requirement of OBJ.
%
%   RESULT = RMI('edit', OBJ) open editor for
%   OBJ's requirements.  Other forms of the 'edit'
%   method are as follows:
%
%       RESULT = RMI('edit', OBJ, INDEX) will
%       open the editor with the INDEX'th requirement
%       selected.  "index" can be [].
%
%       RESULT = RMI('edit', OBJ, ACTIVEINDEX, BASEINDEX, COUNT)
%       will open the editor only showing COUNT requirements
%       starting at BASEINDEX.
%
%   RESULT = RMI('highlightModel', OBJ) highlights
%   objects in the model that have requirements
%
%   RESULT = RMI('unhighlightModel', OBJ) removes
%   highlighting  of requirements.
%
%   RESULT = RMI('descriptions', OBJ, indices) returns
%   array of requirement descriptions for the specified indices.

% Copyright 2003-2004 The MathWorks, Inc.


	% Cache variable arguement size
	nvarargin = length(varargin);

	switch(lower(method))
	case 'ishandlevalid'
		varargout{1} = isValidHandle(obj);

	case 'getmodelh'
		varargout{1} = getModelH(obj);

	case 'isrequirementsobject'
		varargout{1} = isValidReqObj(obj);

	case 'hasrequirements'
		varargout{1} = objHasReqs(obj);

	case 'get'

		switch nvarargin
		case 0
			index = -1;
			count = -1;
		case 2
			index = varargin{1};
			count = varargin{2};
		otherwise
			error('Invalid number of arguments ');
		end;

		% Get requirements
		varargout{1} = getReqs(obj, index, count);

	case 'set'

		switch nvarargin
		case 1
			reqs  = varargin{1};
			index = -1;
			count = -1;
		case 3
			reqs  = varargin{1};
			index = varargin{2};
			count = varargin{3};
		otherwise
			error('Invalid number of arguments ');
		end;

		% Set requirements
		setReqs(obj, reqs, index, count);

	case 'cat'

		switch nvarargin
		case 1
			reqs = varargin{1};
		otherwise
			error('Invalid number of arguments ');
		end;

		% Append requirements
		varargout{1} = catReqs(obj, reqs);

	case 'catempty'

		switch nvarargin
		case 0
			count = 1;
		case 1
			count = varargin{1};
		otherwise
			error('Invalid number of arguments ');
		end;

		% Append empty requirements
		varargout{1} = catEmptyReqs(obj, count);

	case 'createempty'

		switch nvarargin
		case 0
			count = 1;
		case 1
			count = varargin{1};
		otherwise
			error('Invalid number of arguments ');
		end;

		% Append empty requirements
		varargout{1} = createEmptyReqs(count);

	case 'clearall'

		% Delete all requirements
		clearAll(obj);

	case 'delete'

		switch nvarargin
		case 2
			index = varargin{1};
			count = varargin{2};
		otherwise
			error('Invalid number of arguments ');
		end;

		% Delete
		deleteReqs(obj, (index-1) + 1:count);

	case 'view'

		switch nvarargin
		case 0
			% Get requirements
			reqs = rmi('get', obj);

			% If more than 1 requirement, bring up editor
			if length(reqs.docs) > 1
				rmi('edit', obj);

			% If exactly 1 requirement, navigate
			elseif length(reqs.docs) == 1
				navigateToReq(obj, 1);
			end;

		case 1
			% Get index of requirement
			reqIndex = varargin{1};

			% Navigate to requirement
			navigateToReq(obj, reqIndex);

		otherwise
			error('Invalid number of arguments ');
		end;

	case 'edit'

		switch nvarargin
		case 0
			activeIndex = -1;
			index       = -1;
			count       = -1;
		case 1
			activeIndex = varargin{1};
			index       = -1;
			count       = -1;
		case 3
			activeIndex = varargin{1};
			index       = varargin{2};
			count       = varargin{3};
		otherwise
			error('Invalid number of arguments ');
		end;

		% Edit requirements
		varargout{1} = editReqs(obj, activeIndex, index, count);

	case 'descriptions'

		switch nvarargin
		case 0
			index = -1;
			count = -1;
		case 2
			index = varargin{1};
			count = varargin{2};
		otherwise
			error('Invalid number of arguments ');
		end;

		% Return description strings
		varargout{1} = getDescStrings(obj, index, count);

	case 'codecomment'

		% Return comment string
		varargout{1} = getCommentString(obj);

	case 'highlightmodel'
		highlightModel(obj);

	case 'unhighlightmodel'
		unhighlightModel(obj);

	case 'permute'

		switch nvarargin
		case 1
			indices = varargin{1};
		otherwise
			error('Invalid number of arguments ');
		end;

		% Return permutation
		varargout{1} = permuteReqs(obj, indices);

	case 'count'
		varargout{1} = countReqs(obj);
	case 'doorsinstalled'
		varargout{1} = doorsInstalled();
	case 'doorssync'
		doorssync(obj);
	case 'doorsid'

		switch nvarargin
		case 0
			index = -1;
		case 1
			index = varargin{1};
		end;

		varargout{1} = doorsID(obj, index);
	case 'navsl2doors'

		switch nvarargin
		case 0
			index = -1;
		case 1
			index = varargin{1};
		end;

		NavigateToDoors(obj, index);
	case 'navdoors2sl'
		navdoors2sl(obj);
	case 'report'
		reqReport();
	otherwise
		error('Unknown Method');
	end;


function result = tryGetReq(req, colIndex, default)

	[rowCount, colCount] = size(req);

	if colIndex > colCount
		if ~isempty(default)
			result = default;
		else
			result = {''};
		end;
	else
		result = req(colIndex);
	end;


function result = parseReqs(reqs)

	if length(reqs) > 0
		reqs = eval(reqs);
	else
		reqs = {};
	end;

	% Initialize cell array
	result = {};

	% Populate cell array
	[rowCount, colCount] = size(reqs);
	for i = 1:rowCount
		% Get ith requirement
		req = reqs(i, :);

		% Get what is available in string form
		result.reqsys(i)       = tryGetReq(req, 1, {'other'});
		result.docs(i)         = tryGetReq(req, 2, {});
		result.ids(i)          = tryGetReq(req, 3, {});
		result.linked(i)       = tryGetReq(req, 4, {});
		result.descriptions(i) = tryGetReq(req, 5, result.ids(i));
		result.keywords(i)     = tryGetReq(req, 6, {});

		% Convert string data to appropriate data type
		result.linked{i} = str2bool(result.linked(i));
	end;


function result = filterReqs(reqs, index, count)

	if index ~= -1
		% Compute filter
		reqFilter = resolveFilter(index, count);

		% Get vector of requirement indices
		allIndices = 1 : length(reqs.docs);

		% Filter
		indices = setdiff(allIndices, reqFilter);

		% Remove filtered indices
		reqs = deleteReqsPrim(reqs, indices);
	end;

	result = reqs;


function result = resolveFilter(index, count)

	result = index : (index + count - 1);


function result = getReqs(obj, index, count)

	% Get raw unfiltered requirements
	reqs = getRawReqs(obj);

	% Parse raw string into requirements
	reqs = parseReqs(reqs);

	% Filter out unwanted requirements
	reqs = filterReqs(reqs, index, count);

	result = reqs;


function result = reqs2str(reqs);

	% Package requirements into cell array
	ca = {};
	if length(reqs) > 0
		for i = 1:length(reqs.docs);
			ca{i, 1} = escapeString(reqs.reqsys{i});
			ca{i, 2} = escapeString(reqs.docs{i});
			ca{i, 3} = escapeString(reqs.ids{i});
			ca{i, 4} = bool2str(reqs.linked{i});
			ca{i, 5} = escapeString(reqs.descriptions{i});
			ca{i, 6} = escapeString(reqs.keywords{i});
		end;
	end;

	% Convert into string - derived from reqgetstr.m
	s = '{';
	[r,c] = size(ca);
	for i = 1:r
		for j = 1:c
			s = [s '''' ca{i, j} '''' ' '];
		end % for j = 1:c
		if (i < r), s = [s, '; '];, end
	end % for i = 1:r
	s = [s '}'];

	% Don't write empty cell, just write nothing
	if strcmp(s, '{}')
		s = '';
	end;

	result = s;

function result = escapeString(inStr)

	% Double up single quotes
	result = strrep(inStr, '''', '''''');


function result = cellArrayInsert(ca1, ca2, insertPoint)

	% Insert ca2 into ca1 at insertPoint
	result = [ca1(1 : insertPoint - 1) ca2 ca1(insertPoint : length(ca1))];


function result = insertReqsPrim(reqs, insertReqs, insertPoint)

	if isempty(reqs)
		result = insertReqs;
	else
		result.docs         = cellArrayInsert(reqs.docs,         insertReqs.docs,         insertPoint);
		result.ids          = cellArrayInsert(reqs.ids,          insertReqs.ids,          insertPoint);
		result.linked       = cellArrayInsert(reqs.linked,       insertReqs.linked,       insertPoint);
		result.descriptions = cellArrayInsert(reqs.descriptions, insertReqs.descriptions, insertPoint);
		result.keywords     = cellArrayInsert(reqs.keywords,     insertReqs.keywords,     insertPoint);
		result.reqsys       = cellArrayInsert(reqs.reqsys,       insertReqs.reqsys,       insertPoint);
	end;


function result = catReqsPrim(reqs, catReqs)

	if isempty(catReqs)
		result = reqs;
	elseif isempty(reqs)
		result = catReqs;
	else
		result.docs         = {reqs.docs{:}         catReqs.docs{:}};
		result.ids          = {reqs.ids{:}          catReqs.ids{:}};
		result.linked       = {reqs.linked{:}       catReqs.linked{:}};
		result.descriptions = {reqs.descriptions{:} catReqs.descriptions{:}};
		result.keywords     = {reqs.keywords{:}     catReqs.keywords{:}};
		result.reqsys       = {reqs.reqsys{:}       catReqs.reqsys{:}};
	end;


function setReqs(obj, reqs, index, count)

	if index ~= -1
		% Get all requirements
		allReqs = rmi('get', obj);

		% Compute filter
		reqFilter = resolveFilter(index, count);

		% Delete requirements indexed in filter
		allReqs = deleteReqsPrim(allReqs, reqFilter);

		% Insert requirements
		reqs = insertReqsPrim(allReqs, reqs, index);
	end;

	% Get raw req string
	reqstr = reqs2str(reqs);

	% Commit requirements
	setRawReqs(obj, reqstr);


function result = catReqs(obj, reqs)

	% Get existing requirements
	result = getReqs(obj, -1, -1);

	% Append
	result = catReqsPrim(result, reqs);

	% Commit
	setReqs(obj, result, -1, -1);


function result = catEmptyReqs(obj, count)

	emptyReqs = createEmptyReqs(count);
	result    = catReqs(obj, emptyReqs);


function result = createEmptyReqs(count)

	result   = {};
	emptyReq = createEmptyReq();

	for i = 1 : count
		result = catReqsPrim(result, emptyReq);
	end;


function result = createEmptyReq()

	result.docs         = {''};
	result.ids          = {''};
	result.linked       = {0};
	result.descriptions = {''};
	result.keywords     = {''};
	result.reqsys       = {'other'};


function validateIndices(reqs, indices)

	if ~isempty(indices) && (max(indices) > length(reqs.docs))
		error('Bad indices');
	end;


function deleteReqs(obj, indices)

	% Get requirements
	reqs = rmi('get', obj);

	% Delete specified requirements
	reqs = deleteReqsPrim(reqs, indices);

	% Set back requirements
	rmi('set', obj, reqs);


function result = clearAll(objs)

	% Is this a vector operation?
	len = length(objs);

	% Prepare dialog strings
	dialogTitle = 'Delete all';
	if len > 1
		confirmMessage = sprintf('Delete all requirements for %d selected objects?', len);
	else
		confirmMessage = 'Delete all requirements for selected object?';
	end;

	% Confirm
	result = questdlg(confirmMessage, dialogTitle, 'Ok', 'Cancel', 'Cancel');
	result = strcmp(result, 'Ok');

	% Delete all requirements for all objects
	if result
		for i = 1 : len
			% Delete all requirements
			setReqs(objs(i), {}, -1, -1);
		end;
	end;


function result = deleteReqsPrim(reqs, indices)

	% Ensure indices are valid
	validateIndices(reqs, indices);

	% Delete requirements
	if ~isempty(indices)
		reqs.docs(indices)         = [];
		reqs.ids(indices)          = [];
		reqs.linked(indices)       = [];
		reqs.descriptions(indices) = [];
		reqs.keywords(indices)     = [];
		reqs.reqsys(indices)       = [];
	end;

	result = reqs;


function navigateToReq(obj, reqIndex)

	% Fetch requirements
	reqs = rmi('get', obj);

	% Get model handle
	modelH = rmi('getmodelh', obj);

	% Error check index
	if reqIndex > length(reqs.docs)
		error('Invalid requirement specified');
	end;

	% Navigate to requirement
	if isDOORSReq(reqs, reqIndex)
		NavigateToDoors(obj, reqIndex);
	else
		RMINavigateTo(modelH, reqs.docs{reqIndex}, reqs.ids{reqIndex});
	end;


function result = editReqs(obj, activeIndex, index, count)

	result = -1;

	% Is this a vector operation?
	len = length(obj);

	% If vector edit, gui is empty.
	% If scalar edit, prepopulate.
	if len > 1
		reqs   = {};
		source = '';
		handle = obj; % Assumed to be vector of handles
		result = RMIQuickNav('create', source, handle, reqs, -1, -1, -1);
	else
		reqs     = rmi('get', obj, index, count);
		[source, handle] = resolveObj(obj);

		% Is this DOORS requirement
		if ~isempty(reqs) && (length(reqs.docs) >= 1) && isDOORSReq(reqs, 1)
			NavigateToDoors(obj, index);

		% If not, show GUI
		else
			result = RMIQuickNav('create', source, handle, reqs, activeIndex, index, count);
		end;
	end;


function result = isDOORSReq(reqs, index);

	result = strcmp(reqs.reqsys{index}, 'doors');


function result = getDescStrings(obj, index, count)

	% Get reqs
	reqs = rmi('get', obj);

	% Filter requirements
	reqs = filterReqs(reqs, index, count);

	% Return array of decriptions
	if isempty(reqs)
		result = {};
	else
		result = reqs.descriptions;
	end;


function result = getCommentString(obj)

	% Get descriptions
	descriptions = rmi('descriptions', obj);

	% Cat into string
	for i = 1 : length(descriptions)
		if i == 1
			result = sprintf('*  %d. %s', i, descriptions{i});
		else
			result = sprintf('%s\n*  %d. %s', result, i, descriptions{i});
		end;
	end;


function sfHighlight(sfHs, modelName)

	% Compute colors to use
	reqFGColor = [0.9 0 0];      % red
	reqBGColor = 0.92 * [1 1 1]; % gray

	% Create new style
	style = sf('new', 'style');
	sf('set', style,...
	         'style.name',           'requirements',...
	         'style.blockEdgeColor', reqFGColor,...
	         'style.wireColor',      reqFGColor,...
	         'style.fontColor',      reqFGColor,...
	         'style.bgColor',        reqBGColor);

	% Assign style to every object that has a requirement
	for i = 1 : length(sfHs)
		if rmi('hasRequirements', sfHs(i))
			sf('set', sfHs(i), '.altStyle', style);
		end;
	end;

	% Redraw every chart in this machine
	machine = find(sfroot, '-isa', 'Stateflow.Machine', '-and', 'Name', modelName);
	if ~isempty(machine)
		machineID = machine.id;
		sf('Redraw', machineID);
	end;


function sfUnhighlight(modelName)

	% Is Stateflow present?
	machine = find(sfroot, '-isa', 'Stateflow.Machine', '-and', 'Name', modelName);
	if ~isempty(machine)
		machineID = machine.id;

		% Clear style and redraw
		sf('ClearAltStyles', machineID);
		sf('Redraw', machineID);
	end;


function [slHs, sfHs] = getHandlesWithRequirements(obj)

	% Get root model 
	modelH = rmi('getModelH', obj);

	% Get list of all Simulink and Stateflow handles that could have requirements
	modelObj = find(slroot,   '-isa', 'Simulink.BlockDiagram', '-and', 'Handle', modelH);
	slObjs   = find(modelObj,        '-isa', 'Simulink.BlockDiagram',...
							  '-or', '-isa', 'Simulink.Block');
	sfObjs   = find(modelObj,        '-isa', 'Stateflow.Transition',...
							  '-or', '-isa', 'Stateflow.State',...
							  '-or', '-isa', 'Stateflow.Chart');

	% Filter Simulink
	i = 1;
	while i <= length(slObjs)
		if ~rmi('hasRequirements', slObjs(i).Handle)
			slObjs(i) = [];
		else
			i = i + 1;
		end;
	end;

	% Filter Stateflow
	i = 1;
	while i <= length(sfObjs)
		if ~rmi('hasRequirements', sfObjs(i).Id)
			sfObjs(i) = [];
		else
			i = i + 1;
		end;
	end;

	% Objects within a Stateflow chart may have requirements, but
	% the parent block might not.  We still want to highlight the
	% parent block.
	sfObjsWithChart = find(sfObjs, '-property', 'Chart', '-depth', 0);
	sfChartObjs     = get(sfObjsWithChart, 'Chart');
	if iscell(sfChartObjs)
		sfChartObjs = cell2mat(sfChartObjs);
	end;
	sfChartIDs = get(sfChartObjs, 'id');
	if iscell(sfChartIDs)
		sfChartIDs = cell2mat(sfChartIDs);
	end;
	sfChartIDs    = unique(sfChartIDs);
	sfChartBlocks = sf('Private', 'chart2block', sfChartIDs);

	% Get handles
	slHs = get(slObjs, 'Handle');
	sfHs = get(sfObjs, 'Id');

	% Convert to matrices
	if iscell(slHs)
		slHs = cell2mat(slHs);
	end;
	if iscell(sfHs)
		sfHs = cell2mat(sfHs);
	end;

	% Uniquify handles
	slHs = unique([slHs' sfChartBlocks]);
	sfHs = unique(sfHs);


function result = highlightModel(obj)

	% Compute model name
	modelH    = rmi('getModelH', obj);
	modelName = get_param(modelH, 'Name');

	% Get handles
	[slHs, sfHs] = getHandlesWithRequirements(obj);

	% Highlight Simulink
	for i = 1 : length(slHs)
		set_param(slHs(i), 'HiliteAncestors', 'on');
	end;

	% Highlight Stateflow
	sfHighlight(sfHs, modelName);


function result = unhighlightModel(obj)

	% Compute model name
	modelH    = rmi('getModelH', obj);
	modelName = get_param(modelH, 'Name');

	% Get handles
	[slHs, sfHs] = getHandlesWithRequirements(obj);

	% Unhighlight Simulink
	for i = 1 : length(slHs)
		set_param(slHs(i), 'HiliteAncestors', 'off');
	end;

	% Unhighlight Stateflow
	sfUnhighlight(modelName)


function result = permuteReqs(obj, indices)

	% Get requirements
	reqs = rmi('get', obj);

	% Delete requirements
	reqs.docs         = reqs.docs(indices);
	reqs.ids          = reqs.ids(indices);
	reqs.linked       = reqs.linked(indices);
	reqs.descriptions = reqs.descriptions(indices);
	reqs.keywords     = reqs.keywords(indices);
	reqs.reqsys       = reqs.reqsys(indices);

	% Set back requirements
	rmi('set', obj, reqs);

	result = reqs;


function result = countReqs(obj);

	% Assume none
	result = 0;

	% Get requirements
	reqs = rmi('get', obj);

	if ~isempty(reqs)
		result = length(reqs.docs);
	end;

function result = doorsInstalled()

	result = is_doors_installed();


function doorssync(obj);

	modelH = rmi('getModelH', obj);
	sync_with_doors(modelH)


function result = doorsID(obj, index)

	% Assume no DOORS ID
	result = 'null';

	% Get all requirements
	reqs     = getReqs(obj, -1, -1);
	reqCount = countReqs(obj);

	% Resolve which requirement to look at
	indexUsed = 1;
	if index > 0
		indexUsed = index;
	end;

	% Get id
	strID = '';
	if ~isempty(reqs) && (reqCount >= indexUsed)
		strID = reqs.ids{indexUsed};
	end;

	% Is this a valid DOORS id, or did the user enter
	% something in this field?
	numericID = str2num(strID);
	if ~isempty(numericID)
		result = strID;
	end;


function navdoors2sl(obj)

	persistent lastSLBlock;

	% Remove prior highlighting
	if ishandle(lastSLBlock)
		set_param(lastSLBlock, 'HiliteAncestors', 'off');
		lastSLBlock = [];
	end;

	% Pull MATLAB to front of all windows.
	%showwindow('MATLAB', 'shownormal', 1);
	%showwindow('MATLAB Command Window', 'shownormal', 1);

	% Is this a Simulink block?
	handle = rmiSLPath2Handle(obj);
	if ishandle(handle)
		parent = get_param(handle, 'Parent');
		if ~isempty(parent)
			open_system(parent, 'force');
			set_param(handle, 'HiliteAncestors', 'on');
			lastSLBlock = handle;
		end;
	end;

	% Is this a Stateflow object?
	handle = rmiSFPath2Handle(obj);
	if sf('ishandle', handle)
		sf('Open', handle);
	end;

	% Is this a signal builder tab?
	[handle, groupIndex] = rmi_sigbuilder_path_2_handle(obj);
	if ishandle(handle) && (groupIndex >= 1)
		parent = get_param(handle, 'Parent');
		if ~isempty(parent)
			open_system(parent, 'force');
			set_param(handle, 'HiliteAncestors', 'on');
			lastSLBlock = handle;

			% Open sigbuilder to right tab
			navigate_2_sigbuilder(handle, groupIndex);
		end;
	end;


function reqReport()

	% Generate HTML report and get location
	loc = rptgen.report('private/rmi');

	hideBrowser = 1;
	try
		prevLastErr = lasterr;
		hideBrowser = evalin('base', 'BAT_REQMGT_TESTING');
	catch
		lasterr(prevLastErr);
		hideBrowser = 0;
	end

	% View report in browser
	if ~hideBrowser
		web(['file:/' cell2mat(loc)]);
	end;


function result = getModelH(obj)

	% Get source type and handle
	[source, handle] = resolveObj(obj);

	% Return model handle
	switch source
	case 'simulink',  result = slGetModelH(obj);
	case 'stateflow', result = sfGetModelH(obj);
	end;


function result = slGetModelH(handle)

	result = get_param(bdroot(handle), 'Handle');


function result = sfGetModelH(handle)

	result = get_param(bdroot(sf('Private', 'chart2block', sf('get', handle, '.chart'))), 'handle');


function [source, handle] = resolveObj(obj)

	source = '';
	handle = -1;

	% Is Simulink UDD object?
	if slIsValidReqUDDObj(obj)
		source = 'simulink';
		handle = obj.handle;

	% Is Stateflow UDD object?
	elseif sfIsValidReqUDDObj(obj)
		source = 'stateflow';
		handle = obj.Id;

	% Is Simulink handle?
	elseif slIsValidHandle(obj) && slIsValidReqHandle(obj)
		source = 'simulink';
		handle = obj;

	% Is Stateflow handle?
	elseif sfIsValidHandle(obj) && sfIsValidReqHandle(obj)
		source = 'stateflow';
		handle = obj;

	% Is Simulink path
	else
		try
			source = 'simulink';
			handle = get_param(obj, 'Handle');
		catch
			source = '';
			handle = -1;
		end;
	end;

	if handle == -1
		obj
		error('Cannot resolve this object');
	end;


function result = objHasReqs(obj)

	result = 0;

	if isValidReqObj(obj)
		% Get requirements
		reqs = rmi('get', obj);

		% In the case of DOORS it is not enough to simply see if there
		% are any requirements.  We must also determine if linked.
		% This must return a logical scalar for model explorer.
		if ~isempty(reqs)
			result = reqs.linked{1} == 1;
		end;
	end;


function result = slObjHasReq(obj)

	result = 0;

	if slIsReqObject(obj)
		result = ~isempty(slGetRawReqs(obj));
	end;


function result = sfObjHasReq(obj)

	result = 0;

	if sfIsReqObject(obj)
		result = ~isempty(sfGetRawReqs(obj));
	end;


function result = isValidReqObj(obj)

	result = isValidReqUDDObj(obj) || isValidReqHandle(obj) || slIsValidReqPath(obj);


function result = slIsValidReqPath(path)

	result = ~isempty(find_system(path, 'SearchDepth', 0));


function result = isValidReqUDDObj(obj)

	result =    slIsValidReqUDDObj(obj) || sfIsValidReqUDDObj(obj);


function result = slIsValidReqUDDObj(obj)

	result =    isa(obj, 'Simulink.BlockDiagram') || isa(obj, 'Simulink.Block');


function result = sfIsValidReqUDDObj(obj)

	result =    isa(obj, 'Stateflow.Chart')...
	         || isa(obj, 'Stateflow.State')...
	         || isa(obj, 'Stateflow.Transition')...
	         || isa(obj, 'Stateflow.TruthTable')...
	         || isa(obj, 'Stateflow.Function')...
	         || isa(obj, 'Stateflow.EmlFunction');


function result = isValidReqHandle(handle)

	result = slIsValidReqHandle(handle) || sfIsValidReqHandle(handle);


function result = slIsValidReqHandle(handle)

	result  = 0;
	objType = '';

	try
		type = get_param(handle, 'type');
	catch
		type = '';
	end;

	result = strcmp(type, 'block') || strcmp(type, 'block_diagram');


function result = sfIsValidReqHandle(handle)

	result = 0;

	% Get isa enums
	[chartIsa, stateIsa, transition.isa] = sf('get', 'default',...
											  'chart.isa',...
											  'state.isa',...
											  'transition.isa');

	% Get isa for this object
	objIsa = sf('get', handle, '.isa');

	% True for these types of objects
	switch objIsa
		case {chartIsa, stateIsa, transition.isa}
		result = 1;
	end;


function result = isValidHandle(handle)

	result = slIsValidHandle(handle) || sfIsValidHandle(handle);


function result = slIsValidHandle(handle)

	result = strcmp(class(handle), 'double') && ishandle(handle);


function result = sfIsValidHandle(handle)

	result = strcmp(class(handle), 'double') && (handle == floor(handle)) && sf('ishandle', handle);


function result = getRawReqs(obj)

	% Get source type and handle
	[source, handle] = resolveObj(obj);

	% Get raw requirements
	switch source
	case 'simulink',  result = slGetRawReqs(handle);
	case 'stateflow', result = sfGetRawReqs(handle);
	end;


function result = slGetRawReqs(handle)

	result = get_param(handle, 'requirementInfo');


function result = sfGetRawReqs(handle)

	result = sf('get', handle, '.requirementInfo');


function setRawReqs(obj, reqs)

	% Get source type and handle
	[source, handle] = resolveObj(obj);

	% Set raw requirements
	switch source
	case 'simulink',  slSetRawReqs(handle, reqs);
	case 'stateflow', sfSetRawReqs(handle, reqs);
	end;


function slSetRawReqs(handle, reqs)

	set_param(handle, 'requirementInfo', reqs);


function sfSetRawReqs(handle, reqs)

	sf('set', handle, '.requirementInfo', reqs);
