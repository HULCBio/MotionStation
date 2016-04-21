/*  File    : sfun_zc_sat.c
 *  Abstract:
 *
 *      Example of an S-function which has nonsampled zero crossings to
 *      implement a saturation function. This S-function is designed to be
 *      used with a variable or fixed step solver.
 *
 *  A saturation is described by three equations
 *
 *    (1)     y = UpperLimit
 *    (2)     y = u
 *    (3)     y = LowerLimit
 *
 *  and a set of inequalities that specify which equation to use
 *
 *    if                          UpperLimit < u    then   use (1)
 *    if       LowerLimit <= u <= UpperLimit        then   use (2)
 *    if   u < LowerLimit                           then   use (3)
 *
 *  A key fact is that the valid equation 1, 2, or 3, can change at
 *  any instant.  Nonsampled zero crossing support helps the variable step
 *  solvers locate the exact instants when behavior switches from one equation
 *  to another.
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.13.4.3 $
 */


#define S_FUNCTION_NAME  sfun_zc_sat
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

/*========================*
 * General Defines/macros *
 *========================*/

/* index to Upper Limit */
#define I_PAR_UPPER_LIMIT 0

/* index to Lower Limit */
#define I_PAR_LOWER_LIMIT 1

/* total number of block parameters */
#define N_PAR                     2

/*
 *  Make access to mxArray pointers for parameters more readable.
 */
#define P_PAR_UPPER_LIMIT  ( ssGetSFcnParam(S,I_PAR_UPPER_LIMIT) )
#define P_PAR_LOWER_LIMIT  ( ssGetSFcnParam(S,I_PAR_LOWER_LIMIT) )
#define     MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)

 
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *   Check that parameter choices are allowable.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      int_T      i;
      int_T      numUpperLimit;
      int_T      numLowerLimit;
      const char *msg = NULL;

      /*
       * check parameter basics
       */
      for ( i = 0; i < N_PAR; i++ ) {
          if ( mxIsEmpty(    ssGetSFcnParam(S,i) ) ||
               mxIsSparse(   ssGetSFcnParam(S,i) ) ||
               mxIsComplex(  ssGetSFcnParam(S,i) ) ||
               !mxIsNumeric( ssGetSFcnParam(S,i) ) ) {
              msg = "Parameters must be real vectors.";
              goto EXIT_POINT;
          }
      }

      /*
       * Check sizes of parameters.
       */
      numUpperLimit = mxGetNumberOfElements( P_PAR_UPPER_LIMIT );
      numLowerLimit = mxGetNumberOfElements( P_PAR_LOWER_LIMIT );

      if ( ( numUpperLimit != 1             ) &&
           ( numLowerLimit != 1             ) &&
           ( numUpperLimit != numLowerLimit ) ) {
          msg = "Number of input and output values must be equal.";
          goto EXIT_POINT;
      }

      /*
       * Error exit point
       */
  EXIT_POINT:
      if (msg != NULL) {
          ssSetErrorStatus(S, msg);
      }
  }
#endif /* MDL_CHECK_PARAMETERS */



/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Initialize the sizes array.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T numUpperLimit, numLowerLimit, maxNumLimit;

    /*
     * Set and Check parameter count
     */
    ssSetNumSFcnParams(S, N_PAR);

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
            ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
        }
    }

    /*
     * Get parameter size info.
     */
    numUpperLimit = mxGetNumberOfElements( P_PAR_UPPER_LIMIT );
    numLowerLimit = mxGetNumberOfElements( P_PAR_LOWER_LIMIT );

    if (numUpperLimit > numLowerLimit) {
        maxNumLimit = numUpperLimit;
    } else {
        maxNumLimit = numLowerLimit;
    }

    /*
     * states
     */
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    /*
     * outputs
     *   The upper and lower limits are scalar expanded
     *   so their size determines the size of the output
     *   only if at least one of them is not scalar.
     */
    if (!ssSetNumOutputPorts(S, 1)) return;

    if ( maxNumLimit > 1 ) {
        ssSetOutputPortWidth(S, 0, maxNumLimit);
    } else {
        ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);
    }

    /*
     * inputs
     *   If the upper or lower limits are not scalar then
     *   the input is set to the same size.  However, the
     *   ssSetOptions below allows the actual width to
     *   be reduced to 1 if needed for scalar expansion.
     */
    if (!ssSetNumInputPorts(S, 1)) return;

    ssSetInputPortDirectFeedThrough(S, 0, 1 );

    if ( maxNumLimit > 1 ) {
        ssSetInputPortWidth(S, 0, maxNumLimit);
    } else {
        ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    }

    /*
     * sample times
     */
    ssSetNumSampleTimes(S, 1);

    /*
     * work
     */
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);


    /*
     * Modes and zero crossings:
     * If we have a variable step solver and this block has a continuous
     * sample time, then
     *   o One mode element will be needed for each scalar output
     *     in order to specify which equation is valid (1), (2), or (3).
     *   o Two ZC elements will be needed for each scalar output
     *     in order to help the solver find the exact instants
     *     at which either of the two possible "equation switches"
     *     One will be for the switch from eq. (1) to (2);
     *     the other will be for eq. (2) to (3) and vise versa.
     * otherwise
     *   o No modes and nonsampled zero crossings will be used.
     *
     */
    ssSetNumModes(S, DYNAMICALLY_SIZED);
    ssSetNumNonsampledZCs(S, DYNAMICALLY_SIZED);

    /*
     * options
     *   o No mexFunctions and no problematic mxFunctions are called
     *     so the exception free code option safely gives faster simulations.
     *   o Scalar expansion of the inputs is desired.  The option provides
     *     this without the need to  write mdlSetOutputPortWidth and
     *     mdlSetInputPortWidth functions.
     */
    ssSetOptions(S, ( SS_OPTION_EXCEPTION_FREE_CODE |
                      SS_OPTION_ALLOW_INPUT_SCALAR_EXPANSION));

} /* end mdlInitializeSizes */



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specify that the block is continuous.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



#define     MDL_SET_WORK_WIDTHS
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
/* Function: mdlSetWorkWidths ===============================================
 *   The width of the Modes and the ZCs depends on the width of the output.
 *   This width is not always known in mdlInitializeSizes so it is handled
 *   here.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
    int nModes;
    int nNonsampledZCs;

    if (ssIsVariableStepSolver(S) &&
        ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME &&
        ssGetOffsetTime(S,0) == 0.0) {

        int numOutput = ssGetOutputPortWidth(S, 0);

        /*
         * modes and zero crossings 
         *    o One mode element will be needed for each scalar output
         *      in order to specify which equation is valid (1), (2), or (3).
         *    o Two ZC elements will be needed for each scalar output
         *      in order to help the solver find the exact instants
         *      at which either of the two possible "equation switches"
         *      One will be for the switch from eq. (1) to (2);
         *      the other will be for eq. (2) to (3) and vise-versa.
         */
        nModes         = numOutput;
        nNonsampledZCs = 2 * numOutput;
    } else {
        nModes         = 0;
        nNonsampledZCs = 0;
    }
    ssSetNumModes(S,nModes);
    ssSetNumNonsampledZCs(S,nNonsampledZCs);
}
#endif /* MDL_SET_WORK_WIDTHS */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *
 *  A saturation is described by three equations
 *
 *    (1)     y = UpperLimit
 *    (2)     y = u
 *    (3)     y = LowerLimit
 *
 *  When this block is used with a fixed-step solver or it has a noncontinuous
 *  sample time, the equations are used as it
 *
 *  Now consider the case of this block being used with a variable step solver
 *  and it has a continusous sample time. Solvers work best on smooth problems.
 *  In order for the solver to work without chattering, limit cycles, or
 *  similar problems.  It is absolutely crucial that the same equation be used
 *  throughout the duration of a MajorTimeStep. To visualize this, consider
 *  the case of the Saturation block feeding an Integrator block.
 *
 *  To implement this rule, the mode vector is used to specify the
 *  valid equation based on the following:
 *
 *    if                          UpperLimit < u    then   use (1)
 *    if       LowerLimit <= u <= UpperLimit        then   use (2)
 *    if   u < LowerLimit                           then   use (3)
 *
 *  The mode vector is changed only at the beginning of a MajorTimeStep.
 *
 *  During a minor time step, the equation specified by the mode vector
 *  is used without question.  Most of the time, the value of u will agree
 *  with the equation specified by the mode vector.  However, sometimes u's
 *  value will indicate a different equation.  Nonetheless, the equation
 *  specified by the mode vector must be used.
 * 
 *  When the mode and u indicate different equations, the corresponding
 *  calculations are not correct.  However, this is not a problem.  From
 *  the ZC function, the solver will know that an equation switch occured
 *  in the middle of the last MajorTimeStep.  The calculations for that
 *  time step will be discarded.  The ZC function will help the solver
 *  find the exact instant at which the switch occured.  Using this knowledge,
 *  the length of the MajorTimeStep will be reduced so that only one equation
 *  is valid throughout the entire time step.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs     = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y        = ssGetOutputPortRealSignal(S,0);
    int_T             numOutput = ssGetOutputPortWidth(S,0);
    int_T             iOutput;

    /*
     * Set index and increment for input signal, upper limit, and lower limit 
     * parameters so that each gives scalar expansion if needed.
     */
    int_T  uIdx          = 0;
    int_T  uInc          = ( ssGetInputPortWidth(S,0) > 1 );
    const real_T *upperLimit   = mxGetPr( P_PAR_UPPER_LIMIT );
    int_T  upperLimitInc = ( mxGetNumberOfElements( P_PAR_UPPER_LIMIT ) > 1 );
    const real_T *lowerLimit   = mxGetPr( P_PAR_LOWER_LIMIT );
    int_T  lowerLimitInc = ( mxGetNumberOfElements( P_PAR_LOWER_LIMIT ) > 1 );

    UNUSED_ARG(tid); /* not used in single tasking mode */

    if (ssGetNumNonsampledZCs(S) == 0) {
        /*
         * This block is being used with a fixed-step solver or it has
         * a noncontinuous sample time, so we always saturate.
         */
        for (iOutput = 0; iOutput < numOutput; iOutput++) {
            if (*uPtrs[uIdx] >= *upperLimit) {
                *y++ = *upperLimit;
            } else if (*uPtrs[uIdx] > *lowerLimit) {
                *y++ = *uPtrs[uIdx];
            } else {
                *y++ = *lowerLimit;
            }

            upperLimit += upperLimitInc;
            lowerLimit += lowerLimitInc;
            uIdx       += uInc;
        }

    } else {
        /*
         * This block is being used with a variable-step solver.
         */
        int_T *mode = ssGetModeVector(S);

        /*
         * Specify indices for each equation.
         */
        enum { UpperLimitEquation, NonLimitEquation, LowerLimitEquation };

        /*
         * Update the Mode Vector ONLY at the beginning of a MajorTimeStep
         */
        if ( ssIsMajorTimeStep(S) ) {
            /*
             * Specify the mode, ie the valid equation for each output scalar.
             */
            for ( iOutput = 0; iOutput < numOutput; iOutput++ ) {
                if ( *uPtrs[uIdx] > *upperLimit ) {
                    /*
                     * Upper limit eq is valid.
                     */
                    mode[iOutput] = UpperLimitEquation;
                } else if ( *uPtrs[uIdx] < *lowerLimit ) {
                    /*
                     * Lower limit eq is valid.
                     */
                    mode[iOutput] = LowerLimitEquation;
                } else {
                    /*
                     * Nonlimit eq is valid.
                     */
                    mode[iOutput] = NonLimitEquation;
                }
                /*
                 * Adjust indices to give scalar expansion if needed.
                 */
                uIdx       += uInc;
                upperLimit += upperLimitInc;
                lowerLimit += lowerLimitInc;
            }

            /*
             * Reset index to input and limits.
             */
            uIdx       = 0;
            upperLimit = mxGetPr( P_PAR_UPPER_LIMIT );
            lowerLimit = mxGetPr( P_PAR_LOWER_LIMIT );

        } /* end IsMajorTimeStep */

        /*
         * For both MinorTimeSteps and MajorTimeSteps calculate each scalar
         * output using the equation specified by the mode vector.
         */
        for ( iOutput = 0; iOutput < numOutput; iOutput++ ) {
            if ( mode[iOutput] == UpperLimitEquation ) {
                /*
                 * Upper limit eq.
                 */
                *y++ = *upperLimit;
            } else if ( mode[iOutput] == LowerLimitEquation ) {
                /*
                 * Lower limit eq.
                 */
                *y++ = *lowerLimit;
            } else {
                /*
                 * Nonlimit eq.
                 */
                *y++ = *uPtrs[uIdx];
            }

            /*
             * Adjust indices to give scalar expansion if needed.
             */
            uIdx       += uInc;
            upperLimit += upperLimitInc;
            lowerLimit += lowerLimitInc;
        }
    }
} /* end mdlOutputs */



