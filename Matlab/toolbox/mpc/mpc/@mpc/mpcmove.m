function [u, Info] = mpcmove(MPCobj,state,y,r,v)

%MPCMOVE computes the current manipulated plant inputs for MPC.
%
%   [u, Info]=MPCMOVE(MPCobj,x,y,r,v)
%
%   MPCobj = an MPC object specifying the controller to be used.
%   x = current extended state vector, an mpcstate object. 
%   y = current measured plant outputs.
%   r = current setpoints for plant outputs.
%   v = current measured disturbances.
%
%   u = manipulated plant inputs computed by MPC, to be used in
%     the next sampling time.
%   Info = structure giving details of the optimal control calculations, with fields
%     Info.Uopt = optimal input sequence
%         .Yopt = optimal output sequence
%         .Xopt = optimal state sequence
%         .Topt = time sequence 0,1,...p-1 (p=prediction horizon) 
%         .Slack = ECR slack variable at optimum
%         .Iterations = number of iterations needed by the QP solver
%         .QPCode = exit code from QP solver
%
%
%   r/v can be either a sample (no future reference/disturbance known) 
%   or a sequence of samples (when a preview anticipative effect is desired). 
%   The last sample is extended constantly over the horizon, to obtain the 
%   correct size
%
%   Note:  upon the first call, if the input variable x is omitted a zero
%   state object will be constructed.
%
%   Use this same form in all subsequent calls.
%
%   See also ESTIMATOR, MPC, SIM, MPCSTATE.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2004/04/16 22:08:56 $   

if nargin<1,
    error('mpc:mpcmove:none','No MPC object supplied.');
end
if nargin<2 || isempty(state),
    error('mpc:mpcmove:nostate',sprintf(...
        'No (or empty) mpcstate supplied. You can use "state=mpcstate(%s)" to create one',...
        inputname(1)));
end
if ~isa(MPCobj,'mpc'),
    error('mpc:mpcmove:obj','Invalid MPC object');
end
if isempty(MPCobj),
    error('mpc:mpcmove:empty','Empty MPC object');
end

MPCData=getmpcdata(MPCobj);
InitFlag=MPCData.Init;

if nargout>=2,
    save_flag='saveQPmodel';
else
    save_flag='base';
end

if strcmp(save_flag,'saveQPmodel'),
    if ~isfield(MPCData,'MPCstruct'),
        InitFlag=0;
    else
        if ~isfield(MPCData.MPCstruct,'QPmodel'),
            InitFlag=0;
        end
    end
end

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer) 
    try
        MPCstruct=mpc_struct(MPCobj,[],save_flag); % xmpc0=[]
    catch
        rethrow(lasterror);
    end

    % Update MPC object in the workspace
    MPCData=getmpcdata(MPCobj);
    MPCData.Init=1;
    MPCData.QP_ready=1;
    MPCData.L_ready=1;
    MPCData.MPCstruct=MPCstruct;
    setmpcdata(MPCobj,MPCData);
    try
       assignin('caller',inputname(1),MPCobj);
    end
else
    MPCstruct=MPCData.MPCstruct;
end

% Retrieves parameters from MPCstruct

nu=MPCstruct.nu;
nv=MPCstruct.nv;
nym=MPCstruct.nym;
nx=MPCstruct.nx;
ny=MPCstruct.ny;
nxQP=MPCstruct.nxQP;

A=MPCstruct.A;
Bu=MPCstruct.Bu;
Bv=MPCstruct.Bv;
Cm=MPCstruct.Cm;
Dvm=MPCstruct.Dvm;
PTYPE=MPCstruct.PTYPE;
M=MPCstruct.M;
MuKduINV=MPCstruct.MuKduINV;
KduINV=MPCstruct.KduINV;
Kx=MPCstruct.Kx;
Ku1=MPCstruct.Ku1;
Kut=MPCstruct.Kut;
Kr=MPCstruct.Kr;
Kv=MPCstruct.Kv;
Jm=MPCstruct.Jm;
DUFree=MPCstruct.DUFree;
zmin=MPCstruct.zmin;
rhsc0=MPCstruct.rhsc0;
Mlim=MPCstruct.Mlim;
Mx=MPCstruct.Mx;
Mu1=MPCstruct.Mu1;
Mv=MPCstruct.Mv;
rhsa0=MPCstruct.rhsa0;
TAB=MPCstruct.TAB;
optimalseq=MPCstruct.optimalseq;
utarget=MPCstruct.utarget;
degrees=MPCstruct.degrees;
uoff=MPCstruct.uoff;
yoff=MPCstruct.yoff;
voff=MPCstruct.voff;
myoff=MPCstruct.myoff;
maxiter=MPCstruct.maxiter;

