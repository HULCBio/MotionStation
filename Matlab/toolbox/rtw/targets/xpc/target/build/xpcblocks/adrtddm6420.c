/* $Revision: 1.5 $ $Date: 2002/03/25 04:00:00 $ */
/* adrtddm6420.c - xPC Target, non-inlined S-function driver for analog input section of Real Time Devices DM6420 board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME adrtddm6420

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include "drvr6420.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS			(5)
#define CHANNELS_ARG            ssGetSFcnParam(S,0)
#define GAIN_ARG             	ssGetSFcnParam(S,1)
#define COUPLING_ARG            ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,3)
#define BASE_ADDR_ARG           ssGetSFcnParam(S,4)


#define CHANNELS_IND            (0)
#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (18)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)

#define NO_R_WORKS              (18)
#define OFFSET_R_IND			(1)
#define GAIN_R_IND				(2)


#define RES_FLOAT				4096.0 

#define BURST_RATE       		500000.0 	   // Burst rate in [Hz].

static char_T msg[256];


#ifndef MATLAB_MEX_FILE
extern int RTD_DM6420_init;
#endif

#ifndef MATLAB_MEX_FILE
#include "drvr6420.c"
#endif


static void mdlInitializeSizes(SimStruct *S)
{
        int_T num_channels, coupling, gain;
        int_T channel_used[16];
        int_T i, channel;

#ifdef MATLAB_MEX_FILE
        ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
            sprintf(msg,"Wrong number of input arguments passed.\n5 arguments are expected\n");
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
		  if ( mxGetM(COUPLING_ARG)!=1) {
            sprintf(msg,"coupling vector must be a row vector\n");
            ssSetErrorStatus(S,msg);
            return;
        }
		if ( mxGetN(COUPLING_ARG)!= num_channels) {
        	sprintf(msg,"coupling vector must have the same length than the channel vector\n");
            ssSetErrorStatus(S,msg);
            return;
        }

        for (i=0;i<num_channels;i++) {
			coupling=(int_T)mxGetPr(COUPLING_ARG)[i];
			if ( coupling!=1 && coupling!=2 ) {
        		sprintf(msg,"coupling of channel %d can only have value 1 or 2\n", i+1);
            	ssSetErrorStatus(S,msg);
            	return;
			}
			gain=(int_T)mxGetPr(GAIN_ARG)[i];
			if ( gain!=1 && gain!=2 && gain!=4 && gain!=8) {
        		sprintf(msg,"gain of channel %d can only have value 1, 2, 4 or 8\n", i+1);
            	ssSetErrorStatus(S,msg);
            	return;
			}
		}
			
        for (i=0;i<16;i++) channel_used[i]=0;
        for (i=0;i<num_channels;i++) {
        	channel=mxGetPr(CHANNELS_ARG)[i]-1;
			if (mxGetPr(COUPLING_ARG)[i]== 2) {	// is DIFF coupling ?
               	if (channel > 7) {
					sprintf(msg,"only channels 1 to 8 in DIFFERENTIAL-coupling mode supported\n");
            		ssSetErrorStatus(S,msg);
            		return;
               	}
			} else {
               	if (channel > 15) {
					sprintf(msg,"only channels 1 to 16 in SINGLE-ENDED-coupling mode supported\n");
            		ssSetErrorStatus(S,msg);
            		return;
               	}
			}
            if (channel_used[channel]) {
				sprintf(msg,"channel %d is already in use\n",channel+1);
            	ssSetErrorStatus(S,msg);
            	return;
			} else {
				channel_used[channel]=1;
				if (mxGetPr(COUPLING_ARG)[i]== 2) {	// is DIFF coupling ?
					channel_used[channel+8]=1;
				}
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

#ifndef MATLAB_MEX_FILE
	ADTableRow ADTable[16];
#endif
		

    int_T arg_str_len = 128;
    char_T arg_str[128];
    uint_T base_addr;
    int_T num_channels;
    int_T gaintmp, gain;
    int_T coupling, channel, i;

    num_channels = mxGetN(CHANNELS_ARG);
    ssSetIWorkValue(S,CHANNELS_I_IND , num_channels);

    base_addr = (unsigned int) mxGetPr(BASE_ADDR_ARG)[0]; 
		

		

#ifndef MATLAB_MEX_FILE

  	SetBaseAddress(base_addr);
	if (!RTD_DM6420_init) {
  		InitBoard6420();               // Board initializing.
		RTD_DM6420_init=1;
	}

  	for (i=0;i<num_channels;i++) {

		gaintmp=((int_T)(mxGetPr(GAIN_ARG)[i]));
      	if (gaintmp== 1) {
			gain=0;
     		ssSetRWorkValue(S, GAIN_R_IND+i, 20.0/RES_FLOAT);
      	} else if (gaintmp==2) {
			gain=1;
			ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/RES_FLOAT);
		} else if (gaintmp==4) {
			gain=2;
			ssSetRWorkValue(S, GAIN_R_IND+i, 5.0/RES_FLOAT);
		} else if (gaintmp==8) {
			gain=3;
			ssSetRWorkValue(S, GAIN_R_IND+i, 2.5/RES_FLOAT);
		} else {
			printf("gain values can only be: 1, 2, 4 and 8");
			return;
        }	  

	  	ADTable[i].Channel=((int_T)mxGetPr(CHANNELS_ARG)[i])-1;
	  	ADTable[i].Gain=gain;
		ADTable[i].ADRange=1;
	  	ADTable[i].Se_Diff=((int_T)(mxGetPr(COUPLING_ARG)[i]))-1;
	  	ADTable[i].Pause=0;
	  	ADTable[i].Skip=0;

  	}

  	//SetPacerClock6420(RATE);             // Initialize pacer clock.
  	SetBurstClock6420(BURST_RATE);       // Initialize burst clock.
  	SetBurstTrigger6420(0);              // Set Burst Trigger = Softwar.
  	SetStartTrigger6420(0);              // Set Start Trigger = Software.
  	SetStopTrigger6420(3);               // Set Stop Trigger = Sample Counter.
  	SetConversionSelect6420(2);          // Set Conversion select to Burst Clock.
  	LoadADTable6420( num_channels,ADTable); // Load AD Table.
  	EnableTables6420(1,0);               // Enable Ad Table.
  	ClearADFIFO6420();                   //Clear FIFO.
	
#endif
 
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T i;
  	short ADData;
	
#ifndef MATLAB_MEX_FILE

  	StartConversion6420();               // Start conversion.

  	for (i=0; i<num_channels; i++) {
  		while ( IsADFIFOEmpty6420());			// Wait until data is ready to read.
		ADData = ReadADData6420();              // Get data and convert it to voltages.
		y[i]= (double)ADData *  ssGetRWorkValue(S, GAIN_R_IND+i);
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

#ifndef MATLAB_MEX_FILE
	RTD_DM6420_init=0;
#endif

}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif


