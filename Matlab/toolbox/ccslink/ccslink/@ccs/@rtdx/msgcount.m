function num = msgcount(r, channelName)
%MSGCOUNT Get number of messages in specified 'read' configured channel queue.
%   MSGCOUNT(R, CHANNEL) returns an integer value denoting the number of data
%   messages in the 'read' configured RDTX(tm) channel queue specified by the 
%   string CHANNEL, and as defined in the RTDX object R.  This method does not 
%   work for channels configured for 'write' operation.

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.13.4.3 $ $Date: 2004/04/08 20:46:58 $

if ~ischar(channelName),
	error('Channel name must be a character string.');
    return
elseif isempty(channelName),
	error('Channel name cannot be an empty string.');
    return
end

% Look for specified channel name
chID = strmatch(channelName, {r.RtdxChannel{:,1}}, 'exact');
if isempty(chID),
    error('Specified channel is not open.');
end

num =  callSwitchyard(r.ccsversion,[110,r.boardnum,r.procnum,0,0],channelName);

% [EOF] msgcount.m
