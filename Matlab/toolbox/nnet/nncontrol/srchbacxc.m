function [a,gX,perfb,retcode1,delta,tol,Ac] = srchbacxc(net,X,Pd,Tl,Ai,Q,TS,dX,gX,perfa,dperfa,delta,tol,ch_perf)
%SRCHBACXC One-dimensional minimization using backtracking.
%
%  Syntax
%  
%    [a,gX,perfb,retcode1,delta,tol,Ac] = srchbacxc(net,X,Pd,Tl,Ai,Q,TS,dX,gX,perfa,dperfa,delta,tol,ch_perf)
%
%  Description
%
%    SRCHBACXC is a linear search routine.  It searches in a given direction
%     to locate the minimum of the performance function in that direction.
%     It uses a technique called backtracking.
%
%  SRCHBAC(NET,X,Pd,Tl,Ai,Q,TS,dX,gX,PERF,DPERF,DELTA,TOL,CH_PERF) takes these inputs,
%      NET     - Neural network.
%      X       - Vector containing current values of weights and biases.
%      Pd      - Delayed input vectors.
%      Tl      - Layer target vectors.
%      Ai      - Initial input delay conditions.
%      Q       - Batch size.
%      TS      - Time steps.
%      dX      - Search direction vector.
%      gX      - Gradient vector.
%      PERFA   - Performance value at current X.
%      DPERFA  - Slope of performance value at current X in direction of dX.
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
%      Ac      - Final input delay conditions.
%
%    Parameters used for the backstepping algorithm are:
%      alpha     - Scale factor which determines sufficient reduction in perf.
%      beta      - Scale factor which determines sufficiently large step size.
%      low_lim   - Lower limit on change in step size.
%      up_lim    - Upper limit on change in step size.
%      maxstep   - Maximum step length.
%      minstep   - Minimum step length.
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
%    You can create a standard network that uses SRCHBAC with
%    NEWFF, NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with TRAINCGF using
%     the line search function SRCHBAC:
%    1) Set NET.trainFcn to 'traincgf'.
%       This will set NET.trainParam to TRAINCGF's default parameters.
%    2) Set NET.trainParam.searchFcn to 'srchbac'.
%
%    The SRCHBAC function can be used with any of the following
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
%     network training function and the SRCHBAC search function are used.
%
%      % Create and Test a Network
%      net = newff([0 5],[2 1],{'tansig','logsig'},'traincgf');
%      a = sim(net,p)
%
%      % Train and Retest the Network
%       net.trainParam.searchFcn = 'srchbac';
%      net.trainParam.epochs = 50;
%      net.trainParam.show = 10;
%      net.trainParam.goal = 0.1;
%      net = train(net,p,t);
%      a = sim(net,p)
%
%
%  Algorithm
%
%    SRCHBAC locates the minimum of the performance function in
%    the search direction dX, using the backtracking algorithm 
%    described on page 126 and 328 of Dennis and Schnabel.
%     (Numerical Methods for Unconstrained Optimization and Nonlinear Equations 1983).
%
%  See also SRCHBRE, SRCHCHA, SRCHGOL, SRCHHYB
%
%   References    
%
%     Dennis and Schnabel, Numerical Methods for Unconstrained Optimization
%     and Nonlinear Equations, 1983.

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/14 21:12:20 $

% ALGORITHM PARAMETERS
scale_tol = net.trainParam.scale_tol;
alpha = net.trainParam.alpha;
beta = net.trainParam.beta;
low_lim = net.trainParam.low_lim;
up_lim = net.trainParam.up_lim;
maxstep = net.trainParam.maxstep;
minstep = net.trainParam.minstep;
norm_dX = norm(dX);
% 8/8/00 ODJ New minimum lambda may depends on dperfa
minlambda = min([minstep/norm_dX minstep/norm(dperfa)]);
maxlambda = maxstep/norm_dX;
cnt1 = 0;
cnt2 = 0;
start = 1;

% TAKE INITIAL STEP
lambda = 1;
X_temp = X + lambda*dX;
net_temp = setx(net,X_temp);
  
