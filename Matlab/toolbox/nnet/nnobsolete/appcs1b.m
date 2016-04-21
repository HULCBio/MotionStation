%APPCS1B

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.14 $  $Date: 2002/04/14 21:16:45 $

echo off
deg2rad = pi/180;
if ~exist('mnet'),load appcs2d,load appcs1d,end
clf;
figure(gcf)

echo on

%    TESTING THE MODEL
%    =================

%    To test the model network against the pendulum, we will
%    first "measure" the pendulums response to these initial conditions.

angle = 5 * deg2rad;
vel = 0*deg2rad;
force = 0;

init_state = [angle; vel];

%    Here we "measure" and plot the pendulum response for 4 seconds.

[p_time,p_states] = ode23('pmodel',[0 4],[init_state; force]);
p_states = p_states';

pause % Strike any key to see the pendulum repsonse...

%    PENDULUM RESPONSE
%    =================

%    Here we plot the pendulum angle and velocity responses.

subplot(2,1,1)
plot(p_time,p_states(1,:)/deg2rad,'r')
xlabel('Time (sec)');
ylabel('Angle (deg)');
title('Pendulum Response');
hold on
subplot(2,1,2)
plot(p_time,p_states(2,:)/deg2rad,'r')
xlabel('Time (sec)');
ylabel('Velocity (deg/sec)');
hold off

pause % Strike any key to calculate the models open loop response...

%    OPEN LOOP RESPONSE
%    ==================

%    Here we simulate the network open loop response.

time = 0:timestep:4;
state = init_state;
states = zeros(2,length(time));
states(:,1) = state;
for i=2:length(time)
  state = state + sim(mnet,[state;force]);
  states(:,i) = state;
  echo off
end
echo on

pause % Strike any key to see a comparison plot.

%    PENDULUM VS. OPEN LOOP MODEL RESPONSES
%    ======================================

%    The open loop response can be compared with the pendulum.

clf
subplot(2,1,1)
plot(p_time,p_states(1,:)/deg2rad,'+r',time,states(1,:)/deg2rad,'k')
xlabel('Time (sec)');
ylabel('Angle (deg): P + N -');
title('Pendulum and Open Network Response');
hold on
subplot(2,1,2)
plot(p_time,p_states(2,:)/deg2rad,'+r',time,states(2,:)/deg2rad,'k')
xlabel('Time (sec)');
ylabel('Velocity (deg/sec): P + N -');
hold off

%    Note that the model has learned the basic behavior of the
%    pedulum well.  However, over time the slight errors in
%    the model accumulate.

%    Fortunately, the model does not need to be used in an open
%    loop manner.

pause % Strike any key to calculate the models closed loop response...

%    MODEL CLOSED LOOP RESPONSE
%    ==========================

%    Here we simulate the networks closed loop response.

%    Each time step the network calculates its estimate of the
%    pendulums next state, and then measurements of the pendulum
%    state are used to correct this estimate.

state = init_state;
states(:,1) = state;
for i=2:length(time)
  new_state = state + sim(mnet,[state; force]);
  states(:,i) = new_state;
  [ode_time,ode_state] = ode23('pmodel',[0 timestep],[state; force]);
  state = ode_state(length(ode_state),1:2)';
  echo off
end
echo on

pause % Strike any key to see a comparison plot.

%    PENDULUM VS. CLOSED LOOP MODEL RESPONSES
%    ========================================

%    The closed loop response can be compared with the pendulum.

clf
subplot(2,1,1), plot(p_time,p_states(1,:)/deg2rad,'+r')
hold on, plot(time,states(1,:)/deg2rad,'k'), hold off
xlabel('Time (sec)');
ylabel('Angle (deg): P + N -');
title('Pendulum and Closed Network Response');
subplot(2,1,2), plot(p_time,p_states(2,:)/deg2rad,'+r')
hold on, plot(time,states(2,:)/deg2rad,'k'), hold off
xlabel('Time (sec)');
ylabel('Velocity (deg/sec): P + N -');
hold off

%    As can be seen from the plot, the closed loop response of
%    the network model is extremely accurate.

%    See APPCS2 to see how to design a controller using the model.

echo off
disp('End of APPCS1')
