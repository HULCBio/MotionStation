function buildOptions = getBuildOptionsList (h, modelInfo)
% $RCSfile: getBuildOptionsList.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:05:49 $
% Copyright 2003-2004 The MathWorks, Inc.

compilerStr = getCompilerOptions (h, modelInfo);
BIOSstr = '';
linkerStr = getLinkerOptions (h, modelInfo);

% convert strings to cell array
buildOptions = {linkerStr; compilerStr};

%-------------------------------------------------------------------------------
function compilerStr = getCompilerOptions (h, modelInfo)

compilerStr='';

% symbolic debug
if isequal (h.getCompilerOptions.getSymbolicDebugging, 'Yes'),
    compilerStr = '-g ';
end

% Optimization level?
switch h.getCompilerOptions.getOptimizationLevel
case 'None'
    % No addition to string
case 'Register(-o0)'
    compilerStr = [compilerStr '-o0 '];
case 'Local(-o1)'
    compilerStr = [compilerStr '-o1 '];
case 'Function(-o2)'
    compilerStr = [compilerStr '-o2 '];
case 'File(-o3)'
    compilerStr = [compilerStr '-o3 '];
otherwise
    error('getBuildOptionsList:  Invalid optimization level string')
end

% retain .asm files?
if isequal (h.getCompilerOptions.keepASMFiles, 'on'),
    compilerStr = [compilerStr '-k -ss '];
end
    
switch h.getCompilerOptions.compilerVerbosity
case 'Quiet'
    str = '-q ';
case 'Super_quiet'
    str = '-qq ';
case 'Verbose'
    str = '';
end
compilerStr = [compilerStr str];

compilerStr = [compilerStr '-v2xx '];

% get include paths
compilerStr = [compilerStr h.getIncludePaths];

% get some model compiled data:
d = ti_RTWdefines('get');

% set Overrun option
switch h.getRunTimeOptions.OverrunAction
case 'None'
    mode = '0';
case 'Notify_and_continue'
    mode = '1';
case 'Notify_and_halt'
    mode = '2';
otherwise
    mode = '2'; % this is an old model, set the default value for 'overrunAction'
end
compilerStr = [compilerStr '-d"OVERRUN_ACTION=' mode '" '];

% set RTW symbol defines
compilerStr = [compilerStr '-d"MODEL='    modelInfo.name            '" '];
compilerStr = [compilerStr '-d"RT" '                                    ];
compilerStr = [compilerStr '-d"NUMST='    num2str(d.NumSampleTimes) '" '];
compilerStr = [compilerStr '-d"TI01EQ='   num2str(d.FixedStepOpts)  '" '];
compilerStr = [compilerStr '-d"NCSTATES=' num2str(d.NumContStates)  '" '];
compilerStr = [compilerStr '-d"USE_RTMODEL=1" '];

if isequal (d.SolverMode, 'MultiTasking'),
    str = '-d"MT=1" ';
else % 'SingleTasking'
    str = '-d"MT=0" ';
end
compilerStr = [compilerStr str];


%-------------------------------------------------------------------------------
function linkerStr = getLinkerOptions (h, modelInfo)

linkerStr = '';

% suppress progress messages
linkerStr = [linkerStr '-q '];

% autoinitialize variables at loadtime
linkerStr = [linkerStr '-c '];

% create map file if specified
if isequal (h.getLinkerOptions.getCreateMAPFile, 'on'),
    linkerStr = [linkerStr '-m' modelInfo.name '.map '];
end

% create COFF file
linkerStr = [linkerStr '-o"' modelInfo.name '.out" '];

% create larger stack if using full memory map
if isequal (h.getLinkerOptions.LinkerCMDFile, 'Full_memory_map'),
    linkerStr = [linkerStr '-stack0x400 '];
else
    linkerStr = [linkerStr '-stack0x200 '];    
end

% read libraries exhaustively
linkerStr = [linkerStr '-x '];

% define library search path
mlroot = feval ('matlabroot');
linkerPath = ['-i"' mlroot '\toolbox\rtw\targets\tic2000\tic2000\rtlib" '];

% include runtime support libraries
linkerLibs = '-l"dsp_rt_c2400.lib" -l"rtw_rt_c2400.lib" ';

%only little endian supported now
linkerLibs = [ linkerLibs '-l"rts2xx.lib" '];
    
% create linker options string
linkerStr = [linkerStr linkerPath linkerLibs];

linkerStr = [linkerStr '-v2 '];

% [EOF] getBuildOptionsList.m

