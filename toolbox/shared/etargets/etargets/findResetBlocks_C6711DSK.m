function blocks = findResetBlocks_C6711DSK(modelName)

% $RCSfile: findResetBlocks_C6711DSK.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:53 $
% Copyright 2001-2003 The MathWorks, Inc.

blocks = find_system(modelName,'FollowLinks','on','LookUnderMasks','on',...
    'MaskType','C6711DSK RESET');

% [EOF] findResetBlocks_C6711DSK.m
