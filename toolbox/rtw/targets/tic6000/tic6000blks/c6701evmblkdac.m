function varargout = c6701evmblkdac(action)
% C6701EVMBLKDAC Mask Helper Function for the C6701evm_dac block.
%
% $RCSfile: c6701evmblkdac.m,v $
% $Revision: 1.1.6.2 $
% $Date: 2004/04/08 21:00:17 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'dynamic'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
case 'dynamic'
    
    mask_enables_orig    = get_param(blk,'MaskEnables');
    mask_enables         = mask_enables_orig;    
    codecDataFormat      = get_param(blk,'CodecDataFormat');
    ScalingPopupIndex    = 2;
    
    % Changes to Codec data format:
    % -> disable scaling popup when data type is in set to ADPCM.

    if strcmp(codecDataFormat, '4-bit IMA ADPCM'),
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
    C6701EvmDacBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6701EVM DAC');
    if  (length(C6701EvmDacBlocks) > 1), 
        error('Multiple C6701EVM DAC blocks are not allowed.')
    end
    
    % Check for match between EVM ADC and DAC in terms of rates
    %   (Note: For DSK, the only allowable rate is 8kHz, and
    %    this is already checked by the DAC s-function.)
    C6701EvmAdcBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6701EVM ADC');
    if ~isempty(C6701EvmAdcBlocks)
        AdcBlk = C6701EvmAdcBlocks{1}; % uniqueness checked elsewhere
        AdcSampTimes = get_param(AdcBlk,'CompiledSampleTime');
        AdcSampTime = AdcSampTimes(1);
        % If sample rates are not fully propagated, then 
        % we will find a zero or inf value for sample times
        if ~isempty(C6701EvmDacBlocks) && (AdcSampTime > 0) && ...
                    ~isinf(AdcSampTime),
            DacBlk = C6701EvmDacBlocks{1}; % uniqueness checked elsewhere
            DacSampTimes = get_param(DacBlk,'CompiledSampleTime');
            DacSampTime = DacSampTimes(1);
            if (DacSampTime > 0) && ~isinf(DacSampTime), 
                if ~isequal(AdcSampTime,DacSampTime),
                    error(['C6701EVM ADC and DAC blocks must ' ...
                            'execute at the same rate.'])
                end
            end
        end        
    end


end
return

% [EOF] c6701evmblkdac.m
