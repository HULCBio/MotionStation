function channelNames = info(r)
%INFO Return string names of open RTDX(tm) channels.
%   INFO(R) returns channel names of all open channels in a cell array column
%   vector of strings.

% Copyright 2000-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/08 20:46:54 $

channelNames = {r.RtdxChannel{:,1}}';   % Return cell array column vector
                                        % of channel name strings

% [EOF] info.m
