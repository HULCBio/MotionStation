/* $Revision: 1.5.6.1 $ $Date: 2004/04/08 21:03:24 $ */
/* tccbpcidastc.c - xPC Target, non-inlined S-function driver for thermocouple input section of CB PCI-DAS-TC board  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         tccbpcidastc

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
static uint8_T readDPRAM(uint_T baseAddress, uint16_T offset);
static void writeDPRAM(uint_T baseAddress, uint16_T offset, uint8_T value);
static uint8_T executeCommand(uint_T baseAddress, uint8_T command);
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS      (9)
#define RESOLUTION_ARG      ssGetSFcnParam(S,0)
#define AVERAGE_ARG         ssGetSFcnParam(S,1)
#define NCHANNELS_ARG       ssGetSFcnParam(S,2)
#define TCTYPE_ARG          ssGetSFcnParam(S,3)
#define GAIN_ARG            ssGetSFcnParam(S,4)
#define FORMAT_ARG          ssGetSFcnParam(S,5)
#define CJC_ARG             ssGetSFcnParam(S,6)
#define SAMP_TIME_ARG       ssGetSFcnParam(S,7)
#define SLOT_ARG            ssGetSFcnParam(S,8)

#define SAMP_TIME_IND       (0)

#define NO_I_WORKS          (1)
#define BASE_ADDR_I_IND     (0)

#define NO_R_WORKS          (0)


static char_T msg[256];

static uint_T init=1;

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

    if ((int_T)mxGetPr(CJC_ARG)[0]) {
        ssSetNumOutputPorts(S, (int_T)mxGetPr(NCHANNELS_ARG)[0]+1);
    } else {
        ssSetNumOutputPorts(S, (int_T)mxGetPr(NCHANNELS_ARG)[0]);
    }

    for (i=0; i< ssGetNumOutputPorts(S); i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumInputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i=0; i< NUMBER_OF_ARGS; i++) {
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

    PCIDeviceInfo pciinfo;
    uint_T baseAddress;
    char devName[20];
    int  devId;
    int_T i, k, conf;
    uint8_T returnCode;

    strcpy(devName,"CB PCI-DAS-TC");
    devId=0x34;

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        /* look for the PCI-Device */
        if (rl32eGetPCIInfo((unsigned short)0x1307,(unsigned short)devId,&pciinfo)) {
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1307,(unsigned short)devId, (slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);

    baseAddress=pciinfo.BaseAddress[2];

    //printf("Base Address: %x\n",baseAddress);

    ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)baseAddress);

    if (init) {

        // define general configuration (same for all channels)
        conf= ((int_T)mxGetPr(AVERAGE_ARG)[0] << 2) | ((int_T)mxGetPr(RESOLUTION_ARG)[0]-1);
        returnCode=0x00;
        while (returnCode!=0x80) {
            writeDPRAM(baseAddress, (uint16_T)0x300, (uint8_T)conf);
            returnCode= executeCommand(baseAddress, 0x80);
        }

        // configure the channels (channel specific settings)
        for (i=0; i<(int_T)mxGetPr(NCHANNELS_ARG)[0]; i++) {
            printf("        CB PCI-DAS-TC: init channel %x\n", i+1);
            conf= ((int_T)mxGetPr(TCTYPE_ARG)[i]-1) | (((int_T)mxGetPr(GAIN_ARG)[i]-1) << 3) | (((int_T)mxGetPr(FORMAT_ARG)[i]-1) << 5);
            writeDPRAM(baseAddress, (uint16_T)(0x310+i), (uint8_T)conf);
            returnCode= executeCommand(baseAddress, 0x81);
        }

        // check revision of board
        returnCode= executeCommand(baseAddress, 0xc0);
        init=0;

    }

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    uint_T baseAddress = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    uint_T base;
    uint_T i,k;
    real_T  *y;
    real32_T fVal;
    uint8_T returnCode;


    if ((int_T)mxGetPr(NCHANNELS_ARG)[0]==1) {
        returnCode= executeCommand(baseAddress, 0x90);
    } else {
        // select DPRAM address for AM188 mailbox
        rl32eOutpB(baseAddress+0x0, 0x3fe & 0xff);
        rl32eOutpB(baseAddress+0x1, (0x3fe>>8) & 0xff);
        // check if AM188 is ready to receive command
        while (!(rl32eInpB(baseAddress+0x3) & 0x40));
        // write mailbox
        rl32eOutpB(baseAddress+0x2, 0xa0);
        // wait on AM188
        while (!(rl32eInpB(baseAddress+0x3) & 0x40));
        //returnCode= executeCommand(baseAddress, 0xa0);
        returnCode= executeCommand(baseAddress, (uint8_T)(0xb0 | ((int_T)mxGetPr(NCHANNELS_ARG)[0]-1)));
    }

    for (k=0; k<(int_T)mxGetPr(NCHANNELS_ARG)[0]; k++) {
        uint8_T *yTmp=(uchar_T *) &fVal;
        y=ssGetOutputPortSignal(S,k);
        base= 0x320+4*k;
        for (i=base; i<base+4; i++, yTmp++) {
            *yTmp= readDPRAM(baseAddress, (uint16_T)i);
        }
        y[0]=(double) fVal;
    }

    if ((int_T)mxGetPr(CJC_ARG)[0]) {
        uint8_T *yTmp=(uchar_T *) &fVal;
        y=ssGetOutputPortSignal(S, (int_T)mxGetPr(NCHANNELS_ARG)[0]);
        base= 0x360;
        for (i=base; i<base+4; i++, yTmp++) {
            *yTmp= readDPRAM(baseAddress, (uint16_T)i);
        }
        y[0]=(double) fVal;
    }


    /*

      for (k=0; k<(int_T)mxGetPr(NCHANNELS_ARG)[0]; k++) {
      uint8_T *yTmp=(uchar_T *) &fVal;
      returnCode= executeCommand(baseAddress, 0x90 | k);
      y=ssGetOutputPortSignal(S,k);
      base= 0x320+4*k;
      for (i=base; i<base+4; i++, yTmp++) {
      *yTmp= readDPRAM(baseAddress, i);
      }
      y[0]=(double) fVal;
      }

      if ((int_T)mxGetPr(CJC_ARG)[0]) {
      uint8_T *yTmp=(uchar_T *) &fVal;
      y=ssGetOutputPortSignal(S, (int_T)mxGetPr(NCHANNELS_ARG)[0]);
      base= 0x360;
      for (i=base; i<base+4; i++, yTmp++) {
      *yTmp= readDPRAM(baseAddress, i);
      }
      y[0]=(double) fVal;
      }
    */

#endif

}

static void mdlTerminate(SimStruct *S)
{
}

#ifndef MATLAB_MEX_FILE

static uint8_T readDPRAM(uint_T baseAddress, uint16_T offset)
{
    rl32eOutpB(baseAddress + 0x00, offset & 0xff);
    rl32eOutpB(baseAddress + 0x01, (offset >> 8) & 0xff);
    return rl32eInpB(baseAddress + 0x02);
}

static void writeDPRAM(uint_T baseAddress, uint16_T offset, uint8_T value)
{
    rl32eOutpB(baseAddress + 0x00, offset & 0xff);
    rl32eOutpB(baseAddress + 0x01, (offset >> 8) & 0xff);
    rl32eOutpB(baseAddress + 0x02, value);
}

static uint8_T executeCommand(uint_T baseAddress, uint8_T command)
{
    // select DPRAM address for AM188 mailbox
    rl32eOutpB(baseAddress+0x0, 0x3fe & 0xff);
    rl32eOutpB(baseAddress+0x1, (0x3fe>>8) & 0xff);
    // check if AM188 is ready to receive command
    while (!(rl32eInpB(baseAddress+0x3) & 0x40));
    // write mailbox
    rl32eOutpB(baseAddress+0x2, command);
    // wait on AM188
    while (rl32eInpB(baseAddress+0x3) & 0x80);
    // select DPRAM address for PC mailbox
    rl32eOutpB(baseAddress+0x0, 0x3ff & 0xff);
    rl32eOutpB(baseAddress+0x1, (0x3ff>>8) & 0xff);
    // read mailbox
    return rl32eInpB(baseAddress+0x2);

}

#endif


#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
