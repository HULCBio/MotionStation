function [odata,nrm]=ThDDGOXeletiteration(imesh,Dsides,...
					  Simesh,Sinodes,Sielements,SiDsides,...
					  idata,toll,maxit,ptoll,pmaxit,verbose)
  
  ## function [odata,nrm]=ThDDGOXeletiteration(imesh,Dsides,...
  ## 					       Simesh,Sinodes,Sielements,SiDsides,areaSi,SiPatch,...
  ## 					       idata,toll,maxit,ptoll,pmaxit,verbose)
  
  
  global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS
  
  %%%%%%%%%%%%%%%
  %% RRE param %%
  RREnnit      = [1,2];
  RRErank      = 7;  
  RREpattern   = URREcyclingpattern(RREnnit,RRErank,maxit);
  %%%%%%%%%%%%%%%

  odata   = idata;
  V(:,1)  = idata.V;
  Fn(:,1) = idata.Fn;
  Fp(:,1) = idata.Fp;
  n(:,1)  = idata.n;
  p(:,1)  = idata.p;
  Tl      = idata.Tl;
  Tn      = idata.Tn;
  Tp      = idata.Tp;
  
  %% Set list of nodes with Dirichlet BCs
  Dnodes   = Unodesonside(imesh,Dsides);
  SiDnodes = Unodesonside(Simesh,SiDsides);

  SiNelements  = columns(Simesh.t);
  D            = idata.D;
  
  nrm          = 1;

  for ielet=1:maxit

    if (verbose>=1)
      fprintf(1,"*** start of inner iteration number: %d\n",ielet);
    end
    
    if (verbose>=1)
      fprintf(1,"\t*** solving non linear poisson equation\n");
    end
    
    

    Fnshift =  log(idata.ni) .* (1-Tn);
    Fpshift = -log(idata.ni) .* (1-Tp);
    
    [V(:,2),n(:,2),p(:,2)] = ThDDGOXnlpoisson (imesh,Dsides,Sinodes,SiDnodes,Sielements,...
					       V(:,1),Tn,Tp,...
					       n(:,1),p(:,1),Fn(:,1)+Fnshift,Fp(:,1)+Fpshift,D,...
					       idata.l2,idata.l2ox,ptoll,pmaxit,verbose-1);
    
    V(Dnodes,2) = idata.V(Dnodes);
    
    if (verbose>=1)
      fprintf (1,"\t***\tupdating electron qfl\n");
    end
    
    odata.V = V(:,2);
    odata.n = n(:,2);
    odata.p = p(:,2);
    mobn0 = idata.mobn0(imesh,Simesh,Sinodes,Sielements,odata);
    mobp0 = idata.mobp0(imesh,Simesh,Sinodes,Sielements,odata);
    mobn1 = idata.mobn1(imesh,Simesh,Sinodes,Sielements,odata);
    mobp1 = idata.mobp1(imesh,Simesh,Sinodes,Sielements,odata);

    n(:,3) = ThDDGOXelectron_driftdiffusion(Simesh,SiDnodes,n(:,2),p(:,2),...
					    V(Sinodes,2),Tn,mobn0,mobn1,...
					    idata.tn,idata.tp,idata.ni,idata.ni);
    
    Fn(:,2)=V(Sinodes,2) - Tn .* log(n(:,3)) - Fnshift;
    n(SiDnodes,3) = idata.n(SiDnodes);
    Fn(SiDnodes,2) = idata.Fn(SiDnodes);
    
    if (verbose>=1)
      fprintf(1,"\t***\tupdating hole qfl\n");
    end
    
    p(:,3) = ThDDGOXhole_driftdiffusion(Simesh,SiDnodes,n(:,3),p(:,2),...
					V(Sinodes,2),Tp,mobp0,mobp1,...
					idata.tn,idata.tp,idata.ni,idata.ni);
    
    Fp(:,2)= V(Sinodes,2) + Tp .* log(p(:,3)) - Fpshift;
    p(SiDnodes,3)  = idata.p(SiDnodes);
    Fp(SiDnodes,2) = idata.Fp(SiDnodes);
    
    ## store result for RRE
    if RREpattern(ielet)>0
      Fermistore(:,RREpattern(ielet)) = [Fn(:,2);Fp(:,2)];
      if RREpattern(ielet+1)==0 % Apply RRE extrapolation
	if (verbose>=1)		
	  fprintf(1,"\n\t**********\n\tRRE EXTRAPOLATION STEP\n\t**********\n\n");
	end
	Fermi = Urrextrapolation(Fermistore);
	Fn(:,2) = Fermi(1:rows(Fn));
	Fp(:,2) = Fermi(rows(Fn)+1:end);
    end
  end
  
  if (verbose>=1)
    fprintf(1,"*** checking for convergence: ");
  end
  
  nrfn= norm (Fn(:,2)-Fn(:,1),inf);
  nrfp= norm (Fp(:,2)-Fp(:,1),inf);
  nrv = norm (V(:,2)-V(:,1),inf);
  nrm(ielet) = max([nrfn;nrfp;nrv]);
  
  if (verbose>=1)
    subplot(1,3,3);
    semilogy(nrm)
    %%title("max(|dV|,|dFn|,|dFp|)");
    pause(.1)
  end
  
  if (verbose>=1)
    fprintf (1," max(|dFn|,|dFp|,|dV| )= %g\n\n",...
	     nrm(ielet));
  end
  if (nrm(ielet)<toll)
    break
  end
  
  V(:,1) = V(:,2);
  n(:,1) = n(:,3);
  p(:,1) = p(:,3);
  Fn(:,1)= Fn(:,2);
  Fp(:,1)= Fp(:,2);
  
end

if (verbose>0)
  fprintf(1,"\n*** DD simulation over: # of electrical Gummel iterations = %d\n\n",ielet);
end

odata = idata;

odata.n    = n(:,end);
odata.p    = p(:,end);
odata.V    = V(:,end);
odata.Fn   = Fn(:,end);
odata.Fp   = Fp(:,end);
