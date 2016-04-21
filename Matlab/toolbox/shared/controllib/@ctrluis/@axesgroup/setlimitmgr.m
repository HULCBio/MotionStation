function setlimitmgr(h,eventdata)
%SETLIMITMGR  Enables/disables limit manager.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:19 $
% Postset for LimitManager property: enable/disable listeners managing limits
set(h.LimitListeners,'Enable',h.LimitManager)


