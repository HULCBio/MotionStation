function out = slsf(varargin),
%
% SLSF Implementation of Stateflow-Simulink block and instance managament for SIMULINK 2.2 or greater.
%
%
%       Copyright 1995-2004 The MathWorks, Inc.
%	$Revision: 1.69.4.17 $

out = 0;

switch(length(varargin)),
    case 0,
        error_msg('slsf() called with NO ARGS');
        return;
    case 1,
        error_msg('slsf() called with 1 ARG (2 ARGS).');
        return;
    otherwise,
        if (nargout ~= 1)
            error_msg('bad num of output args for call to slsf()');
            return;
        end;

        method = varargin{1};
        machModelH = varargin{2};
        if (nargin == 3), blockH = varargin{3};	end;
end;

switch(method),
    case 'blkCopy',
        out = blk_copy_method(blockH, machModelH);
    case 'blkRealCopy',
        if(is_an_implicit_link(blockH) | is_an_sflink(blockH))
            out = blk_copy_method(blockH, machModelH);
        else
            out = blk_real_copy_method(blockH, machModelH);
        end
    case 'blkClipboard',
        out = blk_clipboard_method(blockH, machModelH);
    case 'blkDelete',
        out = blk_delete_method(blockH, machModelH);
    case 'blkUndoDelete',
        out = blk_undoDelete_method(blockH, machModelH);
    case 'blkDestroy',
        out = blk_destroy_method(blockH, machModelH);
    case 'blkNameChange',
        out = blk_name_change_method(blockH, machModelH);
    case 'blkOpen',
        out = blk_open_method(blockH, machModelH);
    case 'blkLinkBreak',
        out = blk_link_break_method(blockH, machModelH);
    case 'blkUndoLinkBreak',
        out = blk_undo_link_break_method(blockH, machModelH);
    case 'getBlockChartId',
        blockH = machModelH;
        out = get_sf_block_chart_handle(blockH);
    case 'mdlLoad',
        out = mdl_load_method(machModelH);
    case 'mdlPreSave',
        out = mdl_pre_save_method(machModelH);
    case 'mdlSave',
        out = mdl_save_method(machModelH);
    case 'mdlSaveAs',
        out = mdl_saveas_method(machModelH);
    case 'mdlClose',
        out = mdl_close_method(machModelH);
    case 'mdlLock',
        out = mdl_lock_method(machModelH);
    case 'mdlUnLock',
        out = mdl_unlock_method(machModelH);
    case 'mdlStart',
        out = mdl_startfcn_method(machModelH, logical(0));
    case 'mdlStartCmdLine',
        out = mdl_startfcn_method(machModelH, logical(1));
    case 'mdlStop',
        out = mdl_stopfcn_method(machModelH);
    case 'mdlFixBrokenLinks',
        out = mdl_fix_broken_links_method(machModelH);
    case 'mdlGenCode',
        out = machModelH;
    case 'compile_prestart'
        try,
            autobuild_driver('pre_link_resolve',machModelH,'sfun');
        catch,
            set_param(machine2model(machModelH),'SimulationCommand','Stop');
            error(lasterr);
        end
        out = machModelH;
    case 'mdlInit',
        out = machModelH;
    case 'compile_post_link_resolve'
        try,
            autobuild_driver('setup',machModelH,'sfun');
        catch,
            set_param(machine2model(machModelH),'SimulationCommand','Stop');
            error(lasterr);
        end
        out = machModelH;                   
    case 'compile_post_size_propagation'
        out = machModelH;
    case 'compile_post_propagation'
        try,
            autobuild_driver('simbuild',machModelH,'sfun');
        catch,
            set_param(machine2model(machModelH),'SimulationCommand','Stop');
            error(lasterr);
        end
        out = machModelH;                   
    case 'compile_fail'
        out =  mdl_compile_fail_method(machModelH);
    case 'compile_pass'
        out = machModelH;
    case 'exitDebug'
        out = mdl_exitdebug_method(machModelH);
    otherwise,
        % do nothing
        out = machModelH;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = mdl_load_method(modelH),
%
% Called only once when the block is loaded.
%
%	disp('SF BLOCK LOAD');

if ~model_is_a_library(modelH),
    machineId = load_machine_from_file(modelH);
else,
    % load with charts closed if aits a library
    machineId = load_machine_from_file(modelH,1);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = load_machine_from_file(modelH,loadWithAllChartsClosed),
%
% Load the associated machine for this model from fle
%
machineId = -1;

if nargin<2,
    loadWithAllChartsClosed = 0;
end

modelFileName = get_param(modelH, 'filename');
if ~(exist(modelFileName,'file'))
    error_msg(['file ' modelFileName ' does not exist.']);
    %% tell Simulink to never call slsf again for this model
    machineId = 0;
    return;
end

relock = model_is_locked(modelH);

%%% IMPORTANT PROFILING CODE:
%%% We measure the time taken for raw data-dictionary loading
%%% in the following lines.
machineLoadTimeStart = clock;
try,
    ids = sf('load',modelFileName,'Stateflow');
catch,
    ids = [];
    error(sprintf('Problem loading Stateflow from model --> %s', modelFileName));
end;
machineLoadTime = etime(clock,machineLoadTimeStart);

machines = sf('get',ids,'machine.id')';

switch(length(machines)),
    case 0,
        return;
    case 1,
    otherwise,
        warn(['Stateflow loader: ',modelFileName,10,' seems to be corrupted. More than one machine object was saved to file. The first one will be used...']);
end;
machine = machines(1);

if sf('get', machine, '.isLibrary') & model_is_locked(modelH),
    sf('set', machine, '.iced', 1);
end;
if sf('get', machine, '.isLibrary')
    loadWithAllChartsClosed = 1;
