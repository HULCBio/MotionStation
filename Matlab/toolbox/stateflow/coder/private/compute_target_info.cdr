function compute_target_info
global gTargetInfo gMachineInfo

gTargetInfo.codingLibrary = sf('get',sf('get',gTargetInfo.target,'target.machine'),'machine.isLibrary');

flags = sf('get',gMachineInfo.parentTarget,'target.codeFlags');
targetName = sf('get',gMachineInfo.parentTarget,'target.name');
gTargetInfo.codingMakeDebug = coder_options('debugBuilds');
gTargetInfo.codingSFunction = strcmp(targetName,'sfun');
gTargetInfo.codingRTW = strcmp(targetName,'rtw');
gTargetInfo.codingMEX = 0;

gTargetInfo.codingExportChartNames = 0;
gTargetInfo.codingPreserveNames = 0;
gTargetInfo.codingPreserveNamesWithParent=0;

relevantMachineName = sf('get',get_relevant_machine,'machine.name');

gTargetInfo.mdlrefInfo = get_model_reference_info(relevantMachineName);
gTargetInfo.isErtMultiInstanced = is_ert_multi_instance(relevantMachineName) | gTargetInfo.mdlrefInfo.isMultiInst;
gTargetInfo.ertMultiInstanceErrCode = get_ert_multi_instance_errcode(relevantMachineName);

allFlags = all_flags(gMachineInfo.parentTarget);
gTargetInfo.codingDebug = flag_value(allFlags,'debug');
gTargetInfo.codingOverflow = flag_value(allFlags,'overflow');
gTargetInfo.codingNoEcho = ~flag_value(allFlags,'echo');
gTargetInfo.codingPreserveConstantNames = flag_value(allFlags,'preserveconstantnames');

gTargetInfo.codingMultiInstance     = flag_value(allFlags,'multiinstanced');
gTargetInfo.codingNoInitializer = ~flag_value(allFlags,'initializer');

gTargetInfo.codingStateBitsets = flag_value(allFlags,'statebitsets');
gTargetInfo.codingDataBitsets = flag_value(allFlags,'databitsets');
gTargetInfo.codingComments = flag_value(allFlags,'comments');
gTargetInfo.codingAutoComments = flag_value(allFlags,'autocomments');
gTargetInfo.codingEmitObjectDescriptions = flag_value(allFlags,'emitdescriptions');
gTargetInfo.codingLogicalOps = flag_value(allFlags,'emitlogicalops');
gTargetInfo.codingElseIfDetection = flag_value(allFlags,'elseifdetection');
gTargetInfo.codingConstantFolding = flag_value(allFlags,'constantfolding');
gTargetInfo.codingRedundantElim = flag_value(allFlags,'redundantloadelimination');
gTargetInfo.codingEmitObjectRequirements = 0;

ioformat = flag_value(allFlags,'ioformat');
switch(ioformat)
    case 0
        gTargetInfo.codingGlobalIO = 1;
        gTargetInfo.codingPackedIO = 0;
    case 1
        gTargetInfo.codingGlobalIO = 0;
        gTargetInfo.codingPackedIO = 1;
    case 2
        gTargetInfo.codingGlobalIO = 0;
        gTargetInfo.codingPackedIO = 0;
    otherwise
        gTargetInfo.codingGlobalIO = 1;
        gTargetInfo.codingPackedIO = 0;
end

if(gTargetInfo.codingRTW) 
    targetProps = rtw_target_props(relevantMachineName);
    gTargetInfo.codingDebug = 0;
    gTargetInfo.codingOverflow = 0;
    gTargetInfo.codingNoEcho = 1;
    gTargetInfo.codingPreserveConstantNames = 0;

    gTargetInfo.codingMultiInstance = 0;
    gTargetInfo.codingNoInitializer = 0;

    gTargetInfo.codingStateBitsets = targetProps.codingStateBitsets;
    gTargetInfo.codingDataBitsets = targetProps.codingDataBitsets;
    gTargetInfo.codingComments = targetProps.codingComments;
    gTargetInfo.codingAutoComments = targetProps.codingAutoComments;

    gTargetInfo.codingEmitObjectDescriptions = targetProps.codingEmitObjectDescriptions;
    gTargetInfo.codingRedundantElim = 0;
    gTargetInfo.codingLogicalOps = 1;
    gTargetInfo.codingElseIfDetection = 1;
    gTargetInfo.codingConstantFolding = 1;
    
    gTargetInfo.codingEmitObjectRequirements = targetProps.codingEmitObjectRequirements;
    
    gTargetInfo.rtwProps = targetProps;
elseif(gTargetInfo.codingSFunction)
          
    gTargetInfo.codingNoComments = 1;
    gTargetInfo.codingEmitObjectDescriptions = 0;
    gTargetInfo.codingRedundantElim = 1;
    gTargetInfo.codingLogicalOps = 1;
    gTargetInfo.codingElseIfDetection = 1;
    gTargetInfo.codingConstantFolding = 1;
else
    gTargetInfo.codingDebug = 0;

end

if(strcmp(targetName,'testgen') & exist('testgen_gateway.m','file'))
    % WISH: This is a temporary hack for Bill to do his testgen
    % work. MUST GET RID OF IT AS SOON AS POSSIBLE!!!!!!!
    gTargetInfo.codingForTestGen = 1;
else
    gTargetInfo.codingForTestGen = 0;
end


if(gTargetInfo.codingPreserveNamesWithParent)
    gTargetInfo.codingPreserveNames = 1;
end


if(gTargetInfo.codingLibrary & (gTargetInfo.codingSFunction | gTargetInfo.codingRTW))
    gTargetInfo.codingMultiInstance  = 1;
end

% Set codingTMW always 0, so that sfc_mex.dsp, sfc_debugger.dsp won't get included in generated dsw file
% Wait until we figure out how to autogen the VC solution file.
if(0 && exist(fullfile(sf('Root'),'..','prj'),'dir'))
    gTargetInfo.codingTMW = 1;
else
    gTargetInfo.codingTMW = 0;
end


compute_compiler_info;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = all_flags(target)
result = sf('Private','target_methods','codeflags',target);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = flag_value(flags,str)
flagNames = {flags.name};
index = find(strcmp(flagNames,str));
if(~isempty(index))
    result = flags(index).value;
else
    result = 0;
end
