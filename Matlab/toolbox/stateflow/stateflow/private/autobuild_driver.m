function status = autobuild_driver(buildType,machineId,targetName,showNags)

% Copyright 2003-2004 The MathWorks, Inc.

if(nargin<4)
    showNags = 0;
end
if(ischar(showNags))
    showNags = strcmp(showNags,'yes');
end
status = 0;
[machineId,machineName] = unpack_machine_id(machineId);
if sf('get', machineId, '.deleted'), return; end;

switch(lower(buildType))
    case 'pre_link_resolve'
        sfLinks = machine_bind_sflinks(machineId,1);
        update_eml_data(machineId);         % Update data from all opening eML editors
        update_truthtable_data(machineId);  % Update data from all opening truthtable editors
        update_truth_tables(machineId);     % Create diagram if necessary for all truthtables
        % G205007. sync params str after eml did its part.
		update_params_on_instances(machineId);
        linkMachines = get_link_machine_list(machineId, 'sfun');
        for i = 1:length(linkMachines)
            linkMachine = sf('find',sf('MachinesOf'),'machine.name',linkMachines{i});
            update_eml_data(linkMachine);         % Update data from all opening eML editors
            update_truthtable_data(linkMachine);  % Update data from all opening truthtable editors
            update_truth_tables(linkMachine);     % Create diagram if necessary for all truthtables
            update_params_on_instances(linkMachine);
        end
        eml_man('update_ui_state',machineId,'build');
    case 'setup'
        sf('CompileDataTypesAndSizes', machineId); 
        linkMachines = get_link_machine_list(machineId, 'sfun');
        for i = 1:length(linkMachines)
            linkMachine = sf('find',sf('MachinesOf'),'machine.name',linkMachines{i});
            sf('CompileDataTypesAndSizes', linkMachine);
        end
    case 'simbuild'
        modelH = sf('get', machineId, '.simulinkModel');
        switch get_param(modelH, 'simulationstatus')
        case 'initializing'
        case 'stopped'
        case 'updating'
        otherwise, return;
        end
        lasterr('');
        % for simbuild, we ignore the shownags that's passed in and
        % always use no as we an error to be thrown.
        status = autobuild_kernel(machineId,'sfun','build','no','no');
		
		if ~status
            hMakeRTWSettingsObject = get_param(modelH, 'MakeRTWSettingsObject');
            if ~isempty(hMakeRTWSettingsObject)
                if(~strcmp(hMakeRTWSettingsObject.BuildOpts.codeFormat,'Accelerator_S-Function'))
                    status = autobuild_kernel(machineId,'rtw','build','no','no');
                end
            elseif ~rtwenvironmentmode(sf('get',machineId,'machine.name'))
                % we do this because we found that there are calls to rtwgen
                % from outside the make_rtw harness in test-harnesses (e.g. kai's code reuse)
                % instead of bailing, we use pete's earlier suggestion to see
                % if we need to generate TLC
                status = autobuild_kernel(machineId,'rtw','build','no','no');
            end
        end
        
    case 'clean'
        clean_target(machineId,targetName);
    case 'clean_objects'
        clean_target(machineId,targetName,1);
    case {'build','rebuildall'}
        status = 0;
        slsfnagctlr('Clear');
        if strcmp(lower(buildType), 'rebuildall')
            autobuild_driver('clean',machineId,targetName);
        end     
        try,
            if(~model_is_a_library(machineName))
                set_param(machineName,'SimulationCommand','update');
                if(showNags)
                    nag             = slsfnagctlr('NagTemplate');
                    nag.type        = 'Log';
                    nag.msg.details =  sprintf('Model Compilation for %s successful.', machineName);
                    nag.msg.type    = 'Build';
                    nag.msg.summary = 'build log';
                    nag.component   = 'Stateflow';
                    nag.sourceHId   = machineId;
                    nag.ids         = machineId;
                    nag.blkHandles  = [];
                    slsfnagctlr('Naglog', 'push', nag);
                end
            else
                autobuild_driver('pre_link_resolve',machineId,'sfun');
                autobuild_driver('setup',machineId,'sfun');
                switch(lower(buildType))
                case 'rebuildall'
                    status = autobuild_kernel(machineId,targetName,'build','yes',showNags);
                case 'build'
                    status = autobuild_kernel(machineId,targetName,'build','no',showNags);
                end
            end
        catch,
            errMsg = clean_error_msg(lasterr);
            status = 1;
            if(showNags)
               construct_error(machineId, 'Build', errMsg, 0); 
            end
        end
        if(~strcmp(targetName,'sfun'))
            switch(lower(buildType))
            case 'rebuildall'
                status = autobuild_kernel(machineId,targetName,'build','yes',showNags);
            case 'build'
                status = autobuild_kernel(machineId,targetName,'build','no',showNags);
            end
        else
            if(status) 
                if(showNags)
                    slsfnagctlr('View');
                else
                    error(errMsg);
                end
            else
                if(showNags)
                    slsfnagctlr('View');
                    symbol_wiz('View', machineId);
                end
            end
        end
    case 'make'
        status = autobuild_kernel(machineId,targetName,'make','no',showNags);
end        
       

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = model_is_a_library(modelH)
result = strcmp(lower(get_param(modelH,'BlockDiagramType')),'library');
