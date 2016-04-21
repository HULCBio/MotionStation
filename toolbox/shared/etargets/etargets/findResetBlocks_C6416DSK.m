function blocks = findResetBlocks_C6416DSK(modelName)

% $RCSfile: findResetBlocks_C6416DSK.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:37:09 $
% Copyright 2001-2003 The MathWorks, Inc.

blocks = find_system(modelName,'FollowLinks','on','LookUnderMasks','on',...
    'MaskType','C6416DSK RESET');

% [EOF] findResetBlocks_C6416DSK.m
