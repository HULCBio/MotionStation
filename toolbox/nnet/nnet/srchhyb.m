function [a,gX,perf,retcode,delta,tol] = srchhyb(net,X,Pd,Tl,Ai,Q,TS,dX,gX,perf,dperf,delta,tol,ch_perf)
%SRCHHYB One-dimensional minimization using a hybrid bisection-cubic search.
%
%  Syntax
%  
%    [a,gX,perf,retcode,delta,tol] = srchhyb(net,X,P,T,Q,TS,dX,gX,perf,dperf,delta,tol,ch_perf)
%
%  Description
%
%    SRCHHYB is a linear search routine.  It searches in a given direction
%     to locate the minimum of the performance function in that direction.
%     It uses a technique which is a combination of a bisection and a
%     cubic interpolation.
%
%  SRCHHYB(NET,X,Pd,Tl,Ai,Q,TS,dX,gX,PERF,DPERF,DELTA,TOL,CH_PERF) takes these inputs,
%      NET     - Neural network.
%      X       - Vector containing current values of weights and biases.
%      Pd      - Delayed input vectors.
%      Tl      - Layer target vectors.
%      Ai      - Initial input delay conditions.
%      Q       - Batch size.
%      TS      - Time steps.
%      dX      - Search direction vector.
%      gX      - Gradient vector.
%      PERF    - Performance value at current X.
%      DPERF   - Slope of performance value at current X in direction of dX.
%      DELTA   - Initial step size.
%      TOL     - Tolerance on search.
%      CH_PERF - Change in performance on previous step.
%    and returns,
%      A       - Step size which minimizes performance.
%      gX      - Gradient at new minimum point.
%      PERF    - Performance value at new minimum point.
%      RETCODE - Return code which has three elements. The first two elements correspond to
%                 the number of function evaluations in the two stages of the search
%                The third element is a return code. These will have different meanings
%                 for different search algorithms. Some may not be used in this function.
%                   0 - normal; 1 - minimum step taken; 2 - maximum step taken;
%                   3 - beta condition not met.
%      DELTA   - New initial step size. Based on the current step size.
%      TOL     - New tolerance on search.
%
%    Parameters used for the hybrid bisection-cubic algorithm are:
%      alpha     - Scale factor which determines sufficient reduction in perf.
%      beta      - Scale factor which determines sufficiently large step size.
%      bmax      - Largest step size.
%      scale_tol - Parameter which relates the tolerance tol to the initial step
%                   size delta. Usually set to 20.
%     The defaults for these parameters are set in the training function which
%     calls it.  See TRAINCGF, TRAINCGB, TRAINCGP, TRAINBFG, TRAINOSS
%
%    Dimensions for these variables are:
%      Pd - NoxNixTS cell array, each element P{i,j,ts} is a DijxQ matrix.
%      Tl - NlxTS cell array, each element P{i,ts} is an VixQ matrix.
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
%  Network Use
%
%    You can create a standard network that uses SRCHHYB with
%    NEWFF, NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with TRAINCGF using
%     the line search function SRCHHYB:
%    1) Set NET.trainFcn to 'traincgf'.
%       This will set NET.trainParam to TRAINCGF's default parameters.
%    2) Set NET.trainParam.searchFcn to 'srchhyb'.
%
%    The SRCHHYB function can be used with any of the following
%     training functions: TRAINCGF, TRAINCGB, TRAINCGP, TRAINBFG, TRAINOSS.
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
%    neurons, and the second layer has one LOGSIG neuron.  The TRAINCGF
%     network training function and the SRCHHYB search function are to be used.
%
%      % Create and Test a Network
%      net = newff([0 5],[2 1],{'tansig','logsig'},'traincgf');
%      a = sim(net,p)
%
%      % Train and Retest the Network
%       net.trainParam.searchFcn = 'srchhyb';
%      net.trainParam.epochs = 50;
%      net.trainParam.show = 10;
%      net.trainParam.goal = 0.1;
%      net = train(net,p,t);
%      a = sim(net,p)
%
%
%  Algorithm
%
%    SRCHHYB locates the minimum of the performance function in
%    the search direction dX, using the hybrid
%    bisection-cubic interpolation algorithm described on page 50 of Scales.
%    (Introduction to Non-Linear Estimation 1985)
%
%  See also SRCHBAC, SRCHBRE, SRCHCHA, SRCHGOL
%
%   References
%
%     Scales, Introduction to Non-Linear Estimation, 1985.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:33:36 $

