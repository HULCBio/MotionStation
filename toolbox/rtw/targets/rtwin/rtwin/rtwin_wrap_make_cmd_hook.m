function makecmd = rtwin_wrap_make_cmd_hook(makecmdargs)
% RTWIN_WRAP_MAKE_CMD_HOOK  Wrap make RTW hook file for the RTWin Target.

%   Copyright 1994-2003 The MathWorks, Inc.%   $Revision: 1.1.6.2 $  $Date: 2003/06/14 03:37:04 $  $Author: batserve $

makecmd = strrep(makecmdargs.makeCmd, '%RTWIN%', fileparts(fileparts(which(mfilename))));
