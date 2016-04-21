function histprofiler(t, b)
%HISTPROFILER enable or disable history logging for a tlc context
%   HISTPROFILER(H, BOOLEAN) enable or disable history
%   logging for profiler associated with a tlc context
%   H.
%
%   See also: TLCHANDLE, PROFILE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/10 17:57:40 $

tlc('histprofiler',t.Handle,b);
