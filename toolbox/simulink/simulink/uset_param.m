function output = uset_param(object, varargin)
% Unified "set_param" utility for Simulink/Stateflow configuration.
%
% Examples:
%     uset_param('model_name', 'SolverMode', 'Auto')
%     uset_param('model_name', 'GenerateSampleERTMain', 'on')
%     uset_param('model_name', 'RootIOStructures', 'off')
%     uset_param('model_name', 'StateBitSets', 'on')
%
% To create a recovery (undo) point:
%     uset_param('model_name', 'BackupSettings')
% 
% To undo updates since last recovery point:
%     uset_param('model_name', 'RestoreSettings')
% 
% Or, specifify multiple parameter/value pairs for a batch setting
%
%     uset_param('model_name', 'SolverMode', 'Auto', 'RTWInlineParameters', 'off')
%
% To get the table of supported parameters and their valid value group, use
%     uset_param('model_name')
%
% See also UGET_PARAM, GET_PARAM, SET_PARAM.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2004/04/15 00:49:55 $

persistent LAST_OBJECT;  % last working on object
persistent Update_Log;   % updating log
persistent dirty_state;  % dirty state of object

output = '';

isConfigObj = false;

if isa(object, 'Simulink.ConfigSet')
  isConfigObj = true;
else
  object = get_param(object, 'handle');
  if isempty(find_system(object, 'type', 'block_diagram'))
    error('First input argument must be a valid model name');
  end
end

if isempty(LAST_OBJECT)
    % first start
    if isConfigObj
      dirty_state = 'off';
    else
      dirty_state = get_param(object, 'dirty');
    end
    LAST_OBJECT = object;
    Update_Log = {};
elseif ~strcmp(class(LAST_OBJECT), class(object)) || object ~= LAST_OBJECT
    % if user changed working object, clear log
    if isConfigObj
      dirty_state = 'off';
    else
      dirty_state = get_param(object, 'dirty');
    end
    LAST_OBJECT = object;
    Update_Log = {};
end


if (nargin-1) == 0
    % return table if invoked by uset_param(model)
    output = MapParamNametoInternalName('', '');
    % extract Description, External name and valid value group columns
    output = [output(:,1), output(:,3), output(:,4)];
    return;
elseif strcmpi(varargin{1}, 'BackupSettings')
    if isConfigObj
      dirty_state = 'off';
    else
      dirty_state = get_param(object, 'dirty');
    end
    LAST_OBJECT = object;
    Update_Log = {};
    % disp('Recovery point created.');
    return;
elseif strcmpi(varargin{1}, 'RestoreSettings')
    if ~isempty(Update_Log)
        [Update_Log, errorLog] = undoUpdates(object, Update_Log);
        if ~isConfigObj
          set_param(object, 'dirty', dirty_state);
        end
        % disp('Recovery point restored.');
    else
        % disp('Log is empty.');
    end
    return;
elseif strcmpi(varargin{1}, 'uget_param')
    % support for "get" method
    if (nargin-2) == 0
        % return table if invoked by uset_param(model)
        output = MapParamNametoInternalName('', '');
        % extract Description, External name
        output = [output(:,1), output(:,3)];
        return;
    end
    [internalName, internalValue] = MapParamNametoInternalName(varargin{2}, '');
    if iscell(internalName)
        internalName = internalName{:};
    end
    output = unifygetparam(object, internalName);
    return;
elseif mod((nargin-1), 2) > 0
    error('Input arguements must be in the form of property/value pair.');
end

for i=1:2:(nargin-1)
    [internalName, internalValue] = MapParamNametoInternalName(varargin{i}, varargin{i+1});
    if iscell(internalName)
        internalName = internalName{:};
    end
    if iscell(internalValue)
        internalValue = internalValue{:};
    end
    currentLog = unifysetparam(object, internalName, internalValue);
    Update_Log{end+1} = currentLog;
end


function paramValue = unifygetparam(object, paramName)
isConfigObj = isa(object, 'Simulink.ConfigSet');
[category, subParamName] = analyzeName(paramName);

if strcmpi(category, 'stateflow')  % support for stateflow sub category
  paramValue = stateflowsettings('get', getfullname(object), subParamName);
else
  if ~isConfigObj
    cs = getActiveConfigSet(object);
  else
    cs = object;
  end
  
  fp = get_param(cs, 'ObjectParameters');
  if isfield(fp, paramName) 
    paramValue = get_param(cs, paramName);
  else
    error(['Unsupported parameter specified: ' paramName]);
  end
end
    
function currentLog = unifysetparam(object, paramName, paramValue)
currentLog=[]; 
isConfigObj = isa(object, 'Simulink.ConfigSet');
[category, subParamName] = analyzeName(paramName);

if strcmpi(category, 'stateflow')  % support for stateflow sub category
  oldValue = stateflowsettings('get', getfullname(object), subParamName);
  if isempty(oldValue)
    % warning(['Unsupported parameter specified: ' paramName]);
    currentLog.NA = 1; % Not Applicable
  else
    setValue = l_translate(paramValue, 'decode');
    if iscell(setValue)
      setValue = setValue{:};
    end                            
    try
      stateflowsettings('set', getfullname(object), subParamName, setValue);
    catch
      error(lasterr);
      error(['error happened when setting parameter: ' paramName]);
    end
    newValue = stateflowsettings('get', getfullname(object), subParamName);
    % log current action
    currentLog.NA = 0; % not Not Applicable
    currentLog.ParamName = paramName;
    currentLog.oldValue = oldValue;
    currentLog.setValue = setValue;
    currentLog.newValue = newValue;            
  end
else
   if ~isConfigObj
    cs = getActiveConfigSet(object);
  else
    cs = object;
  end
  fp = get_param(cs, 'ObjectParameters');
 
  if isfield(fp, paramName) || strcmpi(paramName, 'ConditionallyExecuteInputs')
    oldValue = get_param(cs, paramName);
    setValue = l_translate(paramValue, 'decode');
    if iscell(setValue)
        setValue = setValue{:};
    end
    if isnumeric(oldValue) && ischar(setValue)
        setValue = str2num(setValue);
    end
    
    try
      set_param(cs, paramName, setValue);
    catch
      error(lasterr);
      error(['error happened when setting parameter: ' paramName]);
    end
    newValue = get_param(cs, paramName);
    % log current action
    currentLog.NA = 0; % not Not Applicable
    currentLog.ParamName = paramName;
    currentLog.oldValue = oldValue;
    currentLog.setValue = setValue;
    currentLog.newValue = newValue;
  else
    % Not Applicable
    currentLog.NA = 1; % Not Applicable
    error(['Unsupported parameter specified: ' paramName]);
  end
end

%undo updates
function [updateLog, errorLog] = undoUpdates(object, lastupdateLog)
updateLog=[];
errorLog='';
for j=1:length(lastupdateLog)
    newLog=[];
    if lastupdateLog{j}.NA
        newLog.NA = 1; % Not Applicable
    else
        newLog.ParamName = lastupdateLog{j}.ParamName;
        newLog.NA = 0;
        newLog.oldValue = lastupdateLog{j}.setValue;
        newLog.setValue = lastupdateLog{j}.oldValue;
        try
            [category, subParamName] = analyzeName(lastupdateLog{j}.ParamName);
            if strcmpi(category, 'stateflow')  % support for stateflow sub category
              stateflowsettings('set', getfullname(object), subParamName, lastupdateLog{j}.oldValue);
            else
              if isa(object, 'Simulink.ConfigSet')
                cs = object;
              else
                cs = getActiveConfigSet(object);
              end
              set_param(cs, lastupdateLog{j}.ParamName, lastupdateLog{j}.oldValue);
            end
        catch
          errorLog = [errorLog, sprintf('\n'), lasterr];
        end
        if strcmpi(category, 'stateflow')  % support for stateflow sub category
          newLog.newValue = stateflowsettings('get', getfullname(object), subParamName);
        else
          if isa(object, 'Simulink.ConfigSet')
            cs = object;
          else
            cs = getActiveConfigSet(object);
          end          
          newLog.newValue = get_param(cs, lastupdateLog{j}.ParamName);
        end
    end
    updateLog{length(updateLog)+1} = newLog;
end

% this function will translate between HTML page display and internal
% representive. i.e., "Yes"<->1 "No <->0
function output = l_translate(input, choice)
Table = ...
    { 'Yes' '1';...
      'No' '0';...
  };
input = num2str(input);
output = input;
switch choice
    case 'encode'
        for i=1:length(Table)
            if strcmpi(Table(i,2), input)
                output = Table(i,1);
                return
            end
        end
    case 'decode'
        for i=1:length(Table)
            if strcmpi(Table(i,1), input)
                output = Table(i,2);
                output = str2num(output{:});
                return
            end
        end
    otherwise
end

% analyze HTML form element:  "Name=Value"
% we expect "Name" follow category_serialNum pattern
function [category, serialNum] = analyzeName(name)
[category, serialNum] = strtok(name, '_');
serialNum = serialNum(2:end);
  
function result = stateflowsettings(methodName,modelName,codeFlag,codeFlagValue)
% call it with
% settings('get'/'set',modelName,'databitsets/statebitsets',1/0)
%
  result = [];
  switch(methodName)
   case 'get',
    result = get_code_flag(modelName,codeFlag);
   case 'set'
    result = set_code_flag(modelName,codeFlag,codeFlagValue);
  end
  
function result = get_code_flag(modelName,codeFlag)
  result = [];
  machineId = sf('find','all','machine.name',modelName);
  if(isempty(machineId))
    return;
  end
  targetId = sf('Private','acquire_target',machineId,'rtw');
  result = sf('Private','target_code_flags','get',targetId,codeFlag);
  
function result = set_code_flag(modelName,codeFlag,flagValue)
  
  machineId = sf('find','all','machine.name',modelName);
  if(isempty(machineId))
    return;
  end
  targetId = sf('Private','acquire_target',machineId,'rtw');
  sf('Private','target_code_flags','set',targetId,codeFlag,flagValue);
  result = flagValue;

  
