%APPLIN3 Linear system identification.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.14 $  $Date: 2002/04/14 21:16:54 $

clf;
figure(gcf)
echo on


%    SOLVELIN - Solves for a linear layer.
%    SIMULIN   - Simulates a linear layer.

%    LINEAR SYSTEM IDENTIFICATION:

%    Using the above functions a linear neuron is designed
%    to model a linear system.

pause % Strike any key to continue...

%    DEFINING A WAVE FORM
%    ====================

%    TIME defines the time steps of this simulation.

time = 0:0.025:5;  % from 0 to 6 seconds

%    X defines a systems input signal:

X = sin(sin(time).*time*10);

%    The input to the neural network is the most recent
%    three values of the systems input signal:

Q=size(X,2);
P = zeros(3,Q);
P(1,1:Q) = X(1,1:Q);
P(2,2:Q) = X(1,1:(Q-1));
P(3,3:Q) = X(1,1:(Q-2));

%    The target T is the output of the original system.

T = filter([1 0.5 -1.5],1,X);

pause % Strike any key to see these signals...

%    PLOTTING THE INPUT SIGNAL
%    =========================

%    Here is a plot of the input signal to the system:

plot(time,X)
axis([0 5 -2 2]);
xlabel('Time');
ylabel('Input Signal');
title('Input Signal to the System');

pause % Strike any key to see these signals...

%    PLOTTING THE OUTPUT SIGNAL
%    ==========================

%    Here is a plot of the output signal of the system:

plot(time,T)
axis([0 5 -2 2]);
xlabel('Time');
ylabel('Output Signal');
title('Output Signal of the System');

pause % Strike any key to design the network...

%    DESIGNING THE NETWORK
%    =====================

%    NEWLIND solves for weights and biases which will let
%    the linear neuron model the system.

net = newlind(P,T);

pause % Strike any key to test the neuron model...

%    TESTING THE MODEL
%    =================

%    SIM simulates the linear neuron which models the
%    original system.

a = sim(net,P);

%    The output signal is plotted with the targets.

plot(time,a,time,T,'+')
axis([0 5 -2 2]);
xlabel('Time');
ylabel('Network Output - System Output +');
title('Network and System Output Signals');

%    The linear neuron does a good job.

pause % Strike any key to see the error signal...

%    THE ERROR SIGNAL
%    ================

%    Error is the difference between output and target signals.

e = T-a;

%    This error can be plotted.

plot(time,e,[min(time) max(time)],[0 0],':r')
axis([0 5 -2 2]);
xlabel('Time');
ylabel('Error');
title('Error Signal');

%    Notice how small the error is!

echo off
disp('End of APPLIN3')
