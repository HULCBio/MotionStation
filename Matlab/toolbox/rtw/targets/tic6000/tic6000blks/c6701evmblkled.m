function varargout = c6701evmblkled(action)
% C6701EVMBLKLED Mask Helper Function for the C6701EVM LED block.
%
% $RCSfile: c6701evmblkled.m,v $
% $Revision: 1.1.6.2 $
% $Date: 2004/04/08 21:00:18 $
% Copyright 2001-2003 The MathWorks, Inc.

if nargin==0, action = 'init'; end
blk = gcbh;
sys = strtok(gcs,'/');

switch action
case 'init'
    
    % Check for uniqueness of this block
    C6701EvmLedBlocks = find_system(sys,'FollowLinks','on', ...
        'LookUnderMasks','on','MaskType','C6701EVM LED');
    if (length(C6701EvmLedBlocks) > 2), 
        error('You cannot use more than two C6701EVM LED blocks at once.')
    elseif (length(C6701EvmLedBlocks) == 2),
        % The two blocks must have different "led_id"s, 
        % 'External' or 'Internal'
        id1 = get_param(C6701EvmLedBlocks{1},'led_id');
        id2 = get_param(C6701EvmLedBlocks{2},'led_id');
        if strcmp(id1,id2),
            error('The two C6701 EVM LED blocks must have different LED identifiers.');
        end
    end
    
end
return

% [EOF] c6701evmblkled.m
