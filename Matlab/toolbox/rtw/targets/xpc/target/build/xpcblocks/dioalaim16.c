/* $Revision: 1.3 $ $Date: 2002/03/25 04:07:05 $ */
/* dioalaim16.c - xPC Target, non-inlined S-function driver for  */
/* the digital IO section of the Analogic AIM16-1/104 and -2/104 */
/* multifunction pc104 board. */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	dioalaim16

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef 	MATLAB_MEX_FILE
#include 	<windows.h>
#include 	"io_xpcimport.h"
#include 	"multialaim16.h"
#endif

	    

/* Input Arguments */
#define NUMBER_OF_ARGS          (5)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define GROUP_ARG               ssGetSFcnParam(S,1)
#define DIRECTION_ARG           ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG          	ssGetSFcnParam(S,3)
#define BASE_ARG                ssGetSFcnParam(S,4)

#define NO_I_WORKS              (2)
#define BASE_I_IND              (0)
#define NCHANS_I_IND            (1)

#define NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    int channel, nchans;
    int direction;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    nchans = (int)mxGetN(CHANNEL_ARG);

    direction = (int)mxGetPr(DIRECTION_ARG)[0];

    if( direction == 1 )  // If input block
    {
        ssSetNumOutputPorts(S, nchans );
        for( i = 0 ; i < nchans ; i++ )
        {
            ssSetOutputPortWidth(S, i, 1);
        }

        ssSetNumInputPorts(S, 0);
    }
    else
    {
        ssSetNumInputPorts(S, nchans );
        for( i = 0 ; i < nchans ; i++ )
        {
            ssSetInputPortWidth(S, i, 1);
            ssSetInputPortRequiredContiguous( S, i, 1 );
        }

        ssSetNumOutputPorts(S, 0);
    }

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
    int32_T    nchans;
    int_T      i;
    int16_T    asr = 0;
    int16_T    csr, csrdio;
    int32_T    direction, group;

    base = (int_T)mxGetPr(BASE_ARG)[0];
    ssSetIWorkValue( S, BASE_I_IND, base );

    direction = (int32_T)mxGetPr(DIRECTION_ARG)[0];
    group = (int32_T)mxGetPr(GROUP_ARG)[0];
    // direction == 1 means input, 2 means output
    // group == 1 means LSB, 2 means MSB

    // The DIO use of the board does not require a full reset.  Only
    // the analog in driver does a reset.
    csr = rl32eInpW( base + CSR );
    if( csr & CSRGO )
        rl32eOutpW( base + CSR, csr & ~CSRGO );
    if( direction == 1 )   // Input
    {
        if( group == 1 )   // LSB
        {
            csrdio = csr & ~CSRLSBOUT;
        }
        else               // MSB
        {
            csrdio = csr & ~CSRMSBOUT;
        }
    }
    else                   // Output
    {
        if( group == 1 )   // LSB
        {
            csrdio = csr | CSRLSBOUT;
        }
        else               // MSB
        {
            csrdio = csr | CSRMSBOUT;
        }
    }
    rl32eOutpW( base + CSR, csrdio );  // Put the DIO direction bits in place.
    rl32eOutpW( base + CSR, csrdio | CSRGO );  // Put the GO bit back in.

    nchans = mxGetN(CHANNEL_ARG);
    ssSetIWorkValue( S, NCHANS_I_IND, nchans );

    // Since we aren't using DMA, set the DTR register to 0.
    rl32eOutpW( base + DTR, 0 );
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int32_T  base, i;
    real_T   *uPtr;
    int32_T  nchans;
    int32_T  direction, group;
    uint16_T val;
    uint16_T  byteval;

    base = ssGetIWorkValue( S, BASE_I_IND );
    nchans = ssGetIWorkValue( S, NCHANS_I_IND );
    direction = (int32_T)mxGetPr(DIRECTION_ARG)[0];
    group = (int32_T)mxGetPr(GROUP_ARG)[0];

    val = rl32eInpW( base + DIOR );

    switch( direction )
    {
      case 1:    // Input
        if( group == 1 )  // LSB
            byteval = val & 0xff;
        else
            byteval = val >> 8;

        //printf("dio reg = 0x%x, byteval = 0x%x\n", val, byteval );
        for( i = 0 ; i < nchans ; i++ )
        {
            int chan;
            chan = (int32_T)mxGetPr(CHANNEL_ARG)[i] - 1;
            uPtr = (real_T *)ssGetOutputPortSignal(S,i);
            uPtr[0] = (byteval >> chan) & 1;
        }
        break;

      case 2:    // Output, finish read/modify/write
        byteval = 0;
        for( i = 0 ; i < nchans ; i++ )
        {
            int chan;
            chan = (int32_T)mxGetPr(CHANNEL_ARG)[i] - 1;
            uPtr = (real_T *)ssGetInputPortSignal(S,i);
            if( uPtr[0] >= 0.5 )
                byteval |= 1 << chan;
        }

        if( group == 1 )  // LSB
            val = (val & ~0xff) | byteval;
        else
            val = (val & ~0xff00) | (byteval << 8);
        
        rl32eOutpW( base + DIOR, val );
        break;
    }
#endif   
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE
    int32_T  base, direction, group, val;

    base = ssGetIWorkValue( S, BASE_I_IND );
    direction = (int32_T)mxGetPr(DIRECTION_ARG)[0];
    group = (int32_T)mxGetPr(GROUP_ARG)[0];

    val = rl32eInpW( base + DIOR );

    if( direction == 2 )  // Turn all outputs off on shutdown.
    {
        if( group == 1 )  // LSB
            val = val & ~0xff;
        else
            val = val & ~0xff00;
        
        rl32eOutpW( base + DIOR, val );
    }

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