u = 999.9;
perfu = 999.99;
dperfu = 999.99;

% ALGORITHM PARAMETERS
scale_tol = net.trainParam.scale_tol;
alpha = net.trainParam.alpha;
beta = net.trainParam.beta;
bmax = net.trainParam.bmax;
min_grad = net.trainParam.min_grad;

% Parameter Checking
if (~isa(scale_tol,'double')) | (~isreal(scale_tol)) | (any(size(scale_tol)) ~= 1) | ...
  (scale_tol <= 0)
  error('Scale_tol is not a positive real value.')
end
if (~isa(alpha,'double')) | (~isreal(alpha)) | (any(size(alpha)) ~= 1) | ...
  (alpha < 0) | (alpha > 1)
  error('Alpha is not a real value between 0 and 1.')
end
if (~isa(beta,'double')) | (~isreal(beta)) | (any(size(beta)) ~= 1) | ...
  (beta < 0) | (beta > 1)
  error('Beta is not a real value between 0 and 1.')
end
if (~isa(bmax,'double')) | (~isreal(bmax)) | (any(size(bmax)) ~= 1) | ...
  (bmax <= 0)
  error('Bmax is not a positive real value.')
end
if (~isa(min_grad,'double')) | (~isreal(min_grad)) | (any(size(min_grad)) ~= 1) | ...
  (min_grad < 0)
  error('Min_grad is not zero or a positive real value.')
end

% STEP SIZE INCREASE FACTOR FOR INTERVAL LOCATION (NORMALLY 2)
scale = 2;

% INITIALIZE A AND B
a = 0;
a_old = 0;
b = delta;
perfa = perf;
dperfa = dperf;
perfa_old = perfa;
dperfa_old = dperfa;
cnt1 = 0;
cnt2 = 0;
  
% CALCLULATE PERFORMANCE FOR B
X_temp = X + b*dX;
net_temp = setx(net,X_temp);
[perfb,E,Ac,N,Zb,Zi,Zl] = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
gX_temp = -calcgx(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfb,Q,TS);
dperfb = gX_temp'*dX;
cnt1 = cnt1 + 1;

% INTERVAL LOCATION
% FIND INITIAL INTERVAL WHERE MINIMUM PERF OCCURS
while (perfa>perfb)&(b<bmax)
  a_old=a;
  perfa_old = perfa;
  dperfa_old = dperfa;
  perfa = perfb;
  dperfa = dperfb;
  a=b;
  b=scale*b;
  X_temp = X + b*dX;
  net_temp = setx(net,X_temp);
  [perfb,E,Ac,N,Zb,Zi,Zl] = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
  gX_temp = -calcgx(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfb,Q,TS);
  dperfb = gX_temp'*dX;
  cnt1 = cnt1 + 1;
end

if (a == a_old)
  % TAKE INITIAL BISECTION STEP IF NO MIDPOINT EXISTS
  x = (a + b)/2;
  X_step = x*dX;
  X_temp = X + X_step;
  net_temp = setx(net,X_temp);
  [perfx,E,Ac,N,Zb,Zi,Zl] = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
  gX_temp = -calcgx(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfx,Q,TS);
  dperfx = gX_temp'*dX;
  cnt1 = cnt1 + 1;
else
  % USE ALREADY COMPUTED VALUE AS INITIAL BISECTION STEP
  x = a;
  perfx = perfa;
  dperfx = dperfa;
  a=a_old;
  perfa=perfa_old;
  dperfa = dperfa_old;
end
  
