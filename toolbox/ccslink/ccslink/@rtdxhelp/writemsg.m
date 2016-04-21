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

% Copyright 2004 The MathWorks, Inc.
