function [net,tr,Ac,El] = trainrp(net,Pd,Tl,Ai,Q,TS,VV,TV)
%TRAINRP RPROP backpropagation.
%
%  Syntax
%  
%    [net,tr,Ac,El] = trainrp(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = trainrp(code)
%
%  Description
%
%    TRAINRP is a network training function that updates weight and
%    bias values according to the resilient backpropagation algorithm
%     (RPROP).
%
%  TRAINRP(NET,Pd,Tl,Ai,Q,TS,VV,TV) takes these inputs,
%      NET - Neural network.
%      Pd  - Delayed input vectors.
%      Tl  - Layer target vectors.
%      Ai  - Initial input delay conditions.
%      Q   - Batch size.
%      TS  - Time steps.
%      VV  - Either empty matrix [] or structure of validation vectors.
%      TV  - Either empty matrix [] or structure of test vectors.
%    and returns,
%      NET - Trained network.
%      TR  - Training record of various values over each epoch:
%            TR.epoch - Epoch number.
%            TR.perf - Training performance.
%            TR.vperf - Validation performance.
%            TR.tperf - Test performance.
%      Ac  - Collective layer outputs for last epoch.
%      El  - Layer errors for last epoch.
%
%    Training occurs according to the TRAINRP's training parameters
%    shown here with their default values:
%      net.trainParam.epochs     100  Maximum number of epochs to train
%      net.trainParam.show        25  Epochs between displays (NaN for no displays)
%      net.trainParam.goal         0  Performance goal
%      net.trainParam.time       inf  Maximum time to train in seconds
%      net.trainParam.min_grad  1e-6  Minimum performance gradient
%      net.trainParam.max_fail     5  Maximum validation failures
%      net.trainParam.lr        0.01  Learning rate
%      net.trainParam.delt_inc   1.2  Increment to weight change
%      net.trainParam.delt_dec   0.5  Decrement to weight change
%      net.trainParam.delta0    0.07  Initial weight change
%      net.trainParam.deltamax  50.0  Maximum weight change
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
%    If VV is not [], it must be a structure of validation vectors,
%      VV.PD - Validation delayed inputs.
%      VV.Tl - Validation layer targets.
%      VV.Ai - Validation initial input conditions.
%      VV.Q  - Validation batch size.
%      VV.TS - Validation time steps.
%    which is used to stop training early if the network performance
%    on the validation vectors fails to improve or remains the same
%    for MAX_FAIL epochs in a row.
%
%    If TV is not [], it must be a structure of validation vectors,
%      TV.PD - Validation delayed inputs.
%      TV.Tl - Validation layer targets.
%      TV.Ai - Validation initial input conditions.
%      TV.Q  - Validation batch size.
%      TV.TS - Validation time steps.
%    which is used to test the generalization capability of the
%     trained network.
%
%    TRAINRP(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINRP with
%    NEWFF, NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with TRAINRP:
%    1) Set NET.trainFcn to 'trainrp'.
%       This will set NET.trainParam to TRAINRP's default parameters.
%    2) Set NET.trainParam properties to desired values.
%
%    In either case, calling TRAIN with the resulting network will
%    train the network with TRAINRP.
%
%  Examples
%
%    Here is a problem consisting of inputs P and targets T that we would
%    like to solve with a network.
%
%      p = [0 1 2 3 4 5];
%      t = [0 0 0 1 1 1];
%
%    Here a two-layer feed-forward network is created.  The network's
%    input ranges from [0 to 10].  The first layer has two TANSIG
%    neurons, and the second layer has one LOGSIG neuron.  The TRAINRP
%    network training function is to be used.
%
%      % Create and Test a Network
%      net = newff([0 5],[2 1],{'tansig','logsig'},'trainrp');
%      a = sim(net,p)
%
%      % Train and Retest the Network
%      net.trainParam.epochs = 50;
%      net.trainParam.show = 10;
%      net.trainParam.goal = 0.1;
%      net = train(net,p,t);
%      a = sim(net,p)
%
%    See NEWFF, NEWCF, and NEWELM for other examples.
%
%  Algorithm
%
%    TRAINRP can train any network as long as its weight, net input,
%    and transfer functions have derivative functions.
%
%    Backpropagation is used to calculate derivatives of performance
%    PERF with respect to the weight and bias variables X.  Each
%    variable is adjusted according to the following:
%
%      dX = deltaX.*sign(gX);
%
%     where the elements of deltaX are all initialized to delta0 and
%     gX is the gradient.  At each iteration the elements of deltaX
%     are modified.  If an element of gX changes sign from one 
%     iteration to the next, then the corresponding element of
%     deltaX is decreased by delta_dec.  If an element of gX 
%     maintains the same sign from one iteration to the next,
%     then the corresponding element of deltaX is increased by
%     delta_inc.  See Reidmiller, Proceedings of the IEEE Int. Conf. 
%      on NN (ICNN) San Francisco, 1993, pp. 586-591.
%
%    Training stops when any of these conditions occur:
%    1) The maximum number of EPOCHS (repetitions) is reached.
%    2) The maximum amount of TIME has been exceeded.
%    3) Performance has been minimized to the GOAL.
%    4) The performance gradient falls below MINGRAD.
%    5) Validation performance has increased more than MAX_FAIL times
%       since the last time it decreased (when using validation).
%
%  See also NEWFF, NEWCF, TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM,
%           TRAINCGP, TRAINCGF, TRAINCGB, TRAINSCG, TRAINOSS,
%           TRAINBFG.
%
%   References
%
%     Reidmiller, Proceedings of the IEEE Int. Conf. on NN (ICNN) 
%     San Francisco, 1993, pp. 586-591.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $ $Date: 2002/04/14 21:31:11 $

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
    net = {'epochs','show','goal','time','min_grad','max_fail','delt_inc',...
           'delt_dec','delta0','deltamax'};
    case 'pdefaults',
    trainParam.epochs = 100;
    trainParam.show = 25;
    trainParam.goal = 0;
    trainParam.time = inf;
    trainParam.min_grad = 1.0e-6;
    trainParam.max_fail = 5;
    trainParam.delt_inc = 1.2;
    trainParam.delt_dec = 0.5;
    trainParam.delta0 = 0.07;
    trainParam.deltamax = 50.0;
    net = trainParam;
    otherwise,
    error('Unrecognized code.')
  end
  return
