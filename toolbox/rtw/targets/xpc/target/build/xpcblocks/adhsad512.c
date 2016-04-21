/* $Revision: 1.6 $ $Date: 2002/03/25 03:59:45 $ */
/* adhsad512.c - xPC Target, non-inlined S-function driver for HS AD512 A/D section */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  adhsad512  	   


/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */

#include  	<stdlib.h>     /* malloc(), free(), strtoul() */
#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"io_xpcimport.h"
#endif


/* S Function Parameters */

#define NUM_PARAMS             (4)
#define BASE_ADDRESS_PARAM     (ssGetSFcnParam(S,0))
#define CHANNEL_SELECT_PARAM   (ssGetSFcnParam(S,1))
#define RANGE_PARAM 	         (ssGetSFcnParam(S,2))
#define SAMPLE_TIME_PARAM      (ssGetSFcnParam(S,3))

/* Convert S Function Parameter to Varibles */

#define NUM_CHANNEL            ((int_T)   mxGetPr(NUM_CHANNEL_PARAM)[0])
#define SAMPLE_TIME            ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[0])
#define SAMPLE_OFFSET          ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[1])

static char_T msg[256];


/*====================*
 * S-function methods *
 *====================*/

static void mdlCheckParameters(SimStruct *S)
{
}

static void mdlInitializeSizes(SimStruct *S)
{
	short 	i = 0;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif


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

    if (!ssSetNumOutputPorts(S, mxGetNumberOfElements(CHANNEL_SELECT_PARAM))) return;

    while (i<(mxGetNumberOfElements(CHANNEL_SELECT_PARAM))) {
		    ssSetOutputPortWidth(S, i, 1);
	       i++;
	 }

    ssSetNumSampleTimes(S, 1);


    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

	ssSetSFcnParamNotTunable(S,0);
	ssSetSFcnParamNotTunable(S,1);
	ssSetSFcnParamNotTunable(S,2);
	ssSetSFcnParamNotTunable(S,3);

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

	uint_T myTimeout;
	short  adParameters = 0;

	/* Check That The Hardware is functioning */

	/* Setup DACTRL Parameters */
   adParameters = 0x40;
	rl32eOutpB ((unsigned short)((uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0] + 0x05), adParameters);

	/* Test A/D conversion */
	myTimeout = 0;
   while (rl32eInpB((unsigned short)(((uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0]) + 0x05)) & 0x80) {
      myTimeout++;
      if (myTimeout >= 100) {
      	sprintf(msg,"%s (0x%x): test A/D conversion failed", "HS A/D AD512", (uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0]);
		ssSetErrorStatus(S,msg);
         return;
      } 
   }   

#endif /* MATLAB_MEX_FIlE */

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	 real_T        *y;
	 short				 adParameters = 0;
	 real_T        tempPortData = 0;
	 short				 i = 0;
	 uint_T				 baseAddr=(uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0];
   double        rangeIncrement = 0;
   real_T        rangeOffset = 0;

	 /* A/D conversion */

	for (i=0; i< mxGetNumberOfElements(CHANNEL_SELECT_PARAM); i++) {

		// set A/D control register and start conversion
		adParameters = 0x40;
 		adParameters |= (((short)mxGetPr(CHANNEL_SELECT_PARAM)[i])-1);

		if (((short)mxGetPr(RANGE_PARAM)[i]) < 0) {
			adParameters |= 0x08; /* USED FOR BIP */
		  rangeOffset = 0;
      rangeIncrement = -1.0* (mxGetPr(RANGE_PARAM)[i] * 2.0) / 4096.0;
    } else {
      rangeOffset = 0;
      rangeIncrement = (mxGetPr(RANGE_PARAM)[i] / 4096.0);  
    }
		if (abs(((short)mxGetPr(RANGE_PARAM)[i])) > 5) {
			adParameters |= 0x10; /* USED FOR RNG */
		}

		rl32eOutpB((unsigned short)((uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0] + 0x05), adParameters);

		/* Wait while the anolog rl32eInpBut is being converted */
		while (rl32eInpB((unsigned short)((uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0] + 0x05)) & 0x80);

		// get converted value
		y = ssGetOutputPortRealSignal(S,i);

    		

    tempPortData = (short)rl32eInpW((unsigned short)((uint_T)mxGetPr(BASE_ADDRESS_PARAM)[0]));
    tempPortData = (tempPortData + rangeOffset) * rangeIncrement; 
    // tempPortData = rangeIncrement;
		y[0] = tempPortData;

	}

#endif /* MATLAB_MEX_FIlE */

}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#endif /* MATLAB_MEX_FIlE */
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
