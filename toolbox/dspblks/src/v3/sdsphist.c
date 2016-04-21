/*
 * SDSPHIST  DSP Blockset S-Function for histogram computation
 * S-Function also computes the running histogram with reset input.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.25 $   $Date: 2002/04/14 20:42:47 $
 */
#define S_FUNCTION_NAME sdsphist
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"


enum {INPORT_DATA=0, INPORT_RESET};
enum {OUTPORT_DATA=0};

enum {MIN_ARGC=0, MAX_ARGC, NBINS_ARGC, NORM_ARGC, RUN_ARGC, FRAME_ARGC, RESET_ARGC, NUM_ARGS};
enum {MIN_MAG_IDX=0, MAX_MAG_IDX, IDELTA_IDX, BIN_COUNT_IDX, ITER_IDX, MAX_NUM_DWORKS};
/* 
 * Number of DWorks
 *  running &&  norm: MAX_NUM_DWORKS
 *  running && !norm: MAX_NUM_DWORKS - 1 (Except ITER_IDX)
 * !running && !norm: MAX_NUM_DWORKS - 2 (Except BIN_COUNT_IDX, and ITER_IDX)
 */

#define MIN_ARG     (ssGetSFcnParam(S,MIN_ARGC))
#define MAX_ARG     (ssGetSFcnParam(S,MAX_ARGC))
#define NBINS_ARG   (ssGetSFcnParam(S,NBINS_ARGC))
#define NORM_ARG    (ssGetSFcnParam(S,NORM_ARGC))
#define RUN_ARG     (ssGetSFcnParam(S,RUN_ARGC))
#define FRAME_ARG   (ssGetSFcnParam(S,FRAME_ARGC))
#define RESET_ARG   (ssGetSFcnParam(S,RESET_ARGC))


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /*
     * Check min and max arguments: 
     */

    /* Check the number of elements: */
    if (OK_TO_CHECK_VAR(S, MIN_ARG) &&
        OK_TO_CHECK_VAR(S, MAX_ARG)) {

        if ((mxGetNumberOfElements(MIN_ARG) != 1)  ||
            (mxGetNumberOfElements(MAX_ARG) != 1)) {
              THROW_ERROR(S, "Minimum and maximum arguments must be scalars.");
        }

        /* Check that the min is less than the max: */
        if ((!mxIsComplex(MIN_ARG)) && (!mxIsComplex(MAX_ARG))) {

            /* Real arguments: */
            if ((mxGetPr(MIN_ARG)[0] >= mxGetPr(MAX_ARG)[0])) {
	        THROW_ERROR(S, "Minimum must be less than maximum");
            }

        } else {
            /* Complex arguments: check the magnitude squared. */
            creal_T umin;
            creal_T umax;
            real_T  min_magsq;
            real_T  max_magsq;

            umin.re = mxGetPr(MIN_ARG)[0];
            umin.im = (!mxIsComplex(MIN_ARG)) ? (real_T)0.0 : mxGetPi(MIN_ARG)[0];

            umax.re = mxGetPr(MAX_ARG)[0];
            umax.im = (!mxIsComplex(MAX_ARG)) ? (real_T)0.0 : mxGetPi(MAX_ARG)[0];

            min_magsq = CMAGSQ(umin);
            max_magsq = CMAGSQ(umax);
        
            if (min_magsq >= max_magsq) {
	        THROW_ERROR(S, "Minimum must be less than maximum.");
            }
        }
    }

    if (OK_TO_CHECK_VAR(S, NBINS_ARG)) {
        if (!IS_FLINT_GE(NBINS_ARG, 1)) {
            THROW_ERROR(S, "Number of bins must be a real, scalar integer > 0.");
        }
    }

    if (!IS_FLINT_IN_RANGE(RUN_ARG, 0, 1)) {
        THROW_ERROR(S, "Parameter can be only 0 (hist) or 1 (running hist).");
    }

    if (!IS_FLINT_IN_RANGE(NORM_ARG, 0, 1)) {
        THROW_ERROR(S, "Parameter can be only 0 (unnormalized) or 1 (normalized).");
    }

    if (!IS_FLINT_IN_RANGE(FRAME_ARG, 0, 1)) {
        THROW_ERROR(S, "Frame can be only 0 (non-frame based) or 1 (frame-based)");
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


    /* Not tunable, since it affects output port width */
    ssSetSFcnParamNotTunable(S, RUN_ARGC);
    ssSetSFcnParamNotTunable(S, FRAME_ARGC);
    ssSetSFcnParamNotTunable(S, RESET_ARGC);
    
    /* Not tunable in RTW generated code. */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        
        ssSetSFcnParamNotTunable(S, NORM_ARGC);
    }


    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    {
        const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
        const boolean_T frame   = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const boolean_T norm    = (boolean_T)(mxGetPr(NORM_ARG)[0] != 0.0);
        const boolean_T rstPort = (boolean_T)(mxGetPr(RESET_ARG)[0] != 0.0);

        /* Protect Nbins against unassigned input variables.
         * In this case, NBINS defaults to an empty, and CheckParam allows
         * this to occur.  At compile time, however, an error is issued automatically
         * by Simulink.
         */
        const int_T Nbins = mxIsEmpty(NBINS_ARG) ? 1 : (int_T)mxGetPr(NBINS_ARG)[0];
        
        if (!running) {
            /* 
             * Histogram: 
             */
             /* Inputs: */
            if (!ssSetNumInputPorts(S, 1)) return;

            ssSetInputPortWidth(            S, INPORT_DATA, DYNAMICALLY_SIZED);
            ssSetInputPortDirectFeedThrough(S, INPORT_DATA, 1);
            ssSetInputPortComplexSignal(    S, INPORT_DATA, COMPLEX_INHERITED);
            ssSetInputPortReusable(         S, INPORT_DATA, 1);
            ssSetInputPortOverWritable(     S, INPORT_DATA, 0);
            ssSetInputPortSampleTime(       S, INPORT_DATA, INHERITED_SAMPLE_TIME);

            /* Outputs: */
            if (!ssSetNumOutputPorts(S,1)) return;

            ssSetOutputPortWidth(        S, OUTPORT_DATA, Nbins);
            ssSetOutputPortComplexSignal(S, OUTPORT_DATA, COMPLEX_NO);
            ssSetOutputPortReusable(     S, OUTPORT_DATA, 1);
            ssSetOutputPortSampleTime(   S, OUTPORT_DATA, INHERITED_SAMPLE_TIME);

        } else {
            /* 
             * Running Histogram: 
             */
            /* Inputs: */
            int_T numInports = (rstPort) ? 2 : 1;
            if (!ssSetNumInputPorts(S, numInports)) return;

            ssSetInputPortWidth(            S, INPORT_DATA, (frame) ? DYNAMICALLY_SIZED : 1);
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
                ssSetInputPortOverWritable(     S, INPORT_RESET, 0);
                ssSetInputPortSampleTime(       S, INPORT_RESET, INHERITED_SAMPLE_TIME);
            }

            /* Outputs: */
            if (!ssSetNumOutputPorts(S,1)) return;

            ssSetOutputPortWidth(        S, OUTPORT_DATA, Nbins);
            ssSetOutputPortComplexSignal(S, OUTPORT_DATA, COMPLEX_NO);
            ssSetOutputPortReusable(     S, OUTPORT_DATA, 1);
            ssSetOutputPortSampleTime(   S, OUTPORT_DATA, INHERITED_SAMPLE_TIME);
        }

        if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

        ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                     SS_OPTION_USE_TLC_WITH_ACCELERATOR);
    }
}


