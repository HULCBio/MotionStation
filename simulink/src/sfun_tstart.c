/*
 * File : sfun_tstart.c
 * Abstract:
 *      S-function start time used by the repeating sequence and chirp
 *      blocks in Simulink.
 *
 * Copyright 1990-2004 The MathWorks, Inc.
 * $Revision: 1.3.4.2 $
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  sfun_tstart


#include "simstruc.h"


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{

    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    if (!ssSetNumInputPorts(S, 0)) return;

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortDataType(S, 0, SS_DOUBLE);  /* same as clock block */
    ssSetOutputPortConstOutputExprInRTW(S, 0, 1);

    ssSetNumSampleTimes(S, 1);

    ssSetOptions(S, 
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Set a constant sample time.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


/* Function: mdlStart =========================================================
 * Abstract:
 *    Initialize output value to the start time.
 */
#define MDL_START
static void mdlStart(SimStruct *S)
{
    real_T *y = (real_T *)ssGetOutputPortSignal(S,0);
    *y = ssGetTStart(S);
}


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    The simulation start time was put into the output memory in 
 *    mdlStart() so nothing else needs to be done here.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* start time set in mdlStart, never changes */
}



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    (not used)
 */
static void mdlTerminate(SimStruct *S)
{
}



/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