#define     MDL_ZERO_CROSSINGS
#if defined(MDL_ZERO_CROSSINGS) && (defined(MATLAB_MEX_FILE) || defined(NRT))

/* Function: mdlZeroCrossings =================================================
 * Abstract:
 *  This will only be called if the number of nonsampled zero crossings is
 *  greater than 0 which means this block has a continuous sample time and the
 *  the model is using a variable step solver.
 *
 *  Calculate zero crossing (ZC) signals that help the solver find the
 *  exact instants at which equation switches occur:
 *
 *    if                          UpperLimit < u    then   use (1)
 *    if       LowerLimit <= u <= UpperLimit        then   use (2)
 *    if   u < LowerLimit                           then   use (3)
 *
 *  The key words are help find. There is no choice of a function that will
 *  direct the solver to the exact instant of the change. The solver will
 *  track the zero crossing signal and do a bisection style search for the
 *  exact instant of equation switch.
 *
 *  There is generally one ZC signal for each pair of signals that can
 *  switch.  The three equations above would broken into two pairs (1)&(2)
 *  and (2)&(3).  The  possibility of a "long jump" from (1) to (3) does
 *  not need to be handled as a separate case.  It is implicitly handled.
 *
 *  When a ZCs are calculated, the value is normally used twice.  When it is
 *  first calculated, it is used as the end of the current time step.  Later,
 *  it will be used as the beginning of the following step.
 *
 *  The sign of the ZC signal always indicates an equation from the pair.  For
 *  S-functions, which equation is associated with a positive ZC and which is
 *  associated with a negative ZC doesn't really matter.  If the ZC is positive
 *  at the beginning and at the end of the time step, this implies that the
 *  "positive" equation was valid throughout the time step.  Likewise, if the
 *  ZC is negative at the beginning and at the end of the time step, this
 *  implies that the "negative" equation was valid throughout the time step.
 *  Like any other nonlinear solver, this is not fool proof, but it is an
 *  excellent indicator.  If the ZC has a different sign at the beginning and
 *  at the end of the time step, then a equation switch definitely occured
 *  during the time step.
 *
 *  Ideally, the ZC signal gives an estimate of when an equation switch
 *  occurred.  For example, if the ZC signal is -2 at the beginning and +6 at
 *  the end, then this suggests that the switch occured 
 *  25% = 100%*(-2)/(-2-(+6)) of the way into the time step.  It will almost
 *  never be true that 25% is perfectly correct.  There is no perfect choice
 *  for a ZC signal, but there are some good rules.  First, choose the ZC
 *  signal to be continuous.  Second, choose the ZC signal to give a monotonic
 *  measure of the "distance" to a signal switch; strictly monotonic is ideal.
 */