end

% CALCULATION
% ===========

% Constants
this = 'TRAINRP';
epochs = net.trainParam.epochs;
show = net.trainParam.show;
goal = net.trainParam.goal;
time = net.trainParam.time;
min_grad = net.trainParam.min_grad;
max_fail = net.trainParam.max_fail;
delt_inc = net.trainParam.delt_inc;
delt_dec = net.trainParam.delt_dec;
delta0 = net.trainParam.delta0;
deltamax = net.trainParam.deltamax;
doValidation = ~isempty(VV);
doTest = ~isempty(TV);

% Parameter Checking
if (~isa(epochs,'double')) | (~isreal(epochs)) | (any(size(epochs)) ~= 1) | ...
  (epochs < 1) | (round(epochs) ~= epochs)
  error('Epochs is not a positive integer.')
end
if (~isa(show,'double')) | (~isreal(show)) | (any(size(show)) ~= 1) | ...
  (isfinite(show) & ((show < 1) | (round(show) ~= show)))
  error('Show is not ''NaN'' or a positive integer.')
end
if (~isa(goal,'double')) | (~isreal(goal)) | (any(size(goal)) ~= 1) | ...
  (goal < 0)
  error('Goal is not zero or a positive real value.')
end
if (~isa(time,'double')) | (~isreal(time)) | (any(size(time)) ~= 1) | ...
  (time < 0)
  error('Time is not zero or a positive real value.')
end
if (~isa(min_grad,'double')) | (~isreal(min_grad)) | (any(size(min_grad)) ~= 1) | ...
  (min_grad < 0)
  error('Min_grad is not zero or a positive real value.')
end
if (~isa(max_fail,'double')) | (~isreal(max_fail)) | (any(size(max_fail)) ~= 1) | ...
  (max_fail < 1) | (round(max_fail) ~= max_fail)
  error('Max_fail is not a positive integer.')
end
if (~isa(delt_inc,'double')) | (~isreal(delt_inc)) | (any(size(delt_inc)) ~= 1) | ...
  (delt_inc < 1)
  error('Delt_inc is not a real value greater than 1.')
end
if (~isa(delt_dec,'double')) | (~isreal(delt_dec)) | (any(size(delt_dec)) ~= 1) | ...
  (delt_dec < 0) | (delt_dec > 1)
  error('Delt_dec is not a real value between 0 and 1.')
end
if (~isa(delta0,'double')) | (~isreal(delta0)) | (any(size(delta0)) ~= 1) | ...
  (delta0 <= 0)
  error('Delta0 is not a positive real value.')
end
if (~isa(deltamax,'double')) | (~isreal(deltamax)) | (any(size(deltamax)) ~= 1) | ...
  (deltamax <= 0)
  error('Deltamax is not a positive real value.')
end

% Initialize
flag_stop = 0;
stop = '';
startTime = clock;
X = getx(net);
if (doValidation)
  VV.net = net;
  VV.X = X;
  VV.perf = calcperf(net,X,VV.Pd,VV.Tl,VV.Ai,VV.Q,VV.TS);
  vperf = VV.perf;
  VV.numFail = 0;
end
tr.epoch = 0:epochs;
tr = newtr(epochs,'perf','vperf','tperf');
deltaX = delta0*ones(size(X));
deltaMAX = deltamax*ones(size(X));
gX = zeros(size(X));
flops(0)

% Train
for epoch=0:epochs

  epochPlus1 = epoch+1;

  % Performance and Gradient
  gX_old = gX;
  [perf,El,Ac,N,Zb,Zi,Zl] = calcperf(net,X,Pd,Tl,Ai,Q,TS);
  [gX,normgX] = calcgx(net,X,Pd,Zb,Zi,Zl,N,Ac,El,perf,Q,TS);
  if (epoch == 0)
    gX_old = gX;
  end
  
  % Training Record
  currentTime = etime(clock,startTime);
  tr.perf(epochPlus1) = perf;
  if (doValidation)
    tr.vperf(epochPlus1) = vperf;
  end
  if (doTest)
    tr.tperf(epochPlus1) = calcperf(net,X,TV.Pd,TV.Tl,TV.Ai,TV.Q,TV.TS);
  end
 
  % Stopping Criteria
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
    flag_stop = plotperf(tr,goal,this,epoch);
    if length(stop) fprintf('%s, %s\n\n',this,stop); end
  end
  if length(stop), break, end

  % APPLY RPROP UPDATE
  ggX = gX.*gX_old;
  deltaX = ((ggX>0)*delt_inc + (ggX<0)*delt_dec + (ggX==0)).*deltaX;
  deltaX = min(deltaX,deltaMAX);
  dX = deltaX.*sign(gX);
  X = X + dX;
  net = setx(net,X);
    
  % Validation
  if (doValidation)
    vperf = calcperf(net,X,VV.Pd,VV.Tl,VV.Ai,VV.Q,VV.TS);
  if (vperf < VV.perf)
    VV.perf = vperf; VV.net = net; VV.X = X; VV.numFail = 0;
  elseif (vperf > VV.perf)
      VV.numFail = VV.numFail + 1;
  end
  end
 
end

if (doValidation)
  net = VV.net;
end

% Finish
tr = cliptr(tr,epoch);


