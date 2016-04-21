%function [gaml,gamu]=sdhfnorm(sdsys,k,h,delay,tol);
%
%  This function computes the L2 induced norm of a continuous-time
%  SYSTEM matrix in feedback with a discrete-time system matrix
%  connected through an ideal sampler and a zero-order hold.
%
%  The continuous-time plant SDSYS is partitioned:
%                          | a   b1   b2   |
%              sdsys    =  | c1   0    0   |
%                          | c2   0    0   |
%
%  Note that d must be zero.
%
%   Inputs:
%      SDSYS    -   continuous-time SYSTEM matrix (plant)
%      K        -   discrete-time SYSTEM matrix   (controller)
%      H        -   sampling period of the controller K
%      DELAY    -   a non-negative integer giving the number of
%                   computational delays of the controller (default 0)
%      TOL      -   difference between upper and lower bounds
%                   when search terminates (default 0.001)
%    Outputs:
%      GAMU    -   upper bound on norm
%      GAML    -   lower bound on norm
%
%
%	                _________
%	               |         |
%	     z <-------|  sdsys  |<-------- w
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
%             RIC_EIG, RIC_SCHR, SDTRSP and SDHFNORM.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [gaml,gamu]=sdhfnorm(sdsys,k,h,delay,tol);

%perform type checking
if nargin == 0
	disp('usage: [gamu,gaml]=sdhfnorm(sdsys,k,h,delay,tol) ')
	return
	end
if nargin <= 2,
	disp('usage: [gamu,gaml]=sdhfnorm(sdsys,k,h,delay,tol) ')
	error('incorrect number of input arguments')
	return
	end

% setup default cases
if nargin == 3
    delay = 0;
    tol=0.001;
elseif nargin == 4
    tol=0.001;
end

[typ,p,m,n]=minfo(sdsys);

if typ~='syst',
	error(' Plant is not a system')
	return
	end

[typ,ncon,nmeas,kn]=minfo(k);
if (typ~='syst') & (typ~='cons'),
	error(' Controller is not a SYSTEM or CONSTANT')
	return
	end

if typ=='cons',  % turn into a system.
        kn=1;
        k=pck(0,zeros(1,nmeas),zeros(ncon,1),k);
        end

if h<= 0,
	error(' Sampling period, H, is nonpositive')
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


% check sampled data feedback system is stable.
sdsys_sh=samhld(sdsys,h);
k_del=k;
if delay>0,
   ndel=delay*nmeas;
   sys_del=pck([zeros(ndel,nmeas) eye(ndel,ndel-nmeas)],...
    [zeros(ndel-nmeas,nmeas);eye(nmeas)],eye(nmeas,ndel),zeros(nmeas,nmeas));
    k_del=mmult(k_del,sys_del);
  end,
cl_sh=starp(sdsys_sh,k_del);
cl_poles=spoles(cl_sh);
if any(abs(cl_poles)>=1),
        disp('sampled data system unstable');
	gaml = []; gamu = [];
        return,
        end,

% check data
[a,b,c,d]=unpck(sdsys);
if rank( diag( exp(eig(a)*h) + ones(n,1) ) ) < n
	disp(' SYSTEM is pathologically sampled');
	gaml = []; gamu = [];
	return
	end
if max(max(abs(d)))~=0,
	disp(' D matrix non-zero');
	gaml = []; gamu = [];
	return
	end

% get an initial guess for gammma from the norm of the
% discrete time system, assuming piecewise constant inputs
% and sampled error signals.

dis_norm=hinfnorm(bilinz2s(cl_sh,h),0.1);
gamtmp=dis_norm(2); % changed from taking the lower bound:  gamtmp=dis_norm(1);

% main gamma iteration loop

foundgaml=0; foundgamu=0; gamu=1; gaml=0; compnormltgaml=0;
amp=1.1;

while ~foundgaml | ~foundgamu | ((gamu-gaml)>tol*gamu),
    b1=b(1:n,1:m-ncon)/sqrt(gamtmp);
    b2=b(1:n,m-ncon+1:m)*sqrt(gamtmp);
    c1=c(1:p-nmeas,1:n)/sqrt(gamtmp);
    c2=c(p-nmeas+1:p,1:n)*sqrt(gamtmp);
    [T,invT,S,s]=ham2schr(a,b1,c1,.02/h);

 if ~compnormltgaml,
	compnormtmp=compnorm(T,invT,S,s,h);
   else
      compnormtmp=1;
  end, %if ~compnormltgaml

 if ~compnormtmp,
      foundgaml=1;
      gaml=gamtmp;
      if foundgamu,
          gamtmp=(gaml+gamu)/2;
        else
          gamtmp=amp*gaml;
          amp=amp^2;  % to increase the rate
       end; %if foundgamu
   else  % (i.e. compnormtmp=1)
      [soln]=  ...
          sdn_step(a,b1,b2,c1,c2,T,invT,S,s,h,delay,mscl(k,1/gamtmp));
      if soln==0,
         compnormltgaml=1;
         foundgaml=1;
         gaml=gamtmp;
         if foundgamu,
             gamtmp=(gaml+gamu)/2;
           else
             gamtmp=amp*gaml;
             amp=amp^2;
          end; %if foundgamu
        else, %(i.e. soln==1)
           foundgamu=1;
           gamu=gamtmp;
           if foundgamu,
              gamtmp=(gaml+gamu)/2;
             else
               gamtmp=gamu/2;
            end, %if foundgamu
        end, % if soln==0
  end, % if ~compnormtmp
end, %while ~foundgaml

if nargout == 0
         disp(['norm between ' num2str(gaml) ' and ' num2str(gamu)]);
  else
    out=[gaml,gamu];
end
%
%