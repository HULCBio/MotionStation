%% Copyright (C) 2004,2007,2008,2009,2010,2011  Carlo de Falco
%%
%% This file is part of:
%%     secs3d - A 3-D Drift--Diffusion Semiconductor Device Simulator 
%%
%%  secs3d is free software; you can redistribute it and/or modify
%%  it under the terms of the GNU General Public License as published by
%%  the Free Software Foundation; either version 2 of the License, or
%%  (at your option) any later version.
%%
%%  secs3d is distributed in the hope that it will be useful,
%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%  GNU General Public License for more details.
%%
%%  You should have received a copy of the GNU General Public License
%%  along with secs3d; If not, see <http://www.gnu.org/licenses/>.
%%
%%  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>

%  
%   [V,n,p,res,niter] = QDDGOXnlpoisson (mesh,Dsides,Sinodes,SiDnodes,...
%     Sielements,Vin,nin,pin,...
%     Fnin,Fpin,Gin,Gpin,D,l2,l2ox,...
%     toll,maxit,verbose)
%
%  solves $$ -\lambda^2 V'' + (n(V,Fn) - p(V,Fp) -D)$$
%

function [V,n,p,res,niter] = QDDGOXnlpoisson (mesh,Dsides,Sinodes,SiDnodes,...
                                              Sielements,Vin,nin,pin,...
                                              Fnin,Fpin,Gin,Gpin,D,l2,l2ox,...
                                              toll,maxit,verbose)


global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS LOGFILENAME

%% Set some useful constants
dampit 		= 3;
dampcoeff	= 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% convert input vectors to columns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if columns(D)>rows(D)
  D=D';
end


if columns(nin)>rows(nin)
  nin=nin';
end

if columns(pin)>rows(pin)
  pin=pin';
end

if columns(Vin)>rows(Vin)
  Vin=Vin';
end 

if columns(Fnin)>rows(Fnin)
  Fnin=Fnin';
end 

if columns(Fpin)>rows(Fpin)
  Fpin=Fpin';
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% setup FEM data structures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nodes=mesh.p;
elements=mesh.t;
Nnodes = length(nodes);
Nelements = length(elements);

Dedges    =[];

for ii = 1:length(Dsides)
  Dedges=[Dedges,find(mesh.e(5,:)==Dsides(ii))];
end

% Set list of nodes with Dirichelet BCs
Dnodes = mesh.e(1:2,Dedges);
Dnodes = [Dnodes(1,:) Dnodes(2,:)];
Dnodes = unique(Dnodes);

% Set values of Dirichelet BCs
Bc     = zeros(length(Dnodes),1);
% Set list of nodes without Dirichelet BCs
Varnodes = setdiff([1:Nnodes],Dnodes);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 		initialization:
%% 		we're going to solve
%% 		$$ - \lambda^2 (\delta V)'' +  (\frac{\partial n}{\partial V} - \frac{\partial p}{\partial V})= -R $$
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set $$ n_1 = nin $$ and $$ V = Vin $$
V = Vin;
Fn = Fnin;
Fp = Fpin;
G  = Gin;
Gp = Gpin;
n = exp(V(Sinodes)+G-Fn);
p = exp(-V(Sinodes)-Gp+Fp);
n(SiDnodes) = nin(SiDnodes);
p(SiDnodes) = pin(SiDnodes);


%%%
%%% Compute LHS matrices
%%%

%% let's compute  FEM approximation of $$ L = -  \frac{d^2}{x^2} $$
if (isempty(DDGOXNLPOISSON_LAP))
  coeff = l2ox * ones(Nelements,1);
  coeff(Sielements)=l2;
  DDGOXNLPOISSON_LAP = Ucomplap (mesh,coeff);
end

%% compute $$ Mv = ( n + p)  $$
%% and the (lumped) mass matrix M
if (isempty(DDGOXNLPOISSON_MASS))
  Cvect = zeros(Nelements,1);
  Cvect(Sielements)=1;
  DDGOXNLPOISSON_MASS = Ucompmass2 (mesh,ones(Nnodes,1),Cvect);
end
freecarr=zeros(Nnodes,1);
freecarr(Sinodes)=(n + p);
Mv      =  freecarr;
MV(SiDnodes) = 0;
M       =  DDGOXNLPOISSON_MASS*spdiags(Mv,0,Nnodes,Nnodes);

