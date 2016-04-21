/* $Revision: 1.5.4.1 $ $Date: 2004/04/08 21:03:28 $ */
/* xpcbyte2any.c - xPC Target, inlined S-function driver for *
 *                 byte-unpacking                            */
/* Copyright 1994-2003 The MathWorks, Inc. */

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         xpcbyte2any

#include        <stddef.h>
#include        <stdlib.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (3)
#define OUTPUTS_ARG             ssGetSFcnParam(S, 0)
#define DTYPES_ARG              ssGetSFcnParam(S, 1)
#define BYTEALIGN_ARG           ssGetSFcnParam(S, 2)


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (0)

#define NO_R_WORKS              (0)

#define NO_P_WORKS              (0)

static char_T msg[256];

static int INIT=0;

static int dTypeSizes[] = {8,4,1,1,2,2,4,4,1};
static int alignSizes[] = {1, 2, 4, 8};

static int_T getWidth(SimStruct *S, int_T width);

static void mdlInitializeSizes(SimStruct *S)
{

    int i;

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n"
                "%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetSFcnParamNotTunable(S, 0);
    ssSetSFcnParamNotTunable(S, 1);
    ssSetSFcnParamNotTunable(S, 2);

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, mxGetN(DTYPES_ARG));
    for (i=0; i<mxGetN(DTYPES_ARG);i++) {
        if ((int_T)mxGetPr(OUTPUTS_ARG)[i*2+1]==0) { /* vector */
            if (!ssSetOutputPortVectorDimension(S, i,
                           (int_T)mxGetPr(OUTPUTS_ARG)[i*2])) return;
        } else { /* matrix */
            if (!ssSetOutputPortMatrixDimensions(S, i,
                (int_T)mxGetPr(OUTPUTS_ARG)[i*2],
                (int_T)mxGetPr(OUTPUTS_ARG)[i*2+1])) return;
        }
        ssSetOutputPortDataType(S, i, (int)mxGetPr(DTYPES_ARG)[i]);
    }

    ssSetNumInputPorts(S, 1);
    if (!ssSetInputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    ssSetInputPortDataType(S, 0, SS_UINT8);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 0, 1);

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

    int_T i, totalWidth=0, width;

    if (!ssSetInputPortDimensionInfo(S, portIndex, dimsInfo)) return;

    if (ssGetInputPortNumDimensions(S,0) != 1) {
        ssSetErrorStatus(S,"input signal is not a vector");
        goto EXIT_POINT;
    }

    for (i=0; i<ssGetNumOutputPorts(S); i++) {
        width = ssGetOutputPortWidth(S,i) *
            dTypeSizes[(int_T)mxGetPr(DTYPES_ARG)[i]];
        totalWidth+= getWidth(S, width);
    }
    /* subtract the last one off, width *is* the last value */
    /* totalWidth += width - getWidth(S, width); */
    if (totalWidth != ssGetInputPortWidth(S,0)) {
        ssSetErrorStatus(S,"input signal size does not match output "
                         "structure size");
        goto EXIT_POINT;
    }



 EXIT_POINT:
    return;

}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int portIndex,
                                          const DimsInfo_T *dimsInfo)
{
    if (!ssSetOutputPortDimensionInfo(S, portIndex, dimsInfo)) return;

}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    if (!ssSetInputPortVectorDimension(S, 0, 1)) return;
}

#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int portIndex,
                                     DTypeId dType)
{
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    uint32_T bufferIndex=0;
    uint32_T noBytes;
    int      outputPort;

    for (outputPort=0; outputPort<mxGetN(DTYPES_ARG); outputPort++) {

        noBytes= dTypeSizes[ssGetOutputPortDataType(S,outputPort)] *
            ssGetOutputPortWidth(S,outputPort);

        memcpy((void *)ssGetOutputPortSignal(S, outputPort),
               (void *)((uint8_T *)ssGetInputPortSignal(S,0)+bufferIndex),
               noBytes);
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
        width[i] = dTypeSizes[ssGetOutputPortDataType(S, i)] *
            ssGetOutputPortWidth(S,i);
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

static void mdlTerminate(SimStruct *S)
{
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
