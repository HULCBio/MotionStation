%APPLIN1 Linear prediction.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.14 $  $Date: 2002/04/14 21:22:30 $

clf;
figure(gcf)
echo on


%    NEWLIND - Solves for a linear layer.
%    SIM   - Simulates a linear layer.

%    LINEAR PREDICTION:

%    Using the above functions a linear neuron is designed
%    to predict the next value in a signal, given the last
%    five values of the signal.

pause % Strike any key to continue...

%    DEFINING A WAVE FORM
%    ====================

%    TIME defines the time steps of this simulation.

time = 0:0.025:5;  % from 0 to 6 seconds

%    T defines the signal in time to be predicted:

T = sin(time*4*pi);
Q = length(T);

%    The input P to the network is the last five values
%    of the signal T:

P = zeros(5,Q);
P(1,2:Q) = T(1,1:(Q-1));
P(2,3:Q) = T(1,1:(Q-2));
P(3,4:Q) = T(1,1:(Q-3));
P(4,5:Q) = T(1,1:(Q-4));
P(5,6:Q) = T(1,1:(Q-5));

pause % Strike any key to see these signals...

%    PLOTTING THE SIGNALS
%    ====================

%    Here is a plot of the signal to be predicted:

plot(time,T)
xlabel('Time');
ylabel('Target Signal');
title('Signal to be Predicted');

pause % Strike any key to design the network...

%    NEWLIND solves for weights and biases which will let
%    the linear neuron model the system.

net = newlind(P,T);

pause % Strike any key to test the predictor...

%    TESTING THE PREDICTOR
%    =====================

%    SIM simulates the linear neuron which attempts
%    to predict the next value in the signal at each
%    timestep.

a = sim(net,P);

%    The output signal is plotted with the targets.

plot(time,a,time,T,'+')
xlabel('Time');
ylabel('Output -  Target +');
title('Output and Target Signals');

%    The linear neuron does a good job.

pause % Strike any key to see the error signal...

%    Error is the difference between output and target signals.

e = T - a;

%    This error can be plotted.

plot(time,e)
hold on
plot([min(time) max(time)],[0 0],':r')
hold off
xlabel('Time');
ylabel('Error');
title('Error Signal');

%    Notice how small the error is!

echo off
disp('End of APPLIN1')
