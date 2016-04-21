/*
 * File : stvctf.c
 * Abstract:
 *      Time Varying Continuous Transfer Function block
 *
 *      This S-function implements a continous time transfer function
 *      whose transfer function polynomials are passed in via the input
 *      vector.  This is useful for continuous time adapative control
 *      applications.
 *
 *      This S-function is also an example of how to "use banks" to avoid
 *      problems with computing derivatives when a continuous output has 
 *      discontinuities. The consistency checker can be used to verify that 
 *      your S-function is correct with respect to always maintaining smooth 
 *      and consistent signals for the integrators. By consistent we mean that
 *      two mdlOutput calls at major time t and minor time t are always the 
 *      same. The consistency checker is enabled on the diagnostics page of the
 *      simulation parameters dialog box. The update method of this S-function
 *      modifies the coefficients of the transfer function, which cause the
 *      output to "jump." To have the simulation work properly, we need to let
 *      the solver know of these discontinuities by setting 
 *      ssSetSolverNeedsReset and then we need to use multiple banks of 
 *      coefficients so the coefficients used in the major time step output 
 *      and the minor time step outputs are the same. In the simulation loop 
 *      we have:
 *        Loop:
 *          o Output in major time step at time t
 *          o Update in major time step at time t
 *          o Integrate (minor time step):
 *              o Consistency check: recompute outputs at time t and compare
 *                with current outputs.
 *              o Derivatives at time t
 *              o One or more Output,Derivative evaluations at time t+k
 *                where k <= step_size to be taken.
 *              o Compute state, x
 *              o t = t + step_size
 *            End_Integrate
 *        End_Loop
 *      Another purpose of the consistency checker is used to verify that when 
 *      the solver needs to try a smaller step_size that the recomputing of 
 *      the output and derivatives at time t doesn't change. Step size 
 *      reduction occurs when tolerances aren't met for the current step size.
 *      The ideal ordering would be to update after integrate. To achieve 
 *      this we have two banks of coefficients. And the use of the new 
 *      coefficients, which were computed in update, are delayed until after 
 *      the integrate phase is complete.
 *
 *	This block has multiple sample times and will not work correctly
 *	in a multitasking environment. It is designed to be used in
 *	a single tasking (or variable step) simulation environment.
 *	Because this block accesses the input signal in both tasks,
 *	it cannot specify the sample times of the input and output ports
 *	(SS_OPTION_PORT_SAMPLE_TIMES_ASSIGNED).
 *
 * See simulink/src/sfuntmpl_doc.c.
 *
 * Copyright 1990-2004 The MathWorks, Inc.
 * $Revision: 1.18.4.3 $
 */

#define S_FUNCTION_NAME  stvctf
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

/*
 * Defines for easy access to the numerator and denominator polynomials
 * parameters
 */
#define NUM(S)  ssGetSFcnParam(S, 0)
#define DEN(S)  ssGetSFcnParam(S, 1)
#define TS_IDX 2
#define TS(S)   ssGetSFcnParam(S, TS_IDX)
#define NPARAMS 3


#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify:
   *     o The numerator must be of a lower order than the denominator.
   *     o The sample time must be a real positive nonzero value.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      int_T i;

      for (i = 0; i < NPARAMS; i++) {
          real_T *pr;
          int_T   el;
          int_T   nEls;
          if (mxIsEmpty(    ssGetSFcnParam(S,i)) ||
              mxIsSparse(   ssGetSFcnParam(S,i)) ||
              mxIsComplex(  ssGetSFcnParam(S,i)) ||
              mxIsLogical(  ssGetSFcnParam(S,i)) ||
              !mxIsNumeric( ssGetSFcnParam(S,i)) || 
              !mxIsDouble(   ssGetSFcnParam(S,i)) ) {
              ssSetErrorStatus(S,"Parameters must be real finite vectors");
              return;
          } 
          pr   = mxGetPr(ssGetSFcnParam(S,i));
          nEls = mxGetNumberOfElements(ssGetSFcnParam(S,i));
          for (el = 0; el < nEls; el++) {
              if (!mxIsFinite(pr[el])) {
                  ssSetErrorStatus(S,"Parameters must be real finite vectors");
                  return;
              }
          }
      }

      if (mxGetNumberOfElements(NUM(S)) > mxGetNumberOfElements(DEN(S)) &&
          mxGetNumberOfElements(DEN(S)) > 0  && *mxGetPr(DEN(S)) != 0.0) {
          ssSetErrorStatus(S,"The denominator must be of higher order than "
                           "the numerator, nonempty and with first "
                           "element nonzero");
          return;
      }

      /* xxx verify finite */
      if (mxGetNumberOfElements(TS(S)) != 1 || mxGetPr(TS(S))[0] <= 0.0) {
          ssSetErrorStatus(S,"Invalid sample time specified");
          return;
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
    int_T nContStates;
    int_T nCoeffs;

    /* See sfuntmpl_doc.c for more details on the macros below. */
 
    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters. */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink. */
    }
