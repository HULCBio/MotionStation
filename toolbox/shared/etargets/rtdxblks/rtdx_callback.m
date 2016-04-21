function retvalue = rtdx_callback(action)
% RTDX_CALLBACK Mask Helper Function for the RTDX Source block.
%
% $RCSfile: rtdx_callback.m,v $
% $Revision: 1.1.6.2 $
% $Date: 2004/04/08 21:08:17 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'dynamic'; end
blk = gcbh;

retvalue = 1;

switch action
case 'dynamic'
    
    mask_enables_orig    = get_param(blk,'MaskEnables');
    mask_enables         = mask_enables_orig;    
    isBlocking           = get_param(blk,'isBlocking');
    ICEditBoxIndex       = 3;
    
    if (strcmp(isBlocking,'on'))
        mask_enables{ICEditBoxIndex} = 'off';
    else
        mask_enables{ICEditBoxIndex} = 'on';
    end

    if ~isequal(mask_enables, mask_enables_orig),
        set_param(blk,'MaskEnables',mask_enables);
    end
    
case 'ChName'
    
    allblocks = [ find_system(gcs,'FollowLinks','on','LookUnderMasks','on','MaskType','To RTDX'); ...
            find_system(gcs,'FollowLinks','on','LookUnderMasks','on','MaskType','From RTDX') ];
    
    allChannelNames = sort(get_param (allblocks, 'channelNameStr'));

    for (i=1:length(allChannelNames)-1),
        if ( isequal (allChannelNames{i}, allChannelNames{i+1} ) )
            retvalue = 0;
            return
        end
    end
    
end

return

% [EOF] rtdx_callback.m
