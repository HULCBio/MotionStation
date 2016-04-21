function varargout = c6416dskblkadc(action)
% C6416DSKBLKADC Mask Helper Function for the c6416dsk/c6713dsk adc blocks.
%
% $RCSfile: c6416dskblkadc.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:26:38 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'dynamic'; end
blk = gcbh;
sys = strtok(gcs,'/');
maskType = get_param(blk,'MaskType');

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
    AdcBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType',maskType);
    if  (length(AdcBlocks) > 1), 
        error(['Multiple ' maskType ' blocks are not allowed.'])
    end
    
end
return

% [EOF]
