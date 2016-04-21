function [odata,it,res] = DDGOXgummelmap (imesh,Dsides,...
Simesh,Sinodes,Sielements,SiDsides,...
idata,toll,maxit,ptoll,pmaxit,verbose)

% [odata,it,res] = DDGOXgummelmap (imesh,Dsides,...
%                           Simesh,Sinodes,Sielements,SiDsides,...
%                           idata,toll,maxit,ptoll,pmaxit,verbose) 
%

% This file is part of 
%
%            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
%         -------------------------------------------------------------------
%            Copyright (C) 2004-2006  Carlo de Falco
%
%
%
%  SECS2D is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation; either version 2 of the License, or
%  (at your option) any later version.
%
%  SECS2D is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with SECS2D; If not, see <http://www.gnu.org/licenses/>.

clear DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS
global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS

%%%%%%%%%%%%%%%
%% RRE param %%
RREnnit      = [1,0];
RRErank      = 5;
RREpattern   = URREcyclingpattern(RREnnit,RRErank,maxit);
%%%%%%%%%%%%%%%

Nnodes     = max(size(imesh.p));
Nelements  = max(size(imesh.t));
SiNnodes     = max(size(Simesh.p));
SiNelements  = max(size(Simesh.t));

V (:,1) = idata.V;

p (:,1) = idata.p;

n (:,1) = idata.n;

Fn(:,1) = idata.Fn;
Fp(:,1) = idata.Fp;

D       = idata.D;

% Set list of nodes with Dirichelet BCs
Dnodes = Unodesonside(imesh,Dsides);

% Set list of nodes with Dirichelet BCs
SiDnodes = Unodesonside(Simesh,SiDsides);

nrm = 1;

for i=1:1:maxit
    if (verbose>=1)
        fprintf(1,'*****************************************************************\n');  
        fprintf(1,'****    start of gummel iteration number: %d\n',i);
        fprintf(1,'*****************************************************************\n');  
        
    end

    if (verbose>=1)
        fprintf(1,'solving non linear poisson equation\n');
        if ((i>1)&(verbose>1))
            DDGOXplotresults(imesh,Simesh,n(:,1)*idata.ns,p(:,1)*idata.ns,V(:,1)*idata.Vs,...
            Fn(:,1)*idata.Vs,Fp(:,1)*idata.Vs,i,nrm(end),'poisson');
        end
    end
    
    
    
    [V(:,2),n(:,2),p(:,2)] =...
        DDGOXnlpoisson (imesh,Dsides,Sinodes,SiDnodes,Sielements,...
                        V(:,1),n(:,1),p(:,1),Fn(:,1),Fp(:,1),D,...
                        idata.l2,idata.l2ox,ptoll,pmaxit,verbose-1);
    V(Dnodes,2) = idata.V(Dnodes);
    
    if (verbose>=1)
        fprintf (1,'***\nupdating electron qfl\n');
        if ((i>1)&(verbose>1))
            DDGOXplotresults(imesh,Simesh,n(:,2)*idata.ns,p(:,2)*idata.ns,...
            V(:,2)*idata.Vs,Fn(:,1)*idata.Vs,Fp(:,1)*idata.Vs,i,nrm(end),'e- continuity');
        end
    end

    mob = Ufielddepmob(Simesh,idata.un,Fn(:,1),idata.vsatn,idata.mubn);
        
    n(:,3) =DDGOXelectron_driftdiffusion(Simesh,SiDsides,n(:,2),p(:,2),...
    V(Sinodes,2),mob,...
    idata.tn,idata.tp,idata.ni,idata.ni);		
    Fn(:,2)=V(Sinodes,2) - log(n(:,3));
    n(SiDnodes,3) = idata.n(SiDnodes);
    Fn(SiDnodes,2) = idata.Fn(SiDnodes);
    
    %%%% store result for RRE
        if RREpattern(i)>0
            Fnstore(:,RREpattern(i)) = Fn(:,2);
            if RREpattern(i+1)==0 % Apply RRE extrapolation
	      if (verbose>=1)		
		fprintf(1,'\n**********\nRRE EXTRAPOLATION STEP\n**********\n');
              end
                Fn(:,2) = Urrextrapolation(Fnstore);
            end
        end
    
    if (verbose>=1)
        fprintf(1,'***\nupdating hole qfl\n');
        if ((i>1)&(verbose>1))		
            DDGOXplotresults(imesh,Simesh,n(:,3)*idata.ns,p(:,2)*idata.ns,V(:,2)*idata.Vs,...
            Fn(:,2)*idata.Vs,Fp(:,1)*idata.Vs,i,nrm(end),'h+ continuity');
        end
    end
    
	mob = Ufielddepmob(Simesh,idata.up,Fp(:,1),idata.vsatp,idata.mubp);
	p(:,3) =DDGOXhole_driftdiffusion(Simesh,SiDsides,n(:,3),p(:,2),...
	V(Sinodes,2),mob,...
	idata.tn,idata.tp,idata.ni,idata.ni);
	Fp(:,2)= V(Sinodes,2) + log(p(:,3));
	p(SiDnodes,3) = idata.p(SiDnodes);
	Fp(SiDnodes,2) = idata.Fp(SiDnodes);

    if (verbose>=1)
        fprintf(1,'checking for convergence\n');
    end

    nrfn= norm(Fn(:,2)-Fn(:,1),inf);
    nrfp= norm (Fp(:,2)-Fp(:,1),inf);
    nrv = norm (V(:,2)-V(:,1),inf);
    nrm(i) = max([nrfn;nrfp;nrv]);
    
    if (verbose>1)
    figure(2);
    semilogy(nrm)
    pause(.1)
    end
    
    if (verbose>=1)
        fprintf (1,' max(|phin_(k+1)-phinn_(k)| ,...\n |phip_(k+1)-phip_(k)| ,...\n |v_(k+1)- v_(k)| )= %g\n',nrm(i));
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
    fprintf(1,'\n***********\nDD simulation over:\n # of Gummel iterations = %d\n\n',it);
end

odata = idata;

odata.n  = n(:,end);
odata.p  = p(:,end);
odata.V  = V(:,end);
odata.Fn = Fn(:,end);
odata.Fp = Fp(:,end);
