function refresh(r)
%REFRESH  Reopens all RTDX channels that are severed during a program load
%   REFRESH(R) - After loading a new program file in Code Composer
%   Studio(R), all RTDX handles become 'stale'.  Even if the new 
%   program file contains equivalently named and configured channels, 
%   it is necessary to reopen the channels.   This method reestablishes
%   previously opened RTDX channels defined in R.
%
%   See also CLOSE, OPEN.

% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.2.2.3 $ $Date: 2004/04/06 01:04:59 $

chan = get(r,'RtdxChannel');
close(r,'all');

for ic = 1:r.numChannels,
    name = chans{ic,1};
    enstat = chans{ic,2};
    ctype = chans{ic,3};
    try
        open(r,name,ctype);
    catch
        disp(lasterr);
        warning(['Failed to open channel: ''' name '''']);
    end
end

% [EOF] refresh.m
