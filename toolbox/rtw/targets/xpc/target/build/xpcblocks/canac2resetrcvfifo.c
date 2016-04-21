/* $Revision: 1.4.6.1 $ $Date: 2004/04/08 21:01:49 $*/
/* canac2resetrcvfifo.c - xPC Target, non-inlined S-function driver for CAN-AC2 from Softing (FIFO Mode)  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define 	DEBUG 				0

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	canac2resetrcvfifo

#include 	<stddef.h>
#include 	<stdlib.h>


#ifndef 	MATLAB_MEX_FILE
#include 	"can_def.h"
#include 	"canlay2_mb1.h" 
#include 	"canlay2_mb2.h"
#include 	"canlay2_mb3.h"

#endif

#include 	"tmwtypes.h"
#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif


#define 	NUMBER_OF_ARGS    	(2)
#define 	BOARD_ARG    		ssGetSFcnParam(S,0)
#define 	SAMP_TIME_ARG       ssGetSFcnParam(S,1)


#define 	NO_I_WORKS          (1)
#define 	NO_R_WORKS          (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

	int_T i;

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

	ssSetNumInputPorts(S, 1);
	ssSetInputPortWidth(S, 0, 1);
	ssSetInputPortDirectFeedThrough(S, 0, 1);
	ssSetInputPortRequiredContiguous(S, 0, 1);


	ssSetNumOutputPorts(S, 0);
	
    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

	for (i=0;i<NUMBER_OF_ARGS;i++) {
		ssSetSFcnParamNotTunable(S,i);
	}

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

#define MDL_START
static void mdlStart(SimStruct *S)
{

	ssSetIWorkValue(S,0,0);

}

 
static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	real_T  		*u;
	int_T			frc;

	u= (real_T *) ssGetInputPortSignal(S,0);

	if (u[0] >= 0.5) {

		if (ssGetIWorkValue(S,0)==0) {
			_asm{pushf
    			cli}; 
			switch ((int_T)mxGetPr(BOARD_ARG)[0]) {
			case 1:
				frc = CANPC_reset_rcv_fifo_mb1();		
				frc = CANPC_reset_lost_msg_counter_mb1();
				break;
			case 2:
				frc = CANPC_reset_rcv_fifo_mb2();	
				frc = CANPC_reset_lost_msg_counter_mb2();
				break;
			case 3:
				frc = CANPC_reset_rcv_fifo_mb3();	
				frc = CANPC_reset_lost_msg_counter_mb3();
				break;
			}
			_asm{popf};
			ssSetIWorkValue(S,0,1);

		}

	} else {

		ssSetIWorkValue(S,0,0);	

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