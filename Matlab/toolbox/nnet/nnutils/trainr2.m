function [net,tr,Ac,El]=trainr(net,Pd,Tl,Ai,Q,TS,VV,TV)
%TRAINR Random order incremental training w/learning functions.
%
%  Syntax
%  
%    [net,tr,Ac,El] = trainr(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = trainr(code)
%
%  Description
%
%    TRAINR is not called directly.  Instead it is called by TRAIN for
%    network's whose NET.trainFcn property is set to 'trainr'.
%
%    TRAINR trains a network with weight and bias learning rules with
%    incremental updates after each presentation of an input.  Inputs
%    are presented in random order.
%
%    TRAINR(NET,Pd,Tl,Ai,Q,TS,VV) takes these inputs,
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
%      Ac  - Collective layer outputs.
%      El  - Layer errors.
%
%    Training occurs according to the TRAINR's training parameters
%    shown here with their default values:
%      net.trainParam.epochs  100  Maximum number of epochs to train
%      net.trainParam.goal      0  Performance goal
%      net.trainParam.show     25  Epochs between displays (NaN for no displays)
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
%    TRAINR does not implement validation or test vectors, so arguments
%    VV and TV are ignored.
%
%    TRAINR(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINR by calling
%    NEWC or NEWSOM.
%
%    To prepare a custom network to be trained with TRAINR:
%    1) Set NET.trainFcn to 'trainr'.
%       (This will set NET.trainParam to TRAINR's default parameters.)
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
%    For each epoch, all training vectors (or sequences) are each
%    presented once in a different random order with the network and
%    weight and bias values updated accordingly after each individual
%    presentation.
%
%    Training stops when any of these conditions are met:
%    1) The maximum number of EPOCHS (repetitions) is reached.
%    2) Performance has been minimized to the GOAL.
%    3) The maximum amount of TIME has been exceeded.
%
%  See also NEWP, NEWLIN, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $  $Date: 2002/04/14 21:19:03 $

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
    net = {'epochs','goal','show','time'};
    case 'pdefaults',
    trainParam.epochs = 100;
    trainParam.goal = 0;
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

% Parameters
epochs = net.trainParam.epochs;
goal = net.trainParam.goal;
show = net.trainParam.show;
time = net.trainParam.time;

% Parameter Checking
if (~isa(epochs,'double')) | (~isreal(epochs)) | (any(size(epochs)) ~= 1) | ...
  (epochs < 1) | (round(epochs) ~= epochs)
  error('Epochs is not a positive integer.')
end
if (~isa(goal,'double')) | (~isreal(goal)) | (any(size(goal)) ~= 1) | ...
  (goal < 0)
  error('Goal is not zero or a positive real value.')
end
if (~isa(show,'double')) | (~isreal(show)) | (any(size(show)) ~= 1) | ...
  (isfinite(show) & ((show < 1) | (round(show) ~= show)))
  error('Show is not ''NaN'' or a positive integer.')
end
if (~isa(time,'double')) | (~isreal(time)) | (any(size(time)) ~= 1) | ...
  (time < 0)
  error('Time is not zero or a positive real value.')
end

% Constants
this = 'TRAINR';
numLayers = net.numLayers;
numInputs = net.numInputs;
numLayerDelays = net.numLayerDelays;
needGradient = net.hint.needGradient;
performFcn = net.performFcn;
if length(performFcn) == 0
  performFcn = 'nullpf';
end
performParam = net.performParam;
dPerformFcn = feval(performFcn,'deriv');
doValidation = ~isempty(VV);
doTest = ~isempty(TV);

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
flag_stop=0;
stop = '';
startTime = clock;
tr = newtr(epochs,'perf','vperf','tperf');
X = getx(net);
[perf,El,Ac] = calcperf(net,X,Pd,Tl,Ai,Q,TS);

% Train
for epoch=0:epochs

  % Training Record
  epochPlus1 = epoch+1;
  tr.perf(epochPlus1) = perf;
  if (doValidation)
    tr.vperf(epochPlus1) = calcperf(net,X,VV.Pd,VV.Tl,VV.Ai,VV.Q,VV.TS);
  end
  if (doTest)
    tr.tperf(epochPlus1) = calcperf(net,X,TV.Pd,TV.Tl,TV.Ai,TV.Q,TV.TS);
  end

  % Stopping Criteria
  currentTime = etime(clock,startTime);
  if (epoch == epochs)
    stop = 'Maximum epoch reached.';
  elseif (perf <= goal)
    stop = 'Performance goal met.';
  elseif (currentTime > time)
    stop = 'Maximum time elapsed.';
  elseif flag_stop
    stop = 'User stop.';
  end
  
  % Progress
  if isfinite(show) & (~rem(epoch,show) | length(stop))
    fprintf(this);
  if isfinite(epochs) fprintf(', Epoch %g/%g',epoch, epochs); end
  if isfinite(time) fprintf(', Time %g%%',currentTime/time/100); end
  fprintf('\n')
    flag_stop=plotperf(tr,goal,this,epoch);
    if length(stop) fprintf('%s, %s\n\n',this,stop); end
  end
 if length(stop), break; end

  % Each vector (or sequence of vectors) in random order
  for q=randperm(Q)

    % Choose one from batch
    q = fix(rand*Q)+1;
    Pd = Pd_div{q};
    Tl = Tl_div{q};
    Ai = Ai_div{q};

    % Performance
    [Ac,N,Zl,Zi,Zb] = calca(net,Pd,Ai,1,TS);
    Elq = calce(net,Ac,Tl,TS);
    X = getx(net);
    perf = feval(performFcn,Elq,X,net.performParam);

    % Gradient
    if (needGradient)
      gE = feval(dPerformFcn,'e',Elq,net,perf,net.performParam);
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
              Pd{i,j,ts},Zi{i,j},N{i},Ac{i,ts+numLayerDelays},Tl{i,ts},Elq{i,ts},gIW{i,j,ts},...
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
              Ad,Zl{i,j},N{i},Ac{i,ts+numLayerDelays},Tl{i,ts},Elq{i,ts},gLW{i,j,ts},...
              gA{i,ts},net.layers{i}.distances,net.layerWeights{i,j}.learnParam,LWLS{i,j});
            net.LW{i,j} = net.LW{i,j} + dw;
          end
        end

        % Update Bias Values
        if net.biasConnect(i)
          learnFcn = net.biases{i}.learnFcn;
          if length(learnFcn)
            [db,BLS{i}] = feval(learnFcn,net.b{i}, ...
              BP,Zb{i},N{i},Ac{i,ts+numLayerDelays},Tl{i,ts},Elq{i,ts},gB{i,ts},...
              gA{i,ts},net.layers{i}.distances,net.biases{i}.learnParam,BLS{i});
            net.b{i} = net.b{i} + db;
          end
        end
      end
    end
  
  % Collect errors
  El = batchinsert(El,Elq,q);
  perf = feval(performFcn,El,X,performParam);
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
function b = batchinsert(b,bq,q)

[rows,cols] = size(bq);

for i=1:rows
  for j=1:cols
    if ~isempty(b{i,j})
      b{i,j}(:,q) = bq{i,j};
    end
  end
end

%===============================================================

