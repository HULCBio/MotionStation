function [LTIcon,Br,Dr,Bv,Dv,Boff,Doff,But,Dut]=ss(MPCobj,ref_preview,md_preview,name_flag)

%SS State-space system corresponding to linearized MPC object (no constraints)
%
%   LTIcon=ss(MPCobj) returns the linear controller LTIcon as an LTI system 
%   in SS form corresponding to the MPC controller when the constraints are 
%   not active. The purpose is to use the linear equivalent control in the 
%   Control Toolbox for sensitivity and other linear analysis.
%
%   The general syntax is 
%   [LTIcon,Br,Dr,Bv,Dv,Boff,Doff,But,Dut]=ss(MPCobj,ref_preview,md_preview,name_flag)
%  
%   The MPC linear controller has the following structure:
%  
%   x(t+1) = A x(t) + B ym(t) + Br r(t) + Bv v(t) + But utarget(t) + Boff
%   u(t)  = C x(t) + D ym(t) + Dr r(t) + Dv v(t) + Dut utarget(t) + Doff
%     
%   where LTIcon=ss(A,B,C,D,MPCobj.Ts)and Br,Bv,Boff,Dr,Dv,Dt are optional output arguments.
%  
%   In the general case of nonzero offsets, ym[r,v,utarget] must be interpreted 
%   as the difference between the vector and the corresponding offset. 
%   Vectors Boff,Doff are constant terms due to nonzero offsets, in particular 
%   they are nonzero if and only if Nominal.DX is nonzero (continuous-time 
%   prediction models), or Nominal.Dx-Nominal.X is nonzero (discrete-time 
%   prediction models). Note that when Nominal.X is an equilibrium state, 
%   Boff,Doff are zero.
%  
%   Example: to get the transfer function LTIcon from (ym,r) to u:
% 
%   [LTIcon,Br,Dr]=ss(MPCobj);
%   set(LTIcon,’B’,[LTIcon.B,Br],’D’,[LTIcon.D,Dr]);
%  
%   Note: vector x includes the observer states (plant+disturbance+noise model) 
%   and the previous manipulated variable (i.e., LTIcon contains an integrator
%   per input channel).
%  
%   If the flag ref_preview='on', then matrix Br(Dr)corresponds to the whole 
%   reference sequence: 
%   x(t+1) = A x(t) + B ym(t) + Br*[r(t);r(t+1);...;r(t+p-1)] + ...
%  
%   Similarly if the flag md_preview='on', matrix Bv(Dv)corresponds to the 
%   whole measured disturbance sequence: x(t+1) = A x(t) + ... + Bv*[v(t);v(t+1);...;v(t+p)] + ...
%  
%   The optional input argument name_flag='names' adds state, input, and output names 
%   to the created LTI object.
%
%   See also TF, ZPK.
  
%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.10.4 $  $Date: 2004/01/03 12:24:04 $   

if nargin<1,
    error('mpc:ss:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:ss:obj','Invalid MPC object');
end

if isempty(MPCobj),
    if nargout<=1,
        LTIcon=ss;
        return
    else
        error('mpc:ss:empty','Empty MPC object');
    end
end

if nargin<2,
    md_preview='off';
end
if nargin<3,
    ref_preview='off';
end
if nargin<4,
    name_flag='';
else
    if ~ischar(name_flag),
        error('mpc:ss:2nd','Second input argument name_flag must be a string');
    end
end

% Check preview flags
if ~ischar(ref_preview),
    ref_preview=''; % to generate and error
end
if ~strcmp(ref_preview,'on') & ~strcmp(ref_preview,'off'),
    error('mpc:ss:ref','Reference preview flag must be either ''on'' or ''off''');
end
if ~ischar(md_preview),
    md_preview=''; % to generate and error
end
if ~strcmp(md_preview,'on') & ~strcmp(md_preview,'off'),
    error('mpc:ss:md','Measured disturbance preview flag must be either ''on'' or ''off''');
end

InitFlag=MPCobj.MPCData.Init;

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer)
    try
        MPCstruct=mpc_struct(MPCobj,[],'base'); % xmpc0=[]
    catch
        rethrow(lasterror);
    end

    % Update MPC object in the workspace
    MPCData=MPCobj.MPCData;
    MPCData.MPCstruct=MPCstruct;
    MPCData.Init=1;
    MPCData.QP_ready=1;
    MPCData.L_ready=1;
    MPCobj.MPCData=MPCData;
    try
       assignin('caller',inputname(1),MPCobj);
    end
 else
    MPCstruct=MPCobj.MPCData.MPCstruct;
end

% Retrieves parameters from MPCstruct

nym=MPCstruct.nym;
ny=MPCstruct.ny;
nu=MPCstruct.nu;
nx=MPCstruct.nx;
nv=MPCstruct.nv;
nxQP=MPCstruct.nxQP;
degrees=MPCstruct.degrees;