% CALCULATE PERFORMANCE AT NEW POINT
[perfb,E,Ac,N,Zb,Zi,Zl] = calcperf2(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
g_flag = 0;
cnt1 = cnt1 + 1;

count = 0;
% MINIMIZE ALONG A LINE (BACKTRACKING)
retcode = 4;

while retcode>3
  
  count=count+1;

  if (perfb <= perfa + alpha*lambda*dperfa)         %CONDITION ALPHA IS SATISFIED
 
    if (g_flag == 0)
      gX_temp = -calcgxmodref(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfb,Q,TS);
      dperfb = gX_temp'*dX;
    end
  
    if (dperfb < beta * dperfa)                     %CONDITION BETA IS NOT SATISFIED

    if (start==1) & (norm_dX<maxstep)

    while (perfb<=perfa+alpha*lambda*dperfa)&(dperfb<beta*dperfa)&(lambda<maxlambda)

          % INCREASE STEP SIZE UNTIL BETA CONDITION IS SATISFIED

          lambda_old = lambda;
          perfb_old = perfb;
          lambda = min ([2*lambda maxlambda]);
          X_temp = X + lambda*dX;
          net_temp = setx(net,X_temp);
          [perfb,E,Ac,N,Zb,Zi,Zl] = calcperf2(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
          cnt1 = cnt1 + 1;
          g_flag = 0;
          if (perfb <= perfa+alpha*lambda*dperfa)           
            gX_temp = -calcgxmodref(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfb,Q,TS);
            dperfb = gX_temp'*dX;
            g_flag = 1;
          end
    end
      end
    
      if (lambda<1) | ((lambda>1)&(perfb>perfa+alpha*lambda*dperfa))
      lambda_lo = min([lambda lambda_old]);
    lambda_diff = abs(lambda_old - lambda);
    
        if (lambda < lambda_old)
          perf_lo = perfb;
          perf_hi = perfb_old;
    else
          perf_lo = perfb_old;
          perf_hi = perfb;
    end
    
        while (dperfb<beta*dperfa)&(lambda_diff>minlambda)
    
          lambda_incr=-dperfb*(lambda_diff^2)/(2*(perf_hi-(perf_lo+dperfb*lambda_diff)));
          if (lambda_incr<0.2*lambda_diff)
        lambda_incr=0.2*lambda_diff;
          end
      
          %UPDATE X
          lambda = lambda_lo + lambda_incr;
          X_temp = X + lambda*dX;
          net_temp = setx(net,X_temp);
          [perfb,E,Ac,N,Zb,Zi,Zl] = calcperf2(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
          g_flag = 0;
          cnt2 = cnt2 + 1;

      if (perfb>perfa+alpha*lambda*dperfa)
            lambda_diff = lambda_incr;
            perf_hi = perfb;
      else
            gX_temp = -calcgxmodref(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfb,Q,TS);
            dperfb = gX_temp'*dX;
            g_flag = 1;
            if (dperfb<beta*dperfa)
              lambda_lo = lambda;
              lambda_diff = lambda_diff - lambda_incr;
              perf_lo = perfb;
            end
          end

        end
    
        retcode = 0;

        if (dperfb<beta*dperfa)    %COULDN'T SATISFY BETA CONDITION
          perfb = perf_lo;
          lambda = lambda_lo;
          X_temp = X + lambda*dX;
          net_temp = setx(net,X_temp);
          [perfb,E,Ac,N,Zb,Zi,Zl] = calcperf2(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
          g_flag = 0;
          cnt2 = cnt2 + 1;
          retcode = 3;
        end
            
      end

      if (lambda*norm_dX>0.99*maxstep)    % MAXIMUM STEP TAKEN
    retcode = 2;
      end

    else
      
      retcode = 0;
    
      if (lambda*norm_dX>0.99*maxstep)    % MAXIMUM STEP TAKEN
        retcode = 2;
      end

    end

  elseif (lambda<minlambda)   % MINIMUM STEPSIZE REACHED

    retcode = 1;

  else    % CONDITION ALPHA IS NOT SATISFIED - REDUCE THE STEP SIZE

    if (start == 1)
      % FIRST BACKTRACK, QUADRATIC FIT
      lambda_temp = -dperfa/(2*(perfb - perfa - dperfa));

    else
      % LOCATE THE MINIMUM OF THE CUBIC INTERPOLATION
      mat_temp = [1/lambda^2 -1/lambda_old^2; -lambda_old/lambda^2 lambda/lambda_old^2];
      mat_temp = mat_temp/(lambda - lambda_old);
      vec_temp = [perfb - perfa - dperfa*lambda; perfb_old - perfa - lambda_old*dperfa];
  
      cub_coef = mat_temp*vec_temp;
      c1 = cub_coef(1); c2 = cub_coef(2);
      disc = c2^2 - 3*c1*dperfa;
      if c1 == 0
        lambda_temp = -dperfa/(2*c2);
      else
        lambda_temp = (-c2 + sqrt(disc))/(3*c1);
      end
    
    end

    % CHECK TO SEE THAT LAMBDA DECREASES ENOUGH
  if lambda_temp > up_lim*lambda
    lambda_temp = up_lim*lambda;
  end
    
  % SAVE OLD VALUES OF LAMBDA AND FUNCTION DERIVATIVE
  lambda_old = lambda;
    perfb_old = perfb;
    
    
  % CHECK TO SEE THAT LAMBDA DOES NOT DECREASE TOO MUCH
  if lambda_temp < low_lim*lambda
    lambda = low_lim*lambda;
  else
    lambda = lambda_temp;
  end
    
  % COMPUTE PERFORMANCE AND SLOPE AT NEW END POINT
    X_temp = X + lambda*dX;
    net_temp = setx(net,X_temp);
    [perfb,E,Ac,N,Zb,Zi,Zl] = calcperf2(net_temp,X_temp,Pd,Tl,Ai,Q,TS);
    g_flag = 0;
    cnt2 = cnt2 + 1;

  end

start = 0;

end

% 8/8/00 ODJ We update variables if results OK.
if perfb <= perfa
   if (g_flag == 0)
      gX = -calcgxmodref(net_temp,X_temp,Pd,Zb,Zi,Zl,N,Ac,E,perfb,Q,TS);
   else
      gX = gX_temp;
   end

   a = lambda;
else
   perfb=perfa;
   % No change
   a=0;        
end

% CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
delta=a;
if delta < net.trainParam.delta
  delta = net.trainParam.delta;
end
%if tol>delta/scale_tol
  tol=delta/scale_tol;
%end

retcode1 = [cnt1 cnt2 retcode];

