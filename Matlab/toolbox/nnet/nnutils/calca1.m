function [A,N,LWZ,IWZ,BZ]=calca1(net,PD,Ai,Q)
%CALCA1 Calculate network signals for one time step.
%
%  Syntax
%
%    [A,N,LWZ,IWZ,BZ] = CALCA1(NET,PD,Ai,Q)
%
%  Description
%
%    This function calculates the outputs of each layer in
%    response to a networks delayed inputs and initial layer
%    delay conditions, for a single time step.
%
%    Calculating outputs for a single time step is useful for
%    sequential iterative algorithms such as TRAINS which
%    which need to calculate the network response for each
%    time step individually.
%
%    [Ac,N,LWZ,IWZ,BZ] = CALCA1(NET,Pd,Ai,Q) takes,
%      NET - Neural network.
%      Pd  - Delayed inputs for a single timestep.
%      Ai  - Initial layer delay conditions for a single timestep.
%      Q   - Concurrent size.
%    and returns,
%      A   - Layer outputs for the timestep.
%      N   - Net inputs for the timestep.
%      LWZ - Weighted layer outputs for the timestep.
%      IWZ - Weighted inputs for the timestep.
%      BZ  - Concurrent biases for the timestep.
%
%  Examples
%
%    Here we create a linear network with a single input element
%    ranging from 0 to 1, three neurons, and a tap delay on the
%    input with taps at 0, 2, and 4 timesteps.  The network is
%    also given a recurrent connection from layer 1 to itself with
%    tap delays of [1 2].
%
%      net = newlin([0 1],3,[0 2 4]);
%      net.layerConnect(1,1) = 1;
%      net.layerWeights{1,1}.delays = [1 2];
%
%    Here is a single (Q = 1) input sequence P with 8 timesteps (TS = 8),
%    and the 4 initial input delay conditions Pi, combined inputs Pc,
%    and delayed inputs Pd.
%
%      P = {0 0.1 0.3 0.6 0.4 0.7 0.2 0.1};
%      Pi = {0.2 0.3 0.4 0.1};
%      Pc = [Pi P];
%      Pd = calcpd(net,8,1,Pc)
%
%    Here the two initial layer delay conditions for each of the
%    three neurons are defined:
%
%      Ai = {[0.5; 0.1; 0.2] [0.6; 0.5; 0.2]};
%
%    Here we calculate the network's combined outputs Ac, and other
%    signals described above, for timestep 1.
%
%      [A,N,LWZ,IWZ,BZ] = calca1(net,Pd(:,:,1),Ai,1)
%
%    We can calculate the new layer delay states from Ai and A,
%    then calculate the signals for timestep 2.
%
%      Ai2 = [Ai(:,2:end) A];
%      [A2,N,LWZ,IWZ,BZ] = calca1(net,Pd(:,:,2),Ai2,1)

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 21:17:24 $

% Concurrent biases
BZ = cell(net.numLayers,1);
ones1xQ = ones(1,Q);
for i=net.hint.biasConnectTo
  BZ{i} = net.b{i}(:,ones1xQ);
end

% Signals
IWZ = cell(net.numLayers,net.numInputs);
LWZ = cell(net.numLayers,net.numLayers);
N = cell(net.numLayers,1);
Ac = [Ai cell(net.numLayers,1)];

% Simulation
ts2 = net.numLayerDelays + 1;
for i=net.hint.simLayerOrder
  
  layer = net.layers{i};
  
  % Input Weights -> Weighed Inputs
  inputInds = find(net.inputConnect(i,:));
  for j=inputInds
    IWZ{i,j} = feval(net.inputWeights{i,j}.weightFcn,net.IW{i,j},PD{i,j});
  end
    
  % Layer Weights -> Weighted Layer Outputs
  layerInds = find(net.layerConnect(i,:));
  for j=layerInds
  Ad = cell2mat(Ac(j,ts2-net.layerWeights{i,j}.delays)');
    LWZ{i,j} = feval(net.layerWeights{i,j}.weightFcn,net.LW{i,j},Ad);
  end
  
  % Net Input Function -> Net Input
  biasInds = find(net.biasConnect(i));
  Z = [IWZ(i,inputInds) LWZ(i,layerInds) BZ(i,biasInds)];
  N{i} = feval(layer.netInputFcn,Z{:});
  
  % Transfer Function -> Layer Output
  Ac{i,ts2} = feval(layer.transferFcn,N{i});
end

% Convert Ac to A
A = Ac(:,ts2);
