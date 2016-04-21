function MPCstruct=mpc_struct(mpcobj,xmpc0,flag,extra)
%MPC_STRUCT Initialize MPC object (QP matrices, observer, prediction model)
%
%   Used by: MPC_INIT, MPCMOVE, SIM, MPCSTATE

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2004/04/10 23:35:07 $   

if nargin<2|isempty(xmpc0),
    xmpc0=mpcstate;
elseif ~isa(xmpc0,'mpcdata.mpcstate'),
    error('mpc:mpc_struct:state','Initial controller state must be a valid MPCSTATE object.');
end
if nargin<3,
    flag='base';
end


[ManipulatedVariables,OutputVariables,Plant,Disturbance,Noise,... 
        Ts,MinOutputECR,MaxIter,...
        p,moves,Nominal,MPCData,Weights]=...
    mpc_getfields(mpcobj);


nutot=MPCData.nutot;
nu=MPCData.nu;
ny=MPCData.ny;

mvindex=MPCData.mvindex;
mdindex=MPCData.mdindex;
unindex=MPCData.unindex;

myindex=MPCData.myindex;
uyindex=setdiff(1:ny,myindex);

% Check consistency of Model.Plant, sampling time, initial state, previous input
% Possibly (re)sample the model and remove delays. Also introduce an extra measured
% disturbance to handle plant offsets. 

xp0=xmpc0.Plant;
u1=xmpc0.LastMove; % This only contains manipulated vars.
% Only previous manipulated vars are needed
%u1=u1(mvindex); % This becomes the initial value for lastu

[model,ts,xp0,u1,uoff,yoff,xoff,dxoff]=mpc_chkmodel(Plant,Ts,Nominal,xp0,u1,mvindex);

% Observability test
theta=obsv(model.A,model.C(myindex,:));
obs=rank(theta);
if obs<size(model.A,1),
    warning('mpc:mpc_struct:obsv',sprintf([...
        'Plant model is probably unobservable (the condition number of the observability matrix\n',...
        'is %g), estimator design may fail.'],cond(theta)));
end

voff=uoff(mdindex); % Offset of measured disturbances
%doff=uoff(unindex); % Offset of unmeasured disturbances (not needed)
uoff=uoff(mvindex); % Offset of manipulated variables
myoff=yoff(myindex);% Offset of measured outputs
uyoff=yoff(uyindex);% Offset of unmeasured outputs


% The last input is the MD introduced to model plant offsets
mdindex=[mdindex;nutot+1];

compute=~mpcobj.MPCData.QP_ready | strcmp(flag,'outdistmodel');

if ~compute,
    MPCstruct=mpcobj.MPCData.MPCstruct;
end

if compute,
    % Augment weights to have p rows
    uwt=mpc_chklen(Weights.ManipulatedVariables,p);
    duwt=mpc_chklen(Weights.ManipulatedVariablesRate,p);
end
ywt=mpc_chklen(Weights.OutputVariables,p);

% Output disturbance model
outdistflag=MPCData.OutDistFlag;
if outdistflag & ~strcmp(flag,'outdistmodel'),
    % Output disturbance model is retrieved from MPCData
    extra=mpc_chkoutdistmodel(MPCData.OutDistModel,ny,ts,'Output');
end

nxp=size(model.A,1); % Needed by SIM(=MPCLOOP), MPC_INIT
if strcmp(flag,'mpcloop')|strcmp(flag,'outdistmodel')|outdistflag,
    Ap=model.A;              
    Bup=model.B(:,mvindex);  
    Bvp=model.B(:,mdindex);  
    Bdp=model.B(:,unindex);  
    Cp=model.C;              
    Dvp=model.D(:,mdindex);  
    Ddp=model.D(:,unindex);  
    nd=length(unindex);
end

% Check unmeasured disturbance model and augment the system (if needed)
%DefaultDisturbanceIntegrators=strcmp(ss_flag,'on'); %1='on', 0='off'
%DefaultDisturbanceIntegrators=strcmp(mpcobj.MPCData.ss_observer,'integrators');

%InitialStateDisturbance=[];
xd0=xmpc0.Disturbance;

if ~(strcmp(flag,'outdistmodel')|outdistflag),
    
    % Default output disturbance model (integrators)
    % Get info about integrated white noise on outputs
    [weight,order]=sort(-sum(abs([ywt;zeros(1,ny)]))); % Order weights
    weight=-weight;
    channels=-ones(ny,1);
    magnitude=-ones(ny,1);
    for h=1:ny,
        mag=OutputVariables(h).Integrator;
        if isempty(mag),
            % Add integrator by default only if weight>0 & output is measured
            if weight(h)>0 & ismember(h,myindex), 
                channels(h)=h;
                magnitude(h)=1;
            end
        else
            if mag>0,
                channels(h)=h;
                magnitude(h)=mag;
            end
        end
    end
    
    outmodelflag=0; % Default is just output integrators
    extra=[]; % Not needed
else
    outmodelflag=1;
    channels=[]; % not needed
    magnitude=[]; % not needed
    order=[]; % not needed
