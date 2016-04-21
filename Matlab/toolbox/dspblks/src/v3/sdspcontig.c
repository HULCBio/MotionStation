/*
 * SDSPCONTIG DSP Blockset CMEX S-Function to make a
 *    contiguous copy of possibly discontiguous inputs.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.9 $  $Date: 2002/04/14 20:42:06 $
 */
#define S_FUNCTION_NAME sdspcontig
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
#endif

    if (!ssSetNumInputPorts( S,NUM_INPORTS)) return;

    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 1);
    ssSetInputPortReusable(        S, INPORT, 1); 

    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;

    ssSetOutputPortWidth(           S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(   S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(       S, OUTPORT, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE |
                        SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T needCopy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT) != OUTPORT);

    if (needCopy) {
	const boolean_T cplx = (ssGetOutputPortComplexSignal(S,OUTPORT) == COMPLEX_YES);
	int_T           N    = ssGetOutputPortWidth(S,OUTPORT);

	if (cplx) {
	    InputPtrsType uptr = ssGetInputPortSignalPtrs(S,INPORT);
	    creal_T       *y   = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
	    while(N-- > 0) {
		*y++ = *((creal_T *)(*uptr++));
	    }
	} else {
	    InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S,INPORT);
	    real_T            *y   = ssGetOutputPortRealSignal(S,OUTPORT);
	    while(N-- > 0) {
		*y++ = **uptr++;
	    }
	}
    }
}


static void mdlTerminate(SimStruct *S)
{
}


/* Complex handshake: */
#include "dsp_cplxhs11.c"


#ifdef	MATLAB_MEX_FILE  
#include "simulink.c"    
#else
#include "cg_sfun.h"     
#endif
