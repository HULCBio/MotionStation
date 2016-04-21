/* $Revision $ $Date: 2004/04/08 21:02:20 $ */
/* encsensoray526.c - xPC Target, non-inlined S-function driver for the */
/* encoder input section of the Sensoray 526 multifunction pc104 board. */
/* Copyright 1996-2004 The MathWorks, Inc. */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	encsensoray526

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
#define NUMBER_OF_ARGS          (8)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define INDEX_ARG               ssGetSFcnParam(S,1)
#define RESETVAL_ARG            ssGetSFcnParam(S,2)
#define INITVAL_ARG             ssGetSFcnParam(S,3)
#define RANGE_ARG               ssGetSFcnParam(S,4)
#define SPEED_ARG               ssGetSFcnParam(S,5)
#define SAMP_TIME_ARG          	ssGetSFcnParam(S,6)
#define BASE_ARG                ssGetSFcnParam(S,7)

#define NO_I_WORKS              (1)
#define BASE_I_IND              (0)

#define NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int i;
        int first_channel, last_channel, nchans;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
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

    ssSetNumOutputPorts(S, 1 );
    ssSetOutputPortWidth(S, 0, 1);

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
    int        index;
    int        initval;
    int        resetval;
    int        speed;
    int        mode;
    int        channel;

    base = (int_T)mxGetPr(BASE_ARG)[0];
    channel = mxGetPr( CHANNEL_ARG )[0] - 1;
    base +=  8*channel;
    ssSetIWorkValue( S, BASE_I_IND, base );

    index = (int)mxGetPr( INDEX_ARG )[0];
    initval = (int)mxGetPr( INITVAL_ARG )[0];
    resetval = (int)mxGetPr( RESETVAL_ARG )[0];
    speed = (int)mxGetPr( SPEED_ARG )[0];

    mode = PRELOAD0 | LATCHONREAD | QUADRATURE;
    switch( index )
    {
      case 1:  // rising edge
        mode |= INDEXRISE;
        break;
      case 2:  // falling edge
        mode |= INDEXFALL;
        break;
      case 3:  // both
        mode |= INDEXRISE | INDEXFALL;
        break;
      case 4:  // neither, no reset on index
        break;
    }

    switch( speed )
    {
      case 1:  // 1x
        mode |= QUADX1;
        break;
      case 2:  // 2x
        mode |= QUADX2;
        break;
      case 3:  // 4x
        mode |= QUADX4;
        break;
    }
//printf("Start writing mode = 0x%x, initval = %d\n", mode, initval );
    // We need to set both PR0 and PR1 with the initial value, and then
    // with the reset value.  The init or reset load sometimes comes from
    // PR0 and sometimes from PR1.
    rl32eOutpW( base + CMR, PRELOAD0 );
    // Addressing PR0, load it with initial value, high word first
    rl32eOutpW( base + CNTH, (initval >> 16) & 0xff );
    rl32eOutpW( base + CNTL, initval & 0xffff );
    rl32eOutpW( base + CMR, PRELOAD1 );
    // Addressing PR0, load it with initial value, high word first
    rl32eOutpW( base + CNTH, (initval >> 16) & 0xff );
    rl32eOutpW( base + CNTL, initval & 0xffff );

    // Assert the counter load bit to load from PR0
    rl32eOutpW( base + CCSR, CNTLOAD );

    // Addressing PR0, load it with reset value, high word first
    rl32eOutpW( base + CMR, PRELOAD0 );
    rl32eOutpW( base + CNTH, (resetval >> 16) & 0xff );
    rl32eOutpW( base + CNTL, resetval & 0xffff );
    rl32eOutpW( base + CMR, PRELOAD1 );
    rl32eOutpW( base + CNTH, (resetval >> 16) & 0xff );
    rl32eOutpW( base + CNTL, resetval & 0xffff );

    // Start the counter
    rl32eOutpW( base + CMR, mode + ENABLE );
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int32_T  base;
    real_T   *uPtr;
    int      value;
    int      range = mxGetPr( RANGE_ARG )[0];

    base = ssGetIWorkValue( S, BASE_I_IND );

    uPtr = (real_T *)ssGetOutputPortSignal(S,0);
    // Reading the low word latches the data.  Always read low first.
    // do the masking for paranoia sake.
    value = rl32eInpW( base + CNTL );
    value = (value & 0xffff) | ((rl32eInpW( base + CNTH ) & 0xff) << 16);
    if( range == 1 ) // signed output, do the sign extend
    {
        if( value & 0x00800000 )  // sign bit of the 24 bit result
            value |= 0xff000000;
    }
    uPtr[0] = (double)value;
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


