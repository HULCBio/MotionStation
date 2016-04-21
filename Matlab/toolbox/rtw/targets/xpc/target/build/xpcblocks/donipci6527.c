/* dopci6527.c - xPC Target, non-inlined S-function driver for digital output */
/* section for the National Instruments 6527 board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         donipci6527

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
#include        "dionipci6527.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (7)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define PORT_ARG                ssGetSFcnParam(S,1)
#define RESET_ARG               ssGetSFcnParam(S,2)
#define INIT_VAL_ARG            ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,4)
#define SLOT_ARG                ssGetSFcnParam(S,5)
#define DEVTYPE_ARG             ssGetSFcnParam(S,6)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (1)
#define BASE_I_IND              (0)

#define NO_R_WORKS              (0)

#define THRESHOLD               (0.5)

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

    for( i = 0 ; i < NUMBER_OF_ARGS ; i++ )
    {
        ssSetSFcnParamTunable(S,i,0);
    }

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    if( mxGetN(SAMP_TIME_ARG) == 1 )
    {
        if( mxGetPr(SAMP_TIME_ARG)[0] == -1 )
        {
            ssSetSampleTime( S, 0, INHERITED_SAMPLE_TIME );
            ssSetOffsetTime( S, 0, FIXED_IN_MINOR_STEP_OFFSET );
        }
        else
        {
            ssSetSampleTime( S, 0, mxGetPr(SAMP_TIME_ARG)[0] );
            ssSetOffsetTime( S, 0, 0.0 );
        }
    }
    else
    {
        ssSetSampleTime( S, 0, mxGetPr(SAMP_TIME_ARG)[0] );
        ssSetOffsetTime( S, 0, mxGetPr(SAMP_TIME_ARG)[1] );
    }
}

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    PCIDeviceInfo pciinfo;
    regs_6527 *base;
    int_T num_channels, port;
    int_T vendorId, deviceId, sectionAddr;
    void *Physical1, *Physical0;
    void *Virtual1, *Virtual0;
    int_T i;

    char_T devName[30];

    switch( (int_T)mxGetPr(DEVTYPE_ARG)[0] )
    {
      case 1:
        strcpy(devName,"NI PCI-6527");
        vendorId=0x1093;
        deviceId=0x2B20;    /* PCI-6527 */
        break;
      case 2:
        strcpy(devName,"NI PXI-6527");
        vendorId=0x1093;    /* National Instruments */
        deviceId=0x2B10;    /* PXI-6527 */
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

    // Map the MITE physical address to virtual and make it R/W
    Physical0=(void *)pciinfo.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 4096, RT_PG_USERREADWRITE);

    // Map the IO physical address to virtual and make it R/W
    Physical1 = (void *)pciinfo.BaseAddress[1];
    Virtual1 = rl32eGetDevicePtr(Physical1, 4096, RT_PG_USERREADWRITE);
    ((long *)Physical0)[0xC0/4] = ((unsigned long)Physical1 & ~0xff) | 0x80; // Set address window size.

    // Save the IO virtual address for later.
    ssSetIWorkValue(S, BASE_I_IND, (uint_T)Virtual1 );
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    regs_6527 *base = (regs_6527 *)ssGetIWorkValue(S, BASE_I_IND);
    int_T port,  i;
    uchar_T output, channel;
    InputRealPtrsType uPtrs;

    port=(int_T)mxGetPr(PORT_ARG)[0]-1;

    output = base->output[port];
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        channel = mxGetPr(CHANNEL_ARG)[i] - 1;
        // a 1 in the output register turns the corresponding opto OFF
        if (*uPtrs[0]>=THRESHOLD)
            output &= ~(1 << channel);
        else
             output |= 1 << channel;
   }
    base->output[port] = output;
#endif
}

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    regs_6527 *base = (regs_6527 *)ssGetIWorkValue(S, BASE_I_IND);
    int_T i, port, channel;
    uchar_T output;

    port = (int_T)mxGetPr(PORT_ARG)[0]-1;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    if (xpceIsModelInit())
        output = 0xff; // default initial setting is OFF
    else
        output = base->output[port];

    for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            channel = mxGetPr(CHANNEL_ARG)[i] - 1;
            // a 1 in the output register turns the corresponding opto OFF
            if ((uint_T)mxGetPr(INIT_VAL_ARG)[i])
                output &= ~(1 << channel);
            else
                output |= 1 << channel;
        }
    }
    base->output[port] = output;
#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
