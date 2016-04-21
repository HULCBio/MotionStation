/* $Revision: 1.5 $ $Date: 2002/03/25 03:59:48 $ */
/* adkmdas1800hr.c - xPC Target, non-inlined S-function driver for analog input section of Keithley Metrabyte DAS1800HR board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME adkmdas1800hr

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
#define NUMBER_OF_ARGS        	(6)
#define CHANNELS_ARG            ssGetSFcnParam(S,0)
#define GAIN_ARG				ssGetSFcnParam(S,1)
#define RANGE_ARG             	ssGetSFcnParam(S,2)
#define MUX_ARG             	ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,4)
#define BASE_ADDR_ARG           ssGetSFcnParam(S,5)


#define RANGE_IND	            (0)
#define MUX_IND		            (0)
#define COMMON_IND	            (0)
#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (20)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)
#define RANGE_I_IND         	(2)



#define NO_R_WORKS              (18)
#define OFFSET_R_IND			(1)
#define GAIN_R_IND				(2)


#define RES_FLOAT 				1.525878906250000e-004
		

static char_T msg[256];




static void mdlInitializeSizes(SimStruct *S)
{
        int_T num_channels, mux;
        int_T channel_used[16];
        int_T i, channel, gain;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif


#ifdef MATLAB_MEX_FILE
        ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
            sprintf(msg,"Wrong number of input arguments passed.\n6 arguments are expected\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if ( mxGetM(CHANNELS_ARG)!=1) {
            sprintf(msg,"channel vector must be a row vector\n");
            ssSetErrorStatus(S,msg);
            return;
        }
#endif

        num_channels=mxGetN(CHANNELS_ARG);
		mux=mxGetPr(MUX_ARG)[MUX_IND];
   
		


#ifdef MATLAB_MEX_FILE

        if ( mxGetM(GAIN_ARG)!=1) {
            sprintf(msg,"gain vector must be a row vector\n");
            ssSetErrorStatus(S,msg);
            return;
        }
		  if ( mxGetN(GAIN_ARG)!= num_channels) {
            sprintf(msg,"gain vector must have the same length than the channel vector\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        
        for (i=0;i<16;i++) channel_used[i]=0;
        for (i=0;i<num_channels;i++) {
       		channel=mxGetPr(CHANNELS_ARG)[i]-1;
			if (mux==1) {	 
            	if (channel > 8) {
					sprintf(msg,"only channels 1 to 8 in differential mode available\n");
            		ssSetErrorStatus(S,msg);
            		return;
            	}
			} else {
            	if (channel > 16) {
					sprintf(msg,"only channels 1 to 16 in single-ended mode available\n");
            		ssSetErrorStatus(S,msg);
            		return;
            	}
			}
            if (channel_used[channel]) {
				sprintf(msg,"channel %d is already defined\n",channel+1);
            	ssSetErrorStatus(S,msg);
            	return;
			} else {
				channel_used[channel]=1;
			}
			gain=mxGetPr(GAIN_ARG)[i];
			if (gain!=1.0 && gain!=2.0 && gain!=4.0 && gain!=8.0) {
				sprintf(msg,"gain elements values can only be 1,2,4 and 8\n");
             	ssSetErrorStatus(S,msg);
             	return;
			}
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
    int_T range, mux, channel, gain;
    int_T i;
    ushort_T out;
         
    num_channels = mxGetN(CHANNELS_ARG);
    ssSetIWorkValue(S,CHANNELS_I_IND , num_channels);

	range=mxGetPr(RANGE_ARG)[RANGE_IND];
	ssSetIWorkValue(S,RANGE_I_IND , range-1);

	mux=mxGetPr(MUX_ARG)[MUX_IND];


    base_addr = (unsigned int) mxGetPr(BASE_ADDR_ARG)[0];
    ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);

    for (i=0;i<num_channels;i++) {
		ssSetRWorkValue(S, GAIN_R_IND+i, mxGetPr(GAIN_ARG)[i]);
	}
		


#ifndef MATLAB_MEX_FILE


	/*board identification */
	if ((rl32eInpB((unsigned short)(base_addr+0x3)) & 0xf0) != 0x60) {
	 	sprintf(msg,"DAS-1800HR (0x%x): board not present",base_addr);
		ssSetErrorStatus(S,msg);
        return;
    }
	
	// set QRAM
	rl32eOutpB((unsigned short)(base_addr+0x2),0x1);

	// write number of QRAM locations
	rl32eOutpB((unsigned short)(base_addr+0xa),(unsigned short)(num_channels-1));

	//load QRAM
	for (i=0;i<num_channels;i++) {
		channel=mxGetPr(CHANNELS_ARG)[i];
		out=channel-1;
		gain=mxGetPr(GAIN_ARG)[i];
		if (gain==2.0) {
			out=out | 0x100;
		} else if (gain==4.0) {
			out=out | 0x200;
		} else if (gain==8.0) {
			out=out | 0x300;
		}
		rl32eOutpW((unsigned short)(base_addr+0x0),(unsigned short)(out));
		//printf("%x\n",out);
	}

	// set control register C
	out=0x10;
	if (range==2) {
		out=out | 0x80;
	}
	if (mux==2 || mux==3) {
		out=out | 0x40;
	}
	if (mux==3) {
		out=out | 0x08;
	}
	rl32eOutpB((unsigned short)(base_addr+0x6),(unsigned short)(out));
	//printf("%x\n",out);

	// enable A/D FIFO
	rl32eOutpB((unsigned short)(base_addr+0x4),0x1);

	// set A/D-FIFO
	rl32eOutpB((unsigned short)(base_addr+0x2),0x0);

	// enable A/D conversions
	rl32eOutpB((unsigned short)(base_addr+0x7),0x80);



#endif
 
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
		int_T range = ssGetIWorkValue(S, RANGE_I_IND);
        int_T i, res;
        double gain;
        unsigned short *ioaddress;
		int_T count;

    
        
#ifndef MATLAB_MEX_FILE

	// write number of QRAM locations
	rl32eOutpB((unsigned short)(base_addr+0xa),(unsigned short)(num_channels-1));
		
    for (i=0;i<num_channels;i++) {
		//initiate A/D conversion
		rl32eOutpW((unsigned short)(base_addr+0x0),0x0);
		while ((rl32eInpB((unsigned short)(base_addr+0x7)) & 0x40) == 0x0);
		count=rl32eInpW((unsigned short)(base_addr+0x0));
		if (count>32767) count=count-65536;
		if (range) {	// unipolar
		   	y[i] = (double)count * RES_FLOAT / ssGetRWorkValue(S, GAIN_R_IND+i);
		} else {
			y[i] = ((double)count * 2.0 * RES_FLOAT) / ssGetRWorkValue(S, GAIN_R_IND+i);
		}
	}
	//printf("%x\n",rl32eInpB((unsigned short)(base_addr+0x7)) & 0x40);

	
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

    
        
#ifndef MATLAB_MEX_FILE

	// disable A/D conversions
	rl32eOutpB((unsigned short)(base_addr+0x7),0x00);
	

	// disable A/D FIFO
	rl32eOutpB((unsigned short)(base_addr+0x4),0x00);

	
#endif


}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif


