function [up_delta,J,dJdu_old,dJdu,retcode,delta,tol] = csrchcha(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX, ...
   dJdu,J,dperf,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp,ch_perf)

%CSRCHCHA One-dimensional minimization using the method of Charalambous.
%
%  Syntax
%  
%    [up_delta,J,dJdu_old,dJdu,retcode,delta,tol] = csrchcha(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX, ...
%   dJdu,J,dperf,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,ch_perf)
%
%  Description
%
%    CSRCHCHA is a linear search routine.  It searches in a given direction
%     to locate the minimum of the performance function in that direction.
%     It uses a technique based on the method of Charalambous.
%
%  CSRCHCHA(...) takes these inputs,
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
%      CH_PERF  - Change in performance on previous step.
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
%    Parameters used for the Charalombous algorithm are:
%      alpha     - Scale factor which determines sufficient reduction in perf.
%      beta      - Scale factor which determines sufficiently large step size.
%      gama      - Parameter to avoid small reductions in performance. Usually set
%                   to 0.1.
%      scale_tol - Parameter which relates the tolerance tol to the initial step
%                   size delta. Usually set to 20.
%     The defaults for these parameters are set in the training function which
%     calls it.  See TRAINCGF, TRAINCGB, TRAINCGP, TRAINBFG, TRAINOSS
%
%  Algorithm
%
%    CSRCHCHA locates the minimum of the performance function in
%    the search direction dX, using an algorithm based on
%    the method described in Charalambous (IEE Proc. vol. 139, no. 3, June 1992).
%
%  See also CSRCHBAC, CSRCHBRE, CSRCHGOL, CSRCHHYB
%
%   References
%
%     Charalambous, IEE Proceedings, vol. 139, no. 3, June 1992.

% Orlando De Jesus, Martin Hagan, 1-30-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 21:11:54 $

tiu   = d-N1+Ni;
upi   = [1:Nu-1 Nu(ones(1,N2-d-Nu+2))];     % [1 2 ... Nu Nu ... Nu] 
uvi   = [tiu:N2-N1+Ni];

% ALGORITHM PARAMETERS
scale_tol = 20;
beta = 0.9;
gama = 0.1;
gama1 = 1 - gama;

delta_orig=delta;

% STEP SIZE INCREASE FACTOR FOR INTERVAL LOCATION 
scale = 3;

% INITIALIZE
a = 0;
a_old = 0;
perfa = J;
perfa_old = perfa;
dperfa = dperf;
if dperfa>=0
   dperfa=dperfa;
end
dJdua=dJdu;
cnt1 = 0;
cnt2 = 0;

% FIND FIRST STEP SIZE
delta_star = -2*ch_perf/dperf;
delta = max([delta delta_star]);
b = delta;

up_delta = max(min(up + b*dX,max_i),min_i);                   % A priori iteration
u_vec(uvi) = up_delta(upi);                                   % Insert updated controls
     
% CALCULATE PERFORMANCE, GRADIENT AND SLOPE AT POINT B
[JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
perfb = JJ;
dJdub = dJJ;

dperfb = dJdub'*dX;
cnt1 = cnt1 + 1;

if (perfa < perfb)
  amin = a; minperf = perfa; dperfmin = dperfa; gX_1 = dJdu;
else
  amin = b; minperf = perfb; dperfmin = dperfb; gX_1 = dJdub;
end

bma = b - a;
% LOCATE THE MINIMUM POINT BY THE CHARALAMBOUS METHOD
while ((bma)>tol) & ((minperf > J + alpha*amin*dperf) | abs(dperfmin)>abs(beta*dperf) )

  % IF THE SLOPE AT B IS NEGATIVE INCREASE OR DECREASE THE STEP SIZE BY SCALE
  if (dperfb < 0)
    % IF FUNCTION IS HIGHER, DECREASE STEP SIZE BY SCALE
    if (perfb >= perfa)  % ODJ 1/28/00 Greater or equal
      delta = delta/scale;
    % IF FUNCTION IS LOWER, CHANGE THE A POINT AND INCREASE THE STEP SIZE BY SCALE
    else
      delta = scale*delta;
    end
  % IF THE SLOPE AT B IS POSITIVE DO A CUBIC INTERPOLATION FOR THE MINIMUM
  else
    ww = 3*(perfa - perfb)/(b-a) + dperfa + dperfb;
    w_gagb = ww^2 - dperfa*dperfb;
    if w_gagb<=0
        w_gagb=w_gagb;
    end
    v = sqrt(w_gagb);
    delta_star =  (b-a)*(1 - (dperfb + v - ww)/(dperfb - dperfa +2*v));
    delta = max( [gama*bma min( [delta_star gama1*bma] )] );
  end

  % CALCULATE PERFORMANCE AND SLOPE AT TEST POINT
  b_test = a + delta;
  up_delta = max(min(up + b*dX,max_i),min_i);                   % A priori iteration
  u_vec(uvi) = up_delta(upi);                                   % Insert updated controls
     
       %----- Determine prediction yhat(t+k,up_delta) -----
  [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
  perfbt = JJ;
  dJdubt = dJJ;
  
  dperfbt = dJdubt'*dX;
  cnt2 = cnt2 + 1;  

  % USE TEST POINT TO UPDATE ENDPOINTS
  if (b_test > b)
    a = b; perfa = perfb; dperfa = dperfb; dJdua = dJdub;
    b = b_test; perfb = perfbt; dperfb = dperfbt; dJdub = dJdubt;
  else
    if (dperfbt > 0) | (perfbt >= perfa)  % ODJ 1/28/00 Greater or equal
      b = b_test; perfb = perfbt; dperfb = dperfbt; dJdub = dJdubt;
    else
      a = b_test; perfa = perfbt; dperfa = dperfbt; dJdua = dJdubt;
    end
  end

  bma = b - a;

  % FIND THE MINIMUM POINT
  if (perfa < perfb)
    amin = a; minperf = perfa; dperfmin = dperfa; gX_1 = dJdua;
  else
    amin = b; minperf = perfb; dperfmin = dperfb; gX_1 = dJdub;
  end
end
  
a = amin;
J = minperf;
dJdu_old=dJdu;
dJdu = gX_1;

% CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
delta=amin;
if delta < delta_orig
  delta = delta_orig;
end
if tol>delta/scale_tol
  tol=delta/scale_tol;
end


retcode = [cnt1 cnt2 0];
