/*  File    : stvmgain.c
 *  Abstract:
 *
 *      Time-varying matrix gain S-function MEX-file. This file is the source
 *      for a time varying matrix gain S-function block.  The block has two
 *      inputs:
 *
 *        1) The input signal.
 *        2) The input gains.
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 * 
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.14.4.3 $
 */

#define S_FUNCTION_NAME stvmgain
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */
 


/* first parameter: gain */
#define K_IDX 0
#define K_PARAM(S) ssGetSFcnParam(S,K_IDX)

/* second parameter: sample time */ 
#define SAMPLE_TIME_IDX 1
#define SAMPLE_TIME_PARAM(S) ssGetSFcnParam(S,SAMPLE_TIME_IDX)
 
#define NPARAMS 2

#define NOUTPUTS     mxGetM(K_PARAM(S))          /* rows of K */
#define NINPUTS      mxGetN(K_PARAM(S))          /* columns of K */


/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      /* Check 1st parameter: Matrix Gain (K) parameter */
      {
          if (!mxIsDouble(K_PARAM(S))) {
              ssSetErrorStatus(S,"1st parameter to S-function must be "
                               "real \"matrix gain\"");
              return;
          }
      }
 
      /* Check 2nd parameter: Sample Time parameter */
      {
          if (!mxIsDouble(SAMPLE_TIME_PARAM(S))) {
              ssSetErrorStatus(S,"2nd parameter to S-function must be "
                               "real \"sample time\"");
              return;
          }
      }
  }
#endif /* MDL_CHECK_PARAMETERS */



/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T matrix_size;
    int_T numInputs;

    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            switch ( iParam )
            {
              case SAMPLE_TIME_IDX:
                
                ssSetSFcnParamTunable( S, iParam, 0 );
                break;

              default:
                ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
                break;
            }
        }
    }

    /* Set-up size information, only do this if there is 1 input arg */
    matrix_size = mxGetNumberOfElements(K_PARAM(S));
 
    /*
     * number of columns of U must match number of columns in K,
     * so input width is columns of U (NINPUTS) + matrix_size
     */
    numInputs = NINPUTS + matrix_size;
    
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 1);
    
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, numInputs);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, NOUTPUTS);
    
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, matrix_size);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    One sample time, and it's passed in as the second S-function parameter
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, *mxGetPr(SAMPLE_TIME_PARAM(S)));
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
}



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize both continuous states to zero
 */
static void mdlInitializeConditions(SimStruct *S)
{
    int_T        lengthK     = mxGetNumberOfElements(K_PARAM(S));
    const real_T *gainValues = mxGetPr(K_PARAM(S));
    real_T       *rWork      = ssGetRWork(S);
    int_T        i;
 
    /* store initial gain matrix values in the real work vector */
    for (i = 0; i < lengthK; i++) {
        rWork[i] = gainValues[i];
    }
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = K * u
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T            *y    = ssGetOutputPortRealSignal(S,0);
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *kPtr = ssGetRWork(S);
    int_T             i,j;
    real_T            accum;
 
    UNUSED_ARG(tid); /* not used in single tasking mode */

    /* Matrix Multiply: y = K * u */
    for (i = 0; i < NOUTPUTS; i++) {
        accum = 0.0;
 
        /* K * u */
        for (j = 0; j < NINPUTS; j++) {
            accum += kPtr[i + NOUTPUTS*j] * U(j);
        }
 
        y[i] = accum;
    }
}



#define MDL_UPDATE
/* Function: mdlUpdate ======================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs       = ssGetInputPortRealSignalPtrs(S,0);
    int_T             matrix_size = mxGetNumberOfElements(K_PARAM(S));
    real_T            *gainValues = ssGetRWork(S);
    /* the first gain value is after the system inputs */
    const real_T      *u          = &U(NINPUTS);
    int_T             i, allZero;
    
    UNUSED_ARG(tid); /* not used in single tasking mode */

    /*
     * check for zeros on the input, it could be unconnected inputs
     * get the next gain matrix
     */
    allZero = 1;
    for (i=0; (i < matrix_size) && allZero; i++) {
        allZero &= u[i] == 0.0;
    }
    
    /*
     * if the inputs gain are not all zero, update the gain matrix
     */
    if (!allZero) {
        for (i = 0; i < matrix_size; i++) {
            *gainValues++ = *u++;
        }
    }
}



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
