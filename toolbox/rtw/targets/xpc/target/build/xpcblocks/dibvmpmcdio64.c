/* $Revision: 1.2 $ $Date: 2002/03/25 04:01:02 $ */
/* dibvmpmcdio64.c - xPC Target, non-inlined S-function driver for digital
 * input section for the BVM PMCDIO64 board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dibvmpmcdio64

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
#define NUMBER_OF_ARGS          (6)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define PORT_ARG                ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define SLOT_ARG                ssGetSFcnParam(S,3)
#define CONFIG_ARG              ssGetSFcnParam(S,4)
#define FORMAT_ARG              ssGetSFcnParam(S,5)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (1)
#define BASE_I_IND              (0)

#define NO_R_WORKS              (0)

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
        ssSetNumOutputPorts(S, 1);
        ssSetOutputPortWidth(S, 0, 1);
        ssSetOutputPortDataType( S, 0, SS_UINT32 );
    }
    else
    {
        ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
        for (i = 0 ; i < mxGetN(CHANNEL_ARG) ; i++ )
        {
            ssSetOutputPortWidth(S, i, 1);
            ssSetOutputPortDataType( S, 0, SS_DOUBLE );
        }
    }

    ssSetNumInputPorts(S, 0);

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
    uint32_T directionconfig;

    vendorId=0x15c0;
    deviceId=0x2ff;
    strcpy( devName, "BVM PMCDIO64" );

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo((unsigned short)vendorId,(unsigned short)deviceId,&pciinfo))
        {
            sprintf(msg,"%s: board not present", devName);
            ssSetErrorStatus(S,msg);
            return;
        }
    } else {
        int_T bus, slot;
        if (mxGetN(SLOT_ARG) == 1)
        {
            bus = 0;
            slot = (int_T)mxGetPr(SLOT_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(SLOT_ARG)[0];
            slot = (int_T)mxGetPr(SLOT_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlot((unsigned short)vendorId,(unsigned short)deviceId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo))
        {
            sprintf( msg, "%s (bus %d,slot %d): board not present", devName, bus, slot );
            ssSetErrorStatus( S, msg );
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
#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    struct dio64regs *regs = (struct dio64regs *)ssGetIWorkValue(S, BASE_I_IND);
    int_T num_channels;
    uint_T port, i, input, channel;
    real_T  *y;
    int_T format = mxGetPr(FORMAT_ARG)[0];

    port=(int_T)mxGetPr(PORT_ARG)[0]-1;
    num_channels = mxGetN(CHANNEL_ARG);

    switch( port )
    {
      case 0:
        input = regs->inlow;
        break;
      case 1:
        input = regs->inhigh;
        break;
    }

    if( format == 1 )
    {
        int_T *IPtr = ssGetOutputPortSignal(S,0);
        IPtr[0] = input;
    }
    else
    {
        for( i = 0 ; i < num_channels ; i++ )
        {
            channel = (int_T)mxGetPr(CHANNEL_ARG)[i]-1;
            y = ssGetOutputPortSignal(S,i);
            y[0] = ( input >> channel ) & 1;
        }
    }

#endif

}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
