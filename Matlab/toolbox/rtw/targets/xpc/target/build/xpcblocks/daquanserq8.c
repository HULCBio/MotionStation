// daquanserq8.c - xPC Target, non-inlined S-function driver for the
// D/A section of the Quanser Q8 Data Acquisition System

// Copyright 2003 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   daquanserq8

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

#define NUM_ARGS       8
#define CHANNEL_ARG    ssGetSFcnParam(S,0) // vector of [1:8] 
#define RANGE_ARG      ssGetSFcnParam(S,1) // vector of [-5, -10, 10]
#define SIMUL_ARG      ssGetSFcnParam(S,2) // 1: yes, 2: no
#define RESET_ARG      ssGetSFcnParam(S,3) // vector of boolean
#define INIT_VAL_ARG   ssGetSFcnParam(S,4) // vector of double
#define SAMP_TIME_ARG  ssGetSFcnParam(S,5) // double
#define PCI_BUS_ARG    ssGetSFcnParam(S,6) //
#define PCI_SLOT_ARG   ssGetSFcnParam(S,7) //

#define NUM_I_WORKS    (1)
#define BASE_I_IND     (0)
#define NUM_R_WORKS    (16)
#define GAIN_R_IND     (0)
#define OFFSET_R_IND   (8)

#define VENDOR_ID      (uint16_T)(0x11E3)   
#define DEVICE_ID      (uint16_T)(0x0010)   
#define SUBVENDOR_ID   (uint16_T)(0x5155)   
#define SUBDEVICE_ID   (uint16_T)(0x0200)   
#define PCI_BYTES      (0x0400)   

#define RESOLUTION     (4096)
#define MAX_COUNT      (RESOLUTION - 1)
#define MAX_CHAN       (8)


#define BIT(n)         (1 << n)

// 32-bit-register offsets
#define CONTROL_REGISTER        (0x08 / 4)   // R/W
#define STATUS_REGISTER         (0x0c / 4)   // R
#define DA_OUTPUT_REGISTER_A    (0x40 / 4)   // R/W
#define DA_OUTPUT_REGISTER_B    (0x44 / 4)   // R/W
#define DA_OUTPUT_REGISTER_C    (0x48 / 4)   // R/W
#define DA_OUTPUT_REGISTER_D    (0x4c / 4)   // R/W
#define DA_UPDATE_REGISTER      (0x50 / 4)   // W
#define DA_MODE_REGISTER        (0x6c / 4)   // R/W
#define DA_MODE_UPDATE_REGISTER (0x70 / 4)   // W

// 16-bit-register offsets
#define DAC0_DATA               (0x40 / 2)   // R/W
#define DAC4_DATA               (0x42 / 2)   // R/W

#define DA_MASK                 (0x03000000) // region of Control Register used for D/A control

