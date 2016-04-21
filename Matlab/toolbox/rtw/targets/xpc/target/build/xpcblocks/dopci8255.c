/* $Revision: 1.17.6.2 $ $Date: 2004/04/08 21:02:11 $ */
/* dopci8255.c - xPC Target, non-inlined S-function driver for digital output section for PCI boards using the 8255 chip */
/* Copyright 1996-2004 The MathWorks, Inc.
*/

// Note: when adding a new DEV_ARG, be sure to add a case to all four DEV_ARG switches

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dopci8255

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
#define NUMBER_OF_ARGS          (9)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define PORT_ARG                ssGetSFcnParam(S,1)
#define RESET_ARG               ssGetSFcnParam(S,2)
#define INIT_VAL_ARG            ssGetSFcnParam(S,3)
#define CHIP_ARG                ssGetSFcnParam(S,4)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,5)
#define SLOT_ARG                ssGetSFcnParam(S,6)
#define CONTROL_ARG             ssGetSFcnParam(S,7)
#define DEV_ARG                 ssGetSFcnParam(S,8)


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)
#define BASE_I_IND              (0)
#define OFFSET_IND              (1)

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

#ifndef MATLAB_MEX_FILE

    PCIDeviceInfo pciinfo;
    int_T i, base, port, control;
    int_T vendorId, deviceId, sectionAddr, offset8255;
    uint_T channel;
    void *Physical1, *Physical0;
    void *Virtual1, *Virtual0;
    unsigned int *ioaddress0;
    unsigned short *ioaddress1, output;
    unsigned char *ioaddress;

    char_T devName[30];

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        strcpy(devName,"CB PCI-DAS1602/16");
        vendorId=0x1307;
        deviceId=0x1;
        sectionAddr=0x3;
        offset8255=0x4;
        break;
      case 2:
        strcpy(devName,"CB PCI-DAS1200");
        vendorId=0x1307;
        deviceId=0xf;
        sectionAddr=0x3;
        offset8255=0x4;
        break;
      case 3:
        strcpy(devName,"CB PCI-DAS1200/JR");
        vendorId=0x1307;
        deviceId=0x19;
        sectionAddr=0x3;
        offset8255=0x4;
        break;
      case 4:
        strcpy(devName,"CB PCI-DIO48H");
        vendorId=0x1307;
        deviceId=0xb;
        sectionAddr=0x1;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
        }
        break;
      case 5:
        strcpy(devName,"CB PCI-DDA02/12");
        vendorId=0x1307;
        deviceId=0x20;
        sectionAddr=0x2;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
        }
        break;
      case 6:
        strcpy(devName,"CB PCI-DDA04/12");
        vendorId=0x1307;
        deviceId=0x21;
        sectionAddr=0x2;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
        }
        break;
      case 7:
        strcpy(devName,"CB PCI-DDA08/12");
        vendorId=0x1307;
        deviceId=0x22;
        sectionAddr=0x2;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
        }
        break;
      case 8:
        strcpy(devName,"CB PCI-DIO24H");
        vendorId=0x1307;
        deviceId=0x14;
        sectionAddr=0x2;
        offset8255=0x0;
        break;
      case 9:
        strcpy(devName,"CB PCI-DIO96H");
        vendorId=0x1307;
        deviceId=0x17;
        sectionAddr=0x2;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
          case 3:
            offset8255=0x8;
            break;
          case 4:
            offset8255=0xc;
            break;
        }
        break;
      case 10:
        strcpy(devName,"CB PCI-DIO24");
        vendorId=0x1307;
        deviceId=0x28;
        sectionAddr=0x2;
        offset8255=0x0;
        break;
      case 11:
        strcpy(devName,"CB PCI-DAS1602/12");
        vendorId=0x1307;
        deviceId=0x10;
        sectionAddr=0x3;
        offset8255=0x4;
        break;
      case 12:
        strcpy(devName,"NI PCI-6503");
        vendorId=0x1093;
        deviceId=0x17d0;
        sectionAddr=0x1;
        offset8255=0x0;
        break;
      case 13:
        strcpy(devName,"NI PCI-DIO-96");
        vendorId=0x1093;
        deviceId=0x0160;
        sectionAddr=0x1;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
          case 3:
            offset8255=0x8;
            break;
          case 4:
            offset8255=0xc;
            break;
        }
        break;
      case 14:
        strcpy(devName,"NI PXI-6508");
        vendorId=0x1093;
        deviceId=0x13c0;
        sectionAddr=0x1;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
          case 3:
            offset8255=0x8;
            break;
          case 4:
            offset8255=0xc;
            break;
        }
        break;
      case 15:
        strcpy(devName,"NI PCI-6025E");
        vendorId=0x1093;
        deviceId=0x2a80;
        sectionAddr=0x1;
        offset8255=0x19;
        break;
      case 16:
        strcpy(devName,"CB PCI-DUAL-AC5");
        vendorId=0x1307;
        deviceId=0x33;
        sectionAddr=0x2;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
        }
        break;
      case 17:
        strcpy(devName,"CB PCI-DDA02/16");
        vendorId=0x1307;
        deviceId=0x23;
        sectionAddr=0x2;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
        }
        break;
      case 18:
        strcpy(devName,"CB PCI-DDA04/16");
        vendorId=0x1307;
        deviceId=0x24;
        sectionAddr=0x2;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
        }
        break;
      case 19:
        strcpy(devName,"CB PCI-DDA08/16");
        vendorId=0x1307;
        deviceId=0x25;
        sectionAddr=0x2;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
        }
        break;
      case 20:
        strcpy(devName,"CB PCIM-DDA06/16");
        vendorId=0x1307;
        deviceId=0x53;
        sectionAddr=0x3;
        offset8255=0x0c;
        break;
      case 21:
        strcpy(devName,"CB PCIM-DAS1602/16");
        vendorId=0x1307;
        deviceId=0x56;
        sectionAddr=0x4;
        offset8255=0x00;
        break;
      case 22:
        strcpy(devName,"CB PCI-DIO96");
        vendorId=0x1307;
        deviceId=0x54;
        sectionAddr=0x3;
        switch ((int_T)mxGetPr(CHIP_ARG)[0]) {
          case 1:
            offset8255=0x0;
            break;
          case 2:
            offset8255=0x4;
            break;
          case 3:
            offset8255=0x8;
            break;
          case 4:
            offset8255=0xc;
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
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
      case 16:
      case 17:
      case 18:
      case 19:
      case 20:
      case 21:
      case 22:
        base=pciinfo.BaseAddress[sectionAddr]+offset8255;
        ssSetIWorkValue(S, BASE_I_IND, base);

        port=(int_T)mxGetPr(PORT_ARG)[0]-1;
        control=(int_T)mxGetPr(CONTROL_ARG)[0];

        rl32eOutpB((unsigned short)(base+3),(unsigned short)control);
        break;
      case 12:
      case 13:
      case 14:
      case 15:
        if( pciinfo.BaseAddress[1] == 0 )
        {
            sprintf(msg,"Board base address came up 0, can't run." );
            ssSetErrorStatus(S,msg);
            return;
        }
        ssSetIWorkValue(S, OFFSET_IND, offset8255);

        Physical1=(void *)pciinfo.BaseAddress[1];
        Virtual1 = rl32eGetDevicePtr(Physical1, 4096, RT_PG_USERREADWRITE);
        ioaddress1=(void *)Physical1;
        Physical0=(void *)pciinfo.BaseAddress[0];
        Virtual0 = rl32eGetDevicePtr(Physical0, 4096, RT_PG_USERREADWRITE);
        ioaddress0=(void *) Physical0;
        ioaddress0[48]=((unsigned int)ioaddress1 & 0xffffff00) | 0x00000080;
        ssSetIWorkValue(S, BASE_I_IND, (uint_T)ioaddress1);

        ioaddress = (void *)ioaddress1;
        port = (int_T)mxGetPr(PORT_ARG)[0];

        control=(int_T)mxGetPr(CONTROL_ARG)[0];
        if ((int_T)mxGetPr(DEV_ARG)[0]==15) {
            ioaddress[0x3*2+offset8255] = control;
        } else {
            ioaddress[0x3+offset8255] = control;
        }
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
    int_T offset8255 = ssGetIWorkValue(S, OFFSET_IND);
    unsigned char *ioaddress;

    port=(int_T)mxGetPr(PORT_ARG)[0]-1;

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
      case 16:
      case 17:
      case 18:
      case 19:
      case 20:
      case 21:
      case 22:
        output=rl32eInpB((unsigned short)(base+port));
        for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
            channel=(uchar_T)mxGetPr(CHANNEL_ARG)[i];
            uPtrs=ssGetInputPortRealSignalPtrs(S,i);
            if (*uPtrs[0]>=THRESHOLD) {
                output |= 1 << (channel-1);
            } else {
                output &= ~(1 << (channel-1));
            }
        }
        rl32eOutpB((unsigned short)(base+port), (unsigned short)(output));
        break;
      case 12:
      case 13:
      case 14:
        ioaddress=(void *) base;
        output = ioaddress[port+offset8255];
        for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
            uPtrs=ssGetInputPortRealSignalPtrs(S,i);
            channel = mxGetPr(CHANNEL_ARG)[i];
            if (*uPtrs[0]>=THRESHOLD) {
                output |= 1 << (channel-1);
            } else {
                output &= ~(1 << (channel-1));
            }
        }
        ioaddress[port+offset8255] = output;
        break;
      case 15:
        ioaddress=(void *) base;
        output = ioaddress[port*2+offset8255];
        for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
            uPtrs=ssGetInputPortRealSignalPtrs(S,i);
            channel = mxGetPr(CHANNEL_ARG)[i];
            if (*uPtrs[0]>=THRESHOLD) {
                output |= 1 << (channel-1);
            } else {
                output &= ~(1 << (channel-1));
            }
        }
        ioaddress[port*2+offset8255] = output;
        break;
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    int_T base = ssGetIWorkValue(S, BASE_I_IND);
    int_T port = (int_T)mxGetPr(PORT_ARG)[0] - 1;
    int_T offset8255 = ssGetIWorkValue(S, OFFSET_IND);
    uint_T channel;
    int_T i;
    unsigned char *ioaddress;
    unsigned char bit, init, reset, mask, output;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    init = reset = mask = 0;

    for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
        channel = (uint_T)(mxGetPr(CHANNEL_ARG)[i] - 1);
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

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
      case 16:
      case 17:
      case 18:
      case 19:
      case 20:
      case 21:
      case 22:
        output = rl32eInpB((unsigned short)(base+port));
        output &= ~mask;
        output |= init;
        rl32eOutpB((unsigned short)(base+port), output);
        break;
      case 12:
      case 13:
      case 14:
        ioaddress=(void *) base;
        output = ioaddress[port+offset8255];
        output &= ~mask;
        output |= init;
        ioaddress[port+offset8255] = output;
        break;
      case 15:
        ioaddress=(void *) base;
        output = ioaddress[port*2+offset8255];
        output &= ~mask;
        output |= init;
        ioaddress[port*2+offset8255] = output;
        break;
    }
#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
