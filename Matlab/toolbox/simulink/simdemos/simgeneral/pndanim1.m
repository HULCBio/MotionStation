function [sys,x0]=pndanim1(t,x,u,flag,ts);
%PNDANIM3 S-function for animating the motion of a pendulum.

%   Ned Gulley, 6-21-93
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 5.10 $

global PendAnim1

if flag==2,
  if any(get(0,'Children')==PendAnim1),
    if strcmp(get(PendAnim1,'Name'),'simppend Animation'),
      set(0,'currentfigure',PendAnim1);
      hndlList=get(gca,'UserData');
      x=[u(1) u(1)+2*sin(u(2))];
      y=[0 -2*cos(u(2))];
      set(hndlList(1),'XData',x,'YData',y);
      set(hndlList(2),'XData',u(1),'YData',0);
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
  animinit('simppend Animation');
  [flag,PendAnim1] = figflag('simppend Animation');
  axis([-3 3 -2 2]);
  hold on;

  x=[0 0];
  y=[0 -2];
  hndlList(1)=plot(x,y,'LineWidth',5,'EraseMode','background');
  hndlList(2)=plot(0,0,'.','MarkerSize',25,'EraseMode','back');
  set(gca,'DataAspectRatio',[1 1 1]);
  set(gca,'UserData',hndlList);

  sys=[0 0 0 2 0 0];
  x0=[];

end

