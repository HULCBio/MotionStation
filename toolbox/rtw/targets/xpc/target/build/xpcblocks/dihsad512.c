/* $Revision: 1.5 $ $Date: 2002/03/25 04:06:44 $ */
/* dihsad512.c - xPC Target, non-inlined S-function driver for HS AD512 DIO section */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

/* S Function Name and Level */
#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  dihsad512

/* Includes */
#include  <stdlib.h>     /* malloc(), free(), strtoul() */
#include "simstruc.h"

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"io_xpcimport.h"
#endif

/* S Function Parameters */
#define NUM_PARAMS             (3)
#define BASE_ADDRESS_PARAM     (ssGetSFcnParam(S,0))
#define CHANNEL_SELECT_PARAM   (ssGetSFcnParam(S,1))
#define SAMPLE_TIME_PARAM      (ssGetSFcnParam(S,2))

/* Convert S Function Parameter to Varibles */
#define SAMPLE_TIME            ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[0])
#define SAMPLE_OFFSET			 ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[1])

/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlCheckParameters ===============================================
 *
 * Checks the validity of S function parameters
 */
static void mdlCheckParameters(SimStruct *S)
{
}

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
	int i = 0;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

    /* See sfuntmpl.doc for more details on the macros below */

    ssSetNumSFcnParams(S, NUM_PARAMS);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 0)) return;

    if (!ssSetNumOutputPorts(S, (mxGetNumberOfElements(CHANNEL_SELECT_PARAM)))) return;

    while (i<(mxGetNumberOfElements(CHANNEL_SELECT_PARAM))) {
		    ssSetOutputPortWidth(S, i, 1);
	       i++;
	 }
 
    ssSetNumSampleTimes(S, 1);

	ssSetSFcnParamNotTunable(S,0);
	ssSetSFcnParamNotTunable(S,1);
	ssSetSFcnParamNotTunable(S,2);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}



static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, SAMPLE_TIME);
    ssSetOffsetTime(S, 0, SAMPLE_OFFSET);

}

#define MDL_START
  static void mdlStart(SimStruct *S)
  {
#ifndef MATLAB_MEX_FILE
#endif /* MATLAB_MEX_FILE */
  }

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
  
	real_T            *y;
	 short 				 tempPortData = 0;
	 short				 i;

    /* Read in Digital Input from Hardware */

	 tempPortData = rl32eInpB((unsigned short)(((uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0]+0x7)));

	 i = 0;

    for (i=0;i < mxGetNumberOfElements(CHANNEL_SELECT_PARAM);i++) {
		 y = ssGetOutputPortRealSignal(S,i);
	    y[0] = ((tempPortData >> (((short)mxGetPr(CHANNEL_SELECT_PARAM)[i])-1))&0x01);
	 } 
#endif /* MATLAB_MEX_FILE */
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#endif /* MATLAB_MEX_FILE */
}

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
