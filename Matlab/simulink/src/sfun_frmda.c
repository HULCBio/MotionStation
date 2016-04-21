/*
 * File : sfun_frmda.c
 * Abstract:
 *    An example of a frame-based D/A converter. During simulation,
 *    this S-function is simply a place-holder. The TLC file
 *    is a place-holder for adding actual code for a 
 *    frame-based D/A converter.
 *
 * Copyright 1990-2004 The MathWorks, Inc.
 * $Revision: 1.7.4.2 $
 */
#define S_FUNCTION_NAME sfun_frmda
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include <string.h>
#include <math.h>
#include "simstruc.h"

enum {INPORT=0, NUM_INPORTS};
enum {NUM_OUTPORTS};

/* Parameters */
enum {NUM_ARGS = 0};

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    
    ssSetNumSampleTimes(S, 1);

    /* Set input */
    ssSetInputPortFrameData(         S, INPORT, FRAME_YES);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_NO);
    ssSetInputPortMatrixDimensions(  S ,INPORT, DYNAMICALLY_SIZED, DYNAMICALLY_SIZED);
    ssSetInputPortSampleTime(        S, INPORT, INHERITED_SAMPLE_TIME);
    ssSetInputPortRequiredContiguous(S, INPORT, 1); 
    ssSetInputPortOverWritable(      S, INPORT, 0);

    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE);
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *dimsInfo)
{
    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
}
#endif

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
}
#endif

#if defined(MATLAB_MEX_FILE)
#define MDL_RTW
/* Function: mdlRTW ===========================================================
 * Abstract:
 */
static void mdlRTW(SimStruct *S)
{
}
#endif /* MDL_RTW */

#ifdef	MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif


/* [EOF] sfun_frmda.c */

