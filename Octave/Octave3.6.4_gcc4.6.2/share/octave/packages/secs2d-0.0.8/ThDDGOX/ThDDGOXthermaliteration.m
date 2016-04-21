function [thermdata,nrm] = ThDDGOXthermaliteration(imesh,Dsides,...
						   Simesh,Sinodes,Sielements,...
						   SiDsides,thermdata,toll,...
						   maxit,verbose)
  

  %%  [thermdata,innrm] = ThDDGOXthermaliteration(imesh,Dsides,...
  %% 						  Simesh,Sinodes,Sielements,...
  %%                                              SiDsides,thermdata,toll,...
  %%                                              maxit,verbose)

  %%%%%%%%%%%%%%%
  %% RRE param %%
  RREnnit      = [10,2];
  RRErank      = maxit;  
  RREpattern   = URREcyclingpattern(RREnnit,RRErank,maxit);
  %%%%%%%%%%%%%%%

  %% Set list of nodes with Dirichlet BCs
  Dnodes = Unodesonside(imesh,Dsides);
  SiDnodes = Unodesonside(Simesh,SiDsides);

  Tl  = thermdata.Tl;
  Tn  = thermdata.Tn;
  Tp  = thermdata.Tp;
  
  tldampcoef = 1;
  tndampcoef = 10;
  tpdampcoef = 10;
  
  mobn0 = thermdata.mobn0(imesh,Simesh,Sinodes,Sielements,thermdata);
  mobp0 = thermdata.mobp0(imesh,Simesh,Sinodes,Sielements,thermdata);
  mobn1 = thermdata.mobn1(imesh,Simesh,Sinodes,Sielements,thermdata);
  mobp1 = thermdata.mobp1(imesh,Simesh,Sinodes,Sielements,thermdata);
  twn0  = thermdata.twn0 (imesh,Simesh,Sinodes,Sielements,thermdata);
  twp0  = thermdata.twp0 (imesh,Simesh,Sinodes,Sielements,thermdata);
  twn1  = thermdata.twn1 (imesh,Simesh,Sinodes,Sielements,thermdata);
  twp1  = thermdata.twp1 (imesh,Simesh,Sinodes,Sielements,thermdata);
  [Ex,Ey] = Updegrad(Simesh,-thermdata.V(Sinodes));
  E =  [Ex;Ey];  

  [jnx,jny] = Ufvsgcurrent3(Simesh,thermdata.n,...
			    mobn0,mobn1,Tn,thermdata.V(Sinodes)-Tn);
  [jpx,jpy] = Ufvsgcurrent3(Simesh,thermdata.p,...
			    -mobp0,mobp1,Tp,-thermdata.V(Sinodes)-Tp);

  Jn = [jnx;jny];
  Jp = [jpx;jpy];
  
  for ith=1:maxit
    
    if (verbose>=1)
      fprintf(1,"*** start of inner iteration number: %d\n",ith);
    end

    if (verbose>=1)
      fprintf(1,'\t***updating electron temperature\n');
    end
    
    Tn =  ThDDGOXupdateelectron_temp(Simesh,SiDnodes,thermdata.Tn,...
     				     thermdata.n,thermdata.p,...
     				     thermdata.Tl,Jn,E,mobn0,...
                                     twn0,twn1,thermdata.tn,thermdata.tp,...
     				     thermdata.ni,thermdata.ni);

    ##Tn(Tn<thermdata.Tl) = thermdata.Tl(Tn<thermdata.Tl);
    
    dtn     = norm(Tn-thermdata.Tn,inf);
    if (dtn>0) 
      tndampfact_n = log(1+tndampcoef*dtn)/(tndampcoef*dtn);
      Tn  = tndampfact_n * Tn + (1-tndampfact_n) * thermdata.Tn;
    end
    
    if (verbose>=1)
      fprintf(1,'\t***updating hole temperature\n');
    end
    

    Tp = ThDDGOXupdatehole_temp(Simesh,SiDnodes,thermdata.Tp,...
   				thermdata.n,thermdata.p,...
    				thermdata.Tl,Jp,E,mobp0,...
                                twp0,twp1,thermdata.tn,thermdata.tp,...
    				thermdata.ni,thermdata.ni);

    ##Tp(Tp<thermdata.Tl) = thermdata.Tl(Tp<thermdata.Tl);

    dtp     = norm(Tp-thermdata.Tp,inf);
    if (dtp>0) 
      tpdampfact_p = log(1+tpdampcoef*dtp)/(tpdampcoef*dtp);
      Tp  = tpdampfact_p * Tp + (1-tpdampfact_p) * thermdata.Tp;
    end
    
    if (verbose>=1)
      fprintf(1,'\t***updating lattice temperature\n');
    end
    
    ## store result for RRE
    if RREpattern(ith)>0
      TEMPstore(:,RREpattern(ith)) = [Tn;Tp;Tl];
      if RREpattern(ith+1)==0 % Apply RRE extrapolation
	if (verbose>=1)		
	  fprintf(1,"\n\t**********\n\tRRE EXTRAPOLATION STEP\n\t**********\n\n");
	end
	TEMP = Urrextrapolation(TEMPstore);
	Tn = TEMP(1:rows(Tn));
	Tp = TEMP(rows(Tn)+1:rows(Tn)+rows(Tp));
        Tl = TEMP(rows(Tn)+rows(Tp)+1:end);
    end
  end

  Tl = ThDDGOXupdatelattice_temp(Simesh,SiDnodes,thermdata.Tl,...
				 Tn,Tp,thermdata.n,...
				 thermdata.p,thermdata.kappa,thermdata.Egap,...
				 thermdata.tn,thermdata.tp,twn0,...
				 twp0,twn1,twp1,...
				 thermdata.ni,thermdata.ni);
  
  ##Tl(Tl<thermdata.Tl) = thermdata.Tl(Tl<thermdata.Tl);

  dtl = norm(Tl-thermdata.Tl,inf);
  if (dtl > 0)
    tldampfact = log(1+tldampcoef*dtl)/(tldampcoef*dtl);
    Tl    = tldampfact * Tl + (1-tldampfact) * thermdata.Tl; 
  end
  
  
  if (verbose>=1)
    fprintf(1,"\t*** checking for convergence:\n ");
  end
  
  nrm(ith) = max([dtl,dtn,dtp]);	
  
  if (verbose>=1)
    fprintf (1,"\t\t|dTL|= %g\n",dtl);
    fprintf (1,"\t\t|dTn|= %g\n",dtn);
    fprintf (1,"\t\t|dTp|= %g\n",dtp);
  end
  
  thermdata.Tl = Tl;
  thermdata.Tn = Tn;
  thermdata.Tp = Tp;
  if (verbose>1)
    subplot(1,3,2);
    title("max(|dTl|,|dTn|,|dTn|)")
    semilogy(nrm)
    pause(.1)
  end
  if nrm(ith)< toll
    if (verbose>=1)
      fprintf(1,"\n***\n***\texit from thermal iteration \n");
    end
    
    break
  end
  
end