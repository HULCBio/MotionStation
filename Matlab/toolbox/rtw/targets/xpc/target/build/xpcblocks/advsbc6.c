/* $Revision: 1.7 $ $Date: 2002/03/25 04:00:22 $ */
/* divsbc6.c - xPC Target, non-inlined S-function driver for analog input section of VSBC-6 SBC from Versalogic  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	advsbc6

#include 	<stddef.h>
#include 	<stdlib.h>
#include 	<string.h>

#include 	"tmwtypes.h"
#include 	"simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"io_xpcimport.h"
#endif

#define 	NUMBER_OF_ARGS      (3)
#define 	CHANNEL_ARG         ssGetSFcnParam(S,0)
#define 	RANGE_ARG           ssGetSFcnParam(S,1)
#define 	SAMP_TIME_ARG       ssGetSFcnParam(S,2)

#define 	NO_I_WORKS          (0)
								
#define 	NO_R_WORKS         	(0)

#define 	ACR   				0xe4
#define 	DCAS  				0xe2
#define 	ADC   				0xe4

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

	int_T i;

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

	ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
	for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
		ssSetOutputPortWidth(S, i, 1);
	}

  	ssSetNumInputPorts(S, 0);

  	ssSetNumSampleTimes(S, 1);

  	ssSetNumRWork(S, NO_R_WORKS);
  	ssSetNumIWork(S, NO_I_WORKS);
  	ssSetNumPWork(S, 0);

  	ssSetNumModes(S, 0);
  	ssSetNumNonsampledZCs(S, 0);

  	ssSetSFcnParamNotTunable(S,0);
  	ssSetSFcnParamNotTunable(S,1);
  	ssSetSFcnParamNotTunable(S,2);

  	ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
        
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
    if (mxGetN((SAMP_TIME_ARG))==1) {
		ssSetOffsetTime(S, 0, 0.0);
	} else {
       	ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
	}
}

static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE
	
	uint_T myTimeout;
	short  adParameters = 0;
  	int    loopCount = 0;

 	/* Check that the hardware is functioning */

  	rl32eOutpB(ACR, 0x08);
 
  	while (((rl32eInpB(DCAS) & 0x4)==0)&&(loopCount<100)) {
    	loopCount++; 
  	}
  	if (loopCount>=100) {
    	sprintf(msg,"A/D conversion timeout occured. Check hardware.");
    	ssSetErrorStatus(S,msg);
  	}
#endif /* MATLAB_MEX_FILE */ 

}   

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	unsigned short	advalu;
	short			advals;
	int 			i;
	real_T  	*y;

	for (i=0; i<mxGetN(CHANNEL_ARG); i++) {
		y=ssGetOutputPortSignal(S,i);
		switch ((int)mxGetPr(RANGE_ARG)[i]) {
			case -10:
				rl32eOutpB((unsigned short)ACR, (unsigned short)(0x18 | (int)mxGetPr(CHANNEL_ARG)[i]-1));
				while ((rl32eInpB(DCAS) & 0x4)==0);
				advals= rl32eInpW(ADC);
				y[0]= advals * 20.0/4096.0;
				break;
			case -5:
        		rl32eOutpB((unsigned short)ACR, (unsigned short)(0x08 | (int)mxGetPr(CHANNEL_ARG)[i]-1));
        		while ((rl32eInpB(DCAS) & 0x4)==0); 
				advals= rl32eInpW(ADC);
				y[0]= advals * 10.0/4096.0;
				break;
			case 10:
				rl32eOutpB((unsigned short)ACR, (unsigned short)(0x10 | (int)mxGetPr(CHANNEL_ARG)[i]-1));
				while ((rl32eInpB(DCAS) & 0x4)==0);
				advalu= rl32eInpW(ADC);
				y[0]= advalu * 10.0/4096.0;
				break;
			 case 5:
				rl32eOutpB((unsigned short)ACR, (unsigned short)(0x00 | (int)mxGetPr(CHANNEL_ARG)[i]-1));
			 	while ((rl32eInpB(DCAS) & 0x4)==0);
				advalu= rl32eInpW(ADC);
				y[0]= advalu * 5.0/4096.0;
				break;
		}
	}

#endif
        
}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

