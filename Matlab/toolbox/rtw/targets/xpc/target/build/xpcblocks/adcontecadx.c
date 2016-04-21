/* $Revision: 1.2 $ */
// adcontecadx.c - xPC Target, non-inlined S-function driver for the A/D
// section of the Contec AD12-16(PCI) and AD12-64(PCI) boards
// Copyright 1996-2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   adcontecadx

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

#define NUM_ARGS        7
#define CHANNEL_ARG     ssGetSFcnParam(S,0) // vector of 1:16 or 1:64
#define RANGE_ARG       ssGetSFcnParam(S,1) // vector of {1.25, 2.5, 5, 10, -1.25, -2.5, -5, -10}
#define POLARITY_ARG    ssGetSFcnParam(S,2) // 1: single-ended; 2: double-ended
#define SAMP_TIME_ARG   ssGetSFcnParam(S,3) // seconds
#define PCI_BUS_ARG     ssGetSFcnParam(S,4) // integer
#define PCI_SLOT_ARG    ssGetSFcnParam(S,5) // integer
#define DEVICE_ARG      ssGetSFcnParam(S,6) // integer

#define VENDOR_ID       (0x1221) // Contec
#define RESOLUTION      (4096)
#define MAX_COUNT       (RESOLUTION - 1)

#define SAMP_TIME_IND   (0)

#define NUM_I_WORKS     (66)
#define BASE_ADDR_I_IND (0)
#define LAST_CHAN_I_IND (1)
#define INVERSE_I_IND   (2)

#define NUM_R_WORKS     (32)
#define OFFSET_R_IND    (0) 
#define GAIN_R_IND      (16)

static char_T msg[256];
static char_T deviceName[40];

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
    real_T *RWork    = ssGetRWork(S);
    int_T   pciSlot  = mxGetPr(PCI_SLOT_ARG)[0];
    int_T   pciBus   = mxGetPr(PCI_BUS_ARG)[0];
    int_T   device   = mxGetPr(DEVICE_ARG)[0];
    int_T   nChans   = mxGetN(CHANNEL_ARG);
    int_T   polarity = mxGetN(POLARITY_ARG);
    int_T   lastChan = 0;

    int_T  i, chan, mode, range, base, deviceId;
    PCIDeviceInfo pciInfo;

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

    for (i = 0; i < 64; i++)
        IWork[INVERSE_I_IND] = -1;

    mode = 0x04; // multi-channel

    if (polarity == 2)
        mode |= 0x08;

    // initialize board
    rl32eOutpB(base + 0x08, 0x00);

    // set sampling mode
    rl32eOutpB(base + 0x08, 0x01);
    rl32eOutpB(base + 0x0c, mode);

    // compute and store lastChan 
    // store inverse of the mapping i -> chan
    // store offsets and gains
    // set range for each chan 
    for( i = 0 ; i < nChans ; i++ ) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        IWork[INVERSE_I_IND + chan] = i;
        if (chan > lastChan)
            lastChan = chan;
        switch ((int_T)mxGetPr(RANGE_ARG)[i]) {
            case -1: // -1.25V to 1.25V
                range = 3;
                RWork[GAIN_R_IND + i]   = 2.5 / RESOLUTION;
                RWork[OFFSET_R_IND + i] = 1.25;
                break;
            case -2: // -2.5V to 2.5V
                range = 2;
                RWork[GAIN_R_IND + i]   = 5.0 / RESOLUTION;
                RWork[OFFSET_R_IND + i] = 2.5;
                break;
            case -5: // -5V to 5V
                range = 1;
                RWork[GAIN_R_IND + i]   = 10.0 / RESOLUTION;
                RWork[OFFSET_R_IND + i] = 5.0;
                break;
            case -10: // -10V to 10V
                range = 0;
                RWork[GAIN_R_IND + i]   = 20.0 / RESOLUTION;
                RWork[OFFSET_R_IND + i] = 10.0;
                break;
            case 1: // 0V to 1.25V
                range = 7;
                RWork[GAIN_R_IND + i]   = 1.25 / RESOLUTION;
                RWork[OFFSET_R_IND + i] = 0.0;
                break;
            case 2: // 0V to 2.5V
                range = 6;
                RWork[GAIN_R_IND + i]   = 2.5 / RESOLUTION;
                RWork[OFFSET_R_IND + i] = 0.0;
                break;
            case 5: // 0V to 5V
                range = 5;
                RWork[GAIN_R_IND + i]   = 5.0 / RESOLUTION;
                RWork[OFFSET_R_IND + i] = 0.0;
                break;
            case 10: // 0V to 10V
                range = 4;
                RWork[GAIN_R_IND + i]   = 10.0 / RESOLUTION;
                RWork[OFFSET_R_IND + i] = 0.0;
                break;
        }

        rl32eOutpB(base + 0x08, 0x02);
        rl32eOutpB(base + 0x0c, chan);
        rl32eOutpB(base + 0x0d, range);
    }
    IWork[LAST_CHAN_I_IND] = lastChan;
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    real_T *RWork    = ssGetRWork(S);
    int_T  *IWork    = ssGetIWork(S);
    int_T   base     = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T   lastChan = ssGetIWorkValue(S, LAST_CHAN_I_IND);
    int_T   i, chan, count;
    real_T *y;

    // start sampling
    rl32eOutpB(base + 0x04, lastChan);

    // wait for completion
    while( !(rl32eInpB(base + 0x06) & 2) );

    for (chan = 0; chan <= lastChan; chan++) {
        count = rl32eInpW(base);
        if ((i = IWork[INVERSE_I_IND + chan]) < 0)
            continue;
        y = ssGetOutputPortRealSignal(S, i);
        y[0] = count * RWork[GAIN_R_IND + i] - RWork[OFFSET_R_IND + i];
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




