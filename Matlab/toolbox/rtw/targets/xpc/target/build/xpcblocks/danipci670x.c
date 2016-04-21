/* $Revision: 1.5.4.1 $ $Date: 2004/04/08 21:02:00 $ */
/* danipci670x.c - xPC Target, non-inlined S-function driver for D/A section
 *                 of NI PCI-6703, PCI-6704 and PXI-6704 series boards  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         danipci670x

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
#define NUMBER_OF_ARGS          (4)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,1)
#define SLOT_ARG                ssGetSFcnParam(S,2)
#define DEV_ARG                 ssGetSFcnParam(S,3)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (3)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)
#define ACTIVE_BLOCK_I_IND      (2)


#define NO_R_WORKS              (0)

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

    ssSetSFcnParamNotTunable(S,0);
    ssSetSFcnParamNotTunable(S,1);
    ssSetSFcnParamNotTunable(S,2);
    ssSetSFcnParamNotTunable(S,3);

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


    int_T nChannels, range;
    int_T i, channel;
    real_T output;

    PCIDeviceInfo pciinfo;
    void *Physical1, *Physical0;
    void *Virtual1, *Virtual0;
    volatile uint32_T *ioaddress0;
    volatile uint32_T *ioaddress;
    volatile uint8_T  *ioaddress8;
    char devName[20];
    int  devId;

    nChannels = mxGetN(CHANNEL_ARG);
    ssSetIWorkValue(S, CHANNELS_I_IND, nChannels);


    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        strcpy(devName,"NI PCI-6703");
        devId = 0x2C90;
        break;
      case 2:
        strcpy(devName,"NI PCI-6704");
        devId = 0x1290;
        break;
      case 3:
        strcpy(devName,"NI PXI-6704");
        devId = 0x1920;
        break;
    }


    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo((unsigned short)0x1093,(unsigned short)devId,&pciinfo)) {
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1093,(unsigned short)devId, (slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present", devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    Physical1=(void *)pciinfo.BaseAddress[1];
    Virtual1 = rl32eGetDevicePtr(Physical1, 4096, RT_PG_USERREADWRITE);
    ioaddress=(void *)Physical1;
    ioaddress8=(void *)Physical1;
    Physical0=(void *)pciinfo.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 4096, RT_PG_USERREADWRITE);
    ioaddress0=(void *) Physical0;
    ioaddress0[48]=((unsigned int)ioaddress & 0xffffff00) | 0x00000080;
    ssSetIWorkValue(S, BASE_ADDR_I_IND, (uint_T)ioaddress);

    output=0.0;

    ioaddress[0x04]=0x00000000;

    for (i=0;i<nChannels;i++) {

        channel=mxGetPr(CHANNEL_ARG)[i]-1;

        if (channel<16) {

            ioaddress[0x03]= channel*2;
            ioaddress[0x00]=(uint32_T)(((output+10.24)/20.48)*65536.0);

        } else {

            ioaddress[0x03]= (channel-16)*2+1;
            if (output==0) {
                ioaddress[0x00]=0x00000000;
            } else {
                ioaddress[0x00]=(uint32_T)(((output+0.01)/20.48)*65536.0);
            }

        }

    }

    ssSetIWorkValue(S, ACTIVE_BLOCK_I_IND, 0);

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    uint_T  base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T activeBlock = ssGetIWorkValue(S, ACTIVE_BLOCK_I_IND);
    int_T i;
    real_T output;
    int_T channel;
    volatile uint32_T *ioaddress;
    InputRealPtrsType uPtrs;

    ioaddress=(void *) base;

    if (activeBlock==0) {
        ssSetIWorkValue(S, ACTIVE_BLOCK_I_IND, 1);
        activeBlock=1;
    } else {
        ssSetIWorkValue(S, ACTIVE_BLOCK_I_IND, 0);
        activeBlock=0;
    }

    for (i=0;i<nChannels;i++) {
        channel=mxGetPr(CHANNEL_ARG)[i]-1;
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        output=*uPtrs[0];

        if (channel<16) {

            ioaddress[0x03]= (channel*2) | (activeBlock<<6);
            if (output < -10.0) output= -10.0;
            if (output > 10.0) output= 10.0;
            ioaddress[0x00]=(uint32_T)(((output+10.24)/20.48)*65536.0);

        } else {

            ioaddress[0x03]= ((channel-16)*2+1) | (activeBlock<<6);
            if (output < 0.0) output= 0.0;
            if (output > 0.02) output= 0.02;
            if (output==0) {
                ioaddress[0x00]=0x00000000;
            } else {
                ioaddress[0x00]=(uint32_T)(((output*1000.0+0.01)/20.48)*65536.0);
            }

        }

    }

    ioaddress[0x04]= activeBlock << 4;


#endif

}


static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    uint_T  base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T activeBlock = ssGetIWorkValue(S, ACTIVE_BLOCK_I_IND);
    int_T i;
    real_T output;
    int_T channel;
    volatile uint32_T *ioaddress;
    int_T oldActiveBlock;

    ioaddress=(void *) base;

    oldActiveBlock= activeBlock;
    if (activeBlock==0) {
        ssSetIWorkValue(S, ACTIVE_BLOCK_I_IND, 1);
        activeBlock=1;
    } else {
        ssSetIWorkValue(S, ACTIVE_BLOCK_I_IND, 0);
        activeBlock=0;
    }

    output= 0.0;

    for (i=0;i<nChannels;i++) {

        channel=mxGetPr(CHANNEL_ARG)[i]-1;

        if (channel<16) {

            ioaddress[0x03]= (channel*2) | (activeBlock<<6);
            ioaddress[0x00]=(uint32_T)(((output+10.24)/20.48)*65536.0);
            ioaddress[0x03]= (channel*2) | (oldActiveBlock<<6);
            ioaddress[0x00]=(uint32_T)(((output+10.24)/20.48)*65536.0);


        } else {

            ioaddress[0x03]= ((channel-16)*2+1) | (activeBlock<<6);
            if (output==0) {
                ioaddress[0x00]=0x00000000;
            } else {
                ioaddress[0x00]=(uint32_T)(((output+0.01)/20.48)*65536.0);
            }
            ioaddress[0x03]= ((channel-16)*2+1) | (oldActiveBlock<<6);
            if (output==0) {
                ioaddress[0x00]=0x00000000;
            } else {
                ioaddress[0x00]=(uint32_T)(((output+0.01)/20.48)*65536.0);
            }

        }

    }

    ioaddress[0x04]= activeBlock << 4;

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
