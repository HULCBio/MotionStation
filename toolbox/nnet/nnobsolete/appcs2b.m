%APPCS2B

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.14 $  $Date: 2002/04/14 21:16:51 $

echo off
clf;
figure(gcf)
deg2rad = pi/180;
if ~exist('mnet'),load appcs2d,end
if ~exist('cnet'),load appcs2d2,end
timestep = 0.05;
echo on

%    TESTING THE CONTROLLER
%    ======================

%    Here are some initial conditions for which the controller
%    will be tested:

angle0 = 10*deg2rad;
vel0 = 0;
init_state = [angle0; vel0];

%    Here is the desired angle of the pendulum:

demand = 90*deg2rad;

pause % Strike any key to calculate the desired response...

%    DESIRED BEHAVIOR
%    ================

%    The function ODE23 can be used to calculate the desired
%    response of the controlled pendulum.  The controlled pendulum
%    is to behave like the linear system PLINEAR.

[p_time,p_states] = ode23('plinear',[0 4],[init_state; demand]);
p_states = p_states';

pause % Strike any key to see the desired response...

%    DESIRED RESPONSE
%    ================

%    Here we plot the desired angle and velocity responses.

subplot(2,1,1), plot(p_time,p_states(1,:)/deg2rad,'r')
hold on, plot(p_time,p_time*0+demand/deg2rad,':r'), hold off
xlabel('Time');
ylabel('Angle (deg)');
title('Pendulum Response');
subplot(2,1,2), plot(p_time,p_states(2,:)/deg2rad,'r')
hold on, plot(p_time,p_time*0,':r'), hold off
xlabel('Time');
ylabel('Velocity (deg/sec)');

%    Note that the angle quickly moves to 90 degrees and to
%    a velocity of 0.

pause % Strike any key to calculate the actual response...

%    ACTUAL BEHAVIOR
%    ===============

%    Each time step the control network calculates the right
%    force to make the pendulum behave like the linear reference
%    model.

time = 0:timestep:4;
state = init_state;
states = zeros(2,length(time));
states(:,1) = state;
for i=2:length(time)
  force = sim(cnet,[state; demand]);
  [ode_time,ode_state] = ode23('pmodel',[0 timestep],[state; force]);
  state = ode_state(length(ode_state),1:2)';
  states(:,i) = state;
  echo off
end
echo on

pause % Strike any key to see the actual response...

%    ACTUAL RESPONSE
%    ===============

%    Here we plot the actual response of the controlled pendulum
%    and compare it to the desired linear system response.

clf
subplot(2,1,1), plot(p_time,p_states(1,:)/deg2rad,'+r',time,states(1,:)/deg2rad,'k')
hold on, plot(p_time,p_time*0+demand/deg2rad,':r'), hold off
xlabel('Time (sec)');
ylabel('Angle (deg): D + A -');
title('Desired and Actual Response');
subplot(2,1,2), plot(p_time,p_states(2,:)/deg2rad,'+r',time,states(2,:)/deg2rad,'k')
hold on, plot(p_time,p_time*0,':r'), hold off
xlabel('Time (sec)');
ylabel('Velocity (deg/sec): D+ A -');

%    The response is close to perfect.  The pendulum has
%    been controlled to match the linear reference model 
%    with a neural controller.

echo off
disp('End of APPCS2')

