/* $Revision: 1.6.4.1 $ $Date: 2004/04/08 21:03:26 $ */
/* xpcany2byte.c - xPC Target, inlined S-function driver for *
 *                 byte-packing                              */
/* Copyright 1994-2003 The MathWorks, Inc. */

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         xpcany2byte

#include        <stddef.h>
#include        <stdlib.h>

#include        "simstruc.h"
#include        <math.h>

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (2)
#define DTYPES_ARG              ssGetSFcnParam(S, 0)
#define BYTEALIGN_ARG           ssGetSFcnParam(S, 1)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (0)

#define NO_R_WORKS              (0)

#define NO_P_WORKS              (0)

static char_T msg[256];

/* static int flag=0; */

static int INIT=0;

static int dTypeSizes[] = {8,4,1,1,2,2,4,4,1};
static int alignSizes[]  = {1,2,4,8};

static int_T getWidth(SimStruct *S, int_T width);

static void mdlInitializeSizes(SimStruct *S)
{

    int i;

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n"
                "%d arguments are expected\n", NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }
    ssSetSFcnParamNotTunable(S, 0);
    ssSetSFcnParamNotTunable(S, 1);

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    /* ssSetNumInputPorts(S, mxGetN(DTYPES_ARG)); */
    ssSetNumInputPorts(S, mxGetN(DTYPES_ARG));
    for (i=0; i<mxGetN(DTYPES_ARG); i++) {
        if (!ssSetInputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
        ssSetInputPortDataType(S, i, (int_T)mxGetPr(DTYPES_ARG)[i]);
        ssSetInputPortDirectFeedThrough(S, i, 1);
        ssSetInputPortRequiredContiguous(S, i, 1);
    }

    ssSetNumOutputPorts(S, 1);
    if (!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortDataType(S, 0, SS_UINT8);


    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, NO_P_WORKS);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);

}



static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int portIndex,
                                         const DimsInfo_T *dimsInfo)
{
    int_T i, width, totalWidth=0;

    if (!ssSetInputPortDimensionInfo(S, portIndex, dimsInfo)) return;

    for (i=0; i<ssGetNumInputPorts(S); i++) {
        if (ssGetInputPortWidth(S,i)==DYNAMICALLY_SIZED) {
            goto EXIT_POINT;
        } else {
            width = ssGetInputPortWidth(S,i) *
                dTypeSizes[(int_T)mxGetPr(DTYPES_ARG)[i]];
            totalWidth += getWidth(S, width);
        }
    }
    /* subtract the last one off, width *is* the last value */
    /* totalWidth += width - getWidth(S, width); */

    if (!ssSetOutputPortVectorDimension(S, 0, totalWidth)) return;

 EXIT_POINT:
    return;

}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int portIndex,
                                          const DimsInfo_T *dimsInfo)
{
    int_T i;

    for (i=0; i<ssGetNumInputPorts(S); i++) {
        if (ssGetInputPortWidth(S,i)==DYNAMICALLY_SIZED) {
            ssSetErrorStatus(S,"backward propagation not supported");
            goto EXIT_POINT;
        }
    }

    if (!ssSetOutputPortDimensionInfo(S, portIndex, dimsInfo)) return;

 EXIT_POINT:
    return;
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    int_T i;

    for (i=0;i<mxGetN(DTYPES_ARG);i++) {
        if (!ssSetInputPortVectorDimension(S, i, 1)) return;
    }
        if (!ssSetOutputPortVectorDimension(S, 0, 1)) return;

}



static void mdlOutputs(SimStruct *S, int_T tid)
{

    uint32_T bufferIndex=0;
    int      inputPort;
    uint32_T noBytes;

    for (inputPort=0; inputPort<mxGetN(DTYPES_ARG); inputPort++) {
        noBytes = dTypeSizes[ssGetInputPortDataType(S,inputPort)] *
            ssGetInputPortWidth(S,inputPort);

        memcpy((void *)((uint8_T *)ssGetOutputPortSignal(S, 0)+bufferIndex),
               (void *)ssGetInputPortSignal(S,inputPort), noBytes);
        bufferIndex+= getWidth(S, noBytes);

    }

}

#define MDL_RTW
static void mdlRTW(SimStruct *S) {
    int n = mxGetN(DTYPES_ARG);
    int i;
    int *width, *offset;

    /* Width is how many bytes to copy, Offset takes care of alignment for
     * the next one.
     */
    if ((width  = calloc(n, sizeof(int))) == NULL ||
        (offset = calloc(n, sizeof(int))) == NULL) {
        free(width);        /* in ANSI C, passing NULL to free is safe. */
        free(offset);
        ssSetErrorStatus(S, "Memory allocation error\n");
        return;
    }
    offset[0] = 0;
    for (i = 0; i < n; i++) {
        width[i] = dTypeSizes[ssGetInputPortDataType(S, i)] *
            ssGetInputPortWidth(S,i);
        if (i > 0)
            offset[i] = offset[i - 1] + getWidth(S, width[i - 1]);
    }
    (void)ssWriteRTWParamSettings(S, 2,
                                  SSWRITE_VALUE_DTYPE_VECT, "Width",
                                  width, n, DTINFO(SS_INT32, 0),
                                  SSWRITE_VALUE_DTYPE_VECT, "Offset",
                                  offset, n, DTINFO(SS_INT32, 0));
    free(width);
    free(offset);
    return;

}

static void mdlTerminate(SimStruct *S) {
}

static int_T getWidth(SimStruct *S, int_T width) {
    int_T rem, align;

    align = alignSizes[(int)(mxGetPr(BYTEALIGN_ARG)[0]) - 1];
    return (width + ((rem = width % align) ? align - rem : 0));
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
