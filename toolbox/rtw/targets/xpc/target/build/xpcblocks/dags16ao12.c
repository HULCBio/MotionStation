/* $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:01:59 $ */
/* dags16ao12.c - xPC Target, non-inlined S-function driver for General */
/* Standards 16 bit 12 channel  D/A board.                              */
/* Copyright 1994-2003 The MathWorks, Inc. */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	dags16ao12

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef         MATLAB_MEX_FILE
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#include        "time_xpcimport.h"
#include        "ioext_xpcimport.h"
#include        "util_xpcimport.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (8)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RESET_ARG               ssGetSFcnParam(S,1)
#define IVAL_ARG                ssGetSFcnParam(S,2)
#define RANGE_ARG               ssGetSFcnParam(S,3)
#define CAL_ARG                 ssGetSFcnParam(S,4)
#define GROUND_ARG              ssGetSFcnParam(S,5)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,6)
#define SLOT_ARG                ssGetSFcnParam(S,7)

#define BASE_ADDR_IND           (0)
#define LAST_CHAN0_IND          (1)
#define LAST_CHAN1_IND          (2)
#define LAST_CHAN2_IND          (3)
#define LAST_CHAN3_IND          (4)
#define LAST_CHAN4_IND          (5)
#define LAST_CHAN5_IND          (6)
#define LAST_CHAN6_IND          (7)
#define LAST_CHAN7_IND          (8)
#define LAST_CHAN8_IND          (9)
#define LAST_CHAN9_IND          (10)
#define LAST_CHAN10_IND         (11)
#define LAST_CHAN11_IND         (12)

#define SCALE_R_IND             (0)

#define NO_I_WORKS              (13)
#define NO_R_WORKS              (1)
#define NO_P_WORKS              (0)

static char_T msg[256];

// Definitions specific to the PMC-16AO-12 board.
typedef struct regs {
    volatile uint32_T  bcr;
    volatile uint32_T  chan_sel;
    volatile uint32_T  sample_rate;
    volatile uint32_T  buffer_ops;
    volatile uint32_T  dummy1;
    volatile uint32_T  dummy2;
    volatile uint32_T  output;
    volatile uint32_T  clock;
} daregs;

// Bits in the bcr register
#define BURST_ENABLE         0x0001
#define BURST_READY          0x0002
#define BURST_TRIGGER        0x0004
#define GROUND_SENSE         0x0008
#define OFFSET_BINARY        0x0010
#define SIMUL_OUTPUT         0x0080
#define START_CAL            0x2000
#define CAL_STATUS           0x4000
#define INIT                 0x8000

// Bits in the buffer operations register
#define DEFAULT_BUFFER_SIZE  0x000d   // 32K samples in the buffer, no reason to change it.
#define EXTERNAL_CLOCK       0x0010
#define CLOCK_ENABLE         0x0020
#define CLOCK_READY          0x0040   // status bit, RO
#define SW_CLOCK             0x0080
#define CIRC_BUFFER          0x0100
#define LOAD_REQUEST         0x0200
#define LOAD_READY           0x0400   // status bit, RO
#define CLEAR_BUFFER         0x0800

// End of definitions

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, 0);

    ssSetNumInputPorts(S, (int)mxGetN(CHANNEL_ARG));
    for ( i = 0 ; i < (int)mxGetN(CHANNEL_ARG) ; i++ )
    {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortRequiredContiguous( S, i, 1 );
    }

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, NO_P_WORKS);

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
    void *Physical;
    void *Virtual;
    daregs *regs;
    char *devName="PMC-16AO-12";
    int_T i;
    uint32_T initval;
    real_T scale;
    unsigned short vendorID, deviceID, SubvendorID, SubsystemID;
    int_T nchans = (int)mxGetN(CHANNEL_ARG);
    double ticks, start;

    vendorID = 0x10b5;
    deviceID = 0x9080;
    SubvendorID = 0x10b5;
    SubsystemID = 0x2405;

// Need to check Subsystem ID and Subvendor ID, all GS boards that use the 9080
// have the same DeviceID and VendorID.
    if ((int_T)mxGetPr(SLOT_ARG)[0]<0)
    {
        if( rl32eGetPCIInfoExt( vendorID, deviceID, SubvendorID, SubsystemID, &pciinfo ) )
        {
            sprintf(msg,"%s: board not present", devName);
            ssSetErrorStatus(S,msg);
            return;
        }
    }
    else
    {
        int_T bus, slot;
        if (mxGetN(SLOT_ARG) == 1)
        {
            bus = 0;
            slot = (int_T)mxGetPr(SLOT_ARG)[0];
        }
        else
        {
            bus = (int_T)mxGetPr(SLOT_ARG)[0];
            slot = (int_T)mxGetPr(SLOT_ARG)[1];
        }
        if (rl32eGetPCIInfoAtSlotExt( vendorID, deviceID, SubvendorID, SubsystemID, (slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo))
        {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // Show device information
//    rl32eShowPCIInfo(pciinfo);

    Physical = (void *)pciinfo.BaseAddress[2]; 

    Virtual = rl32eGetDevicePtr(Physical, 1024, RT_PG_USERREADWRITE);

    regs = (daregs *)Virtual;

    ssSetIWorkValue(S, BASE_ADDR_IND, (int)regs );

//    printf("Register dump\n");
//    printf("bcr         = 0x%x\n", regs->bcr );
//    printf("chan_sel    = 0x%x\n", regs->chan_sel );
//    printf("sample_rate = 0x%x\n", regs->sample_rate );
//    printf("buffer_ops  = 0x%x\n", regs->buffer_ops );
//    printf("clock       = 0x%x\n", regs->clock );

    initval = SIMUL_OUTPUT;

    if( (int)mxGetPr( GROUND_ARG )[0] == 1 )
        initval |= GROUND_SENSE;

    // Do this only in initial download call to mdlStart
    if( xpceIsModelInit() && ((int)mxGetPr( CAL_ARG )[0] == 1) )
    {
        regs->bcr = initval | START_CAL;
        start = rl32eGetTicksDouble();
        printf("PMC-16AO-12 Autocalibration started\n");
        while( (regs->bcr & START_CAL) == START_CAL )
        {
            ticks = rl32eGetTicksDouble();
            if( ticks - start > 1193000.0 * 7.0 )   // 7 second timeout
            {
                sprintf(msg,"%s Autocalibration timed out",devName );
                ssSetErrorStatus(S,msg);
                return;
            }
        }

        if( (regs->bcr & CAL_STATUS) == 0 )  // success
            printf("PMC-16AO-12 Autocalibration succeeded.\n" );
        else
        {
            sprintf(msg,"%s Autocalibration failed",devName );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    /* reset board, this loads calibration constants that may just have
     * been computed.
     */
    regs->bcr = INIT;
    start = rl32eGetTicksDouble();
    while( regs->bcr & INIT )
    {
        ticks = rl32eGetTicksDouble();
        if( ticks - start > 1193000.0 * 2.0 )   // 2 second timeout
        {
            sprintf(msg,"%s failed to complete hardware initialization",devName );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    regs->bcr = initval;

    switch( (int_T)mxGetPr(RANGE_ARG)[0] )
    {
      case 1:    // +-10 volts
        scale = 32768.0 / 10.0;
        break;
      case 2:    // +-5 volts
        scale = 32768.0 / 5.0;
        break;
      case 3:    // +-2.5 volts
        scale = 32768.0 / 2.5;
        break;
    }
    ssSetRWorkValue(S, SCALE_R_IND, scale );

    // Set up the channel selection register, a 1 bit for each active channel.
    // Write to all 12 channels all of the time.
    regs->chan_sel = 0xfff;

    // Leave the sample rate selection set to the default initialization value.

    // Set up the buffer operations register
    // First, clear the buffer, the bit resets when done.
    regs->buffer_ops = DEFAULT_BUFFER_SIZE | CLOCK_ENABLE | CLEAR_BUFFER;
    start = rl32eGetTicksDouble();
    while( regs->buffer_ops & CLEAR_BUFFER )
    {
        ticks = rl32eGetTicksDouble();
        if( ticks - start > 1193000.0 * 2.0 )   // 2 second timeout
        {
            sprintf(msg,"%s failed to complete hardware initialization",devName );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    daregs *regs = (daregs *)ssGetIWorkValue(S, BASE_ADDR_IND);
    real_T scale = ssGetRWorkValue( S, SCALE_R_IND );
    int nchans = (int)mxGetN(CHANNEL_ARG);
    int i, k;
    real_T *uPtr;
    int channel;

    /* write data to output FIFO */
    for (i = 0 ; i < nchans ; i++ )
    {
        int temp;
        channel = (int)mxGetPr(CHANNEL_ARG)[i] - 1;
        uPtr = (real_T *)ssGetInputPortRealSignal(S,i);
        temp = (int)(scale * uPtr[0]);
        if( temp > 32767 )
            temp = 32767;
        if( temp < -32768 )
            temp = -32768;
        // Change the data for the active channels
        ssSetIWorkValue( S, LAST_CHAN0_IND + channel, temp );
    }

    // Write all 12 channels worth of data to output FIFO
    for( i = 0 ; i < 12 ; i++ )
        regs->output = ssGetIWorkValue( S, LAST_CHAN0_IND + i );

#endif
}

static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
    daregs *regs = (daregs *)ssGetIWorkValue(S, BASE_ADDR_IND);
    real_T scale = ssGetRWorkValue( S, SCALE_R_IND );
    int nchans = (int)mxGetN(CHANNEL_ARG);
    int i;

    /* Reset the outputs that need to be reset, else use the
     *  previous value.
     */
    if( xpceIsModelInit() )
    {
        // First initialize all to 0 on boot initialization.
        for( i = 0 ; i < 12 ; i++ )
            ssSetIWorkValue( S, LAST_CHAN0_IND + i, 0 );
    }
    for (i = 0 ; i < nchans ; i++)
    {
        if( xpceIsModelInit() || (int)mxGetPr( RESET_ARG )[i] )
        {
            int channel = (int)mxGetPr(CHANNEL_ARG)[i] - 1;
            int value = (int)( scale * (double)mxGetPr(IVAL_ARG)[i] );
            ssSetIWorkValue( S, LAST_CHAN0_IND + channel, value );
        }
    }

    for( i = 0 ; i < 12 ; i++ )
        regs->output = ssGetIWorkValue( S, LAST_CHAN0_IND + i );
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


