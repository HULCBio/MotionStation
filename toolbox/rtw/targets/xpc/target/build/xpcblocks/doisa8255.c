/* $Revision: 1.11 $ $Date: 2002/03/25 04:07:46 $ */
/* doisa8255.c - xPC Target, non-inlined S-function driver for digital output section of ISA boards using the 8255 chip */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     doisa8255

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h" 

#ifdef      MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef     MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "util_xpcimport.h"
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS          (7)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define PORT_ARG                ssGetSFcnParam(S,1)
#define RESET_ARG               ssGetSFcnParam(S,2)
#define INIT_VAL_ARG            ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,4)
#define BASE_ARG                ssGetSFcnParam(S,5)
#define CONTROL_ARG             ssGetSFcnParam(S,6)


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)            

#define NO_I_WORKS              (0)

#define NO_R_WORKS              (0)

#define THRESHOLD               0.5

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d input args expected, %d passed", NUMBER_OF_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumOutputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for( i = 0 ; i < NUMBER_OF_ARGS ; i++ )
    {
        ssSetSFcnParamTunable(S,i,0);  /* None of the parameters are tunable */
    }

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
    
        
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (mxGetPr(SAMP_TIME_ARG)[0]==-1.0)
    {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    }
    else
    {
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
        ssSetOffsetTime(S, 0, 0.0);
    }
}
 
#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    int_T num_channels, base, port, control; 
         
    num_channels = mxGetN(CHANNEL_ARG);
    base=(int_T)mxGetPr(BASE_ARG)[0];
    port=(int_T)mxGetPr(PORT_ARG)[0]-1;
    control=(int_T)mxGetPr(CONTROL_ARG)[0];

    if (control>=15000) { /* Diamond MM-32 */
        control= control-15000;
        rl32eOutpB((unsigned short)(base-4),(unsigned short)0x01);
    }

    rl32eOutpB((unsigned short)(base+3),(unsigned short)control);
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int_T num_channels, base, port, i;
    uchar_T output, channel;
    InputRealPtrsType uPtrs;
          
    num_channels = mxGetN(CHANNEL_ARG);
    base= (int_T)mxGetPr(BASE_ARG)[0];
    port= (int_T)mxGetPr(PORT_ARG)[0]-1;
    
    output=rl32eInpB((unsigned short)(base+port));
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        channel=(uchar_T)mxGetPr(CHANNEL_ARG)[i];
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        if (*uPtrs[0]>=THRESHOLD) {
            output |= 1 << (channel-1);
        } else {
            output &= ~(1 << (channel-1));
        }
    }
    rl32eOutpB((unsigned short)(base+port), output);

#endif
        
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE

    int_T i, channel; 
    uchar_T output;

    int_T base=(int_T)mxGetPr(BASE_ARG)[0];
    int_T port=(int_T)mxGetPr(PORT_ARG)[0]-1;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    if (xpceIsModelInit())
        output=0;
    else
        output=rl32eInpB((unsigned short)(base+port));

    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            channel=mxGetPr(CHANNEL_ARG)[i]-1;
            if ((uint_T)mxGetPr(INIT_VAL_ARG)[i]) 
                output |= 1 << channel;
            else
                output &= ~(1 << channel);
        }
    }
    rl32eOutpB((unsigned short)(base+port), output);
        
#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
