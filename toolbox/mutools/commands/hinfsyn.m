% function [k,g,gfin,ax,ay,hamx,hamy] =
%                 hinfsyn(p,nmeas,ncon,gmin,gmax,tol,ricmethd,epr,epp,quiet)
%
%  This function computes the H-infinity (sub) optimal n-state
%  controller, using Glover's and Doyle's 1988 result, for a system P.
%  the system P is partitioned:
%                          | a   b1   b2   |
%              p    =      | c1  d11  d12  |
%                          | c2  d21  d22  |
%   where b2 has column size of the number of control inputs (NCON)
%   and c2 has row size of the number of measurements (NMEAS) being
%   provided to the controller.
%
%   inputs:
%      P        -   interconnection matrix for control design
%      NMEAS    -   # controller inputs (np2)
%      NCON     -   # controller outputs (nm2)
%      GMIN     -   lower bound on gamma
%      GMAX     -   upper bound on gamma
%      TOL      -   relative difference between final gamma values
%      RICMETHD -   Riccati solution via
%                     1 - eigenvalue reduction (balance)
%                    -1 - eigenvalue reduction (no balancing)
%                     2 - real schur decomposition  (balance,default)
%                    -2 - real schur decomposition  (no balancing)
%      EPR      -   measure of when real(eig) of Hamiltonian is zero
%                    (default EPR = 1e-10)
%      EPP      -  positive definite determination of xinf solution
%                    (default EPP = 1e-6)
%     QUIET   -   prints out information about H-infinity iteration
%                    0 - do not print results
%                    1 - print results to command window (default)
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
%   See also: H2SYN, H2NORM, HINFFI, HINFNORM, RIC_EIG, and RIC_SCHR

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [k,g,gfin,ax,ay,hamx,hamy] = ...
          hinfsyn(p,nmeas,ncon,gmin,gmax,tol,imethd,epr,epp,quiet)
%
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
rhopcond = 0;
rhofcond = 0;
rhogamdata = [];
minrat = 0.2;
maxrat = 0.8;
k=[]; g =[]; gfin = []; % GJB matlab v5 fix
if nargin == 0
 disp('usage: [k,g,gfin] = hinfsyn(p,nmeas,ncon,gmin,gmax,tol,ricmethd,epr,epp) ')
 return
end
if nargin <= 5
 disp('usage: [k,g,gfin] = hinfsyn(p,nmeas,ncon,gmin,gmax,tol,ricmethd,epr,epp) ')
 error('incorrect number of input arguments')
 return
end
% setup default cases
if nargin == 6
  imethd = 2;
  epr = 1e-10;
  epp = 1e-6;
  quiet = 1;
elseif nargin == 7
  epr = 1e-10;
  epp = 1e-6;
  quiet = 1;
elseif nargin == 8
  epp = 1e-6;
  quiet = 1;
elseif nargin == 9
  quiet = 1;
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
% [p,r12,r21,fail] = hinf_st(p,nmeas,ncon);
  [p,r12,r21,fail,gmin] = hinf_st(p,nmeas,ncon,gmin,gmax,quiet);
  if fail == 1,
    fprintf('\n')
    return
  end

%			gamma iteration

if quiet == 1
	fprintf('Test bounds:  %10.4f <  gamma  <=  %10.4f\n\n',gmin,gmax)
	fprintf('  gamma    hamx_eig  xinf_eig  hamy_eig   yinf_eig   nrho_xy   p/f\n')
end

 while niter==1
  totaliter = totaliter + 1;
  if first_it ==1		% first iteration checks gamma max
    gam = gmax;
  else
    if rhopcond >= 1 & rhofcond >= 1
      [gam,exc] = gpredict(rhogamdata,minrat,maxrat);
      if exc ~= 0
        disp('EXCEPTION')
        gam=((gam2+gam0)/2.);
      end
    else
      gam=((gam2+gam0)/2.);
    end
    gamall=[gam0 gam gam2];
  end
  if quiet == 1
  	if gam < 1000
    	  fprintf('%9.3f  ',gam)
  	else
    	  fprintf('%9.3e  ',gam)
  	end
  end
  [xinf,yinf,f,h,fail,hmx,hmy,hxmin,hymin] = ...
                        hinf_gam(p,nmeas,ncon,epr,gam,imethd);
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
    if quiet == 1
      mprintf(hxmin,'%8.1e',' ');
    end
    if xeig < -epp | xeig == nan    % change to a stablility test
      if quiet == 1
      	mprintf(xeig,' %8.1e','#');
      end
      npass = 1;
    else
      if quiet == 1
      	mprintf(xeig,' %8.1e',' ');
      end
    end

    if quiet == 1
       mprintf(hymin,' %8.1e','  ');
    end
    if yeig < -epp | yeig == nan % change to a stablility test
      if quiet == 1
      	mprintf(yeig,' %8.1e','#');
      end
      npass = 1;
    else
      if quiet == 1
      	mprintf(yeig,' %8.1e',' ');
      end
    end
%   scaled rho(xy)
    if npass == 0
      rhogamdata = [rhogamdata;[xyinfe/gam/gam gam]];
    end
    if xyinfe/gam/gam > 1
      if quiet == 1
      	fprintf('  %7.4f#  ',xyinfe/gam/gam)
      end
      if npass == 0
        npass = 1;
        rhofcond = rhofcond+1;
      end
    else
      if quiet == 1
        fprintf('  %7.4f   ',xyinfe/gam/gam)
      end
      if npass == 0
        rhopcond = rhopcond+1;
      end
    end
  else
    if isempty(xinf)
        if quiet == 1
      		mprintf(hxmin,'%8.1e','#');
      		fprintf('  ******* ')
        end
      	if isempty(yinf)
      		if quiet == 1
        		mprintf(hymin,' %8.1e','# ');
        		fprintf('  ******* ')
        		fprintf('   ******   ')
		end
      	else
        	ye = eig(yinf);
        	yeig = min(real(ye));
		if quiet == 1
        		mprintf(hymin,' %8.1e ',' ');
        		if yeig < -epp | yeig == nan
          			mprintf(yeig,' %8.1e','#');
        		else
          			mprintf(yeig,' %8.1e',' ');
        		end
       		 	fprintf('   ******   ')
      		end
	end
    else
      xe = eig(xinf);
      xeig = min(real(xe));
      if quiet == 1
      		mprintf(hxmin,'%8.1e',' ');
      		if xeig < -epp | xeig == nan
       	 		mprintf(xeig,' %8.1e','#');
      		else
        		mprintf(xeig,' %8.1e',' ');
      		end
      		mprintf(hymin,' %8.1e ','#');
      		fprintf('  ******* ')
      		fprintf('   ******   ')
      end
    end
    npass = 1;
  end

  if quiet == 1
  	if npass == 1
   	  fprintf(' f \n')
  	else
    	  fprintf(' p \n')
  	end
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
     if quiet == 1
     	fprintf('Gamma max, %10.4f, is too small !!\n',gmax);
     end
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
if quiet == 1
	fprintf('\n Gamma value achieved: %10.4f\n',gfin)
end

[k] = hinf_c(p,nmeas,ncon,xinf,yinf,fsave,hsave,gfin,r12,r21);
[g] = starp(pnom,k,nmeas,ncon);

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