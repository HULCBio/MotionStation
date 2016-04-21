function [sys,x0]=animtank(t,x,u,flag,ts)
%ANIMTANK Animation of water tank system.

%   Ned Gulley, 10-4-94
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.8.2.1 $  $Date: 2003/01/07 19:34:32 $

global tankdemo

if flag==2,
    if any(get(0,'Children')==tankdemo),
      if strcmp(get(tankdemo,'Name'),'Tank Demo'),

    % Update tank one level
        tankHndlList=get(tankdemo,'UserData');
    yData=get(tankHndlList(1),'YData');
    yOffset=yData(1);
    yData(3:4)=[1 1]*u(2)+yOffset;
    set(tankHndlList(1),'YData',yData);

    yData=get(tankHndlList(2),'YData');
    yData([3 4])=[1 1]*u(2)+yOffset;
    set(tankHndlList(2),'YData',yData);

    yData=get(tankHndlList(3),'YData');
    yData=[1 1]*u(1)+1;
    set(tankHndlList(3),'YData',yData);

        drawnow;
      end
    end
    sys=[];
    x0=[];
    
elseif flag == 4 % Return next sample hit
  
  % ns stores the number of samples
  ns = t/ts;

  % This is the time of the next sample hit.
  sys = (1 + floor(ns + 1e-13*(1+ns)))*ts;
  x0=[];
  
elseif flag==0,

    % Initialize the figure for use with this simulation
    animinit('Tank Demo');
    tankdemo=findobj(0,'Name','Tank Demo');

    tank1Wid=1; 
    tank1Ht=2; 
    tank1Init=0;
    setPt=0.5;

    tankX=[0 0 1 1]-0.5;
    tankY=[1 0 0 1];
    % Draw the tank
    line(1.1*tankX*tank1Wid+1,tankY*tank1Ht+0.95,'LineWidth',2,'Color','black');
    tankX=[0 1 1 0 0]-0.5;
    tankY=[0 0 1 1 0];
    % Draw the water
    waterX=tankX*tank1Wid+1;
    waterY=tankY*tank1Init+1;
    tank1Hndl=patch(waterX,waterY,'blue','EraseMode','none','EdgeColor','none');
    % Draw the anti-water (to erase the blue as we go along)
    waterY([1 2 5])=tank1Ht*[1 1 1]+1;
    waterY([3 4])=tank1Init*[1 1]+1; 
    tank2Hndl=patch(waterX,waterY,[.9 .9 .9],'EdgeColor','none','EraseMode','none');
    % Draw the set point
    lineHndl=line([0 0.4],setPt*[1 1]+1,'Color','red','LineWidth',4, ...
    'EraseMode','background');

    set(gcf, ...
    'Color',[.9 .9 .9], ...
    'UserData',[tank1Hndl tank2Hndl lineHndl]);
    set(gca, ...
    'XLim',[0 2],'YLim',[0 3.5], ...
    'XTick',[],'YTick',[], ...
    'XColor','black','YColor','black', ...
    'Box','on');
    axis equal
    xlabel('Water Level Control','Color','black');
    set(get(gca,'XLabel'),'Visible','on')

    sys=[0 0 0 2 0 0];
    x0=[];

end;
