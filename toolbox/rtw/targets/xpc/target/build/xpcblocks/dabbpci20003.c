/* $Revision: 1.4 $ $Date: 2002/03/25 04:05:09 $ */
/* dabbpci20003.c - xPC Target, non-inlined S-function driver for analog output section of BB PCI-20003 module  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME dabbpci20003

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS                  (4)
#define CHANNELS_ARG                      ssGetSFcnParam(S,0)
#define SAMP_TIME_ARG                   ssGetSFcnParam(S,1)
#define MODULE_ARG		     ssGetSFcnParam(S,2)
#define BASE_ADDR_ARG                   ssGetSFcnParam(S,3)


#define CHANNELS_IND            	(0)
#define SAMP_TIME_IND                   (0)
#define MODULE_IND                         (0)
#define BASE_ADDR_IND                   (0)

#define NO_I_WORKS                      (3)
#define CHANNELS_I_IND 	 (0)
#define BASE_ADDR_I_IND             (1)
#define MOFFSET_I_IND		(2)

#define NO_R_WORKS                      (4)

#define MAX_CHANNELS                   (2)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
        int_T num_channels;

#ifdef MATLAB_MEX_FILE
       ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
       if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
            sprintf(msg,"Wrong number of input arguments passed.\nFour arguments are expected\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if ( mxGetM(CHANNELS_ARG)!=1 ) {
            sprintf(msg,"channel argument must be row vector\n");
            ssSetErrorStatus(S,msg);
            return;
        }
#endif

        num_channels=mxGetN(CHANNELS_ARG);

#ifdef MATLAB_MEX_FILE
        if (num_channels>MAX_CHANNELS) {
            sprintf(msg,"not more than 2 channels available\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if ( mxGetM(MODULE_ARG)!=1 | mxGetN(MODULE_ARG)!=1 ) {
            sprintf(msg,"module argument must be scalar\n");
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
        ssSetNumOutputs(S, 0);
        ssSetNumInputs(S, num_channels);
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
        int_T num_channels;
        real_T *RWork=ssGetRWork(S);
        int_T i, range, counts;
        real_T value;

        char_T *ioaddress;
        int_T carrierid, modulepr;
        int_T module;
        int_T moffset;
        int_T moduleid;

#ifndef MATLAB_MEX_FILE
//         extern int_T BBPCI;
#endif


        /* Store the base address, the number of channels, 
         * in int_Teger workspace vector.
         */
         
        num_channels = mxGetN(CHANNELS_ARG);
        ssSetIWorkValue(S,CHANNELS_I_IND , num_channels);

        module=mxGetPr(MODULE_ARG)[MODULE_IND];
        moffset=module*0x100;
        ssSetIWorkValue(S,MOFFSET_I_IND , moffset);

        //2.50
        base_addr = 16*(uint_T)mxGetPr(BASE_ADDR_ARG)[BASE_ADDR_IND];
        if (  (base_addr < 0xc0000) || (base_addr > 0xdbc00)) {
          sprintf(msg,"the carrier base address can only be between 0xc000 and 0xdbc0");
          ssSetErrorStatus(S,msg);
          return;
        }
        ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);

        /* prepare gain and offset work vector */
        
        for (i=0;i<num_channels;i++) {
          range=100*mxGetPr(CHANNELS_ARG)[i];
          if (range==-1000) {
            RWork[2*i]=20.0/4096.0;
            RWork[2*i+1]=10.0;
          } else if (range==-500) {
            RWork[2*i]=10.0/4096.0;
            RWork[2*i+1]=5.0;
          } else if (range==1000) {
            RWork[2*i]=10.0/4096.0;
            RWork[2*i+1]=0.0;
          } else {
#ifdef MATLAB_MEX_FILE
      sprintf(msg,"the analog output range values can only be -10, -5, 10");
      ssSetErrorStatus(S,msg);
      return;
#endif
          }
       }

       /* initialize hardware, reset all output channels to 0*/
#ifndef MATLAB_MEX_FILE

       ioaddress=(void *) base_addr;

       //printf("%x\n",ioaddress[0]);
 
       carrierid=ioaddress[0] & 0x0f;
       if (carrierid !=1 && carrierid !=3 && carrierid !=5 && carrierid !=7) {
			 sprintf(msg,"PCI-20003M (0x%x): PCI-20041C-2A,3A carrier board not present",base_addr);
			 ssSetErrorStatus(S,msg);
            return;
       }
       modulepr=(ioaddress[0] & 0xe0) >> 5;
       if ((modulepr & (1 << (module -1))) !=0) {
			sprintf(msg,"PCI-20003M (Id: %x): not present on carrier board",module);
			ssSetErrorStatus(S,msg);
            return;
       }
       // set interupt mode to latched mode and all digital ports to input
       //ioaddress[0]=BBPCI;
       // interrupt clear
       ioaddress[1]=0x0;
       //access analog module
       moduleid=ioaddress[moffset+0x0];
       if (moduleid != 0xf7) {
			sprintf(msg,"PCI-20003M (Id: %x): module has wrong type",module);
			ssSetErrorStatus(S,msg);
            return;
       }

       // set the 2 outputs to zero

      for (i=0;i<num_channels;i++) {
         value=0.0;
         counts=(value+RWork[2*i+1])/RWork[2*i];
         if (counts>4095) counts=4095;
         if (counts<0)    counts=0;
         ioaddress[moffset+0x1+0x4*i]=counts & 0xff;
         ioaddress[moffset+0x2+0x4*i]= (counts >> 8) &  0x0f;
      }
      ioaddress[moffset+0x4]=0x0;


#endif

       
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T moffset=ssGetIWorkValue(S, MOFFSET_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
        real_T *RWork=ssGetRWork(S);
        int_T i, counts;
        real_T value;

        char_T *ioaddress;

        
#ifndef MATLAB_MEX_FILE

      ioaddress=(void *) base_addr;

      if (num_channels>0) {

          value=u[0];
          counts=(value+RWork[1])/RWork[0];
          if (counts>4095) counts=4095;
          if (counts<0)    counts=0;
          ioaddress[moffset+0x1]=counts & 0xff;
          ioaddress[moffset+0x2]= (counts >> 8) &  0x0f;

         if (num_channels==2) {
            value=u[1];
            counts=(value+RWork[3])/RWork[2];
            if (counts>4095) counts=4095;
            if (counts<0)    counts=0;
            ioaddress[moffset+0x5]=counts & 0xff;
            ioaddress[moffset+0x6]= (counts >> 8) &  0x0f;
        }
        if (num_channels==1) {
            ioaddress[moffset+0x3]=0x0;
        } else { 
            ioaddress[moffset+0x4]=0x0;
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
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T moffset = ssGetIWorkValue(S, MOFFSET_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
        real_T *RWork=ssGetRWork(S);
        int_T i, counts;
        real_T value;
        
        char_T *ioaddress;

#ifndef MATLAB_MEX_FILE

      ioaddress=(void *) base_addr;

      for (i=0;i<num_channels;i++) {
         value=0.0;
         counts=(value+RWork[2*i+1])/RWork[2*i];
         if (counts>4095) counts=4095;
         if (counts<0)    counts=0;
         ioaddress[moffset+0x1+0x4*i]=counts & 0xff;
         ioaddress[moffset+0x2+0x4*i]= (counts >> 8) &  0x0f;
      }
      ioaddress[moffset+0x4]=0x0;
    
#endif
  
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif




