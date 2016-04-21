function buildOptions = getBuildOptionsList_TItarget(modelInfo)

% $RCSfile: getBuildOptionsList_TItarget.m,v $
% $Revision: 1.1.6.4 $ $Date: 2004/04/08 21:07:55 $
% Copyright 2001-2004 The MathWorks, Inc.

% create compiler options string
compilerStr = getCompilerOptions(modelInfo);

% create BIOS builder string
BIOSstr = '';

% create linker options string
linkerStr = getLinkerOptions(modelInfo);

% convert strings to cell array
buildOptions = {linkerStr;BIOSstr;compilerStr};


%-------------------------------------------------------------------------------
function compilerStr = getCompilerOptions(modelInfo)

compilerStr='';

% symbolic debug
if isSymbolicDebug(modelInfo.buildArgs),
    compilerStr = '-g ';
end

% Optimization level?
optLevelStr = parseRTWBuildArgs_DSPtarget(modelInfo.buildArgs,'OPT_LEVEL');
switch optLevelStr
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
if isRetainASM(modelInfo.buildArgs),
    compilerStr = [compilerStr '-k -ss '];
end
    
banners = parseRTWBuildArgs_DSPtarget(modelInfo.buildArgs,'BANNERS');
switch banners
case 'Quiet'
    str = '-q ';
case 'Super_quiet'
    str = '-qq ';
case 'Verbose'
    str = '';
end
compilerStr = [compilerStr str];

% endianness
if isBigEndian(modelInfo.buildArgs),
	compilerStr =[compilerStr '-me '];
end

% get include paths
targetType = getTargetType_DSPtarget(modelInfo.name);
includePaths = getIncludePaths_DSPtarget(modelInfo, targetType);
compilerStr = [compilerStr includePaths];

% get some model compiled data:
d = ti_RTWdefines('get');

% set Overrun option
overrunAction = parseRTWBuildArgs_DSPtarget(modelInfo.buildArgs,'OVERRUN_ACTION');
switch overrunAction
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
compilerStr = [compilerStr '-d"USE_RTMODEL" '                           ];
compilerStr = [compilerStr '-d"ERT_CORE" '                           ];

cs = getActiveConfigSet(modelInfo.name);
if strcmp(get_param(cs,'SystemTargetFile'),'ti_c6000_ert.tlc'),
    integerCode = strcmp(get_param(cs,'PurelyIntegerCode'), 'on');
    compilerStr = [compilerStr '-d"INTEGER_CODE=' ...
        num2str(integerCode) '" '];
    MultiInstanceERTCode = strcmp(get_param(cs,'MultiInstanceERTCode'), 'on');
    compilerStr = [compilerStr '-d"MULTI_INSTANCE_CODE='  ...
        num2str(MultiInstanceERTCode) '" '];

end
haveSTDIO = ~strcmp(get_param(cs,'useDSPBIOS'),'off');
compilerStr = [compilerStr '-d"HAVESTDIO=' num2str(haveSTDIO) '" '];

if isInline(modelInfo.buildArgs)
    compilerStr = [compilerStr '-d"MWDSP_INLINE_DSPRTLIB" '             ];
end

if isMultiTasking_DSPtarget(d.SolverMode),
    str = '-d"MT=1" ';
else % 'SingleTasking'
    str = '-d"MT=0" ';
end
compilerStr = [compilerStr str];

% static options:
%    set RTDX interrupt flag
compilerStr = [compilerStr '-mi '];

% processor-specific compiler switches: '-mv6700' or '-mv6710'
compilerStr = [compilerStr feval(['getCompilerSwitch_' targetType], ...
        isFullMemoryMap(modelInfo.buildArgs)) ' '];

% define chip name  
switch targetType,
    case 'C6711DSK',
        compilerStr = [compilerStr '-d"CHIP_6711" '];
    case 'C6701EVM',
        compilerStr = [compilerStr '-d"CHIP_6701" '];
    case 'C6416DSK',
        compilerStr = [compilerStr '-d"CHIP_6416" '];
    case 'C6713DSK',
        compilerStr = [compilerStr '-d"CHIP_6713" '];
    otherwise,
        error(['unsupported target type: ' targetType])
