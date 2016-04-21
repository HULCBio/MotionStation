/*
 * SDSPDSAMP  S-function which decreases the sampling rate 
 *     of a signal by downsampling by an integer factor.
 *     Start downsampling starting at specifid sample offset.
 *     DSP Blockset S-Function for downsampling input.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.23 $  $Date: 2002/04/14 20:42:00 $
 */

/*
 *                              LATENCY
 * 
 *     ----------------------------------------------------------------------
 *     |                   Sample-Based Mode                                | 
 *     ----------------------------------------------------------------------
 *     |               SingleTasking             MultiTasking               |
 *     |                                                                    |
 *     | SingleRate      <--------  N=1, phase=0, no ICs --------->         |
 *     | --------------------------------------------------------------------
 *     |                                                                    |
 *     | MultiRate  1) N>1, phase=0, no ICs                                 |
 *     |            2) N>1, phase>0, ICs         N>1, phase>=0, ICs         |
 *     ----------------------------------------------------------------------
 * 
 *
 *     ----------------------------------------------------------------------
 *     |                   Frame-Based Mode                                 | 
 *     ----------------------------------------------------------------------
 *     |               SingleTasking             MultiTasking               |
 *     |                                                                    |
 *     | SingleRate      <--------  N>=1, phase>=0, no ICs --------->       |
 *     | --------------------------------------------------------------------
 *     |                                                                    |
 *     | MultiRate       <--------  N>1, phase>=0, ICs --------->           |
 *     ----------------------------------------------------------------------
 */
#define S_FUNCTION_NAME sdspdsamp
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {COUNT_IDX=0, BUFF_IDX, NUM_DWORKS};
enum {OUTBUF_PTR=0, INBUF_PTR, NUM_PWORKS};

enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

enum {CONVFACTOR_ARGC=0, PHASE_ARGC, IC_ARGC, ENFORCE_MODE_ARGC, FRAME_ARGC, NCHANS_ARGC, OUTMODE_ARGC, NUM_ARGS};
#define CONVFACTOR_ARG  ssGetSFcnParam(S, CONVFACTOR_ARGC)
#define PHASE_ARG       ssGetSFcnParam(S, PHASE_ARGC)
#define IC_ARG          ssGetSFcnParam(S, IC_ARGC)
#define ENFORCE_MODE_ARG ssGetSFcnParam(S, ENFORCE_MODE_ARGC)
#define FRAME_ARG       ssGetSFcnParam(S, FRAME_ARGC)
#define NCHANS_ARG      ssGetSFcnParam(S, NCHANS_ARGC)
#define OUTMODE_ARG     ssGetSFcnParam(S, OUTMODE_ARGC)

typedef enum {
    fcnEqualSizes = 1,
    fcnEqualRates
} FcnType;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    static char *msg;
    real_T convfactor_dbl, phase_dbl;
    int_T  convfactor_int, phase_int;
    real_T d;
    int_T  i;

    msg = NULL;

    /* Downsample factor */
    if (OK_TO_CHECK_VAR(S, CONVFACTOR_ARG)) {
        if (mxGetNumberOfElements(CONVFACTOR_ARG) != 1) {
            msg = "Sample rate conversion factor must be a scalar";
            goto FCN_EXIT;
        }

        convfactor_dbl = mxGetPr(CONVFACTOR_ARG)[0];
        convfactor_int = (int_T)convfactor_dbl;
        if ((convfactor_dbl != convfactor_int) ||
            (convfactor_dbl <= (real_T)0.0)) {
            msg = "Sample rate conversion factor must be an integer > 0";
            goto FCN_EXIT;
        }
    }

    /* Sample offset */
    if (OK_TO_CHECK_VAR(S, PHASE_ARG)) {
        if (mxGetNumberOfElements(PHASE_ARG) != 1) {
            msg = "Phase must be a scalar";
            goto FCN_EXIT;
        }
        phase_dbl = mxGetPr(PHASE_ARG)[0];
        phase_int = (int_T)phase_dbl;

        if (phase_dbl != phase_int) {
            msg = "Sample offset must be an integer";
            goto FCN_EXIT;
        }
        if ((phase_int < 0) || (phase_int > convfactor_int-1)) {
            msg = "Sample offset must be an integer in the range [0:N-1]";
            goto FCN_EXIT;
        }
    }

    /* Initial conditions: */
    if (OK_TO_CHECK_VAR(S, IC_ARG)) {
        if (!mxIsNumeric(IC_ARG) || mxIsSparse(IC_ARG) ) {
            msg = "Initial conditions must be numeric.";
            goto FCN_EXIT;
        }
    }

     
    /* Sample mode */
    if ( !mxIsDouble(ENFORCE_MODE_ARG)                  || 
         (mxGetNumberOfElements(ENFORCE_MODE_ARG) != 1) || 
         ((mxGetPr(ENFORCE_MODE_ARG)[0] != 0.0)  && 
         (mxGetPr(ENFORCE_MODE_ARG)[0] != 1.0)   )      ) {
        msg = "Sample mode can be only 0 (don't enforce single-rate) or 1 (enforce single-rate)";
        goto FCN_EXIT;
    }


    /* Frame */
    if ( !mxIsDouble(FRAME_ARG)                  || 
         (mxGetNumberOfElements(FRAME_ARG) != 1) || 
         ((mxGetPr(FRAME_ARG)[0] != 0.0)  && 
         (mxGetPr(FRAME_ARG)[0] != 1.0)   )      ) {
        msg = "Frame can be only 0 (non-frame based) or 1 (frame-based)";
        goto FCN_EXIT;
    }

    /* Number of channels */
    if (OK_TO_CHECK_VAR(S, NCHANS_ARG)) {
        if ( !mxIsDouble(NCHANS_ARG) || 
             mxIsComplex(NCHANS_ARG) || 
             (mxGetNumberOfElements(NCHANS_ARG) != 1) ) {
            msg = "Number of channels must be a scalar";
            goto FCN_EXIT;
        }

        d = mxGetPr(NCHANS_ARG)[0];
        i = (int_T)d;
        if ( (d != i) || (i < 1) ) {
            msg = "Number of channels must be an integer > 0";
            goto FCN_EXIT;
        }
    }

    /* Function Mode */
    if ( !mxIsDouble(OUTMODE_ARG)                  || 
         (mxGetNumberOfElements(OUTMODE_ARG) != 1) || 
         ((mxGetPr(OUTMODE_ARG)[0] < 0.0)  && 
          (mxGetPr(OUTMODE_ARG)[0] > 1.0))
       ) {
        msg = "Output mode must be a scalar in the range [0,1].";
        goto FCN_EXIT;
    }


FCN_EXIT:
    THROW_ERROR(S,msg);
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

    /* All parameters are nontunable */
    ssSetSFcnParamNotTunable(S, CONVFACTOR_ARGC);
    ssSetSFcnParamNotTunable(S, PHASE_ARGC);
    ssSetSFcnParamNotTunable(S, IC_ARGC);
    ssSetSFcnParamNotTunable(S, ENFORCE_MODE_ARGC);
    ssSetSFcnParamNotTunable(S, FRAME_ARGC);
    ssSetSFcnParamNotTunable(S, NCHANS_ARGC);
    ssSetSFcnParamNotTunable(S, OUTMODE_ARGC);

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortReusable(         S, INPORT, 0);
    ssSetInputPortOverWritable(     S, INPORT, 0);  

    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 0);

    /* Set up inport/outport sample times: */
    {
        const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const boolean_T isEnforceSingleRate = (boolean_T)(mxGetPr(ENFORCE_MODE_ARG)[0] != 0.0);

        if (!isInputFrameBased && isEnforceSingleRate) {
            ssSetNumSampleTimes(S, 1);
        } else {
            ssSetNumSampleTimes(      S, PORT_BASED_SAMPLE_TIMES);    
            ssSetInputPortSampleTime( S, INPORT, INHERITED_SAMPLE_TIME);
            ssSetOutputPortSampleTime(S, OUTPORT, INHERITED_SAMPLE_TIME);
        }
    }

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    ssSetNumPWork(S, DYNAMICALLY_SIZED);

    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE |
                  SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const boolean_T isEnforceSingleRate = (boolean_T)(mxGetPr(ENFORCE_MODE_ARG)[0] != 0.0);

    if (!isInputFrameBased && isEnforceSingleRate) {
        THROW_ERROR(S, "Invalid call to set input port sample time in single-rate mode.");
    } 

    if (sampleTime == CONTINUOUS_SAMPLE_TIME)  {
       THROW_ERROR(S,"Continuous sample times not allowed for downsample blocks.");
    }

    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed.");
    }

    ssSetInputPortSampleTime(S, INPORT, sampleTime);
    ssSetInputPortOffsetTime(S, INPORT, offsetTime);

    /* Set output port sample time: */
    {
        const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const FcnType ftype    = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
        const int_T convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
        const real_T  Tso      = ((isInputFrameBased) && (ftype == fcnEqualRates)) 
                               ? sampleTime : sampleTime*convfactor;

        ssSetOutputPortSampleTime(S, OUTPORT, Tso);
    }
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const boolean_T isEnforceSingleRate = (boolean_T)(mxGetPr(ENFORCE_MODE_ARG)[0] != 0.0);

    if (!isInputFrameBased && isEnforceSingleRate) {
        THROW_ERROR(S, "Invalid call to set output port sample time in single-rate mode.");
    } 

    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
       THROW_ERROR(S,"Continuous sample times not allowed for downsample blocks.");
    }

    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed.");
    }

    ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
    ssSetOutputPortOffsetTime(S, OUTPORT, offsetTime);

    /* Set input port sample time: */
    {
        const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const FcnType ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
        const int_T   convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
        const real_T  Tsi        = ((isInputFrameBased) && (ftype == fcnEqualRates)) ? sampleTime
                                                                                     : sampleTime/convfactor;

        ssSetInputPortSampleTime(S, INPORT, Tsi);
    }
    ssSetInputPortOffsetTime(S, INPORT, 0.0);
}
#endif