static void mdlZeroCrossings(SimStruct *S)
{
    int_T             iOutput;
    int_T             numOutput = ssGetOutputPortWidth(S,0);
    real_T            *zcSignals = ssGetNonsampledZCs(S);
    InputRealPtrsType uPtrs      = ssGetInputPortRealSignalPtrs(S,0);

    /*
     * Set index and increment for the input signal, upper limit, and lower 
     * limit parameters so that each gives scalar expansion if needed.
     */
    int_T  uIdx          = 0;
    int_T  uInc          = ( ssGetInputPortWidth(S,0) > 1 );
    const real_T *upperLimit   = mxGetPr( P_PAR_UPPER_LIMIT );
    int_T  upperLimitInc = ( mxGetNumberOfElements( P_PAR_UPPER_LIMIT ) > 1 );
    const real_T *lowerLimit   = mxGetPr( P_PAR_LOWER_LIMIT );
    int_T  lowerLimitInc = ( mxGetNumberOfElements( P_PAR_LOWER_LIMIT ) > 1 );

    /*
     * For each output scalar, give the solver a measure of "how close things
     * are" to an equation switch.
     */
    for ( iOutput = 0; iOutput < numOutput; iOutput++ ) {

        /*  The switch from eq (1) to eq (2)
         *
         *    if                          UpperLimit < u    then   use (1)
         *    if       LowerLimit <= u <= UpperLimit        then   use (2)
         *
         *  is related to how close u is to UpperLimit.  A ZC choice
         *  that is continuous, strictly monotonic, and is
         *    u - UpperLimit 
         *  or it is negative.
         */
        zcSignals[2*iOutput] = *uPtrs[uIdx] - *upperLimit;

        /*  The switch from eq (2) to eq (3)
         *
         *    if       LowerLimit <= u <= UpperLimit        then   use (2)
         *    if   u < LowerLimit                           then   use (3)
         *
         *  is related to how close u is to LowerLimit.  A ZC choice
         *  that is continuous, strictly monotonic, and is
         *    u - LowerLimit.
         */
        zcSignals[2*iOutput+1] = *uPtrs[uIdx] - *lowerLimit;

        /*
         * Adjust indices to give scalar expansion if needed.
         */
        uIdx       += uInc;
        upperLimit += upperLimitInc;
        lowerLimit += lowerLimitInc;
    }
}

#endif /* end mdlZeroCrossings */



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
