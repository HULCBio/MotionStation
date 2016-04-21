
/* $Revision: 1.2 $ $Date: 2003/01/22 20:18:53 $ */
/* serwritebase.c - xPC Target, non-inlined S-function driver for serial
 * output direction for the Quatech QSC-100 board */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         serwritebase

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
#include        "serialdefines.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (1)
#define ADDR_ARG                ssGetSFcnParam(S,0)

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

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, 0);

    ssSetNumInputPorts(S, 2);

    ssSetInputPortRequiredContiguous( S, 0, 1 ); 
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDataType( S, 0, SS_UINT32 );
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    ssSetInputPortRequiredContiguous( S, 1, 1 ); 
    ssSetInputPortWidth(S, 1, 1 );
    ssSetInputPortDataType( S, 1, SS_UINT32 );
    ssSetInputPortDirectFeedThrough(S, 1, 1);

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
    	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    	ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}

#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth( SimStruct *S, int_T port, int_T width )
{
    if( width > 65 )  // Need to check the fifo mode that the board is set to!
    {
        sprintf( msg, "Input vector width must be less than the hardware fifo size" );
        ssSetErrorStatus(S,msg);
        return;
    }
    ssSetInputPortWidth( S, port, width );
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth( SimStruct *S, int_T port, int_T width )
{
}

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE
    int_T base;
    short* biosram;
    bool found = false;
    int i;

    // Save the base address for mdlOutputs
    base = mxGetPr(ADDR_ARG)[0];
    // Check the BIOS data area for this base address.
    biosram = (short *)rl32eGetDevicePtr( (void *)0x400, 1024, RT_PG_USERREADWRITE);
    for( i = 0 ; i < 4 ; i++ )
    {
        if( biosram[i] == base )
        {
            found = true;
            break;
        }
    }
    if( found == false )
        base = 0;

    ssSetIWorkValue(S, BASE_I_IND, base);

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int base = ssGetIWorkValue(S, BASE_I_IND);
    int_T *IPtr = (int_T *)ssGetInputPortSignal(S,0);
    int volatile status = 0;
    int count = 0;
    int ier, iir;
    int enable = *(int *)ssGetInputPortSignal(S,1);

    if( base == 0 || enable <= 0 )
        return;  // This isn't our interrupt.

    // On entry, verify that the transmitter holding register is empty
    // so we can stuff all that came from the software fifo into the
    // hardware fifo.  Assume that the software fifo has a max read
    // parameter that fits with the hardware fifo mode setting.

    status = rl32eInpB( (unsigned short)(base + LSR) ) & 0xff;
    if( IPtr[0] == 0 )
    {
//printf("%1xt", base>>8 );

        // No data, turn off the transmitter empty interrupt and leave
        ier = rl32eInpB( (unsigned short)(base + IER) ) & 0xff;
        rl32eOutpB( (unsigned short)(base + IER), (unsigned short)(ier & ~IERXMT) );
    }
    else if( status & LSRTHRE )
    {
        int i;
        // Copy all the data from the input vector to the HW fifo.
        // The fifo read block MUST have the correct max read value
        // for the fifo mode.

        for( i = 0 ; i < IPtr[0] ; i++ )
        {
            rl32eOutpB( (ushort_T)(base + DATA), (ushort_T)(IPtr[i+1] & 0xff) );
        }
//printf("%1xw%dc", base>>8, i );
    }
    else
    {
        sprintf(msg, "Attempted write to hardware fifo that isn't empty" );
        ssSetErrorStatus( S, msg );
        return;
    }

#endif

}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
