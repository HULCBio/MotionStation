/* mpc_common.c: MPC Simulink/RTW S-Function - Common C-code for MPC_SFUN.C 
                 and MPCLOOP_ENGINE.C
              
      Author: A. Bemporad, G. Bianchini
      Copyright 1986-2003 The MathWorks, Inc. 
      $Revision: 1.1.10.5 $  $Date: 2004/04/04 03:37:37 $   
*/

static void getrv(real_T *window, real_T *signal, int_T t1, int_T t2, int_T n, int_T m, int_T len)
{   /* function required for previewing reference and measured disturbance signals
  
	   Defines window=signal(1:n,t1+1:t2+1), where [m,t2-t1+1]=size(window) 
	   if signal has enough columns, otherwise repeats the last column 
	   ([n,len]=size(signal))
     */

  /* Counters */
  int_T i,j; 

#ifdef DEBUG
printf("t1: %d, t2: %d\n",t1,t2);
#endif

 if (t1+1>len) /* repeats the last one */
   /* window=signal(:,len)*ones(1,t2-t1+1); */
   for (i=0;i<t2-t1+1;i++)   
   		for (j=0;j<n;j++)
   			window[i*m+j]=signal[n*(len-1)+j];
 else if (t2+1>len)
	/* window=[signal(:,t1+1:len),signal(:,len)*ones(1,t2+1-len)]; */
   {
   for (i=0;i<len-t1+1;i++)   
   		for (j=0;j<n;j++)
   			window[i*m+j]=signal[n*(t1+i)+j];
   for (i=len-t1;i<t2-t1+1;i++)   
   		for (j=0;j<n;j++)
   			window[i*m+j]=signal[n*(len-1)+j];
   }
 else
   /* window=signal(:,t1+1:t2+1); */
 	for (i=0;i<t2-t1+1;i++)   
   		for (j=0;j<n;j++)
   			window[i*m+j]=signal[n*(t1+i)+j];

 
#ifdef DEBUG
for (i=0; i<t2-t1+1; i++)
	for (j=0; j<m; j++)
		printf("window(%d,%d): %5.2f\n",j,i,window[m*i+j]);
#endif
}

#ifdef MPC_SFUN
static void mdlOutputs(SimStruct *S, int_T tid) 
#endif
#ifdef MPCLOOP
static void mdlOutputs(const mxArray *S, int_T tid, real_T *lastx, real_T *lastu,
      real_T *v, real_T *optimalseq, long int *lastt,
      real_T *md_t, real_T *my_t, real_T *u_out, 
      boolean_T unconstr)
	  /* Note that with MPCLOOP tid = current time step. With MPCSFUN tid = Task ID */
#endif

{
  
  static real_T *ref_signal, * md_signal, *yoff, *voff, *myoff, *uoff;
  static real_T *M, *Cm, *Dvm;
  static int_T q, nvar, nxQP, p, degrees, PTYPE, useslack; 
  static long int maxiter;
  static real_T *Kv, *Mv, *Kx, *Ku1, *Kut, *Kr, *KduINV;
  static real_T *Mx, *Mu1, *rhsc0, *rhsa0, *Mlim, *MuKduINV, *TAB, *zmin;

  static real_T *utarget;
  static int_T nu, nx, nym, ny, nv;
  static boolean_T no_md, no_ref, no_ym, ref_from_ws, ref_preview, md_from_ws, md_preview;
  static int_T Nref_signal, Nmd_signal;
  static boolean_T isemptyKv;

  /* Counters */
  int_T i,j; 
  int_T numc;
  
  /* Accumulator */
  real_T adder;

  
#ifdef LOCKUPDATE
  int_T *updateflag = w_updateflag;
#endif
 
  /* Local work variables */

  real_T *r;      /* Reference values extended over pred. hor. */
  real_T *ytilde; /* Measurement update */
  real_T *vKv;
  real_T *Mvv;
  real_T *zopt;   /* Optimal sequence */
  real_T *zopx;   
  real_T *ztemp;
  real_T *rhsc;
  real_T *rhsa;
  real_T *basis;  /* Basis vector for QP */
  real_T *tab;    /* Tableau for QP */
  long int *ib;   /* Index vector for QP */
  long int *il;   /* Index vector fo QP */
  real_T *duold;
  int nuc = 0;    /* number of unconstrained vars in DANTZGMP */
  int iret;       /* DANTZGMP return code */
  
  int nym2;
  
  /* SimStruct *PS; */
  
  /* int no_md;*/  /* Variables for detecting if meas.dist and refs are connected to MPC block */
  /* int no_ref;  */
  
  /* Input and output vectors */
  
#ifdef MPC_SFUN  
	#ifndef RT
     real_T *openloopstates; 
     real_T *discstates;
	#endif
	 real_T *u_out;
	 real_T *lastx;
     real_T *lastu;
	 real_T *optimalseq = w_optimalseq;
     real_T *v;
     long int *lastt;
     InputRealPtrsType uPtrs;
     real_T *wlastx; 
     real_T *wlastu;

     int_T openloopflag = (int_T)*mxGetPr(p_openloopflag(S));


   /* printf("tid=%d\n",tid);  
   */

#ifdef DEBUG
     printf("%s","mdlout");
#endif
     if (openloopflag==1) {
#ifdef DEBUG
       printf("%s","get disc states");
#endif
       u_out = ssGetOutputPortRealSignal(S,0); 
       nu = ssGetOutputPortWidth(S, 0);   /* Size of input vector */
	   #ifndef RT
       openloopstates = ssGetDiscStates(S);
#ifdef DEBUG
       printf("%f",openloopstates[0]);
#endif
       for (q=0; q<nu; q++){
            u_out[q] = openloopstates[q];}
	   #endif
	   return;
     }


    /* (jgo) Copy 0:nx-1 of the disc states vector to lastx
	   Copy nx:nx+nu-1 of the disc states vector or last u */
    nu = (int_T)*mxGetPr(p_nu(S));   /* Size of input vector */
    nx = (int_T)*mxGetPr(p_nx(S));   /* Size of extended state vector */
    lastx = (real_T *)alloca(nx*sizeof(real_T));
    lastu = (real_T *)alloca(nu*sizeof(real_T));
	#ifndef RT
    discstates = ssGetDiscStates(S);
	memcpy(lastx, discstates, nx*sizeof(real_T));
	memcpy(lastu, discstates+nx, nu*sizeof(real_T));
	#else
	memcpy(lastx, w_lastx, nx*sizeof(real_T));
	memcpy(lastu, w_lastu, nu*sizeof(real_T));
    #endif

	optimalseq = w_optimalseq;
    v = w_v;
    lastt = w_lastt;
    
	
#endif
 
  /* Initialize vars from structure S */
#ifdef MPCLOOP
	if (tid==0) {
#else
	if (lastt[0]==0) {
#endif

    ref_signal=mxGetPr(p_ref_signal(S));
  	Nref_signal=mxGetN(p_ref_signal(S));
  	md_signal=mxGetPr(p_md_signal(S));
  	Nmd_signal=mxGetN(p_md_signal(S));
  	yoff=mxGetPr(p_yoff(S));
  	voff=mxGetPr(p_voff(S));
  	myoff=mxGetPr(p_myoff(S));
  	uoff=mxGetPr(p_uoff(S));
  	
  	M=mxGetPr(p_M(S));
  	Cm=mxGetPr(p_Cm(S));
  	Dvm=mxGetPr(p_Dvm(S));
  	
  	Kv=mxGetPr(p_Kv(S));
  	isemptyKv=mxIsEmpty(p_Kv(S));  
	Mv=mxGetPr(p_Mv(S));
  	Kx=mxGetPr(p_Kx(S));
  	Ku1=mxGetPr(p_Ku1(S));
  	Kut=mxGetPr(p_Kut(S));
  	Kr=mxGetPr(p_Kr(S));
  	KduINV=mxGetPr(p_KduINV(S));
	Mx=mxGetPr(p_Mx(S));
	Mu1=mxGetPr(p_Mu1(S));
	rhsc0=mxGetPr(p_rhsc0(S));
	rhsa0=mxGetPr(p_rhsa0(S));
	Mlim=mxGetPr(p_Mlim(S));
  	MuKduINV=mxGetPr(p_MuKduINV(S));
	TAB=mxGetPr(p_TAB(S));
	zmin=mxGetPr(p_zmin(S));

  	utarget=mxGetPr(p_utarget(S));

    nxQP = (int_T)*mxGetPr(p_nxQP(S)); /* Size of state vector without Noise model states */
    nu = (int_T)*mxGetPr(p_nu(S));   /* Size of input vector */
    nx = (int_T)*mxGetPr(p_nx(S));   /* Size of extended state vector */
    nym = (int_T)*mxGetPr(p_nym(S)); /* Size of measured output vector */
    ny = (int_T)*mxGetPr(p_ny(S));   /* Size of current ref. vect. */
    nv = (int_T)*mxGetPr(p_nv(S));   /* Size of current meas. dist. vect. */
	
    /*
	    no_md = mxGetLogicals(p_no_md(S))[0];   // no_md=TRUE means no MD connected 
	    no_ref = mxGetLogicals(p_no_ref(S))[0]; // no_ref=TRUE means no reference connected 
	    ref_from_ws = mxGetLogicals(p_ref_from_ws(S))[0]; // reference signal comes from workspace
	    ref_preview = mxGetLogicals(p_ref_preview(S))[0]; // =TRUE means preview is on 
	    md_from_ws = mxGetLogicals(p_md_from_ws(S))[0];   // meas. dist. signal comes from workspace 
	    md_preview = mxGetLogicals(p_md_preview(S))[0];   // =TRUE means preview is on 
   */ 
    
    no_md = (boolean_T) *mxGetPr(p_no_md(S));   /* no_md=TRUE means no MD connected */
  	no_ref = (boolean_T) *mxGetPr(p_no_ref(S)); /* no_ref=TRUE means no reference connected */
	no_ym = (boolean_T) *mxGetPr(p_no_ym(S));   /* no_ym=TRUE means no meas. output connected */
	ref_from_ws = (boolean_T) *mxGetPr(p_ref_from_ws(S)); /* reference signal comes from workspace */
  	ref_preview = (boolean_T) *mxGetPr(p_ref_preview(S)); /* =TRUE means preview is on */
  	md_from_ws = (boolean_T) *mxGetPr(p_md_from_ws(S));   /* meas. dist. signal comes from workspace */
  	md_preview = (boolean_T) *mxGetPr(p_md_preview(S));   /* =TRUE means preview is on */
 
   	q = mxGetM(p_Mlim(S)); /* Number of constraints in QP problem */
  	p = (int_T)*mxGetPr(p_p(S)); /* Prediction horizon */
    degrees = (int_T)*mxGetPr(p_degrees(S)); 
    PTYPE = (int_T)*mxGetPr(p_PTYPE(S));
    maxiter = (int_T) *mxGetPr(p_maxiter(S)); /* Maxiter */
	
	if (PTYPE == SOFTCONSTR)
		useslack = 1;
    else
    	useslack = 0;
    nvar=degrees+useslack; /* number of optimization variables */
 }


#ifdef LOCKUPDATE
  /* Execute only if previous time update has been performed */

  if (*updateflag == 0) { /* Lock updateflag */
   *updateflag = 1;
#endif


#ifdef MPCLOOP
  if (unconstr) PTYPE=UNCONSTR;  /* remove MPC constraints */
#endif

/*printf("lastx: ["); for (i=0;i<nx;i++) printf("%g,",lastx[i]); printf("]\n"); */

    r =(real_T *)alloca(p*ny*sizeof(real_T)); /* reference signal vector r from workspace */


	#ifdef MPC_SFUN  
    	/* Retrieve pointers to input and output vectors */

    	uPtrs = ssGetInputPortRealSignalPtrs(S,0); /* only (S,0), as there's only one input port ... */
   		u_out = ssGetOutputPortRealSignal(S,0);    /* only (S,0), as there's only one output port ...*/
	#endif
     
    if (!ref_from_ws) /* ref. signal comes from Simulink diagram */ 
		{ /* Get output ref. from input port */
    	for (i=0; i<p; i++) {
			for (j=0; j<ny; j++) {
				if (no_ref)
					r[j+i*ny] = 0;  /* default: r=yoff */
	  			else 
		  			#ifdef MPC_SFUN  
		  				r[j+i*ny] = *uPtrs[j+nym]-yoff[j];
		  			#endif
		  			#ifdef MPCLOOP  
		  			/*	r[j+i*ny] = ref_t[j]-yoff[j]; */ /*This can never happen! */
		  			{ /* do nothing */
		  		    }
		  		    #endif
		  	}    
      	}
      	nym2=nym+1;
      	if (no_ref)
      		nym2=nym+ny;
    	}
    else /* Reference signal is contained in ref_signal */
    	{
    		if (!ref_preview)
    		{
		        getrv(r,ref_signal,*lastt,*lastt,ny,ny,Nref_signal);
    		/* Repeat over prediction horizon */
    		    for (i=1; i<p; i++) 
    		    	for (j=0; j<ny; j++)
						r[j+i*ny] = r[j];
			}
			else
        		getrv(r,ref_signal,*lastt,*lastt+p-1,ny,ny,Nref_signal);
    	}

#ifdef DEBUG
for (i=0; i<p; i++) {
	printf("r(:,%d): [",i);
	for (j=0; j<ny; j++)
		printf("%5.2f, ",r[ny*i+j]);
	printf("]'\n");
}
#endif
/*printf("r: ["); for (i=0;i<ny;i++) printf("%g,",r[i]); printf("]\n"); */


    /* Set up measured disturbance vector v from *uPtrs or from rv (file)
       as a one-component vector */

    if (!md_from_ws) /* measured disturbance comes from Simulink diagram */
		{ /* Get meas. dist. from input */
      	for (i=0; i<p+1; i++)
	    	for (j=0; j<nv-1; j++) {
	    		if (no_md)
					v[j+i*nv] = 0;  /* default: md=voff */
	      		else
		  			#ifdef MPC_SFUN  
		      			v[j+i*nv] = *uPtrs[j+nym2]-voff[j];
					#endif
		  			#ifdef MPCLOOP  
		      			v[j+i*nv] = md_t[j]-voff[j];
					#endif
			}
    }
    else /* Measured disturbance signal is contained in md_signal */
    	{
    		if (!md_preview)
    		{
		        getrv(v,md_signal,*lastt,*lastt,nv-1,nv-1,Nmd_signal);
		        /* Repeat over prediction horizon */
    		    for (i=1; i<p+1; i++) 
    		    	for (j=0; j<nv; j++)
						v[j+i*nv] = v[j];
			}
			else
				getrv(v,md_signal,*lastt,*lastt+p,nv-1,nv,Nmd_signal);
	}
	   
#ifdef DEBUG
for (i=0; i<p+1; i++) {
	printf("v(:,%d): [",i);
	for (j=0; j<nv; j++)
		printf("%5.2f, ",v[nv*i+j]);
	printf("]'\n");
}
#endif
	   
   
	   
    /* Measurement update of state observer */
  
    /* ytilde=y-myoff-(Cm*xk+Dvm*vk); */

    ytilde=(real_T *)alloca(nym*sizeof(real_T));

	/* printf("ym[0]=%g\n",*uPtrs[0]); */

    for (i=0; i<nym; i++) {
       CLR; /* i.e., adder = 0 */
       MVP(Cm, lastx, i, nym, nx);
       MVP(Dvm, v, i, nym, nv);
/* printf("adder[%d]: %g\n",i,adder); */
  
	  #ifdef MPC_SFUN
       if (no_ym)
           ytilde[i]=0.0-myoff[i]-adder;
       else
	      ytilde[i]=*uPtrs[i]-myoff[i]-adder;
	  #endif

	   
      #ifdef MPCLOOP  
	      ytilde[i]=my_t[i]-adder;
	  #endif
    }

    /*   xk=xk+M*ytilde;  % (NOTE: what is called M here is also called M in KALMAN's help file) */
    
#ifdef DEBUG
	printf("lastx[0]=%g\n",lastx[0]);
#endif

    for (i=0; i<nx; i++) {
      CLR;
      MVP(M, ytilde, i, nx, nym);
      lastx[i] += adder;

#ifdef DEBUG
      printf("Measurement update: x[%d]: %f\n",i,lastx[i]);
#endif
    }      

    /* Now ready for MPC optimization problem

      xQP=xk(1:nxQP)  only these first nx states are fed back to the QP problem
                      (i.e., multiplied by the Kx gain)
     */

#ifdef DEBUG
    printf("Starting MPC Optimization Problem ...\n");
#endif

    vKv = (real_T *)alloca(degrees*sizeof(real_T));

    if (isemptyKv) {
      for (j=0; j<degrees; j++)
		 vKv[j]=0.0;

	if(PTYPE != UNCONSTR) {
	Mvv = (real_T *)alloca(q*sizeof(real_T)); /* q=number of constraints */
        for(i=0; i<q; i++)
          Mvv[i]=0.0;
      }
    }
    else {
    	
      	for (j=0; j<nvar; j++) {
			CLR;
			MVTP(Kv, v, j, (p+1)*nv);
			vKv[j]=adder;
    }
    if (PTYPE != UNCONSTR) {
    	/*printf("N(Mv),M(Mv): %d,%d -- nvar: %d, (p+1)*nv: %d\n",mxGetN(p_Mv(S)),mxGetM(p_Mv(S)),q,(p+1)*nv); */
		Mvv = (real_T *)alloca(q*sizeof(real_T));
		for (i=0; i<q; i++) {
	  		CLR;  
	  		MVP(Mv, v, i, q, (p+1)*nv);
	  		Mvv[i]=adder; 
		} 
      } 
    }   

    /* The equivalent of mpc2.m starts here */
  
    if (PTYPE == UNCONSTR) { 

      /* Unconstrained problem, compute zopt */

#ifdef DEBUG
      printf("UNCONSTRAINED!\n");
#endif


	  /*     zopt=-KduINV*(Kx'*xk+Ku1'*uk1+Kut'*utarget+Kr'*r+vKv'); */
	  

      ztemp=(real_T *)alloca(nvar*sizeof(real_T)); /* stores linear term of the cost function */
      for (i=0; i<nvar; i++) {
		CLR;
		MTVP(Kx, lastx, i, nxQP);  
		
		/* for (j=0; j<nxQP; j++) {
		printf("Kx[%d]: %7.5f, x[%d]: %7.5f\n",j,mxGetPr(p_Kx(S))[j],j,lastx[j]); 
		} */
        
		MTVP(Ku1, lastu, i, nu);  

		/*printf("N(Kut),M(Kut): %d,%d -- nvar: %d, p*nu: %d\n",mxGetN(p_Kut(S)),mxGetM(p_Kut(S)),nvar,p*nu); */
		MTVP(Kut, utarget, i, p*nu);
		/*printf("N(Kr),M(Kr): %d,%d -- nvar: %d, p*ny: %d\n",mxGetN(p_Kr(S)),mxGetM(p_Kr(S)),nvar,p*ny); */
		MTVP(Kr, r, i, p*ny);
		ztemp[i]=adder+vKv[i];
      }   
      zopt=(real_T *)alloca(nvar*sizeof(real_T));
      for (i=0; i<nvar; i++) {
		CLR;
		MVP(KduINV, ztemp, i, nvar, nvar);
		zopt[i] = -adder;
	  }
    }      
    else { 

      /* Constrained, must solve QP */

#ifdef DEBUG
      printf("CONSTRAINED!\n");
#endif

      /* Set up matrices for QP */
 

	  /* rhsc=rhsc0+Mlim+Mx*xk+Mu1*uk1+Mvv; */
      /* printf("N(rhsc0),M(rhsc0): %d,%d -- 1: %d, q: %d\n",mxGetN(p_rhsc0(S)),mxGetM(p_rhsc0(S)),1,q); */
      rhsc=(real_T *)alloca(q*sizeof(real_T));

      for (i=0; i<q; i++) {
		CLR;
		MVP(Mx, lastx, i, q, nxQP);
		MVP(Mu1, lastu, i, q, nu);
		rhsc[i]=rhsc0[i]+Mlim[i]+Mvv[i]+adder;
      }    

	  /* rhsa=rhsa0-[(xk'*Kx+r'*Kr+uk1'*Ku1+vKv+utarget'*Kut),zeros(1,useslack)]'; */
      /*printf("N(rhsa0),M(rhsa0): %d,%d -- 1: %d, nvar: %d\n",mxGetN(p_rhsa0(S)),mxGetM(p_rhsa0(S)),1,nvar); */
	  rhsa=(real_T *)alloca(nvar*sizeof(real_T));
      rhsa[nvar-1] = 0.0;
	  /* printf("N(Kut),M(Kut): %d,%d -- nvar: %d, p*nu: %d\n",mxGetN(p_Kut(S)),mxGetM(p_Kut(S)),nvar-useslack,p*nu); */
	  /* printf("N(Kr),M(Kr): %d,%d -- nvar: %d, p*ny: %d\n",mxGetN(p_Kr(S)),mxGetM(p_Kr(S)),nvar-useslack,p*ny); */
	
	  for (j=0; j<nvar-useslack; j++) {
		CLR;
		MVTP(Kx, lastx, j, nxQP); /* AB: modified Aug 9, 2002 */ 
		MVTP(Kr, r, j, p*ny);
		MVTP(Ku1, lastu, j, nu);
		MVTP(Kut, utarget, j, p*nu);
		/* rhsa[j]=mxGetPr(p_rhsa0(S))[j]-(adder+vKv[j]); */
		rhsa[j]=rhsa0[j]-(adder+vKv[j]);  /* << This wasn't working unless I was using printf(rhsa[j]) (why?) */
	    /* printf("%5.2f\n",rhsa[j]); */
	    
      }
    /* basis=[KduINV*rhsa;rhsc-MuKduINV*rhsa]; */
      
      numc = nvar+q;
      basis = (real_T *)alloca(numc*sizeof(real_T));

#ifdef DEBUG
      printf("Basis is %d items\n", numc);
#endif      

      for(i=0; i<nvar; i++) {
        CLR;
        MVP(KduINV, rhsa, i, nvar, nvar);
        basis[i]=adder;

#ifdef DEBUG
        printf("B %f\n",basis[i]);
#endif

      }
      /* printf("N(MuKduINV),M(MuKduINV): %d,%d -- 1: %d, nvar: %d\n",mxGetN(p_MuKduINV(S)),mxGetM(p_MuKduINV(S)),nvar,q); */

      for(i=0; i<q; i++) {
        CLR;
        MVP(MuKduINV, rhsa, i, q, nvar);
	    basis[i+nvar]=rhsc[i]-adder;

#ifdef DEBUG 
        printf("B %f\n",basis[i+mxGetM(p_KduINV(S))]);
#endif

      } 
      /* ibi=-[1:nvar+nc]'; */
      /* ili=-ibi; */
    
      ib = (long int *)alloca(numc*sizeof(long int));
      il = (long int *)alloca(numc*sizeof(long int));
      for(i=0; i<numc; i++) {
        il[i]=i+1;
        ib[i]=-il[i];
      }

      /* Initialize the tableau */

      tab = (real_T *)alloca(numc*numc*sizeof(real_T));
      memcpy(tab, TAB, numc*numc*sizeof(real_T));

#ifdef DEBUG
      printf("Tableau (is it modified?): %f",tab[0]);
#endif    

      /* Call QP optimizer and check if problem was feasible */
	  iret=dantzg(tab, &numc, &numc, &nuc, basis, ib, il, &maxiter);
      if (iret > 0) {

	      #ifndef RT /* return error messages, unless code is compiled for RTW */
				if (iret > maxiter)
        			mexWarnMsgTxt("Maximum number of iterations exceeded, solution is unreliable. Please augment Optimizer.MaxIter.");
	  	  #endif

        /* Feasible, extract the solution */

#ifdef DEBUG
	printf("Feasible!\n");        
#endif


	/* 
       for j=1:nvar
         if il(j) <= 0
             zopt(j)=zmin(j);
          else
             zopt(j)=basis(il(j))+zmin(j);
          end
        end
     */

        zopt=(real_T *)alloca((nvar)*sizeof(real_T));
        for (i=0; i<nvar; i++) {

#ifdef DEBUG
          printf("IL %d\n",il[i]);
#endif

          if (il[i] <= 0) {
            zopt[i]=zmin[i];
          }
          else {
            zopt[i]=basis[il[i]-1]+zmin[i]; 
          }

#ifdef DEBUG
          printf("Zopt %f\n",zopt[i]);
#endif

        }
      }
      else { 

        /* Unfeasible, recall last optimal sequence
           This should never happen 
         */

#ifdef DEBUG
	printf("Unfeasible!\n");
#endif 

      #ifndef RT /* return error messages, unless code is compiled for RTW */
			if (iret == numc * -3) {
        		mexWarnMsgTxt("Problems with QP solver -- Unable to delete a variable from basis");
				#ifdef DEBUG
        			printf("basis=["); 
        			for (i=0;i<numc;i++) {
        				printf("%g",basis[i]); 
        				if (i<numc-1)
        			    	printf(",");
        				}
        			printf("]\n");
				#endif 
        		printf("Using previous optimal sequence ...\n");      
        	}
			else
        		mexWarnMsgTxt("QP problem infeasible, using previous optimal sequence ...\n");
	  #endif

	/* POSSIBLE OTHER DEFAULT: zopt=0, so that u(t)=last_u+0=last_u */

	/*  duold=Jm*optimalseq;
		zopt=[duold(1+nu:nu*p);zeros(nu,1)]; % shifts
    
		% Rebuilds optimalseq from zopt
		%free=find(kron(DUFree(:),ones(nu,1))); % Indices of free moves
		free=find(DUFree(:));
		epsslack=Inf; % Slack variable for soft output constraints
	  	zopt=zopt(free);
     */

        zopx = (real_T *)alloca(nu*p*sizeof(real_T));
        zopt = (real_T *)alloca(mxGetM(p_optimalseq(S))*sizeof(real_T));
        for (i=0; i<mxGetM(p_optimalseq(S)); i++)
          zopt[i]=0.0;
        duold = (real_T *)alloca(mxGetM(p_Jm(S))*sizeof(real_T));
        for (i=0; i<mxGetM(p_Jm(S)); i++) {
          CLR;
          MVP(mxGetPr(p_Jm(S)), optimalseq,
              i, mxGetM(p_Jm(S)), mxGetN(p_Jm(S)));
          duold[i]=adder;   
        }

        for (i=nu; i<nu*p; i++)
          zopx[i-nu]=duold[i];
        for (i=nu*(p-1); i<nu*p; i++)
          zopx[i]=0.0;

	/* Find free moves */ 

        j=0;
        for (i=0; i<mxGetM(p_DUFree(S)); i++) {
          if ((int)(mxGetPr(p_DUFree(S))[i]) != 0)
            zopt[j++]=zopx[i];
        }         
      } 

      /* Rebuild optimalseq */ 

	  /* printf("%d, %d\n",mxGetM(p_optimalseq(S)),degrees); */
      for (i=0; i<degrees; i++)
        optimalseq[i]=zopt[i]; 
 
    /* End of MPC2.M */

    }
#ifdef DEBUG
      printf("zopt[0] %f\n",zopt[0]);
#endif

    /* Compute current input and update lastu */

    for (i=0; i<nu; i++){
      lastu[i] += zopt[i];
      u_out[i] = lastu[i]+uoff[i]; 
    
#ifdef DEBUG
      printf("Lastu %f\n",lastu[i]);
#endif
    } 

#ifdef MPC_SFUN
/* (jgo) Copy the new "state" vector back to the work vector */
       wlastx = w_lastx; 
       wlastu = w_lastu;
	   memcpy(wlastx, lastx, nx*sizeof(real_T));
       memcpy(wlastu, lastu, nu*sizeof(real_T));
#endif

#ifdef LOCKUPDATE
  }
  else { 
    /* Dummy step: do nothing! */
  }
#endif

}

#define MDL_UPDATE

#ifdef MPC_SFUN
static void mdlUpdate(SimStruct *S, int_T tid)
#endif
#ifdef MPCLOOP
static void mdlUpdate(const mxArray *S, int_T tid, real_T *lastx, real_T *lastu,
      real_T *v, long int *lastt)
#endif

{
  static int_T nu, nx, nv;
  static real_T *A, *Bu, *Bv;
  
  
  real_T *xk; /* Temporary state update */
  
  #ifdef MPC_SFUN
     #ifndef RT
     real_T *states;
     #endif
	 real_T *lastx = w_lastx;
     real_T *lastu = w_lastu;
     real_T *v = w_v;
     long int *lastt = w_lastt;
     int_T openloopflag = (int_T) *mxGetPr(p_openloopflag(S)); /* jgo */
  #endif

  int_T i,j;
  real_T adder;

#ifdef LOCKUPDATE
  int_T *updateflag = w_updateflag;
  *updateflag = 0;
#endif

#ifdef MPC_SFUN 
  #ifndef RT
  states = ssGetDiscStates(S);
  #endif
  if (openloopflag==1){
     return; /* don't change the state */
  }
#endif
#ifdef DEBUG
  printf("UPDATE\n");
#endif
 
    /* Initialize vars from structure S */
#ifdef MPCLOOP
	if (tid==0) {
#else
	if (lastt[0]==0) {
#endif
  	    nu = (int_T)*mxGetPr(p_nu(S));   /* Size of input vector */
    	nx = (int_T)*mxGetPr(p_nx(S));   /* Size of extended state vector */
    	nv = (int_T)*mxGetPr(p_nv(S));   /* Size of current meas. dist. vect. */
	   	A = mxGetPr(p_A(S));
	   	Bu = mxGetPr(p_Bu(S));
	   	Bv = mxGetPr(p_Bv(S));
	}
	
  /* Time update of state observer */
  
  xk = (real_T *)alloca(nx*sizeof(real_T));


    for (i=0; i<nx; i++) {
      CLR;
      MVP(A, lastx, i, nx, nx);
      MVP(Bu, lastu, i, nx, nu);
      MVP(Bv, v, i, nx, nv);
      xk[i]=adder;
      
#ifdef DEBUG
      printf("Time update: xk[%d]: %f\n",i,xk[i]);
#endif

    }

    memcpy(lastx, xk, nx*sizeof(real_T));
    
     /* update lastt */
   	*lastt += 1;


#ifdef DEBUG     
     printf("Lastt: %d\n",*lastt);
#endif

    #ifdef MPC_SFUN
  		#ifndef RT
     	for (i=0; i<nx; i++)
            states[i]=lastx[i];
     	for (i=0; i<nu; i++)
            states[nx+i]=lastu[i];
  		#endif
	#endif
}
