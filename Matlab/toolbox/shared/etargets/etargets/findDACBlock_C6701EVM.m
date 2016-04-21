function block = findDACBlock_C6701EVM(modelName)

% $RCSfile: findDACBlock_C6701EVM.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:51 $
% Copyright 2001-2003 The MathWorks, Inc.

block = find_system(modelName,'FollowLinks','on','LookUnderMasks','on',...
    'MaskType','C6701EVM DAC');

% [EOF] findDACBlock_C6701EVM.m
