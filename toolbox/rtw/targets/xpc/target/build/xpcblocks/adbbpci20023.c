/* $Revision: 1.4 $ $Date: 2002/03/25 03:59:15 $ */
/* adbbpci20023.c - xPC Target, non-inlined S-function driver for analog input section of BB PCI-20023 module  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME adbbpci20023

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "time_xpcimport.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS        		(5)
#define CHANNELS_ARG         		ssGetSFcnParam(S,0)
#define RANGE_ARG 	            	ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           	ssGetSFcnParam(S,2)
#define MODULE_ARG              	ssGetSFcnParam(S,3)
#define BASE_ADDR_ARG           	ssGetSFcnParam(S,4)

#define CHANNELS_IND            	(0)
#define RANGE_IND                	(0)
#define MODULE_IND                	(0)
#define SAMP_TIME_IND           	(0)
#define BASE_ADDR_IND           	(0)

#define NO_I_WORKS              	(4)
#define CHANNELS_I_IND          	(0)
#define BASE_ADDR_I_IND         	(1)
#define MOFFSET_I_IND         		(2)
#define MODULE_I_IND	         	(3)

#define NO_R_WORKS              	(2)
#define GAIN_R_IND					(0)
#define OFFSET_R_IND				(1)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
        int_T num_channels, mux;

#ifndef MATLAB_MEX_FILE
#include "time_xpcimport.c"
#endif

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
         if ( mxGetM(MODULE_ARG)!=1 | mxGetN(MODULE_ARG)!=1 ) {
            sprintf(msg,"module argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }
#endif

        num_channels=(int_T)mxGetPr(CHANNELS_ARG)[CHANNELS_IND];

#ifdef MATLAB_MEX_FILE
        
        if (num_channels>8) {
             sprintf(msg,"not more than 8 analog input channels available\n");
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
        int_T num_channels;
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

        module=mxGetPr(MODULE_ARG)[MODULE_IND];
        ssSetIWorkValue(S,MODULE_I_IND , module);
        moffset=module*0x100;
        ssSetIWorkValue(S,MOFFSET_I_IND , moffset);

        //2.50
        base_addr = 16* (uint_T)mxGetPr(BASE_ADDR_ARG)[BASE_ADDR_IND];
        if (  (base_addr < 0xc0000) || (base_addr > 0xdbc00)) {
          sprintf(msg,"the carrier base address can only be between 0xc000 and 0xdbc0");
          ssSetErrorStatus(S,msg);
          return;
        }
        ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);

        range=1000*mxGetPr(RANGE_ARG)[RANGE_IND];
   
         if (range==-10000) {
            gain=20.0/4096.0;
            offset=10,0;
         } else if (range==-5000) {
            gain=10.0/4096.0;
            offset=5.0;
         } else if (range==-2500) {
            gain=5.0/4096.0;
            offset=2.5;
         } else if (range==10000) {
            gain=10.0/4096.0;
            offset=0.0;
         } else if (range==5000) {
            gain=5.0/4096.0;
            offset=0.0;
         } else {
#ifdef MATLAB_MEX_FILE
       sprintf(msg,"the analog input range can only be -10, -5, -2.5, 10, 5\n");
      ssSetErrorStatus(S,msg);
      return;
#endif
         }

         ssSetRWorkValue(S,GAIN_R_IND , gain);
         ssSetRWorkValue(S,OFFSET_R_IND , offset);

         /* initiallize hardware */

#ifndef MATLAB_MEX_FILE
 
       ioaddress=(void *) base_addr;
 
       carrierid=ioaddress[0] & 0x0f;
       if (carrierid !=1 && carrierid !=3 && carrierid !=5 && carrierid !=7) {
			 sprintf(msg,"PCI-20023 (0x%x): PCI-20041C-2A,3A carrier board not present",base_addr);
			 ssSetErrorStatus(S,msg);
            return;
       }
       modulepr=(ioaddress[0] & 0xe0) >> 5;
       if ((modulepr & (1 << (module -1))) !=0) {
			sprintf(msg,"PCI-20023 (Id: %x): not present on carrier board",module);
			ssSetErrorStatus(S,msg);
            return;
       }

       res=ioaddress[moffset+0x2];

       // interrupt clear
       ioaddress[0x1]=0x0;


       //access analog module
       moduleid=ioaddress[moffset+0x0];
       if (moduleid != 0xc1) {
			sprintf(msg,"PCI-20023 (Id: %x): module has wrong type or software channel selection is not enabled",module);
			ssSetErrorStatus(S,msg);
            return;
       }

       // set MUX
       ioaddress[moffset+0x4]=0x08;


#endif

                 
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T moffset = ssGetIWorkValue(S, MOFFSET_I_IND);
        int_T module = ssGetIWorkValue(S, MODULE_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
        real_T gain=ssGetRWorkValue(S,GAIN_R_IND);
        real_T offset=ssGetRWorkValue(S,OFFSET_R_IND);
        int_T i, res, timetmp;

        char_T *ioaddress;
    
        
#ifndef MATLAB_MEX_FILE

        ioaddress = (void *) base_addr;

        for (i=0;i<num_channels;i++) {
               //start conversion   
               ioaddress[moffset+0x3]=0x0;
               // set new mux channel
        	if (i==(num_channels-1)) {
           		ioaddress[moffset+0x4]=0x08;
        	} else {
           		ioaddress[moffset+0x4]=0x08 | (i+1);
        	}
        	// wait for 6us
			rl32eWaitDouble(0.000006);
        	// read data
       	res=ioaddress[moffset+0x1];
       	res= ((ioaddress[moffset+0x2] & 0x0f) << 8) | res;
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

