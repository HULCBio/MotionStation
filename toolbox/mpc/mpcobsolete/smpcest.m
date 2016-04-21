function [K,newmod]=smpcest(mod,tau,signoise);

%SMPCEST Design a state estimation gain matrix for use in MPC.
%	[Kest,newmod]=smpcest(imod,tau,signoise);
%	Kest=smpcest(imod,Q,R)
% Inputs:
%   imod  is the internal model for which the estimator
%         is to be designed (in the MPC format).
%    tau  Is the vector of time constants (continuous time)
%         characterizing the disturbances affecting each measured
%         output.  Setting an element equal to zero is equivalent
%         to the DMC assumption.  Setting one to "inf" is equivalent
%         to assuming that random ramps affect that output.  Setting
%         tau=[] or omitting it gives DMC for all outputs.
%signoise is the signal-to-noise ratio affecting each output.  Must
%         be between "inf" (no noise) and zero (no signal).
%       Q is the covariance of the unmeasured disturbances in imod.
%       R is the covariance of the measurement noise.
% Outputs:
%   Kest is the resulting estimator gain.
% newmod is the modified version of the input model, which contains
%        new states to represent disturbances (if any of the TAU values
%        are non-zero).
% See also SCMPC, SMPCCL, SMPCCON, SMPCSIM.
% NOTE:   only specify newmod when you want simplified
%        disturbance modeling using tau and signoise.  If you only give
%        Kest, SMPCEST takes the more general approach using Q and R.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin < 1
   disp('USAGE:  [Kest,newmod]=smpcest(imod,tau,signoise)')
   disp('               [Kest]=smpcest(imod,Q,R)')
   return
end

[a,b,c,d,minfo]=mod2ss(mod);
T=minfo(1);            % sampling period
n=minfo(2);            % system order
nu=minfo(3);           % number of manipulated variables
nmd=minfo(4);          % number of measured disturbances
numd=minfo(5);         % number of unmeasured disturbances
nym=round(minfo(6));   % number of measured outputs
nyu=round(minfo(7));   % number of unmeasured outputs

if nym <= 0
   error('MINFO(6)<=0 in IMOD.  Must have at least 1 measured output.')
end

if nargout == 2

% SIMPLIFIED DISTURBANCE MODEL CASE.

% Check for errors and set up default values.

   estr='Using simplified disturbance model.';
   if nargin > 1
      if isempty(tau)
         tau=zeros(nym,1);
      else
         if length(tau) ~= nym
            disp(estr)
            error(['TAU must have ',int2str(nym),' elements.'])
         elseif any(tau < 0)
            disp(estr)
            error('All elements of TAU must be >= 0.')
         end
      end
   else
      tau=zeros(nym,1);
      signoise=inf*ones(nym,1);
   end

   if nargin > 2
      if isempty(signoise)
         signoise=inf*ones(nym,1);
      else
         if length(signoise) ~= nym
            disp(estr)
            error(['SIGNOISE must have ',int2str(nym),' elements.'])
         elseif any(signoise < 0)
            disp(estr)
            error('All elements of SIGNOISE must be >= 0.')
         end
      end
   else
      signoise=inf*ones(nym,1);
   end

   if nargin > 3
      disp(estr)
      error('Too many input arguments.  Should be <= 3.')
   end

% Loop for each output to set up the estimator gain and the model.

   k2=[];
   k3=[];
   an=[];
   cn=[];
   for i=1:nym
      if tau(i) == 0
         if signoise(i) == 0
            k2(i,i)=0;
         else
            k2(i,i) = 2/(1+sqrt(1+4/(signoise(i)^2 + 1e-10)));
         end
      else
         Texp=exp(-T/tau(i));
         if signoise(i) > 1e40
            g=1e40;
         else
            g=signoise(i);
         end
         if g == 0
            p1=0;
         else
            cc=(g/2)*sqrt(4*(Texp*(Texp+2)+1)+g*g);
            ac=((2*(1-Texp*Texp)-g*g)*cc ...
                -(2*Texp*(Texp+2)+0.5*g*g+2)*g*g)/(2*cc);
            p1=0.5*(sqrt(4*(cc+0.5*g*g)+ac*ac)-ac);
         end
         p3=p1*p1*Texp/(1+p1+Texp);
         k2(i,i)=p1/(p1+1);
         k3=[k3; zeros(1,i-1) p3/(p1+1) zeros(1,nym-i)];
         an=[an;Texp];
         cn=[cn [zeros(i-1,1);1/Texp;zeros(nym-i,1)]];
      end
   end

   K=[zeros(n,nym)
          k3
          k2
	  zeros(nyu,nym)];

   newn=length(an);
   if newn > 0
      a(n+1:n+newn,n+1:n+newn)=diag(an);
      b=[b;zeros(newn,nu+nmd+numd)];
      c=[c [cn;zeros(nyu,newn)]];
      minfo(2)=n+newn;
      newmod=ss2mod(a,b,c,d,minfo);
   else
      newmod=mod;
   end

elseif nargout == 1

% GENERAL DISTURBANCE MODEL CASE.

   estr='Using general disturbance model.';
   if nargin ~= 3
      disp(estr)
      error('Must supply 3 input arguments.')
   end
   Q=tau;
   R=signoise;
   [rq,cq]=size(Q);
   [rr,cr]=size(R);
   if rq ~= cq | rq ~= numd
      disp(estr)
      disp(['There are nw=',int2str(numd),' unmeasured disturbances in IMOD.'])
      error('The number of rows and columns in Q must equal nw.')
   elseif rr ~= cr | rr ~= nym
      disp(estr)
      disp(['There are nym=',int2str(nym),' measured outputs in IMOD.'])
      error('The number of rows and columns in R must equal nym.')
   end
   lamQ=eig(Q);
   if any(imag(lamQ) ~= 0)
      disp(estr)
      error('Q does not appear to be symmetric')
   elseif any(lamQ < 0)
      error('Q does not appear to be positive semi-definite')
   end
   lamR=eig(R);
   if any(imag(lamR) ~= 0)
      disp(estr)
      error('R does not appear to be symmetric')
   elseif any(lamR <= 0)
      error('R does not appear to be positive-definite')
   end
   [a,b,c]=mpcaugss(a,b,c);
   c=c(1:nym,:);             % Strip off the unmeasured outputs.
   K=dlqe2(a,b(:,nu+nmd+1:nu+nmd+numd),c,Q,R);

else
   error('Incorrect number of output arguments.  Must be 1 or 2.')
end

% END OF SMPCEST
