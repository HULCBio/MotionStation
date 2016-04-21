function incCodeGenInfo = compute_inc_codegen_info(fileNameInfo,codingRebuildAll)

global gMachineInfo gTargetInfo

if(isunix)
    libext = 'a';
else
    libext = 'lib';
end

incCodeGenInfo.flags = ones(length(gMachineInfo.charts),1);
incCodeGenInfo.infoStruct = [];

infoStruct = [];
if(~gTargetInfo.codingLibrary && gTargetInfo.codingSFunction)
    infoStruct = sf('Private','infomatman','load','dll',gMachineInfo.machineId,gMachineInfo.targetName);
else
    infoStruct = sf('Private','infomatman','load','binary',gMachineInfo.machineId,gMachineInfo.targetName);
end
[prevErrMsg, prevErrId] = lasterr;
try,
    lastBuildDate = infoStruct.date;
catch,
    infoStruct.date = 0.0;
    lastBuildDate = 0.0;
    lasterr(prevErrMsg, prevErrId);
end
regenerateCodeForallCharts = codingRebuildAll;
if(~regenerateCodeForallCharts)
    if(gTargetInfo.codingLibrary && gTargetInfo.codingSFunction)
        regenerateCodeForallCharts = ~exist([gMachineInfo.machineName,'_',gMachineInfo.targetName,'.',libext],'file');
    end
end

if(~regenerateCodeForallCharts)
    regenerateCodeForallCharts = ~isequal(infoStruct.machineChecksum,sf('get',gMachineInfo.machineId,'machine.checksum'));
end

if(~regenerateCodeForallCharts)
    regenerateCodeForallCharts = ~isequal(infoStruct.exportedFcnChecksum,sf('get',gMachineInfo.machineId,'machine.exportedFcnChecksum'));
end

if(~regenerateCodeForallCharts)
    regenerateCodeForallCharts = ~isequal(infoStruct.targetChecksum,sf('get',gMachineInfo.target,'target.checksumSelf'));
end
if((gTargetInfo.codingSFunction || gTargetInfo.codingRTW) && regenerateCodeForallCharts)
   clean_code_gen_dir(fileNameInfo.targetDirName);
end

incCodeGenInfo.infoStruct = infoStruct;

if(regenerateCodeForallCharts)
   return;
end

for i = 1:length(gMachineInfo.charts)
    chart = gMachineInfo.charts(i);
    [chartNumber,chartFileNumber] = sf('get',chart,'chart.number','chart.chartFileNumber');
    sourceFileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1});
    headerFileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartHeaderFiles{chartNumber+1});

    if(~regenerateCodeForallCharts && ...
       check_if_file_is_in_sync(sourceFileName,lastBuildDate) && ...
       check_if_file_is_in_sync(headerFileName,lastBuildDate))
        checksum = [];
        index = find(infoStruct.chartFileNumbers==chartFileNumber);
        if(~isempty(index))
            checksum = infoStruct.chartChecksums(index,:);
        end
        regenerateCodeForThisChart = ~isequal(checksum,sf('get',chart,'chart.checksum'));
    else
        regenerateCodeForThisChart = 1;
    end
    if(~regenerateCodeForThisChart)
        incCodeGenInfo.flags(i) = 0;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = check_if_file_is_in_sync(fileName,buildDate)

result = sf('Private','check_if_file_is_in_sync',fileName,buildDate);
