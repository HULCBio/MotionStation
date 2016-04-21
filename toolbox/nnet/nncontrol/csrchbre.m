function [up_delta,J,dJdu_old,dJdu,retcode,delta,tol] = csrchbre(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX, ...
   dJdu,J,dperf,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp)

%CSRCHBRE One-dimensional interval location using Brent's method.
%
%  Syntax
%  
%    [up_delta,J,dJdu_old,dJdu,retcode,delta,tol] = csrchbre(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX, ...
%   dJdu,J,dperf,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize)
%
%  Description
%
%    CSRCHBRE is a linear search routine.  It searches in a given direction
%     to locate the minimum of the performance function in that direction.
%     It uses a technique called Brent's method.
%
%  CSRCHBRE(...) takes these inputs,
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
%     Parameters used for the brent algorithm are:
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
%    CSRCHBRE brackets the minimum of the performance function in
%    the search direction dX, using Brent's
%    algorithm described on page 46 of Scales (Introduction to 
%     Non-Linear Estimation 1985). It is a hybrid algorithm based on 
%     the golden section search and quadratic approximation.
%
%  See also CSRCHBAC, CSRCHCHA, CSRCHGOL, CSRCHHYB
%
%   References
%
%     Brent, Introduction to Non-Linear Estimation, 1985.

% Orlando De Jesus, Martin Hagan, 1-30-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 21:11:51 $

tiu   = d-N1+Ni;
upi   = [1:Nu-1 Nu(ones(1,N2-d-Nu+2))];     % [1 2 ... Nu Nu ... Nu] 
uvi   = [tiu:N2-N1+Ni];

% ALGORITHM PARAMETERS
scale_tol = 20;
beta = 0.1;
bmax = 26;

delta_orig=delta;

%INITIALIZE
perfa = J;
a = 0;
u = 1e19;
perfu = 1e19;
cnt1 = 0;
cnt2 = 0;
lambda = delta;

% INTERVAL FOR GOLDEN SECTION SEARCH
tau = 0.618;
tau1 = 1 - tau;

% STEP SIZE INCREASE FACTOR FOR INTERVAL LOCATION (NORMALLY 2)
scale = 2;

% INITIALIZE A AND B
a = 0;
a_old = 0;
b = delta;
perfa = J;
perfa_old = perfa;
  
up_delta = max(min(up + b*dX,max_i),min_i);                  % A priori iteration
u_vec(uvi) = up_delta(upi);                                  % Insert updated controls
     
% CALCULATE PERFORMANCE FOR B
[JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
perfb = JJ;
dJdub = dJJ;

cnt1 = cnt1 + 1;

% INTERVAL LOCATION
% FIND INITIAL INTERVAL WHERE MINIMUM PERF OCCURS
while (perfa>perfb)&(b<bmax)
  a_old=a;
  perfa_old=perfa;
  perfa=perfb;
  a=b;
  b=scale*b;
  up_delta = max(min(up + b*dX,max_i),min_i);                   % A priori iteration
  u_vec(uvi) = up_delta(upi);                                   % Insert updated controls
     
   % CALCULATE PERFORMANCE FOR B
  [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
  perfb = JJ;
  dJdub = dJJ;
  
  cnt1 = cnt1 + 1;
end

if (a == a_old)
  % GET INTERMEDIATE POINT IF NO MIDPOINT EXISTS
  v = a + tau1*(b - a);
  w = v;
  x = v;
  
  up_delta = max(min(up + v*dX,max_i),min_i);                   % A priori iteration
  u_vec(uvi) = up_delta(upi);                                   % Insert updated controls
     
      % CALCULATE PERFORMANCE FOR V
  [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
  perfv = JJ;
  dJduv = dJJ;

  perfw = perfv;
  perfx = perfv;
  cnt1 = cnt1 + 1;
else
  % USE ALREADY COMPUTED VALUE AS INITIAL INTERMEDIATE POINT
  v = a;
  w = v;
  x = v;
  perfv = perfa;
  perfw = perfv;
  perfx = perfv;
  a=a_old;
  perfa=perfa_old;
end

max_int = w;
min_int = w;

% REDUCE THE INTERVAL
while ((b-a)>tol) & (perfx >= J + alpha*x*dperf)

  % QUADRATIC INTERPOLATION
  if (w~=x)&(w~=v)&(x~=v)&( (max_int - min_int) > 0.02*(b-a) )
    [zz,i] = sort([v w x]);
    pp = [perfv perfw perfx];
    pp = pp(i);
    num = (zz(3)^2 - zz(2)^2)*pp(1) + (zz(2)^2 - zz(1)^2)*pp(3) + (zz(1)^2 - zz(3)^2)*pp(2);
    den = (zz(3) - zz(2))*pp(1) + (zz(2) - zz(1))*pp(3) + (zz(1) - zz(3))*pp(2); 
    if den==0
       x_star=Inf;      % ODJ: 1-30-00 If den = 0 then x_star = Inf.
    else
       x_star = 0.5*num/den;
    end
    if (x_star < b)&(a < x_star)
      u = x_star;
      gold_sec = 0;
    else
      gold_sec = 1;
    end
  else
    gold_sec = 1;
  end

  % GOLDEN SECTION 
  if (gold_sec == 1)
    if (x >= (a + b)/2);
      u = x - tau1*(x - a);
    else
      u = x + tau1*(b - x);
    end
  end

  up_delta = max(min(up + u*dX,max_i),min_i);                  % A priori iteration
  u_vec(uvi) = up_delta(upi);                                  % Insert updated controls
     
    % CALCULATE PERFORMANCE FOR B
  [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
  perfu = JJ;
  dJduu = dJJ;

  cnt2 = cnt2 + 1;

  % UPDATE POINTS
  if (perfu <= perfx)
    if (u < x)
      b = x;
      perfb = perfx;
    else
      a = x;
      perfa = perfx;
    end

    v = w; perfv = perfw;
    w = x; perfw = perfx;
    x = u; perfx = perfu;
  else
    if (u < x)
      a = u;
      perfa = perfu;
    else
      b = u;
      perfb = perfu;
    end
    
    if (perfu <= perfw) | (w == x)
      v = w; perfv = perfw;
      w = u; perfw = perfu;
    elseif (perfu <= perfv) | (v == x) | (v == w)
      v = u; perfv = perfu;
    end

  end

  temp = [w x v];
  min_int = min(temp);
  max_int = max(temp);
end


% COMPUTE THE FINAL STEP, FUNCTION VALUE AND GRADIENT
xtot = [a b v w x];
perftot = [perfa perfb perfv perfw perfx];
[perftot,i] = sort(perftot);
xtot = xtot(i);
a = xtot(1);

up_delta = max(min(up + a*dX,max_i),min_i);                  % A priori iteration
u_vec(uvi) = up_delta(upi);                                  % Insert updated controls
     
% CALCULATE PERFORMANCE FOR A
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
