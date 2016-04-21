%APPCS1 Nonlinear system identification.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.16 $  $Date: 2002/04/14 21:16:42 $

clf;
figure(gcf)

echo on
deg2rad = pi/180;
rand('seed',584146048);


%    NEWFF  - Creates feed-forward networks.
%    TRAIN - Trains a network.
%    SIM   - Simulates networks.

%    NONLINEAR SYSTEM IDENTIFICATION:

%    Using the above functions a feed-forward network is trained
%    to model a nonlinear system: the inverted pendulum.

pause % Strike any key to continue...

%    DEFINING THE MODEL PROBLEM
%    ==========================

%    We would like to train a network to model a pendulum system
%    described by the functions PMODEL.

%    To do this we need examples of pendulum initial states and
%    associated target state changes.

%    The file APPCS1D contains such initial/target states.

load appcs1d

pause % Strike any key to see where these values came from...

%    HOW INITIAL STATES WERE OBTAINED
%    ================================

%    Below is the code that was used to define the initial states Pc
%    consisting of various combinations of angle, velocity, and
%    force values, in addition to a set of steady state conditions
%    (vel = 0, force = 0).

% angle = [-20:22:200]*deg2rad;
% vel = [-90:36:90]*deg2rad;
% force = -30:6:30;
% angle2 = [-20:10:200]*deg2rad;
% Pm = [combvec(angle,vel,force) [angle2; zeros(2,length(angle2))]];

pause % Strike any key to see how the next states were obtained...

%    HOW TARGET STATE CHANGES WERE OBTAINED
%    ======================================

%    The target changes Tm were found by simulating the pendulum
%    system PMODEL for one time step for each initial state
%    vector in Pc.

% timestep = 0.05;
% Q = length(Pm); 
% Tm = zeros(2,Q);
% for i=1:Q
%   [ode_time,ode_state] = ode23('pmodel',[0 timestep],Pm(:,i));
%   Tm(:,i) = ode_state(length(ode_state),1:2)' - Pm(1:2,i);
% end
% save appcs1d timestep Q Pm Tm

pause % Strike any key to design the model network...

%    DESIGNING THE NETWORK
%    =====================

%    NEWFF creates weights and biases for a two-layer
%    TANSIG/PURELIN network with 8 TANSIG neurons.

S1 = 8;
[S2,Q] = size(Tm);

mnet = newff(minmax(Pm),[S1 S2],{'tansig' 'purelin'},'trainlm');

pause % Strike any key to train the neuron model...

%    TRAINING THE NETWORK
%    ====================

%    We will use TRAIN to train the model network so that
%    a typical error is 0.0037 radians (0.2 deg) for the Q
%    2-element target vectors.

mnet.trainParam.show = 10;          % Frequency of progress displays (in epochs).
mnet.trainParam.epochs = 300;       % Maximum number of epochs to train.
mnet.trainParam.goal = (0.0037^2);  % Mean-squared error goal.

%    Training begins...please wait...

mnet = train(mnet,Pm,Tm);

%    ...and finally finishes.
pause % Strike any key to test the neuron model...

appcs1b
