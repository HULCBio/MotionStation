function [KduINV,Kx,Kr,Ku1,Kv,Kut,Jm,DUFree,TAB,MuKduINV,rhsa0,rhsc0,...
         Mlim,Mx,Mu1,Mv,zmin,... 
         degrees]=mpc_buildmat(...
      A,Bu,Bv,C,Dv,uwt,duwt,ywt,umin,umax,dumin,dumax,ymin,ymax,...
      Vumin,Vumax,Vdumin,Vdumax,Vymin,Vymax,p,m,...
	      mvi,mdi,uni,ptype,nx,ny,nutot,nu,nv,rhoeps)
      
%MPC_BUILDMAT  Builds optimization matrices (constrained) / gain controllers (unconstrained)
      
%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2004/04/10 23:39:07 $   

% Build Sx,Su1,Hv,Hd

pny=p*ny;
Sx=zeros(pny,nx);
Su1=zeros(pny,nu);
Hv=zeros(pny,(p+1)*nv);
%Hd=zeros(pny,(p+1)*nd);
Su=zeros(pny,p*nu);

CA=C*A;
rows=1:ny;
Sx(rows,:)=CA;
Su1(rows,:)=C*Bu;

if nv,
   Hv(rows,:)=[C*Bv,Dv,zeros(ny,(p-1)*nv)];
end
%if nd,
%   Hd(rows,:)=[C*Bd,Dd,zeros(ny,(p-1)*nd)];
%end
Sum=C*Bu;
Su(rows,:)=[Sum,zeros(ny,(p-1)*nu)];

for i=2:p,
   rows=((i-1)*ny+1:i*ny);
   Su1(rows,:)=Su1(rows-ny,:)+CA*Bu;
   if nv,
      Hv(rows,:)=[CA*Bv,Hv(rows-ny,1:p*nv)];
   end
   %if nd,
   %   Hd(rows,:)=[CA*Bd,Hd(rows-ny,1:p*nd)];
   %end
   Sum=Sum+CA*Bu;
   Su(rows,:)=[Sum,Su(rows-ny,1:(p-1)*nu)];
   
   CA=CA*A;
   Sx(rows,:)=CA;
end

% Build Jm (blocking moves matrix) and DUFree (free input moves)

Inu=eye(nu);
nb=size(m,2); % Row vector
if nb==1,
   moves=[ones(1,m-1) p-m+1];
else
   moves=m; % sum(m)=P has already been checked in chkm.m
end

nmoves=length(moves);
degrees=nmoves*nu;


Jm=zeros(nu*p,degrees); % The number of columns of Jm equals
                        % the number of optimization vars

%DUFree=zeros(degrees,1); % DUfree(i)=1 iff DU(i) is free 
% length(find(index)) = number of optimization vars
%
j=0;
for i=1:nmoves,
   ni=moves(i);
   %Jm(j*nu+1:(j+ni)*nu,1+(i-1)*nu:i*nu)=kron([1;zeros(ni-1,1)],Inu);
   %DUFree(j*nu+1:(j+ni)*nu)=kron([1;zeros(ni-1,1)],ones(nu,1));
   
   % ALTERNATIVE way of computing Jm 
   Jm(j*nu+1:(j+1)*nu,1+(i-1)*nu:i*nu)=Inu;
   j=j+ni;
