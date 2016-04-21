function varargout = c6711dskblkswitch(action)
% C6711DSKBLKSWITCH   Mask Helper Function for the C6711DSK Switch block.
%
% $RCSfile: c6711dskblkswitch.m,v $
% $Revision: 1.1.6.2 $
% $Date: 2004/04/08 21:00:22 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'init'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
case 'init'
    
    % Check for uniqueness of this block
    C6711DskSwitchBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6711 DSK DIP Switch');
    if  (length(C6711DskSwitchBlocks) > 1), 
        error('Multiple C6711 DSK DIP Switch blocks are not allowed.')
    end
    
end
return

% [EOF] c6711dskblkswitch.m
