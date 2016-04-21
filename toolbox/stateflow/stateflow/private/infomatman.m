function infoStruct = infomatman(loadOrSave,modelOrBinary,machineIdOrName,targetIdOrName,dontCalculateChecksum,dateStr)
% initialize infoStruct

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.26.4.9 $  $Date: 2004/04/15 00:58:22 $

if(nargin<6)
   dateStr = '';
end

if(nargin<5)
   dontCalculateChecksum = 0;
end

if isunix
    fileSepChar = '/';
else
    fileSepChar = '\';
end
if(isa(machineIdOrName,'numeric'))
   machineId = machineIdOrName;
   machineName = sf('get',machineId,'machine.name');
else
   machineName = machineIdOrName;
   machineId = sf('find','all','machine.name',machineName);
end
if(isa(targetIdOrName,'numeric'))
   targetId = targetIdOrName;
   targetName = sf('get',targetId,'target.name');
else
   targetName = targetIdOrName;
   if(~isempty(machineId))
      targetId = sf('find',sf('TargetsOf',machineId),'target.name',targetName);
   else
      targetId = [];
   end
end
modelH = get_param(machineName,'handle');


switch(modelOrBinary)

case 'model'
    %machineFullPath = which([machineName,'.mdl']);
    machineFullPath = get_param(modelH,'filename');
    if(isempty(machineFullPath))
        machineDirectory = pwd;
    else
        lastFileSep = max(find(machineFullPath==fileSepChar));
        if(~isempty(lastFileSep))
            machineDirectory = machineFullPath(1:lastFileSep-1);
        else
            machineDirectory = pwd;
        end
    end

    modelInfoDirectory = [machineDirectory,fileSepChar,'sfprj',fileSepChar,'build',fileSepChar,machineName,fileSepChar,targetName,fileSepChar,'info'];
    modelInfoMatFileName = [modelInfoDirectory,fileSepChar,'minfo.mat'];
    switch(loadOrSave)
    case 'load'
        infoStruct = load_method(modelInfoMatFileName);
    case 'save'
        %%% note that we explicitly calculate the target checksum
        %%% since this is called at save time
        if(~dontCalculateChecksum)
            sync_target(targetId,targetId);
        end
        create_directory_path(machineDirectory,'sfprj','build',machineName,targetName,'info');
        save_method(modelInfoMatFileName,machineId,targetId,targetName,modelOrBinary,modelInfoDirectory,dateStr);
    end
case 'binary'
    binaryInfoDirectory = [cd,fileSepChar,'sfprj',fileSepChar,'build',fileSepChar,machineName,fileSepChar,targetName,fileSepChar,'info'];
    binaryInfoMatFileName = [binaryInfoDirectory,fileSepChar,'binfo.mat'];
    switch(loadOrSave)
    case 'load'
        infoStruct = load_method(binaryInfoMatFileName);
    case 'save'
        %%% note that we do NOT calculate the target checksum
        %%% since this is called after a successful build
        create_directory_path(cd,'sfprj','build',machineName,targetName,'info');
        save_method(binaryInfoMatFileName,machineId,targetId,targetName,modelOrBinary,binaryInfoDirectory,dateStr);
    end
case 'dll'
   [infoStruct.machineChecksum,infoStruct.date] = get_checksum_from_dll(machineName,targetName,'machine','',[]);
   infoStruct.machineChartChecksum = []; % WISH: fix this.
   infoStruct.targetChecksum = get_checksum_from_dll(machineName,targetName,'target','',[]);
   infoStruct.makefileChecksum = get_checksum_from_dll(machineName,targetName,'makefile','',[]);
   infoStruct.exportedFcnChecksum = get_checksum_from_dll(machineName,targetName,'exportedFcn','',[]);

   chartIds = sf('get',machineId,'machine.charts');
   chartFileNumbers = sf('get',chartIds,'chart.chartFileNumber');
   [sortedFileNumbers,indices] = sort(chartFileNumbers);
   infoStruct.chartFileNumbers = sortedFileNumbers;
   infoStruct.chartChecksums = zeros(length(sortedFileNumbers),4);
   for i = 1:length(sortedFileNumbers)
      infoStruct.chartChecksums(i,:) = get_checksum_from_dll(machineName,targetName,'chart','',sortedFileNumbers(i));
   end
    infoStruct.sfunChecksum = get_checksum_from_dll(machineName,targetName,'','',[]);
end


