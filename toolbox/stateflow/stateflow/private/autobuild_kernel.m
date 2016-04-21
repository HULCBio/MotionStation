function status = autobuild_kernel(machineId,targetName,buildType,rebuildAllFlag,showNags,chartId)
% DONT CALL THIS DIRECTLY. CALL AUTOBUILD_DRIVER INSTEAD
% STATUS = AUTOBUILD_KERNEL( MACHINENAMEORID,
%                     TARGETNAME,
%                     BUILDTYPE={'parse','code','make','build'},
%                     REBUILDALLFLAG={'yes','no'}, %% relevant only if BUILDTYPE is 'code' or 'build'
%                     SHOWNAGS={'yes','no'})
%                     CHARTID (relevant only if buildtype is parse and you want to parse single chart)
%
%

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/15 00:56:01 $




status = 0;

[machineId,machineName] = unpack_machine_id(machineId);

if (nargin<3),   buildType 	    = 'build'; end;
if (nargin<4),   rebuildAllFlag = 0;       end;
if (nargin<5),   showNags       = 1;   end;
if (nargin<6),   chartId        = [];   end;

if(ischar(rebuildAllFlag))
    rebuildAllFlag = strcmp(rebuildAllFlag,'yes');
end
if(ischar(showNags))
    showNags = strcmp(showNags,'yes');
end
if(strcmp(targetName,'rtw'))
    if ~sf('Feature', 'RTW Incremental CodeGen')
        rebuildAllFlag = 1;
    end
end


slsfnagctlr('Clear', machineName, 'Stateflow Builder');
sfdebug('sf','build_start',machineId);
lasterr('');
try,
    status = autobuild_local(machineId,targetName,rebuildAllFlag,buildType,chartId,showNags);
catch,
    sfdebug('sf','build_end',machineId);
    status = 1;
end

if(showNags),
    slsfnagctlr('ViewNaglog');
    symbol_wiz('View', machineId);
else
    if status==1
        error(lasterr);
    end
end

%------------------------------------------------------------------------------------------------------
function status = autobuild_local(machineId,targetName,rebuildAllFlag,buildType,chartId,showNags)
%
%
%

lasterr('');

status = 0;

if strcmp(targetName,'rtw') && ~sf('License','coder',machineId)
   error(['To build RTW with Stateflow blocks requires a valid ', ...
         'Stateflow Coder license.']);
end

targetId  = acquire_target(machineId,targetName);

applyToAllLibs = sf('get',targetId,'target.applyToAllLibs');

ted_the_editors(machineId);

machineName = sf('get',machineId,'.name');

modelIsLibrary = sf('get',machineId,'machine.isLibrary');

if strcmp(targetName,'sfun') & rebuildAllFlag~=2
    sfLinks = machine_bind_sflinks(machineId,0);
else
    % if rebuild-all flag is 2 or if the target is not sfun, their do
    % find_system. otherwise, we skip it (above) to achieve a bit of
    % speed-up
    sfLinks = machine_bind_sflinks(machineId,1);
end

numLinksInMachine = length(sfLinks);
numChartsInMachine = length(sf('get',machineId,'machine.charts'));
%%%early return if the machine does not need code gen. i.e. no charts or links
if(~modelIsLibrary && numLinksInMachine==0 && numChartsInMachine==0), return;
elseif(modelIsLibrary && numChartsInMachine==0),                      return;
end

error_check_current_dir(machineId,machineName);

if(~modelIsLibrary)
    errorStr =  check_for_long_model_name(machineName);
    if(~isempty(errorStr))
	   construct_error(machineId, 'Build', errorStr, 1);
    end
end

if(~modelIsLibrary)
    [linkMachines,linkMachineFullPaths,linkLibFullPaths] = ...
    get_link_machine_list(sf('get',machineId,'machine.name'),sf('get',targetId,'target.name'));
else
    linkMachines = [];
    linkMachineFullPaths = [];
    linkLibFullPaths = [];
end

%%%% 20feb2002:vijay: we must compute the exported_fcn_info before we call
%%%% sync target.
update_exported_fcn_info(machineId,targetName,linkMachines);

%%%% we must do this before we look at libraries, because we might need the target's self
%%%% checksum to combine with library checksum.
sync_target(targetId, targetId,machineId);

ignoreChecksums = sfc('coder_options','ignoreChecksums');

needToRelink = 0;

if(modelIsLibrary==0 && ~strcmp(buildType,'parse'))
    %%%check if all the libraries are up-to-date if this a regular machine

    numLinkMachines = length(linkMachines);
    for i=1:numLinkMachines
        linkMachineId = sf('find','all','machine.name',linkMachines{i});
        if(isempty(linkMachineId))
            error('Unexpected internal error loading library model %s',linkMachines{i});            
        else
            linkMachineTarget = acquire_target(linkMachineId,targetName);
            if(applyToAllLibs)
                parentTargetId = targetId;
            else
                parentTargetId = linkMachineTarget;
            end
            sync_target(linkMachineTarget,parentTargetId,machineId);
            libraryModelChecksum = sf('get',linkMachineTarget,'target.checksumNew');
        end
        binaryInfoStruct = infomatman('load','binary',linkMachines{i},targetName);
        libraryBinaryChecksum  = binaryInfoStruct.sfunChecksum;

        prevLastErr = lasterr;
        try
            % the date property in infoStruct was introduced only recently.
            % try catch in case we are loading a really old infoStruct
            libraryBinarySaveDate = binaryInfoStruct.date;
        catch
            libraryBinarySaveDate = 0.0;
        end
        lasterr(prevLastErr);
        
        if(   rebuildAllFlag || ...
                isempty(libraryBinaryChecksum) || ...
                ~isequal(libraryModelChecksum,libraryBinaryChecksum) || ...
                (strcmp(targetName,'sfun') & ~check_if_file_is_in_sync(linkLibFullPaths{i},libraryBinarySaveDate,ignoreChecksums)) )

            mustBuildModel = 1;
        else
            mustBuildModel = 0;
        end

        if( mustBuildModel)
            sf_display('Autobuild',sprintf('Rebuilding library machine %s.',linkMachineFullPaths{i}));
            % we calculated checksum above.

            if(applyToAllLibs)
                parentTargetId = targetId;
            else
                parentTargetId = linkMachineTarget;
            end

            try
                status = targetman(buildType,linkMachineTarget,0,rebuildAllFlag, parentTargetId,[],machineId,i);
            catch
                construct_error(machineId, 'Build', 'Library failed to build. Cannot continue build process.', 1);
            end

            needToRelink = 1;
            %% if any one of the libraries is rebuilt then we must relink all the lib files
            %% to get the main machine's sfunction DLL
            %% note that we use the variable needToRelink below to invoke make_method
            %% on main machine if necessary
        end
        if (~needToRelink && strcmp(targetName,'sfun'))
            %% if the library has been rebuilt since last time the main machine dll was built
            %% (but not in the above loop), then we must relink.
            libraryBinaryChecksumInDll = get_checksum_from_dll(machineName,targetName,'library',linkMachines{i},[]);
            if ~isequal(libraryBinaryChecksumInDll,libraryBinaryChecksum)
                needToRelink = 1;
            end
        end
    end
end


if isunix
    libext = 'a';
else
    libext = 'lib';
end


if rebuildAllFlag==0
    modelChecksum = sf('get',targetId,'.checksumNew');
    if(modelIsLibrary==0 && strcmp(targetName,'sfun'))
        infoStruct = infomatman('load','dll',machineName,targetName);
    else
        infoStruct = infomatman('load','binary',machineName,targetName);
    end


    binaryChecksumVector = infoStruct.sfunChecksum;
    %%% in the following, we handle the case where the checksums are different
    %%% but since the existing DLL or lib-file is from a different directory
    %%% we need to set rebuildAll flag to 1 since incremental code gen would
    %%% fail otherwise. geck 48957
    if(~isequal(binaryChecksumVector,modelChecksum))
        if(strcmp(targetName,'sfun'))
            if(modelIsLibrary==1)
                binaryFile = fullfile(pwd,[machineName,'_sfun.',libext]);
            else
                binaryFile = fullfile(pwd,[machineName,'_sfun.',mexext]);
            end
            rebuildAllFlag = ~exist(binaryFile,'file');
        end
        if(ignoreChecksums)
            checksumChanged = 0;
        else
            checksumChanged = 1;
        end
    else
        checksumChanged = 0;
    end
else
    %%% to be on the safe side
    checksumChanged = 1;
end

if rebuildAllFlag==0 && ...
   checksumChanged==0 && ...
   ~strcmp(buildType, 'parse') &&...
   ~strcmp(buildType, 'make')
    if(needToRelink && strcmp(buildType, 'build'))
        % G175162. break out and go thru minimal codegen.
        % who knows if someone deleted the sfprj directory
    else
        return;
    end
end

status = targetman(buildType,targetId,0,rebuildAllFlag,targetId,chartId);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newChecksum = compute_effective_checksum(infoStruct,parentTargetId,mainMachineId)

%%% this function combines the checksums from infoStruct (loaded from an information MAT file)
%%% with the self checksum of a target that is passed in.
%%% note that this combination must correspond to what is in sync_target.m
%%% look for magic keyword zzyzx in sync_target.m
%%% feb20, 2002: vijay: modified this wickedly clever trick to
%%% handle exported graphical functions
makefileChecksum = infoStruct.makefileChecksum;
if(~isempty(parentTargetId))
    targetChecksum = sf('get',parentTargetId,'target.checksumSelf');
else
    targetChecksum = infoStruct.targetChecksum;
end
machineChecksum = infoStruct.machineChecksum;
machineChartChecksum = infoStruct.machineChartChecksum;
sfVersionString = sf('Version','Number');
exportedFcnChecksum = sf('get',mainMachineId,'machine.exportedFcnChecksum');
newChecksum = md5(exportedFcnChecksum,makefileChecksum,targetChecksum,machineChecksum,machineChartChecksum,sfVersionString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function error_check_current_dir(machineId,machineName)

matlabBin = lower(fullfile(matlabroot,'bin'));
currentDir = lower(pwd);


if (length(matlabBin)<=length(currentDir) && strcmp(matlabBin,currentDir(1:length(matlabBin)))),
    str = sprintf('The current directory is %s, which is reserved for MATLAB files.',currentDir);
    str = [str,10,10,...
          'Please change your current directory to a writable directory preferably outside of MATLAB installation area.'];
    construct_error(machineId,'Build',str,1,[]);
end

if (strncmp('\\',currentDir,2))
    errorMsg = 'DOS commands may not be executed when the current directory is a UNC pathname ';
    errorMsg = [errorMsg,10,10,...
                'Please change the current directory to a local directory or use a network drive mapped to the current directory.'];
    construct_error( [], 'Build', errorMsg, 1, [])
end
