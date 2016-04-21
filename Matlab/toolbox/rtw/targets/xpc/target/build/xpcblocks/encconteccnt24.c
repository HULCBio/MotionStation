/* $Revision: 1.1.6.1 $ */
// encconteccnt24.c - xPC Target, non-inlined S-function driver for the 
// Contec CNT24-4D counter board
// Copyright 2003 The MathWorks, Inc.

#define S_FUNCTION_LEVEL  2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME   encconteccnt24

#include "simstruc.h" 

#ifdef  MATLAB_MEX_FILE
#include "mex.h"
#endif

#ifndef MATLAB_MEX_FILE
#include <windows.h>
#include "io_xpcimport.h"
#include "pci_xpcimport.h"
#include "util_xpcimport.h"
#endif

#define NUM_ARGS              11
#define CHANNEL_ARG           ssGetSFcnParam(S, 0) // 4 of 0:3
#define SEL_ARG               ssGetSFcnParam(S, 1) // 4 of 0:1
#define MODE_ARG              ssGetSFcnParam(S, 2) // 4 of 0:8
#define DIR_ARG               ssGetSFcnParam(S, 3) // 4 of 0:1
#define ZSEL_ARG              ssGetSFcnParam(S, 4) // 4 of 0:1
#define ZMODE_ARG             ssGetSFcnParam(S, 5) // 4 of 0:2
#define INIT_COUNT_ARG        ssGetSFcnParam(S, 6) // 4 of 0:0xffffff
#define FILTER_ARG            ssGetSFcnParam(S, 7) // 4 of 0:15
#define SAMP_TIME_ARG         ssGetSFcnParam(S, 8) // seconds
#define PCI_BUS_ARG           ssGetSFcnParam(S, 9) // integer
#define PCI_SLOT_ARG          ssGetSFcnParam(S,10) // integer

#define VENDOR_ID             (0x1221) // Contec
#define DEVICE_ID             (0x8115) // CNT24-4D

#define NUM_CHANS             (4) 

#define SAMP_TIME_IND         (0)

#define NUM_I_WORKS           (2)
#define BASE_ADDR_I_IND       (0)
#define LATCH_I_IND           (1)
#define NUM_R_WORKS           (0)

// byte offsets of control ports
#define COMMAND_PORT          (0x00)
#define DATA_PORT             (0x01)

#define OFFSET_PER_CHAN       (0x05)

// output commands - per channel
#define INITIAL_COUNT_VALUE   (0x00)  
#define OPERATION_MODE        (0x01)
#define PHASE_Z_CLR_INPUT     (0x02)
#define COMPARE_REGISTER      (0x03)
#define DIGITAL_FILTER        (0x04)

// output commands - apply to all channels at once
#define COUNT_VALUE_LATCH     (0x14)
#define INTERRUPT_MASK        (0x15)
#define SENSE_RESET           (0x16)
#define TIMER_DATA            (0x17)
#define TIMER_START           (0x18)
#define ONE_SHOT_PULSE_WIDTH  (0x19)
#define GENERAL_PURPOSE_INPUT (0x1A)

// input commands - per channel
#define COUNT_VALUE           (0x00)  
#define STATUS_DATA           (0x01)

// input commands - apply to all channels at once
#define INTERRUPT_MASK        (0x15)
#define SENSE_PORT            (0x16)
#define INPUT_SIGNAL_SELECT   (0x1A)

// OPERATION_MODE bits
#define OPERATION_MODE_SEL0   (0x01)  
#define OPERATION_MODE_SEL1   (0x02)
#define OPERATION_MODE_SEL2   (0x04)
#define OPERATION_MODE_DIR    (0x08) // 0:clockwise counts down; 1:up
#define OPERATION_MODE_UD_AB  (0x10)
#define OPERATION_MODE_ZSEL   (0x20) // 0:Z input active high, 1:active low
#define OPERATION_MODE_SEL    (0x40) // 0:line receiver, 1:TTL-level input
#define OPERATION_MODE_RESET  (0x80) // 0:clear counter, 1:count

// PHASE_Z_CLR_INPUT bits
#define PHASE_Z_CLR_INPUT_ZE0 (0x02)  
#define PHASE_Z_CLR_INPUT_ZE1 (0x04)  

