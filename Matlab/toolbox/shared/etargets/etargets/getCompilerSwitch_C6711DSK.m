function str = getCompilerSwitch_C6711DSK(isFullMemoryMap)

% $RCSfile: getCompilerSwitch_C6711DSK.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:57 $
% Copyright 2001-2003 The MathWorks, Inc.

 if (isFullMemoryMap)
    str = ' -ml3 -mv6710';
 else
    str = ' -mv6710';    
 end;
 % [EOF] getCompilerSwitch_C6711DSK.m
