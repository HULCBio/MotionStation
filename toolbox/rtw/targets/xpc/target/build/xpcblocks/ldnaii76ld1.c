// ldnaii76ld1.c - xPC Target, non-inlined S-function driver for the
// L/D section of the NAII Apex 76LD1 Series LVDT/RVDT boards
// Copyright 2003 The MathWorks, Inc.

#define S_FUNCTION_LEVEL         2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME          ldnaii76ld1

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
#endif

#define NUM_ARGS                 (9)
#define CHANNEL_ARG              ssGetSFcnParam(S, 0) // vector int 1-12
#define WIRING_ARG               ssGetSFcnParam(S, 1) // vector int 2-3
#define FORMAT_ARG               ssGetSFcnParam(S, 2) // format_T (defined below)
#define LATCH_ARG                ssGetSFcnParam(S, 3) // boolean
#define FREQUENCY_ARG            ssGetSFcnParam(S, 4) // double
#define VOLTAGE_ARG              ssGetSFcnParam(S, 5) // double
#define SAMPLE_TIME_ARG          ssGetSFcnParam(S, 6) // double
#define PCI_BUS_ARG              ssGetSFcnParam(S, 7) // integer
#define PCI_SLOT_ARG             ssGetSFcnParam(S, 8) // integer

#define VENDOR_ID                (uint16_T)(0x15ac)   // NAII
#define DEVICE_ID                (uint16_T)(0x7631)   // 76LD1

#define PCI_MEM_LEN              (1024)
#define MAX_LD                   (12)

#define BIT(n)                   (1 << n)

#define Register                 volatile uint16_T *

// 16-bit-register offsets

#define LD_DATA                  (0x000 / 2) // read
#define LD_VELOCITY              (0x030 / 2) // read
#define SCALE                    (0x060 / 2) // read/write
#define ACTIVE_CHANNELS_LD       (0x090 / 2) // read/write
#define TEST_D2_VERIFY_LD        (0x094 / 2) // read/write
#define TEST_ENABLE_LD           (0x098 / 2) // read/write
#define SIGNAL_STATUS_LD         (0x09C / 2) // read
#define EXCITATION_STATUS_LD     (0x0A0 / 2) // read
#define TEST_STATUS_LD           (0x0A4 / 2) // read
#define LATCH                    (0x0A8 / 2) // write
#define LVDTD_TEST_POSITION      (0x0AC / 2) // read/write
#define WIRE_MODE_LD             (0x0B0 / 2) // read/write
#define A_B_RESOLUTION           (0x0B4 / 2) // read/write
#define VELOCITY_SCALE           (0x0E4 / 2) // read/write
#define MAGNITUDE_A_B            (0x114 / 2) // read/write

#define INTERRUPT_ENABLE         (0x1C4 / 2) // read/write
#define INTERRUPT_STATUS         (0x1C8 / 2) // read
#define REFERENCE_FREQUENCY      (0x1CC / 2) // read/write
#define REFERENCE_VOLTAGE        (0x1D0 / 2) // read/write
#define WATCHDOG_TIMER           (0x1D4 / 2) // read/write
#define SOFT_RESET               (0x1D8 / 2) // write
#define PART_NUMBER              (0x1DC / 2) // read
#define SERIAL_NUMBER            (0x1E0 / 2) // read
#define DATE_CODE                (0x1E4 / 2) // read
#define REV_LEVEL_PCB            (0x1E8 / 2) // read
#define REV_LEVEL_DSP_MASTER     (0x1EC / 2) // read
#define REV_LEVEL_FPGA_MASTER    (0x1F0 / 2) // read
#define REV_LEVEL_DSP_SLAVE      (0x1F4 / 2) // read
#define REV_LEVEL_FPGA_SLAVE     (0x1F8 / 2) // read
#define REV_LEVEL_INTERFACE_FPGA (0x1FC / 2) // read
#define BOARD_READY              (0x200 / 2) // read

#define NUM_I_WORKS              (1)
#define NUM_R_WORKS              (0)
#define BASE_I_IND               (0)

#define MAX_DL                   (6)

