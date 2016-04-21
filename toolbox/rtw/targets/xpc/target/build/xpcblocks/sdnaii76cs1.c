// sdnaii76cs1.c - xPC Target, non-inlined S-function driver for the
// S/D section of the NAII Apex 76CS1 Series Synchro/Resolver boards
// Copyright 2003 The MathWorks, Inc.

#define S_FUNCTION_LEVEL          2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME           sdnaii76cs1

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

#define NUM_ARGS                 (15)
#define CHANNEL_ARG              ssGetSFcnParam(S, 0) // vector of double
#define TWO_SPEED_RATIO_ARG      ssGetSFcnParam(S, 1) // vector of double >= 1
#define HI_RESOLUTION_ARG        ssGetSFcnParam(S, 2) // vector of boolean
#define SYNCHRO_ARG              ssGetSFcnParam(S, 3) // vector of boolean
#define ENCODER_ARG              ssGetSFcnParam(S, 4) // vector of double
#define LATCH_ARG                ssGetSFcnParam(S, 5) // boolean
#define MAX_RPS_ARG              ssGetSFcnParam(S, 6) // vector of double
#define DYNAMIC_MAX_RPS_ARG      ssGetSFcnParam(S, 7) // boolean
#define SAVE_SETUP_ARG           ssGetSFcnParam(S, 8) // boolean
#define FORMAT_ARG               ssGetSFcnParam(S, 9) // Format_T
#define FREQUENCY_ARG            ssGetSFcnParam(S,10) // double
#define VOLTAGE_ARG              ssGetSFcnParam(S,11) // double
#define SAMPLE_TIME_ARG          ssGetSFcnParam(S,12) // double
#define PCI_BUS_ARG              ssGetSFcnParam(S,13) // integer
#define PCI_SLOT_ARG             ssGetSFcnParam(S,14) // integer

#define VENDOR_ID                (uint16_T)(0x15ac)   // NAII
#define DEVICE_ID                (uint16_T)(0x7621)   // 76CS1 

#define PCI_MEM_LEN              (1024)
#define MAX_SD                   (8)
#define MAX_DS                   (6)
#define LO_MAX_RPS               (9.5367)
#define HI_MAX_RPS               (152.5878)
#define PI                       (3.14159265358979)

#define CLAMP_LO(x, lo)          (x < lo ? lo : x)
#define CLAMP_HI(x, hi)          (x > hi ? hi : x)
#define CLAMP(x, lo, hi)         (CLAMP_LO(CLAMP_HI(x, hi), lo))
#define CLAMP_MAX_RPS(x)         (CLAMP(x, LO_MAX_RPS, HI_MAX_RPS))

#define BIT(n)                   (1 << n)

#define Register                 volatile uint16_T *

// 16-bit-register offsets

#define SD_DATA                  (0x000 / 2) // read
#define SD_VELOCITY              (0x020 / 2) // read  
#define SD_RATIO                 (0x040 / 2) // read/write
#define ANGLE_DELTA              (0x050 / 2) // read/write
#define ANGLE_DELTA_INITIATE     (0x070 / 2) // write
#define SD_ACTIVE_CHANNELS       (0x074 / 2) // read/write
#define SD_TEST_D2_VERIFY        (0x078 / 2) // read/write
#define SD_TEST_ENABLE           (0x07C / 2) // read/write
#define SD_SIGNAL_STATUS         (0x080 / 2) // read
#define SD_REFERENCE_STATUS      (0x084 / 2) // read
#define SD_TEST_STATUS           (0x088 / 2) // read
#define LATCH                    (0x08C / 2) // write
#define SD_TEST_ANGLE            (0x090 / 2) // read/write
#define ANGLE_DELTA_ALERT        (0x094 / 2) // read
#define SYNCHRO_RESOLVER         (0x0A0 / 2) // read/write

#define SD_POST_ENABLE           (0x0A4 / 2) // read/write
#define LOCK_LOSS                (0x0A8 / 2) // read
#define A_B_RESOLUTION_POLES     (0x0AC / 2) // read/write
#define SD_VELOCITY_SCALE        (0x0CC / 2) // read/write
#define SD_CHAN_DATA_LO          (0x0F0 / 2) // read

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

typedef enum { // possible values of FORMAT_ARG
    POSITION = 1,
    POSITION_STATUS,
    POSITION_VELOCITY,
    POSITION_VELOCITY_STATUS 
} Format_T;

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    Format_T format  = (Format_T) mxGetPr(FORMAT_ARG)[0];
    int_T    dynamic = mxGetPr(DYNAMIC_MAX_RPS_ARG)[0];
    int_T    nChans  = mxGetN(CHANNEL_ARG);
    int_T    i, width;

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

    ssSetNumOutputPorts(S, nChans);

    switch (format) {
        case POSITION:
            width = 1; 
            break;
        case POSITION_STATUS:
            width = 2; 
            break;
        case POSITION_VELOCITY:
            width = 2; 
            break;
        case POSITION_VELOCITY_STATUS:
            width = 3; 
            break;
    }

    for (i = 0; i < nChans; i++) 
        ssSetOutputPortWidth(S, i, width);

    ssSetNumInputPorts(S, 0);

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

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T   *IWork     = ssGetIWork(S);
    int_T    nChans    = mxGetN(CHANNEL_ARG);
    int_T    pciSlot   = mxGetPr(PCI_SLOT_ARG)[0];
    int_T    pciBus    = mxGetPr(PCI_BUS_ARG)[0];
    int_T    busSlot   = pciSlot + pciBus * 256;
    Format_T format    = (Format_T) mxGetPr(FORMAT_ARG)[0];
    int_T    frequency = mxGetPr(FREQUENCY_ARG)[0];
    int_T    voltage   = mxGetPr(VOLTAGE_ARG)[0];
    uint16_T write1    = 0xA5A5;
    uint16_T write2    = ~write1;

    uint16_T read1, read2, code, ratio, active, synchro, velScale;
    int_T    i, chan, encoder;
    void    *addr;
    Register base;
    real_T   maxRps;

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

    // return if not download time
    if (!xpceIsModelInit())
        return;

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

    for (i = active = synchro = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        if (chan >= MAX_SD) {
            sprintf(msg, "No such NAII Apex 76CL1 S/D channel: %d", chan+1);
            ssSetErrorStatus(S, msg);
            return;
        }

        // only even (1-based) channels can have ratios other than 1
        if (chan % 2) { 
            ratio = mxGetPr(TWO_SPEED_RATIO_ARG)[i];
            base[SD_RATIO + chan - 1] = ratio;
        } else 
            base[SD_RATIO + chan - 1] = 1;

        // add to active channel list
        active |= BIT(chan);

        // if synchro, add to synchro list 
        if (mxGetPr(SYNCHRO_ARG)[i])
            synchro |= BIT(chan);

        // set the velocity scale
        maxRps = CLAMP_MAX_RPS( mxGetPr(MAX_RPS_ARG)[i] );
        velScale = (uint16_T) (0xfff * HI_MAX_RPS / maxRps);
        base[SD_VELOCITY_SCALE + 2 * chan] = velScale;

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
        base[A_B_RESOLUTION_POLES + 2 * chan] = code;
    }

    base[SD_ACTIVE_CHANNELS] = active;
    base[SYNCHRO_RESOLVER] = synchro;

    base[REFERENCE_FREQUENCY] = frequency;
    base[REFERENCE_VOLTAGE] = 10 * voltage;

    // disengage latch for all channels
    base[LATCH] = 0; 

    // if status output is requested, enable automatic background BIT (D2)
    if (format == POSITION_STATUS || format == POSITION_VELOCITY_STATUS) 
        base[SD_TEST_ENABLE] = 4;
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T    *IWork   = ssGetIWork(S);
    Register  base    = (Register) IWork[BASE_I_IND];
    Format_T  format  = (Format_T) mxGetPr(FORMAT_ARG)[0];
    int_T     dynamic = mxGetPr(DYNAMIC_MAX_RPS_ARG)[0];
    int_T     latch   = mxGetPr(LATCH_ARG)[0];
    int_T     nChans  = mxGetN(CHANNEL_ARG);

    int_T     i, chan, hiRes, status, tstStatus, sigStatus, refStatus;
    real_T   *y, maxRps, position, velocity;
    uint16_T  ratio, velScale, dataLo, count;

    InputRealPtrsType uPtrs;

    if (latch)
        base[LATCH] = 2; // latch angle data for all channels

    // read status if requested
    if (format == POSITION_STATUS || format == POSITION_VELOCITY_STATUS) {
        tstStatus = base[SD_TEST_STATUS];
        sigStatus = base[SD_SIGNAL_STATUS];
        refStatus = base[SD_REFERENCE_STATUS];
    }

    for (i = 0; i < nChans; i++) {
        y = ssGetOutputPortSignal(S, i);
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        position = base[SD_DATA + 2 * chan];

        // process hiRes if requested
        // ignore a hiRes request unless two-speed ratio > 1
        // note m-file doesn't allow hiRes for odd-numbered channels

        ratio = mxGetPr(TWO_SPEED_RATIO_ARG)[i];

        hiRes = (ratio > 1) ? mxGetPr(HI_RESOLUTION_ARG)[i] : 0;

        if (hiRes) {
            dataLo = (base[SD_CHAN_DATA_LO + chan - 1] & 0xff00) >> 8;
            position = 256.0 * position + dataLo; 
            position *= 2 * PI / 0x1000000;
        } else
            position *= 2 * PI / 0x10000;

        // read velocity if requested and normalize to lie between 0 and 1
        if (format == POSITION_VELOCITY || format == POSITION_VELOCITY_STATUS) {

            // set the velocity scale dynamically if requested
            if (dynamic) {
                uPtrs = ssGetInputPortRealSignalPtrs(S, i);
                maxRps = CLAMP_MAX_RPS( *uPtrs[0] );
                velScale = (uint16_T) (0xfff * HI_MAX_RPS / maxRps);
                base[SD_VELOCITY_SCALE + 2 * chan] = velScale;
            } else 
                maxRps = CLAMP_MAX_RPS( mxGetPr(MAX_RPS_ARG)[i] );

            velocity = (int16_T) base[SD_VELOCITY + 2 * chan];
            velocity *= maxRps / 0x8000 * 2 * PI; 
        }

        // compute status output if requested
        if (format == POSITION_STATUS || format == POSITION_VELOCITY_STATUS) 
            status = 
                ((tstStatus & BIT(chan)) ? 1 : 0) |
                ((sigStatus & BIT(chan)) ? 2 : 0) |
                ((refStatus & BIT(chan)) ? 4 : 0) ;

        // output to port
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
    int_T saveSetup = mxGetPr(SAVE_SETUP_ARG)[0];

    // save setup at model exit if requested
    if (saveSetup && !xpceIsModelInit()) {
        int_T *IWork = ssGetIWork(S);
        Register base = (Register) IWork[BASE_I_IND];

        printf("Saving current setup ...\n");
        base[SAVE] = 0x5555;
        while (base[SAVE] != 0);
        printf("Setup has been saved\n");
    }
#endif
}

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
