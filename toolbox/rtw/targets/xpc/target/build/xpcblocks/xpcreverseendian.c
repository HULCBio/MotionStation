/* Revision: 1.1$      $Date: 2004/04/08 21:03:31 $ */
/* xpcreverseendian.c: xPC Target, inlined S-Function driver for         *
 *                     switching from little- big-endian and vice versa. */
/* Copyright 1996-2003 The MathWorks, Inc. */

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         xpcreverseendian

#include <assert.h>
#include "simstruc.h"

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif

static char msg[200];

static void swapBytes(void *dest, void *src, int size, int num);
static int_T getDataTypeSize(int_T dTypeId);


/* Input Argument(s) */
#define NUMBER_OF_ARGS      (1)
#define NUM_INPUTS          (ssGetSFcnParam(S, 0))

#define NO_I_WORKS          (0)
#define NO_R_WORKS          (0)
#define NO_P_WORKS          (0)

static void mdlInitializeSizes(SimStruct *S) {
    int numPorts = (int)mxGetPr(NUM_INPUTS)[0];
    int i;
    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n"
                "%d arguments are expected\n", NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }
    ssSetSFcnParamNotTunable(S, 0);
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumInputPorts( S, numPorts);
    ssSetNumOutputPorts(S, numPorts);
    for (i = 0; i < numPorts; i++) {
        if (!ssSetInputPortDimensionInfo( S, i, DYNAMIC_DIMENSION)) return;
        if (!ssSetOutputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
        ssSetInputPortDirectFeedThrough(  S, i, 1);
        ssSetInputPortRequiredContiguous( S, i, 1);
        ssSetInputPortDataType( S, i, DYNAMICALLY_TYPED);
        ssSetOutputPortDataType(S, i, ssGetInputPortDataType(S, i));
    }
    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, NO_P_WORKS);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
    return;
}

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int portIndex,
                                         const DimsInfo_T *dimsInfo)
{
    if (!ssSetInputPortDimensionInfo( S, portIndex, dimsInfo)) return;
    if (!ssSetOutputPortDimensionInfo(S, portIndex, dimsInfo)) return;
    return;
}

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int_T port, DTypeId id) {
    ssSetInputPortDataType(S, port, id);
    ssSetOutputPortDataType(S, port, id);
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

static void mdlInitializeSampleTimes(SimStruct *S) {
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}

/* Data Types should have been set up by now */
#define MDL_START
static void mdlStart(SimStruct *S) {
    int_T  i;

    /* Check the data type sizes */
    for (i = 0; i < ssGetNumInputPorts(S); i++)
        if (getDataTypeSize(ssGetInputPortDataType(S, i)) == -1) {
            sprintf(msg, "Invalid data type for input port %d\n", i);
            ssSetErrorStatus(S, msg);
            return;
        }
    return;
}

static void mdlOutputs(SimStruct *S, int_T tid) {
    int i;
    for (i = 0; i < ssGetNumInputPorts(S); i++) {
        swapBytes(ssGetOutputPortSignal(S, i),
                  (void *)ssGetInputPortSignal( S, i),
                  getDataTypeSize(ssGetInputPortDataType(S, i)),
                  ssGetInputPortWidth(S, i));
    }
    return;
}

static void mdlTerminate(SimStruct *S){}

#define MDL_RTW
static void mdlRTW(SimStruct *S) {
    int *width[4];
    int howMany[4] = {0, 0, 0, 0};
    int i, n;

    n = ssGetNumInputPorts(S);
    if ((width[0] = calloc(n * 4, sizeof(int))) == NULL) {
        ssSetErrorStatus(S, "Memory allocation error\n");
        return;
    }
    width[1] = width[0] + n;
    width[2] = width[1] + n;
    width[3] = width[2] + n;

    /* Collect ports of datatype width (1,2,4,8) into width[0,1,2,3] */
    for (i = 0; i < n; i++) {
        switch(getDataTypeSize(ssGetInputPortDataType(S, i))) {
          case 1:
            width[0][howMany[0]++] = i; break;
          case 2:
            width[1][howMany[1]++] = i; break;
          case 4:
            width[2][howMany[2]++] = i; break;
          case 8:
            width[3][howMany[3]++] = i; break;
          default:
            ssSetErrorStatus(S, "Invalid data type\n");
            free(width[0]);
            return;
        }
    }
    (void)ssWriteRTWParamSettings(S, 4,
                                  SSWRITE_VALUE_DTYPE_VECT, "Width1Input",
                                  width[0], howMany[0], DTINFO(SS_INT32, 0),
                                  SSWRITE_VALUE_DTYPE_VECT, "Width2Input",
                                  width[1], howMany[1], DTINFO(SS_INT32, 0),
                                  SSWRITE_VALUE_DTYPE_VECT, "Width4Input",
                                  width[2], howMany[2], DTINFO(SS_INT32, 0),
                                  SSWRITE_VALUE_DTYPE_VECT, "Width8Input",
                                  width[3], howMany[3], DTINFO(SS_INT32, 0));
    free(width[0]);
}

/* ======================================================================= *
 *                             Helper functions                            *
 * ========================================================================*/

static int_T getDataTypeSize(int_T dTypeId) {
    int_T dtSize;
    char  errMsg[100];
    switch(dTypeId) {
      case SS_DOUBLE:
        dtSize = sizeof(real_T   );
        break;
      case SS_SINGLE:
        dtSize = sizeof(real32_T );
        break;
      case SS_INT8:
        dtSize = sizeof(int8_T   );
        break;
      case SS_UINT8:
        dtSize = sizeof(uint8_T  );
        break;
      case SS_INT16:
        dtSize = sizeof(int16_T  );
        break;
      case SS_UINT16:
        dtSize = sizeof(uint16_T );
        break;
      case SS_INT32:
        dtSize = sizeof(int32_T  );
        break;
      case SS_UINT32:
        dtSize = sizeof(uint32_T );
        break;
      case SS_BOOLEAN:
        dtSize = sizeof(boolean_T);
        break;
      default:
        dtSize = -1;
    }
    return dtSize;
}

static void swapBytes(void *dest, void *src, int size, int num) {
    uint8_T *dest1, *src1, tmp, i, size1;

    assert(src != dest);
    dest1 = dest;
    src1  = src;

    if (size == 1) {
        memcpy(dest1, src1, num);
        return;
    }
    while (num--) {
        for (i = 0; i < size; i++)
            dest1[i] = src1[size-i-1];
        dest1 += size;
        src1  += size;
    }
    return;
}


#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
