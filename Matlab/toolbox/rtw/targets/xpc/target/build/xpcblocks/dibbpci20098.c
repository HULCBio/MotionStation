/* $Revision: 1.4 $ $Date: 2002/03/25 04:00:59 $ */
/* dibbpci20098.c - xPC Target, non-inlined S-function driver for digital input section of BB PCI-20098 board  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME dibbpci20098

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS          (4)
#define CHANNELS_ARG            ssGetSFcnParam(S,0)
#define PORT_ARG                ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define BASE_ADDR_ARG           ssGetSFcnParam(S,3)

#define CHANNELS_IND            (0)
#define PORT_IND                (0)
#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (3)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)
#define OUTPORT_I_IND           (2)

#define NO_R_WORKS              (0)

#define MAX_CHANNELS           	(8)

#ifndef MATLAB_MEX_FILE
extern int_T pci20098PortA;
extern int_T pci20098PortB;
#endif

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
        if ( mxGetM(CHANNELS_ARG)!=1 | mxGetN(CHANNELS_ARG)!=1 ) {
            sprintf(msg,"channel argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }
#endif

        num_channels=(int_T)mxGetPr(CHANNELS_ARG)[CHANNELS_IND];

#ifdef MATLAB_MEX_FILE
        if ( mxGetM(PORT_ARG)!=1 | mxGetN(PORT_ARG)!=1 ) {
            sprintf(msg,"port argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if (num_channels>MAX_CHANNELS) {
            sprintf(msg,"not more than 8 channels available\n");
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
        int_T control, port, carrierid;

        char_T *ioaddress;


        /* Store the base address, the number of channels, 
         * in int_Teger workspace vector.
         */
         
        num_channels = (int_T)mxGetPr(CHANNELS_ARG)[CHANNELS_IND];
        ssSetIWorkValue(S,CHANNELS_I_IND , num_channels);

        //2.50
        base_addr = 16*(uint_T)mxGetPr(BASE_ADDR_ARG)[BASE_ADDR_IND];
        if (  (base_addr < 0xc0000) || (base_addr > 0xdbc00)) {
          sprintf(msg,"the carrier base address can only be between 0xc000 and 0xdbc0");
          ssSetErrorStatus(S,msg);
          return;
        }
        ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);
   

        /* initialize hardware */
        
        port=(int_T)mxGetPr(PORT_ARG)[PORT_IND];
        if (  (port < 1) || (port > 2)) {
          sprintf(msg,"the value of the port argument can only be between 1 or 2");
          ssSetErrorStatus(S,msg);
          return;
        }


#ifndef MATLAB_MEX_FILE

        ioaddress = (void *) base_addr;

        carrierid=ioaddress[0x0];
        if (carrierid !=0xc1 && carrierid !=0x81 && carrierid !=0x41 && carrierid !=0x1) {
			 sprintf(msg,"PCI-20098C (0x%x): board not present",base_addr);
			 ssSetErrorStatus(S,msg);
            return;
        }

        switch (port) {
            case 1: 
               if (pci20098PortA) {
			 		sprintf(msg,"PCI-20098C (0x%x): Port A (digital) already in use");
			 		ssSetErrorStatus(S,msg);
              		return;
               }
               pci20098PortA=1; // set it to input
               control=0x92;
               if (pci20098PortB==2) {
                 control=control & 0xfd;
               }
               ioaddress[0xb]=control;
               ssSetIWorkValue(S,OUTPORT_I_IND , 0x8);
               break; 
            case 2:
               if (pci20098PortB) {
			 		sprintf(msg,"PCI-20098C (0x%x): Port B (digital) already in use");
			 		ssSetErrorStatus(S,msg);
               return;
               }
               pci20098PortB=1; // set it to input
               control=0x92;
               if (pci20098PortA==2) {
                 control=control & 0xef;
               }
               ioaddress[0xb]=control;
               ssSetIWorkValue(S,OUTPORT_I_IND , 0x9);
               break; 
          }


#endif
                  
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T num_channels = ssGetIWorkValue(S, CHANNELS_I_IND);
        int_T port=ssGetIWorkValue(S, OUTPORT_I_IND);
        int_T i;
        int_T input;

        char_T *ioaddress;
    
        
#ifndef MATLAB_MEX_FILE

       ioaddress=(void *) base_addr;

        ioaddress=(void *) base_addr;

        input=ioaddress[port];
        for (i=0;i<num_channels;i++) {
          y[i]=(input & (1<<i)) >>i; 
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
        /*
         * This function sets the digital outputs
         * to 0. 
         */
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
        int_T port=ssGetIWorkValue(S, OUTPORT_I_IND);

        char_T *ioaddress;

        
#ifndef MATLAB_MEX_FILE

         pci20098PortA=0;
         pci20098PortB=0;

#endif

       

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


