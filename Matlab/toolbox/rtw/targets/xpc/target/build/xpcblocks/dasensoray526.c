/* $Revision: 1.1.6.1 $ $Date: 2004/03/30 13:13:37 $ */
/* dasensoray526.c - xPC Target, non-inlined S-function driver for          */
/* the analog output section of the Sensoray 526 multifunction pc104 board. */
/* Copyright 1996-2004 The MathWorks, Inc.                                  */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	dasensoray526

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
#define NUMBER_OF_ARGS          (9)
#define CHANNEL1_ARG            ssGetSFcnParam(S,0)
#define RESET1_ARG              ssGetSFcnParam(S,1)
#define INITIAL1_ARG            ssGetSFcnParam(S,2)
#define CHANNEL2_ARG            ssGetSFcnParam(S,3)
#define RESET2_ARG              ssGetSFcnParam(S,4)
#define INITIAL2_ARG            ssGetSFcnParam(S,5)
#define SAMP_TIME_ARG          	ssGetSFcnParam(S,6)
#define BASE1_ARG               ssGetSFcnParam(S,7)
#define BASE2_ARG               ssGetSFcnParam(S,8)

#define NO_I_WORKS              (4)
#define BASE1_I_IND             (0)
#define BASE2_I_IND             (1)
#define NCHANS1_I_IND           (2)
#define NCHANS2_I_IND           (3)

#define NO_R_WORKS              (16)
#define SCALE_R_IND             (0)

struct scale {
    double mult;
    double offset;
};

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    int nchans, nchans1, nchans2;
    int base1, base2;

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

    nchans1 = mxGetN( CHANNEL1_ARG );
    nchans2 = mxGetN( CHANNEL2_ARG );
    nchans = 0;
    base1 = (int)mxGetPr(BASE1_ARG)[0];
    base2 = (int)mxGetPr(BASE2_ARG)[0];
    if( base1 > 0 )
        nchans += nchans1;
    if( base2 > 0 )
        nchans += nchans2;

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

    int32_T    base[2];
    double     dac0A, dac0B, dac1A, dac1B, dac2A, dac2B, dac3A, dac3B;
    struct scale *scaleptr = (struct scale *)ssGetRWork(S);
    int brd;

    base[0] = (int_T)mxGetPr(BASE1_ARG)[0];
    base[1] = (int_T)mxGetPr(BASE2_ARG)[0];
    ssSetIWorkValue( S, BASE1_I_IND, base[0] );
    ssSetIWorkValue( S, BASE2_I_IND, base[1] );

    for( brd = 0 ; brd < 2 ; brd++ )
    {
        if( base[brd] == 0 )
            continue;
        dac0A = readEEPROM( DAC0A, base[brd] );
        dac0B = readEEPROM( DAC0B, base[brd] );
        scaleptr[0+4*brd].mult = dac0A;
        scaleptr[0+4*brd].offset = dac0B;

        dac1A = readEEPROM( DAC1A, base[brd] );
        dac1B = readEEPROM( DAC1B, base[brd] );
        scaleptr[1+4*brd].mult = dac1A;
        scaleptr[1+4*brd].offset = dac1B;

        dac2A = readEEPROM( DAC2A, base[brd] );
        dac2B = readEEPROM( DAC2B, base[brd] );
        scaleptr[2+4*brd].mult = dac2A;
        scaleptr[2+4*brd].offset = dac2B;

        dac3A = readEEPROM( DAC3A, base[brd] );
        dac3B = readEEPROM( DAC3B, base[brd] );
        scaleptr[3+4*brd].mult = dac3A;
        scaleptr[3+4*brd].offset = dac3B;
#ifdef DEBUG
        printf("DAC 0 a = %lg, b = %lg\n", dac0A, dac0B );
        printf("DAC 1 a = %lg, b = %lg\n", dac1A, dac1B );
        printf("DAC 2 a = %lg, b = %lg\n", dac2A, dac2B );
        printf("DAC 3 a = %lg, b = %lg\n", dac3A, dac3B );
#endif
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

    int32_T  base[2], i;
    real_T   *uPtr;
    int32_T  nchans[2];
    struct scale *scaleptr = (struct scale *)ssGetRWork(S);
    int32_T  chanbase = 0;  // channel base for second board

    base[0] = ssGetIWorkValue( S, BASE1_I_IND );
    base[1] = ssGetIWorkValue( S, BASE2_I_IND );

    nchans[0] = mxGetN( CHANNEL1_ARG );
    nchans[1] = mxGetN( CHANNEL2_ARG );

#ifdef DEBUG
    for( i = 0 ; i < 8 ; i++ )
    {
        printf("DAC %d: mult = %lg, offset = %lg\n", i, scaleptr[i].mult, scaleptr[i].offset );
    }
#endif
    if( base[0] != 0 )
    {
        for( i = 0 ; i < nchans[0] ; i++ )
        {
            int chan;
            double data;
            int ldata;

            chan = mxGetPr( CHANNEL1_ARG )[i] - 1; // get chan and convert to 0 based
            uPtr = (real_T *)ssGetInputPortRealSignal(S,i);
            data = *uPtr;
            //printf("data = %lf\n", data );
            data = scaleptr[chan].mult * data + scaleptr[chan].offset;
            ldata = (int)(data + 0.5);
            //printf("scaled data = %lf, idata = 0x%x\n", data, ldata );
            rl32eOutpW( base[0]+DAC, DASELECT(chan) );
            rl32eOutpW( base[0]+ADD, ldata );
        }
        chanbase = nchans[0];
    }
    if( base[1] != 0 )
    {
        for( i = 0 ; i < nchans[1] ; i++ )
        {
            int chan;
            double data;
            int ldata;

            chan = mxGetPr( CHANNEL2_ARG )[i] - 1; // get chan and convert to 0 based
            uPtr = (real_T *)ssGetInputPortRealSignal(S,i+chanbase);
            data = *uPtr;
            //printf("data = %lf\n", data );
            data = scaleptr[chan+4].mult * data + scaleptr[chan+4].offset;
            ldata = (int)(data + 0.5);
            //printf("scaled data = %lf, idata = 0x%x\n", data, ldata );
            rl32eOutpW( base[1]+DAC, DASELECT(chan) );
            rl32eOutpW( base[1]+ADD, ldata );
        }
    }

    if( base[0] != 0 )
        rl32eOutpW( base[0]+DAC, DASTART );
    if( base[1] != 0 )
        rl32eOutpW( base[1]+DAC, DASTART );

#endif
}