p=MPCobj.PredictionHorizon;
xoff=MPCstruct.xoff;


% Output
if nargin<3,
    y=[];
end
if isempty(y),
    y=zeros(nym,1);
else
    if ~isa(y,'double'),
        error('mpc:mpcmove:y','Current output measurement must be real valued.')
    elseif ~all(isfinite(y)), %some y(i) are Inf
        error('mpc:mpcmove:yinf','Infinite output measurements are not allowed.')
    else
        [n,m]=size(y);
        if n*m~=nym, 
            error('mpc:mpcmove:ydim',sprintf('The output measurement vector should have dimension %d.',nym));
        end
        y=y(:)-myoff;
    end
end

% Reference signal
if nargin<4,
    r=[];
end
if isempty(r),
    r=yoff';
    n=1;
else
    if ~isa(r,'double'),
        error('mpc:mpcmove:r','Reference signal must be real valued.')
    elseif ~all(isfinite(r)), %some r(i,j) are Inf
        error('mpc:mpcmove:rinf','Infinite reference signals are not allowed.')
    else
        [n,m]=size(r);
        if n==ny,
            r=r'; % Puts it as a row vector
            m=ny;
            n=1;
        end
        if m~=ny, 
            error('mpc:mpcmove:rdim',sprintf('The reference signal should have %d entries or columns.',ny));
        end
    end
end

if n==1,
    % no preview, r has dimension 1-by-ny
    r=r-yoff';
    r=ones(p,1)*r;
else
    % preview is on
    r=r-ones(n,1)*yoff';
    if n>p,
        r=r(1:p,:);
    elseif n<p,
        r=[r;ones(p-n,1)*r(n,:)];
    end
end
r=r';
r=r(:);    %Put r in one column


% Measured disturbance signal
% Here nv = number of true measured disturbances + 1 (because offsets are treated as MDs)
if nargin<5,
    v=[];
end
if isempty(v),
    v=voff';
    n=1;
else
    if ~isa(v,'double'),
        error('mpc:mpcmove:v','Measured disturbance signal must be real valued.')
    elseif ~all(isfinite(v)), %some v(i,j) are Inf
        error('mpc:mpcmove:vinf','Infinite measured disturbance signals are not allowed.')
    else
        [n,m]=size(v);
        if n==nv-1,
            v=v'; % Puts it as a row vector
            m=nv-1;
            n=1;
        end
        if m~=nv-1, 
            error('mpc:mpcmove:vdim',sprintf('The measured disturbance signal should have %d entries or columns.',nv-1));
        end
    end
end

if n==1,
    % no preview, v has dimension 1-by-nv-1
    v=v-voff';
    v=[v,1]; % Add measured disturbance for offsets
    v=ones(p+1,1)*v;
else
    % preview is on
    v=v-ones(n,1)*voff';
    if n>p+1,
        v=v(1:p+1,:);
    elseif n<p,
        v=[v;ones(p+1-n,1)*v(n,:)];
    end
    v=[v,ones(p+1,1)]; % Add measured disturbance for offsets
end
v=v';
v=v(:);  %Put v in one column 

if ~isa(state,'mpcdata.mpcstate'),
    error('mpc:mpcmove:state','Extended state vector must be a valid MPCSTATE object');
end

nxp=MPCstruct.nxp;
nxumd=MPCstruct.nxumd;
nxnoise=MPCstruct.nxnoise;

try
    xp=mpc_chkstate(state,'Plant',nxp,xoff(1:nxp));
    xd=mpc_chkstate(state,'Disturbance',nxumd,xoff(nxp+1:nxp+nxumd));
    xn=mpc_chkstate(state,'Noise',nxnoise,xoff(nxp+nxumd+1:end));
    uold=mpc_chkstate(state,'LastMove',nu,uoff);
