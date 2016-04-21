/*
 * SDSPRMS DSP Blockset S-Function for rms computation,
 * with value and index outputs. S-Function also computes the
 * running rms with reset input.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.20 $  $Date: 2002/04/14 20:43:02 $
 */
#define S_FUNCTION_NAME sdsprms
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

/* If running 2 dworks, otherwise no dwork. */
enum {ITER_IDX=0, RMS_IDX, MAX_NUM_DWORKS};
enum {INPORT_DATA, INPORT_RESET};
enum {OUTPORT_DATA};

enum {RUN_ARGC=0, FRAME_ARGC, NCHANS_ARGC, RESET_ARGC, NUM_ARGS};
#define RUN_ARG    (ssGetSFcnParam(S,RUN_ARGC))
#define FRAME_ARG  (ssGetSFcnParam(S,FRAME_ARGC))
#define NCHANS_ARG (ssGetSFcnParam(S,NCHANS_ARGC))
#define RESET_ARG  (ssGetSFcnParam(S,RESET_ARGC))

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if (!IS_FLINT_IN_RANGE(RUN_ARG, 0, 1)) {
        THROW_ERROR(S, "Running can be only 0 (RMS) or 1 (running RMS).");
    }

    if (!IS_FLINT_IN_RANGE(FRAME_ARG, 0, 1)) {
        THROW_ERROR(S, "Frame can be only 0 (non-frame based) or 1 (frame-based).");
    }

    if (!IS_FLINT_IN_RANGE(RESET_ARG, 0, 1)) {
        THROW_ERROR(S, "Reset inport flag must be 0 or 1.");
    }

    if (OK_TO_CHECK_VAR(S, NCHANS_ARG)) {
        if (!IS_FLINT_GE(NCHANS_ARG, 1)) {
            THROW_ERROR(S, "Number of channels must be an real integer value > 0.");
        }
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
    ssSetSFcnParamNotTunable(S, NCHANS_ARGC);
    ssSetSFcnParamNotTunable(S, RESET_ARGC);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    {
        const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
        if (!running) {
            /* 
             * RMS: 
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

            ssSetOutputPortWidth(        S, OUTPORT_DATA, 1);
	    ssSetOutputPortComplexSignal(S, OUTPORT_DATA, COMPLEX_NO);
            ssSetOutputPortReusable(     S, OUTPORT_DATA, 1);
            ssSetOutputPortSampleTime(   S, OUTPORT_DATA, INHERITED_SAMPLE_TIME);

        } else {
            /* 
             * Running RMS: 
             */
	    /* Inputs: */
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
                ssSetInputPortOverWritable(     S, INPORT_RESET, 0);
                ssSetInputPortSampleTime(       S, INPORT_RESET, INHERITED_SAMPLE_TIME);
            }

            /* Outputs: */
            if (!ssSetNumOutputPorts(S,1)) return;

            /* Output of RMS is purely real, even if input is complex: */
            ssSetOutputPortWidth(        S, OUTPORT_DATA, DYNAMICALLY_SIZED);
            ssSetOutputPortComplexSignal(S, OUTPORT_DATA, COMPLEX_NO);
            ssSetOutputPortReusable(     S, OUTPORT_DATA, 1);
            ssSetOutputPortSampleTime(   S, OUTPORT_DATA, INHERITED_SAMPLE_TIME);
        }
    }

    /* DWorks: */
    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | 
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


