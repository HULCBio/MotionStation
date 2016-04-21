function [perf,E,Ac,N,BZ,IWZ,LWZ]=calcperf2(net,X,PD,T,Ai,Q,TS)
%CALCPERF2 Calculate network outputs, signals, and performance for the
%  NN model Reference Adaptive Controller.
%
%  Synopsis
%
%    [perf,El,Ac,N,BZ,IWZ,LWZ]=calcperf2(net,X,Pd,Tl,Ai,Q,TS)
%
%  Description
%
%    This function calculates the outputs of each layer in
%    response to a networks delayed inputs and initial layer
%    delay conditions.
%
%    [perf,E,Ac,N,LWZ,IWZ,BZ] = CALCPERF(NET,X,Pd,Tl,Ai,Q,TS) takes,
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
%    This function only works with the four-layer NN defined for
%    the NN model Reference Adaptive Controller.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Orlando De Jesus, Martin Hagan, Change for NN model Reference Adaptive Controller, 7-7-99
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:10:46 $

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

E = cell(net.numLayers,TS);

% Simulation
for ts=1:TS
%  for i=net.hint.simLayerOrder
  
  ts2 = numLayerDelays + ts;
  
  % First layer.
  n = IW{1,1}*PD{1,1,ts}+LW{1,2}*cell2mat(Ac(2,ts2-layerDelays{1,2})') ...
     +LW{1,4}*cell2mat(Ac(4,ts2-layerDelays{1,4})')+BZ{1};
  % Tansig.
  a = 2 ./ (1 + exp(-2*n)) - 1;
  k = find(~finite(a));
  a(k) = sign(n(k));
  Ac{1,ts2} = a;
      
  % Second layer.
  Ac{2,ts2} = LW{2,1}*Ac{1,ts2} + BZ{2};
      
  % Third layer.
  n = LW{3,2}*cell2mat(Ac(2,ts2-layerDelays{3,2})') ...
     +LW{3,4}*cell2mat(Ac(4,ts2-layerDelays{3,4})')+BZ{3};
  % Tansig.
  a = 2 ./ (1 + exp(-2*n)) - 1;
  k = find(~finite(a));
  a(k) = sign(n(k));
  Ac{3,ts2} = a;
      
  % Fourth layer.
  Ac{4,ts2} = LW{4,3}*Ac{3,ts2} + BZ{4};
      
  E{4,ts} = T{4,ts} - Ac{4,ts2};       
  
end

% Performance
%============

performFcn = net.performFcn;
if length(performFcn) ==0
  performFcn = 'nullpf';
end
perf = feval(performFcn,E,X,net.performParam);
