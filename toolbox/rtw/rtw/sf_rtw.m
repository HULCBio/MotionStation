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
%   $Revision: 1.22.2.3 $

if exist(fullfile(matlabroot,'toolbox','stateflow','stateflow','private','sf_rtw.m'), 'file')
    result = sf('Private', 'sf_rtw', commandName, varargin{:});
    return;
end


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
   machineId = sf('find','all','machine.name',machineName);
   targets = sf('TargetsOf',machineId);
   rtwTarget = sf('find',targets,'target.name','rtw');
   if(~sf('get',rtwTarget,'target.applyToAllLibs'))
       % get user sources from the library only when
       % main machine does say applyToAllLibs
       [linkMachines,usedChartFileNumbers] = feval('sf'...
        ,'Private','get_link_chart_file_numbers',machineName);
        for i=1:length(linkMachines)
            result = [result,' ',user_srcs_for_machine(linkMachines{i})];        
        end
    end
   result = deblank(result);
   
case 'get_sf_makeinfo'
  machineName = varargin{1};
  machineId = sf('find','all','machine.name',machineName);
  result = {};
  if ~isempty(machineId) & machineId ~= 0
    targets = sf('TargetsOf',machineId);
    rtwTarget = sf('find',targets,'target.name','rtw');
    result = sfc('makeinfo',rtwTarget,rtwTarget);
  end
case 'get_sf_headers'
   machineName = varargin{1};
   result = get_sf_headers(machineName);
case 'buildStateflowTarget'
   result = 0;
   buildStateflowTarget(varargin{1},varargin{2});
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = user_srcs_for_machine(machineName)
result = '';
machineId = sf('find','all','machine.name',machineName);
if ~isempty(machineId) & machineId ~= 0
    targets = sf('TargetsOf',machineId);
    rtwTarget = sf('find',targets,'target.name','rtw');
    makeinfo = sfc('makeinfo',rtwTarget,rtwTarget);
    if ~isempty(makeinfo.fileNameInfo.userAbsSources)
        result = sprintf('%s ',makeinfo.fileNameInfo.userAbsSources{:});
        result = deblank(result);
    end
end

% Function: get_sf_modules =====================================================
% Abstract:
%	Get all state flow modules for a machine.
%
function sfModules = get_sf_modules(machineName)

sfModules = get_sf_modules_for_machine(machineName,0,[]);

[linkMachines,usedChartFileNumbers] = feval('sf'...
   ,'Private','get_link_chart_file_numbers',machineName);

for i=1:length(linkMachines)
   sfModules = [sfModules,' ',get_sf_modules_for_machine(linkMachines{i},1,usedChartFileNumbers{i})];
end

function sfModules = get_sf_headers(machineName)

sfModules = get_sf_headers_for_machine(machineName,0,[]);

[linkMachines,usedChartFileNumbers] = feval('sf'...
   ,'Private','get_link_chart_file_numbers',machineName);

for i=1:length(linkMachines)
   sfModules = [sfModules,' ',get_sf_headers_for_machine(linkMachines{i},1,usedChartFileNumbers{i})];
end

% end get_sf_modules


% Function: GetSFModulesForMachine =============================================
% Abstract:
%	Only called if we have stateflow blocks in the model. Probe into
%       stateflow and return the modules for a given machine
%
function sfModules = get_sf_modules_for_machine(machineName,filterFlag,usedChartFileNumbers)

sfModules = '';
infoStruct = feval('sf','Private','infomatman','load','binary',...
   machineName,'rtw');

if(~strcmp(infoStruct.machineInlinable,'Yes') & ...
      ~isempty(infoStruct.machineTLCFile))
   sfModules = [infoStruct.machineTLCFile,'.c'];
end

if(filterFlag==1)
   for i = 1:length(usedChartFileNumbers)
      chartNumber = find(infoStruct.chartFileNumbers==usedChartFileNumbers(i));
      if(strcmp(infoStruct.inlineCharts{chartNumber},'No') | strcmp(infoStruct.hasSharedOutputBroadcastCode{chartNumber},'Yes'))         
         sfModules = [sfModules,' ',infoStruct.chartTLCFiles{chartNumber},'.c'];
      end
   end   
else
   for i = 1:length(infoStruct.chartTLCFiles)
      if(strcmp(infoStruct.inlineCharts{i},'No') | strcmp(infoStruct.hasSharedOutputBroadcastCode{i},'Yes'))         
         sfModules = [sfModules,' ',infoStruct.chartTLCFiles{i},'.c'];
      end
   end
end
%%% WISH Inline.chart is overridden by multi-instance flag in TLC code
%%% bring it out somehow
return; 

function sfModules = get_sf_headers_for_machine(machineName,filterFlag,usedChartFileNumbers)

sfModules = '';
infoStruct = feval('sf','Private','infomatman','load','binary',...
   machineName,'rtw');

if(~isempty(infoStruct.machineTLCFile))
   sfModules = [infoStruct.machineTLCFile,'.h'];
end

if(filterFlag==1)
   for i = 1:length(usedChartFileNumbers)
      chartNumber = find(infoStruct.chartFileNumbers==usedChartFileNumbers(i));
      sfModules = [sfModules,' ',infoStruct.chartTLCFiles{chartNumber},'.h'];
      if(strcmp(infoStruct.inlineCharts{i},'Yes'))         
          %sfModules = [sfModules,' ',infoStruct.chartTLCFiles{chartNumber},'.ci'];
      end
   end   
else
   for i = 1:length(infoStruct.chartTLCFiles)
       sfModules = [sfModules,' ',infoStruct.chartTLCFiles{i},'.h'];
       if(strcmp(infoStruct.inlineCharts{i},'Yes'))         
           %sfModules = [sfModules,' ',infoStruct.chartTLCFiles{i},'.ci'];
       end
   end
end

return; 



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

infoStruct = feval('sf','Private','infomatman','load','binary',...
   machineName,'rtw');
chartNumber = find(infoStruct.chartFileNumbers==chartFileNumber);
if(isempty(chartNumber))
   machineId = sf('Private','sf_force_open_machine',machineName);
   sf('Private','goto_target',machineId,'rtw');
   error(sprintf('The Stateflow-RTW target of %s needs to be rebuilt. Please choose rebuild all option',machineName));
end

sfNames = 'StateflowVersion';
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   sprintf('%f',feval('sf','Version',1)));

sfNames = feval('sf','Private', 'strrows', sfNames, 'ChartInLibrary');
sfNames = feval('sf','Private', 'strrows', sfNames, infoStruct.isLibrary);

sfNames = feval('sf','Private', 'strrows', sfNames, 'InlineChart');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.inlineCharts{chartNumber});

sfNames = feval('sf','Private', 'strrows', sfNames, 'HasSharedOutputBroadcastCode');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.hasSharedOutputBroadcastCode{chartNumber});

sfNames = feval('sf','Private', 'strrows', sfNames, 'ChartTLCFile');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.chartTLCFiles{chartNumber});

sfNames = feval('sf','Private', 'strrows', sfNames, 'ChartInitializeFcn');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.chartInitializeFcns{chartNumber});

sfNames = feval('sf','Private', 'strrows', sfNames, 'ChartRTWInitializer');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.chartRTWInitializeFcns{chartNumber});

sfNames = feval('sf','Private', 'strrows', sfNames, 'ChartOutputsFcn');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.chartOutputsFcns{chartNumber});

sfNames = feval('sf','Private', 'strrows', sfNames, 'ChartInstanceTypedef');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.chartInstanceTypedefs{chartNumber});

sfNames = feval('sf','Private', 'strrows', sfNames, 'InputDataCount');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.inputDataCount{chartNumber});

sfNames = feval('sf','Private', 'strrows', sfNames, 'InputEventCount');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.inputEventCount{chartNumber});

sfNames = feval('sf','Private', 'strrows', sfNames, 'NoInputs');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.noInputs{chartNumber});

sfNames = feval('sf','Private', 'strrows', sfNames, 'MultiInstanced');
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.isMultiInstanced{chartNumber});


return;
% end 

% Function: get_machine_info ===================================================
% Abstract:
%	Only called if we have stateflow blocks in the model. Probe into
%       stateflow and return the rtw names.
%
function sfNames = get_machine_info(machineName)

infoStruct = feval('sf','Private','infomatman','load','binary',...
   machineName,'rtw');

if(isempty(infoStruct.machineTLCFile))
   machineId = sf('Private','sf_force_open_machine',machineName);
   sf('Private','goto_target',machineId,'rtw');
   error(sprintf('The Stateflow-RTW target of %s needs to be rebuilt. Please choose rebuild all option',machineName));
end

sfNames = infoStruct.machineTLCFile;
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   infoStruct.machineInlinable);
sfNames = feval('sf','Private', 'strrows', sfNames, ...
   machineName);

[linkMachines,linkMachineFullPaths,linkLibFullPaths] = ...
   feval('sf','Private','get_link_machine_list'...
   ,machineName...
   ,'rtw');

for i=1:length(linkMachines)
   infoStruct = feval('sf','Private','infomatman','load','binary', ...
      linkMachines{i},'rtw');
   sfNames = feval('sf','Private', 'strrows', sfNames, ...
      infoStruct.machineTLCFile);
   sfNames = feval('sf','Private', 'strrows', sfNames, ...
      infoStruct.machineInlinable);
   sfNames = feval('sf','Private', 'strrows', sfNames, ...
      linkMachines{i});
end
%end get_machine_info 



% Function: BuildStateflowTarget ===============================================
% Abstract:
%      Only called if we have stateflow blocks in the model. Here we
%      build the Stateflow target.
%      Check for a Stateflow target named "rtw".  If nonexistent, create a
%      default target from the "sfun" target.
%
function buildStateflowTarget(modelName,codeFormat)

if(~sf_is_here)
    return;
end
try,
   machineId = feval('sf','find','all','machine.name',modelName);
catch,
   lasterr('');
   return;
end
if(isempty(machineId))
   return;
end
rebuildAllFlag = 0;
showNags = 'ifError';
rtwOptions.codeFormat = codeFormat;
try,
   sf('Private','autobuild',machineId,'rtw','code',rebuildAllFlag, showNags,[],rtwOptions);
catch,
   error(['Problem building Stateflow RTW target.',10,lasterr]);   
end

function isHere = sf_is_here
[mf, mexf] = inmem;

isHere = any(strcmp(mexf,'sf'));

%end buildStateflowTarget
