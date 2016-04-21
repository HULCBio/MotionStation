% function [k,g,gfin,ax,hamx] = hinffi(p,ncon,gmin,gmax,tol,ricmethd,epr,epp)
%
%  This function computes the FULL INFORMATION h-infinity n-state
%  controller, using Glover's and Doyle's 1988 result,
%  for a system P.  The solution assumes that all the states
%  and disturbances can be measured. The P matrix has the form:
%
%       p  =  | ap  | b1   b2  |
%             | c1  | d11  d12 |
%
%  Care must be taken by the user when closing the loop with the
%  full information controller. For feedback the interconnection
%  structure, P, must be augmented with state and disturbance
%  measurements.
%
%  inputs:
%      P      -   interconnection matrix for control design
%      NCON   -   # controller outputs (nm2)
%      GMIN   -   lower bound on gamma
%      GMAX   -   upper bound on gamma
%      TOL    -   relative difference between final gamma values
%      RICMETHD - Ricatti solution via
%                     1 - eigenvalue reduction (balance)
%                    -1 - eigenvalue reduction (no balancing)
%                     2 - real schur decomposition  (balance,default)
%                    -2 - real schur decomposition  (no balancing)
%      EPR    -   measure of when real(eig) of Hamiltonian is zero
%                  (default EPR = 1e-10)
%      EPP    -   positive definite determination of xinf solution
%                  (default EPP = 1e-6)
%
%  outputs:
%      K      -   H-infinity FULL INFORMATION controller
%      G      -   closed-loop system
%      GFIN   -   final gamma value used in control design
%      AX     -   Riccati solution as a VARYING matrix with independent
%                  variable gamma (optional)
%      HAMX   -   Hamiltonian matrix as a VARYING matrix with independent
%                  variable gamma (optional)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [k,g,gfin,ax,hamx] = hinffi(p,ncon,gmin,gmax,tol,imethd,epr,epp)

%
%   The following assumptions are made:
%    (i)   (a,b2,c2) is stabilizable and detectable
%    (ii)  d12 has full rank
%   on return, the eigenvalues in egs must all be > 0 for the closed-
%   loop system to be stable and to have inf-norm less than gam.
%   this program provides a gamma iteration using a bisection method,
%   it iterates on the value of gam to approach the h-inf optimal
%   full information controller.
%                                    np  nm1  nm2
%   The system p is partitioned:   | a   b1   b2   | np
%                                  | c1  d11  d12  | np1
%
%   Reference Paper:
%    'State-space formulae for all stabilizing controllers
%     that satisfy and h-infinity-norm bound and relations
%     to risk sensitivity,' by keith glover and john doyle,
%     systems & control letters 11, oct, 1988, pp 167-172.
%
storxinf = [];
storhx = [];
gammavecxi = [];
gammavechx = [];

if nargin == 0
  disp('usage: [k,g,gfin,ax,hamx] = hinffi(p,ncon,gmin,gmax,tol,imethd,epr,epp)')
  return
end
if nargin < 5
  disp('usage: [k,g,gfin,ax,hamx]=hinffi(p,ncon,gmin,gmax,tol,imethd,epr,epp)')
  error('incorrect number of input arguments')
  return
end
% setup default cases
if nargin == 5
  imethd = 2;
  epr = 1e-10;
  epp = 1e-6;
elseif nargin == 6
  epr = 1e-10;
  epp = 1e-6;
else
  epp = 1e-10;
end

gam2=gmax;
gam0=gmax;
if gmin > gmax
  error(' gamma min is greater than gamma max')
  return
end
% save the input system to form the closed-loop system
pnom = p;
niter = 1;
npass = 0;
first_it = 1;
totaliter = 0;
% fprintf('checking rank conditions: ');
 [p,q12,r12,fail] = hinffi_t(p,ncon);
 if fail == 1,
    fprintf('\n')
    return
 end

%			gamma iteration

fprintf('Test bounds:  %10.4f <  gamma  <=  %10.4f\n\n',gmin,gmax)
fprintf('   gamma      ham_eig      x_eig      pass/fail\n')

 while niter==1
  totaliter = totaliter + 1;
  if first_it ==1		          % first iteration checks gamma max
    gam = gmax;
  else
    gam=((gam2+gam0)/2.);
    gamall=[gam0 gam gam2];
  end
  fprintf(' %9.3f  ',gam)
  [xinf,f,fail,hmx,hxmin] = hinffi_g(p,ncon,epr,gam,imethd);
  if nargout >= 4
    if isempty(xinf)
      % don't update the matrix
    else
      gammavecxi = [gammavecxi ; gam];
      storxinf = [storxinf ; xinf];
    end
    if nargout >= 5
      if isempty(hmx)
        % don't update the matrix
      else
        gammavechx = [gammavechx ; gam];
        storhx = [storhx ; hmx];
      end
    end
  end
%
% check the conditions for a solution to the FULL INFORMATION
%  h-infinity control problem.
%
  if fail == 0
    xe = eig(xinf);
    xeig = min(real(xe));
    mprintf(hxmin,'%9.2e ',' ');
    if xeig < -epp | xeig == nan    % change to a stablility test
      mprintf(xeig,' %9.2e','#');
      npass = 1;
    else
      mprintf(xeig,' %9.2e',' ');
    end
  else
    mprintf(hxmin,' %9.2e ','#');
    fprintf('  ******** ')
    npass = 1;
  end

  if npass == 1
    fprintf('      fail \n')
  else
    fprintf('      pass \n')
  end
%
% check the gamma iteration
%
 if first_it == 1;
   if npass == 0;
     gam0 = gmin;
     gam2 = gmax;
     xinffin = xinf;
     fsave = f;
     gfin = gmax;
     first_it = 0;
     if gmin == gmax
       niter = 0;           % stop since gmax = gmin
     end
   else
     niter = 0;
     fprintf('Gamma max, %10.4f, is too small !!\n',gmax);
     if nargout >= 4
       ax = vpck(storxinf,gammavecxi);
       if nargout >= 5
         hamx = vpck(storhx,gammavechx);
       end
     end
        return
      end
 else
   if abs(gam - gam0) < tol
     niter = 0;
     if npass == 0
       gfin = gam;
       xinffin = xinf;
       fsave = f;
     else
       gfin = gam2;
     end
   else
     if npass == 0;
       gam2 = gam;
       xinffin = xinf;
       fsave = f;
     else
       gam0 = gam;
     end
   end
   npass = 0;
 end
end
xinf = xinffin;

%  finished with gamma iteration

fprintf('\n Gamma value achieved: %10.4f\n',gfin)

[k] = hinffi_c(p,ncon,fsave,r12);
%
% modify the interconnection structure to form the closed-loop plant
%
[ap,bp,cp,dp,b1,b2,c1,d11,d12,ndata] = hinffi_p(p,ncon);
 np = max(size(ap));
 c21 = eye(np);
 [nr1,nc1] = size(b1);
 c22 = zeros(nc1,np);
 d211 = zeros(np,nc1);
 d212 = eye(nc1);
 [nr2,nc2] = size(b2);
 d221 = zeros(np,nc2);
 d222 = zeros(nc1,nc2);

 [a,b,c,d] = unpck(pnom);
 c = [c; c21; c22];
 d = [d; d211 d221; d212 d222];
 p_fi = pck(a,b,c,d);
%
% form closed-loop system
%
 [g] = starp(p_fi,k,np+nc1,ncon);
  if nargout >= 4
    ax = vpck(storxinf,gammavecxi);
    if nargout >= 5
      hamx = vpck(storhx,gammavechx);
    end
  end
%
%