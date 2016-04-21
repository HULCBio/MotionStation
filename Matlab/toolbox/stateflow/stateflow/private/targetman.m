function status = targetman(method, targetId, syncTarget, forceRebuildAll, parentTargetId,chartId,mainMachineId,libraryIndex)
% STATEFLOW TARGET MANAGER
%   STATUS = TARGETMAN( METHOD, TARGETID, SYNCTARGET, FORCEREBUILDALL)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.89.4.12 $  $Date: 2004/04/15 01:01:05 $

[machineId,targetName,dialogFigure] = sf('get',targetId,'.machine','.name','.dialog');
machineName = sf('get',machineId,'.name');
sf('set',machineId,'machine.activeTarget',targetId);
isSfunTarget = strcmp(targetName,'sfun');

if nargin<3, syncTarget      = 0;        end;
if nargin<4, forceRebuildAll = 0;        end;
if nargin<5, parentTargetId  = targetId; end;
if nargin<6, chartId  = []; end; % sometimes you want to parse a single chart
if nargin<7, mainMachineId = [];end;
if nargin<8, libraryIndex = 0;end;

displayIfError = '';
set_busy(dialogFigure);
status = 0; % Always return 0 for legacy

try,
    if(strcmp(targetName,'sfun'))
        check_not_simulating( targetId, machineId,machineName, targetName);
    end;
    
    machineType = get_machine_type(machineId);
    
    switch method,
        case 'clean_objects'
         	msg = sprintf('%s clean target directory for model "%s"...',machineType,machineName);
         	sf_display('Coder',msg,2);
            method_nag_wrapper('Clean', 'clean_objects_method', targetId, parentTargetId, syncTarget, forceRebuildAll,mainMachineId,libraryIndex);
         	msg = sprintf('Done\n');
         	sf_display('Coder',msg,2);
        case 'clean'
         	msg = sprintf('%s clean target directory for model "%s"...',machineType,machineName);
         	sf_display('Coder',msg,2);
            method_nag_wrapper('Clean', 'clean_method', targetId, parentTargetId, syncTarget, forceRebuildAll,mainMachineId,libraryIndex);
         	msg = sprintf('Done\n');
         	sf_display('Coder',msg,2);
        case 'parse',
            method_nag_wrapper('Parse', 'parse_method', targetId, parentTargetId,chartId,mainMachineId);
        case 'code'
            % before codegen we must make sure the sfun
            % block has the correct set of params str.
            method_nag_wrapper('Parse', 'parse_method', targetId, parentTargetId,[],mainMachineId);
            method_nag_wrapper('Coder', 'code_method', targetId, parentTargetId, syncTarget, forceRebuildAll,mainMachineId,libraryIndex);
        case 'make',
            method_nag_wrapper('Make',  'make_method', targetId, parentTargetId);
        case 'build'
            
         	msg = sprintf('%s parsing for model "%s"...',machineType,machineName);
         	sf_display('Coder',msg,2);
            % before codegen we must make sure the sfun
            % block has the correct set of params str.
            method_nag_wrapper('Parse', 'parse_method', targetId, parentTargetId,[],mainMachineId);
         	msg = sprintf('Done\n');
         	sf_display('Coder',msg,2);
         	
            msg = sprintf('%s code generation for model "%s"...',machineType,machineName);
         	sf_display('Coder',msg,2);
            method_nag_wrapper('Coder', 'code_method',  targetId, parentTargetId, syncTarget, forceRebuildAll,mainMachineId,libraryIndex);
         	msg = sprintf('Done\n');
         	sf_display('Coder',msg,2);
         	
            if(isSfunTarget) 
                msg = sprintf('%s compilation for model "%s"...',machineType,machineName);
             	sf_display('Coder',msg,2);
            end
            method_nag_wrapper('Make',  'make_method',  targetId, parentTargetId);
            if(isSfunTarget) 
                msg = sprintf('Done\n');
                sf_display('Coder',msg,2);
            end
        otherwise,
            construct_error(targetId,'Internal','Bad targetman method');
    end
    
catch,
    if (isempty(lasterr)),
        error(slsfnagctlr('NagToken'));
    else,                
        error(lasterr);
    end;
end;

set_idle(dialogFigure);

%----------------------------------------------------------------------------------
function method_nag_wrapper(methodType, fcn, targetId, parentTargetId, varargin),
%
%
%
methodTimeStart = clock;
log_file_manager('begin_log');

lasterr('');

try,   
    [status fileNameInfo] = feval(fcn, targetId, parentTargetId, varargin{:});
catch, 
    status = 1;
    fileNameInfo = [];
end;

logTxt = log_file_manager('get_log');
machineId = sf('get',targetId,'target.machine');
machineName = sf('get',machineId,'machine.name');

if ~isempty(logTxt),
    nag             = slsfnagctlr('NagTemplate');
    if status == 1, nag.type = 'Error'; else,  nag.type = 'Log'; end;
    nag.msg.details = logTxt;
    nag.msg.type    = methodType;
    nag.msg.summary = '';
    nag.component   = methodType;
    nag.sourceName   = sf('get',machineId,'machine.name');
    nag.sourceFullName   = sf('get',machineId,'machine.name');
    nag.ids         = machineId;
    nag.blkHandles  = [];
    
    % Set the reference directory for the nag to be pushed.
    % this will be used by the slsfnagctlr to resolve relative
    % file links.
    switch (methodType)
        case {'Coder','Make'}
            if isempty(fileNameInfo)
                fileNameInfo = sfc('filenameinfo',targetId,parentTargetId);
            end
            nag.refDir = fileNameInfo.targetDirName;
        case 'Parse'
            nag.refDir = '';
        otherwise,
            nag.refDir = '';
    end
    slsfnagctlr('Naglog', 'push', nag);
    
end;
log_file_manager('end_log');
%%% IMPORTANT PROFILING CODE:
%%% We measure the time taken for parse/code/make
%%% stages and cache it away on the target.

methodTime = etime(clock,methodTimeStart);
switch(methodType)
    case 'Parse'
        sf('set',targetId,'target.time.parse',methodTime);
    case 'Coder'
        sf('set',targetId,'target.time.code',methodTime);
    case 'Make'
        sf('set',targetId,'target.time.make',methodTime);
end
if status == 1, 
    if(~isempty(logTxt))
        disp(logTxt);
    end
    error(lasterr); 
end;


%----------------------------------------------------------------------------------
function [status fileNameInfo] = parse_method( targetId, parentTargetId,chartId,mainMachineId)
%
%
%
status = 0;
fileNameInfo = [];
machineId = sf('get',targetId,'target.machine');
ted_the_editors(machineId);

target_methods('preparse',targetId,parentTargetId);
throwError = parse_kernel(machineId,chartId,targetId,parentTargetId,mainMachineId);
target_methods('postparse',targetId,parentTargetId);
if(throwError)
    statusString = 'failed';
else
    statusString = 'successful';
end
if(isempty(chartId))
    sf_display('Parse',sprintf('Parsing %s for machine: "%s"(#%d)', statusString,sf('get',machineId,'.name'),machineId));
else
    sf_display('Parse',sprintf('Parsing %s for chart: "%s"(#%d)', statusString,sf('get',chartId,'.name'),chartId));
end

if(throwError)
    if(~isempty(lasterr))
        error(lasterr);
    else
        error(slsfnagctlr('NagToken'));
    end
end

%--------------------------------------------------------------------------
function [status fileNameInfo] = clean_objects_method( targetId, parentTargetId, syncTarget ,forceRebuildAll,mainMachineId,libraryIndex)
machineId = sf('get',targetId,'.machine');
lasterr('');
try,
    fileNameInfo = sfc('clean_objects',targetId,parentTargetId,mainMachineId,libraryIndex);
    status = delete_target_sfunction_func(targetId);
catch,
    status = 1;
end

if status==1,
    sf_display('Coder',sprintf('Target directory clean failed %s%c\n',clean_error_msg(lasterr),7));
end;


%--------------------------------------------------------------------------
function [status fileNameInfo] = clean_method( targetId, parentTargetId, syncTarget ,forceRebuildAll,mainMachineId,libraryIndex)

machineId = sf('get',targetId,'.machine');

lasterr('');
try,
    fileNameInfo = sfc('clean',targetId,parentTargetId,mainMachineId,libraryIndex);
    status = delete_target_sfunction_func(targetId);
catch,
    status = 1;
end

if status==1,
    sf_display('Coder',sprintf('Target directory clean failed %s%c\n',clean_error_msg(lasterr),7));
end;

%-----------------------------------------------------------------------------------
function [status fileNameInfo] = code_method( targetId, parentTargetId, syncTarget ,forceRebuildAll,mainMachineId,libraryIndex)
%
%
%

if syncTarget==1
    sync_target(targetId,parentTargetId,mainMachineId);
end

machineId = sf('get',targetId,'.machine');

if(forceRebuildAll)
    codeMethod = 'codeNonIncremental';
else
    codeMethod = 'codeIncremental';
end

lasterr('');
try,
    coder_error_count_man('reset');
    target_methods('precode',targetId,parentTargetId);
    fileNameInfo = sfc(codeMethod,targetId,parentTargetId,mainMachineId,libraryIndex);
    target_methods('postcode',targetId,parentTargetId);
    status = coder_error_count_man('get')~=0;
catch,
    status = 1;
end

