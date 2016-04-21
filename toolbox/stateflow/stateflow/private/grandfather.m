function result = grandfather( command, varargin )
% RESULT = GRANDFATHER( COMMAND, ... )

%	E. Mehran Mestchian
%  Copyright 1995-2004 The MathWorks, Inc.
%  $Revision: 1.45.4.7 $  $Date: 2004/04/15 00:58:17 $

result = [];
switch command
case 'isproperty' % propName
    % Add the list of all grandfathered properties to the switchyard below.
    propName = varargin{1};
    display2( command,propName);
    result = 1;
    switch propName
    case 'chart.decomposition'
    case 'state.decomposition'
    case 'chart.animationColor'
    case 'chart.groupedColor'
    case 'transition.coverageInfo'
    case 'transition.src.intersection'
    case 'transition.dst.intersection'
    case 'transition.drawStyle'
    case 'state.coverageInfo'
    case 'state.superState'
    case 'target.codeCommand'
    case 'data.range.minimum'
    case 'data.range.maximum'
    case 'data.range'
    case 'data.array.size'
    case 'data.array.firstIndex'
    case 'data.initialValue'
    otherwise % property is not grandfathered
        result = 0;
        return;
    end
case 'get' % objId, propName
    objId = varargin{1};
    propName = varargin{2};
    %	display3( command, objId, propName);
case 'set' % objId, propName, propValue
    objId = varargin{1};
    propName = varargin{2};
    propValue = varargin{3};
    %	display4( command, objId, propName, propValue );
case 'preload' % fileName
    fileName = varargin{1};
    %	display2( command,fileName);
case 'load' % objId, propValuePairs
    objId = varargin{1};
    propValuePairs = varargin{2};
    for i=1:length(propValuePairs)
        prop = propValuePairs{i}{1};
        value = propValuePairs{i}{2};
        switch prop
        case 'state.superState',
            if isequal(value, 'HIDDENGROUPED'),
                sf('set', objId, '.superState', 'GROUPED');
            end;
        case 'target.codeCommand'
        case 'transition.drawStyle',
            if isequal(value, 'CURVE'),
                sf('set', objId, '.drawStyle', 'STATIC');
            elseif isequal(value, 'STRAIGHT'),
                sf('set', objId, '.drawStyle', 'SMART');
            end;
        end
    end
    %   display3( command, objId, propValuePairs);
