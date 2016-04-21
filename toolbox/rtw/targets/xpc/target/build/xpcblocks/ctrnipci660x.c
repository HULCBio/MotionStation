/* $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:01:54 $*/
/* ctrnipci660x.c - xPC Target, non-inlined S-function driver for PCI/PXI 6602
 *                  counter/timer boards. This driver is used for pulse train
 *                  generation.
/* Copyright 1996-2004 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         ctrnipci660x

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
#include        "time_xpcimport.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS       (6)
#define CHANNEL_ARG          ssGetSFcnParam(S, 0)
#define SAMP_TIME_ARG        ssGetSFcnParam(S, 1)
#define PCI_DEV_ARG          ssGetSFcnParam(S, 2)
#define INIT_HIGH_ARG        ssGetSFcnParam(S, 3)
#define INIT_LOW_ARG         ssGetSFcnParam(S, 4)
#define DEV_ID_ARG           ssGetSFcnParam(S, 5)

#define SAMP_TIME_IND        (0)

#define NO_R_WORKS           (0)
#define NO_I_WORKS           (4)
#define NO_P_WORKS           (1)

/* Index into PWork */
#define BASE_ADDR_P_IND      (0)
/*Index into IWork */
#define CHAN_I_IND           (0)     /*   Which channel is it?  */
#define  LOW_I_IND           (1)     /********************************/
#define HIGH_I_IND           (2)     /* Individual elements for ctrs */
#define BANK_I_IND           (3)     /********************************/

static char_T msg[256];

#ifndef  MATLAB_MEX_FILE
#include "xpcnitio.c"
#endif

static int inputSet = 0;

//static void getLowHigh(const double *lhDbl, unsigned int *lowhigh) {
//    lowhigh[0] = (unsigned int)lhDbl[0] - 1;
//    lowhigh[1] = (unsigned int)lhDbl[1] - 1;
//    return;
//}

static void mdlInitializeSizes(SimStruct *S) {
    int j;
#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
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

    ssSetNumInputPorts(S, 2);
    ssSetInputPortWidth(             S, 0, 1);
    ssSetInputPortDirectFeedThrough( S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 0, 1);
    ssSetInputPortWidth(             S, 1, 1);
    ssSetInputPortDirectFeedThrough( S, 1, 1);
    ssSetInputPortRequiredContiguous(S, 1, 1);

    ssSetNumOutputPorts(S, 0);

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
    const char *devName;
    unsigned short  devId;
    PCIDeviceInfo pciinfo;
    void *Physical1, *Physical0;
    void *Virtual1,  *Virtual0;
    volatile unsigned int *MITE;
    volatile uint16_T *board, *TIO;
    unsigned int ctrMask, chipOffset = 0, lowhigh[2];
    ushort_T absChan, chan;
    int inittype = 0;

    lowhigh[0] = mxGetPr(INIT_HIGH_ARG)[0];
    lowhigh[1] = mxGetPr(INIT_LOW_ARG)[0];

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
        printf("Unknown device detected.\n[%d x %d], first element\n"
               "%f\n", mxGetM(DEV_ID_ARG), mxGetN(DEV_ID_ARG),
               mxGetPr(DEV_ID_ARG));    /* xxxxxxxxx */

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
                                  (slot & (int_T)0xff) | 
                                  ((bus & (int_T)0xff)<< 8),
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
    i[CHAN_I_IND] = chan;

    /**
     * TIO is the base address of the _TIO Chip_, not the board. This is
     * the value that is saved in the PWork below. We will only address the
     * board in MdlStart, so we do not save the board address.
     */
    TIO = (unsigned short *)((char *)board + chipOffset);
    ssGetPWork(S)[BASE_ADDR_P_IND] = (int *)TIO;

    TIO_Write32((uint_T *)TIO, Clock_Config_Reg, ctrMask);
    /* Reset the Counter */
    resetCtr(TIO, chan);

    TIO_Write32((uint_T *)TIO, Clock_Config_Reg, ctrMask);
    /* Get Low and High Values and set up counter for them */
    lowhigh[0] = mxGetPr(INIT_HIGH_ARG)[0];
    lowhigh[1] = mxGetPr(INIT_LOW_ARG)[0];

    Cont_Pulse_Train_Generation(TIO, chan, lowhigh);

    /* Write 0x01000000 to enable Counter output to PFI */
    TIO_Write32((uint_T *)TIO, IOReg[absChan], 0x01000000);

    /* Arm the Counter: Gi_Arm <= 1 */
    TIO_Write16(TIO, chan, G0_Command_Reg, 0x1905);
    i[BANK_I_IND] = whichBank(TIO, chan);
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid) {
#ifndef MATLAB_MEX_FILE
    int32_T  *iwork = ssGetIWork(S);
    volatile void     *TIO   = ssGetPWork(S)[BASE_ADDR_P_IND];
    uint32_T  lowhigh[2], oldlow, oldhigh;
    ushort_T bank, chan;

    lowhigh[0] = (uint32_T)ssGetInputPortRealSignal(S, 0)[0];
    lowhigh[1] = (uint32_T)ssGetInputPortRealSignal(S, 1)[0];
    oldlow  = iwork[ LOW_I_IND];
    oldhigh = iwork[HIGH_I_IND];

    if( lowhigh[0] < 1 ) lowhigh[0] = 1;
    if( lowhigh[1] < 1 ) lowhigh[1] = 1;

    /* do nothing if nothing needs to be done */
    if (oldhigh == lowhigh[0] && oldlow == lowhigh[1]) return;

    bank = (ushort_T)iwork[BANK_I_IND];
    chan = (ushort_T)iwork[CHAN_I_IND];

    /* Banks need to have switched since last update; can't do it if not */
    if (whichBank(TIO, chan) != bank) {
        return;
    }

    /* Gi_Load_B <= high - 1 */
    TIO_Write32(TIO, (ushort_T)(G0_Load_B_Reg + regOff32[chan]), lowhigh[0]);
    /* Gi_Load_A <= low - 1 */
    TIO_Write32(TIO, (ushort_T)(G0_Load_A_Reg + regOff32[chan]), lowhigh[1]);

    /* Gi_Bank_Switch <= 1 */
    TIO_Write16(TIO, chan, G0_Command_Reg, 0x1d05);
    iwork[BANK_I_IND] = 1 - bank;
    iwork[HIGH_I_IND] = lowhigh[0];
    iwork[ LOW_I_IND] = lowhigh[1];
    return;
#endif /* not defined MATLAB_MEX_FILE */
}

static void mdlTerminate(SimStruct *S) {
    void *TIO  = ssGetPWork(S)[BASE_ADDR_P_IND];
    int   chan = ssGetIWork(S)[CHAN_I_IND];
    inputSet = 0;
#ifndef MATLAB_MEX_FILE
    resetCtr(TIO, chan);
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
