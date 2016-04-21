%function [k,gfin]=
%	sdhfsyn(sdsys,nmeas,ncon,gmin,gmax,tol,h,delay,ricmethd,epr,epp,quiet)
%
%  This function computes the H-infinity (sub) optimal n-state
%  discrete-time controller for a sampled-data system.  Using
%  results from Bamieh and Pearson '92, the initial problem is
%  converted isomorphically to discrete-time.  The discrete-time
%  problem is bilinearly mapped to continuous-time where Glover's
%  and Doyle's 1988 result is used.
%
%  The continuous-time plant SDSYS is partitioned:
%                          | a   b1   b2   |
%              sdsys    =  | c1   0    0   |
%                          | c2   0    0   |
%   where b2 has column size of the number of control inputs (NCON)
%   and c2 has row size of the number of measurements (NMEAS) being
%   provided to the controller.  Note that d must be zero.
%
%   Inputs:
%      SDSYS    -   interconnection matrix for control design
%                    (continuous time)
%      NMEAS    -   # controller inputs (np2)
%      NCON     -   # controller outputs (nm2)
%      GMIN     -   lower bound on gamma (MUST BE GREATER THAN 0)
%      GMAX     -   upper bound on gamma
%      TOL      -   relative difference between final gamma values
%      H        -   sampling period of the controller to be designed
%      DELAY    -   a non-negative integer giving the number of
%                   computational delays of the controller (default is 0)
%      RICMETHD -   Riccati solution via
%                     1 - eigenvalue reduction (balance)
%                    -1 - eigenvalue reduction (no balancing)
%                     2 - real schur decomposition  (balance,default)
%                    -2 - real schur decomposition  (no balancing)
%      EPR      -   measure of when real(eig) of Hamiltonian is zero
%                    (default EPR = 1e-10)
%      EPP      -   positive definite determination of xinf solution
%                    (default EPP = 1e-6)
%      QUIET    -   print out information on sampled-data H-infinity iteration
%                    0 - do not print results
%                    1 - print results to command window (default)
%
%
%    Outputs:
%      K       -   H-infinity controller (discrete time)
%      GFIN    -   final gamma value used in control design
%
%	                _________
%	               |         |
%	       <-------|  sdsys  |<--------
%	               |         |
%	      /--------|_________|<-----\
%	      |       __  		 |
%	      |      |d |		 |
%	      |  __  |e |   ___    __    |
%	      |_|S |_|l |__| K |__|H |___|
%	        |__| |a |  |___|  |__|
%	             |y |
%	             |__|
%
%   See also: DHFNORM, DHFSYN, DTRSP, H2SYN, H2NORM, HINFFI, HINFNORM,
%             RIC_EIG, RIC_SCHR, SDTRSP and SDHFNORM

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $


function [k,gfin]= ...
	sdhfsyn(sdsys,nmeas,ncon,gmin,gmax,tol,h,delay,ricmethd,epr,epp,quiet);

% Initialize return values
k = []; gfin = [];

% perform type checking
if nargin == 0
  disp('usage: [k,gfin] = sdhfsyn(sdsys,nmeas,ncon,gmin,gmax,tol,h,delay,ricmethd,epr,epp) ')
  return
  end
if nargin <= 7,
  disp('usage: [k,gfin] = sdhfsyn(sdsys,nmeas,ncon,gmin,gmax,tol,h,delay,ricmethd,epr,epp) ')
  error('incorrect number of input arguments')
  return
  end

[typ,p,m,n]=minfo(sdsys);

if typ~='syst',
	error(' Plant is not a system')
	return
	end

if h<= 0,
	error(' Sampling period H is nonpositive')
	return
	end

if delay < 0,
	error(' DELAY must be a non-negative integer');
	return
	end

if delay~=floor(delay),
	error(' DELAY must be a non-negative integer');
	return
	end


if gmin > gmax,
	error(' GAMMA MIN is greater than GAMMA MAX')
	return
	end

if tol<=0,
	error(' TOL must be positive')
	return
	end

if gmin <= 0
	error(' GMIN must be greater than 0')
	return
	end


% setup default cases
if nargin == 7
  delay=0;
  ricmethd = 2;
  epr = 1e-10;
  epp = 1e-6;
  quiet = 1;
elseif nargin == 8
  ricmethd = 2;
  epr = 1e-10;
  epp = 1e-6;
  quiet = 1;
elseif nargin == 9
  epr = 1e-10;
  epp = 1e-6;
  quiet = 1;
elseif nargin == 10
  epp = 1e-6;
  quiet = 1;
elseif nargin == 11
  quiet = 1;
end

% check data
[a,b,c,d]=unpck(sdsys);
if rank( diag( exp(eig(a)*h) + ones(n,1) ) ) < n
	error(' System is pathologically sampled')
	return
	end
