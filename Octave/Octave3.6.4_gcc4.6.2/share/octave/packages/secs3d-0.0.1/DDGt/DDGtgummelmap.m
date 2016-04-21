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
%  [odata,it,res] =...
%  DDGtgummelmap (imesh,Dsides,idata,toll,maxit,ptoll,pmaxit,verbose)
%

function [odata,it,res] =...
    DDGtgummelmap (imesh,Dsides,idata,toll,maxit,ptoll,pmaxit,verbose)

clear global
global DDGNLPOISSON_LAP DDGNLPOISSON_MASS DDG_RHS DDG_MASS

V (:,1) = idata.V;
p (:,1) = idata.p;
n (:,1) = idata.n;
Fn(:,1) = idata.Fn;
Fp(:,1) = idata.Fp;
D       = idata.D;

Nnodes     = max(size(imesh.p));
Nelements  = max(size(imesh.t));

for i=1:1:maxit
  if (verbose>1)
    fprintf(1,'*****************************************************************\n');  
    fprintf(1,'****    start of gummel iteration number: %d\n',i);
    fprintf(1,'*****************************************************************\n');  
    
  end

  if (verbose>1)
    fprintf(1,'solving non linear poisson equation\n\n');
  end
  [V(:,2),n(:,2),p(:,2)] =...
      DDGnlpoisson (imesh,Dsides,V(:,1),n(:,1),p(:,1),Fn(:,1),Fp(:,1),D,...
                    idata.l2,ptoll,pmaxit,verbose-1);
  
  
  if (verbose>1)
    fprintf (1,'\n\nupdating electron qfl\n\n');
  end
  n(:,3) =DDGtelectron_driftdiffusion(imesh,Dsides,idata.n,idata.p,V(:,2),...
                                      idata.un*ones(Nelements,1),...
                                      idata.tn,idata.tp,idata.ni,idata.ni,idata.n,idata.dt);
  Fn(:,2)=V(:,2) - log(n(:,3));
  
  if (verbose>1)
    fprintf(1,'updating hole qfl\n\n');
  end
  p(:,3) =DDGthole_driftdiffusion(imesh,Dsides,idata.n,idata.p,V(:,2),...
                                  idata.up*ones(Nelements,1),...
                                  idata.tn,idata.tp,idata.ni,idata.ni,idata.p,idata.dt);
  
  Fp(:,2)=V(:,2) + log(p(:,3));
  
  if (verbose>1)
    fprintf(1,'checking for convergence\n\n');
  end

  nrfn= norm(Fn(:,2)-Fn(:,1),inf);
  nrfp= norm (Fp(:,2)-Fp(:,1),inf);
  nrv = norm (V(:,2)-V(:,1),inf);
  nrm(i) = max([nrfn;nrfp;nrv]);
  
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

clear global

% Last Revision:
% $Author: carlo $
% $Date: 2005/05/27 15:29:23 $