% DETERMINE THE W POINT (A OR B WITH MINIMUM FUNCTION VALUE)
if perfa>perfb
  w = b;
  perfw = perfb;
  dperfw = dperfb;
else
  w = a;
  perfw = perfa;
  dperfw = dperfa;
end

% DETERMINE THE OVERALL MINIMUM POINT
minperf = min([perfa perfb perfx]);
amin = a; dperfmin = dperfa;
if perfb<= minperf
  amin = b; dperfmin = dperfb;
elseif perfx <= minperf
  amin = x; dperfmin = dperfx;
end

% LOCATE THE MINIMUM POINT BY THE HYBRID BISECTION-CUBIC SEARCH
while ((b-a)>tol) & ((minperf > perf + alpha*amin*dperf) | abs(dperfmin)>abs(beta*dperf) )

  if(abs(w-x)<.02*(b-a))
    bisection = 1;
  else
    % CUBIC INTERPOLATION
    if (w > x)
      aa = x; fa = perfx; ga = dperfx;
      bb = w; fb = perfw; gb = dperfw;
    else
      bb = x; fb = perfx; gb = dperfx;
      aa = w; fa = perfw; ga = dperfw;
    end
    ww = 3*(fa - fb)/(bb-aa) + ga + gb;
    w_gagb = ww^2 - ga*gb;
    if (w_gagb >= 0)
      v = sqrt(w_gagb);
      u_star = aa + (bb-aa)*(1 - (gb + v - ww)/(gb - ga +2*v));
      if ((u_star > a)&(u_star < b))
        X_temp = X + u_star*dX;
        net_temp = setx(net,X_temp);
        [perfu,E,Ac,N,Zb,Zi,Zl] = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
        gX_temp = -calcgx(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfu,Q,TS);
        dperfu = gX_temp'*dX;
        u = u_star;
        cnt2 = cnt2 + 1;
        bisection = 0;
      else
        bisection = 1;
      end
    else
      bisection = 1;
    end
  end
  
  if (bisection == 1)
    % BISECTION
    if ((dperfa<0) & ((dperfx>0) | (perfx>perfa))) | ((dperfa>0) & (dperfx>0) & (perfx<perfa))
    u = (a + x)/2;
  else
    u = (x + b)/2;
  end
    X_temp = X + u*dX;
    net_temp = setx(net,X_temp);
    [perfu,E,Ac,N,Zb,Zi,Zl] = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
    gX_temp = -calcgx(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfu,Q,TS);
    dperfu = gX_temp'*dX;
    cnt2 = cnt2 + 1;
  end

  if ( dperfu < min_grad )
    a = u; perfa = perfu; dperfa = dperfu;
    b = u; perfb = perfu; dperfb = dperfu;
  elseif (u>x)
    a = x; perfa = perfx; dperfa = dperfx;
  elseif (u<x)
    b = x; perfb = perfx; dperfb = dperfx;
  else
    a = x; perfa = perfx; dperfa = dperfx;
    b = x; perfb = perfx; dperfb = dperfx;
  end
  
  % DETERMINE THE W POINT (A OR B WITH MINIMUM FUNCTION VALUE)
  if perfa>perfb
    w = b;
    perfw = perfb;
    dperfw = dperfb;
  else
    w = a;
    perfw = perfa;
    dperfw = dperfa;
  end

  x = u; perfx = perfu; dperfx = dperfu; 
  
  minperf = min([perfa perfb perfx]);
  amin = a; dperfmin = dperfa;
  if perfb<= minperf
    amin = b; dperfmin = dperfb;
  elseif perfx <= minperf
    amin = x; dperfmin = dperfx;
  end

end
  
perf = minperf;
a = amin;

% COMPUTE FINAL GRADIENT
X = X + a*dX;
net = setx(net,X);
[perf,E,Ac,N,Zb,Zi,Zl] = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
gX = -calcgx(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perf,Q,TS);

% CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
delta=a;
if delta < net.trainParam.delta
  delta = net.trainParam.delta;
end
if tol>delta/scale_tol
  tol=delta/scale_tol;
end


retcode = [cnt1 cnt2 0];
