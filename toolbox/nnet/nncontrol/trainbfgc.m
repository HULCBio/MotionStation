function [net,tr,Y,E,Pf,Af,flag_stop] = trainbfgc(net,P,T,Pi,Ai,epochs,TS,Q)
%TRAINBFGC BFGS quasi-Newton backpropagation for use with the NN model reference adaptive controller.
%
%  Syntax
%  
%    [net,tr,Y,E,Pf,Af,flag_stop] = trainbfgc(net,P,T,Pi,Ai,epochs,TS,Q)
%    info = trainbfgc(code)
%
%  Description
%
%    TRAINBFGC is a network training function that updates weight and
%    bias values according to the BFGS quasi-Newton method.  This function
%    is called from NNMODREF, a gui for the model reference adaptive
%    control SIMULINK block.
%
%  TRAINBFGC(NET,P,T,Pi,Ai,EPOCHS,TS) takes these inputs,
%      NET    - Neural network.
%      P      - Delayed input vectors.
%      T      - Layer target vectors.
%      Pi     - Initial input delay conditions.
%      Ai     - Initial input delay conditions.
%      EPOCHS - Number of iterations for training.
%      TS     - Time steps.
%      Q      - Batch size.
%    and returns,
%      NET      - Trained network.
%      TR       - Training record of various values over each epoch:
%                   TR.epoch - Epoch number.
%                   TR.perf - Training performance.
%                   TR.vperf - Validation performance.
%                   TR.tperf - Test performance.
%      Y         - Network output for last epoch.
%      E         - Layer errors for last epoch.
%      Pf        - Final input delay conditions.
%      Af        - Collective layer outputs for last epoch.
%      FLAG_STOP - Indicates if the user stopped the training.
%
%    Training occurs according to the TRAINBFGC's training parameters,
%    shown here with their default values:
%      net.trainParam.epochs            100  Maximum number of epochs to train
%      net.trainParam.show               25  Epochs between displays (NaN for no displays)
%      net.trainParam.goal                0  Performance goal
%      net.trainParam.time              inf  Maximum time to train in seconds
%      net.trainParam.min_grad         1e-6  Minimum performance gradient
%      net.trainParam.max_fail            5  Maximum validation failures
%      net.trainParam.searchFcn 'srchbacxc'  Name of line search routine to use.
%
%    Parameters related to line search methods (not all used for all methods):
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
%    TRAINBFGC(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Algorithm
%
%    TRAINBFGC can train any network as long as its weight, net input,
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
%    5) Precision problems have occurred in the matrix inversion.
%
%   References
%
%     Gill, Murray & Wright, Practical Optimization, 1981.

% Orlando De Jesus, Martin Hagan, Model Reference Controller Neural Network, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/14 21:12:23 $

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
    trainParam.searchFcn = 'srchbacxc';
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

% [] -> zeros
if any(size(Ai) == 0)
  c = cell(net.numLayers,net.numLayerDelays);
  for i=1:net.numLayers
    for ts=1:net.numLayerDelays
    c{i,ts} = zeros(net.layers{i}.size,Q);
  end
  end
  Ai = c;
else
   % Check cell array dimensions
   if (size(Ai,1) ~= net.numLayers)
     err = sprintf('Ai must have %g rows.',net.numLayers);
     return
   end
   if (size(Ai,2) ~= net.numLayerDelays)
     err = sprintf('Ai must have %g columns.',net.hint.layerDelays);
     return
   end
end

flag_stop=0;
this = 'TRAINBFGC';

Pc = [Pi P];
Pd = calcpd(net,TS,Q,Pc);
Tl = expandrows(T,net.hint.targetInd,net.numLayers);
    
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
retcode = 0;

% Initialize
stop = '';
startTime = clock;
X = getx(net);
num_X = length(X);

tr.epoch = 0:epochs;
tr = newtr(epochs,'perf','vperf','tperf','gradient','dperf','tol','delta','a');
flops(0)

a=0;
first_transition=1;

for epoch=0:epochs

  epochPlus1 = epoch+1;

  % Performance, Gradient and Search Direction

  if (epoch == 0) | (a <= tol)

    if epoch~=0
       first_transition=0;
       if Q > 1
         % ODJ If change Ok move this to the beginning.
         Aisize=size(Ai);
         Acsize=size(Ac,2);
         for k1=1:Aisize(1)
           for k2=1:Aisize(2)
             Ai{k1,k2}(:,2:Q)=Ac{k1,Acsize-Aisize(2)+k2}(:,1:Q-1);
           end
         end
      end
    end
    % First iteration

    % Initial performance
    [perf,El,Ac,N,Zb,Zi,Zl] = calcperf2(net,X,Pd,Tl,Ai,Q,TS);
    perf_old = perf;
    ch_perf = perf;
    avg1 = 0; avg2 = 0; sum1 = 0; sum2 = 0;

    % Intial gradient and norm of gradient
    gX = -calcgxmodref(net,X,Pd,Zb,Zi,Zl,N,Ac,El,perf,Q,TS);
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
  
    % Calculate new Hessian approximation. 
    % 2/12/99 ODJ If H is rank defficient, use previous H matrix.
    H_ant=H;
    H = H + gX_old*gX_old'/(gX_old'*dX) + dgX*dgX'/(dgX'*X_step);
    if rank(H) ~= num_X
       H=H_ant;
    end

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
% If flag_stop ON then User stop. ODJ 11/20/98
  elseif flag_stop
    stop = 'User stop.';
  end
 
  % Progress
  if isfinite(show) & (~rem(epoch,show) | length(stop))
    fprintf('%s%s%s',this,'-',searchFcn);
  if isfinite(epochs) fprintf(', Epoch %g/%g',epoch, epochs); end
  if isfinite(time) fprintf(', Time %g%%',currentTime/time/100); end
  if isfinite(goal) fprintf(', %s %g/%g',upper(net.performFcn),perf,goal); end
  if isfinite(min_grad) fprintf(', Gradient %g/%g',normgX,min_grad); tr.gradient(epochPlus1)=normgX; end
   if isfinite(dperf) fprintf(', dperf %g tol %g delta %g a %g ',dperf,tol,delta,a); tr.dperf(epochPlus1)=dperf; tr.tol(epochPlus1)=tol; tr.delta(epochPlus1)=delta; tr.a(epochPlus1)=a; tr.X{epochPlus1}=X; end
  fprintf('\n')
% We accept flag from plotperf to check for User stop. ODJ 11/20/98
  flag_stop=plotperf(tr,goal,this,epoch);
    if length(stop) fprintf('%s, %s\n\n',this,stop); end
  end
  if length(stop), break; end

  % Minimize the performance along the search direction
%  delta = 1;
  [a,gX,perf,retcode,delta,tol,Ac] = feval(searchFcn,net,X,Pd,Tl,Ai,Q,TS,dX,gX,perf,dperf,delta,tol,ch_perf);
  
  % ODJ Temporal Q movement. ****
  if Q > 1 %& first_transition==1
     % ODJ If change Ok move this to the beginning.
     Aisize=size(Ai);
     Acsize=size(Ac,2);
     for k1=1:Aisize(1)
        for k2=1:Aisize(2)
           Ai{k1,k2}(:,2:Q)=Ac{k1,Acsize-Aisize(2)+k2}(:,1:Q-1);
        end
     end
  end
  

  % Keep track of the number of function evaluations
  sum1 = sum1 + retcode(1);
  sum2 = sum2 + retcode(2);
  avg1 = sum1/epochPlus1;
  avg2 = sum2/epochPlus1;

  % Update X
  X_step = a*dX;
  X = X + X_step;
  net = setx(net,X);
 
  % ODJ We recalculate perf for new initial conditions.
  [perf,El,Ac,N,Zb,Zi,Zl] = calcperf2(net,X,Pd,Tl,Ai,Q,TS);
   
end

% Finish
tr = cliptr(tr,epoch);

%net = class(net,'network');

% Network outputs, errors, final inputs
Y = Ac(net.hint.outputInd,net.numLayerDelays+[1:TS]);
E = El(net.hint.targetInd,:);
Pf = Pc(:,TS+[1:net.numInputDelays]);
Af = Ac(:,TS+[1:net.numLayerDelays]);


% ============================================================
function [s2] = expandrows(s,ind,rows)

s2 = cell(rows,size(s,2));
s2(ind,:) = s;

% ============================================================
function [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P,T,Pi,Ai);

err = '';

% Check signals: all matrices or all cell arrays
% Change empty matrices/arrays to proper form
switch class(P)
  case 'cell', matrixForm = 0; name = 'cell array'; default = {};
  case 'double', matrixForm = 1; name = 'matrix'; default = [];
  otherwise, err = 'P must be a matrix or cell array.'; return
end
if (nargin < 3)
  T = default;
elseif (isa(T,'double') ~= matrixForm)
  if isempty(T)
    T = default;
  else
    err = ['T is a ' name ', so T must be a ' name ' too.'];
    return
  end
end
if (nargin < 4)
  Pi = default;
elseif (isa(Pi,'double') ~= matrixForm)
  if isempty(Pi)
    Pi = default;
  else
    err = ['P is a ' name ', so Pi must be a ' name ' too.'];
    return
  end
end
if (nargin < 5)
  Ai = default;
elseif (isa(Ai,'double') ~= matrixForm)
  if isempty(Ai)
    Ai = default;
  else
    err = ['P is a ' name ', so Ai must be a ' name ' too.'];
    return
  end
end

% Check Matrices, Matrices -> Cell Arrays
if (matrixForm)
  [R,Q] = size(P);
  TS = 1;
  [err,P] = formatp(net,P,Q); if length(err), return, end
  [err,T] = formatt(net,T,Q,TS); if length(err), return, end
  [err,Pi] = formatpi(net,Pi,Q); if length(err), return, end
  [err,Ai] = formatai(net,Ai,Q); if length(err), return, end
  
% Check Cell Arrays
else
  [R,TS] = size(P);
  [R1,Q] = size(P{1,1});
  [err] = checkp(net,P,Q,TS); if length(err), return, end
  [err,T] = checkt(net,T,Q,TS); if length(err), return, end
  [err,Pi] = checkpi(net,Pi,Q); if length(err), return, end
  [err,Ai] = checkai(net,Ai,Q); if length(err), return, end
end

% ============================================================

