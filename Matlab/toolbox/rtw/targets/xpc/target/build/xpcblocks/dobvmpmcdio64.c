/* $Revision: 1.2 $ $Date: 2002/03/25 04:07:11 $ */
/* dobvmpmcdio64.c - xPC Target, non-inlined S-function driver for digital 
 * output section for the BVM PMCDIO64 board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dobvmpmcdio64

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
#include        "diobvmpmcdio64.h"
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS          (8)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define PORT_ARG                ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define SLOT_ARG                ssGetSFcnParam(S,3)
#define CONFIG_ARG              ssGetSFcnParam(S,4)
#define FORMAT_ARG              ssGetSFcnParam(S,5)
#define STOP_ARG                ssGetSFcnParam(S,6)
#define INITIAL_ARG             ssGetSFcnParam(S,7)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (1)
#define BASE_I_IND              (0)

#define NO_R_WORKS              (0)

#define THRESHOLD               0.5

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    int_T format = mxGetPr(FORMAT_ARG)[0];

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


    if( format == 1 )  // Single 32 bit port
    {
        ssSetNumInputPorts(S, 1);
        ssSetInputPortWidth(S, 0, 1);
        ssSetInputPortDirectFeedThrough(S, 0, 1);
        ssSetInputPortDataType( S, 0, SS_UINT32 );
        ssSetInputPortRequiredContiguous( S, 0, 1 );
    }
    else
    {
        // else use the default type of double.
        ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
        for (i=0;i<mxGetN(CHANNEL_ARG);i++)
        {
            ssSetInputPortWidth(S, i, 1);
            ssSetInputPortDirectFeedThrough(S, i, 1);
            ssSetInputPortDataType( S, i, SS_DOUBLE );
            ssSetInputPortRequiredContiguous( S, i, 1 );
        }
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
    int_T base;
    int_T virtual;
    int_T vendorId, deviceId;
    char_T devName[30];
    struct dio64regs *regs;
    int_T port;
    int_T initial;
    uint32_T directionconfig;

    strcpy(devName,"BVM PMCDIO64");
    vendorId=0x15c0;
    deviceId=0x2ff;

    if ((int_T)mxGetPr(SLOT_ARG)[0] < 0) {
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

    base = pciinfo.BaseAddress[2];
    ssSetIWorkValue(S, BASE_I_IND, base);
    regs = (struct dio64regs *)base;
    virtual = (int_T)rl32eGetDevicePtr((void *)base, 1024, RT_PG_USERREADWRITE);

    // Check the function register to make sure the subsystem device ID
    // is 0x65.
    if( (regs->function & 0xff) != 0x65 )
    {
        sprintf( msg, "%s: board not present", devName );
        ssSetErrorStatus( S, msg );
    }

    // Set the global output enable bit and clear the output hold bit.
    regs->statuscontrol = 0x0010;

    // All blocks computed the same directionconfig value in the mask init
    // file.
    directionconfig = (int_T)mxGetPr(CONFIG_ARG)[0];
    regs->direction = directionconfig;

    port = mxGetPr(PORT_ARG)[0]-1;
    initial = (int)mxGetPr(INITIAL_ARG)[0];
    switch( port )
    {
      case 0:
        regs->outlow = initial;
        break;
      case 1:
        regs->outhigh = initial;
        break;
    }
#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    struct dio64regs *regs = (struct dio64regs *)ssGetIWorkValue(S, BASE_I_IND);
    int_T num_channels;
    int_T port,  i;
    int_T format;
    uint_T output, bits, channel;
    real_T *uPtr;
    int32_T *IPtr;

    port=(int_T)mxGetPr(PORT_ARG)[0]-1;
    format = mxGetPr(FORMAT_ARG)[0];
    if( format == 1 )  // Single 32 bit port
    {
        IPtr = (int32_T *)ssGetInputPortSignal(S,0);
        bits = IPtr[0];
    }
    else
    {
        num_channels = mxGetN(CHANNEL_ARG);

        bits = 0;
        for( i = 0 ; i < mxGetN(CHANNEL_ARG) ; i++ )
        {
            channel = (uchar_T)mxGetPr(CHANNEL_ARG)[i] - 1;
            uPtr = (real_T *)ssGetInputPortRealSignal(S,i);
            if ( uPtr[0] >= THRESHOLD )
            {
                bits |= 1 << channel;
            }
        }
    }

    switch( port )
    {
      case 0:
        regs->outlow = bits;
        break;
      case 1:
        regs->outhigh = bits;
        break;
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    struct dio64regs *regs = (struct dio64regs *)ssGetIWorkValue(S, BASE_I_IND);
    int_T port;
    int_T stopaction = (int_T)mxGetPr(STOP_ARG)[0];
    int_T initial;

    port=(int_T)mxGetPr(PORT_ARG)[0]-1;

    // stopaction is a vector if 32 bits that indicates what is to be
    // done with each bit on stop.  If a bit is 0, then the output 
    // should be held.  If the bit is 1, then reset to the value 
    // in initial.  If the format indicates a single 32 bit register,
    // then the initialization m file stuffs 0xffff into stopaction.

    initial = (int_T)mxGetPr(INITIAL_ARG)[0];
    initial &= stopaction;
    switch( port )
    {
      case 0:
        regs->outlow = (regs->outlow & ~stopaction) | initial;
        break;
      case 1:
        regs->outhigh = (regs->outhigh & ~stopaction) | initial;
        break;
    }
#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
