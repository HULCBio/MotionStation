function defxpctimer(timerid,timeint,filename)

% DEFXPCTIMER - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4.2.1 $ $Date: 2004/04/22 01:36:33 $

if nargin~=3
	error('xpcwtimer expects 3 input arguments')
end;

%xpcwtimer(0,timerid,timeint,filename);

xpctimerObjs=getappdata(0,'xpctimers');
tids=get(xpctimerObjs,'UserData');
if iscell(tids)
   tids=cell2mat(tids);
end
    
t=xpctimerObjs(find(timerid==tids));

if length(t)== 0
    t=timer;
    if isempty(xpctimerObjs)        
        xpctimerObjs=t;
    else
        xpctimerObjs(end+1)=t;
    end 
end
if ~strcmpi(t.running,'on')
    t.UserData=timerid;
    t.Period=timeint/1000;
    t.ExecutionMode='fixedSpacing';
    t.TimerFcn=sprintf('%s(%d)',filename,timerid);%filename;
    start(t)
end
setappdata(0,'xpctimers',xpctimerObjs)
%start(t)


  