end

% if High Speed RTDX used, define its symbol
if isUsingHighSpeedRTDX_TItarget & isDSK(modelInfo.buildArgs)
    compilerStr = [compilerStr '-d"HSRTDX" '];
end


%-------------------------------------------------------------------------------
function linkerStr = getLinkerOptions(modelInfo)

linkerStr = '';

% suppress progress messages
linkerStr = [linkerStr '-q '];
% autoinitialize variables at runtime
linkerStr = [linkerStr '-c '];

% create map file if specified
if isCreateMAP(modelInfo.buildArgs),
    linkerStr = [linkerStr '-m' modelInfo.name '.map '];
end

% create COFF file
linkerStr = [linkerStr '-o"' modelInfo.name '.out" '];

% create large stack if using full memory map
if isFullMemoryMap(modelInfo.buildArgs),
    linkerStr = [linkerStr '-stack0x40000 '];
else
    linkerStr = [linkerStr '-stack0x2000 '];    
end

% read libraries exhaustively
linkerStr = [linkerStr '-x '];

% library search path
if exist('tmpTiMatlabRoot.m','file'),
    mlroot_ti_tmp = tmpTiMatlabRoot;
else
    mlroot_ti_tmp = matlabroot;
end
rtlibdir = fullfile(mlroot_ti_tmp, ...
    'toolbox','rtw','targets','tic6000', 'tic6000','rtlib');
linkerStr = [linkerStr '-i"' rtlibdir '" '];

% Run-time libraries
linkerStr = getRTlibNames(modelInfo, linkerStr);

% ------------------------------------------------
function linkerStr = getRTlibNames(modelInfo,linkerStr)

targetType = getTargetType_DSPtarget(modelInfo.name);

% Get appropriate -mvXXXX switch value for this target
% (although we do not always get to use this)
switch targetType,
    case 'C6416DSK',
        mvSwitch = '6410'; % Actually it's 6400, but this is what we've used
    case 'C6701EVM',
        mvSwitch = '6700';
    case {'C6711DSK','C6713DSK'}
        mvSwitch = '6710';
end

endianness = parseRTWBuildArgs_DSPtarget(modelInfo.buildArgs,'ENDIAN');
if strcmp(endianness,'Big_endian'),
    endianStr = 'e';
else
    endianStr = '';
end

% MathWorks product runtime libraries (order is important)
% if ~strcmp(targetType,'C6416DSK'),
%     linkerStr = [linkerStr '-l"dsp_rt_asm_c' mvSwitch endianStr '.lib" '];
% end
linkerStr = [linkerStr '-l"dsp_rt_c' mvSwitch endianStr '.lib" '];
linkerStr = [linkerStr '-l"rtw_rt_c' mvSwitch endianStr '.lib" '];

% Libraries that we need to add if DSP/BIOS is not used
useDSPBIOS = isUsingDSPBIOS_TItarget(modelInfo);
if (~useDSPBIOS),
    
    % C Run-time support library
    % note: there is no C6711-specific rts library
    switch targetType,
        case 'C6416DSK',
            linkerStr = [linkerStr '-l"rts6400' endianStr '.lib" '];
        otherwise,
            linkerStr = [linkerStr '-l"rts6701' endianStr '.lib" '];
    end
    
    % RTDX
    if isRTDXLibNeeded(modelInfo)
        if isUsingHighSpeedRTDX_TItarget && isDSK(modelInfo.buildArgs),
            linkerStr = [linkerStr '-l"rtdxhs' endianStr '.lib" '];
        else
            switch targetType,
                case 'C6416DSK',
                    linkerStr = [linkerStr '-l"rtdx64xx' endianStr '.lib" '];
                otherwise,
                    linkerStr = [linkerStr '-l"rtdx'     endianStr '.lib" '];
            end                
        end
    end
    
    % Chip Support Library, % e.g. "csl6416e.lib"
    chipID = targetType(2:5);  
    linkerStr = [linkerStr '-l"csl' chipID endianStr '.lib" '];
    
