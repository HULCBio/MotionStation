/*
 *  SDSPBIQUAD: Second-order section (biquad) filter implementation for DSP Blockset.
 *   - Uses direct-form II transpose implementation.
 *   - Supports real and complex data and filters.
 *   - Supports sample- and frame-based filtering
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.22 $  $Date: 2002/04/14 20:41:41 $
 */
#define S_FUNCTION_NAME sdspbiquad
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {ARGC_SOS=0, ARGC_IC, ARGC_CHANS, NUM_ARGS};
#define SOS_ARG   ssGetSFcnParam(S,ARGC_SOS)   /* Second-order section matrix */
#define IC_ARG    ssGetSFcnParam(S,ARGC_IC)   /* Initial conditions */
#define CHANS_ARG ssGetSFcnParam(S,ARGC_CHANS) /* Number of Channels for frame-based */

#define SAMPLE_BASED -1

enum {INPORT=0,  NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};
enum {DISC_STATE=0, NUM_DWORKS};

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char      *msg        = NULL;
    const boolean_T runTime     = (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);
    int_T M, N;
    
    if (runTime || !mxIsEmpty(CHANS_ARG)) {
        if ( (mxGetNumberOfElements(CHANS_ARG) != 1) || 
             (((int_T) mxGetPr(CHANS_ARG)[0]) != mxGetPr(CHANS_ARG)[0]) ||
             ((mxGetPr(CHANS_ARG)[0] <= 0.0)  && (mxGetPr(CHANS_ARG)[0] != SAMPLE_BASED))
           ) {
            msg = "The number of channels must be an integer > 0, or must be "
	          "set to -1 for non-frame based operation.";
            goto FCN_EXIT;
        }
    }
    
    /* Check size of SOS_ARG
     * NOTE: this must be a "processed" 5xN matrix,
     *       while the original sos is Mx6
     */
    M = mxGetM(SOS_ARG);
    N = mxGetN(SOS_ARG);

    if (runTime || !mxIsEmpty(SOS_ARG)) {
        if ((M!=5) || (N==0)) {
            msg = "Second-order section matrix must be a non-empty Mx6 matrix";
            goto FCN_EXIT;
        }
    }
        
FCN_EXIT:
    ssSetErrorStatus(S,msg);
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
    
    ssSetSFcnParamNotTunable(S, ARGC_SOS);
    ssSetSFcnParamNotTunable(S, ARGC_IC);
    ssSetSFcnParamNotTunable(S, ARGC_CHANS);

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

    ssSetInputPortWidth	(           S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 1);
    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;

    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    if(!ssSetNumDWork( S, DYNAMICALLY_SIZED)) return;
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T	    inWidth     = ssGetInputPortWidth(S, INPORT);
    const int_T     chans_arg   = (int_T)(mxGetPr(CHANS_ARG)[0]);
    const boolean_T isFrame     = (boolean_T)(chans_arg != SAMPLE_BASED);
    const int_T	    numChans    = (isFrame) ? chans_arg : inWidth;
    const boolean_T isComplex   = (ssGetDWorkComplexSignal(S, DISC_STATE) == COMPLEX_YES);
    const boolean_T ICcomplex   = mxIsComplex(IC_ARG);
    const int_T     M           = mxGetM(SOS_ARG);
    const int_T     N           = mxGetN(SOS_ARG);
    const int_T     M1          = mxGetM(IC_ARG);
    const int_T     N1          = mxGetN(IC_ARG);
    
    if (isFrame && (inWidth % numChans != 0)) {
        ssSetErrorStatus (S, "The port width must be a multiple of the number of channels");
        return;
    }
    if (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME) {
        ssSetErrorStatus(S, "Input to block must have a discrete sample time");
        return;
    }
    if (ICcomplex && !isComplex) {
        ssSetErrorStatus(S, "Complex initial conditions can only be used if either the "
            "filter or the data are complex");
        return;
    }
    /* Check the size of the initial conditions */
    /* Check Single IC per channel or Full matrix of ICs ? */
    if (M1*N1 > 1 && numChans > 0 &&  M*N > 0) {
        if (M1*N1 != N*2 && !(M1 == N*2 && N1 == numChans)) {
            ssSetErrorStatus(S, "Valid initial conditions are:\n"
                "empty vector:  Treated as zero.\n"
                "scalar:        Scalar expanded to all filter states.\n"
                "vector:        Vector length = 2 * (number of second-order sections).\n"
                "               Applied to each channel.\n"
                "2-D matrix:    Number of rows = 2 * (number of second-order sections).\n"
                "               Number of columns = number of channels");
        }
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const int_T	    inWidth     = ssGetInputPortWidth(S, INPORT);
    const int_T     chans_arg   = (int_T)(mxGetPr(CHANS_ARG)[0]);
    const boolean_T isFrame     = (boolean_T)(chans_arg != SAMPLE_BASED);
    const int_T	    numChans    = (isFrame) ? chans_arg : inWidth;
    const int_T     M           = mxGetM(SOS_ARG);
    const int_T     N           = mxGetN(SOS_ARG);    
    const int_T     M1          = mxGetM(IC_ARG);
    const int_T     N1          = mxGetN(IC_ARG);
    const boolean_T isComplex   = (ssGetDWorkComplexSignal(S, DISC_STATE) == COMPLEX_YES);
    const boolean_T ICcomplex   = mxIsComplex(IC_ARG);
    int_T i, j;

    if (M1*N1 <= 1) { /* Single IC */
        i = ssGetDWorkWidth(S, DISC_STATE);
        if (isComplex) {
            creal_T *states = (creal_T *) ssGetDWork(S, DISC_STATE);
            creal_T ic;

            if (M1*N1 == 0) {
                ic.re = ic.im = (real_T) 0.0;
            } else { 
                ic.re = *mxGetPr(IC_ARG); 
                ic.im = ((ICcomplex) ? *mxGetPi(IC_ARG) : (real_T) 0.0);
            }
            for (j=0; j++ < i;    ) *states++ = ic;
        } else {
            real_T *states = (real_T *) ssGetDWork(S, DISC_STATE);
            if (M1*N1 == 0) {
                for (j=0; j++ < i;    ) *states++ = (real_T) 0.0;
            } else {
                for (j=0; j++ < i;    ) *states++ = *mxGetPr(IC_ARG);
            }
        }
    } else if (M1*N1 == 2*N) { /* Vector of IC's copied to each channel */
        const int_T statesPerChan = ssGetDWorkWidth(S, DISC_STATE) / numChans;
        if (isComplex) {
            creal_T *states = (creal_T *) ssGetDWork(S, DISC_STATE);
            for (i=0; i++ < numChans;    ) {
                real_T  *icr    = mxGetPr(IC_ARG);
                real_T  *ici    = mxGetPi(IC_ARG);
                for (j=0; j++ < statesPerChan;    ) {
                    creal_T ic;
                    ic.re = *icr++;
                    ic.im = ((ICcomplex) ? *ici++ : (real_T) 0.0);
                    *states++ = ic;
                }
            }
        } else {
            real_T *states = (real_T *) ssGetDWork(S, DISC_STATE);
            for (i=0; i++ < numChans;    ) {
                real_T  *ic = mxGetPr(IC_ARG);
                for (j=0; j++ < statesPerChan;    ) *states++ = *ic++;
            }
        }
    } else { /* Full matrix of ICs: N second-order sections per channel */
        i = ssGetDWorkWidth(S, DISC_STATE);
        if (isComplex) {
            creal_T *states = (creal_T *) ssGetDWork(S, DISC_STATE);
            real_T  *icr    = mxGetPr(IC_ARG);
            real_T  *ici    = mxGetPi(IC_ARG);
            creal_T ic;
            for (j=0; j++ < i;    ) {
                ic.re = *icr++;
                ic.im = ((ICcomplex) ? *ici++ : (real_T) 0.0);
                *states++ = ic;
            }
        } else {
            real_T  *states = (real_T *) ssGetDWork(S, DISC_STATE);
            real_T  *ic     = mxGetPr(IC_ARG);
            for (j=0; j++ < i;    ) *states++ = *ic++;
        }
    }
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    /*
     * Arrangement of input samples:
     *    Channel1:[u[t1] u[t2] ... u[tJ]]  (frame for channel 1)
     *    Channel2:[u[t1] u[t2] ... u[tJ]]  (frame for channel 2)
     *           ...
     *    ChannelI:[u[t1] u[t2] ... u[tJ]]  (frame for channel I)
     *
     * Arrangement of states in memory:
     *    Channel1: [Sect1: [state0, state1], Sect2: [state0, state1], ... SectK[state0, state1]]
     *    Channel2: [Sect1: [state0, state1], Sect2: [state0, state1], ... SectK[state0, state1]]
     *      ...
     *    ChannelI: [Sect1: [state0, state1], Sect2: [state0, state1], ... SectK[state0, state1]]
     *
     * Arrangement of coefficients:
     *    Sect1: [b0,b1,b2,a1,a2]  (numerator then denominator)
     *    Sect2: [b0,b1,b2,a1,a2]  (these are the same for all channels)
     *     ...
     *    SectK: [b0,b1,b2,a1,a2]
     */
    const int_T		inWidth	        = ssGetInputPortWidth(S, INPORT);
    const int_T         chans_arg       = (int_T)(mxGetPr(CHANS_ARG)[0]);
    const boolean_T     isFrame         = (boolean_T)(chans_arg != SAMPLE_BASED);
    const int_T		numChans	= (isFrame) ? chans_arg           : inWidth;
    const int_T         numTimeSteps    = (isFrame) ? inWidth / chans_arg : 1;
    const int_T         numSections     = mxGetN(SOS_ARG);
    const boolean_T     ComplexCoeffs   = (boolean_T)(mxIsComplex(SOS_ARG));
    const boolean_T     ComplexInputs   = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);

    if (ComplexInputs) {

        if (ComplexCoeffs) {
            /*
             * Complex inputs, complex coefficients - complex output:
             */
            InputPtrsType uptr = ssGetInputPortSignalPtrs(S, INPORT);
            creal_T      *y     = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
            creal_T      *mem0  = (creal_T *)ssGetDWork(S, DISC_STATE);
            int_T i;

            for (i=0; i++ < numChans; ) {
                int_T j;

                for (j=0; j++ < numTimeSteps; ) {
                    creal_T *mem    = mem0;
                    real_T  *cr     = mxGetPr(SOS_ARG);
		    real_T  *ci     = mxGetPi(SOS_ARG);
                    creal_T in      = *((creal_T *)(*uptr++));
                    creal_T out;
                    int_T k;

                    for (k=0; k++ < numSections; ) {
                        out.re = mem->re + in.re * *cr   - in.im * *ci;
                        out.im = mem->im + in.re * *ci++ + in.im * *cr++;

                        mem->re     = (mem+1)->re + (in.re * *cr - in.im * *ci)
                                    - (out.re * *(cr+2) - out.im * *(ci+2));
                        mem->im     = (mem+1)->im + (in.re * *ci + in.im * *cr)
                                    - (out.re * *(ci+2) + out.im * *(cr+2));
                        ++mem;

                        mem->re     = (in.re * *(cr+1) - in.im * *(ci+1))  
                                    - (out.re * *(cr+3) - out.im * *(ci+3));
                        (mem++)->im = (in.re * *(ci+1) + in.im * *(cr+1))
                                    - (out.re * *(ci+3) + out.im * *(cr+3));

                        in = out;
                        cr += 4;
                        ci += 4;
                    }
                    *y++ = out;  /* Output from final section */
                } /* Frame */
                /* Move to the state memory for the next channel */
                mem0 += 2 * numSections;
            } /* Channel */
        } else {
            /*
             * Complex inputs, real coefficients - complex output:
             */
            InputPtrsType uptr = ssGetInputPortSignalPtrs(S, INPORT);
            creal_T      *y    = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
            creal_T      *mem0 = (creal_T *)ssGetDWork(S, DISC_STATE);
            int_T i;

            for (i=0; i++ < numChans; ) {
                int_T j;

                for (j=0; j++ < numTimeSteps; ) {
                    creal_T *mem    = mem0;
                    real_T  *c      = mxGetPr(SOS_ARG);
                    creal_T  in     = *((creal_T *)(*uptr++));
                    creal_T out;
                    int_T k;

                    for (k=0; k++ < numSections; ) {
                        out.re = mem->re + in.re * *c;
                        out.im = mem->im + in.im * *c++;

                        mem->re     = (mem+1)->re + in.re * *c - out.re * *(c+2);
                        mem->im     = (mem+1)->im + in.im * *c - out.im * *(c+2);
                        ++mem;

                        mem->re     = in.re * *(c+1) - out.re * *(c+3);
                        (mem++)->im = in.im * *(c+1) - out.im * *(c+3);

                        in = out;
                        c += 4;
                    }
                    *y++ = out;  /* Output from final section */
                } /* Frame */
                /* Move to the state memory for the next channel */
                mem0 += 2 * numSections;
            } /* Channel */
        }

    } else {
        /* Real inputs */

        if (ComplexCoeffs) {
            /*
             * Real input, complex coefficients -> complex output:
             */
            InputRealPtrsType uptr  = ssGetInputPortRealSignalPtrs(S, INPORT);
            creal_T          *y     = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
            creal_T          *mem0  = (creal_T *)ssGetDWork(S, DISC_STATE);
            int_T i;

            for (i=0; i++ < numChans; ) {
                int_T j;

                for (j=0; j++ < numTimeSteps; ) {
                    creal_T *mem    = mem0;
                    real_T *cr      = mxGetPr(SOS_ARG);
		    real_T *ci      = mxGetPi(SOS_ARG);
                    creal_T  in, out;
                    int_T    k;

                    in.re = **uptr++;
                    in.im = (real_T) 0.0;

                    for (k=0; k++ < numSections; ) {
                        out.re = mem->re + in.re * *cr   - in.im * *ci;
                        out.im = mem->im + in.re * *ci++ + in.im * *cr++;

                        mem->re     = (mem+1)->re + (in.re * *cr - in.im * *ci)
                                    - (out.re * *(cr+2) - out.im * *(ci+2));
                        mem->im     = (mem+1)->im + (in.re * *ci + in.im * *cr)
                                    - (out.re * *(ci+2) + out.im * *(cr+2));
                        ++mem;

                        mem->re     = (in.re * *(cr+1) - in.im * *(ci+1))  
                                    - (out.re * *(cr+3) - out.im * *(ci+3));
                        (mem++)->im = (in.re * *(ci+1) + in.im * *(cr+1))
                                    - (out.re * *(ci+3) + out.im * *(cr+3));

                        in = out;
                        cr += 4;
                        ci += 4;
                    }
                    *y++ = out;  /* Output from final section */
                } /* Frame */
                /* Move to the state memory for the next channel */
                mem0 += 2 * numSections;
            } /* Channel */
        } else {
            /*
             * Real input, real coefficients -> real output:
             */

            InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT);
            real_T           *y    = ssGetOutputPortRealSignal(S, OUTPORT);
            real_T           *mem0 = (real_T *)ssGetDWork(S, DISC_STATE);
            int_T i;

            for (i=0; i++ < numChans; ) {
                int_T j;

                for (j=0; j++ < numTimeSteps; ) {
                    real_T  *mem    = mem0;
                    real_T  *c      = mxGetPr(SOS_ARG);
                    real_T  in      = **uptr++;
                    real_T  out;
                    int_T k;

                    for (k=0; k++ < numSections; ) {
                        out = *mem + in * *c++;
                        *mem   = *(mem+1) + in * *c     - out * *(c+2);
                        ++mem;
                        *mem++ =            in * *(c+1) - out * *(c+3);

                        in = out;
                        c += 4;
                    }
                    *y++ = out;  /* Output from final section */
                } /* Frame */
                /* Move to the state memory for the next channel */
                mem0 += 2 * numSections;
            } /* Channel */
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T     numSections     = mxGetN(SOS_ARG);  /* Note: SOS has been transposed, reordered, and scaled */
    const boolean_T ComplexCoeffs   = (boolean_T)mxIsComplex(SOS_ARG);
    const boolean_T ComplexInputs   = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const int_T	    inWidth         = ssGetInputPortWidth(S, INPORT);
    const int_T     chans_arg       = (int_T)(mxGetPr(CHANS_ARG)[0]);
    const boolean_T isFrame         = (boolean_T)(chans_arg != SAMPLE_BASED);
    const int_T	    numChans        = (isFrame) ? chans_arg : inWidth;


    if(!ssSetNumDWork( S, NUM_DWORKS)) return;

    ssSetDWorkWidth(        S, DISC_STATE, 2 * numSections * numChans); /* 2 states per section */
    ssSetDWorkDataType(     S, DISC_STATE, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, DISC_STATE, (ComplexCoeffs || ComplexInputs) ? COMPLEX_YES : COMPLEX_NO);
    ssSetDWorkName(         S, DISC_STATE, "States");
    
}
#endif

