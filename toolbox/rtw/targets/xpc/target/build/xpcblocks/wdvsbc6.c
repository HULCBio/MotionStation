/* $Revision: 1.6 $ $Date: 2002/03/25 04:11:45 $*/
/* wdvsbc6.c - xPC Target, non-inlined S-function driver for VSBC-6 Watchdog (Versalogic) */
/* Copyright 1996-2002 The MathWorks, Inc.
*/


#define 	S_FUNCTION_LEVEL 	2
#define 	S_FUNCTION_NAME  	wdvsbc6

#include 	"simstruc.h"
#include 	"tmwtypes.h"

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"io_xpcimport.h"
#endif

#define 	NUMBER_OF_ARGS   	(3)
#define 	SHOW_ENABLE_ARG	    ssGetSFcnParam(S,0)
#define 	SHOW_RESET_ARG 	    ssGetSFcnParam(S,1)
#define 	SAMP_TIME_ARG       ssGetSFcnParam(S,2)

#define 	NO_I_WORKS          (4)
#define 	ENABLE_I_IND        (0)
#define 	ENABLESTATE_I_IND   (1)
#define 	RESET_I_IND         (2)
#define 	RESETSTATE_I_IND   	(3)

#define 	NO_R_WORKS          (0)

#define		wdENABLE			0xe0
#define		wdREFRESH			0xe1




static char_T msg[256];


static void mdlInitializeSizes(SimStruct *S)
{

	int_T i, num_inpports;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

	
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

	ssSetNumOutputPorts(S, 0);

	num_inpports=0;
	if ((int_T)mxGetPr(SHOW_ENABLE_ARG)[0]) {
		num_inpports++;
	}
	if ((int_T)mxGetPr(SHOW_RESET_ARG)[0]) {
		num_inpports++;
	}
    ssSetNumInputPorts(S, num_inpports);
	for (i=0;i<num_inpports;i++) {
	     ssSetInputPortWidth(S, i, 1);
             ssSetInputPortDirectFeedThrough(S,i,1);
	}										
	
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
    ssSetOffsetTime(S, 0, 0.0);

}


#define MDL_START 
static void mdlStart(SimStruct *S)
{
	int_T wdEnable, wdReset, tmp;

	wdEnable= (int_T)mxGetPr(SHOW_ENABLE_ARG)[0];
	ssSetIWorkValue(S,ENABLE_I_IND , wdEnable);
	ssSetIWorkValue(S,ENABLESTATE_I_IND , 0);
	wdReset= (int_T)mxGetPr(SHOW_RESET_ARG)[0];
	ssSetIWorkValue(S,RESET_I_IND , wdReset);
	ssSetIWorkValue(S,RESETSTATE_I_IND , 0);

#ifndef MATLAB_MEX_FILE

	// reset WD
	tmp=rl32eInpB(wdENABLE);
	rl32eOutpB((unsigned short)wdENABLE,(unsigned short)(tmp & 0xfe));

	if (!wdEnable) {
		tmp=rl32eInpB(wdENABLE);
		rl32eOutpB((unsigned short)wdENABLE,(unsigned short)(tmp | 0x01));
	}	


#endif
		
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
        
#ifndef MATLAB_MEX_FILE

    int_T 	wdEnable 		= ssGetIWorkValue(S, ENABLE_I_IND);
    int_T 	wdEnableState 	= ssGetIWorkValue(S, ENABLESTATE_I_IND);
    int_T 	wdReset 		= ssGetIWorkValue(S, RESET_I_IND);
    int_T 	wdResetState 	= ssGetIWorkValue(S, RESETSTATE_I_IND);
	InputRealPtrsType uPtrs;
	int_T	tmp;

	if (wdEnable) {
		uPtrs=ssGetInputPortRealSignalPtrs(S,0);
		if ((int_T)*uPtrs[0] != wdEnableState) {
			if ((int_T)*uPtrs[0]) {
				// enable WD
				tmp=rl32eInpB(wdENABLE);
				rl32eOutpB((unsigned short)wdENABLE,(unsigned short)(tmp | 0x01));
				wdEnableState=1;
			} else {
				// disable WD
				tmp=rl32eInpB(wdENABLE);
				rl32eOutpB((unsigned short)wdENABLE,(unsigned short)(tmp & 0xfe));
				wdEnableState=0;
			}
		}
	}

	if (wdReset) {
		if (wdEnable) {
			uPtrs=ssGetInputPortRealSignalPtrs(S,1);
		} else {
			wdEnableState=1;
			uPtrs=ssGetInputPortRealSignalPtrs(S,0);
		}
		if ((int_T)*uPtrs[0] && wdEnableState) {
			wdResetState=1;
		}
	}

	if (!wdResetState) {
		// refresh WD
		rl32eOutpB(wdREFRESH, 0x5a);
	}

	ssSetIWorkValue(S,ENABLESTATE_I_IND , wdEnableState);
	ssSetIWorkValue(S,RESETSTATE_I_IND , wdResetState);

#endif

}


static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

  	int_T tmp;

	tmp=rl32eInpB(wdENABLE);
	rl32eOutpB((unsigned short)wdENABLE,(unsigned short)(tmp & 0xfe));

#endif

}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
