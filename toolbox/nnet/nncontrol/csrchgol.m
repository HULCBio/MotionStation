function [up_delta,J,dJdu_old,dJdu,retcode,delta,tol] = csrchgol(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX, ...
   dJdu,J,dperf,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp)

%CSRCHGOL One-dimensional minimization using golden section search.
%
%  Syntax
%  
%    [up_delta,J,dJdu_old,dJdu,retcode,delta,tol] = csrchgol(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX, ...
%   dJdu,J,dperf,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize)
%
%  Description
%
%    CSRCHGOL is a linear search routine.  It searches in a given direction
%     to locate the minimum of the performance function in that direction.
%     It uses a technique called the golden section search.
%
%  CSRCHGOL(...) takes these inputs,
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
%  Parameters used for the golden section algorithm are:
%    alpha     - Scale factor which determines sufficient reduction in perf.
%    bmax      - Largest step size.
%    scale_tol - Parameter which relates the tolerance tol to the initial step
%                 size delta. Usually set to 20.
%     The defaults for these parameters are set in the training function which
%     calls it.  See TRAINCGF, TRAINCGB, TRAINCGP, TRAINBFG, TRAINOSS
%
%  Algorithm
%
%    CSRCHGOL locates the minimum of the performance function in
%    the search direction dX, using the
%    golden section search. It is based on the algorithm as
%    described on page 33 of Scales (Introduction to Non-Linear Estimation 1985).
%
%  See also CSRCHBAC, CSRCHBRE, CSRCHCHA, CSRCHHYB
%
%   References
%
%     Scales, Introduction to Non-Linear Estimation, 1985.

% Orlando De Jesus, Martin Hagan, 1-30-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 21:11:57 $

tiu   = d-N1+Ni;
upi   = [1:Nu-1 Nu(ones(1,N2-d-Nu+2))]; 
uvi   = [tiu:N2-N1+Ni];

% ALGORITHM PARAMETERS
delta_orig=delta;
scale_tol = 20;
bmax = 26;
norm_dX=norm(dX);

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
dJdua=dJdu;
dJdua_old=dJdua;
cnt1 = 0;
cnt2 = 0;

up_delta = max(min(up + b*dX,max_i),min_i);                 % A priori iteration
u_vec(uvi) = up_delta(upi);                                 % Insert updated controls
     
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
  dJdua_old=dJdua;
  dJdua=dJdub;
  a=b;
  b=scale*b;
  
  %==============  COMPUTE PREDICTIONS FROM TIME t+N1 TO t+N2  ===============
  up_delta = max(min(up + b*dX,max_i),min_i);                 % A priori iteration
  u_vec(uvi) = up_delta(upi);                                 % Insert updated controls
     
   % CALCULATE PERFORMANCE FOR B
  [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
  perfb = JJ;
  dJdub   = dJJ;
  cnt1 = cnt1 + 1;
end
  
% INITIALIZE C AND D (INTERIOR POINTS FOR LINEAR MINIMIZATION)
if (a == a_old)
  % COMPUTE C POINT IF NO MIDPOINT EXISTS
  c = a + tau1*(b - a);
  %==============  COMPUTE PREDICTIONS FROM TIME t+N1 TO t+N2  ===============
  up_delta = max(min(up + c*dX,max_i),min_i); %up + c*dX;                % A priori iteration
  u_vec(uvi) = up_delta(upi);          % Insert updated controls
     
   % CALCULATE PERFORMANCE FOR C
  [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
  perfc = JJ;
  dJduc = dJJ;
  cnt1 = cnt1 + 1;
else
  % USE ALREADY COMPUTED VALUE AS INITIAL C POINT
  c = a;
  perfc = perfa;
  dJduc = dJdua;
  a=a_old;
  perfa=perfa_old;
  dJdua=dJdua_old;
end

% INITIALIZE D POINT
d=b-tau1*(b-a);
  %==============  COMPUTE PREDICTIONS FROM TIME t+N1 TO t+N2  ===============
up_delta = max(min(up + d*dX,max_i),min_i);                 % A priori iteration
u_vec(uvi) = up_delta(upi);                                 % Insert updated controls
     
   % CALCULATE PERFORMANCE FOR D
[JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
perfd = JJ;
dJdud = dJJ;
cnt1 = cnt1 + 1;
  
minperf = min([perfa perfb perfc perfd]);
if perfb <= minperf
  a_min = b;
  dJdu_min=dJdub;
elseif perfc <= minperf
  a_min = c;
  dJdu_min=dJduc;
elseif perfd <= minperf
  a_min = d;
  dJdu_min=dJdud;
else
  a_min = a;
  dJdu_min=dJdua;
end

% MINIMIZE ALONG A LINE (GOLDEN SECTION SEARCH)
while ((b-a)>tol) & (minperf >= J + alpha*a_min*dperf)

  if ( (perfc<perfd)&(perfb>=min([perfa perfc perfd])) ) | perfa<min([perfb perfc perfd])
    b=d; d=c; perfb=perfd; dJdub=dJdud;
    c=a+tau1*(b-a);
    perfd=perfc; dJdud=dJduc;
      %==============  COMPUTE PREDICTIONS FROM TIME t+N1 TO t+N2  ===============
    up_delta = max(min(up + c*dX,max_i),min_i);                 % A priori iteration
    u_vec(uvi) = up_delta(upi);                                 % Insert updated controls
     
      % CALCULATE PERFORMANCE FOR C
    [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
    perfc = JJ;
    dJduc = dJJ;
    cnt2 = cnt2 + 1;
    if (perfc < minperf)
      minperf = perfc;
      a_min = c;
      dJdu_min=dJduc;
    end
  else
    a=c; c=d; perfa=perfc; dJdua=dJduc;
    d=b-tau1*(b-a);
    perfc=perfd; dJduc=dJdud;
      %==============  COMPUTE PREDICTIONS FROM TIME t+N1 TO t+N2  ===============
    up_delta = max(min(up + d*dX,max_i),min_i);                 % A priori iteration
    u_vec(uvi) = up_delta(upi);                                 % Insert updated controls
     
     % CALCULATE PERFORMANCE FOR D
    [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
    perfd = JJ;
    dJdud = dJJ;
    cnt2 = cnt2 + 1;
    if (perfd < minperf)
      minperf = perfd;
      a_min = d;
      dJdu_min=dJdud;
    end
  end

end

a=a_min;
J_delta = minperf;
dJdu_delta   = dJdu_min;
  %==============  COMPUTE PREDICTIONS FROM TIME t+N1 TO t+N2  ===============
up_delta = max(min(up + a*dX,max_i),min_i);                 % A priori iteration
u_vec(uvi) = up_delta(upi);                                 % Insert updated controls
     
J = J_delta;
dJdu_old = dJdu;
dJdu = dJdu_delta;

% CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
delta=a;
if delta < delta_orig 
   delta = delta_orig; 
end
if tol>delta/scale_tol
  tol=delta/scale_tol;
end

retcode = [cnt1 cnt2 0];
