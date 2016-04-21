/* $Revision: 1.2 $ $Date: 2002/03/25 04:07:20 $ */
/* dopci8255.c - xPC Target, non-inlined S-function driver for digital output section for PCI boards using the 8255 chip */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         docbpcipdisox

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
#define PORT_ARG                ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define SLOT_ARG                ssGetSFcnParam(S,3)
#define FILTER_ARG             	ssGetSFcnParam(S,4)
#define DEV_ARG                 ssGetSFcnParam(S,5)


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)
#define BASE_I_IND              (0)
#define OFFSET_IND              (1)

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

	for( i = 0 ; i < NUMBER_OF_ARGS ; i++ )
    {
        ssSetSFcnParamTunable(S,i,0);  /* None of the parameters are tunable */
    }


    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);


}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (mxGetPr(SAMP_TIME_ARG)[0]==-1.0)
    {
    	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    	ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    }
    else
    {
      	ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
   		ssSetOffsetTime(S, 0, 0.0);
    }
}

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    PCIDeviceInfo pciinfo;
    int_T num_channels, base, port, filter;
    int_T vendorId, deviceId, sectionAddr, offset;
    void *Physical1, *Physical0;
    void *Virtual1, *Virtual0;
    unsigned int *ioaddress0;
    unsigned short *ioaddress1;
    unsigned char *ioaddress;

    char_T devName[30];

   switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        strcpy(devName,"CB PCI-PDISO8");
        vendorId=0x1307;
        deviceId=0xdd;
        sectionAddr=0x1;
        offset=0x0;
        break;
      case 2:
        strcpy(devName,"CB PCI-PDISO16");
        vendorId=0x1307;
        deviceId=0xd;
        sectionAddr=0x1;
        switch ((int_T)mxGetPr(PORT_ARG)[0]) {
          case 1:
            offset=0x0;
            break;
          case 2:
            offset=0x4;
            break;
        }
        break;
    }

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo((unsigned short)vendorId,(unsigned short)deviceId,&pciinfo)) {
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)vendorId,(unsigned short)deviceId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot);
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    //rl32eShowPCIInfo(pciinfo);

	switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
      case 2:
        base=pciinfo.BaseAddress[sectionAddr]+offset;
        ssSetIWorkValue(S, BASE_I_IND, base);
        rl32eOutpB((unsigned short)(base+0), 0x0);
        break;
    }

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int_T base = ssGetIWorkValue(S, BASE_I_IND);
    int_T port,  i;
    uchar_T output, channel;
    InputRealPtrsType uPtrs;
    unsigned char *ioaddress;

    port=(int_T)mxGetPr(PORT_ARG)[0]-1;

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
      case 2:
      	output=rl32eInpB((unsigned short)(base+0));
        for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
            channel=(uchar_T)mxGetPr(CHANNEL_ARG)[i];
            uPtrs=ssGetInputPortRealSignalPtrs(S,i);
            if (*uPtrs[0]>=THRESHOLD) {
                output |= 1 << (channel-1);
            } else {
                output &= ~(1 << (channel-1));
            }
        }
        rl32eOutpB((unsigned short)(base+0), (unsigned short)(output));
        break;
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    int_T base = ssGetIWorkValue(S, BASE_I_IND);
    int_T port;
    unsigned char *ioaddress;

    port=(int_T)mxGetPr(PORT_ARG)[0]-1;

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
      case 2:
      	rl32eOutpB((unsigned short)(base+0), (unsigned short)(0x00));
        break;
    }
#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
