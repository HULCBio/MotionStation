/* $Revision: 1.4 $ $Date: 2002/03/25 04:11:06 $ */
/* rs232_setup.c - xPC Target, non-inlined S-function driver for setup RS232 on motherboards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME rs232_setup

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include <string.h>
#include "rs232_xpcimport.h"
#endif

//#define TCPIP     99


/* Input Arguments */
#define NUMBER_OF_ARGS        	(9)
#define PORT_ARG             	ssGetSFcnParam(S,0)
#define BAUDRATE_ARG 	        ssGetSFcnParam(S,1)
#define DATABIT_ARG           	ssGetSFcnParam(S,2)
#define STOPBIT_ARG             ssGetSFcnParam(S,3)
#define PARITY_ARG 	            ssGetSFcnParam(S,4)
#define PROTOCOL_ARG           	ssGetSFcnParam(S,5)
#define SENDBUF_ARG           	ssGetSFcnParam(S,6)
#define RECBUF_ARG           	ssGetSFcnParam(S,7)
#define WAIT_ARG				ssGetSFcnParam(S,8)



#define NO_I_WORKS              	(0)

#define NO_R_WORKS              	(0)

static char_T msg[256];

extern int rs232ports[];
extern int rs232recbufs[];


static void mdlInitializeSizes(SimStruct *S)
{
        int_T num_channels, mux;

#ifndef MATLAB_MEX_FILE
#include "rs232_xpcimport.c"
#endif


#ifdef MATLAB_MEX_FILE
        ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
            sprintf(msg,"Wrong number of input arguments passed.\n9 arguments are expected\n");
            ssSetErrorStatus(S,msg);
            return;
        }
#endif

                
        /* Set-up size information */
        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);
        ssSetNumOutputs(S, 0);
        ssSetNumInputs(S, 0);
        ssSetDirectFeedThrough(S, 0); /* Direct dependency on inputs */
        ssSetNumSampleTimes(S,0);
        ssSetNumInputArgs(S, NUMBER_OF_ARGS);
        ssSetNumIWork(S, NO_I_WORKS); 
        ssSetNumRWork(S, NO_R_WORKS);
        ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
        ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
        ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
        ssSetOptions(          S, 0);   /* general options (SS_OPTION_xx)        */
        
}
 
/* Function to initialize sample times */
static void mdlInitializeSampleTimes(SimStruct *S)
{
        
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
		ssSetOffsetTime(S, 0, 0.0);

}
 

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{

#ifndef MATLAB_MEX_FILE


	int baudrates[]={115200,57600,38400,19200,9600,4800,2400,1200,300,110};
	int parities[]={0x100,0x200,0x400};
	int baudrate, parity, port;


	port=((int_T)mxGetPr(PORT_ARG)[0])-1;
	//if (port==PORT) {
	//	printf("        RS232 I/O-Error: choosen COM-port used for host<->target communication\n");
	//	return;
	//}
	baudrate=baudrates[((int_T)mxGetPr(BAUDRATE_ARG)[0])-1];
	//printf("%d\n",baudrate);
	parity=parities[((int_T)mxGetPr(PARITY_ARG)[0])-1];
	//printf("%d\n",parity);




   	rl32eInitCOMPort(	port,
				DefaultCOMIOBase[port],
				DefaultCOMIRQ[port],
				baudrate,
				parity,
				(int_T)mxGetPr(STOPBIT_ARG)[0],
				9-((int_T)mxGetPr(DATABIT_ARG)[0]),
				(int_T)mxGetPr(RECBUF_ARG)[0],
				(int_T)mxGetPr(SENDBUF_ARG)[0],
				((int_T)mxGetPr(PROTOCOL_ARG)[0])-1);

	rs232ports[port]=1;
	
    
#endif

                 
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	 
#endif
}

/* Function to compute model update */
static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}
 
/* Function to compute derivatives */
static void mdlDerivatives(real_T *dx, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}
 
/* Function to perform housekeeping at execution termination */
static void mdlTerminate(SimStruct *S)
{        
#ifndef MATLAB_MEX_FILE

		int port;

		port=((int_T)mxGetPr(PORT_ARG)[0])-1;

		rl32eCloseCOMPort(port);
		rs232ports[port]=0;

#endif


}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
