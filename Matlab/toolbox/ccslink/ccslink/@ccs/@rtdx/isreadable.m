function bool = isreadable(r, channelName)
%ISREADABLE Check if specified RDTX(tm) channel is readable.
%   ISREADABLE(R, CHANNEL) returns a Boolean value signifying whether an RTDX 
%   channel specified by the string CHANNEL, and as defined in the RTDX object 
%   R, is configured for 'read' operation.
%

% Copyright 2000-2003 The MathWorks, Inc.
% $Revision: 1.12.4.2 $ $Date: 2004/04/08 20:46:56 $

error(nargchk(2,2,nargin))

if ~exist('r'),
	error('Specified RTDX object does not exist.');
end

if ~ischar(channelName),
	error('Channel name must be a character string.');
elseif isempty(channelName),
	error('Channel name cannot be an empty string.');
end

% Check if the channelName is an existing open channel
chID=strmatch(channelName, {r.RtdxChannel{:,1}}, 'exact');
if isempty(chID),
    error('Specified channel is not open.');
end

if strcmpi(r.RtdxChannel{chID, 3},'r'),
    bool = logical(1);
elseif strcmpi(r.RtdxChannel{chID, 3},'w'),
    bool = logical(0);
else
    error('Specified channel is not properly initialized.');
end

% [EOF] isreadable.m

