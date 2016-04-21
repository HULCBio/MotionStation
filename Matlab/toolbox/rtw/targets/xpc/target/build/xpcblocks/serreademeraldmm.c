/* $Revision: 1.1.6.1 $ $Date: 2003/09/02 01:15:26 $ */
/* serreadbase.c - xPC Target, non-inlined S-function driver for serial
 * input section for the baseboard UARTs. */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         serreademeraldmm

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
#define NUMBER_OF_ARGS          (2)
#define ADDR_ARG                ssGetSFcnParam(S,0)
#define FLUSH_ARG               ssGetSFcnParam(S,1)

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

    ssSetNumOutputPorts(S, 1);
    // The output is wide enough to hold up to 1 hardware fifo full of characters
    // plus 1 spot for the count.  Assume it could be a 16450, 16550 or 16750.
    ssSetOutputPortWidth(S, 0, 65);
    ssSetOutputPortDataType( S, 0, SS_UINT32 );

    ssSetNumInputPorts(S, 1);
    ssSetInputPortRequiredContiguous( S, 0, 1 ); 
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDataType( S, 0, SS_UINT32 );
    ssSetInputPortDirectFeedThrough(S, 0, 1);

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

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE


    int_T base;
    int flush = (int)mxGetPr(FLUSH_ARG)[0];
    int i = 0;

    // Save the base address for mdlOutputs
    base = mxGetPr(ADDR_ARG)[0];
    ssSetIWorkValue(S, BASE_I_IND, base);
    //printf("serreademeraldmm: base = 0x%x\n", base );
    if( flush && base != 0 )
    {
        // Flush the hardware fifo on startup.  Limit to 65 character
	// flush.
        while( i++ < 65 && rl32eInpB( (unsigned short)(base + LSR) ) & LSRDR )
        {
            // Read and discard the data.
            rl32eInpB( (unsigned short)(base + DATA) );
        }
    }
#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int base = ssGetIWorkValue(S, BASE_I_IND);
    int_T *OPtr = ssGetOutputPortSignal(S,0);
    int_T *IPtr = (int_T *)ssGetInputPortSignal(S,0);
    int status = 0;
    int count = 0;
    int enable;

    enable = (IPtr[0]) & 0xff;
    //printf("re%d ", enable);

    if( base != 0 ) // && enable > 0 )
    {
        status = rl32eInpB( (unsigned short)(base + LSR) ) & 0xff;
	//printf("read status = %x\n", status );
        // While there is data in the fifo, read it, also read error status.
        while( (status & LSRDR) )
        {
            int c;
            int masked;
            
            count++;
            c = rl32eInpB( (unsigned short)(base + DATA) ) & 0xff;  // read character
            masked = status & (LSROE | LSRPE | LSRFE | LSRBI);
//if( masked != 0 )
//    printf("ERROR(%x): 0x%x\n", base, masked );
//printf("c = %x, stat = 0x%x, masked = 0x%x ", c, status, masked );
            OPtr[count] = ((status & (LSROE | LSRPE | LSRFE | LSRBI)) << 8) | ( c & 0xff );
            status = rl32eInpB( (unsigned short)(base + LSR) ) & 0xff;
        }
	//printf("%1xr%dc ", base>>8, count );
        OPtr[0] = count;
    }
    else
    {
        OPtr[0] = 0;
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