end
% ALTERNATIVE way of computing DUFree
DUFree=sum(Jm')';


I1=kron(ones(p,1),Inu);
I2=kron(tril(ones(p,p)),Inu);

% Build Wu
%uwt=extend(uwt,p); % Extends matrix by repeating last row
uwtc=uwt';uwtc=uwtc(:);
Wu=diag(uwtc.^2);
clear uwtc

% Build Wdu. 

% The following was removed:
%For numerical stability, we add a slight weight on duwt. 
%Note that the optimization problem is solved w.r.t. du
%duwt=duwt+10*sqrt(eps);  

%duwt=extend(duwt,p); % Extends matrix by repeating last row
duwtc=duwt';duwtc=duwtc(:);
Wdu=diag(duwtc.^2);
clear duwtc


% Build Wy
%ywt=extend(ywt,p); % Extends matrix by repeating last row
ywtc=ywt';ywtc=ywtc(:);
Wy=diag(ywtc.^2);
clear ywtc

% Build Kdu,Ku1,Kx,Kv,Kd,Kut

SuJm=Su*Jm;
I2Jm=I2*Jm;
WySuJm=Wy*SuJm;
WuI2Jm=Wu*I2Jm;

Kdu=(SuJm)'*WySuJm+Jm'*Wdu*Jm+Jm'*I2'*WuI2Jm;

%clear SuJm

Ku1=Su1'*WySuJm+I1'*WuI2Jm;
Kut=-Wu*I2Jm;

%clear I2Jm WuI2Jm

Kx=Sx'*WySuJm;

if nv,
   Kv=Hv'*WySuJm;
else
   Kv=[];
end
%if nd,
%   Kd=Hd'*WySuJm;
%else
%   Kd=[];
%end

Kr=-WySuJm;

%clear WySuJm

bigcondnum=1e12;
smallhessian=10*sqrt(eps);
warnmsghessian='Hessian matrix of QP problem is close to singular. Augmenting diagonal terms';

if ptype>=1,
    % Check positive definiteness of Kdu
   condnum=cond(Kdu); % condition number = ration max/min sing. value of Kdu
   if condnum>bigcondnum,
       warning('mpc:mpc_buildmat:hessian',warnmsghessian);
       Kdu=Kdu+eye(degrees)*smallhessian;
   end
end

%if strcmp(type,'Unconstrained'),
if (ptype==2),

   KduINV=Kdu\eye(degrees);
   %Mat=struct('KduINV',KduINV,'Kx',Kx,'Kr',Kr,...
   %   'Ku1',Ku1,'Kv',Kv,'Kd',Kd,'Kut',Kut,'Jm',Jm,'DUFree',DUFree);
   
   % set all unused parameter to []
   TAB=[];MuKduINV=[];rhsa0=[];rhsc0=[];
   Mlim=[];Mx=[];Mu1=[];Mv=[];%Md=[];
   zmin=[];
   
   return
end


%%% CONSTRAINED CASE

% Build Mu, Mx, Mu1, Mv, Md matrices
I3=eye(degrees);
Mu=[Su*Jm;-Su*Jm;I2*Jm;-I2*Jm;I3;-I3];

aux=2*nu*p+2*degrees;
Mx=[-Sx;Sx;zeros(aux,nx)];
Mu1=[-Su1;Su1;-I1;I1;zeros(2*degrees,nu)];
Mv=[-Hv;Hv;zeros(aux,(p+1)*nv)];
%Md=[-Hd;Hd;zeros(aux,(p+1)*nd)];

%clear I3

% Build Mlim matrix

%umin=extend(umin,p); % Extends umin
%umax=extend(umax,p); % Extends umax
%dumin=extend(dumin,p); % Extends dumin
%dumax=extend(dumax,p); % Extends dumax
%ymin=extend(ymin,p); % Extends ymin
%ymax=extend(ymax,p); % Extends ymax
%Vumin=extend(Vumin,p); % Extends Vumin
%Vumax=extend(Vumax,p); % Extends Vumax
%Vdumin=extend(Vdumin,p); % Extends Vdumin
%Vdumax=extend(Vdumax,p); % Extends Vdumax
%Vymin=extend(Vymin,p); % Extends Vymin
%Vymax=extend(Vymax,p); % Extends Vymax



% Now take out from dumin,dumax entries relative to blocked moves, as they
% are constraint of the form dumin <=0 <=dumax

nb=size(m,2);
if nb==1,
   moves=[ones(1,m-1) p-m+1];
else
   moves=m; % sum(m)=p has already been checked in chkm.m
end
nmoves=length(moves);
degrees=nmoves*nu;
index=zeros(degrees,1); % index(i)=1 iff DU(i) free 
% length(index) = number of optimization vars

j=0;
for i=1:nmoves,
   ni=moves(i);
   index(j*nu+1:(j+ni)*nu)=[ones(nu,1);zeros((ni-1)*nu,1)];
   j=j+ni;
end

index2=find(~index); % Now index contains indices of DUs which are 0

% Transpose to put matrices in a single column below

dumin=dumin';dumin=dumin(:);
dumax=dumax';dumax=dumax(:);
Vdumin=Vdumin';Vdumin=Vdumin(:);
Vdumax=Vdumax';Vdumax=Vdumax(:);

% Check if blocked moves DU=0 are infeasible
if any(dumin(index2,:)>0),
   warning('mpc:mpc_buildmat:posblocked','Positive lower bounds on blocked input increments will be zeroed');
end
if any(dumax(index2,:)<0),
   warning('mpc:mpc_buildmat:negblocked','Negative upper bounds on blocked input increments will be zeroed');
end
dumin(index2,:)=[];
dumax(index2,:)=[];
Vdumin(index2,:)=[];
Vdumax(index2,:)=[];

% Remove constraints on U where DU=0, but take the 
% smallest UMIN (or UMAX) and the smallest VUmin (or VUmax) for the remaining constraint
% over the free input move u

% now umin=[umin_1(0), umin_2(0), ..., umin_nu(0);
%          [umin_1(1), umin_2(1), ..., umin_nu(1);
%          [...         ...             ...
%          [umin_1(p-1), umin_2(p-1), ..., umin_nu(p-1);

k=0;
for i=1:nmoves,
   blocked=[(k+1):k+moves(i)]'; % indices of frozen moves for the i-th degree of freedom,
   % including the first free move and the remaining nonfree moves
   
   umin2=max(umin(blocked,:),[],1); % most stringent lower constraint (umin2=row vector)
   umax2=min(umax(blocked,:),[],1); % most stringent upper constraint (umax2=row vector)
   
   umin(k+1,:)=umin2; % tighten the constraint on the free move
   umax(k+1,:)=umax2; % tighten the constraint on the free move
   
   Vumin2=min(Vumin(blocked,:),[],1); % most stringent violation of lower constraint (umin2=row vector)
   Vumax2=min(Vumax(blocked,:),[],1); % most stringent violation of upper constraint (umax2=row vector)
   
   Vumin(k+1,:)=Vumin2; % tighten the violation multiplier on the free move
   Vumax(k+1,:)=Vumax2; % tighten the violation multiplier on the free move
   
   k=k+moves(i); % update for next step
end


% Now take out from umin,umax entries relative to nonfree blocked moves

umin=umin';umin=umin(:); 
umax=umax';umax=umax(:); 
Vumin=Vumin';Vumin=Vumin(:); 
Vumax=Vumax';Vumax=Vumax(:); 

umin(index2,:)=[];
umax(index2,:)=[];
Vumin(index2,:)=[];
Vumax(index2,:)=[];


% Modified July 01, 2001: remove constraints also in Mu,Mx,Mu1,Mv,Md
Mu(2*p*ny+[index2;p*nu+index2],:)=[];
Mx(2*p*ny+[index2;p*nu+index2],:)=[];
Mu1(2*p*ny+[index2;p*nu+index2],:)=[];
Mv(2*p*ny+[index2;p*nu+index2],:)=[];
%Md(2*p*ny+[index;p*nu+index],:)=[];

  
ymin=ymin';
ymax=ymax';

Mlim=[ymax(:);-ymin(:);umax(:);-umin(:);dumax;-dumin];

% Takes out constraints which have Mlim(i)=Inf
isinf=find(Mlim==Inf);
Mlim(isinf,:)=[];
Mu(isinf,:)=[];
Mx(isinf,:)=[];
Mu1(isinf,:)=[];
if ~isempty(Mv),
   Mv(isinf,:)=[];
else
   Mv=zeros(length(isinf),0);
end
%if ~isempty(Md),
%   Md(isinf,:)=[];
%else
%   Md=zeros(length(isinf),0);
%end



% Define the matrices needed for the DANTZGMP routine


%zmin=dumin2(find(DUFree))';
%zmin=zmin(:);
zmin=dumin(:);


%if strcmp(type,'Soft_Constrained'),
if (ptype==0),

   % For efficiency, only add slack var if there are output constraints (any ymin/ymax is finite)
   
   zmin=[zmin;0];
   % Add slack variable for soft output constraints
   %   Me=-[ones(2*length(ymax(:)),1);zeros(2*length(umax(:))+2*length(dumax(:)),1)];
   Vymax=Vymax';
   Vymin=Vymin';
   Vumax=Vumax';
   Vumin=Vumin';
   Vdumax=Vdumax';
   Vdumin=Vdumin';
   
   Me=-[Vymax(:);Vymin(:);Vumax(:);Vumin(:);Vdumax(:);Vdumin(:)];
   Me(isinf,:)=[];
   
   
   Mu2=[Mu,Me];
   rhsc0=-Mu2*zmin;
   Kdu2=[Kdu,zeros(degrees,1);zeros(1,degrees),rhoeps];
   
   % Check positive definiteness of Kdu2
   condnum=cond(Kdu2); % condition number = ratio max/min sing. value of Kdu2
   if condnum>bigcondnum,
       warning('mpc:mpc_buildmat:hessian',warnmsghessian);
       Kdu2=Kdu2+eye(degrees+1)*smallhessian;
   end

   rhsa0=-Kdu2'*zmin;    
   % This is a constant term that adds to the initial basis
   % in each QP.
   KduINV=Kdu2\eye(degrees+1);
   %clear Kdu
   
   TAB=[-KduINV KduINV*Mu2';Mu2*KduINV -Mu2*KduINV*Mu2'];
   MuKduINV=Mu2*KduINV;
   
   %basisi=[KduINV*rhsa;
   %       rhsc-MuKduINV*rhsa];
else
   rhsc0=-Mu*zmin;
   
   rhsa0=-Kdu'*zmin;    
   % This is a constant term that adds to the initial basis
   % in each QP.
   KduINV=Kdu\eye(degrees);
   %clear Kdu
   
   TAB=[-KduINV KduINV*Mu';Mu*KduINV -Mu*KduINV*Mu'];
   MuKduINV=Mu*KduINV;
   
   %basisi=[KduINV*rhsa;
   %       rhsc-MuKduINV*rhsa];
end   

%end buildmat2

%function vec2=extend(vec,p)
% If vec has less than p rows, repeat the last one so that vec has p rows
%nrow=size(vec,1);
%if nrow<p,
%   vec2=[vec;kron(ones(p-nrow,1),vec(nrow,:))];    
%else
%   vec2=vec;
%end

