function disable(r, channelName)
%DISABLE Disable RDTX(tm) interface, or specified channel, or all channels. 
%   DISABLE(R, CHANNEL) disables the RTDX channel specified by the string name
%   CHANNEL, and as defined in the RTDX object R.  If CHANNEL is 'all' or 'ALL',
%   all open channels are disabled.
%
%   DISABLE(R) disables the RTDX interface defined in R.
%   
%   See also ENABLE

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.14.4.4 $ $Date: 2004/04/08 20:46:49 $

error(nargchk(1,2,nargin));

if nargin == 2,
     if ischar(channelName) & strcmpi(channelName, 'all'),
        % Enable ALL open channels (for THIS instance)
        for  ich = 1:r.numChannels;
             callSwitchyard(r.ccsversion,[102,r.boardnum,r.procnum,0,0],r.RtdxChannel{ich,1});
        end
    else
         callSwitchyard(r.ccsversion,[102,r.boardnum,r.procnum,0,0],channelName);
    end
else
    % Enable RTDX - Global
    callSwitchyard(r.ccsversion,[102,r.boardnum,r.procnum,0,0]);
end

% [EOF] disable.m
