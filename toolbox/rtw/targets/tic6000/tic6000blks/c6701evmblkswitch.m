function varargout = c6701evmblkswitch(action)
% C6701EVMBLKSWITCH   Mask Helper Function for the 
%                     C6701EVM DIP Switch block.
%
% $RCSfile: c6701evmblkswitch.m,v $
% $Revision: 1.1.6.2 $
% $Date: 2004/04/08 21:00:19 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'init'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
case 'init'
    
    % Check for uniqueness of this block
    C6701evmSwitchBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6701 EVM DIP Switch');
    if  (length(C6701evmSwitchBlocks) > 1), 
        error('Multiple C6701EVM DIP Switch blocks are not allowed.')
    end
    
end
return

% [EOF] c6701evmblkswitch.m
