function data = readmsg(varargin)
%READMSG Read data messages from specified RDTX(tm) channel.
%   DATA = READMSG(R, CHANNELNAME, DATATYPE, SIZ, NUMMSGS, TIMEOUT) reads 
%   NUMMSGS number of data messages of type DATATYPE from a 'read' configured 
%   RTDX channel queue specified by the string CHANNEL, and as defined in the 
%   RTDX object R.  The output data is formatted as a single-row cell-array of
%   NUMMSGS number of matrices whose dimensions are specified by the dimension 
%   vector SIZ.  If NUMMSGS is set to 'all' or 'ALL', all messages in the 
%   channel queue at the time of the method call will be read.  The number of 
%   elements of the output matrix must correspond exactly to the number of 
%   elements in the corresponding message.  TIMEOUT in units of seconds is used
%   instead of the global timeout stored in the object R.  If the specified 
%   number of messages, NUMMSGS, is not available in the channel queue when 
%   this method is called, the routine will enter a 'wait' loop until either 
%   the full complement of data is made available, or the timeout period 
%   expires.
%       DATATYPE:    'uint8'
%                    'int16'
%                    'int32'
%                    'single'
%                    'double'
%
%   DATA = READMSG(R, CHANNELNAME, DATATYPE, SIZ, NUMMSGS) reads NUMMSGS number
%   of messages as described above, using the global time value stored in the
%   object R.
%
%   DATA = READMSG(R, CHANNELNAME, DATATYPE, SIZ) reads a single data message
%   as NUMMSGS defaults to 1.
%
%   DATA = READMSG(R, CHANNELNAME, DATATYPE, NUMMSGS) reads NUMMSGS messages, 
%   and returns the messages as a single-row cell array of row matrices of the
%   form [data(1) data(N)], where N is equal to the number of data values in 
%   the current message, i.e., SIZ defaults to [1 N].  Unlike the above calling
%   sequences, the length of each message can be of variable length.
%
%   DATA = READMSG(R, CHANNELNAME, DATATYPE) reads one message and returns a 
%   single row vector.  Defaults apply for all unspecified input arguments.
%
%   In all of the above cases, SIZ and NUMMSGS may be set to an empty matrix, 
%   in which case the defaults discussed above are substituted.
%
%   WARNING: If the timeout expires before the requested number of messages
%            have been read from the channel, all messages read to that point 
%            will be lost.
%
%   Example:
%
%       outData = readmsg(cc.rtdx, 'ochan', 'int32', [3 5], 2);
%
%       Two messages of data type 'int32' are read from the read-configured
%       channel named 'ochan'.  Both messages are formatted as 3x5 matrices and
%       returned in a 1x2 cell array, outData, of matrices.
%   See also READMAT, WRITEMSG
%

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.42.4.3 $ $Date: 2004/04/08 20:47:01 $

% Parse and validate the inputs
[errMsg,r,channelName,dataType,siz,numMsgs,timeOut] = ...
    parse_args(varargin{:});
error(errMsg);

if numMsgs == 0,
    data = [];
    return
end
data = callSwitchyard(r.ccsversion,[107,r.boardnum,r.procnum,timeOut,0],channelName,dataType,siz,numMsgs);


%------------------------------------------------------------------------------
function [msg,r,channel,datatype,siz,num,timeout] = parse_args(varargin)
% Parse and validate the inputs
% 'msg' is empty if no error occurs.

r        = [];
channel  = [];
datatype = [];
siz      = [];
num      = [];
timeout  = [];


msg = nargchk(3,6,nargin);
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

if isempty(strmatch(channel, {r.RtdxChannel{:,1}}, 'exact')),
    msg = 'Specified channel is not open';
    return
end


% Parse DATATYPE argument
datatype = varargin{3};

% Parse NUM and SIZ arguments:
if nargin >= 4,
    
    % Presume (..., siz, num) for now:
    siz = varargin{4};
    if nargin > 4,
        num=varargin{5};
    else
        % if only 4, 4th arg could be siz or num
        if length(siz) < 2 | isequal(siz,'all'),
            num = siz;
            siz = [];
        end
    end
    
    % apply default values:
    if isempty(num), 
        num = 1; 
    end
    
    % validate num and siz:
    % - check that siz is a vector of doubles
    if ~isempty(siz),
        if ~(isnumeric(siz) & isreal(siz) & (length(siz)>1)...
                & all(siz > 0) & all(siz==floor(siz))),
            msg = ['Dimension vector must contain 2 or more integer values, ' ...
                    'all greater than zero.'];
            return
        end
    end
    
    % - check that num is a scalar double or 'all'
    if ~strcmpi(num,'all'),
        if ~((class(num)=='double') & (num>=0) & isreal(num) & ...
                (num==floor(num))),
            msg = ['Number of messages must be a real positive integer ' ...
                'value, or ''all''.'];
            return
        end
    end
else
    num = 1;
end

% Determine timeout
if (nargin == 6)&(~isempty(varargin{6})),
    timeout = varargin{6};
    if ~isnumeric(timeout)|(timeout<0),
        msg = 'Time-out must be a positive numeric value.';
        return
    end
else 
    timeout = r.timeout; 
end 


% [EOF] readmsg.m
