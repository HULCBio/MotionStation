function cfzoom(hProp,hEvent,ax1,ax2,srcnum)
%CFZOOM Adjust X limits of both axes when either one zooms

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:40:20 $

% Bail out if things are in a bad state
if ~ishandle(ax1) | ~ishandle(ax2)
   return
end

% We know the source of the zoom, find our target
targnum = 1:2;
targnum(srcnum) = [];

% Find the list of listeners and the one listener we should disable
if srcnum==1
   axresid = ax1;
   targnum = 2;
else
   axresid = ax2;
   targnum = 1;
end
list = get(axresid,'UserData');
if length(list)~=2
   return
end
list = list(targnum);

% Disable this listener, change the axes, and re-enable the listener
list.enable = 'off';
set(ax2,'XLim',get(ax1,'XLim'));
list.enable = 'on';
