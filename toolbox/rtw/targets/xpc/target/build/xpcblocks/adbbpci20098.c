/* $Revision: 1.5 $ $Date: 2002/03/25 03:59:18 $ */
/* adbbpci20098.c - xPC Target, non-inlined S-function driver for analog input section of BB PCI-20098 board  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME adbbpci20098

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS        		(5)
#define CHANNELS_ARG             	ssGetSFcnParam(S,0)
#define RANGE_ARG 	            	ssGetSFcnParam(S,1)
#define MUX_ARG 	            	ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG              	ssGetSFcnParam(S,3)
#define BASE_ADDR_ARG           	ssGetSFcnParam(S,4)

#define CHANNELS_IND            	(0)
#define RANGE_IND                	(0)
#define MUX_IND		(0)
#define SAMP_TIME_IND           	(0)
#define BASE_ADDR_IND           	(0)

#define NO_I_WORKS              	(2)
#define CHANNELS_I_IND          	(0)
#define BASE_ADDR_I_IND         	(1)

#define NO_R_WORKS              	(2)
#define GAIN_R_IND					(0)
#define OFFSET_R_IND				(1)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
        int_T num_channels, mux;

#ifdef MATLAB_MEX_FILE

        ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
           sprintf(msg,"Wrong number of input arguments passed.\nFive arguments are expected\n");
          ssSetErrorStatus(S,msg);
          return;
        }

        if ( mxGetM(CHANNELS_ARG)!=1 | mxGetN(CHANNELS_ARG)!=1 ) {
            sprintf(msg,"channel argument must be a scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }


         if ( mxGetM(MUX_ARG)!=1 | mxGetN(MUX_ARG)!=1 ) {
            sprintf(msg,"MUX argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
         }
#endif

        num_channels=(int_T)mxGetPr(CHANNELS_ARG)[CHANNELS_IND];
        mux=(int_T)mxGetPr(MUX_ARG)[MUX_IND];

#ifdef MATLAB_MEX_FILE

       if (mux==2) {
          if (num_channels>8) {
             sprintf(msg,"not more than 8 channels in the differential mode available\n");
             ssSetErrorStatus(S,msg);
             return;          }
        } else if (mux==1) {
          if (num_channels>16) {
             sprintf(msg,"not more than 16 channels in the single-ended mode available\n");
             ssSetErrorStatus(S,msg);
             return;
          }
        } else {
             sprintf(msg,"MUX argument can only have the value 8 or 16\n");
             ssSetErrorStatus(S,msg);
             return;
        }

         if ( mxGetM(RANGE_ARG)!=1 | mxGetN(RANGE_ARG)!=1 ) {
             sprintf(msg,"range argument must be a scalar\n");
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


        int_T arg_str_len = 128;
        char_T arg_str[128];
        uint_T base_addr;
        int_T num_channels, mux, tmp;
        int_T range;
        real_T gain, offset;
        int_T res, i;

        char *ioaddress;
        int_T carrierid, modulepr;
        int_T module;
        int_T moffset;
        int_T moduleid;
        int_T timetmp;

#ifndef MATLAB_MEX_FILE
         extern int_T BBPCI;
#endif

        /* Store the base address, the number of channels, 
         * in integer workspace vector.
         */
         
        num_channels = (int_T)mxGetPr(CHANNELS_ARG)[CHANNELS_IND];
        ssSetIWorkValue(S,CHANNELS_I_IND , num_channels);

        mux = (int_T)mxGetPr(MUX_ARG)[MUX_IND];
        
        //2.50
        base_addr = 16* (uint_T)mxGetPr(BASE_ADDR_ARG)[BASE_ADDR_IND];
        if (  (base_addr < 0xc0000) || (base_addr > 0xdbc00)) {
          sprintf(msg,"the carrier base address can only be between 0xc000 and 0xdbc0");
          ssSetErrorStatus(S,msg);
          return;
        }
        ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);

        range=(int_T)mxGetPr(RANGE_ARG)[RANGE_IND];
   
         if (range==1) {
            gain=20.0/4096.0;
            offset=10.0;
         } else if (range==2) {
            gain=10.0/4096.0;
            offset=5.0;
         } else if (range==3) {
            gain=10.0/4096.0;
            offset=0.0;
         } else {
#ifdef MATLAB_MEX_FILE
       sprintf(msg,"the analog input range can only be -10, -5, 10\n");
      ssSetErrorStatus(S,msg);
      return;
#endif
         }

         ssSetRWorkValue(S,GAIN_R_IND , gain);
         ssSetRWorkValue(S,OFFSET_R_IND , offset);

         /* initiallize hardware */

#ifndef MATLAB_MEX_FILE
 
       ioaddress=(void *) base_addr;
 
       carrierid=ioaddress[0x0];
       if (carrierid !=0xc1 && carrierid !=0x81 && carrierid !=0x41 && carrierid !=0x1) {
			 sprintf(msg,"PCI-20098C (0x%x): board not present",base_addr);
			 ssSetErrorStatus(S,msg);
            return;
       }
      
       // disable channel list
       ioaddress[0x10]=0x0;
      
       // set up channel list
       if (mux==1) {	// 16 single-ended
         for (i=0;i<num_channels;i++) {
           if (i<8) { // first MUX
             if (i==(num_channels-1)) {
               ioaddress[0x80+i]=0x08 | i;
             } else {
               ioaddress[0x80+i]=0x88 | i;
             }
           } else {
             if (i==(num_channels-1)) {
               ioaddress[0x80+i]=0x10 | (i-8);
             } else {
               ioaddress[0x80+i]=0x90 | (i-8);
             }
           }
         }
       } else {	// 8 differential
         for (i=0;i<num_channels;i++) {
           if (i==(num_channels-1)) {
             ioaddress[0x80+i]=0x18 | i;
           } else {
             ioaddress[0x80+i]=0x98 | i;
           }
         }
       }
       ioaddress[0x14]=0;

       // set up A/D circuit
       if (mux==1) {
         ioaddress[0x10] = 0xe8 | range;
       } else {
         ioaddress[0x10] = 0xec | range;
       }

       // enable software initiated conversion
       ioaddress[0x70]=0x0;
       ioaddress[0x71]=0x0;

       // clear overrun bit
       tmp=ioaddress[0x14];
             
#endif

                 
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
        real_T gain=ssGetRWorkValue(S,GAIN_R_IND);
        real_T offset=ssGetRWorkValue(S,OFFSET_R_IND);
        int_T i, res, timetmp;

        volatile char_T *ioaddress;
    
        
#ifndef MATLAB_MEX_FILE

        ioaddress = (void *) base_addr;

        for (i=0;i<num_channels;i++) {
               // clear EOC
               ioaddress[0x5]=0;
               //start conversion   
               ioaddress[0x11]=0;
        	// poll for EOC
                while ( (ioaddress[0x5] & 0x8) == 0 );//printf("converting\n");
                // read A/D value
       	res=ioaddress[0x12];
       	res= ((ioaddress[0x13] & 0x0f) << 8) | res;
       	y[i]=res*gain-offset; 
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

