/* dipci6527.c - xPC Target, non-inlined S-function driver for */
/* the digital input section on the National Instruments 6527 board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dinipci6527

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
#include        "dionipci6527.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (7)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define PORT_ARG                ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define SLOT_ARG                ssGetSFcnParam(S,3)
#define FILTER_ARG              ssGetSFcnParam(S,4)
#define FILTER_TIME_ARG         ssGetSFcnParam(S,5)
#define DEVTYPE_ARG             ssGetSFcnParam(S,6)

#define NO_I_WORKS              (1)
#define BASE_I_IND              (0)

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

    ssSetNumContStates(S, 0);  /* No continuous states */
    ssSetNumDiscStates(S, 0);  /* No discrete states */

    ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG)); /* inputs from hardware are outputs from block */
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumInputPorts(S, 0);  /* Used by digital output side, inputs to block */

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);  /* size of real work vector */
    ssSetNumIWork(S, NO_I_WORKS);  /* size of integer work vector */
    ssSetNumPWork(S, 0);           /* size of pointer work vector */

    ssSetNumModes(S, 0);           /* size of the mode vector */
    ssSetNumNonsampledZCs(S, 0);   /* zero crossing detection */

    for( i = 0 ; i < NUMBER_OF_ARGS ; i++ )
    {
        ssSetSFcnParamTunable(S,i,0);  /* None of the parameters are tunable */
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
    int_T num_channels, port;
    int_T vendorId, deviceId;
    char_T devName[30];
    void *Physical1, *Physical0;
    void *Virtual1, *Virtual0;
    int_T i;
    regs_6527 *base;
    real_T filtTime;
    int_T filtCount;
    unsigned char fmask = 0;
    int_T channel, maskbit;

    switch( (int_T)mxGetPr(DEVTYPE_ARG)[0] )
    {
      case 1:
        strcpy(devName,"NI PCI-6527");
        vendorId=0x1093;    /* National Instruments */
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
            sprintf(msg,"%s (bus %d,slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    //rl32eShowPCIInfo(pciinfo);

    // Map MITE space and mark it read/write
    Physical0 = (void *)pciinfo.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 4096, RT_PG_USERREADWRITE);

    // Map IO space and mark it read/write
    Physical1 = (void *)pciinfo.BaseAddress[1];
    Virtual1 = rl32eGetDevicePtr(Physical1, 4096, RT_PG_USERREADWRITE);
    ((long *)Physical0)[0xC0/4] = ((unsigned long)Physical1 & ~0xff) | 0x80; // Set address window size.

    // Save IO space base address for later.
    ssSetIWorkValue( S, BASE_I_IND, (uint_T)Virtual1 );

    // Compute the filtering enable mask based on the FILTER_ARG vector.
    for( i = 0 ; i < mxGetN(CHANNEL_ARG) ; i++ )
    {
        maskbit = (int_T)mxGetPr(FILTER_ARG)[i];
        channel = (int_T)mxGetPr(CHANNEL_ARG)[i] - 1;
        fmask |= maskbit << channel;
    }

    base = (regs_6527 *)Virtual1;
    if( fmask != 0 )
    {
        // Set the board filter interval from FILTER_TIME_ARG and enable filtering
        // on the requested channels.  Write the filter interval, only if this block
        // is using it.
        filtTime = (real_T)mxGetPr( FILTER_TIME_ARG )[0];
        filtCount = (int_T)( filtTime / 0.0000002 );   // Number of 200ns counts in filtTime seconds, truncated.
        printf("filtTime = %lf, filtCount = %d\n", filtTime, filtCount );
        base->filter_interval[2] = (filtCount >> 16) & 0xff;
        base->filter_interval[1] = (filtCount >> 8) & 0xff;
        base->filter_interval[0] = filtCount & 0xff;
        base->clear = 0x3;   // Clear and reset the filter counter.
    }

    // Write the filter enable mask to the hardware.
    port=(int_T)mxGetPr(PORT_ARG)[0]-1;
    base->filter_enable[port] = fmask;
#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    regs_6527 *base = (regs_6527 *)ssGetIWorkValue(S, BASE_I_IND);
    real_T  *y;
    int_T port, i, input, channel;

    port=(int_T)mxGetPr(PORT_ARG)[0]-1;

    input = (int_T)base->input[ port ];

    for (i = 0 ; i < mxGetN(CHANNEL_ARG) ; i++ )
    {
        channel = (int_T)mxGetPr(CHANNEL_ARG)[i] - 1;
        y = ssGetOutputPortSignal(S,i);
        y[0] = (input >> channel) & 1;
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
