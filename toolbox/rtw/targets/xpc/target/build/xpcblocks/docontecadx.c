/* $Revision: 1.2 $ */
// docontecadx.c - xPC Target, non-inlined S-function driver for the 
// digital output section of Contec AD12-16(PCI) and AD12-64(PCI) boards
// Copyright 1996-2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   docontecadx

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

#define NUM_ARGS        (7)
#define CHANNEL_ARG     ssGetSFcnParam(S,0) // vector of 1:4
#define RESET_ARG       ssGetSFcnParam(S,1) // vector of 0:1
#define INIT_VAL_ARG    ssGetSFcnParam(S,2) // vector of 0:1
#define SAMP_TIME_ARG   ssGetSFcnParam(S,3) // seconds
#define PCI_BUS_ARG     ssGetSFcnParam(S,4) // integer
#define PCI_SLOT_ARG    ssGetSFcnParam(S,5) // integer
#define DEVICE_ARG      ssGetSFcnParam(S,6) // integer

#define VENDOR_ID       (0x1221) // Contec
#define SAMP_TIME_IND   (0)
#define NUM_I_WORKS     (2)
#define BASE_ADDR_I_IND (0)
#define VALUE_I_IND     (1)
#define NUM_R_WORKS     (0)
#define THRESHOLD       (0.5)

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
    ssSetNumOutputPorts(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i = 0;i < mxGetN(CHANNEL_ARG); i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
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

    PCIDeviceInfo pciInfo;
    int_T  base, deviceId;
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
    int_T   bit[4] = {1, 2, 4, 8};
    uint8_T value  = 0;
    
    int_T   i, chan;
    InputRealPtrsType uPtrs;

    for (i = 0; i < nChans; i++) {
        chan = (int_T)mxGetPr(CHANNEL_ARG)[i] - 1;
        uPtrs = ssGetInputPortRealSignalPtrs(S, i);
        if (*uPtrs[0] < THRESHOLD)
            value &= ~bit[chan]; 
        else
            value |= bit[chan];  
    }
    
    rl32eOutpB(base + 5, value);
    IWork[VALUE_I_IND] = value;
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T  *IWork  = ssGetIWork(S);
    int_T   nChans = mxGetN(CHANNEL_ARG);
    int_T   base   = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T   value  = ssGetIWorkValue(S, VALUE_I_IND);
    int_T   bit[4] = {1, 2, 4, 8};
    
    int_T   i, chan;
    InputRealPtrsType uPtrs;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    for (i = 0; i < nChans; i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            chan = (int_T)mxGetPr(CHANNEL_ARG)[i] - 1;
            if ((uint_T)mxGetPr(INIT_VAL_ARG)[i] == 0)
                value &= ~bit[chan]; 
            else
                value |= bit[chan];  
        }
    }

    rl32eOutpB(base + 5, value);
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif




