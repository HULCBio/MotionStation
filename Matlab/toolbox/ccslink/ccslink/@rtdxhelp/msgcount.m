function num = msgcount(r, channelName)
%MSGCOUNT Get number of messages in specified 'read' configured channel queue.
%   MSGCOUNT(R, CHANNEL) returns an integer value denoting the number of data
%   messages in the 'read' configured RDTX(tm) channel queue specified by the 
%   string CHANNEL, and as defined in the RTDX object R.  This method does not 
%   work for channels configured for 'write' operation.

% Copyright 2004 The MathWorks, Inc.
