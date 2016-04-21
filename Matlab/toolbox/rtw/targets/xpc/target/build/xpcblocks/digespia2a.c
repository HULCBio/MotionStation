/* $Revision: 1.5 $ $Date: 2002/03/25 04:06:38 $ */
/* digespia2a.c - xPC Target, non-inlined S-function driver for digital input section of Gespac GESPIA-2A board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME digespia2a

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
#define NUMBER_OF_ARGS          (4)
#define CHANNELS_ARG            ssGetSFcnParam(S,0)
#define PORT_ARG                ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define BASE_ADDR_ARG           ssGetSFcnParam(S,3)

#define CHANNELS_IND            (0)
#define PORT_IND                (0)
#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (3)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)
#define OUTPORT_I_IND           (2)

#define NO_R_WORKS              (0)

#define MAX_CHANNELS           	(8)
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
        if ( mxGetM(PORT_ARG)!=1 | mxGetN(PORT_ARG)!=1 ) {
            sprintf(msg,"port argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if (num_channels>MAX_CHANNELS) {
             sprintf(msg,"not more than 8 channels available\n");
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
        int_T port; 

        num_channels = (int_T)mxGetPr(CHANNELS_ARG)[CHANNELS_IND];
        ssSetIWorkValue(S,CHANNELS_I_IND , num_channels);

        base_addr = (unsigned int) mxGetPr(BASE_ADDR_ARG)[0];
        ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);
   

        /* initialize hardware */
        
        port=(int_T)mxGetPr(PORT_ARG)[PORT_IND];

#ifndef MATLAB_MEX_FILE
       
        if (port==1) {
	ssSetIWorkValue(S,OUTPORT_I_IND , 0x0);
	rl32eOutpB((unsigned short)(base_addr+2*0x2+1), 0x0);			// PIA 0 A control
	rl32eOutpB((unsigned short)(base_addr+2*0x0+1),0x0);			// PIA 0 A direction
	rl32eOutpB((unsigned short)(base_addr+2*0x2+1),0x4);			// PIA 0 A control
        } else if (port==2) {
	ssSetIWorkValue(S,OUTPORT_I_IND , 0x1);
	rl32eOutpB((unsigned short)(base_addr+2*0x3+1), 0x0);			// PIA 0 B control
	rl32eOutpB((unsigned short)(base_addr+2*0x1+1),0x0);			// PIA 0 B direction
	rl32eOutpB((unsigned short)(base_addr+2*0x3+1),0x4);			// PIA 0 B control
        } else if (port==3) {
	ssSetIWorkValue(S,OUTPORT_I_IND , 0x4);
	rl32eOutpB((unsigned short)(base_addr+2*0x6+1), 0x0);			// PIA 1 A control
	rl32eOutpB((unsigned short)(base_addr+2*0x4+1),0x0);			// PIA 1 A direction
	rl32eOutpB((unsigned short)(base_addr+2*0x6+1),0x4);			// PIA 1 A control
        } else if (port==4) {
	ssSetIWorkValue(S,OUTPORT_I_IND , 0x5);
	rl32eOutpB((unsigned short)(base_addr+2*0x7+1), 0x0);			// PIA 1 B control
	rl32eOutpB((unsigned short)(base_addr+2*0x5+1),0x0);			// PIA 1 B direction
	rl32eOutpB((unsigned short)(base_addr+2*0x7+1),0x4);			// PIA 1 B control
         }

#endif
                 
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
        int_T port=ssGetIWorkValue(S, OUTPORT_I_IND);
        int_T i;
        int_T input;
    
        
#ifndef MATLAB_MEX_FILE

        input=rl32eInpB((unsigned short)(base_addr+2*port+1));
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
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


