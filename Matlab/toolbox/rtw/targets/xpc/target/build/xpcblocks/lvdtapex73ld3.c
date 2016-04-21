/* $Revision: 1.4.6.1 $ */
// lvdtapex73ld3.c - xPC Target, non-inlined S-function driver for
// the Apex 73LD3 Series LVDT/RVDT converters
// Copyright 2002-2003 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   lvdtapex73ld3

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h"

#ifdef      MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef     MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "time_xpcimport.h"
#endif

#define NUM_ARGS           (10)
#define CHANNEL_ARG        ssGetSFcnParam(S, 0) // vector of {1:6}
#define SIGNAL_SCALE_ARG   ssGetSFcnParam(S, 1) // vector of {0:0xFFFF}
#define VELOCITY_SCALE_ARG ssGetSFcnParam(S, 2) // vector of double
#define DYNAMIC_SCALE_ARG  ssGetSFcnParam(S, 3) // double (boolean)
#define FORMAT_ARG         ssGetSFcnParam(S, 4) // format_T (defined below)
#define WIRING_ARG         ssGetSFcnParam(S, 5) // wiring_T (defined below)
#define HERTZ_ARG          ssGetSFcnParam(S, 6) // double
#define VRMS_ARG           ssGetSFcnParam(S, 7) // double
#define SAMPLE_TIME_ARG    ssGetSFcnParam(S, 8) // double
#define BASE_ARG           ssGetSFcnParam(S, 9) // 0x000 .. 0x3e0

#define NUM_I_WORKS        (0)
#define NUM_R_WORKS        (0)

#define PAGE_REGISTER      (0x1E)
#define PAGE(n)            (n-1)

#define POSITION_DATA      (0x00) // PAGE(1) register offsets
#define SIGNAL_SCALE       (0x10)
#define WIRING_SELECT      (0x1C)

#define VELOCITY_DATA      (0x00) // PAGE(2) register offsets
#define VELOCITY_SCALE     (0x10)

#define ACTIVE_CHANNELS    (0x00) // PAGE(3) register offsets
#define TEST_D2_VERIFY     (0x02)
#define TEST_ENABLE        (0x04)
#define TEST_POSITION      (0x06)
#define LATCH              (0x08)
#define POST_ENABLE        (0x0A)
#define SIGNAL_STATUS      (0x10)
#define EXCITATION_STATUS  (0x12)
#define TEST_STATUS        (0x14)
#define SUMMARY_STATUS     (0x16)
#define EXCITATION_HERTZ   (0x1A)
#define EXCITATION_VRMS    (0x1C)

#define A_AND_B_RESOLUTION (0x10) // PAGE(4) register offsets

#define WATCHDOG_TIMER     (0x00) // PAGE(5) register offsets
#define SOFT_RESET         (0x02)
#define PART_NUMBER        (0x04)
#define SERIAL_NUMBER      (0x06)
#define DATE_CODE          (0x08)
#define PCB_REV            (0x0A)
#define SOFTWARE_REV       (0x0C)
#define FPGA_REV           (0x0E)
#define SAVE               (0x10)

#define BANK_SELECT_0_7    (0x00) // PAGE(6) register offsets
#define BANK_SELECT_8_15   (0x02)
#define OUTPUT             (0x04)
#define INPUT              (0x06)

#define A_PLUS_B_MAGNITUDE (0x00) // PAGE(7) register offsets

#define NUM_CHANS          (6)
#define MIN_VELOCITY_SCALE (0x0FFF)
#define MAX_VELOCITY_SCALE (0xFFF0)

typedef enum { // possible values of WIRING_ARG
    TWO_WIRE = 1,
    THREE_OR_FOUR_WIRE } wiring_T;

typedef enum { // possible values of FORMAT_ARG
    POSITION = 1,
    POSITION_STATUS,
    POSITION_VELOCITY,
    POSITION_VELOCITY_STATUS } format_T;

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T    dynamic = (format_T) mxGetPr(DYNAMIC_SCALE_ARG)[0];
    format_T format  = (format_T) mxGetPr(FORMAT_ARG)[0];
    int_T    nChans  = (int_T) mxGetN(CHANNEL_ARG);
    int_T    i, width;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d input args expected, %d passed", NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, nChans);

    switch (format) {
        case POSITION:
                width = 1;
                break;
        case POSITION_STATUS:
        case POSITION_VELOCITY:
                width = 2;
                break;
        case POSITION_VELOCITY_STATUS:
                width = 3;
                break;
    }

    for (i = 0; i < nChans; i++) {
        ssSetOutputPortWidth(S, i, width);
    }

    if (dynamic) {
        ssSetNumInputPorts(S, nChans);
        for (i = 0; i < nChans; i++) {
            ssSetInputPortWidth(S, i, 1);
            ssSetInputPortDirectFeedThrough(S, i, 1);
        }
    } else {
        ssSetNumInputPorts(S, 0);
    }

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
    if (mxGetPr(SAMPLE_TIME_ARG)[0] == -1.0) {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    } else {
        ssSetSampleTime(S, 0, mxGetPr(SAMPLE_TIME_ARG)[0]);
        ssSetOffsetTime(S, 0, 0.0);
    }
}

#ifndef MATLAB_MEX_FILE
static void debugPrintRegisters(int_T base)
{
    int_T    i, x, y;
    uint16_T word;

    for (i = 1 ; i <= 7; i++) {

        printf("page %d\n", i);

        rl32eOutpW(base + PAGE_REGISTER, PAGE(i));

        for (y = 0; y < 8; y += 2){
            for (x = y; x < y + 32; x += 8) {
                word = rl32eInpW(base + x);
                printf(" %02X:%04X", x, word);
            }
            printf("\n");
        }
    }
}
#endif

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T     base   = (int_T) mxGetPr(BASE_ARG)[0];
    wiring_T  wiring = (wiring_T) mxGetPr(WIRING_ARG)[0];
    format_T  format = (format_T) mxGetPr(FORMAT_ARG)[0];
    int_T     hertz  = (int_T) mxGetPr(HERTZ_ARG)[0];
    int_T     vrms   = (int_T) (10.0 * mxGetPr(VRMS_ARG)[0]);
    int_T     nChans = (int_T) mxGetN(CHANNEL_ARG);
    uint16_T  write1 = 0xA5A5;
    uint16_T  write2 = ~write1;
    int_T     bit[NUM_CHANS] = {1, 2, 4, 8, 16, 32};

    uint16_T  i, chan, read1, read2, activeChans, sigScale;
    real_T    velScale;

    // check that a 73LD3 is present by writing values to the
    // watchdog timer register - any value written should be
    // inverted by the board within 100 microseconds
    rl32eOutpW(base + PAGE_REGISTER, PAGE(5));
    //
    rl32eOutpW(base + WATCHDOG_TIMER, write1);
    rl32eWaitDouble(0.0001);
    read1 = rl32eInpW(base + WATCHDOG_TIMER);
    //
    rl32eOutpW(base + WATCHDOG_TIMER, write2);
    rl32eWaitDouble(0.0001);
    //
    read2 = rl32eInpW(base + WATCHDOG_TIMER);
    //
    if((read1 != write2) || (read2 != write1)) {
        sprintf(msg, "no 73LD3 detected at base address %03x hex", base);
        ssSetErrorStatus(S, msg);
        return;
    }

    activeChans = 0;

    // set the signal scale for each channel
    rl32eOutpW(base + PAGE_REGISTER, PAGE(1));
    for (i = 0; i < nChans; i++) {
        chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
        activeChans |= bit[chan];
        sigScale = (uint16_T) mxGetPr(SIGNAL_SCALE_ARG)[i];
        rl32eOutpW(base + SIGNAL_SCALE + 2 * chan, sigScale);
    }

    // set the active channels
    rl32eOutpW(base + PAGE_REGISTER, PAGE(3));
    rl32eOutpW(base + ACTIVE_CHANNELS, activeChans);


    // set the velocity scale for each channel
    rl32eOutpW(base + PAGE_REGISTER, PAGE(2));
    for (i = 0; i < nChans; i++) {
        chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
        velScale = 4095.0 * 150.0 / mxGetPr(VELOCITY_SCALE_ARG)[i];
        if (velScale < MIN_VELOCITY_SCALE)
            velScale = MIN_VELOCITY_SCALE;
        if (velScale > MAX_VELOCITY_SCALE)
            velScale = MAX_VELOCITY_SCALE;
       rl32eOutpW(base + VELOCITY_SCALE + 2 * chan, (uint16_T)velScale);
    }

    // set the wiring
    rl32eOutpW(base + PAGE_REGISTER, PAGE(1));
    switch (wiring) {
    case TWO_WIRE:
        rl32eOutpW(base + WIRING_SELECT, 1);
        break;
    case THREE_OR_FOUR_WIRE:
        rl32eOutpW(base + WIRING_SELECT, 0);
        break;
    }

    // set the excitation signal frequency and voltage
    rl32eOutpW(base + PAGE_REGISTER, PAGE(3));
    rl32eOutpW(base + EXCITATION_HERTZ, hertz);
    rl32eOutpW(base + EXCITATION_VRMS, vrms);

    // if status output is requested, enable automatic background BIT
    if (format == POSITION_STATUS || format == POSITION_VELOCITY_STATUS)
        rl32eOutpW(base + TEST_ENABLE, 4);

    // debugPrintRegisters(base);
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T     base    = (int_T) mxGetPr(BASE_ARG)[0];
    int_T     nChans  = (int_T) mxGetN(CHANNEL_ARG);
    format_T  format  = (format_T) mxGetPr(FORMAT_ARG)[0];
    int_T     dynamic = (format_T) mxGetPr(DYNAMIC_SCALE_ARG)[0];
    int_T     bit[NUM_CHANS] = {1, 2, 4, 8, 16, 32};

    real_T    velScale;
    int_T     i, chan, temp, tstStatus, sigStatus, excStatus;
    real_T   *y, position[NUM_CHANS], velocity[NUM_CHANS], status[NUM_CHANS];

    InputRealPtrsType uPtrs;

    // get position
    rl32eOutpW(base + PAGE_REGISTER, PAGE(1));
    //
    for (i = 0; i < nChans; i++) {
        chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
        position[chan] = (real_T) (int16_T) rl32eInpW(base + POSITION_DATA + 2 * chan);
   }

    // get velocity if requested
    if (format == POSITION_VELOCITY || format == POSITION_VELOCITY_STATUS) {
        rl32eOutpW(base + PAGE_REGISTER, PAGE(2));

        for (i = 0; i < nChans; i++) {
            chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
            velocity[chan] = (int16_T) rl32eInpW(base + VELOCITY_DATA + 2 * chan);
        }
    }

    // get status if requested
    if (format == POSITION_STATUS || format == POSITION_VELOCITY_STATUS) {
        rl32eOutpW(base + PAGE_REGISTER, PAGE(3));
        tstStatus = rl32eInpW(base + TEST_STATUS);
        sigStatus = rl32eInpW(base + SIGNAL_STATUS);
        excStatus = rl32eInpW(base + EXCITATION_STATUS);

        for (i = 0; i < nChans; i++) {
            chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
            temp = 0;
            if (tstStatus & bit[chan])
                temp &= 1;
            if (sigStatus & bit[chan])
                temp &= 2;
            if (excStatus & bit[chan])
                temp &= 4;
            status[chan] = (real_T) temp;
       }
    }

    // output the signals
    for (i = 0; i < nChans; i++) {
        y = ssGetOutputPortSignal(S, i);
        chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

        switch (format) {
        case POSITION:
            y[0] = position[chan];
            break;
        case POSITION_STATUS:
            y[0] = position[chan];
            y[1] = status[chan];
            break;
        case POSITION_VELOCITY:
            y[0] = position[chan];
            y[1] = velocity[chan];
            break;
        case POSITION_VELOCITY_STATUS:
            y[0] = position[chan];
            y[1] = velocity[chan];
            y[2] = status[chan];
            break;
        }
    }

    // set the velocity scale dynamically for each channel if requested
    if (dynamic) {
        rl32eOutpW(base + PAGE_REGISTER, PAGE(2));

        for (i = 0; i < nChans; i++) {
            chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
            uPtrs = ssGetInputPortRealSignalPtrs(S, i);
            if (*uPtrs[0] * MAX_VELOCITY_SCALE <= 4095.0 * 150.0)
                velScale = MAX_VELOCITY_SCALE;
            else if (*uPtrs[0] * MIN_VELOCITY_SCALE >= 4095.0 * 150.0)
                velScale = MIN_VELOCITY_SCALE;
            else
                velScale = 4095.0 * 150.0 / *uPtrs[0];
            rl32eOutpW(base + VELOCITY_SCALE + 2 * chan, (uint16_T)velScale);
        }
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
