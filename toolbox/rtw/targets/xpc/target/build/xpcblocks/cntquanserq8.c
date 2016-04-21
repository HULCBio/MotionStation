// cntquanserq8.c - xPC Target, non-inlined S-function driver for the
// counter section of the Quanser Q8 Data Acquisition System

// Copyright 2003 The MathWorks, Inc.

// The Q8 has two 32-bit counters called Counter and Watchdog which decrement 
// every 30 nanoseconds when enabled. Each counter has two sets of register
// pairs. Each pair consists of a Preload Low and a Preload High register.

// For a PWM mode channel the driver displays a pair of input ports labeled  
// 'lo' and 'hi'. These are read and used to update the corresponding Preload 
// Low and High registers accordingly.

// For a FM mode channel the driver displays a single input port which is 
// used to update the corresponding Preload Low register and produce square 
// wave output.

// If 'Show arm input' is selected for a channel, an additional boolean input
// port labeled 'arm' is displayed and used to enable or disable the counter. 



#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   cntquanserq8

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

#define NUM_ARGS                       9
#define CHANNEL_ARG                    ssGetSFcnParam(S,0) // vector of [1 2] 
#define MODE_ARG                       ssGetSFcnParam(S,1) // vector of mode_T 
#define SHOW_ARM_ARG                   ssGetSFcnParam(S,2) // vector of boolean 
#define RESET_ARG                      ssGetSFcnParam(S,3) // vector of boolean
#define INIT_LO_VAL_ARG                ssGetSFcnParam(S,4) // vector of unsigned int
#define INIT_HI_VAL_ARG                ssGetSFcnParam(S,5) // vector of unsigned int
#define SAMP_TIME_ARG                  ssGetSFcnParam(S,6) // double
#define PCI_BUS_ARG                    ssGetSFcnParam(S,7) // int
#define PCI_SLOT_ARG                   ssGetSFcnParam(S,8) // int

#define NUM_I_WORKS                    (3)
#define BASE_I_IND                     (0)
#define ACTIVE_I_IND                   (1)
#define CONTROL_I_IND                  (2)
#define NUM_R_WORKS                    (0)

#define VENDOR_ID                      (uint16_T)(0x11E3)   
#define DEVICE_ID                      (uint16_T)(0x0010)   
#define SUBVENDOR_ID                   (uint16_T)(0x5155)   
#define SUBDEVICE_ID                   (uint16_T)(0x0200)   
#define PCI_BYTES                      (0x0400)   

#define MAX_CHAN                       (2)

#define THRESHOLD                      (0.5)

#define BIT(n)                         (1 << n)

#define CLAMP_LO(x, lo)                (x < lo ? lo : x)
#define CLAMP_HI(x, hi)                (x > hi ? hi : x)
#define CLAMP_UINT32(x)                (CLAMP_LO(CLAMP_HI(x, 0xffffffff), 0))


// 32-bit-register offsets

#define CONTROL_REGISTER               (0x08 / 4) // R/W
#define STATUS_REGISTER                (0x0c / 4) // R

#define COUNTER_PRELOAD_REGISTER       (0x10 / 4) // R
#define COUNTER_REGISTER               (0x14 / 4) // R
#define WATCHDOG_PRELOAD_REGISTER      (0x18 / 4) // R
#define WATCHDOG_REGISTER              (0x1c / 4) // R

#define COUNTER_PRELOAD_LOW_REGISTER   (0x10 / 4) // W
#define COUNTER_PRELOAD_HIGH_REGISTER  (0x14 / 4) // W
#define WATCHDOG_PRELOAD_LOW_REGISTER  (0x18 / 4) // W
#define WATCHDOG_PRELOAD_HIGH_REGISTER (0x1c / 4) // W

#define COUNTER_CONTROL_REGISTER       (0x20 / 4) // R/W


// Counter Control Register bits - watchdog portion

#define WD_LD    BIT(25) // 0: no load operation
                         // 1: load watchdog counter from active preload and WD_VAL

#define WD_VAL   BIT(24) // value of watchdog counter output (ignored if WD_LD = 0)

#define WD_ACT   BIT(23) // 0: deactive watchdog features of WATCHDOG counter
                         // 1: active watchdog features 

#define WD_SEL   BIT(22) // 0: WATCHDOG output is watchdog interrupt state (active low)
                         // 1: output is output of WATCHDOG counter

#define WD_OUTEN BIT(21) // 0: disable WATCHDOG output (output always high)
                         // 1: enable WATCHDOG output (value determined by WD_SEL) 

#define WD_PRSEL BIT(20) // 0: use Watchdog Preload Low reg
                         // 1: use Watchdog Preload High reg (ignored if WD_MODE = 1)

#define WD_WSET  BIT(19) // 0: use watchdog register set #0 for writes to preload regs
                         // 1: use register set #1 

#define WD_RSET  BIT(18) // 0: use watchdog register set #0 for active set and reads
                         // 1: use register set #1 

#define WD_MODE  BIT(17) // 0: square wave mode (WD_PRSEL selects preload register)
                         // 1: PWM mode (both preload low and high registers used)

#define WD_ENAB  BIT(16) // 0: disable counting of watchdog counter
                         // 1: enable watchdog counter 


// Counter Control Register bits - counter portion

#define CT_LD    BIT(9)  // 0: no load operation
                         // 1: load counter from active preload and CT_VAL

#define CT_VAL   BIT(8)  // value of counter output (ignored if CT_LD = 0)

#define CT_ENPOL BIT(6)  // 0: if CTEN_CV = 0, CNTREN is active high 
                         //    if CTEN_CV = 1, CNTREN is falling edge 
                         // 1: if CTEN_CV = 0, CNTREN is active low  
                         //    if CTEN_CV = 1, CNTREN is rising edge 

#define CT_OUTEN BIT(5)  // 0: disable CNTR_OUT output (output always high)
                         // 1: enable CNTR_OUT output (value is output of COUNTER)

#define CT_PRSEL BIT(4)  // 0: use Counter Preload Low reg
                         // 1: use Counter Preload High reg (ignored if CT_MODE = 1)

#define CT_WSET  BIT(3)  // 0: use counter register set #0 for writes to preload regs
                         // 1: use register set #1

#define CT_RSET  BIT(2)  // 0: use counter register set #0 for active set and reads
                         // 1: use register set #1

#define CT_MODE  BIT(1)  // 0: square wave mode (CT_PRSEL selects preload register)
                         // 1: PWM mode (both preload low and high registers used)

#define CT_ENAB  BIT(0)  // 0: disable counting of counter
                         // 1: enable counter 


typedef enum {
    COUNTER = 0,
    WATCHDOG } chan_T;

typedef enum {
    FM = 0,
    PWM } mode_T;