#endif

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            switch ( iParam )
            {
              case TS_IDX:
                
                ssSetSFcnParamTunable( S, iParam, 0 );
                break;

              default:
                ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
                break;
            }
        }
    }

    /*
     * Define the characteristics of the block:
     *
     *   Number of continuous states:     length of denominator - 1
     *   Inputs port width                2 * (NumContStates+1) + 1
     *   Output port width                1
     *   DirectFeedThrough:               1 (yes, because the transfer function
     *                                       may be proper, not strictly 
     *                                       proper).
     *   Number of sample times:          2 (continuous and discrete)
     *   Number of Real work elements:    4*NumCoeffs
     *                                    (Two banks for num and den coeff's:
     *                                     NumBank0Coeffs
     *                                     DenBank0Coeffs
     *                                     NumBank1Coeffs
     *                                     DenBank1Coeffs)
     *   Number of Integer work elements: 2 (indicator of active bank 0 or 1
     *                                       and flag to indicate when banks
     *                                       have been updated).
     *
     * The number of inputs arises from the following:
     *   o 1 input (u)
     *   o the numerator and denominator polynomials each have NumContStates+1
     *     coefficients
     */
    nCoeffs     = mxGetNumberOfElements(DEN(S));
    nContStates = nCoeffs - 1;

    ssSetNumContStates(S, nContStates);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1 + (2*nCoeffs));
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortSampleTime(S, 0, mxGetPr(TS(S))[0]);
    ssSetInputPortOffsetTime(S, 0, 0);

    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOutputPortOffsetTime(S, 0, 0);

    ssSetNumSampleTimes(S, 2);

    ssSetNumRWork(S, 4 * nCoeffs);
    ssSetNumIWork(S, 2);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, (SS_OPTION_EXCEPTION_FREE_CODE));

} /* end mdlInitializeSizes */



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *      This function is used to specify the sample time(s) for the
 *      S-function.  This S-function has two sample times.  The
 *      first, a continous sample time, is used for the input to the
 *      transfer function, u.  The second, a discrete sample time
 *      provided by the user, defines the rate at which the transfer
 *      function coefficients are updated.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    /*
     * the first sample time, continuous
     */
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

    /*
     * the second, discrete sample time, is user provided
     */
    ssSetSampleTime(S, 1, mxGetPr(TS(S))[0]);
    ssSetOffsetTime(S, 1, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);

} /* end mdlInitializeSampleTimes */



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ==========================================
 * Abstract:
 *      Initalize the states, numerator and denominator coefficients.
 */
static void mdlInitializeConditions(SimStruct *S)
{
    int_T  i;
    int_T  nContStates = ssGetNumContStates(S);
    real_T *x0           = ssGetContStates(S);
    int_T  nCoeffs       = nContStates + 1;
    real_T *numBank0     = ssGetRWork(S);
    real_T *denBank0     = numBank0 + nCoeffs;
    int_T *activeBank    = ssGetIWork(S);

    /*
     * The continuous states are all initialized to zero.
     */
    for (i = 0; i < nContStates; i++) {
        x0[i]       = 0.0;
        numBank0[i] = 0.0;
        denBank0[i] = 0.0;
    }
    numBank0[nContStates] = 0.0;
    denBank0[nContStates] = 0.0;

    /*
     * Set up the initial numerator and denominator.
     */
    {
        const real_T *numParam   = mxGetPr(NUM(S));
        int          numParamLen = mxGetNumberOfElements(NUM(S));

        const real_T *denParam   = mxGetPr(DEN(S));
        int          denParamLen = mxGetNumberOfElements(DEN(S));
        real_T       den0        = denParam[0];

        for (i = 0; i < denParamLen; i++) {
            denBank0[i] = denParam[i] / den0;
        }

        for (i = 0; i < numParamLen; i++) {
            numBank0[i] = numParam[i] / den0;
        }
    }

    /*
     * Normalize if this transfer function has direct feedthrough.
     */
    for (i = 1; i < nCoeffs; i++) {
        numBank0[i] -= denBank0[i]*numBank0[0];
    }

    /*
     * Indicate bank0 is active (i.e. bank1 is oldest).
     */
    *activeBank = 0;

} /* end mdlInitializeConditions */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      The outputs for this block are computed by using a controllable state-
 *      space representation of the transfer function.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    if (ssIsContinuousTask(S,tid)) {
        int               i;
        real_T            *num;
        int               nContStates = ssGetNumContStates(S);
        real_T            *x          = ssGetContStates(S);
        int_T             nCoeffs     = nContStates + 1;
        InputRealPtrsType uPtrs       = ssGetInputPortRealSignalPtrs(S,0);
        real_T            *y          = ssGetOutputPortRealSignal(S,0);
        int_T             *activeBank = ssGetIWork(S);

        /*
         * Switch banks we've updated them in mdlUpdate and we're no longer
         * in a minor time step.
         */
        if (ssIsMajorTimeStep(S)) {
            int_T *banksUpdated = ssGetIWork(S) + 1;
            if (*banksUpdated) {
                *activeBank = !(*activeBank);
                *banksUpdated = 0;
                /*
                 * Need to tell the solvers that the derivatives are no
                 * longer valid.
                 */
                ssSetSolverNeedsReset(S);
            }
        }
        num = ssGetRWork(S) + (*activeBank) * (2*nCoeffs);

        /*
         * The continuous system is evaluated using a controllable state space
         * representation of the transfer function.  This implies that the
         * output of the system is equal to:
         *
         *     y(t) = Cx(t) + Du(t)
         *          = [ b1 b2 ... bn]x(t) + b0u(t)
         *
         * where b0, b1, b2, ... are the coefficients of the numerator 
         * polynomial:
         *
         *    B(s) = b0 s^n + b1 s^n-1 + b2 s^n-2 + ... + bn-1 s + bn
         */
        *y = *num++ * (*uPtrs[0]);
        for (i = 0; i < nContStates; i++) {
            *y += *num++ * *x++;
        }
    }

} /* end mdlOutputs */


#define MDL_UPDATE
/* Function: mdlUpdate ========================================================
 * Abstract:
 *      Every time through the simulation loop, update the
 *      transfer function coefficients. Here we update the oldest bank.
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{
    UNUSED_ARG(tid); /* not used in single tasking mode */

    if (ssIsSampleHit(S, 1, tid)) {
        int_T             i;
        InputRealPtrsType uPtrs        = ssGetInputPortRealSignalPtrs(S,0);
        int_T             uIdx         = 1;/*1st coeff is after signal input*/
        int_T             nContStates  = ssGetNumContStates(S);
        int_T             nCoeffs      = nContStates + 1;
        int_T             bankToUpdate = !ssGetIWork(S)[0];
        real_T            *num         = ssGetRWork(S)+bankToUpdate*2*nCoeffs;
        real_T            *den         = num + nCoeffs;

        real_T            den0;
        int_T             allZero;


        /*
         * Get the first denominator coefficient.  It will be used
         * for normalizing the numerator and denominator coefficients.
         *
         * If all inputs are zero, we probably could have unconnected
         * inputs, so use the parameter as the first denominator coefficient.
         */
        den0 = *uPtrs[uIdx+nCoeffs];
        if (den0 == 0.0) {
            den0 = mxGetPr(DEN(S))[0];
        }

        /*
         * Grab the numerator.
         */
        allZero = 1;
        for (i = 0; (i < nCoeffs) && allZero; i++) {
            allZero &= *uPtrs[uIdx+i] == 0.0;
        }

        if (allZero) { /* if numerator is all zero */
            const real_T *numParam   = mxGetPr(NUM(S));
            int_T        numParamLen = mxGetNumberOfElements(NUM(S));
            /*
             * Move the input to the denominator input and
             * get the denominator from the input parameter.
             */
            uIdx += nCoeffs;
            num += nCoeffs - numParamLen;
            for (i = 0; i < numParamLen; i++) {
                *num++ = *numParam++ / den0;
            }
        } else {
            for (i = 0; i < nCoeffs; i++) {
                *num++ = *uPtrs[uIdx++] / den0;
            }
        }

        /*
         * Grab the denominator.
         */
        allZero = 1;
        for (i = 0; (i < nCoeffs) && allZero; i++) {
            allZero &= *uPtrs[uIdx+i] == 0.0;
        }

        if (allZero) {  /* If denominator is all zero. */
            const real_T *denParam   = mxGetPr(DEN(S));
            int_T        denParamLen = mxGetNumberOfElements(DEN(S));

            den0 = denParam[0];
            for (i = 0; i < denParamLen; i++) {
                *den++ = *denParam++ / den0;
            }
        } else {
            for (i = 0; i < nCoeffs; i++) {
                *den++ = *uPtrs[uIdx++] / den0;
            }
        }

        /*
         * Normalize if this transfer function has direct feedthrough.
         */
        num = ssGetRWork(S) + bankToUpdate*2*nCoeffs;
        den = num + nCoeffs;
        for (i = 1; i < nCoeffs; i++) {
            num[i] -= den[i]*num[0];
        }

        /*
         * Indicate oldest bank has been updated.
         */
        ssGetIWork(S)[1] = 1;
    }

} /* end mdlUpdate */



#define MDL_DERIVATIVES
/* Function: mdlDerivatives ===================================================
 * Abstract:
 *      The drivatives for this block are computed by using a controllable 
 *      state-space representation of the transfer function.
 */
static void mdlDerivatives(SimStruct *S) 
{
    int_T             i;
    int_T             nContStates = ssGetNumContStates(S);
    real_T            *x          = ssGetContStates(S);
    real_T            *dx         = ssGetdX(S);
    int_T             nCoeffs     = nContStates + 1;
    int_T             activeBank  = ssGetIWork(S)[0];
    const real_T      *num        = ssGetRWork(S) + activeBank*(2*nCoeffs);
    const real_T      *den        = num + nCoeffs;
    InputRealPtrsType uPtrs       = ssGetInputPortRealSignalPtrs(S,0);

    /*
     * The continuous system is evaluated using a controllable state-space
     * representation of the transfer function.  This implies that the
     * next continuous states are computed using:
     *
     *     dx = Ax(t) + Bu(t)
     *        = [-a1 -a2 ... -an] [x1(t)] + [u(t)]
     *          [  1  0  ...   0] [x2(t)] + [0]
     *          [  0  1  ...   0] [x3(t)] + [0]
     *          [  .  .  ...   .]   .     +  .
     *          [  .  .  ...   .]   .     +  .
     *          [  .  .  ...   .]   .     +  .
     *          [  0  0  ... 1 0] [xn(t)] + [0]
     *
     * where a1, a2, ... are the coefficients of the numerator polynomial:
     *
     *    A(s) = s^n + a1 s^n-1 + a2 s^n-2 + ... + an-1 s + an
     */
    dx[0] = -den[1] * x[0] + *uPtrs[0];
    for (i = 1; i < nContStates; i++) {
        dx[i] = x[i-1];
        dx[0] -= den[i+1] * x[i];
    }

} /* end mdlDerivatives */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *      Called when the simulation is terminated.
 *      For this block, there are no end of simulation tasks.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */
} /* end mdlTerminate */


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
