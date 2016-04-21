/* $Revision: 1.4 $ $Date: 2002/03/25 04:01:42 $ */
/* canac2104send_mb3.c - xPC Target, non-inlined S-function driver for CAN-AC2-104 from Softing (multi board)  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/


#define 	DEBUG 				0

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	canac2104send_mb3

#include 	<stddef.h>
#include 	<stdlib.h>


#ifndef 	MATLAB_MEX_FILE
#include 	"can_def_mb3.h"
#include 	"canlay2_mb3.h" 
#endif

#include 	"tmwtypes.h"
#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif


#define 	NUMBER_OF_ARGS    	(4)
#define 	CAN_PORT_ARG       	ssGetSFcnParam(S,0)
#define 	CAN_ID_ARG         	ssGetSFcnParam(S,1)
#define 	CAN_INDEX_ARG       ssGetSFcnParam(S,2)
#define 	SAMP_TIME_ARG       ssGetSFcnParam(S,3)

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

	if (((int_T)mxGetPr(CAN_PORT_ARG)[0])==1) {		// CAN 1
    	for (i=0;i<mxGetN(CAN_INDEX_ARG);i++) {
           	index=(int_T)mxGetPr(CAN_INDEX_ARG)[i];
           	uPtrs=ssGetInputPortRealSignalPtrs(S,i);
			for(j=0; j<sizeof(double); j++) {
    			p_data[j]=get_double_byte(*uPtrs[0], j);
    		}   
    		frc = CANPC_write_object_mb3(index, 8, p_data);
			if (frc) {
				printf("ERROR:  CANPC_write_object_mb3 for CAN 1: %d\n",frc);
				return;
			} 
		}
	} else {
    	for (i=0;i<mxGetN(CAN_INDEX_ARG);i++) {
           	index=(int_T)mxGetPr(CAN_INDEX_ARG)[i];
           	uPtrs=ssGetInputPortRealSignalPtrs(S,i);
			for(j=0; j<sizeof(double); j++) {
    			p_data[j]=get_double_byte(*uPtrs[0], j);
    		}   
    		frc = CANPC_write_object2_mb3(index, 8, p_data);
			if (frc) {
				printf("ERROR:  CANPC_write_object_mb3 for CAN 2: %d\n",frc);
				return;
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