typedef volatile void *ptr_T;
typedef volatile int16_T *reg16_T;
typedef volatile int32_T *reg32_T;

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i;

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

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i = 0;i < mxGetN(CHANNEL_ARG); i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i = 0; i < NUM_ARGS; i++) {
        ssSetSFcnParamTunable(S, i, 0);
    }

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
    real_T *RWork   = ssGetRWork(S);
    int_T  *IWork   = ssGetIWork(S);
    int_T   nChans  = mxGetN(CHANNEL_ARG);
    int_T   simul   = mxGetPr(SIMUL_ARG)[0];
    int_T   pciSlot = mxGetPr(PCI_SLOT_ARG)[0];
    int_T   pciBus  = mxGetPr(PCI_BUS_ARG)[0];

    ptr_T   bar;
    reg32_T base;
    int_T   i, chan, code, mode, range, shift, control;

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

    bar = (ptr_T) pciInfo.BaseAddress[0];

    base = (reg32_T) rl32eGetDevicePtr(bar, PCI_BYTES, RT_PG_USERREADWRITE);

    IWork[BASE_I_IND] = (int_T) base;

    // store offsets and gains; compute mode word
    for(i = mode = 0 ; i < nChans ; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        if (chan < 0 || chan >= MAX_CHAN) {
            printf(msg, "Bad channel in Quanser Q8 D/A: %n", chan + 1);
        }

        range = mxGetPr(RANGE_ARG)[i];

        switch (range) {
            case -5: // -5V to 5V
                code = 1;
                RWork[GAIN_R_IND + chan]   = RESOLUTION / 10.0;
                RWork[OFFSET_R_IND + chan] = 5.0;
                break;
            case -10: // -10V to 10V
                code = 17;
                RWork[GAIN_R_IND + chan]   = RESOLUTION / 20.0;
                RWork[OFFSET_R_IND + chan] = 10.0;
                break;
            case 10: // 0V to 10V
                code = 0;
                RWork[GAIN_R_IND + chan]   = RESOLUTION / 10.0;
                RWork[OFFSET_R_IND + chan] = 0.0;
                break;
            default:
                printf(msg, "Bad range in Quanser Q8 D/A: %d", range);
        }

        shift = (chan / 4) ? 27 - chan : 7 - chan;
        mode |= (code << shift);
    }

    // set transparent mode as requested
    control = base[CONTROL_REGISTER] & ~DA_MASK;
    control |= (simul) ? 0 : 0x03000000;
    base[CONTROL_REGISTER] = control;

    // set modes
    base[DA_MODE_REGISTER] = mode;
    base[DA_MODE_UPDATE_REGISTER] = 0;

    //*/ printf(": control <- %x  mode <- %x  simul:%d\n", control, mode, simul);
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    real_T *RWork      = ssGetRWork(S);
    int_T  *IWork      = ssGetIWork(S);
    int_T   simul      = mxGetPr(SIMUL_ARG)[0];
    int_T   nChans     = mxGetN(CHANNEL_ARG);
    int_T   base       = IWork[BASE_I_IND];
    bool    valid03[4] = {false, false, false, false};
    bool    valid47[4] = {false, false, false, false};

    real_T  voltage, offset, gain;
    uint_T  i, chan, mod, div, count03[4], count47[4];
    int_T   count;

    InputRealPtrsType uPtrs;

    // compute the counts and set the valid indicators
    for (i = 0; i < nChans; i++) {
        chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

        uPtrs = ssGetInputPortRealSignalPtrs(S, i);
        voltage = *uPtrs[0];

        gain = RWork[GAIN_R_IND + chan];
        offset = RWork[OFFSET_R_IND + chan];

        count = gain * (voltage + offset);

        if (count < 0) {
            count = 0;
        }

        if (count > MAX_COUNT) {
            count = MAX_COUNT;
        }

        mod = chan % 4; 
        div = chan / 4;

        if (div) {
            count47[mod] = count;
            valid47[mod] = true;
        } else {
            count03[mod] = count;
            valid03[mod] = true;
        }
    }

    // output the valid counts
    for (i = 0; i < 4; i++) {

        if (valid03[i] && valid47[i]) {
            ((reg32_T)base)[DA_OUTPUT_REGISTER_A + i] = 
                count03[i] | (count47[i] << 16);
        } 
        else if (valid03[i]) {
            ((reg16_T)base)[DAC0_DATA + 2 * i] = count03[i];
        } 
        else {
            ((reg16_T)base)[DAC4_DATA + 2 * i] = count47[i];
        }
    }

    if (simul) {
        ((reg32_T)base)[DA_UPDATE_REGISTER] = 0;
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    real_T *RWork      = ssGetRWork(S);
    int_T  *IWork      = ssGetIWork(S);
    int_T   simul      = mxGetPr(SIMUL_ARG)[0];
    int_T   nChans     = mxGetN(CHANNEL_ARG);
    int_T   base       = IWork[BASE_I_IND];
    bool    valid03[4] = {false, false, false, false};
    bool    valid47[4] = {false, false, false, false};

    real_T  voltage, offset, gain;
    uint_T  i, chan, mod, div, count03[4], count47[4];
    int_T   count;

    InputRealPtrsType uPtrs;

    // compute the counts and set the valid indicators
    for (i = 0; i < nChans; i++) {
        chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

        // when downloading, set channels to initial values;
        // when terminating, set requested channels to initial values

        if (!xpceIsModelInit() && !(uint_T)mxGetPr(RESET_ARG)[i]) 
            continue;

        voltage = mxGetPr(INIT_VAL_ARG)[i];

        gain = RWork[GAIN_R_IND + chan];
        offset = RWork[OFFSET_R_IND + chan];

        count = gain * (voltage + offset);

        if (count < 0)
            count = 0;

        if (count > MAX_COUNT)
            count = MAX_COUNT;

        mod = chan % 4; 
        div = chan / 4;

        if (div) {
            count47[mod] = count;
            valid47[mod] = true;
        } else {
            count03[mod] = count;
            valid03[mod] = true;
        }
    }

    // output the valid counts

    for (i = 0; i < 4; i++) {

        if (valid03[i] && valid47[i]) {
            ((reg32_T)base)[DA_OUTPUT_REGISTER_A + i] = 
                count03[i] | (count47[i] << 16);
        } 
        else if (valid03[i]) {
            ((reg16_T)base)[DAC0_DATA + 2 * i] = count03[i];
        } 
        else {
            ((reg16_T)base)[DAC4_DATA + 2 * i] = count47[i];
        }
    }
    if (simul) {
        ((reg32_T)base)[DA_UPDATE_REGISTER] = 0;
    }

#endif
}

#ifdef MATLAB_MEX_FILE 
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif




