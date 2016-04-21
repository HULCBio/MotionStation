/* ctrnipcie.c - xPC Target, non-inlined S-function driver for
 *               Pulse Train generation using the General Purpose Counters
 *               of the National Instruments E series boards.
 */
/* Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.4.6.1 $ $Date: 2004/03/02 03:03:55 $
 */

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         ctrnipcie

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
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (4)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,1)
#define PCI_DEV_ARG             ssGetSFcnParam(S,2)
#define DEV_ID_ARG              ssGetSFcnParam(S,3)

#define SAMP_TIME_IND           (0)

#define NO_R_WORKS              (0)
#define NO_I_WORKS              (7)
#define NO_P_WORKS              (1)

/* Index into PWork */
#define BASE_ADDR_P_IND         (0)
/*Index into IWork */
#define CHANNEL_I_IND           (0)     /*   Which channel(s) are used?  */
#define G0_I_IND                (1)     /*   Starting Index of G0 Part   */
#define G1_I_IND                (4)     /*   Starting Index of G1 Part   */
#define LOW_I_IND               (0)     /********************************/
#define HIGH_I_IND              (1)     /* Individual elements for ctrs */
#define BANK_I_IND              (2)     /********************************/

static char_T msg[256];

#ifndef  MATLAB_MEX_FILE
#include "xpcioni.c"
#endif

static void getLowHigh(SimStruct *S, int inpPort, unsigned int *lowhigh) {
    lowhigh[0] = ((unsigned int)ssGetInputPortRealSignal(S, inpPort)[0] - 1)
        & 0xffffff;
    lowhigh[1] = ((unsigned int)ssGetInputPortRealSignal(S, inpPort)[1] - 1)
        & 0xffffff;
    return;
}

static void mdlInitializeSizes(SimStruct *S) {
    int i, j, numInputs;
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

    i = (int)mxGetPr(CHANNEL_ARG)[0];
    numInputs = (i == 3 ? 2 : 1);
    ssSetNumInputPorts(S, numInputs);
    for (j = 0; j < numInputs; j++) {
        ssSetInputPortWidth(             S, j, 2);
        ssSetInputPortDirectFeedThrough( S, j, 1);
        ssSetInputPortRequiredContiguous(S, j, 1);
    }

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
    PCIDeviceInfo pciinfo;
    unsigned int lowhigh[2];
    void *Physical1, *Physical0;
    void *Virtual1, *Virtual0;
    unsigned int *ioaddress0;
    volatile unsigned short *ioaddress1;
    const char *devName = NULL;
    int  devId;
    int  chan0, chan1, channel;

    i[CHANNEL_I_IND] = (int)mxGetPr(CHANNEL_ARG)[0];
    i[BANK_I_IND + G0_I_IND] = i[BANK_I_IND + G1_I_IND] = 0;
    chan0 = i[CHANNEL_I_IND] & 0x1;
    chan1 = i[CHANNEL_I_IND] & 0x2;
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
    ssGetPWork(S)[BASE_ADDR_P_IND] = (unsigned short *)ioaddress1;

    if (chan0)
        Counter_Reset_All(ioaddress1, STCRegisters[0], STCMasks[0]);
    if (chan1)
        Counter_Reset_All(ioaddress1, STCRegisters[1], STCMasks[1]);
    /* Set all PFIs for input */
    DAQ_STC_Windowed_Mode_Write(ioaddress1, IO_Bidirection_Pin_Register,
                                0x0000);
    if (chan0) {
        getLowHigh(S, 0, lowhigh);
        Cont_Pulse_Train_Generation(ioaddress1, STCRegisters[0],
                                    STCMasks[0], lowhigh);
    }
    if (chan1) {
        /* if !chan0, chan1 is the first input set, so we have to pass 0 */
        getLowHigh(S, (chan0 ? 1 : 0), lowhigh);
        Cont_Pulse_Train_Generation(ioaddress1, STCRegisters[1],
                                    STCMasks[1], lowhigh);
    }
    Enable_Counters(ioaddress1, chan0, chan1);
    if (chan0)
        Ctr_Arm_All(ioaddress1, STCRegisters[0]);
    if (chan1)
        Ctr_Arm_All(ioaddress1, STCRegisters[1]);

#endif
}

#ifndef MATLAB_MEX_FILE
static void switchOutputs(SimStruct *S,
                          int32_T  *iwork,
                          volatile ushort_T *ioaddress,
                          int      inpPort,
                          ushort_T *reg, ushort_T *mask) {
    uint32_T lowhigh[2], oldlow, oldhigh;
    ushort_T bank;
    getLowHigh(S, inpPort, lowhigh);
    oldlow  = (uint32_T)iwork[ LOW_I_IND];
    oldhigh = (uint32_T)iwork[HIGH_I_IND];
    bank    = (ushort_T)iwork[BANK_I_IND];
    /* do nothing if nothing needs to be done */
    if (oldlow == lowhigh[0] && oldhigh == lowhigh[1]) return;
    /* Banks need to have switched since last update; can't do it if not */
    if (!!(DAQ_STC_Windowed_Mode_Read(ioaddress, Joint_Status_1_Register) &
           mask[GI_BANK_ST]) != bank) return;

    /* Load low, high values into appropriate registers */

    /* Gi_Load_A <= low - 1 */
    /* masking not necessary since it is already only 24 bit wide */
    DAQ_STC_Windowed_Mode_Write(ioaddress,  reg[LOAD_A_REG],
                                (ushort_T)(lowhigh[0] >> 16));
    DAQ_STC_Windowed_Mode_Write(ioaddress,  (ushort_T)(reg[LOAD_A_REG] + 1),
                                (ushort_T)(lowhigh[0] & 0xffff));

    /* Gi_Load_B <= high - 1 */
    /* masking not necessary since it is already only 24 bit wide */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[LOAD_B_REG],
                                (ushort_T)(lowhigh[1] >> 16));
    DAQ_STC_Windowed_Mode_Write(ioaddress,  (ushort_T)(reg[LOAD_B_REG] + 1),
                                (ushort_T)(lowhigh[1] & 0xffff));
    /* Gi_Bank_Switch <= 1 */
    DAQ_STC_Windowed_Mode_Write(ioaddress, reg[COMMAND_REG], 0x1d05);
    iwork[BANK_I_IND] = 1 - bank;
    iwork[ LOW_I_IND] = (int32_T)lowhigh[0];
    iwork[HIGH_I_IND] = (int32_T)lowhigh[1];
    return;
}
#endif /* not defined MATLAB_MEX_FILE */

static void mdlOutputs(SimStruct *S, int_T tid) {
#ifndef MATLAB_MEX_FILE
    uint32_T          lowhigh[2], oldlow, oldhigh;
    uchar_T           output, chan;
    int32_T          *i = ssGetIWork(S);
    volatile unsigned short *ioaddress = 
        (volatile unsigned short *)ssGetPWork(S)[BASE_ADDR_P_IND];

    chan = i[CHANNEL_I_IND];
    if (chan & 0x1)                     /* channel 0 is used */
        switchOutputs(S, i + G0_I_IND, ioaddress, 0,
                      STCRegisters[0], STCMasks[0]);
    if (chan & 0x2)                     /* channel 1 is used */
        /* if channel is 3, we want input 1, else 0 */
        switchOutputs(S, i + G1_I_IND, ioaddress, (chan == 3),
                      STCRegisters[1], STCMasks[1]);
#endif
}

static void mdlTerminate(SimStruct *S) {
#ifndef MATLAB_MEX_FILE
    uchar_T channel = (uchar_T)ssGetIWork(S)[CHANNEL_I_IND];
    volatile unsigned short *ioaddress = (volatile unsigned short *)ssGetPWork(S)[BASE_ADDR_P_IND];
    if (channel & 0x01)
        Counter_Reset_All(ioaddress, STCRegisters[0], STCMasks[0]);
    if (channel & 0x02)
        Counter_Reset_All(ioaddress, STCRegisters[1], STCMasks[1]);
#endif
    return;
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
