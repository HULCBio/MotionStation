function resumeprofiler(t)
%RESUMEPROFILER resume collecting profiler data for a tlc context
%   RESUMEPROFILER(H) resume collecting profiler data
%   for tlc context H.
%
%   See also: TLCHANDLE, PROFILE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/10 17:57:46 $

tlc('resumeprofiler',t.Handle);
