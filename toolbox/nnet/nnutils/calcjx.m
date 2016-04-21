function jx=calcjx(net,PD,BZ,IWZ,LWZ,N,Ac,Q,TS)
%CALCJX Calculate weight and bias performance Jacobian as a single matrix.
%
%  Syntax
%
%    jx = calcjx(net,PD,BZ,IWZ,LWZ,N,Ac,Q,TS)
%
%  Description
%
%    This function calculates the Jacobian of a network's errors
%    with respect to its vector of weight and bias values X.
%
%    jX = CALCJX(NET,PD,BZ,IWZ,LWZ,N,Ac,Q,TS) takes,
%      NET    - Neural network.
%      PD     - Delayed inputs.
%      BZ     - Concurrent biases.
%      IWZ    - Weighted inputs.
%      LWZ    - Weighted layer outputs.
%      N      - Net inputs.
%      Ac     - Combined layer outputs.
%      Q      - Concurrent size.
%      TS     - Time steps.
%    and returns,
%      jX     - Jacobian of network errors with respect to X.
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
%    two neurons, and the layer targets for the two neurons over
%    five timesteps are defined.
%
%      Ai = {[0.5; 0.1] [0.6; 0.5]};
%      Tl = {[0.1;0.2] [0.3;0.1], [0.5;0.6] [0.8;0.9], [0.5;0.1]};
%
%    Here the network's weight and bias values are extracted, and
%    the network's performance and other signals are calculated.
%
%      [perf,El,Ac,N,BZ,IWZ,LWZ] = calcperf(net,X,Pd,Tl,Ai,1,5);
%
%    Finally we can use CALCJX to calculate the Jacobian.
%
%      jX = calcjx(net,Pd,BZ,IWZ,LWZ,N,Ac,1,5);
%
%  See also CALCGX, CALCJEJJ.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:17:57 $

% Shortcuts
numLayerDelays = net.numLayerDelays;
TF = net.hint.transferFcn;
dTF = net.hint.dTransferFcn;
NF = net.hint.netInputFcn;
dNF = net.hint.dNetInputFcn;
IWF = net.hint.inputWeightFcn;
dIWF = net.hint.dInputWeightFcn;
LWF = net.hint.layerWeightFcn;
dLWF = net.hint.dLayerWeightFcn;
ICF = net.hint.inputConnectFrom;
LCF = net.hint.layerConnectFrom;
LCT = net.hint.layerConnectTo;

% CALCULATE ERROR SIZE
S = net.hint.totalTargetSize;
QS = Q*S;

% CALCULATE ERROR CONNECTIONS
QNegEyes =  repcol(-eye(S),Q);
gE = cell(net.numLayers,1);
pos = 0;
for i=net.hint.targetInd
  siz = net.layers{i}.size;
  gE{i} = QNegEyes(pos+[1:siz],:);
  pos = pos + siz;
end

% EXPAND SIGNALS
ind = floor([0:(QS-1)]/S)+1;
for i=find(net.biasConnect)'
  BZ{i} = BZ{i}(:,ind);
end
for ts=1:TS
  for i=1:net.numLayers
    for j=find(net.inputConnect(i,:))
      PD{i,j,ts} = PD{i,j,ts}(:,ind);
      IWZ{i,j,ts} = IWZ{i,j,ts}(:,ind);
    end
  end
  for i=1:net.numLayers
    for j=find(net.layerConnect(i,:))
      LWZ{i,j,ts} = LWZ{i,j,ts}(:,ind);
    end
  end
  for i=1:net.numLayers
    N{i,ts} = N{i,ts}(:,ind);
  end
end
for ts=1:TS+numLayerDelays;
  for i=1:net.numLayers
    Ac{i,ts} = Ac{i,ts}(:,ind);
  end
end

Q = QS;

% Signals
gA = cell(net.numLayers,TS);
gN = cell(net.numLayers,TS);
gBZ = cell(net.numLayers,TS);
gIWZ = cell(net.numLayers,net.numInputs,TS);
gLWZ = cell(net.numLayers,net.numLayers,TS);
gB = gBZ;
gIW = gIWZ;
gLW = gIWZ;

