/* $Revision: 1.5 $ $Date: 2002/03/25 04:05:56 $ */
/* adgesada1.c - xPC Target, non-inlined S-function driver for analog output section of Gespac GESADA-1 board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME dagesada1

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
#define NUMBER_OF_ARGS                  (3)
#define CHANNELS_ARG                   	ssGetSFcnParam(S,0)
#define SAMP_TIME_ARG                   ssGetSFcnParam(S,1)
#define BASE_ADDR_ARG                   ssGetSFcnParam(S,2)

#define CHANNELS_IND            		(0)
#define SAMP_TIME_IND                   (0)
#define BASE_ADDR_IND                   (0)

#define NO_I_WORKS                      (2)
#define CHANNELS_I_IND 	 				(0)
#define BASE_ADDR_I_IND                 (1)

#define NO_R_WORKS                      (8)

#define MAX_CHANNELS                   	(4)

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
        if ( mxGetM(CHANNELS_ARG)!=1 ) {
            sprintf(msg,"channel argument must be row vector\n");
            ssSetErrorStatus(S,msg);
            return;
        }
#endif

        num_channels=mxGetN(CHANNELS_ARG);

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
        ssSetNumOutputs(S, 0);
        ssSetNumInputs(S, num_channels);
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
        real_T *RWork=ssGetRWork(S);
        int_T i, range, counts;
        real_T value;


         
        num_channels = mxGetN(CHANNELS_ARG);
        ssSetIWorkValue(S,CHANNELS_I_IND , num_channels);

        base_addr = (unsigned int) mxGetPr(BASE_ADDR_ARG)[0];
        ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);

        /* prepare gain and offset work vector */
        
        for (i=0;i<num_channels;i++) {
          range=100*mxGetPr(CHANNELS_ARG)[i];
          if (range==-1000) {
            RWork[2*i]=20.0/1024.0;
            RWork[2*i+1]=10.0;
          } else if (range==-500) {
            RWork[2*i]=10.0/1024.0;
            RWork[2*i+1]=5.0;
          } else if (range==1000) {
            RWork[2*i]=10.0/1024.0;
            RWork[2*i+1]=0.0;
          } else {
#ifdef MATLAB_MEX_FILE
      sprintf(msg,"the analog output range values can only be -10, -5, 10");
      ssSetErrorStatus(S,msg);
      return;
#endif
          }
       }

       /* initialize hardware, reset all output channels to 0*/
#ifndef MATLAB_MEX_FILE

       for (i=0;i<num_channels;i++) {
         value=0.0;
         counts=(value+RWork[2*i+1])/RWork[2*i];
         if (counts>1023) counts=1023;
         if (counts<0)    counts=0;
         rl32eOutpB((unsigned short)(base_addr+4*i+1),(unsigned short)((counts >> 2) & 0xff));
         rl32eOutpB((unsigned short)(base_addr+4*i+3),(unsigned short)((counts & 0x3) << 6));

      }

#endif

       
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
        real_T *RWork=ssGetRWork(S);
        int_T i, counts;
        real_T value;
        
#ifndef MATLAB_MEX_FILE

       for (i=0;i<num_channels;i++) {
         value=u[i];
         counts=(value+RWork[2*i+1])/RWork[2*i];
         if (counts>1023) counts=1023;
         if (counts<0)    counts=0;
         rl32eOutpB((unsigned short)(base_addr+4*i+1),(unsigned short)((counts >> 2) & 0xff));
         rl32eOutpB((unsigned short)(base_addr+4*i+3),(unsigned short)((counts & 0x3) << 6));
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
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
        real_T *RWork=ssGetRWork(S);
        int_T i, counts;
        real_T value;
        
#ifndef MATLAB_MEX_FILE

       for (i=0;i<num_channels;i++) {
         value=0.0;
         counts=(value+RWork[2*i+1])/RWork[2*i];
         if (counts>1023) counts=1023;
         if (counts<0)    counts=0;
         rl32eOutpB((unsigned short)(base_addr+4*i+1),(unsigned short)((counts >> 2) & 0xff));
         rl32eOutpB((unsigned short)(base_addr+4*i+1),(unsigned short)((counts & 0x3) << 6));
      }
    
#endif
  
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif




