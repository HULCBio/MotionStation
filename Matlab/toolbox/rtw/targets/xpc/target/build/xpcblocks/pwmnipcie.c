/**
 * Abstract:
 *
 *   - xPC Target, non-inlined S-function for pulsewidth/single-period
 *     capture using the General Purpose Counter/Timers of the National
 *     Instruments E series boards.
 */
/* Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.4.6.1 $:  $Date: 2004/03/02 03:04:56 $
 */

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         pwmnipcie

#include        <stddef.h>
#include        <stdlib.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

#ifndef         MATLAB_MEX_FILE
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#include        "xpcioni.h"

#define          STCWRITE16 DAQ_STC_Windowed_Mode_Write
#define          STCREAD16  DAQ_STC_Windowed_Mode_Read
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (6)
#define CHANNEL_ARG             ssGetSFcnParam(S, 0)
#define GATE_MODE_ARG           ssGetSFcnParam(S, 1) /* level or edge */
/* Falling/Rising for Edge gate, or low/high for level gate */
#define GATE_DIR_ARG            ssGetSFcnParam(S, 2)
#define SAMP_TIME_ARG           ssGetSFcnParam(S, 3)
#define PCI_DEV_ARG             ssGetSFcnParam(S, 4)
#define DEV_ID_ARG              ssGetSFcnParam(S, 5)

#define SAMP_TIME_IND           (0)

#define NO_R_WORKS              (0)
#define NO_I_WORKS              (1)
#define NO_P_WORKS              (1)

#define BASE_ADDR               (ssGetPWork(S)[0])
#define CTR_CHANNEL             (ssGetIWork(S)[0])

static char_T msg[256];

#ifndef  MATLAB_MEX_FILE
#include "xpcioni.c"
#endif

static void mdlInitializeSizes(SimStruct *S) {
    int i, j;
#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#endif
    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n"
                "%d arguments are expected\n", NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, 0);

    ssSetNumOutputPorts(S, 1);
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, NO_P_WORKS);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (j = 0; j < NUMBER_OF_ARGS; j++)
        ssSetSFcnParamNotTunable(S, j);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
    return;
}

static void mdlInitializeSampleTimes(SimStruct *S) {
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S) {
    int *i = ssGetIWork(S);
#ifndef MATLAB_MEX_FILE
    PCIDeviceInfo pciinfo;
    void *Physical1, *Physical0;
    void *Virtual1, *Virtual0;
    unsigned int *ioaddress0;
    unsigned short *ioaddress1;
    const char *devName = NULL;
    int  devId, chan;
    ushort_T *stcReg, *stcMask, value;

    switch ((int_T)mxGetPr(DEV_ID_ARG)[0]) {
      case 1:
        devName = "NI PCI-6023E";
        devId   = 0x2a60;
        break;
      case 2:
        devName = "NI PCI-6024E";
        devId   = 0x2a70;
        break;
      case 3:
        devName = "NI PCI-6025E";
        devId   = 0x2a80;
        break;
      case 4:
        devName = "NI PCI-6070E";
        devId   = 0x1180;
        break;
      case 5:
        devName = "NI PCI-6040E";
        devId   = 0x1190;
        break;
      case 6:
        devName = "NI PXI-6070E";
        devId   = 0x11b0;
        break;
      case 7:
        devName = "NI PXI-6040E";
        devId   = 0x11c0;
        break;
      case 8:
        devName = "NI PCI-6071E";
        devId   = 0x1350;
        break;
      case 9:
        devName = "NI PCI-6052E";
        devId   = 0x18b0;
        break;
      case 10:
        devName = "NI PCI-6030E";
        devId   = 0x1170;
        break;
      case 11:
        devName = "NI PCI-6031E";
        devId   = 0x1330;
        break;
      case 12:
        devName = "NI PXI-6071E";
        devId   = 0x15B0;
        break;
    }

    if ((int_T)mxGetPr(PCI_DEV_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo(0x1093, (unsigned short)devId, &pciinfo)) {
            sprintf(msg,"%s: board not present", devName);
            ssSetErrorStatus(S,msg);
            return;
        }
    } else {
        int_T bus, slot;
        if (mxGetN(PCI_DEV_ARG) == 1) {
            bus = 0;
            slot = (int_T)mxGetPr(PCI_DEV_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(PCI_DEV_ARG)[0];
            slot = (int_T)mxGetPr(PCI_DEV_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlot(0x1093, (unsigned short)devId,
                                  (slot & 0xff) | ((bus & 0xff)<< 8),
                                  &pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",
                    devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    Physical1=(void *)pciinfo.BaseAddress[1];
    Virtual1 = rl32eGetDevicePtr(Physical1, 4096, RT_PG_USERREADWRITE);
    ioaddress1=(void *)Physical1;
    Physical0=(void *)pciinfo.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 4096, RT_PG_USERREADWRITE);
    ioaddress0=(void *) Physical0;
    ioaddress0[48]=((unsigned int)ioaddress1 & 0xffffff00) | 0x00000080;

    chan = (int)mxGetPr(CHANNEL_ARG)[0];
    stcReg  = STCRegisters[chan];
    stcMask = STCMasks[chan];
    Counter_Reset_All(ioaddress1, stcReg, stcMask);

    /* Set all PFIs for input */
    STCWRITE16(ioaddress1, IO_Bidirection_Pin_Register, 0x0000);
    /* Gi_Load_Source_Select <= 0 (Load A) */
    STCWRITE16(ioaddress1, stcReg[MODE_REG], 0x0000);
    writeLoadReg(ioaddress1, stcReg[LOAD_A_REG], 0x00000000);
    writeLoadReg(ioaddress1, stcReg[LOAD_B_REG], 0x00000000);

    /* Gi_Load <= 1 */
    STCWRITE16(ioaddress1, stcReg[COMMAND_REG], 0x0104);

    /****** Input Select Register *********/
    /* Gi_Source_Select    <= 0 (G_In_Time_Base1)
     * Gi_Source_Polarity  <= 0 (rising edges)
     * Gi_Gate_Select      <= 10 (PFI9: GPCTR0_Gate) or 5 (PFI4: GPCTR1_Gate)
     * Gi_OR_Gate          <= 0 (Dont OR with other ctrs gate)
     * Gi_Output_Polarity  <= 0 (initial high)
     * Gi_Gate_Select_Load_Source <= 0 (Dont select LOAD_[AB] based on gate)
     *
     */
    {
        ushort_T gates[] = {0x0500, 0x0280};
        value = gates[chan];            /* Gate input, Gi_Gate_Select */
    }
    STCWRITE16(ioaddress1, stcReg[INPUT_SELECT_REG],  value);

    /******** Mode Register *********/
    {
        uint16_T polarities[] = {0x2000, 0x0000};
        uint16_T gate_modes[] = {0x0001, 0x0002};
        /**
         * Output_Mode             <= 1 (one clock cycle output)
         * Reload Source Switching <= 0 (use same load reg)
         * Loading on Gate         <= 1 (reload on active gate edge)
         * Loading on TC           <= 0 (don't)
         * Gate on both Edges      <= 0 (don't)
         * Trig Mode for Edge Gate <= 3 (gate used to reload counter)
         * Stop Mode               <= 0 (Stop on gate condition)
         * Counting Once           <= 0 (don't disarm)
         */
        value = 0x4118 |
            /**
             * Gate_Polarity       <= 1 (invert:      active low) or
             *                        0 (dont invert: active high)
             */
            polarities[(int)mxGetPr(GATE_DIR_ARG)[0]] |
            /**
             * Gating Mode         <= 1 (level) or 2 (rising edge)
             */
            gate_modes[(int)mxGetPr(GATE_MODE_ARG)[0]];
    }
    STCWRITE16(ioaddress1, stcReg[MODE_REG], value);

    /****** Command_Register *****/
    /* Gi_Up_Down                    <= 1 (up)
     * Gi_Bank_Switch_Enable         <= 0
     * Gi_Bank_Switch_Mode           <= 0
     */
    STCWRITE16(ioaddress1, stcReg[COMMAND_REG], 0x0120);

    STCWRITE16(ioaddress1, stcReg[INTERRUPT_ENABLE_REG], 0x0000);
    STCWRITE16(ioaddress1, stcReg[COMMAND_REG], 0x0121);
    BASE_ADDR   = ioaddress1;
    CTR_CHANNEL = chan;
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid) {
#ifndef MATLAB_MEX_FILE
    ushort_T *base = BASE_ADDR;
    int       chan = CTR_CHANNEL;
    unsigned int output;
    ushort_T *reg  = STCRegisters[chan];

    if (STCREAD16(base, reg[GATE_STATUS_REG]) & 0x0004) {
        ssGetOutputPortRealSignal(S, 0)[0] = (double)
            ((unsigned int)STCREAD16(base, (unsigned short)(reg[HW_SAVE_REG] + 1)) |
             ((unsigned int)STCREAD16(base, reg[HW_SAVE_REG]) & 0x00ff) << 16);
        STCWRITE16(base, reg[INTERRUPT_ACK_REG], 0x8000); /* ack the intr */
    }
#endif
}

static void mdlTerminate(SimStruct *S) {
#ifndef MATLAB_MEX_FILE
    int chan = CTR_CHANNEL;
    Counter_Reset_All(BASE_ADDR, STCRegisters[chan], STCMasks[chan]);
#endif
    return;
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