#ifdef MATLAB_MEX_FILE

#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    int_T outputPortWidth = ssGetOutputPortWidth(S, OUTPORT);
    
    ssSetInputPortWidth (S, port, inputPortWidth);

    if (outputPortWidth == DYNAMICALLY_SIZED) {
        ssSetOutputPortWidth(S, OUTPORT, inputPortWidth);

    } else if (outputPortWidth != inputPortWidth) {
        ssSetErrorStatus (S, "Input port must have same width as output port.");
        return;
    }
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    int_T inputPortWidth = ssGetInputPortWidth(S, port);
    
    ssSetOutputPortWidth (S, port, outputPortWidth);

    if (inputPortWidth == DYNAMICALLY_SIZED) {
        ssSetInputPortWidth(S, INPORT, outputPortWidth);
    } else if (inputPortWidth != outputPortWidth) {
        ssSetErrorStatus (S, "Output port must have same width as input port.");
        return;
    }
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);

    if (iPortComplexSignal || mxIsComplex(SOS_ARG)) {
        ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_YES);
    } else {
        ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
    }
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx,
                                          CSignal_T      oPortComplexSignal)
{
    boolean_T outputComplex = oPortComplexSignal == COMPLEX_YES;

    ssSetOutputPortComplexSignal(S, portIdx, outputComplex);

    /* Logic:
     * If output is real, input must be real.
     * If output is complex, then:
     *   1) If filter is real, then input must be complex.
     *
     *   2) If filter is complex, input could be EITHER real OR complex.
     *      in which case we cannot set the input complexity at this time.
     */
    if (!outputComplex) {
        ssSetInputPortComplexSignal(S,  INPORT, COMPLEX_NO);
    } else if (!mxIsComplex(SOS_ARG)) {
        ssSetInputPortComplexSignal(S,  INPORT, COMPLEX_YES);
    }
}
#endif

#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    int_T       numIC    = mxGetNumberOfElements(IC_ARG);
    real_T      *ICr     = mxGetPr(IC_ARG);
    real_T      *ICi     = mxGetPi(IC_ARG);
    const int_T nCoeffs  = mxGetNumberOfElements(SOS_ARG);
    real_T      dummy    = 0.0;
    int32_T     numChans = (int32_T)mxGetPr(CHANS_ARG)[0];

    if (numIC == 0) {
        /* SSWRITE_VALUE_*_VECT does not support empty vectors */
        numIC = 1;
        ICr = ICi = &dummy;
    }
     
    if (!ssWriteRTWParamSettings(S, 3,

                                 SSWRITE_VALUE_DTYPE_ML_VECT, "SOS", 
                                 mxGetPr(SOS_ARG), mxGetPi(SOS_ARG),
                                 nCoeffs, 
                                 DTINFO(SS_DOUBLE, mxIsComplex(SOS_ARG)),

                                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC", ICr, ICi,
                                 numIC, DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG)),

                                 SSWRITE_VALUE_DTYPE_NUM,  "NUM_CHANS",   
                                 &numChans,
                                 DTINFO(SS_INT32, 0))) {
        return;
    }
}
#endif


#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] sdspbiquad.c */
