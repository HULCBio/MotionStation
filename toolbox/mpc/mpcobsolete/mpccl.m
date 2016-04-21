function [clmod,cmod]=mpccl(plant,model,Kmpc,tfilter,dplant,dmodel)
%MPCCL	Combine a plant STEP model and a controller STEP model.
%   	[clmod,cmod]=mpccl(plant,model,Kmpc,tfilter,dplant,dmodel)
% MPCCL	combines a plant STEP model and a controller STEP model.
% yielding a closed-loop system model in the MPC MOD format.
% Required Inputs:
%  plant  the plant model in the STEP format.
%  model  the internal model in the STEP format.
%  Kmpc   the controller gain matrix created by MPCCON.
% Optional Inputs:
%  tfilter matrix of filter time constants and noise dynamics.
%	   If omitted or set to an empty matrix, the default is to
%	   use the DMC estimator.
%  dplant  model in STEP format representing all the disturbances
%	   (measured and unmeasured) that affect the plant.
%	   If omitted or set to an empty matrix, the default is that
%	   there are no disturbances.
%  dmodel  model in STEP format representing the measured disturbances.
%	   If omitted or set to an empty matrix, the default is that
%	   there are no measured disturbances. See the documentation
%	   for the function MPCSIM for more details on how disturbances
%	   are handled when using step-response models.
% Outputs:
%  clmod  the resulting closed-loop system model in the MOD format.
%  cmod   the dynamic model of the controller in the MOD format (optional).
% See also CMPC, MOD2STEP, MPCCON, MPCSIM, SMPCGAIN, SMPCPOLE.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

%NOTE:  assumes measured disturbances and setpoints
%       will be constant in the future.
%
%   ny setpoints (where ny is the number of outputs).
%   ny measurement noise inputs.
%   nu additive input disturbances (w_u).
%   nd disturbances
%   ny true plant output variables.
%   nu manipulated variables.
%   ny output estimates (from the state estimator).

if nargin == 0,
   disp('Usage:  clmod = mpccl(plant,model,Kmpc)');
   disp('Usage:  [clmod,cmod] = mpccl(plant,model,Kmpc,tfilter,dplant,dmodel)');
   return
end

if nargin < 3 | nargin > 6
   error('Incorrect number of input variables')
end

if isempty(plant) | isempty (model)
   error('Plant and internal model must be non-empty, in STEP format.')
end

%Find dimensions of all inputs

[row_plant,nu_plant] = size(plant) ;
ny_plant = plant(row_plant-1,1) ;
delt_plant = plant(row_plant,1) ;
n_plant = (row_plant-2)/(ny_plant)-1;
nout_plant = plant(n_plant*ny_plant+1:n_plant*ny_plant+ny_plant,1) ;

[row_model,nu_model] = size(model) ;
ny_model = model(row_model-1,1) ;	%number of outputs
delt_model = model(row_model,1) ;	%sampling time
n_model = (row_model-2)/ny_model-1 ;	%number of step response coefficients
nout_model = model(n_model*ny_model+1:n_model*ny_model+ny_model,1) ;
					%tells us where the integrators are

[row_Kmpc,col_Kmpc]=size(Kmpc) ;
p=col_Kmpc/ny_plant ;	%horizon

if (nargin<4)
   tfilter = [];
end
[row_tfilter,col_tfilter]=size(tfilter) ;

if (nargin<5)
   dplant = [];
end

if isempty(dplant)
   dmodel = [];disp('You have assumed no disturbances')
   nout_dplant = ones(ny_plant,1);
   ny_dplant=0;
   nd_plant=0;
   n_dplant=0;
   delt_dplant=0;
else
   [row_dplant,nd_plant] = size(dplant) ;
   ny_dplant = dplant(row_dplant-1,1) ;
   delt_dplant = dplant(row_dplant,1) ;
   n_dplant = (row_dplant-2)/(ny_dplant)-1;
   nout_dplant = dplant(n_dplant*ny_dplant+1:n_dplant*ny_dplant+ny_dplant,1) ;
end

% if [p(horizon)+1] > n_model (the truncation order of the model),
% make n_model = p+1, and extend the last step response coefficients
% (p+1-n_model) times
if ((p+1)>n_model)
     k = n_model*ny_model;  kx = n_model*ny_model-ny_model+1;
     int = (ones(ny_model,1)-nout_model)*ones(1,nu_model);
      for ib = n_model+1:p+1
           model(k+1:k+ny_model,:) = model(kx:k,:)+int.*(model(kx:k,:)...
	 			-model(kx-ny_model:kx-1,:));
            k = k+ny_model;  kx = kx+ny_model;
	end;
      n_model = p+1;
end;


if (nargin==5)
   dmodel = [zeros(n_model*ny_model+ny_model,nd_plant);[ny_model;delt_dplant],...
		zeros(2,nd_plant-1)];
end

if (nargin>4)&(isempty(dmodel)==0)
   [row_dmodel,nd_model]=size(dmodel) ;
   ny_dmodel = dmodel(row_dmodel-1,1) ;	%number of outputs
   delt_dmodel = dmodel(row_dmodel,1) ;	%sampling time
   n_dmodel = (row_dmodel-2)/ny_dmodel-1 ;	%# of step response coefficients
   nout_dmodel = dmodel(n_dmodel*ny_dmodel+1:n_dmodel*ny_dmodel+ny_dmodel,1) ;
					%tells us where the integrators are
else
   nout_dmodel = ones(ny_model,1);
   ny_dmodel=0;
   n_dmodel=0;
   delt_dmodel=0;
   nd_model=0;

end


% +++ Check for errors and inconsistencies. +++

if delt_plant ~= delt_model
   error('The sampling time must be the same in PLANT and MODEL')
elseif nu_model ~= nu_plant
   error('PLANT and MODEL must have an equal number of manipulated variables')
elseif ny_model ~= ny_plant
   error('The number of outputs of PLANT and MODEL must be the same')
elseif row_tfilter > 2 & row_tfilter ~= 0
   error('TFILTER must have two or less rows')
elseif col_tfilter ~= ny_plant & col_tfilter ~= 0
   error('The # of columns of TFILTER must equal the # of PLANT outputs')
elseif (delt_dplant~=delt_dmodel) & (isempty(dplant)==0)
   error('The sampling time must be the same in DPLANT and DMODEL')
elseif (delt_dplant ~= delt_plant) & (isempty(dplant)==0)
   error('The sampling time must be the same in DPLANT and PLANT')
elseif (nd_model ~= nd_plant) & (isempty(dplant)==0)
   error('The number of disturbances to DPLANT and DMODEL must be the same')
elseif (ny_dmodel ~= ny_dplant) & (isempty(dplant)==0)
   error('The number of outputs of DPLANT and DMODEL must be the same')
elseif (ny_dplant ~= ny_plant) & (isempty(dplant)==0)
   error('The number of outputs of DPLANT and PLANT must be the same')
elseif row_Kmpc ~= nu_model
   error('The number of controller outputs and plant inputs must be the same')
elseif round(col_Kmpc/ny_plant) ~= p
   error('Input matrix Kmpc has wrong number of columns')
end

% +++ set dimensions

nu = nu_plant;
ny = ny_plant;
nd = nd_plant;
np = n_plant;
nm = n_model;
ndp = n_dplant;
ndm = n_dmodel;
nmny = nm*ny;

% +++ make the truncation order of PLANT and DPLANT equal

intp = ones(ny,1)-nout_plant;
intdp = ones(ny,1)-nout_dplant;
if (ndp>np)
   k = np*ny;	kx = np*ny-ny+1;
   int = intp*ones(1,nu);
   for ib = np+1:ndp
       plant(k+1:k+ny,:) = plant(kx:k,:)+int.*(plant(kx:k,:)...
                                        -plant(kx-ny:kx-1,:));
       kx = kx + ny;
       k = k + ny;
   end;
   np = ndp;n_plant = ndp;
elseif (ndp<np) & (ndp>0)
   k = ndp*ny;          kx = ndp*ny-ny+1;
   int = intdp*ones(1,nu);
   for ib = ndp+1:np
       dplant(k+1:k+ny,:) = dplant(kx:k,:)+int.*(dplant(kx:k,:)...
					-dplant(kx-ny:kx-1,:));
       k = k + ny;
       kx = kx + ny;
   end;
   ndp = np;n_dplant = np;
end;

% +++ make the truncation order of MODEL and DMODEL equal

intm = ones(ny,1)-nout_model;
intdm = ones(ny,1)-nout_dmodel;
if (ndm>nm)
   k = nm*ny;	kx = nm*ny-ny+1;
   int = intm*ones(1,nu);
   for ib = nm+1:ndm
       model(k+1:k+ny,:) = model(kx:k,:)+int.*(model(kx:k,:)...
                                        -model(kx-ny:kx-1,:));
       k = k + ny;
       kx = kx + ny;
   end;
   nmny = k;   nm = ndm;n_model=ndm;
elseif (ndm<nm) & (ndm>0)
   k = ndm*ny;          kx = ndm*ny-ny+1;
   int = intdm*ones(1,nu);
   for ib = ndm+1:nm
       dmodel(k+1:k+ny,:) = dmodel(kx:k,:)+int.*(dmodel(kx:k,:)...
					-dmodel(kx-ny:kx-1,:));
       k = k + ny;
       kx = kx + ny;
   end;
   ndm = nm; n_dmodel = nm;
end;

% +++ interpret filter and disturbance time constants +++

[nrtfil,nctfil]=size(tfilter);
if (isempty(tfilter))
     tdist=[];
