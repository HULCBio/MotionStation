/* $Revision: 1.4.4.1 $ $Date: 2004/03/04 20:09:43 $ */
/* xpcdouble2bit.c - xPC Target, inlined S-function for CAN bit-unpacking  */
/* Copyright 1996-2004 The MathWorks, Inc.
*/

//#define debug

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         xpcdouble2bit

#include        <stddef.h>
#include        <stdlib.h>
#include        <stdio.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS          (2)
#define BITFIELD_ARG            ssGetSFcnParam(S,0)
#define DTYPE_ARG               ssGetSFcnParam(S,1)

#define NO_I_WORKS              (0)
#define NO_R_WORKS              (0)


static char_T msg[256];

static const uint32_T  nthBitOne_[32] = {
    0x00000001ul, 0x00000002ul, 0x00000004ul, 0x00000008ul,
    0x00000010ul, 0x00000020ul, 0x00000040ul, 0x00000080ul,
    0x00000100ul, 0x00000200ul, 0x00000400ul, 0x00000800ul,
    0x00001000ul, 0x00002000ul, 0x00004000ul, 0x00008000ul,
    0x00010000ul, 0x00020000ul, 0x00040000ul, 0x00080000ul,
    0x00100000ul, 0x00200000ul, 0x00400000ul, 0x00800000ul,
    0x01000000ul, 0x02000000ul, 0x04000000ul, 0x08000000ul,
    0x10000000ul, 0x20000000ul, 0x40000000ul, 0x80000000ul
};

static  uint32_T lastNBitsZero[32] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

static void mdlInitializeSizes(SimStruct *S) {
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

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, 1);
    ssSetInputPortWidth(             S, 0, 1);
    ssSetInputPortDataType(          S, 0, SS_DOUBLE);
    ssSetInputPortDirectFeedThrough( S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 0, 1);

    ssSetNumOutputPorts(S, mxGetN(DTYPE_ARG));
    for (i=0;i<mxGetN(DTYPE_ARG);i++) {
        ssSetOutputPortWidth(S, i, 1);
        ssSetOutputPortDataType(S, i, (int)mxGetPr(DTYPE_ARG)[i]);
    }

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);

}

static void mdlInitializeSampleTimes(SimStruct *S) {
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S) {
    int i;
    for (i = 0; i < 32; i++)
        lastNBitsZero[i] = 0xFFFFFFFF ^ (nthBitOne_[i] - 1);
}


