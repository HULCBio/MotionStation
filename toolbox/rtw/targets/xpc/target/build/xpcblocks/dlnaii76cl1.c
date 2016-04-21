// dlnaii76cl1.c - xPC Target, non-inlined S-function driver for the
// D/L section of the NAII Apex 76CL1 Series LVDT/RVDT boards
// Copyright 2003 The MathWorks, Inc.

#define S_FUNCTION_LEVEL         2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME          dlnaii76cl1

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

#define NUM_ARGS                 (11)
#define CHANNEL_ARG              ssGetSFcnParam(S,0) // vector int 1-6
#define RESET_ARG                ssGetSFcnParam(S,1) // vector boolean
#define INIT_VAL_ARG             ssGetSFcnParam(S,2) // vector double -1 to 1
#define WIRING_ARG               ssGetSFcnParam(S,3) // vector int 2-3
#define RATIO_ARG                ssGetSFcnParam(S,4) // vector double 0-2
#define SHOW_STATUS_ARG          ssGetSFcnParam(S,5) // boolean
#define FREQUENCY_ARG            ssGetSFcnParam(S,6) // double
#define VOLTAGE_ARG              ssGetSFcnParam(S,7) // double
#define SAMPLE_TIME_ARG          ssGetSFcnParam(S,8) // double
#define PCI_BUS_ARG              ssGetSFcnParam(S,9) // integer
#define PCI_SLOT_ARG             ssGetSFcnParam(S,10)// integer

#define VENDOR_ID                (uint16_T)(0x15ac)  // NAII
#define DEVICE_ID                (uint16_T)(0x7651)  // 76CL1
#define PCI_MEM_LEN              (1024)

#define BIT(n)                   (1 << n)

#define Register                 volatile uint16_T *

// 16-bit-register offsets

#define POSITION_CHAN_A_DATA     (0x0E4 / 2) // read/write
#define POSITION_CHAN_B_DATA     (0x0E8 / 2) // read/write
#define TRANSFORMER_RATIO        (0x114 / 2) // read/write
#define WRAP_AROUND_DL           (0x12C / 2) // read
#define WIRE_MODE_DL             (0x19C / 2) // read/write
#define SIGNAL_STATUS_DL         (0x1A0 / 2) // read
#define EXCITATION_STATUS_DL     (0x1A4 / 2) // read
#define TEST_STATUS_DL           (0x1A8 / 2) // read
#define ACTIVE_CHANNELS_DL       (0x1AC / 2) // read/write
#define TEST_D2_VERIFY_DL        (0x1B0 / 2) // read/write
#define TEST_ENABLE_DL           (0x1B4 / 2) // read/write
#define OUTPUTS_ON_OFF           (0x1B8 / 2) // read/write


#define INTERRUPT_ENABLE         (0x1BC / 2) // read/write
#define INTERRUPT_STATUS         (0x1C0 / 2) // read
#define REFERENCE_FREQUENCY      (0x1C4 / 2) // read/write
#define REFERENCE_VOLTAGE        (0x1C8 / 2) // read/write
#define WATCHDOG_TIMER           (0x1CC / 2) // read/write
#define SOFT_RESET               (0x1D0 / 2) // write
#define PART_NUMBER              (0x1D4 / 2) // read
#define SERIAL_NUMBER            (0x1D8 / 2) // read
#define DATA_CODE                (0x1DC / 2) // read
#define REV_LEVEL_PCB            (0x1E0 / 2) // read
#define REV_LEVEL_DSP_MASTER     (0x1E4 / 2) // read
#define REV_LEVEL_FPGA_MASTER    (0x1E8 / 2) // read
#define REV_LEVEL_DSP_SLAVE      (0x1EC / 2) // read
#define REV_LEVEL_FPGA_SLAVE     (0x1F0 / 2) // read
#define REV_LEVEL_INTERFACE_FPGA (0x1F4 / 2) // read
#define BOARD_READY              (0x1F8 / 2) // read

#define NUM_I_WORKS              (1)
#define NUM_R_WORKS              (0)
#define BASE_I_IND               (0)

