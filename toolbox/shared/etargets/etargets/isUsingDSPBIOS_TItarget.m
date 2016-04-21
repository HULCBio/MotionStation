function bool = isUsingDSPBIOS_TItarget(modelInfo)
% return TRUE if BIOS enabled
%

% $RCSfile: isUsingDSPBIOS_TItarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:08:07 $
% Copyright 2002-2003 The MathWorks, Inc.

bool =  strcmp(parseRTWBuildArgs_DSPtarget(modelInfo.buildArgs,'USE_DSPBIOS'),'1');


% [EOF] isUsingDSPBIOS_TItarget.m