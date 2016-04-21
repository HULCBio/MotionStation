/* $Revision: 1.5 $ $Date: 2002/03/25 04:03:54 $ */
/* divsbc6.c - xPC Target, non-inlined S-function driver for digital I/O section of VSBC-6 SBC from Versalogic  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME divsbc6

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

#define 	NUMBER_OF_ARGS        	(2)
#define 	CHANNEL_ARG         	ssGetSFcnParam(S,0)
#define 	SAMP_TIME_ARG          	ssGetSFcnParam(S,1)

#define 	SAMP_TIME_IND           (0)

#define 	NO_I_WORKS             	(0)

#define 	NO_R_WORKS              (0)

#define 	DCAS					0xe2
#define		DIOHI					0xe7
#define		DIOLO					0xe6

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

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
        
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{    
   	ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    if (mxGetN((SAMP_TIME_ARG))==1) {
			ssSetOffsetTime(S, 0, 0.0);
		} else {
        	ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
		}

}

#define MDL_START 
static void mdlStart(SimStruct *S)
{


#ifndef MATLAB_MEX_FILE

	int_T channel, tmp, i;

    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
	
		channel=(int_T)mxGetPr(CHANNEL_ARG)[i];

		tmp=rl32eInpB(DCAS);
	
		if (channel<9) {
			rl32eOutpB((unsigned short)DCAS, (unsigned short)(tmp & 0xfe));
		} else {
			rl32eOutpB((unsigned short)DCAS, (unsigned short)(tmp & 0xfd));
		}

	}

#endif


}	

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	int_T 			i, inputLO, inputHI;
	int_T			channel;
	real_T  		*y;

	inputLO=rl32eInpB(DIOLO);
	inputHI=rl32eInpB(DIOHI);

	for (i=0; i<mxGetN(CHANNEL_ARG); i++) {
		y=ssGetOutputPortSignal(S,i);
    	if ((int_T)mxGetPr(CHANNEL_ARG)[i] < 9) {
			channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
			y[0]=(inputLO & (1<<(channel-1))) >>(channel-1);
		} else {
			channel=(int_T)mxGetPr(CHANNEL_ARG)[i]-8;
			y[0]=(inputHI & (1<<(channel-1))) >>(channel-1);
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

