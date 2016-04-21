function varargout = c6711dskblkadc(action)
% C6711DSKBLKADC Mask Helper Function for the C6711dsk_adc block.
%
% $RCSfile: c6711dskblkadc.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:00:20 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'dynamic'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
case 'dynamic'
    
    mask_visibility_orig = get_param (blk,'MaskVisibilities');
    mask_visibility      = mask_visibility_orig;      
    mask_enables_orig    = get_param(blk,'MaskEnables');
    mask_enables         = mask_enables_orig;    
    ADCsource            = get_param(blk,'ADCsource');
    outputDataType       = get_param(blk,'OutputDataType');
    MicGainCheckboxIndex = 2;
    % SamplRateCheckboxIndex = 3;    
    ScalingPopupIndex    = 4;
    
    % Changes to 'ADC Source':
    if strcmp(ADCsource,'Mic In'),
        s='on';
    else
        s='off';
    end
    mask_enables{MicGainCheckboxIndex} = s;
    
    % Changes to Output data type and codec data format:
    % -> disable scaling popup when data type
    if strcmp(outputDataType,  'Integer'),
        s='off';
    else
        s='on';
    end
    mask_enables{ScalingPopupIndex} = s;
    
    if ~isequal(mask_enables, mask_enables_orig),
        set_param(blk,'MaskEnables',mask_enables);
    end
    
    % mask_visibility{SamplRateCheckboxIndex} = 'off';
  
    %if ~isequal(mask_visibility, mask_visibility_orig),
    %    set_param(blk,'MaskVisibilities',mask_visibility);
    %end         

case 'init'
    
    % Check for uniqueness of this block
    C6711DskAdcBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6711DSK ADC');
    if  (length(C6711DskAdcBlocks) > 1), 
        error('Multiple C6711DSK ADC blocks are not allowed.')
    end
    
end
return

% [EOF] c6711dskblkadc.m
