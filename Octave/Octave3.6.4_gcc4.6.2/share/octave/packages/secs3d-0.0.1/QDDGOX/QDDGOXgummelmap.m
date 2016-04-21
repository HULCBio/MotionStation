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

% [odata,it,res] = QDDGOXgummelmap (imesh,Dsides,...
%     Simesh,Sinodes,Sielements,SiDsides,Intsides,...
%     idata,toll,maxit,ptoll,pmaxit,stoll,smaxit,verbose,options);


function [odata,it,res] = QDDGOXgummelmap (imesh,Dsides,...
                                           Simesh,Sinodes,Sielements,SiDsides,Intsides,...
                                           idata,toll,maxit,ptoll,pmaxit,stoll,smaxit,verbose,options)


clear global
global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS LOGFILENAME

Nnodes      = max(size(imesh.p));
Nelements   = max(size(imesh.t));
SiNnodes    = max(size(Simesh.p));
SiNelements = max(size(Simesh.t));

if (options.SRH==1)
  tn= idata.tn;tp=idata.tp;
else
  tn=Inf;tp=Inf;
end

V (:,1) = idata.V;
p (:,1) = idata.p;
n (:,1) = idata.n;
Fn(:,1) = idata.Fn;
Fp(:,1) = idata.Fp;

D       = idata.D;


Dnodes   = Ugetnodesonface(imesh,Dsides)';
Intnodes = Ugetnodesonface(Simesh,Intsides)';
SiDnodes = Ugetnodesonface(Simesh,SiDsides)';

if (options.FD==1)
  FDn  = idata.FDn;
  FDp  = idata.FDp;
else
  FDn  = zeros(SiNnodes,1);
  FDp  = zeros(SiNnodes,1);
end

G (:,1) =  Fn(:,1) - V(Sinodes,1) - FDn + log(n(:,1));
if (options.holes==1)
  Gp (:,1) = Fp(:,1) - V(Sinodes,1) - FDp - log(p(:,1));
else
  Gp (:,1) = G(:,1)*0;
end