% Backpropagate Derivatives...
for ts=TS:-1:1
  for i=net.hint.bpLayerOrder

    % ...from Performance
    if net.targetConnect(i)
      gA{i,ts} = gE{i};       %%% NO TS REQUIRED
    else
      gA{i,ts} = zeros(net.layers{i}.size,Q);
    end
  
    % ...through Layer Weights
    for k=LCT{i}
      if (any(net.layerWeights{k,i}.delays == 0)) % only zero delay paths
    ZeroDelayW = net.LW{k,i}(:,1:net.layers{i}.size);
      gA{i,ts} = gA{i,ts} + ...
        feval(dLWF{k,i},'p',ZeroDelayW,Ac{i,ts+numLayerDelays},LWZ{k,i,ts})' * ...
          gLWZ{k,i,ts};
      end
    end
  
    % ...through Transfer Functions
    gN{i,ts} = feval(dTF{i},N{i,ts},Ac{i,ts+numLayerDelays}) .* gA{i,ts};
  
    % ...to Bias
  if net.biasConnect(i)
      gBZ{i,ts} = feval(dNF{i},BZ{i},N{i,ts}) .* gN{i,ts};
  end

    % ...to Input Weights
    for j=ICF{i}
      gIWZ{i,j,ts} = feval(dNF{i},IWZ{i,j,ts},N{i,ts}) .* gN{i,ts};
    end
  
    % ...to Layer Weights
    for j=LCF{i}
      gLWZ{i,j,ts} = feval(dNF{i},LWZ{i,j,ts},N{i,ts}) .* gN{i,ts};
    end
  end
end

% Shortcuts
inputWeightCols = net.hint.inputWeightCols;
layerWeightCols = net.hint.layerWeightCols;

% Bias and Weight Gradients
for ts=1:TS
  for i=1:net.numLayers
    gB{i,ts} = gBZ{i,ts};
    for j=ICF{i}
      sW = feval(dIWF{i,j},'w',net.IW{i,j},PD{i,j,ts},IWZ{i,j,ts});
      gIW{i,j,ts} = reprow(gIWZ{i,j,ts},inputWeightCols(i,j)) .* ...
      reprowint(sW,net.layers{i}.size);
    end
    for j=LCF{i}
    Ad = cell2mat(Ac(j,ts+numLayerDelays-net.layerWeights{i,j}.delays)');
      sW = feval(dLWF{i,j},'w',net.LW{i,j},Ad,LWZ{i,j,ts});
      gLW{i,j,ts} = reprow(gLWZ{i,j,ts},layerWeightCols(i,j)) .* ...
      reprowint(sW,net.layers{i}.size);
    end
  end
end

% Shortcuts
inputLearn = net.hint.inputLearn;
layerLearn = net.hint.layerLearn;
biasLearn = net.hint.biasLearn;
inputWeightInd = net.hint.inputWeightInd;
layerWeightInd = net.hint.layerWeightInd;
biasInd = net.hint.biasInd;

% gB{}, gIW{}, gLW{} -> jX()
jx = zeros(net.hint.xLen,QS*TS);
for i=1:net.numLayers
  for j=find(inputLearn(i,:))
    jx(inputWeightInd{i,j},:) = [gIW{i,j,:}];
  end
  for j=find(layerLearn(i,:))
    jx(layerWeightInd{i,j},:) = [gLW{i,j,:}];
  end
  if biasLearn(i)
    jx(biasInd{i},:) = [gB{i,:}];
  end
end

% ===========================================================
function m = repcol(m,n)
% REPLICATE COLUMNS OF Ac MATRIX

mcols = size(m,2);
m = m(:,rem(0:(mcols*n-1),mcols)+1);

% ===========================================================
function m = repcolint(m,n)
% REPLICATE COLUMNS OF MATRIX WITH ELEMENTS INTERLEAVED

mcols = size(m,2);
m = m(:,floor([0:(mcols*n-1)]/n)+1);

% ===========================================================
function m = reprow(m,n)
% REPLICATE ROWS OF Ac MATRIX

mrows = size(m,1);
m = m(rem(0:(mrows*n-1),mrows)+1,:);

% ===========================================================
function m = reprowint(m,n)
% REPLICATE ROWS OF MATRIX WITH ELEMENTS INTERLEAVED

mrows = size(m,1);
m = m(floor([0:(mrows*n-1)]/n)+1,:);

% ===========================================================

