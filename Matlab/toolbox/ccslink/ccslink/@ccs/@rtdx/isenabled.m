function bool = isenabled(r, varargin)
%ISENABLED Checks if RTDX(tm) or specified RTDX channel is enabled.
%   ISENABLED(R, CHANNEL) returns a Boolean value signifying whether an RTDX 
%   channel specified by the string CHANNEL, and as defined in the RTDX object 
%   R, is enabled.
%
%   ISENABLED(R) returns a Boolean value signifying whether RTDX is enabled.

% $RCSfile: isenabled.m,v $
% $Revision: 1.7.4.3 $ $Date: 2004/04/08 20:46:55 $
% Copyright 2000-2004 The MathWorks, Inc.

error(nargchk(1,2,nargin))

if nargin == 2,
    % Is Channel Enabled ?
    channelName = varargin{1};
    if ~ischar(channelName),
        error('Channel name must be a character string.');
    elseif isempty(channelName),
        error('Channel name cannot be an empty string.');
    end
    % Check if the channelName is an existing open channel
    if isempty(strmatch(channelName, {r.RtdxChannel{:,1}}, 'exact')),
        error(['Specified channel, "' channelName '", is not open.']);
    end
    bool = callSwitchyard(r.ccsversion,[114,r.boardnum,r.procnum,0,0],channelName);
else
    % Is RTDX Enabled ?
    bool = callSwitchyard(r.ccsversion,[114,r.boardnum,r.procnum,0,0]);
end

% [EOF] isenabled.m