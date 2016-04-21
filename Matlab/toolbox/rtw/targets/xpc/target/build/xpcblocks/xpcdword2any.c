/* xpcdword2any.c - xPC Target, non-inlined S-function driver for
 *                  unpacking multiple signals from a single uint32
 *                  vector.
 *
 * Copyright 1994-2004 The MathWorks, Inc.
 * $Revision: 1.2.4.2 $ $Date: 2004/04/08 21:03:29 $
 *
 * Revision history
 *  12/30/03 - (ADowd) Changed API to use parameter Address in place 
 *             of Alignment. 
 *
 *  See also xpcany2dword
 */


#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         xpcdword2any

#include        <stddef.h>
#include        <stdlib.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (4)
#define ITYPES_ARG             ssGetSFcnParam(S, 0)  
#define ISIZE_ARG              ssGetSFcnParam(S, 1)
#define IADDRESS_ARG           ssGetSFcnParam(S, 2)
#define SIZEOF_ARG             ssGetSFcnParam(S, 3)

//  Description of parameters
//  All parameters (except sizeof) describe the type,size,etc of the
//    input ports this block will grow (one port per entry in ITYPE vector).  
//    All data from the input ports will  be combined to a vector of dwords 
//    (32 bits) of type uint32.
//
//   
//  IType - Integer which declares signal type
//   Type        Bytes   IType
//   'double'     8       1
//   'single'     4       2
//   'int8'       1       3
//   'uint8'      1       4
//   'int16'      2       5
//   'uint16'     2       6
//   'int32'      4       7
//   'uint32'     4       8
//   'boolean'    1       9
//   
//  ISize - Size of each segment.  Equivalent to >size(foo).  This should be a
//    a matrix of size [2 N], with one column per port.  For example: 
//   >ISize = [[3; 2] [5; 6] [5; 0]];
//    where first port is a matrix of size (3,2).  The third port is vector 
//     with 5 elements.
//
//  IAddress - Address of each segement.  Note, segement addresses are always
//   relative from the first address in this vector.  Thus IAddress = [10 20] will
//   produce identical results to IAddress = [0 10].
//
//  Sizeof - Total Byte size.  Unlike the rest of the parameters, this is a
//   scalar value.  It describes the combined byte size of all ports.  This 
//   must be a multiple of 4, since it defines the number of uint32 vectors 
//   in the output signal.  
//  
//  Note - if sizeof is wrong, some output data will be read from random memory locations
//
//
#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (0)
#define NO_R_WORKS              (0)
#define NO_P_WORKS              (0)

static char_T msg[256];

static int INIT=0;

static int dTypeSizes[] = {8,4,1,1,2,2,4,4,1};
static int alignSizes[] = {1, 2, 4, 8};

static void mdlInitializeSizes(SimStruct *S)
{

    int_T i;


    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n"
                "%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);


	ssSetNumOutputPorts(S, mxGetN(ITYPES_ARG));
    for (i=0; i<mxGetN(ITYPES_ARG); i++) {
		if ((int_T)mxGetPr(ISIZE_ARG)[i*2+1]==0) { /* vector */
        	if (!ssSetOutputPortVectorDimension(S, i, (int_T)mxGetPr(ISIZE_ARG)[i*2])) return;
        } else { /* matrix */
            if (!ssSetOutputPortMatrixDimensions(S, i, (int_T)mxGetPr(ISIZE_ARG)[i*2], (int_T)mxGetPr(ISIZE_ARG)[i*2+1])) return;
        }
        ssSetOutputPortDataType(S, i, (int_T)mxGetPr(ITYPES_ARG)[i]);
    }

    ssSetNumInputPorts(S, 1);
    ssSetInputPortWidth(S, 0, (int_T)mxGetPr(SIZEOF_ARG)[0]>>2);  // Convert bytesize to wordsize
    ssSetInputPortDataType(S, 0, SS_UINT32);
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

static void mdlOutputs(SimStruct *S, int_T tid)
{
    uint32_T  bufferstart = (uint32_T)mxGetPr(IADDRESS_ARG)[0];  // Set offset
    uint32_T  bufoffset;
    int       outputPort;
    uint32_T  noBytes;

    for (outputPort=0; outputPort<mxGetN(ITYPES_ARG); outputPort++) {
        bufoffset = (uint32_T)mxGetPr(IADDRESS_ARG)[outputPort] - bufferstart;
        noBytes= dTypeSizes[ssGetOutputPortDataType(S,outputPort)] *
            ssGetOutputPortWidth(S,outputPort);

        memcpy((void *)ssGetOutputPortSignal(S, outputPort),
               (void *)((uint8_T *)ssGetInputPortSignal(S,0)+bufoffset),
               noBytes);

    }
}

static void mdlTerminate(SimStruct *S)
{
}


#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
