%APPLIN4 Adaptive linear system identification.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.17 $  $Date: 2002/04/14 21:16:57 $

clf;
figure(gcf)
echo on


%    NEWLIN  - Initializes a linear layer.
%    ADAPT  - Trains a linear layer with Widrow-Hoff rule.

%    ADAPTIVE LINEAR SYSTEM IDENTIFICATION:

%    Using the above functions a linear neuron is adaptively
%    trained to model a linear system.

%    The linear neuron is able to adapt to changes in the
%    model it is trying to predict.

pause % Strike any key to continue...

%    DEFINING A WAVE FORM
%    ====================

%    TIME1 and TIME2 define two segments of time.

time1 = 0:0.005:4;       % from 0 to 4 seconds
time2 = 4.005:0.005:6;   % from 4 to 6 seconds

%    TIME defines all the time steps of this simulation.

time = [time1 time2];    % from 0 to 6 seconds

%    X defines input signal to the system:

X = sin(sin(time*4).*time*8);

pause % Strike any key to get system outputs...

%    GETTING SYSTEM OUTPUTS
%    ======================

%    Normally the outputs of the system would be measured.
%    Here we will generate some values.

%    T1 defines the outputs during seconds 0 through 4.

steps1 = length(time1);
[T1,state] = filter([1 -0.5],1,X(1:steps1));

%    At 4 seconds the system changes slightly.
%    T2 defines the outputs during seconds 4 through 6.

steps2 = length(time2);
T2 = filter([0.9 -0.6],1,X((1:steps2) + steps1),state);

%    T defines the outputs during the entire interval.

T = [T1 T2];

pause % Strike any key to see these signals...

%    PLOTTING THE INPUT SIGNAL
%    =========================

%    Here is a plot of the input to the system:

plot(time,X)
xlabel('Time');
ylabel('Input Signal');
title('Input Signal to System');

pause % Strike any key to see the output signal...

%    PLOTTING THE OUTPUT SIGNAL
%    ==========================

%    Here is a plot of the output of the system:

plot(time,T)
xlabel('Time');
ylabel('Output Signal');
title('Output Signal of System');

pause % Hit any key to define the problem...

%    DEFINING THE PROBLEM
%    ====================

%    The input P to the network will be the input to
%    the system.  The network will use the input and
%    one delayed value to predict the system output T.

T = con2seq(T);
P = con2seq(X);

pause % Strike any key to define the network...

%    DEFINE THE NETWORK
%    ==================

%    NEWLIN generates a linear network.

%    We will use a learning rate of 0.5, and two
%    delays in the input.  The resulting network
%    will predict the next value of the target signal 
%    using the last two values of the input.

lr = 0.5;
delays = [0 1];

net = newlin(minmax(cat(2,P{:})),1,delays,lr);

pause % Strike any key to adapt the linear neuron...

%    ADAPTING THE LINEAR NEURON
%    ==========================

%    ADAPT simulates adaptive linear neurons.  It takes the
%    initial network, an input signal, and a target signal,
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

%    PLOTTING THE ERROR SIGNAL
%    =========================

%    A plot of the difference between the neurons output
%    signal and the target signal shows how well the
%    adaptive neuron works.

plot(time,cat(2,e{:}),[min(time) max(time)],[0 0],':r')
xlabel('Time');
ylabel('Error');
title('Error Signal');

%    The neuron learns to model the system fairly quickly.
%    When the system changes, at 4 seconds, the neuron
%    quickly adapts to the change.

echo off
disp('End of APPLIN4')
