function [net,tr,Ac,El] = trainbfg(net,Pd,Tl,Ai,Q,TS,VV,TV)
%TRAINBFG BFGS quasi-Newton backpropagation.
%
%  Syntax
%  
%    [net,tr,Ac,El] = trainbfg(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = trainbfg(code)
%
%  Description
%
%    TRAINBFG is a network training function that updates weight and
%    bias values according to the BFGS quasi-Newton method.
%
%  TRAINBFG(NET,Pd,Tl,Ai,Q,TS,VV,TV) takes these inputs,
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
%    Training occurs according to the TRAINBFG's training parameters,
%    shown here with their default values:
%      net.trainParam.epochs          100  Maximum number of epochs to train
%      net.trainParam.show             25  Epochs between displays (NaN for no displays)
%      net.trainParam.goal              0  Performance goal
%      net.trainParam.time            inf  Maximum time to train in seconds
%      net.trainParam.min_grad       1e-6  Minimum performance gradient
%      net.trainParam.max_fail          5  Maximum validation failures
%       net.trainParam.searchFcn 'srchcha'  Name of line search routine to use.
%
%   Parameters related to line search methods (not all used for all methods):
%      net.trainParam.scal_tol         20  Divide into delta to determine tolerance for linear search.
%      net.trainParam.alpha         0.001  Scale factor which determines sufficient reduction in perf.
%      net.trainParam.beta            0.1  Scale factor which determines sufficiently large step size.
%      net.trainParam.delta          0.01  Initial step size in interval location step.
%      net.trainParam.gama            0.1  Parameter to avoid small reductions in performance. Usually set
%                                           to 0.1. (See use in SRCH_CHA.)
%      net.trainParam.low_lim         0.1  Lower limit on change in step size.
%      net.trainParam.up_lim          0.5  Upper limit on change in step size.
%      net.trainParam.maxstep         100  Maximum step length.
%      net.trainParam.minstep      1.0e-6  Minimum step length.
%      net.trainParam.bmax             26  Maximum step size.
%
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
%    TRAINBFG(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINBFG with
%    NEWFF, NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with TRAINBFG:
%    1) Set NET.trainFcn to 'trainbfg'.
%       This will set NET.trainParam to TRAINBFG's default parameters.
%    2) Set NET.trainParam properties to desired values.
%
%    In either case, calling TRAIN with the resulting network will
%    train the network with TRAINBFG.
%
%
%  Examples
%
%    Here is a problem consisting of inputs P and targets T that we would
%    like to solve with a network.
%
%      P = [0 1 2 3 4 5];
%      T = [0 0 0 1 1 1];
%
%    Here a two-layer feed-forward network is created.  The network's
%    input ranges from [0 to 10].  The first layer has two TANSIG
%    neurons, and the second layer has one LOGSIG neuron.  The TRAINBFG
%     network training function is to be used.
%
%      % Create and Test a Network
%      net = newff([0 5],[2 1],{'tansig','logsig'},'trainbfg');
%      a = sim(net,P)
%
%      % Train and Retest the Network
%      net.trainParam.epochs = 50;
%      net.trainParam.show = 10;
%      net.trainParam.goal = 0.1;
%      net = train(net,P,T);
%      a = sim(net,P)
%
%    See NEWFF, NEWCF, and NEWELM for other examples.
%
%  Algorithm
%
%    TRAINBFG can train any network as long as its weight, net input,
%    and transfer functions have derivative functions.
%
%     Backpropagation is used to calculate derivatives of performance
%    PERF with respect to the weight and bias variables X.  Each
%    variable is adjusted according to the following:
%
%       X = X + a*dX;
%
%     where dX is the search direction.  The parameter a is selected
%     to minimize the performance along the search direction.  The line
%     search function searchFcn is used to locate the minimum point.
%     The first search direction is the negative of the gradient of performance.
%     In succeeding iterations the search direction is computed 
%     according to the following formula:
%
%       dX = -H\gX;
%
%     where gX is the gradient and H is an approximate Hessian matrix.
%    See page 119 of Gill, Murray & Wright (Practical Optimization  1981) for
%     a more detailed discussion of the BFGS quasi-Newton method.
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
%           TRAINRP, TRAINCGF, TRAINCGB, TRAINSCG, TRAINCGP,
%           TRAINOSS.
%
%   References
%
%     Gill, Murray & Wright, Practical Optimization, 1981.

% Copyright 1992-2004 The MathWorks, Inc.
% $Revision: 1.9.4.1 $ $Date: 2004/03/24 20:43:00 $

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
    net = {'epochs','show','goal','time','min_grad','max_fail','searchFcn','scal_tol','alpha',...
           'beta','delta','gama','low_lim','up_lim','maxstep','minstep','bmax'};
    case 'pdefaults',
    trainParam.epochs = 100;
    trainParam.show = 25;
    trainParam.goal = 0;
    trainParam.time = inf;
    trainParam.min_grad = 1.0e-6;
    trainParam.max_fail = 5;
    trainParam.searchFcn = 'srchbac';
    trainParam.scale_tol = 20;
    trainParam.alpha = 0.001;
    trainParam.beta = 0.1;
    trainParam.delta = 0.01;
    trainParam.gama = 0.1;
    trainParam.low_lim = 0.1;
    trainParam.up_lim = 0.5;
    trainParam.maxstep = 100;
    trainParam.minstep = 1.0e-6;
    trainParam.bmax = 26;
    net = trainParam;
    otherwise,
    error('Unrecognized code.')
  end
  return
