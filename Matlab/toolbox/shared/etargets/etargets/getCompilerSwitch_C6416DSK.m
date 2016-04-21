function str = getCompilerSwitch_C6416DSK(isFullMemoryMap)

% $RCSfile: getCompilerSwitch_C6416DSK.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:37:16 $
% Copyright 2001-2003 The MathWorks, Inc.

% For C64x, there is 1MB internal ram, which 
% is too big for near calls/data.  Therefore, we 
% must use -ml3 regardless of the user's choice of
% memory model.

str = ' -ml3 -mv6400';

% [EOF] getCompilerSwitch_C6416DSK.m
