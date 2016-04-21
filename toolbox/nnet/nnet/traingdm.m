function [net,tr,Ac,El] = traingdm(net,Pd,Tl,Ai,Q,TS,VV,TV)
%TRAINGDM Gradient descent with momentum backpropagation.
%
%  Syntax
%  
%    [net,tr,Ac,El] = traingdm(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = traingdm(code)
%
%  Description
%
%    TRAINGDM is a network training function that updates weight and
%    bias values according to gradient descent with momentum.
%
%    TRAINGDM(NET,Pd,Tl,Ai,Q,TS,VV,TV) takes these inputs:
%      NET - Neural network.
%      Pd  - Delayed input vectors.
%      Tl  - Layer target vectors.
%      Ai  - Initial input delay conditions.
%      Q   - Batch size.
%      TS  - Time steps.
%      VV  - Empty matrix [] or structure of validation vectors.
%      TV  - Empty matrix [] or structure of test vectors.
%    and returns:
%      NET - Trained network.
%      TR  - Training record of various values over each epoch:
%            TR.epoch - Epoch number.
%            TR.perf  - Training performance.
%            TR.vperf - Validation performance.
%            TR.tperf - Test performance.
%      Ac  - Collective layer outputs for last epoch.
%      El  - Layer errors for last epoch.
%
%    Training occurs according to the TRAINGDM's training parameters
%    shown here with their default values:
%      net.trainParam.epochs      10  Maximum number of epochs to train
%      net.trainParam.goal         0  Performance goal
%      net.trainParam.lr        0.01  Learning rate
%      net.trainParam.max_fail     5  Maximum validation failures
%      net.trainParam.mc         0.9  Momentum constant.
%      net.trainParam.min_grad 1e-10  Minimum performance gradient
%      net.trainParam.show        25  Epochs between displays (NaN for no displays)
%      net.trainParam.time       inf  Maximum time to train in seconds
%
%    Dimensions for these variables are:
%      Pd - NoxNixTS cell array, each element P{i,j,ts} is a DijxQ matrix.
%      Tl - NlxTS cell array, each element P{i,ts} is a VixQ matrix.
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
%    If VV or TV is not [], it must be a structure of vectors:
%      VV.PD, TV.PD - Validation/test delayed inputs.
%      VV.Tl, TV.Tl - Validation/test layer targets.
%      VV.Ai, TV.Ai - Validation/test initial input conditions.
%      VV.Q,  TV.Q  - Validation/test batch size.
%      VV.TS, TV.TS - Validation/test time steps.
%    Validation vectors are used to stop training early if the network
%    performance on the validation vectors fails to improve or remains
%    the same for MAX_FAIL epochs in a row.  Test vectors are used as
%    a further check that the network is generalizing well, but do not
%    have any effect on training.
%
%    TRAINGDM(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINGDM with
%    NEWFF, NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with TRAINGDM:
%    1) Set NET.trainFcn to 'traingdm'.
%       This will set NET.trainParam to TRAINGDM's default parameters.
%    2) Set NET.trainParam properties to desired values.
%
%    In either case, calling TRAIN with the resulting network will
%    train the network with TRAINGDM.
%
%    See NEWFF, NEWCF, and NEWELM for examples.
%
%  Algorithm
%
%    TRAINGDM can train any network as long as its weight, net input,
%    and transfer functions have derivative functions.
%
%    Backpropagation is used to calculate derivatives of performance
%    PERF with respect to the weight and bias variables X.  Each
%    variable is adjusted according to gradient descent with
%    momentum,
%
%      dX = mc*dXprev + lr*(1-mc)*dperf/dX
%
%    where dXprev is the previous change to the weight or bias.
%
%    Training stops when any of these conditions occur:
%    1) The maximum number of EPOCHS (repetitions) is reached.
%    2) The maximum amount of TIME has been exceeded.
%    3) Performance has been minimized to the GOAL.
%    4) The performance gradient falls below MINGRAD.
%    5) Validation performance has increase more than MAX_FAIL times
%       since the last time it decreased (when using validation).
%
%  See also NEWFF, NEWCF, TRAINGD, TRAINGDA, TRAINGDX, TRAINLM.

% Mark Beale, 11-31-97
% ODJ, 11/20/98, added support for user stopping.
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $ $Date: 2002/04/14 21:36:08 $

