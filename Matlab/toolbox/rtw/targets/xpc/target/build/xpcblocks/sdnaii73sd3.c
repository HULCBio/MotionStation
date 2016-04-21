// sdnaii73sd3.c - xPC Target, non-inlined S-function driver for
// the NAII PC104-73SD3 Series Synchro/Resolver converters
// Copyright 2003 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   sdnaii73sd3

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

#define NUM_ARGS             (12)
#define CHANNEL_ARG          ssGetSFcnParam(S,0)  // vector of double
#define TWO_SPEED_RATIO_ARG  ssGetSFcnParam(S,1)  // vector of double >= 1
#define HI_RESOLUTION_ARG    ssGetSFcnParam(S,2)  // vector of boolean
#define ENCODER_ARG          ssGetSFcnParam(S,3)  // vector of double
#define LATCH_ARG            ssGetSFcnParam(S,4)  // boolean
#define MAX_RPS_ARG          ssGetSFcnParam(S,5)  // vector of double
#define DYNAMIC_MAX_RPS_ARG  ssGetSFcnParam(S,6)  // boolean
#define FORMAT_ARG           ssGetSFcnParam(S,7)  // Format_T (see below)
#define FREQUENCY_ARG        ssGetSFcnParam(S,8)  // double
#define VOLTAGE_ARG          ssGetSFcnParam(S,9)  // double
#define SAMPLE_TIME_ARG      ssGetSFcnParam(S,10) // double
#define BASE_ARG             ssGetSFcnParam(S,11) // 0x000 .. 0x3e0

#define NUM_I_WORKS          (0)
#define NUM_R_WORKS          (0)

                         // PAGE(1) byte offsets
#define DATA_HI              (0x00) // read
#define DATA_LO              (0x10) // read
#define TWO_SPEED_LOSS       (0x16) // read
#define RATIO                (0x18) // read/write

                         // PAGE(2) byte offsets 
#define VELOCITY             (0x00) // read
#define VELOCITY_SCALE       (0x10) // read/write

                         // PAGE(3) byte offsets 
#define ACTIVE_CHANNELS      (0x00) // read/write 
#define TEST_D2_VERIFY       (0x02) // read/write
#define TEST_ENABLE          (0x04) // read/write
#define TEST_ANGLE           (0x06) // read/write
#define LATCH                (0x08) // write
#define POST_ENABLE          (0x0A) // read/write
#define SIGNAL_STATUS        (0x10) // read
#define REFERENCE_STATUS     (0x12) // read
#define TEST_STATUS          (0x14) // read
#define SUMMARY_STATUS       (0x16) // read
#define REFERENCE_FREQUENCY  (0x1A) // read/write
#define REFERENCE_VOLTAGE    (0x1C) // read/write

                         // PAGE(4) byte offsets 
#define ANGLE_DELTA          (0x00) // read/write
#define ANGLE_DELTA_INIT     (0x0C) // read/write
#define ANGLE_DELTA_ALERT    (0x0E) // read/write
#define A_B_RESOLUTION       (0x10) // read/write
 
                         // PAGE(5) byte offsets 
#define WATCHDOG_TIMER       (0x00) // read/write
#define SOFT_RESET           (0x02) // write
#define PART_NUMBER          (0x04) // read
#define SERIAL_NUMBER        (0x06) // read
#define DATE_CODE            (0x08) // read
#define PCB_REV              (0x0A) // read
#define DSP_REV              (0x0C) // read
#define FPGA_REV             (0x0E) // read
#define SAVE                 (0x10) // read/write

                         // PAGE(6) byte offsets 
#define BANK_SELECT_0_7      (0x00) // read/write 
#define BANK_SELECT_8_15     (0x02) // read/write
#define OUTPUT               (0x04) // read/write
#define INPUT                (0x06) // read

                         // PAGE(7) byte offsets 
#define CUMULATIVE_TURNS     (0x00) // read/write 

#define PAGE_REGISTER        (0x1E)
#define PAGE(n)              (n-1)

#define MAX_CHAN             (6)
#define LO_MAX_RPS           (9.5367)
#define HI_MAX_RPS           (152.5878)
#define PI                   (3.14159265358979)

#define CLAMP_LO(x, lo)      ((x) < (lo) ? (lo) : (x))
#define CLAMP_HI(x, hi)      ((x) > (hi) ? (hi) : (x))
#define CLAMP(x, lo, hi)     (CLAMP_LO(CLAMP_HI(x, hi), lo))

#define BIT(n)               (1 << n)

typedef enum { // possible values of FORMAT_ARG
    POSITION = 1,
    POSITION_STATUS,
    POSITION_VELOCITY,
    POSITION_VELOCITY_STATUS } Format_T;

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    Format_T format  = (Format_T) mxGetPr(FORMAT_ARG)[0];
    int_T    dynamic = mxGetPr(DYNAMIC_MAX_RPS_ARG)[0];
    int_T    nChans  = (int_T) mxGetN(CHANNEL_ARG);
    int_T    i, width;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
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

#ifdef XPC_DEBUG
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
    int_T     base      = (int_T) mxGetPr(BASE_ARG)[0];
    int_T     nChans    = (int_T) mxGetN(CHANNEL_ARG);
    Format_T  format    = (Format_T) mxGetPr(FORMAT_ARG)[0];
    int_T     frequency = (int_T) mxGetPr(FREQUENCY_ARG)[0];
    int_T     voltage   = (int_T) (10.0 * mxGetPr(VOLTAGE_ARG)[0]);
    uint16_T  write1    = 0xA5A5;
    uint16_T  write2    = ~write1;

    uint16_T  i, chan, read1, read2, code, encoder, ratio, active, velScale;
    real_T    maxRps;

    // Check the 73SD3 by writing test values to the watchdog timer. 
    // These should be inverted by the board within 100 microseconds.
    
    rl32eOutpW(base + PAGE_REGISTER, PAGE(5));

    rl32eOutpW(base + WATCHDOG_TIMER, write1);
    rl32eWaitDouble(0.0001);
    read1 = rl32eInpW(base + WATCHDOG_TIMER);

    rl32eOutpW(base + WATCHDOG_TIMER, write2);
    rl32eWaitDouble(0.0001);
    read2 = rl32eInpW(base + WATCHDOG_TIMER);

    if((read1 != write2) || (read2 != write1)) {
        sprintf(msg, "Unresponsive NAII Apex 73SD3 at base %03x hex", base);
        ssSetErrorStatus(S, msg);
        return;
    }

    for (i = active = 0; i < nChans; i++) {
        chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

        if (chan < 0 || chan >= MAX_CHAN) {
            sprintf(msg, "The NAII PC104-73SD3 has no S/D channel %d", chan+1);
            ssSetErrorStatus(S, msg);
            return;
        }

        // only even (1-based) channels can have ratios other than 1
        if (chan % 2) { 
            ratio = mxGetPr(TWO_SPEED_RATIO_ARG)[i];
            rl32eOutpW(base + PAGE_REGISTER, PAGE(1));
            rl32eOutpW(base + RATIO + chan - 1, ratio);
        } 

        // set the velocity scale
        maxRps = CLAMP(mxGetPr(MAX_RPS_ARG)[i], LO_MAX_RPS, HI_MAX_RPS);
        velScale = (uint16_T) (0xfff * HI_MAX_RPS / maxRps);
        rl32eOutpW(base + PAGE_REGISTER, PAGE(2));
        rl32eOutpW(base + VELOCITY_SCALE + 2 * chan, velScale);

        // add to active channel list
        active |= BIT(chan);

        // configure commutator/encoder outputs
        encoder = mxGetPr(ENCODER_ARG)[i];
        switch (encoder) {
            case  4: code = 0x8000; break; // 4-pole commutator
            case  6: code = 0x8001; break; // 6-pole commutator
            case  8: code = 0x8002; break; // 8-pole commutator
            case 12: code = 0x0004; break; // 12-bit encoder
            case 13: code = 0x0003; break; // 13-bit encoder
            case 14: code = 0x0002; break; // 14-bit encoder
            case 15: code = 0x0001; break; // 15-bit encoder
            case 16: code = 0x0000; break; // 16-bit encoder
            default: code = 0x0000;
        }
        rl32eOutpW(base + PAGE_REGISTER, PAGE(4));
        rl32eOutpW(base + A_B_RESOLUTION + 2 * chan, code);
    }

    // set the active channels, excitation signal frequency and voltage
    rl32eOutpW(base + PAGE_REGISTER, PAGE(3));
    rl32eOutpW(base + ACTIVE_CHANNELS, active);
    rl32eOutpW(base + REFERENCE_FREQUENCY, frequency);
    rl32eOutpW(base + REFERENCE_VOLTAGE, voltage);

    // if status output is requested, enable automatic background BIT
    if (format == POSITION_STATUS || format == POSITION_VELOCITY_STATUS)
        rl32eOutpW(base + TEST_ENABLE, 4);

#ifdef XPC_DEBUG
    debugPrintRegisters(base);
#endif

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T    base    = (int_T) mxGetPr(BASE_ARG)[0];
    int_T    nChans  = (int_T) mxGetN(CHANNEL_ARG);
    int_T    latch   = (int_T) mxGetPr(LATCH_ARG)[0];
    int_T    dynamic = (int_T) mxGetPr(DYNAMIC_MAX_RPS_ARG)[0];
    Format_T format  = (Format_T) mxGetPr(FORMAT_ARG)[0];

    int_T    i, chan, ratio, hiRes, dataLo, tstStatus, sigStatus, refStatus;
    real_T  *y, position[MAX_CHAN], velocity[MAX_CHAN], status[MAX_CHAN];

    // if requested, latch angle data for all channels
    if (latch) {
        rl32eOutpW(base + PAGE_REGISTER, PAGE(3));
        rl32eOutpW(base + LATCH, 2);
    }

    // if requested, get and format status data
    if (format == POSITION_STATUS || format == POSITION_VELOCITY_STATUS) {

        rl32eOutpW(base + PAGE_REGISTER, PAGE(3));

        tstStatus = rl32eInpW(base + TEST_STATUS);
        sigStatus = rl32eInpW(base + SIGNAL_STATUS);
        refStatus = rl32eInpW(base + REFERENCE_STATUS);

        for (i = 0; i < nChans; i++) {
            chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
            status[chan] = (real_T) (
                ((tstStatus & BIT(chan)) ? 1 : 0) |
                ((sigStatus & BIT(chan)) ? 2 : 0) |
                ((refStatus & BIT(chan)) ? 4 : 0) );
        }
    }

    // get position
    rl32eOutpW(base + PAGE_REGISTER, PAGE(1));

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        position[chan] = (int16_T) rl32eInpW(base + DATA_HI + 2 * chan);

        // if requested, read and process high resolution position data
        // ignore a high resolution request unless two-speed ratio > 1
        // note m-file doesn't allow high resolution for odd-numbered channels

        ratio = mxGetPr(TWO_SPEED_RATIO_ARG)[i];

        hiRes = (ratio > 1) ? mxGetPr(HI_RESOLUTION_ARG)[i] : 0;

        if (hiRes) {
            dataLo = (rl32eInpW(base + DATA_LO + chan - 1) >> 8) & 0xff00;
            position[chan] *= 256.0; 
            position[chan] += dataLo; 
            position[chan] *= 2.0 * PI / 0x1000000;
        } else
            position[chan] *= 2.0 * PI / 0x10000;
    
    }

    // get velocity if requested
    if (format == POSITION_VELOCITY || format == POSITION_VELOCITY_STATUS) {
        rl32eOutpW(base + PAGE_REGISTER, PAGE(2));

        for (i = 0; i < nChans; i++) {
            chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
            velocity[chan] = (int16_T) rl32eInpW(base + VELOCITY + 2 * chan);
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
        real_T maxRps;
        uint16_T velScale;
        InputRealPtrsType uPtrs;

        rl32eOutpW(base + PAGE_REGISTER, PAGE(2));

        for (i = 0; i < nChans; i++) {
            chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
            uPtrs = ssGetInputPortRealSignalPtrs(S, i);
            maxRps = CLAMP(*uPtrs[0], LO_MAX_RPS, HI_MAX_RPS);
            velScale = (uint16_T) (0xfff * HI_MAX_RPS / maxRps);
            rl32eOutpW(base + VELOCITY_SCALE + 2 * chan, velScale);
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
