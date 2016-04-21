function massprng(action);

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.11 $

global xySpr syBox
if nargin==0,
    xySpr=[ ...
        0.00    0.45
        0.05    0.45
        0.07    0.55
        0.11    0.35
        0.15    0.55
        0.19    0.35
        0.23    0.55
        0.27    0.35
        0.29    0.45
        0.34    0.45];
    xyBox=[ ...
        0.00    0.45
        0.00    0.30
        0.10    0.30
        0.10    0.60
        0.00    0.60
        0.00    0.45];
    plot([0 0],[0.6 0.3]);
    hold on;
    axis([0 1 0 1]);
    axis off;
    set(gca,'Drawmode','fast');
    set(gcf,'BackingStore','off');
    xy=[xySpr; [xyBox(:,1)+0.34 xyBox(:,2)]];
    h=plot(xy(:,1),xy(:,2),'EraseMode','background');
    for t=0:.05:1000,
        xSpr=xySpr(:,1)*(sin(t)+1.2);
        xBox=xyBox(:,1)+max(xSpr);
        set(h,'XData',[xSpr; xBox]);
        drawnow;
    end;
else
    h=get(gcf,'UserData');
    xSpr=xySpr(:,1)*u;
    xBox=xyBox(:,1)+max(xSpr);
    set(h,'XData',[xSpr; xBox]);
    drawnow;
end;
