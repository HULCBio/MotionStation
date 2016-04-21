/* $Revision: 1.4 $ $Date: 2002/03/25 04:02:00 $*/
/* canac2pcisend.c - xPC Target, non-inlined S-function driver for CAN-AC2-PCI from Softing (single board)  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	DEBUG 				0

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	canac2isaereceive

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


#define 	NUMBER_OF_ARGS    	(6)
#define 	CAN_PORT_ARG       	ssGetSFcnParam(S,0)
#define 	CAN_ID_ARG         	ssGetSFcnParam(S,1)
#define 	CAN_INDEX_ARG       ssGetSFcnParam(S,2)
#define 	OUTPUT_ARG      	ssGetSFcnParam(S,3)
#define 	SAMP_TIME_ARG       ssGetSFcnParam(S,4)
#define 	BOARD_ARG    		ssGetSFcnParam(S,5)


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

	ssSetNumOutputPorts(S, mxGetN(CAN_ID_ARG));
	for (i=0;i<mxGetN(CAN_ID_ARG);i++) {
		switch ((int_T)mxGetPr(OUTPUT_ARG)[0]) {
		case 1:
			ssSetOutputPortWidth(S, i, 1);
			break;
		case 2:
		case 3:
			ssSetOutputPortWidth(S, i, 2);	 
			break;
		case 4:
			ssSetOutputPortWidth(S, i, 3);
			break;
		}
	}

    ssSetNumInputPorts(S, 0);

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
	real_T  		*y;
	unsigned long	time;
	real_T			*value;

	if (((int_T)mxGetPr(CAN_PORT_ARG)[0])==1) {		// CAN 1
    	for (i=0;i<mxGetN(CAN_INDEX_ARG);i++) {
           	index=(int_T)mxGetPr(CAN_INDEX_ARG)[i];
           	y=ssGetOutputPortSignal(S,i);
			frc = CANPC_read_rcv_data(index, p_data, &time);		
			if (frc>-2) {
				value=(double *) &p_data[0];
				y[0]=*value;			
			} 
			switch ((int_T)mxGetPr(OUTPUT_ARG)[0]) {
			case 2:
				y[1]=(double)frc;
				break;
			case 3:
				y[1]=1.0e-6*(real_T)time;
				break;
			case 4:
				y[1]=(double)frc;
				y[2]=1.0e-6*(real_T)time;
				break;
			}
		}
	} else {
    	for (i=0;i<mxGetN(CAN_INDEX_ARG);i++) {
           	index=(int_T)mxGetPr(CAN_INDEX_ARG)[i];
           	y=ssGetOutputPortSignal(S,i);
			frc = CANPC_read_rcv_data2(index, p_data, &time);		
			if (frc>-2) {
				value=(double *) &p_data[0];
				y[0]=*value;			
			} 
			switch ((int_T)mxGetPr(OUTPUT_ARG)[0]) {
			case 2:
				y[1]=(double)frc;
				break;
			case 3:
				y[1]=1.0e-6*(real_T)time;
				break;
			case 4:
				y[1]=(double)frc;
				y[2]=1.0e-6*(real_T)time;
				break;
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