function varargout = c6713dskblkswitch(action)
% Mask Helper Function for the C6713DSK DIP Switch block.
%
% $RCSfile: c6713dskblkswitch.m,v $
% $Revision: 1.1.6.1 $
% $Date: 2004/01/22 18:26:53 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'init'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
    case 'init'
        
        % Check for uniqueness of this block
        Blocks = find_system(sys,'FollowLinks','on', ...
            'LookUnderMasks','on','MaskType','C6713 DSK DIP Switch');
        if  (length(Blocks) > 1), 
            error('Multiple C6713 DSK DIP Switch blocks are not allowed.')
        end
        
end
return

% [EOF] 
