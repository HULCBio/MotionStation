function [net,tr,Ac,El,v5,v6,v7,v8] = ...
  trainlm(net,Pd,Tl,Ai,Q,TS,VV,TV,v9,v10,v11,v12)
%TRAINLM Levenberg-Marquardt backpropagation.
%
%  Syntax
%  
%    [net,tr] = trainlm(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = trainlm(code)
%
%  Description
%
%    TRAINLM is a network training function that updates weight and
%    bias values according to Levenberg-Marquardt optimization.
%
%    TRAINLM(NET,Pd,Tl,Ai,Q,TS,VV,TV) takes these inputs,
%      NET - Neural network.
%      Pd  - Delayed input vectors.
%      Tl  - Layer target vectors.
%      Ai  - Initial input delay conditions.
%      Q   - Batch size.
%      TS  - Time steps.
%      VV  - Either empty matrix [] or structure of validation vectors.
%      TV  - Either empty matrix [] or structure of validation vectors.
%    and returns,
%      NET - Trained network.
%      TR  - Training record of various values over each epoch:
%            TR.epoch - Epoch number.
%            TR.perf  - Training performance.
%            TR.vperf - Validation performance.
%            TR.tperf - Test performance.
%            TR.mu    - Adaptive mu value.
%
%    Training occurs according to the TRAINLM's training parameters
%    shown here with their default values:
%      net.trainParam.epochs     100  Maximum number of epochs to train
%      net.trainParam.goal         0  Performance goal
%      net.trainParam.max_fail     5  Maximum validation failures
%      net.trainParam.mem_reduc    1  Factor to use for memory/speed trade off.
%      net.trainParam.min_grad 1e-10  Minimum performance gradient
%      net.trainParam.mu       0.001  Initial Mu
%      net.trainParam.mu_dec     0.1  Mu decrease factor
%      net.trainParam.mu_inc      10  Mu increase factor
%      net.trainParam.mu_max    1e10  Maximum Mu
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
%    TRAINLM(CODE) return useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINLM with
%    NEWFF, NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with TRAINLM:
%    1) Set NET.trainFcn to 'trainlm'.
%       This will set NET.trainParam to TRAINLM's default parameters.
%    2) Set NET.trainParam properties to desired values.
%
%    In either case, calling TRAIN with the resulting network will
%    train the network with TRAINLM.
%
%    See NEWFF, NEWCF, and NEWELM for examples.
%
%  Algorithm
%
%    TRAINLM can train any network as long as its weight, net input,
%    and transfer functions have derivative functions.
%
%    Backpropagation is used to calculate the Jacobian jX of performance
%    PERF with respect to the weight and bias variables X.  Each
%    variable is adjusted according to Levenberg-Marquardt,
%
%      jj = jX * jX
%      je = jX * E
%      dX = -(jj+I*mu) \ je
%
%    where E is all errors and I is the identity matrix.
%
%    The adaptive value MU is increased by MU_INC until the change above
%    results in a reduced performance value.  The change is then made to
%    the network and mu is decreased by MU_DEC.
%
%    The parameter MEM_REDUC indicates how to use memory and speed to
%    calculate the Jacobian jX.  If MEM_REDUC is 1, then TRAINLM runs
%    the fastest, but can require a lot of memory. Increasing MEM_REDUC
%    to 2, cuts some of the memory required by a factor of two, but
%    slows TRAINLM somewhat.  Higher values continue to decrease the
%    amount of memory needed and increase training times.
%
%    Training stops when any of these conditions occurs:
%    1) The maximum number of EPOCHS (repetitions) is reached.
%    2) The maximum amount of TIME has been exceeded.
%    3) Performance has been minimized to the GOAL.
%    4) The performance gradient falls below MINGRAD.
%    5) MU exceeds MU_MAX.
%    6) Validation performance has increased more than MAX_FAIL times
%       since the last time it decreased (when using validation).
%
%    Unlike other training functions, TRAINLM assumes the network has
%    the MSE performance function.  This is a basic assumption of the
%    Levenberg-Marquardt algorithm.
%
%  See also NEWFF, NEWCF, TRAINGD, TRAINGDM, TRAINGDA, TRAINGDX.

% Mark Beale, 11-31-97, ODJ 11/20/98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.20 $ $Date: 2002/04/14 21:33:27 $

% **[ NNT2 Support ]**
if ~isa(net,'struct') & ~isa(net,'char')
  nntobsu('trainlm','Use NNT2FF and TRAIN to update and train your network.')
  switch(nargin)
  case 5, [net,tr,Ac,El] = tlm1(net,Pd,Tl,Ai,Q); return
  case 6, [net,tr,Ac,El] = tlm1(net,Pd,Tl,Ai,Q,TS); return
  case 8, [net,tr,Ac,El,v5,v6] = tlm2(net,Pd,Tl,Ai,Q,TS,VV,TV); return
  case 9, [net,tr,Ac,El,v5,v6] = tlm2(net,Pd,Tl,Ai,Q,TS,VV,TV,v9); return
  case 11, [net,tr,Ac,El,v5,v6,v7,v8] = tlm3(net,Pd,Tl,Ai,Q,TS,VV,TV,v9,v10,v11); return
  case 12, [net,tr,Ac,El,v5,v6,v7,v8] = tlm3(net,Pd,Tl,Ai,Q,TS,VV,TV,v9,v10,v11,v12); return
  end
end

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
    net = fieldnames(trainlm('pdefaults'));
    case 'pdefaults',
    trainParam.epochs = 100;
    trainParam.goal = 0;
    trainParam.max_fail = 5;
    trainParam.mem_reduc = 1;
    trainParam.min_grad = 1e-10;
    trainParam.mu = 0.001;
    trainParam.mu_dec = 0.1;
    trainParam.mu_inc = 10;
    trainParam.mu_max = 1e10;
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
max_fail = net.trainParam.max_fail;
mem_reduc = net.trainParam.mem_reduc;
min_grad = net.trainParam.min_grad;
mu = net.trainParam.mu;
mu_inc = net.trainParam.mu_inc;
mu_dec = net.trainParam.mu_dec;
mu_max = net.trainParam.mu_max;
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
if (~isa(max_fail,'double')) | (~isreal(max_fail)) | (any(size(max_fail)) ~= 1) | ...
  (max_fail < 1) | (round(max_fail) ~= max_fail)
  error('Max_fail is not a positive integer.')
end
if (~isa(mem_reduc,'double')) | (~isreal(mem_reduc)) | (any(size(mem_reduc)) ~= 1) | ...
  (mem_reduc < 1) | (round(mem_reduc) ~= mem_reduc)
  error('Mem_reduc is not a positive integer.')
end
if (~isa(min_grad,'double')) | (~isreal(min_grad)) | (any(size(min_grad)) ~= 1) | ...
  (min_grad < 0)
  error('Min_grad is not zero or a positive real value.')
end
if (~isa(mu,'double')) | (~isreal(mu)) | (any(size(mu)) ~= 1) | ...
  (mu <= 0)
  error('Mu is not a positive real value.')
end
if (~isa(mu_dec,'double')) | (~isreal(mu_dec)) | (any(size(mu_dec)) ~= 1) | ...
  (mu_dec < 0) | (mu_dec > 1)
  error('Mu_dec is not a real value between 0 and 1.')
end
if (~isa(mu_inc,'double')) | (~isreal(mu_inc)) | (any(size(mu_inc)) ~= 1) | ...
  (mu_inc < 1)
  error('Mu_inc is not a real value greater than 1.')
end
if (~isa(mu_max,'double')) | (~isreal(mu_max)) | (any(size(mu_max)) ~= 1) | ...
  (mu_max <= 0)
  error('Mu_max is not a positive real value.')
end
if (mu > mu_max)
  error('Mu is greater than Mu_max.')
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
this = 'TRAINLM';
doValidation = ~isempty(VV);
doTest = ~isempty(TV);

% Initialize
flag_stop=0;
stop = '';
startTime = clock;
X = getx(net);
numParameters = length(X);
ii = sparse(1:numParameters,1:numParameters,ones(1,numParameters));
[perf,El,Ac,N,Zb,Zi,Zl] = calcperf(net,X,Pd,Tl,Ai,Q,TS);
if (doValidation)
  VV.net = net;
  vperf = calcperf(net,X,VV.Pd,VV.Tl,VV.Ai,VV.Q,VV.TS);
  VV.perf = vperf;
  VV.numFail = 0;
end
tr = newtr(epochs,'perf','vperf','tperf','mu');

% Train
for epoch=0:epochs

  % Jacobian
  [je,jj,normgX]=calcjejj(net,Pd,Zb,Zi,Zl,N,Ac,El,Q,TS,mem_reduc);
  
  % Training Record
  epochPlus1 = epoch+1;
  tr.perf(epoch+1) = perf;
  tr.mu(epoch+1) = mu;
  if (doValidation)
    tr.vperf(epochPlus1) = VV.perf;
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
  elseif (mu > mu_max)
    stop = 'Maximum MU reached, performance goal was not met.';
  elseif (doValidation) & (VV.numFail > max_fail)
    stop = 'Validation stop.';
  elseif flag_stop
    stop = 'User stop.';
  end
  
  % Progress
  if isfinite(show) & (~rem(epoch,show) | length(stop))
    fprintf(this);
  if isfinite(epochs) fprintf(', Epoch %g/%g',epoch, epochs); end
  if isfinite(time) fprintf(', Time %4.1f%%',currentTime/time*100); end
  if isfinite(goal) fprintf(', %s %g/%g',upper(net.performFcn),perf,goal); end
  if isfinite(min_grad) fprintf(', Gradient %g/%g',normgX,min_grad); end
  fprintf('\n')
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
  
  % Levenberg Marquardt
  while (mu <= mu_max)
    dX = -(jj+ii*mu) \ je;
    X2 = X + dX;
    net2 = setx(net,X2);
    [perf2,El2,Ac2,N2,Zb2,Zi2,Zl2] = calcperf(net2,X2,Pd,Tl,Ai,Q,TS);

    if (perf2 < perf)
      X = X2; net = net2; Zb = Zb2; Zi = Zi2; Zl = Zl2;
      N = N2; Ac = Ac2; El = El2; perf = perf2;
      mu = mu * mu_dec;
      if (mu < 1e-20)
        mu = 1e-20;
      end
      break
    end
    mu = mu * mu_inc;
  end

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
