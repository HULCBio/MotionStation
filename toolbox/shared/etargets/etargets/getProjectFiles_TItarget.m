function list = getProjectFiles_TItarget(modelName, type, useDSPBIOS)

% $RCSfile: getProjectFiles_TItarget.m,v $
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:08:01 $
% Copyright 2001-2004 The MathWorks, Inc.

names = { [modelName '_main'] ...
        'MW_c6xxx_csl' ...      
        'MW_c62xx_clib' };  

extensions   = {'.c' '.c' '.c'};

% Determine whether rt_nonfinite.c is needed. 
% Logic is copied from toolbox/rtw/rtw/gen_rtnonfinite.m.
% If the file is required, it will be generated into the 
% codegen directory by RTW. 
cs = getActiveConfigSet(modelName);
if ~(strcmp(uget_param(modelName, 'IsERTTarget'), 'on') && ...
        (strcmp(uget_param(modelName, 'PurelyIntegerCode'),'on') || ...
        (hasProp(cs, 'SupportNonFinite') && ...
        strcmp(uget_param(modelName, 'SupportNonFinite'),'off')))),
    names = {names{:} 'rt_nonfinite'};
    extensions = {extensions{:} '.c'};
end

% Determine whether rt_sim.c is needed.
% This is only so if the target is GRT-based.
if strcmp(get_param(cs,'SystemTargetFile'),'ti_c6000.tlc'),
    names = {names{:} 'rt_sim'};
    extensions = {extensions{:} '.c'};
end

rtwDefines = ti_RTWdefines ('get');
srcFilesList = rtwDefines.SourceFiles;
while ( ~isempty(srcFilesList) )
    [filename, srcFilesList] = strtok (srcFilesList);    
    [pathstr, name, ext, versn] = fileparts(filename);
    names = { names{:} name };   
    extensions   = { extensions{:} ext }; 
end;

if isBslRequired(modelName),
    names = { names{:} 'MW_c6xxx_bsl' };
    extensions   = { extensions{:} '.c' }; 
end;

if ~useDSPBIOS, 
    names = { names{:} 'vectors' }; 
    extensions   = { extensions{:} '.asm' }; 
end

if isIncludeASM(modelName), 
    names = { names{:} 'sat_mpy' };
    extensions   = { extensions{:} '.sa' }; 
end 

if strmatch(type,'source','exact'),
    list = '';
    for i=1:length(names),
        list = [list names{i} extensions{i} ' '];
    end
else % if type='object'
    ext = '.obj';
    list = {};
    for i=1:length(names),
        list = {list{:} [names{i} ext]};
    end
end
 
 
%------------------------------------------------------------------------------- 
function bool = isEVMDACblock16bitLinear(modelName) 
% find if EVM DAC block is in the model and whether its codec 
% has 16-bit linear format  
DACblock = findDACBlock_C6701EVM(modelName); 
if ~isempty (DACblock),  
    bool = strcmp(get_param (DACblock, 'CodecDataFormat'), '16-bit linear'); 
else 
    bool = 0; 
end; 


%------------------------------------------------------------------------------- 
function bool = isIncludeASM(modelName) 
% if board type is C6711DSK or if board is EVM and DAC 
% codec format is 16-bit linear, include .asm version  
switch getTargetType_DSPtarget(modelName),
    case 'C6711DSK',
        bool = true;
    case 'C6701EVM',
        bool = isEVMDACblock16bitLinear(modelName);
    otherwise,
        bool = false;
end;


%-------------------------------------------------------------------------------
function bool = isBslRequired(modelName)
% if model includes any codec blocks, 
% one must include board support functions
switch getTargetType_DSPtarget(modelName),
    case 'C6711DSK',
        ADCblock = ~isempty (find_system(modelName, ...
        'FollowLinks','on','LookUnderMasks','on','MaskType','C6711DSK ADC'));
        if (~ADCblock)
            ADCblock = ~isempty (find_system(modelName,...
            'FollowLinks','on','LookUnderMasks','on','MaskType','TI TMDX326040A ADC'));
        end;
        DACblock = ~isempty (find_system(modelName,...
        'FollowLinks','on','LookUnderMasks','on','MaskType','C6711DSK DAC'));
        if (~DACblock)
            DACblock = ~isempty (find_system(modelName,...
            'FollowLinks','on','LookUnderMasks','on','MaskType','TI TMDX326040A DAC'));
        end;
    case 'C6701EVM',
        ADCblock = ~isempty (find_system(modelName,...
        'FollowLinks','on','LookUnderMasks','on','MaskType','C6701EVM ADC'));
        DACblock = ~isempty (find_system(modelName,...
        'FollowLinks','on','LookUnderMasks','on','MaskType','C6701EVM DAC'));
    case 'C6416DSK',
        ADCblock = ~isempty (find_system(modelName,...
        'FollowLinks','on','LookUnderMasks','on','MaskType','C6416DSK ADC'));
        DACblock = ~isempty (find_system(modelName,...
        'FollowLinks','on','LookUnderMasks','on','MaskType','C6416DSK DAC'));
    case 'C6713DSK',
        ADCblock = ~isempty (find_system(modelName,...
        'FollowLinks','on','LookUnderMasks','on','MaskType','C6713DSK ADC'));
        DACblock = ~isempty (find_system(modelName,...
        'FollowLinks','on','LookUnderMasks','on','MaskType','C6713DSK DAC'));
end;

bool = ADCblock | DACblock;

% [EOF] getProjectFiles_TItarget.m