catch
    rethrow(lasterror);
end
x=[xp;xd;xn]; % offset-free current state

% Measurement update of state observer
yest=Cm*x+Dvm*v(1:nv);
x=x+M*(y-yest);  % (NOTE: what is called L here is called M in KALMAN's help file)

% Solves MPC optimization problem
isunconstr=(PTYPE==2);
useslack=(PTYPE==0);

if isempty(Kv),
    vKv=zeros(1,degrees);
    if ~isunconstr,
        Mvv=zeros(size(Mlim));
    end
else
    vKv=v'*Kv;
    if ~isunconstr,
        Mvv=Mv*v;
    end
end


xQP=x(1:nxQP); % Only these first nx states are fed back to the QP problem
% (i.e., multiplied by the Kx gain)

% Solves optimization problem
try
    if isunconstr,
        [zopt,slack,how,iter]=mpc_solve([],KduINV,Kx,Ku1,Kut,Kr,[],[],...
            [],[],[],[],[],[],Jm,DUFree,...
            xQP,uold,utarget,r,vKv,...
            nu,p,degrees,optimalseq,isunconstr,useslack,maxiter);

    else
        [zopt,slack,how,iter]=mpc_solve(MuKduINV,KduINV,Kx,Ku1,Kut,Kr,zmin,rhsc0,...
            Mlim,Mx,Mu1,Mvv,rhsa0,TAB,Jm,DUFree,...
            xQP,uold,utarget,r,vKv,...
            nu,p,degrees,optimalseq,isunconstr,useslack,maxiter);
    end
catch
    rethrow(lasterror);
end

% Compute the current input (previous input + new input increment)
u=uold+zopt(1:nu); % The first delta-u move is always a degree of freedom

%%% BEGIN - Compute Optimal Trajectories
if nargout>=2,
    % Compute optimal sequence of inputs U
    duopt=Jm*zopt;
    for i=1:nu,
        uopt(:,i)=cumsum(duopt(i:nu:p*nu))+uold(i)+uoff(i);
    end
    Ar=MPCstruct.Ar;
    Bur=MPCstruct.Bur;
    Bvr=MPCstruct.Bvr;
    Cr=MPCstruct.Cr;
    Dvr=MPCstruct.Dvr;
    ts=MPCstruct.ts;        
    
    yopt=zeros(p+1,ny);
    xopt=zeros(p+1,MPCstruct.nxQP);
    topt=zeros(p+1,1);
    for t=1:p+1,
        vv=v((t-1)*nv+1:t*nv);
        yopt(t,:)=(Cr*xQP+Dvr*vv+yoff)'; %no feedthrough from manipulated vars;
        xopt(t,:)=(xQP+xoff(1:nxQP))';
        topt(t,:)=ts*(t-1);
        if t<p+1,
            uu=uopt(t,:)'-uoff;
            xQP=Ar*xQP+Bur*uu+Bvr*vv;
        end
    end
    % Only returns optimal trajectories for t=0,...,p-1
    Info=struct('Uopt',uopt,'Yopt',yopt(1:p,:),'Xopt',xopt(1:p,:),'Topt',topt(1:p,:),'Slack',slack,...
        'Iterations',iter,'QPCode',how);
end
%%% END - Compute Optimal Trajectories

% Time update of state observer (based on the full model Plant+Disturbance+Noise)

xnew=A*x+Bu*u+Bv*v(1:nv);

%% Rebuilds optimalseq from zopt
%free=find(kron(Mat.DUFree(:),ones(nu,1))); % Indices of free moves
optimalseq=zopt;%(free);

%MPCstruct.lastx=xnew;
%MPCstruct.lastu=u;


%% Update MPC object in the workspace, in order to save .lastx and .lastu
%MPCobj.MPCData.MPCstruct=MPCstruct;
%mpcobjname=inputname(1);
%assignin('caller',mpcobjname,MPCobj);

xnew = xnew+xoff; % Add offset on extended state
u = u+uoff; % Add offset on manipulated vars
set(state,'Plant',xnew(1:nxp),'Disturbance',xnew(nxp+1:nxp+nxumd),'Noise',...
    xnew(nxp+nxumd+1:end),'LastMove',u);
