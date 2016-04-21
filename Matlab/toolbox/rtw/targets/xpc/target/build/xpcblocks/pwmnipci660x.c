/**
 * pwmnipci660x.c - xPC Target, non-inlined S-function driver for PCI/PXI
 *                  6602 counter/timer boards. This driver is used for
 *                  pulsewidth/period measurement
 *
 */
/* Copyright 1996-2004 The MathWorks, Inc. */
/* $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:03:18 $*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         pwmnipci660x

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
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS       (6)
#define CHANNEL_ARG          ssGetSFcnParam(S, 0)
#define CHANNEL_ARG          ssGetSFcnParam(S, 0)
#define GATE_MODE_ARG        ssGetSFcnParam(S, 1) /* level or edge */
/* Falling/Rising for Edge gate, or low/high for level gate */
#define GATE_DIR_ARG         ssGetSFcnParam(S, 2)
#define SAMP_TIME_ARG        ssGetSFcnParam(S, 3)
#define PCI_DEV_ARG          ssGetSFcnParam(S, 4)
#define DEV_ID_ARG           ssGetSFcnParam(S, 5)

#define SAMP_TIME_IND        (0)

#define NO_R_WORKS           (0)
#define NO_I_WORKS           (1)
#define NO_P_WORKS           (1)

#define BASE_ADDR               (ssGetPWork(S)[0])
#define CTR_CHANNEL             (ssGetIWork(S)[0])

static char_T msg[256];

#ifndef  MATLAB_MEX_FILE
#include "xpcnitio.c"
#endif

static int inputSet = 0;

static void mdlInitializeSizes(SimStruct *S) {
    int j;
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
#ifndef MATLAB_MEX_FILE
    const char *devName;
    int  devId;
    PCIDeviceInfo pciinfo;
    void *Physical1, *Physical0;
    void *Virtual1,  *Virtual0;
    volatile unsigned int *MITE;
    volatile uint16_T *board, *TIO, value;
    unsigned int ctrMask, chipOffset = 0;
    int absChan, chan;
    int inittype = 0;

    switch ((int)mxGetPr(DEV_ID_ARG)[0]) {
      case 1:
        devName = "NI PCI 6602";
        devId = 0x1310;
        inittype = 2;
        break;
      case 2:
        devName = "NI PXI 6602";
        devId = 0x1360;
        inittype = 2;
        break;
      case 3:
        devName = "NI PCI 6601";
        devId = 0x2c60;
        inittype = 1;
        break;
      default:
        devName = "Unknown device";
        devId = 0xFFFF;
        break;
    }
    if ((int_T)mxGetPr(PCI_DEV_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo(0x1093, devId, &pciinfo)) {
            sprintf(msg, "%s: board not present", devName);
            ssSetErrorStatus(S, msg);
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
        if (rl32eGetPCIInfoAtSlot(0x1093, devId,
                                  (slot & 0xff) | ((bus & 0xff)<< 8),
                                  &pciinfo)) {
            sprintf(msg, "%s (bus %d, slot %d): board not present",
                    devName, bus, slot);
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    Physical1 = (void *)pciinfo.BaseAddress[1];
    Virtual1  = rl32eGetDevicePtr(Physical1, 4096, RT_PG_USERREADWRITE);
    board     = (void *)Physical1;
    Physical0 = (void *)pciinfo.BaseAddress[0];
    Virtual0  = rl32eGetDevicePtr(Physical0, 4096, RT_PG_USERREADWRITE);
    MITE      = (volatile unsigned int *) Physical0;
    if( inittype == 2 )  // 6602 MITE init
    {
        MITE[49]  = ((unsigned int)board & 0xffffff00) | 0x0000008C;
        MITE[61]  = 0;
    }
    else  // 6601 MITE init
    {
        MITE[48]  = ((unsigned int)board & 0xffffff00) | 0x00000080;
    }

    if (!inputSet) {
        int i;
        /* set all counters for input */
        //TIO_Write32((uint_T *)(board + 0x000), Clock_Config_Reg, 0x00000000);
        //TIO_Write32((uint_T *)(board + 0x400), Clock_Config_Reg, 0x00200000);
        inputSet = 1;
    }

    absChan = (int)mxGetPr(CHANNEL_ARG)[0]; /* 0-based */
    chan    = absChan % 4;
    if (absChan / 4) {                  /* counters 4 - 7, on chip 1 */
        chipOffset = 0x800;
        ctrMask    = 0x00200000;
    } else {
        chipOffset = 0;
        ctrMask    = 0;
    }
    /* IWork gets the channel relative to the chip: e.g. Ctr5 is <TIO1,
     * Ctr1>. absChan contains the absolute channel no. (in this case 5). */
    CTR_CHANNEL = chan;

    /* TIO is the base address of the _TIO Chip_, not the board. This is
     * the value that is saved in the PWork below. We will only address the
     * board in MdlStart, so we do not save the board address. */
    TIO = (unsigned short *)((char *)board + chipOffset);
    BASE_ADDR = TIO;

    TIO_Write32((uint_T *)TIO, IOReg[absChan], 0x00000000);

    TIO_Write32((uint_T *)TIO, Clock_Config_Reg, ctrMask);
    /* Reset the Counter */
    resetCtr(TIO, chan);

    /* Load Select <= 0 (Load_Reg_A) */
    TIO_Write16(TIO, chan, G0_Mode_Reg, 0x0000);
    /* Write the load registers */
    TIO_Write32((uint32_T *)TIO, G0_Load_A_Reg + regOff32[chan], 0x00000000);
    TIO_Write32((uint32_T *)TIO, G0_Load_B_Reg + regOff32[chan], 0x00000000);
    /* Gi_Alternate_Sync <= 1 (needed for 80 MHz) */
    TIO_Write16(TIO, chan, G0_Counting_Mode_Reg, 0x2000);

    /**
     * Synchronized Gate           <= 1
     * Load                        <= 1 (strobe)
     */
    TIO_Write16(TIO, chan, G0_Command_Reg, 0x0104);

    /**** Input_Select ****/
    /**
     * Source Select               <= 30 (11110)
     * Source Polarity             <= 0 (Rising Edge)
     * Gate Select                 <= 1 (gate pin dedicated to this counter)
     * Output Polarity             <= 0 (initial high)
     */
    TIO_Write16(TIO, chan, G0_Input_Select_Reg, 0x00F8);

    /******* Mode Register *******/
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
             * Gate_Polarity       <= 0 (dont invert: active high) or
             *                        1 (invert:       active low)
             */
            polarities[(int)mxGetPr(GATE_DIR_ARG)[0]] |
            /**
             * Gating Mode         <= 1 (level) or 2 (rising edge)
             */
            gate_modes[(int)mxGetPr(GATE_MODE_ARG)[0]];
    }
    TIO_Write16(TIO, chan, G0_Mode_Reg, value);

    /**
     * Up/Down                    <= 1 (up)
     * Bank_Switch_Enable         <= 0
     * Bank_Switch_Mode           <= 0
     * Arm                        <= 1 (strobe)
     */
    TIO_Write16(TIO, chan, G0_Command_Reg, 0x0121);
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid) {
#ifndef MATLAB_MEX_FILE
    static ushort_T HWSave[] = {0x010, 0x014, 0x110, 0x114};
    static ushort_T SWSave[] = {0x018, 0x01C, 0x118, 0x11C};
    int32_T chan = CTR_CHANNEL;
    void   *TIO  = BASE_ADDR;
    uint32_T value;

    ssGetOutputPortRealSignal(S, 0)[0] =
        (double)TIO_Read32(TIO, HWSave[chan]);

    return;
#endif /* not defined MATLAB_MEX_FILE */
}

static void mdlTerminate(SimStruct *S) {
    inputSet = 0;
#ifndef MATLAB_MEX_FILE
    resetCtr(BASE_ADDR, CTR_CHANNEL);
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