Ts=MPCstruct.ts;
p=MPCstruct.p;

A=MPCstruct.A;
Cm=MPCstruct.Cm;
Bu=MPCstruct.Bu;
Bv0=MPCstruct.Bv;
Dvm0=MPCstruct.Dvm;
M=MPCstruct.M;

KduINV=MPCstruct.KduINV;
Kx=MPCstruct.Kx;
Ku1=MPCstruct.Ku1;
Kut=MPCstruct.Kut;
Kr=MPCstruct.Kr;
Kv=MPCstruct.Kv;
PTYPE=MPCstruct.PTYPE;

% Unconstrained MPC equations:
%
% 1) x=offset-free extended state vector (Plant + Disturbance + Noise)
% 2) uold=offset-free manipulated input vector
% 3) xQP=offset-free Plant + Disturbance state vector
%
% A) ymest=Cm*x+Dvm*(v-voff);  % Measurement update of state observer
% B) x1=x+L*(ym-ymoff-ymest);   % (NOTE: what is called L here is called M in KALMAN's help file)
% C) xQP=x1(1:nxQP); % Only these first nxQP states are fed back to the QP problem
% D) zopt=-KduINV*(Kx'*xQP+Ku1'*uold+Kut'*(utarget-uoff)+Kr'*(r-yoff)+Kv'*(v-voff));
% E) u-uoff=uold+zopt(1:nu)
% F) xnew=A*x1+Bu*(u-uoff)+Bv*(v-voff);

% du(t)=(-[I 0 ... 0]*KduINV)*(Kx'*xQP+Ku1'*uold+Kut'*(utarget-uoff)+Kr'*(r-yoff)+Kv'*(v-voff));
%      = Fx*x+Dym*ym+Dv*v(1:nv-1)+Doff+Fu*uold+Dut*utarget+Dr*r

epsslack=(PTYPE==0); %=1 if eps slack is present, 0 otherwise

nmoves=degrees/nu; % number of free (vector) moves


Kmat=-[eye(nu),zeros(nu,(nmoves-1)*nu)]*KduINV(1:degrees,1:degrees);
KmatQP=Kmat*Kx'*[eye(nxQP) zeros(nxQP,nx-nxQP)];
Fx=KmatQP*(eye(nx)-M*Cm);
Dym=KmatQP*M;

IIoff=(1:p+1)*nv; % Indices of additional MD for offsets over prediction horizon
IIv=setdiff((1:nv*(p+1)),IIoff); % Indices of MDs over prediction horizon 
Ivaux=[eye(nv-1),zeros(nv-1,p*(nv-1))]; % Extract v(t) from [v(t);...;v(t+p)];

Dv=-KmatQP*M*Dvm0(:,1:nv-1)*Ivaux+Kmat*Kv(IIv,:)';
Doff=-KmatQP*M*Dvm0(:,nv)+Kmat*Kv(IIoff,:)'*ones(p+1,1);
Fu=Kmat*Ku1';
Dut=Kmat*Kut';
Dr=Kmat*Kr';


% MPC controller's state: [x;uold], where x=offset-free extended state vector 
% (Plant + Disturbance + Noise) and uold=offset-free manipulated input vector

C=[Fx Fu+eye(nu)];
AM=A*M;
AA=[A-AM*Cm+Bu*Fx,Bu+Bu*Fu;
    C];
Bym=[AM+Bu*Dym;Dym];


LTIcon=ss(AA,Bym,C,Dym,Ts);

if nargout>=2,
    Br=[Bu*Dr;Dr];
    if ~strcmp(ref_preview,'on')
        aux=kron(ones(p,1),eye(ny));
        Br=Br*aux;
        Dr=Dr*aux;
    end
    if nargout>=4,
        Bv=[(Bv0(:,1:nv-1)-AM*Dvm0(:,1:nv-1))*Ivaux+Bu*Dv;Dv];
        if ~strcmp(md_preview,'on')
            Bv=Bv*ones(p+1,1);
            Dv=Dv*ones(p+1,1);
        end
        if nargout>=6,
            Boff=[Bv0(:,nv)+Bu*Doff-AM*Dvm0(:,nv);Doff];
            if nargout>=8,
                But=[Bu*Dut;Dut];
            end
        end
    end
end

if strcmp(name_flag,'names'),
    % Assign names to LTI MPC controller
    xaux={};
    for i=1:nx,
        xaux{i}=sprintf('Estim. X #%d',i);
    end
    for i=1:nu,
        xaux{nx+i}=sprintf('Prev. MV #%d',i);
    end
    uaux={};
    for i=1:nym,
        uaux{i}=sprintf('Meas. Y #%d',i);
    end
    yaux={};
    for i=1:nu,
        yaux{i}=sprintf('MV #%d',i);
    end
    set(LTIcon,'StateName',xaux,'InputName',uaux,'OutputName',yaux);
end
