// diquanserq8.c - xPC Target, non-inlined S-function driver for the
// digital input section of the Quanser Q8 Data Acquisition System

// Copyright 2003 The MathWorks, Inc.

#define S_FUNCTION_LEVEL     2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME      diquanserq8

#include <stddef.h> 
#include <stdlib.h> 

#include "simstruc.h" 

#ifdef  MATLAB_MEX_FILE
#include "mex.h"
#endif

#ifndef MATLAB_MEX_FILE
#include <windows.h>
#include "io_xpcimport.h"
#include "pci_xpcimport.h"
#include "time_xpcimport.h"
#include "util_xpcimport.h"

#endif

#define NUM_ARGS             5
#define CHANNEL_ARG          ssGetSFcnParam(S,0) // vector of [1:32] 
#define CONTROL_ARG          ssGetSFcnParam(S,1) // int 
#define SAMP_TIME_ARG        ssGetSFcnParam(S,2) // double
#define PCI_BUS_ARG          ssGetSFcnParam(S,3) // int
#define PCI_SLOT_ARG         ssGetSFcnParam(S,4) // int

#define NUM_I_WORKS          (1)
#define BASE_I_IND           (0)
#define NUM_R_WORKS          (0)

#define VENDOR_ID            (uint16_T)(0x11E3)   
#define DEVICE_ID            (uint16_T)(0x0010)   
#define SUBVENDOR_ID         (uint16_T)(0x5155)   
#define SUBDEVICE_ID         (uint16_T)(0x0200)   
#define PCI_BYTES            (0x0400)   

#define MAX_CHAN             (32)

#define BIT(n)               (1L << n)

// 32-bit-register offsets
#define DIGITAL_IO_REGISTER  (0x24 / 4) // R/W
#define DIGITAL_DIR_REGISTER (0x28 / 4) // W

typedef void *ptr_T;
typedef volatile uint32_T *reg32_T;

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i, numOutputPorts;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg, "%d input args expected, %d passed", 
            NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumInputPorts(S, 0);

    numOutputPorts = mxGetN(CHANNEL_ARG);

    ssSetNumOutputPorts(S, numOutputPorts);
    for (i = 0; i < numOutputPorts; i++) {
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
    int_T   *IWork   = ssGetIWork(S);
    int_T    pciSlot = (int_T) mxGetPr(PCI_SLOT_ARG)[0];
    int_T    pciBus  = (int_T) mxGetPr(PCI_BUS_ARG)[0];
    int_T    control = (int_T) mxGetPr(CONTROL_ARG)[0];

    ptr_T    bar0;
    reg32_T  base;

    PCIDeviceInfo pciInfo;

    if (pciSlot < 0) {
        if (rl32eGetPCIInfo(VENDOR_ID, DEVICE_ID, &pciInfo)) {
            sprintf(msg, "No %% found");
            ssSetErrorStatus(S, msg);
            return;
        }
    } 
    else if (rl32eGetPCIInfoAtSlot(VENDOR_ID, DEVICE_ID, 
        pciSlot + pciBus * 256, &pciInfo)) {
        sprintf(msg, "No %% at bus %d slot %d", pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    bar0 = (ptr_T) pciInfo.BaseAddress[0];

    base = (reg32_T) rl32eGetDevicePtr(bar0, PCI_BYTES, RT_PG_USERREADWRITE);

    IWork[BASE_I_IND] = base;

    base[DIGITAL_DIR_REGISTER] = control;
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T  *IWork  = ssGetIWork(S);
    reg32_T base   = (reg32_T) IWork[BASE_I_IND];
    uint_T  input  = base[DIGITAL_IO_REGISTER];
    int_T   nChans = mxGetN(CHANNEL_ARG);

    real_T *y;
    int_T   i, chan;
    
    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        y = ssGetOutputPortRealSignal(S, i);
        y[0] = (input & BIT(chan)) ? 1 : 0;
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#endif
}

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
