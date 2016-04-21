function [odata,ith,res] = ThDDGOXgummelmap (imesh,Dsides,...
					    Simesh,Sinodes,Sielements,SiDsides,...
					    idata,tol,maxit,ptol,pmaxit,thtol,thmaxit,...
					    eltol,elmaxit,verbose)
  
  ##   [odata,it,res] = ThDDGOXgummelmap (imesh,Dsides,...
  ## 				          Simesh,Sinodes,Sielements,SiDsides,...
  ## 				          idata,tol,maxit,ptol,pmaxit,thtol,thmaxit,...
  ## 				          eltol,elmaxit,verbose) 
  
  clear DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS
  global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS
  
  eletdata  = idata;
  thermdata = idata;
  nrm      = 1;
  eletnrm  = [];
  thermnrm = [];

  for ith=1:maxit
    
    eletdata.Tl  = thermdata.Tl;
    eletdata.Tn  = thermdata.Tn;
    eletdata.Tp  = thermdata.Tp;
    
    if (verbose>=1)
      fprintf(1,'\n***\n***\tupdating potentials\n***\n');
    end
    
    [eletdata,innrm1]=ThDDGOXeletiteration(imesh,Dsides,...
					  Simesh,Sinodes,Sielements,SiDsides,...
					  eletdata,eltol,elmaxit,ptol,pmaxit,verbose);
    eletnrm = [eletnrm,innrm1];
    
    thermdata.n  = eletdata.n;
    thermdata.p  = eletdata.p;
    thermdata.V  = eletdata.V;

    if (verbose>=1)
      fprintf(1,'\n***\n***\tupdating temperatures\n***\n');
    end
    
    [thermdata,innrm] = ThDDGOXthermaliteration(imesh,Dsides,...
						Simesh,Sinodes,Sielements,SiDsides,...
						thermdata,thtol,thmaxit,2);


    thermnrm = [eletnrm,innrm];
   
    nrm(ith) = max([innrm,innrm1]);
    if (verbose>=1)
      subplot(1,3,1);
      semilogy(nrm)
      pause(.1)
    end
    if (nrm(ith)<tol)
      if (verbose>0)
	fprintf(1,"\n***\n***\tThDD simulation over: # \
of Global iterations = %d\n***\n",ith);
      end
      break
    end
    
   
  end
  
  res = {nrm,eletnrm,thermnrm};  
  odata    = thermdata;
  