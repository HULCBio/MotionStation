/* $Revision: 1.4 $ $Date: 2002/03/25 04:00:56 $ */
/* dibbpci20041.c - xPC Target, non-inlined S-function driver for digital input section of BB PCI-20041 board  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME dibbpci20041

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
#define THRESHOLD              	0.5

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
        int_T control, port;

        char_T *ioaddress;
#ifndef MATLAB_MEX_FILE
         extern int_T pci20041digout;
#endif


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
        if (  (port < 0) || (port > 3)) {
          sprintf(msg,"the value of the port argument can only be between 0 and 3");
          ssSetErrorStatus(S,msg);
          return;
        }


#ifndef MATLAB_MEX_FILE

        ioaddress = (void *) base_addr;

        switch (port) {
            case 0: 
               pci20041digout=pci20041digout | 0x1;
               ioaddress[0x8]=0x0;
               ioaddress[0x0]=pci20041digout;
               ssSetIWorkValue(S,OUTPORT_I_IND , 0x8);
               break;
            case 1:
               pci20041digout=pci20041digout | 0x82;
               ioaddress[0x9]=0x0;
               ioaddress[0x0]=pci20041digout;
               ssSetIWorkValue(S,OUTPORT_I_IND , 0x9);
               break;
            case 2:
               pci20041digout=pci20041digout | 0x84;
               ioaddress[0xa]=0x0;
               ioaddress[0x0]=pci20041digout;
               ssSetIWorkValue(S,OUTPORT_I_IND , 0xa);
               break;
            case 3:
               pci20041digout=pci20041digout | 0x88;
               ioaddress[0xb]=0x0;
               ioaddress[0x0]=pci20041digout;
               ssSetIWorkValue(S,OUTPORT_I_IND , 0xb);
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
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