typedef enum { // possible values of FORMAT_ARG
    POSITION = 1,
    POSITION_STATUS,
    POSITION_VELOCITY,
    POSITION_VELOCITY_STATUS } format_T;

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T  nChans  = mxGetN(CHANNEL_ARG);
    int_T  format  = mxGetPr(FORMAT_ARG)[0];
    int_T  i, width;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
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

    ssSetNumInputPorts(S, 0);
    ssSetNumOutputPorts(S, nChans);

    switch (format) {
        case POSITION:
                width = 1; break;
        case POSITION_STATUS:
                width = 2; break;
        case POSITION_VELOCITY:
                width = 2; break;
        case POSITION_VELOCITY_STATUS:
                width = 3; break;
    }

    for (i = 0; i < nChans; i++) 
        ssSetOutputPortWidth(S, i, width);
    
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
    int_T   *IWork     = ssGetIWork(S);
    int_T    nChans    = mxGetN(CHANNEL_ARG);
    int_T    pciSlot   = mxGetPr(PCI_SLOT_ARG)[0];
    int_T    pciBus    = mxGetPr(PCI_BUS_ARG)[0];
    int_T    busSlot   = pciSlot + pciBus * 256;
    int_T    format    = mxGetPr(FORMAT_ARG)[0];
    int_T    frequency = mxGetPr(FREQUENCY_ARG)[0];
    int_T    voltage   = mxGetPr(VOLTAGE_ARG)[0];
    uint16_T write1    = 0xA5A5;
    uint16_T write2    = ~write1;

    uint16_T read1, read2, active, wiring;
    int_T    i, chan;
    void    *addr;
    Register base;

    PCIDeviceInfo pciInfo;

    if (pciSlot < 0) {
        if (rl32eGetPCIInfo(VENDOR_ID, DEVICE_ID, &pciInfo)) {
            sprintf(msg, "No NAII Apex 76LD1 found");
            ssSetErrorStatus(S, msg);
            return;
        }
    } 
    else if (rl32eGetPCIInfoAtSlot(VENDOR_ID, DEVICE_ID, busSlot, &pciInfo)) {
        sprintf(msg, "No NAII Apex 76LD1 at bus %d slot %d", pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    addr = (void *) pciInfo.BaseAddress[0];
    base = (Register) rl32eGetDevicePtr(addr, PCI_MEM_LEN, RT_PG_USERREADWRITE);

    IWork[BASE_I_IND] = (int_T) base;

    // Check the 76LD1 by writing test values to the watchdog timer. 
    // These should be inverted by the board within 100 microseconds.

    base[WATCHDOG_TIMER] = write1;
    rl32eWaitDouble(0.0001);
    read1 = base[WATCHDOG_TIMER];

    base[WATCHDOG_TIMER] = write2;
    rl32eWaitDouble(0.0001);
    read2 = base[WATCHDOG_TIMER];

    if((read1 != write2) || (read2 != write1)) {
        sprintf(msg, "Unresponsive NAII Apex 76LD1 at bus %d slot %d", 
            pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    for (i = active = wiring = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        if (chan >= MAX_LD) {
            sprintf(msg, "No such NAII Apex 76LD1 L/D channel: %d", chan + 1);
            ssSetErrorStatus(S, msg);
            return;
        }

        active |= BIT(chan << 1) * 3;

        if (mxGetPr(WIRING_ARG)[i] == 2)
            wiring |= BIT(chan);
    }

    base[ACTIVE_CHANNELS_LD] = active;
    base[WIRE_MODE_LD] = wiring;

    base[REFERENCE_FREQUENCY] = frequency;
    base[REFERENCE_VOLTAGE] = 10 * voltage;

    // enable automatic background BIT (D2) if requested
    if (format == POSITION_STATUS || format == POSITION_VELOCITY_STATUS)
        base[TEST_ENABLE_LD] = 4;
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T   *IWork  = ssGetIWork(S);
    Register base   = (Register) IWork[BASE_I_IND];
    int_T    nChans = mxGetN(CHANNEL_ARG);
    int_T    format = mxGetPr(FORMAT_ARG)[0];
    real_T   vscale = 152.5878 / 32768;
    real_T   fudge  = 152.5878 / 1000;

    int_T    i, chan, sigStat, excStat, tstStat;
    real_T  *y, position, velocity, status;

    // get status if necessary
    switch (format) {
    case POSITION_STATUS:
    case POSITION_VELOCITY_STATUS:
        sigStat = base[SIGNAL_STATUS_LD];
        excStat = base[EXCITATION_STATUS_LD];
        tstStat = base[TEST_STATUS_LD];
        break;
    }

    for (i = 0; i < nChans; i++) {
        y = ssGetOutputPortSignal(S, i);
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        // get position
        position = (real_T)(int16_T) base[LD_DATA + 2 * chan]; 
        position /= 0x8000; // normalize to lie between -1 and 1

        // get velocity if necessary
        switch (format) {
        case POSITION_VELOCITY:
        case POSITION_VELOCITY_STATUS:
            velocity = (real_T)(int16_T) base[LD_VELOCITY + 2 * chan];
            velocity *= vscale; // normalize to lie between -1 and 1
            velocity *= fudge;  // empirical fudge factor
            break;
        }

        // compute channel status if necessary
        switch (format) {
        case POSITION_STATUS:
        case POSITION_VELOCITY_STATUS:
            status = ((sigStat >> chan) & 1)
                   | ((excStat >> chan) & 1) * 2
                   | ((tstStat >> chan) & 1) * 4;
            break;
        }

        // output as appropriate
        switch (format) {
        case POSITION:
            y[0] = position;
            break;
        case POSITION_STATUS:
            y[0] = position;
            y[1] = status;
            break;
        case POSITION_VELOCITY:
            y[0] = position;
            y[1] = velocity;
            break;
        case POSITION_VELOCITY_STATUS:
            y[0] = position;
            y[1] = velocity;
            y[2] = status;
            break;
        }
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
