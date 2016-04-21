function targetChanged = sync_target(thisTarget,parentTarget,mainMachine)
%SYNC_TARGET calculates synchronization values for a given target
%  RESULT = SYNC_TARGET_GATEWAY(thisTarget,parentTarget)

%	Vijay Raghavan
%	Copyright 1995-2004 The MathWorks, Inc.
%  $Revision: 1.24.4.5 $  $Date: 2004/04/15 01:00:54 $


thisMachine = sf('get',thisTarget,'target.machine');
if(nargin<2)
    parentTarget = thisTarget;
end
if(nargin<3)
    mainMachine = thisMachine;
end
if(isempty(mainMachine))
    mainMachine = thisMachine;
end
%% before we do anything, we need to update machine.sfLinks
if(~sf('get',thisMachine,'.isLibrary'))
    junk = slsf('mdlFixBrokenLinks',thisMachine);
end

sf('SyncMachine',thisMachine,thisTarget);
targetChecksum = ck_target(thisTarget,parentTarget,mainMachine);

machineName = sf('get',thisMachine,'machine.name');
linkMachineChecksum = [];
isPc = ~isunix;
isLibrary = sf('get',thisMachine,'machine.isLibrary');
if(~isLibrary)
    [linkMachineList,linkMachineFullPaths,linkLibFullPaths] = get_link_machine_list(machineName,sf('get',thisTarget,'target.name'));
    for i = 1:length(linkLibFullPaths)
        if isPc
            linkMachineChecksum = md5(linkMachineChecksum,lower(linkLibFullPaths{i}));
        else
            linkMachineChecksum = md5(linkMachineChecksum,linkLibFullPaths{i});
        end
    end
end

chartList = sf('get',thisMachine,'machine.charts');

if(isLibrary & thisTarget~=parentTarget)
    userSources = [];
    userLibraries = [];
    userMakefiles = [];
    makeCommand = [];
    targetFunction = [];
else
    userSources = sf('get',parentTarget,'target.userSources');
    userLibraries = sf('get',parentTarget,'target.userLibraries');
    userMakefiles = sf('get',parentTarget,'target.userMakefiles');
    makeCommand = sf('get',parentTarget,'target.makeCommand');
    targetFunction = sf('get',parentTarget,'target.targetFunction');
end

makefileChecksum = md5(sort(sf('get',chartList,'chart.chartFileNumber')')...
    ,sf('get',chartList,'chart.exportChartFunctions')'...
    ,userSources...
    ,userLibraries...
    ,userMakefiles...
    ,makeCommand...
    ,targetFunction...
    ,linkMachineChecksum...
    ,targetChecksum);

sf('set',thisMachine,'machine.makefileChecksum',makefileChecksum);

sf('set',thisTarget,'target.checksumSelf',targetChecksum);

machineChecksum = sf('get',thisMachine,'machine.checksum');
machineChartChecksum = sf('get',thisMachine,'machine.chartChecksum');
exportedFcnChecksum = sf('get',mainMachine,'machine.exportedFcnChecksum');
sf('set',thisMachine,'machine.exportedFcnChecksum',exportedFcnChecksum);
sfVersionString = sf('Version','Number');


%%% this is where we combine all sorts of checksums to form an aggregated
%%% target checksum.
%%% if you are lost say zzyzx thrice. look for it in autobuild.m before
%%% changing this magical line.
newChecksum = md5(exportedFcnChecksum,makefileChecksum,targetChecksum,machineChecksum,machineChartChecksum,sfVersionString);


sf('set',thisTarget,'.checksumNew',newChecksum);
savedChecksum = sf('get',thisTarget,'.checksumOld');

targetChanged = any(newChecksum ~= savedChecksum);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  targetChecksum = ck_target(target,parentTarget,mainMachine)
targetName = sf('get',target,'target.name');
mainMachineName = sf('get',mainMachine,'machine.name');
if(strcmp(targetName,'rtw'))
    targetProps = sfc('private','rtw_target_props',mainMachineName);
    targetChecksum = md5(...
        targetName...
        ,sfc('revision')...
        ,targetProps);
else    
    [algorithmWordsizes,targetWordsizes,algorithmHwInfo,targetHwInfo] = sfc('private','get_word_sizes',mainMachineName,targetName);
    targetChecksum = md5(...
        targetName...
        ,sf('get',parentTarget,'target.customCode')...
        ,sf('get',parentTarget,'target.userIncludeDirs')...
        ,sf('get',parentTarget,'target.codeFlags')...
        ,sf('get',parentTarget,'target.reservedNames')...
        ,sf('get',target,'target.targetFunction')...
        ,sfc('revision')...
        ,algorithmWordsizes...
        ,targetWordsizes...
        ,algorithmHwInfo,targetHwInfo...        
        );
end
