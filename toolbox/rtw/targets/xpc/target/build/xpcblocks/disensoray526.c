/* $Revision: 1.1.6.1 $ $Date: 2004/03/30 13:13:38 $ */
/* disensoray526.c - xPC Target, non-inlined S-function driver for  */
/* the analog input section of the Sensoray 526 analog to digital   */
/* converter pc104 board.                                           */
/* Copyright 1996-2004 The MathWorks, Inc.                          */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	disensoray526

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

//#define DEBUG

#ifndef 	MATLAB_MEX_FILE
#include 	<windows.h>
#include 	"io_xpcimport.h"
#include 	"time_xpcimport.h"
#include        "xpcsensoray.c"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (4)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define DIOCSR_ARG              ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG          	ssGetSFcnParam(S,2)
#define BASE_ARG                ssGetSFcnParam(S,3)

#define NO_I_WORKS              (2)
#define BASE_I_IND              (0)
#define ACQUIRE_I_IND           (1)

#define NO_R_WORKS              (2)
#define SCALEMULT_R_IND         (0)
#define OFFSET_R_IND            (1)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int i;
        int channel, nchans;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "time_xpcimport.c"
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

    nchans = mxGetN( CHANNEL_ARG );

    ssSetNumOutputPorts(S, nchans );
    for( i = 0 ; i < nchans ; i++ )
    {
        ssSetOutputPortWidth(S, i, 1);
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

    int32_T    base;
    int        diocsr;

    base = (int_T)mxGetPr(BASE_ARG)[0];
    ssSetIWorkValue( S, BASE_I_IND, base );

    // Set the DIO control register, sets direction bits.
    diocsr = mxGetPr(DIOCSR_ARG)[0];
    rl32eOutpW( base+DIO, diocsr );
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int32_T  base, i;
    real_T   *uPtr;
    int32_T  nchans;
    short    data;

    base = ssGetIWorkValue( S, BASE_I_IND );

    nchans = mxGetN(CHANNEL_ARG);

    data = rl32eInpW( base+DIO );
    //printf("di 0x%x\n", data );

    for( i = 0 ; i < nchans ; i++ )
    {
        int chan = mxGetPr(CHANNEL_ARG)[i] - 1;  // convert to 0 based channel

        uPtr = (real_T *)ssGetOutputPortSignal(S,i);

        if( data & (1 << chan) )
            uPtr[0] = 1;
        else
            uPtr[0] = 0;
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