end

[model,unindex,xd0,nnUMD,nnUMDyint,nxumd,outdistchannels,indistchannels]=...
    mpc_chkumdmodel(model,Disturbance,...
    xd0,channels,magnitude,order,unindex,myindex,nutot,outmodelflag,extra);

% Save the number of states (excluding states from Noise.Model).
% Only these first states are fed back to the QP problem (i.e., multiplied
% by the Kx gain)
nx=size(model.C,2); % number of states
nym=length(myindex);  % number of measured outputs 
nv=length(mdindex);   % number of measured disturbances (including the additional MD due to offsets)

if compute,
    
    [umin,umax,Vumin,Vumax,dumin,dumax,Vdumin,Vdumax,utarget]=...
        mpc_constraints(ManipulatedVariables,p,nu,'u',uoff);
    
    [ymin,ymax,Vymin,Vymax]=mpc_constraints(OutputVariables,...
        p,ny,'y',yoff);
    
    
    % Check if problem is constrained, unconstrained, soft-constrained,
    % and redefines dumin (if needed)
    [dumin,PTYPE]=mpc_chkunconstr(umin,umax,dumin,dumax,ymin,ymax,...
        Vumin,Vumax,Vdumin,Vdumax,Vymin,Vymax);
    
    
    % Builds optimization matrices for QP problem. These are based
    % only on Model.Plant and Model.Disturbance, as we want to optimize
    % and constrain only the 'true' output (i.e., not perturbed by Model.Noise)
    
    %[Mat,degrees]=buildmat(A,Bu,Bv,Bd,C,Dv,Dd,uwt,duwt,ywt,...
    %   umin,umax,dumin,dumax,ymin,ymax,...
    %   Vumin,Vumax,Vdumin,Vdumax,Vymin,Vymax,p,moves,...
    %   mvindex,mdindex,unindex,PTYPE,nx,ny,nutot,nu,nv,nd,rhoeps);
    [KduINV,Kx,Kr,Ku1,Kv,Kut,Jm,DUFree,TAB,MuKduINV,rhsa0,rhsc0,...
            Mlim,Mx,Mu1,Mv,zmin,... 
            degrees]=mpc_buildmat(...
        model.A,model.B(:,mvindex),model.B(:,mdindex),...
        model.C,model.D(:,mdindex),...
        uwt,duwt,ywt,umin,umax,dumin,dumax,ymin,ymax,...
        Vumin,Vumax,Vdumin,Vdumax,Vymin,Vymax,p,moves,...
        mvindex,mdindex,unindex,PTYPE,nx,ny,nutot,nu,nv,Weights.ECR);     % Md,Kd,Dd,nd removed (AB, July 3, 2001)
    
    
    %Private=struct('p_defaulted',p_defaulted,'PTYPE',PTYPE,...
    %   'mvindex',mvindex,'mdindex',mdindex,...
    %   'myindex',myindex,'unindex',unindex,...
    %   'nutot',nutot,'ny',ny,'nu',nu,...
    %   'umin',umin,'umax',umax,'Vumin',Vumin,'Vumax',Vumax,...
    %   'dumin',dumin,'dumax',dumax,'utarget',utarget,...
    %   'Vdumin',Vdumin,'Vdumax',Vdumax,...
    %   'ymin',ymin,'ymax',ymax,'Vymin',Vymin,'Vymax',Vymax);
    
    
    % Perhaps we can eliminate 'optimalseq' if we decide that the QP problem will be always feasible
    optimalseq=zeros(degrees,1);
    
    MPCstruct=struct('ts',ts,'PTYPE',PTYPE,...
        'nu',nu,'nv',nv,'nym',nym,'ny',ny,...
        'degrees',degrees,'MuKduINV',MuKduINV,'KduINV',KduINV,'Kx',Kx,'Ku1',Ku1,'Kut',Kut,...
        'Kr',Kr,'Kv',Kv,'zmin',zmin,'rhsc0',rhsc0,...
        'Mlim',Mlim,'Mx',Mx,'Mu1',Mu1,'Mv',Mv,'rhsa0',rhsa0,'TAB',TAB,...
        'optimalseq',optimalseq,'utarget',utarget,...
        'p',p,'Jm',Jm,'DUFree',DUFree,...
        'uoff',uoff,'yoff',yoff,'voff',voff,'myoff',myoff);
    
end

MPCstruct.outdistchannels=outdistchannels;
MPCstruct.indistchannels=indistchannels;

MPCstruct.nxQP=nx; % Only the states of Plant and Disturbance models are used for QP
MPCstruct.nutot=nutot;

if strcmp(flag,'saveQPmodel')|strcmp(flag,'outdistmodel')|outdistflag, %|strcmp(flag,'ssmodel') << only needed for SSMODEL(MPCobj,'prediction'),
    % Save QP model -- It may be needed by MPCMOVE when yopt,xopt are
    % requested
    MPCstruct.QPmodel=model;
    
    % For computing optimal sequence of states and outputs
    [Ar,Br,Cr,Dr]=ssdata(model);
    MPCstruct.Ar=Ar;
    MPCstruct.Bur=Br(:,mvindex);
    MPCstruct.Bvr=Br(:,mdindex);
    MPCstruct.Cr=Cr;
    MPCstruct.Dvr=Dr(:,mdindex);
