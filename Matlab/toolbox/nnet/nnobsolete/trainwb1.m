function [net,tr,Ac,E]=trainwb1(net,Pd,Tl,Ai,Q,TS,VV,TV)
%TRAINWB1 By-weight-&-bias 1-vector-at-a-time training function.
%  
%  This function is obselete.
%  Use TRAINR to train your network.

nntobsf('trainwb1','Use TRAINR to train your network.')

%  Syntax
%  
%    [net,tr] = trainwb1(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = trainwb1(code)
%
%  Description
%
%    TRAINWB1 is a network training function which updates each weight
%    and bias according to its learning function.  Each epoch, TRAINWB1
%    randomly chooses just one input vector (or sequence) to present
%    to the network.
%
%    TRAINWB1(NET,Pd,Tl,Ai,Q,TS,VV,TV) takes these inputs,
%      NET - Neural network.
%      Pd  - Delayed inputs.
%      Tl  - Layer targets.
%      Ai  - Initial input conditions.
%      Q   - Batch size.
%      TS  - Time steps.
%      VV  - Ignored.
%      TV  - Ignored.
%    and returns,
%      NET - Trained network.
%      TR  - Training record of various values over each epoch:
%            TR.epoch - Epoch number.
%            TR.perf  - Training performance.
%            TR.index - Index of presented input vector (or sequence).
%
%    Training occurs according to the TRAINWB's training parameters
%    shown here with their default values:
%      net.trainParam.epochs  100  Maximum number of epochs to train
%      net.trainParam.show     25  Epochs between showing progress
%      net.trainParam.time    inf  Maximum time to train in seconds
%
%    Dimensions for these variables are:
%      Pd - NoxNixTS cell array, each element Pd{i,j,ts} is a DijxQ matrix.
%      Tl - NlxTS cell array, each element P{i,ts} is a VixQ matrix or [].
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%    Where
%      Ni = net.numInputs
%    Nl = net.numLayers
%    LD = net.numLayerDelays
%      Ri = net.inputs{i}.size
%      Si = net.layers{i}.size
%      Vi = net.targets{i}.size
%      Dij = Ri * length(net.inputWeights{i,j}.delays)
%
%    TRAINWB1 does not implement validation or test vectors, so arguments
%    VV and TV are ignored.
%
%    TRAINWB1(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINWB1 by calling
%    NEWC or NEWSOM.
%
%    To prepare a custom network to be trained with TRAINWB1:
%    1) Set NET.trainFcn to 'trainwb1'.
%       (This will set NET.trainParam to TRAINWB1's default parameters.)
%    2) Set each NET.inputWeights{i,j}.learnFcn to a learning function.
%       Set each NET.layerWeights{i,j}.learnFcn to a learning function.
%       Set each NET.biases{i}.learnFcn to a learning function.
%       (Weight and bias learning parameters will automatically be
%       set to default values for the given learning function.)
%
%    To train the network:
%    1) Set NET.trainParam properties to desired values.
%    2) Set weight and bias learning parameters to desired values.
%    3) Call TRAIN.
%
%    See NEWC and NEWSOM for training examples.
%
%  Algorithm
%
%    For each epoch, a vector (or sequence) is chosen randomly and
%    presented to the network and weight and bias values are
%    updated accordingly.
%
%    Training stops when any of these conditions are met:
%    1) The maximum number of EPOCHS (repetitions) is reached.
%    2) The maximum amount of TIME has been exceeded.
%
%  See also NEWP, NEWLIN, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
    net = {'epochs','show','time'};
    case 'pdefaults',
    trainParam.epochs = 100;
    trainParam.show = 25;
    trainParam.time = inf;
    net = trainParam;
    otherwise,
    error('Unrecognized code.')
  end
  return
end

% CALCULATION
% ===========

% Constants
this = 'TRAINWB1';
numLayers = net.numLayers;
numInputs = net.numInputs;
epochs = net.trainParam.epochs;
show = net.trainParam.show;
time = net.trainParam.time;
numLayerDelays = net.numLayerDelays;
needGradient = net.hint.needGradient;
performFcn = net.performFcn;
if length(performFcn) == 0
  performFcn = 'nullpf';
end
dPerformFcn = feval(performFcn,'deriv');
if (~isempty(VV))
  fprintf('Warning - %s does not support validation vectors.\n',this);
end
if (~isempty(TV))
  fprintf('Warning - %s does not support test vectors.\n',this);
end

% Divide up batches
Pd_div = batchdiv(Pd,Q);
Tl_div = batchdiv(Tl,Q);
Ai_div = batchdiv(Ai,Q);

