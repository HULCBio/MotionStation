/* $Revision: 1.7 $ $Date: 2002/03/25 04:06:20 $ */
/* dartddm6604.c - xPC Target, non-inlined S-function driver for analog output section of Real Time Devices DM6604 board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	dartddm6604

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

#define NUMBER_OF_ARGS        	(4)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RANGE_ARG               ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define BASE_ADDR_ARG           ssGetSFcnParam(S,3)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)
								
#define NO_I_WORKS              (2)
#define CHANNEL_I_IND  			(0)
#define BASE_ADDR_I_IND         (1)

#define NO_R_WORKS              (16)

#define MAX_CHANNELS            (8)

#define RES_INT					4095
#define RES_FLOAT				4096.0


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int_T num_channels, i;

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

	ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
	for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
		ssSetInputPortWidth(S, i, 1);
		ssSetInputPortDirectFeedThrough(S, i, 1);
	}

    ssSetNumOutputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

	ssSetSFcnParamNotTunable(S,0);
	ssSetSFcnParamNotTunable(S,1);
	ssSetSFcnParamNotTunable(S,2);
	ssSetSFcnParamNotTunable(S,3);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
       
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}
 

#define MDL_START
static void mdlStart(SimStruct *S)
{
    uint_T base_addr;
    int_T num_channels, channel;
    real_T *RWork=ssGetRWork(S);
    int_T i, range, counts;
    real_T value;
         
    num_channels = mxGetN(CHANNEL_ARG);
    ssSetIWorkValue(S,CHANNEL_I_IND , num_channels);

    base_addr = (unsigned int) mxGetPr(BASE_ADDR_ARG)[0];
    ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);

    for (i=0;i<num_channels;i++) {
		channel=(int_T)mxGetPr(CHANNEL_ARG)[i]-1;
		range=(int_T)mxGetPr(RANGE_ARG)[i];
        if (range==-10) {
            RWork[2*channel]=20.0/RES_FLOAT;
            RWork[2*channel+1]=10.0;
        } else if (range==-5) {
            RWork[2*channel]=10.0/RES_FLOAT;
            RWork[2*channel+1]=5.0;
        } else if (range==10) {
            RWork[2*channel]=10.0/RES_FLOAT;
            RWork[2*channel+1]=0.0;
        } else if (range==5) {
            RWork[2*channel]=5.0/RES_FLOAT;
            RWork[2*channel+1]=0.0;
        }
  	}

#ifndef MATLAB_MEX_FILE

    for (i=0;i<num_channels;i++) {
		channel=(int_T)(mxGetPr(CHANNEL_ARG)[i])-1;
        value=0.0;
		counts=(value+RWork[i*2+1])/RWork[i*2];
        if (counts>RES_INT)	counts=RES_INT;
        if (counts<0)    	counts=0;
        rl32eOutpW((unsigned short)(base_addr+4+i*2),(unsigned short)counts);
    }
    rl32eOutpB((unsigned short)(base_addr+20),0x0);  

#endif
       
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
   	uint_T 	base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T 	num_channels = ssGetIWorkValue(S, CHANNEL_I_IND);
	int_T 	i;
    real_T 	*RWork=ssGetRWork(S);
    int_T 	counts, channel;
    real_T 	value;
	InputRealPtrsType uPtrs;

#ifndef MATLAB_MEX_FILE

    for (i=0;i<num_channels;i++) {
		channel=(int_T)(mxGetPr(CHANNEL_ARG)[i])-1;
		uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        value=*uPtrs[0];
		counts=(value+RWork[channel*2+1])/RWork[channel*2];
        if (counts>RES_INT)	counts=RES_INT;
        if (counts<0)    	counts=0;
        rl32eOutpW((unsigned short)(base_addr+4+channel*2),(unsigned short)counts);
    }
    rl32eOutpB((unsigned short)(base_addr+20),0x0);  
	
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
    int_T num_channels = ssGetIWorkValue(S, CHANNEL_I_IND);
    real_T *RWork=ssGetRWork(S);
    int_T i, counts, channel;
    real_T value;
        
#ifndef MATLAB_MEX_FILE

    for (i=0;i<num_channels;i++) {
		channel=(int_T)(mxGetPr(CHANNEL_ARG)[i])-1;
        value=0.0;
		counts=(value+RWork[i*2+1])/RWork[i*2];
        if (counts>RES_INT)	counts=RES_INT;
        if (counts<0)    	counts=0;
        rl32eOutpW((unsigned short)(base_addr+4+i*2),(unsigned short)counts);
    }
    rl32eOutpB((unsigned short)(base_addr+20),0x0);  

#endif

       

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif





