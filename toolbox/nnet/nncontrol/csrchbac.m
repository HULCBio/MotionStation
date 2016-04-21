function [up_delta,J,dJdu_old,dJdu,retcode1,delta,tol] = csrchbac(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX, ...
   dJdu,J,dperfa,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize,minp,maxp)

%CSRCHBAC One-dimensional minimization using backtracking for the NN Predictive Controller.
%
%  Syntax
%  
%    [up_delta,J,dJdu_old,dJdu,retcode1,delta,tol] = csrchbac(up,u_vec,ref,Ai,Nu,N1,N2,d,Ni,Nj,dX, ...
%               dJdu,J,dperfa,delta,rho,dUtilde_dU,alpha,tol,Ts,min_i,max_i,Normalize)
%
%  Description
%
%    CSRCHBAC is a linear search routine.  It searches in a given direction
%     to locate the minimum of the performance function in that direction.
%     It uses a technique called backtracking.
%
%  CSRCHBAC(...) takes these inputs,
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
%      RETCODE  - Return code which has three elements. The first two elements correspond to
%                 the number of function evaluations in the two stages of the search
%                 The third element is a return code. These will have different meanings
%                 for different search algorithms. Some may not be used in this function.
%                   0 - normal; 1 - minimum step taken; 2 - maximum step taken;
%                   3 - beta condition not met.
%      DELTA   - New initial step size. Based on the current step size.
%      TOL     - New tolerance on search.
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
%  Algorithm
%
%    CSRCHBAC locates the minimum of the performance function in
%    the search direction dX, using the backtracking algorithm 
%    described on page 126 and 328 of Dennis and Schnabel.
%     (Numerical Methods for Unconstrained Optimization and Nonlinear Equations 1983).
%
%  See also CSRCHBRE, CSRCHCHA, CSRCHGOL, CSRCHHYB
%
%   References    
%
%     Dennis and Schnabel, Numerical Methods for Unconstrained Optimization
%     and Nonlinear Equations, 1983.

% Orlando De Jesus, Martin Hagan, 1-30-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 21:11:48 $

tiu   = d-N1+Ni;
upi   = [1:Nu-1 Nu(ones(1,N2-d-Nu+2))];     % [1 2 ... Nu Nu ... Nu] 
uvi   = [tiu:N2-N1+Ni];

% ALGORITHM PARAMETERS
delta=1;
scale_tol = 20;
beta = 0.9;
low_lim = 0.1;
up_lim = 0.5;
maxstep = 100;
minstep = 1e-6;
norm_dX = norm(dX);
minlambda = minstep/norm_dX;
maxlambda = maxstep/norm_dX;
cnt1 = 0;
cnt2 = 0;
start = 1;

perfa = J;
delta_orig=delta;

% TAKE INITIAL STEP
lambda = 1;

up_delta = max(min(up + lambda*dX,max_i),min_i);     % A priori iteration
u_vec(uvi) = up_delta(upi);                          % Insert updated controls
     
% CALCULATE PERFORMANCE AT NEW POINT
[JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
perfb = JJ;
dJdub = dJJ;

perfb_old=perfb;
lambda_old=lambda;
g_flag = 0;
cnt1 = cnt1 + 1;

count = 0;
% MINIMIZE ALONG A LINE (BACKTRACKING)
retcode = 4;

while retcode>3
  
  count=count+1;

  if (perfb <= perfa + alpha*lambda*dperfa)         %CONDITION ALPHA IS SATISFIED
 
    if (g_flag == 0)
      dperfb = dJdub'*dX;
    end
  
    if (dperfb < beta * dperfa)                     %CONDITION BETA IS NOT SATISFIED

      if (start==1) & (norm_dX<maxstep)

        while (perfb<=perfa+alpha*lambda*dperfa)&(dperfb<beta*dperfa)&(lambda<maxlambda)

          % INCREASE STEP SIZE UNTIL BETA CONDITION IS SATISFIED

          lambda_old = lambda;
          perfb_old = perfb;
          dJdub_old = dJdub;
          upb_old=up_delta;
          lambda = min ([2*lambda maxlambda]);
          
          up_delta = max(min(up + lambda*dX,max_i),min_i);                % A priori iteration
          u_vec(uvi) = up_delta(upi);                                     % Insert updated controls
     
           % CALCULATE PERFORMANCE AT NEW POINT
          [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
          perfb = JJ;
          dJdub = dJJ;
          
          cnt1 = cnt1 + 1;
          g_flag = 0;
          if (perfb <= perfa+alpha*lambda*dperfa)           
            dperfb = dJdub'*dX;
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
          
          up_delta = max(min(up + lambda*dX,max_i),min_i);                   % A priori iteration
          u_vec(uvi) = up_delta(upi);                                        % Insert updated controls
     
            % CALCULATE PERFORMANCE AT NEW POINT
          [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
          perfb = JJ;
          dJdub = dJJ;
          
          g_flag = 0;
          cnt2 = cnt2 + 1;

          if (perfb>perfa+alpha*lambda*dperfa)
            lambda_diff = lambda_incr;
            perf_hi = perfb;
          else
            dperfb = dJdub'*dX;
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
          
          up_delta = max(min(up + lambda*dX,max_i),min_i);                   % A priori iteration
          u_vec(uvi) = up_delta(upi);                                        % Insert updated controls
     
              % CALCULATE PERFORMANCE AT NEW POINT
          [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
          perfb = JJ;
          dJdub = dJJ;
          
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
   dJdub_old = dJdub;
   upb_old=up_delta;
    
    
  % CHECK TO SEE THAT LAMBDA DOES NOT DECREASE TOO MUCH
  if lambda_temp < low_lim*lambda
    lambda = low_lim*lambda;
  else
    lambda = lambda_temp;
  end
    
  % COMPUTE PERFORMANCE AND SLOPE AT NEW END POINT
    up_delta = max(min(up + lambda*dX,max_i),min_i);                   % A priori iteration
    u_vec(uvi) = up_delta(upi);                                        % Insert updated controls
     
            %----- Determine prediction yhat(t+k,up_delta) -----
    [JJ,dJJ]=calcjjdjj(u_vec,Ni,Nu,Nj,N2,Ai,Ts,ref,tiu,rho,dUtilde_dU,Normalize,minp,maxp);
    perfb = JJ;
    dJdub = dJJ;
    
    g_flag = 0;
    cnt2 = cnt2 + 1;

  end

start = 0;

end

if perfb<=perfb_old
  J=perfb;
  dJdu_old=dJdu;
  dJdu=dJdub;
  a = lambda;
else
  J=perfb_old;
  dJdu_old=dJdu;
  dJdu=dJdub_old;
  up_delta=upb_old;
  a = lambda_old;
end


% CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
delta=a;
if delta < delta_orig
  delta = delta_orig;
end
if tol>delta/scale_tol
  tol=delta/scale_tol;
end

retcode1 = [cnt1 cnt2 retcode];