% translate parameter name/value pairs (such as Solver, GenSampleERTMain...) into internal
% representation name such as rtwoption_GenSampleERTMain.
function [internalName, internalValue] = MapParamNametoInternalName(paramName, paramValue)
persistent TranslationTable;
if isempty(TranslationTable)
    TranslationTable = ...
    { %Description name, Internal name, External paramName, valid values
    % Solver Page
        'Start simulation time', 'StartTime', 'StartTime', {};...
        'Stop simulation time', 'StopTime', 'StopTime', {};...
        'Absolute tolerance', 'AbsTol', 'AbsTol', {};...
        'Fixed step size', 'FixedStep', 'FixedStep', {};...
        'Initial step size', 'InitialStep', 'InitialStep', {};...
             %If MinStepSize paramter is a 2 element vector, then the the second element is MaxNumMinSteps
        'Maxium number of minium steps violation', 'MaxNumMinSteps', 'MaxnumMinSteps', {};...
        'Maxium Order (variable step solver ode15s)', 'MaxOrder', 'MaxOrder', {};...
        'Maxium step size', 'MaxStep', 'MaxStep', {};...
        'Minum step size', 'MinStep', 'MinStep', {};...
        'Relative tolerance', 'RelTol', 'RelTol', {};...
        'Tasking mode', 'SolverMode', 'SolverMode', {'Auto', 'SingleTasking', 'MultiTasking'};...
        'Solver', 'Solver', 'Solver', {'VariableStepDiscrete', 'ode45', 'ode23', 'ode113', 'ode15s', 'ode23s', 'ode23t', 'ode23tb', 'FixedStepDiscrete', 'ode5', 'ode4', 'ode3', 'ode2', 'ode1'};...
        % 'SolverType', derivative param from Solver, not writtable
        'Global zero cross control', 'ZeroCrossControl', 'ZeroCrossControl', {'UseLocalSettings', 'EnableAll', 'DisableAll'};... %R14 only
        % 'Zero cross algoritnm', only accessable via ConfigSet object. 
    % Data Import/Export
        'Decimation', 'Decimation', 'Decimation', {};...
        'External input', 'ExternalInput', 'ExternalInput', {};...    
        'Final state name', 'FinalStateName', 'FinalStateName', {};...
        'Initial state name', 'InitialState', 'InitialState', {};...
        'Limit save data points', 'LimitDataPoints', 'LimitDataPoints', {'on', 'off'};...
        'Maxium save data points', 'MaxDataPoints', 'MaxDataPoints', {};...
        'Load external input', 'LoadExternalInput', 'LoadExternalInput', {'on', 'off'};...
        'Load initial state', 'LoadInitialState', 'LoadInitialState', {'on', 'off'};...
        'Save final state', 'SaveFinalState', 'SaveFinalState', {'on', 'off'};...
        'Save format', 'SaveFormat', 'SaveFormat', {'Array', 'StructureWithTime', 'Structure'};...
        'Save output', 'SaveOutput', 'SaveOutput', {'on', 'off'};...
        'Save state', 'SaveState', 'SaveState', {'on', 'off'};...
        'Save time', 'SaveTime', 'SaveTime', {'on', 'off'};...
        'State save name on workspace', 'StateSaveName', 'StateSaveName', {};...
        'Time save name on workspace', 'TimeSaveName', 'TimeSaveName', {};...
        'Output save name on workspace', 'OutputSaveName', 'OutputSaveName', {};...
        'Signal logging name', 'SignalLoggingName', 'SignalLoggingName', {};...
        'Output option', 'OutputOption', 'OutputOption', {'RefineOutputTimes', 'AdditionalOutputTimes', 'SpecifiedOutputTimes'};...
        'Output times', 'OutputTimes', 'OutputTimes', {};...
        'Output refine factor', 'Refine', 'Refine', {};...
        
    % Optimization
        'Eliminate redundant blocks (block reduction)', 'BlockReduction', 'BlockReduction', {'on', 'off'};...
        'Implement logic signals as boolean data', 'BooleanDataType', 'BooleanDataType', {'on', 'off'};...
        %'Conditionally execute blocks without state that feed switch operations', 'ConditionallyExecuteInputs', 'ConditionalExecOptimization', {'on', 'off'};...  % R13 version, it will disappear from ObjectParamaeters list in R14.
        %'Conditionally execute blocks without state that feed switch operations', 'ConditionalExecOptimization', 'ConditionalExecOptimization', {'on', 'off'};...  % R14 version
%         'Inline parameter values', 'InlineParams', 'InlineParams', {'on', 'off'};...  % R13 & R14
%         'Inline parameter values', 'InlineParameters', 'InlineParams', {'on', 'off'};... % R14 only 
        'Inline parameter values', 'InlineParams', 'InlineParams', {'on', 'off'};
        'Inline invariant signals with macros', 'InlineInvariantSignals', 'InlineInvariantSignals',  {'on', 'off'};...
        'Implement every signal in persistent global memory (1 of 2)', 'OptimizeBlockIOStorage', 'OptimizeBlockIOStorage', {'on', 'off'};...
        'Reuse local (stack) variables', 'BufferReuse', 'BufferReuse', {'on', 'off'};...
        'Preserve integer downcasts in folded expressions', 'EnforceIntegerDowncast', 'EnforceIntegerDowncast', {'on', 'off'};...
        'Eliminate superfluous temporary variables (expression folding)', 'ExpressionFolding', 'ExpressionFolding', {'on', 'off'};...
        'Expression fold unrolled vector signals', 'FoldNonRolledExpr', 'FoldNonRolledExpr', {'on', 'off'};...       
        'Implement every signal in persistent global memory (2 of 2)', 'LocalBlockOutputs', 'LocalBlockOutputs', {'on', 'off'};...
        'Generate reusable code for the entire model', 'MultiInstanceERTCode', 'MultiInstanced',  {'on', 'off'};...
        'Optimize storage of non-scalar parameter values', 'ParameterPooling', 'ParameterPooling', {'on', 'off'};...
        'For storing state information in Stateflow charts', 'StateBitsets', 'StateBitSets', {'on','off'};
        'For storing boolean data in Stateflow charts', 'DataBitsets', 'DataBitsets', {'on','off'};...
        'RTW System code inline auto', 'SystemCodeInlineAuto', 'SystemCodeInlineAuto', {'on', 'off'};...
        % IOFormat : stateflow option, skip for now
        
    % Debugging
        'Consistency checking', 'ConsistencyChecking', 'ConsistencyChecking', {'none', 'warning', 'error'} ;...
        'Array bounds checking', 'ArrayBoundsChecking', 'ArrayBoundsChecking', {'none', 'warning', 'error'} ;...
        'Algebraic loop', 'AlgebraicLoopMsg', 'AlgebraicLoopMsg', {'none', 'warning', 'error'} ;...
        'Block priority violation', 'BlockPriorityViolationMsg', 'BlockPriorityViolationMsg', {'warning', 'error'} ;...
        'Minial step size violation', 'MinStepSizeMsg', 'MinStepSizeMsg', {'warning', 'error'} ;...
        '-1 sample time in source', 'InheritedTsInSrcMsg', 'InheritedTsInSrcMsg', {'none', 'warning', 'error'} ;...
        'Discrete used as continuous', 'DiscreteInheritContinuousMsg', 'DiscreteInheritContinuousMsg', {'none', 'warning', 'error'} ;...
        'MultiTask rate transition', 'MultiTaskRateTransMsg', 'MultiTaskRateTransMsg', {'warning', 'error'} ;...
        'SingleTask rate transition', 'SingleTaskRateTransMsg', 'SingleTaskRateTransMsg', {'none', 'warning', 'error'} ;...
        'Check for singular matrix', 'CheckMatrixSingularityMsg', 'CheckForMatrixSingularity', {'none', 'warning', 'error'} ;...
        'Data overflow', 'IntegerOverflowMsg', 'IntegerOverflowMsg', {'none', 'warning', 'error'} ;...
        'Int32 to float conversion', 'Int32ToFloatConvMsg', 'Int32ToFloatConvMsg', {'none', 'warning'} ;...
        'Parameter downcast', 'ParameterDowncastMsg', 'ParameterDowncastMsg', {'none', 'warning', 'error'} ;...
        'Parameter overflow', 'ParameterOverflowMsg', 'ParameterOverflowMsg', {'none', 'warning', 'error'} ;...
        'Parameter precision loss', 'ParameterPrecisionLossMsg', 'ParameterPrecisionLossMsg', {'none', 'warning', 'error'} ;...
        'Under specified data types', 'UnderSpecifiedDataTypeMsg', 'UnderSpecifiedDataTypeMsg', {'none', 'warning', 'error'} ;...
        'Unneeded type conversions', 'UnnecessaryDatatypeConvMsg', 'UnnecessaryDatatypeConvMsg', {'none', 'warning'} ;...
        'Vector/Matrix conversion', 'VectorMatrixConversionMsg', 'VectorMatrixConversionMsg', {'none', 'warning', 'error'} ;...
        'Model reference I/O', 'ModelReferenceIOMsg', 'ModelrefIOMsg', {'none', 'warning', 'error'} ;...
        'Invalid FunCall connection', 'InvalidFcnCallConnMsg', 'InvalidFcnCallConnMsg', {'none', 'warning', 'error'} ;...
        'Singal lable mismatch', 'SignalLabelMismatchMsg', 'SignalLabelMismatchMsg', {'none', 'warning', 'error'} ;...
        'Unconnected block input', 'UnconnectedInputMsg', 'UnconnectedInputMsg', {'none', 'warning', 'error'} ;...
        'Unconnected block output', 'UnconnectedOutputMsg', 'UnconnectedOutputMsg', {'none', 'warning', 'error'} ;...
        'Unconnected line', 'UnconnectedLineMsg', 'UnconnectedLineMsg', {'none', 'warning', 'error'} ;...
        'S-function upgrades needed', 'SFcnCompatibilityMsg', 'SfunCompatibilityCheckMsg', {'none', 'warning', 'error'} ;...
        'Show build log inside MATLAB Command Window', 'RTWVerbose', 'RTWVerbose',    {'on', 'off'};...
        'Retain RTW file', 'RetainRTWFile', 'RetainRTWFile', {'on', 'off'};...
        'Profile TLC file', 'ProfileTLC', 'ProfileTLC', {'on', 'off'};...
        'Start TLC debugger when generating code', 'TLCDebug', 'TLCDebug', {'on', 'off'};...
        'Start TLC coverage when generating code', 'TLCCoverage', 'TLCCoverage', {'on', 'off'};...
        'Enable TLC assertions', 'TLCAssert', 'TLCAssertion', {'on', 'off'};...
        'Model verification block control', 'AssertControl', 'AssertControl', {'UseLocalSettings', 'EnableAll', 'DisableAll'};...
        % 'Stateflow echo', skip for now
        % 'Stateflow enable overflow detection', skip for now
        
        
    % Custom Code: Stateflow options, skip for now        
        % 'CustomCode'
        % 'CustomInitializer'
        % 'CustomTerminator'
        % 'UserIncludeDirs'
        % 'UserLibs'
        % 'UserSrcs'
    
    % Hardware Implementation
        'Production hardware characteristics', 'ProdHWDeviceType', 'ProdHWDeviceType', {'Specified','32-bit Generic','Infineon TriCore',...
                                                                                        'Motorola PowerPC','Motorola 68332','NEC 85x',...
                                                                                        'Hitachi SH-2','TI C6000','16-bit Generic',...
                                                                                        'ARM7','Infineon C16x','Motorola HC12','ASIC/FPGA'};...
        'Number of bits per char', 'ProdBitPerChar', 'ProdBitPerChar', {};... 
        'Number of bits per int', 'ProdBitPerInt', 'ProdBitPerInt', {};... 
        'Number of bits per long', 'ProdBitPerLong', 'ProdBitPerLong', {};... 
        'Number of bits per short', 'ProdBitPerShort', 'ProdBitPerShort', {};...
        
    % Document
        % 'DocumentLink', Stateflow options, skip for now        
        'Document generated code inside an HTML report', 'GenerateReport', 'GenerateReport',   {'on', 'off'};...
        
    % Code Appearance
        % 'Comment', stateflow option
        'Unconditionally comment parameter data structure', 'ForceParamTrailComments', 'ForceParamTrailComments', {'on', 'off'};...
        'Include comments', 'GenerateComments', 'GenerateComments', {'on', 'off'};...
        'Ignore custom storage classes', 'IgnoreCustomStorageClasses', 'IgnoreCustomStorageClasses',  {'on', 'off'};...
        'Include system hierarchy number in identifiers', 'IncHierarchyInIds', 'IncHierarchyInIds',  {'on', 'off'};...
        'Maximum identifier length (does not apply to Stateflow identifiers)', 'MaxIdLength', 'MaxIdLength', {};...
        % 'PreserveName' stateflow option
        % 'PreserveNameWithParent' stateflow option
        'Show eliminated code statements', 'ShowEliminatedStatement', 'ShowEliminatedStatement',    {'on', 'off'};...

    % RTW Target
        'RTW system target file', 'SystemTargetFile', 'SystemTargetFile', {};...
        % 'Code generation directory', only accessable via ConfigSet, R14 only
        'Generate code only', 'GenCodeOnly', 'GenCodeOnly', {'on', 'off'};...
        'RTW make command', 'MakeCommand', 'MakeCommand', {};...
        'Template make file', 'TemplateMakefile', 'TemplateMakefile', {};...
        'Include data type acronym in identifier', 'IncDataTypeInIds', 'IncDataTypeInIds', {'on', 'off'};...
        'Prefix model name to global identifiers', 'PrefixModelToSubsysFcnNames', 'PrefixModelToSubsysFcnNames', {'on', 'off'};...
        'Generate scalar inlined parameters as', 'InlinedPrmAccess', 'InlinedPrmAccess', {'Literals', 'Macros'};...
        'Generate full header including time stamp', 'GenerateFullHeader', 'GenerateFullHeader', {'on', 'off'};...
        'Processor in the loop Target', 'IsPILTarget', 'IsPILTarget', {'on', 'off'};...
        'MAT-file variable name modifier', 'LogVarNameModifier', 'LogVarNameModifier', {'rt_', 'none', '_rt'};... % R14 GRT only
        'Instrument code for Simulink External Mode', 'ExtMode', 'ExtMode', {'on', 'off'};...
%       'External mode transport layer', 'ExtModeTransport', 'ExtModeTransport', {'tcpip', 'serial_win32'};...
        'External mode transport layer', 'ExtModeTransport', 'ExtModeTransport', {};...
        
   % Additional options 
        'Initialize root level I/O data to zero', 'ZeroExternalMemoryAtStartup', 'ZeroExternalMemoryAtStartup', {'on', 'off'};...
        'Initialize internal state data to zero', 'ZeroInternalMemoryAtStartup', 'ZeroInternalMemoryAtStartup', {'on', 'off'};...
        'Explicitly initialize floats and doubles to 0.0', 'InitFltsAndDblsToZero', 'InitFltsAndDblsToZero', {'on', 'off'};...
        'Parameter structure implementation', 'InlinedParameterPlacement', 'InlinedParameterPlacement', {'Hierarchical', 'NonHierarchical'};...
        'Generate a concise example main program for this model', 'GenerateSampleERTMain', 'GenerateSampleERTMain', {'on', 'off'};...
        'Target operating system', 'TargetOS', 'TargetOS', {'BareBoardExample', 'VxWorksExample'};...
        'Generate integer code only', 'PurelyIntegerCode', 'PurelyIntegerCode', {'on', 'off'};...
        'Target floating point math environment', 'GenFloatMathFcnCalls', 'GenFloatMathFcnCalls', {'ANSI_C', 'ISO_C'};...
        'Unroll for loops when signal width does not exceed threshold', 'RollThreshold', 'RollThreshold', {};...
        'Insert Simulink block descriptions', 'InsertBlockDesc', 'InsertBlockDesc', {'on', 'off'};...
        'Create Simulink (S-Function) block for software-in-the-loop testing', 'GenerateErtSFunction', 'GenerateErtSFunction', {'on', 'off'};...
        'Instrument the generated code to log results into a MAT-file', 'MatFileLogging', 'MatFileLogging',   {'on', 'off'};...
        'Reusable code error diagnostic', 'MultiInstanceErrorCode', 'MultiInstanceErrorCode',  {'Error', 'Warning', 'None'};...
        'Pass root level I/O data as', 'RootIOFormat', 'RootIOStructures',  {'Individual Arguments', 'Structure Reference'};...
        'Suppress error status in real-time model data structure', 'SuppressErrorStatus', 'SuppressErrorStatus',  {'on', 'off'};...
        'Combine the model step function into a single output/update function', 'CombineOutputUpdateFcns', 'CombineOutputUpdateFcns', {'on', 'off'};...
        'Generate a model termination function', 'IncludeMdlTerminateFcn', 'IncludeMdlTerminateFcn',  {'on', 'off'};...
        'Generate an ASAP2 data exchange file', 'GenerateASAP2', 'GenerateASAP2', {'on', 'off'};...
        'Generate a C-interface API for runtime Signal monitoring', 'RTWCAPISignals', 'BlockIOSignals',       {'on', 'off'};...
        'Generate a C-interface API for runtime Parameter tuning', 'RTWCAPIParams', 'ParameterTuning',     {'on', 'off'};...
        
    };
    verinfo = ver('simulink');
    vernum = str2num(verinfo.Version(1:3));
    R13str = {'Conditionally execute blocks without state that feed switch operations', 'ConditionallyExecuteInputs', 'ConditionalExecOptimization', {'on', 'off'};}; % R13 version, it will disappear from ObjectParamaeters list in R14.
    R14str = {'Conditionally execute blocks without state that feed switch operations', 'ConditionalExecOptimization', 'ConditionalExecOptimization', {'on', 'off'};};  % R14 version
    if abs(vernum - 5.0) > 1e-4
        % TranslationTable = [TranslationTable; R14str]; % Vertical concatenation
        % always using R13 style for increase compatiability.
        TranslationTable = [TranslationTable; R13str]; % Vertical concatenation
    else
        TranslationTable = [TranslationTable; R13str]; % Vertical concatenation
    end
