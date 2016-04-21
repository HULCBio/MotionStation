function blocks = findResetBlocks_C6713DSK(modelName)

% $RCSfile: findResetBlocks_C6713DSK.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:37:12 $
% Copyright 2001-2003 The MathWorks, Inc.

blocks = find_system(modelName,'FollowLinks','on','LookUnderMasks','on',...
    'MaskType','C6713DSK RESET');

% [EOF] findResetBlocks_C6713DSK.m
