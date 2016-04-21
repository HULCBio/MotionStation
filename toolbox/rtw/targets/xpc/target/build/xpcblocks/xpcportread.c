/* $Revision: 1.6 $ $Date: 2002/03/25 03:57:35 $ */
/* xpcportread.c - xPC Target, non-inlined S-function driver for I/O-port access */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

//#define debug

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	xpcportread

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
#define NUMBER_OF_ARGS          (3)
#define PORT_ARG            	ssGetSFcnParam(S,0)
#define DTYPE_ARG            	ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG          	ssGetSFcnParam(S,2)


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)            

#define NO_I_WORKS              (0)

#define NO_R_WORKS              (0)


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

	ssSetNumOutputPorts(S, mxGetN(PORT_ARG));
	for (i=0;i<mxGetN(PORT_ARG);i++) {
		ssSetOutputPortWidth(S, i, DYNAMICALLY_SIZED);
    	ssSetOutputPortDataType(S, i, mxGetPr(DTYPE_ARG)[i]);
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
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int portIndex, int inWidth)
{
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int portIndex, int outWidth)
{
    ssSetOutputPortWidth(S, portIndex, outWidth);
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
	int port;

	for (port=0; port < ssGetNumOutputPorts(S); port++) {
		switch (ssGetOutputPortDataType( S, port)) {
			case SS_INT8:
    		case SS_UINT8:
			case SS_INT16:
      		case SS_UINT16:
			case SS_INT32:
      		case SS_UINT32:
        	break;
      		default:
        	ssSetErrorStatus(S, "Output signal(s) must be one of the types: "
                         "int8, uint8, int16, uint16, int32, uint32.\n" 
                         "Suggest using a data type conversion block "
                         "after the output." );
     
    	}
	}
}


static void mdlOutputs(SimStruct *S, int_T tid)
{

	void 			*yVoid;
    int 			port, i;
	int 			address;

	for (port=0;port<mxGetN(PORT_ARG);port++) {

    	yVoid= ssGetOutputPortSignal(S,port);
	
		address=(int)mxGetPr(PORT_ARG)[port];

    	switch (ssGetOutputPortDataType(S,port)) {
      		case SS_INT8: {
				  int8_T *y = yVoid;
#ifdef debug
				  printf("data type of port %d is int8\n", port);
#endif	
#ifndef MATLAB_MEX_FILE
				  for (i=0; i<ssGetOutputPortWidth(S,port); i++) {
					y[i]= rl32eInpB((unsigned short)address);
				  }
#endif
			}
			break;
      		case SS_UINT8: {
				  uint8_T *y = yVoid;
#ifdef debug
				  printf("data type of port %d is uint8\n", port);
#endif	
#ifndef MATLAB_MEX_FILE
				  for (i=0; i<ssGetOutputPortWidth(S,port); i++) {
					y[i]= rl32eInpB((unsigned short)address);
				  }
#endif
			}
			break;
      		case SS_INT16: {
				  int16_T *y = yVoid;
#ifdef debug
				  printf("data type of port %d is int16\n", port);
#endif	
#ifndef MATLAB_MEX_FILE
				  for (i=0; i<ssGetOutputPortWidth(S,port); i++) {
					y[i]= rl32eInpW((unsigned short)address);
				  }
#endif
			}
			break;
      		case SS_UINT16: {
				  uint16_T *y = yVoid;
#ifdef debug
				  printf("data type of port %d is uint16\n", port);
#endif	
#ifndef MATLAB_MEX_FILE
				  for (i=0; i<ssGetOutputPortWidth(S,port); i++) {
					y[i]= rl32eInpW((unsigned short)address);
				  }
#endif
			}
			break;
      		case SS_INT32: {
				  int32_T *y = yVoid;
#ifdef debug
				  printf("data type of port %d is int32\n", port);
#endif	
#ifndef MATLAB_MEX_FILE
				  for (i=0; i<ssGetOutputPortWidth(S,port); i++) {
					y[i]= rl32eInpDW((unsigned short)address);
				  }
#endif
			}
			break;
      		case SS_UINT32: {
				  uint32_T *y = yVoid;
#ifdef debug
				  printf("data type of port %d is uint32\n", port);
#endif	
#ifndef MATLAB_MEX_FILE
				  for (i=0; i<ssGetOutputPortWidth(S,port); i++) {
					y[i]= rl32eInpDW((unsigned short)address);
				  }
#endif
			}
			break;
		}

	}

        
}

static void mdlTerminate(SimStruct *S)
{   

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


