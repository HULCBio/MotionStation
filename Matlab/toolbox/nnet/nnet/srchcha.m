function [a,gX,perf,retcode,delta,tol] = srchcha(net,X,Pd,Tl,Ai,Q,TS,dX,gX,perf,dperf,delta,tol,ch_perf)
%SRCHCHA One-dimensional minimization using the method of Charalambous.
%
%  Syntax
%  
%  [a,gX,perf,retcode,delta,tol] = srchcha(net,X,Pd,Tl,Ai,Q,TS,dX,gX,
%                                               perf,dperf,delta,tol,ch_perf)
%
%  Description
%
%    SRCHCHA is a linear search routine.  It searches in a given direction
%     to locate the minimum of the performance function in that direction.
%     It uses a technique based on the method of Charalambous.
%
%  SRCHCHA(NET,X,Pd,Tl,Ai,Q,TS,dX,gX,PERF,DPERF,DELTA,TOL,CH_PERF) 
%   takes these inputs,
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
%       RETCODE - Return code which has three elements. The first two elements 
%                 correspond to the number of function evaluations in the two
%                 stages of the search.  The third element is a return code.
%                These will have different meanings for different search 
%                 algorithms. Some may not be used in this function.
%                   0 - normal; 1 - minimum step taken; 2 - maximum step taken;
%                   3 - beta condition not met.
%      DELTA   - New initial step size. Based on the current step size.
%      TOL     - New tolerance on search.
%
%    Parameters used for the Charalombous algorithm are:
%      alpha     - Scale factor which determines sufficient reduction in perf.
%      beta      - Scale factor which determines sufficiently large step size.
%      gama      - Parameter to avoid small reductions in performance. Usually 
%                   set to 0.1.
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
%    You can create a standard network that uses SRCHCHA with
%    NEWFF, NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with TRAINCGF using
%     the line search function SRCHCHA:
%    1) Set NET.trainFcn to 'traincgf'.
%       This will set NET.trainParam to TRAINCGF's default parameters.
%    2) Set NET.trainParam.searchFcn to 'srchcha'.
%
%    The SRCHCHA function can be used with any of the following
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
%     network training function and the SRCHCHA search function are to be used.
%
%      % Create and Test a Network
%      net = newff([0 5],[2 1],{'tansig','logsig'},'traincgf');
%      a = sim(net,p)
%
%      % Train and Retest the Network
%       net.trainParam.searchFcn = 'srchcha';
%      net.trainParam.epochs = 50;
%      net.trainParam.show = 10;
%      net.trainParam.goal = 0.1;
%      net = train(net,p,t);
%      a = sim(net,p)
%
%
%  Algorithm
%
%    SRCHCHA locates the minimum of the performance function in
%    the search direction dX, using an algorithm based on
%    the method described in Charalambous (IEE Proc. vol. 139, no. 3, June 1992).
%
%  See also SRCHBAC, SRCHBRE, SRCHGOL, SRCHHYB
%
%   References
%
%     Charalambous, IEEE Proceedings, vol. 139, no. 3, June 1992.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $ $Date: 2002/04/14 21:33:33 $

% ALGORITHM PARAMETERS
scale_tol = net.trainParam.scale_tol;
alpha = net.trainParam.alpha;
beta = net.trainParam.beta;
gama = net.trainParam.gama;
gama1 = 1 - gama;

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
if (~isa(gama,'double')) | (~isreal(gama)) | (any(size(gama)) ~= 1) | ...
  (gama < 0) | (gama > 1)
  error('Gama is not a real value between 0 and 1.')
end

% STEP SIZE INCREASE FACTOR FOR INTERVAL LOCATION 
scale = 3;

% INITIALIZE
a = 0;
a_old = 0;
perfa = perf;
perfa_old = perfa;
dperfa = dperf;
cnt1 = 0;
cnt2 = 0;

% FIND FIRST STEP SIZE
delta_star = -2*ch_perf/dperf;
delta = max([delta delta_star]);
b = delta;

% CALCULATE PERFORMANCE, GRADIENT AND SLOPE AT POINT B
X_temp = X + b*dX;
net_temp = setx(net,X_temp);
[perfb,E,Ac,N,Zb,Zi,Zl] = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
gX_b = -calcgx(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfb,Q,TS);
dperfb = gX_b'*dX;
cnt1 = cnt1 + 1;

if (perfa < perfb)
  amin = a; minperf = perfa; dperfmin = dperfa; gX_1 = gX;
else
  amin = b; minperf = perfb; dperfmin = dperfb; gX_1 = gX_b;
end

bma = b - a;
% LOCATE THE MINIMUM POINT BY THE CHARALAMBOUS METHOD
while ((bma)>tol) & ((minperf > perf + alpha*amin*dperf) | abs(dperfmin)>abs(beta*dperf) )

  % IF THE SLOPE AT B IS NEGATIVE INCREASE OR DECREASE THE STEP SIZE BY SCALE
  if (dperfb < 0)
    % IF FUNCTION IS HIGHER, DECREASE STEP SIZE BY SCALE
    if (perfb > perfa)
      delta = delta/scale;
    % IF FUNCTION IS LOWER, CHANGE THE A POINT AND INCREASE THE STEP SIZE BY SCALE
    else
      delta = scale*delta;
    end
  % IF THE SLOPE AT B IS POSITIVE DO A CUBIC INTERPOLATION FOR THE MINIMUM
  else
    ww = 3*(perfa - perfb)/(b-a) + dperfa + dperfb;
    w_gagb = ww^2 - dperfa*dperfb;
    v = sqrt(w_gagb);
    delta_star =  (b-a)*(1 - (dperfb + v - ww)/(dperfb - dperfa +2*v));
    delta = max( [gama*bma min( [delta_star gama1*bma] )] );
  end

  % CALCULATE PERFORMANCE AND SLOPE AT TEST POINT
  b_test = a + delta;
  X_temp = X + b_test*dX;
  net_temp = setx(net,X_temp);
  [perfbt,E,Ac,N,Zb,Zi,Zl] = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
  gX_temp = -calcgx(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfbt,Q,TS);
  dperfbt = gX_temp'*dX;
  cnt2 = cnt2 + 1;  

  % USE TEST POINT TO UPDATE ENDPOINTS
  if (b_test > b)
    a = b; perfa = perfb; dperfa = dperfb; gX = gX_b;
    b = b_test; perfb = perfbt; dperfb = dperfbt; gX_b = gX_temp;
  else
    if (dperfbt > 0) | (perfbt > perfa)
      b = b_test; perfb = perfbt; dperfb = dperfbt; gX_b = gX_temp;
    else
      a = b_test; perfa = perfbt; dperfa = dperfbt; gX = gX_temp;
    end
  end

  bma = b - a;

  % FIND THE MINIMUM POINT
  if (perfa < perfb)
    amin = a; minperf = perfa; dperfmin = dperfa; gX_1 = gX;
  else
    amin = b; minperf = perfb; dperfmin = dperfb; gX_1 = gX_b;
  end
end
  
a = amin;
perf = minperf;
gX = gX_1;

% CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
delta=amin;
if delta < net.trainParam.delta
  delta = net.trainParam.delta;
end
if tol>delta/scale_tol
  tol=delta/scale_tol;
end


retcode = [cnt1 cnt2 0];