/* Set all ports to the identical, discrete rates: */
#include "dsp_ctrl_ts.c"


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    const boolean_T frame   = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nchans  = (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T     width   = ssGetInputPortWidth(S, INPORT_DATA);

    if (running) {
        if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
            THROW_ERROR(S,"Input to running RMS block must have a discrete sample time.");
        }
        if (frame && (width % nchans != 0)) {
            THROW_ERROR(S,"Size of input matrix does not match number of channels");
        }
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    /* We start out in "reset mode" (e.g., at startup, the first input
     * value *is* the rms value).  After that, we only look at the
     * reset input port to determine if we must reset the rms value.
     * However, in a re-enabling subsystem, we might have to reset
     * the rms value as well.
     */
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    if (running) {
        real_T  *iter_cnt = (real_T *)ssGetDWork(S, ITER_IDX);
        *iter_cnt = 0.0;  /* Reset iteration counter */
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    const boolean_T c0      = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT_DATA) == COMPLEX_YES);
    real_T         *y       = ssGetOutputPortRealSignal(S,OUTPORT_DATA);

    if (!running) {
        /*
         * RMS:
         */
        const int_T N = ssGetInputPortWidth(S, INPORT_DATA);
   	    
        if (!c0) {
            /* 
             * Real inputs:
             */
            InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,INPORT_DATA);
            real_T             sx2  = 0.0;
            int_T              i    = N;

            /* rms = sqrt(sum(x.^2)/N) */
            while(i-- > 0) {
                real_T u = **uptr++;
                sx2 += u*u;
            }
            *y = sqrt(sx2/N);

        } else {
   	    /* 
             * Complex inputs:
             */
            InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT_DATA);
            real_T         sx2  = 0.0;
            int_T          i    = N;

	    while(i-- > 0) {
                const creal_T val = *((creal_T *)(*uptr++));
		sx2 += CMAGSQ(val);
	    }
	    *y = sqrt(sx2/N);
        }

    } else {
        /*
         * Running RMS:
         */
        const int_T        width    = ssGetInputPortWidth(S, INPORT_DATA);
        const boolean_T    frame    = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const int_T        nchans   = (frame) ? (int_T)mxGetPr(NCHANS_ARG)[0] : width;
        const int_T        nsamps   = (frame) ? width / nchans : 1;
        real_T            *iter_cnt = (real_T *)ssGetDWork(S, ITER_IDX);
        
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
                    *iter_cnt = 0.0;  /* Will reset on zero count */
                }
            }
        }

        if (!c0) {
            /* 
             * Real input: 
             */
            real_T *msqsum = (real_T *)ssGetDWork(S, RMS_IDX); /* rms squared sum */

            if (*iter_cnt == 0.0) {
                int_T i = nchans;
                while(i-- > 0) {
                    *msqsum++ = 0.0;
                }
                msqsum -= nchans;
            }

            *iter_cnt += nsamps;

            {
                InputRealPtrsType uptr0 = ssGetInputPortRealSignalPtrs(S, INPORT_DATA);
                const real_T      den   = 1.0 / *iter_cnt;
                int_T             i     = nchans;
                
                while(i-- > 0) {
                    real_T tsqsum = *msqsum;
                    int_T  j      = nsamps;

                    while(j-- > 0) {
                        const real_T val = **uptr0++;
                        tsqsum += val*val;
                    }
                    *msqsum++ = tsqsum;
                    *y++      = sqrt(tsqsum * den);
                }
            }

        } else {
 	    /*
             * Complex input:
             */
            real_T *y      = (real_T *)ssGetOutputPortSignal(S, OUTPORT_DATA);
            real_T *msqsum = (real_T *)ssGetDWork(S, RMS_IDX);

            if (*iter_cnt == 0.0) {
                int_T i = nchans;
                while(i-- > 0) {
                    *msqsum++ = 0.0;
                }
                msqsum -= nchans;
            }

            *iter_cnt += nsamps;

            {
                InputRealPtrsType uptr0 = ssGetInputPortRealSignalPtrs(S, INPORT_DATA);
                const real_T      den   = 1.0 / *iter_cnt;
                int_T             i     = nchans;

                while(i-- > 0) {
                    real_T tsqsum = *msqsum;
                    int_T j       = nsamps;

                    while(j-- > 0) {
                        const creal_T val = *((creal_T *)(*uptr0++));
                        tsqsum += CMAGSQ(val);
                    }
                    *msqsum++ = tsqsum;
                    *y++      = sqrt(tsqsum * den);
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

    if (running) {
        /* Running rms: 2 inputs (Val, Rst), 1 output */
        if (port != 0) {  /* Input port 1 is not dynamic */
            THROW_ERROR(S, "Invalid input port number for running case");
        }
        ssSetInputPortWidth(S, port, inputPortWidth);

        {
            const boolean_T  frame    = (boolean_T)mxGetPr(FRAME_ARG)[0];
            const int_T      nchans   = (frame) ? (int_T)mxGetPr(NCHANS_ARG)[0] : inputPortWidth ;
            ssSetOutputPortWidth(S, OUTPORT_DATA, nchans);   
        }

    } else {
        /* RMS: 1 input, 1 output */
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
    const boolean_T running = (boolean_T)mxGetPr(RUN_ARG)[0];

    if (running) {
        /* Running rms: 2 inputs (Val, Rst), 1 output */
        if (port != 0) {
            THROW_ERROR(S, "Invalid output port number for running case");
        }
        ssSetOutputPortWidth(S,port,outputPortWidth);

        {
            const boolean_T frame = (boolean_T)mxGetPr(FRAME_ARG)[0];
        
            if (frame) {
                if (outputPortWidth != (int_T)mxGetPr(NCHANS_ARG)[0])  {
                    THROW_ERROR(S,"Invalid output port width propagation for frame-based"
                                   "running RMS");
                }
                /* Samples per frame unknown so we can't set the input port width */
            } else {
                /* Not frame based */
                ssSetInputPortWidth(S, INPORT_DATA, outputPortWidth);
            }
        }

    } else {
        /* RMS: 1 input, 1 output */
        /* Output port is a scalar (not dynamic) */
        THROW_ERROR(S, "Error propagating output port width info for non-running case");
    }
}

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const boolean_T running = (boolean_T)(mxGetPr(RUN_ARG)[0] != 0.0);
    const int_T     nDWorks = (running) ? MAX_NUM_DWORKS: 0;
    /* 
     * Work vectors are only needed when computing the running mean.
     */
    if(!ssSetNumDWork(S, nDWorks)) return;
    if(running){
        /* Running mean: */
        const int_T      N      = ssGetInputPortWidth(S, INPORT_DATA);
        const boolean_T  frame  = (boolean_T)mxGetPr(FRAME_ARG)[0];
        const int_T      nchans = (frame) ? (int_T)mxGetPr(NCHANS_ARG)[0] : N;

        /* Store one state per real/complex input element.
         *   RMS_IDX: stores 1 state per input element, purely real (mag squared)
         *   ITER_IDX scalar iteration index, purely real
         */
        ssSetDWorkWidth(        S, ITER_IDX, 1);
        ssSetDWorkDataType(     S, ITER_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, ITER_IDX, COMPLEX_NO);
        ssSetDWorkName(         S, ITER_IDX, "Iteration");
        ssSetDWorkUsedAsDState( S, ITER_IDX, 1);


        ssSetDWorkWidth(        S, RMS_IDX, nchans);
        ssSetDWorkDataType(     S, RMS_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, RMS_IDX, COMPLEX_NO);
        ssSetDWorkName(         S, RMS_IDX, "RMS");
        ssSetDWorkUsedAsDState( S, RMS_IDX, 1);
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

/* [EOF] sdsprms.c */
