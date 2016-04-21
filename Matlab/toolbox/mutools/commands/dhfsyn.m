% function [k,g,gfin,ax,ay,hamx,hamy] =
%         dhfsyn(p,nmeas,ncon,gmin,gmax,tol,h,z0,quiet,ricmethd,epr,epp)
%
%  This function computes the H-infinity (sub) optimal n-state
%  controller, for a discrete time system, P, using a bilinear transformation
%  to continuous time and then calling HINFSYNE.
%  the system P is partitioned:
%                          | a   b1   b2   |
%              p    =      | c1  d11  d12  |
%                          | c2  d21  d22  |
%   where b2 has column size of the number of control inputs (NCON)
%   and c2 has row size of the number of measurements (NMEAS) being
%   provided to the controller.  Gives the extremal entropy solution
%   at the point z=z0.
%
%   Inputs:
%      P        -   interconnection matrix for control design (discrete time)
%      NMEAS    -   # controller inputs (np2)
%      NCON     -   # controller outputs (nm2)
%      GMIN     -   lower bound on gamma
%      GMAX     -   upper bound on gamma
%      TOL      -   relative difference between final gamma values
%      H        -   sampling period (default=1)
%      Z0       -   point about which entropy is extremised (ABS(Z0)>1)
%                    (default Z0=inf)
%                    if ABS(Z0)>1 then all solutions are parametrized in K and G
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
%    Outputs:
%      K       -   H-infinity controller (discrete time)
%      G       -   closed-loop system    (discrete time)
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
%   See also: DHFNORM, DTRSP, H2SYN, H2NORM, HINFFI, HINFNORM, RIC_EIG, RIC_SCHR%              SDHFNORM, SDHFSYN, and SDTRSP

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [k,g,gfin,ax,ay,hamx,hamy] = ...
         dhfsyn(p,nmeas,ncon,gmin,gmax,tol,h,z0,quiet,ricmethd,epr,epp)

%   the following assumptions are made:
%    (i)   (a,b2,c2) is stabilizable and detectable
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

if nargin == 0
 disp('usage: [k,g,gfin] = ')
 disp('     dhfsyn(p,nmeas,ncon,gmin,gmax,tol,h,z0,quiet,ricmethd,epr,epp) ')
 return
end
if nargin <= 5
 disp('usage: [k,g,gfin] = ')
 disp('     dhfsyn(p,nmeas,ncon,gmin,gmax,tol,h,z0,quiet,ricmethd,epr,epp) ')
 error('incorrect number of input arguments')
 return
end
% setup default cases
if nargin == 6
  h=1;
  z0=inf;
  quiet=0;
  ricmethd = 2;
  epr = 1e-10;
  epp = 1e-6;
elseif nargin == 7
  z0=inf;
  quiet=0;
  ricmethd = 2;
  epr = 1e-10;
  epp = 1e-6;
elseif nargin == 8
  quiet=-1;
  ricmethd = 2;
  epr = 1e-10;
  epp = 1e-6;
elseif nargin == 9
  ricmethd = 2;
  epr = 1e-10;
  epp = 1e-6;
elseif nargin == 10
  epr = 1e-10;
  epp = 1e-6;
elseif nargin == 11
  epp = 1e-6;
end

% transform to continuous time
% firstly introduce constant output feedback if p has poles near -1
F=dhinf_p(p,nmeas,ncon,1e-5);
p_F=starp(p,[F eye(ncon); eye(nmeas) zeros(nmeas,ncon)],nmeas,ncon);
p_c=bilinz2s(p_F,h);
if z0 == inf,
     s0=2/h;
   else
     s0=(2/h)*(z0-1)/(z0+1);
  end; %if z0 == inf
% now remove the D22 term
[type,nrow,ncol,nstates]=minfo(p_c);
d22=p_c(nstates+nrow-nmeas+1:nstates+nrow,nstates+ncol-ncon+1:nstates+ncol);
p_c(nstates+nrow-nmeas+1:nstates+nrow,nstates+ncol-ncon+1:nstates+ncol)=...
    zeros(nmeas,ncon);

[k_cF,g_c,gfin,ax,ay,hamx,hamy] = ...
        hinfsyne(p_c,nmeas,ncon,gmin,gmax,tol,s0,quiet,ricmethd,epr,epp);

if ~isempty(k_cF),
   k_c=starp([zeros(ncon,nmeas) eye(ncon); eye(nmeas) -d22],k_cF,nmeas,ncon);
   k_c=starp([F eye(ncon); eye(nmeas) zeros(nmeas,ncon)],k_c,nmeas,ncon);
   k=bilins2z(k_c,h);
   g=bilins2z(g_c,h);
else
   k = []; % Added for matlab v5
   g = []; % Added for matlab v5
end;
%