function varargout = c6711dskblkdac(action)
% C6711DSKBLKDAC Mask Helper Function for the C6711DSK DAC block.
%
% $RCSfile: c6711dskblkdac.m,v $
% $Revision: 1.1.6.1 $
% $Date: 2004/01/22 18:26:49 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'init'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
case 'init'
    
    % Check for uniqueness of this block
    C6711DskDacBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6711DSK DAC');
    if  (length(C6711DskDacBlocks) > 1), 
        error('Multiple C6711DSK DAC blocks are not allowed.')
    end
    
case 'start'
    
    % Check for match between ADC and DAC in terms of frame size
    AdcBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6711DSK ADC');
    if ~isempty(AdcBlocks)
        AdcBlk = AdcBlocks{1}; % uniqueness checked elsewhere
        % Check dimensions:  stereo mode and frame size must match
        DacPortHandles = get_param(blk,'porthandles');
        DacInportHandle = DacPortHandles.Inport(1);
        DacDims = get_param(DacInportHandle,'CompiledPortDimensions');
        DacRows = DacDims(2);  % Dims(1) is the number of dimensions
        DacCols = DacDims(3);  
        AdcFrameSize = str2num(get_param(AdcBlk,'FrameSize'));
        if ~isequal(AdcFrameSize, DacRows),
            error('ADC and DAC frame sizes must be equal.')
        end
    end

    
end
return

% [EOF] c6711dskblkdac.m
