/* $Revision: 1.4 $ $Date: 2002/03/25 03:59:51 $ */
/* adkpci1800.c - xPC Target, non-inlined S-function driver for A/D section of KPCI-1800 series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         adkpci1800

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
#define NUMBER_OF_ARGS          (6)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RANGE_ARG               ssGetSFcnParam(S,1)
#define COUPLING_ARG            ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,3)
#define SLOT_ARG                ssGetSFcnParam(S,4)
#define DEV_ARG                 ssGetSFcnParam(S,5)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)

#define NO_R_WORKS              (128)
#define GAIN_R_IND              (0)
#define OFFSET_R_IND            (64)


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
    ssSetSFcnParamNotTunable(S,5);

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
    int_T i, channel, range, dacRange, coupling;
    uint32_T out;

    PCIDeviceInfo pciinfo;
    void *Physical;
    void *Virtual;
    volatile uint32_T *ioaddress;
    char devName[20];
    int  devId;
    double resFloat;

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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x11F3,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8) ,&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    //rl32eShowPCIInfo(pciinfo);

    Physical=(void *)pciinfo.BaseAddress[1];
    Virtual = rl32eGetDevicePtr(Physical, 65536, RT_PG_USERREADWRITE);
    ioaddress=(void *)Physical;


    ssSetIWorkValue(S, BASE_ADDR_I_IND, (uint_T)ioaddress);
    ssSetIWorkValue(S, CHANNELS_I_IND, nChannels);

    ioaddress[0x2]=nChannels-1;

    out=0x0;


    for (i=0;i<nChannels;i++) {

        channel=mxGetPr(CHANNEL_ARG)[i];
        range=(int_T)(1000*mxGetPr(RANGE_ARG)[i]);
        coupling=mxGetPr(COUPLING_ARG)[i];

        switch ((int_T)mxGetPr(DEV_ARG)[0]) {
          case 1:
            if (range== -10000) {
                out=0x0;
                ssSetRWorkValue(S, GAIN_R_IND+i, 20.0/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.0);
            } else if (range==-5000) {
                out=0x1;
                ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.0);
            } else if (range==-2500) {
                out=0x2;
                ssSetRWorkValue(S, GAIN_R_IND+i, 5.0/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.0);
            } else if (range==-1250) {
                out=0x3;
                ssSetRWorkValue(S, GAIN_R_IND+i, 2.5/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.0);
            } else if (range==10000) {
                out=0x4;
                ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 5.0);
            } else if (range==5000) {
                out=0x5;
                ssSetRWorkValue(S, GAIN_R_IND+i, 5.0/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 2.5);
            } else if (range==2500) {
                out=0x6;
                ssSetRWorkValue(S, GAIN_R_IND+i, 2.5/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 1.25);
            } else if (range==1250) {
                out=0x7;
                ssSetRWorkValue(S, GAIN_R_IND+i, 1.25/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.625);
            }
            break;
          case 2:
            if (range== -5000) {
                out=0x0;
                ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.0);
            } else if (range==-1000) {
                out=0x1;
                ssSetRWorkValue(S, GAIN_R_IND+i, 2.0/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.0);
            } else if (range==-100) {
                out=0x2;
                ssSetRWorkValue(S, GAIN_R_IND+i, 0.2/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.0);
            } else if (range==-20) {
                out=0x3;
                ssSetRWorkValue(S, GAIN_R_IND+i, 0.04/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.0);
            } else if (range==5000) {
                out=0x4;
                ssSetRWorkValue(S, GAIN_R_IND+i, 5.0/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 2.5);
            } else if (range==1000) {
                out=0x5;
                ssSetRWorkValue(S, GAIN_R_IND+i, 1.0/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.5);
            } else if (range==100) {
                out=0x6;
                ssSetRWorkValue(S, GAIN_R_IND+i, 0.1/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.05);
            } else if (range==20) {
                out=0x7;
                ssSetRWorkValue(S, GAIN_R_IND+i, 0.02/resFloat);
                ssSetRWorkValue(S, OFFSET_R_IND+i, 0.01);
            }
            break;
        }

        out= out << 7;
        if (coupling==0) {
            out |= 0x40;
        }

        ioaddress[0x1000+i]= out | (uint32_T)(channel-1);

    }

    ioaddress[0x1]= 0x40c06;    // first digit (here 4) is the burst frequency: 1MHz/4=250kHz

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE


    uint_T base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T i, res;
    double gain;
    volatile uint32_T *ioaddress;
    volatile int16_T *ioaddress1;
    real_T  *y;

    ioaddress=(void *) base;
    ioaddress1=(void *) base;

    ioaddress[0x0]=0x00;

    for (i=0;i<nChannels;i++) {
        y=ssGetOutputPortSignal(S,i);
        while (!(ioaddress[0x1]&0x20));
        y[0] = ioaddress1[0x0] * ssGetRWorkValue(S, GAIN_R_IND+i) + ssGetRWorkValue(S, OFFSET_R_IND+i);
    }

#endif


}

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE


    uint_T base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    volatile uint32_T *ioaddress;

    ioaddress=(void *) base;

    ioaddress[0x1]=0x00;

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
