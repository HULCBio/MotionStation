function [net,tr,Ac,El] = traincgb(net,Pd,Tl,Ai,Q,TS,VV,TV)
%TRAINCGB Conjugate gradient backpropagation with Powell-Beale restarts.
%
%  Syntax
%  
%    [net,tr,Ac,El] = traincgb(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = traincgb(code)
%
%  Description
%
%    TRAINCGB is a network training function that updates weight and
%    bias values according to the conjugate gradient backpropagation
%     with Powell-Beale restarts.
%
%  TRAINCGB(NET,Pd,Tl,Ai,Q,TS,VV,TV) takes these inputs,
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
%    Training occurs according to the TRAINCGB's training parameters,
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
%    TRAINCGB(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINCGB with
%    NEWFF, NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with TRAINCGB:
%    1) Set NET.trainFcn to 'traincgb'.
%       This will set NET.trainParam to TRAINCGB's default parameters.
%    2) Set NET.trainParam properties to desired values.
%
%    In either case, calling TRAIN with the resulting network will
%    train the network with TRAINCGB.
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
%    neurons, and the second layer has one LOGSIG neuron.  The TRAINCGB
%     network training function is to be used.
%
%      % Create and Test a Network
%      net = newff([0 5],[2 1],{'tansig','logsig'},'traincgb');
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
%    TRAINCGB can train any network as long as its weight, net input,
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
%     In succeeding iterations the search direction is computed from the new
%     gradient and the previous search direction according to the
%     formula:
%
%       dX = -gX + dX_old*Z;
%
%     where gX is the gradient. The parameter Z can be computed in several 
%     different ways.  The Powell-Beale variation of conjugate gradient
%     is distinguished by two features.  First, the algorithm uses a test
%     to determine when to reset the search direction to the negative of
%     the gradient.  Second, the search direction is computed from the
%     negative gradient, the previous search direction, and the last
%     search direction before the previous reset.
%    See Powell, Mathematical Programming, Vol. 12 (1977) pp. 241-254, for
%     a more detailed discussion of the algorithm.
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
%     Powell, Mathematical Programming, Vol. 12 (1977) pp. 241-254

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:34:08 $

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
    trainParam.searchFcn = 'srchcha';
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
this = 'TRAINCGB';
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

a=1;

% Train
for epoch=0:epochs

  epochPlus1 = epoch+1;

  % Performance, Gradient and Search Direction

  if (epoch == 0)
    % First Iteration
  
    % Initial performance
    [perf,El,Ac,N,Zb,Zi,Zl] = calcperf(net,X,Pd,Tl,Ai,Q,TS);
    perf_old = perf;
    ch_perf = perf;
    avg1 = 0; avg2 = 0; sum1 = 0; sum2 = 0;

    % Intial gradient and norm of gradient
    gX = -calcgx(net,X,Pd,Zb,Zi,Zl,N,Ac,El,perf,Q,TS);
    norm_sqr = gX'*gX;
    normgX = sqrt(norm_sqr);
    dX_old = -gX;
    gX_old = gX;
    dgX_t = zeros(size(gX));
    dX_t = dgX_t;
    dX_gXt = 1;

    % Initial search direction and initial slope
    dX = -gX/normgX;
    dperf = gX'*dX;

    % Initialize restart location
    t = 1;

  else

    % After first iteration

    % Calculate change in performance and norm of gradient
    normnew_sqr = gX'*gX;
    normgX = sqrt(normnew_sqr);
    ch_perf = perf - perf_old;
  
    % Check for restart
    if (abs(gX_old'*gX) >= 0.2*normnew_sqr) | ((epoch-t) >= num_X)
      t = epoch -1;
      dgX_t = gX - gX_old;
      dX_t = dX_old;
      dX_gXt = dX_t'*dgX_t;
    end

    % Calculate search direction modification parameters
    if (epoch == t+1)
      Z2 = 0;
     else
      Z2 = gX'*dgX_t/dX_gXt;
    end
    
    dgX = gX - gX_old;

    Z1 = gX'*dgX/(dX_old'*dgX);

    % Calculate new search direction
    dX = -gX + dX_old*Z1 + dX_t*Z2;

    % Save new directions and norm of gradient
    dgX = dX - dX_old;
    dX_old = dX;
    gX_old = gX;
    norm_sqr = normnew_sqr;
    perf_old = perf;
  
    % Normalize search direction
    dX = dX/norm(dX);

    % Check for a descent direction
    dperf = gX'*dX;
    if (dperf >= -0.001*normgX)
      dX = -gX/normgX;
    dX_old = -gX;
      dperf = gX'*dX;
      t = epoch;
      dgX_t = zeros(size(gX));
      dX_t = dgX_t;
      dX_gXt = 1;
      dperf = gX'*dX;
    end

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
  elseif (a == 0)
    stop = 'Minimum step size reached, performance goal was not met.';
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
  [a,gX,perf,retcode,delta,tol] = feval(searchFcn,net,X,Pd,Tl,Ai,Q,TS,dX,gX,perf,dperf,delta,tol,ch_perf);

  % Keep track of the number of function evaluations
  sum1 = sum1 + retcode(1);
  sum2 = sum2 + retcode(2);
  avg1 = sum1/epochPlus1;
  avg2 = sum2/epochPlus1;

  % Update X
  X = X + a*dX;
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
