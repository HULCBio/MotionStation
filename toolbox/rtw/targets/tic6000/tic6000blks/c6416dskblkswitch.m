function varargout = c6416dskblkswitch(action)
% Mask Helper Function for the C6416DSK DIP Switch block.
%
% $RCSfile: c6416dskblkswitch.m,v $
% $Revision: 1.1.6.1 $
% $Date: 2004/01/22 18:26:41 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'init'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
    case 'init'
        
        % Check for uniqueness of this block
        Blocks = find_system(sys,'FollowLinks','on', ...
            'LookUnderMasks','on','MaskType','C6416 DSK DIP Switch');
        if  (length(Blocks) > 1), 
            error('Multiple C6416 DSK DIP Switch blocks are not allowed.')
        end
        
end
return

% [EOF] 