case 'postload' % fileName, objects
    fileName = varargin{1};
    ids = varargin{2};		% ids of everything in machine are passed in
    machineId = ids(1);
    sfVersion = sf('get',machineId,'.sfVersion');
	if(sfVersion < 20011061.000000)
		%In 1.06, we were storing animation delay as an index into the debugger
		%pop-up , i.e, 0-4. In 1.2 onwards , we are storing the actual value of the delay.
		%hence the conversion. G42321
		animationDelay = sf('get',machineId,'machine.debug.animation.delay');
		animationDelay = animationDelay/5.0;
		sf('set',machineId,'machine.debug.animation.delay',animationDelay);
	end
    if(sfVersion < 30011050.000001)
        % prior to rationalizing workspace data
        workspaceData = sf('find',ids,'data.scope','WORKSPACE_DATA');
        for i=1:length(workspaceData)
            dataSize = sf('get',workspaceData(i),'data.parsedInfo.array.size');
            if(~isempty(dataSize) & dataSize>0)
                if(~isempty(sf('get',sf('get',workspaceData(i),'data.linkNode.parent'),'machine.id')))
                    % machine parented vector data
                    sf('set',workspaceData(i),'data.scope','EXPORTED_DATA','data.initFromWorkspace',1);
                else
                    % chart parented vector data
                    sf('set',workspaceData(i),'data.scope','LOCAL_DATA','data.initFromWorkspace',1);
                end
            else
                sf('set',workspaceData(i),'data.scope','PARAMETER_DATA');
            end
        end
        tempData = sf('find',ids,'data.scope','TEMPORARY_DATA');
        tempDataParents = sf('get',tempData,'data.linkNode.parent');
        for i=1:length(tempDataParents)
            if(~isempty(sf('find',tempDataParents(i),'~state.type',2)))
                % parented by a state that is not a function. change type to local
                sf('set',tempData(i),'data.scope','LOCAL_DATA');
            end
        end
    end

    if (sfVersion > 30000000.000000 & sfVersion <= 30111061.000000)
        fix_corrupted_subgroups(machineId);
    end

    % move bitops property from target to machine/charts.
    if (40000000.000000 <= sfVersion & sfVersion < 40012060.000003)...
            | (sfVersion < 30111061.000003)

        allTargets = sf('TargetsOf',machineId);
        sfunTarget = sf('find',allTargets,'target.name','sfun');
        % get property from sfun target and apply to all charts and machine
        enableBitOps = ~isempty(findstr(sf('get',sfunTarget,'target.codeFlags'),'bitops'));
        allCharts = sf('get',machineId,'machine.charts');
        sf('set',allCharts,'chart.actionLanguage',enableBitOps);
        sf('set',machineId,'machine.defaultActionLanguage',enableBitOps);
        % check for inconsistent settings across targets; strip out old flags
        count = 0;
        for t = allTargets
            flags = sf('get',t,'target.codeFlags');
            [s f] = regexp(flags,'[+\-]bitops', 'once');
            if(~isempty(s))
                count = count + 1;
                flags(s:f) = [];
                sf('set',t,'target.codeFlags',flags);
            end
        end
        if (0 < count) & (count < length(allTargets))
            disp(sprintf('Warning: In model ''%s'' some targets enable C-like bit operations while other targets do not.',...
                sf('get',machineId,'machine.name')));
            if(enableBitOps)
                disp(sprintf('         Bit operations have been enabled on all charts, consistent with sfun target.'));
            else
                disp(sprintf('         Bit operations have been disabled on all charts, consistent with sfun target.'));
            end
        end
    end


    if sfVersion < 20011030.000003
        % Upgrade the old data types to new mapping compatible with Simulink
        for dataId = sf('get',ids,'data.id')'
            dataType = sf('get',dataId,'.dataType');
            %			disp(sprintf('#%d ''%s''',dataId,dataType));
            switch(dataType)
            case {'Boolean (unsigned char)','Boolean (1 bit)'}
                dataType ='boolean';
            case {'Nibble (4 bits)','Byte (unsigned char)'}
                dataType ='uint8';
            case {'Word (unsigned short)'}
                dataType = 'uint16';
            case {'Word (unsigned long)'}
                dataType = 'uint32';
            case {'Byte (signed char)'}
                dataType ='int8';
            case {'Integer (short)'}
                dataType = 'int16';
            case {'Integer (long)'}
                dataType ='int32';
            case {'Real (float)'}
                dataType = 'single';
            case {'Real (double)','double',''}
                dataType = 'double';
            case {'State'}
                dataType = 'State';
            otherwise
                disp(sprintf('Warning: loading an improper Stateflow data type ''%s'' #%d. Reverting to double.',dataType,dataId))
                dataType = 'double';
            end
            %			disp(sprintf('\t#%d ''%s''',dataId,dataType));
            sf('set',dataId,'.dataType',dataType);
        end
    end
    if sfVersion <= 20011030.000005
        if sfVersion > 1.07
            % This forces a all SF editor windows to be auto-adjusted. Fixes a bug introduced in SF 1.2 until the above version.
            sf('set',ids,'chart.screen.position',[1 1 1 1]);
        end
        % change output rising/falling edge events into 'either edge' events
        outputEventIds = sf('find',ids,'event.scope','OUTPUT_EVENT');
        risingEventIds = sf('find',outputEventIds,'event.trigger','RISING_EDGE_EVENT');
        if ~isempty(risingEventIds)
            sf('set',risingEventIds,'event.trigger','EITHER_EDGE_EVENT');
            disp('Warning: The following output rising-edge events have been converted to either-edge events:');
            for id = risingEventIds
                disp(['         ' sf('FullNameOf',id,'/')]);
            end
        end
        fallingEventIds = sf('find',outputEventIds,'event.trigger','FALLING_EDGE_EVENT');
        if ~isempty(fallingEventIds)
            sf('set',fallingEventIds,'event.trigger','EITHER_EDGE_EVENT');
            disp('Warning: The following output falling-edge events have been converted to either-edge events:');
            for id = fallingEventIds
                disp(['         ' sf('FullNameOf',id,'/')]);
            end
        end
    end

    if sfVersion < 20011050.000002
        sfunId = sf('find',ids,'target.name','sfun');
        if ~isempty(sfunId)
            sf('set',sfunId,'.applyToAllLibs',1);
        end
    end
    %%% Insert parentheses into labels to account for precedence change in 2.0
    if (sfVersion < 20011050.000002) & ~((1.1 <= sfVersion) & (sfVersion < 1.2))
        % parse all labels and fix up any precedence problems with parentheses.
        charts = sf('get',ids,'chart.id');
        for chart = charts(:)'
            grandfather_precedence(chart)
        end
    end
    %%% Update format of coder flags
    if sfVersion <= 40212071.000001
        % parse codeFlags on all targets and reformat them
        targets = sf('get',ids,'target.id');
        simpleFlags = { 'debug',
            'telemetry',
            'preservenames',
            'preservenameswithparent',
            'exportcharts',
            'project',
            'multiinstanced'};

        for target = targets(:)'
            oldFlags = sf('get',target,'target.codeFlags');
            newFlags = {};
            newValues = [];

            % handle the easy cases
            for i = 1:length(simpleFlags)
                flag = simpleFlags{i};
                % first check for the new style
                flagIsOne = ~isempty(regexp(oldFlags,['\s',flag,'=1'], 'once'));
                flagIsZero = ~isempty(regexp(oldFlags,['\s',flag,'=0'], 'once'));
                if(~flagIsOne & ~flagIsZero)
                    % now check for the old style
                    val = ~isempty(regexp(oldFlags, ['[+\-]' flag], 'once'));
                elseif flagIsOne
                    val = 1;
                else
                    val = 0;
                end
                newFlags{end+1} = flag;
                newValues(end+1) = val;
            end

            % this flag got split into two
            val = ~isempty(regexp(oldFlags, ['[+\-]bitsets'], 'once'));
            newFlags{end+1} = 'statebitsets';
            newValues(end+1) = val;

            newFlags{end+1} = 'databitsets';
            newValues(end+1) = val;

            % fix the inverted polarity of these
            val = isempty(regexp(oldFlags, ['[+\-]nocomments'], 'once'));
            newFlags{end+1} = 'comments';
            newValues(end+1) = val;

            val = isempty(regexp(oldFlags, ['[+\-]noecho'], 'once'));
            newFlags{end+1} = 'echo';
            newValues(end+1) = val;

            val = isempty(regexp(oldFlags, ['[+\-]noinitializer'], 'once'));
            newFlags{end+1} = 'initializer';
            newValues(end+1) = val;

            % merge two switches that should be a single multi-valued switch
            % ioformat = 0  ==> use global io
            % ioformat = 1  ==> pack io into structures
            % ioformat = 2  ==> use individual arguments for io
            if ~isempty(regexp(oldFlags, '[+\-]globalio', 'once'))
                newFlags{end+1} = 'ioformat';
                newValues(end+1) = 0;
            elseif ~isempty(regexp(oldFlags, '[+\-]nopackio', 'once'))
                newFlags{end+1} = 'ioformat';
                newValues(end+1) = 2;
            else
                newFlags{end+1} = 'ioformat';
                newValues(end+1) = 1;
            end

            target_code_flags('set',target,newFlags,newValues);
        end


    end
    
    % Convert truth table format
    if sfVersion < 51013000.000003
        
        truthtables = sf('find',ids,'state.truthTable.isTruthTable',1);
        if(sfVersion < 51013000.000002)
            for i = 1:length(truthtables)
                ttId = truthtables(i);
                
                predArray = sf('get', ttId, 'state.truthTable.predicateArray');
                if ~isempty(predArray)
                    newPredArray = predArray(:,[1,3:end]);
                    for r = 1:size(newPredArray, 1)-1
                        if ~isempty(predArray{r,2})
                            newPredArray{r,2} = [predArray{r,2} ':' 10 newPredArray{r,2}];
                        end
                    end
                    sf('set', ttId, 'state.truthTable.predicateArray', newPredArray);
                end
                
                actArray = sf('get', ttId, 'state.truthTable.actionArray');
                if ~isempty(actArray)
                    newActArray = actArray(:,[1 3]);
                    for r = 1:size(newActArray, 1)
                        if ~isempty(actArray{r,2})
                            newActArray{r,2} = [actArray{r,2} ':' 10 newActArray{r,2}];    
                        end
                    end
                    sf('set', ttId, 'state.truthTable.actionArray', newActArray);
                end
            end
        end
        % set autogen field for objects in truthtable
        for i = 1:length(truthtables)
            ttId = truthtables(i);
            ttData = sf('DataIn',ttId);
            ttData = sf('find',ttData,'data.scope','TEMPORARY_DATA');
            sf('set',ttData,'data.autogen.isAutoCreated',1);            
        end        
    end
    
    %   display2( command,fileName);
