/* $Revision: 1.3 $ $Date: 2002/03/25 04:03:42 $ */
/* dirtddm64x0.c - xPC Target, non-inlined S-function driver for DIO section of RTD DM64x0 board  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	dirtddm64x0

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
#define NUMBER_OF_ARGS          (4)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define PORT_ARG				ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define BASE_ADDR_ARG           ssGetSFcnParam(S,3)

#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (1)
#define BASE_ADDR_I_IND			(0)

#define NO_R_WORKS              (0)

#define THRESHOLD              	0.5


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

	uint_T i;

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

	ssSetNumOutputPorts(S,mxGetN(CHANNEL_ARG));
	for (i=0; i<mxGetN(CHANNEL_ARG); i++) {
		ssSetOutputPortWidth(S, i, 1);
	}

    ssSetNumInputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

	for (i=0; i<NUMBER_OF_ARGS; i++) {
		ssSetSFcnParamNotTunable(S,i);
	}

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


  	uint16_T numChannels; 
	        
	uint16_T	BaseAddress;
	uint16_T i, j;
	uint16_T output, channel, port;         
	uchar_T tmp;

    BaseAddress = (uint16_T)mxGetPr(BASE_ADDR_ARG)[0]; 
	ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)BaseAddress);
	
    numChannels = (int16_T)mxGetN(CHANNEL_ARG);

	port = ((int16_T)mxGetPr(PORT_ARG)[0])-1;

	if (port==0) {
		
		// read port 1 direction
		tmp= rl32eInpB(BaseAddress+30) & 0x04;

		// select direction register
		rl32eOutpB(BaseAddress+30, tmp | 0x01);

		// write directions
		rl32eOutpB(BaseAddress+28, 0x00);

	} else if (port==1) {

		// read port 0 direction
		tmp= rl32eInpB(BaseAddress+30) & 0x03;

		// write direction
		rl32eOutpB(BaseAddress+30, tmp | 0x00);

	}

#endif
                 
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	uint16_T 	BaseAddress = (uint16_T)ssGetIWorkValue(S, BASE_ADDR_I_IND);
	int_T 		i;
	uchar_T 	channel, tmp; 
	real_T  	*y;
	int16_T 	port = ((int16_T)mxGetPr(PORT_ARG)[0])-1;

	
	tmp=rl32eInpB(BaseAddress+24+port*2);

	for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
		channel=(uchar_T)mxGetPr(CHANNEL_ARG)[i];
		y=ssGetOutputPortSignal(S,i);
		y[0]=(tmp & (1<<(channel-1))) >>(channel-1); 
	}
			
#endif
	
}

static void mdlTerminate(SimStruct *S)
{   
}




#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


