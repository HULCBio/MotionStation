% AERO_GUID_PLOT StopFcn plot script for Simulink model 'guidance'

%   J.Hodgson  
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/06/17 13:13:46 $

d2r = pi/180;

if ~isempty(findobj(0,'Tag','F3'));delete(findobj(0,'Tag','F3'));end;
f3 = figure('Tag','F3');
set(gcf,'pos',[408 61 596 569])

% The following assignments allows the demos that call this script to run
% inside functions as well as interactively
Latax    = evalin('caller','Latax');
Incid    = evalin('caller','Incid');
Mach     = evalin('caller','Mach');
Fin_dem  = evalin('caller','Fin_dem');
Gimbal   = evalin('caller','Gimbal');
Tgt_pos  = evalin('caller','Tgt_pos');
Miss_pos = evalin('caller','Miss_pos');
Mode     = evalin('caller','Mode');

subplot(221);plot(Latax.time,Latax.signals.values(:,1)/9.81,Latax.time,Latax.signals.values(:,2)/9.81,'-.');grid;
set(gca,'xlim',[0 max(Latax.time)])
xlabel('Time [Sec]');ylabel('Normal Acceleration [g]')
legend('a_z','a_{zdemand}')
subplot(222);plot(Incid.time,Incid.signals.values/d2r);grid
set(gca,'xlim',[0 max(Incid.time)])
xlabel('Time [Sec]');ylabel('Incidence \alpha [deg]')
subplot(223);plot(Mach.time,Mach.signals.values);grid
set(gca,'xlim',[0 max(Mach.time)])
xlabel('Time [Sec]');ylabel('Mach Number')
subplot(224);plot(Fin_dem.time,Fin_dem.signals(1).values/d2r);grid;
set(gca,'xlim',[0 max(Fin_dem.time)])
xlabel('Time [Sec]');ylabel('Fin Demands [deg]')

if ~isempty(findobj(0,'Tag','F4'));delete(findobj(0,'Tag','F4'));end;
f4 = figure('Tag','F4');
set(gcf,'pos',[10 60 390 250])
I=find(diff(Mode.signals.values)~=0);
plot(Gimbal.time,Gimbal.signals.values(:,2)/d2r,'--',Gimbal.time,Gimbal.signals.values(:,1)/d2r,Gimbal.time(I),Gimbal.signals.values(I,1)/d2r,'rx');grid;
set(gca,'xlim',[0 max(Gimbal.time)],'ylim',[-30 30])
legend('True Look Angle','Gimbal Angle','Mode Changes')
xlabel('Time [Sec]');ylabel('Gimbal & Look Angles [deg]')

if ~isempty(findobj(0,'Tag','F5'));delete(findobj(0,'Tag','F5'));end;
f5 = figure('Tag','F5');
set(gcf,'pos',[10 385 390 244])
h=plot(Tgt_pos.signals.values(:,1),Tgt_pos.signals.values(:,2),'--',Miss_pos.signals.values(:,1),Miss_pos.signals.values(:,2),Miss_pos.signals.values(end,1),Miss_pos.signals.values(end,2),'x');grid
set(gca,'ydir','reverse')
xlabel('X [m]');ylabel('Z [m]');title('Missile and Target Trajectories');
legend('Target','Missile')
