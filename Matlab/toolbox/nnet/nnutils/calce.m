function E=calce(net,Ac,T,TS)
%CALCE Calculate layer errors.
%
%  Synopsis
%
%    El = calce(net,Ac,Tl,TS)
%
%  Description
%
%    This function calculates the errors of each layer in
%    response to layer outputs and targets.
%
%    El = CALCE(NET,Ac,Tl,TS) takes,
%      NET - Neural network.
%      Ac  - Combined layer outputs.
%      Tl  - Layer targets.
%      Q   - Concurrent size.
%    and returns,
%      El  - Layer errors.
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
%    each of the five time steps, and calculate the layer errors.
%    
%      Tl = {[0.1;0.2] [0.3;0.1], [0.5;0.6] [0.8;0.9], [0.5;0.1]};
%      El = calce(net,Ac,Tl,5)
%
%    Here we view the network's error for layer 1 at timestep 2.
%
%      El{1,2}

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 21:17:27 $

E = cell(net.numLayers,TS);
delays = net.numLayerDelays;

for ts = 1:TS
  for i=net.hint.targetInd;
    E{i,ts} = T{i,ts} - Ac{i,ts+delays};
  end
end
