function refresh(r)
%REFRESH  Reopens all RTDX channels that are severed during a program load
%   REFRESH(R) - After loading a new program file in Code Composer
%   Studio(R), all RTDX handles become 'stale'.  Even if the new 
%   program file contains equivalently named and configured channels, 
%   it is necessary to reopen the channels.   This method reestablishes
%   previously opened RTDX channels defined in R.
%
%   See also CLOSE, OPEN.

% Copyright 2004 The MathWorks, Inc.
