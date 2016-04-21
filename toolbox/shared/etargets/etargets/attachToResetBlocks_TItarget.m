function attachToResetBlocks_TItarget(modelInfo, boardProc) 
% save board number and processor number in RESET block

% $RCSfile: attachToResetBlocks_TItarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:39 $
% Copyright 2001-2003 The MathWorks, Inc.

targetType = getTargetType_DSPtarget(modelInfo.name);

theBlocks = feval(['findResetBlocks_' targetType],modelInfo.name);

for i=1:length(theBlocks), 
    set_param(theBlocks{i}, 'UserData', boardProc); 
end 

% [EOF] attachToResetBlocks_TItarget.m
