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


%  w = QDDGOXcompdens(mesh,Dsides,win,vin,fermiin,d2,toll,maxit,verbose);
%
%   This is an internal function which is only expected to be called by QDDGOgummelmap.
%

function w = QDDGOXcompdens(mesh,Dsides,win,vin,fermiin,d2,toll,maxit,verbose);

global QDDGOXCOMPDENS_LAP QDDGOXCOMPDENS_MASS QDDGOXCOMPDENS_RHS LOGFILENAME
%% Set some usefull constants
VErank = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% convert input vectors to columns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if columns(win)>rows(win)
  win=win';
end
if columns(vin)>rows(vin)
  vin=vin';
end 
if columns(fermiin)>rows(fermiin)
  fermiin=fermiin';
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% convert grid info to FEM form
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nodes 		    = mesh.p;
Nnodes		    = size(nodes,2);

elements	    = mesh.t(1:3,:);
Nelements           = size(elements,2);

Dedges    =[];

for ii = 1:length(Dsides)
  Dedges=[Dedges,find(mesh.e(5,:)==Dsides(ii))];
end

% Set list of nodes with Dirichelet BCs
Dnodes = mesh.e(1:2,Dedges);
Dnodes = [Dnodes(1,:) Dnodes(2,:)];
Dnodes = unique(Dnodes);

Dvals  = win(Dnodes);

Varnodes = setdiff([1:Nnodes],Dnodes);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 		initialization:
%% 		we're going to solve
%% 		$$ -\delta^2 \Lap w_{k+1} + B'(w_k) \delta w_{k+1} =  2 * w_k$$
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set $$ w_1 = win $$ 
w = win;
wnew = win;

%% let's compute  FEM approximation of $$ L = - \aleph \frac{d^2}{x^2} $$
if (isempty(QDDGOXCOMPDENS_LAP))
  QDDGOXCOMPDENS_LAP = Ucomplap (mesh,ones(Nelements,1));
end
L = d2*QDDGOXCOMPDENS_LAP;

%% now compute $$ G_k = F - V  + 2 V_{th} log(w) $$
if (isempty(QDDGOXCOMPDENS_MASS))
  QDDGOXCOMPDENS_MASS =  Ucompmass (mesh,ones(Nnodes,1));
end
G	    = fermiin - vin  + 2*log(w);
Bmat	= QDDGOXCOMPDENS_MASS*spdiags(G,0,Nnodes,Nnodes);
nrm     = 1;
%%%%%%%%%%%%%%%%%%%%%%%%
%%% NEWTON ITERATION START
%%%%%%%%%%%%%%%%%%%%%%%%
converged = 0;
for jnewt =1:ceil(maxit/VErank)
  for k=1:VErank
    [w(:,k+1),converged,G,L,Bmat]=onenewtit(w(:,k),G,fermiin,vin,L,Bmat,jnewt,mesh,Dnodes,Varnodes,Dvals,Nnodes,Nelements,toll);        
    if converged
      break
    end
  end
  if converged
    break
  end
  w  = Urrextrapolation(w);
end	
%%%%%%%%%%%%%%%%%%%%%%%%
%%% NEWTON ITERATION END
%%%%%%%%%%%%%%%%%%%%%%%%
w = w(:,end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% ONE NEWTON ITERATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [w,converged,G,L,Bmat]=onenewtit(w,G,fermiin,vin,L,Bmat,jnewt,mesh,Dnodes,Varnodes,Dvals,Nnodes,Nelements,toll);

global QDDGOXCOMPDENS_LAP QDDGOXCOMPDENS_MASS QDDGOXCOMPDENS_RHS LOGFILENAME
dampit 		= 5;
dampcoeff	        = 2;
converged             = 0;
wnew                  =  w;

res0      = norm((L + Bmat) * w,inf);


%% chose $ t_k $ to ensure positivity of  $w$
mm  = -min(G);
pause(1)

if (mm>2)
  tk = max( 1/(mm));
else
  tk = 1;
end


tmpmat = QDDGOXCOMPDENS_MASS*2;
if (isempty(QDDGOXCOMPDENS_RHS))
  QDDGOXCOMPDENS_RHS = Ucompconst (mesh,ones(Nnodes,1),ones(Nelements,1));
end
tmpvect= 2*QDDGOXCOMPDENS_RHS.*w;

%%%%%%%%%%%%%%%%%%%%%%%%
%%% DAMPING ITERATION START
%%%%%%%%%%%%%%%%%%%%%%%%
for idamp = 1:dampit
  %% Compute $ B1mat = \frac{2}{t_k} $
  %% and the (lumped) mass matrix B1mat(w_k)
  B1mat	= tmpmat/tk;
  
  %% now we're ready to build LHS matrix and RHS of the linear system for 1st Newton step
  A 		= L + B1mat + Bmat;
  b 		= tmpvect/tk;
  
  %% Apply boundary conditions
  A (Dnodes,:) = 0;
  b (Dnodes)   = 0;
  b = b - A (:,Dnodes) * Dvals;
  
  A(Dnodes,:)= [];
  A(:,Dnodes)= [];
  
  b(Dnodes)	= [];
  

  wnew(Varnodes) =  A\b;	
  
  
  %% compute $$ G_{k+1} = F - V  + 2 V_{th} log(w) $$
  G	    = fermiin - vin  + 2*log(wnew);
  Bmat	= QDDGOXCOMPDENS_MASS*spdiags(G,0,Nnodes,Nnodes);
  
  res    = norm((L + Bmat) * wnew,inf);
  
  if (res<res0)
    break
  else
    tk = tk/dampcoeff;
  end
end	
%%%%%%%%%%%%%%%%%%%%%%%%
%%% DAMPING ITERATION END
%%%%%%%%%%%%%%%%%%%%%%%%
nrm = norm(wnew-w);


if (nrm < toll)
  w= wnew;
  converged = 1;
else
  w=wnew;
end

