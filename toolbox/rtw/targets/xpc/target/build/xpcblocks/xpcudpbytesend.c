/* $Revision: 1.5.2.1 $ $Date: 2003/11/20 11:58:07 $ */
/* xpcupdbytesend.c - xPC Target, non-inlined S-function driver for
 *                    sending UDP packets
 */
/* Copyright 1994-2003 The MathWorks, Inc. */

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         xpcudpbytesend

#include        <stddef.h>
#include        <stdlib.h>
#include        "simstruc.h"
#include        <math.h>


#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

#ifdef  MATLAB_MEX_FILE
#include "host/udpcom.c"
#else
#include        <windows.h>
#include        "udp_xpcimport.h"
#include        "util_xpcimport.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (4)
#define IP_ADDRESS_ARG          ssGetSFcnParam(S,0)
#define IP_PORT_ARG             ssGetSFcnParam(S,1)
#define LOCAL_PORT_ARG          ssGetSFcnParam(S,2)
#define SAMPLE_TIME_ARG         ssGetSFcnParam(S,3)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)

#define NO_R_WORKS              (0)

#define NO_P_WORKS              (1)

static char_T msg[256];

static int INIT = 0;

static void mdlInitializeSizes(SimStruct * S) {
    int i;

#ifndef MATLAB_MEX_FILE
#include "udp_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg, "Wrong number of input arguments passed.\n"
                "%d arguments are expected\n", NUMBER_OF_ARGS);
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, 0);

    ssSetNumInputPorts(S, 1);
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
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

static void mdlInitializeSampleTimes(SimStruct *S) {
    ssSetSampleTime(S, 0, mxGetPr(SAMPLE_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int portIndex, int inWidth) {
    ssSetInputPortWidth(S, portIndex, inWidth);
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int portIndex, int outWidth) {
    ssSetOutputPortWidth(S, portIndex, outWidth);
}

#define MDL_SET_DEFAULT_PORT_WIDTH
static void mdlSetDefaultPortWidth(SimStruct *S) {
    ssSetInputPortWidth(S, 0, 1);
}


#define MDL_START
static void mdlStart(SimStruct *S) {
    uchar_T ipAddress[16];
    int_T ipPort, noBytes, id;
    uint8_T *buffer;
    int_T broadcast;
    int_T localPort;

    noBytes = ssGetInputPortWidth(S, 0);

    // alloc memory and store pointer
    buffer = (uint8_T *) calloc(noBytes, sizeof(uint8_T));
    if (buffer == NULL) {
        sprintf(msg, "Error in udpcharsend: memory allocation failed");
        ssSetErrorStatus(S, msg);
        return;
    }
    ssSetPWorkValue(S, 0, (void *)buffer);

    // initialize buffer with zeros
    memset((void *)buffer, 0, noBytes * sizeof(uint8_T));

    mxGetString(IP_ADDRESS_ARG, ipAddress, 16);
    ipPort = (int_T) mxGetPr(IP_PORT_ARG)[0];

    id = 0;

    broadcast = !strcmp(ipAddress, "255.255.255.255");
    localPort = (int_T)mxGetPr(LOCAL_PORT_ARG)[0];
    localPort = localPort < 0 ? -1 : (int)(uint16_T)localPort;
#ifdef MATLAB_MEX_FILE
    id = udpOpenSend(ipAddress, localPort, ipPort, broadcast, noBytes);
#else
    if (!xpceIsModelInit())
        id = xpceUDPOpenSend(ipAddress, localPort, ipPort, broadcast, noBytes);
#endif

    if (id < 0) {
        sprintf(msg, "Error: No udp Channel free or udp error");
        ssSetErrorStatus(S, msg);
    }

    ssSetIWorkValue(S, 0, id);
    ssSetIWorkValue(S, 1, noBytes);
}

static void mdlOutputs(SimStruct *S, int_T tid) {
    uint8_T *buffer;
    int_T id, noBytes, count;
    InputRealPtrsType uPtrs;

    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);

    buffer = (uint8_T *)ssGetPWorkValue(S, 0);
    id = ssGetIWorkValue(S, 0);
    noBytes = ssGetIWorkValue(S, 1);

    memcpy((void *)((uint8_T *) buffer),
           (void *)ssGetInputPortSignal(S, 0),
           noBytes);

#ifdef MATLAB_MEX_FILE
    count = udpSend(id, buffer, noBytes);
#else
    count = xpceUDPSend(id, buffer, noBytes);
#endif
}

static void mdlTerminate(SimStruct *S) {
    void *buffer = ssGetPWorkValue(S, 0);
    int id       = ssGetIWorkValue(S, 0);

#ifdef MATLAB_MEX_FILE
    udpClose(id);
#else
    if (!xpceIsModelInit())
        xpceUDPClose(id);

#endif
    if (buffer != NULL) {
        free(buffer);
    }
}

#ifdef MATLAB_MEX_FILE     /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* Mex glue */
#else
#include "cg_sfun.h"       /* Code generation glue */
#endif
