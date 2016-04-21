function cvdisplay(inIndex),
%CVDISPLAY - Select an object on its graphical diagram

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.10.2.2 $  $Date: 2004/04/15 00:36:55 $

global  gSfMachinesWithSyncedTarget;
persistent  lastSlBlock sfIsa;
if isempty(lastSlBlock)
    lastSlBlock = -1;
end

if isempty(sfIsa)
    sfIsa.machine = sf('get','default','machine.isa');
    sfIsa.chart = sf('get','default','chart.isa');
    sfIsa.state = sf('get','default','state.isa');
    sfIsa.transition = sf('get','default','transition.isa');
    sfIsa.junction = sf('get','default','junction.isa');
end

% get the linkTable triplet
objIndex = inIndex(1);
linkInfo = html_info_mgr('get','linkTable',objIndex);
cvId = linkInfo{1};
handle = linkInfo{2};
fullPath = linkInfo{3};
objModelName = strtok(fullPath,'/');


% First we do a sanity check to see if the existing handle is ok
try
    if(floor(handle)~=handle)
        % This is a Simulink object, make sure that the model is the
        % same, othrewise reload.
        orig = 1;
        modelName = get_param(bdroot(handle),'Name');
        if strcmp(objModelName,modelName)
            mustReload = 0;
        else
            mustReload = 1;
        end
      
    else
        % This is a Stateflow object
        orig = 2;
        lastslash = find(fullPath=='/');
        lastslash = lastslash(end);
        objClassInitial = fullPath(lastslash+1);
        objNumber = str2num(fullPath((lastslash+2):end));
        
		if ~sf('ishandle',handle)
			mustReload = 1;
		else
        	switch(sf('get',handle,'.isa'))
            case sfIsa.chart,
                mustReload = 1;
            case sfIsa.state,
                sfNumber = sf('get',handle,'state.number');
                if( isequal('S',objClassInitial) & isequal(sfNumber,objNumber))
			        mustReload = 0;
                else
			        mustReload = 1;
                end
            case sfIsa.transition,
                sfNumber = sf('get',handle,'trans.number');
                if( isequal('T',objClassInitial) & isequal(sfNumber,objNumber))
			        mustReload = 0;
                else
			        mustReload = 1;
                end
            otherwise,
                mustReload = 1;
            end
		end
    end
    
catch
    mustReload = 1;
end

if (mustReload)
    % First see if the model is loaded
    try, 
        modelH = get_param(objModelName,'Handle');
    catch
        modelH = [];
    end
    
    if isempty(modelH)
        h = msgbox(sprintf('Loading model "%s".  Please wait.',objModelName));
        drawnow;
        try
            open_system(objModelName);
        catch
            delete(h);
            errordlg( ['The model "%s", referenced in the coverage report,', ...
                       'could not be loaded']);
        end
        delete(h);
    end
    
    
    if orig==1
        handle = get_param(fullPath,'Handle');
    else
        sepIndex = find(fullPath =='/');
        blockFullPath = fullPath(1:(sepIndex(end)-1));
        sfClass = fullPath(sepIndex(end)+1);
        
        blockH = get_param(blockFullPath,'Handle');
        open_system(blockH);
        instanceId = get_sf_block_instance_handle(blockH);
    
        if isempty(instanceId) | instanceId==0,
            return;
        end
    
        sfChartId = sf('get',instanceId,'instance.chart');
        if isempty(sfChartId) | sfChartId==0,
            return;
        end
        
        machineId = sf('get',sfChartId,'chart.machine');
        if isempty(machineId) | machineId==0,
            return;
        end
        
        if isempty(gSfMachinesWithSyncedTarget) | ~any(gSfMachinesWithSyncedTarget==machineId)
            sync_machine_sim_target(machineId);
            gSfMachinesWithSyncedTarget = [gSfMachinesWithSyncedTarget machineId];
        end
    
        switch(lower(sfClass))
        case 'c'
            handle = sfChartId;
        case 't'
            nmbr = str2num(fullPath((sepIndex(end)+2):end));
            handle = sf('find','all','trans.chart',sfChartId,'trans.number',nmbr);
        case 's'
            nmbr = str2num(fullPath((sepIndex(end)+2):end));
            handle = sf('find','all','state.chart',sfChartId,'state.number',nmbr);
		end
    end
end


if ishandle(lastSlBlock)
    set_param(lastSlBlock,'HiliteAncestors','off')
end

if (orig==1) % This is a simulink object
    if ishandle(handle)
        parent = get_param(handle,'Parent');
        open_system(parent,'force');
        set_param(handle,'HiliteAncestors','find')
        lastSlBlock = handle;
    end 
    return;
end

if (orig==2) % This is a stateflow object
    if sf('ishandle',handle),
        if length(inIndex)>1
            sf('Open',handle,inIndex(2),inIndex(3));
        else
            sf('Open',handle);
        end
    end
    return;
end



function sync_machine_sim_target(machineId)

    targetId = sf('get',machineId,'machine.firstTarget');
    sf('Private','sync_target',targetId);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Functions copied from toolbox/stateflow/stateflow/slsf.m        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function instanceId = get_sf_block_instance_handle(blockH),
%
%
%
if ~ishandle(blockH), 
   error_msg('Invalid block handle passed to slsf()');
   instanceId = 0;
	return;   
end;

	if is_an_sflink(blockH), 
		refBlock = get_param(blockH, 'ReferenceBlock');
		ind = find('/'==refBlock);
		instanceName = refBlock((ind(1)+1):end);

		% force library to be open, otherwise the refBlock
                % may not be valid!
		load_system(refBlock(1:(ind(1)-1)));
		
		%
		% Make sure the instance for the reference block has been loaded.
		%	
		ud = get_param(refBlock, 'userdata');	
		if isempty(ud) | ~isnumeric(ud) | ~sf('ishandle',ud) | isempty(sf('find', 'all', 'instance.name', instanceName)),
			modelName = get_root_name_from_block_path(refBlock);
			sf_load_model(modelName);
			%
			% If it's locked, it probably hasn't been loaded, unlock it
			% and lock it to insure that it has.
			%
			if strcmp(lower(get_param(modelName, 'lock')),'on'),
				set_param(modelName, 'lock','off');
				set_param(modelName, 'lock','on');
			end;
		end;

		instanceId = get_param(refBlock, 'userdata'); 
	else, 
		instanceId = get_param(blockH, 'userdata');
	end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLink = is_an_sflink(blockH),
%
% Determine if a block is a link
%
if isempty(get_param(blockH, 'ReferenceBlock')),
   isLink = 0;
else,
   isLink = 1;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLib = is_an_sflib(blockH),
%
% Determine if a block is a library block (sflib)
%
	modelH = bdroot(blockH);
	if ~is_an_sflink(blockH) & model_is_a_library(modelH),
		isLib = 1;
	else,
		isLib = 0;
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rootName = get_root_name_from_block_path(blkpath)
%
%
%
	ind = min(find(blkpath=='/'));
	rootName = blkpath(1:(ind(1)-1));


% This function copied from 
% toolbox/stateflow/stateflow/private/sf_load_model.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sf_load_model(modelName)
%
% Silently loads a Simulink model given its name.
%
	eval([modelName,'([],[],[],''load'');'], '');

