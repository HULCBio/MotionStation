function enable(r, channelName)
%ENABLE Enable RDTX(tm) interface, or a specified channel, or all channels. 
%   ENABLE(R, CHANNEL) enables the RTDX channel specified by the string CHANNEL,
%   and as defined in the RTDX object R.  If CHANNEL is 'all' or 'ALL', all 
%   open channels are enabled.
%
%   ENABLE(R) enables the RTDX interface defined in R.
%   
%   See also DISABLE

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.13.4.4 $ $Date: 2004/04/08 20:46:52 $

error(nargchk(1,2,nargin));

if nargin == 2,
     if ischar(channelName) & strcmpi(channelName, 'all'),
        % Enable ALL open channels (for THIS instance)
        for  ich = 1:r.numChannels;
             callSwitchyard(r.ccsversion,[101,r.boardnum,r.procnum,0,0],r.RtdxChannel{ich,1});
        end
     else
         callSwitchyard(r.ccsversion,[101,r.boardnum,r.procnum,0,0],channelName);
    end
else
    % Enable RTDX - Global
    callSwitchyard(r.ccsversion,[101,r.boardnum,r.procnum,0,0]);
end

% [EOF] enable.m
