%RUNABS  script which loads and runs the model absbrake
%   RUNABS  when typed at the command line, loads the model
%   and plots the results.
%
%   See also ABSDATA

%   Author(s): L. Michaels, S. Quinn, 12/1/97 
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $

%
% Open the absbrake model, and run the simulation until the vehicle stops.
% Try to be a little robust here, if the simulation fails try loading the
% model data again, it may have been cleared from the workspace.
%
absbrake
try
  time = sim('absbrake',25);
catch
  absdata
  time = sim('absbrake',25);
end  

h = findobj(0, 'Name', 'ABS Speeds');
if isempty(h),
  h=figure('Position',[300   387   452   257],...
           'Name','ABS Speeds',...
           'NumberTitle','off');
end

figure(h)
set(h,'DefaultAxesFontSize',8)

plot(time,yout(:,1:2))
title('Vehicle speed and wheel speed')
ylabel('Speed(rad/sec)')
xlabel('Time(secs)')
set(gca,'Position',[0.1300    0.1500    0.7750    0.750])
set(get(gca,'xlabel'),'FontSize',10)
set(get(gca,'ylabel'),'FontSize',10)
set(get(gca,'title'),'FontSize',10)

% Plot arrow with annotation
hold on
plot([5.958; 4.192],[36.92; 17.29],'r-',[5.758; 5.958; 6.029],[36.55; 36.92; 35.86],'r-' )
text(8.533,54.66,'Vehicle speed (\omega_v)','FontSize',10)
plot([7.14; 8.35],[43.1; 56.3],'r-',[7.34; 7.14; 7.07],[43.4; 43.1; 44.1],'r-' )
text(4.342,15.69,'Wheel speed (\omega_w)','FontSize',10)
drawnow
hold off

h = findobj(0, 'Name', 'ABS Slip');
if isempty(h),
  h=figure('Position',[300    56   452   257],...
           'Name','ABS Slip',...
           'NumberTitle','off');
end

figure(h);
set(h,'DefaultAxesFontSize',8)

plot(time,slp)
title('Slip')
xlabel('Time(secs)')
ylabel('Normalized Relative Slip')
set(gca,'Position',[0.1300    0.1500    0.7750    0.750])
set(get(gca,'xlabel'),'FontSize',10)
set(get(gca,'ylabel'),'FontSize',10)
set(get(gca,'title'),'FontSize',10)

