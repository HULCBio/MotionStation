/*
 * SDSPMAX DSP Blockset S-Function for maximum computation,
 * with value and index outputs. S-Function also computes the
 * running maxumum with reset input.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.30 $  $Date: 2002/04/14 20:42:53 $
 */
#define S_FUNCTION_NAME sdspmax
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {RESET_IDX=0, CACHE_IDX, MAX_NUM_DWORKS};

/* If running: 2 dworks, otherwise no dwork. */ 
enum {INPORT_DATA, INPORT_RESET};
enum {OUTPORT_DATA, OUTPORT_IDX};

enum {FCN_TYPE_ARGC=0, FRAME_ARGC, NCHANS_ARGC, RESET_ARGC, NUM_ARGS};
#define FCN_TYPE_ARG (ssGetSFcnParam(S,FCN_TYPE_ARGC))
#define FRAME_ARG    (ssGetSFcnParam(S,FRAME_ARGC))
#define NCHANS_ARG   (ssGetSFcnParam(S,NCHANS_ARGC))
#define RESET_ARG    (ssGetSFcnParam(S,RESET_ARGC))

typedef struct {
    real_T  magsq; 
    creal_T cmplx;
} minmax_cache;

typedef enum {
    fcnValandIdx = 1,
    fcnVal,    
    fcnIdx,    
    fcnRunning 
} FcnType;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if (!IS_FLINT_IN_RANGE(FCN_TYPE_ARG, 1, 4)) {
        THROW_ERROR(S, "Function type must be a scalar in the range [1,4].");
    }

    if (!IS_FLINT_IN_RANGE(FRAME_ARG, 0, 1)) {
        THROW_ERROR(S, "Frame can be only 0 (non-frame based) or 1 (frame-based)");
    }

    if (OK_TO_CHECK_VAR(S, NCHANS_ARG)) {
        if (!IS_FLINT_GE(NCHANS_ARG, 1)) {
            THROW_ERROR(S, "Number of channels must be a scalar integer > 0.");
        }
    }

    if (!IS_FLINT_IN_RANGE(RESET_ARG, 0, 1)) {
        THROW_ERROR(S, "Reset inport flag must be 0 or 1.");
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

    /* Not tunable, since it affects # of ports AND whether we use DWork storage */
    ssSetSFcnParamNotTunable(S, FCN_TYPE_ARGC);
    ssSetSFcnParamNotTunable(S, FRAME_ARGC);
    ssSetSFcnParamNotTunable(S, NCHANS_ARGC);
    ssSetSFcnParamNotTunable(S, RESET_ARGC);
    
    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    {
        const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
        switch (ftype) {
            case fcnRunning:
            {
                /* Running maximum: 2 inputs (Data, Reset), 1 output (Val) */
                /* Inputs: */
                const boolean_T rstPort = (boolean_T)((int_T)(mxGetPr(RESET_ARG)[0]) != 0);
                int_T numInports = rstPort ? 2 : 1;

                if (!ssSetNumInputPorts(S, numInports)) return;

                ssSetInputPortWidth(            S, INPORT_DATA, DYNAMICALLY_SIZED);
                ssSetInputPortDirectFeedThrough(S, INPORT_DATA, 1);
                ssSetInputPortComplexSignal(    S, INPORT_DATA, COMPLEX_INHERITED);
                ssSetInputPortReusable(         S, INPORT_DATA, 1);
                ssSetInputPortOverWritable(     S, INPORT_DATA, 0);
                ssSetInputPortSampleTime(       S, INPORT_DATA, INHERITED_SAMPLE_TIME);

                if (rstPort) {
                    ssSetInputPortWidth(            S, INPORT_RESET, 1);
                    ssSetInputPortDirectFeedThrough(S, INPORT_RESET, 1);
                    ssSetInputPortComplexSignal(    S, INPORT_RESET, COMPLEX_NO);
                    ssSetInputPortReusable(         S, INPORT_RESET, 1);
                    ssSetInputPortOverWritable(     S, INPORT_RESET, 1);  /* Only read once at start */
                    ssSetInputPortSampleTime(       S, INPORT_RESET, INHERITED_SAMPLE_TIME);
                }
        
                /* Outputs: */
                if (!ssSetNumOutputPorts(S, 1)) return;

                ssSetOutputPortWidth(        S, OUTPORT_DATA, DYNAMICALLY_SIZED);
                ssSetOutputPortComplexSignal(S, OUTPORT_DATA, COMPLEX_INHERITED);
                ssSetOutputPortReusable(     S, OUTPORT_DATA, 1);
                ssSetOutputPortSampleTime(   S, OUTPORT_DATA, INHERITED_SAMPLE_TIME);
            }
            break;

            case fcnVal:
            case fcnIdx:
            case fcnValandIdx:
            {
                /* Maximum: 1 input (data) */
                /* Input */
                if (!ssSetNumInputPorts(S, 1)) return;

                ssSetInputPortWidth(            S, INPORT_DATA, DYNAMICALLY_SIZED);   
                ssSetInputPortDirectFeedThrough(S, INPORT_DATA, 1);
                ssSetInputPortComplexSignal(    S, INPORT_DATA, COMPLEX_INHERITED);
                ssSetInputPortReusable(         S, INPORT_DATA, 1);
                ssSetInputPortOverWritable(     S, INPORT_DATA, 0);
                ssSetInputPortSampleTime(       S, INPORT_DATA, INHERITED_SAMPLE_TIME);

                if (ftype != fcnValandIdx) {
                    /* Outputs: 1 output (Val or Idx)*/
                    if (!ssSetNumOutputPorts(S, 1)) return;

                    ssSetOutputPortWidth(        S, OUTPORT_DATA, 1);                
                    ssSetOutputPortComplexSignal(S, OUTPORT_DATA, (ftype == fcnVal) ? COMPLEX_INHERITED : COMPLEX_NO);
                    ssSetOutputPortReusable(     S, OUTPORT_DATA, 1);
                    ssSetOutputPortSampleTime(   S, OUTPORT_DATA, INHERITED_SAMPLE_TIME);

                } else {    
                    /* Outputs: 2 outputs (Val and Idx) */
                    if (!ssSetNumOutputPorts(S, 2)) return;

                    ssSetOutputPortWidth(        S, OUTPORT_DATA, 1);
                    ssSetOutputPortComplexSignal(S, OUTPORT_DATA, COMPLEX_INHERITED);
                    ssSetOutputPortReusable(     S, OUTPORT_DATA, 1);
                    ssSetOutputPortSampleTime(   S, OUTPORT_DATA, INHERITED_SAMPLE_TIME);

                    ssSetOutputPortWidth(        S, OUTPORT_IDX, 1);
                    ssSetOutputPortComplexSignal(S, OUTPORT_IDX, COMPLEX_NO);       /* Real index only */
                    ssSetOutputPortReusable(     S, OUTPORT_IDX, 1);
                    ssSetOutputPortSampleTime(   S, OUTPORT_IDX, INHERITED_SAMPLE_TIME);
                }
            }
            break;
        }
    }


    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


/* Set all ports to the identical, discrete rates: */
#define DSP_ALLOW_CONTINUOUS
#include "dsp_ctrl_ts.c"


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const FcnType   ftype   = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T running = (boolean_T)(ftype == fcnRunning);
    const boolean_T frame   = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nchans  = (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T     width   = ssGetInputPortWidth(S, INPORT_DATA);

    if (running && frame && (width % nchans != 0)) {
        THROW_ERROR(S,"Size of input matrix does not match number of channels");
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const FcnType   ftype   = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T running = (boolean_T)(ftype == fcnRunning);

    /* We start out in "reset mode" (e.g., at startup, the first input
     * value *is* the max value).  After that, we only look at the
     * reset input port to determine if we must reset the max value.
     * However, in a re-enabling subsystem, we might have to reset
     * the max value as well.
     */
    if (running) {
        boolean_T *reset = (boolean_T *)ssGetDWork(S, RESET_IDX);
        *reset = 1;
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T c0    = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT_DATA) == COMPLEX_YES);
    const FcnType   ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);

    switch (ftype) {
        case fcnRunning:
        {
            /*
             * Running Maximum: 2 inputs (data and reset) and 1 output (minimum).
             */
            const int_T     width  = ssGetInputPortWidth(S, INPORT_DATA);
            const boolean_T frame  = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
            const int_T     nchans = (frame) ? (int_T)mxGetPr(NCHANS_ARG)[0] : width;
            const int_T     nsamps = (frame) ? width /nchans : 1;
            boolean_T      *reset  = (boolean_T *)ssGetDWork(S, RESET_IDX);

            /* If there is a reset port, and it is non-zero, all states are to be reset.
             * However, just because the reset input is zero doesn't mean we're
             * not going to reset ... we ALWAYS reset at the first time step
             * after initialization.  So check before setting the reset flag.
             */
            {
                const boolean_T rstPort = (boolean_T)((int_T)(mxGetPr(RESET_ARG)[0]) != 0);
                if (rstPort) {
                    InputRealPtrsType pRstIn = ssGetInputPortRealSignalPtrs(S, INPORT_RESET);
                    if (*pRstIn[0] != 0.0) {
                        *reset = 1;
                    }
                }
            }
        
            if (!c0) {
                /* 
                 * Real input:
                 */
                InputRealPtrsType  uptr0 = ssGetInputPortRealSignalPtrs(S, INPORT_DATA);
                real_T            *y     = ssGetOutputPortRealSignal(S, 0);

                /* Point to array of "last maximum data values" for each input element */
                real_T            *cache   = (real_T *)ssGetDWork(S, CACHE_IDX);
            
                if (*reset) {
                    /* 
                     * We are in reset mode
                     * the current input is the output (minimum) value 
                     */
                    int_T i = nchans;
                    while(i-- > 0) {
                        int_T  j    = nsamps - 1;  /* We'll grab the first input manually */
                        real_T tmax = **uptr0++;

                        while(j-- > 0) {
                            const real_T val = **uptr0++;
                            if (val > tmax) {
                                tmax = val;
                            }
                        }
                        *y++ = *cache++ = tmax;
                    }
                    *reset = 0;  /* No longer in reset mode */

                } else {
                    /* Compare latest inputs to stored maximum values: */

                    int_T i = nchans;
                    while (i-- > 0) {
                        int_T  j    = nsamps;
                        real_T tmax = *cache;

                        while(j-- > 0) {
                            const real_T val = **uptr0++;
                            if (val > tmax) {
                                tmax = val;
                            }
                        }
                        *y++ = *cache++ = tmax;
                    }
                }

            } else {
                /* 
                 * Complex input: 
                 */
                InputPtrsType  uptr0 = ssGetInputPortSignalPtrs(S, INPORT_DATA);
                creal_T	      *y     = (creal_T *)ssGetOutputPortSignal(S,0);

                /* Point to array of the last minimum data values */
                minmax_cache  *cache = (minmax_cache *)ssGetDWork(S, CACHE_IDX);
            
                if (*reset) {
                    /* We are in reset mode
                     * the current input is the output (minimum) value
                     */
                    int_T i = nchans;
                    while (i-- > 0) {
                        creal_T *u      = (creal_T *)(*uptr0++);
                        int_T    j      = nsamps - 1;
                        real_T   maxmag = CMAGSQ(*u);
                        creal_T  maxval = *u;

                        while(j-- > 0) {
                            creal_T      *newval = (creal_T *)(*uptr0++);
                            const real_T  newmag = CMAGSQ(*newval);  /* Mag squared of current input element */

                            /* Compare to "cached" mag-squared value of last "maximum" complex element: */
                            if (newmag > maxmag) {
                                maxval = *newval;
                                maxmag = newmag;
                            }
                        }
                        cache->cmplx     = maxval;
                        (cache++)->magsq = maxmag;
                        *y++ = maxval;
                    }
                    *reset = 0;  /* No longer in reset mode */
                
                } else {
                    /* Compare latest inputs to stored minimum values: */
                    int_T i = nchans;
                    while (i-- > 0) {
                        int_T   j      = nsamps;
                        real_T  maxmag = cache->magsq;
                        creal_T maxval = cache->cmplx;

                        while(j-- > 0) {
                            creal_T      *newval = (creal_T *)(*uptr0++);
                            const real_T  newmag = CMAGSQ(*newval);  /* Mag squared of current input element */

                            /* Compare to "cached" mag-squared value of last "minimum" complex element: */
                            if (newmag > maxmag) {
                                maxval = *newval;
                                maxmag = newmag;
                            }
                        }
                        cache->cmplx     = maxval;
                        (cache++)->magsq = maxmag;
                        *y++ = maxval;
                    }
                }
            }
        }
        break;

        case fcnVal:
        case fcnIdx:
        case fcnValandIdx:
        {
            const int_T  width = ssGetInputPortWidth(S, INPORT_DATA);
            const int_T  c0    = ssGetInputPortComplexSignal(S, INPORT_DATA);
            int_T        m_idx = 0;   /* 0-based index of 1st element is 0 */
   	        
            if (!c0) {
                /* 
                 * Real:
                 */
                InputRealPtrsType  uptr  = ssGetInputPortRealSignalPtrs(S, INPORT_DATA);
                real_T            *y0    = ssGetOutputPortRealSignal(S, 0);
                real_T             m_val = **(uptr++);  /* 1st element is initial max */
                int_T              idx;

                for (idx=1; idx<width; idx++) {
                    real_T val = **(uptr++);
                    if (val > m_val) {
                        m_val = val;
                        m_idx = idx;
                    }
                }
                /* 
                 * fcnVal: 1 output, maximum value 
                 * fcnIdx: 1 output, index of maximum value
                 * fcnValandIdx: 2 outputs, maximum value and index
                 */
                *y0 = ((ftype == fcnVal) || (ftype == fcnValandIdx)) ? m_val : (real_T)(m_idx + 1);
                if (ftype == fcnValandIdx) {
                    /* 2nd output must be the index */
                     real_T *y1 = ssGetOutputPortRealSignal(S,1);
                     *y1 = (real_T)(m_idx + 1); /* Convert C-index to 1-based MATLAB index */
                }

            } else {
                /* 
                 * Complex: 
                 */
                InputPtrsType  uptr  = ssGetInputPortSignalPtrs(S, INPORT_DATA);
                creal_T       *u     = (creal_T *)(*uptr++); /* 1st element is initial max */
                real_T         m_val = CMAGSQ(*u);
                int_T          idx;
                
                for (idx=1; idx<width; idx++) {
                    creal_T *u   = (creal_T *)(*uptr++);
                    real_T   val = CMAGSQ(*u);
                
                    if (val > m_val) {
                        m_val = val;
                        m_idx = idx;
                    }
                }
                {
                    if ((ftype == fcnVal) || (ftype == fcnValandIdx)) {
                        /* Since we've bumped uptr above, get the original input ptr again,
                         * and index directly into that list
                         */
                        const creal_T *u  = (creal_T *)(ssGetInputPortSignalPtrs(S, INPORT_DATA)[m_idx]);
                        creal_T       *y0 = (creal_T *)ssGetOutputPortSignal(S,0);
                        *y0 = *u;

                    } else {
                        real_T *y0 = ssGetOutputPortRealSignal(S,0);
                        *y0 = (real_T)(m_idx + 1); /* Convert C-index to 1-based MATLAB index */
                    }

                    if (ftype == fcnValandIdx) {
                        real_T *y1 = ssGetOutputPortRealSignal(S,1);
                        *y1 = (real_T)(m_idx + 1); /* Convert C-index to 1-based MATLAB index */
                    }
                }
            }
        }
        break;
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
    const FcnType   ftype   = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T running = (boolean_T) (ftype == fcnRunning);

    if (running) {
        /* Running maximum:
         * 2 inputs (In and Rst), 1 output
         * output width must be same width as input 0
         */
        if (port != 0) {
            THROW_ERROR(S, "Invalid input port number for running case");
        }
        ssSetInputPortWidth(S, port, inputPortWidth);

        {
            const boolean_T  frame  = (boolean_T)mxGetPr(FRAME_ARG)[0];
            const int_T      nchans = (frame) ? (int_T)mxGetPr(NCHANS_ARG)[0] : inputPortWidth ;
            ssSetOutputPortWidth(S, OUTPORT_DATA, nchans);   
        }

    } else {
        if (port != 0) {
            THROW_ERROR(S, "Invalid input port number for non-running case");
        }
        ssSetInputPortWidth(S, port, inputPortWidth);
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    const FcnType   ftype   = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T running = (boolean_T) (ftype == fcnRunning);

    if (running) {
        if (port != 0) {
            THROW_ERROR(S, "Invalid output port number for running case");
        }
        ssSetOutputPortWidth(S,port,outputPortWidth);
        {
            const boolean_T frame = (boolean_T)mxGetPr(FRAME_ARG)[0];
        
            if (frame) {
                if (outputPortWidth != (int_T)mxGetPr(NCHANS_ARG)[0])  {
                    THROW_ERROR(S,"Invalid output port width propagation for frame-based"
                                   "running mean");
                }
                /* Samples per frame unknown so we can't set the input port width */
            } else {
                /* Not frame based */
                ssSetInputPortWidth(S, INPORT_DATA, outputPortWidth);
            }
        }

    } else {
        /* Max: 1 input, 1 output */
        /* Output port is a scalar (not dynamic) */
        THROW_ERROR(S, "Error propagating output port width info for non-running case");
    }
}

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const FcnType   ftype       = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T running     = (boolean_T) (ftype == fcnRunning);
    const int_T     nDWorks    = (running)? MAX_NUM_DWORKS : 0;

    if(!ssSetNumDWork(S, nDWorks)) return;
    if (running) {
        /* Store the number disc states for either real/complex input. 
         * We need 1 state per input channel. 
         */
        const int_T      N         = ssGetInputPortWidth(S, INPORT_DATA);
        const boolean_T  frame     = (boolean_T)mxGetPr(FRAME_ARG)[0];
        const int_T      nchans    = (frame) ? (int_T)mxGetPr(NCHANS_ARG)[0] : N;
        int_T            cache_siz = nchans;

        if (ssGetInputPortComplexSignal(S, INPORT_DATA)) {
            /* 
             * For complex inputs, store the real and imaginary
             * parts of the input and the magnitude squared
             */
            cache_siz *= sizeof(minmax_cache) / sizeof(real_T);  /* should be 3 */
        }

        ssSetDWorkWidth(        S, CACHE_IDX, cache_siz);
        ssSetDWorkDataType(     S, CACHE_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, CACHE_IDX, COMPLEX_NO);
        ssSetDWorkName(         S, CACHE_IDX, "Cache");
        ssSetDWorkUsedAsDState( S, CACHE_IDX, 1);

        ssSetDWorkWidth(        S, RESET_IDX, 1);
        ssSetDWorkDataType(     S, RESET_IDX, SS_BOOLEAN);
        ssSetDWorkComplexSignal(S, RESET_IDX, COMPLEX_NO);
        ssSetDWorkName(         S, RESET_IDX, "Reset");
        ssSetDWorkUsedAsDState( S, RESET_IDX, 1);

    } 
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    
    switch (ftype) {
        case fcnRunning:
        {
            if (portIdx != 0) {
                THROW_ERROR(S,"Invalid port index for running mode complex propagation.");
            }
            ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal);
            ssSetOutputPortComplexSignal(S, OUTPORT_DATA, iPortComplexSignal);
        }
        break;

        case fcnVal:
        case fcnIdx:
        case fcnValandIdx:
        {
            ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal);  
            if (ftype != fcnIdx) {
                ssSetOutputPortComplexSignal(S, OUTPORT_DATA, iPortComplexSignal);  
            }
        }
        break;
    }
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx, 
                                          CSignal_T oPortComplexSignal)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);

    switch (ftype) {
        case fcnRunning:
        {
            if (portIdx == 1) {
                THROW_ERROR(S,"Invalid port index for running mode complex propagation.");
            }
            ssSetOutputPortComplexSignal(S, portIdx, oPortComplexSignal);  
            ssSetInputPortComplexSignal(S, INPORT_DATA, oPortComplexSignal);
        }
        break;

        case fcnVal:
        case fcnValandIdx:
        {
            ssSetOutputPortComplexSignal(S, portIdx, oPortComplexSignal);
            ssSetInputPortComplexSignal(S, INPORT_DATA, oPortComplexSignal);
        }
        break;

        case fcnIdx:
        {
            THROW_ERROR(S,"Invalid complex propagation for Idx setting.");
        }
        break;
    }
}
#endif


#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* [EOF] sdspmax.c */
