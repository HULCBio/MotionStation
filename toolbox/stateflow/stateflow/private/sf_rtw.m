function result = sf_rtw(commandName, varargin)
% SF_RTW Extract Stateflow information required for RTW build for
% Stateflow versions 1.1 and above
%
%   SF_RTW is called from inside TLC to extract the necessary
%   Stateflow information which is required for the RTW build.
%   In particular, RTW needs to know the unique names that Stateflow
%   uses for its input data, output data, input events, output
%   events, chart workspace data, and machine workspace data.  The
%   underlying motivation is that RTW must create a list of hash
%   defines for Stateflow since RTW creates these data under a
%   different name.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $

switch(commandName)
case 'get_value'
    varName = varargin{1};
    result = evalin('base',varName);
    if(strcmp(class(result),'Simulink.Parameter'))
        result = result.Value;
    end
    result = double(result);
case 'process_tag'
   tag = varargin{1};
   tagLength = length('Stateflow S-Function');
   if(length(tag)>tagLength)
      tag = tag(1:tagLength);
   end
   if(strcmp(tag,'Stateflow S-Function'))
      result = 'Yes';
   else
      result = 'No';
   end
case 'get_block_info'
   result = get_block_info(varargin{1});
case 'get_machine_info'
   result = get_machine_info(varargin{1});
case 'get_sf_user_modules'
   machineName = varargin{1};
   result = user_srcs_for_machine(machineName);
   machineId = sf('find',sf('MachinesOf'),'machine.name',machineName);
   targets = sf('TargetsOf',machineId);
   rtwTarget = sf('find',targets,'target.name','rtw');
   if(~sf('get',rtwTarget,'target.applyToAllLibs'))
       % get user sources from the library only when
       % main machine does say applyToAllLibs
       linkMachines = get_link_chart_file_numbers(machineName);
        for i=1:length(linkMachines)
            result = [result,' ',user_srcs_for_machine(linkMachines{i})];
        end
    end
   result = deblank(result);

case 'get_sf_makeinfo'
  machineName = varargin{1};
  machineId = sf('find',sf('MachinesOf'),'machine.name',machineName);
  result = {};
  if ~isempty(machineId) & machineId ~= 0
    targets = sf('TargetsOf',machineId);
    rtwTarget = sf('find',targets,'target.name','rtw');
    result = sfc('makeinfo',rtwTarget,rtwTarget);
  end
case 'usesDSPLibrary'
  machineName = varargin{1};
  result = machine_uses_DSP_library(machineName);
case 'update_sf_include_libraries'
  machineName = varargin{1};
  fileNameInfo = varargin{2};
  sfcnPathArray = varargin{3};
  makeRTWHandle = varargin{4};
  currdir = pwd;
  cd(makeRTWHandle.StartDirToRestore);
  usesDSPLibrary = machine_uses_DSP_library(machineName);
  cd(currdir);
  if usesDSPLibrary
    includeFile = fullfile(currdir, ['dsp_' fileNameInfo.rtwDspLibIncludeFileName]);
    if ~exist(includeFile)
      includeFileSrc = fullfile(fileNameInfo.rtwDspLibInclude, fileNameInfo.rtwDspLibIncludeFileName);
      if exist(includeFileSrc, 'file')
        fidSrc = fopen(includeFileSrc, 'r');
        includeFileText = fread(fidSrc);
        fclose(fidSrc);        
        fidDst = fopen(includeFile, 'w');
        fprintf(fidDst, '#ifndef __DSP_TEMPLATE_SUPPORT_HEADER\n');
        fprintf(fidDst, '#define __DSP_TEMPLATE_SUPPORT_HEADER\n\n');
        fwrite(fidDst, includeFileText);
        fprintf(fidDst, '\n\n#endif\n');
        fclose(fidDst);
      end
    end
    sfcnPathArray = {sfcnPathArray{:}, fullfile(matlabroot, 'toolbox', 'dspblks', 'dspmex')};
  end
  result = sfcnPathArray;
case 'buildStateflowTarget'
   result = 0;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = uses_DSP_library(machineName)
  machineId = sf('find',sf('MachinesOf'),'machine.name',machineName);
  result = 0;
  if ~isempty(machineId) & machineId ~= 0
    infoStruct = infomatman('load','binary',machineId,'rtw');
    if ~isempty(infoStruct.chartFileNumbers)
      result = any([infoStruct.chartInfo.usesDSPLibrary]);
    end
  end
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = machine_uses_DSP_library(machineName)
  result = uses_DSP_library(machineName);
  if result
    return;
  end
  linkMachines = get_link_machine_list(machineName, 'rtw');
  for i=1:length(linkMachines)
    result = uses_DSP_library(linkMachines{i});
    if result
      return;
    end
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = user_srcs_for_machine(machineName)
result = '';
machineId = sf('find',sf('MachinesOf'),'machine.name',machineName);
if ~isempty(machineId) & machineId ~= 0
    targets = sf('TargetsOf',machineId);
    rtwTarget = sf('find',targets,'target.name','rtw');
    makeinfo = sfc('makeinfo',rtwTarget,rtwTarget);
    if ~isempty(makeinfo.fileNameInfo.userAbsSources)
        result = sprintf('%s ',makeinfo.fileNameInfo.userAbsSources{:});
        result = deblank(result);
    end
end


% Function: get_block_info =====================================================
% Abstract:
%	Only called if we have stateflow blocks in the model. Probe into
%       stateflow and return the rtw block info
%
function sfNames = get_block_info(tag)

tagLength = length('Stateflow S-Function');
infoTag = tag(tagLength+2:end);
firstSpace = find(infoTag==32);
machineName = infoTag(1:firstSpace-1);
chartFileNumber = sscanf(infoTag(firstSpace+1:end),'%d');

if(isempty(chartFileNumber))
   error(['Please run sfconv20 in this directory to convert all old ', ...
         'library models.']);
end

infoStruct = infomatman('load','binary',...
   machineName,'rtw');
chartNumber = find(infoStruct.chartFileNumbers==chartFileNumber);
if(isempty(chartNumber))
   machineId = sf_force_open_machine(machineName);
   goto_target(machineId,'rtw');
   error(sprintf('The Stateflow-RTW target of %s needs to be rebuilt. Please choose rebuild all option',machineName));
end

sfNames = 'StateflowVersion';
sfNames = strrows(sfNames, sprintf('%f',sf('Version',1)));

sfNames = strrows(sfNames, 'ChartInLibrary');
sfNames = strrows(sfNames, infoStruct.isLibrary);

sfNames = strrows(sfNames, 'InlineChart');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).Inline);

sfNames = strrows(sfNames, 'HasSharedOutputBroadcastCode');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).HasSharedOutputBroadcastCode);

sfNames = strrows(sfNames, 'ChartTLCFile');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).TLCFile);

sfNames = strrows(sfNames, 'ChartInitializeFcn');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).InitializeFcn);

sfNames = strrows(sfNames, 'ChartRTWInitializer');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).RTWInitializeFcn);

sfNames = strrows(sfNames, 'ChartOutputsFcn');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).OutputsFcn);

sfNames = strrows(sfNames, 'ChartInstanceTypedef');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).InstanceTypedef);

sfNames = strrows(sfNames, 'InputDataCount');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).InputDataCount);

sfNames = strrows(sfNames, 'InputEventCount');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).InputEventCount);

sfNames = strrows(sfNames, 'NoInputs');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).NoInputs);

sfNames = strrows(sfNames, 'MultiInstanced');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).IsMultiInstanced);

sfNames = strrows(sfNames, 'ChartInstanceOptimizedOut');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).InstanceOptimizedOut);

sfNames = strrows(sfNames, 'TimeVarUsed');
sfNames = strrows(sfNames, infoStruct.chartInfo(chartNumber).TimeVarUsed);


return;
% end

% Function: get_machine_info ===================================================
% Abstract:
%	Only called if we have stateflow blocks in the model. Probe into
%       stateflow and return the rtw names.
%
function sfNames = get_machine_info(machineName)

infoStruct = infomatman('load','binary',machineName,'rtw');

if(isempty(infoStruct.machineTLCFile))
   machineId = sf_force_open_machine(machineName);
   goto_target(machineId,'rtw');
   error(sprintf('The Stateflow-RTW target of %s needs to be rebuilt. Please choose rebuild all option',machineName));
end

sfNames = infoStruct.machineTLCFile;
sfNames = strrows(sfNames, infoStruct.machineInlinable);
sfNames = strrows(sfNames, machineName);

linkMachines = get_link_machine_list(machineName,'rtw');

for i=1:length(linkMachines)
   infoStruct = infomatman('load','binary',linkMachines{i},'rtw');
   sfNames = strrows(sfNames, infoStruct.machineTLCFile);
   sfNames = strrows(sfNames, infoStruct.machineInlinable);
   sfNames = strrows(sfNames, linkMachines{i});
end
%end get_machine_info