end % ~useDSPBIOS


% C62/C64 DSP Library
[c62_used, c64_used] = checkDspLibraryUse(modelInfo, targetType, endianness);
if c62_used,
    linkerStr = [linkerStr '-l"dsp62x.lib" '];
elseif c64_used,
    linkerStr = [linkerStr '-l"dsp64x.lib" '];
end


%---------------------------------------------------------
function cell2 = addItem(cell1, item1)
% Add item to cell array (shorthand)

cell2 = cell1;
cell2{end+1} = item1;


%---------------------------------------------------------
function bool = isRTDXLibNeeded(modelInfo)
ToRTDXblock = find_system(modelInfo.name, ...
    'FollowLinks','on','LookUnderMasks','on','MaskType','To RTDX');
FromRTDXblock = find_system(modelInfo.name, ...
    'FollowLinks','on','LookUnderMasks','on','MaskType','From RTDX');
bool = ~isempty(ToRTDXblock) || ~isempty(FromRTDXblock);

%--------------------------------------------------------------------------
function bool = isUserOption(variable,value,args)
setting = parseRTWBuildArgs_DSPtarget(args,variable);
bool =  strcmp(setting,value);


%---------------------------------------------------------
function bool = isDSK(args)
bool = ~isUserOption('TARGET_TYPE','C6701EVM',args);

%---------------------------------------------------------
function [c62_used, c64_used] = ...
    checkDspLibraryUse(modelInfo, targetType, endianness)

% First do some error checking, as long as we are doing find_system
c62_blks = find_system(modelInfo.name, ...
    'followlinks','on', ...
    'lookundermasks','on', ...
    'Regexp','on', ...
    'ReferenceBlock','^tic62dsplib');
c64_blks = find_system(modelInfo.name, ...
    'followlinks','on', ...
    'lookundermasks','on', ...
    'Regexp','on', ...
    'ReferenceBlock','^tic64dsplib');

c62_used = ~isempty(c62_blks);
c64_used = ~isempty(c64_blks);


% Verify that C62 and C64 dsplib blocks do not coexist
if c62_used && c64_used,
    error(['C62x DSP Library blocks and C64x DSP Library blocks ' ...
        'cannot coexist in a model.']);
end

% Verify that C62 or C64 dsplib blocks match target type
if c62_used && strcmp(targetType,'C6416DSK'),
    warning(['C62x DSP Library blocks can be used on C64x hardware, ' ...
        'but the same algorithms will be faster if you use the ' ...
        'corresponding blocks from C64x DSP Library.']);
end
if c64_used && ~strcmp(targetType,'C6416DSK'),
    error(['C64x DSP Library blocks will only work on C64x hardware. ' ...
        'Use C62x DSP Library blocks if you intend to target C67x or C62x ' ...
        'hardware.']);
end

% Check endianness
if strcmp(endianness,'Big_endian') && (c62_used || c64_used),
    error('C62x/C64x DSP Libraries require little-endian byte order.')
end


%-------------------------------------------------------------------------------
function bool = isSymbolicDebug(args)
bool = isUserOption('SYMBOLIC_DEBUG','1',args);

function bool = isRetainASM(args)
bool = isUserOption('RETAIN_ASM','1',args);

function bool = isBigEndian(args)
cs = getActiveConfigSet(gcs);
e = get_param(cs,'TargetEndianess');
bool = strcmp(e,'BigEndian');

function bool = isCreateMAP(args)
bool = isUserOption('CREATE_MAP','1',args);

function bool = isFullMemoryMap(args)
bool = isUserOption('LINKER_CMD','Full_memory_map',args);

function bool = isInline(args)
bool = isUserOption('INLINE_DSPBLKS','1',args);



% [EOF] getBuildOptionsList_TItarget.m
