function [perf,E,Ac,N,BZ,IWZ,LWZ]=calcperf(net,X,PD,T,Ai,Q,TS)
%CALCPERF Calculate network outputs, signals, and performance.
%
%  Synopsis
%
%    [perf,El,Ac,N,BZ,IWZ,LWZ]=calcperf(net,X,Pd,Tl,Ai,Q,TS)
%
%  Description
%
%    This function calculates the outputs of each layer in
%    response to a networks delayed inputs and initial layer
%    delay conditions.
%
%    [perf,El,Ac,N,LWZ,IWZ,BZ] = CALCPERF(NET,X,Pd,Tl,Ai,Q,TS) takes,
%      NET - Neural network.
%      X   - Network weight and bias values in a single vector.
%      Pd  - Delayed inputs.
%      Tl  - Layer targets.
%      Ai  - Initial layer delay conditions.
%      Q   - Concurrent size.
%      TS  - Time steps.
%    and returns,
%      perf - Network performance.
%      El   - Layer errors.
%      Ac   - Combined layer outputs = [Ai, calculated layer outputs].
%      N    - Net inputs.
%      LWZ  - Weighted layer outputs.
%      IWZ  - Weighted inputs.
%      BZ   - Concurrent biases.
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
%    two neurons are defined.
%
%      Ai = {[0.5; 0.1] [0.6; 0.5]};
%
%    Here we define the layer targets for the two neurons for
%    each of the five time steps.
%    
%      Tl = {[0.1;0.2] [0.3;0.1], [0.5;0.6] [0.8;0.9], [0.5;0.1]};
%
%    Here the network's weight and bias values are extracted.
%
%      X = getx(net);
%
%    Here we calculate the network's combined outputs Ac, and other
%    signals described above..
%
%      [perf,El,Ac,N,BZ,IWZ,LWZ] = calcperf(net,X,Pd,Tl,Ai,1,5)

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:17:39 $

% CALCA: [Ac,N,LWZ,IWZ,BZ] = calca(net,PD,Ai,Q,TS)
%=================================================

% Concurrent biases
BZ = cell(net.numLayers,1);
ones1xQ = ones(1,Q);
for i=net.hint.biasConnectTo
  BZ{i} = net.b{i}(:,ones1xQ);
end

% Signals
IWZ = cell(net.numLayers,net.numInputs,TS);
LWZ = cell(net.numLayers,net.numLayers,TS);
Ac = [Ai cell(net.numLayers,TS)];
N = cell(net.numLayers,TS);

% Shortcuts
numLayerDelays = net.numLayerDelays;
inputConnectFrom = net.hint.inputConnectFrom;
layerConnectFrom = net.hint.layerConnectFrom;
biasConnectFrom = net.hint.biasConnectFrom;
inputWeightFcn = net.hint.inputWeightFcn;
layerWeightFcn = net.hint.layerWeightFcn;
netInputFcn = net.hint.netInputFcn;
transferFcn = net.hint.transferFcn;
layerDelays = net.hint.layerDelays;
IW = net.IW;
LW = net.LW;

% Simulation
for ts=1:TS
  for i=net.hint.simLayerOrder
  
    ts2 = numLayerDelays + ts;
  
    % Input Weights -> Weighed Inputs
  inputInds = inputConnectFrom{i};
    for j=inputInds
    switch inputWeightFcn{i,j}
    case 'dotprod'
      IWZ{i,j,ts} = IW{i,j} * PD{i,j,ts};
    otherwise
        IWZ{i,j,ts} = feval(inputWeightFcn{i,j},IW{i,j},PD{i,j,ts});
    end
    end
    
    % Layer Weights -> Weighted Layer Outputs
  layerInds = layerConnectFrom{i};
    for j=layerInds
    thisLayerDelays = layerDelays{i,j};
    if (length(thisLayerDelays) == 1) & (thisLayerDelays == 0)
      Ad = Ac{j,ts2};
    else
      Ad = cell2mat(Ac(j,ts2-layerDelays{i,j})');
    end
    switch layerWeightFcn{i,j}
    case 'dotprod'
        LWZ{i,j,ts} = LW{i,j} * Ad;
    otherwise
        LWZ{i,j,ts} = feval(layerWeightFcn{i,j},LW{i,j},Ad);
    end
    end
  
    % Net Input Function -> Net Input
  if net.biasConnect(i)
      Z = [IWZ(i,inputInds,ts) LWZ(i,layerInds,ts) BZ(i)];
  else
      Z = [IWZ(i,inputInds,ts) LWZ(i,layerInds,ts)];
  end
  switch netInputFcn{i}
  case 'netsum'
      N{i,ts} = Z{1};
      for k=2:length(Z)
        N{i,ts} = N{i,ts} + Z{k};
      end
  case 'netprod'
      N{i,ts} = Z{1};
      for k=2:length(Z)
        N{i,ts} = N{i,ts} .* Z{k};
      end
  otherwise
      N{i,ts} = feval(netInputFcn{i},Z{:});
    end
  
    % Transfer Function -> Layer Output
  switch transferFcn{i}
  case 'purelin'
    Ac{i,ts2} = N{i,ts};
  case 'tansig'
    n = N{i,ts};
    a = 2 ./ (1 + exp(-2*n)) - 1;
      k = find(~finite(a));
      a(k) = sign(n(k));
      Ac{i,ts2} = a;
  case 'logsig'
      n = N{i,ts};
      a = 1 ./ (1 + exp(-n));
      k = find(~finite(a));
      a(k) = sign(n(k));
    Ac{i,ts2} = a;
  otherwise
      Ac{i,ts2} = feval(transferFcn{i},N{i,ts});
  end
  end
end

% CALCE: E = calce(net,Ac,T,TS);
%===============================

E = cell(net.numLayers,TS);

for ts = 1:TS
  for i=net.hint.targetInd
    E{i,ts} = T{i,ts} - Ac{i,ts+numLayerDelays};
  end
end

% Performance
%============

performFcn = net.performFcn;
if length(performFcn) ==0
  performFcn = 'nullpf';
end
perf = feval(performFcn,E,X,net.performParam);
