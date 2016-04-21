/* $Revision: 1.3.4.1 $ */

// dicontecadx.c - xPC Target, non-inlined S-function driver for the 
// digital input section of Contec AD12-16(PCI) and AD12-64(PCI) boards
// Copyright 1996-2003 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   dicontecadx

#include "simstruc.h" 

#ifdef  MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "pci_xpcimport.h"
#include    "util_xpcimport.h"
#endif

#define NUM_ARGS        5
#define CHANNEL_ARG     ssGetSFcnParam(S,0) // vector of 1:4
#define SAMP_TIME_ARG   ssGetSFcnParam(S,1) // seconds
#define PCI_BUS_ARG     ssGetSFcnParam(S,2) // integer
#define PCI_SLOT_ARG    ssGetSFcnParam(S,3) // integer
#define DEVICE_ARG      ssGetSFcnParam(S,4) // integer

#define VENDOR_ID       (0x1221) // Contec
#define SAMP_TIME_IND   (0)
#define NUM_I_WORKS     (1)
#define BASE_ADDR_I_IND (0)
#define NUM_R_WORKS     (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i;

#ifndef MATLAB_MEX_FILE
#include    "io_xpcimport.c"
#include    "pci_xpcimport.c"
#include    "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg, "%d input args expected, %d passed", NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumInputPorts(S, 0);

    ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
    for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i = 0; i < NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (mxGetPr(SAMP_TIME_ARG)[0] == -1.0) {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    } else {
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
        ssSetOffsetTime(S, 0, 0.0);
    }
}

#define MDL_START 
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T  *IWork    = ssGetIWork(S);
    int_T   pciSlot  = mxGetPr(PCI_SLOT_ARG)[0];
    int_T   pciBus   = mxGetPr(PCI_BUS_ARG)[0];
    int_T   device   = mxGetPr(DEVICE_ARG)[0];

    int_T  base, deviceId;
    PCIDeviceInfo pciInfo;
    char_T  deviceName[40];

    switch (device) {
        case 1: {
            deviceId = 0x8153;
            sprintf(deviceName, "Contec AD12-16(PCI)");
            break;
        }
        case 2: {
            deviceId = 0x8143;
            sprintf(deviceName, "Contec AD12-64(PCI)");
            break;
        }
        default: {
            sprintf(msg, "Unsupported device %d", device);
            ssSetErrorStatus(S, msg);
            return;
        }
    }

    if (pciSlot < 0) {
        if (rl32eGetPCIInfo((uint16_T) VENDOR_ID, 
            (uint16_T) deviceId, &pciInfo)) {
            sprintf(msg, "No %s found", deviceName);
            ssSetErrorStatus(S, msg);
            return;
        }
    } 
    else if (rl32eGetPCIInfoAtSlot((uint16_T)VENDOR_ID, (uint16_T)deviceId, 
        pciSlot + pciBus * 256, &pciInfo)) {
        sprintf(msg, "No %s at bus %d slot %d", deviceName, pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    base = pciInfo.BaseAddress[0];
    IWork[BASE_ADDR_I_IND] = base;
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T  *IWork  = ssGetIWork(S);
    int_T   nChans = mxGetN(CHANNEL_ARG);
    int_T   base   = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T   value  = rl32eInpB(base + 5);
    int_T   bit[4] = {1, 2, 4, 8};
    int_T   i, chan;
    real_T *y;

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        y = ssGetOutputPortSignal(S, i);
        y[0] = (value & bit[chan]) ? 1.0 : 0.0;
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif




