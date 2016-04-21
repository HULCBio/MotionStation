function open(varargin)
%OPEN Open RDTX(tm) channels to the target DSP.
%   OPEN(R, CHANNEL1, MODE1, CHANNEL2, MODE2,...) opens new RTDX channels
%   with specified string names CHANNEL1, CHANNEL2, etc. and corresponding 
%   specified read/write modes MODE1, MODE2, etc., and stores these attributes
%   in the RTDX object R.
%       MODE: 'r' or 'R' to configure channel for read, or
%             'w' or 'W' to configure for write
%
%   OPEN(R, CHANNEL, MODE) opens a single, new RTDX channel.
%
%   Note:  Code Composer Studio(R) API will error out if corresponding channel
%   name is not defined and enabled in the target DSP code.
%
%   See also CLOSE

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.29.4.4 $ $Date: 2004/04/08 20:46:59 $


try 
	if ~ishandle(varargin{1}),
        error('First Parameter must be an RTDX Handle.');
	end
catch
    if strcmpi(pwd,[matlabroot '\toolbox\ccslink\ccslink\@ccs\@rtdx']) && ischar(varargin{1}),
        edit(varargin{1});
        return;
    else
        error(lasterr);
    end
end

% Parse and validate the inputs
[errMsg,r,channelName,mode,numCh] = parse_args(varargin{:});
error(errMsg);

for ct = 1:numCh,    
    
    callSwitchyard(r.ccsversion,[103,r.boardnum,r.procnum,0,0],channelName{ct},mode{ct});
    row = r.numChannels+1;
    tmp = r.RtdxChannel;
    tmp{row,1} = channelName{ct};
    tmp{row,2} = [];
    tmp{row,3} = lower(mode{ct});
    r.RtdxChannel = tmp;
    r.numChannels = row;
end


%------------------------------------------------------------------------------
function [msg,r,channel,mode,numCh] = parse_args(varargin)
% Parse and validate the inputs
% 'msg' is empty if no error occurs.

msg     = [];
r       = [];
channel = [];
mode    = [];
numCh   = [];

if ~rem(nargin,2),
    msg = 'Invalid number of input arguments.';
    return
end
r = varargin{1};

numCh = floor(nargin/2);
for ct = 1:numCh,
    if ~ischar(varargin{2*ct}),
        msg = 'Channel name must be a character string.';
        return
    elseif isempty(varargin{2*ct}),
        msg = 'Channel name cannot be an empty string.';
        return
    end
    channel{ct} = varargin{2*ct};
    
    if ~((strcmpi(varargin{2*ct+1}, 'r'))|strcmpi(varargin{2*ct+1}, 'w')),
        msg = sprintf(['Mode for channel "' varargin{2*ct} '" must be a ' ...
                'character: \n''r''/''R'' for read, and ''w''/''W'' for ' ...
                'write.']);
        return
    end
    mode{ct} = varargin{2*ct+1};
    % Check if the channelName is an existing open channel
    chID = strmatch(channel{ct}, {r.RtdxChannel{:,1}}, 'exact');
    if ~isempty(chID),
        msg = sprintf(['The channel "' channel{ct} '" is already open.  If ' ...
                'changing mode only, close channel \nand re-open with ' ...
                'desired mode.']);
        return
    end
end

%------------------------------------------------------------------------------
function cellobj = addchannel(r, row, channelName, handle, mode)
%ADDCHANNEL Add a cell-array row (channel entry) in the RDTX(tm) object.
%   ADDCHANNEL(R, ROW, CHANNEL, HANDLE, MODE) is a private method which adds a 
%   channel entry, setting its properties CHANNEL name string, HANDLE to the
%   Rtdx channel, and read/write MODE of an RTDX channel into the object R cell
%   array indexed by ROW.

% Implementation should be:
% cellobj{row,col} = value;
%
% Temporary workaround for language limitation

tmp = r.RtdxChannel;
tmp{row,1} = channelName;
tmp{row,2} = handle;
tmp{row,3} = mode;
cellobj = tmp;
 
% [EOF] open.m
