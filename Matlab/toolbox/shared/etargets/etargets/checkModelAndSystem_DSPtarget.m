function checkModelAndSystem_DSPtarget(modelInfo)
%checkModelAndSystem_DSPtarget    Before code generation, check for 
%          anomalies in the model and the installation.

% Copyright 2001-2004 The MathWorks, Inc.

% $Revision: 1.1.6.2 $ $Date: 2004/02/06 00:33:50 $

% Get list of Codec blocks in model
C6701EvmAdcBlocks = find_system(modelInfo.name,'FollowLinks','on', ...
    'LookUnderMasks','on','MaskType','C6701EVM ADC');
C6701EvmDacBlocks = find_system(modelInfo.name,'FollowLinks','on', ...
    'LookUnderMasks','on','MaskType','C6701EVM DAC');

C6711DskAdcBlocks = find_system(modelInfo.name,'FollowLinks','on', ...
    'LookUnderMasks','on','MaskType','C6711DSK ADC');
C6711DskDacBlocks = find_system(modelInfo.name,'FollowLinks','on', ...
    'LookUnderMasks','on','MaskType','C6711DSK DAC');

C6416DskAdcBlocks = find_system(modelInfo.name,'FollowLinks','on', ...
    'LookUnderMasks','on','MaskType','C6416DSK ADC');
C6416DskDacBlocks = find_system(modelInfo.name,'FollowLinks','on', ...
    'LookUnderMasks','on','MaskType','C6416DSK DAC');

C6713DskAdcBlocks = find_system(modelInfo.name,'FollowLinks','on', ...
    'LookUnderMasks','on','MaskType','C6713DSK ADC');
C6713DskDacBlocks = find_system(modelInfo.name,'FollowLinks','on', ...
    'LookUnderMasks','on','MaskType','C6713DSK DAC');

% Daughtercards
Tmdx326040AdcBlocks = find_system(modelInfo.name,'FollowLinks','on', ...
    'LookUnderMasks','on','MaskType','TI TMDX326040A ADC');
Tmdx326040DacBlocks = find_system(modelInfo.name,'FollowLinks','on', ...
    'LookUnderMasks','on','MaskType','TI TMDX326040A DAC');



% Check for match between codec blocks and board type
targetType = getTargetType_DSPtarget(modelInfo.name);
if (~isempty(C6701EvmAdcBlocks) || ~isempty(C6701EvmDacBlocks)) && ...
        ~strcmp(targetType,'C6701EVM'),
    error('Codec blocks do not match target type.');
end
if (~isempty(C6711DskAdcBlocks) || ~isempty(C6711DskDacBlocks)) && ...
        ~strcmp(targetType,'C6711DSK'),
    error('Codec blocks do not match target type.');
end
if (~isempty(C6416DskAdcBlocks) || ~isempty(C6416DskDacBlocks)) && ...
        ~strcmp(targetType,'C6416DSK'),
    error('Codec blocks do not match target type.');
end
if (~isempty(C6713DskAdcBlocks) || ~isempty(C6713DskDacBlocks)) && ...
        ~strcmp(targetType,'C6713DSK'),
    error('Codec blocks do not match target type.');
end
if (~isempty(Tmdx326040AdcBlocks) || ~isempty(Tmdx326040DacBlocks)) && ...
        ~strcmp(targetType,'C6711DSK'),
    error(['Codec blocks do not match target type.  ' ...
            'TMDX326040A blocks can only be used on C6711DSK.']);
end

% Check solver options:  fixed-step, discrete
slvr = get_param(modelInfo.name,'solver');
if ~strcmp(slvr,'FixedStepDiscrete'),
    error(['Fixed Step / Discrete solver is required for ' ...
            'Embedded Target for TI C6000 DSP.'])
end


% Check for incompatible C6000 RTW Options
cs = getActiveConfigSet(modelInfo.name);
if strcmp(get_param(cs,'useDSPBIOS'), 'on') && ...
    strcmp(get_param(cs,'LinkerCommandFile'), 'User_defined'),
    error(['User-defined linker command file is not supported in conjunction ' ...
        'with DSP/BIOS.  You must turn off the "Incorporate DSP/BIOS" option ' ...
        'in order to allow your custom linker command file to be used.']);
end

% EOF checkModelAndSystem_DSPtarget.m
