/* mpc_sfun.c: Online MPC controller - Simulink/RTW S-Function
//
//    Author: A. Bemporad, G. Bianchini
//    Copyright 1986-2003 The MathWorks, Inc.
//    $Revision: 1.1.10.8 $  $Date: 2004/04/04 03:37:38 $
 */

#include "mpc_sfun.h"
#include "mpc_common.c"
/*
// MPC_COMMON.C contains the following functions (shared with MPCLOOP_ENGINE.C):
//      mdlOutputs(mxArray *S, int_T tid)
//      mdlUpdate(mxArray *S, int_T tid)
*/

/* S-Function callback methods */

static void mdlCheckParameters(SimStruct *S)

{
}

/* #define DEBUG */

static void mdlInitializeSizes (SimStruct *S)   /*Initialise the sizes array */
{
    int_T openloopflag;
    
    /*
    // The open-loop behavior is modelled by the state space “open circuit” system
    // (no direct feedthrough)
    //
    // x(k+1) = x(k)
    // y(k)   = x(k), where x(k),y(k) have dimension nu (=number of MVs)
     */
    
    int_T nu; /* Size of input vector */
    int_T nx; /* Size of state vector */
    int_T nym;
    int_T ny;
    int_T nv;
    int_T nxQP; /* Size of state vector without Noise model states */
    
    boolean_T no_md; /* no_md=1 means no MD connected */
    boolean_T no_ref; /* no_ref=1 means no reference connected */
    boolean_T no_ym; /* no_ym=1 means no measured output connected */
    boolean_T md_inport; /* md_inport=1 means MD port is enabled */

    openloopflag = (int_T)*mxGetPr(p_openloopflag(S)); 

#ifdef DEBUG
  printf("%s: openloopflag=%d\n","mdlInitializeSizes",openloopflag);
#endif

     nu = (int)*mxGetPr(p_nu(S)); /* Size of input vector */
     if (nu==0){
          ssSetErrorStatus(S, "MPC Block is empty. Open the MPC designer to create an MPC controller");
         return;}

  if (openloopflag==0){
     nx = (int)*mxGetPr(p_nx(S)); /* Size of state vector */
     nym = (int)*mxGetPr(p_nym(S));
     ny = (int)*mxGetPr(p_ny(S));
     nv = (int)*mxGetPr(p_nv(S));
     nxQP = (int)*mxGetPr(p_nxQP(S)); /* Size of state vector without Noise model states */

     /*
	 //no_md = mxGetLogicals(p_no_md(S))[0];   // no_md=1 means no MD connected
     //no_ref = mxGetLogicals(p_no_ref(S))[0]; // no_ref=1 means no reference connected
      */
     no_md = (boolean_T) *mxGetPr(p_no_md(S));   /* no_md=1 means no MD connected */
     no_ref =  (boolean_T) *mxGetPr(p_no_ref(S)); /* no_ref=1 means no reference connected */
     no_ym =  (boolean_T) *mxGetPr(p_no_ym(S)); /* no_ym=1 means no measured output connected */
     md_inport =  (boolean_T) *mxGetPr(p_md_inport(S)); /* md_inport=1 means no MD signal is enabled */
  }


  ssSetNumSFcnParams(S, NPARAMS);  /* Expected number of parameters */

#ifdef DEBUG
  printf("ssGetSFcnParamsCount(S)=%d\n",ssGetSFcnParamsCount(S));
#endif

  if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S))
  {
    mdlCheckParameters(S); /* Initial parameter format check (needed?) */
    if (ssGetErrorStatus(S) != NULL)
      return; /* Parameter type error */
  }
  else
  {
 #ifdef DEBUG
  printf("ssGetSFcnParamsCount(S)=%d\n",ssGetSFcnParamsCount(S));
#endif
    ssSetErrorStatus(S, param_MSG);
    return; /* Parameter number mismatch */
  }

  /* No continuous states */

  ssSetNumContStates(S, 0);


  /* No discrete states when using RT, work vectors will do */
  if (openloopflag==1)
     ssSetNumDiscStates(S, nu);   /* open-loop: x(k+1)=x(k), y(k)=x(k), dim(y)=dim(x)=nu */
  else
  	#ifndef RT
     ssSetNumDiscStates(S, nx+nu); /* register lastx and lastu as states */
  /*
	//                                w_lastx = (ssGetPWorkValue(S,0))  
	//                                w_lastu = (ssGetPWorkValue(S,1)) 
   */
    #else
     ssSetNumDiscStates(S, 0);  /* don't duplicate workvalues to states when using RTW */
    #endif

  /* Set up input ports */

  if (!ssSetNumInputPorts(S, 1))
    return;


  if (openloopflag==0){
#ifdef DEBUG
     printf("%s\n","Closed loop port assignment");
     printf("ny=%d, nym=%d, nv=%d\n",ny,nym,nv);
     printf("no_ref=%d, no_md=%d, no_ym=%d, md_inport=%d, INPUTSIZE=%d",no_ref,no_md,no_ym,md_inport,nym*(1-no_ym)+ny*(1-no_ref)+(nv-1)*(1-no_md)+no_md*md_inport+no_ref+no_ym);
#endif
     /* ssSetInputPortVectorDimension(S,0,nym*(1-no_ym)+ny*(1-no_ref)+(nv-1)*(1-no_md)+no_md*md_inport+no_ref+no_ym); */
     ssSetInputPortWidth(S,0,DYNAMICALLY_SIZED); 
  }
  else{  
#ifdef DEBUG
       printf("%s\n","Open loop port assignment");
#endif
     ssSetInputPortWidth(S,0,DYNAMICALLY_SIZED); 
  } 

    /* Set up output ports */
  if (!ssSetNumOutputPorts(S,1)) /* one output port */
    return;

      ssSetOutputPortVectorDimension(S, 0, nu);

    if (openloopflag==0 ){  
	#ifdef DEBUG
		printf("%s\n","Direct feed through");
	#endif
      ssSetInputPortDirectFeedThrough(S,0,1);
  }
  else{
	#ifdef DEBUG
      	printf("%s\n","No direct feed through");
	#endif
      ssSetInputPortDirectFeedThrough(S,0,0);
      }    


  /* One sample time */

  ssSetNumSampleTimes(S, 1);

  /*  Number of work dynamic variables */

  ssSetNumPWork(S,NPWORK);
#ifdef LOCKUPDATE
  ssSetNumIWork(S,NIWORK);
#endif

  ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
  real_T ts = (real_T)*mxGetPr(p_Ts(S));

  int_T openloopflag = (int_T)*mxGetPr(p_openloopflag(S));
#ifdef DEBUG
    printf("%s\n","mdlInitializeSampleTimes");
#endif

  if (( openloopflag==0)
	  & (ts > 0))  /*AB: ts was set as the sampling time only if ts>0 */
	    ssSetSampleTime(S, 0, ts);
  else
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);

  ssSetOffsetTime(S, 0, 0.0);
}



#define MDL_INITIALIZE_CONDITIONS
#if defined(MDL_INITIALIZE_CONDITIONS)

static void mdlInitializeConditions(SimStruct *S)

{
  int_T i;

  #ifndef RT
  real_T *states; /* pointer to s-function states, also used if openloopflag=1
                     When openloopflag=1, there are nu states. Otherwise, nx+nu states.
                     If RTW is used, then there're no states
                   */
  #endif

  real_T *lastx;
  real_T *lastu;
  real_T *optimalseq;
  real_T *v;
  long int *lastt;

  /* Retrieve some useful constants */
  int_T nu,nx,nv,p;

    int_T openloopflag = (int_T)*mxGetPr(p_openloopflag(S)); 
#ifdef DEBUG
    printf("%s\n","mdlInitializeConditions");
#endif

  nu = (int_T)mxGetPr(p_nu(S))[0]; /* Size of input vector */
  nx = (int_T)mxGetPr(p_nx(S))[0]; /* Size of extended state vector */

  #ifndef RT
  states = ssGetDiscStates(S);

  if (openloopflag==1){  
	#ifdef DEBUG
  		printf("%s\n","initializing");
	#endif
       /* Initialize state vector and return */
       /*nu = ssGetOutputPortWidth(S, 0);*/   /* Size of input vector */
       for (i=0; i<nu; i++){
            states[i]=0.0;} /* AB: SHOULDN'T THIS BE THE INPUT OFFSET uoff, */ 
                            /* OR EVEN BETTER lastu PASSED FROM THE MASK ? */
                            /* Yes but if there is no MPC obj we must assume 0 */
	#ifdef DEBUG
       printf("%s\n","initialized");
	#endif
       return; 
  }
  #endif

  nv = (int_T)mxGetPr(p_nv(S))[0]; /* Size of current meas. dist. vect */
  p = (int_T)mxGetPr(p_p(S))[0]; /* Prediction horizon */


  /* Initialize lastx, lastu, optimalseq, lastt to parameter values */

  lastx = calloc(nx,sizeof(real_T));
  lastu = calloc(nu,sizeof(real_T));
  optimalseq = calloc(mxGetM(p_optimalseq(S)),sizeof(real_T));
  v = calloc((p+1)*nv,sizeof(real_T));
  lastt = calloc(1,sizeof(long int));

  memcpy(lastx, mxGetPr(p_lastx(S)), nx*sizeof(real_T));
  memcpy(lastu, mxGetPr(p_lastu(S)), nu*sizeof(real_T));
  memcpy(optimalseq, mxGetPr(p_optimalseq(S)),
         mxGetM(p_optimalseq(S))*sizeof(real_T));

  lastt[0] = 0;

  for (i=0; i<p+1; i++) {
	v[i*nv+nv-1]=1.0; /* additional measured disturbance due to offsets */
  }

  w_lastx = lastx;
  w_lastu = lastu;
  w_v = v;
  w_optimalseq = optimalseq;
  w_lastt = lastt;

  	#ifndef RT
     for (i=0; i<nx; i++)
            states[i]=lastx[i];
     for (i=0; i<nu; i++)
            states[nx+i]=lastu[i];
  	#endif

#ifdef LOCKUPDATE
  /* Initialize updateflag */
  *w_updateflag = 0;
#endif

}


#endif /* MDL_INITIALIZE_CONDITIONS */

/*
// static void mdlOutputs(SimStruct *S, int_T tid)    --> moved to MPC_COMMON.C
// static void mdlUpdate(SimStruct *S, int_T tid)     --> moved to MPC_COMMON.C
 */


static void mdlTerminate(SimStruct *S)
{
  int i;

#ifdef DEBUG
  printf("END\n");
#endif

  /* Free all work vectors */

  for (i = 0; i<ssGetNumPWork(S); i++) {
    if (ssGetPWorkValue(S,i) != NULL) {
      free(ssGetPWorkValue(S,i));
    }
  }
}

#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                   int_T inputPortWidth)
  {
     ssSetInputPortWidth(S,port,inputPortWidth);
     /* ssSetOutputPortWidth(S,port,2); */
  }
# define MDL_SET_OUTPUT_PORT_WIDTH
  static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                    int_T outputPortWidth)
  {
     ssSetInputPortWidth(S,port,DYNAMICALLY_SIZED);
     /*ssSetOutputPortWidth(S,port,2);*/

  }
#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
