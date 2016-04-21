function GetRTWRoot(h, rtwVerbose)
%   GETRTWROOT: calculate RTW root. 
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:23:50 $

h.RTWRoot = fullfile(matlabroot, 'rtw');
[h.RTWRoot] = LocInternalMathWorksDevelopment(h, h.RTWRoot, rtwVerbose);
