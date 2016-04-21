function [net,tr,Ac,El] = trainscg(net,Pd,Tl,Ai,Q,TS,VV,TV)
%TRAINSCG Scaled conjugate gradient backpropagation.
%
%  Syntax
%  
%    [net,tr,Ac,El] = trainscg(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = trainscg(code)
%
%  Description
%
%    TRAINSCG is a network training function that updates weight and
%    bias values according to the scaled conjugate gradient method.
%
%  TRAINSCG(NET,Pd,Tl,Ai,Q,TS,VV,TV) takes these inputs,
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
%    Training occurs according to the TRAINSCG's training parameters
%    shown here with their default values:
%      net.trainParam.epochs          100  Maximum number of epochs to train
%      net.trainParam.show             25  Epochs between displays (NaN for no displays)
%      net.trainParam.goal              0  Performance goal
%      net.trainParam.time            inf  Maximum time to train in seconds
%      net.trainParam.min_grad       1e-6  Minimum performance gradient
%      net.trainParam.max_fail          5  Maximum validation failures
%      net.trainParam.sigma        5.0e-5  Determines change in weight for second derivative approximation.
%      net.trainParam.lambda       5.0e-7  Parameter for regulating the indefiniteness of the Hessian.
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
%    TRAINSCG(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINSCG with
%    NEWFF, NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with TRAINSCG:
%    1) Set NET.trainFcn to 'trainscg'.
%       This will set NET.trainParam to TRAINSCG's default parameters.
%    2) Set NET.trainParam properties to desired values.
%
%    In either case, calling TRAIN with the resulting network will
%    train the network with TRAINSCG.
%
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
%    neurons, and the second layer has one LOGSIG neuron.  The TRAINSCG
%     network training function is to be used.
%
%      % Create and Test a Network
%      net = newff([0 5],[2 1],{'tansig','logsig'},'trainscg');
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
%    TRAINSCG can train any network as long as its weight, net input,
%    and transfer functions have derivative functions.
%     Backpropagation is used to calculate derivatives of performance
%    PERF with respect to the weight and bias variables X.
%
%    The scaled conjugate gradient algorithm is based on conjugate 
%     directions, as in TRAINCGP, TRAINCGF and TRAINCGB, but this 
%     algorithm does not perform a line search at each iteration.
%    See Moller (Neural Networks, vol. 6, 1993, pp. 525-533) for a more
%     detailed discussion of the scaled conjugate gradient algorithm.
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
%           TRAINRP, TRAINCGF, TRAINCGB, TRAINBFG, TRAINCGP,
%           TRAINOSS.
%
%   References
%
%     Moller, Neural Networks, vol. 6, 1993, pp. 525-533.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:33:57 $

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
    net = {'epochs','show','goal','time','min_grad','max_fail',...
           'sigma','lambda'};
    case 'pdefaults',
    trainParam.epochs = 100;
    trainParam.show = 25;
    trainParam.goal = 0;
    trainParam.time = inf;
    trainParam.min_grad = 1.0e-6;
    trainParam.max_fail = 5;
    trainParam.sigma = 5.0e-5;
    trainParam.lambda = 5.0e-7;
    net = trainParam;
    otherwise,
    error('Unrecognized code.')
  end
  return
end

% CALCULATION
% ===========

% USEFUL VALUES
this = 'TRAINSCG';
epochs = net.trainParam.epochs;
show = net.trainParam.show;
goal = net.trainParam.goal;
time = net.trainParam.time;
min_grad = net.trainParam.min_grad;
max_fail = net.trainParam.max_fail;
goal = net.trainParam.goal;
sigma = net.trainParam.sigma;
lambda = net.trainParam.lambda;
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
if (~isa(sigma,'double')) | (~isreal(sigma)) | (any(size(sigma)) ~= 1) | ...
  (sigma <= 0)
  error('Sigma is not a positive real value.')
end
if (~isa(lambda,'double')) | (~isreal(lambda)) | (any(size(lambda)) ~= 1) | ...
  (lambda <= 0)
  error('Lambda is not a positive real value.')
end

% Initialize
flag_stop = 0;
stop = '';
startTime = clock;
X = getx(net);
num_X = length(X);
if (doValidation)
  VV.net = net;
  VV.X = X;
  VV.perf = calcperf(net,X,VV.Pd,VV.Tl,VV.Ai,VV.Q,VV.TS);
  vperf = VV.perf;
  VV.numFail = 0;
end
tr.epoch = 0:epochs;
tr = newtr(epochs,'perf','vperf','tperf');
flops(0)

% Train
for epoch=0:epochs

  epochPlus1 = epoch+1;

  if (epoch==0)
    % Initial performance
    [perf,El,Ac,N,Zb,Zi,Zl] = calcperf(net,X,Pd,Tl,Ai,Q,TS);

    % Intial gradient and old gradient
    gX = -calcgx(net,X,Pd,Zb,Zi,Zl,N,Ac,El,perf,Q,TS);
    normgX = sqrt(gX'*gX);
    gX_old = gX;

    % Initial search direction and norm
    dX = -gX;
    nrmsqr_dX = dX'*dX;
    norm_dX = sqrt(nrmsqr_dX);

    % Initial training parameters and flag
    success = 1;
    lambdab = 0;
    lambdak = lambda;
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

  % If success is true, calculate second order information
  if (success == 1)
    sigmak = sigma/norm_dX;
    X_temp = X + sigmak*dX;
    net_temp = setx(net,X_temp);
    [perf_temp,El,Ac,N,Zb,Zi,Zl] = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
    gX_temp = -calcgx(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,El,perf_temp,Q,TS);
    sk = (gX_temp - gX)/sigmak;
    deltak = dX'*sk;
  end

  % Scale deltak
  deltak = deltak + (lambdak - lambdab)*nrmsqr_dX;

  % IF deltak <= 0 then make the Hessian matrix positive definite
  if (deltak <= 0)
    lambdab = 2*(lambdak - deltak/nrmsqr_dX);
    deltak = -deltak + lambdak*nrmsqr_dX;
    lambdak = lambdab;
  end

  % Calculate step size
  muk = -dX'*gX;
  alphak = muk/deltak;

  % Calculate the comparison parameter
  X_temp = X + alphak*dX;
  net_temp = setx(net,X_temp);
  [perf_temp,El,Ac,N,Zb,Zi,Zl] = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
  difk = 2*deltak*(perf - perf_temp)/(muk^2);

  % If difk >= 0 then a successful reduction in error can be made
  if (difk >= 0)
    gX_old = gX;
    X = X_temp;
    net = net_temp;
    gX = -calcgx(net,X,Pd,Zb,Zi,Zl,N,Ac,El,perf_temp,Q,TS);
    normgX = sqrt(gX'*gX);
    lambdab = 0;
    success = 1;
    perf = perf_temp;

    % Restart the algorithm every num_X iterations
    if rem(epoch,num_X)==0
      dX = -gX;
    else
      betak = (gX'*gX - gX'*gX_old)/muk;
      dX = -gX + betak*dX;
    end

    nrmsqr_dX = dX'*dX;
    norm_dX = sqrt(nrmsqr_dX);

    % If difk >= 0.75, then reduce the scale parameter
    if (difk >= 0.75)
      lambdak = 0.25*lambdak;
    end

  else

    lambdab = lambdak;
    success = 0;

  end

  % If difk < 0.25, then increase the scale parameter
  if (difk < 0.25)
    lambdak = lambdak + deltak*(1 - difk)/nrmsqr_dX;
  end
 
    
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
