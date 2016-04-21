function [clmod,cmod]=smpccl(pmod,imod,Ks,Kest)
%SMPCCL Create a model of the closed-loop system for simulations.
%    	[clmod,cmod]=smpccl(pmod,imod,Ks)
%    	[clmod,cmod]=smpccl(pmod,imod,Ks,Kest)
% NOTE:  assumes measured disturbances and setpoints
% will be constant in the future.
%
% Inputs:
%  pmod   the plant model in the MOD format.
%  imod   the internal model in the MOD format.
%  Ks     the controller gain matrix created by SMPCCON
%  Kest   the estimator gain matrix.  If omitted or Kest=[],
%         the MPC default estimator gain is used.
%
% Outputs:
%  clmod  the resulting closed-loop system model in the
%         MOD format.
%  cmod   the dynamic model of the controller in the MOD
%         format (optional).
%
% See also MOD2STEP, SMPCGAIN, SMPCPOLE, SCMPC, SMPCCON, SMPCEST,.
%	SMPCSIM

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

%
%NOTE:  when used for simulations, clmod requires the following inputs:
%
%   ny setpoints (where ny is the TOTAL number of outputs, meas.+unmeas.).
%   ny measurement noise inputs.
%   nu additive input disturbances (where nu is number of
%      manipulated variables).
%   nv measured disturbances (if pmod and imod include them).
%   nw unmeasured disturbances (if pmod includes them).
%
%Then clmod will generate the following outputs:
%
%   ny true plant output variables.
%   nu manipulated variables.
%   ny output estimates (from the state estimator).
%
%[clmod,cmod]=smpccl(pmod,imod,Ks,Kest)


if nargin == 0
   disp('USAGE:  [clmod,cmod]=smpccl(pmod,imod,Ks,Kest)')
   return
elseif nargin < 3 | nargin > 4
   error('Incorrect number of input variables')
end

if isempty(pmod) | isempty (imod)
   error('Plant and internal model must be non-empty, in MOD format.')
end

% Get plant and internal models in state-space form.

[phip,gamp,cp,dp,minfop]=mod2ss(pmod);
tsamp=minfop(1);
np=minfop(2);
nup=minfop(3);
nvp=minfop(4);
nwp=minfop(5);
nymp=minfop(6);
nyup=minfop(7);
nyp=nymp+nyup;

[phii,gami,ci,di,minfoi]=mod2ss(imod);
ni=minfoi(2);
nui=minfoi(3);    % number of man. vars.
nvi=minfoi(4);    % number of meas. dist.
nwi=minfoi(5);    % number of unmeas. dist.
nymi=minfoi(6);   % number of measured outputs.
nyui=minfoi(7);   % number of unmeasured outputs.
nyi=nymi+nyui;    % total number of outputs.

% +++ Check for errors and inconsistencies. +++

if any(any(dp(:,1:nup+nvp)))
   error(['PMOD:  first nu+nv=',int2str(nup+nvp),' columns of D',...
          ' matrix must be zero.'])
elseif any(any(di(:,1:nui+nvi)))
   error(['IMOD:  first nu+nv=',int2str(nui+nvi),' columns of D',...
          ' matrix must be zero.'])
end

if minfoi(1) ~= tsamp
   error('PMOD and IMOD have different sampling periods')
elseif nui ~= nup
   error('PMOD and IMOD must have equal number of manipulated variables')
elseif nvi ~= nvp
   error('PMOD and IMOD must have equal number of measured disturbances')
elseif nymi ~= nymp
   error('PMOD and IMOD must have equal number of measured outputs')
elseif nyui ~= nyup
   error('PMOD and IMOD must have equal number of unmeasured outputs')
end

[nrow,ncol]=size(Ks);
p=round((ncol-1)/nyi);
pny=p*nyi;
if ncol ~= 2*nyi+ni+nvi
   error('Input matrix Ks has wrong number of columns')
end
if nrow ~= nui
   error('Input matrix Ks has wrong number of rows')
end

