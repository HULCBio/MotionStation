function addArgout(hThis,hArg)

% Copyright 2003 The MathWorks, Inc.

argout = get(hThis,'Argout');
set(hThis,'Argout',[argout,hArg]);