if max(max(abs(d)))~=0,
	error(' D matrix non-zero')
	return
	end

% 7 nov 95
%
% The problem has more measurements than states with zero observation noise.
% Now in continuous time we would insist on full row rank D21 but
% in sampled-data we insist on D21=0.  Hence in the sampled-data case
% if we have nmeas>xd there are redundant measurements  and even after we
% have done all the SDEQUIV and converted to c-t via BILINZ2S we
% still essentially have redundant states.  The failure is in fact
% in HINFSYNE with the [a b1; c2 d21] being rank deficient.
%
% There are two alternatives,
% 	- one is to say that nmeas<=xd is required.
%	- the other is to detect this situation and then for example
%	  change c2 to be I and at the end post-multiply the controller
%	  by a left inverse of c2.  The same problem will occur
%	  if we have ncont>xd and the solution would be then to
%	  replace b2 by I and then pre-multiply the
%	  resulting controller by a right inverse of b2.
%
b1 = b(1:n,1:m-ncon)/sqrt(gmin);
b2 = b(1:n,m-ncon+1:m);
c1 = c(1:p-nmeas,1:n)/sqrt(gmin);
c2 = c(p-nmeas+1:p,1:n);

realnmeas = nmeas; % MOVED for matlab v5
if nmeas>n,
	realc2 = c2;
	c2 = eye(n);
	nmeas = n;
end
realncont = ncon; % MOVED for matlab V5
if ncon>n,
	realb2 = b2;
	b2 = eye(n);
	ncon = n;
end

[T,invT,S,s]=ham2schr(a,b1,c1,0.02/h);
sys1eye=pck(a,[b1 b2],[c1;c2]);

compnormltgmin=compnorm(T,invT,S,s,h);

%			gamma iteration

if quiet == 1
	fprintf('Test bounds:  %10.4f <  gamma  <=  %10.4f\n\n',gmin,gmax)
	fprintf('  gamma    hamx_eig  xinf_eig  hamy_eig   yinf_eig   nrho_xy   p/f\n')
end

%initialize loop control variables
gtmp=gmax;
gold=gmax-2*tol;
itn=0; %flags the first iteration

if quiet == 1
	dquiet = 0;
else
	dquiet = 1;
end

%main driving loop
while abs(gold-gtmp)>tol/2,
	b1=b(1:n,1:m-ncon)/sqrt(gtmp);
	c1=c(1:p-nmeas,1:n)/sqrt(gtmp);
	[T,invT,S,s]=ham2schr(a,b1,c1,0.02/h);
	if compnormltgmin==0,
		hcompnorm=compnorm(T,invT,S,s,h);
	else
		hcompnorm=1;
	end
	if hcompnorm==1,
		dsdsys=sdequiv(a,b1,b2,c1,c2,T,invT,S,s,h,delay);
                [dsdsystype,dsdsysp,dsdsysm,dsdsysn]=minfo(dsdsys);
                % rescale gamma back from one to gtmp
                if strcmp(dsdsystype,'syst'),
                  dsdsys(dsdsysn+1:dsdsysn+dsdsysp-nmeas,:) = ...
                    dsdsys(dsdsysn+1:dsdsysn+dsdsysp-nmeas,:)*sqrt(gtmp);
                  dsdsys(:,dsdsysn+1:dsdsysn+dsdsysm-ncon) = ...
                    dsdsys(:,dsdsysn+1:dsdsysn+dsdsysm-ncon)*sqrt(gtmp);
                  [ktmp]= ...
                    dhfsyn(dsdsys,nmeas,ncon,gtmp,gtmp,tol,h,inf,...
                    dquiet,ricmethd,epr,epp);
                end %if if strcmp(dsdsystype,'syst')
                if ~strcmp(dsdsystype,'syst') | isempty(ktmp),
                  soln=0;
                else
                  soln=1;
                end; %if isempty(ktmp)
	else
		soln=0;
	end
	if soln==0,
		if itn==0,
			fprintf('Gamma max, %10.4f, is too small !!\n',gmax);
			return;
		else
			gmin=gtmp;
			gold=gtmp;
			gtmp=(gmax+gmin)/2;
			itn=1;
                        if hcompnorm==1 & isempty(ktmp),
                          compnormltgmin=1;
                         end
                end
	else
		if soln==1,
			gmax=gtmp;
			gold=gtmp;
			gfin=gtmp;
			gtmp=(gmax+gmin)/2;
			k=(ktmp);
			if realnmeas>n,
				k=mmult(k,pinv(realc2));
			end
			if realncont>n,
				k=mmult(pinv(realb2),k);
			end
			itn=1;
                end
	end

end % end of   gamma iteration


if quiet == 1
  fprintf('\n Gamma value achieved: %10.4f\n',gfin)
end

%end of function
%
%
