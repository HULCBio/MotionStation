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

% [odata,it,res] = DDGOXgummelmap (imesh,Dsides,...
%                           Simesh,Sinodes,Sielements,SiDsides,...
%                           idata,toll,maxit,ptoll,pmaxit,verbose) 
%

function [odata,it,res] = DDGOXgummelmap (imesh,Dsides,...
                                          Simesh,Sinodes,Sielements,SiDsides,...
                                          idata,toll,maxit,ptoll,pmaxit,verbose)


clear global
global LOGFILENAME DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS

Nnodes       = max(size(imesh.p));
Nelements    = max(size(imesh.t));
SiNnodes     = max(size(Simesh.p));
SiNelements  = max(size(Simesh.t));

V (:,1) = idata.V;

p (:,1) = idata.p;
n (:,1) = idata.n;

Fn(:,1) = idata.Fn;
Fp(:,1) = idata.Fp;

D       = idata.D;

Dnodes   = Ugetnodesonface(imesh,Dsides);
SiDnodes = Ugetnodesonface(Simesh,SiDsides);

nrm = 1;

for i=1:1:maxit
  if (verbose>1)
    fprintf(1,'*****************************************************************\n');  
    fprintf(1,'****    start of gummel iteration number: %d\n',i);
    fprintf(1,'*****************************************************************\n');  
    
  end

  if (verbose>1)
    fprintf(1,'solving non linear poisson equation\n\n');
  end
  
  
  [V(:,2),n(:,2),p(:,2)] =DDGOXnlpoisson (imesh,Dsides,Sinodes,SiDnodes,Sielements,...
                                          V(:,1),n(:,1),p(:,1),Fn(:,1),Fp(:,1),D,...
                                          idata.l2,idata.l2ox,ptoll,pmaxit,verbose-1);
  V(Dnodes,2) = idata.V(Dnodes);
  
  if (verbose>1)
    fprintf (1,'\n\nupdating electron qfl\n\n');
  end

  mob = Ufielddepmob(Simesh,idata.un,Fn(:,1),idata.vsatn,idata.mubn);
  
  n(:,3) =DDGelectron_driftdiffusion(Simesh,SiDsides,n(:,2),p(:,2),...
                                     V(Sinodes,2),mob,...
                                     idata.tn,idata.tp,idata.ni,idata.ni);

  Fn(:,2)=V(Sinodes,2) - log(n(:,3));
  n(SiDnodes,3) = idata.n(SiDnodes);
  Fn(SiDnodes,2) = idata.Fn(SiDnodes);

  if (verbose>1)
    fprintf(1,'updating hole qfl\n\n');
  end

  mob = Ufielddepmob(Simesh,idata.up,Fp(:,1),idata.vsatp,idata.mubp);

  p(:,3) =DDGhole_driftdiffusion(Simesh,SiDsides,n(:,3),p(:,2),...
                                 V(Sinodes,2),mob,...
                                 idata.tn,idata.tp,idata.ni,idata.ni);


  Fp(:,2)= V(Sinodes,2) + log(p(:,3));
  p(SiDnodes,3) = idata.p(SiDnodes);
  Fp(SiDnodes,2) = idata.Fp(SiDnodes);

  if (verbose>1)
    fprintf(1,'checking for convergence\n\n');
  end

  nrfn= norm(Fn(:,2)-Fn(:,1),inf);
  nrfp= norm (Fp(:,2)-Fp(:,1),inf);
  nrv = norm (V(:,2)-V(:,1),inf);
  nrm(i) = max([nrfn;nrfp;nrv]);

  figure(2)
  semilogy(nrm)
  pause(.1)

  
  if (verbose>1)
    fprintf (1,' max(|phin_(k+1)-phinn_(k)| , |phip_(k+1)-phip_(k)| , |v_(k+1)- v_(k)| )= %d\n',nrm(i));
  end
  if (nrm(i)<toll)
    break
  end

  V(:,1) = V(:,end);
  n(:,1) = n(:,end);
  p(:,1) = p(:,end);
  Fn(:,1)= Fn(:,end);
  Fp(:,1)= Fp(:,end);
  
  
end

it = i;
res = nrm;

if (verbose>0)
  fprintf(1,'\n\nDD: # of Gummel iterations = %d\n\n',it);
end

odata = idata;

odata.n  = n(:,end);
odata.p  = p(:,end);
odata.V  = V(:,end);
odata.Fn = Fn(:,end);
odata.Fp = Fp(:,end);