if nargin > 3
   if isempty(Kest)
      Kest=[zeros(ni,nymi)       % This is the default value of Kest
              eye(nymi)
            zeros(nyui,nymi)];
   else
      [nrow,ncol]=size(Kest);
      if nrow ~= ni+nyi | ncol ~= nymi
         error('Kest must have n+nym+nyu rows and nym columns')
      end
   end
else
   Kest=[zeros(ni,nymi)       % Default
           eye(nymi)
         zeros(nyui,nymi)];
end

% +++ If there are unmeasured outputs, add columns of zeros
%     to the estimator gain matrix.  This just makes subsequent
%     algebra simpler.

if nyup > 0
   Kest=[Kest zeros(ni+nyi,nyup)];
end

% +++ Augment the internal model states.

[phii,gami,ci,di,ni]=mpcaugss(phii,gami,ci,di);

% +++ Break Ks into its components

Kr=Ks(:,1:nyi);
Kx=Ks(:,nyi+1:nyi+ni);
if nvi > 0
   Kv=Ks(:,ni+nyi+1:ni+nyi+nvi);
end

% +++ Define the state-space matrices for the controller +++


icr=[1:nyi];              % These are pointers to columns in the
icy=[nyi+1:2*nyi];        % gamma and d matrices of the controller.
icv=[2*nyi+1:2*nyi+nvi];
iu=[1:nui];               % Points to man. var. columns

IKC=eye(ni)-Kest*ci;
PKX=phii+gami(:,iu)*Kx;
CK=ci*Kest;
phic1=PKX*IKC;
gamc1=[gami(:,iu)*Kr, PKX*Kest];
cc1=Kx*IKC;
dc1=[Kr, Kx*Kest];

if nvi > 0
   iv=[nui+1:nui+nvi];
   gamc1=[gamc1, gami(:,iu)*Kv+gami(:,iv)];
   dc1=[dc1, Kv];
end

% +++ Add states for integration of delta u and for differencing the v input.

phic=[phic1 zeros(ni,nui)
       cc1    eye(nui)];
gamc=[gamc1
       dc1];
cc=[cc1 eye(nui)];
dc=dc1;

if nvi > 0
   phic=[ phic, [-gamc1(:,icv); -dc1(:,icv)]; zeros(nvi,ni+nui+nvi)];
   gamc=[ gamc; [zeros(nvi,nyi+nyi), eye(nvi)] ];
     cc=[   cc, -dc1(:,icv)];
end

nc=ni+nui+nvi;

% +++ Define the state-space model of the closed-loop system. +++

phicl=[ phip+gamp(:,iu)*dc(:,icy)*cp,   gamp(:,iu)*cc
           gamc(:,icy)*cp,                phic     ];

gamcl=[ gamp(:,iu)*dc(:,[icr,icy]), gamp(:,iu)
        gamc(:,[icr,icy]),         zeros(nc,nui)];

ccl=[ cp              zeros(nyp,nc)
      dc(:,icy)*cp          cc
      CK*cp         ci*IKC  zeros(nyi,nui+nvi)];

dcl=[zeros(nyp,2*nyp+nup)
     dc(:,[icr,icy])     zeros(nup,nup)
     zeros(nyp,nyp)     CK  zeros(nyp,nup) ];

if nvp > 0
   gamcl=[gamcl, [ gamp(:,iu)*dc(:,icv)+gamp(:,iv) ; ...
                   gamc(:,icv)] ];
   dcl=[dcl, [zeros(nyp,nvp) ; dc(:,icv); zeros(nyp,nvp)] ];
end

if nwp > 0
   iw=[nup+nvp+1:nup+nvp+nwp];
   gamcl=[gamcl, [gamp(:,iu)*dc(:,icy)*dp(:,iw)+gamp(:,iw) ; ...
                   gamc(:,icy)*dp(:,iw)] ];
   dcl=[dcl, [dp(:,iw); dc(:,icy)*dp(:,iw); CK*dp(:,iw)] ];
end

%  +++ return the closed loop model +++

clmod=ss2mod(phicl,gamcl,ccl,dcl,tsamp);

% +++ return the optional controller model +++

if nargout > 1
   cmod=ss2mod(phic,gamc,cc,dc,tsamp);
end