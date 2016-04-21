function [up_delta,J,dJdu_old,dJdu,retcode,delta,tol] = csrchhyb(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX, ...
   dJdu,J,dperf,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp)

%CSRCHHYB One-dimensional minimization using a hybrid bisection-cubic search.
%
%  Syntax
%  
%    [up_delta,J,dJdu_old,dJdu,retcode,delta,tol] = csrchhyb(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX, ...
%   dJdu,J,dperf,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize)
%
%  Description
%
%    CSRCHHYB is a linear search routine.  It searches in a given direction
%     to locate the minimum of the performance function in that direction.
%     It uses a technique which is a combination of a bisection and a
%     cubic interpolation.
%
%  CSRCHHYB(...) takes these inputs,
%      up       - Plant Inputs during the Control Horizon (Nu).
%      u        - Plant Inputs during the Cost Horizon (N2).
%      ref      - Reference input.
%      Ai       - Initial input delay conditions.
%      Nu       - Control Horizon.
%      N1       - Beginning of the Control and Cost Horizons (Usually 1).
%      N2       - Cost Horizon.
%      d        - Counter that defined intial time (Usually 1).
%      Ni       - Number of delayed plant inputs.
%      Nj       - Number of delayed plant outputs.
%      dX       - Search direction vector for U.
%      dJdu     - Derivate of the cost function respect U.
%      J        - Cost function value.
%      dperfa   - Slope of performance value at current U in direction of dX.
%      delta    - Initial step size.
%      rho      - Control weighting factor.
%      dUtlde_dU - Derivate of the difference of U(t)-U(t-1) respect U.
%      alpha    - Search parameter.
%      tol      - Tolerance on search.
%      Ts       - Time steps.
%      min_i    - Minimum Input to the Plant.
%      max_i    - Maximum Input to the Plant.
%      Normalize - Indicate if the NN has input-output normalized.
%    and returns,
%      up_delta - New Plant Inputs for the Control Horizon (Nu).
%      J        - New Cost function value.
%      dJdu_old - Previous Derivate of the cost function respect U.
%      dJdu     - New Derivate of the cost function respect U.
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
%  Algorithm
%
%    CSRCHHYB locates the minimum of the performance function in
%    the search direction dX, using the hybrid
%    bisection-cubic interpolation algorithm described on page 50 of Scales.
%    (Introduction to Non-Linear Estimation 1985)
%
%  See also CSRCHBAC, CSRCHBRE, CSRCHCHA, CSRCHGOL
%
%   References
%
%     Scales, Introduction to Non-Linear Estimation, 1985.

% Orlando De Jesus, Martin Hagan, 1-30-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/14 21:12:00 $

tiu   = d-N1+Ni;
upi   = [1:Nu-1 Nu(ones(1,N2-d-Nu+2))];     % [1 2 ... Nu Nu ... Nu] 
uvi   = [tiu:N2-N1+Ni];

u = 999.9;
perfu = 999.99;
dperfu = 999.99;

% ALGORITHM PARAMETERS
scale_tol = 20;
beta = 0.9;
bmax = 26;
min_grad = 1e-6;

delta_orig=delta;

% STEP SIZE INCREASE FACTOR FOR INTERVAL LOCATION (NORMALLY 2)
scale = 2;

% INITIALIZE A AND B
a = 0;
a_old = 0;
b = delta;
perfa = J;
dperfa = dperf;
perfa_old = perfa;
dperfa_old = dperfa;
cnt1 = 0;
cnt2 = 0;
  
up_delta = max(min(up + b*dX,max_i),min_i);                 % A priori iteration
u_vec(uvi) = up_delta(upi);                                 % Insert updated controls
     
% CALCLULATE PERFORMANCE FOR B
[JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
perfb = JJ;
dJdub = dJJ;

dperfb = dJdub'*dX;
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
  
  up_delta = max(min(up + b*dX,max_i),min_i);                 % A priori iteration
  u_vec(uvi) = up_delta(upi);                                 % Insert updated controls
     
    % CALCLULATE PERFORMANCE FOR B
  [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
  perfb = JJ;
  dJdub = dJJ;
  
  dperfb = dJdub'*dX;
  cnt1 = cnt1 + 1;
end

if (a == a_old)
  % TAKE INITIAL BISECTION STEP IF NO MIDPOINT EXISTS
  x = (a + b)/2;
  X_step = x*dX;
  
  up_delta = max(min(up + X_step,max_i),min_i);                 % A priori iteration
  u_vec(uvi) = up_delta(upi);                                   % Insert updated controls
     
    % CALCLULATE PERFORMANCE FOR X
  [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
  perfx = JJ;
  dJdux = dJJ;
  
  dperfx = dJdux'*dX;
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
while ((b-a)>tol) & ((minperf > J + alpha*amin*dperf) | abs(dperfmin)>abs(beta*dperf) )

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
        up_delta = max(min(up + u_star*dX,max_i),min_i);                 % A priori iteration
        u_vec(uvi) = up_delta(upi);                                      % Insert updated controls
     
         % CALCLULATE PERFORMANCE FOR U_STAR
        [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
        perfu = JJ;
        dJduu = dJJ;
        
        dperfu = dJduu'*dX;
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
    up_delta = max(min(up + u*dX,max_i),min_i);                 % A priori iteration
    u_vec(uvi) = up_delta(upi);                                 % Insert updated controls
     
      % CALCLULATE PERFORMANCE FOR U
    [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
    perfu = JJ;
    dJduu = dJJ;
        
    dperfu = dJduu'*dX;
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
up_delta = max(min(up + a*dX,max_i),min_i);                 % A priori iteration
u_vec(uvi) = up_delta(upi);                                 % Insert updated controls
     
% CALCLULATE PERFORMANCE FOR FINAL GRADIENT
[JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
J = JJ;
dJdu_old=dJdu;
dJdu = dJJ;

% CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
delta=a;
if delta < delta_orig
  delta = delta_orig;
end
if tol>delta/scale_tol
  tol=delta/scale_tol;
end


retcode = [cnt1 cnt2 0];