elseif nrtfil==1
     tdist=[];
else
     tdist=tfilter(2,:);
     tfilter=tfilter(1,:);
end;
KF = zeros(ny+nmny,ny);
for i = 1:ny
   if (isempty(tfilter)==1)
       fa(i)=1;
       for j = 1:nm
          KF((j-1)*ny+i,i)=fa(i);
       end;
    else
       if tfilter(i)==0
          fa(i) = 1;
       elseif tfilter(i)==inf
          fa(i) = 0;
       else
          fa(i)=1-exp(-delt/tfilter(i));
          if fa(i) < 0 | fa(i) > 1
             error('Filter time constants must be positive')
          end;
       end;
       for j = 1:nm
          KF((j-1)*ny+i,i)=fa(i);
       end;
    end;
end;
for i=1:ny
  if (isempty(tdist))
      if (nout_model(i)==0|nout_dmodel(i)==0)
          alpha(i)=1;
      else
          alpha(i)=0;
      end;
  else
     if tdist(i)==0
           alpha(i)=0;
     elseif tdist(i)==inf
           alpha(i)=1;
     elseif ((noutm(i)==0|noutdm(i)==0) & tdist(i)~=inf)
           disp('WARNING: tdist(i) must equal inf');
           disp('         for integrating outputs.');
           disp('         tdist(i) will be set to inf.');
           alpha(i)=1;
     else
           alpha(i)= exp(-delt/tdist(i));
           if alpha(i) < 0 | alpha(i) > 1
             error('Disturbance time constants must be positive');
           end;
     end;
  end;
     fb(i) = alpha(i)*fa(i)^2/(1+alpha(i)-alpha(i)*fa(i));
end;
KFA = zeros(nmny,ny);
Ad=diag(alpha);
for i=2:nm
      KFA((i-1)*ny+1:i*ny,1:ny)=KFA((i-2)*ny+1:(i-1)*ny,1:ny) + Ad^(i-2);
end;

KFA(nmny+1:nmny+ny,1:ny)=Ad^(nm-1);
KF(nmny+1:nmny+ny,1:ny)=zeros(ny,ny);

KFB=KFA*diag(fb);
K = KF + KFB;

% +++ Define the state-space model of the closed-loop system. +++

S_u_plant = plant(1:n_plant*ny,1:nu);
S_u_model = [model(1:n_model*ny,1:nu);zeros(ny,nu)];

Np = [eye(ny),zeros(ny,np*ny-ny)];
Nm = [eye(ny),zeros(ny,nm*ny)];

%build M for model

M_model = zeros(nm*ny+ny);
for i = 1:nm*ny,
   M_model(i,ny+i) = 1;
end
H = diag(nout_model)*diag(nout_dmodel)-eye(ny);
G = 2*eye(ny)-diag(nout_model)*diag(nout_dmodel);
for i = 0:ny-1
   M_model(nm*ny+ny-i,nm*ny+ny-i) = Ad(ny-i,ny-i);
end
for i = 0:ny-1
   M_model(nm*ny-i,nm*ny-i) = G(ny-i,ny-i);
end
for i = 0:ny-1
   M_model(nm*ny-i,nm*ny-i-ny) = H(ny-i,ny-i);
end

%build M for plant

M_plant = zeros(np*ny);
for i = 1:np*ny-ny,
   M_plant(i,ny+i) = 1;
end
H = diag(nout_plant)*diag(nout_dplant)-eye(ny);
G = 2*eye(ny)-diag(nout_plant)*diag(nout_dplant);
for i = 0:ny-1
   M_plant(np*ny-i,np*ny-i) = G(ny-i,ny-i);
end
for i = 0:ny-1
   M_plant(np*ny-i,np*ny-i-ny) = H(ny-i,ny-i);
end

M_p = [eye(p*ny),zeros(p*ny,(nm+1)*ny-p*ny)]*M_model;

R = eye(ny) ;
for i = 2:p,
   R = [R;eye(ny)] ;
end

% +++ Define the state-space model of the closed-loop system. +++

M = M_plant;
su = S_u_plant;
sum = S_u_model;

if isempty(dplant)
   A_bar = [M,-su*Kmpc*M_p;K*Np*M,...
	-(sum-K*Nm*sum+K*Np*su)*Kmpc*M_p+(eye((nm+1)*ny)-K*Nm)*M_model];
   B_bar = [su;K*Np*su];
   C_bar = [su*Kmpc*R,zeros(np*ny,ny);(sum-K*Nm*sum+K*Np*su)*Kmpc*R,K];
   D_bar = [B_bar;eye(nu);zeros(nu,nu)];
   E_bar = [C_bar;zeros(nu,ny+ny);Kmpc*R,zeros(nu,ny)];
   J_bar = [Np,zeros(ny,ny*(nm+1)+(nu)+nu);...
	   zeros(nu,np*ny+ny*(nm+1)+nu+nu);...
	   zeros(ny,np*ny),Nm,zeros(ny,(nu)+nu)];
   K_bar = [zeros(ny,ny*np+ny*(nm+1)+nu+nu);...
	   zeros(nu,np*ny+ny*(nm+1)+nu),eye(nu);...
	   zeros(ny,np*ny+ny*(nm+1)+nu+nu)];
   phi_CL = [A_bar,-B_bar,zeros(np*ny+(nm+1)*ny,nu);...
	    zeros(nu,np*ny+(nm+1)*ny+(nu)+nu);...
	    zeros(nu,np*ny),-Kmpc*M_p,zeros(nu,nu),eye(nu)];
   gamma_CL = [E_bar,D_bar];
   C_CL = J_bar+K_bar*phi_CL;
   D_CL = K_bar*gamma_CL;
else
   S_d_plant = dplant(1:n_dplant*ny,1:nd);sd = S_d_plant;
   S_d_model=[dmodel(1:n_dmodel*ny,1:nd);zeros(ny,nd)];sdm = S_d_model;
   A_bar = [M,-su*Kmpc*M_p;K*Np*M,...
	-(sum-K*Nm*sum+K*Np*su)*Kmpc*M_p+(eye((nm+1)*ny)-K*Nm)*M_model];
   B_bar = [su,sd;K*Np*su,(sdm-K*Nm*sdm+K*Np*sd)];
   C_bar = [su*Kmpc*R,zeros(np*ny,ny);(sum-K*Nm*sum+K*Np*su)*Kmpc*R,K];
   D_bar = [B_bar;eye(nu+nd);zeros(nu,nu+nd)];
   E_bar = [C_bar;zeros(nu+nd,ny+ny);Kmpc*R,zeros(nu,ny)];
   J_bar = [Np,zeros(ny,ny*(nm+1)+(nu+nd)+nu);...
	   zeros(nu,np*ny+ny*(nm+1)+(nu+nd)+nu);...
	   zeros(ny,np*ny),Nm,zeros(ny,(nu+nd)+nu)];
   K_bar = [zeros(ny,ny*np+ny*(nm+1)+(nu+nd)+nu);...
	   zeros(nu,np*ny+ny*(nm+1)+(nu+nd)),eye(nu);...
	   zeros(ny,np*ny+ny*(nm+1)+(nu+nd)+nu)];
   phi_CL = [A_bar,-B_bar,zeros(np*ny+(nm+1)*ny,nu);...
	    zeros(nu+nd,np*ny+(nm+1)*ny+(nu+nd)+nu);...
	    zeros(nu,np*ny),-Kmpc*M_p,zeros(nu,nu+nd),eye(nu)];
   gamma_CL = [E_bar,D_bar];
   C_CL = J_bar+K_bar*phi_CL;
   D_CL = K_bar*gamma_CL;
end

%  +++ return the closed loop model +++

clmod=ss2mod(phi_CL,gamma_CL,C_CL,D_CL,delt_plant);

% +++ return the optional controller model +++

if nargout > 1
   N = Nm ;n=nm;
   if isempty(dplant)
      A_bar = [(eye(n*ny+ny)-K*N)*S_u_model*Kmpc*R,K] ;
      B_bar = [(eye(n*ny+ny)-K*N)*(M_model-S_u_model*Kmpc*M_p)] ;
      phi_C = [B_bar,zeros((nm+1)*ny,nu);-Kmpc*M_p,eye(nu)] ;
      gamma_C = [A_bar;Kmpc*R,zeros(nu,ny)] ;
      C_C = [-Kmpc*M_p,eye(nu)] ;
      D_C = [Kmpc*R zeros(nu,ny)] ;
   else
      A_bar = [(eye(n*ny+ny)-K*N)*S_u_model*Kmpc*R,K] ;
      B_bar = [(eye(n*ny+ny)-K*N)*(M_model-S_u_model*Kmpc*M_p),...
		-1*(eye(n*ny+ny)-K*N)*S_d_model;zeros(nd,(nm+1)*ny+nd)] ;
      C_bar = [(eye(n*ny+ny)-K*N)*S_d_model;eye(nd)] ;
      phi_C = [B_bar,zeros((nm+1)*ny+nd,nu);-Kmpc*M_p,zeros(nu,nd),eye(nu)] ;
      gamma_C = [[A_bar;zeros(nd,ny+ny)],C_bar;Kmpc*R,zeros(nu,ny+nd)] ;
      C_C = [-Kmpc*M_p,zeros(nu,nd),eye(nu)] ;
      D_C = [Kmpc*R zeros(nu,ny+nd)] ;
   end
   cmod=ss2mod(phi_C,gamma_C,C_C,D_C,delt_plant);
end