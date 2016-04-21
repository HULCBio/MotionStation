/* $Revision: 1.4.4.1 $ $Date: 2004/03/04 20:09:42 $ */
/* xpcbit2double.c - xPC Target, inlined S-function for CAN bit-packing */
/* Copyright 1996-2004 The MathWorks, Inc.
*/

//#define debug

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         xpcbit2double

#include        <stddef.h>
#include        <stdlib.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS          (2)
#define BITFIELD_ARG            ssGetSFcnParam(S,0)
#define NINPUTS_ARG             ssGetSFcnParam(S,1)

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

static void mdlInitializeSizes(SimStruct *S)
{

    int_T i;

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }
    ssSetSFcnParamNotTunable(S, 0);
    ssSetSFcnParamNotTunable(S, 1);

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, (int_T)mxGetPr(NINPUTS_ARG)[0]);
    for (i=0;i<(int_T)mxGetPr(NINPUTS_ARG)[0];i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDataType(S, i, DYNAMICALLY_TYPED);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumOutputPorts(S, 1);
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortDataType(S, 0, SS_DOUBLE);

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

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int portIndex, DTypeId dType)
{
    int_T port;
    uint16_T index, maxBits;

    index= 0;
    for (port=0; port < portIndex; port++) {
        index+= (uint16_T)mxGetPr(BITFIELD_ARG)[index]+1;
    }

    switch (dType) {
      case SS_INT8:
        maxBits=8;
        break;
      case SS_UINT8:
        maxBits=8;
        break;
      case SS_INT16:
        maxBits=16;
        break;
      case SS_UINT16:
        maxBits=16;
        break;
      case SS_INT32:
        maxBits=32;
        break;
      case SS_UINT32:
        maxBits=32;
        break;
      case SS_BOOLEAN:
        maxBits=1;
        break;
      default:
        ssSetErrorStatus(S, "Input signal(s) must be one of the types: "
                         "int8, uint8, int16, uint16, int32, uint32, boolean.\n"
                         "Suggest using a data type conversion block "
                         "before the input." );
        return;
        break;
    }

    if (((uint16_T)mxGetPr(BITFIELD_ARG)[index]) > maxBits) {
        sprintf(msg,"More bits specified than input port data type can provide: port %d\n",port);
        ssSetErrorStatus(S,msg);
    }

    index+= (uint16_T)mxGetPr(BITFIELD_ARG)[index]+1;

    ssSetInputPortDataType( S, portIndex, dType);

}

#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int portIndex, DTypeId dType)
{
}


static void mdlOutputs(SimStruct *S, int_T tid) {

    InputPtrsType   uVoidPtrs;
    real_T         *y;
    uint32_T       *output;
    uint16_T       nInputs, inputPort, index, chunk, bitIndex;

    y=ssGetOutputPortSignal(S,0);
    output= (uint32_T *)y;

    nInputs= (uint16_T)mxGetPr(NINPUTS_ARG)[0];

    index= 0;

    output[0]=0ul;
    output[1]=0ul;


    for (inputPort=0; inputPort<nInputs; inputPort++) {

        uVoidPtrs= ssGetInputPortSignalPtrs(S,inputPort);

        switch (ssGetInputPortDataType(S,inputPort)) {

          case SS_INT8:
            {
                const int8_T *uPtr = uVoidPtrs[0];
                uint16_T bitPort;
                for (bitPort=0; bitPort<(uint16_T)mxGetPr(BITFIELD_ARG)[index]; bitPort++) {
                    if ( (uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort] != -1 ) {
                        chunk= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])/32;
                        bitIndex= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])%32;
                        if (*uPtr & (int8_T)nthBitOne_[bitPort]) {
                            output[chunk]|= nthBitOne_[bitIndex];
                        }
                    }
                }
            }
            break;
          case SS_UINT8:
            {
                const uint8_T *uPtr = uVoidPtrs[0];
                uint16_T bitPort;
                for (bitPort=0; bitPort<(uint16_T)mxGetPr(BITFIELD_ARG)[index]; bitPort++) {
                    if ( (uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort] != -1 ) {
                        chunk= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])/32;
                        bitIndex= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])%32;
                        if (*uPtr & (uint8_T)nthBitOne_[bitPort]) {
                            output[chunk]|= nthBitOne_[bitIndex];
                        }
                    }
                }
            }
            break;
          case SS_INT16:
            {
                const int16_T *uPtr = uVoidPtrs[0];
                uint16_T bitPort;
                for (bitPort=0; bitPort<(uint16_T)mxGetPr(BITFIELD_ARG)[index]; bitPort++) {
                    if ( (uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort] != -1 ) {
                        chunk= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])/32;
                        bitIndex= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])%32;
                        if (*uPtr & (int16_T)nthBitOne_[bitPort]) {
                            output[chunk]|= nthBitOne_[bitIndex];
                        }
                    }
                }
            }
            break;
          case SS_UINT16:
            {
                const uint16_T *uPtr = uVoidPtrs[0];
                uint16_T bitPort;
                for (bitPort=0; bitPort<(uint16_T)mxGetPr(BITFIELD_ARG)[index]; bitPort++) {
                    if ( (uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort] != -1 ) {
                        chunk= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])/32;
                        bitIndex= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])%32;
                        if (*uPtr & (uint16_T)nthBitOne_[bitPort]) {
                            output[chunk]|= nthBitOne_[bitIndex];
                        }
                    }
                }
            }
            break;
          case SS_INT32:
            {
                const int32_T *uPtr = uVoidPtrs[0];
                uint16_T bitPort;
                for (bitPort=0; bitPort<(uint16_T)mxGetPr(BITFIELD_ARG)[index]; bitPort++) {
                    if ( (uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort] != -1 ) {
                        chunk= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])/32;
                        bitIndex= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])%32;
                        if (*uPtr & (int32_T)nthBitOne_[bitPort]) {
                            output[chunk]|= nthBitOne_[bitIndex];
                        }
                    }
                }
            }
            break;
          case SS_UINT32:
            {
                const uint32_T *uPtr = uVoidPtrs[0];
                uint16_T bitPort;
                for (bitPort=0; bitPort<(uint16_T)mxGetPr(BITFIELD_ARG)[index]; bitPort++) {
                    if ( (uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort] != -1 ) {
                        chunk= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])/32;
                        bitIndex= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])%32;
                        if (*uPtr & (uint32_T)nthBitOne_[bitPort]) {
                            output[chunk]|= nthBitOne_[bitIndex];
                        }
                    }
                }
            }
            break;
          case SS_BOOLEAN:
            {
                const boolean_T *uPtr = uVoidPtrs[0];
                uint16_T bitPort;
                for (bitPort=0; bitPort<(uint16_T)mxGetPr(BITFIELD_ARG)[index]; bitPort++) {
                    if ( (uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort] != -1 ) {
                        chunk= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])/32;
                        bitIndex= ((uint16_T)mxGetPr(BITFIELD_ARG)[index+1+bitPort])%32;
                        if (*uPtr != 0) {
                            output[chunk]|= nthBitOne_[bitIndex];
                        }
                    }
                }
            }
            break;
        }

        index+= (uint16_T)mxGetPr(BITFIELD_ARG)[index]+1;

    }

}

