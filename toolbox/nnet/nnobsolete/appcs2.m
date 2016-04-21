%APPCS2 Feedback linearization.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.16 $  $Date: 2002/04/14 21:16:48 $

echo off
clf;
figure(gcf)

deg2rad = pi/180;
rand('seed',24792483);
echo on


%    NEWFF  - Creates feed-forward networks.
%    TRAIN - Trains a network.
%    SIM   - Simulates networks.

%    MODEL REFERENCE CONTROL:

%    Using the above functions a feed-forward network is trained
%    to control a nonlinear system: the inverted pendulum.

%    The control network is trained by using a model network to
%    backpropagate system errors to the controller.

pause % Strike any key to continue...

%    DEFINING THE CONTROL PROBLEM
%    ============================

%    We would like to train a network to control a pendulum
%    so that the entire system behaves according to the linear
%    system PLINEAR.

%    To do this we need a neural model of the pendulum and
%    examples of initial states and associated target next states.

%    The file APPCS2D contains the weights and biases for the
%    model network, and initial/target states.

load appcs2d

pause % Strike any key to see where these values came from...

%    HOW NETWORK MODEL AND INITIAL STATES WERE OBTAINED
%    ==================================================

%    The network which models the pendulum was found with the application
%    script APPCS1.

%    Below is the code that was used to define the initial states Pc
%    consisting of various combinations of angle, velocity, and
%    demand values, in addition to a set of steady state conditions
%    (vel = 0, demand = angle).

% angle = [-10:40:190]*deg2rad;
% vel = [-90:36:90]*deg2rad;
% demand = [-180:40:180]*deg2rad;
% angle2 = [-10:10:190]*deg2rad;
% Pc = [combvec(angle,vel,demand) [angle2; zeros(size(angle2)); angle2]];

pause % Strike any key to see how the next states were obtained...

%    HOW TARGET NEXT STATES WERE OBTAINED
%    ====================================

%    The target states Tc were found by simulating the desired
%    linear system PLINEAR for one time step for each initial
%    state vector in Pc.

% timestep = 0.05;
% Q = length(Pc); 
% Tc = zeros(2,Q);
% for i=1:Q
%   [ode_time,ode_state] = ode23('plinear',[0 timestep],Pc(:,i));
%   Tc(:,i) = ode_state(length(ode_state),1:2)' - Pc(1:2,i);
% end
% save appcs2d Q timestep Pc Tc mW1 mb1 mW2 mb2 

pause % Strike any key to design the control network...

%    DESIGNING THE NETWORK
%    =====================

%    NEWFF creates weights and biases for a two-layer
%    TANSIG/PURELIN network with 8 TANSIG neurons and 1 output.

S1 = 8;
cnet = newff(minmax(Pc),[S1 1],{'tansig' 'purelin'});

%    NETWORK creates a network TNET which is a combination of the
%    control network CNET and the model network MNET.  Only
%    the weights and biases for the model network will be
%    adjusted.

numInputs = 2;
numLayers = 4;
tnet = network(numInputs,numLayers);
tnet.biasConnect = [1 1 1 1]';
tnet.inputConnect = [1 0 1 0; 1 0 0 0]';
tnet.layerConnect = [0 0 0 0; 1 0 0 0; 0 1 0 0; 0 0 1 0];
tnet.outputConnect = [0 0 0 1];
tnet.targetConnect = [0 0 0 1];
tnet.inputs{1}.range = minmax(Pc(1:2,:));
tnet.inputs{2}.range = minmax(Pc(3,:));
tnet.layers{1}.size = S1;
tnet.layers{1}.transferFcn = 'tansig';
tnet.layers{2}.size = 1;
tnet.layers{2}.transferFcn = 'purelin';
tnet.layers{3}.size = 8;
tnet.layers{3}.transferFcn = 'tansig';
tnet.layers{4}.size = 2;
tnet.layers{4}.transferFcn = 'purelin';
tnet.performFcn = 'mse';
tnet.trainFcn = 'trainbfg';
tnet.IW{1,1} = cnet.IW{1,1}(:,1:2);
tnet.inputWeights{1,1}.learn = 1;
tnet.IW{1,2} = cnet.IW{1,1}(:,3);
tnet.inputWeights{1,2}.learn = 1;
tnet.b{1} = cnet.b{1};
tnet.biases{1}.learn = 1;
tnet.b{2} = cnet.b{2}; 
tnet.biases{2}.learn = 1;
tnet.LW{2,1} = cnet.LW{2,1};
tnet.layerWeights{2,1}.learn = 1;
tnet.IW{3,1} = mnet.IW{1,1}(:,1:2);
tnet.inputWeights{3,1}.learn = 0;
tnet.LW{3,2} = mnet.IW{1,1}(:,3);
tnet.layerWeights{3,2}.learn = 0;
tnet.b{3} = mnet.b{1};
tnet.biases{3}.learn = 0;
tnet.LW{4,3} = mnet.LW{2,1};
tnet.layerWeights{4,3}.learn = 0;
tnet.b{4} = mnet.b{2};
tnet.biases{4}.learn = 0;

pause % Strike any key to train the neural controller...


%    TRAINING THE NETWORK
%    ====================

%    We will use TRAIN to train the control network so that
%    a typical error is 0.002 radians (0.11 deg) for the Q
%    2-element target vectors.

tnet.trainParam.show = 5;          % Frequency of progress displays (in epochs).
tnet.trainParam.epochs = 600;      % Maximum number of epochs to train.
tnet.trainParam.goal = (0.002^2);  % Sum-squared error goal.

%    Training begins...please wait...

[tnet,tr] = train(tnet,{Pc(1:2,:);  Pc(3,:)},{Tc});

%    ...and finally finishes.

%    Now we take the trained weights and put them back in the
%    control network.

cnet.IW{1,1}(:,1:2) = tnet.IW{1,1};
cnet.IW{1,1}(:,3) = tnet.IW{1,2};
cnet.b{1} = tnet.b{1};
cnet.b{2} = tnet.b{2}; 
cnet.LW{2,1} = tnet.LW{2,1};

pause % Strike any key to test the neuron model...

appcs2b
