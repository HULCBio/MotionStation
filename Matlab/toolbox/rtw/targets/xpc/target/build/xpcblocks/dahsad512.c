/* $Revision: 1.8 $ $Date: 2002/03/25 04:05:59 $ */
/* dahsad512.c - xPC Target, non-inlined S-function driver for HS AD512 D/A section */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  dahsad512
									    
// Includes
#include  <stdlib.h>     /* malloc(), free(), strtoul() */
#include "simstruc.h"

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"io_xpcimport.h"
#endif


// S function parameters 
#define NUM_PARAMS             (4)
#define BASE_ADDRESS_PARAM     (ssGetSFcnParam(S,0))
#define CHANNEL_SELECT_PARAM   (ssGetSFcnParam(S,1))
#define RANGE_PARAM            (ssGetSFcnParam(S,2))
#define SAMPLE_TIME_PARAM      (ssGetSFcnParam(S,3))

#define NO_I_WORKS                      (0)

#define NO_R_WORKS                      (4)


// Buffer for any error messages
static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	short i =0;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

  ssSetNumSFcnParams(S, NUM_PARAMS);  /* Number of expected parameters */
  if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
    sprintf(msg,"Wrong number of input arguments passed.\nFour arguments are expected\n");
    ssSetErrorStatus(S,msg);
    return;
  }

  ssSetNumContStates(S, 0);
  ssSetNumDiscStates(S, 0);

  if (!ssSetNumInputPorts(S, (mxGetNumberOfElements(CHANNEL_SELECT_PARAM)))) return;

  for (i=0;i < (mxGetN(CHANNEL_SELECT_PARAM));i++) {
       ssSetInputPortWidth(S, i, 1);
       ssSetInputPortDirectFeedThrough(S,i,1);
  }

  if (!ssSetNumOutputPorts(S, 0)) return;
 
  ssSetNumSampleTimes(S, 1);

  ssSetNumRWork(S, NO_R_WORKS);
  ssSetNumIWork(S, NO_I_WORKS); 
  ssSetNumPWork(S, 0);


  ssSetSFcnParamNotTunable(S,0);
  ssSetSFcnParamNotTunable(S,1);
  ssSetSFcnParamNotTunable(S,2);
  ssSetSFcnParamNotTunable(S,3);

  ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
        ssSetSampleTime(S, 0, mxGetPr(SAMPLE_TIME_PARAM)[0]);
        if (mxGetN((SAMPLE_TIME_PARAM)) > 1) {
        	ssSetOffsetTime(S, 0, mxGetPr(SAMPLE_TIME_PARAM)[1]);
		} else {
			ssSetOffsetTime(S, 0, 0.0);
		}
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
  int_T i,j,ba,counts;
  real_T value,offset,gain = 0;

  ba = (uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0];

  for (i=0;i<mxGetN(CHANNEL_SELECT_PARAM);i++) {
    j = (int_T)mxGetPr(CHANNEL_SELECT_PARAM)[i] - 1;
    if (mxGetPr(RANGE_PARAM)[i] < 0) {
      ssSetRWorkValue(S,(j*2+0),(-1.0 * mxGetPr(RANGE_PARAM)[i]));
      ssSetRWorkValue(S,(j*2+1),(4096 / (-2.0 * mxGetPr(RANGE_PARAM)[i])));
    } else {
      ssSetRWorkValue(S,(j*2+0),0);
      ssSetRWorkValue(S,(j*2+1),(4096 / mxGetPr(RANGE_PARAM)[i]));
    }
  }

  /* Set inital state to zero */
  for (i=0;i < mxGetNumberOfElements(CHANNEL_SELECT_PARAM);i++) {
        j = (int_T)mxGetPr(CHANNEL_SELECT_PARAM)[i] - 1;
	value = 0;
	offset = ssGetRWorkValue(S,(j*2+0));
	gain = ssGetRWorkValue(S,(j*2+1));
	counts=(value+offset)*gain;
        if (counts>4095) counts=4095;
        if (counts<0)    counts=0;
        rl32eOutpB((unsigned short)(ba+(j*2)+0),(unsigned short)(counts  & 0x00ff));
        rl32eOutpB((unsigned short)(ba+(j*2)+1),(unsigned short)((counts >> 8) & 0x000f));
  }

  rl32eOutpB((unsigned short)(ba+0x04),0x01);

#endif /* MATLAB_MEX_FILE */

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

  InputRealPtrsType	uPtrs;
  int_T				i, j, ba, counts;
  real_T			gain, offset;
  real_T			value;

  /* d/a convesion */
  i = 0;
  ba = (uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0];

  for (i=0;i < (mxGetN(CHANNEL_SELECT_PARAM));i++) {
	uPtrs=ssGetInputPortRealSignalPtrs(S,i);
    j = (int_T)mxGetPr(CHANNEL_SELECT_PARAM)[i] - 1;
	value=*uPtrs[0];
	offset = ssGetRWorkValue(S,(j*2+0));
	gain = ssGetRWorkValue(S,(j*2+1));
    counts = (value + offset) * gain;
    if (counts>4095) counts=4095;
    if (counts<0)    counts=0;
    rl32eOutpB((unsigned short)(ba+(j*2)+0),(unsigned short)(counts  & 0x00ff));
    rl32eOutpB((unsigned short)(ba+(j*2)+1),(unsigned short)((counts >> 8) & 0x000f));
  }

  rl32eOutpB((unsigned short)(ba+0x04),0x01);

#endif /* MATLAB_MEX_FILE */

}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
	
  int_T i, j, ba, counts;
  real_T gain, offset;
  real_T value;

  ba = (uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0];

  /* Set final state to zero */
  for (i=0;i < mxGetNumberOfElements(CHANNEL_SELECT_PARAM);i++) {
    j = (int_T)mxGetPr(CHANNEL_SELECT_PARAM)[i] - 1;
	value = 0;
	offset = ssGetRWorkValue(S,(j*2+0));
	gain = ssGetRWorkValue(S,(j*2+1));
	counts=(value+offset)*gain;
    if (counts>4095) counts=4095;
    if (counts<0)    counts=0;
    rl32eOutpB((unsigned short)(ba+(j*2)+0),(unsigned short)(counts  & 0x00ff));
    rl32eOutpB((unsigned short)(ba+(j*2)+1),(unsigned short)((counts >> 8) & 0x000f));
  }
  rl32eOutpB((unsigned short)(ba+0x04),0x01);
#endif
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
