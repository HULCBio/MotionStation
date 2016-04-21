function xpcpollwarn(mdl)
% XPCPOLLWARN xPC Target private function.

%   This function determines whether polling mode is active or not, and
%   emits a warning if it is. It is called from xpctarget_make_rtw_hook.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $ $Date: 2002/03/25 04:22:18 $

% Look for xpcCPUClockPoll
if ~getxpcPollClock(mdl)
  return
end

nag           = slsfnagctlr('NagTemplate');
nag.type      = 'Warning';
nag.component = 'xPC Target';
nag.msg.summary   = 'Host-Target communication may be stopped';
nag.msg.details = sprintf([                                           ...
    'You have selected the Polling mode of xPC Target. '              ...
    'In this mode, all communication between host and '               ...
    'target will be suspended while an application is running.\n\n'   ...
    'This is normal, and the connection will be re-established when ' ...
    'the application stops running.\n\n' ...
    'For more information, refer to the Polling Mode chapter in the ' ...
    'xPC Target Users''s guide.']);
nag.sourceFullName = gcs;
nag.sourceName     = gcs;

slsfnagctlr('Push', nag);
slsfnagctlr('View');

function clock = getxpcPollClock(mdl)
clock   = 0;
rtwopts = get_param(mdl, 'RTWOptions');

str     = '-axpcCPUClockPoll=';
strl    = length(str);
idx     = strfind(rtwopts, str);
if isempty(idx)
  return;
end

for tmpIdx = [idx + strl : length(rtwopts)]
  if isspace(rtwopts(tmpIdx))
    break
  end
end

if isempty(rtwopts(idx + strl : tmpIdx - 1))
  return;
end
clock = str2num(rtwopts(idx + strl : tmpIdx - 1));
