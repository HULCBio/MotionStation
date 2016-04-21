function varargout = c6711dskblkled(action)
% C6711DSKBLKLED Mask Helper Function for the C6711DSK LED block.
%
% $RCSfile: c6711dskblkled.m,v $
% $Revision: 1.1.6.2 $
% $Date: 2004/04/08 21:00:21 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'init'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
case 'init'
    
    % Check for uniqueness of this block
    C6711DskLedBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6711DSK LED');
    if  (length(C6711DskLedBlocks) > 1), 
        error('Multiple C6711DSK LED blocks are not allowed.')
    end
    
end
return

% [EOF] c6711dskblkled.m
