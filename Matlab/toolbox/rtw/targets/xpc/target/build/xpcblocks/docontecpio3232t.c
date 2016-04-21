/* $Revision: 1.2 $ */
// docontecpio3232t.c - xPC Target, non-inlined S-function driver for 
// Digital Output section of Contec PIO-32/32T  
// Copyright 2000-2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   docontecpio3232t

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h"

#ifdef  MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "pci_xpcimport.h"
#include    "util_xpcimport.h"
#endif

#define NUMBER_OF_ARGS  (7)
#define IO_FORMAT_ARG   ssGetSFcnParam(S,0) // 1:serial, 2:parallel
#define CHANNEL_ARG     ssGetSFcnParam(S,1) // vector of 1-32
#define RESET_ARG       ssGetSFcnParam(S,2) // vector of boolean
#define INIT_VAL_ARG    ssGetSFcnParam(S,3) // vector of double
#define SAMP_TIME_ARG   ssGetSFcnParam(S,4) // double
#define PCI_BUS_ARG     ssGetSFcnParam(S,5) // integer
#define PCI_SLOT_ARG    ssGetSFcnParam(S,6) // integer

#define SAMP_TIME_IND   (0)
#define NO_I_WORKS      (1)
#define BASE_ADDR_I_IND (0)
#define NO_R_WORKS      (0)
#define THRESHOLD       (0.5)

#define VENDOR_ID       (0x1221) // Contec
#define DEVICE_ID       (0x8152) // PIO-32/32T

#define SERIAL          (1)
#define PARALLEL        (2)

static char_T msg[256];

static uint32_T bit[32];

static void mdlInitializeSizes(SimStruct *S)
{
    uint32_T i, j;
    int_T  ioFormat = mxGetPr(IO_FORMAT_ARG)[0];

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    switch (ioFormat) {
    case SERIAL:
        ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
        for (i = 0;i < mxGetN(CHANNEL_ARG); i++) {
            ssSetInputPortWidth(S, i, 1);
            ssSetInputPortDirectFeedThrough(S, i, 1);
        }
        break;
    case PARALLEL:
        ssSetNumInputPorts(S, 1);
        ssSetInputPortWidth(S, 0, 1);
        ssSetInputPortDirectFeedThrough(S, 0, 1);
        ssSetInputPortDataType( S, 0, SS_UINT32 );
        ssSetInputPortRequiredContiguous( S, 0, 1 );
        break;
    default:
        sprintf(msg,"bad ioFormat %d\n",ioFormat);
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumOutputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i = 0; i < NUMBER_OF_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);

    // initialize the bit array
    for (j = 1, i = 0; i < 32; i++) {
        bit[i] = j;
        j <<= 1;
    }
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

    int_T *IWork   = ssGetIWork(S);
    int_T  pciSlot = mxGetPr(PCI_SLOT_ARG)[0];
    int_T  pciBus  = mxGetPr(PCI_BUS_ARG)[0];

    int    base;

    PCIDeviceInfo pciInfo;

    if (pciSlot < 0) {
        if (rl32eGetPCIInfo((uint16_T) VENDOR_ID, 
            (uint16_T) DEVICE_ID, &pciInfo)) {
            sprintf(msg, "No Contec PIO-32/32T found");
            ssSetErrorStatus(S, msg);
            return;
        }
    } 
    else if (rl32eGetPCIInfoAtSlot(VENDOR_ID, DEVICE_ID, 
        pciSlot + pciBus * 256, &pciInfo)) {
        sprintf(msg, "No PIO-32/32T at bus %d slot %d", pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    base = pciInfo.BaseAddress[0] + 4;

    IWork[BASE_ADDR_I_IND] = base;
#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T *IWork    = ssGetIWork(S);
    int_T  base     = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T  ioFormat = mxGetPr(IO_FORMAT_ARG)[0];

    int_T  i, chan;
    uint32_T  value;
    uint32_T *iPtr;
    InputRealPtrsType uPtrs;

    switch(ioFormat) {
    case SERIAL:
        value = ~0;

        for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
            chan = (uchar_T)mxGetPr(CHANNEL_ARG)[i] - 1;
            uPtrs = ssGetInputPortRealSignalPtrs(S, i);
            if (*uPtrs[0] < THRESHOLD)
                value |= bit[chan];  // transistor ON, i.e. low level
            else
                value &= ~bit[chan]; // transistor OFF, i.e. high level
        }
        break;
    case PARALLEL:
        iPtr = (uint32_T *)ssGetInputPortSignal(S, 0);
        value = ~iPtr[0];
        break;
    }
 
    rl32eOutpDW(base, value);
#endif
}


static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T *IWork    = ssGetIWork(S);
    int_T  base     = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T  ioFormat = mxGetPr(IO_FORMAT_ARG)[0];

    int_T  i, chan;
    uint32_T  value;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    value = rl32eInpDW(base);

    switch(ioFormat) {
    case SERIAL:
        for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
            if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
                chan = mxGetPr(CHANNEL_ARG)[i] - 1;
                if ((uint_T)mxGetPr(INIT_VAL_ARG)[i] == 0)
                    value |= bit[chan];   // transistor ON, i.e. low level
                else 
                    value &= ~bit[chan];  // transistor OFF, i.e. high level
            }
        }
        break;
    case PARALLEL:
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[0]) 
            value = ~(uint_T)mxGetPr(INIT_VAL_ARG)[0];
        break;
    }

    rl32eOutpDW(base, value);
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