end
%%% IMPORTANT PROFILING CODE:
%%% We measure the time taken for instance binding
%%% in the following lines.
machineBindTimeStart = clock;
machine = sf('MachinePostLoad', machine, modelH,loadWithAllChartsClosed);
machineBindTime = etime(clock,machineBindTimeStart);
machineId = machine;
if(machineId==0)
    % License check failed
    set_param(modelH, 'preSaveFcn', 'errordlg(''Cannot save this model with a Demo Stateflow License!'');error(''Invalid Stateflow License'');');
    set_param(modelH, 'InitFcn', 'errordlg(''Cannot simulate/compile this model with a Demo Stateflow License!'');error(''Invalid Stateflow License'');');
    hs = find_system(modelH, 'FollowLinks','on', 'LookUnderMasks','on', 'MaskType','Stateflow');
    for h = hs(:).',
        sf_mark_block_as_tainted(h);
    end;
    sf_demo_disclaimer;
    return;
end
%%% IMPORTANT PROFILING CODE:
%%% We cache away load and bind times on the machine.
sf('set',machineId...
    ,'machine.time.load',machineLoadTime...
    ,'machine.time.bind',machineBindTime);
grandfather('postbind',machineId);
% G206451. after grandfathering, we must turn off the dirty flag
% as grandfathering may have modified the model.
sf('set',machineId,'machine.dirty',0);
if relock,
    set_param(modelH,'lock','on');
end;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = mdl_pre_save_method(machModelH)
%
% PreSave callback
%
out = machModelH;

%
% If this machine hasn't been loaded yet, load it.
%
if ~sf('License', 'basic', machModelH),
    sf_demo_disclaimer;
    error('Cannot save Stateflow model without a Stateflow license');
    return;
end;
if ~is_an_sf_id(machModelH),
    if (machModelH == -1),
        modelH = get_param(gcs,'handle');
    else,
        modelH = machModelH;
    end;
    % see if the new name satisfies us (if not, sf_validate_file_name errors out )
    sf_validate_file_name( modelH );
    if model_is_locked(modelH),
        %
        % If the model is locked, unlock to trigger a load
        % and then relock.
        %
        set_param(modelH, 'lock', 'off');
        set_param(modelH, 'lock', 'on');
        machineId = sf('find','all','machine.simulinkModel',modelH);
        if(~isempty(machineId))
            out = machineId;
        end
    else
        out = mdl_load_method(modelH);
    end;
else % it is a stateflow machine
    modelH = sf( 'get',machModelH, 'machine.simulinkModel' );
    % see if the new name satisfies us (if not, sf_validate_file_name errors out )
    sf_validate_file_name( modelH );

    % update all eML data, and truth table data if editors are open
    machineId = sf('find','all','machine.simulinkModel',modelH);
    update_eml_data(machineId);
    update_truthtable_data(machineId);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sf_validate_file_name( modelH )
%
%
%
newMachineName = get_param(modelH,'Name');
oldFileName = get_param( modelH, 'FileName' );

sfDirFileName = fullfile( sf('Root'), newMachineName );

sfMdlFileName = [sfDirFileName '.mdl'];
sfMFileName = [sfDirFileName '.m'];
sfPFileName = [sfDirFileName '.p'];
sfMexFileName = [sfDirFileName, mexext];

if(ispc)
    sfMdlFileName = lower(sfMdlFileName);
    oldFileName = lower(oldFileName);
end

if strcmp( oldFileName, sfMdlFileName )
    % allow save if the model file already exists in SF directory
    return;
end


if exist( sfMFileName, 'file' ) | exist( sfPFileName, 'file' ) | ...
        exist( sfMdlFileName, 'file' ) | exist( sfMexFileName, 'file' )
    errorStr = ['Cannot save model as ''' newMachineName ''' due to name conflict with a Stateflow command.' ];
    error( errorStr );
end

bdType = get_param(modelH,'BlockDiagramType');
isLibrary = strcmp(bdType,'library');

if(~isLibrary)
    errorStr = check_for_long_model_name(newMachineName);
    if(~isempty(errorStr))
        error( errorStr );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = mdl_save_method(machineId),
%
%
%
%	disp('SF BLOCK SAVE');

if is_a_model_handle(machineId),
    if model_is_a_library(machineId),
        %
        % Must be an unloaded library, this should never happen
        % since the mdlPreSave event loads it!
        %
        error_msg('Attempt to overwrite Stateflow content in mdl-File. Should never get here!');
        machineId = -1;
        return;
    else
        warning('An unloaded nonlibrary model with Stateflow components was found. Ignoring...');
        machineId = -1;
        return;
    end;
end;

if ~is_an_sf_id(machineId), return; end;

%
% Do not save this to file if has been deleted! --this means that the machine is empty, so why save it?
%
if sf('get', machineId, '.deleted'), return; end;

modelH = sf('get', machineId, '.simulinkModel');

modelFileName = get_param(modelH,'filename');
if(testing_stateflow_in_bat)
    %%% Protect against saving any files in
    %%% MATLAB directories. This will catch
    %%% bugs when tests erroneously try to
    %%% save files without first copying them
    %%% to tempdir.
    filePath = fileparts(modelFileName);
    if(~isempty(findstr(lower(matlabroot),lower(filePath))))
        errStr = sprintf('Trying to save model %s in MATLAB area during testing.',modelFileName);
        error(errStr);
    end
end

header = [...
    '# Finite State Machines', 10 ...
    '#', 10 ...
    '#    Stateflow ',sf('Version'), 10 ...
    '#', 10 ...
    '#', 10 ...
    10 ];


if(~model_is_locked(modelH))
    slModelName = get_param(modelH,'name');
    sfMachineName = sf('get',machineId,'machine.name');
    simRunning = strcmp(get_param(modelH, 'SimulationStatus'),'running');
    if(~strcmp(slModelName,sfMachineName))
        if(simRunning)
            error('Stateflow models cannot be renamed during simulation.');
        end
        sf('set',machineId,'machine.name',slModelName);
    end
    if(~simRunning)
        ted_the_editors(machineId);
    end
end

%%% IMPORTANT PROFILING CODE:
%%% We measure the time taken for saving
%%% in the following lines.
machineSaveTimeStart = clock;
sf('SaveMachines',machineId,modelFileName,header);
machineSaveTime = etime(clock,machineSaveTimeStart);
sf('set',machineId,'machine.time.save',machineSaveTime);
sf('set',machineId,'.dirty',0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = mdl_saveas_method(machineId),
%
% Called just before the internal model's 'filename' changes
% due to a SaveAs operation.  This gives us a chance to load the
% Stateflow portion of the file before saving to a new file.
%
% machineId may be a valid machineId or a valid model Handle
%

%
% If this has already been loaded, just return.
%
if is_an_sf_id(machineId), return; end;

%
% If this is an unloaded library, load it.
%
if is_a_model_handle(machineId),
    modelH = machineId;

    %
    % If this is an unloaded library, load it.
    %
    if model_is_a_library(modelH),
        isLocked = model_is_locked(modelH);
        set_param(modelH,'lock','off');
        machineId = sf('find','all','machine.simulinkModel',modelH);
        machineId = machineId(1);
        if isLocked, set_param(modelH, 'lock','on'); end;
    else, warning('mdl_saveas_method() was passed a model handle when it expected a library handle');
    end;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_open_method(blockH, machModelH),
%
% Open method for SF block.
%
%	disp('SF BLOCK OPEN');

machineId = machModelH;

if (machineId == 0),
    return;
end;

%
% If this is a previously unloaded library, load it now!
%
if (machineId == -1),
    modelH = get_param(sfbdroot(blockH), 'handle');
    if model_is_a_library(modelH),
        isLocked = model_is_locked(modelH);
        set_param(modelH,'lock','off');
        machineId = sf('find','all','machine.simulinkModel',modelH);
        machineId = machineId(1);
        if isLocked, set_param(modelH, 'lock','on'); end;
    else,
        error_msg('No machine found: Stateflow data-dictionary is inconsistent with Simulink!');
        error_msg('Do not save this model.');
        machineId = machModelH;
        return;
    end;
end;

if is_an_sflink(blockH),
    linkStatus = lower(get_param(blockH, 'LinkStatus'));

    if strcmp(linkStatus, 'unresolved'),
        open_system(blockH);
    else
        %
        % The user may have closed the library manually, so we need
        % to first open the root of the reference block to avoid
        % Simulink errors.
        %
        ref = get_param(blockH, 'ReferenceBlock');
        rootName = get_root_name_from_block_path(ref);
        sf_load_model(rootName);
        if(strcmp(rootName, 'eml_lib') && ...
                strcmp(get_param(bdroot(blockH),'Name'),'simulink'))
            errordlg(['To open the Embedded MATLAB Fcn Block, first place this block in a model or library. ']);
            return;
        else
            open_system(ref);
        end
        refH = get_param(ref, 'handle');
        instanceId = sf('find','all','instance.simulinkBlock',refH);
        if(~isempty(instanceId))
            chartId = sf('get',instanceId,'instance.chart');
            sf('set',chartId,'chart.activeInstance',blockH);
        end
    end;
    return;
end;


instanceH = get_sf_block_instance_handle(blockH);
%
% If this is a valid instance handle, then Stateflow guarantees that the parent
% chart is valid too, so open it.
%
if (is_an_sf_id(instanceH))
    chartH = sf('get', instanceH, '.chart');
    sf('set',chartH,'chart.activeInstance',0.0);
    sf('Open', chartH);
else,
    set_param(blockH,'MaskType','');
    msg = sprintf('Cannot open corrupted Stateflow block %s',get_param(blockH,'name'));
    error_msg(msg);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_copy_and_real_copy(blockH, machModelH,realCopyFlag),
%
% Called from blk_copy_method and blk_real_copy_method
% the code from the above two functions is refactored into this common function

machineId = machModelH;

GET = sf('method','get');
SET = sf('method','set');

newModelH = get_param(sfbdroot(blockH), 'handle');

if(~is_sf_machine(machModelH))
    if  ~is_an_sflink(blockH) && is_sf_chart_block(blockH)
        % G209936 we must be *very* careful about calling sf('license','basic')
        % as it tries to check out a license. do it only when we are sure
        % that we are copying a Stateflow chart
        if(~sf('License','basic'))
            % we must be *very* careful about calling
            % is_sf_chart_block which in turn calls block2chart causing
            % the source library to load. Do it only when block is not a link block.
            sf_demo_disclaimer;
            sf_mark_block_as_tainted(blockH);
            return;
        end
    end
end;
makeLinkReal = 0;
if(realCopyFlag==0 & is_an_sflink(blockH))
    %%%% G162544
    %%%% IMPORTANT ARCANA:
    %%%% 1. Dont try to use get_param on sourceModelName as Simulink
    %%%% may not have loaded it yet
    %%%% Hence the comparison is done via strcmp of model names
    %%%% 2. Dont use get_param(blockH,'linkstatus') to figure out
    %%%% if it is an implicit link as it causes block_copy
    %%%% events to be pumped back into Stateflow
    %%%% hence the call to the function is_an_implicit_link()
    %%%% which checks if the parent of this block has a referenceblock
    %%%% 3. Use bdroot_from_string instead of bdroot or sfbdroot for the
    %%%% same reason as 1. The source model for the ref block may not
    %%%% be loaded yet.
    sourceBlockName = get_param(blockH,'referenceblock');
    sourceModelName = bdroot_from_block_path(sourceBlockName);
    dstModelName = get_param(newModelH,'name');
    if(strcmp(dstModelName,sourceModelName))
        if(~is_an_implicit_link(blockH))
            if(strcmp(get_param(newModelH,'lock'),'on'))
                set_param(newModelH,'lock','off');
            end
            makeLinkReal = 1;
        end
    elseif(is_an_eml_slLibrary(blockH) & ~strcmp(dstModelName,'simulink'))
        makeLinkReal = 1;
    else
        makeLinkReal = 0;
    end
    if(makeLinkReal)
        set_param(blockH,'referenceblock','');
        sourceBlockH = get_param(sourceBlockName,'handle');
        sourceInstanceId = get_sf_block_instance_handle(sourceBlockH);
        set_param(blockH,'userdata',sourceInstanceId);
        set_param(newModelH,'Dirty','on');
        realCopyFlag = 1;
    end
end


if realCopyFlag==0 & is_an_sflink(blockH),
    %% since realCopyFlag==0, this code is relevant for blk_copy_method only
    if model_is_a_library(newModelH)
        myMachine = sf('find', 'all', 'machine.simulinkModel', newModelH);
        if (isempty(myMachine) & machModelH == -1),
            % If you get here, your looking at an sfLink instantiation INSIDE a library
            % (ie, nested stateflow libraries).  In the spirit of Just-in-time loading of
            % Stateflow machines, simply return;
            % However, if the machModelH passed back down from Simulink is not -1, then
            % you must be copying into a newly created library.  So, create a machine.
            return;
        end;
    end;
    machineId = acquire_or_create_machine_for_model(blockH, newModelH);
    sf('MachineAddsfLink', machineId, blockH);
    change_icon_to(blockH, 'link');
    set_active_instance(blockH);
    return;
end;

oldInstanceId = get_sf_block_instance_handle(blockH);

% ASSERT that this block has a valid instance.
if (~is_an_sf_id(oldInstanceId)),
    set_param(blockH,'MaskType','');
    msg = sprintf('Cannot copy corrupted Stateflow block %s',get_param(blockH,'name'));
    error_msg(msg);
    machineId = machModelH;
    return;
end

[oldMachineId, oldChartId] = sf(GET, oldInstanceId, '.machine', '.chart');
oldModelWasClean = 0;
oldMachineWasClean = 0;
oldModelH = sf(GET,oldMachineId,'machine.simulinkModel');
if(oldModelH~=0)
    %% not a clipboard machine
    oldMachineWasClean = sf(GET,oldMachineId,'machine.dirty')==0;
    oldModelWasClean = strcmp(get_param(oldModelH,'Dirty'),'off');
end

%% note that if oldMachineId is a clipboard machine, then oldModelWasClean
%% remains at 0 so that we dont attempt to reset the dirty flag on a
%% non-existent SL model and a clipboard machine.

if(realCopyFlag==0 & sf(GET, oldMachineId, '.isLibrary')),
    %% since realCopyFlag==0, this code is relevant for blk_copy_method only
    %% we just made a link chart from a library model. dont actually copy the chart.
    return;
end;

newMachineId = acquire_or_create_machine_for_model(blockH, newModelH);
if (oldMachineId ~= newMachineId)
    %%% by setting dontUpdateChartFileNumber=1, we tell CopyChart not to update
    %%% chartFileNumber property of the chart since it will happen in MoveToMachine
    %%% anyway.
    dontUpdateChartFileNumber = 1;
else
    %%% we are duplicating the chart in the same machine. we must update the
    %%% chartFileNumber property.
    dontUpdateChartFileNumber = 0;
end

newChartId		= sf('CopyChart', oldChartId,dontUpdateChartFileNumber);
if(realCopyFlag==1)
    %% since realCopyFlag==1, this code is relevant for blk_real_copy_method only
    sf(SET,newChartId,'chart.locked',0);
    sf(SET,newChartId,'chart.iced',0);
end

newInstanceName	= get_instance_name_from_block(blockH);
newInstanceId	= sf('new', 'instance', '.simulinkBlock', blockH, '.chart', newChartId);
sf(SET, newInstanceId, '.name', newInstanceName);
set_param(blockH, 'userdata', newInstanceId);

% Update the name and jog the position of the new chart.
pos = sf(GET, newChartId, '.windowPosition');
sf(SET, newChartId, '.windowPosition', pos+[15 -15 0 0], '.visible',0);

if(realCopyFlag==0)
    %% since realCopyFlag==0, this code is relevant for blk_copy_method only

    % The chart in sflib.mdl has chart.actionLanguage == -1, which is how
    % we distinguish between "new" charts and "copied" charts.
    % The code below ensures that all other charts have a valid chart.actionLanguage.
    %
    % For new charts, get the action language from the machine.
    % For copied charts:
    %   if this is the only chart in machine
    %     set machine default from this chart
    %   else if chart doesn't match machine
    %     preserve chart property but give a warning to confirm the user's intent.
    %
    actionLanguage = sf(GET,newChartId,'chart.actionLanguage');
    defaultActionLanguage = sf(GET,newMachineId,'machine.defaultActionLanguage');
    if(actionLanguage < 0)
        % new chart: chart inherits action language from machine
        sf(SET,newChartId,'chart.actionLanguage',defaultActionLanguage);
    elseif(isempty(sf(GET,newMachineId,'machine.charts')))
        % empty machine: machine inherits action language from chart
        sf(SET,newMachineId,'machine.defaultActionLanguage',actionLanguage);
        %   elseif(actionLanguage~=defaultActionLanguage)
        %      % machine has other charts; issue warning
        %      msg = ['Warning: Chart property ''Enable C-like bit operations'' ',10,...
        %            'is different from machine''s default property. If this difference is ',10,...
        %            'intentional, you can ignore this warning.'];
        %      %%%%WISH ask Paul for an informative warning message withe the chart name
        %      %%%%Add this to the documentation
        %      %%%%Push it into naglog
        %      disp(msg);
    end
end

if (oldMachineId ~= newMachineId)
    sf('MoveToMachine', newInstanceId, newMachineId);
    %% the above operations may have marked our oldmachine and oldmodel dirty
    %% even though they were clean to begin with. in which case, we must mark them
    %% clean again. note that the are two dirt flags of SL and SF are independent
    %% and need to be handled seperately.

    if(oldMachineWasClean)
        sf(SET,oldMachineId,'machine.dirty',0);
    end

    if( oldModelWasClean &...
            strcmp(get_param(oldModelH,'Lock'),'off') & ...
            strcmp(get_param(oldModelH,'Dirty'),'on'))
        [prevErrMsg, prevErrId] = lasterr;
        try,
            set_param(oldModelH,'Dirty','off');
        catch,
            lasterr(prevErrMsg, prevErrId);
        end
    end
end;
machineId = newMachineId;
if(realCopyFlag)
    % G175443: we need to do this
    sf('Toast',newChartId);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_copy_method(blockH, machModelH),
%
% Called directly after an SF block has been ***PASTED*** from the Simulink Clipboard,
% or a right click and drag operation OR when an sfLink is instantiated.
%
%	disp('SF BLOCK COPY');

machineId = blk_copy_and_real_copy(blockH,machModelH,0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_real_copy_method(blockH, machModelH),
%
% Called after a link break has occurred.
% disp('SF BLOCK REALCOPY');

machineId = blk_copy_and_real_copy(blockH,machModelH,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = acquire_or_create_machine_for_model(blockH, newModelH),
%
%
%
% Either the new model has a machine or not
newMachineId = sf('find', 'all', 'machine.simulinkModel', newModelH);
if model_is_a_library(newModelH),
    dstIsALibrary = 1;
else,
    dstIsALibrary = 0;
end;

switch(length(newMachineId)),
    case 0,
        newMachineId = sf('new', 'machine', '.name', get_param(newModelH, 'name'), '.simulinkModel', newModelH, '.isLibrary', dstIsALibrary);
    case 1,
    otherwise,
        warning('Multiple machines found for this model, picking first one.');
        newMachineId = newMachineId(1);
end;

% If this machine was deleted, undelete it
if sf('get', newMachineId, '.deleted'),
    sf('set', newMachineId, '.deleted', 0);
end;
machineId = newMachineId;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_destroy_method(blockH, machModelH),
%
% Simulink is about to destroy this block.
% Stateflow must now destroy it's components.
%
%	disp('SF BLOCK DESTROY');
machineId = machModelH;

if (machineId == -1), return; end;

% safe check for link at destroy time
if is_an_sflink(blockH),
    return;
end;

% If there's no instance for this Model, then we've already Closed the Model!
instanceId = get_param(blockH, 'userdata');

if ~is_an_sf_id(instanceId),
    return;
else
    chartId = sf('get',instanceId,'instance.chart');
    sf('delete', chartId);
end;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_clipboard_method(blockH, machModelH),
%
% *Copy* the passed in block's instance/chart to the clipboard.
% The block does not live in a valid system at this point! So, special precautions
% have to be taken.  No get_param() calls on the the modelH may be performed.
%
%	disp('SF BLOCK CLIPBOARD');
machineId = machModelH;

if (machineId == -1) return; end;

if is_an_sflink(blockH), return; end;

instanceId		= get_param(blockH, 'userdata');
if (~is_an_sf_id(instanceId)),
    set_param(blockH,'MaskType','');
    msg = sprintf('Cannot copy corrupted Stateflow block %s',get_param(blockH,'name'));
    error_msg(msg);
    machineId = machModelH;
    return;
end;
chartId			= sf('get', instanceId, '.chart');
machineOfChart			= sf('get', chartId, '.machine');
clipboardId		= get_clipboard_handle;
modelH			= sf('get', machineOfChart, '.simulinkModel');
instanceName	= sf('get', instanceId, '.name');
machineOfChartIsClean = sf('get',machineOfChart,'machine.dirty')==0;
modelIsClean = strcmp(get_param(modelH,'Dirty'),'off');
%%% by setting dontUpdateChartFileNumber=1, we tell CopyChart not to update
%%% chartFileNumber property of the chart. Doing this will enable us to
%%% cut and paste a chart without changing chartFileNumber unnecessarily.
dontUpdateChartFileNumber = 1;
newChartId		= sf('CopyChart', chartId,dontUpdateChartFileNumber);
newInstanceId	= sf('new', 'instance', '.name', instanceName, '.simulinkBlock', blockH, '.chart', newChartId);
set_param(blockH, 'userdata', newInstanceId);
sfclose(newChartId);
sf('MoveToMachine', newInstanceId, clipboardId);
%%% the above operations mark the source machine and model dirty
%%% hence we mark them clean if they were clean to begin with
if(machineOfChartIsClean)
    sf('set',machineOfChart,'machine.dirty',0);
end
if(modelIsClean)
    set_param(modelH,'Dirty','off');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_delete_method(blockH, machModelH),
%
% The delete function does one thing and one thing only --it
% moves said block's chart to the Stateflow clipboard.  This is in
% accordance with the Simulink/Stateflow Summit held March 1997 (i.e., to spec).
%	disp('STATEFLOW BLOCK DELETE');
machineId = machModelH;

if (machineId == -1) return; end;

%
% Locked models do not allow delete operations!
%
modelH = get_param(sfbdroot(blockH), 'handle');
if model_is_locked(modelH), return; end;

%
% The machine has already left memory, return.
% UNLESS the block is a link. If so, we must reset the
% activeInstance of a chart editor that may be pointing
% to it. G168881
if ~is_an_sf_id(machineId),
    if is_an_sflink(blockH),
        reset_active_instance(blockH);
    end
    return;
end;

%
% Process link destruction.
%
if is_an_sflink(blockH),
    sf('MachineDeletesfLink', machineId, blockH);
    reset_active_instance(blockH);
    return;
end;

move_instance_to_clipboard(blockH);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function move_instance_to_clipboard(blockH)
%
% Normal sfblock MoveToMachine code.
%
instanceId = get_param(blockH, 'userdata');
if ~is_an_sf_id(instanceId),
    % If there's no instance AND no machine, we must be closing the model.
    if ~bdroot_has_a_machine(blockH),
        return;
    else,
        set_param(blockH,'MaskType','');
        msg = sprintf('Cannot copy corrupted Stateflow block %s to clipboard',get_param(blockH,'name'));
        error_msg(msg);
        return;
    end;
end;

chartId		= sf('get', instanceId, '.chart');
clipboardId	= get_clipboard_handle;

% ASSERT that this instance is NOT on the clipboard
if isequal(sf('get', instanceId, '.machine'),clipboardId),
    warning('Stateflow Data Dictionary is out of sink with Simulink Model. If possible, exit MATLAB and reload model.')
    return;
end;

sfclose(chartId);
sf('MoveToMachine', instanceId, clipboardId);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_undoDelete_method(blockH, machModelH),
%
% Simulink just undid a block deletion. We need to find this block's
% Instance on the clipboard and move it and it's chart to the current machine.
%
%	disp('STATEFLOW BLOCK UNDODELETE');
machineId = machModelH;

modelH = get_param(sfbdroot, 'handle');
if model_is_locked(modelH), return; end;

% ASSERT only one machineId for this model
if sf('get', machineId, '.deleted'),
    sf('set', machineId, '.deleted', 0);
end;

if is_an_sflink(blockH),
    sf('MachineAddsfLink', machineId, blockH);
    sf('Explr','HIER');
    return;
end;

instanceId	= get_sf_block_instance_handle(blockH);
if(isempty(instanceId) | instanceId==0)
    return;
end;

chartId		= get_sf_block_chart_handle(blockH);
if(chartId==0)
    return;
end;
clipboardId = get_clipboard_handle;

% ASSERT that the instance AND chart are on the Clipboard
if (~isequal(sf('get', instanceId, '.machine'),clipboardId) | ~isequal(sf('get', chartId, '.machine'),clipboardId)),
    disp('Simulink/Stateflow clipboard missmatch! Recommend you exit MATLAB and reload.');
    return;
end;

sf('MoveToMachine', instanceId, machineId);

%
% Refresh all links pointing to this block.
%
links = find_system('LookUnderMasks','on','FollowLinks','on', 'MaskType','Stateflow','ReferenceBlock', blk_fullpath(blockH));
get_param(links, 'LinkStatus');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_name_change_method(blockH, machModelH),
%
%
%
machineId = machModelH;
modelH = get_param(sfbdroot(blockH), 'handle');

%%% Early return if the model is simulating
if(strcmp(get_param(modelH, 'SimulationStatus'),'running'))
    return;
end

isLocked = model_is_locked(modelH);

%
% Check for unloaded and/or locked machine scenarios.
% In either case, we can just set the name and return
% since the name change must have just been a model name change
% (and NOT due a block changing its name).
%
if isLocked | (machineId == -1),
    %
    % Force load by unlocking.
    %
    set_param(modelH,'lock','off');

    %
    % Update the machine's name.
    %
    machineId = sf('find','all','machine.simulinkModel',modelH);
    sf('set', machineId, '.name', get_param(modelH, 'Name'));

    %
    % Be a good citizen and relock it if it was locked to begin with.
    %
    if isLocked, set_param(modelH, 'lock', 'on'); end;
    return;
end;


if is_an_sflink(blockH),
    linkChartId = get_param(blockH,'userdata');
    if(isempty(linkChartId))
        % G133483: For library models containing link-charts
        % we will not use userdata to store linkchart id as set_param
        % fails when the library is locked. We use a slightly slower
        % sf('find') to get at the linkchart object.
        linkChartId = sf('find','all','linkchart.handle',blockH);
    end
    sf('set', linkChartId, 'linkchart.name',get_instance_name_from_block(blockH));
    return;
end;

instanceId = get_sf_block_instance_handle(blockH);

if (is_an_sf_id(instanceId))
    [oldInstanceName, oldMachineId, chartId] = sf('get', instanceId,'.name','.machine','.chart');
    [oldMachineName, oldModelH] = sf('get',oldMachineId,'.name','.simulinkModel');
    newMachineName = get_param(modelH,'Name');

    newInstanceName = get_instance_name_from_block( blockH );

    %
    % Either we've:
    % 	  - moved the block to a new location in the current machine's hierarchy
    %    - moved the block to an entirely new machine
    % 	  - or, renamed the current machine (Save As/set_param())
    %
    if (~strcmp(oldMachineName, newMachineName) | ~strcmp(oldInstanceName,newInstanceName))
        sf('set', instanceId, '.name', newInstanceName);

        %
        % Update machine name if necessary
        %
        if (~strcmp(oldMachineName, newMachineName))

            %
            % Check for SaveAs/set_param() case.
            %
            if (modelH == oldModelH),
                sf('set', machineId, '.name', newMachineName);
            else,
                %
                % Block has changed models ==> so, change your machine
                % Either the new model contains a machine or not, do the right thing...
                %
                newMachineId = sf('find', 'all', 'machine.simulinkModel', newModelH);
                switch(length(newMachineId)),
                    case 0,
                        newMachineId = sf('new', 'machine', '.name', newMachineName, '.simulinkModel', newModelH);
                    case 1,
                    otherwise,
                        warning('Multiple machines found for this model, picking first one.');
                        newMachineId = newMachineId(1);
                end;

                %
                % If this machine was previously deleted, undelete it.
                %
                if sf('get', newMachineId, '.deleted'),
                    sf('set', newMachineId, '.deleted', 0);
                end;

                %
                % Move the instance to the new machine.
                %
                sf('MoveToMachine', instanceId, newMachineId);
                machineId = newMachineId;
            end
        end
    end
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = blk_iconx_method,
%
%  Generates X data for curved corner blocks.
%
x = [...
    0.085857;0.073638;0.061668;0.050191;0.039439;0.029633;0.020971;0.013629;0.007759;0.003478;0.000874;0;0;0.000874;0.003478;0.007759;0.013629;0.020971;0.029633;0.039439;0.050191;0.061668;0.073638;0.085857;0.914143;0.926362;0.938332;0.949809;0.960561;0.970367;0.979029;0.986371;0.992241;0.996522;0.999126;1;1;0.999126;0.996522;0.992241;0.986371;0.979029;0.970367;0.960561;0.949809;0.938332;0.926362;0.914143;0.089439;
    ... inner icon xdata
    NaN;0.4;0.4;0.405;0.415;0.48;0.495;0.5;0.5;0.495;0.48;0.415;0.405;0.4;
    NaN;0.5;0.5;0.505;0.515;0.585;0.595;0.6;0.6;0.595;0.58;0.515;0.505;0.5;
    NaN;0.44;0.425;0.44;0.455;0.44;0.44;0.445;0.455;0.47;0.49;0.5;
    NaN;0.55;0.535;0.55;0.565;0.55;0.55;0.55;0.545;0.53;0.51;0.5;
    ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = blk_icony_method,
%
%  Generates Y data for curved corner blocks.
%
y = [...
    0;0.001219;0.00485;0.010819;0.019005;0.029242;0.041321;0.054995;0.069987;0.085992;0.102683;0.119722;0.880278;0.897317;0.914008;0.930013;0.945005;0.958679;0.970758;0.980995;0.989181;0.99515;0.998781;1;1;0.998781;0.99515;0.989181;0.980995;0.970758;0.958679;0.945005;0.930013;0.914008;0.897317;0.880278;0.119722;0.102683;0.085992;0.069987;0.054995;0.041321;0.029242;0.019005;0.010819;0.00485;0.001219;0;0;
    ... inner icon ydata
    NaN;0.625;0.57;0.555;0.55;0.55;0.555;0.57;0.63;0.645;0.65;0.65;0.64;0.625;
    NaN;0.43;0.37;0.355;0.35;0.35;0.355;0.37;0.425;0.445;0.45;0.45;0.445;0.43;
    NaN;0.525;0.525;0.55;0.525;0.525;0.5;0.465;0.425;0.405;0.4;0.4;
    NaN;0.48;0.48;0.45;0.48;0.48;0.515;0.55;0.58;0.595;0.6;0.6;
    ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = blk_icont_method(blockH),
%
%  Generates str data for block icon
%
if is_an_sflink(blockH),
    str = 'L';
else,
    str = '';
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = mdl_startfcn_method(machineId, fromCmdLine),
%
%  Called at start of simulation time (after commited simulation)
%
if (nargin > 1 & fromCmdLine),
    sfsim('running_from_command_line', machineId);
else,
    sfsim('running', machineId);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = mdl_stopfcn_method(machineId),
%
%  Called at stop simulation time
%
modelH = sf('get', machineId, '.simulinkModel');
switch get_param(modelH, 'simulationstatus')
    case 'terminating'
    case 'stopped'
    otherwise, return
end
sfsim('stop', machineId);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = mdl_exitdebug_method(machineId)

sfdebug('gui', 'stop_debugging', machineId);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = mdl_compile_fail_method(machineId)
%
%  Called when compilation fails
%

sfsim('compile_fail', machineId);


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
    blockOfInstance = refBlock;
else,
    blockOfInstance = blockH;
end;
instanceId = get_param(blockOfInstance, 'userdata');
if(~is_an_sf_id(instanceId))
    % Several Simulink blocks have the nasty habit of
    % scribbling over the userdata of other blocks
    % thru use of gcbh. Source of major corruptions
    % for the last several years. Example: XY Graph block
    % When we find that the instanceId is corrupted,
    % we must try to find an instance that points
    % back to this block and re-establish the binding.
    % G120650
    tryInstanceId = sf('find','all','instance.simulinkBlock',blockOfInstance);
    if(~isempty(tryInstanceId))
        instanceId = tryInstanceId;
        set_param(blockOfInstance, 'userdata',instanceId);
    else
        % return the corrupted version
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chartH = get_sf_block_chart_handle(blockH),
%
%
%
instanceH = get_sf_block_instance_handle(blockH);
if (is_an_sf_id(instanceH)),	chartH = sf('get', instanceH, '.chart');
else,
    error_msg('Invalid instance handle detected');
    chartH = 0;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = mdl_close_method(machineId),
%
%
%
%	disp('MODEL CLOSE FCN');

% If this hasn't been loaded, just return.
if ~is_an_sf_id(machineId),
    machineId = -1;
    return;
end;

ted_the_editors(machineId);
%%WISH update titles on library charts when appropriate

sf('delete',machineId);
sf('Explr','HIER');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bool = this_is_on_the_clipboard(h),
%
%
%
bool = 0;

if (~is_an_sf_id( h)) return; end;

[chartIsa, instanceIsa] = sf('get', 'default', 'chart.isa', 'instance.isa');

switch(sf('get', h, '.isa')),
    case chartIsa,
    case instanceIsa,
    otherwise, return;
end;

clipboardH = get_clipboard_handle;

bool = isequal(sf('get', h, '.machine'),clipboardH);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clipboardH = get_clipboard_handle,
%
%
%
clipboardH = sf('find','all','machine.name','$$Clipboard$$');
switch(length(clipboardH)),
    case 0,
        warning('No clipboard machine found, creating new one.');
        clipboardH = sf('new', 'machine', '.name', '$$Clipboard$$');
    case 1, return;
    otherwise,
        warning('Multiple clipboards in memory.');
        sf('delete', clipboardH(2:end));
        clipboardH = clipboardH(1);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function name = get_instance_name_from_block( blockH )
%
%
%
name = getfullname(blockH);
slashInd = find(name=='/');
name = name((slashInd(1)+1):end);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = bdroot_has_a_machine(blockH)
%
%
%
modelH = get_param(sfbdroot(blockH),'handle');
machines = sf('find','all','machine.simulinkModel',modelH);
switch length(machines),
    case 0,		result = 0;
    otherwise,	result = 1;
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
function is_eml_Lib = is_an_eml_slLibrary(blockH)
%
% Determine if the block is a EML_LIB library block and an eML Block
is_eml_Lib = 0;

srcLibrary = get_param(blockH,'ReferenceBlock');
if(strcmp(bdroot_from_block_path(srcLibrary), 'eml_lib'))
    is_eml_Lib = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLib = is_an_sflib(blockH),
%
% Determine if a block is a library block (sflib)
%
modelH = sfbdroot(blockH);
if ~is_an_sflink(blockH) & model_is_a_library(modelH),
    isLib = 1;
else,
    isLib = 0;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = model_is_a_library(modelH),
%
%
%
if strcmp(lower(get_param(modelH,'BlockDiagramType')),'library'), result = 1;
else, result = 0;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = model_is_locked(modelH),
%
%
%
result = strcmp(lower(get_param(modelH, 'lock')), 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_link_break_method(blockH, machineId),
%
%
%
%
% Unlockd this puppy if needs be.
%
modelH = sfbdroot(blockH);
relock = model_is_locked(modelH);
if(relock)
    set_param(modelH,'lock','off');
end

%
% Just in case this link resided in an unloaded machine-model, get the new id.
%
machineAlreadyExists = 1;
switch(machineId)
    case -1,
        %%% The library has Stateflow stuff but not loaded yet
        machineId = sf('find', 'all', 'machine.simulinkModel', modelH);
        machineId = machineId(1);
    case 0,
        %%% The library does not have any Stateflow stuff
        machineAlreadyExists = 0;
    otherwise,
        %%% The library has Stateflow stuff and is loaded
end;

clipboardId = get_clipboard_handle;

% JRT Wunsch: it would be nice at this point to check for deleted instances
% of this block's old instance on the Stateflow clipboard so that previous
% editing could be recouped; however, we would need to give the user a dialog
% to ask if they wanted a new raw copy of the reference block or if they wanted
% to get their previous changes back.

%
% Copy verbatim from the referenceBlock.
%
machineId = blk_real_copy_method(blockH, machineId);

if(relock)
    set_param(modelH,'lock','on');
end

if(machineAlreadyExists)
    sf('MachineDeletesfLink', machineId, blockH);
    reset_active_instance(blockH);
end
change_icon_to(blockH, 'blockAfterLinkBreak');
sf('Explr','HIER');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = blk_undo_link_break_method(blockH, machineId),
%
% Move the created instance to the clipboard, reset the instanceid for
% this link to match it's refBlock and add it back to the machine as a link.
%
%
% Move the instance/chart pair for this block to the clipboard.
%
if is_an_sflink(blockH),
    % G156737
    % Simulink is spuriously calling undo-link-break for
    % Stateflow link charts. I found this to happen in a few cases
    % Be safe and return early.
    return;
end

move_instance_to_clipboard(blockH);

%
% Reinitialize this link with the refblock instanceId.
%
instanceId = get_sf_block_instance_handle(blockH);
if(isempty(instanceId) | instanceId==0)
    return;
end

set_param(blockH, 'userdata', instanceId);

%
% Add an sfLink to this machine.
%
sf('MachineAddsfLink', machineId, blockH);
change_icon_to(blockH, 'link');

sf('Explr','HIER');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = mdl_lock_method(machineId),
%
%
%
if is_a_model_handle(machineId) machineId = -1;return; end;

sf('set', machineId, '.locked', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = mdl_unlock_method(machineId),
%
%
%
%
% If a model handle was passed in, this must be an unloaded library. Load it.
%
if is_a_model_handle(machineId),
    machineId = load_machine_from_file(machineId);
end;
sf('set', machineId, '.locked', 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = is_a_model_handle(mH),
%
%
%
if (mH ~= 0 & ~is_an_sf_id(mH) & ishandle(mH)), result = 1;
else result = 0;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = is_an_sf_id(mId),
%
%
%
result = 0;

if(isempty(mId)) return;end;

% If it ain't an int it ain't an id!
if ((floor(mId) - mId) ~= 0) return; end;

if sf('ishandle', mId), result = 1; end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fullPath = blk_fullpath(blockH)
%
%
%
parent = get_param(blockH, 'Parent');
name = get_param(blockH, 'Name');
fullPath = [parent,'/',name];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = mdl_fix_broken_links_method(machModelH)
%
% Updates all sfLinks for a given machine. This function is
% critical for codegen which must rely on the machine
% level sfLinks vector.  This rountine forces that list to
% be up to date with Simulink.
%
modelH = sf('get', machModelH, '.simulinkModel');
%
% Exteremly fast and complete method to update ALL links in a model.
% This find_system does not suffer from speed issues since it will
% never actually find anything.  The output will always be empty; however,
% it cleanly forces Simulink to reevaluate all of it's links.  When these links
% are updated, the standard SLSF() callbacks will bring Stateflow and Simulink into
% sync.
%
junk = find_system(modelH, 'LookUnderMasks','On', 'LinkStatus', 'Implicit');
out = machModelH;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rootName = get_root_name_from_block_path(blkpath)
%
%
%
ind = min(find(blkpath=='/'));
rootName = blkpath(1:(ind(1)-1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function error_msg(str)
%
%
%
disp( str );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function reset_active_instance(blockH)

[prevErrMsg, prevErrId] = lasterr;
try,
    chartId = sf('find','all','chart.activeInstance',blockH);
    sf('set',chartId,'chart.activeInstance',0.0);
catch,
    lasterr(prevErrMsg, prevErrId);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_active_instance(blockH)

[prevErrMsg, prevErrId] = lasterr;
try,
    ref = get_param(blockH, 'ReferenceBlock');
    refH = get_param(ref,'handle');
    instanceId = sf('find','all','instance.simulinkBlock',refH);
    if(~isempty(instanceId))
        fullPathOfBlock = getfullname(blockH);
        chartId = sf('get',instanceId,'instance.chart');
        if( sf('get',chartId,'chart.visible') & ...
                strcmp(sf('get',chartId,'chart.fullPathOfActiveInstance'),fullPathOfBlock))
            sf('set',chartId,'chart.activeInstance',blockH);
        end
    end
catch,
    lasterr(prevErrMsg, prevErrId);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isImplicit = is_an_implicit_link(blockH)
%%%% IMPORTANT: this is a safe/lightweight way of
%%%% figuring out if a link is an implicit link
%%%% without using get_param(blockH,'linkstatus')
%%%% that can cause spurious block_copy events to be
%%%% pumped back into Stateflow.
parentH = get_param(get_param(blockH,'parent'),'handle');
if(~strcmp(get_param(parentH,'type'),'block_diagram') &...
        ~isempty(get_param(parentH,'referenceblock')))
    isImplicit = 1;
else
    isImplicit = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bdRootName = bdroot_from_block_path(blockPath)
%%%% lightweight bdroot from blockPath
%%%%
bdRootName = strtok(blockPath,'/');