static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
    int32_T  base[2], i;
    int32_T  nchans[2];
    struct scale *scaleptr = (struct scale *)ssGetRWork(S);

    base[0] = ssGetIWorkValue( S, BASE1_I_IND );
    base[1] = ssGetIWorkValue( S, BASE2_I_IND );
    nchans[0] = mxGetN( CHANNEL1_ARG );
    nchans[1] = mxGetN( CHANNEL2_ARG );

    if( base[0] != 0 )
    {
        for( i = 0 ; i < nchans[0] ; i++ )
        {
            int chan;
            double data;
            int ldata;

            if (xpceIsModelInit() || (uint_T)mxGetPr(RESET1_ARG)[i])
            {
                chan = mxGetPr( CHANNEL1_ARG )[i] - 1; // get chan and convert to 0 based
                data = (real_T)mxGetPr(INITIAL1_ARG)[i];
                //printf("(0) reset data = %lf\n", data );
                data = scaleptr[chan].mult * data + scaleptr[chan].offset;
                ldata = (int)(data + 0.5);
                //printf("scaled data = %lf, idata = 0x%x\n", data, ldata );
                rl32eOutpW( base[0]+DAC, DASELECT(chan) );
                rl32eOutpW( base[0]+ADD, ldata );
            }
        }
    }
    if( base[1] != 0 )
    {
        for( i = 0 ; i < nchans[1] ; i++ )
        {
            int chan;
            double data;
            int ldata;

            if (xpceIsModelInit() || (uint_T)mxGetPr(RESET2_ARG)[i])
            {
                chan = mxGetPr( CHANNEL2_ARG )[i] - 1; // get chan and convert to 0 based
                data = (real_T)mxGetPr(INITIAL2_ARG)[i];
                //printf("(1) data = %lf\n", data );
                data = scaleptr[chan+4].mult * data + scaleptr[chan+4].offset;
                ldata = (int)(data + 0.5);
                // printf("scaled data = %lf, idata = 0x%x\n", data, ldata );
                rl32eOutpW( base[1]+DAC, DASELECT(chan) );
                rl32eOutpW( base[1]+ADD, ldata );
            }
        }
    }

    if( base[0] != 0 )
        rl32eOutpW( base[0]+DAC, DASTART );
    if( base[1] != 0 )
        rl32eOutpW( base[1]+DAC, DASTART );


#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


