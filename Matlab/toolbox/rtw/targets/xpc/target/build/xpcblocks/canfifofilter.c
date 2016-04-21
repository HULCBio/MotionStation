/* $Revision: 1.4 $ $Date: 2002/03/25 04:02:54 $ */
/* canfifofilter.c - xPC Target, non-inlined S-function for CAN message filtering (FIFO mode)  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/


#define 	DEBUG 				0

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	canfifofilter

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


#define 	NUMBER_OF_ARGS    	(4)
#define 	PORT_ARG    		ssGetSFcnParam(S,0)
#define 	TYPE_ARG    		ssGetSFcnParam(S,1)
#define 	IDENT_ARG    		ssGetSFcnParam(S,2)
#define 	IDENTSEL_ARG    	ssGetSFcnParam(S,3)




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
	DECL_AND_INIT_DIMSINFO(iDimsInfo);
	int iDims[2];



	
    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

	ssSetNumInputPorts(S, 1);
	if (!ssSetInputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
	ssSetInputPortDirectFeedThrough(S, 0, 1);
	ssSetInputPortRequiredContiguous(S, 0, 1);

	iDimsInfo.width   = 6;
    iDimsInfo.numDims = 2;
    iDimsInfo.dims    = iDims;
    iDims[0] = 1;
    iDims[1] = 6;

	ssSetNumOutputPorts(S, 2);
	if (!ssSetOutputPortDimensionInfo(S, 0, &iDimsInfo)) return;
	ssSetOutputPortWidth(S, 1, 1);


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

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int portIndex, const DimsInfo_T *dimsInfo)
{

	if (dimsInfo->numDims != 2) {
		sprintf(msg,"Input must be a matrix signal");
        ssSetErrorStatus(S,msg);
		return;
	}

	if (dimsInfo->dims[1] != 6) {
		sprintf(msg,"Input must be a m*6 matrix");
        ssSetErrorStatus(S,msg);
		return;
	}


	if (!ssSetInputPortDimensionInfo(S, portIndex, dimsInfo)) return;
	
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int portIndex, const DimsInfo_T *dimsInfo)
{

	if (!ssSetOutputPortDimensionInfo(S, portIndex, dimsInfo)) return;

}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
	if (!ssSetInputPortVectorDimension(S, 0, 1)) return;
}

 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}
 
static void mdlOutputs(SimStruct *S, int_T tid)
{
	int_T  i,m, j, n, getThis, sel, counter=0;
	real_T *u, *y, *type, *port, *ident;

	m=ssGetInputPortWidth(S,0)/6;
	
	u= (real_T *) ssGetInputPortSignal(S,0);
	y= (real_T *) ssGetOutputPortSignal(S,0);

	port= (real_T *)mxGetPr(PORT_ARG);
	type= (real_T *)mxGetPr(TYPE_ARG);
	ident=(real_T *)mxGetPr(IDENT_ARG);

	n= mxGetM(IDENT_ARG) * mxGetN(IDENT_ARG);
	sel= (int_T)mxGetPr(IDENTSEL_ARG)[0];


	for (i=0; i<m; i++) {
		if ( (int_T)port[((int_T)u[i+m*0])-1] && (int_T)type[((int_T)u[i+m*2])] ) {

			int_T typein= (int_T)u[i+m*2];
			int_T identin= (uint32_T)u[i+m*1];

			if (typein!=0 && typein!=5 && typein!=15) {


				if (!sel) {	/* include */
					getThis=0;
					for (j=0;j<n;j++) {
						if (identin==ident[j]) {
							getThis=1;
						}
					}
				} else { /* exclude */
					getThis=1;
					for (j=0;j<n;j++) {
						if (identin==ident[j]) {
							getThis=0;
						}
					}
				}
				if (getThis) {
					y[0]=u[i+m*0];
					y[1]=u[i+m*1];
					y[2]=u[i+m*2];
					y[3]=u[i+m*3];
					y[4]=u[i+m*4];
					y[5]=u[i+m*5];  
					counter++;
				}

			} else {
					if (typein==0) {
						y[0]= 0.0;
					} else {
						y[0]=u[i+m*0];
					}
					if (typein==0) {
						y[1]=-1.0;
					} else {
						y[1]=u[i+m*1];
					}
					y[2]=u[i+m*2];
					y[3]=0.0;
					if (typein==0) {
						y[4]= 0.0;
					} else {
						y[4]=u[i+m*5];
					}
					y[5]=0.0;  
					counter++;
			}

		}
	}

	y= (real_T *) ssGetOutputPortSignal(S,1);
	y[0]= (real_T)counter;

}
 
static void mdlTerminate(SimStruct *S)
{
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif