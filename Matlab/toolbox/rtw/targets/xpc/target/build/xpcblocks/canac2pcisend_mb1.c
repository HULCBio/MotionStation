/* $Revision: 1.4 $ $Date: 2002/03/25 04:03:12 $ */
/* canac2pcisend_mb1.c - xPC Target, non-inlined S-function driver for CAN-AC2-PCI from Softing (multi board)  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/


#define DEBUG 0

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME canac2pcisend_mb1

#include <stddef.h>
#include <stdlib.h>

#define MAX_OBJECTS 				200
#define MAX_IDS_EXT  				536870911
#define MAX_IDS  					2031

#ifndef MATLAB_MEX_FILE
#include "can_def.h"
#include "canlay2_pci_mb1.h" 
#endif

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS          	(3)
#define CAN_PORT_ARG            	ssGetSFcnParam(S,0)
#define CAN_ID_ARG               	ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           	ssGetSFcnParam(S,2)

#define SAMP_TIME_IND				0

#define NO_I_WORKS                  (0)

#define NO_R_WORKS                  (0)

static char_T msg[256];


#ifndef MATLAB_MEX_FILE

extern int CANAC2_1_send_mb1[MAX_OBJECTS];
extern int CANAC2_1_receive_mb1[MAX_OBJECTS];
extern int CANAC2_2_send_mb1[MAX_OBJECTS];
extern int CANAC2_2_receive_mb1[MAX_OBJECTS];

extern int CANAC2_1_sendmaxindex_mb1;
extern int CANAC2_1_sendindex_mb1[MAX_OBJECTS];
extern int CANAC2_2_sendmaxindex_mb1;
extern int CANAC2_2_sendindex_mb1[MAX_OBJECTS];


static unsigned char get_double_byte(double value, int n)
{
    unsigned char *p;
        
    p = (unsigned char *) &value;
    return p[n];
}


#endif



static void mdlInitializeSizes(SimStruct *S)
{

	int_T i, id, n;

  
#ifdef MATLAB_MEX_FILE

  	ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  // Number of expected parameters 
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
    	sprintf(msg,"Wrong number of input arguments passed.\nThree arguments are expected\n");
        ssSetErrorStatus(S,msg);
        return;
    }
    if (mxGetM(CAN_ID_ARG)>1 ) {
      	sprintf(msg,"identifier argument must be a row vector\n");
        ssSetErrorStatus(S,msg);
        return;
    }
	for (i=0;i<mxGetN(CAN_ID_ARG);i++) {
		id=(int)mxGetPr(CAN_ID_ARG)[i];
		if (id >= 0) { // standard identifiers  
			if (id > MAX_IDS) {
				sprintf(msg,"the standard identifiers must be in the range of 0..2031\n");
        		ssSetErrorStatus(S,msg);
        		return;
			}
		} else { // extended identifiers
		    id= -id;
			if (id > MAX_IDS_EXT + 1) {
				sprintf(msg,"the extended identifiers must be in the range of -1..-536870912\n");
        		ssSetErrorStatus(S,msg);
        		return;
			}
		}
	}

	    

#endif


		n=mxGetN(CAN_ID_ARG);


        /* Set-up size information */
        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);
        ssSetNumOutputs(S, 0);
        ssSetNumInputs(S, n);
        ssSetDirectFeedThrough(S, 0); /* Direct dependency on inputs */
        ssSetNumSampleTimes(S,1);
        //ssSetNumInputArgs(S, NUMBER_OF_ARGS);
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
        
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
        if (mxGetN((SAMP_TIME_ARG))==1) {
			ssSetOffsetTime(S, 0, 0.0);
		} else {
        	ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
		}

}
 

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{ 


#ifndef MATLAB_MEX_FILE


	int port, msg_id, index, frc, i, j;
	unsigned char 	p_data[8];
	int  			DataLength;
	unsigned long	Time;
	double value, starttime;



	port=(int)mxGetPr(CAN_PORT_ARG)[0];
	if (port==1) {		// CAN 1
    	for (i=0;i<mxGetN(CAN_ID_ARG);i++) {
           	msg_id=(int)mxGetPr(CAN_ID_ARG)[i];
			index=-1;
			for (j=0;j<CANAC2_1_sendmaxindex_mb1;j++) {
				if (msg_id==CANAC2_1_sendindex_mb1[j]) { // found
					index=j;
				}
			}
			if (index==-1) {
				printf("Error:  identifier %d not defined in setup block\n",msg_id);
				return;
			}
           	value = u[i];
			for(j=0; j<sizeof(double); j++) {
    			p_data[j]=get_double_byte(value, j);
    		}   
    		DataLength = 8;

//starttime=rl32eGetTicksDouble();
    		frc = CANPC_write_object_mb1(CANAC2_1_send_mb1[index],DataLength, p_data);
//printf("%f\n",rl32eETimeDouble(rl32eGetTicksDouble(),starttime));

			if (frc) {
				printf("ERROR:  CANPC_write_object_mb1 for CAN 1: %d\n",frc);
				return;
			} 
		}
	} else {
		for (i=0;i<mxGetN(CAN_ID_ARG);i++) {
           	msg_id=(int)mxGetPr(CAN_ID_ARG)[i];
			index=-1;
			for (j=0;j<CANAC2_2_sendmaxindex_mb1;j++) {
				if (msg_id==CANAC2_2_sendindex_mb1[j]) { // found
					index=j;
				}
			}
			if (index==-1) {
				printf("Error:  identifier %d not defined in setup block\n",msg_id);
				return;
			}
           	value = u[i];
			for(j=0; j<sizeof(double); j++) {
    			p_data[j]=get_double_byte(value, j);
    		}   
    		DataLength = 8;
    		frc = CANPC_write_object2_mb1(CANAC2_2_send_mb1[index],DataLength, p_data);
			if (frc) {
				printf("ERROR:  CANPC_write_object_mb1 for CAN 2: %d\n",frc);
				return;
			} 
		}
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

  	    
#endif

  
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif