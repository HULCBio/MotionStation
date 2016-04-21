function E=calce1(net,A,T)
%CALCE1 Calculate layer errors for one time step.
%
%  Synopsis
%
%    El = calce1(net,A,Tl)
%
%  Description
%
%    This function calculates the errors of each layer in
%    response to layer outputs and targets, for a single time step.
%
%    Calculating errors for a single time step is useful for
%    sequential iterative algorithms such as TRAINS which
%    need to calculate the network response for each
%    time step individually.
%
%    El = CALCE1(NET,A,Tl) takes,
%      NET - Neural network.
%      A   - Layer outputs, for a single time step.
%      Tl  - Layer targets, for a single time step.
%    and returns,
%      El  - Layer errors, for a single time step.
%
%  Examples
%
%    Here we create a linear network with a single input element
%    ranging from 0 to 1, two neurons, and a tap delay on the
%    input with taps at 0, 2, and 4 timesteps.  The network is
%    also given a recurrent connection from layer 1 to itself with
%    tap delays of [1 2].
%
%      net = newlin([0 1],2);
%      net.layerConnect(1,1) = 1;
%      net.layerWeights{1,1}.delays = [1 2];
%
%    Here is a single (Q = 1) input sequence P with 5 timesteps (TS = 5),
%    and the 4 initial input delay conditions Pi, combined inputs Pc,
%    and delayed inputs Pd.
%
%      P = {0 0.1 0.3 0.6 0.4};
%      Pi = {0.2 0.3 0.4 0.1};
%      Pc = [Pi P];
%      Pd = calcpd(net,5,1,Pc);
%
%    Here the two initial layer delay conditions for each of the
%    two neurons are defined, and the networks combined outputs Ac
%    and other signals are calculated.
%
%      Ai = {[0.5; 0.1] [0.6; 0.5]};
%      [Ac,N,LWZ,IWZ,BZ] = calca(net,Pd,Ai,1,5);
%
%    Here we define the layer targets for the two neurons for
%    each of the five time steps, and calculate the layer errors
%    using the first time step layer output Ac(:,5) (The five
%    is found by adding the number of layer delays, 2, to the
%    time step 1.), and the first time step targets Tl(:,1).
%    
%      Tl = {[0.1;0.2] [0.3;0.1], [0.5;0.6] [0.8;0.9], [0.5;0.1]};
%      El = calce1(net,Ac(:,3),Tl(:,1))
%
%    Here we view the network's error for layer 1.
%
%      El{1}

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 21:17:30 $

E = cell(net.numLayers,1);

for i=net.hint.targetInd;
  E{i} = T{i} - A{i};
end
