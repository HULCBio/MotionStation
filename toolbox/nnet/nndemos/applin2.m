%APPLIN2 Adaptive linear prediction.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.15 $  $Date: 2002/04/14 21:22:39 $

clf;
figure(gcf)
echo on


%    NEWLIN  - Creates and initializes a linear layer.
%    ADAPT  - Trains a linear layer with Widrow-Hoff rule.

%    ADAPTIVE LINEAR PREDICTION:

%    Using the above functions a linear neuron is adaptively
%    trained to predict the next value in a signal, given the
%    last five values of the signal.

%    The linear neuron is able to adapt to changes in the
%    signal it is trying to predict.

pause % Strike any key to continue...

%    DEFINING A WAVE FORM
%    ====================

%    TIME1 and TIME2 define two segments of time.

time1 = 0:0.05:4;      % from 0 to 4 seconds
time2 = 4.05:0.024:6;  % from 4 to 6 seconds

%    TIME defines all the time steps of this simulation.

time = [time1 time2];  % from 0 to 6 seconds

%    T defines a signal which changes frequency once:

T = con2seq([sin(time1*4*pi) sin(time2*8*pi)]);

%    The input P to the network is the same as the
%    target.  The network will use the last five
%    values of the target to predict the next value.

P = T;

pause % Strike any key to see these signals...

%    PLOTTING THE SIGNALS
%    ====================

%    Here is a plot of the signal to be predicted:

plot(time,cat(2,T{:}))
xlabel('Time');
ylabel('Target Signal');
title('Signal to be Predicted');

pause % Strike any key to design the network...

%    DEFINE THE NETWORK
%    ==================

%    NEWLIN generates a linear network.

%    We will use a learning rate of 0.1, and five
%    delays in the input.  The resulting network
%    will predict the next value of the target signal 
%    using the last five values of the target.

lr = 0.1;
delays = [1 2 3 4 5];

net = newlin(minmax(cat(2,P{:})),1,delays,lr);

pause % Strike any key to adapt the linear neuron...

%    ADAPTING THE LINEAR NEURON
%    ==========================

%    ADAPT simulates adaptive linear neurons.  It takes the initial
%    network, an input signal, and a target signal,
%    and filters the signal adaptively.  The output signal and
%    the error signal are returned, along with new network.


%    Adapting begins...please wait...

[net,y,e]=adapt(net,P,T);

%    ...and finishes.

pause % Strike any key to see the output signal...

%    PLOTTING THE OUTPUT SIGNAL
%    ==========================

%    Here the output signal of the linear neuron is plotted
%    with the target signal.

plot(time,cat(2,y{:}),time,cat(2,T{:}),'--')
xlabel('Time');
ylabel('Output ---  Target - -');
title('Output and Target Signals');

%    It does not take the adaptive neuron long to figure out
%    how to generate the target signal.

pause % Strike any key to see the error signal...

%    A plot of the difference between the neurons output
%    signal and the target signal shows how well the
%    adaptive neuron works.

plot(time,cat(2,e{:}),[min(time) max(time)],[0 0],':r')
xlabel('Time');
ylabel('Error');
title('Error Signal');

echo off
disp('End of APPLIN2')
