%SUSPGRPH script which runs the suspension model.
%   SUSPGRPH when typed at the command line runs the simulation and
%   plots the results of the Simulink model SUSPN.
%
%   See also SUSPDAT, SUSPN.

%   Author(s): D. Maclay, S. Quinn, 12/1/97
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $

x0 = [-4.335788328729104e-018;-1.201224489795918e-001;6.462348535570529e-027;-1.033975765691285e-025];
[t,x]=sim('suspn',10,simset('InitialState',x0));  % run a time response

% Plot graphs
tt=[0:0.01:t(length(t))];
figure
subplot(5,1,1), plot(tt,THETAdot), ylabel('THETAdot')
text(2.2,0.002,'d\theta/dt')
title('Vehicle Suspension Model Simulation')
set(gca, 'xticklabel', '')
subplot(5,1,2), plot(tt,Zdot), ylabel('Zdot')
text(2.2, 0.03, 'dz/dt')
set(gca, 'xticklabel', '')
subplot(5,1,3), plot(tt,ForceF), ylabel('Ff')
text(0.5,6500,'reaction force at front wheels')
set(gca, 'xticklabel', '')
subplot(5,1,4), plot(tt, h), ylabel('h'), set(gca,'Ylim',[-0.005 0.015]);
text(0.5,0.005 ,'road height')
set(gca, 'xticklabel', '')
subplot(5,1,5), plot(tt, Y), ylabel('Y'), set(gca,'Ylim',[-20 120]);
text(3.5,70,'moment due to vehicle accel/decel')
xlabel('time in seconds')
echo off

% For hardcopy
%set(gcf,'Paperposition',[0.25 2.5 5 6]);
%print -deps suspn.eps
