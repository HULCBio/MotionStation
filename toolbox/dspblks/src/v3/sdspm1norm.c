/*
 * SDSPM1NORM Compute the matrix 1-norm.
 *
 * This is the maximum column sum of absolute values,
 * in MATLAB notation: max(sum(abs(A))).
 *
 *  P. Anderson, D. Orofino
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.14 $  $Date: 2002/04/14 20:42:11 $
 */
#define S_FUNCTION_NAME sdspm1norm
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT_A=0, NUM_INPORTS}; 
enum {OUTPORT_M1NORM=0, NUM_OUTPORTS};

enum {NCOLS_ARGC=0, NUM_ARGS};
#define NCOLS_ARG (ssGetSFcnParam(S,NCOLS_ARGC))

typedef struct {
    int_T M;
    int_T N;    /* Precomputed size of matrix */
} SFcnCache;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    /* Number of columns: */
    if (OK_TO_CHECK_VAR(S, NCOLS_ARG)) {
        real_T d;

        if (!IS_FLINT(NCOLS_ARG)) {
            THROW_ERROR(S, "Number of columns must be a real scalar");
        }

        d = mxGetPr(NCOLS_ARG)[0];
        if ((d<1) && (d != -1)) {
            THROW_ERROR(S, "Number of columns must be an integer value > 0");
        }
    }
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
    
    ssSetSFcnParamNotTunable(S,NCOLS_ARGC); 
    
    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

    ssSetInputPortWidth(            S, INPORT_A, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT_A, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT_A, 1);
    ssSetInputPortReusable(         S, INPORT_A, 1);
    ssSetInputPortOverWritable(     S, INPORT_A, 0);
    
    /* Outputs: */
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;

    ssSetOutputPortWidth(        S, OUTPORT_M1NORM, 1);
    ssSetOutputPortComplexSignal(S, OUTPORT_M1NORM, COMPLEX_NO);
    ssSetOutputPortReusable(     S, OUTPORT_M1NORM, 1);
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
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
    /*
     * Cache the matrix size for efficiency.
     * Do not use IWork, as this is a "constant" which 
     * does not change throughout the simulation, and
     * there is no need to take up an IWork with this value.
     */
    const int_T     nColsArg = (int_T)mxGetPr(NCOLS_ARG)[0];
    const boolean_T isSquare = (boolean_T)(nColsArg == -1);

    const int_T MN = ssGetInputPortWidth(S,INPORT_A);
    const int_T N  = (isSquare) ? (int_T)sqrt((real_T)MN) : nColsArg;
    const int_T M  = MN / N;

    /*
     * Check for a square input matrix:
     */
    if (isSquare && (M!=N)) {
        THROW_ERROR(S, "Input matrix must be square if # cols is set to -1.");
    }

    if (M*N != MN) {
        THROW_ERROR(S, "Input width is not consistent with number of columns.");
    }

    /* Cache data for later reference: */
    CallocSFcnCache(S, SFcnCache);
    {
        SFcnCache *cache = ssGetUserData(S);
        cache->M = M;
        cache->N = N;
    }
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T  cA     = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_A) == COMPLEX_YES);
    const SFcnCache *cache  = (SFcnCache *)ssGetUserData(S);
    const int_T      M      = cache->M;
    const int_T      N      = cache->N;
    real_T	    *y      = ssGetOutputPortRealSignal(S,OUTPORT_M1NORM);
    real_T           m1norm = 0.0;
    int_T            i, j;

    if (!cA) {
       /*
        * Real input: 
        */
        InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S, INPORT_A);
        
        /* Compute maximum column (absolute value) sum */
        for(j=N; j-- > 0; ) {
            real_T sumabsAj = 0.0;
            for(i=M; i-- > 0; ) {
                sumabsAj += fabs(**uPtrs++);
            }
            m1norm = MAX(m1norm, sumabsAj);
        }
        *y = m1norm;
        
    } else {
       /*
        * Complex input:
        */
        InputPtrsType uPtrs = ssGetInputPortSignalPtrs(S, INPORT_A);
        
        for(j=N; j-- > 0; ) {
            real_T sumcabsAj = 0.0;
            for(i=M; i-- > 0; ) {
                real_T cabsAij;
                const creal_T uval = *((creal_T *)(*uPtrs++));
                CABS(uval, cabsAij);
                sumcabsAj += cabsAij;
            }
            m1norm = MAX(m1norm, sumcabsAj);
        }
        *y = m1norm;
    }
}


static void mdlTerminate(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    FreeSFcnCache(S, SFcnCache);
#endif
}


#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    /*
     * Write to the RTW file parameters which do not change during execution:
     *    pad length and number of channels
     */
    SFcnCache *cache = (SFcnCache *)ssGetUserData(S);

    if (cache != NULL) {
        if (!ssWriteRTWParamSettings(S, 2,
                                     SSWRITE_VALUE_DTYPE_NUM, "Rows",
                                     &cache->M,
                                     DTINFO(SS_INT32,0),
                                 
                                     SSWRITE_VALUE_DTYPE_NUM, "Cols",
                                     &cache->N,
                                     DTINFO(SS_INT32,0))) {
            return;
        }
    }
}
#endif


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    ssSetInputPortWidth(S, port, inputPortWidth);
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    ssSetErrorStatus(S, "Invalid output port propagation call");
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S,
                                         int_T port,
                                         CSignal_T portComplex)
{
    ssSetInputPortComplexSignal(S, port, portComplex ? COMPLEX_YES : COMPLEX_NO);
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S,
                                          int_T port,
                                          CSignal_T portComplex)
{
    ssSetErrorStatus(S, "Invalid output port complexity call");
}
#endif


#ifdef	MATLAB_MEX_FILE  
#include "simulink.c"    
#else
#include "cg_sfun.h"     
#endif

/* [EOF] sdspm1norm.c */