static void mdlOutputs(SimStruct *S, int_T tid) {
    void               *y;
    const uint32_T     *input;
    uint32_T            output;
    uint16_T            nOutputs, outputPort, chunk, len;
    real_T             *bf = mxGetPr(BITFIELD_ARG);

    input = ssGetInputPortSignal(S,0);

    nOutputs= (uint16_T)mxGetN(DTYPE_ARG);

    for (outputPort = 0; outputPort < nOutputs; outputPort++, bf += len) {
        uint16_T inBit, outBit;
        DTypeId  dType;

        output = 0;
        len = (uint16_T)*bf++;

        for (outBit = 0; outBit < len; outBit++) {
            if ( (int16_T)bf[outBit] == -1 ) continue;
            chunk = ((uint16_T)bf[outBit]) / 32;
            inBit = ((uint16_T)bf[outBit]) % 32;

            if (input[chunk] & nthBitOne_[inBit]) {
                output |= nthBitOne_[outBit];
            }
        }

        dType = ssGetOutputPortDataType(S, outputPort);
        if (dType == SS_INT8 || dType == SS_INT16 || dType == SS_UINT32) {
            if (output & nthBitOne_[len - 1])
                output |= lastNBitsZero[len];
        }

        y = ssGetOutputPortSignal(S,outputPort);

#define CAST__(type, dest, src) ((type *)(dest))[0] = (type)(src)
#define CAST2(slType, cType)       \
   case SS_##slType:               \
     CAST__(cType##_T, y, output); \
     break

        switch (ssGetOutputPortDataType(S,outputPort)) {
            CAST2( INT8,    int8);
            CAST2(UINT8,   uint8);
            CAST2( INT16,   int16);
            CAST2(UINT16,  uint16);
            CAST2( INT32,   int32);
            CAST2(UINT32,  uint32);
            CAST2(BOOLEAN, boolean);
        }
    }
}

#define MDL_RTW
static void mdlRTW(SimStruct *S) {
    const real_T *p = mxGetPr(BITFIELD_ARG);
    int iIdx;
    signed char i, j, limit, length;
    signed char *map, *origMap, *lenVec;
    DTypeId dType;

    /* 64 input bits + 5 columns/row (see below) */
    if ((origMap = malloc(64 * 5)) == NULL) {
        ssSetErrorStatus(S, "Memory Allocation failed\n");
        return;
    }
    if ((lenVec = malloc(sizeof(signed char) *
                         ssGetNumOutputPorts(S))) == NULL) {
        ssSetErrorStatus(S, "Memory Allocation failed\n");
        free(origMap);
        return;
    }

    map  = origMap;

    /* input is a double broken up into two unsigned int's */
    /* We do run-length encoding of sorts: find contiguous regions */
    /**
     * We generate an array with n rows and 5 columns. The first
     * array is a map of inputs to outputs for input chunk 0, and
     * the second for chunk 1.
     *
     * Each row will contain:
     * output port, output offset, length, input chunk, input offset
     */
    for (i = 0; i < ssGetNumOutputPorts(S); i++, p += limit) {
        limit = (signed char)*p++;
        dType = ssGetOutputPortDataType(S, i);
        lenVec[i] = (signed char)limit;
        if (dType == SS_INT8 || dType == SS_INT16 || dType == SS_INT32) {
            lenVec[i] = -lenVec[i];
        }

        length = 0; iIdx = -1;
        for (j = 0; j < limit; j++) {
            if ((signed char)p[j] == -1) {
                if (iIdx != -1) {       /* end of region */
                    map[2] = length;
                    map   += 5;
                    length = 0;
                    iIdx  = -1;
                }
                continue;
            }
#define CHUNK(x)  ((signed char)(x) > (signed char)31)
#define OFFSET(x) ((signed char)(x) & (signed char)31)
            /* p[j] is not -1, so we are either starting a new region
             * or continuing a previous region. */
            if (iIdx == -1) {
                /* Start a new region */
                iIdx   = CHUNK(p[j]);
                map[0] = i;
                map[1] = j;
                map[3] = iIdx;
                map[4] = OFFSET(p[j]);
                length++;
            } else {
                /* Continuing a previous region: hence p[j] is not -1 */
                if (CHUNK( p[j]) == iIdx &&
                    OFFSET(p[j]) == OFFSET(p[j - 1]) + 1)
                    /* inside a contiguous section */
                    length++;
                else {                  /* have quit a contiguous section */
                    /* since both p[j] and p[j - 1] are not -1, but are not
                     * contigous, we are closing a contiguous section and
                     * beginning another. */
                    map[2] = length;
                    map   += 5;
                    length = 1; /* first element of new region */
                    iIdx   = CHUNK(p[j]); /* reset to the next chunk */
                    map[0] = i;
                    map[1] = j;
                    map[3] = iIdx;
                    map[4] = OFFSET(p[j]);
                }
#undef CHUNK
#undef OFFSET
            }
        }
        if (iIdx != -1) {
            map[2] = length;
            map   += 5;
            iIdx   = -1;
            length = 0;
        }
    }
    length = (map - origMap) / 5;
    (void)ssWriteRTWParamSettings(S, 2,
                                  SSWRITE_VALUE_DTYPE_2DMAT, "Map",
                                  origMap, 5, length, DTINFO(SS_INT8, 0),
                                  SSWRITE_VALUE_DTYPE_VECT, "Lengths",
                                  lenVec, ssGetNumOutputPorts(S),
                                  DTINFO(SS_INT8,0));

    free(origMap);
    free(lenVec);
}


static void mdlTerminate(SimStruct *S) {
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
