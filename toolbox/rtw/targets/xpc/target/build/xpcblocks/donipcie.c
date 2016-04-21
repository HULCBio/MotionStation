/* $Revision: 1.13.6.3 $ $Date: 2004/04/08 21:02:10 $*/
/* donipcie.c - xPC Target, non-inlined S-function driver for Digital Output section of NI PCI-E series boards  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         donipcie

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
#include        "xpcioni.h"
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

#ifndef         MATLAB_MEX_FILE
#include        "xpcioni.c"
#endif

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
    int_T i, output, channel;
    int_T Control_Register;

#ifndef MATLAB_MEX_FILE
    PCIDeviceInfo pciinfo;
    void *Physical1, *Physical0;
    void *Virtual1, *Virtual0;
    unsigned int *ioaddress0;
    unsigned short *ioaddress1;
    char devName[20];
    int  devId;
#endif

    num_channels = mxGetN(CHANNEL_ARG);

#ifndef MATLAB_MEX_FILE

    switch ((int_T)mxGetPr(DEV_ID_ARG)[0]) {
      case 1:
        strcpy(devName,"NI PCI-6023E");
        devId=0x2a60;
        break;
      case 2:
        strcpy(devName,"NI PCI-6024E");
        devId=0x2a70;
        break;
      case 3:
        strcpy(devName,"NI PCI-6025E");
        devId=0x2a80;
        break;
      case 4:
        strcpy(devName,"NI PCI-MIO-16E-1");
        devId=0x1180;
        break;
      case 5:
        strcpy(devName,"NI PCI-MIO-16E-4");
        devId=0x1190;
        break;
      case 6:
        strcpy(devName,"NI PXI-6070E");
        devId=0x11b0;
        break;
      case 7:
        strcpy(devName,"NI PXI-6040E");
        devId=0x11c0;
        break;
      case 8:
        strcpy(devName,"NI PCI-6071E");
        devId=0x1350;
        break;
      case 9:
        strcpy(devName,"NI PCI-6052E");
        devId=0x18b0;
        break;
      case 10:
        strcpy(devName,"NI PCI-MIO-16XE-10");
        devId=0x1170;
        break;
      case 11:
        strcpy(devName,"NI PCI-6031E");
        devId=0x1330;
        break;
      case 12:
        strcpy(devName,"NI PXI-6071E");
        devId=0x15B0;
        break;
      case 13:
        strcpy(devName,"NI PCI-6713");
        devId=0x1870;
        break;
      case 14:
        strcpy(devName,"NI PXI-6713");
        devId=0x2B80;
        break;
      case 15:
        strcpy(devName,"NI PXI-6711");
        devId=0x1880;
        break;
    }



    if ((int_T)mxGetPr(PCI_DEV_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo((unsigned short)0x1093,(unsigned short)devId,&pciinfo)) {
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1093,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    //rl32eShowPCIInfo(pciinfo);

    Physical1=(void *)pciinfo.BaseAddress[1];
    Virtual1 = rl32eGetDevicePtr(Physical1, 4096, RT_PG_USERREADWRITE);
    ioaddress1=(void *)Physical1;
    Physical0=(void *)pciinfo.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 4096, RT_PG_USERREADWRITE);
    ioaddress0=(void *) Physical0;
    ioaddress0[48]=((unsigned int)ioaddress1 & 0xffffff00) | 0x00000080;
    ssSetIWorkValue(S, BASE_ADDR_I_IND, (uint_T)ioaddress1);


    DAQ_STC_Windowed_Mode_Write(ioaddress1, DIO_Control_Register,(unsigned short)((int_T)mxGetPr(CONTROL_ARG)[0]));

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T i;
    uchar_T output, channel;
    unsigned short *ioaddress;
    InputRealPtrsType uPtrs;

#ifndef MATLAB_MEX_FILE

    ioaddress=(void *) base_addr;


    output=DAQ_STC_Windowed_Mode_Read(ioaddress, DIO_Parallel_Input_Register);
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        channel=(uchar_T)mxGetPr(CHANNEL_ARG)[i];
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        if (*uPtrs[0]>=THRESHOLD) {
            output |= 1 << (channel-1);
        } else {
            output &= ~(1 << (channel-1));
        }
    }
    DAQ_STC_Windowed_Mode_Write(ioaddress, DIO_Output_Register, output);

#endif

}

static void mdlTerminate(SimStruct *S)
{
    uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    uchar_T i, output, channel;
    unsigned short *ioaddress;

#ifndef MATLAB_MEX_FILE

    ioaddress=(void *) base_addr;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    output=DAQ_STC_Windowed_Mode_Read(ioaddress, DIO_Parallel_Input_Register);
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            channel=(uchar_T)mxGetPr(CHANNEL_ARG)[i];
            if ((uint_T)mxGetPr(INIT_VAL_ARG)[i] > 0)
                output |= 1 << (channel-1);
            else 
                output &= ~(1 << (channel-1));
        }
    }
    DAQ_STC_Windowed_Mode_Write(ioaddress, DIO_Output_Register, output);

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
