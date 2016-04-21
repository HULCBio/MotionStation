function close(varargin)
%CLOSE Close RDTX(tm) channels to the target DSP.
%   CLOSE(R, CHANNEL1, CHANNEL2,...) closes open RTDX channels specified by
%   string names CHANNEL1, CHANNEL2, etc., and as defined in the RTDX object R.
%   Interface handle to the specified channel is released and the channel
%   entry is removed for the RtdxChannel cell array.
%
%   CLOSE(R, CHANNEL) closes a single specified CHANNEL, or if CHANNEL is 
%   'all' or 'ALL', then all open channels are closed.
%
%   See also OPEN

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.22.4.4 $ $Date: 2004/04/08 20:46:47 $

[errMsg,r,chVect] = parse_args(varargin{:});
error(errMsg);

if ~isempty(r.Rtdx),          % Check if handle was created with CCSDSP object
    handleAction = @release;
else
    handleAction = @delete;
end
% closeChannels(r, chVect, handleAction);
for ct = chVect,
    callSwitchyard(r.ccsversion,[104 r.boardnum r.procnum r.timeout 0],r.RtdxChannel{ct,1});
    % r.RtdxChannel = r.deletechannel(ct);
      tmp = r.RtdxChannel;
      tmp(ct, :) = [];
      cellobj = tmp;
      r.RtdxChannel = cellobj;
    %%% eof r.deletechannel
    r.numChannels = r.numChannels - 1;
end
if (r.numChannels == 0),
    r.RtdxChannel = {'' [] ''};    % Reset RtdxChannel cell array
end
%%% eof closeChannels



%------------------------------------------------------------------------------
function [msg,r,chVect] = parse_args(varargin)
% Parse and validate the inputs
% 'msg' is empty if no error occurs.

msg      = [];
r        = [];
chVect   = [];

if nargin < 2,
    msg = 'There must be at least 2 input arguments.';
    return
end
r = varargin{1};

if ~ischar(varargin{2}),
    msg = 'Channel name must be a character string.';
    return
elseif isempty(varargin{2}),
    msg = 'Channel name cannot be an empty string.';
    return
end
if strcmpi(varargin{2}, 'all'),
    if nargin > 2,
        msg = ['Invalid number of arguments for the close "ALL" option.'];
        return
    else
        % Close all channels
        chVect = r.numChannels:-1:1;
        return
    end
else
    for ct = 1:nargin - 1,
        if ~ischar(varargin{ct+1}),
            msg = 'Channel names must be character strings.';
            return
        elseif isempty(varargin{ct+1}),
            msg = 'Channel name cannot be an empty string.';
            return
        end
        % Close specified channel
        chID=strmatch(varargin{ct+1}, {r.RtdxChannel{:,1}}, 'exact');
        if isempty(chID),
            msg = ['Channel "' varargin{ct+1} '" is not open.'];
            return
        end
        chVect = [chVect chID];
    end
    chVect = fliplr(sort(chVect));
end


%------------------------------------------------------------------------------
function dummy = closeChannels(r, chVect, handleAction)
%CLOSECHANNELS Closes channels in R indexed by the elements of channel ID vector

for ct = chVect,
    callSwitchyard(r.ccsversion,[104 r.boardnum r.procnum r.timeout 0],r.RtdxChannel{ct,1});
%   r.RtdxChannel = r.deletechannel(ct);
    tmp = r.RtdxChannel;
    tmp(ct, :) = [];
    cellobj = tmp;
    r.RtdxChannel = cellobj;
    
    r.numChannels = r.numChannels - 1;
end
if (r.numChannels == 0),
    r.RtdxChannel = {'' [] ''};    % Reset RtdxChannel cell array
end

%------------------------------------------------------------------------------
function cellobj = deletechannel(r, row)
%DELETECHANNEL Delete a cell-array row (channel entry) in the RDTX(tm) object.
%   DELETECHANNEL(R, ROW) is a private method which deletes a channel entry 
%   indexed by ROW in the cell array in the object R.

% Implementation should be:
% cellobj{row,col} = value;
%
% Temporary workaround for language limitation:

tmp = r.RtdxChannel;
tmp(row, :) = [];
cellobj=tmp;

% [EOF] close.m