function save_method(modelInfoMatFileName,machineId,targetId,targetName,methodName,infoDirectory,dateStr)

   if(isempty(dateStr))
       dateStr = sf_date_str(now);
   end
   chartIds = sf('get',machineId,'machine.charts');
   chartFileNumbers = sf('get',chartIds,'chart.chartFileNumber');
   [sortedFileNumbers,indices] = sort(chartFileNumbers);
   chartIds = chartIds(indices);

   infoStruct.date = sf_date_num(dateStr);
   infoStruct.dateStr = dateStr;
   infoStruct.sfVersion = sf('get',machineId,'machine.sfVersion');
   infoStruct.mVersion = version;

   infoStruct.chartFileNumbers = sortedFileNumbers;
   infoStruct.chartChecksums = sf('get',chartIds,'chart.checksum');
   infoStruct.makefileChecksum = sf('get',machineId,'machine.makefileChecksum');
   infoStruct.machineChecksum = sf('get',machineId,'machine.checksum');
   infoStruct.machineChartChecksum = sf('get',machineId,'machine.chartChecksum');
   infoStruct.targetChecksum = sf('get',targetId,'target.checksumSelf');
   infoStruct.sfunChecksum = sf('get',targetId,'target.checksumNew');
   
   infoStruct.exportedFcnInfo = exported_fcns_in_machine(machineId);
   infoStruct.exportedFcnChecksum = sf('get',machineId,'machine.exportedFcnChecksum');

   if(sf('get',machineId,'machine.isLibrary'))
      infoStruct.isLibrary = 'Yes';
   else
      infoStruct.isLibrary = 'No';
   end
   if(sf('get',machineId,'machine.codeOptimizer.machineInlinable'))
      infoStruct.machineInlinable = 'Yes';
   else
      infoStruct.machineInlinable = 'No';
   end

   if(strcmp(targetName,'rtw') & strcmp(methodName,'binary'))
        oldInfoStruct = load_method(modelInfoMatFileName);
        for i = 1:length(chartIds)
            if sf('get', chartIds(i), 'chart.rtwInfo.codeGeneratedNow')
                inputData = sf('find',sf('DataOf',chartIds(i)),'data.scope','INPUT_DATA');
                inputEvents = sf('find',sf('EventsOf',chartIds(i)),'event.scope','INPUT_EVENT');
                infoStruct.chartInfo(i).InputDataCount = sprintf('%d',length(inputData));
                infoStruct.chartInfo(i).InputEventCount = sprintf('%d',length(inputEvents));

                infoStruct.chartInfo(i).NoInputs = yes_or_no(isempty(inputData) & isempty(inputEvents));

                infoStruct.chartInfo(i).TLCFile = sf('get',chartIds(i),'chart.rtwInfo.chartTLCFile');
                infoStruct.chartInfo(i).InitializeFcn = sf('get',chartIds(i),'chart.rtwInfo.chartInitializeFcn');
                infoStruct.chartInfo(i).RTWInitializeFcn = sf('get',chartIds(i),'chart.rtwInfo.chartRTWInitializeFcn');
                infoStruct.chartInfo(i).OutputsFcn = sf('get',chartIds(i),'chart.rtwInfo.chartOutputsFcn');

                infoStruct.chartInfo(i).ReusableOutputs = sf('get',chartIds(i),'chart.rtwInfo.reusableOutputs');
                infoStruct.chartInfo(i).ExpressionableInputs = sf('get',chartIds(i),'chart.rtwInfo.expressionableInputs');

                infoStruct.chartInfo(i).IsMultiInstanced = yes_or_no(sf('get',chartIds(i),'chart.rtwInfo.isMultiInstanced'));

                if(sf('get',chartIds(i),'chart.rtwInfo.chartInstanceOptimizedOut'))
                    infoStruct.chartInfo(i).InstanceOptimizedOut = 'Yes';
                    infoStruct.chartInfo(i).InstanceTypedef = '';
                else
                    infoStruct.chartInfo(i).InstanceOptimizedOut = 'No';
                    infoStruct.chartInfo(i).InstanceTypedef = sf('get',chartIds(i),'chart.rtwInfo.chartInstanceTypedef');
                end

                infoStruct.chartInfo(i).Inline = yes_or_no(sf('get',chartIds(i),'chart.rtwInfo.chartWhollyInlinable'));
                infoStruct.chartInfo(i).TimeVarUsed = yes_or_no(sf('get',chartIds(i),'chart.rtwInfo.timeVarUsed'));
                infoStruct.chartInfo(i).HasSharedOutputBroadcastCode = yes_or_no(sf('get',chartIds(i),'chart.rtwInfo.hasSharedOutputBroadcastCode'));
                infoStruct.chartInfo(i).usesDSPLibrary = sf('get',chartIds(i),'chart.rtwInfo.usesDSPLibrary');
                infoStruct.chartInfo(i).usesGlobalEventVar = sf('get',chartIds(i),'chart.rtwInfo.usesGlobalEventVar');
                infoStruct.chartInfo(i).sfSymbols = sf('get',chartIds(i),'chart.rtwInfo.sfSymbols');
            else
                indx = find(oldInfoStruct.chartFileNumbers==infoStruct.chartFileNumbers(i));
                if isempty(indx)
                    error('Incremental CodeGen');
                else
                    infoStruct.chartInfo(i) = oldInfoStruct.chartInfo(indx);
                end
            end
        end
        infoStruct.machineTLCFile = sf('get',machineId,'machine.rtwInfo.machineTLCFile');
    end

   save(modelInfoMatFileName,'infoStruct');

function infoStruct = load_method(infoMatFileName)

   if(isempty(infoMatFileName) | ~exist(infoMatFileName,'file'))
      infoStruct = get_default_info_struct;
      return;
   else
    % Be robust to corrupted MAT files and do the default thing
    % G127858
      [prevErrMsg, prevErrId] = lasterr;
      try,
          load(infoMatFileName);
      catch,
          infoStruct = get_default_info_struct;
          lasterr(prevErrMsg, prevErrId);
      end
   end

function infoStruct = get_default_info_struct
      infoStruct.date = 0.0;
      infoStruct.sfVersion = 0.0;
      infoStruct.mVersion = 0.0;
      infoStruct.machineChecksum = [];
      infoStruct.machineChartChecksum = [];
      infoStruct.targetChecksum = [];
      infoStruct.makefileChecksum = [];
      infoStruct.chartFileNumbers = [];
      infoStruct.chartChecksums = [];
      infoStruct.chartTLCFiles = {};
      infoStruct.machineTLCFile = [];
      infoStruct.machineInlinable = 'No';
      infoStruct.sfunChecksum = [];
      infoStruct.exportedFcnInfo = [];
      infoStruct.exportedFcnChecksum = [];
      infoStruct.chartReusableOutputs = [];
      infoStruct.chartExpressionableInputs = [];

function y_or_n = yes_or_no(val)
    if val
        y_or_n = 'Yes';
    else
        y_or_n = 'No';
    end