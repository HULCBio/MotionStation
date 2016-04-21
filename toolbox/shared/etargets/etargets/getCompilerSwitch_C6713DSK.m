function str = getCompilerSwitch_C6713DSK(isFullMemoryMap)

% $RCSfile: getCompilerSwitch_C6713DSK.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:37:19 $
% Copyright 2001-2003 The MathWorks, Inc.

% -ml_ flag does not depend on memory map option for this target.
% We must use the "far" memory model even in Internal Mem Map mode,
% because the ISRAM is too big for near references.
str = ' -ml3 -mv6710';

 % [EOF] getCompilerSwitch_C6713DSK.m