% Signals
BP = 1;
gIW = cell(numLayers,numInputs,TS);
gLW = cell(numLayers,numLayers,TS);
gB = cell(net.numLayers,1,TS);
gA = cell(net.numLayers,TS);
IWLS = cell(numLayers,numInputs);
LWLS = cell(numLayers,numLayers);
BLS = cell(numLayers,1);

% Initialize
stop = '';
startTime = clock;
tr = newtr(epochs,'perf','index');

% Train
for epoch=0:epochs

  % Choose one from batch
  q = fix(rand*Q)+1;
  Pd = Pd_div{q};
  Tl = Tl_div{q};
  Ai = Ai_div{q};

  % Performance
  [Ac,N,Zl,Zi,Zb] = calca(net,Pd,Ai,1,TS);
  E = calce(net,Ac,Tl,TS);
  X = getx(net);
  perf = feval(performFcn,E,X,net.performParam);

  % Training Record
  epochPlus1 = epoch+1;
  tr.perf(epochPlus1) = perf;
  tr.index(epochPlus1) = q;

  % Stopping Criteria
  currentTime = etime(clock,startTime);
  if (epoch == epochs)
    stop = 'Maximum epoch reached.';
  elseif (currentTime > time)
    stop = 'Maximum time elapsed.';
  end
  
  % Progress
  if ~rem(epoch,show) | length(stop)
    fprintf(this);
  if isfinite(epochs) fprintf(', Epoch %g/%g',epoch, epochs); end
  if isfinite(time) fprintf(', Time %g%%',currentTime/time/100); end
  fprintf('\n')
    if length(stop) fprintf('%s, %s\n\n',this,stop); break; end
  end

  % Gradient
  if (needGradient)
    gE = feval(dPerformFcn,'e',E,net,perf,net.performParam);
    [gB,gIW,gLW,gA] = calcgrad(net,1,Pd,Zb,Zi,Zl,N,Ac,gE,TS);
  end
  
  % Update with Weight and Bias Learning Functions
  for ts=1:TS
    for i=1:numLayers

      % Update Input Weight Values
      for j=find(net.inputConnect(i,:))
        learnFcn = net.inputWeights{i,j}.learnFcn;
        if length(learnFcn)
          [dw,IWLS{i,j}] = feval(learnFcn,net.IW{i,j}, ...
            Pd{i,j,ts},Zi{i,j},N{i},Ac{i,ts+numLayerDelays},Tl{i,ts},E{i,ts},gIW{i,j,ts},...
            gA{i,ts},net.layers{i}.distances,net.inputWeights{i,j}.learnParam,IWLS{i,j});
          net.IW{i,j} = net.IW{i,j} + dw;
        end
      end
  
      % Update Layer Weight Values
      for j=find(net.layerConnect(i,:))
        learnFcn = net.layerWeights{i,j}.learnFcn;
        if length(learnFcn)
          Ad = cell2mat(Ac(j,ts+numLayerDelays-net.layerWeights{i,j}.delays)');
          [dw,LWLS{i,j}] = feval(learnFcn,net.LW{i,j}, ...
            Ad,Zl{i,j},N{i},Ac{i,ts+numLayerDelays},Tl{i,ts},E{i,ts},gLW{i,j,ts},...
            gA{i,ts},net.layers{i}.distances,net.layerWeights{i,j}.learnParam,LWLS{i,j});
          net.LW{i,j} = net.LW{i,j} + dw;
        end
      end

      % Update Bias Values
      if net.biasConnect(i)
        learnFcn = net.biases{i}.learnFcn;
        if length(learnFcn)
          [db,BLS{i}] = feval(learnFcn,net.b{i}, ...
            BP,Zb{i},N{i},Ac{i,ts+numLayerDelays},Tl{i,ts},E{i,ts},gB{i,ts},...
            gA{i,ts},net.layers{i}.distances,net.biases{i}.learnParam,BLS{i});
          net.b{i} = net.b{i} + db;
        end
      end
    end
  end
end

% Finish
tr = cliptr(tr,epoch);

%===============================================================
function b_div = batchdiv(b,Q)

[rows,cols] = size(b);
b_div = cell(1,Q);
for q=1:Q
  b_div{q} = cell(rows,cols);
end

for i=1:rows
  for j=1:cols
  if ~isempty(b{i,j})
    for q=1:Q
      b_div{q}{i,j} = b{i,j}(:,q);
    end
  end
  end
end

%===============================================================

