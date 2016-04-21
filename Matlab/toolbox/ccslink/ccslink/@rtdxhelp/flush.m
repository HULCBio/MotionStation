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

% Copyright 2004 The MathWorks, Inc.
