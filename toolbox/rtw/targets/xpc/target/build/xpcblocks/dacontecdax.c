/* $Revision: 1.1 $ */
// dacontecdax.c - xPC Target, non-inlined S-function driver for 
// the Contec DA12-4(PCI) and DA12-16(PCI) D/A boards
// Copyright 2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   dacontecdax

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

#define NUM_ARGS        (8)
#define CHANNEL_ARG     ssGetSFcnParam(S,0) // vector of 1:4 or 1:16
#define RANGE_ARG       ssGetSFcnParam(S,1) // vector of {-5, -10, 10}
#define RESET_ARG       ssGetSFcnParam(S,2) // vector of boolean
#define INIT_VAL_ARG    ssGetSFcnParam(S,3) // vector of double
#define SAMP_TIME_ARG   ssGetSFcnParam(S,4) // double
#define PCI_BUS_ARG     ssGetSFcnParam(S,5) // integer
#define PCI_SLOT_ARG    ssGetSFcnParam(S,6) // integer
#define DEVICE_ARG      ssGetSFcnParam(S,7) // 1: DA12-4, 2: DA12-16

#define VENDOR_ID       (0x1221) // Contec
#define RESOLUTION      (4096)
#define MAX_COUNT       (RESOLUTION - 1)

#define SAMP_TIME_IND   (0)

#define NUM_I_WORKS     (1)
#define BASE_ADDR_I_IND (0)

#define NUM_R_WORKS     (16)
#define GAIN_R_IND      (0)
#define OFFSET_R_IND    (8)

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
        sprintf(msg, "%d input args expected, %d passed", NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i=0; i<mxGetN(CHANNEL_ARG); i++){
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

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
    int_T  pciSlot = mxGetPr(PCI_SLOT_ARG)[0];
    int_T  pciBus  = mxGetPr(PCI_BUS_ARG)[0];
    int_T  device  = mxGetPr(DEVICE_ARG)[0];
    int_T  nChans  = mxGetN(CHANNEL_ARG);
    
    int_T  i, chan, range, base, deviceId;
    char_T deviceName[40];
    PCIDeviceInfo pciInfo;

    switch (device) {
        case 1: {
            deviceId = 0x8183;
            sprintf(deviceName, "Contec DA12-4");
            break;
        }
        case 2: {
            deviceId = 0x8163;
            sprintf(deviceName, "Contec DA12-16");
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

    // initialize board
    rl32eOutpB(base + 0x08, 0x00);

    // set simultaneous output mode
    rl32eOutpB(base + 0x08, 0x01);
    rl32eOutpB(base + 0x0c, 0x01);

    // store offsets and gains; set ranges
    for( i = 0 ; i < nChans ; i++ ) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        switch ((int_T)mxGetPr(RANGE_ARG)[i]) {
            case -5: // -5V to 5V
                range = 1;
                RWork[GAIN_R_IND + i]   = RESOLUTION / 10.0;
                RWork[OFFSET_R_IND + i] = 5.0;
                break;
            case -10: // -10V to 10V
                range = 2;
                RWork[GAIN_R_IND + i]   = RESOLUTION / 20.0;
                RWork[OFFSET_R_IND + i] = 10.0;
                break;
            case 10: // 0V to 10V
                range = 0;
                RWork[GAIN_R_IND + i]   = RESOLUTION / 10.0;
                RWork[OFFSET_R_IND + i] = 0.0;
                break;
        }

        rl32eOutpB(base + 0x08, 0x02);
        rl32eOutpB(base + 0x0c, chan);
        rl32eOutpB(base + 0x0d, range);
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    real_T *RWork  = ssGetRWork(S);
    int_T  *IWork  = ssGetIWork(S);
    int_T   nChans = mxGetN(CHANNEL_ARG);
    int_T   base   = ssGetIWorkValue(S, BASE_ADDR_I_IND);

    InputRealPtrsType uPtrs;

    int_T   i, count, chan, status;
    real_T  voltage, gain, offset, temp;

    for( i = 0 ; i < nChans ; i++ ) {
        chan = (int_T)mxGetPr(CHANNEL_ARG)[i] - 1;
        uPtrs = ssGetInputPortRealSignalPtrs(S,i);

        voltage = *uPtrs[0];
        temp = (voltage + RWork[OFFSET_R_IND + i]) * RWork[GAIN_R_IND + i];

        count = (int_T) temp;

        if (count < 0)
            count = 0;
        else if (count > MAX_COUNT)
            count = MAX_COUNT;

        // set channel
        rl32eOutpB(base + 0x04, chan);

        // set count
        rl32eOutpW(base + 0x00, count);
    }

    // simultanous output
    rl32eOutpB(base + 0x08, 0x03);

    // wait to settle
    do 
        status = rl32eInpB(base + 0x06);
    while
        ((status & 0x02) == 0);
#endif       
}

static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
    real_T *RWork  = ssGetRWork(S);
    int_T  *IWork  = ssGetIWork(S);
    int_T   nChans = mxGetN(CHANNEL_ARG);
    int_T   base   = ssGetIWorkValue(S, BASE_ADDR_I_IND);

    int_T   i, count, chan, status;
    real_T  voltage, gain, offset, temp;

    // At load time, set channel to its initial value.
    // At termination, set channel to its initial value if reset requested.

    for( i = 0 ; i < nChans ; i++ ) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            chan = (int_T)mxGetPr(CHANNEL_ARG)[i] - 1;
            voltage = (real_T)mxGetPr(INIT_VAL_ARG)[i];
            temp = (voltage + RWork[OFFSET_R_IND + i]) * RWork[GAIN_R_IND + i];

            count = (int_T) temp;

            if (count < 0)
                count = 0;
            else if (count > MAX_COUNT)
                count = MAX_COUNT;

            // set channel
            rl32eOutpB(base + 0x04, chan);

            // set count
            rl32eOutpW(base + 0x00, count);
        }
    }

    // simultanous output
    rl32eOutpB(base + 0x08, 0x03);

    // wait to settle
    do 
        status = rl32eInpB(base + 0x06);
    while
        ((status & 0x02) == 0);
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
