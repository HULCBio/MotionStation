// adquanserq8.c - xPC Target, non-inlined S-function driver for the 
// A/D section of the Quanser Q8 Data Acquisition System

// Copyright 2003 The MathWorks, Inc.

#define S_FUNCTION_LEVEL  2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME   adquanserq8

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

#define NUM_ARGS           6
#define CHANNEL_ARG        ssGetSFcnParam(S,0)  
#define INDEX_03_ARG       ssGetSFcnParam(S,1)  
#define INDEX_47_ARG       ssGetSFcnParam(S,2)  
#define SAMP_TIME_ARG      ssGetSFcnParam(S,3) 
#define PCI_BUS_ARG        ssGetSFcnParam(S,4) 
#define PCI_SLOT_ARG       ssGetSFcnParam(S,5) 

#define NUM_I_WORKS        (2)
#define BASE_I_IND         (0)
#define CONTROL_I_IND      (1)
#define NUM_R_WORKS        (0)

#define VENDOR_ID          (uint16_T)(0x11E3)   
#define DEVICE_ID          (uint16_T)(0x0010)   
#define SUBVENDOR_ID       (uint16_T)(0x5155)   
#define SUBDEVICE_ID       (uint16_T)(0x0200)   
#define PCI_BYTES          (0x0400)   

#define BIT(n)             (1 << n)

#define RESOLUTION         (16384)
#define GAIN               (20.0 / RESOLUTION)

// 32-bit-register offsets
#define CONTROL_REGISTER   (0x08 / 4) // R/W
#define STATUS_REGISTER    (0x0c / 4) // R
#define AD_REGISTER        (0x2c / 4) // R/W

// 16-bit register offsets
#define AD_REGISTER_03     (0x2c / 2) // R
#define AD_REGISTER_47     (0x2e / 2) // R

// Control Register bits
#define CTRL_ADC03_SCK     BIT(9)
#define CTRL_ADC03_HS      BIT(12)
#define CTRL_ADC03_CV      BIT(15)
#define CTRL_ADC47_SCK     BIT(17)
#define CTRL_ADC47_HS      BIT(20)
#define CTRL_ADC47_CV      BIT(23)

#define AD_MASK            (0x10ffff00) // region of Control Register used for A/D control

// Status Register bits
#define STAT_ADC03_RDY     BIT(18)
#define STAT_ADC47_RDY     BIT(19)


typedef volatile void     *ptr_T;
typedef volatile int16_T  *reg16_T;
typedef volatile int32_T  *reg32_T;

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i, numOutputPorts;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
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
    int_T  *IWork    = ssGetIWork(S);
    int_T   pciSlot  = (int_T) mxGetPr(PCI_SLOT_ARG)[0];
    int_T   pciBus   = (int_T) mxGetPr(PCI_BUS_ARG)[0];
    int_T   nChans   = (int_T) mxGetN(CHANNEL_ARG);
    int_T   nChans03 = (int_T) mxGetN(INDEX_03_ARG);
    int_T   nChans47 = (int_T) mxGetN(INDEX_47_ARG);
    ptr_T   bar;
    reg32_T base;
    int_T   i, chan, chans, control;

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

    if (nChans03 + nChans47 != nChans) {
        sprintf(msg, "Quanser Q8 A/D driver internal error");
        ssSetErrorStatus(S, msg);
        return;
    }

    bar = (ptr_T) pciInfo.BaseAddress[0];

    base  = (reg32_T) rl32eGetDevicePtr(bar, PCI_BYTES, RT_PG_USERREADWRITE);

    IWork[BASE_I_IND] = (int_T) base;

    control = base[CONTROL_REGISTER] & ~AD_MASK;

    // use A/D (not Control) Register to select channels
    control |= (nChans03 > 0) ? CTRL_ADC03_HS : 0;
    control |= (nChans47 > 0) ? CTRL_ADC47_HS : 0;

    // if sampling both ADC03 and ADC47 channels, use the common clock 
    // for both types, otherwise use the appropriate internal clock
    if (nChans03 > 0 && nChans47 > 0)
        control |= CTRL_ADC03_SCK | CTRL_ADC47_SCK;

    IWork[CONTROL_I_IND] = control;

    base[CONTROL_REGISTER] = control;

    // program the A/D Register
    for (i = chans = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        chans |= (chan < 4) ? BIT(chan) : BIT(chan + 12);
    }
    
    base[AD_REGISTER] = chans;
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
#define BOTH_RDY  (STAT_ADC03_RDY | STAT_ADC47_RDY)

    int_T  *IWork    = ssGetIWork(S);
    int_T   control  = IWork[CONTROL_I_IND];
    int_T   nChans03 = (int_T) mxGetN(INDEX_03_ARG);
    int_T   nChans47 = (int_T) mxGetN(INDEX_47_ARG);
    reg32_T base     = (reg32_T) IWork[BASE_I_IND];
    int_T   i, i03, i47;
    real_T *y;
    bool    done;

    union { int32_T int32; int16_T int16[2]; } x;

    // initiate conversions and wait for completion

    if (nChans03 > 0 && nChans47 > 0){
        base[CONTROL_REGISTER] = control | CTRL_ADC03_CV | CTRL_ADC47_CV;
        while ((base[STATUS_REGISTER] & BOTH_RDY) != BOTH_RDY);

    } else if (nChans03 > 0) {
        base[CONTROL_REGISTER] = control | CTRL_ADC03_CV;
        while (!(base[STATUS_REGISTER] & STAT_ADC03_RDY));

    } else if (nChans47 > 0) {
        base[CONTROL_REGISTER] = control | CTRL_ADC47_CV;
        while (!(base[STATUS_REGISTER] & STAT_ADC47_RDY));
    } 
        
    // read FIFO, convert and update signals

    i03 = i47 = 0; done = false;
    
    while(!done) {

        if (i03 < nChans03 && i47 < nChans47) {

            x.int32 = base[AD_REGISTER];

            i = mxGetPr(INDEX_03_ARG)[i03++];
            y = ssGetOutputPortRealSignal(S, i);
            y[0] = GAIN * x.int16[0];

            i = mxGetPr(INDEX_47_ARG)[i47++];
            y = ssGetOutputPortRealSignal(S, i);
            y[0] = GAIN * x.int16[1];

        } else if (i03 < nChans03) {
            i = mxGetPr(INDEX_03_ARG)[i03++];
            y = ssGetOutputPortRealSignal(S, i);
            y[0] = GAIN * ((reg16_T)base)[AD_REGISTER_03];

        } else if (i47 < nChans47) {
            i = mxGetPr(INDEX_47_ARG)[i47++];
            y = ssGetOutputPortRealSignal(S, i);
            y[0] = GAIN * ((reg16_T)base)[AD_REGISTER_47];

        } else {
            done = true;
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