end

% return full table if empty paramName pass in
if isempty(paramName)
    internalName = TranslationTable;
    return;
end

% do translation
for i=1:length(TranslationTable)
    if strcmp(TranslationTable(i, 3), paramName)
        internalName = TranslationTable(i,2);
        if ~isempty(paramValue)
            validValueGroup = TranslationTable(i,4);
            validValueGroup = validValueGroup{1};
        else
            % if only pass in paramName, we'll only translate paramName
            internalValue = '';
            return
        end
        if ~isempty(validValueGroup)
            % if validValueGroup is 'on/off' group, translate 'on/off' into
            % it.
            if (strcmpi(validValueGroup(1), 'Yes'))
                if strcmpi(paramValue, 'on')
                    paramValue = 'Yes';
                elseif strcmpi(paramValue, 'off')
                    paramValue = 'No';
                end
            end
            
            for j=1:length(validValueGroup)
                if strcmpi(validValueGroup(j), paramValue)
                    internalValue = validValueGroup(j);
                    return
                end
            end
            % if reach here, means value not found in validValueGroup
            error(['Invalid input parameter value: ' paramValue ' for parameter: ' paramName]);
        else
            % no rescrition on valid values 
            internalValue = paramValue;
        end
        return
    end
end
% if not found in the table, keep the original pair untouched
internalName = paramName;
internalValue = paramValue;
