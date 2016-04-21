/* $Revision: 1.4 $ $Date: 2002/03/25 04:11:00 $ */
/* rs232_send.c - xPC Target, non-inlined S-function driver for RS232 send (asynchronious) on motherboards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME rs232_send

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


/* Input Arguments */
#define NUMBER_OF_ARGS        	(4)
#define PORT_ARG				ssGetSFcnParam(S,0)
#define FORMAT_SEND_ARG        	ssGetSFcnParam(S,1)
#define WAIT_ARG        		ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,3)


#define NO_I_WORKS              	(0)

#define NO_R_WORKS              	(0)

#define NO_P_WORKS              	(3)

#define tmpsize						128


static char_T msg[256];

extern int rs232ports[];


static int datacount(char *formatstring)
{

	int i,n;

	n=0;
	for (i=0;i<strlen(formatstring);i++) {
		if (formatstring[i]=='%') n++;
	}
	return(n);
}

#ifndef MATLAB_MEX_FILE
	
static void build(char *formatstring,double *data, int port)
{

	int i, fi, j, found, k;
	char tmp[tmpsize];
	char token[tmpsize];

	i=0;
	fi=0;
	while (fi<strlen(formatstring)) {
   		if (formatstring[fi]=='%') {
      		// search format token
	      	found=0;
	      	j=fi;
			k=0;
	      	while (!found) {
	        	switch (formatstring[j]) {
	         		case 'x':
						//printf("%s %d\n",formatstring+fi,k+1);
					    strncpy(token,formatstring+fi,k+1);
						token[k+1]='\0';
						//printf("%s\n",token);
						sprintf(tmp,token,(int)data[i]);
					    rl32eSendBlock(port,(void *) tmp, strlen(tmp));
	            		found=1;
						break;
					case 'd':
	            	   	strncpy(token,formatstring+fi,k+1);
						token[k+1]='\0';
						sprintf(tmp,token,(int)data[i]);
						rl32eSendBlock(port,(void *) tmp, strlen(tmp));
	            		found=1;
						break;
					case 'u':
	            	   	strncpy(token,formatstring+fi,k+1);
						token[k+1]='\0';
						sprintf(tmp,token,(int)data[i]);
						rl32eSendBlock(port,(void *) tmp, strlen(tmp));
	            		found=1;
						break;
					case 'f':
	            	   	strncpy(token,formatstring+fi,k+1);
						token[k+1]='\0';
	            		sprintf(tmp,token,data[i]);
					    rl32eSendBlock(port,(void *) tmp, strlen(tmp));
	            		found=1;
						break;
					case 'e':
	            	   	strncpy(token,formatstring+fi,k+1);
						token[k+1]='\0';
	            		sprintf(tmp,token,data[i]);
					    rl32eSendBlock(port,(void *) tmp, strlen(tmp));
	            		found=1;
						break;
					case 'g':
	            	   	strncpy(token,formatstring+fi,k+1);
						token[k+1]='\0';
	            		sprintf(tmp,token,data[i]);
					    rl32eSendBlock(port,(void *) tmp, strlen(tmp));
	            		found=1;
						break;
	               	default:
					    //mexPrintf("in\n");
						k++;
						j++;
						if (j>strlen(formatstring)-1) {
	               			printf("error in format string\n");
						}
						break;
	         	}
	     	}
	      
	      	// set new fi
	      	fi=j+1;
	      	i++;

   		} else {
			rl32eSendChar(port,formatstring[fi]);			
       		fi++;
   		}
   
	}

}

#endif




static void mdlInitializeSizes(SimStruct *S)
{
        int_T num_in, port;
		char_T *buffer;

#ifndef MATLAB_MEX_FILE
#include "rs232_xpcimport.c"
#endif

#ifdef MATLAB_MEX_FILE
        ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
            sprintf(msg,"Wrong number of input arguments passed.\nFour arguments are expected\n");
            ssSetErrorStatus(S,msg);
            return;
        }
#endif

		buffer=(char *)calloc(mxGetN(FORMAT_SEND_ARG)+1,sizeof(char));
		if (buffer==NULL) {
			printf("Error in rs232_send: could not allocate memory\n");
			return;
		}
		mxGetString(FORMAT_SEND_ARG, buffer, mxGetN(FORMAT_SEND_ARG)+1);

		num_in=datacount(buffer);


        
        /* Set-up size information */
        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);
        ssSetNumOutputs(S, 0);
        ssSetNumInputs(S, num_in);
        ssSetDirectFeedThrough(S, 0); /* Direct dependency on inputs */
        ssSetNumSampleTimes(S,1);
        ssSetNumInputArgs(S, NUMBER_OF_ARGS);
        ssSetNumIWork(S, NO_I_WORKS); 
        ssSetNumRWork(S, NO_R_WORKS);
        ssSetNumPWork(S, NO_P_WORKS);   /* number of pointer work vector elements*/
        ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
        ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
        ssSetOptions(          S, 0);   /* general options (SS_OPTION_xx)        */

		free(buffer);
        
}
 
/* Function to initialize sample times */
static void mdlInitializeSampleTimes(SimStruct *S)
{
        
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
        if (mxGetN((SAMP_TIME_ARG))==1) {
			ssSetOffsetTime(S, 0, 0.0);
		} else {
        	ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
		}


}
 

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

	char *buffer;
	double *test;
	
	//printf("%d\n",mxGetN(FORMAT_SEND_ARG)+1);
    buffer=(char *)calloc(mxGetN(FORMAT_SEND_ARG)+1,sizeof(char));
	if (buffer==NULL) {
		printf("Error in rs232_send: could not allocate memory\n");
		return;
	}
	mxGetString(FORMAT_SEND_ARG, buffer, mxGetN(FORMAT_SEND_ARG)+1);
	//printf("%s\n",buffer);
	ssSetPWorkValue(S,0,(void *)buffer);

#endif


}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE


		int_T port;
		int i,n, received;
		char *formatsend;
		char c;
		

		port=((int_T)mxGetPr(PORT_ARG)[0])-1;
		if (!rs232ports[port]) {
			printf("        RS232 I/O-send Error: choosen COM-port not initialized\n");
			return;
		}

		formatsend=(char *)ssGetPWorkValue(S,0);

		build(formatsend, (double *) u, port);

		if ((int_T)mxGetPr(WAIT_ARG)[0]) {
			while (!(rl32eLineStatus(port) & TX_SHIFT_EMPTY));
		}


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


	char *buffer;

	buffer=(char *)ssGetPWorkValue(S,0);

	if (buffer!=NULL) {
		free(buffer);
	}

#endif
   
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
