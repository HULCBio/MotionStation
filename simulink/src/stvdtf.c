/*  File    : stvdtf.c
 *  Abstract:
 *
 *      Time Varying Discrete Transfer Function block
 *
 *      This block implements a discrete time transfer function
 *      whose transfer function polynomials are passed in via
 *      the input vector.  This is useful for discrete time
 *      adaptive control applications.
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 *
 *	This block has multiple sample times and will not work correctly
 *	in a multitasking environment. It is designed to be used in
 *	a single tasking (or variable step) simulation environment.
 *	Because this block accesses the input signal in both tasks,
 *	it cannot specify the sample times of the input and output ports
 *	(SS_OPTION_PORT_SAMPLE_TIMES_ASSIGNED).
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.17.4.3 $
 */

#define S_FUNCTION_NAME stvdtf
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define NUMERATOR_IDX 0
#define NUMERATOR_PARAM(S) ssGetSFcnParam(S,NUMERATOR_IDX)
 
#define DENOMINATOR_IDX 1
#define DENOMINATOR_PARAM(S) ssGetSFcnParam(S,DENOMINATOR_IDX)
 
#define PARAM_SAMPLE_TIME_IDX 2
#define PARAM_SAMPLE_TIME_PARAM(S) ssGetSFcnParam(S,PARAM_SAMPLE_TIME_IDX)

#define SAMPLE_TIME_IDX 3
#define SAMPLE_TIME_PARAM(S) ssGetSFcnParam(S,SAMPLE_TIME_IDX)
 
#define NPARAMS 4



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
      /* Check 1st & 2nd parameters: NUMERATOR/DENOMINATOR parameters */
      {
          if (mxGetNumberOfElements(NUMERATOR_PARAM(S)) >
              mxGetNumberOfElements(DENOMINATOR_PARAM(S))) {
              ssSetErrorStatus(S,"The denominator (parameter 2) must be same "
                               "or higher order than the numerator "
                               "(parameter 1)");
              return;
          }

          if (mxGetNumberOfElements(DENOMINATOR_PARAM(S)) <= 1) {
              ssSetErrorStatus(S,"There must be at least one state in the "
                               "transfer function");
              return;
          }
      }
 
      /* Check 3rd parameter: Parameter Sample Time parameter */
      /* the parameter sample rate must be slower than the block sample time */
      {
          if (*mxGetPr(PARAM_SAMPLE_TIME_PARAM(S)) < 
              *mxGetPr(SAMPLE_TIME_PARAM(S))) {
              ssSetErrorStatus(S,"The parameter sample rate (parameter 3) "
                               "must be slower than the block sample "
                               "rate (parameter 4)");
              return;
          }
      }
 
      /* Check 4th parameter: Sample Time of Block */
      /* The block sample time must be greater than zero (0.0) */
      {
          if (*mxGetPr(SAMPLE_TIME_PARAM(S)) <= 0.0) {
              ssSetErrorStatus(S,"The block sample rate (4th parameter) "
                               "must be greater than zero");
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
    int_T numDiscStates;
    int_T numInputs;

    /* See sfuntmpl_doc.c for more details on the macros below */
 
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
              case PARAM_SAMPLE_TIME_IDX:
              case SAMPLE_TIME_IDX:
                
                ssSetSFcnParamTunable( S, iParam, 0 );
                break;

              default:
                ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
                break;
            }
        }
    }

    numDiscStates = mxGetNumberOfElements(DENOMINATOR_PARAM(S)) - 1;
    numInputs     = 1 + 2 * (numDiscStates + 1);

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, numDiscStates);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, numInputs);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 2);
    ssSetNumRWork(S, 2*(numDiscStates+1));
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);

}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, *mxGetPr(SAMPLE_TIME_PARAM(S)));
    ssSetOffsetTime(S, 0, 0.0);

    ssSetSampleTime(S, 1, *mxGetPr(PARAM_SAMPLE_TIME_PARAM(S)));
    ssSetOffsetTime(S, 1, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 

}



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize the discrete states to zero and
 *    squirrel away the initial numerator and denominator
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T       *x0           = ssGetRealDiscStates(S);
    int_T        numDiscStates = ssGetNumDiscStates(S);
    real_T       *num          = ssGetRWork(S);
    real_T       *den          = num + numDiscStates + 1;
    const real_T *numParam     = mxGetPr(NUMERATOR_PARAM(S));
    const real_T *denParam     = mxGetPr(DENOMINATOR_PARAM(S));
    real_T       den0;
    int_T        i;

    /* The discrete states are all initialized to zero */
    for (i = 0; i < numDiscStates; i++) {
        x0[i]  = 0.0;
        num[i] = 0.0;
        den[i] = 0.0;
    }
 
    num[numDiscStates] = 0.0;
    den[numDiscStates] = 0.0;
 
    /* squirrel away the initial numerator and denominator */
    den0 = denParam[0];
    for (i = 0; i < mxGetNumberOfElements(DENOMINATOR_PARAM(S)); i++) {
        *den++ = *denParam++ / den0;
    }
 
    num += ssGetNumDiscStates(S)+1-mxGetNumberOfElements(NUMERATOR_PARAM(S));

    for (i = 0; i < mxGetNumberOfElements(NUMERATOR_PARAM(S)); i++) {
        *num++ = *numParam++ / den0;
    }
 
    /* normalize if this transfer function has direct feedthrough */
    num = ssGetRWork(S);
    den = num + numDiscStates + 1;
    for (i = 1; i < numDiscStates + 1; i++) {
        num[i] -= den[i]*num[0];
    }
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = Cx + Du 
 *
 *      The discrete system is evaluated using a controllable state space
 *      representation of the transfer function.  This implies that the
 *         output of the system is equal to:
 *
 *          y(k) = Cx(k) + Du(k)
 *               = [ b1 b2 ... bn]x(k) + b0u(k)
 *
 *      where b0, b1, b2, ... are the coefficients of 
 *      the numerator polynomial:
 *
 *         B(q) = b0 q^n + b1 q^n-1 + b2 q^n-2 + ... + bn-1 q + bn
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T            *y    = ssGetOutputPortRealSignal(S,0);
    real_T            *x    = ssGetRealDiscStates(S);
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);

    UNUSED_ARG(tid); /* not used in single tasking mode */

    if (ssIsSampleHit(S, 0, tid)) {
        int_T  i;
        int_T  numDiscStates = ssGetNumDiscStates(S);
        real_T *num = ssGetRWork(S);
 
        *y = *num++ * U(0);
        for (i = 0; i < numDiscStates; i++) {
            *y += *num++ * *x++;
        }
    }
}



#define MDL_UPDATE
/* Function: mdlUpdate ======================================================
 * Abstract:
 *      The discrete system is evaluated using a controllable state space
 *      representation of the transfer function.  This implies that the
 *      next discrete states are computed using:
 *
 *          x(k+1) = Ax(k) + Bu(k)
 *                 = [-a1 -a2 ... -an] [x1(k)] + [u(k)]
 *                   [  1  0  ...   0] [x2(k)] + [0]
 *                   [  0  1  ...   0] [x3(k)] + [0]
 *                   [  .  .  ...   .]   .     +  .
 *                   [  .  .  ...   .]   .     +  .
 *                   [  .  .  ...   .]   .     +  .
 *                   [  0  0  ... 1 0] [xn(k)] + [0]
 *     
 *      where a1, a2, ... are the coefficients of the numerator polynomial:
 *
 *         A(q) = q^n + a1 q^n-1 + a2 q^n-2 + ... + an-1 q + an
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{
    real_T            *x            = ssGetRealDiscStates(S);
    InputRealPtrsType uPtrs         = ssGetInputPortRealSignalPtrs(S,0);
    const real_T      *u            = &U(0);
    int_T             numDiscStates = ssGetNumDiscStates(S);
    real_T            *num          = ssGetRWork(S);
    real_T            *den          = num + numDiscStates + 1;
    int_T             i;

    UNUSED_ARG(tid); /* not used in single tasking mode */

    if (ssIsSampleHit(S, 0, tid)) {
        real_T firstTerm, x0;
        firstTerm = -den[1] * x[0];
        x0 = 0.0;
        for (i = 1; i < numDiscStates; i++) {
            real_T tmp;
 
            tmp = x[i];
            x[i] = x[i-1];
            x0 -= den[i+1] * tmp;
        }
 
        x[0] = x0 + firstTerm + u[0];
    }

    if (ssIsSampleHit(S, 1, tid)) {
        real_T den0;
        int_T numCoeffs;
        int_T allZero;
 
        /* the first numerator input is after the system input */
        u++;
 
        /*
         *---------------------------------------------------------------
         * if all inputs are zero, ignore it could be unconnected inputs
         *---------------------------------------------------------------
         */
 
        /*
         * Get the first denominator coefficient.  It will be used
         * for normalizing the numerator and denominator coefficients.
         */
 
        numCoeffs = numDiscStates + 1;
        den0 = u[numCoeffs];
        if (den0 == 0.0) {
            den0 = mxGetPr(DENOMINATOR_PARAM(S))[0];
        }
 
        /* grab the numerator */
        allZero = 1;
        for (i = 0; (i < numCoeffs) && allZero; i++) {
            allZero &= u[i] == 0.0;
        }

        if (allZero) {
            const real_T *numParam;
 
            /* move the input to the denominator input */
            u += numCoeffs;
 
            /* get the denominator from the input parameter */
            numParam = mxGetPr(NUMERATOR_PARAM(S));
            num += numCoeffs - mxGetNumberOfElements(NUMERATOR_PARAM(S));
            for (i = 0; i < mxGetNumberOfElements(NUMERATOR_PARAM(S)); i++) {
                *num++ = *numParam++ / den0;
            }
        } else {
            for (i = 0; i < numCoeffs; i++) {
                *num++ = *u++ / den0;
            }
        }
 
        /* grab the denominator */
        allZero = 1;
        for (i = 0; (i < numCoeffs) && allZero; i++) {
            allZero &= u[i] == 0.0;
        }
 
        if (allZero) {
            const real_T *denParam;
 
            denParam = mxGetPr(DENOMINATOR_PARAM(S));
            den0 = denParam[0];
            for (i = 0; i < mxGetNumberOfElements(DENOMINATOR_PARAM(S)); i++) {
                *den++ = *denParam++ / den0;
            }
 
        } else {
            for (i = 0; i < numCoeffs; i++) {
                *den++ = *u++ / den0;
            }
        }
 
        /* normalize if this transfer function has direct feedthrough */
 
        num = ssGetRWork(S);
        den = num + numCoeffs;
        for (i = 1; i < numCoeffs; i++) {
            num[i] -= den[i]*num[0];
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
