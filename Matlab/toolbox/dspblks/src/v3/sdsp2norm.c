/*
 * SDSP2NORM Normalize input by the vector 2-norm.
 *   Can choose norm or norm-squared normalization, where
 *   the norm requires a square-root.
 *
 *  BIAS: Any scalar, generally a small positive number (1e-10)
 *  SQR: An enumeration, 1="2-norm", 2="squared 2-norm"
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.15 $  $Date: 2002/04/14 20:43:14 $
 */
#define S_FUNCTION_NAME sdsp2norm
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "dsp_sim.h"

enum {INPORT=0}; 
enum {OUTPORT=0}; 
typedef enum {NORM=1, NORMSQ} NormType;

enum {BIAS_ARGC=0, SQR_ARGC, NUM_ARGS};

#define BIAS_ARG (ssGetSFcnParam(S,BIAS_ARGC))
#define SQR_ARG  (ssGetSFcnParam(S,SQR_ARGC))


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
        static char *msg;
	real_T d;
	int_T  i;

        msg = NULL;

	if (mxGetNumberOfElements(BIAS_ARG) != 1) {
            msg = "Bias must be a scalar";
	    goto FCN_EXIT;
	}

	if (mxGetNumberOfElements(SQR_ARG) != 1) {
            msg = "Squared-norm flag must be a scalar";
	    goto FCN_EXIT;
	}

	d = mxGetPr(SQR_ARG)[0];
	i = (int_T)d;
	if ((d!=i) || ((i!=1)&&(i!=2))) {
            msg = "Squared-norm flag must be 1 (2-norm) or 2 (squared 2-norm)";
	    goto FCN_EXIT;
	}

FCN_EXIT:
    ssSetErrorStatus(S, msg);
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S,  NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* Not tunable in RTW generated code. */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        
        ssSetSFcnParamNotTunable(S, SQR_ARGC);
        ssSetSFcnParamNotTunable(S, BIAS_ARGC);
    }

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortReusable(        S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 1);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(    S, OUTPORT, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T inplace = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT) == OUTPORT);
    const boolean_T c0      = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const NormType  sqr     = (NormType)((int_T)mxGetPr(SQR_ARG)[0]);
    const real_T    b       = mxGetPr(BIAS_ARG)[0];
    const int_T     N       = ssGetInputPortWidth(S,INPORT);
    real_T          E       = 0.0;
    int_T           i;

    if (!c0) {
        /*
         * Real input: 
         */
        if (inplace) {
            real_T *y = ssGetOutputPortRealSignal(S,OUTPORT);

            /* Determine energy (sum of squares): */
            for(i=N; i-- > 0; ) {
	        real_T u = *y++;
	        E += u*u;
            }
            if (sqr == NORM) {
                E = sqrt(E);
            }
            /* Normalize input vector: */
            E = 1.0 / (E + b);

            y -= N;
            for(i=N; i-- > 0; ) {
	        *y++ *= E;
            }

        } else {
            /* Separate input/output spaces, or discontiguous: */

            InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,INPORT);
            real_T	      *y    = ssGetOutputPortRealSignal(S,OUTPORT);

            /* Determine energy (sum of squares): */
            for(i=N; i-- > 0; ) {
	        real_T u = **uptr++;
	        E += u*u;
            }
            if (sqr == NORM) {
                E = sqrt(E);
            }
            /* Normalize input vector: */
            E = 1.0 / (E + b);

            uptr = ssGetInputPortRealSignalPtrs(S,0);
            for(i=N; i-- > 0; ) {
	        *y++ = **uptr++ * E;
            }
        }

    } else {
        /*
         * Complex input:
         */
        if (inplace) {
            creal_T *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);

            /* Determine energy: */
            for (i=N; i-- > 0; ) {
                const creal_T u = *y++;
                E += CMAGSQ(u);
            }
            if (sqr == NORM) {
                E = sqrt(E);  /* 2-norm */
            }
            /* Normalize input vector: */
            E = 1.0 / (E + b);

            y -= N;
            for(i=N; i-- > 0; ) {
	        y->re     *= E;
                (y++)->im *= E;
            }

        } else {
            /* Separate input/output spaces, or discontiguous: */

            InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT);
            creal_T	  *y    = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);

            /* Determine energy: */
            for (i=N; i-- > 0; ) {
                const creal_T *u = (creal_T *)(*uptr++);
                E += CMAGSQ(*u);
            }
            if (sqr == NORM) {
                E = sqrt(E);  /* 2-norm */
            }
            /* Normalize input vector: */
            E = 1.0 / (E + b);

            uptr = ssGetInputPortSignalPtrs(S,0);
            for(i=N; i-- > 0; ) {
                const creal_T *u = (creal_T *)(*uptr++);
	        y->re     = u->re * E;
                (y++)->im = u->im * E;
            }
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}

#include "dsp_cplxhs11.c"   

#ifdef	MATLAB_MEX_FILE  
#include "simulink.c"    
#else
#include "cg_sfun.h"     
#endif
