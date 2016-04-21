/*  File    : sfun_fcncall.c
 *  Abstract:
 *
 *      Example of an S-function which is configure to execute 
 *      "function-call" subsystems on the 1st and 3rd output element of
 *      the output port. Note when performing function-calls, these
 *      can only be done through the 1st output port.
 *
 *      For more details about S-functions, see src/simulink/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.15.4.2 $
 */

#define S_FUNCTION_NAME  sfun_fcncall
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 1);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    
    if (!ssSetNumOutputPorts(S,2)) return;
    ssSetOutputPortWidth(S, 0, 2);
    ssSetOutputPortWidth(S, 1, 1);

    ssSetNumSampleTimes(   S, 1);
    ssSetNumRWork(         S, 0);
    ssSetNumIWork(         S, 0);
    ssSetNumPWork(         S, 0);
    ssSetNumModes(         S, 0);
    ssSetNumNonsampledZCs( S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Discrete sample time of 0.1 seconds and specify that we are doing
 *    function-call's on the 1st and 3rd element.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, 0.1);
    ssSetOffsetTime(S, 0, 0.0);
    
    ssSetCallSystemOutput(S,0);  /* call on first element */
    ssSetCallSystemOutput(S,1);  /* call on second element */
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    Issue ssCallSystemWithTid on 1st or 3rd output element and then update
 *    2nd output element with the state.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T            *x    = ssGetRealDiscStates(S);
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y    = ssGetOutputPortRealSignal(S,1);

    /*
     * ssCallSystemWithTid is used to execute a function-call subsystem. The
     * 2nd argument is the element of the 1st output port index which
     * connected to the function-call subsystem. Function-call subsystems
     * can be driven by the first output port of s-function blocks.
     */
    
    UNUSED_ARG(tid); /* not used in single tasking mode */

    if (((int)*uPtrs[0]) % 2 == 1) {
        if (!ssCallSystemWithTid(S,0,tid)) {
            /* Error occurred which will be reported by Simulink */
            return;
        }
    } else {
        if (!ssCallSystemWithTid(S,1,tid)) {
            /* Error occurred which will be reported by Simulink */
            return;
        }
    }
    y[0] = x[0]; 
}


/* Function: mdlUpdate ========================================================
 * Abstract:
 *    Increment the state for next time around (i.e. a counter).
 */
#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid)
{
    real_T *x = ssGetRealDiscStates(S);    

    UNUSED_ARG(tid); /* not used in single tasking mode */

    x[0]++;
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
