/* $Revision: 1.3 $ $Date: 2002/03/25 04:06:17 $ */
/* dartddm64x0.c - xPC Target, non-inlined S-function driver for analog output section of RTD DM64x0 boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	dartddm64x0

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef 	MATLAB_MEX_FILE
#include 	<windows.h>
#include 	"io_xpcimport.h"
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS          (5)
#define CHANNEL_ARG            	ssGetSFcnParam(S,0)
#define RANGE_ARG            	ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG          	ssGetSFcnParam(S,2)
#define BASE_ARG            	ssGetSFcnParam(S,3)
#define BOARD_TYPE_ARG          ssGetSFcnParam(S,4)



#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (4)
#define BASE_I_IND				(0)
#define NCHANNELS_I_IND			(1)
#define RESINT_I_IND			(2)
#define DEV_ID_I_IND			(3)


#define NO_R_WORKS              (4)
#define GAIN_R_IND				(0)
#define OFFSET_R_IND			(2)

#define LSB_16					0.00030517578125


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

	int i;

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

#ifndef MATLAB_MEX_FILE


  	int_T 	nChannels, base, i, channel, range, counts; 
	real_T 	*RWork=ssGetRWork(S);
	int_T 	*IWork=ssGetIWork(S);
	real_T 	resFloat, value;
	
	base=(int_T)mxGetPr(BASE_ARG)[0];
	IWork[BASE_I_IND]=base;
  
    nChannels = mxGetN(CHANNEL_ARG);
	IWork[NCHANNELS_I_IND]=nChannels;

   	resFloat=4096.0;
	
    for (i=0;i<nChannels;i++) {
		channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
		range=100*mxGetPr(RANGE_ARG)[i];
		switch (range) {
			case -500:
				RWork[GAIN_R_IND+channel-1]=10.0/resFloat;
				RWork[OFFSET_R_IND+channel-1]=5.0;
				break;
			case 1000:
				RWork[GAIN_R_IND+channel-1]=10.0/resFloat;
				RWork[OFFSET_R_IND+channel-1]=0.0;
				break;
			case 500:
				RWork[GAIN_R_IND+channel-1]=5.0/resFloat;
				RWork[OFFSET_R_IND+channel-1]=0.0;
				break;
		}
					
	}

	switch ((uint16_T)mxGetPr(BOARD_TYPE_ARG)[0]) {
	case 1:
		value=0.0;
    	for (i=0;i<nChannels;i++) {
			channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
			counts=(value+RWork[OFFSET_R_IND+channel-1])/RWork[GAIN_R_IND+channel-1];
        	if (counts>4095) counts=4095;
        	if (counts<0)    counts=0;
			rl32eOutpW((unsigned short)(base+12+(channel-1)*2),(unsigned short)counts); 
   		}
		break;
	case 2:
		rl32eOutpW((unsigned short)(base+12),0x0000);
		break;
	}
		
#endif
	                 
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

  	int_T 				channel, base, i, counts;
	InputRealPtrsType 	uPtrs;
	real_T 				*RWork=ssGetRWork(S);
	int_T 				*IWork=ssGetIWork(S);
	real_T				value;
	int16_T				counts16;

  	base=IWork[BASE_I_IND];

	switch ((uint16_T)mxGetPr(BOARD_TYPE_ARG)[0]) {
	case 1:
	    for (i=0;i<IWork[NCHANNELS_I_IND];i++) {
			channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
			uPtrs=ssGetInputPortRealSignalPtrs(S,i);
			value=*uPtrs[0];
			counts=(value+RWork[OFFSET_R_IND+channel-1])/RWork[GAIN_R_IND+channel-1];
        	if (counts>4095) counts=4095;
        	if (counts<0)    counts=0;
			rl32eOutpW((unsigned short)(base+12+(channel-1)*2),(unsigned short)counts);
   		}
		break;
	case 2:
		uPtrs=ssGetInputPortRealSignalPtrs(S,0);
		value=*uPtrs[0]/LSB_16;
		if (value>32767.0) value=32767.0;
        if (value<-32768.0) value=-32768.0;
		counts16=(int16_T)value;
		rl32eOutpW((unsigned short)(base+12),counts16);
		break;
	}

#endif
        
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE

  	int_T 				channel, base, i, counts;
	real_T 				*RWork=ssGetRWork(S);
	int_T 				*IWork=ssGetIWork(S);
	real_T 				value;

  	base=IWork[BASE_I_IND];

	switch ((uint16_T)mxGetPr(BOARD_TYPE_ARG)[0]) {
	case 1:
	  	value=0.0;
    	for (i=0;i<IWork[NCHANNELS_I_IND];i++) {
			channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
			counts=(value+RWork[OFFSET_R_IND+channel-1])/RWork[GAIN_R_IND+channel-1];
        	if (counts>4095) counts=4095;
        	if (counts<0)    counts=0;
			rl32eOutpW((unsigned short)(base+12+(channel-1)*2),(unsigned short)counts);
   		}
		break;
	case 2:
		rl32eOutpW((unsigned short)(base+12),0x0000);
		break;
	}
		
#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


