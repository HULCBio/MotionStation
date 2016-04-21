/* $Revision: 1.5 $ $Date: 2002/03/25 04:01:21 $ */
/* encadpa1700.c - xPC Target, non-inlined S-function driver for incremental encoder section of PA-1700 from ADDI-DATA  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME encadpa1700

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "io_xpcimport.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS        		(7)
#define RESET_ARG					ssGetSFcnParam(S,0)
#define COUNTER_ARG             	ssGetSFcnParam(S,1)
#define MODE_ARG             		ssGetSFcnParam(S,2)
#define HYST_ARG 	            	ssGetSFcnParam(S,3)
#define RES_ARG 	            	ssGetSFcnParam(S,4)
#define SAMP_TIME_ARG              	ssGetSFcnParam(S,5)
#define BASE_ADDR_ARG           	ssGetSFcnParam(S,6)

#define RESET_IND					(0)
#define COUNTER_IND            		(0)
#define MODE_IND                	(0)
#define HYST_IND                	(0)
#define RES_IND                		(0)
#define SAMP_TIME_IND           	(0)
#define BASE_ADDR_IND           	(0)

#define NO_I_WORKS              	(5)
#define BASE_ADDR_I_IND         	(0)
#define COUNTER_I_IND				(1)
#define MODE_I_IND					(2)
#define INDEXOK_I_IND				(3)
#define TURNS_I_IND					(4)


#define NO_R_WORKS              	(1)
#define RES_R_IND		        	(0)

#define PI							3.14159265358979	


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif


#ifdef MATLAB_MEX_FILE
        ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
            sprintf(msg,"Wrong number of input arguments passed.\n7 arguments are expected\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if ( mxGetM(COUNTER_ARG)!=1 | mxGetN(COUNTER_ARG)!=1 ) {
            sprintf(msg,"counter argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }
	if ( mxGetM(MODE_ARG)!=1 | mxGetN(MODE_ARG)!=1 ) {
            sprintf(msg,"mode argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }
	if ( mxGetM(HYST_ARG)!=1 | mxGetN(HYST_ARG)!=1 ) {
            sprintf(msg,"hystheresis argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }
	if ( mxGetM(RES_ARG)!=1 | mxGetN(RES_ARG)!=1 ) {
            sprintf(msg,"resolution argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if ( mxGetM(SAMP_TIME_ARG)!=1 | mxGetN(SAMP_TIME_ARG)!=1 ) {
             sprintf(msg,"sample time argument must be scalar\n");
             ssSetErrorStatus(S,msg);
             return;
        }
        if ( mxGetM(BASE_ADDR_ARG)!=1 | mxGetN(BASE_ADDR_ARG)!=1 ) {
             sprintf(msg,"base address argument must be scalar\n");
             ssSetErrorStatus(S,msg);
             return;
        }


#endif
        
        /* Set-up size information */
        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);
        ssSetNumOutputs(S, 2);
        ssSetNumInputs(S, 0);
        ssSetDirectFeedThrough(S, 0); /* Direct dependency on inputs */
        ssSetNumSampleTimes(S,1);
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
        
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
        if (mxGetN((SAMP_TIME_ARG))==1) {
			ssSetOffsetTime(S, 0, 0.0);
		} else {
        	ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
		}

}
 

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{


        int_T arg_str_len = 128;
        char_T arg_str[128];
        uint_T base_addr;
        int_T counterno, mode, modeout, hyst;
        real_T res;

        /* Store the base address, the number of channels, 
         * in int_Teger workspace vector.
         */
         
        counterno=(int_T)mxGetPr(COUNTER_ARG)[COUNTER_IND];
        ssSetIWorkValue(S,COUNTER_I_IND , counterno);
		mode=(int_T)mxGetPr(MODE_ARG)[MODE_IND];
		hyst=(int_T)mxGetPr(HYST_ARG)[HYST_IND];
		res=mxGetPr(RES_ARG)[RES_IND];
        ssSetRWorkValue(S,RES_R_IND , res);
		//2.50
        base_addr = (unsigned int) mxGetPr(BASE_ADDR_ARG)[0]; //2.50
        ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);
		ssSetIWorkValue(S,INDEXOK_I_IND , 0);

        
#ifndef MATLAB_MEX_FILE

		rl32eOutpW((unsigned short)(base_addr+24), (unsigned short)(counterno-1));       // define counter
    	rl32eOutpW((unsigned short)(base_addr+26), 0x7);  		// clear if index for the first time

    	if (mode==1) {
        	modeout=0x5;
		ssSetIWorkValue(S,MODE_I_IND , 1);
    	} else if (mode==2) {
        	modeout=0x1;
		ssSetIWorkValue(S,MODE_I_IND , 2);
    	} else if (mode==3) {
        	modeout=0x0;
		ssSetIWorkValue(S,MODE_I_IND , 4);
    	}

    	if (hyst==2) {
        	modeout=modeout | 0x20;
    	}      

    	rl32eOutpW((unsigned short)(base_addr+10), (unsigned short)modeout);           // set counter mode

   
#endif

                 
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T counterno = ssGetIWorkValue(S, COUNTER_I_IND);
	int_T mode = ssGetIWorkValue(S, MODE_I_IND);
	real_T res = ssGetRWorkValue(S, RES_R_IND);
    int_T indexok=ssGetIWorkValue(S,INDEXOK_I_IND);
	int_T turns=ssGetIWorkValue(S,TURNS_I_IND);
    int_T countval, statval;
	real_T countfloat;
    
        
#ifndef MATLAB_MEX_FILE

	rl32eOutpW((unsigned short)(base_addr+24), (unsigned short)(counterno-1)); 				// define counter	
    rl32eOutpW((unsigned short)(base_addr+0),0x1);         				// strobe counter to latch 1
	countval=rl32eInpW((unsigned short)(base_addr+2)) | (rl32eInpW((unsigned short)(base_addr+4)) << 16);         // read latch
	if ((int_T)mxGetPr(RESET_ARG)[RESET_IND]==1) {
		if (!indexok) {
			statval=rl32eInpW((unsigned short)(base_addr+24));                 // read status
    		if ( ((statval & (1 << (counterno-1))) >> (counterno-1)) == 0x1) {
    			indexok=1;
		    	ssSetIWorkValue(S,INDEXOK_I_IND , indexok);
			}
		}
		countval=countval/mode;
    	countfloat=countval/res*2.0*PI; 
    	//printf("%f\n",countfloat);
		y[0]=countfloat;
		y[1]=(double)indexok;
	} else {
		statval=rl32eInpW((unsigned short)(base_addr+24));                 // read status
   		if ( ((statval & (1 << (counterno-1))) >> (counterno-1)) == 0x1) {
			if (!indexok) {
				indexok=1;
				turns=0;
	    		ssSetIWorkValue(S,INDEXOK_I_IND , indexok);
				ssSetIWorkValue(S,TURNS_I_IND , turns);
			} else {
				rl32eOutpW((unsigned short)(base_addr+26), 0x7);
				if ( ((statval & (1 << ((counterno-1)+9))) >> ((counterno-1)+9)) == 0x1) {
					turns++;
				} else {
					turns--;
				}
				ssSetIWorkValue(S,TURNS_I_IND , turns);
			}
		}
		countval=countval/mode;
    	countfloat=countval/res*2.0*PI; 
    	//printf("%f\n",countfloat);
		y[0]=countfloat;
		y[1]=(double)turns;
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
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
