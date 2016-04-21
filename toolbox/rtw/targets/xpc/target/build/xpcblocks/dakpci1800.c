/* $Revision: 1.7 $ $Date: 2002/03/25 04:06:04 $ */
/* dakpci1800.c - xPC Target, non-inlined S-function driver for D/A section of KPCI-1800 series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dakpci1800

#include        <stddef.h>
#include        <stdlib.h>

#include        "simstruc.h"
#include        <math.h>

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
#define NUMBER_OF_ARGS          (6)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RESET_ARG               ssGetSFcnParam(S,1)
#define INIT_VAL_ARG            ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,3)
#define SLOT_ARG                ssGetSFcnParam(S,4)
#define DEV_ARG                 ssGetSFcnParam(S,5)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)

#define NO_R_WORKS              (4)
#define GAIN_R_IND              (0)
#define OFFSET_R_IND            (2)


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

#ifndef MATLAB_MEX_FILE


    int_T nChannels;
    int_T channel, range, dacRange, coupling;

    PCIDeviceInfo pciinfo;
    void *Physical;
    void *Virtual;
    volatile uint32_T *ioaddress;
    char devName[20];
    int  devId;
    double resFloat;
    volatile int16_T *ioaddress1;

    nChannels = mxGetN(CHANNEL_ARG);

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        strcpy(devName,"KPCI-1802HC");
        devId=0x1802;
        resFloat=65536.0;
        break;
      case 2:
        strcpy(devName,"KPCI-1801HC");
        devId=0x1801;
        resFloat=65536.0;
        break;
    }


    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        /* look for the PCI-Device */
        if (rl32eGetPCIInfo((unsigned short)0x11F3,(unsigned short)devId,&pciinfo)) {
            sprintf(msg,"%s: board not present", devName);
            ssSetErrorStatus(S,msg);
            return;
        }
    } else {
        int_T bus, slot;
        if (mxGetN(SLOT_ARG) == 1) {
            bus = 0;
            slot = (int_T)mxGetPr(SLOT_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(SLOT_ARG)[0];
            slot = (int_T)mxGetPr(SLOT_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x11F3,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    //rl32eShowPCIInfo(pciinfo);

    Physical=(void *)pciinfo.BaseAddress[2];
    Virtual = rl32eGetDevicePtr(Physical, 1024, RT_PG_USERREADWRITE);
    ioaddress=(void *)Physical;
    ioaddress1=(void *)Physical;

    ssSetIWorkValue(S, BASE_ADDR_I_IND, (uint_T)ioaddress);
    ssSetIWorkValue(S, CHANNELS_I_IND, nChannels);

    ioaddress[0x2]=0;

    ssSetRWorkValue(S, GAIN_R_IND, resFloat/20.0);

    ioaddress[0x1]= 0x00406;    // first digit (here 4) is the burst frequency: 1MHz/4=250kHz

    ioaddress[0x20]=0x00;
    ioaddress1[0x00]= 0;
    ioaddress[0x20]=0x01;
    ioaddress1[0x00]= 0;

    ioaddress[0x3]= 0x0; // what does this do?

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE


    uint_T base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T i;
    volatile uint32_T *ioaddress;
    volatile int16_T *ioaddress1;
    InputRealPtrsType uPtrs;
    real_T out;

    ioaddress=(void *) base;
    ioaddress1=(void *) base;

    for (i=0;i<nChannels;i++) {
        uPtrs = ssGetInputPortRealSignalPtrs(S,i);
        out= *uPtrs[0] * ssGetRWorkValue(S, GAIN_R_IND);
        out=max(out,-32768);
        out=min(out,32767);
        out=floor(out+0.5);
        ioaddress[0x20]=(uchar_T)mxGetPr(CHANNEL_ARG)[i]-1;
        ioaddress1[0x00]= (int16_T)out;
    }

#endif


}

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    int_T i;
    real_T out;
    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    uint_T base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    volatile uint32_T *ioaddress = (void *) base;
    volatile int16_T *ioaddress1 = (void *) base;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    for (i=0;i<nChannels;i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            out= mxGetPr(INIT_VAL_ARG)[i] * ssGetRWorkValue(S, GAIN_R_IND);
            out=max(out,-32768);
            out=min(out,32767);
            out=floor(out+0.5);
            ioaddress[0x20]=(uchar_T)mxGetPr(CHANNEL_ARG)[i]-1;
            ioaddress1[0x00]= (int16_T)out;
        }
    }

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
