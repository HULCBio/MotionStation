/* $Revision: 1.1 $ */
// dacontecdaxe.c - xPC Target, non-inlined S-function driver for the D/A 
// section of Contec AD12-16(PCI)E, AD12-16U(PCI)E, AD16-16(PCI)E boards (pjk)
// Copyright 2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   dacontecadxe

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

#define NUM_ARGS        (7)
#define RANGE_ARG       ssGetSFcnParam(S,0) // integer
#define RESET_ARG       ssGetSFcnParam(S,1) // boolean
#define INIT_VAL_ARG    ssGetSFcnParam(S,2) // double
#define SAMP_TIME_ARG   ssGetSFcnParam(S,3) // double
#define PCI_BUS_ARG     ssGetSFcnParam(S,4) // integer
#define PCI_SLOT_ARG    ssGetSFcnParam(S,5) // integer
#define DEVICE_ARG      ssGetSFcnParam(S,6) // device_T (defined below)

#define VENDOR_ID       (0x1221) // Contec

#define NUM_I_WORKS     (2)
#define BASE_I_IND      (0)
#define MAX_COUNT_I_IND (1)

#define NUM_R_WORKS     (2)
#define GAIN_R_IND      (0)
#define OFFSET_R_IND    (1)

#define ANALOG_OUTPUT_REGISTER_LOWER (4)
#define ANALOG_OUTPUT_REGISTER_UPPER (5)
#define COMMAND_OUTPUT_REGISTER      (6)
#define DATA_INPUT_REGISTER          (7)
#define DATA_OUTPUT_REGISTER         (7)
#define ANALOG_OUTPUT_COMMAND  (37)

typedef enum { 
    AD12_16  = 0,
    AD12_16U = 1,
    AD16_16  = 2
} device_T;

static char name[3][15] = {"AD12-16 ", "AD12-16U", "AD16-16 "};
static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

#ifndef MATLAB_MEX_FILE
#include    "io_xpcimport.c"
#include    "pci_xpcimport.c"
#include    "util_xpcimport.c"
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

    ssSetNumInputPorts(S, 1);
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    ssSetNumOutputPorts(S, 0);
    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for( i = 0 ; i < NUM_ARGS ; i++ ) {
        ssSetSFcnParamTunable(S, i, 0); 
    }

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
    int_T  *IWork  = ssGetIWork(S);
    real_T *RWork  = ssGetRWork(S);
    int_T  range   = mxGetPr(RANGE_ARG)[0];
    int_T  pciSlot = mxGetPr(PCI_SLOT_ARG)[0];
    int_T  pciBus  = mxGetPr(PCI_BUS_ARG)[0];
    int_T  device  = mxGetPr(DEVICE_ARG)[0];
    
    int_T  base, deviceId, resolution;
    PCIDeviceInfo pciInfo;

    switch (device) {
        case AD12_16: {
            deviceId = 0x8113;
            resolution = 4096;
            break;
        }
        case AD12_16U: {
            deviceId = 0x8103;
            resolution = 4096;
            break;
        }
        case AD16_16: {
            deviceId = 0x8123;
            resolution = 65536;
            break;
        }
        default: {
            sprintf(msg, "bad ADxx-16 device parameter: %d", range);
            ssSetErrorStatus(S, msg);
            return;
        }
    }

    IWork[MAX_COUNT_I_IND] = resolution - 1;

    if (pciSlot < 0) {
        if (rl32eGetPCIInfo((uint16_T) VENDOR_ID, 
            (uint16_T) deviceId, &pciInfo)) {
            sprintf(msg, "No Contec %s(PCI)E found", name[device]);
            ssSetErrorStatus(S, msg);
            return;
        }
    } 
    else if (rl32eGetPCIInfoAtSlot((uint16_T)VENDOR_ID, (uint16_T)deviceId, 
        pciSlot + pciBus * 256, &pciInfo)) {
        sprintf(msg, "No Contec %s(PCI)E at bus %d slot %d", 
            name[device], pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    base = pciInfo.BaseAddress[0];

    IWork[BASE_I_IND] = base;

    switch (range) {
        case 1: // -5V to 5V
            RWork[GAIN_R_IND]   = resolution / 10.0;
            RWork[OFFSET_R_IND] = 5.0;
            break;
        case 2: // -10V to 10V
            RWork[GAIN_R_IND]   = resolution / 20.0;
            RWork[OFFSET_R_IND] = 10.0;
            break;
        case 3: // 0V to 10V
            RWork[GAIN_R_IND]   = resolution / 10.0;
            RWork[OFFSET_R_IND] = 0.0;
            break;
        default: 
            sprintf(msg, "bad %s range parameter: %d", name[device], range);
            ssSetErrorStatus(S, msg);
            return;
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    real_T *RWork = ssGetRWork(S);
    int_T  *IWork = ssGetIWork(S);
    int_T   base  = ssGetIWorkValue(S, BASE_I_IND);
    int_T   max   = ssGetIWorkValue(S, MAX_COUNT_I_IND);

    InputRealPtrsType uPtrs;

    uint8_T data;
    uint_T  count;
    real_T  voltage;

    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);

    voltage = *uPtrs[0];

    count = (int_T) (RWork[GAIN_R_IND] * (voltage + RWork[OFFSET_R_IND]));

    if (count < 0)
        count = 0;
    else if (count > max)
        count = max;

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, ANALOG_OUTPUT_COMMAND); 
    data = rl32eInpB(base + DATA_INPUT_REGISTER);
    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, ANALOG_OUTPUT_COMMAND); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, data | 8);
    rl32eOutpB(base + ANALOG_OUTPUT_REGISTER_LOWER, count); 
    rl32eOutpB(base + ANALOG_OUTPUT_REGISTER_UPPER, count >> 8);
    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, ANALOG_OUTPUT_COMMAND); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, data & 0xf7);
#endif       
}

static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE

    real_T *RWork = ssGetRWork(S);
    int_T  *IWork = ssGetIWork(S);
    int_T   reset = mxGetPr(RESET_ARG)[0];
    int_T   base  = ssGetIWorkValue(S, BASE_I_IND);
    int_T   max   = ssGetIWorkValue(S, MAX_COUNT_I_IND);

    uint8_T data;
    uint_T  count;
    real_T  voltage;

    // At load time, set channel to its initial value.
    // At termination, set channel to its initial value if reset requested.

    if (xpceIsModelInit() || reset) {
        voltage = (real_T)mxGetPr(INIT_VAL_ARG)[0];

        count = (int_T) (RWork[GAIN_R_IND] * (voltage + RWork[OFFSET_R_IND]));

        if (count < 0)
            count = 0;
        else if (count > max)
            count = max;

        rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, ANALOG_OUTPUT_COMMAND); 
        data = rl32eInpB(base + DATA_INPUT_REGISTER);
        rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, ANALOG_OUTPUT_COMMAND); 
        rl32eOutpB(base + DATA_OUTPUT_REGISTER, data | 8);
        rl32eOutpB(base + ANALOG_OUTPUT_REGISTER_LOWER, count); 
        rl32eOutpB(base + ANALOG_OUTPUT_REGISTER_UPPER, count >> 8);
        rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, ANALOG_OUTPUT_COMMAND); 
        rl32eOutpB(base + DATA_OUTPUT_REGISTER, data & 0xf7);
    }
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
