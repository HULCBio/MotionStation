function [net,tr,Ac,E]=trainwb(net,Pd,Tl,Ai,Q,TS,VV,TV)
%TRAINWB By-weight-and-bias network training function.
%  
%  This function is obselete.
%  Use TRAINB to train your network.

nntobsf('trainwb','Use TRAINB to train your network.')

%  Syntax
%  
%    [net,tr] = trainwb(net,Pd,Tl,Ai,Q,TS,VV)
%    info = trainwb(code)
%
%  Description
%
%    TRAINWB is a network training function which updates each
%    weight and bias according to its learning function.
%
%    TRAINWB(NET,Pd,Tl,Ai,Q,TS,VV,TV) takes these inputs,
%      NET - Neural network.
%      Pd  - Delayed inputs.
%      Tl  - Layer targets.
%      Ai  - Initial input conditions.
%      Q   - Batch size.
%      TS  - Time steps.
%      VV  - Either empty matrix [] or structure of validation vectors.
%    and returns,
%      NET - Trained network.
%      TR  - Training record of various values over each epoch:
%            TR.epoch - Epoch number.
%            TR.perf  - Training performance.
%            TR.vperf - Validation performance.
%            TR.tperf - Test performance.
%
%    Training occurs according to the TRAINWB's training parameters,
%    shown here with their default values:
%      net.trainParam.epochs  100  Maximum number of epochs to train
%      net.trainParam.goal      0  Performance goal
%      net.trainParam.max_fail  5  Maximum validation failures
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
%    If VV is not [], it must be a structure of validation vectors,
%      VV.Pd - Validation delayed inputs.
%      VV.Tl - Validation layer targets.
%      VV.Ai - Validation initial input conditions.
%      VV.Q  - Validation batch size.
%      VV.TS - Validation time steps.
%    which is used to stop training early if the network performance
%    on the validation vectors fails to improve or remains the same
%    for MAX_FAIL epochs in a row.
%
%    TRAINWB(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINWB by calling
%    NEWP or NEWLIN.
%
%    To prepare a custom network to be trained with TRAINWB:
%    1) Set NET.trainFcn to 'trainwb'.
%       (This will set NET.trainParam to TRAINWB's default parameters.)
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
%    See NEWP and NEWLIN for training examples.
%
%  Algorithm
%
%    Each weight and bias updates according to its learning function
%    after each epoch (one pass through the entire set of input vectors).
%
%    Training stops when any of these conditions are met:
%    1) The maximum number of EPOCHS (repetitions) is reached.
%    2) Performance has been minimized to the GOAL.
%    3) The maximum amount of TIME has been exceeded.
%    4) Validation performance has increase more than MAX_FAIL times
%       since the last time it decreased (when using validation).
%
%  See also NEWP, NEWLIN, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
    net = {'epochs','goal','max_fail','show','time'};
    case 'pdefaults',
    trainParam.epochs = 100;
    trainParam.goal = 0;
    trainParam.max_fail = 5;
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
this = 'TRAINWB';
numLayers = net.numLayers;
numInputs = net.numInputs;
epochs = net.trainParam.epochs;
goal = net.trainParam.goal;
max_fail = net.trainParam.max_fail;
show = net.trainParam.show;
time = net.trainParam.time;
numLayerDelays = net.numLayerDelays;
needGradient = net.hint.needGradient;
performFcn = net.performFcn;
dPerformFcn = feval(performFcn,'deriv');
doValidation = ~isempty(VV);
doTest = ~isempty(TV);
doShow = isfinite(net.trainParam.show);

% Signals
BP = ones(1,Q);
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
X = getx(net);
if (doValidation)
  VV.net = net;
  VV.perf = calcperf(net,X,VV.Pd,VV.Tl,VV.Ai,VV.Q,VV.TS);
  VV.numFail = 0;
end
tr = newtr(epochs,'perf','vperf','tperf');

% Train
for epoch=0:epochs

  % Performance
  [Ac,N,Zl,Zi,Zb] = calca(net,Pd,Ai,Q,TS);
  E = calce(net,Ac,Tl,TS);
  perf = feval(performFcn,E,X,net.performParam);

  % Training Record
  epochPlus1 = epoch+1;
  tr.perf(epochPlus1) = perf;
  if (doValidation)
    tr.vperf(epochPlus1) = VV.perf;
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
  elseif (doValidation) & (VV.numFail > max_fail)
    stop = 'Validation stop.';
  net = VV.net;
  end
  
  % Progress
  if rem(epoch,show)==0 | length(stop)
    if doShow
      fprintf(this);
    if isfinite(epochs) fprintf(', Epoch %g/%g',epoch, epochs); end
    if isfinite(time) fprintf(', Time %g%%',currentTime/time/100); end
    if isfinite(goal) fprintf(', %s %g/%g.',upper(net.performFcn),perf,goal); end
    fprintf('\n')
    plotperf(tr,goal,this,epoch)
      if length(stop), fprintf('%s, %s\n\n',this,stop); end
  end
    if length(stop), break; end
  end

  % Gradient
  if (needGradient)
    gE = feval(dPerformFcn,'e',E,net,perf,net.performParam);
    [gB,gIW,gLW,gA] = calcgrad(net,Q,Pd,Zb,Zi,Zl,N,Ac,gE,TS);
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
  X = getx(net);

  % Validation
  if (doValidation)
    vperf = calcperf(net,X,VV.Pd,VV.Tl,VV.Ai,VV.Q,VV.TS);
  if (vperf < VV.perf)
    VV.perf = vperf; VV.net = net; VV.numFail = 0;
  elseif (vperf > VV.perf)
      VV.numFail = VV.numFail + 1;
  end
  end
end

% Finish
tr = cliptr(tr,epoch);