case 'postbind'
	machineId = varargin{1};
    [sfVersion,machineName] = sf('get',machineId,'.sfVersion','.name');
	suppressMsg = 0;
    %%% VERY IMPORTANT: This needs to be done in postbind
    %%% for the instance object to contain info on port handles
    % Reconcile vector size string '1,10', '[10,1]' to '10' for pre R14 beta 1 models 
    if sfVersion < 60014000.000001
        dataIds = sf('DataIn',machineId);
        for dataId = dataIds(:)'
            dataSize = sf('get',dataId,'data.parsedInfo.array.size');
            if length(dataSize) == 2
                if dataSize(1) == 1 && dataSize(2) == 1
                    sf('set',dataId,'data.props.array.size','');
                elseif dataSize(1) == 1
                    sf('set',dataId,'data.props.array.size',int2str(dataSize(2)));
                elseif dataSize(2) == 1
                    sf('set',dataId,'data.props.array.size',int2str(dataSize(1)));
                else
                    % No need to reconcile
                end
            end
        end
    end
    
	if sfVersion < 40212071.000002
		% G94175: we have to wait until post-bind to do this
		% otherwise, we wont detect the corruption.
		fixedModel = fix_corrupted_grouped_bits(machineId);
		if(fixedModel)
			suppressMsg = 1;
		end
    end

    if sfVersion < 60014000.000003
        % eML chart contains parameter data must force sync prototype
        emlBlks = eml_blocks_in(machineId);
        for i = 1:length(emlBlks)
            ioData = sf('DataOf', emlBlks(i));
            if ~isempty(sf('find', ioData, 'data.scope', 'PARAMETER_DATA'))
                % eML chart parameter data presents, force sync
                sf('EmlChartFixPrototype', emlBlks(i));
            end
        end
	end

	% dboissy says:
	% Custom code settings for RTW now exist in configset
	if sfVersion < 60014000.000005
		% Need to wrap this in a version check
		modelName  = sf('get', machineId, 'machine.name');
		allTargets = sf('TargetsOf', machineId);
		rtwTargets = sf('find', allTargets, 'target.name', 'rtw');

		if length(rtwTargets) > 0
			% Get RTW settings from configset
			cs = getActiveConfigSet(modelName);

			% Check to see if configset available, libraries don't have one
			if ~isempty(cs)
				rtwSettings = cs.getComponent('any', 'Real-Time Workshop');

				for i = 1 : length(rtwTargets)
					rtwtarget = rtwTargets(i);

					% Get custom code settings from rtw target
					customCode        = sf('get', rtwtarget, 'target.customCode');
					userIncludeDirs   = sf('get', rtwtarget, 'target.userIncludeDirs');
					userLibraries     = sf('get', rtwtarget, 'target.userLibraries');
					customInitializer = sf('get', rtwtarget, 'target.customInitializer');
					customTerminator  = sf('get', rtwtarget, 'target.customTerminator');
					userSources       = sf('get', rtwtarget, 'target.userSources');

					% Append Stateflow RTW target settings to the configset
					rtwSettings.CustomHeaderCode  = [rtwSettings.CustomHeaderCode  customCode];
					rtwSettings.CustomInclude     = [rtwSettings.CustomInclude     userIncludeDirs];
					rtwSettings.CustomLibrary     = [rtwSettings.CustomLibrary     userLibraries];
					rtwSettings.CustomInitializer = [rtwSettings.CustomInitializer customInitializer];
					rtwSettings.CustomTerminator  = [rtwSettings.CustomTerminator  customTerminator];
					rtwSettings.CustomSource      = [rtwSettings.CustomSource      userSources];

					% Clear rtw target
					sf('set', rtwtarget, 'target.customCode',        '');
					sf('set', rtwtarget, 'target.userIncludeDirs',   '');
					sf('set', rtwtarget, 'target.userLibraries',     '');
					sf('set', rtwtarget, 'target.customInitializer', '');
					sf('set', rtwtarget, 'target.customTerminator',  '');
					sf('set', rtwtarget, 'target.userSources',       '');
				end; % for
			end; % if configset exists
		end; % if length(rtwTargets)
	end; % if sfVersion

otherwise
    disp(sprintf('stateflow/private/grandfather: unknown command %s.',command));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display2( command, arg2)
%
%
%
return;
disp(sprintf('grandfather(%s, %s)',command,arg2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display3( command, objId, arg3 )
%
%
%
return;
%	if ischar(arg3)
%		disp(sprintf('grandfather(%s,%d,%s)',command,objId,arg3));
%   elseif iscell(arg3)
%		for i=1:length(arg3)
%			propName = arg3{i}{1};
%			propValue = arg3{i}{2};
%			display4(command,objId,propName,propValue);
%		end
%	else
%		disp(sprintf('grandfather(%s,%d,[%s ])',command,objId,sprintf(' %d',arg3)));
%	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display4( command, objId, propName, propValue )
%
%
%
return;
%	if ischar(propValue)
%		disp(sprintf('grandfather(%s,%d,%s,''%s'')',command,objId,propName,propValue));
%   else
%		disp(sprintf('grandfather(%s,%d,%s,[%s ])',command,objId,propName,sprintf(' %d',propValue)));
%	end


