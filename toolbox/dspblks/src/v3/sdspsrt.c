/*
 * SDSPSRT DSP Blockset S-Function for sorting real and complex vectors
 *
 *  Updated: D. Orofino
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.16 $  $Date: 2002/04/14 20:44:43 $
 */
#define S_FUNCTION_NAME sdspsrt
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"
#include "dspsrt_rt.h"

enum {FCN_TYPE_ARGC=0, OUT_TYPE_ARGC, NUM_ARGS};
#define FCN_TYPE_ARG ssGetSFcnParam(S,FCN_TYPE_ARGC)
#define OUT_TYPE_ARG ssGetSFcnParam(S,OUT_TYPE_ARGC)

typedef enum {
    fcnAscend  = 1,
    fcnDescend
} FcnType;

typedef enum {
    outValandIdx = 1,
    outVal, 
    outIdx
} OutType;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    /*
     * Function parameter is a scalar double: 0=ascending, 1=descending, only:
     */
    if(!IS_FLINT_IN_RANGE(FCN_TYPE_ARG,1,2)) {
        THROW_ERROR(S, "Function argument must be 1 (ascending), 2 (descending).");
    }

     /*
     * Output type argument is a scalar double: 1=ValandIdx, 2=Val, 3=Idx 
     */
    if(!IS_FLINT_IN_RANGE(OUT_TYPE_ARG,1,3)) {
        THROW_ERROR(S, "Output type argument must be in the range [1:3].");
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

    /* Output type is not tunable because it changes the number of output ports. */
    ssSetSFcnParamNotTunable(S, OUT_TYPE_ARGC);

    /* Not tunable in RTW generated code. */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        
        ssSetSFcnParamNotTunable(S, FCN_TYPE_ARGC);
    }


    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(            S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortComplexSignal(    S, 0, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, 0, 1);
    ssSetInputPortOverWritable(     S, 0, 0);

    /* Outputs: */
    {
        const OutType otype = (OutType)((int_T)mxGetPr(OUT_TYPE_ARG)[0]);
        const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);

        /* Determine number of ports: */ 
        if (otype == outValandIdx) {
            if (!ssSetNumOutputPorts(S,2)) return;
            ssSetOutputPortWidth(        S, 1, DYNAMICALLY_SIZED);   /* 2nd port: Idx */
            ssSetOutputPortComplexSignal(S, 1, COMPLEX_NO);
            ssSetOutputPortReusable(    S, 1, 1);
        } else {
            if (!ssSetNumOutputPorts(S,1)) return;
        }

        ssSetOutputPortWidth(        S, 0, DYNAMICALLY_SIZED);   /* 1st port */
        ssSetOutputPortComplexSignal(S, 0, (otype == outIdx) ? COMPLEX_NO : COMPLEX_INHERITED);
        ssSetOutputPortReusable(    S, 0, 1);
    }

    ssSetNumIWork(         S, DYNAMICALLY_SIZED);
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
    const int_T    N     = ssGetInputPortWidth(S,0);
    const int_T    c0    = ssGetInputPortComplexSignal(S,0);
    const FcnType  ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const OutType  otype = (OutType)((int_T)mxGetPr(OUT_TYPE_ARG)[0]);
    int_T         *index = ssGetIWork(S);
    int_T          i;

    /*
     * Copy (possibly discontiguous) inputs to a scratch area
     * The scratch will be the output region, because we can GUARANTEE sufficient alloc space.
     * For complex, copy the MAGNITUDE-SQUARED values instead of the complex values.
     */
    {
        /* contiguous real-valued input to the sort fcn */
        real_T *sort_in = (real_T *)(ssGetOutputPortSignal(S,0));

        if (!c0) {
            InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S,0);
            for(i=0; i<N; i++) {
                *sort_in++ = **uptr++;
            }

        } else {
            InputPtrsType uptr = ssGetInputPortSignalPtrs(S,0);
            for(i=0; i<N; i++) {
                creal_T *val = (creal_T *)(*uptr++);
                *sort_in++ = CMAGSQ(*val);
            }
        }
        sort_in -= N;

        /* Sort input vector: */
        MWDSP_SrtQkRecD(sort_in, index, 0, N-1);

    }

    if (!c0) {
        /* 
         * Real input: 
         */
        InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,0);
        real_T            *y    = ssGetOutputPortRealSignal(S,0);

        switch(ftype) {
            case fcnAscend:
            {
                if(otype == outIdx) {
                    /* Output the sorted indices (outIdx) */
                    for (i=0; i<N; i++) {
                        *y++ = (real_T)(index[i]+1); /* Convert to MATLAB 1-based indexing */
                    }

                } else {
                    /* Output the sorted values (outVal or outValandIdx) */
                    for(i=0; i<N; i++) {
                        *y++ = *uptr[index[i]];
                    }


                    if (otype == outValandIdx) {
                        /* Output sorted indices in the second output port */
                        real_T *y1 = ssGetOutputPortRealSignal(S,1);

                        for (i=0; i<N; i++) {
                            *y1++ = (real_T)(index[i]+1);  /* Convert to MATLAB 1-based indexing */
                        }
                    }
                }
            } 
            break;

            case fcnDescend:
            {
                if (otype == outIdx) {
                    /* outIdx */
                    for(i=N-1; i>=0; i--) {
                        *y++ = (real_T)(index[i]+1); /* Convert to MATLAB 1-based indexing */
                    }

                } else {
                    /* outVal or outValandIdx */
                    for(i=N-1; i>=0; i--) {
                        *y++ = *uptr[index[i]];
                    }

                    if (otype == outValandIdx) {
                        real_T *y1 = ssGetOutputPortRealSignal(S,1);

                        for(i=N-1; i>=0; i--) {
                            *y1++ = (real_T)(index[i]+1); /* Convert to MATLAB 1-based indexing */
                        }
                    }
                }
            }
            break;
        }

    } else {
        /* 
         * Complex input: 
         */
        InputPtrsType uptr = ssGetInputPortSignalPtrs(S,0);

        switch(ftype) {
            case fcnAscend:
            {
                if (otype == outIdx) {
                    real_T *y = ssGetOutputPortRealSignal(S,0);
                    
                    for (i=0; i<N; i++) {
                        *y++ = (real_T)(index[i]+1); /* Convert to MATLAB 1-based indexing */
                    }

                } else {
                    /* outVal or outValandIdx */
                    creal_T *y = (creal_T *)ssGetOutputPortSignal(S,0);

                    for (i=0; i<N; i++) {
                        *y++ = *(creal_T *)(uptr[index[i]]);
                    }

                    if (otype == outValandIdx) {
                        real_T *y1 = ssGetOutputPortRealSignal(S,1);

                        for (i=0; i<N; i++) {
                            *y1++ =  (real_T)(index[i]+1); /* Convert to MATLAB 1-based indexing */
                        }
                    }
                }
            }
            break;

            case fcnDescend:
            {
                if (otype == outIdx) {
                    real_T *y = ssGetOutputPortRealSignal(S,0);

                    for(i=N-1; i>=0; i--) {
                        *y++ = (real_T)(index[i]+1); /* Convert to MATLAB 1-based indexing */
                    }

                } else {
                    creal_T *y = (creal_T *)ssGetOutputPortSignal(S,0);

                    for(i=N-1; i>=0; i--) {
                        *y++ = *(creal_T *)(uptr[index[i]]);
                    }

                    if (otype == outValandIdx) {
                        real_T *y1 = ssGetOutputPortRealSignal(S,1);
                        
                        for(i=N-1; i>=0; i--) {
                            *y1++ = (real_T)(index[i]+1); /* Convert to MATLAB 1-based indexing */
                        }
                    }
                }
            }
            break;
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
    const OutType otype = (OutType)((int_T)mxGetPr(OUT_TYPE_ARG)[0]);

    if (port != 0) {
        THROW_ERROR(S, "Invalid port index for input port width propagation.");
    }

    ssSetInputPortWidth(S, port, inputPortWidth);
    ssSetOutputPortWidth(S, 0, inputPortWidth);

    if (otype == outValandIdx) {
        ssSetOutputPortWidth(S, 1, inputPortWidth);
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    const OutType otype = (OutType)((int_T)mxGetPr(OUT_TYPE_ARG)[0]);

    if (port == 0) {
        ssSetOutputPortWidth(S,port,outputPortWidth);
        ssSetInputPortWidth(S,0,outputPortWidth);

        if (otype == outValandIdx) {
            ssSetOutputPortWidth(S,1,outputPortWidth);
        }

    } else {
        /* 2nd port propagation */
        if (otype != outValandIdx) {
            THROW_ERROR(S, "Invalid output port propagation call for Sort block.");
        } else {
            ssSetOutputPortWidth(S,port,outputPortWidth);
            ssSetOutputPortWidth(S,0,outputPortWidth);
            ssSetInputPortWidth(S,0,outputPortWidth);
        }
    }
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    /* Declare storage for sorted indices: */
    const int_T N = ssGetInputPortWidth(S,0);
    ssSetNumIWork(S, N);
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)

{
    const OutType otype = (OutType)((int_T)mxGetPr(OUT_TYPE_ARG)[0]);

    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal);  

    /* The outValandIdx 2nd port and outIdx 1st port are pre-set to be real only: */
    if (otype != outIdx) {
        ssSetOutputPortComplexSignal(S, 0, iPortComplexSignal); 
    }
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx, 
                                          CSignal_T oPortComplexSignal)
{
    const OutType otype = (OutType)((int_T)mxGetPr(OUT_TYPE_ARG)[0]);

    /* The outValandIdx and outIdx are pre-set to be real only: */
    if ((otype == outIdx) || (portIdx != 0)) {
        THROW_ERROR(S, "Invalid call for port 1 complex propagation.");
    }

    ssSetOutputPortComplexSignal(S, portIdx, oPortComplexSignal);  
    ssSetInputPortComplexSignal(S, 0, oPortComplexSignal);
}
#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdspsrt.c */