end

% CALCULATION
% ===========

% Constants
this = 'TRAINBFG';
epochs = net.trainParam.epochs;
show = net.trainParam.show;
goal = net.trainParam.goal;
time = net.trainParam.time;
min_grad = net.trainParam.min_grad;
max_fail = net.trainParam.max_fail;
scale_tol = net.trainParam.scale_tol;
delta = net.trainParam.delta;
searchFcn = net.trainParam.searchFcn;
tol = delta/scale_tol;
doValidation = ~isempty(VV);
doTest = ~isempty(TV);
retcode = 0;

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
if(isstr(searchFcn))
  exist_search = exist(searchFcn);
  if (exist_search<2) | (exist_search>3)
    error('SearchFcn is not a valid search function.')
  end
else
  error('SearchFcn is not a character string')
end
if (~isa(scale_tol,'double')) | (~isreal(scale_tol)) | (any(size(scale_tol)) ~= 1) | ...
  (scale_tol <= 0)
  error('Scale_tol is not a positive real value.')
end
if (~isa(delta,'double')) | (~isreal(delta)) | (any(size(delta)) ~= 1) | ...
  (delta <= 0)
  error('Delta is not a positive real value.')
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

a=0;

for epoch=0:epochs

  epochPlus1 = epoch+1;

  % Performance, Gradient and Search Direction

  if (epoch == 0)

    % First iteration

    % Initial performance
    [perf,El,Ac,N,Zb,Zi,Zl] = calcperf(net,X,Pd,Tl,Ai,Q,TS);
    perf_old = perf;
    ch_perf = perf;
    avg1 = 0; avg2 = 0; sum1 = 0; sum2 = 0;

    % Intial gradient and norm of gradient
    gX = -calcgx(net,X,Pd,Zb,Zi,Zl,N,Ac,El,perf,Q,TS);
    normgX = sqrt(gX'*gX);
    gX_old = gX;

    % Initial search direction and initial slope
    II = eye(num_X);
    H = II;
    dX  = -gX;
    dperf = gX'*dX;

  else

    % After first iteration

    % Calculate change in gradient
    dgX = gX - gX_old;

    % Calculate change in performance and save old performance
    ch_perf = perf - perf_old;
    perf_old = perf;
  
    % Calculate new Hessian approximation
    H = H + gX_old*gX_old'/(gX_old'*dX) + dgX*dgX'/(dgX'*X_step);

    % Calculate new search direction
    dX = -H\gX;

    % Check for a descent direction
    dperf = gX'*dX;
    if dperf>0
      H = II;
      dX = -gX;
      dperf = gX'*dX;
    end

    % Save old gradient and norm of gradient
    normgX = sqrt(gX'*gX);
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
  elseif(any(isnan(dX)) | any(isinf(dX)))
    stop =  'Precision problems in matrix inversion.';
  elseif (normgX < min_grad)
    stop = 'Minimum gradient reached, performance goal was not met.';
  elseif (doValidation) & (VV.numFail > max_fail)
    stop = 'Validation stop.';
  elseif flag_stop
    stop = 'User stop.';
  end
 
  % Progress
  if isfinite(show) & (~rem(epoch,show) | length(stop))
    fprintf('%s%s%s',this,'-',searchFcn);
  if isfinite(epochs) fprintf(', Epoch %g/%g',epoch, epochs); end
  if isfinite(time) fprintf(', Time %g%%',currentTime/time/100); end
  if isfinite(goal) fprintf(', %s %g/%g',upper(net.performFcn),perf,goal); end
  if isfinite(min_grad) fprintf(', Gradient %g/%g',normgX,min_grad); end
  fprintf('\n')
    flag_stop = plotperf(tr,goal,this,epoch);
    if length(stop) fprintf('%s, %s\n\n',this,stop); end
  end
  if length(stop), break; end

  % Minimize the performance along the search direction
  delta = 1;
  [a,gX,perf,retcode,delta,tol] = feval(searchFcn,net,X,Pd,Tl,Ai,Q,TS,dX,gX,perf,dperf,delta,tol,ch_perf);

  % Keep track of the number of function evaluations
  sum1 = sum1 + retcode(1);
  sum2 = sum2 + retcode(2);
  avg1 = sum1/epochPlus1;
  avg2 = sum2/epochPlus1;

  % Update X
  X_step = a*dX;
  X = X + X_step;
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
[perf,El,Ac] = calcperf(net,X,Pd,Tl,Ai,Q,TS);