if status==1,
    sf_display('Coder',sprintf('Code generation failed %s%c\n',clean_error_msg(lasterr),7));
else,
    sf_display('Coder',sprintf('Code generation successful for machine: "%s"',sf('get',machineId,'.name')));
end;

targetName = sf('get',targetId,'target.name');
if (strcmp(targetName,'rtw') & status == 0)
    % complete success deserves an update of the target checksum for rtwTarget
    % for all other targets we do this in make_method_mathod
    infomatman('save','binary',machineId,targetId);
end


%---------------------------------------------------------------------------------------
function [status fileNameInfo] = make_method( targetId,parentTargetId )
%
%
%
status = 1;
machineId = sf('get', targetId, '.machine');

targetName = sf('get',targetId,'target.name');

makeInfo = sfc('makeinfo',targetId,parentTargetId);
fileNameInfo = makeInfo.fileNameInfo;

simulationTarget = strcmp(targetName,'sfun');
mexTarget = 0;
rtwTarget = strcmp(targetName,'rtw');

if simulationTarget
    status = delete_target_sfunction_func(targetId);
    if (status == 1), throw_make_error; end;
    
    str = sprintf('Making simulation target "%s", ... \n', makeInfo.fileNameInfo.mexFunctionName);
    sf_display('Make', str);
    
    if(ispc),
        makeCommand = ['call ',makeInfo.fileNameInfo.makeBatchFile];
    else,
        gmake = [sf('Root'),'private/bin/',lower(computer),'/make'];
        if ~exist(gmake,'file')
            gmake = 'make';  % gmake==make on lnx86
        end
        makeCommand = [gmake,' -f ',makeInfo.fileNameInfo.unixMakeFile];
    end;
    modelDirectory = pwd;
    
    safely_execute_dos_command(makeInfo.fileNameInfo.targetDirName,makeCommand);
    
    
    if(sf('get',machineId,'machine.isLibrary')),
        if(isunix)
            extString = 'a';
        else
            extString = 'lib';
        end
    else,
        extString = mexext;
    end;
    
    dllFileName = [makeInfo.fileNameInfo.mexFunctionName,'.', extString];
    srcFileName = fullfile(makeInfo.fileNameInfo.targetDirName,dllFileName);
    destFileName = fullfile(modelDirectory,dllFileName);
    if(exist(srcFileName,'file'))
        sf_display('Make',sprintf('Make successful for machine: "%s"', sf('get',machineId,'.name')));
        if(~strcmp(modelDirectory,makeInfo.fileNameInfo.targetDirName))
            
            %G203073           
            [copySuccess, errMsg] = move_from_project_dir(makeInfo.fileNameInfo.targetDirName, dllFileName);
            
            if ~copySuccess
                throw_make_error(errMsg);
            end
            
            binaryDirInfo = dir(destFileName);
            binaryDateStr = binaryDirInfo.date;
            if(ispc)
                csfFile = [makeInfo.fileNameInfo.mexFunctionName,'.csf'];
                csfSourceFile = fullfile(makeInfo.fileNameInfo.targetDirName,csfFile);
                csfDestFile = fullfile(modelDirectory,[makeInfo.fileNameInfo.mexFunctionName,'.csf']);
            else
                csfFile = [dllFileName,'.csf'];
                csfSourceFile = fullfile(makeInfo.fileNameInfo.targetDirName,csfFile);
                csfDestFile = fullfile(modelDirectory,[dllFileName,'.csf']);
            end
            if(exist(csfSourceFile,'file'))
                try,
                    if(exist(csfDestFile,'file'))
                        sf_delete_file(csfDestFile,1);
                    end
                    
            		%G203073           
                    [copySuccess, errMsg] = move_from_project_dir(makeInfo.fileNameInfo.targetDirName, csfFile);
                end
            end
            
            
            %%% this is an undocumented feature given to us by
            %%% MATLAB parser. we call fschange function on pwd
            %%% to inform MATLAB parser that something changed
            %%% so that it will load the newly generated SFunction DLL
            fschange(pwd);
        end;
    else,
        throw_make_error;
    end
    binaryFileInfo = dir(destFileName);
    binaryDateStr = sf_date_num(binaryFileInfo.date);
    
else
    target_methods('make',targetId,parentTargetId);
    binaryDateStr = sf_date_str;
end;


if ~rtwTarget
    % complete success deserves an update of the target checksum
    % for rtwTarget, we do this in code_mathod
    infomatman('save','binary',machineId,targetId,1,binaryDateStr);
end
status = 0;


%---------------------------------------------------------------------------------------------------
function status = delete_target_sfunction_func( target )
%
%
%
status = 1;
if (~sf('get', target, '.simulationTarget')),
    status = 0;
    return;
end;

machineId	= sf('get', target, '.machine');
machineName	= sf('get', machineId, '.name');
targetName	= sf('get', target, '.name');

mexFunctionName = [machineName,'_sfun'];
if(~sf('get',machineId,'machine.isLibrary'))
    if exist(mexFunctionName,'file'),
        prevErr = lasterr;
        try,
            feval(mexFunctionName,'sf_mex_unlock');
        catch
            lasterr(prevErr);
        end
        clear(mexFunctionName); 
    end;
    
    sfunctionFileName = fullfile(pwd,[mexFunctionName,'.', mexext]);
    if exist(sfunctionFileName,'file')
        try, sf_delete_file(sfunctionFileName); end;
        fschange(pwd); % needed on network dirs for MATLAB to know the dir has changed
    end
    if exist(sfunctionFileName,'file')
        % this means delete failed. must be a locking problem. try clear('mex')
        sf_display('Make',sprintf('%s could not be deleted. Trying to delete again.',sfunctionFileName));
        clear('mex');
        try, sf_delete_file(sfunctionFileName); end
        fschange(pwd); % needed on network dirs for MATLAB to know the dir has changed
    end
    
    if exist(sfunctionFileName,'file')
        msgString = ['Two attempts to delete ',sfunctionFileName,' have failed.'];
        msgString = [msgString,10,'This file is either not writable or is locked by another process.'];
        sf_display('Make', msgString);
        status = 1;
        return;
    end
else
    if(isunix)
        libext = 'a';
    else
        libext = 'lib';
    end
    
    sfunctionFileName = fullfile(pwd,[mexFunctionName,'.',libext]);
    if exist(sfunctionFileName,'file'),
        try, sf_delete_file(sfunctionFileName);
        catch,
            status = 1;
            sf_display('Make',sprintf('Problem deleting target lib-File %s',sfunctionFileName) );
            return;
        end
    end
end
status = 0;


function check_not_simulating( targetId, machineId, machineName, targetName)
if (sf('get',targetId,'.simulationTarget'))
    simStatus = get_param(machineName, 'SimulationStatus');
    switch(simStatus)
        case {'stopped','initializing'}
            % do nothing
        case {'running','paused'}
            construct_error(machineId,'Make',sprintf('%s is running --cannot operate on target: %s, during simulation.',machineName,targetName),1);
        otherwise,
            % unknown simulation status. go thru with make
    end
end


function set_busy( dialogFigure )
if dialogFigure==0 | ~ishandle(dialogFigure), return; end
set(dialogFigure,'Pointer','watch');

function set_idle( dialogFigure )
if dialogFigure==0 | ~ishandle(dialogFigure), return; end
set(dialogFigure,'Pointer','arrow');

%----------------------------------------------------------------------------------
function throw_make_error(msg),
%
% Throws a make error with the proper slsf-token.
%
if nargin > 0 & ~isempty(msg) 
    sf_display('Make', msg); 
end;

error(slsfnagctlr('NagToken'));


%----------------------------------------------------------------------------------
function [copySuccess, errMsg] = my_movefile(src,dst)

if ispc
    dos(['move "', src, '" "', dst, '"']);
else
    unix(['mv ', src, ' ', dst]);
end

copySuccess = exist(dst,'file');
    
errMsg = '';
if(~copySuccess) 
    errMsg = sprintf('moving %s to %s failed.',src,dst);
else
   if ispc
        dos(['attrib -r "', dst, '"']);
    else
        unix(['chmod +w ',dst]);
    end
end


%----------------------------------------------------------------------------------
function [copySuccess, errMsg] = move_from_project_dir(projectDir, fileName)

currDir = cd(projectDir);
if ispc
    relPath = '..\..\..\..\..';
    dos(['copy "', fileName, '" ', relPath]);
%    dos(['move "', fileName, '" ', relPath]);
else
    relPath = '../../../../..';
    unix(['mv ', fileName, ' ', relPath]);
end


cd(currDir);

copySuccess = exist(fullfile(pwd,fileName),'file');
    
errMsg = '';
if(~copySuccess) 
    errMsg = sprintf('moving %s from %s to %s failed.',fileName,projectDir,pwd);
else
   if ispc
        dos(['attrib -r "', fileName, '"']);
    else
        unix(['chmod +w ',fileName]);
    end
end

function machineTypeStr = get_machine_type(machineId)
   
    allEmlBlocks = eml_blocks_in(machineId);
    allCharts = sf('get',machineId,'machine.charts');
    if(isempty(allEmlBlocks))
      machineTypeStr = 'Stateflow';
    elseif(length(allEmlBlocks)==length(allCharts))
      machineTypeStr = 'Embedded MATLAB';
    else 
      machineTypeStr = 'Stateflow/Embedded MATLAB';
    end
    