end

% Check measurement noise model and augment the system (if needed).
% The resulting model is used for the Kalman filter (both design of the gain 
% and on-line implementation).
%
% The states of Noise.Model are appended at the end
%InitialStateNoise=[];
xn0=xmpc0.Noise;

[model,xn0,nnMN,Bmn,Dmn,nxnoise]=mpc_chkmnmodel(model,Noise,xn0,...
    myindex,mvindex,mdindex,nym);

x0=[xp0;xd0;xn0]; % Initial extended state vector
nx=length(x0); % now nx also includes states of Disturbance and Noise models

MPCstruct.nx=nx; % Total size of extended state vector 
MPCstruct.xoff=[xoff;zeros(nxnoise+nxumd,1)]; 

MPCstruct.nxumd=nxumd; % Needed by MPCLOOP, MPC_INIT, SSMODEL
MPCstruct.nxnoise=nxnoise; % Needed by MPCLOOP, MPC_INIT, SSMODEL
MPCstruct.nxp=nxp;  % Needed by MPCLOOP, MPC_INIT
MPCstruct.xpoff=xoff; % Needed by MPCLOOP, MPC_INIT

if strcmp(flag,'mpcloop')|strcmp(flag,'outdistmodel')|outdistflag,
    MPCstruct.myindex=myindex;
    MPCstruct.nd=nd; % It only accounts for unmeasured disturbances to Plant, and therefore
    % does not include additional output integrators
    MPCstruct.Ap=Ap;              
    MPCstruct.Bup=Bup;  
    MPCstruct.Bvp=Bvp;  
    MPCstruct.Bdp=Bdp;  
    MPCstruct.Cp=Cp;              
    MPCstruct.Dvp=Dvp;  
    MPCstruct.Ddp=Ddp;  
    MPCstruct.dxpoff=dxoff; 
end

% Now left with observer

if ~mpcobj.MPCData.L_ready | strcmp(flag,'outdistmodel'), % observer gain not ready
    
    % unindex is not updated, so that it represents the number of UMD entering 
    % Plant+Disturbance+Integrators model (while MPCData.unindex equals the number 
    % of UMDs entering Model.Plant)

    Cm=model.C(myindex,:);
    Dvm=model.D(myindex,mdindex);
    
    A=model.A;
    Bu=model.B(:,mvindex);
    Bv=model.B(:,mdindex);
    
    InputCovariance=eye(nu+nv);
    DisturbanceCovariance=eye(nnUMD);
    NoiseCovariance=eye(nnMN);
    
    
    
    % Covariance matrices
    S13=blkdiag(DisturbanceCovariance,eye(nnUMDyint),InputCovariance);
    S2=NoiseCovariance;
    
    %[S13,S2]=mpc_chkcovmat(InputCovariance,DisturbanceCovariance,...
    %   NoiseCovariance,nu,nnUMD,nnMN,nnUMDyint);
    
    
    % Design estimator gain (NOTE: what is called M here is also called M in KALMAN's help file)
    %if ~strcmp(swarn(1).state,'off'),
    %    fprintf('-->Designing default Kalman estimator ... ')
    %end
    M=mpc_estimator(model,Bmn,Dmn,S13,S2,mvindex,mdindex,myindex,nnUMD+nnUMDyint);
    %if ~strcmp(swarn(1).state,'off'),
    %    fprintf('Done!\n')
    %end
else
    
    % Retrieves observer gain and matrices from MPC object 
    
    M=mpcobj.MPCData.MPCstruct.M;
    Cm=mpcobj.MPCData.MPCstruct.Cm;
    Dvm=mpcobj.MPCData.MPCstruct.Dvm;
    A=mpcobj.MPCData.MPCstruct.A;
    Bu=mpcobj.MPCData.MPCstruct.Bu;
    Bv=mpcobj.MPCData.MPCstruct.Bv;
    
end

if strcmp(flag,'ssmodel')|strcmp(flag,'outdistmodel')|outdistflag,
    MPCstruct.B=model.B;
    MPCstruct.C=model.C;
    MPCstruct.D=model.D;
    MPCstruct.nnUMDyint=nnUMDyint;
    MPCstruct.nnUMD=nnUMD;
    MPCstruct.nnMN=nnMN;
    MPCstruct.Bmn=Bmn;
    MPCstruct.Dmn=Dmn;
    
    MPCstruct.uyoff=uyoff; % Needed by TRIM
    
end

MPCstruct.A=A;
MPCstruct.Cm=Cm;
MPCstruct.Dvm=Dvm;
MPCstruct.Bu=Bu;
MPCstruct.Bv=Bv;
MPCstruct.M=M;

MPCstruct.lastx=x0;
MPCstruct.lastu=u1;

MPCstruct.maxiter=MaxIter;