function [sys,x0]=pndanim2(t,x,u,flag,ts);
%PNDANIM2 S-function for animating the motion of a double pendulum.

%   Ned Gulley, 6-21-93
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 5.11 $

global PendAnim2

if flag==2,
  if any(get(0,'Children')==PendAnim2),
    if strcmp(get(PendAnim2,'Name'),'dblpend1 Animation'),
      set(0,'currentfigure',PendAnim2);
      hndl=get(gca,'UserData');
      b=1; c=2;
      xSFP=0; ySFP=0;
      xBFP=xSFP+b*sin(u(1)); yBFP=ySFP-b*cos(u(1));
      xMC=xBFP+c*sin(u(2)); yMC=yBFP-c*cos(u(2));
      x=[xSFP xBFP NaN xBFP xMC];
      y=[ySFP yBFP NaN yBFP yMC];
      set(hndl,'XData',x,'YData',y);
      drawnow;
    end
  end
  sys=[];

elseif flag==0,
  % Initialize the figure for use with this simulation
  animinit('dblpend1 Animation');
  [flag,PendAnim2] = figflag('dblpend1 Animation');
  axis([-3 3 -5 2]);
  hold on;

  % Set up the geometry for the problem
  % SFP=Space Fixed Pivot
  % BFP=Body Fixed Pivot
  b=1; c=2;
  xSFP=0; ySFP=0;
  xBFP=xSFP; yBFP=ySFP-b;
  xMC=xBFP; yMC=yBFP-c;
  x=[xSFP xBFP NaN xBFP xMC];
  y=[ySFP yBFP NaN yBFP yMC];
  hndl=plot(x,y, ...
           'EraseMode','background', ...
           'LineWidth',5, ...
           'Marker','.', ...
           'MarkerSize',20);
  set(gca,'DataAspectRatio',[1 1 1]);
  set(gca,'UserData',hndl);

  sys=[0 0 0 2 0 0];
  x0=[];

end

