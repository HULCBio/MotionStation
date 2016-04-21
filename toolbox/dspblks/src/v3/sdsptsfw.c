/*
 * SDSPTSFW DSP Blockset triggered signal from workspace block.
 *
 *   
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.13.4.1 $  $Date: 2004/01/25 22:39:42 $
 */
#define S_FUNCTION_NAME  sdsptsfw
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

/*
 * ----------------------------------------------------------
 * Simulink/RTW zero-crossing detector function prototype:
 *
 * OBSOLETE FOR DSP BLOCKSET 5.0 (Release 13) AND LATER
 * THIS IS JUST FOR CERTAIN S-FCNS FROM RELEASE 11.x !!!
 * ----------------------------------------------------------
 */
extern ZCEventType rt_ZCFcn(ZCDirection direction,
                            ZCSigState *prevSigState, 
                            real_T      zcSig);

enum {WKS_ARGC=0, CYCLE_ARGC, IC_ARGC, TRIGTYPE_ARGC, NSAMPS_ARGC, NUM_ARGS};
#define WKS_ARG      ssGetSFcnParam(S,WKS_ARGC)
#define CYCLE_ARG    ssGetSFcnParam(S,CYCLE_ARGC)
#define IC_ARG       ssGetSFcnParam(S,IC_ARGC)
#define TRIGTYPE_ARG ssGetSFcnParam(S,TRIGTYPE_ARGC)
#define NSAMPS_ARG   ssGetSFcnParam(S,NSAMPS_ARGC)

enum {TRIGPORT=0, NUM_INPORTS};
enum {OUTPORT=0,  NUM_OUTPORTS};

enum {PREV_TRIG_STATE=0, ROW_IDX, NUM_IWORK};

