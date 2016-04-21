function varargout = c6416dskblkled(action)
% C6416DSKBLKLED Mask Helper Function for the C6416DSK LED block.
% Also used for C6713 DSK LED block.  
%
% $RCSfile: c6416dskblkled.m,v $
% $Revision: 1.1.6.1 $
% $Date: 2004/01/22 18:26:40 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'init'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
case 'init'
    
    % Check for uniqueness of this block
    maskType = get_param(blk,'masktype');
    LedBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType',maskType);
    if  (length(LedBlocks) > 1), 
        error('Multiple LED blocks are not allowed.')
    end
    
end
return

% [EOF] c6416dskblkled.m
