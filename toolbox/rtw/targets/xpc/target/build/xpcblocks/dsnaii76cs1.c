// dsnaii76cs1.c - xPC Target, non-inlined S-function driver for the
// D/S section of the NAII Apex 76CS1 Series Synchro/Resolver boards
// Copyright 2003 The MathWorks, Inc.

// 
#define S_FUNCTION_LEVEL         2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME          dsnaii76cs1

#include <math.h>
#include <stddef.h>
#include <stdlib.h>

#include "simstruc.h"

#ifdef   MATLAB_MEX_FILE
#include "mex.h"
#endif

#ifndef  MATLAB_MEX_FILE
#include <windows.h>
#include "io_xpcimport.h"
#include "pci_xpcimport.h"
#include "time_xpcimport.h"
#include "util_xpcimport.h"
#endif

#define NUM_ARGS                 (11)
#define CHANNEL_ARG              ssGetSFcnParam(S, 0) // vector int 1-6
#define RESET_ARG                ssGetSFcnParam(S, 1) // vector boolean
#define INIT_VAL_ARG             ssGetSFcnParam(S, 2) // vector double -1 to 1
#define TWO_SPEED_RATIO_ARG      ssGetSFcnParam(S, 3) // vector of double >= 1
#define HI_RESOLUTION_ARG        ssGetSFcnParam(S, 4) // vector of boolean
#define SHOW_STATUS_ARG          ssGetSFcnParam(S, 5) // boolean
#define FREQUENCY_ARG            ssGetSFcnParam(S, 6) // double
#define VOLTAGE_ARG              ssGetSFcnParam(S, 7) // double
#define SAMPLE_TIME_ARG          ssGetSFcnParam(S, 8) // double
#define PCI_BUS_ARG              ssGetSFcnParam(S, 9) // integer
#define PCI_SLOT_ARG             ssGetSFcnParam(S,10) // integer

#define VENDOR_ID                (uint16_T)(0x15ac)  // NAII
#define DEVICE_ID                (uint16_T)(0x7621)  // 76CS1 

#define PCI_MEM_LEN              (1024)
#define MAX_DS                   (6)
#define PI                       (3.14159265358979)

#define BIT(n)                   (1 << n)
#define MOD1(x)                  ((x >= 0) ? fmod(x,1) : 1 + fmod(x,1))

#define Register                 volatile uint16_T *

// 16-bit-register offsets

#define DS_DATA                  (0x100 / 2) // read/write
#define DS_WRAP_AROUND           (0x118 / 2) // read
#define DS_RATIO                 (0x130 / 2) // read/write
#define STOP_ANGLE               (0x140 / 2) // read/write

#define DS_ROTATION_RATE         (0x158 / 2) // read/write
#define INITIATE_ROTATION        (0x170 / 2) // write
#define STOP_ROTATION            (0x174 / 2) // write
#define ROTATION_MODE            (0x178 / 2) // read/write
#define ROTATION_COMPLETED       (0x17C / 2) // read (not implemented)
#define DS_SIGNAL_STATUS         (0x180 / 2) // read
#define DS_REFERENCE_STATUS      (0x184 / 2) // read
#define DS_TEST_STATUS           (0x188 / 2) // read
#define DS_TEST_D2_VERIFY        (0x190 / 2) // read/write
#define DS_TEST_ENABLE           (0x194 / 2) // read/write
#define DS_POST_ENABLE           (0x198 / 2) // read/write
#define DS_ACTIVE_CHANNELS       (0x1A0 / 2) // read/write
#define OUTPUTS_ON_OFF           (0x1A4 / 2) // read/write

#define INTERRUPT_ENABLE         (0x1B0 / 2) // read/write
#define INTERRUPT_STATUS         (0x1B4 / 2) // read
#define REFERENCE_FREQUENCY      (0x1B8 / 2) // read/write
#define REFERENCE_VOLTAGE        (0x1BC / 2) // read/write
#define WATCHDOG_TIMER           (0x1C0 / 2) // read/write
#define SOFT_RESET               (0x1C4 / 2) // write
#define PART_NUMBER              (0x1C8 / 2) // read
#define SERIAL_NUMBER            (0x1CC / 2) // read
#define DATA_CODE                (0x1D0 / 2) // read
#define REV_LEVEL_PCB            (0x1D4 / 2) // read
#define REV_LEVEL_SD_DSP         (0x1D8 / 2) // read
#define REV_LEVEL_SD_FPGA        (0x1DC / 2) // read
#define REV_LEVEL_DS_DSP         (0x1E0 / 2) // read
#define REV_LEVEL_DS_FPGA        (0x1E4 / 2) // read
#define REV_LEVEL_INTERFACE_FPGA (0x1EC / 2) // read
#define SAVE                     (0x1FC / 2) // read/write

#define NUM_I_WORKS              (1)
#define NUM_R_WORKS              (0)
#define BASE_I_IND               (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T  nChans     = mxGetN(CHANNEL_ARG);
    int_T  showStatus = mxGetPr(SHOW_STATUS_ARG)[0];
    int_T  i, width;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d input args expected, %d passed", 
            NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, nChans);

    for (i = 0; i < nChans; i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    if (showStatus) {
        ssSetNumOutputPorts(S, 1);
        ssSetOutputPortWidth(S, 0, 3);
    } else {
        ssSetNumOutputPorts(S, 0);
    }

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for( i = 0 ; i < NUM_ARGS ; i++ )
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (mxGetPr(SAMPLE_TIME_ARG)[0] == -1.0) {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    } else {
        ssSetSampleTime(S, 0, mxGetPr(SAMPLE_TIME_ARG)[0]);
        ssSetOffsetTime(S, 0, 0.0);
    }
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T   *IWork      = ssGetIWork(S);
    int_T    nChans     = mxGetN(CHANNEL_ARG);
    int_T    showStatus = mxGetPr(SHOW_STATUS_ARG)[0];
    int_T    frequency  = mxGetPr(FREQUENCY_ARG)[0];
    int_T    voltage    = mxGetPr(VOLTAGE_ARG)[0];
    int_T    pciSlot    = mxGetPr(PCI_SLOT_ARG)[0];
    int_T    pciBus     = mxGetPr(PCI_BUS_ARG)[0];
    int_T    busSlot    = pciSlot + pciBus * 256;
    uint16_T write1     = 0xA5A5;
    uint16_T write2     = ~write1;

    uint16_T read1, read2, active, output, ratio;
    int_T     i, chan;
    void     *addr;
    Register  base;

    PCIDeviceInfo pciInfo;

    if (pciSlot < 0) {
        if (rl32eGetPCIInfo(VENDOR_ID, DEVICE_ID, &pciInfo)) {
            sprintf(msg, "No NAII Apex 76CS1 found");
            ssSetErrorStatus(S, msg);
            return;
        }
    } 
    else if (rl32eGetPCIInfoAtSlot(VENDOR_ID, DEVICE_ID, busSlot, &pciInfo)) {
        sprintf(msg, "No NAII Apex 76CS1 at bus %d slot %d", pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    addr = (void *) pciInfo.BaseAddress[0];
    base = (Register) rl32eGetDevicePtr(addr, PCI_MEM_LEN, RT_PG_USERREADWRITE);

    IWork[BASE_I_IND] = (int_T) base;

    // Check the 76CS1 by writing test values to the watchdog timer. 
    // These should be inverted by the board within 100 microseconds.

    base[WATCHDOG_TIMER] = write1;
    rl32eWaitDouble(0.0001);
    read1 = base[WATCHDOG_TIMER];

    base[WATCHDOG_TIMER] = write2;
    rl32eWaitDouble(0.0001);
    read2 = base[WATCHDOG_TIMER];

    if((read1 != write2) || (read2 != write1)) {
        sprintf(msg, "Unresponsive NAII Apex 76CS1 at bus %d slot %d", 
            pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    for (i = active = output = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        if (chan >= MAX_DS) {
            sprintf(msg, "No such NAII Apex 76CS1 D/S channel: %d", chan+1);
            ssSetErrorStatus(S, msg);
            return;
        }

        active |= BIT(chan);
        output |= BIT(chan);

        if (chan % 2) { // if an even-numbered channel

            ratio = mxGetPr(TWO_SPEED_RATIO_ARG)[i];
            base[DS_RATIO + chan - 1] = ratio;

            if (ratio > 1) { // if a 2-speed channel
                active |= BIT(chan - 1);
                output |= BIT(chan - 1);

                if (mxGetPr(HI_RESOLUTION_ARG)[i])
                    base[DS_DATA + 2 * chan] = 0;
            }
        }
    }

    base[DS_ACTIVE_CHANNELS] = active;
    base[OUTPUTS_ON_OFF] = output;

    base[REFERENCE_FREQUENCY] = frequency;
    base[REFERENCE_VOLTAGE] = 10 * voltage;

    // if status output is requested, enable automatic background BIT (D2)
    if (showStatus) 
        base[DS_TEST_ENABLE] = 4;
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T   *IWork      = ssGetIWork(S);
    Register base       = (Register) IWork[BASE_I_IND];
    int_T    showStatus = mxGetPr(SHOW_STATUS_ARG)[0];
    int_T    nChans     = mxGetN(CHANNEL_ARG);

    int_T    i, chan;
    real_T  *y, revs;

    InputRealPtrsType uPtrs;

    // output position values
    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        uPtrs = ssGetInputPortRealSignalPtrs(S, i);
        revs = MOD1(*uPtrs[0] / 2 / PI);

        if (mxGetPr(TWO_SPEED_RATIO_ARG)[i] == 1) // 1-speed
            base[DS_DATA + 2 * chan] = revs * 0x10000;

        else if (mxGetPr(HI_RESOLUTION_ARG)[i] == 0) // 2-speed, 16-bit
            base[DS_DATA + 2 * chan - 1] = revs * 0x10000;
        
        else { // 2-speed, 24-bit 
            base[DS_DATA + 2 * chan] = ((int32_T)(revs * 0x1000000)) & 0xff;
            base[DS_DATA + 2 * chan - 1] = revs * 0x10000;
        }
    }

    // report status if requested
    if (showStatus) {
        y = ssGetOutputPortSignal(S, 0);
        y[0] = base[DS_TEST_STATUS];
        y[1] = base[DS_SIGNAL_STATUS];
        y[2] = base[DS_REFERENCE_STATUS];
    }

#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T   *IWork  = ssGetIWork(S);
    Register base   = (Register) IWork[BASE_I_IND];
    int_T    nChans = mxGetN(CHANNEL_ARG);
    
    int_T    i, chan;
    real_T   revs;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    for (i = 0; i < nChans; i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            chan = mxGetPr(CHANNEL_ARG)[i] - 1;
            revs = MOD1(mxGetPr(INIT_VAL_ARG)[i] / 2 / PI);

            if (mxGetPr(TWO_SPEED_RATIO_ARG)[i] == 1) // 1-speed
                base[DS_DATA + 2 * chan] = revs * 0x10000;

            else if (mxGetPr(HI_RESOLUTION_ARG)[i] == 0) // 2-speed, 16-bit
                base[DS_DATA + 2 * chan - 1] = revs * 0x10000;
        
            else { // 2-speed, 24-bit 
                base[DS_DATA + 2 * chan] = ((int32_T)(revs * 0x1000000)) & 0xff;
                base[DS_DATA + 2 * chan - 1] = revs * 0x10000;
            }
        }
    }
#endif
}


#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

