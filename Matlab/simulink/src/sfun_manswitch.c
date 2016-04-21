/*
 * File : sfun_manswitch.c
 * Abstract:
 *      S-function manual switch used by manual switch block in Simulink
 *      library.
 *
 * Copyright 1990-2004 The MathWorks, Inc.
 * $Revision: 1.5.4.6 $
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  sfun_manswitch


#include "simstruc.h"


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

    ssSetNumSFcnParams(S, 1);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            ssSetSFcnParamTunable( S, iParam, SS_PRM_TUNABLE );
        }
    }

    if (!ssSetNumInputPorts(S, 0)) return;

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortDataType(  S, 0, SS_BOOLEAN);

    ssSetNumSampleTimes(S, 1);

    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                 SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME |
                 SS_OPTION_NONVOLATILE);
}


/* Function: mdlProcessParameters ===========================================
 * Abstract:
 *      Update run-time parameters.
 */
#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
    ssUpdateDlgParamAsRunTimeParam(S,0);
}


/* Function: mdlSetWorkWidths =============================================
 * Abstract:
 *    Sets the number of runtime parameters.
 */
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S) {
    ssSetNumRunTimeParams(S,1);
    ssRegDlgParamAsRunTimeParam(S,0,0,"P1",SS_BOOLEAN);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T *y = (boolean_T *)ssGetOutputPortSignal(S,0);
    *y = *(boolean_T*)(ssGetRunTimeParamInfo(S,0)->data);
}


/* Function: mdlRTW ==========================================================
 * Abstract:
 *    Writes out the value of switch to the variable P1 in the RTW file.
 */
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    ssWriteRTWParamSettings(S, 1,
                            SSWRITE_VALUE_NUM,
                            "P1",
                            *(boolean_T*)(ssGetRunTimeParamInfo(S,0)->data),1);
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



/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
