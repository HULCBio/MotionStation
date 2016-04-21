/* $Revision: 1.2 $ */
// dicontecpio3232t.c - xPC Target, non-inlined S-function driver for 
// Digital Input section of Contec PIO-32/32T  
// Copyright 2000-2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   dicontecpio3232t

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

#define NUMBER_OF_ARGS  (5)
#define IO_FORMAT_ARG   ssGetSFcnParam(S,0) // 1:serial, 2:parallel
#define CHANNEL_ARG     ssGetSFcnParam(S,1) // vector of 1-32
#define SAMP_TIME_ARG   ssGetSFcnParam(S,2) // double
#define PCI_BUS_ARG     ssGetSFcnParam(S,3) // integer
#define PCI_SLOT_ARG    ssGetSFcnParam(S,4) // integer

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
    int_T ioFormat = mxGetPr(IO_FORMAT_ARG)[0];

    uint32_T i, j;


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

    switch(ioFormat) {
    case SERIAL:
        ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
        for (i = 0;i < mxGetN(CHANNEL_ARG); i++) {
            ssSetOutputPortWidth(S, i, 1);
        }
        break;
    case PARALLEL:
        ssSetNumOutputPorts(S, 1);
        ssSetOutputPortWidth(S, 0, 1);
        ssSetOutputPortDataType( S, 0, SS_UINT32 );
        break;
    default:
        sprintf(msg,"bad ioFormat %d\n",ioFormat);
        ssSetErrorStatus(S, msg);
        return;
    }


    ssSetNumInputPorts(S, 0);

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

    base = pciInfo.BaseAddress[0];

    IWork[BASE_ADDR_I_IND] = base;
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T   *IWork    = ssGetIWork(S);
    int_T    base     = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T    ioFormat = mxGetPr(IO_FORMAT_ARG)[0];
    uint32_T value    = rl32eInpDW(base);

    int_T     i, chan;
    uint32_T *iPtr;
    real_T   *y; 

    switch(ioFormat) {
    case SERIAL:
        for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
            chan = mxGetPr(CHANNEL_ARG)[i] - 1;
            y = ssGetOutputPortSignal(S, i);
            y[0] = (value & bit[chan]) ? 1.0 : 0.0;
        }
        break;
    case PARALLEL:
        iPtr = ssGetOutputPortSignal(S, 0);
        iPtr[0] = value;
        break;
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
