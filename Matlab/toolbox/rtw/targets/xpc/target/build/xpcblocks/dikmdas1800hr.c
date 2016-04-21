/* $Revision: 1.5 $ $Date: 2002/03/25 04:06:50 $ */
/* dikmdas1800hr.c - xPC Target, non-inlined S-function driver for digital input section of Keithley Metrabyte DAS1800HR board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/


#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME dikmdas1800hr

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "io_xpcimport.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS          (3)
#define CHANNELS_ARG            ssGetSFcnParam(S,0)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,1)
#define BASE_ADDR_ARG           ssGetSFcnParam(S,2)

#define CHANNELS_IND            (0)
#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)

#define NO_R_WORKS              (0)

#define MAX_CHANNELS           	(4)
#define THRESHOLD              	0.5

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
        int_T num_channels;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif


#ifdef MATLAB_MEX_FILE
       ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
       if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
            sprintf(msg,"Wrong number of input arguments passed.\nThree arguments are expected\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if ( mxGetM(CHANNELS_ARG)!=1 | mxGetN(CHANNELS_ARG)!=1 ) {
            sprintf(msg,"channel argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }
#endif

        num_channels=(int_T)mxGetPr(CHANNELS_ARG)[CHANNELS_IND];

#ifdef MATLAB_MEX_FILE
        if (num_channels>MAX_CHANNELS) {
             sprintf(msg,"not more than 4 channels available\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if ( mxGetM(BASE_ADDR_ARG)!=1 | mxGetN(BASE_ADDR_ARG)!=1 ) {
             sprintf(msg,"base address argument must be scalar\n");
             ssSetErrorStatus(S,msg);
             return;
        }

#endif
        
        /* Set-up size information */
        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);
        ssSetNumOutputs(S, num_channels);
        ssSetNumInputs(S, 0);
        ssSetDirectFeedThrough(S, 0); /* Direct dependency on inputs */
        ssSetNumSampleTimes(S,1);
        ssSetNumInputArgs(S, NUMBER_OF_ARGS);
        ssSetNumIWork(S, NO_I_WORKS); 
        ssSetNumRWork(S, NO_R_WORKS);
        ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
        ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
        ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
        ssSetOptions(          S, 0);   /* general options (SS_OPTION_xx)        */
        
}
 
/* Function to initialize sample times */
static void mdlInitializeSampleTimes(SimStruct *S)
{
        
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
        if (mxGetN((SAMP_TIME_ARG))==1) {
			ssSetOffsetTime(S, 0, 0.0);
		} else {
        	ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
		}

}
 

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{


        int_T arg_str_len = 128;
        char_T arg_str[128];
        uint_T base_addr;
        int_T num_channels;

        num_channels = (int_T)mxGetPr(CHANNELS_ARG)[CHANNELS_IND];
        ssSetIWorkValue(S,CHANNELS_I_IND , num_channels);

        base_addr = (unsigned int) mxGetPr(BASE_ADDR_ARG)[0];
        ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);
   

        /* initialize hardware */
        
#ifndef MATLAB_MEX_FILE

		//board identification
		if ((rl32eInpB((unsigned short)(base_addr+0x3)) & 0xf0) != 0x60) {
	 		sprintf(msg,"DAS-1800HR (0x%x): board not present",base_addr);
			ssSetErrorStatus(S,msg);
            return;
      	}
		

#endif

                 
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
        int_T i;
        int_T input;
    
        
#ifndef MATLAB_MEX_FILE

        input=rl32eInpB((unsigned short)(base_addr+0x3));
        for (i=0;i<num_channels;i++) {
          y[i]=(input & (1<<i)) >>i; 
        }

#endif
        
}

/* Function to compute model update */
static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}
 
/* Function to compute derivatives */
static void mdlDerivatives(real_T *dx, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}
 
/* Function to perform housekeeping at execution termination */
static void mdlTerminate(SimStruct *S)
{
        /*
         * This function sets the digital outputs
         * to 0. 
         */
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
       

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


