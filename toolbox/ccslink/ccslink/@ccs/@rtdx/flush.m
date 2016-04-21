function flush(varargin)
%FLUSH Flush data in a specified RDTX(tm) channel.
%   FLUSH(R, CHANNEL, NUM, TIMEOUT) removes NUM oldest data messages from an 
%   RTDX channel queue specified by the string CHANNEL and as defined in the 
%   RTDX object R.  TIMEOUT in units of seconds is used instead of the global
%   timeout stored in the object R.  The timeout processing is applied when 
%   flushing the last message in the channel queue since it is necessary to 
%   perform an explicit 'read' to advance the read pointer past the last 
%   message.  This calling syntax is valid for 'read' configured CHANNEL only.
%
%   FLUSH(R, CHANNEL, NUM) removes NUM oldest data messages from an RTDX 
%   channel and uses the global timeout value stored in the object R.  This 
%   calling syntax is valid for 'read' configured CHANNEL only.
%
%   FLUSH(R, CHANNEL, [], TIMEOUT) or
%   FLUSH(R, CHANNEL,'all', TIMEOUT) flushes all data messages from the CHANNEL,
%   with TIMEOUT in unit of seconds is used in instead of the global timeout 
%   stored in the object R.  This calling syntax is valid for 'read' configured
%   CHANNEL only.  
%
%   FLUSH(R, CHANNEL) removes all pending data messages from CHANNEL which may 
%   may be configured for 'read' or 'write' operation.
%

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.24.4.4 $ $Date: 2004/04/08 20:46:53 $


% Parse and validate the inputs
[msg,r,channelName,numMsgs,timeOut] = parse_args(varargin{:});
error(msg);
callSwitchyard(r.ccsversion,[113,r.boardnum,r.procnum,timeOut,0],channelName,numMsgs);

%------------------------------------------------------------------------------
function [msg,r,channel,num,timeout] = parse_args(varargin)
% Parse and validate the inputs
% 'msg' is empty if no error occurs.

r       = [];
channel = [];
num     = [];
timeout = [];

msg = nargchk(2,4,nargin);
if ~isempty(msg), return; end

% Parse RTDX argument:
r = varargin{1};

% Parse CHANNEL argument:
channel = varargin{2};
if ~ischar(channel),
	msg = 'Channel name must be a character string.';
    return
elseif isempty(channel),
	msg = 'Channel name cannot be an empty string.';
    return
end

% Parse NUM argument:
if nargin<3,
    num = 'all';
elseif isempty(varargin{3}),
    num = 'all';
else
    num = varargin{3};
end

% Parse TIMEOUT argument:
if nargin < 4,
	timeout = r.timeout;
else
    timeout = varargin{4};
end

% Look for specified channel name
chID = strmatch(channel, {r.RtdxChannel{:,1}}, 'exact');
if isempty(chID),
    msg = 'Specified channel is not open.';
    return
end

if r.iswritable(channel),
    if nargin > 2,
        msg = 'Too many input arguments for write channel FLUSH.';
        return
    end
else  % FLUSH read channel
    if nargin > 2,  % FLUSH specified number of messages?
        if ~strcmpi(num,'all'),
            if ~isnumeric(num) | ...
                    ~isreal(num) | ...
                    (num<0) | (num ~= floor(num)),
                msg = 'Number of messages must be positive integer value.';
                return
            end
        end
    end
end



% [EOF] flush.m
