/*
 * SDSPMDN DSP Blockset S-Function for computing the median value
 * of real and complex inputs.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.17 $  $Date: 2002/04/14 20:44:40 $
 */

#define S_FUNCTION_NAME sdspmdn
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"
#include "dspsrt_rt.h"

#define NUM_ARGS  (0)

enum {SORT_IN_IDX=0, MAX_NUM_DWORKS};

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
#endif

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(            S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortComplexSignal(    S, 0, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, 0, 1);
    ssSetInputPortOverWritable(     S, 0, 0);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(        S, 0, 1);
    ssSetOutputPortComplexSignal(S, 0, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, 0, 1);

    ssSetNumIWork(S, DYNAMICALLY_SIZED);
    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;


    ssSetNumSampleTimes(   S, 1);
    ssSetOptions(          S, SS_OPTION_EXCEPTION_FREE_CODE |
                           SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    /* 
     * Initialize sort indices to ascending integers in range [0,N-1].
     * After that, the integers are in a "random" order, which
     * is efficient for sorting purposes on subsequent calls.
     */
    const int_T  N     = ssGetInputPortWidth(S,0);
    int_T       *index = ssGetIWork(S);
    int_T        i;

    for (i=0; i < N; i++) {
        *index++ = i;
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T      N       = ssGetInputPortWidth(S,0);
    const boolean_T  c0      = (boolean_T)(ssGetInputPortComplexSignal(S,0) == COMPLEX_YES);
    int_T           *index   = ssGetIWork(S);
    real_T          *sort_in = (real_T *)ssGetDWork(S, SORT_IN_IDX);
    int_T            i       = N;

    /*
     * Copy (possibly discontiguous) inputs to a scratch area:
     *
     * For all inputs, the scratch will be RWork 
     * because we can GUARANTEE sufficient alloc space.
     *
     * For complex inputs, copy the MAGNITUDE-SQUARED values 
     * instead of the complex values.
     * 
     * Now we'll have contiguous real-valued input to the sort fcn
     */
    if (!c0) {
        InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,0);
        
        while (i-- > 0) {
            *sort_in++ = **uptr++;
        }
    } else {
        InputPtrsType uptr = ssGetInputPortSignalPtrs(S,0);
        
        while (i-- > 0) {
            creal_T *val = (creal_T *)(*uptr++);
            *sort_in++ = CMAGSQ(*val);
        }
    }
    sort_in -= N;
    
    /* Sort input vector: */
    MWDSP_SrtQkRecD(sort_in, index, 0, N-1);  
    

    if (!c0) {
        /* 
         * Real input: 
         */
        InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,0);
        real_T            *y    = ssGetOutputPortRealSignal(S,0);
        
        if (N % 2 == 0) {
            /* Even number of elements - interpolate: */
            *y = 0.5 * (*uptr[index[N/2-1]] + *uptr[index[N/2]]);
        } else {
            *y = *uptr[index[(N-1)/2]];
        }

    } else {
        /* 
         * Complex input: 
         */
        InputPtrsType uptr = ssGetInputPortSignalPtrs(S,0);
        creal_T *y = (creal_T *)ssGetOutputPortSignal(S,0);

        if (N % 2 == 0) {
            /* Even number of elements - interpolate: */
            creal_T *u0 = (creal_T *)(uptr[index[N/2-1]]);
            creal_T *u1 = (creal_T *)(uptr[index[N/2]]);

            y->re = 0.5 * (u0->re + u1->re);
            y->im = 0.5 * (u0->im + u1->im);

        } else {

            *y = *(creal_T *)(uptr[index[(N-1)/2]]);
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}


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
    /* This case should never be called since the output
     * width is defined as a scalar in initialize sizes
     */
    ssSetErrorStatus(S,"Invalid output port propagation call for Median block.");
    return;
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    /* Declare storage for sorted indices: */
    const int_T N    = ssGetInputPortWidth(S,0);
    
    ssSetNumIWork(S, N);

    if(!ssSetNumDWork(          S, 1)) return;
    ssSetDWorkWidth(        S, SORT_IN_IDX, N);
    ssSetDWorkDataType(     S, SORT_IN_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, SORT_IN_IDX, COMPLEX_NO);
    ssSetDWorkName(         S, SORT_IN_IDX, "Sort_In");
    /* ssSetDWorkUsedAsDState( S, SORT_IN_IDX, 1); */
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal);  
    ssSetOutputPortComplexSignal(S, 0, iPortComplexSignal);  
}


#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx, 
                                          CSignal_T oPortComplexSignal)
{
    ssSetOutputPortComplexSignal(S, portIdx, oPortComplexSignal);  
    ssSetInputPortComplexSignal(S, 0, oPortComplexSignal);
}
#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
