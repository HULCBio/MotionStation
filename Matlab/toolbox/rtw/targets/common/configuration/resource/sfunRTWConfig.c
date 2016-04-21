/*
 * File: sfunRTWConfig.c
 *
 * Abstract:
 *   The sfunction does nothing during Simulation. However at build
 *   time it's corresponding TLC file interrogates the TargetProperties
 *   field and generates target configuration code.
 *
 *
 * $Revision: 1.6.4.2 $
 * $Date: 2004/04/19 01:21:30 $
 *
 * Copyright 2001-2003 The MathWorks, Inc.
 */

//#define debug

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	sfunRTWConfig

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

static void mdlInitializeSizes(SimStruct *S)
{

   int i;

   ssSetNumSFcnParams(S, 0 );

   ssSetNumContStates(S, 0);
   ssSetNumDiscStates(S, 0);

   ssSetNumInputPorts(S, 0);
   ssSetNumOutputPorts(S, 0);

   ssSetNumSampleTimes(S, 1);

   ssSetNumPWork(S, 0);

   ssSetNumModes(S, 0);
   ssSetNumNonsampledZCs(S, 0);

   ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | 
                   SS_OPTION_USE_TLC_WITH_ACCELERATOR|
                   SS_OPTION_PLACE_ASAP);

}

static void mdlInitializeSampleTimes(SimStruct *S)
{
   ssSetSampleTime(S, 0, mxGetInf() );
   ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{


}


static void mdlTerminate(SimStruct *S)
{   
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


