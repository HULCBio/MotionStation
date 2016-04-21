/* $Revision: 1.7.6.1 $ $Date: 2004/04/08 21:01:41 $*/
/* canac2pcisend.c - xPC Target, non-inlined S-function driver for CAN-AC2-PCI from Softing (single board)  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/


#define 	DEBUG 				0

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	canac2104send

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


#define 	NUMBER_OF_ARGS    	(7)
#define 	CAN_PORT_ARG       	ssGetSFcnParam(S,0)
#define 	CAN_ID_ARG         	ssGetSFcnParam(S,1)
#define 	CAN_INDEX_ARG       ssGetSFcnParam(S,2)
#define 	OUTPUT_ARG			ssGetSFcnParam(S,3)
#define 	SAMP_TIME_ARG       ssGetSFcnParam(S,4)
#define 	CAN_SIZE_ARG    	ssGetSFcnParam(S,5)
#define 	BOARD_ARG    		ssGetSFcnParam(S,6)


#define 	NO_I_WORKS          (0)
#define 	NO_R_WORKS          (0)

static char_T msg[256];


#ifndef MATLAB_MEX_FILE
unsigned char get_double_byte(double value, int n);

static unsigned char get_double_byte(double value, int n)
{
    unsigned char *p;
        
    p = (unsigned char *) &value;
    return p[n];
}
#endif



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

	ssSetNumInputPorts(S, mxGetN(CAN_ID_ARG));
	for (i=0;i<mxGetN(CAN_ID_ARG);i++) {
		ssSetInputPortWidth(S, i, 1);
    	ssSetInputPortDirectFeedThrough(S, i, 1);
	}

	if ((int_T)mxGetPr(OUTPUT_ARG)[0]) {
		ssSetNumOutputPorts(S, mxGetN(CAN_ID_ARG));	
		for (i=0;i<mxGetN(CAN_ID_ARG);i++) {
			ssSetOutputPortWidth(S, i, 1);
		}
	} else {
		ssSetNumOutputPorts(S, 0);
	}

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
 
static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	int_T 			index, frc, i, j;
	unsigned char 	p_data[8];
	InputRealPtrsType uPtrs;
	real_T  		*y;

	if (((int_T)mxGetPr(CAN_PORT_ARG)[0])==1) {		// CAN 1
    	for (i=0;i<mxGetN(CAN_INDEX_ARG);i++) {
           	index=(int_T)mxGetPr(CAN_INDEX_ARG)[i];
           	uPtrs=ssGetInputPortRealSignalPtrs(S,i);
			for(j=0; j<(int_T)mxGetPr(CAN_SIZE_ARG)[i]; j++) {
    			p_data[j]=get_double_byte(*uPtrs[0], j);
    		}
    		_asm{pushf
    		    cli};     
			switch ((int_T)mxGetPr(BOARD_ARG)[0]) {
			case 1:
				frc = CANPC_write_object_mb1(index, (int_T)mxGetPr(CAN_SIZE_ARG)[i], p_data);		
				break;
			case 2:
				frc = CANPC_write_object_mb2(index, (int_T)mxGetPr(CAN_SIZE_ARG)[i], p_data);
				break;
			case 3:
				frc = CANPC_write_object_mb3(index, (int_T)mxGetPr(CAN_SIZE_ARG)[i], p_data);
				break;
			}
			_asm{popf};
			if ((int_T)mxGetPr(OUTPUT_ARG)[0]) {
				y=ssGetOutputPortSignal(S,i);
				y[0]=(double)frc;
			}
		}
	} else {
    	for (i=0;i<mxGetN(CAN_INDEX_ARG);i++) {
           	index=(int_T)mxGetPr(CAN_INDEX_ARG)[i];
           	uPtrs=ssGetInputPortRealSignalPtrs(S,i);
			for(j=0; j<(int_T)mxGetPr(CAN_SIZE_ARG)[i]; j++) {
    			p_data[j]=get_double_byte(*uPtrs[0], j);
    		}   
			_asm{pushf
    		    cli};  
			switch ((int_T)mxGetPr(BOARD_ARG)[0]) {
			case 1:
				frc = CANPC_write_object2_mb1(index, (int_T)mxGetPr(CAN_SIZE_ARG)[i], p_data);		
				break;
			case 2:
				frc = CANPC_write_object2_mb2(index, (int_T)mxGetPr(CAN_SIZE_ARG)[i], p_data);
				break;
			case 3:
				frc = CANPC_write_object2_mb3(index, (int_T)mxGetPr(CAN_SIZE_ARG)[i], p_data);
				break;
			}
			_asm{popf};
			if ((int_T)mxGetPr(OUTPUT_ARG)[0]) {
				y=ssGetOutputPortSignal(S,i);
				y[0]=(double)frc;
			}
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
