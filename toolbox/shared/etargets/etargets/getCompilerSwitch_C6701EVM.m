function str = getCompilerSwitch_C6701EVM(isFullMemoryMap)

% $RCSfile: getCompilerSwitch_C6701EVM.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:56 $
% Copyright 2001-2003 The MathWorks, Inc.

if (isFullMemoryMap)
 str = ' -ml3 -mv6700';
else
 str = ' -mv6700';    
end;
 
 % [EOF] getCompilerSwitch_C6701EVM.m
