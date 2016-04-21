% function mvtext

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function mvtext

global MUDUMMYICONS

pw = get(0,'pointerwindow');    % integre window
pl = get(0,'pointerlocation');      % pixels on window
loc = find(MUDUMMYICONS(:,1)==pw);
if ~isempty(loc)
        wpos = get(pw,'position');              % window pixel position
        notpw = find(MUDUMMYICONS(:,1)~=pw);
        newpos = [(pl-wpos(1:2))./wpos(3:4)];   % NEW TEXT POSITION , NORMAL
        set(MUDUMMYICONS(loc,3),'position',newpos,'visible','on');
        if ~isempty(notpw)
          set(MUDUMMYICONS(notpw,3),'visible','off');
        end;
else
        set(MUDUMMYICONS(:,3),'visible','off')
end