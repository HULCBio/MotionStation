/* $Revision: 1.4 $ $Date: 2002/03/25 03:59:24 $ */
/* adcbdas16jrexp.c - xPC Target, non-inlined S-function driver for A/D section of CB CIO-DAS16/JR  series boards with attached EXP-boards */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME adcbdas16jrexp

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "io_xpcimport.h"
#include "time_xpcimport.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS        		(6)
#define CHANNELS_ARG            	ssGetSFcnParam(S,0)
#define GAIN_ARG					ssGetSFcnParam(S,1)
#define ADMUX_ARG					ssGetSFcnParam(S,2)
#define RANGE_ARG 	           		ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG           	ssGetSFcnParam(S,4)
#define BASE_ADDR_ARG           	ssGetSFcnParam(S,5)

#define RANGE_IND                	(0)
#define ADMUX_IND                	(0)
#define SAMP_TIME_IND           	(0)
#define BASE_ADDR_IND           	(0)

#define NO_I_WORKS              	(4)
#define CHANNELS_I_IND          	(0)
#define BASE_ADDR_I_IND         	(1)
#define ADMUX_I_IND	         		(2)
#define DIRECT_I_IND         		(3)



#define NO_R_WORKS              	(2)
#define GAIN_R_IND					(0)
#define OFFSET_R_IND				(1)


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
        int_T num_channels, mux;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "time_xpcimport.c"
#endif


#ifdef MATLAB_MEX_FILE

        ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        	sprintf(msg,"Wrong number of input arguments passed.\nSix arguments are expected\n");
          	ssSetErrorStatus(S,msg);
			return;
        }

        if ( mxGetM(CHANNELS_ARG)>1) {
            sprintf(msg,"channel argument must be a row vector\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if ( mxGetM(GAIN_ARG)>1) {
            sprintf(msg,"gain argument must be a row vector\n");
            ssSetErrorStatus(S,msg);
            return;
        }
		if ( mxGetN(GAIN_ARG) != mxGetN(CHANNELS_ARG) ) {
			sprintf(msg,"the range and gain vectors must have the same length\n");
            ssSetErrorStatus(S,msg);
            return;
        }



#endif

        num_channels=mxGetN(CHANNELS_ARG);
		if (num_channels==0) {
			num_channels=1;

		}

#ifdef MATLAB_MEX_FILE
        
        if (num_channels>16) {
             sprintf(msg,"not more than 16 channels in the single-ended mode available\n");
             ssSetErrorStatus(S,msg);
             return;
        }
        if ( mxGetM(SAMP_TIME_ARG)!=1 | mxGetN(SAMP_TIME_ARG)!=1 ) {
             sprintf(msg,"sample time argument must be a scalar\n");
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
        ssSetNumOutputs(S, num_channels);
        ssSetNumInputs(S, 0);
        ssSetDirectFeedThrough(S, 0); /* Direct dependency on inputs */
        ssSetNumSampleTimes(S,1);
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


        uint_T base_addr;
        int_T num_channels;
        int_T range, i, admux;
        real_T gain, offset;

        /* Store the base address, the number of channels, 
         * in integer workspace vector.
         */
         
        num_channels = mxGetN(CHANNELS_ARG);
		ssSetIWorkValue(S,DIRECT_I_IND , 0);
		if (num_channels==0) {
			num_channels=1;
			ssSetIWorkValue(S,DIRECT_I_IND , 1);
		}


        ssSetIWorkValue(S,CHANNELS_I_IND , num_channels);

        base_addr = (uint_T)mxGetPr(BASE_ADDR_ARG)[BASE_ADDR_IND];
        ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);

        range=(int_T)mxGetPr(RANGE_ARG)[RANGE_IND];
		admux=mxGetPr(ADMUX_ARG)[ADMUX_IND];

   
         if (range==1) {
            gain=20.0/4096.0;
            offset=10,0;
#ifndef MATLAB_MEX_FILE
            outp(base_addr+0xb,0x8);
#endif
         } else if (range==2) {
            gain=10.0/4096.0;
            offset=5.0;
#ifndef MATLAB_MEX_FILE
            outp(base_addr+0xb,0x0);
#endif
         } else if (range==3) {
            gain=5.0/4096.0;
            offset=2.5;
#ifndef MATLAB_MEX_FILE
            outp(base_addr+0xb,0x1);
#endif
         } else if (range==4) {
            gain=2.5/4096.0;
            offset=1.25;
#ifndef MATLAB_MEX_FILE
            outp(base_addr+0xb,0x2);
#endif
         } else if (range==5) {
            gain=1.25/4096.0;
            offset=0.625;
#ifndef MATLAB_MEX_FILE
            outp(base_addr+0xb,0x3);
#endif
         } else if (range==6) {
            gain=10.0/4096.0;
            offset=0.0;
#ifndef MATLAB_MEX_FILE
            outp(base_addr+0xb,0x4);
#endif
         } else if (range==7) {
            gain=5.0/4096.0;
            offset=0.0;
#ifndef MATLAB_MEX_FILE
            outp(base_addr+0xb,0x5);
#endif
         } else if (range==8) {
            gain=2.5/4096.0;
            offset=0.0;
#ifndef MATLAB_MEX_FILE
            outp(base_addr+0xb,0x6);
#endif
         } else if (range==9) {
            gain=1.25/4096.0;
            offset=0.0;
#ifndef MATLAB_MEX_FILE
            outp(base_addr+0xb,0x7);
#endif
         } else {
#ifdef MATLAB_MEX_FILE
       sprintf(msg,"the analog input range can only be -10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25\n");
      ssSetErrorStatus(S,msg);
      return;
#endif
         }

         ssSetRWorkValue(S,GAIN_R_IND , gain);
         ssSetRWorkValue(S,OFFSET_R_IND , offset);
		 ssSetIWorkValue(S,ADMUX_I_IND , admux);



         /* initiallize hardware */

#ifndef MATLAB_MEX_FILE
 
         /* no DMA, Software triggered A/D, interrupts disabled */
         outp(base_addr+0x9,0);
        
        // test A/D conversion
        outp(base_addr+0x0,0x0);
         i=0;
         while ((inp(base_addr+0x8) & 0x80) == 0x80 ) {
           if (100<i++) {
			 sprintf(msg,"CIO-DAS16/JR EXP (0x%x): test A/D conversion failed",base_addr);
			 ssSetErrorStatus(S,msg);
             return;
           }
         }


#endif

                 
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
        real_T gain=ssGetRWorkValue(S,GAIN_R_IND);
        real_T offset=ssGetRWorkValue(S,OFFSET_R_IND);
		real_T gainexp;
		int_T admux = ssGetIWorkValue(S, ADMUX_I_IND);
		int_T direct = ssGetIWorkValue(S, DIRECT_I_IND);

        int_T i, res, j, a;
		int_T channel;
		int_T timetmp;
    
        
#ifndef MATLAB_MEX_FILE

		

        for (i=0;i<num_channels;i++) {

		  if (!direct) {	
		  	channel=(int_T)mxGetPr(CHANNELS_ARG)[i];
		  	// set exp channel
		  	outp(base_addr+0x3,channel); // exp channel 2
        	// wait for n us
            rl32eWaitDouble(0.000025);		
		  }
		  // set mux
		  outp(base_addr+0x2,((admux-1) << 4 | (admux-1))); // A/D channel
		  // wait for n ticks
          rl32eWaitDouble(0.000005);		
           /* start conversion */
          outp(base_addr+0x0,0x0);
          /* wait until conversion finished */
          while ((inp(base_addr+0x8) & 0x80) == 0x80 );
          /* get value */
          res=(0xfff0 & inpw(base_addr+0x0)) >>4;
          y[i]=(res*gain-offset);
		  if (!direct) {
		    gainexp=(int_T)mxGetPr(GAIN_ARG)[i]; 
		  	y[i]=y[i]/gainexp;	
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
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

