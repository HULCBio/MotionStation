function data = readmat(r, channelName, dataType, siz, timeout)
%READMAT Read a matrix of data values from specified RDTX(tm) channel.
%   DATA = READMAT(R, CHANNELNAME, DATATYPE, SIZ, TIMEOUT) reads data values of
%   type DATATYPE from a 'read' configured RTDX channel queue specified by the 
%   string CHANNEL, and as defined in the RTDX object R.  The output data is 
%   formatted as a matrix whose dimensions are specified by the vector SIZ.  
%   The number of elements of the output matrix must correspond to an integral 
%   number of channel messages.  TIMEOUT in units of seconds used in instead of
%   the global timeout stored in the object R.  Messages will be read until
%   the output matrix is filled, or until the timeout period expires.
%       DATATYPE:    'uint8'
%                    'int16'
%                    'int32'
%                    'single'
%                    'double'
%
%   DATA = READMAT(R, CHANNELNAME, DATATYPE, SIZ) uses the global timeout value 
%   stored in the object R.
%
%   WARNING: If the timeout expires before the output matrix is filled, all 
%            messages read from the channel to that point will be lost.
%
%
%   Example:
%
%       outData = readmat(cc.rtdx, 'ochan', 'single', [3 10]);
%
%       One or greater integral number of messages of data type 'single' are 
%       read from the read-configured channel named 'ochan' and returned as a 
%       3x10 matrix called outData.  If each message consists of one data value,
%       then 30 messages must be read to fill the output matrix; if each message
%       contains 10 data values, then 3 messages must be read to fill the output
%       matrix.
%
%   See also READMSG, WRITEMSG

% Copyright 2004 The MathWorks, Inc.
