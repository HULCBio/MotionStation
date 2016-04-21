% function [k,g,gfin,ax,ay,hamx,hamy] =
%                hinfsyne(p,nmeas,ncon,gmin,gmax,tol,s0,quiet,ricmethd,epr,epp)
%
%  This function computes the H-infinity (sub) optimal n-state
%  controller, using Glover and Doyle's 1988 result, for a system P.
%  the system P is partitioned:
%                          | a   b1   b2   |
%              p    =      | c1  d11  d12  |
%                          | c2  d21  d22  |
%   where b2 has column size of the number of control inputs (NCON)
%   and c2 has row size of the number of measurements (NMEAS) being
%   provided to the controller.  Gives the extremal entropy solution
%   at the point s=s0.
%
%   inputs:
%      P        -   interconnection matrix for control design
%      NMEAS    -   # controller inputs (np2)
%      NCON     -   # controller outputs (nm2)
%      GMIN     -   lower bound on gamma
%      GMAX     -   upper bound on gamma
%      TOL      -   relative difference between final gamma values
%      S0       -   point about which entropy is extremised (>0)
%                    (default S0=inf)
%                    if S0<=0 then all solutions are parametrized in K and G
%                    as starp(K,Phi) with norm of Phi < gfin.
%      QUIET    -   controls printing on screen:
%                     1 - no printing
%                     0 - header not printed
%                    -1 - full printing (default)
%      RICMETHD -   Riccati solution via
%                     1 - eigenvalue reduction (balance)
%                    -1 - eigenvalue reduction (no balancing)
%                     2 - real schur decomposition  (balance,default)
%                    -2 - real schur decomposition  (no balancing)
%      EPR      -   measure of when real(eig) of Hamiltonian is zero
%                    (default EPR = 1e-10)
%      EPP      -  positive definite determination of xinf solution
%                    (default EPP = 1e-6)
%
%    outputs:
%      K       -   H-infinity controller
%      G       -   closed-loop system
%      GFIN    -   final gamma value used in control design
%      AX      -   X-Riccati solution as a VARYING matrix with
%                     independent variable gamma (optional)
%      AY      -   Y-Riccati solution as a VARYING matrix with
%                      independent variable gamma (optional)
%      HAMX    -   X-Hamiltonian matrix as a VARYING matrix with
%                      independent variable gamma (optional)
%      HAMY    -   Y-Hamiltonian matrix as a VARYING matrix with
%                      independent variable gamma (optional)
%
%   See also: DHFSYN, H2SYN, H2NORM, HINFFI, HINFNORM, RIC_EIG, RIC_SCHR,
%             SDHFNORM, and SDHFSYN

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [k,g,gfin,ax,ay,hamx,hamy] = ...
            hinfsyne(p,nmeas,ncon,gmin,gmax,tol,s0,quiet,ricmethd,epr,epp)

%   the following assumptions are made:
%    (i)   (a,b2,c2) is stabilizable and detectable
%    (ii)  d12 and d21 have full rank
%     on return, the eigenvalues in egs must all be > 0
%     for the closed-loop system to be stable and to
%     have inf-norm less than GAM.
%     this program provides a gamma iteration using a
%     bisection method, it iterates on the value
%     of GAM to approach the H-inf optimal controller.
%                                    np  nm1  nm2
%   The system p is partitioned:   | a   b1   b2   | np
%                                  | c1  d11  d12  | np1
%                                  | c2  d21  d22  | np2
%
% Reference Paper:
%       'State-space formulae for all stabilizing controllers
%         that satisfy and h-infinity-norm bound and relations
%         to risk sensitivity,' by keith glover and john doyle,
%         systems & control letters 11, oct, 1988, pp 167-172.

storxinf = [];
storyinf = [];
storhx = [];
storhy = [];
gammavecxi = [];
gammavecyi = [];
gammavechx = [];
gammavechy = [];

k    = [];
g    = [];
gfin = [];
ax   = [];
ay   = [];
hamx = [];
hamy = [];

if nargin == 0
 disp('usage: [k,g,gfin] = ')
 disp('     hinfsyne(p,nmeas,ncon,gmin,gmax,tol,s0,quiet,ricmethd,epr,epp) ')
 return
end
if nargin <= 5
 disp('usage: [k,g,gfin] = ')
 disp('     hinfsyne(p,nmeas,ncon,gmin,gmax,tol,s0,quiet,ricmethd,epr,epp) ')
 error('incorrect number of input arguments')
 return
end

% setup default cases
if nargin == 6
  s0=inf;
  quiet=-1;
  ricmethd = 2;
  epr = 1e-10;
  epp = 1e-6;
elseif nargin == 7
  quiet=-1;
  ricmethd = 2;
  epr = 1e-10;
  epp = 1e-6;
elseif nargin == 8
  ricmethd = 2;
  epr = 1e-10;
  epp = 1e-6;
elseif nargin == 9
  epr = 1e-10;
  epp = 1e-6;
elseif nargin == 10
  epp = 1e-6;
end

gam2=gmax;
gam0=gmax;
if gmin > gmax
  error(' GAMMA MIN is greater than GAMMA MAX')
  return
end
% save the input system to form the closed-loop system
pnom = p;
niter = 1;
npass = 0;
first_it = 1;
totaliter = 0;
% fprintf('checking rank conditions: ');
% [p,r12,r21,fail] = hinf_st(p,nmeas,ncon);
  [p,r12,r21,fail,gmin] = hinf_st(p,nmeas,ncon,gmin,gmax,abs(quiet-1));
  if fail == 1,
    if quiet<=0,
      fprintf('\n');
    end
    return
  end

%			gamma iteration
if quiet<0,
fprintf('Test bounds:  %10.4f <  gamma  <=  %10.4f\n\n',gmin,gmax)
fprintf('  gamma    hamx_eig  xinf_eig  hamy_eig   yinf_eig   nrho_xy   p/f\n')
end, %if quiet
 while niter==1
  totaliter = totaliter + 1;
  if first_it ==1		% first iteration checks gamma max
    gam = gmax;
  else
    gam=((gam2+gam0)/2.);
    gamall=[gam0 gam gam2];
  end
  if gam < 1000
     if quiet<=0, fprintf('%9.3f  ',gam), end
   else
     if quiet<=0, fprintf('%9.3e  ',gam), end
    end

  [xinf,yinf,f,h,fail,hmx,hmy,hxmin,hymin] = ...
                    hinf_gam(p,nmeas,ncon,epr,gam,ricmethd);
  if nargout >= 4
    if isempty(xinf)
      % don't update the matrix
    else
      gammavecxi = [gammavecxi ; gam];
      storxinf = [storxinf ; xinf];
    end
    if nargout >= 5
      if isempty(yinf)
        % don't update the matrix
      else
        gammavecyi = [gammavecyi ; gam];
        storyinf = [storyinf ; yinf];
      end
      if nargout >= 6
        if isempty(hmx)
          % don't update the matrix
        else
          gammavechx = [gammavechx ; gam];
          storhx = [storhx ; hmx];
        end
        if nargout >= 7
          if isempty(hmy)
            % don't update the matrix
          else
           gammavechy = [gammavechy ; gam];
           storhy = [storhy ; hmy];
          end
        end
      end
    end
  end
%
% check the conditions for a solution to the h-infinity control problem
%
  if fail == 0
    xe = eig(xinf);
    ye = eig(yinf);
    xye = eig(xinf*yinf);
    xeig = min(real(xe));
    yeig = min(real(ye));
    xyinfe = max(abs(xye));
    if quiet<=0, mprintf(hxmin,'%8.1e',' '); end
    if xeig < -epp | xeig == nan    % change to a stablility test
      if quiet<=0, mprintf(xeig,' %8.1e','#');
        end
      npass = 1;
    else
     if quiet<=0, mprintf(xeig,' %8.1e',' ');end
    end

    if quiet<=0, mprintf(hymin,' %8.1e','  ');end
    if yeig < -epp | yeig == nan % change to a stablility test
     if quiet<=0, mprintf(yeig,' %8.1e','#'); end
      npass = 1;
    else
     if quiet<=0, mprintf(yeig,' %8.1e',' '); end
    end
%   scaled rho(xy)
    if xyinfe/gam/gam >= 1
     if quiet<=0, fprintf('  %7.4f#  ',xyinfe/gam/gam), end
      npass = 1;
    else
     if quiet<=0, fprintf('  %7.4f   ',xyinfe/gam/gam), end
    end

  else
    if isempty(xinf)
      if quiet<=0, mprintf(hxmin,'%8.1e','#'); end
      if quiet<=0, fprintf('  ******* '), end
      if isempty(yinf)
        if quiet<=0, mprintf(hymin,' %8.1e ','#'); end
        if quiet<=0, fprintf('  ******* '), end
        if quiet<=0, fprintf('   ******   '), end
      else
        ye = eig(yinf);
        yeig = min(real(ye));
        if quiet<=0, mprintf(hymin,' %8.1e ',' '); end
        if yeig < -epp | yeig == nan
          if quiet<=0, mprintf(yeig,' %8.1e','#'); end
        else
          if quiet<=0, mprintf(yeig,' %8.1e',' '); end
        end
        if quiet<=0, fprintf('   ******   '), end
      end
    else
      xe = eig(xinf);
      xeig = min(real(xe));
      if quiet<=0, mprintf(hxmin,'%8.1e',' '); end
      if xeig < -epp | xeig == nan
        if quiet<=0, mprintf(xeig,' %8.1e','#'); end
      else
        if quiet<=0, mprintf(xeig,' %8.1e',' '); end
      end
      if quiet<=0, mprintf(hymin,' %8.1e ','#'); end
      if quiet<=0, fprintf('  ******* '), end
      if quiet<=0, fprintf('   ******   '), end
    end
    npass = 1;
  end

  if npass == 1
    if quiet<=0, fprintf(' f \n'), end
  else
    if quiet<=0, fprintf(' p \n'), end
  end
%
% check the gamma iteration
%
 if first_it == 1;
   if npass == 0;
     gam0 = gmin;
     gam2 = gmax;
     xinffin = xinf;
     yinffin = yinf;
     fsave = f;
     hsave = h;
     gfin = gmax;
     first_it = 0;
     if gmin == gmax
       niter = 0;           % stop since gmax = gmin
     end
   else
     niter = 0;
     if quiet<0, fprintf('Gamma max, %10.4f, is too small !!\n',gmax); end
% save output data
     if nargout >= 4
       ax = vpck(storxinf,gammavecxi);
       if nargout >= 5
         ay = vpck(storyinf,gammavecyi);
         if nargout >= 6
           hamx = vpck(storhx,gammavechx);
           if nargout >= 7
             hamy = vpck(storhy,gammavechy);
           end
         end
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
       yinffin = yinf;
     fsave = f;
     hsave = h;
     else
       gfin = gam2;
     end
   else
     if npass == 0;
       gam2 = gam;
       xinffin = xinf;
       yinffin = yinf;
     fsave = f;
     hsave = h;
     else
       gam0 = gam;
     end
   end
   npass = 0;
 end
end
xinf = xinffin;
yinf = yinffin;
%  finished with gamma iteration
if quiet<0, fprintf('\n Gamma value achieved: %10.4f\n',gfin), end

[ka] = hinfe_c(p,nmeas,ncon,xinf,yinf,fsave,hsave,gfin,r12,r21);


[ga] = starp(pnom,ka,nmeas,ncon);
[a,b,c,d]=unpck(ga);
[type,nout,nin,nstates]=minfo(ga);

% get extremal entropy solution for Phi=g22(s0)*gfin^2
if s0 == inf,
    k=sel(ka,1:ncon,1:nmeas);
    g=sel(ga,1:nout-nmeas,1:nin-ncon);
  elseif s0>0,
    Phi=(d(nout-nmeas+1:nout,nin-ncon+1:nin)+(c(nout-nmeas+1:nout,:)/...
          (eye(nstates)*s0-a))*b(:,nin-ncon+1:nin))'*gfin^2;
    k=starp(ka,Phi);
    g=starp(ga,Phi);
  else % s0<0 so give all solns.
    k=ka;
    g=ga;
 end; %if s0 == inf


% save output data
  if nargout >= 4
    ax = vpck(storxinf,gammavecxi);
    if nargout >= 5
      ay = vpck(storyinf,gammavecyi);
      if nargout >= 6
        hamx = vpck(storhx,gammavechx);
        if nargout >= 7
          hamy = vpck(storhy,gammavechy);
        end
      end
    end
  end
%
%