// STATUS_DATA bits
#define STATUS_DATA_U         (0x01) // general purpose input value 
#define STATUS_DATA_EQ        (0x02) // 0: count = compare reg; 1: unequal
#define STATUS_DATA_U_D       (0x04) // 0: counting up; 1: down
#define STATUS_DATA_B         (0x10) // phase B value
#define STATUS_DATA_A         (0x20) // phase A value
#define STATUS_DATA_Z         (0x40) // 1: phase Z asserted
#define STATUS_DATA_AI        (0x80) // 1: abnormal pulse input


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
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
    int_T *IWork   = ssGetIWork(S);
    int_T  pciSlot = mxGetPr(PCI_SLOT_ARG)[0];
    int_T  pciBus  = mxGetPr(PCI_BUS_ARG)[0];
    int_T  nChans  = mxGetN(CHANNEL_ARG);
    int_T  mode[9] = {0x00, 0x01, 0x02, 0x04, 0x05, 0x06, 0x13, 0x03, 0x07};

    int_T   i, base, chan, offset, latch, opMode, zMode, initCount, filter;
    PCIDeviceInfo pciInfo;

    if (pciSlot < 0) {
        if (rl32eGetPCIInfo((uint16_T) VENDOR_ID, 
                            (uint16_T) DEVICE_ID, &pciInfo)) {
            sprintf(msg, "No Contec CNT24-4D found");
            ssSetErrorStatus(S, msg);
            return;
        }
    } 
    else if (rl32eGetPCIInfoAtSlot((uint16_T)VENDOR_ID, (uint16_T)DEVICE_ID, 
                                   pciSlot + pciBus * 256, &pciInfo)) {
        sprintf(msg, "No Contec CNT24-4D at bus %d slot %d", pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    IWork[BASE_ADDR_I_IND] = base = pciInfo.BaseAddress[0];

    if (xpceIsModelInit())
    {   // at download time
        // reset all channels
        for( chan = 0 ; chan < NUM_CHANS ; chan++ ) {
            offset = chan * OFFSET_PER_CHAN;
            rl32eOutpB(base + COMMAND_PORT, OPERATION_MODE + offset);
            rl32eOutpB(base + DATA_PORT, 0);
        }
    }

    if (!xpceIsModelInit())
    {   // at run time

        latch = 0;
        base = IWork[BASE_ADDR_I_IND];

        for( i = 0 ; i < nChans ; i++ ) {
            chan = mxGetPr(CHANNEL_ARG)[i];
            offset = chan * OFFSET_PER_CHAN;
            latch |= (1 << chan);

            zMode = PHASE_Z_CLR_INPUT_ZE0 * mxGetPr(ZMODE_ARG)[chan];
            rl32eOutpB(base + COMMAND_PORT, PHASE_Z_CLR_INPUT + offset);
            rl32eOutpB(base + DATA_PORT, zMode);

            filter = mxGetPr(FILTER_ARG)[chan];
            rl32eOutpB(base + COMMAND_PORT, DIGITAL_FILTER + offset);
            rl32eOutpB(base + DATA_PORT, filter);

            opMode = OPERATION_MODE_RESET * 1 // start counting
                   | OPERATION_MODE_SEL   * (int_T)(mxGetPr(SEL_ARG)[chan])
                   | OPERATION_MODE_ZSEL  * (int_T)(mxGetPr(ZSEL_ARG)[chan])
                   | OPERATION_MODE_DIR   * (int_T)(mxGetPr(DIR_ARG)[chan])
                   | OPERATION_MODE_SEL0  * mode[(int_T)mxGetPr(MODE_ARG)[chan]]
                   ;
            rl32eOutpB(base + COMMAND_PORT, OPERATION_MODE + offset);
            rl32eOutpB(base + DATA_PORT, opMode);

            initCount = mxGetPr(INIT_COUNT_ARG)[chan];
            rl32eOutpB(base + COMMAND_PORT, INITIAL_COUNT_VALUE + offset);
            rl32eOutpB(base + DATA_PORT, 0xff & initCount);
            rl32eOutpB(base + DATA_PORT, 0xff & (initCount >> 8));
            rl32eOutpB(base + DATA_PORT, 0xff & (initCount >> 16)); 

            // printf("chan %d zMode %x filter %x opMode %x initCount %d\n", chan+1, zMode, filter, opMode, initCount);
        }
        IWork[LATCH_I_IND] = latch;
    }

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T  *IWork  = ssGetIWork(S);
    int_T   base   = IWork[BASE_ADDR_I_IND];
    int_T   latch  = IWork[LATCH_I_IND];
    int_T   nChans = mxGetN(CHANNEL_ARG);
    int_T   i, chan, offset, shift, count;
    real_T *y;

    rl32eOutpB(base + COMMAND_PORT, COUNT_VALUE_LATCH);
    rl32eOutpB(base + DATA_PORT, latch);

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i];
        offset = chan * OFFSET_PER_CHAN;

        rl32eOutpB(base + COMMAND_PORT, COUNT_VALUE + offset);

        for (count = 0, shift = 0; shift < 24; shift += 8) 
            count |= ( (rl32eInpB(base + DATA_PORT) & 0xff) << shift );

        y = ssGetOutputPortRealSignal(S, i);
        y[0] = count;
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
