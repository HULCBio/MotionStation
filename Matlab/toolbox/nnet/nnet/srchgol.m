function [a,gX,perf,retcode,delta,tol] = srchgol(net,X,Pd,Tl,Ai,Q,TS,dX,gX,perf,dperf,delta,tol,ch_perf)
%SRCHGOL One-dimensional minimization using golden section search.
%
%  Syntax
%  
%    [a,gX,perf,retcode,delta,tol] = srchgol(net,X,Pd,Tl,Ai,Q,TS,dX,gX,perf,dperf,delta,tol,ch_perf)
%
%  Description
%
%    SRCHGOL is a linear search routine.  It searches in a given direction
%     to locate the minimum of the performance function in that direction.
%     It uses a technique called the golden section search.
%
%  SRCHGOL(NET,X,Pd,Tl,Ai,Q,TS,dX,gX,PERF,DPERF,DELTA,TOL,CH_PERF) takes these inputs,
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
%  Parameters used for the golden section algorithm are:
%    alpha     - Scale factor which determines sufficient reduction in perf.
%    bmax      - Largest step size.
%    scale_tol - Parameter which relates the tolerance tol to the initial step
%                 size delta. Usually set to 20.
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
%    You can create a standard network that uses SRCHGOL with
%    NEWFF, NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with TRAINCGF using the 
%     line search function SRCHGOL:
%     
%    1) Set NET.trainFcn to 'traincgf'.
%       This will set NET.trainParam to TRAINCGF's default parameters.
%    2) Set NET.trainParam.searchFcn to 'srchgol'.
%
%    The SRCHGOL function can be used with any of the following
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
%     network training function and the SRCHGOL search function are to be used.
%
%      % Create and Test a Network
%      net = newff([0 5],[2 1],{'tansig','logsig'},'traincgf');
%      a = sim(net,p)
%
%      % Train and Retest the Network
%       net.trainParam.searchFcn = 'srchgol';
%      net.trainParam.epochs = 50;
%      net.trainParam.show = 10;
%      net.trainParam.goal = 0.1;
%      net = train(net,p,t);
%      a = sim(net,p)
%
%
%  Algorithm
%
%    SRCHGOL locates the minimum of the performance function in
%    the search direction dX, using the
%    golden section search. It is based on the algorithm as
%    described on page 33 of Scales (Introduction to Non-Linear Estimation 1985).
%
%  See also SRCHBAC, SRCHBRE, SRCHCHA, SRCHHYB
%
%   References
%
%     Scales, Introduction to Non-Linear Estimation, 1985.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:33:08 $

% ALGORITHM PARAMETERS
scale_tol = net.trainParam.scale_tol;
alpha = net.trainParam.alpha;
bmax = net.trainParam.bmax;
norm_dX=norm(dX);

% Parameter Checking
if (~isa(scale_tol,'double')) | (~isreal(scale_tol)) | (any(size(scale_tol)) ~= 1) | ...
  (scale_tol <= 0)
  error('Scale_tol is not a positive real value.')
end
if (~isa(alpha,'double')) | (~isreal(alpha)) | (any(size(alpha)) ~= 1) | ...
  (alpha < 0) | (alpha > 1)
  error('Alpha is not a real value between 0 and 1.')
end
if (~isa(bmax,'double')) | (~isreal(bmax)) | (any(size(bmax)) ~= 1) | ...
  (bmax <= 0)
  error('Bmax is not a positive real value.')
end

% INTERVAL FOR GOLDEN SECTION SEARCH
tau = 0.618;
tau1 = 1 - tau;

% STEP SIZE INCREASE FACTOR FOR INTERVAL LOCATION (NORMALLY 2)
scale = 2;

% INITIALIZE A AND B
a = 0;
a_old = 0;
b = delta;
perfa = perf;
perfa_old = perfa;
cnt1 = 0;
cnt2 = 0;

% CALCLULATE PERFORMANCE FOR B
X_temp = X + b*dX;
net_temp = setx(net,X_temp);
perfb = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
cnt1 = cnt1 + 1;
  
% INTERVAL LOCATION
% FIND INITIAL INTERVAL WHERE MINIMUM PERF OCCURS
while (perfa>perfb)&(b<bmax)
  a_old=a;
  perfa_old=perfa;
  perfa=perfb;
  a=b;
  b=scale*b;
  X_temp = X + b*dX;
  net_temp = setx(net,X_temp);
  perfb = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
  cnt1 = cnt1 + 1;
end
  
% INITIALIZE C AND D (INTERIOR POINTS FOR LINEAR MINIMIZATION)
if (a == a_old)
  % COMPUTE C POINT IF NO MIDPOINT EXISTS
  c = a + tau1*(b - a);
  X_temp = X + c*dX;
  net_temp = setx(net,X_temp);
  perfc = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
  cnt1 = cnt1 + 1;
else
  % USE ALREADY COMPUTED VALUE AS INITIAL C POINT
  c = a;
  perfc = perfa;
  a=a_old;
  perfa=perfa_old;
end

% INITIALIZE D POINT
d=b-tau1*(b-a);
X_temp = X + d*dX;
net_temp = setx(net,X_temp);
perfd = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
cnt1 = cnt1 + 1;
  
minperf = min([perfa perfb perfc perfd]);
if perfb <= minperf
  a_min = b;
elseif perfc <= minperf
  a_min = c;
elseif perfd <= minperf
  a_min = d;
else
  a_min = a;
end

% MINIMIZE ALONG A LINE (GOLDEN SECTION SEARCH)
while ((b-a)>tol) & (minperf >= perf + alpha*a_min*dperf)

  if ( (perfc<perfd)&(perfb>=min([perfa perfc perfd])) ) | perfa<min([perfb perfc perfd])
    b=d; d=c; perfb=perfd;
    c=a+tau1*(b-a);
    perfd=perfc;
    X_temp = X + c*dX;
    net_temp = setx(net,X_temp);
    perfc = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
    cnt2 = cnt2 + 1;
    if (perfc < minperf)
      minperf = perfc;
      a_min = c;
    end
  else
    a=c; c=d; perfa=perfc;
    d=b-tau1*(b-a);
    perfc=perfd;
    X_temp = X + d*dX;
    net_temp = setx(net,X_temp);
    perfd = calcperf(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
    cnt2 = cnt2 + 1;
    if (perfd < minperf)
      minperf = perfd;
      a_min = d;
    end
  end

end

a=a_min;
perf = minperf;
X = X + a*dX;
net = setx(net,X);
[perf,E,Ac,N,Zb,Zi,Zl] = calcperf(net,X,Pd,Tl,Ai,Q,TS);
gX = -calcgx(net,X,Pd,Zb,Zi,Zl,N,Ac,E,perf,Q,TS);

% CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
delta=a;
if delta < net.trainParam.delta
  delta = net.trainParam.delta;
end
if tol>delta/scale_tol
  tol=delta/scale_tol;
end

retcode = [cnt1 cnt2 0];
