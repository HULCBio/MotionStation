function throwError = parse_kernel(machineId,chartId,targetId,parentTargetId,mainMachineId)
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.5.2.1 $  $Date: 2004/04/15 00:58:58 $

throwError = 0;

if(nargin<5)
    mainMachineId = machineId;
end
if(isempty(mainMachineId))
    mainMachineId = machineId;
end
if(~isempty(chartId))
    objectType = 'chart';
    parseObjectId = chartId;
else
    objectType = 'machine';
    parseObjectId = machineId;
end

try,
    sf('Parse', parseObjectId, targetId, parentTargetId);
catch,
    throwError = 1;
end

switch(objectType)
case 'chart'
    allCharts = chartId;
case 'machine'
    allCharts = sf('get',machineId,'machine.charts');
end

allowedSymbolsInfo = collect_custom_code_syms(parentTargetId);
exportedFunctionsInfo = collect_exported_functions(targetId,parentTargetId,mainMachineId);

hasUnresolvedSymbols = 0;
for i=1:length(allCharts)
    if(parser_unresolved_symbol(machineId,...
                                allCharts(i),...
                                targetId,...
                                allowedSymbolsInfo,...
                                exportedFunctionsInfo))
        hasUnresolvedSymbols = 1;
        throwError = 1;
    end
end

% call symbol-wiz no matter what. it will hide the GUI if no symbols.

symbol_wiz('New',parseObjectId);    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allowedSymbolsInfo = collect_custom_code_syms(targetId)

[targetName,customCode] = sf('get',targetId,'target.name','target.customCode');
allowedSymbolsInfo.ignoreUnresolvedSymbols = 1;
allowedSymbolsInfo.symbols = [];
 
if sfc('coder_options','ignoreUnresolvedSymbols')
    return;
end
if ~strcmp(targetName,'sfun')
    % Not an SFunction target. Dont bother.
    return;
end

if(isempty(customCode))
    % No custom code for sfunction target. no allowed symbols. 
	allowedSymbolsInfo.ignoreUnresolvedSymbols = 0;
    return;
end
    
if(~ispc)
    return;
end

% If you are here, the following are true:
% It is an S-function target, which has custom code 
% and we are on PC.
    
compilerInfo = compilerman('get_compiler_info');
compilerIsLcc = strcmp(compilerInfo.compilerName,'lcc');
if(compilerIsLcc)
    allowedSymbolsInfo.ignoreUnresolvedSymbols = 0;
    allowedSymbolsInfo.symbols = collect_custom_code_symbols(targetId,customCode,{});
else
    allowedSymbolsInfo.ignoreUnresolvedSymbols = 1;
	allowedSymbolsInfo.symbols = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allowedSymbolsInfo = collect_exported_functions(targetId,parentTargetId,mainMachineId)

   defaultAllowedSymbols = {
      'min'
      'max'
      'sin'
      'cos'
      'tan'
      'asin'
      'acos'
      'atan'
      'atan2'
      'sinh'
      'cosh'
      'tanh'
      'exp'
      'log'
      'log10'
      'pow'
      'sqrt'
      'ceil'
      'floor'
      'fabs'
      'ldexp'
      'fmod'
      'rand'
      'abs'
      'labs'
   };

[targetName,customCode] = sf('get',parentTargetId,'target.name','target.customCode');
allowedSymbolsInfo.ignoreUnresolvedSymbols = 1;
allowedSymbolsInfo.symbols = [];

if sfc('coder_options','ignoreUnresolvedSymbols')
    return;
end
if ~strcmp(targetName,'sfun')
    % Not an SFunction target. Dont bother.
    return;
end

if(~isempty(customCode))
    % There is custom code for sfunction target. No error checking 
    return;
end

allowedSymbolsInfo.ignoreUnresolvedSymbols = 0;
allowedSymbolsInfo.symbols = defaultAllowedSymbols;

exportedFcnInfo = sf('get',mainMachineId,'machine.exportedFcnInfo');
for i=1:length(exportedFcnInfo)    
    allowedSymbolsInfo.symbols{end+1} = exportedFcnInfo(i).name;
end

