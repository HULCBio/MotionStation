%   VDPDEMO
%   This demo is designed to be run with the VDP Simulink demo.  

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.22 $

vdp
set_param('vdp/Mu','Gain','1');
open_system('vdp/Scope');
clc;
clf;
echo on;
%
%
% ----------------   Van der Pol Demo    ----------------------
%    MATLAB will simulate the system for 30 seconds
%    and plot the time-varying behavior of X1 and X2.

[t,x] = sim('vdp',20);

pause % Strike any key for plots.

echo off
clc
hold off;
subplot(2,1,1);
title('The State Variables of the Van der Pol System');
shg;
plot(t,x(:,2));
ylabel('X1');
subplot(2,1,2);
plot(t,x(:,1));
ylabel('X2');
xlabel('Time in seconds');
echo on
clc
%
%     Plotting X1 against X2, the data forms a phase-plane diagram...
%
pause % Strike any key for plot.
echo off
clc
clf
shg;
plot(x(:,1),x(:,2));
title('The Phase behavior of the Van der Pol System');
xlabel('X1');
ylabel('X2');
drawnow
time = 20;
iterations = 10;
step_size = 0.2;
x = ones(time/step_size + 1,iterations);
y = ones(time/step_size + 1,iterations);
clc
echo on

%    MATLAB will now run 10 simulations, varying the fraction
%    of X2 that is subtracted from X1'.
mu = 1;
set_param('vdp/Mu','Gain','mu');
open_system('vdp/Scope');
for i = 1:iterations
  mu = 1 - i/iterations;
  [t,s] = sim('vdp', time, ...
      simset('solver','ode1','InitialState',[0.25,0.0],'FixedStep',step_size));
  x(:,i) = s(:,2);
  y(:,i) = s(:,1);
end
set_param('vdp/Mu','Gain','1');


pause % Strike any key for plots.

echo off
clf;
shg;
subplot(2,1,1);
title('The Effect of Reducing the Negative Feedback of X2');
mesh(x);
subplot(2,1,2);
mesh(y);
clc;
echo on;

%    Slices of these surfaces can be displayed as phase-plane diagrams

pause % Strike any key for plots.
echo off;
clc;
clf;
shg;
subplot(2,2,1);
plot(x(:,1),y(:,1));
title('- 1 * X2');
xlabel('X1');
ylabel('X2');
axis;
subplot(2,2,2);
plot(x(:,3),y(:,3));
title('-0.7 * X2');
xlabel('X1');
ylabel('X2');
subplot(2,2,3);
plot(x(:,6),y(:,6));
title('-0.4 * X2');
xlabel('X1');
ylabel('X2');
subplot(2,2,4);
plot(x(:,9),y(:,9));
title('-0.1 * X2');
xlabel('X1');
ylabel('X2');
axis;
echo on;
%
pause % Strike any key to finish demo.
%
echo off;
hold off;
clc;
