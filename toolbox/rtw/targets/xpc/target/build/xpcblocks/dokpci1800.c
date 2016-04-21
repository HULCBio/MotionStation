/* $Revision: 1.6 $ $Date: 2002/03/25 04:07:54 $ */
/* dokpci1800.c - xPC Target, non-inlined S-function driver for Digital Output section of KPCI-1800 series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dokpci1800

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
#include        "util_xpcimport.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (7)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RESET_ARG               ssGetSFcnParam(S,1)
#define INIT_VAL_ARG            ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,3)
#define PCI_DEV_ARG             ssGetSFcnParam(S,4)
#define CONTROL_ARG             ssGetSFcnParam(S,5)
#define DEV_ID_ARG              ssGetSFcnParam(S,6)


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (3)
#define CHANNELS_I_IND          (0)
#define OUTPORT_I_IND           (1)
#define BASE_ADDR_I_IND         (2)

#define NO_R_WORKS              (0)

#define THRESHOLD               0.5

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumOutputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i = 0; i < NUMBER_OF_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);


}



static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{

    int_T num_channels;
    int_T i, channel;
    int_T Control_Register;

#ifndef MATLAB_MEX_FILE
    PCIDeviceInfo pciinfo;
    void *Physical;
    void *Virtual;
    volatile uint32_T *ioaddress;
    char devName[20];
    int  devId;
#endif

    num_channels = mxGetN(CHANNEL_ARG);

#ifndef MATLAB_MEX_FILE

    switch ((int_T)mxGetPr(DEV_ID_ARG)[0]) {
      case 1:
        strcpy(devName,"KPCI-1802HC");
        devId=0x1802;
        break;
      case 2:
        strcpy(devName,"KPCI-1801HC");
        devId=0x1801;
        break;
    }

    if ((int_T)mxGetPr(PCI_DEV_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo((unsigned short)0x11F3,(unsigned short)devId,&pciinfo)) {
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x11F3,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8) ,&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);

    Physical=(void *)pciinfo.BaseAddress[3];
    Virtual = rl32eGetDevicePtr(Physical, 1024, RT_PG_USERREADWRITE);
    ioaddress=(void *)Physical;
    ssSetIWorkValue(S, BASE_ADDR_I_IND, (uint_T)ioaddress);

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T i;
    uint8_T output, channel;
    volatile uint32_T *ioaddress;
    InputRealPtrsType uPtrs;

#ifndef MATLAB_MEX_FILE

    ioaddress=(void *) base_addr;

    output=0x00;
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        channel=(uint32_T)mxGetPr(CHANNEL_ARG)[i];
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        if (*uPtrs[0]>=THRESHOLD) {
            output |= 1 << (channel-1);
        } else {
            output &= ~(1 << (channel-1));
        }
    }
    ioaddress[0x9]= output;

#endif

}

static void mdlTerminate(SimStruct *S)
{
    uint32_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    uint8_T bit, mask, init, reset, output;
    int_T i, channel;
    volatile uint32_T *ioaddress;

#ifndef MATLAB_MEX_FILE

    ioaddress=(void *) base_addr;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    init = reset = mask = 0;

    for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
        channel = (int_T)(mxGetPr(CHANNEL_ARG)[i] - 1);
        bit = 1 << channel;
        mask |= bit;
        if ((uint_T)mxGetPr(INIT_VAL_ARG)[i] > 0)
            init |= bit;
        if ((uint_T)mxGetPr(RESET_ARG)[i] > 0)
            reset |= bit;
    }

    if (~xpceIsModelInit()) {
        mask &= reset;
        init &= reset;
    }

    output = ioaddress[0x9];
    output &= ~mask;
    output |= init;
    ioaddress[0x9] = output;

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
