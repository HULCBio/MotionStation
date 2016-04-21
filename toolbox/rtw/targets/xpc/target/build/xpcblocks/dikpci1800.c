/* $Revision: 1.4 $ $Date: 2002/03/25 04:06:53 $ */
/* dikpci1800.c - xPC Target, non-inlined S-function driver for Digital Input section of KPCI-1800 series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dikpci1800

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
#define NUMBER_OF_ARGS          (5)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,1)
#define PCI_DEV_ARG             ssGetSFcnParam(S,2)
#define CONTROL_ARG             ssGetSFcnParam(S,3)
#define DEV_ID_ARG              ssGetSFcnParam(S,4)


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
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumInputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);


    ssSetSFcnParamNotTunable(S,0);
    ssSetSFcnParamNotTunable(S,1);
    ssSetSFcnParamNotTunable(S,2);
    ssSetSFcnParamNotTunable(S,3);
    ssSetSFcnParamNotTunable(S,4);

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
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot);
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
    uint8_T input, channel;
    volatile uint32_T *ioaddress;
    real_T *y;

#ifndef MATLAB_MEX_FILE

    ioaddress=(void *) base_addr;

    input=ioaddress[0x9];

    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        channel=(int_T)mxGetPr(CHANNEL_ARG)[i]-1;
        y=ssGetOutputPortSignal(S,i);
        y[0]=( input & (1 << channel) ) >> channel;
    }

#endif

}

static void mdlTerminate(SimStruct *S)
{
    uint32_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    volatile uint32_T *ioaddress;

#ifndef MATLAB_MEX_FILE

    ioaddress=(void *) base_addr;
    ioaddress[0x9]=0x00;

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