%%%
%%% Compute RHS vector (-residual)
%%%

%% now compute $$ T0 = \frac{q}{\epsilon} (n - p - D) $$
if (isempty(DDGOXNLPOISSON_RHS))
  DDGOXNLPOISSON_RHS = Ucompconst (mesh,ones(Nnodes,1),ones(Nelements,1));
end
totcharge = zeros(Nnodes,1);
totcharge(Sinodes)=(n - p - D);
Tv0   = totcharge;
T0    = Tv0 .* DDGOXNLPOISSON_RHS;

%% now we're ready to build LHS matrix and RHS of the linear system for 1st Newton step
A 		= DDGOXNLPOISSON_LAP + M;
R 		= DDGOXNLPOISSON_LAP * V  + T0; 

%% Apply boundary conditions
A (Dnodes,:) = [];
A (:,Dnodes) = [];
R(Dnodes)  = [];

%% we need $$ \norm{R_1} $$ and $$ \norm{R_k} $$ for the convergence test   
normr(1)	=  norm(R,inf);
relresnorm 	= 1;
reldVnorm       = 1;
normrnew	= normr(1);
dV              = V*0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% START OF THE NEWTON CYCLE
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for newtit=1:maxit
  if (verbose>0)
    fprintf(1,'\n***\nNewton iteration: %d, reldVnorm = %e\n***\n',newtit,reldVnorm);
    
  end
  
  dV(Varnodes) =(A)\(-R);
  dV(Dnodes)=0;
  
  
  %%%%%%%%%%%%%%%%%%
  %% Start of th damping procedure
  %%%%%%%%%%%%%%%%%%
  tk = 1;
  for dit = 1:dampit
    if (verbose>0)
      fprintf(1,'\ndamping iteration: %d, residual norm = %e\n',dit,normrnew);
    end
    Vnew   = V + tk * dV;
    
    n = exp(Vnew(Sinodes)+G-Fn);
    p = exp(-Vnew(Sinodes)-Gp+Fp);
    n(SiDnodes) = nin(SiDnodes);
    p(SiDnodes) = pin(SiDnodes);
    
    
    %%%
    %%% Compute LHS matrices
    %%%
    
    %% let's compute  FEM approximation of $$ L = -  \frac{d^2}{x^2} $$
    %L      = Ucomplap (mesh,ones(Nelements,1));
    
    %% compute $$ Mv =  ( n + p)  $$
    %% and the (lumped) mass matrix M
    freecarr=zeros(Nnodes,1);
    freecarr(Sinodes)=(n + p);  
    Mv   =  freecarr;
    M       =  DDGOXNLPOISSON_MASS*spdiags(Mv,0,Nnodes,Nnodes);%M     = Ucompmass (mesh,Mv);
    
    %%%
    %%% Compute RHS vector (-residual)
    %%%
    
    %% now compute $$ T0 = \frac{q}{\epsilon} (n - p - D) $$
    totcharge( Sinodes)=(n - p - D);
    Tv0   = totcharge;
    T0    = Tv0 .* DDGOXNLPOISSON_RHS;%T0    = Ucompconst (mesh,Tv0,ones(Nelements,1));
    
    %% now we're ready to build LHS matrix and RHS of the linear system for 1st Newton step
    A 		= DDGOXNLPOISSON_LAP + M;
    R 		= DDGOXNLPOISSON_LAP * Vnew  + T0; 
    
    %% Apply boundary conditions
    A (Dnodes,:) = [];
    A (:,Dnodes) = [];
    R(Dnodes)  = [];
    
    %% compute $$ | R_{k+1} | $$ for the convergence test
    normrnew= norm(R,inf);
    
    % check if more damping is needed
    if (normrnew > normr(newtit))
      tk = tk/dampcoeff;
    else
      if (verbose>0)
        fprintf(1,'\nexiting damping cycle because residual norm = %e \n-----------\n',normrnew);
      end		
      break
    end	
  end
  
  V		            = Vnew;	
  normr(newtit+1) 	= normrnew;
  dVnorm              = norm(tk*dV,inf);
  pause(.1);
  % check if convergence has been reached
  reldVnorm           = dVnorm / norm(V,inf);
  if (reldVnorm <= toll)
    if(verbose>0)
      fprintf(1,'\nexiting newton cycle because reldVnorm= %e \n',reldVnorm);
    end
    break
  end
  
end

res = normr;
niter = newtit;