static int_T  pwm[2] = { CT_MODE,  WD_MODE };
static int_T  set[2] = { CT_WSET | WD_WSET,  CT_RSET | WD_RSET };
static int_T  arm[2] = { CT_ENAB | CT_OUTEN, WD_ENAB | WD_OUTEN };

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i, nPorts;

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
    ssSetNumOutputPorts(S, 0);

    nPorts = mxGetN(CHANNEL_ARG);
    for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
        if (mxGetPr(MODE_ARG)[i] > 0)
            nPorts++;
        if (mxGetPr(SHOW_ARM_ARG)[i] > 0)
            nPorts++;
    }

    ssSetNumInputPorts(S, nPorts);

    for (i = 0;i < nPorts; i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
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
    int_T  nChans  = mxGetN(CHANNEL_ARG);
    int_T  pciSlot = mxGetPr(PCI_SLOT_ARG)[0];
    int_T  pciBus  = mxGetPr(PCI_BUS_ARG)[0];

    void *bar;
    volatile uint32_T *base;

    uint_T   i, s, lo, hi, chan, disable, control;

    PCIDeviceInfo pciInfo;

    if (pciSlot < 0) {
        if (rl32eGetPCIInfo(VENDOR_ID, DEVICE_ID, &pciInfo)) {
            sprintf(msg, "No Quanser Q8 found");
            ssSetErrorStatus(S, msg);
            return;
        }
     
    } else if (rl32eGetPCIInfoAtSlot(VENDOR_ID, DEVICE_ID, 
        pciSlot + pciBus * 256, &pciInfo)) {
        sprintf(msg, "No Quanser Q8 at bus %d slot %d", pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    bar = (void *) pciInfo.BaseAddress[0];

    base = (volatile uint32_T *) rl32eGetDevicePtr(bar, PCI_BYTES, RT_PG_USERREADWRITE);

    // configure each channel appropriately as FM or PWM

    for (i = control = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        if (chan == 1) {
            control |= WD_SEL;
        }

        if (mxGetPr(MODE_ARG)[i] == PWM) {
            control |= pwm[chan];
        }
    }

    // initialize both sets of preload registers

    for (s = disable = 0; s < 2; s++) {
        base[COUNTER_CONTROL_REGISTER] = set[s];
        for (i = 0; i < nChans; i++) {
            chan = mxGetPr(CHANNEL_ARG)[i] - 1;

            lo = CLAMP_UINT32(mxGetPr(INIT_LO_VAL_ARG)[i]);
            hi = CLAMP_UINT32(mxGetPr(INIT_HI_VAL_ARG)[i]);
            base[COUNTER_PRELOAD_LOW_REGISTER + 2 * chan] = lo;
            base[COUNTER_PRELOAD_HIGH_REGISTER + 2 * chan] = hi;
        }
    }

    IWork[ACTIVE_I_IND]  = 0;
    IWork[CONTROL_I_IND] = control;
    IWork[BASE_I_IND]    = (int32_T) base;

    base[COUNTER_CONTROL_REGISTER] = control | set[0];
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T *IWork   = ssGetIWork(S);
    int_T  nChans  = mxGetN(CHANNEL_ARG);
    int_T  active  = IWork[ACTIVE_I_IND];
    int_T  control = IWork[CONTROL_I_IND];
    int_T  offset  = mxGetPr(MODE_ARG)[0] + mxGetPr(SHOW_ARM_ARG)[0] + 1;

    volatile uint32_T *base = (volatile uint32_T *) IWork[BASE_I_IND];

    int_T   i, chan, index, enable;

    InputRealPtrsType uPtrs;

    // update the preload values from the input ports

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        uPtrs = ssGetInputPortRealSignalPtrs(S, i * offset);
        base[COUNTER_PRELOAD_LOW_REGISTER + 2 * chan] = CLAMP_UINT32(*uPtrs[0]);

        if (mxGetPr(MODE_ARG)[i] > 0) {
            uPtrs = ssGetInputPortRealSignalPtrs(S, i * offset + 1);
            base[COUNTER_PRELOAD_HIGH_REGISTER + 2 * chan] = CLAMP_UINT32(*uPtrs[0]);
        }
    }

    // if an arm input port is being displayed, enable or disable the 
    // corresponding channel according to the current arm input value,
    // else display it unconditionally

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        enable = 1;

        if (mxGetPr(SHOW_ARM_ARG)[i] > 0) {
            index = i * offset + mxGetPr(MODE_ARG)[i] + 1;
            uPtrs = ssGetInputPortRealSignalPtrs(S, index);
            enable = (*uPtrs[0] > THRESHOLD) ? 1 : 0;
        }
            
        control |= enable * arm[chan];
    }

    // toggle the active register set

    active = (active + 1) % 2;

    IWork[ACTIVE_I_IND] = active;

    base[COUNTER_CONTROL_REGISTER] = control | set[active];
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T  *IWork   = ssGetIWork(S);
    int_T   nChans  = mxGetN(CHANNEL_ARG);
    int_T   active  = IWork[ACTIVE_I_IND];
    int_T   control = IWork[CONTROL_I_IND];
    int_T   offset  = mxGetPr(MODE_ARG)[0] + mxGetPr(SHOW_ARM_ARG)[0] + 1;

    volatile uint32_T *base = (volatile uint32_T *) IWork[BASE_I_IND];

    uint_T  i, lo, hi, chan, index, enable;

    InputRealPtrsType uPtrs;

    for (i = 0; i < nChans; i++) {
        chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

        // When downloading or resetting: load the preload registers from the initial
        // value parameters

        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            lo = CLAMP_UINT32(mxGetPr(INIT_LO_VAL_ARG)[i]);
            hi = CLAMP_UINT32(mxGetPr(INIT_HI_VAL_ARG)[i]);
            base[COUNTER_PRELOAD_LOW_REGISTER + 2 * chan] = lo;
            base[COUNTER_PRELOAD_HIGH_REGISTER + 2 * chan] = hi;
        }
        
        // When downloading: arm the channel if both lo and hi initial values are > 0.
        // When stopping: arm the channel according to the value of the arm input port 
        // (if one is displayed - if it isn't, arm the channel unconditionally).

        if (xpceIsModelInit()) {
            enable = (lo > 0 && hi > 0) ? 1 : 0;

        } else if (mxGetPr(SHOW_ARM_ARG)[i] > 0) {
            index = i * offset + mxGetPr(MODE_ARG)[i];
            uPtrs = ssGetInputPortRealSignalPtrs(S, index);
            enable = (*uPtrs[0] > THRESHOLD) ? 1 : 0;
        
        } else {
            enable = 1;
        }

        control |= enable * arm[chan];
    }

    // toggle the active register set

    active = (active + 1) % 2;

    IWork[ACTIVE_I_IND]  = active;

    base[COUNTER_CONTROL_REGISTER] = control | set[active];
#endif
}

#ifdef MATLAB_MEX_FILE 
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif




