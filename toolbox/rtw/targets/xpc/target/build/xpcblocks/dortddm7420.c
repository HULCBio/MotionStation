/* $Revision: 1.4 $ $Date: 2002/03/25 04:08:13 $ */
/* dortddm7420.c - xPC Target, non-inlined S-function driver for DIO section of RTD DM7420 board  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dortddm7420

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
#define NUMBER_OF_ARGS          (5)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define PORT_ARG                ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define SLOT_ARG                ssGetSFcnParam(S,3)
#define DEV_ARG                 ssGetSFcnParam(S,4)

#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (3)
#define LAS0_I_IND              (0)
#define LAS1_I_IND              (1)
#define LAS2_I_IND              (2)

#define NO_R_WORKS              (0)

#define THRESHOLD               0.5



static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    uint_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S,mxGetN(CHANNEL_ARG));
    for (i=0; i<mxGetN(CHANNEL_ARG); i++) {
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

    for (i=0; i<NUMBER_OF_ARGS; i++) {
        ssSetSFcnParamNotTunable(S,i);
    }

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


    uint16_T numChannels;

    PCIDeviceInfo pciinfo;
    char devName[20];
    uint16_T    LAS0, LAS1, LAS2;
    int  devId;
    uint16_T i, j;
    uint16_T output, channel, port;
    real_T currentTime;
    uchar_T tmp;

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        strcpy(devName,"RTD DM7420");
        devId=0x7420;
        break;
    }


    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        /* look for the PCI-Device */
        if (rl32eGetPCIInfo((unsigned short)0x1435,(unsigned short)devId,&pciinfo)) {
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1435,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);

    LAS0= pciinfo.BaseAddress[2];
    LAS1= pciinfo.BaseAddress[3];
    LAS2= pciinfo.BaseAddress[4];

    ssSetIWorkValue(S, LAS0_I_IND, (int_T)LAS0);
    ssSetIWorkValue(S, LAS1_I_IND, (int_T)LAS1);
    ssSetIWorkValue(S, LAS2_I_IND, (int_T)LAS2);

    numChannels = (int16_T)mxGetN(CHANNEL_ARG);

    port = ((int16_T)mxGetPr(PORT_ARG)[0])-1;

    if (port==0) {

        // read port 1 direction
        tmp= rl32eInpB(LAS2+0x13) & 0x04;

        // select direction register
        rl32eOutpB(LAS2+0x13, tmp | 0x01);

        // write directions
        rl32eOutpB(LAS2+0x12, 0xff);

    } else if (port==1) {

        // read port 0 direction
        tmp= rl32eInpB(LAS2+0x13) & 0x03;

        // write direction
        rl32eOutpB(LAS2+0x13, tmp | 0x04);

    }

    rl32eOutpB(LAS2+ 0x10+ port, 0x00);

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    uint16_T                    LAS2= (uint16_T)ssGetIWorkValue(S, LAS2_I_IND);
    int_T                               i;
    uchar_T                     channel, tmp;
    InputRealPtrsType   uPtrs;
    int16_T                     port = ((int16_T)mxGetPr(PORT_ARG)[0])-1;

    tmp=0x00;

    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        channel=(uchar_T)mxGetPr(CHANNEL_ARG)[i];
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        if (*uPtrs[0]>=THRESHOLD) {
            tmp|= 1 << (channel-1);
        }
    }

    rl32eOutpB(LAS2+0x10+port,tmp);

#endif

}

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    uint16_T    LAS2= (uint16_T)ssGetIWorkValue(S, LAS2_I_IND);
    int16_T     port= ((int16_T)mxGetPr(PORT_ARG)[0])-1;


    rl32eOutpB(LAS2+ 0x10+ port, 0x00);

#endif

}




#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
