function [sys, x0] = dee4plt(t,x,u,flag,plotit),
%DEE4PLT Draw a two mass, two spring system.
%   DEE4PLT is an S-function that is used to animate
%   a two mass, two spring system.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.15 $

global Handles;

if abs(flag) == 0,
  sys = [ 0 1 0 3 0 0];
  x0 = 0;
  if plotit,
    for i = 1:length(Handles),
      set(Handles(i),'Visible','On');
    end
  end
elseif (flag == 2),
  if (plotit & ~isempty(Handles)),
    x1 = u(1);
    x2 = u(2);
    F1 = u(3);

    % add initial positions
    x1 = x1+3;
    x2 = x2+5;

    %set handles
    m1h = Handles(1);
    m2h = Handles(2);
    s1h = Handles(3);
    s2h = Handles(4);
    d1h = Handles(5);
    d2h = Handles(6);

    % initialize constants

    nlinks12 = 6;
    nlinks01 = 8;
    Llink = 1;
    lenM1 = .7;
    widM1 = .6;
    lenM2 = .7;
    widM2 = 0.6;
    lenD2 = 1.5;

    % Draw the ceiling at x= 0
    %xc = [0   0];
    %yc = [-1  1];

    % mass1 is a block centered at x1
    xm1i = [-lenM1/2, lenM1/2 lenM1/2 -lenM1/2];
    xm1 = xm1i+x1;

    % mass2 is centered at x2
    xm2i = [-lenM2/2, lenM2/2 lenM2/2 -lenM2/2];
    xm2 = xm2i+x2;

    % Force arrow acts on block 2, length proportional to force
    xA1 = x2+lenM2/2;
    xA = [xA1, xA1 + F1];
    xAH = [xA1, xA1+.15*F1, xA1+.15*F1];
    yAH = [0, -.1*F1, .1*F1];
    % spring #1
    theta1 = asin((x1-lenM1/2)/nlinks01/Llink);

    pinX1 = Llink*sin(theta1)*[0 .5 1.5 2.5 3.5 4.5 5.5 6.5 7.5 8];
    pinY1 = 0.5*Llink*cos(theta1)*[0 -1 1 -1 1 -1 1 -1 1 0];

    % spring #2
    theta2 = asin((x2-(x1+lenM1/2)-lenM2/2)/nlinks12/Llink);

    pinX2 = Llink*sin(theta2)*[0 .5 1.5 2.5 3.5 4.5 5.5 6]+x1+lenM1/2;
    pinY2 = 0.5*Llink*cos(theta2)*[0 -1 1 -1 1 -1 1 0];

    % damper
    xd1 = [0 x1-lenM1/2-lenD2];
    xd2 = [x1-lenM1/2-lenD2 x1];
    yd = [0.8 0.8];

    % color [0 x1-lenM1/2-lenD2];
    xd2 = [x1-lenM1/2-lenD2 x1];
    yd = [0.8 0.8];

    % color ratios, for changing colors
    ratio1 = min(abs((x1-3)/7 + .5), 1);
    ratio2 = min(abs((x2-5)/7 + .5), 1);
    
    %reset the picture
    set(m1h,'Xdata',xm1,'FaceColor',[ratio1 ratio1 .5]);
    set(m2h,'Xdata',xm2,'FaceColor',[.9 ratio2 ratio2]);
    set(s1h,'Xdata',pinX1,'Ydata',pinY1);
    set(s2h,'Xdata',pinX2,'Ydata',pinY2);
    set(d1h,'Xdata',xd1);
    set(d2h,'Xdata',xd2);
    drawnow
  else
    % do nothing
  end % if plotit
  sys = 0;
else
  sys= [];
end % if abs(flag) == 0

