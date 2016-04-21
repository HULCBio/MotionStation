%RADPLOT Radar Data Processing Tracker plotting script
%

% Author: P. Barnard
% Copyright 1990-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/10 18:40:43 $

%delt = 0.1;  %  Simulated radar data sample time
%deltat = 5;  %  Radar update time

% Post Processing of the Data for Plotting:
pos = [10 40 500 300];
h_1 = figure(1);
set(h_1,'pos',pos);

polar(PolarCoords(:,2) - Measurement_noise(:,2), ...
      PolarCoords(:,1) - Measurement_noise(:,1),'r')
hold on
rangehat = sqrt(X_hat(:,1).^2+X_hat(:,3).^2);
bearinghat = atan2(X_hat(:,3),X_hat(:,1));
polar(bearinghat,rangehat,'g')
text(-35000,-50000,'Actual Trajectory (red) and Estimated Trajectory (green)')

h_2 = figure(2);
set(h_2,'pos',[pos(1)+500 pos(2) pos(3:4)]);
plot(residual(:,1)); grid;set(gca,'xlim',[0 length(residual)]);
xlabel('Number of Measurements');
ylabel('Range Estimate Error - Feet')
title('Estimation Residual for Range')

h_3 = figure(3);
set(h_3,'pos',[pos(1) pos(2)+350 pos(3:4)]);
XYMeas = [PolarCoords(:,1).*cos(PolarCoords(:,2)), ...
          PolarCoords(:,1).*sin(PolarCoords(:,2))];
t_full = [0:0.1:100]';    
t_hat = [0:deltat:100]';    
       
subplot(211)
plot(t_full,XYCoords(:,2),'r');
grid on;hold on
plot(t_full,XYMeas(:,2),'g');
plot(t_hat,X_hat(:,3),'b');
title('E-W Position');
legend('Actual','Meas','Est',3);
hold off
subplot(212)
plot(t_full,XYCoords(:,1),'r');
grid on;hold on
plot(t_full,XYMeas(:,1),'g');
plot(t_hat,X_hat(:,1),'b');
xlabel('Time (sec)');
title('N-S Position');
hold off

