/* $Revision: 1.1.6.1 $ $Date: 2004/03/30 13:13:36 $ */
/* adsensoray526.c - xPC Target, non-inlined S-function driver for  */
/* the analog input section of the Sensoray 526 analog to digital   */
/* converter pc104 board.                                           */
/* Copyright 1996-2004 The MathWorks, Inc.                          */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	adsensoray526

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
#define NUMBER_OF_ARGS          (5)
#define CHANNEL1_ARG            ssGetSFcnParam(S,0)
#define CHANNEL2_ARG            ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG          	ssGetSFcnParam(S,2)
#define BASE1_ARG               ssGetSFcnParam(S,3)
#define BASE2_ARG               ssGetSFcnParam(S,4)

// With the following pairs, make the second one always have
// the next number so the board index, 0 or 1 can be added to the first one.
#define NO_I_WORKS              (4)
#define BASE1_I_IND             (0)
#define BASE2_I_IND             (1)
#define ACQUIRE1_I_IND          (2)
#define ACQUIRE2_I_IND          (3)

#define NO_R_WORKS              (4)
#define SCALEMULT1_R_IND        (0)
#define SCALEMULT2_R_IND        (1)
#define OFFSET1_R_IND           (2)
#define OFFSET2_R_IND           (3)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int i;
        int channel, nchans;
        int nchans1, nchans2;

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

    nchans1 = mxGetN( CHANNEL1_ARG );

    nchans2 = mxGetN( CHANNEL2_ARG );

    nchans = 0;
    if( mxGetPr(BASE1_ARG)[0] > 0 )
        nchans += nchans1;
    if( mxGetPr(BASE2_ARG)[0] > 0 )
        nchans += nchans2;

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
//printf("exit mdlInitializeSizes\n");
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

    int32_T    base[2];
    double     ref;
    short      c0, c10;
    double     sum0, sum10;
    unsigned short wreg, rreg;
    double     scalemult;
    int        nchans[2];
    double     *chanptr[2];
    
    double t1, t2;
    short r0, r1, r2, r3;
    int i, brd;

    base[0] = (int_T)mxGetPr(BASE1_ARG)[0];
    base[1] = (int_T)mxGetPr(BASE2_ARG)[0];
    nchans[0] = mxGetN(CHANNEL1_ARG);
    nchans[1] = mxGetN(CHANNEL2_ARG);
    chanptr[0] = (double *)mxGetPr(CHANNEL1_ARG);
    chanptr[1] = (double *)mxGetPr(CHANNEL2_ARG);

    // If base[N] is 0, then that board is not present.
    // All conditionals use this to decide if the board is present.
    for( brd = 0 ; brd < 2 ; brd++ )
    {
        ssSetIWorkValue( S, BASE1_I_IND+brd, base[brd] );
        if( base[brd] == 0 )
            continue;  // skip a missing board

#ifdef DEBUG
        printf("base[%d] = 0x%x\n", brd, base[brd] );
#endif
        // Read the reference voltage from the EEPROM
        ref = readEEPROM( ADCREF, base[brd] );
#ifdef DEBUG
        printf("[%d]: ref voltage = %lg\n", brd, ref );
#endif

        sum0 = 0;
        sum10 = 0;
        // Perform 10 reads of the references and average.
        for( i = 0 ; i < 10 ; i++ )
        {
            // Perform a read on the two calibration inputs
            t1 = rl32eGetTicksDouble();
            wreg = ADMUXDELAY | ADREF0 | ADREF10 | ADSTART;
            //wreg = ADREF0 | ADREF10 | ADSTART;
            rl32eOutpW( base[brd]+ADC, wreg );
            waitISRbit( base[brd], ADCDONE );
            rl32eOutpW( base[brd]+ADC, ADREADREF0 );
            c0 = rl32eInpW( base[brd]+ADD );
            rl32eOutpW( base[brd]+ADC, ADREADREF10 );
            c10 = rl32eInpW( base[brd]+ADD );
            t2 = rl32eGetTicksDouble();
            //printf("With delay, c0 = 0x%x, c10 = 0x%x, %f ticks\n", c0, c10, t2-t1 );
            sum0 += (double)c0;
            sum10 += (double)c10;
        }
#ifdef DEBUG
        printf("brd(%d) Avg: c0 = %f, c10 = %f\n", brd, sum0/i, sum10/i );
#endif
        scalemult = (ref * i) / ( sum10 - sum0 );
        ssSetRWorkValue( S, SCALEMULT1_R_IND+brd, scalemult );
        ssSetRWorkValue( S, OFFSET1_R_IND+brd, (double)(sum0/i) );
#ifdef DEBUG
        printf("brd(%d) mult = %f, offset = %f\n", brd, scalemult, sum0/i );
#endif
        // V = scalemult * (cmeas - offset);

        wreg = ADSTART;
        for( i = 0 ; i < nchans[brd] ; i++ )
        {
            int chan = chanptr[brd][i] - 1;  // convert to 0 based channel
            wreg |= ADCVT(chan);
        }
        // It appears that we always need the muxdelay bit when more than
        // one channel is requested.
        if( nchans[brd] > 1 )
            wreg |= ADMUXDELAY;

        ssSetIWorkValue( S, ACQUIRE1_I_IND+brd, wreg );
    }

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

    int32_T  base[2], i;
    real_T   *uPtr;
    int32_T  nchans[2];
    double   scalemult[2], offset[2];
    int32_T  chanbase = 0;

    base[0] = ssGetIWorkValue( S, BASE1_I_IND );
    base[1] = ssGetIWorkValue( S, BASE2_I_IND );
    // Start the acquire as soon as possible, finish setup, then wait.
    if( base[0] != 0 )
        rl32eOutpW( base[0]+ADC, ssGetIWorkValue( S, ACQUIRE1_I_IND ));
    if( base[1] != 0 )
        rl32eOutpW( base[1]+ADC, ssGetIWorkValue( S, ACQUIRE2_I_IND ));

    scalemult[0] = ssGetRWorkValue( S, SCALEMULT1_R_IND );
    offset[0] = ssGetRWorkValue( S, OFFSET1_R_IND );
    scalemult[1] = ssGetRWorkValue( S, SCALEMULT2_R_IND );
    offset[1] = ssGetRWorkValue( S, OFFSET2_R_IND );
    // V = scalemult * ((double)cmeas - offset);

    nchans[0] = mxGetN(CHANNEL1_ARG);
    nchans[1] = mxGetN(CHANNEL2_ARG);

    if( base[0] != 0 )
    {
        waitISRbit( base[0], ADCDONE );
        for( i = 0 ; i < nchans[0] ; i++ )
        {
            int chan = mxGetPr(CHANNEL1_ARG)[i] - 1;  // convert to 0 based channel
            short data;

            uPtr = (real_T *)ssGetOutputPortSignal(S,i);

            rl32eOutpW( base[0]+ADC, ADREAD(chan) );
            data = rl32eInpW( base[0]+ADD );
            uPtr[0] = scalemult[0] * ( (double)data - offset[0] );
        }
        chanbase = nchans[0];
    }
    if( base[1] != 0 )
    {
        waitISRbit( base[1], ADCDONE );
        for( i = chanbase ; i < chanbase + nchans[1] ; i++ )
        {
            int chan = mxGetPr(CHANNEL2_ARG)[i-chanbase] - 1;  // convert to 0 based channel
            short data;

            uPtr = (real_T *)ssGetOutputPortSignal(S,i);

            rl32eOutpW( base[1]+ADC, ADREAD(chan) );
            data = rl32eInpW( base[1]+ADD );
            uPtr[0] = scalemult[1] * ( (double)data - offset[1] );
        }
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


