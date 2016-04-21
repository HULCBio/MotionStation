function sync_with_doors(modelH)

% Copyright 2004 The MathWorks, Inc.

	% Get DOORS COM object
	hDOORS = resolve_com_doors();

	% Start sync
	beginDOORSSync(hDOORS, modelH);

	% Sync model
	doorsSyncModel(modelH, hDOORS);

	% End sync
	endDOORSSync(hDOORS);


function doorsSyncModel(modelH, hDOORS)

	% Get list of all blocks
	allBlocks = find_system(modelH, 'LookUnderMasks', 'all');

	for blockIndex = 1 : length(allBlocks)

		block  = allBlocks(blockIndex);
		parent = get_param(block, 'Parent');

		% Don't sync child blocks of signal builder
		if ~is_signal_builder_block(parent)

			% Get sync info
			fullPath  = getfullname(block);
			shortName = get_param(block, 'Name');
			objType   = getSLObjType(block);
			level     = getSLObjLevel(fullPath);

			% If Stateflow add supported objects
			if is_stateflow_block(block)
				% Sync Stateflow block then chart
				doorsSyncItem(hDOORS, block, -1, fullPath, shortName, objType, level);
				doorsSyncStateflowChart(hDOORS, block, level);

			% If signal builder, add item per tab, but none for main block
			elseif is_signal_builder_block(block)
				doorsSyncSignalBuilder(hDOORS, block, level);

			else
				% Vanilla Simulink block
				doorsSyncItem(hDOORS, block, -1, fullPath, shortName, objType, level);
			end;
		end;
	end;


function beginDOORSSync(hDOORS, modelH)

	modelName = get_param(modelH, 'Name');
	hDOORS.runStr(['dmiSendObjectStart_("' modelName '");']);
	if ~isempty(hDOORS.Result)
		error(['DOORS application error:' hDOORS.Result]);
	end;


function endDOORSSync(hDOORS)

	hDOORS.runStr(['dmiSendObjectEnd_("' date '");']);
	if ~isempty(hDOORS.Result)
		error(['DOORS application error:' hDOORS.Result]);
	end;


function doorsSyncSignalBuilder(hDOORS, block, level)

	% Get signal builder group count
	[time, data, siglabels, grouplabels] = signalbuilder(block);
	groupCount = length(grouplabels);

	% Get count of requirements for each group
	reqsPerGroup = sigbuild_groupreqcnt(block);
	if isempty(reqsPerGroup)
		reqsPerGroup = zeros(1, groupCount);
	end;

	% Guarantee we have exactly one requirement per group
	for i = 1 : groupCount

		% If we don't have exactly one requirement
		if (reqsPerGroup(i) == 0) || (reqsPerGroup(i) > 1)
			% Create empty requirement
			emptyReq = rmi('createempty', 0);

			% If no requirements for group then insert.
			% If more than one requirement for group, replace
			% any existing requirements with empty requirement.
			rmi('set', block, emptyReq, i, reqsPerGroup(i));
		end;
	end;

	% Update count of requirements / group to 1
	newGroupReqCounts = ones(1, groupCount);
	vnv_panel_mgr('sbUpdateReq', block, [], [], newGroupReqCounts);

	for i = 1 : length(grouplabels);
		group     = grouplabels{i};
		fullPath  = [getfullname(block) '/' group];
		shortName = [get_param(block, 'name') ': ' group];
		objType   = 'Signal Group';

		doorsSyncItem(hDOORS, block, i, fullPath, shortName, objType, level);
	end;


function doorsSyncStateflowChart(hDOORS, block, level)

	% NOTE: Not performing Stateflow license check.  The
	%       fact that the model is loaded and has a Stateflow
	%       machine is evidence of a proper licence, possibly
	%       a demo license.

	% Get chart handle
	blockH  = get_param(block, 'Handle');
	chartID = sf('Private', 'block2chart', blockH);

	% Sync chart, recursing into substates
	doorsSyncStateflowChartRecursively(hDOORS, chartID, level + 1);


function doorsSyncStateflowChartRecursively(hDOORS, parentid, level)

	STATE_ISA      = sf('get', 'default', 'state.isa');
	TRANSITION_ISA = sf('get', 'default', 'transition.isa');

	children = [sf('AllSubstatesOf', parentid) sf('TransitionsOf', parentid)];
	for i = 1:length(children)
		% Cache object isa
		obj_isa = sf('get', children(i), '.isa');

		% Full name
		fullPath = rmsfnamefull(children(i));

		% Short name
		shortName = '';
		switch obj_isa
		case STATE_ISA
			shortName = sf('get', children(i), '.name');
		case TRANSITION_ISA
			shortName = sf('get', children(i), '.labelString');
		end;
		shortName = strrep(shortName, '/', '//');

		% Type
		objType = '';
		switch obj_isa
		case STATE_ISA
			objType = 'Stateflow State';
		case TRANSITION_ISA
			objType = 'Stateflow Transition';
		end;

		% Sync Stateflow object
		doorsSyncItem(hDOORS, children(i), -1, fullPath, shortName, objType, level);

		% Recurse for states
		if obj_isa == STATE_ISA
			doorsSyncStateflowChartRecursively(hDOORS, children(i), level + 1);
		end;
	end;


function doorsSyncItem(hDOORS,...    % DOORS COM object
                       obj,...       % Simulink/Stateflow object
                       reqIndex,...  % Which requirement to use for syncing
                       fullPath, shortName, objType, level)

	% Get persistent DOORS ID if exists, otherwise null
	id = ['"' rmi('doorsid', obj, reqIndex) '"'];

	% Escape quotes
	fullPath  = strrep(fullPath,  '"', '\"');
	shortName = strrep(shortName, '"', '\"');

	% In short name, no CRLFs
	shortName = strrep(shortName, char(10), ' ');

	% Convert level to string
	levelStr = sprintf('%d', level);

	% Form DOORS command
	commandArgs = [id ',"' fullPath '","' objType '",' levelStr ',"' shortName '"'];
	commandFunc = 'dmiSendObject_';
	command     = [commandFunc '(' commandArgs ');'];

	% Execute command
	hDOORS.runStr(command);

	% Parse result and committ back to object
	commandResult = hDOORS.Result;
	if ~isempty(commandResult)

		% Result will be of form "id, true/false" where
		% the 2nd arg indicates if the item is linked or not
		[newID, remainder] = strtok(commandResult, ',');
		isLinkedStr = strtok(remainder, ',');
		isLinked    = str2bool(isLinkedStr);

		% Update requirement
		reqs.descriptions(1) = {['DOORS item:' newID]};
		reqs.docs(1)         = {''};
		reqs.ids(1)          = {newID};
		reqs.linked(1)       = {isLinked};
		reqs.keywords(1)     = {''};
		reqs.reqsys(1)       = {'doors'};

		% Commit new id
		if reqIndex > 0
			rmi('set', obj, reqs, reqIndex, 1);
		else
			rmi('set', obj, reqs);
		end;
	end;


function result = getSLObjType(block)

	result = '';
	type   = get_param(block, 'Type');

	switch type
	case 'block_diagram'
		result = 'Block Diagram';
	case 'block'
		blockType = get_param(block, 'BlockType');

		if is_stateflow_block(block)
			result = 'Stateflow Subsystem';
		else
			result = blockType;
		end;
	end;


function result = getSLObjLevel(block)

	% Count occurences of "/" in the block name.
	% If user enters forward slash in block name
	% it is assumed that it will be escaped "//".
	% find_system already does this.

	% For the purpose of counting levels we don't
	% need "//".
	copyBlock = strrep(block, '//', '');

	% Count "/"s and add one
	result = find(copyBlock == '/');
	result = length(result) + 1;
