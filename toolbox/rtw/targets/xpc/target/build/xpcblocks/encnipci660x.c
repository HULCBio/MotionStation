// encnipci660x.c - xPC Target, non-inlined S-function driver for the 
// encoder functionality of National Instruments 6601 and 6602 series counter boards

// This version supports quad modes X1, X2, X4 for channels 1-4.
// Spurious reloads are sometimes observed when reload is selected.

// Copyright 2003-2004 The MathWorks, Inc.

#define S_FUNCTION_LEVEL  2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME   encnipci660x

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
#include "util_xpcimport.h"

#endif

#define NUM_ARGS        10
#define DEVICE_ARG      ssGetSFcnParam(S, 0) // 0:PCI-6601 1:PCI-6602 2:PXI-6602
#define CHANNEL_ARG     ssGetSFcnParam(S, 1) // 1-4 (6601) or 1-8 (6602)
#define COUNT_MODE_ARG  ssGetSFcnParam(S, 2) // 1:normal 2:X1 3:X2 4:X4
#define INIT_COUNT_ARG  ssGetSFcnParam(S, 3) // 0-0xffffffff
#define RELOAD_ARG      ssGetSFcnParam(S, 4) // boolean
#define INDEX_PHASE_ARG ssGetSFcnParam(S, 5) // 1-4
#define FILTER_ARG      ssGetSFcnParam(S, 6) // 1-7
#define SAMP_TIME_ARG   ssGetSFcnParam(S, 7) // seconds
#define PCI_BUS_ARG     ssGetSFcnParam(S, 8) // integer
#define PCI_SLOT_ARG    ssGetSFcnParam(S, 9) // integer

#define VENDOR_ID       (uint16_T)(0x1093)   // National Instruments

#define NUM_I_WORKS     (1)
#define TIO_I_IND       (0)
#define NUM_R_WORKS     (0)

typedef void *ptr_T;
typedef volatile uint16_T *reg16_T;
typedef volatile uint32_T *reg32_T;

#define READ16(tio, offset)((reg16_T)(tio))[(offset)/2]
#define READ32(tio, offset)((reg32_T)(tio))[(offset)/4]

#define WRITE16(tio, offset, data)((reg16_T)(tio))[(offset)/2] = (uint16_T)(data)
#define WRITE32(tio, offset, data)((reg32_T)(tio))[(offset)/4] = (uint32_T)(data)

// byte offsets of control registers - the TIO-1 (ctr4-ctr7) addresses  
// are 0x800 higher than the corresponding TIO-0 (ctr0-ctr3) addresses

static int_T STATUS[8]        = {0x004, 0x006, 0x104, 0x106, 0x804, 0x806, 0x904, 0x906};
static int_T COMMAND[8]       = {0x00c, 0x00e, 0x10c, 0x10e, 0x80c, 0x80e, 0x90c, 0x90e};
static int_T HW_SAVE[8]       = {0x010, 0x014, 0x110, 0x114, 0x810, 0x814, 0x910, 0x914};
static int_T SW_SAVE[8]       = {0x018, 0x01c, 0x118, 0x11c, 0x818, 0x81c, 0x918, 0x91c};
static int_T LOAD_A[8]        = {0x038, 0x040, 0x138, 0x140, 0x838, 0x840, 0x938, 0x940};
static int_T LOAD_B[8]        = {0x03c, 0x044, 0x13c, 0x144, 0x83c, 0x844, 0x93c, 0x944};
static int_T MODE[8]          = {0x034, 0x036, 0x134, 0x136, 0x834, 0x836, 0x934, 0x936};
static int_T INPUT_SELECT[8]  = {0x048, 0x04a, 0x148, 0x14a, 0x848, 0x84a, 0x948, 0x94a};
static int_T COUNTING_MODE[8] = {0x0b0, 0x0b2, 0x1b0, 0x1b2, 0x8b0, 0x8b2, 0x9b0, 0x9b2};
static int_T SECOND_GATE[8]   = {0x0b4, 0x0b6, 0x1b4, 0x1b6, 0x8b4, 0x8b6, 0x9b4, 0x9b6};
static int_T DMA_CONFIG[8]    = {0x0b8, 0x0ba, 0x1b8, 0x1ba, 0x8b8, 0x8ba, 0x9b8, 0x9ba};
static int_T DMA_STATUS[8]    = {0x0b8, 0x0ba, 0x1b8, 0x1ba, 0x8b8, 0x8ba, 0x9b8, 0x9ba};
static int_T IO_CONFIG[10]    = {0x7a0, 0x79c, 0x798, 0x794, 0x790, 0x78c, 0x788, 0x784, 0x780, 0x77c};
static int_T INT_ACK[4]       = {0x004, 0x006, 0x892, 0x992};
static int_T JOINT_STATUS[4]  = {0x008, 0x108, 0x808, 0x908};
static int_T JOINT_STATUS1[4] = {0x036, 0x136, 0x836, 0x936};
static int_T JOINT_STATUS2[4] = {0x03a, 0x13a, 0x83a, 0x93a};
static int_T JOINT_RESET[4]   = {0x090, 0x190, 0x890, 0x990};
static int_T INT_ENABLE[4]    = {0x092, 0x192, 0x892, 0x992};
static int_T CLOCK_CONFIG[2]  = {0x73c, 0xf3c};

static char_T msg[256];
static uint_T id[3] = {0x2C60, 0x1310, 0x1360};
static char_T name[3][9] = {"PCI-6601", "PCI-6602", "PXI-6602"};

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i, numOutputPorts;

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

    numOutputPorts = mxGetN(CHANNEL_ARG);

    ssSetNumOutputPorts(S, numOutputPorts);
    for (i = 0; i < numOutputPorts; i++) {
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
    int_T    device  = (int_T) mxGetPr(DEVICE_ARG)[0];
    int_T    pciSlot = (int_T) mxGetPr(PCI_SLOT_ARG)[0];
    int_T    pciBus  = (int_T) mxGetPr(PCI_BUS_ARG)[0];
    int_T    mode[8] = {0, 0, 1, 2, 3, 4, 6, 0};
    int_T    reg[8]  = {0, 0, 1, 1, 2, 2, 3, 3};
    int_T    bit[8]  = {0x0004, 0x0008,0x0004, 0x0008,0x0004, 0x0008,0x0004, 0x0008};

    int_T    i;
    int_T    tio, chan, reload, phase, filter, initCount, countMode;
    ptr_T    bar0, bar1;
    reg32_T  mite;

    PCIDeviceInfo pciInfo;

    if (device < 0 || device > 2) {
        sprintf(msg, "Bad 660x device code: %d", device);
        ssSetErrorStatus(S, msg);
        return;
    } 
    else if (pciSlot < 0) {
        if (rl32eGetPCIInfo(VENDOR_ID, id[device], &pciInfo)) {
            sprintf(msg, "No NI %s found", name[device]);
            ssSetErrorStatus(S, msg);
            return;
        }
    } 
    else if (rl32eGetPCIInfoAtSlot(VENDOR_ID, id[device], 
        pciSlot + pciBus * 256, &pciInfo)) {
        sprintf(msg, "No NI %s at bus %d slot %d", name[device], pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    bar0 = (ptr_T) pciInfo.BaseAddress[0];
    bar1 = (ptr_T) pciInfo.BaseAddress[1];

    mite = (reg32_T) rl32eGetDevicePtr(bar0, 0x1000, RT_PG_USERREADWRITE);
    tio  = (int32_T) rl32eGetDevicePtr(bar1, 0x1000, RT_PG_USERREADWRITE);

    if( device == 0 )  // 6601 is device type 0
        mite[48] = ((uint_T) bar1 & 0xffffff00) | 0x00000080;
    else   // PCI-6602 and PXI-6602 are types 1 and 2
    {
        mite[49] = ((uint_T) bar1 & 0xffffff00) | 0x0000008c;
        mite[61] = 0;
    }

    IWork[TIO_I_IND] = tio;

    chan = (int_T)mxGetPr(CHANNEL_ARG)[0] - 1;

    reload = (int_T)mxGetPr(RELOAD_ARG)[0];  
    reload = (reload & 1) << 14;

    phase = (int_T)mxGetPr(INDEX_PHASE_ARG)[0] - 1;  
    phase = (phase & 3) << 5;

    filter = (int_T)mxGetPr(FILTER_ARG)[0] - 1;  
    filter = (filter & 7) << 4;

    initCount = (int_T)mxGetPr(INIT_COUNT_ARG)[0];  

    countMode = mode[ (int_T)mxGetPr(COUNT_MODE_ARG)[0] & 7 ];

    // disarm counters
    WRITE16(tio, COMMAND[chan], 0x0010);

    // 
    WRITE32(tio, CLOCK_CONFIG[0], 0); 
    WRITE32(tio, CLOCK_CONFIG[1], 0); 

    // set filter and configure I/O pins to input for this counter
    WRITE16(tio, IO_CONFIG[chan], filter); 

    // reset this counter
    WRITE16(tio, JOINT_RESET[reg[chan]], bit[chan]); 

    // load initial value to load register
    WRITE32(tio, LOAD_A[chan], initCount);
    WRITE32(tio, LOAD_B[chan], initCount);

    // no gated start/stop, rising edge gate
    WRITE16(tio, MODE[chan], 0x001a);

    // sync gate, load counter
    WRITE16(tio, COMMAND[chan], 0x0104);

    // index phase
    WRITE16(tio, COUNTING_MODE[chan], phase);

    // reload counter on gate if requested
    // no gated start/stop, rising edge gate, output = counter TC
    WRITE16(tio, MODE[chan], 0x011a | reload);

    // gate = dedicated source and gate pins
    WRITE16(tio, INPUT_SELECT[chan], 0x0080); 

    // sync gate, direction = aux pin, disarm counter
    WRITE16(tio, COMMAND[chan], 0x0140);

    // alt sync, index phase, counting mode
    WRITE16(tio, COUNTING_MODE[chan], 0x2000 | phase | countMode);

    // dedicated up/down pin
    WRITE16(tio, SECOND_GATE[chan], 0x0080);

    // direction = aux pin, arm counter
    WRITE16(tio, COMMAND[chan], 0x0041);

    if (chan > 3)
        WRITE32(tio, CLOCK_CONFIG[1], 0x00200000); 

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T  *IWork = ssGetIWork(S);
    int_T   tio   = IWork[TIO_I_IND];
    int_T   chan  = mxGetPr(CHANNEL_ARG)[0] - 1;
    real_T *y     = ssGetOutputPortRealSignal(S, 0);

    // synch gate, counting direction = aux pin 
    WRITE16(tio, COMMAND[chan], 0x140);

    // synch gate, counting direction = aux pin, save trace
    WRITE16(tio, COMMAND[chan], 0x142);

    // read count
    y[0] = (real_T) (int_T) READ32(tio, SW_SAVE[chan]);
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
