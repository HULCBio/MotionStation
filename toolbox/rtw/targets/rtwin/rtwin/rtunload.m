function rtunload
%RTUNLOAD Unload all hardware drivers.
%
%   RTUNLOAD unloads all hardware drivers and compiled models from memory.
%
%   Normally, hardware drivers are unloaded automatically when necessary.
%   Use this function for troubleshooting purposes only.
%
%   See also RTLOAD, RTCLEAR.

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 18:53:32 $  $Author: batserve $

rttool('Unload');