% FUNCTION INFO
% =============
if isstr(net)
  switch (net)
    case 'pnames',
      net = fieldnames(traingdm('pdefaults'));
    case 'pdefaults',
      trainParam.epochs = 100;
    trainParam.goal = 0;
    trainParam.lr = 0.01;
    trainParam.max_fail = 5;
    trainParam.mc = 0.9;
    trainParam.min_grad = 1e-10;
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
lr = net.trainParam.lr;
max_fail = net.trainParam.max_fail;
mc = net.trainParam.mc;
min_grad = net.trainParam.min_grad;
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
if (~isa(lr,'double')) | (~isreal(lr)) | (any(size(lr)) ~= 1) | ...
  (lr < 0)
  error('Learning rate is not zero or a positive real value.')
end
if (~isa(max_fail,'double')) | (~isreal(max_fail)) | (any(size(max_fail)) ~= 1) | ...
  (max_fail < 1) | (round(max_fail) ~= max_fail)
  error('Max_fail is not a positive integer.')
end
if (~isa(mc,'double')) | (~isreal(mc)) | (any(size(mc)) ~= 1) | ...
  (mc < 0) | (mc > 1)
  error('MC is not real value between 0.0 and 1.0.')
end
if (~isa(min_grad,'double')) | (~isreal(min_grad)) | (any(size(min_grad)) ~= 1) | ...
  (min_grad < 0)
  error('Min_grad is not zero or a positive real value.')
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
this = 'TRAINGDM';
doValidation = ~isempty(VV);
doTest = ~isempty(TV);

% Initialize
flag_stop=0;
stop = '';
startTime = clock;
X = getx(net);
[perf,El,Ac,N,Zb,Zi,Zl] = calcperf(net,X,Pd,Tl,Ai,Q,TS);
gX = calcgx(net,X,Pd,Zb,Zi,Zl,N,Ac,El,perf,Q,TS);
dX = lr*gX;
if (doValidation)
  VV.net = net;
  vperf = calcperf(net,X,VV.Pd,VV.Tl,VV.Ai,VV.Q,VV.TS);
  VV.perf = vperf;
  VV.numFail = 0;
end
tr = newtr(epochs,'perf','vperf','tperf');

% Train
for epoch=0:epochs
  
  % Performance and Gradient
  [perf,El,Ac,N,Zb,Zi,Zl] = calcperf(net,X,Pd,Tl,Ai,Q,TS);
  [gX,normgX] = calcgx(net,X,Pd,Zb,Zi,Zl,N,Ac,El,perf,Q,TS);
  
  % Training Record
  epochPlus1 = epoch+1;
  tr.perf(epochPlus1) = perf;
  if (doValidation)
    tr.vperf(epochPlus1) = vperf;
  end
  if (doTest)
    tr.tperf(epochPlus1) = calcperf(net,X,TV.Pd,TV.Tl,TV.Ai,TV.Q,TV.TS);
  end
  
  % Stopping Criteria
  currentTime = etime(clock,startTime);
  if (perf <= goal)
    stop = 'Performance goal met.';
  elseif (epoch == epochs)
    stop = 'Maximum epoch reached, performance goal was not met.';
  elseif (currentTime > time)
    stop = 'Maximum time elapsed, performance goal was not met.';
  elseif (normgX < min_grad)
    stop = 'Minimum gradient reached, performance goal was not met.';
  elseif (doValidation) & (VV.numFail > max_fail)
    stop = 'Validation stop.';
% If flag_stop ON then User stop. ODJ 11/20/98
  elseif flag_stop
    stop = 'User stop.';
  end
  
  % Progress
  if isfinite(show) & (~rem(epoch,show) | length(stop))
    fprintf(this);
  if isfinite(epochs) fprintf(', Epoch %g/%g',epoch, epochs); end
  if isfinite(time) fprintf(', Time %g%%',currentTime/time/100); end
  if isfinite(goal) fprintf(', %s %g/%g',upper(net.performFcn),perf,goal); end
  if isfinite(min_grad) fprintf(', Gradient %g/%g',normgX,min_grad); end
  fprintf('\n')
  % We accept flag from plotperf to check for User stop. ODJ 11/20/98
  flag_stop=plotperf(tr,goal,this,epoch);
    if length(stop) fprintf('%s, %s\n\n',this,stop); end
  end

  % Stop when criteria indicate its time
  if length(stop)
    if (doValidation)
    net = VV.net;
  end
    break
  end
  
  % Gradient Descent with Momentum
  dX = mc*dX + (1-mc)*lr*gX;
  X = X + dX;
  net = setx(net,X);
  
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
