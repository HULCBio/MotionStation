function varargout = c6701evmblkadc(action)
% C6701EVMBLKADC Mask Helper Function for the C6701evm_adc block.
%
% $RCSfile: c6701evmblkadc.m,v $
% $Revision: 1.1.6.2 $
% $Date: 2004/04/08 21:00:16 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'dynamic'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
case 'dynamic'
    
    mask_enables_orig    = get_param(blk,'MaskEnables');
    mask_enables         = mask_enables_orig;    
    ADCsource            = get_param(blk,'ADCsource');
    outputDataType       = get_param(blk,'OutputDataType');
    codecDataFormat      = get_param(blk,'CodecDataFormat');
    MicGainCheckboxIndex = 2;
    ScalingPopupIndex    = 7;
    
    % Changes to 'ADC Source':
    if strcmp(ADCsource,'Mic In'),
        s='on';
    else
        s='off';
    end
    mask_enables{MicGainCheckboxIndex} = s;
    
    % Changes to Output data type and codec data format:
    % -> disable scaling popup when data type is in
    %    integer mode or data format is set to ADPCM.
    if strcmp(outputDataType,  'Integer') | strcmp(codecDataFormat, '4-bit IMA ADPCM'),
        s='off';
    else
        s='on';
    end
    mask_enables{ScalingPopupIndex} = s;
    
    if ~isequal(mask_enables, mask_enables_orig),
        set_param(blk,'MaskEnables',mask_enables);
    end
    
case 'init'
    
    % Check for uniqueness of this block
    C6701EvmAdcBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6701EVM ADC');
    if  (length(C6701EvmAdcBlocks) > 1), 
        error('Multiple C6701EVM ADC blocks are not allowed.')
    end
    
end
return

% [EOF] c6701evmblkadc.m