#define MAX_DL                   (6)
#define MAX_POSITION             (32767)
#define MIN_POSITION             (-32768)

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
        width = (mxGetPr(WIRING_ARG)[i] == 2) ? 2 : 1;
        ssSetInputPortWidth(S, i, width);
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

    uint16_T read1, read2, active, output, wiring, ratio;
    int_T    i, chan;
    void    *addr;
    Register base;

    PCIDeviceInfo pciInfo;

    if (pciSlot < 0) {
        if (rl32eGetPCIInfo(VENDOR_ID, DEVICE_ID, &pciInfo)) {
            sprintf(msg, "No NAII Apex 76CL1 found");
            ssSetErrorStatus(S, msg);
            return;
        }
    } 
    else if (rl32eGetPCIInfoAtSlot(VENDOR_ID, DEVICE_ID, busSlot, &pciInfo)) {
        sprintf(msg, "No NAII Apex 76CL1 at bus %d slot %d", pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    addr = (void *) pciInfo.BaseAddress[0];
    base = (Register) rl32eGetDevicePtr(addr, PCI_MEM_LEN, RT_PG_USERREADWRITE);

    IWork[BASE_I_IND] = (int_T) base;

    // Check the 76CL1 by writing test values to the watchdog timer. 
    // These should be inverted by the board within 100 microseconds.

    base[WATCHDOG_TIMER] = write1;
    rl32eWaitDouble(0.0001);
    read1 = base[WATCHDOG_TIMER];

    base[WATCHDOG_TIMER] = write2;
    rl32eWaitDouble(0.0001);
    read2 = base[WATCHDOG_TIMER];

    if((read1 != write2) || (read2 != write1)) {
        sprintf(msg, "Unresponsive NAII Apex 76CL1 at bus %d slot %d", 
            pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    for (i = active = output = wiring = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        if (chan >= MAX_DL) {
            sprintf(msg, "No such NAII Apex 76CL1 D/L channel: %d", chan+1);
            ssSetErrorStatus(S, msg);
            return;
        }

        active  |= BIT(chan << 1) * 3;
        output  |= BIT(chan);

        if (mxGetPr(WIRING_ARG)[i] == 2)
            wiring |= BIT(chan);

        ratio = 1000 * mxGetPr(RATIO_ARG)[i];

        base[TRANSFORMER_RATIO + 2 * chan] = ratio;
    }

    base[ACTIVE_CHANNELS_DL] = active;
    base[WIRE_MODE_DL] = wiring;
    base[OUTPUTS_ON_OFF] = output;

    base[REFERENCE_FREQUENCY] = frequency;
    base[REFERENCE_VOLTAGE] = 10 * voltage;

    // enable automatic background BIT (D2) if requested
    if (showStatus) {
        base[TEST_ENABLE_DL] = 4;
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T   *IWork      = ssGetIWork(S);
    Register base       = (Register) IWork[BASE_I_IND];
    int_T    nChans     = mxGetN(CHANNEL_ARG);
    int_T    showStatus = mxGetPr(SHOW_STATUS_ARG)[0];

    int_T     i, chan;
    real_T   *y, position;

    InputRealPtrsType uPtrs;

    // read status if requested
    if (showStatus) {
        y = ssGetOutputPortSignal(S, 0);
        y[0] = base[TEST_STATUS_DL];
        y[1] = base[SIGNAL_STATUS_DL];
        y[2] = base[EXCITATION_STATUS_DL];
    }

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        uPtrs = ssGetInputPortRealSignalPtrs(S, i);
        position = *uPtrs[0] * (MAX_POSITION + 1);

        if (position > MAX_POSITION) 
            position = MAX_POSITION;
        if (position < MIN_POSITION) 
            position = MIN_POSITION;

        base[POSITION_CHAN_A_DATA + 4 * chan] = (uint16_T) position;

        // if 2-wire, output the B channel
        if (mxGetPr(WIRING_ARG)[i] == 2) {
            position = *uPtrs[1] * (MAX_POSITION + 1);

            if (position > MAX_POSITION) 
                position = MAX_POSITION;
            if (position < MIN_POSITION) 
                position = MIN_POSITION;

            base[POSITION_CHAN_A_DATA + 4 * chan + 2] = (uint16_T) position;
        }
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
    real_T   position;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    for (i = 0; i < nChans; i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            chan = mxGetPr(CHANNEL_ARG)[i] - 1;

            position = mxGetPr(INIT_VAL_ARG)[i] * (MAX_POSITION + 1);

            if (position > MAX_POSITION) 
                position = MAX_POSITION;
            if (position < MIN_POSITION) 
                position = MIN_POSITION;

            base[POSITION_CHAN_A_DATA + 4 * chan] = (uint16_T) position;

            if (mxGetPr(WIRING_ARG)[i] == 2) { // 2-wire
                base[POSITION_CHAN_A_DATA + 4 * chan + 2] = (uint16_T) position;
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