static void mdlInitializeSampleTimes(SimStruct *S)
{
    const boolean_T  isEnforceSingleRate = (boolean_T)(mxGetPr(ENFORCE_MODE_ARG)[0] != 0.0);
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);

    if (!isInputFrameBased && isEnforceSingleRate) {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, 0.0);

    } else {
        /* Check port sample times: */
        const real_T Tsi = ssGetInputPortSampleTime(S, INPORT);
        const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);

        if ((Tsi == INHERITED_SAMPLE_TIME)  ||
            (Tso == INHERITED_SAMPLE_TIME)   ) {
            THROW_ERROR(S,"Sample time propagation failed for downsample block.");
        }
    }
}



#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const boolean_T frame   = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nchans  = (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T     width   = ssGetInputPortWidth(S, INPORT);

    if (frame && (width % nchans != 0)) {
        ssSetErrorStatus(S,"Size of input matrix does not match number of channels");
        return;
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const boolean_T isMultiRate = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = (boolean_T)(ssGetSolverMode(S) == SOLVER_MODE_MULTITASKING);

    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const boolean_T isEnforceSingleRate = (boolean_T)(mxGetPr(ENFORCE_MODE_ARG)[0] != 0.0);

    const boolean_T cplx       = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const int_T     numIC      = mxGetNumberOfElements(IC_ARG);
    const int_T     outWidth   = ssGetOutputPortWidth(S, OUTPORT);
    const int32_T   phase      = (int32_T)(mxGetPr(PHASE_ARG)[0]);
    const int_T     convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);

    /* Latency (ICs) is required for all multi-rate modes,
     * except for multi-rate, sample-based, single-tasking with no phase offeset (whew!)
     */
    const boolean_T  needICs  = ( (!isInputFrameBased && isEnforceSingleRate) || 
                                      (isMultiRate && !(!isInputFrameBased && (!isMultiTasking) && (phase == 0))));

    /* Reset counter */
    *((int32_T *)ssGetDWork(S, COUNT_IDX)) = (phase == 0) ? 0 : convfactor - phase;

    if (needICs) {
        /* Initialize buffer for modes that require ICs */

        if (!cplx) {
            /* Real input */
            real_T *pIC    = mxGetPr(IC_ARG);
            real_T *outBuf = (real_T *)ssGetDWork(S, BUFF_IDX);

            /* Set the first PWork for all modes (that require latency) */
            ssSetPWorkValue(S, OUTBUF_PTR, outBuf); 

            /* Set the second PWork for the multi-rate mode only */
            if (isMultiRate) {
                ssSetPWorkValue(S, INBUF_PTR,  outBuf + outWidth);
            }

            if (numIC <= 1) {
	        /* Scalar expansion, or no IC's given: */
                real_T ic = (numIC == 0) ? (real_T)0.0 : *pIC;
                int_T i;

	        for(i = 0; i < outWidth; i++) {
	            *outBuf++ = ic;
	        }

            } else {
	        memcpy(outBuf, pIC, outWidth * sizeof(real_T));
            }

        } else {
            /* Complex inputs */
	    real_T          *prIC    = mxGetPr(IC_ARG);
	    real_T          *piIC    = mxGetPi(IC_ARG);
            creal_T         *outBuf  = (creal_T *)ssGetDWork(S, BUFF_IDX);
            const boolean_T  ic_cplx = (boolean_T)(piIC != NULL);
            int_T            i;
	    
            /* Set the first PWork for all modes (that require latency) */
            ssSetPWorkValue(S, OUTBUF_PTR, outBuf);

            /* Set the second PWork for the multi-rate mode only */
            if (isMultiRate) {
                ssSetPWorkValue(S, INBUF_PTR,  outBuf + outWidth);
            }

	    if (numIC <= 1) {
	        /* Scalar expansion, or no IC's given: */
	        creal_T ic;
	        if (numIC == 0) {
		    ic.re = 0.0;
		    ic.im = 0.0;
	        } else {
		    ic.re = *prIC;
		    ic.im = (ic_cplx) ? *piIC : 0.0;
	        }

	        for(i = 0; i < outWidth; i++) {
		    *outBuf++ = ic;
	        }

            } else {
	        if (ic_cplx) {
		    for(i = 0; i < outWidth; i++) {
		        outBuf->re     = *prIC++;
		        (outBuf++)->im = *piIC++;
		    }
	        } else {
		    for(i = 0; i < outWidth; i++) {
		        outBuf->re     = *prIC++;
		        (outBuf++)->im = 0.0;
		    }
	        }
	    }
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T isMultiRate = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = (boolean_T)(ssGetSolverMode(S) == SOLVER_MODE_MULTITASKING);
    const boolean_T isEnforceSingleRate = (boolean_T)(mxGetPr(ENFORCE_MODE_ARG)[0] != 0.0);

    const int_T OutportTid = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    const int_T InportTid  = ssGetInputPortSampleTimeIndex(S, INPORT);

    const boolean_T  cplx                  = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    int32_T         *counter               = (int32_T *)ssGetDWork(S, COUNT_IDX);
    const int_T      convfactor            = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
    const int_T      phase                 = (int_T) (mxGetPr(PHASE_ARG)[0]);
    const boolean_T  isInputFrameBased     = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T      inWidth               = ssGetInputPortWidth(S, INPORT);
    const int_T      outWidth              = ssGetOutputPortWidth(S, OUTPORT);
    const int_T      nChans                = (isInputFrameBased) ? (int_T)(mxGetPr(NCHANS_ARG)[0]) : inWidth;
    const int_T      SamplesPerInputFrame  = inWidth/nChans;
    int_T n;
    int_T c;

    /* Latency (ICs) is required for all multi-rate modes,
     * except for multi-rate, sample-based, single-tasking with no phase offeset 
     */
    const boolean_T  needICs  = ( (!isInputFrameBased && isEnforceSingleRate) || 
                                      (isMultiRate && !(!isInputFrameBased && (!isMultiTasking) && (phase == 0))));

    if (!needICs) {
        if (!cplx) {
            /* Real input */
            real_T            *y     = ssGetOutputPortRealSignal(S, OUTPORT);
            InputRealPtrsType  uptr  = ssGetInputPortRealSignalPtrs(S,INPORT);

            for (n = 0; n < nChans; n++) {
                int_T i;
                c = *counter; /* Reset counter for each channel */

                for (i=0; i<SamplesPerInputFrame; i++) {
                    if (c++ == 0)   *y++ = **uptr++;
                    else            uptr++;
                    if (c == convfactor)    c = 0;
                }
            }
            *counter = c; /* Update counter for next sample hit */
        
        } else {
            /* Complex input */
            creal_T *y      = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
	    InputPtrsType  uptr  = ssGetInputPortSignalPtrs(S,INPORT);

            for (n = 0; n < nChans; n++) {
                int_T i;
                c = *counter; /* Reset counter for each channel */

                for (i=0; i<SamplesPerInputFrame; i++) {
                    if (c++ == 0)   *y++ = *((creal_T *)(*uptr++));
                    else            uptr++;
                    if (c == convfactor)    c = 0;
                }
            }
            *counter = c; /* Update counter for next sample hit */
        }

    } else {

        if (!isInputFrameBased && isEnforceSingleRate) {
            if (!cplx) {
                /* Real input */
                real_T            *y      = ssGetOutputPortRealSignal(S, OUTPORT);
                InputRealPtrsType  uptr   = ssGetInputPortRealSignalPtrs(S,INPORT);
                real_T            *outBuf = (real_T *)ssGetPWorkValue(S, OUTBUF_PTR);

                for (n = 0; n < nChans; n++) {
                    c = *counter; /* Reset counter for each channel */

                    if (c++ == 0)   *outBuf = **uptr++;
                    if (c == convfactor)    c = 0;
                
                    *y++ = *outBuf++;
                }
                *counter = c; /* Update counter for next sample hit */

            } else {
                /* Complex input */
                creal_T        *y      = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
                InputPtrsType   uptr   = ssGetInputPortSignalPtrs(S,INPORT);
                creal_T        *outBuf = (creal_T *)ssGetPWorkValue(S, OUTBUF_PTR);

                for (n = 0; n < nChans; n++) {
                    c = *counter; /* Reset counter for each channel */

                    if (c++ == 0)   *outBuf = *((creal_T *)(*uptr++));
                    if (c == convfactor)    c = 0;
                
                    *y++ = *outBuf++;
                }
                *counter = c; /* Update counter for next sample hit */
            }

        } else {

            if (ssIsSampleHit(S, OutportTid, tid)) {
                const int_T     outWidth = ssGetOutputPortWidth(S, OUTPORT);
    
                if (!cplx) {
                    /* Real */
                    real_T *y      = ssGetOutputPortRealSignal(S, OUTPORT);
                    real_T *outBuf = (real_T *)ssGetPWorkValue(S, OUTBUF_PTR);
                    int_T   i      = outWidth;

                    while (i-- > 0) {
                        *y++ = *outBuf++;
                    }
                    {
                        real_T *aBuf = (real_T *)ssGetDWork(S, BUFF_IDX);
                        if (outBuf == aBuf + 2*outWidth) {
                            outBuf = aBuf ;
                        }
                        ssSetPWorkValue(S, OUTBUF_PTR, outBuf);
                    }

                } else {
                    /* Complex input */
                    creal_T *y      = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
                    creal_T *outBuf = (creal_T *)ssGetPWorkValue(S, OUTBUF_PTR);
                    int_T    i      = outWidth;

                    while (i-- > 0) {
                        *y++ = *outBuf++;
                    }
                    {
                        creal_T *aBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);
                        if (outBuf == aBuf + 2*outWidth) {
                            outBuf = aBuf ;
                        }
                        ssSetPWorkValue(S, OUTBUF_PTR, outBuf);
                    }
                }
            }

            if (ssIsSampleHit(S, InportTid, tid)) {

                if (isInputFrameBased) {
                    /* Frame-based inputs */

                    if (!cplx) {
                        /* Real input*/
                        InputRealPtrsType uptr  = ssGetInputPortRealSignalPtrs(S,INPORT);
                        real_T           *inBuf;

                        for (n = 0; n < nChans; n++) {
                            int_T   i;

                             /* Point to current channel */
                            inBuf = (real_T *)ssGetPWorkValue(S, INBUF_PTR) + n*SamplesPerInputFrame;

                            c = *counter; /* Reset counter for each channel */

                            for (i=0; i<SamplesPerInputFrame; i++) {
                                if (c++ == 0) *inBuf++ = **uptr++;
                                else uptr++;

                                if (c == convfactor) c = 0;
                            }
                        }
                        *counter = c; /* Update counter for next sample hit */

                        {
                            real_T *aBuf = (real_T *)ssGetDWork(S, BUFF_IDX);
                            /*
                             *  We are not in general through with filling any one buffer segment
                             *  at this point in time.  So in the general case, we just want to
                             *  back up the pointer into the first channel data segment.
                             *
                             *  However, if we happen to have finished filling the segment, we need
                             *  to "wrap" the pointer around and swap the input & output buffers.
                             *  Thus, if the pointer is now beyond the total allocation, we wrap it
                             *  back to the start of the total allocation.  On the other hand, if the
                             *  pointer has moved from the first half of the total allocation to the
                             *  second half, we move it to ... right where it is!  Leave it alone in
                             *  this case.  Way too long of a comment here...
                             */
                            if (inBuf == aBuf + 2*outWidth) {
                                inBuf = aBuf;
                            } else if (inBuf != aBuf + outWidth) {
                                /* Backup pointer to point to first channel */
                                inBuf -= (nChans-1)*SamplesPerInputFrame;
                            }
                            ssSetPWorkValue(S, INBUF_PTR, inBuf);
                        }

                    } else {
                        /* Complex input */
                        InputPtrsType   uptr   = ssGetInputPortSignalPtrs(S,INPORT);
                        creal_T         *inBuf = (creal_T *)ssGetPWorkValue(S, INBUF_PTR);

                        for (n = 0; n < nChans; n++) {
                            int_T   i;

                             /* Point to current channel */
                            inBuf = (creal_T *)ssGetPWorkValue(S, INBUF_PTR) + n*SamplesPerInputFrame;

                            c = *counter; /* Reset counter for each channel */

                            for (i=0; i<SamplesPerInputFrame; i++) {
                                if (c++ == 0) *inBuf++ = *((creal_T *)(*uptr++));
                                else uptr++;

                                if (c == convfactor) c = 0;
                            }
                        }
                        *counter = c; /* Update counter for next sample hit */

                        {
                            creal_T *aBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);
                            /*
                             *  We are not in general through with filling any one buffer segment
                             *  at this point in time.  So in the general case, we just want to
                             *  back up the pointer into the first channel data segment.
                             *
                             *  However, if we happen to have finished filling the segment, we need
                             *  to "wrap" the pointer around and swap the input & output buffers.
                             *  Thus, if the pointer is now beyond the total allocation, we wrap it
                             *  back to the start of the total allocation.  On the other hand, if the
                             *  pointer has moved from the first half of the total allocation to the
                             *  second half, we move it to ... right where it is!  Leave it alone in
                             *  this case.  Way too long of a comment here...
                             */
                            if (inBuf == aBuf + 2*outWidth) {
                                inBuf = aBuf;
                            } else if (inBuf != aBuf + outWidth) {
                                /* Backup pointer to point to first channel */
                                inBuf -= (nChans-1)*SamplesPerInputFrame;
                            }
                            ssSetPWorkValue(S, INBUF_PTR, inBuf);
                        }

                    
                    }

                } else {
                    /* Sample-based inputs */

                    if (!cplx) {
                        /* Real input*/
                        InputRealPtrsType  uptr  = ssGetInputPortRealSignalPtrs(S,INPORT);
                        real_T            *inBuf = (real_T *)ssGetPWorkValue(S, INBUF_PTR);

                        for (n = 0; n < nChans; n++) {
                            int_T   i;

                            c = *counter; /* Reset counter for each channel */

                            for (i=0; i<SamplesPerInputFrame; i++) {
                                if (c++ == 0) *inBuf++ = **uptr++;
                                else uptr++;

                                if (c == convfactor)    c = 0;
                            }
                        }

                        *counter = c; /* Update counter for next sample hit */

                        {
                            real_T *aBuf = (real_T *)ssGetDWork(S, BUFF_IDX);
                            if (inBuf == aBuf + 2*outWidth) {
                                inBuf = aBuf ;
                            } 
                            ssSetPWorkValue(S, INBUF_PTR, inBuf);
                        }
                    
                    } else {
                        /* Complex input */

                        InputPtrsType   uptr   = ssGetInputPortSignalPtrs(S,INPORT);
                        creal_T         *inBuf = (creal_T *)ssGetPWorkValue(S, INBUF_PTR);

                        for (n = 0; n < nChans; n++) {
                            int_T   i;
                            c = *counter; /* Reset counter for each channel */
                    
                            for (i=0; i<SamplesPerInputFrame; i++) {
                                if (c++ == 0)   *inBuf++ = *((creal_T *)(*uptr++));
                                else            uptr++;
                                if (c == convfactor)    c = 0;
                            }
                        }

                        *counter = c; /* Update counter for next sample hit */

                        {
                            creal_T *aBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);
                            if (inBuf == aBuf + 2*outWidth) {
                                inBuf = aBuf ;
                            } 
                            ssSetPWorkValue(S, INBUF_PTR, inBuf);
                        }
                    }
                } 
            }
        }
    }
}

static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const boolean_T isMultiRate = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = (boolean_T)(ssGetSolverMode(S) == SOLVER_MODE_MULTITASKING);
    const boolean_T isEnforceSingleRate = (boolean_T)(mxGetPr(ENFORCE_MODE_ARG)[0] != 0.0);

    const FcnType   ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
    const int_T     convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
    const int32_T   phase      = (int32_T)(mxGetPr(PHASE_ARG)[0]);
    const int_T     outWidth   = ssGetOutputPortWidth(S, OUTPORT);
    const CSignal_T cplx       = ssGetInputPortComplexSignal(S, INPORT);

    /* Latency (ICs) is required for all multi-rate modes,
     * except for multi-rate, sample-based, single-tasking with no phase offeset 
     */
    const boolean_T  needICs  = ( (!isInputFrameBased && isEnforceSingleRate) || 
                                      (isMultiRate && !(!isInputFrameBased && (!isMultiTasking) && (phase == 0))));

    /* Set PWorks and DWorks: */ 
    if (needICs) {
        if (!ssSetNumDWork(S, NUM_DWORKS)) return;         /* Counter and ICs */
        if ((!isInputFrameBased && isEnforceSingleRate)) ssSetNumPWork(S, NUM_PWORKS-1);
        else                                             ssSetNumPWork(S, NUM_PWORKS);
    } else {
        if (!ssSetNumDWork(S, NUM_DWORKS-1)) return;        /* Counter (no ICs) */
        ssSetNumPWork(S, NUM_PWORKS-2);
    }

    /* Counter */
    ssSetDWorkWidth(        S, COUNT_IDX, 1);
    ssSetDWorkDataType(     S, COUNT_IDX, SS_INT32);
    ssSetDWorkComplexSignal(S, COUNT_IDX, COMPLEX_NO);
    ssSetDWorkName(         S, COUNT_IDX, "Count");
    ssSetDWorkUsedAsDState( S, COUNT_IDX, 1);

    if (needICs) {
        /* Buffer */
        ssSetDWorkWidth(        S, BUFF_IDX, (outWidth * ((!isInputFrameBased && isEnforceSingleRate) ? 1 : 2)));  
        ssSetDWorkDataType(     S, BUFF_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, BUFF_IDX, cplx ? COMPLEX_YES : COMPLEX_NO);
        ssSetDWorkName(         S, BUFF_IDX, "Buffer");
        ssSetDWorkUsedAsDState( S, BUFF_IDX, 1);    

        /* IC checking */
        {
            const int_T numIC   = mxGetNumberOfElements(IC_ARG);
  
            /* We need to make sure the IC vector is not bigger than our output width
             * because we are allocating the dwork storage based on the output width.
             * The output width can be smaller than the input width when the mode is
             * set to "equal rates" and the downsample factor is greater than one.
             */
            if ((numIC != 0) && (numIC != 1)
                && (numIC != outWidth)) {
                ssSetErrorStatus(S, "Initial condition vector does not match output dimensions");
                return;
            }

            if ((cplx == COMPLEX_NO) && mxIsComplex(IC_ARG)) {
	        ssSetErrorStatus(S, "Complex initial conditions are not allowed with real inputs.");
	        return;
            }
        }
    }
}


# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const FcnType ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
    const int_T   convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
    const int_T   nChans     = (isInputFrameBased) ? (int_T)(mxGetPr(NCHANS_ARG)[0]) : inputPortWidth;
    const int_T   nFsamps    = inputPortWidth/nChans;
          int_T   outWidth;
    static char   *msg;
    static char   errmsg[256];

    msg = NULL;
 
    if ((isInputFrameBased) && (ftype == fcnEqualRates)) {
        if (inputPortWidth / convfactor < nChans) {
            msg = errmsg;
            sprintf(msg, "Downsampling more than the number of samples per frame is not allowed. \
There are %d number of samples per frame for this block, which is calculated by (inWidth / nChans).", nFsamps);
            goto FCN_EXIT;

        } else if (inputPortWidth % convfactor != 0) {
            msg = "Input width must be a multiple of conversion factor when rates are the same.";
            goto FCN_EXIT;
        
        } else if(nFsamps % convfactor != 0) {
            msg = errmsg;
            sprintf(msg, "The downsample factor must be a multiple of samples per frame. \
Thre are %d number of samples per frame for this block, which is calculated by (inWidth / nChans).", nFsamps);
            goto FCN_EXIT;

        } else {
            outWidth = inputPortWidth/convfactor;      /* Valid outport width setting. */
        }

    } else {
        outWidth = inputPortWidth;
    }

    ssSetInputPortWidth(S, port, inputPortWidth);
    ssSetOutputPortWidth(S, OUTPORT, outWidth);   


FCN_EXIT:
    ssSetErrorStatus(S,msg);
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const FcnType ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
    const int_T   convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
    const int_T   inWidth    = ((isInputFrameBased) && (ftype == fcnEqualRates)) ? outputPortWidth*convfactor :outputPortWidth;

    ssSetOutputPortWidth(S, port, outputPortWidth);   
    ssSetInputPortWidth(S, INPORT, inWidth);   
}
#endif

#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    /* If the IC parameter is an empty matrix we'll assign it to be zero,
     * so that ssWriteRTWParamSettings will not error out.  Setting IC to
     * zero when it is specified as an empty matrix is consistent with the
     * functionality of the rebuffer block.
     */
    int_T   numIC       = 1; 
    real_T  zero        = 0;
    real_T  *IC_re      = &zero;
    real_T  *IC_im      = NULL;
    int32_T icRows      = (int32_T)mxGetM(IC_ARG);
    int32_T icCols      = (int32_T)mxGetN(IC_ARG);
    int32_T convfactor  = (int32_T)mxGetPr(CONVFACTOR_ARG)[0];
    int32_T phase       = (int32_T)mxGetPr(PHASE_ARG)[0];
    int32_T outmode     = (int32_T)mxGetPr(OUTMODE_ARG)[0];
    int32_T nChans      = (int32_T)mxGetPr(NCHANS_ARG)[0];

    const boolean_T isMultiRate = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = (boolean_T)(ssGetSolverMode(S) == SOLVER_MODE_MULTITASKING);
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const boolean_T isEnforceSingleRate = (boolean_T)(mxGetPr(ENFORCE_MODE_ARG)[0] != 0.0);
    /* Latency (ICs) is required for all multi-rate modes,
     * except for multi-rate, sample-based, single-tasking with no phase offeset 
     */
    const boolean_T  needICs  = ( (!isInputFrameBased && isEnforceSingleRate) || 
                                      (isMultiRate && !(!isInputFrameBased && (!isMultiTasking) && (phase == 0))));

    /* Write out the PWork record to the RTW file. */ 
    if (needICs) {
        if ((!isInputFrameBased && isEnforceSingleRate)) {
            if(!ssWriteRTWWorkVect(S, "PWork", 1, "pOutBuf", 1)) return;   
        } else {
            if(!ssWriteRTWWorkVect(S, "PWork", 2, "pOutBuf", 1, "pInBuf", 1 )) return;   
        }
    }

    if(!mxIsEmpty(IC_ARG)) {
        numIC = mxGetNumberOfElements(IC_ARG);
        IC_re = mxGetPr(IC_ARG);
        IC_im = mxGetPi(IC_ARG);
    }
    
    if (!ssWriteRTWParamSettings(S, 9,
                                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC", IC_re, 
                                 IC_im, numIC, 
                                 DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG)),

                                 SSWRITE_VALUE_DTYPE_NUM,  "IC_ROWS",
                                 &icRows,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "IC_COLS",
                                 &icCols,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "CONVFACTOR",
                                 &convfactor,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "PHASE",
                                 &phase,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "OUTMODE",
                                 &outmode,
                                 DTINFO(SS_INT32,0),
                                 
                                 SSWRITE_VALUE_DTYPE_NUM,  "isInputFrameBased",
                                 &isInputFrameBased,
                                 DTINFO(SS_BOOLEAN,COMPLEX_NO),

                                 SSWRITE_VALUE_DTYPE_NUM,  "isEnforceSingleRate",
                                 &isEnforceSingleRate,
                                 DTINFO(SS_BOOLEAN,COMPLEX_NO),

                                 SSWRITE_VALUE_DTYPE_NUM,  "NCHANS",
                                 &nChans,
                                 DTINFO(SS_INT32,0))) {
        return;
    }
}
#endif

#include "dsp_cplxhs11.c"

#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