nrm=1;
for i=1:1:maxit
  if (verbose>=1)
    fprintf(1,'*****************************************************************\n');
    fprintf(1,'****    start of gummel iteration number: %d\n',i);
    fprintf(1,'*****************************************************************\n');
  end

  V(:,2)= V(:,1);
  G(:,2)= G(:,1);
  Gp(:,2)= Gp(:,1);
  n(:,2)= n(:,1);
  bohmdeltav=1;
  for j=1:smaxit
    if (verbose>=1)
      fprintf(1,'*---------------------------------------------------------------*\n');
      fprintf(1,'****    start of Poisson-Bohm iteration number: %d (bohmdeltav=%g)\n',j,bohmdeltav);
      fprintf(1,'*---------------------------------------------------------------*\n');
    end



    if (verbose>1)
      fprintf(1,'solving non linear poisson equation\n\n');
    end


    [V(:,3),n(:,2),p(:,2)] =...
        QDDGOXnlpoisson (imesh,Dsides,Sinodes,[SiDnodes,Intnodes] ,Sielements,...
                         V(:,2),n(:,1),p(:,1),Fn(:,1),Fp(:,1),G(:,2)+FDn,Gp(:,2)+FDp,D,...
                         idata.l2,idata.l2ox,ptoll,pmaxit,verbose-1);

    n([SiDnodes,Intnodes],2) = idata.n([SiDnodes,Intnodes]);
    p([SiDnodes,Intnodes],2) = idata.p([SiDnodes,Intnodes]);
    V(Dnodes,3) = idata.V(Dnodes);

    if (verbose>1)
      fprintf(1,'solving non linear Bohm equation for electrons\n\n');
    end
    n(Intnodes,2) = idata.n(Intnodes);

    w       = QDDGOXcompdens(Simesh,[SiDsides,Intsides],sqrt(n(:,2)),V(Sinodes,3) + FDn,Fn(:,1),idata.dn2,stoll,smaxit,verbose-1);
    n(:,2)  = w.^2;
    n([SiDnodes,Intnodes],2) = idata.n([SiDnodes,Intnodes]);
    G(:,3)  = Fn(:,1) - V(Sinodes,3) - FDn + log(n(:,2));
    if (verbose>1)
      fprintf(1,'solving non linear Bohm equation for holes\n\n');
    end

    if (options.holes==1)

      p(Intnodes,2) = idata.p(Intnodes);
      wp      = QDDGOXcompdens(Simesh,[SiDsides,Intsides],sqrt(p(:,2)),-V(Sinodes,3) - FDp,...
                               -Fp(:,1),idata.dp2,ptoll,pmaxit,verbose-1);
      p(:,2)  = wp.^2;
      p([SiDnodes,Intnodes],2) = idata.p([SiDnodes,Intnodes]);
      Gp(:,3) = Fp(:,1) - V(Sinodes,3) - FDp - log(p(:,2));

    else
      Gp(:,3)=G(:,3)*0;
    end


    if (options.FD==1)
      fprintf(1,'\n*** APPLYING FD STATISTICS ***\n')
      n(:,2) = idata.Nc*Ufermidirac(V(Sinodes,3)+G(:,3)-Fn(:,1)-log(idata.Nc),1/2);
      n(SiDnodes,2) = idata.n(SiDnodes);
      nMBtmp = exp(V(Sinodes,3)+G(:,3)-Fn(:,1));
      FDn    = log(n(:,2)./ nMBtmp);
      FDn(SiDnodes) = idata.FDn(SiDnodes);

      p(:,2) = idata.Nv*Ufermidirac(-V(Sinodes,3)-Gp(:,3)+Fp(:,1)-log(idata.Nv),1/2);
      p([SiDnodes,Intnodes],2) = idata.p([SiDnodes,Intnodes]);
      pMBtmp = exp(-V(Sinodes,3)-Gp(:,3)+Fp(:,1));
      FDp    = -log(p(:,2)./ pMBtmp);
      FDp(SiDnodes) = idata.FDp(SiDnodes);
    end

    bohmdeltav = norm(G(:,3)-G(:,2),inf) +...
        norm(Gp(:,3)-Gp(:,2),inf) +...
        norm(V(:,3)-V(:,2),inf);
    Gp(:,2)=Gp(:,3);

    G(:,2)=G(:,3);
    V(:,2)=V(:,3);


    if (bohmdeltav<=stoll)
      if (verbose>1)
        fprintf(1,'Exiting poisson-bohm iteration because bohmdeltav=%g\n\n',bohmdeltav);
      end
      break;
    end
  end

  if (verbose>1)
    fprintf (1,'\n\nupdating electron qfl\n\n');
  end

  mob = idata.un*ones(Nelements,1);
  
  n(:,3) =QDDGOXelectron_driftdiffusion(Simesh,SiDsides,Intsides,n(:,2),p(:,2),...
                                        V(Sinodes,3)+G(:,3)+FDn,mob,...
                                        tn,tp,idata.n0,idata.p0);


  Fn(:,2)                  = V(Sinodes,3) + G(:,3) + FDn - log(n(:,3));
  Fn(SiDnodes,2)           = idata.Fn(SiDnodes);
  n([SiDnodes,Intnodes],3) = idata.n([SiDnodes,Intnodes]);

  if (verbose>1)
    fprintf(1,'updating hole qfl\n\n');
  end

  if (options.holes==1)
    mob = idata.up*ones(Nelements,1);
    p(:,3) =DDGhole_driftdiffusion(Simesh,SiDsides,n(:,3),p(:,2),...
                                   V(Sinodes,3)+Gp(:,3)+FDp,mob,...
                                   tn,tp,idata.n0,idata.p0);
    Fp(:,2)=V(Sinodes,3) + Gp(:,3) + FDp + log(p(:,3));
    p([SiDnodes,Intnodes],3) = idata.p([SiDnodes,Intnodes]);
  else
    Fp(:,2)=Fn(:,2) + 2 * log(idata.ni);
    p(:,3) = exp(Fp(:,2)-V(Sinodes,3)-FDp);
    p([SiDnodes],3) = idata.p([SiDnodes]);
  end
  Fp(SiDnodes,2) = idata.Fp(SiDnodes);

  if (verbose>1)
    fprintf(1,'checking for convergence\n\n');
  end

  nrfn= norm(Fn(:,2)-Fn(:,1),inf);
  nrfp= norm (Fp(:,2)-Fp(:,1),inf);
  nrv = norm (V(:,3)-V(:,1),inf);
  nrg = norm (G(:,3)-G(:,1),inf);
  nrgp = norm (Gp(:,3)-Gp(:,1),inf);
  nrm(i) = max([nrfn;nrfp;nrv;nrg;nrgp]);

  figure(2)
  semilogy(nrm)
  pause(.1)


  
  if (verbose>1)
    fprintf (1,' max(|phin_(k+1)-phinn_(k)| , |phip_(k+1)-phip_(k)| , |v_(k+1)-v_(k)|  |g_(k+1)-g_(k)|)= %d\n',nrm(i));
  end
  if (nrm(i)<toll)
    break
  end

  V(:,1) = V(:,end);
  G(:,1) = G(:,end);
  Gp(:,1) = Gp(:,end);
  n(:,1) = n(:,end);
  p(:,1) = p(:,end);
  Fn(:,1)= Fn(:,end);
  Fp(:,1)= Fp(:,end);


end

it = i;
res = nrm

if (verbose>0)
  fprintf(1,'\n\nDD: # of Gummel iterations = %d\n\n',it);
end

odata = idata;

odata.n  = n(:,end);
odata.p  = p(:,end);
odata.V  = V(:,end);
odata.Fn = Fn(:,end);
odata.Fp = Fp(:,end);
odata.G  = G(:,end);
odata.Gp  = Gp(:,end);
