/* $Revision: 1.9 $ $Date: 2002/03/25 04:07:41 $ */
/* dohsad512.c - xPC Target, non-inlined S-function driver for HS AD512 DIO section */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

/* S Function Name and Level */
#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  dohsad512

// Includes
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

#define THRESHOLD              	0.5

/*====================*
 * S-function methods *
 *====================*/

static void mdlCheckParameters(SimStruct *S)
{
}

static void mdlInitializeSizes(SimStruct *S)
{
	 short i = 0;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_PARAMS);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;        /* Error reported in mdlCheckParameters */
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, (mxGetNumberOfElements(CHANNEL_SELECT_PARAM)))) return;

    for (i=0;i < mxGetNumberOfElements(CHANNEL_SELECT_PARAM);i++) {
         ssSetInputPortWidth(S, i, 1);
         ssSetInputPortDirectFeedThrough(S,i,1);
    }


    if (!ssSetNumOutputPorts(S, 0)) return;
 
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
	/* Set Digital Output to Initial State */

	 rl32eOutpB((unsigned short)(((uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0]+0x7)),0);
#endif /* MATLAB_MEX_FILE */

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE	
    
	int_T             i;
    InputRealPtrsType uPtrs;
    int_T             ad512DOPortData = 0;

    /* Send Input to Digital Output */	
    ad512DOPortData = 0;


    for (i=0;i < mxGetNumberOfElements(CHANNEL_SELECT_PARAM);i++) {
		uPtrs = ssGetInputPortRealSignalPtrs(S,i);
	    if (*uPtrs[0]>=THRESHOLD) {
	    	ad512DOPortData |= (1 << (((short)mxGetPr(CHANNEL_SELECT_PARAM)[i])-1));
		}
	} 

	rl32eOutpB((unsigned short)(((uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0]+0x7)),(unsigned short)ad512DOPortData);

#endif /* METLAB_MAE_FILE */
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
	
	/* Set Final State of digital output */

   rl32eOutpB((unsigned short)((uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0]+0x7),0);

	ssSetUserData(S,NULL);

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