#define MDL_RTW
static void mdlRTW(SimStruct *S) {
    const real_T *p = mxGetPr(BITFIELD_ARG);
    int oIdx;
    char i, j, limit, length;
    char *map, *origMap;

    /* 64 output bits * 5 columns/row (see below) */
    if ((origMap = malloc(64 * 5)) == NULL) {
        ssSetErrorStatus(S, "Memory Allocation failed\n");
        return;
    }

    map  = origMap;

    /* output is a double broken up into two unsigned int's */
    /* We do run-length encoding of sorts: find contiguous regions */
    /**
     * We generate an array with n rows and 5 columns. The first
     * array is a map of inputs to outputs for output chunk 0, and
     * the second for chunk 1.
     *
     * Each row will contain:
     * output chunk, output offset, length, input port, input offset
     */
    for (i = 0; i < ssGetNumInputPorts(S); i++, p += limit) {
        limit = (int)*p++;
        length = 0; oIdx = -1;
        for (j = 0; j < limit; j++) {
            if ((signed char)p[j] == -1) {
                if (oIdx != -1) {
                    map[2] = length;
                    map   += 5;
                    length = 0;
                    oIdx = -1;
                }
                continue;
            }
#define CHUNK(x)  ((signed char)(x) > (signed char)31)
#define OFFSET(x) ((signed char)(x) & (signed char)31)
            /* p[j] is not -1, so we are either starting a new region
             * or continuing a previous region. */
            if (oIdx == -1) {
                /* Start a new region */
                oIdx  = CHUNK(p[j]);
                map[0] = oIdx;
                map[1] = OFFSET(p[j]);
                map[3] = i;
                map[4] = j;
                length++;
            } else {
                /* Continuing a previous region: hence p[j] is not -1 */
                if (CHUNK( p[j]) == oIdx &&
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
                    oIdx = CHUNK(p[j]); /* reset to the next chunk */
                    map[0] = oIdx;
                    map[1] = OFFSET(p[j]);
                    map[3] = i;
                    map[4] = j;
                }
#undef CHUNK
#undef OFFSET
            }
        }
        if (oIdx != -1) {
            map[2] = length;
            map   += 5;
            oIdx   = -1;
            length = 0;
        }
    }
    length = (map - origMap) / 5;

    (void)ssWriteRTWParamSettings(S, 1,
                                  SSWRITE_VALUE_DTYPE_2DMAT, "Map",
                                  origMap, 5, length, DTINFO(SS_INT8, 0));

    free(origMap);
}

static void mdlTerminate(SimStruct *S) {
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
