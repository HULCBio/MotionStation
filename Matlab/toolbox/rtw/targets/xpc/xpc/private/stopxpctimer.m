function stopxpctimer(timerid)

% STOPXPCWTIMER - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4.2.1 $ $Date: 2004/04/22 01:36:34 $
		
if nargin~=1
	error('stopxpctimer expects 1 input argument')
end;

xpctimerObjs=getappdata(0,'xpctimers');
tids=get(xpctimerObjs,'UserData');
if iscell(tids)
   tids=cell2mat(tids);
end
t=xpctimerObjs(find(timerid==tids));

if length(t) ~= 1
    error('Could not find timer')
end
%if ~strcmp(t.running,'on')
    stop(t)
%end
%xpcwtimer(1,timerid);
