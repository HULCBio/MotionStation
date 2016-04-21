function writemsg(r, channelName, data, timeout)
%WRITEMSG Write data values to specified RTDX(tm) channel.
%   WRITEMSG(R, CHANNEL, DATA,TIMEOUT) writes column-wise data values from 
%   matrix DATA to the 'write' configured RTDX channel queue specified by the 
%   string CHANNEL, and as defined in the RTDX object R. TIMEOUT in units of 
%   seconds used in instead of the global timeout stored in the object R.
%   Data is limited to types: UINT8, INT16, INT32, SINGLE and DOUBLE.
%
%   WRITEMSG(R, CHANNEL, DATA) uses the global timeout value stored
%   in the object R.
%   Example:
%
%       inData = [1 4 7; 2 5 8; 3 6 9];
%       writemsg(cc.rtdx, 'ichan', inData);
%
%       The matrix inData is written column-wise to write-configured channel
%       named 'ichan'.  Note that the above function call is equivalent to
%
%       writemsg(cc.rtdx, 'ichan', [1:9]);
%
%   See also READMAT, READMSG

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.14.4.4 $ $Date: 2004/04/08 20:47:04 $

msg = nargchk(3,4,nargin);
if ~ischar(channelName),
	msg = 'Channel name must be a character string.';
elseif isempty(channelName),
	msg = 'Channel name cannot be an empty string.';
end

% Look for specified channel name
if isempty(strmatch(channelName, {r.RtdxChannel{:,1}}, 'exact')),
    msg = 'Specified channel is not open.';
end

if isempty(data),
    msg = 'Data matrix is empty.';
end

% Parse timeout
if( nargin >= 4)&(~isempty(timeout)),
    if ~isnumeric(timeout) | length(timeout) ~= 1,
        error('TIMEOUT parameter must be a single numeric value.');
    end
    dtimeout = double(timeout);
else
    dtimeout = double(r.timeout);
end

callSwitchyard(r.ccsversion,[106,r.boardnum,r.procnum,dtimeout,0],channelName,data);

% [EOF] writemsg.m