/* This PWORKs is here only for code generation purposes */
enum {SIGNAL_PTR=0, NUM_PWORK};


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    real_T d;

    if (!mxIsNumeric(WKS_ARG) || mxIsSparse(WKS_ARG) || mxIsEmpty(WKS_ARG)) {
	THROW_ERROR(S, "Matrix must be full, non-empty, and numeric.");
    }

    if (!IS_DOUBLE_NEW(WKS_ARG)) {
	THROW_ERROR(S, "Signal parameter data type not supported.");
    }

    if (mxGetNumberOfElements(CYCLE_ARG) != 1) {
        THROW_ERROR(S, "Cycle must be a scalar");
    }
    d = mxGetPr(CYCLE_ARG)[0];
    if ((d!=0.0) && (d!=1.0)) {
        THROW_ERROR(S, "Cycle must be 0=off or 1=on");
    }

    if (!mxIsNumeric(IC_ARG) || mxIsSparse(IC_ARG)) {
	THROW_ERROR(S, "Initial conditions must be numeric.");
    }
    if ((mxGetM(IC_ARG)>1) && (mxGetN(IC_ARG)>1)) {
	THROW_ERROR(S, "Initial condition must be a scalar or vector.");
    }

    if (mxGetNumberOfElements(TRIGTYPE_ARG) != 1) {
        THROW_ERROR(S, "Trigger type must be a scalar");
    }
    d = mxGetPr(TRIGTYPE_ARG)[0];
    if ((d!=1.0) && (d!=2.0) && (d!=3.0)) {
        THROW_ERROR(S, "Trigger type must be 1=rising, 2=falling, or 3=either");
    }

    if (mxGetNumberOfElements(NSAMPS_ARG) != 1) {
        THROW_ERROR(S, "Number of samples must be a scalar");
    }
    d = mxGetPr(NSAMPS_ARG)[0];
    if (d!=floor(d)) {
        THROW_ERROR(S, "Number of samples must be an integer value");
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /*
     * Changing workspace matrix during simulation could cause a change
     *   from complex from real, etc., causing problems.
     * Likewise, a change in the cyclic parameter might have unpredictable
     *   results during simulation: once it is in "cyclic" mode, a change
     *   back to non-cyclic does not have the expected effect.
     * Trigger type is valid to change, as are the IC's.
     */
    ssSetSFcnParamNotTunable(S, WKS_ARGC);
    ssSetSFcnParamNotTunable(S, CYCLE_ARGC);

    /* TrigType and ICs are not tunable in RTW generated code. */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        
        ssSetSFcnParamNotTunable(S, TRIGTYPE_ARGC);
        ssSetSFcnParamNotTunable(S, IC_ARGC);
        
    }

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

    ssSetInputPortWidth	(           S, TRIGPORT, 1);
    ssSetInputPortDirectFeedThrough(S, TRIGPORT, 1);
    ssSetInputPortComplexSignal(    S, TRIGPORT, COMPLEX_NO);
    ssSetInputPortReusable(        S, TRIGPORT, 1);
    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;

    ssSetOutputPortWidth(        S, OUTPORT, mxGetN(WKS_ARG));
    ssSetOutputPortComplexSignal(S, OUTPORT, mxIsComplex(WKS_ARG) ? COMPLEX_YES : COMPLEX_NO);
    ssSetOutputPortReusable(    S, OUTPORT, 0);  /* triggered - need to maintain output data */

    ssSetNumPWork(      S, NUM_PWORK);
    ssSetNumIWork(      S, NUM_IWORK);
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    {
	const boolean_T cplx = (ssGetOutputPortComplexSignal(S,OUTPORT) == COMPLEX_YES);
	if (!cplx && mxIsComplex(IC_ARG)) {
	    THROW_ERROR(S, "Initial conditions must be real if workspace data is real.");
	}
    }
    {
	int_T M        = mxGetM(IC_ARG);
	int_T N        = mxGetN(IC_ARG);
        int_T numEle   = M*N;
	int_T outWidth = ssGetOutputPortWidth(S,OUTPORT);
        int_T nSamps   = mxGetPr(NSAMPS_ARG)[0];

        if (numEle > 1) {
            /* Not a scalar or an empty - check IC size */

            if (nSamps == 1) {
                /* non-frame based - IC's must now be the same size as the rows in Signal (WKS_ARG) */
                if (!( ((M==1) && (N==outWidth)) ||
                       ((N==1) && (M==outWidth))  )) {
                    THROW_ERROR(S, "Initial condition vector has an incorrect number of elements.");
                }

            } else {
                /* frame based - IC's can be either:
                 *   - the whole buffered matrix (M*N==outWidth)
                 *   - one channel of IC to be repeated (nSamps)
                 */
                if ((numEle != outWidth) && (numEle != nSamps)) {
                    THROW_ERROR(S, "Initial condition vector has an incorrect number of elements.");
                }
            }
        }
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    /*
     * Initialize output:
     */
    const boolean_T portCplx = (ssGetOutputPortComplexSignal(S,OUTPORT) == COMPLEX_YES);

    /* Get real output pointer, even if complex: */
    real_T *y        = (real_T *)ssGetOutputPortSignal(S,OUTPORT);
    int_T   outWidth = ssGetOutputPortWidth(S,OUTPORT);
    int_T   nSamps   = mxGetPr(NSAMPS_ARG)[0];
    int_T   ICele    = mxGetNumberOfElements(IC_ARG);

    if (ICele <= 1) {
	real_T icre, icim;

	if (mxIsEmpty(IC_ARG)) {
	    icre = icim = 0.0;
	} else {
	    icre = mxGetPr(IC_ARG)[0];
	    icim = mxIsComplex(IC_ARG) ? mxGetPi(IC_ARG)[0] : 0.0;
	}

	while(outWidth-- > 0) {
	    *y++ = icre;
	    if (portCplx) {
		*y++ = icim;
	    }
	}

    } else if ((nSamps > 1) && (ICele != outWidth)) {
        /* Vector of IC's to be replicated over each channel: */

        int_T nChans = outWidth / nSamps;
	while(nChans-- > 0) {
	    real_T *pre = mxGetPr(IC_ARG);
	    real_T *pim = mxGetPi(IC_ARG);
            int_T i;
            for (i=0; i<nSamps; i++) {
	        *y++ = *pre++;
	        if (portCplx) {
		    *y++ = (pim==NULL) ? 0.0 : *pim++;
	        }
            }
	}

    } else {
        /* Matrix IC's: */
	real_T *pre = mxGetPr(IC_ARG);
	real_T *pim = mxGetPi(IC_ARG);
	while(outWidth-- > 0) {
	    *y++ = *pre++;
	    if (portCplx) {
		*y++ = (pim==NULL) ? 0.0 : *pim++;
	    }
	}
    }

    /*
     * Initialize state:
     */
    ssSetIWorkValue(S, PREV_TRIG_STATE, UNINITIALIZED_ZCSIG);
    ssSetIWorkValue(S, ROW_IDX, 0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    ZCEventType isTrig;

    {
        /* Determine triggering operation: */
        int_T       mask_dir = (int_T)mxGetPr(TRIGTYPE_ARG)[0];
        ZCDirection zc_dir   = (mask_dir==1) ? RISING_ZERO_CROSSING :
			       (mask_dir==2) ? FALLING_ZERO_CROSSING : ANY_ZERO_CROSSING;

        InputRealPtrsType trig_in = ssGetInputPortRealSignalPtrs(S, TRIGPORT);
        isTrig = rt_ZCFcn(zc_dir, (ZCSigState *)ssGetIWork(S) + PREV_TRIG_STATE, **trig_in);
    }

    if (isTrig) {
        const boolean_T portCplx = (ssGetOutputPortComplexSignal(S,OUTPORT) == COMPLEX_YES);
	const int_T     N        = ssGetOutputPortWidth(S,OUTPORT);
	const boolean_T cyclic   = (mxGetPr(CYCLE_ARG)[0] != 0);
	const int_T     Mwks     = mxGetM(WKS_ARG);
	int_T * const   rowIdx   = ssGetIWork(S) + ROW_IDX;
	const int_T     outIdx   = *rowIdx;

	/* Get real output pointer, even if complex: */
        real_T *y = (real_T *)ssGetOutputPortSignal(S,OUTPORT);

	if (outIdx < Mwks) {
	    /*
	     * Output next matrix row:
	     */
	    real_T *pre = mxGetPr(WKS_ARG);
	    real_T *pim = mxGetPi(WKS_ARG);
	    int_T   i;
	    for (i = 0; i < N; i++) {
		*y++ = *(pre + outIdx + i*Mwks);
		if (portCplx) {
		    *y++ = (pim == NULL) ? 0.0 : *(pim + outIdx + i*Mwks);
		}
	    }

	} else {
	    /*
	     * Zero extend output:
	     */
	    int_T i;
	    for (i = 0; i < N; i++) {
		*y++ = 0.0;
		if (portCplx) *y++ = 0.0;
	    }
	}

	/* Update row index for next read: */
	(*rowIdx)++;
	if (cyclic && (*rowIdx == Mwks)) *rowIdx = 0;
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] sdsptsfw.c */
