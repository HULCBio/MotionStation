function clearprofiler(t)
%CLEARPROFILER clears profiler data associated with a tlc context
%   CLEARPROFILER(H) clears profiler data associated
%   with tlc context H.
%
%   See also: TLCHANDLE, PROFILE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/10 17:57:37 $

tlc('clearprofiler',t.Handle);
