function [sys,x0]=crtanim1(t,x,u,flag,ts);
%CRTANIM1 S-function for animating the motion of a mass-spring system.

%   Ned Gulley, 6-21-93
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 5.9 $

global xSpr1 xBx11 xBx21 onecart

offset=4;

if flag==2,
    if any(get(0,'Children')==onecart),
      if strcmp(get(onecart,'Name'),'onecart Animation'),
        set(0,'currentfigure',onecart);
            u(2)=u(2)+offset;
            distance=u(2)-u(1);
            hndl=get(gca,'UserData');
            x=[xBx11+u(1); xSpr1/4*distance+u(1); xBx21+distance+u(1)];
                set(hndl,'XData',x);
            drawnow;
      end
    end
    sys=[];

elseif flag == 4 % Return next sample hit
  
  % ns stores the number of samples
  ns = t/ts;

  % This is the time of the next sample hit.
  sys = (1 + floor(ns + 1e-13*(1+ns)))*ts;

elseif flag==0,

    % Initialize the figure for use with this simulation
    animinit('onecart Animation');
        onecart = findobj('Type','figure','Name','onecart Animation');
    axis([-10 20 -7 7]);
    hold on;

    xySpr1=[ ...
        0        0
        .4        0
        .8        0.65
        1.6        -0.65
        2.4        0.65
        3.2        -0.65
        3.6        0
        4.0        0];
    xyBx11=[ ...
        0        1.2
        0        -1.2
        0        0];
    xyBx21=[ ...
        0        1.2
        2        1.2
        2        -1.2
        0        -1.2
        0        1.2];
    xBx11=xyBx11(:,1);
    yBx11=xyBx11(:,2);
    xBx21=xyBx21(:,1);
    yBx21=xyBx21(:,2);
    xSpr1=xySpr1(:,1);
    ySpr1=xySpr1(:,2);

    x=[xBx11; xSpr1; xBx21(:,1)+offset];
    y=[yBx11; ySpr1; yBx21];

    % Draw the floor under the sliding masses
    plot([-10 20],[-1.4 -1.4],'yellow', ...
        [-10:19;-9:20],[-2 -1.4],'yellow','LineWidth',2);
    hndl=plot(x,y,'y','EraseMode','background','LineWidth',3);
    set(gca,'UserData',hndl);
    %set(gcf,'Color','w');

    sys=[0 0 0 2 0 0];
    x0=[];

end;
