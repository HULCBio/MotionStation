/*
 * File: sfun_register_can_types.c
 *
 * Abstract:
 *   
 *
 * $Revision: 1.1 $
 * $Date: 2002/10/03 15:26:15 $
 *
 * Copyright 2002 The MathWorks, Inc.
 */

/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function
 * (i.e. replace sfuntmpl_basic with the name of your S-function).
 */

#define S_FUNCTION_NAME sfun_register_can_types
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

/*=============================
 * Externally defined functions
 *=============================*/

/*====================*
 * Defines
 *===================*/

#define P_NPARMS     0


/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{

        int idx;

        /* See sfuntmpl_doc.c for more details on the macros below */

        ssSetNumSFcnParams(S, P_NPARMS);  /* Number of expected parameters */
        // No parameters will be tunable
        for(idx=0; idx<P_NPARMS; idx++){
                ssSetSFcnParamNotTunable(S,idx);
        }

        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
                /* Return if number of expected != number of actual parameters */
                return;
        }


        ssSetNumInputPorts(S,0);

        ssSetNumOutputPorts(S,0);

        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);


        ssSetNumSampleTimes(S, 1);
        ssSetNumRWork(S, 0);
        ssSetNumIWork(S, 0);
        ssSetNumPWork(S, 0);
        ssSetNumModes(S, 0);
        ssSetNumNonsampledZCs(S, 0);

        ssSetOptions(S, SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
        int idx;

        // Just set this to avoid Simulink whinging
        ssSetSampleTime(S, 0, mxGetInf());
        ssSetOffsetTime(S, 0, 0.0);
}

#undef MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
/* Function: mdlStart =======================================================
 * Abstract:
 *    This function is called once at start of model execution. If you
 *    have states that should be initialized once, this is the place
 *    to do it.
 */
static void mdlStart(SimStruct *S)
{
}
#endif /*  MDL_START */



#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */
#define UT(type,element) (*((type *)uPtrs[element])) /* Pointer to Input Port0 */

/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
}

/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}

/*======================================================*
 * See sfuntmpl_doc.c for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
