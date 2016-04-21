/* $Revision: 1.1.6.1 $ */
// adcontecadxe.c - xPC Target, non-inlined S-function driver for the A/D
// section of the Contec AD12-16(PCI)E, AD12-16U(PCI)E, AD16-16(PCI)E boards (pjk)
// Copyright 1996-2002 The MathWorks, Inc.

#define S_FUNCTION_LEVEL  2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME   adcontecadxe

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

#define NUM_ARGS      7
#define CHANNEL_ARG   ssGetSFcnParam(S,0) // vector of [1:16]
#define GAIN_ARG      ssGetSFcnParam(S,1) // vector of [1, 2, 4, 8]
#define RANGE_ARG     ssGetSFcnParam(S,2) // integer
#define SAMP_TIME_ARG ssGetSFcnParam(S,3) // seconds
#define PCI_BUS_ARG   ssGetSFcnParam(S,4) // integer
#define PCI_SLOT_ARG  ssGetSFcnParam(S,5) // integer
#define DEVICE_ARG    ssGetSFcnParam(S,6) // device_T (defined below)

#define VENDOR_ID     (0x1221) // Contec

#define TIMEOUT       (1000)

#define NUM_I_WORKS   (1)
#define BASE_I_IND    (0)

#define NUM_R_WORKS   (2)
#define OFFSET_R_IND  (0) 
#define COEFF_R_IND   (1)


#define SAMPLING_OPERATION_START_REGISTER      (2) // Output register offsets
#define DIGITAL_OUTPUT_REGISTER                (3)
#define ANALOG_OUTPUT_REGISTER_LOWER           (4)
#define ANALOG_OUTPUT_REGISTER_UPPER           (5)
#define COMMAND_OUTPUT_REGISTER                (6)
#define DATA_OUTPUT_REGISTER                   (7)
#define COUNTER_0_DATA_OUTPUT_REGISTER_8254    (8)
#define COUNTER_1_DATA_OUTPUT_REGISTER_8254    (10)
#define COUNTER_2_DATA_OUTPUT_REGISTER_8254    (12)
#define CONTROL_WORD_REGISTER_8254             (14)

#define BUFFER_MEMORY_DATA_READ_REGISTER_LOWER (0) // Input register offsets
#define BUFFER_MEMORY_DATA_READ_REGISTER_UPPER (1)
#define STATUS_AND_FLAG_INPUT_REGISTER         (2)
#define FLAG_INPUT_REGISTER                    (3)
#define DIGITAL_INPUT_REGISTER                 (3)
#define DATA_INPUT_REGISTER                    (7)
#define COUNTER_0_DATA_INPUT_REGISTER_8254     (8)
#define COUNTER_1_DATA_INPUT_REGISTER_8254     (10)
#define COUNTER_2_DATA_INPUT_REGISTER_8254     (12)

typedef enum { // commands
    SET_SAMPLING_FUNCTION                     = 0,
    SET_INPUT_GAIN                            = 1,
    SET_INPUT_CHANNEL_SEQUENCE                = 2,
    SET_CHANNEL_SCAN_CLOCK                    = 3,
    SET_SAMPLING_CLOCK                        = 4,
    SET_SAMPLING_START_CONDITION              = 5,
    SET_SAMPLING_START_LEVEL                  = 6,
    SET_SAMPLING_STOP_CONDITION               = 8,
    SET_SAMPLING_STOP_LEVEL                   = 9,
    SET_SAMPLING_COUNT                        = 11,
    SET_DELAYED_SAMPLING_COUNT                = 12,
    SET_TRIGGER_DELAY_COUNT                   = 13,
    SET_REPEAT_COUNT                          = 14,
    RESET_BUFFER_MEMORY                       = 17,
    SET_BUFFER_MEMORY_WRITE_POINTER           = 18,
    SET_BUFFER_MEMORY_READ_POINTER            = 19,
    SET_BUFFER_MEMORY_TRIGGERED_WRITE_POINTER = 20,
    RESET_BOARD                               = 22,
    STOP_OPERATION                            = 23,
    RESET_CONVERSION_ERROR_FLAGS              = 24,
    SET_INTERRUPT_LEVEL                       = 25,
    SET_INTERRUPT_MASK                        = 26,
    INTERRUPT_FACTOR_STORAGE_REGISTER         = 27,
    RESET_INTERRUPT_FACTOR_STORAGE_REGISTER   = 28,
    SET_DMA_TRANSFER_CONDITIONS               = 29,
    OPEN_8254_GATE                            = 30,
    CLOSE_8254_GATE                           = 31,
    RESET_8254_FLAGS                          = 32,
    OPEN_EXTERNAL_TRIGGER_GATE                = 33,
    CLOSE_EXTERNAL_TRIGGER_GATE               = 34,
    RESET_EXTERNAL_TRIGGER_FLAGS              = 35,
    BOARD_SETTING_STATUS_REGISTER             = 36
} command_T;

typedef enum { // status bits
    BUSY                  = 1,
    DATA_READY            = 2,
    BUFFER_HALF_FULL      = 4,
    BUFFER_OVERFLOW       = 8,
    SAMPLING_END          = 16,
    OVER_RANGE_ERROR      = 32,
    START_TRIGGER_ERROR   = 64,
    SAMPLING_CLOCK_ERROR  = 128
} status_T;

typedef enum { // device types
    AD12_16  = 0,
    AD12_16U = 1,
    AD16_16  = 2
} device_T;

static char name[3][15] = {"AD12-16 ", "AD12-16U", "AD16-16 "};

static char_T msg[256];


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
    int_T   *IWork   = ssGetIWork(S);
    real_T  *RWork   = ssGetRWork(S);
    int_T    range   = mxGetPr(RANGE_ARG)[0];
    int_T    pciSlot = mxGetPr(PCI_SLOT_ARG)[0];
    int_T    pciBus  = mxGetPr(PCI_BUS_ARG)[0];
    int_T    device  = mxGetPr(DEVICE_ARG)[0];
    int_T    nChans  = mxGetN(CHANNEL_ARG);

    uint8_T  chan, gain, gainSetting; 
    uint16_T samplingFunction; 
    uint_T   scanNanosec, sampleNanosec;
    uint_T   scanClock, sampleClock;
    uint_T   repeatCount, sampleCount;
    int_T    i, base, deviceId, resolution;
    PCIDeviceInfo pciInfo;

    switch (device) {
        case AD12_16: {
            deviceId = 0x8113;
            resolution = 4096;
            scanNanosec = 15000;
            break;
        }
        case AD12_16U: {
            deviceId = 0x8103;
            resolution = 4096;
            scanNanosec = 1500;
            break;
        }
        case AD16_16: {
            deviceId = 0x8123;
            resolution = 65536;
            scanNanosec = 15000;
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

    // store coeffs and offsets
    switch (range) {
        case 1: // -2.5V to 2.5V
            RWork[COEFF_R_IND]  =  5.0 / resolution;
            RWork[OFFSET_R_IND] =  2.5;
            break;
        case 2: // -5V to 5V
            RWork[COEFF_R_IND]  = 10.0 / resolution;
            RWork[OFFSET_R_IND] =  5.0;
            break;
        case 3: // 0V to 5V
            RWork[COEFF_R_IND]  =  5.0 / resolution;
            RWork[OFFSET_R_IND] =  0.0;
            break;
        case 4: // 0V to 10V
            RWork[COEFF_R_IND]  = 10.0 / resolution;
            RWork[OFFSET_R_IND] =  0.0;
            break;
        default: 
            sprintf(msg, "bad %s range parameter: %d", name[device], range);
            ssSetErrorStatus(S, msg);
            return;
    }

    sampleNanosec = scanNanosec * nChans;
    scanClock     = scanNanosec / 25 - 1;
    sampleClock   = sampleNanosec / 25 + 10;
    repeatCount   = 0;          // 0 means once
    sampleCount   = nChans - 1; // 0 means 1 sample

    IWork[BASE_I_IND] = base = pciInfo.BaseAddress[0];

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, RESET_BOARD);

    samplingFunction = 0

        | 0x2000 * 0  //       data format = straight binary
        | 0x1000 * 1  // simultaneous hold = on
        | 0x0800 * 0  //               DMA = not used
        | 0x0200 * 0  //   repeat function = counter setting
        | 0x0100 * 0  //     buffer format = FIFO
        | 0x0080 * 1  //  channel sequence = multi-channel
        | 0x0020 * 0  //    sampling clock = internal 
        | 0x0004 * 0  //      stop trigger = set count completed
        | 0x0001 * 0; //     start trigger = software command

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_SAMPLING_FUNCTION);
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, samplingFunction);
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, samplingFunction >> 8);

    for( i = 0 ; i < nChans ; i++ ) {
        gain = mxGetPr(GAIN_ARG)[i];
        switch (gain) {
            case 1 : gainSetting = 0; break;
            case 2 : gainSetting = 1; break;
            case 4 : gainSetting = 2; break;
            case 8 : gainSetting = 3; break;
        }
        rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_INPUT_GAIN); 
        rl32eOutpB(base + DATA_OUTPUT_REGISTER, i);
        rl32eOutpB(base + DATA_OUTPUT_REGISTER, gainSetting);
    }
    
    for( i = 0 ; i < nChans ; i++ ) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_INPUT_CHANNEL_SEQUENCE);
        rl32eOutpB(base + DATA_OUTPUT_REGISTER, i);    // address
        rl32eOutpB(base + DATA_OUTPUT_REGISTER, chan); // channel
    }

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_CHANNEL_SCAN_CLOCK); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, scanClock);
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, scanClock >> 8); 

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_SAMPLING_CLOCK); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, sampleClock);
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, sampleClock >> 8);
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, sampleClock >> 16);
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, sampleClock >> 24); 

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_SAMPLING_START_CONDITION); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_SAMPLING_START_LEVEL); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_SAMPLING_STOP_CONDITION); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_SAMPLING_STOP_LEVEL); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_SAMPLING_COUNT); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, sampleCount);
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, sampleCount >> 8);
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, sampleCount >> 16); 

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_DELAYED_SAMPLING_COUNT); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_TRIGGER_DELAY_COUNT); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, 0); 

    rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, SET_REPEAT_COUNT); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, repeatCount); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, repeatCount >> 8); 
    rl32eOutpB(base + DATA_OUTPUT_REGISTER, repeatCount >> 16); 
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
#define BAD (BUFFER_OVERFLOW | START_TRIGGER_ERROR | SAMPLING_CLOCK_ERROR)

    int_T   *IWork  = ssGetIWork(S);
    real_T  *RWork  = ssGetRWork(S);
    int_T    base   = IWork[BASE_I_IND];
    real_T   coeff  = RWork[COEFF_R_IND];
    real_T   offset = RWork[OFFSET_R_IND];
    int_T    nChans = mxGetN(CHANNEL_ARG);
    int_T    device = mxGetPr(DEVICE_ARG)[0];

    real_T  *y;
    uint8_T  status;
    int_T    i, time, gain, count;

    if (nChans > 1) // why is a buffer reset necessary when nChans > 1 ?
        rl32eOutpB(base + COMMAND_OUTPUT_REGISTER, RESET_BUFFER_MEMORY); 

    rl32eOutpB(base + SAMPLING_OPERATION_START_REGISTER, nChans - 1);

    for (i = 0; i < nChans; i++) {
        gain = (int_T)mxGetPr(GAIN_ARG)[i];
        y = ssGetOutputPortRealSignal(S,i);

        for (time = 0; time < TIMEOUT; time++) {  
            status = rl32eInpB(base + STATUS_AND_FLAG_INPUT_REGISTER);

            // if (status & BAD) printf("%s status %x ", name[device], status);

            if (status & DATA_READY)
                break;
        }
        if (time >= TIMEOUT) {
            sprintf(msg, "Contec %s A/D timeout", name[device]);
            ssSetErrorStatus(S, msg);
            return;
        }

        count = rl32eInpW(base);
        y[0] = (count * coeff - offset) / gain;
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




