function [sys,x0]=pndanim3(t,x,u,flag, ts);
%PNDANIM3 S-function for animating the motion of a double pendulum.

%   Ned Gulley, 6-21-93
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 5.11 $

global PendAnim3

if flag==2,
  if any(get(0,'Children')==PendAnim3),
    if strcmp(get(PendAnim3,'Name'),'dblpend2 Animation'),
      set(0,'currentfigure',PendAnim3);
      hndlList=get(gca,'UserData');
      b=.4; c=3;
      xSFP=0; ySFP=0;
      xBFP=xSFP+b*cos(u(1)); 
      yBFP=ySFP+b*sin(u(1));
      xMB1=-xBFP; 
      yMB1=-yBFP;
      xMB2=xMB1+b*sin(u(1)); 
      yMB2=yMB1-b*cos(u(1));
      xMC=xBFP+c*sin(u(2)); 
      yMC=yBFP-c*cos(u(2));
      x=[xMB2 xMB1 xBFP NaN xBFP xMC];
      y=[yMB2 yMB1 yBFP NaN yBFP yMC];
      set(hndlList(1),'XData',x,'YData',y); 
      drawnow;
    end
  end
  sys=[];

elseif flag==0,
  % Initialize the figure for use with this simulation
  animinit('dblpend2 Animation');
  [flag,PendAnim3] = figflag('dblpend2 Animation');
  axis([-2.5 2.5 -4 2]);
  hold on;

  % Set up the geometry for the problem
  % SFP=Space Fixed Pivot
  % BFP=Body Fixed Pivot
  b=.4; c=3;
  xSFP=0; ySFP=0;
  xMB1=xSFP-b; yMB1=ySFP;
  xMB2=xMB1; yMB2=yMB1-b;
  xBFP=xSFP+b; yBFP=ySFP;
  xMC=xBFP; yMC=yBFP-c;
  % Use NaNs to make the link distinct
  x=[xMB2 xMB1 xBFP NaN xBFP xMC];
  y=[yMB2 yMB1 yBFP NaN yBFP yMC];
  hndlList(1)=plot(x,y,...
                  'EraseMode','background', ...
                  'LineWidth',5, ...
                  'Marker','.', ...
                  'MarkerSize',20);

  set(gca,'DataAspectRatio',[1 1 1]);
  set(gca,'UserData',hndlList);

  sys=[0 0 0 2 0 0];
  x0=[];

end

