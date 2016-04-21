/* $Revision: 1.4 $ $Date: 2002/03/25 04:10:57 $ */
/* rs232_rec.c - xPC Target, non-inlined S-function driver for RS232 receive (asynchronious) on motherboards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/


#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME rs232_rec

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
#define FORMAT_REC_ARG        	ssGetSFcnParam(S,1)
#define NUMB_ARG				ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,3)


#define NO_I_WORKS              	(2)
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
	

static void extract(char *formatstring, char *in, double *data)
{

	int i, fi, ini, j, found, k;
	char token[tmpsize];
	char endchar;
	char substr[tmpsize];
	int type;
	int tmpi;
	float tmpf;
	


	fi=0;
	ini=fi;

	i=0;

	while (fi<=strlen(formatstring)) {
   		if (formatstring[fi]=='%') {
      		// search format token
      		found=0;
      		j=fi;
      		while (!found) {
         		switch (formatstring[j]) {
         			case 'f':
         				type=1; 
						found=1;
						break;
					case 'd':
         				type=2; 
						found=1;
						break;
					case 'x':
         				type=2; 
						found=1;
						break;
					default:
	            		j++;
    	        		if (j>=strlen(formatstring)) {
        	       			printf("error in format string\n");
            			}
         				break;
				}
      		}
      		// token found
      		// save it
      		strncpy(token,formatstring+fi,j-fi+1);
			token[j-fi+1]='\0';
      		// endchar
      		endchar=formatstring[j+1];
      		// search endchar
      		found=0;
      		k=ini;
      		while (!found) {
         		if (in[k]==endchar) {
            		found=1;
         		} else {
            		k++;
        		}
      		}
      		// save it
      		strncpy(substr,in+ini,k-ini);
      		substr[k-ini]='\0';
			if (type==1) {
				sscanf(substr,token,&tmpf);
				//printf("%f\n",tmpf);
				data[i]=(double)tmpf;
			} else if (type==2) {
				sscanf(substr,token,&tmpi);
				data[i]=(double)tmpi;
			}      								   
      		// set new ini and fi
      		fi=j;
      		ini=k-1;   
			i++;
   		}
   		fi++;
   		ini++;
	}

}



static void mdlInitializeSizes(SimStruct *S)
{
        int_T num_out, port;
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

		buffer=(char *)calloc(mxGetN(FORMAT_REC_ARG)+1,sizeof(char));
		if (buffer==NULL) {
			printf("Error in rs232_rec: could not allocate memory\n");
			return;
		}
		mxGetString(FORMAT_REC_ARG, buffer, mxGetN(FORMAT_REC_ARG)+1);
		
		num_out=datacount(buffer);
        
        /* Set-up size information */
        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);
        ssSetNumOutputs(S, num_out);
        ssSetNumInputs(S, 0);
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
	char *in;
	double *test;
	int port;
	
    buffer=(char *)calloc(mxGetN(FORMAT_REC_ARG)+1,sizeof(char));
	if (buffer==NULL) {
		printf("Error in rs232_rec: could not allocate memory\n");
		return;
	}
	mxGetString(FORMAT_REC_ARG, buffer, mxGetN(FORMAT_REC_ARG)+1);
	ssSetPWorkValue(S,0,(void *)buffer);

   	buffer=(char *)calloc(65536,sizeof(char));
	if (buffer==NULL) {
		printf("Error in rs232_rec: could not allocate memory\n");
		return;
	}
	*buffer='\0';
	ssSetPWorkValue(S,1,(void *)buffer);

	ssSetIWorkValue(S,0,0);


#endif


}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE


		int_T port;
		int i,n;
		char c;
		int k;
		char *in, *formatrec;
		int index;


		port=((int_T)mxGetPr(PORT_ARG)[0])-1;
		if (!rs232ports[port]) {
			printf("        RS232 I/O-receive Error: choosen COM-port not initialized\n");
			return;
		}

		formatrec=(char *)ssGetPWorkValue(S,0);
		//printf("%s\n",formatrec);
		in=(char *)ssGetPWorkValue(S,1);
		//printf("%s\n",in);
		index=ssGetIWorkValue(S,0);
		//printf("%d\n",index);
		
		n=(int)mxGetPr(NUMB_ARG)[0];
		k=rl32eReceiveBufferCount(port);
		for (i=0;i<k;i++) {
			c=rl32eReceiveChar(port);
			if (( c & 0xff00)!=0) {
				printf("receive error\n");
				return;
			}
			in[index++]=c;
			in[index]='\0';
			if (i>=n) {
				if (!strcmp(in+index-n,formatrec+strlen(formatrec)-n)) {
					//printf("%s\n",in);
					extract(formatrec,in,(double *)y );
					index=0;
					*in='\0';
				}
			}
		}
		ssSetIWorkValue(S,0,index);

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


	buffer=(char *)ssGetPWorkValue(S,1);

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
