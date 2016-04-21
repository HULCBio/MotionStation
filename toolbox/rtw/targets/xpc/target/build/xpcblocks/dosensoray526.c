/* $Revision: 1.1.6.1 $ $Date: 2004/03/30 13:13:39 $ */
/* dosensoray526.c - xPC Target, non-inlined S-function driver for          */
/* the analog output section of the Sensoray 526 multifunction pc104 board. */
/* Copyright 1996-2004 The MathWorks, Inc.                                  */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	dosensoray526

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
#include        "util_xpcimport.h"
#include 	"time_xpcimport.h"
#include        "xpcsensoray.c"
#endif

	    

/* Input Arguments */
#define NUMBER_OF_ARGS          (6)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RESET_ARG               ssGetSFcnParam(S,1)
#define INITIAL_ARG             ssGetSFcnParam(S,2)
#define DIOCSR_ARG              ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG          	ssGetSFcnParam(S,4)
#define BASE_ARG                ssGetSFcnParam(S,5)

#define NO_I_WORKS              (2)
#define BASE_I_IND              (0)
#define NCHANS_I_IND            (1)

#define NO_R_WORKS              (0)
// SCALE value uses indexes 0-15
//#define SCALE_R_IND             (0)

struct scale {
    double mult;
    double offset;
};

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int i;
        int first_channel, last_channel, nchans;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "util_xpcimport.c"
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    nchans = mxGetN( CHANNEL_ARG );

    ssSetNumInputPorts(S, nchans );
    for( i = 0 ; i < nchans ; i++ )
    {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortRequiredContiguous( S, i, true );
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

    int32_T    base;
    int        diocsr;

    base = (int_T)mxGetPr(BASE_ARG)[0];
    ssSetIWorkValue( S, BASE_I_IND, base );

    // Set the DIO control register, sets direction bits.
    diocsr = mxGetPr(DIOCSR_ARG)[0];
    rl32eOutpW( base+DIO, diocsr );
//printf("diocsr = 0x%x\n", diocsr );
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int32_T  base, i;
    real_T   *uPtr;
    int32_T  nchans;
    int      diocsr = mxGetPr(DIOCSR_ARG)[0];

    base = ssGetIWorkValue( S, BASE_I_IND );

    nchans = mxGetN( CHANNEL_ARG );

    for( i = 0 ; i < nchans ; i++ )
    {
        int chan;
        double data;
        int ldata;

        chan = mxGetPr( CHANNEL_ARG )[i] - 1; // get chan and convert to 0 based
        uPtr = (real_T *)ssGetInputPortRealSignal(S,i);
        data = *uPtr;
        //printf("data = %lf\n", data );
        if( data >= 0.5 )
            diocsr |= (1 << chan);
        else
            diocsr &= ~(1 << chan);
    }
//printf("do 0x%x\n", diocsr );
    rl32eOutpW( base+DIO, diocsr );

#endif
        
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE
    int32_T  base, i;
    int32_T  nchans;
    int      diocsr = mxGetPr(DIOCSR_ARG)[0];

    base = ssGetIWorkValue( S, BASE_I_IND );

    nchans = mxGetN( CHANNEL_ARG );

    for( i = 0 ; i < nchans ; i++ )
    {
        int chan;
        double data;
        int ldata;

        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i])
        {
            chan = mxGetPr( CHANNEL_ARG )[i] - 1; // get chan and convert to 0 based
            data = (real_T)mxGetPr(INITIAL_ARG)[i];
            //printf("data = %lf\n", data );
            if( data >= 0.5 )
                diocsr |= (1 << chan);
            else
                diocsr &= ~(1 << chan);
        }
    }
    rl32eOutpW( base+DIO, diocsr );

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


