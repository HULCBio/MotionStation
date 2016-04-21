function ph=getprofiler(t)
%GETPROFILER get profiler handle associated with a tlc context
%   GETPROFILER(H) get profiler handle associated
%   with a tlc context H.
%
%   See also: TLCHANDLE, PROFREPORT, PROFILE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/10 17:57:34 $

ph=tlc('getprofiler',t.Handle);
