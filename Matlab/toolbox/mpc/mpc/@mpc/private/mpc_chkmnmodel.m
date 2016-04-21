function [newmodel,newxn0,nnMN,Bmn,Dmn,nxbar]=mpc_chkmnmodel(...
   model,mnmodel,xn0,myindex,mvindex,mdindex,nym);

%MPC_CHKMNMODEL Check for Model.Noise and eventually augment the system 
%   for Kalman filter design, including white noise on measured outputs, 
%   white noise on the state of Model.Noise,
%   and white noise on each manipulated variable channel

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date:    

verbose=warning('query','mpc:verbosity');
verbose=strcmp(verbose.state,'on');

if isempty(mnmodel) 
   
   % Default: Add white noise + an integrator driven by unit-variance white noise
   %          for each measured output channel, i.e. step-like measurement noise.
   %          **UNLESS** a UMD model was specified by the user, in this case no integrators 
   %          are added on outputs, as the user may already have included output integrators 
   %          in his UMD model, and therefore duplicating such integrators should lead to 
   %          unobservability.
   
   %if noumd,% noumd=0 means that Model.UnmeasDist was specified
   
   %warning('No Model.Noise specified. Assuming one integrator per measured output channel')
   
   %mnmodel=ss(zeros(nym,nym),eye(nym),eye(nym),zeros(nym,nym));
   %else
   %warning('No Model.Noise specified, but Model.UnmeasDist was specified. Assuming white noise on each measured output channel')
   
   if verbose,
      fprintf('-->No Model.Noise specified, assuming white noise on each measured output channel\n');
   end
   
   %% Default: a random noise with unit covariance matrix
   %%          for each unmeasured disturbance
   
   mnmodel=tf(eye(length(myindex)));
   %mnx0=[];
   
   % Do nothing, random white noise is added anyway later in the Kalman filter design
   %end
end


if ~isa(mnmodel,'ss'),    
    if norm(xn0)>0, 
        error('mpc:mpc_mnmodel:SSstate','You have specified an initial state for noise model, which is not a SS model');
    else
        xn0=[]; % Zero initial states are emptied, to alleviate the user for wrong dimensions of zero vectors
    end
    mnmodel=ss(mnmodel);
end

ts=model.Ts;
nts=mnmodel.Ts;

if nts<0,
    if ts>0,
        wmsg1='No sampling time provided for noise model.';
        wmsg2=sprintf('Assuming sampling time = plant model''s sampling time = %g',ts);
        warning('mpc:mpc_chkmnmodel:defaultts',sprintf('%s\n         %s',wmsg1,wmsg2));
        nts=ts;
        mnmodel.ts=ts;
    else
        error('mpc:mpc_chkmnmodel:noTs','No sampling time provided for noise model');
    end
end

if nts==0,
   mnmodel=c2d(mnmodel,ts);    % Note: UserData field is lost during conversion !!!
   
elseif abs(ts-nts)>1e-10, % ts different from nts

   if ~strcmp(swarn(1).state,'off'),
      disp('Resampling Model.Noise to controller''s sampling time');
   end
   mnmodel=d2d(mnmodel,ts);
   %takes out possible imaginary parts
   set(mnmodel,'a',real(mnmodel.a),'b',real(mnmodel.b));
end


% Augment the system (note that mnmodel may be just a static gain)

[nx,nutot]=size(model.b);
[ny,nx]=size(model.c);
nu=length(mvindex);
nv=length(mdindex);

[nxbar,nubar]=size(mnmodel.b); % nxbar=number of states in mnmodel, which will
                               % be appended below the states of MODEL

newc=[model.c,zeros(ny,nxbar)];
newc(myindex,nx+1:nx+nxbar)=mnmodel.c;
newd=[model.d,model.d(:,[mvindex(:);mdindex(:)]'),zeros(ny,nxbar)]; % the term mnmodel.d * inputs-to-Model.Noise is treated as v-disturbance in the Kalman filter design
newb=[model.b,model.b(:,[mvindex(:);mdindex(:)]'),zeros(nx,nxbar);zeros(nxbar,nutot+nu+nv),eye(nxbar)];
newa=[model.a,zeros(nx,nxbar);zeros(nxbar,nx),mnmodel.a];


newmodel=ss(newa,newb,newc,newd,model.ts);

Bmn=mnmodel.b;
Dmn=mnmodel.d;

% This is to prevent the following message from
% KALMAN.M: The covariance matrix
%               E{(Hw+v)(Hw+v)'} = [H,I]*[Qn Nn;Nn' Rn]*[H';I]
%           must be positive definite.
if min(eig(Dmn*Dmn'))<1e-8,
   warning('mpc:mpc_chkmnmodel:feedthrough','A feedthrough channel in NoiseModel was inserted to prevent problems with estimator design\n');
   Dmn=Dmn+1e-4*eye(size(Dmn));
end


nnMN=nubar; % Number of white noise inputs to Model.Noise

newxn0=mpc_chkx0u1(xn0,nxbar,zeros(nxbar,1),'initial state of noise model');

%nxmn=nxbar; % Number of states of Model.Noise

%% Compute the gain Cmn, which is used to estimate the true output:
%%
%% ytrue=yest-Cmn*xest
%%
%% Note that if Model.Noise is a static gain (e.g.: identity) then Cmn=zeros(nym,nx)
%% Note also that a corresponding gain Dmn is not needed, because the best estimate of 
%% the white noise feeding through Model.Noise is zero.
%
%Cmn=mnmodel.c;
%Amn=mnmodel.a;
%
%if nxbar==0,
%   iszeroCmn=1;
%else 
%   iszeroCmn=0;
%end

%newunindex=[unindex;(nutot+1:nutot+nxbar)']; % mnmodel.b * inputs-to-Model.Noise are treated as unmeasured inputs


% end of mpc_chkmnmodel