/* Set and propagate sample times: */
#include "dsp_ctrl_ts.c"


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    if (running) {
        if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
            THROW_ERROR(S,"Input to running mean block must have a discrete sample time.");
        }
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{

    /* Preset the min and max values once at start of simulation: */
    {
        const int_T  Nbins  = (int_T)mxGetPr(NBINS_ARG)[0];
        real_T      *umin   = (real_T *)ssGetDWork(S, MIN_MAG_IDX);
        real_T      *umax   = (real_T *)ssGetDWork(S, MAX_MAG_IDX);
        real_T      *idelta = (real_T *)ssGetDWork(S, IDELTA_IDX);

        if (!mxIsComplex(MIN_ARG)) {
            *umin = mxGetPr(MIN_ARG)[0];
        } else {
            creal_T cval;
            cval.re = mxGetPr(MIN_ARG)[0];
            cval.im = mxGetPi(MIN_ARG)[0];
            *umin = sqrt(CMAGSQ(cval));
        }

        if (!mxIsComplex(MAX_ARG)) {
            *umax = mxGetPr(MAX_ARG)[0];
        } else {
            creal_T cval;
            cval.re = mxGetPr(MAX_ARG)[0];
            cval.im = mxGetPi(MAX_ARG)[0];
            *umax = sqrt(CMAGSQ(cval));
        }
        *idelta = Nbins / (*umax - *umin);
    }

    {
        const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
        if (running) {

            const boolean_T norm = (boolean_T)(mxGetPr(NORM_ARG)[0] != 0.0);
            if (norm) {
                /* Iteration counter keeps track of the number of inputs */
                real_T *iter_idx = ssGetDWork(S, ITER_IDX);
                *iter_idx = 0.0;
            }

            /* Set all histogram bin counts to zero: */
            memset(ssGetDWork(S, BIN_COUNT_IDX), 0, ssGetDWorkWidth(S, BIN_COUNT_IDX)*sizeof(uint32_T));
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T  running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    const boolean_T  norm    = (boolean_T)(mxGetPr(NORM_ARG)[0] != 0.0);
    const boolean_T  frame   = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const boolean_T  c0      = (boolean_T)(ssGetInputPortComplexSignal(S,0) == COMPLEX_YES);
    const int_T      Nbins   = (int_T)mxGetPr(NBINS_ARG)[0];
    const real_T     umin    = *((real_T *)ssGetDWork(S, MIN_MAG_IDX));
    const real_T     umax    = *((real_T *)ssGetDWork(S, MAX_MAG_IDX));
    const real_T     idelta  = *((real_T *)ssGetDWork(S, IDELTA_IDX));
    InputPtrsType    uptr    = ssGetInputPortSignalPtrs(S, INPORT_DATA);
    real_T          *y       = ssGetOutputPortRealSignal(S, OUTPORT_DATA);
    int_T            i;

    if (!running) {
        /*
         * Histogram:
         */
        int_T width = ssGetInputPortWidth(S, INPORT_DATA);

        /* Initialize all bins to zero:
         * WARNING: Do not memset a block of zeros here.
         *          Floating point zero is not all zero-bytes on TI DSP's.
         *          (non-IEEE representation)
         *          So don't do this!
         *                memset(y, 0, Nbins * sizeof(real_T));
         */
	for (i=0; i<Nbins; i++) {
            y[i] = 0.0;
	}

        while(width-- > 0) {
            /*
             * Both real AND complex cases:
             *
             * uptr is a InputPtrsType
             *   If real, cast to a (real_T *)
             *   If complex, cast to a (creal_T *)
             */
            real_T val;
            if (c0) {
                const creal_T cval = *((creal_T *)(*uptr++));
                val = sqrt(CMAGSQ(cval));
            } else {
                val = *((real_T *)(*uptr++));
            }

            /*
             * Update appropriate histogram bin:
             */
	    if (val <= umin) {
		i = 0;
	    } else if (val > umax) {
		i = Nbins-1;
	    } else {
		i = (int_T)(ceil((val-umin) * idelta) - 1) ;
	    }
            (*(y + i))++;
        }

        if (norm) {
            real_T scale = 1.0 / ssGetInputPortWidth(S, INPORT_DATA);

            i = Nbins;
            while (i-- > 0) {
                *y++ *= scale;
            }
        }

    } else {
        /*
         * Running Histogram:
         */
        uint32_T *h = (uint32_T *)ssGetDWork(S, BIN_COUNT_IDX);
        {
            /*
             * The second input is a reset line.
             * If non-zero, all states are to be reset.
             */
            const boolean_T rstPort = (boolean_T)((int_T)(mxGetPr(RESET_ARG)[0]) != 0);
            if (rstPort) {
                InputRealPtrsType pRstIn = ssGetInputPortRealSignalPtrs(S, INPORT_RESET);
                if (*pRstIn[0] != 0.0) {
                    /* Can use memset because internal states are int_T's, not real_T's */
                    memset((void *)h, 0, Nbins*sizeof(uint32_T));

                    if (norm) {
                        /* Reset iteration counter */
                        real_T *iter_cnt = (real_T *)ssGetDWork(S,ITER_IDX);
                        *iter_cnt = 0.0;
                    }
                }
            }
        }
        {
            /*
             * Both Real and Complex input:
             *
             * NOTE: For running block,
             *   - input width is 1 (scalar only) for non-frame based
             *   - input may be a vector for frame-based
             *   - matrix inputs are not currently supported for
             *     the frame-based running histogram
             */
            int_T j = ssGetInputPortWidth(S, INPORT_DATA);
            while(j-- > 0) {
                real_T val;
                if (c0) {
                    const creal_T cval = *((creal_T *)(*uptr++));
                    val = sqrt(CMAGSQ(cval));
                } else {
                    val = *((real_T *)(*uptr++));
                }

                /*
                 * Update appropriate histogram bin:
                 */
                if (val <= umin) {
                    i = 0;
                } else if (val > umax) {
                    i = Nbins-1;
                } else {
	             i = (int_T)(ceil((val-umin) * idelta) - 1);
	        }
                (*(h + i))++;
            }

            if (norm) {
                /* Copy normalized bin count to output: */
                real_T *iter_cnt = (real_T *)ssGetDWork(S, ITER_IDX);
                real_T   scale;

                (*iter_cnt)++;
                scale = 1.0 / *iter_cnt;

                for (i=0; i<Nbins; i++) {
                    *y++ = scale * (real_T)(*h++);
                }
        
            } else {
                /* Copy unnormalized bin count to output: */
                for (i=0; i<Nbins; i++) {
                    *y++ = (real_T)(*h++);
                }
            }
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
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    const boolean_T frame   = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);

    /* Running histogram: 
     * Widths for all input and outputs are known at initialization
     *   if not frame based.
     * If frame-based, width of input is unknown and is cannot
     *   be deduced.
     */

    ssSetInputPortWidth(S, port, inputPortWidth);

    if (!running) {
        /* Histogram: 
         * Ouput is not dynamic 
         */
        if (port != 0) {
            THROW_ERROR(S, "Invalid input port number for non-running case");
        }
    } else {
        /* The only reason to be here is that we are in frame-based mode: */
        if (!frame) {
            THROW_ERROR(S, "Invalid input port for non-frame based running case");
        }
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    /* Outputs shouldn't be called because
     * they're set in initialization in both cases
     */
    THROW_ERROR(S, "Error propagating output port width info.");
}

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    const boolean_T norm    = (boolean_T)(mxGetPr(NORM_ARG)[0] != 0.0);
    const int_T     nDWorks = (running && norm) ? 
                                  MAX_NUM_DWORKS : 
                                  (running ? MAX_NUM_DWORKS-1 : MAX_NUM_DWORKS-2);  

    if(!ssSetNumDWork(S, nDWorks)) return;
    
    ssSetDWorkWidth(        S, MIN_MAG_IDX, 1);
    ssSetDWorkDataType(     S, MIN_MAG_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, MIN_MAG_IDX, COMPLEX_NO);
    ssSetDWorkName(         S, MIN_MAG_IDX, "MinMag");
    ssSetDWorkUsedAsDState( S, MIN_MAG_IDX, 1);
    
    ssSetDWorkWidth(        S, MAX_MAG_IDX, 1);
    ssSetDWorkDataType(     S, MAX_MAG_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, MAX_MAG_IDX, COMPLEX_NO);
    ssSetDWorkName(         S, MAX_MAG_IDX, "MaxMag");
    ssSetDWorkUsedAsDState( S, MAX_MAG_IDX, 1);
    
    ssSetDWorkWidth(        S, IDELTA_IDX, 1);
    ssSetDWorkDataType(     S, IDELTA_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, IDELTA_IDX, COMPLEX_NO);
    ssSetDWorkName(         S, IDELTA_IDX, "Idelta");
    ssSetDWorkUsedAsDState( S, IDELTA_IDX, 1);

    if (running) {
        /* bin count is only needed for running histogram. */
        int_T           N    = (int_T)mxGetPr(NBINS_ARG)[0];

        ssSetDWorkWidth(        S, BIN_COUNT_IDX, N);
        ssSetDWorkDataType(     S, BIN_COUNT_IDX, SS_UINT32);
        ssSetDWorkComplexSignal(S, BIN_COUNT_IDX, COMPLEX_NO);
        ssSetDWorkName(         S, BIN_COUNT_IDX, "BinCount");
        ssSetDWorkUsedAsDState( S, BIN_COUNT_IDX, 1);

        if (norm) {
            ssSetDWorkWidth(        S, ITER_IDX, 1);
            ssSetDWorkDataType(     S, ITER_IDX, SS_DOUBLE);
            ssSetDWorkComplexSignal(S, ITER_IDX, COMPLEX_NO);
            ssSetDWorkName(         S, ITER_IDX, "Iteration");
            ssSetDWorkUsedAsDState( S, ITER_IDX, 1);
        }
    }
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
   if (portIdx != 0) {
        THROW_ERROR(S,"Invalid port index for running mode complex propagation.");
    }
    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal);  
}


#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx, 
                                          CSignal_T oPortComplexSignal)
{
    THROW_ERROR(S,"Invalid complex output port propagation call.");
}
#endif


#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdsphist.c */
