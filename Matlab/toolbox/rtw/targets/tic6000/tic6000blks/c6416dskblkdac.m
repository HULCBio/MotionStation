function varargout = c6416dskblkdac(action)
% C6416DSKBLKDAC Mask Helper Function for the C6416DSK/C6713DSK DAC blocks.
%
% $RCSfile: c6416dskblkdac.m,v $
% $Revision: 1.1.6.3 $
% $Date: 2004/04/08 21:00:15 $
% Copyright 2001-2004 The MathWorks, Inc.

if nargin==0, action = 'dynamic'; end
blk = gcbh;
sys = strtok(gcs,'/');
maskType = get_param(blk,'MaskType');
boardType = maskType(1:5);

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
    DacBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType',maskType);
    if  (length(DacBlocks) > 1), 
        error(['Multiple ' boardType ' DAC blocks are not allowed.'])
    end
    
case 'start'
    
    % Check for match between ADC and DAC in terms of rates and sizes
    AdcBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6416DSK ADC');
    if isempty(AdcBlocks),  % Temporary fix until we actually unify the blocks!
        AdcBlocks = find_system(sys,'FollowLinks','on', ...
            'LookUnderMasks','on','MaskType','C6713DSK ADC');
    end
    if ~isempty(AdcBlocks)
        AdcBlk = AdcBlocks{1}; % uniqueness checked elsewhere
        AdcSampTimes = get_param(AdcBlk,'CompiledSampleTime');
        AdcSampTime = AdcSampTimes(1);
        if (AdcSampTime > 0) && ~isinf(AdcSampTime),
            DacBlk = blk; 
            DacSampTimes = get_param(DacBlk,'CompiledSampleTime');
            DacSampTime = DacSampTimes(1);
            if (DacSampTime > 0) && ~isinf(DacSampTime), 
                if ~isequal(AdcSampTime,DacSampTime),
                    error([boardType ' ADC and DAC blocks must ' ...
                            'execute at the same rate.'])
                end
            end
        end
        % Check dimensions:  stereo mode and frame size must match
        DacPortHandles = get_param(blk,'porthandles');
        DacInportHandle = DacPortHandles.Inport(1);
        DacDims = get_param(DacInportHandle,'CompiledPortDimensions');
        % DacDims(1) is the number of dimensions
        if DacDims(1)==2,
            DacRows = DacDims(2);
            DacCols = DacDims(3);
            isAdcStereo = strcmp(get_param(AdcBlk,'stereo'),'on');
            if isAdcStereo && ~(DacCols==2),
                error('DAC input must have two columns when ADC is in stereo mode.')
            elseif (~isAdcStereo) && ~(DacCols==1),
                error('DAC input must have one column when ADC is in mono mode.')
            end
            AdcFrameSize = str2num(get_param(AdcBlk,'FrameSize'));
            if ~isequal(AdcFrameSize, DacRows),
                error('ADC and DAC frame sizes must be equal.')
            end
        elseif DacDims(1)==1   % 1-d vector or scalar
            DacWidth = DacDims(2);
            isAdcStereo = strcmp(get_param(AdcBlk,'stereo'),'on');
            AdcFrameSize = str2num(get_param(AdcBlk,'FrameSize'));
            if isAdcStereo,
                if ~(DacWidth==(AdcFrameSize*2)),
                    error('DAC input must be twice the ADC frame size when ADC is in stereo mode.')
                end
            else  % mono
                if ~(DacWidth==(AdcFrameSize)),
                    error('DAC input size must match the ADC frame size.')
                end
            end
        end
    end


end
return

% [EOF]
