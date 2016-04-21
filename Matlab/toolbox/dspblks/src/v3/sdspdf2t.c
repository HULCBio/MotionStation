/*
 *  SDSPDF2T: Multichannel IIR (Direct Form II Transposed) filter block.
 *
 *  DSP Blockset S-Function for multichannel IIR filtering.
 *  Supports real or complex data and filters for parallel
 *  sample-based filtering or for frame-based filtering.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.22 $  $Date: 2002/04/14 20:41:37 $
 */
#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sdspdf2t

#include "dsp_sim.h"

enum {ARGC_NUM, ARGC_DEN, ARGC_IC, ARGC_CHANS, NUM_ARGS};
#define NUM_ARG     ssGetSFcnParam(S,ARGC_NUM)   /* Numerator Coeffs   */
#define DEN_ARG     ssGetSFcnParam(S,ARGC_DEN)   /* Denominator Coeffs */
#define IC_ARG      ssGetSFcnParam(S,ARGC_IC)    /* Initial Conditions */
#define CHANS_ARG   ssGetSFcnParam(S,ARGC_CHANS) /* Number of Channels */

/* An invalid number of channels is used to flag sample-based operation */
const int_T SAMPLE_BASED = -1;

enum {INPORT, NUM_INPORTS};
enum {OUTPORT, NUM_OUTPORTS};

/* Indices for DWork */
enum {Coeffs=0, DiscState, NUM_DWORKS};

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const int_T      numNumArg    = mxGetNumberOfElements(NUM_ARG);
    const int_T      numDenArg    = mxGetNumberOfElements(DEN_ARG);
    const int_T      numICArg     = mxGetNumberOfElements(IC_ARG);
    const int_T      numChanArg   = mxGetNumberOfElements(CHANS_ARG);
    const boolean_T  runTime      = (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);
    const char      *msg          = NULL;
    int_T            M, N;

    if (runTime || numNumArg >= 1) {
        /* Check size of NUM_ARG and DEN_ARG: */
        M = mxGetM(NUM_ARG);
        N = mxGetN(NUM_ARG);
        if ( ((N != 1) && (M != 1)) || (M == 0) || (N == 0) ) {
            msg = "Numerator must be a non-empty vector";
            goto FCN_EXIT;
        }
    }
    
    if (runTime || numDenArg >= 1) {
        M = mxGetM(DEN_ARG);
        N = mxGetN(DEN_ARG);
        if ( ((M != 1) && (N != 1)) || (M == 0) || (N == 0) ) {
            msg = "Denominator must be a non-empty vector";
            goto FCN_EXIT;
        }
        if (mxIsComplex(DEN_ARG)) {
            if (mxGetPr(DEN_ARG)[0] == 0.0 && mxGetPi(DEN_ARG)[0] == 0.0) {
                msg = "First denominator coefficient must be nonzero";
                goto FCN_EXIT;
            }
        }
        else if (mxGetPr(DEN_ARG)[0] == 0.0) {
            msg = "First denominator coefficient must be nonzero";
            goto FCN_EXIT;
        }
    }

    if (runTime || numChanArg >= 1) {
        if (numChanArg != 1) {
            msg = "The number of channels must be an integer. "
                  "If it is -1, the number of channels equals the port width";
            goto FCN_EXIT;
        }
        else {
            /* Check the VALUE of the "Number of channels" parameter here to be absolutely    */
            /* certain that it has been entered in as an INTEGER and is WITHIN A VALID RANGE. */
            /* The valid range is a positive integer OR equal to "-1" for sample-based.       */
            const real_T nChansDblVal = mxGetPr(CHANS_ARG)[0];

            if ( (nChansDblVal != SAMPLE_BASED) &&
                 ( !(IS_FLINT(CHANS_ARG)) || (nChansDblVal == 0.0) ) ) {
                msg = "The number of channels must be an integer. "
                      "If it is -1, the number of channels equals the port width";
                goto FCN_EXIT;
            }
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

    /* # channels is always non-tunable: */
    ssSetSFcnParamNotTunable(S, ARGC_CHANS);

    /*
     * Make these params non-tunable during code gen until
     * we revisit the generated code/mdlRTW functions:
     */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        ssSetSFcnParamNotTunable(S, ARGC_NUM);
        ssSetSFcnParamNotTunable(S, ARGC_DEN);
        ssSetSFcnParamNotTunable(S, ARGC_IC);
    }

    if (!ssSetNumInputPorts(        S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 0);

    if (!ssSetNumOutputPorts (   S, NUM_OUTPORTS)) return;
    ssSetOutputPortWidth (       S, OUTPORT, DYNAMICALLY_SIZED);
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


#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
    const int_T lenNUM   = mxGetNumberOfElements(NUM_ARG);
    const int_T lenDEN   = mxGetNumberOfElements(DEN_ARG);
    real_T      *numPoly = mxGetPr(NUM_ARG);
    real_T      *denPoly = mxGetPr(DEN_ARG);
    int_T       i;

    /*
     * Copy the filter coefficients into working storage.
     * By doing this it makes it easier to handle the case
     * of having one of the numerator or denominator vectors
     * complex and the other real:
     */
    if (mxIsComplex(NUM_ARG) || mxIsComplex(DEN_ARG)) {
        creal_T *numC = (creal_T *)ssGetDWork(S, Coeffs);
        creal_T *denC = numC + lenNUM;

        if (mxIsComplex(NUM_ARG)) {
            real_T  *numPolyI = mxGetPi(NUM_ARG);
            for (i=0; i < lenNUM; i++) {
                numC->re = *numPoly++;  (numC++)->im = *numPolyI++; 
            }
        } else  {
            for (i=0; i < lenNUM; i++) { 
                numC->re = *numPoly++;  (numC++)->im = (real_T) 0.0; 
            }
        }

        if (mxIsComplex(DEN_ARG)) {
            real_T  *denPolyI = mxGetPi(DEN_ARG);
            for (i=0; i < lenDEN; i++) { 
                denC->re = *denPoly++;  (denC++)->im = *denPolyI++; 
            }
        } else  {
            for (i=0; i < lenDEN; i++) { 
                denC->re = *denPoly++; (denC++)->im = (real_T) 0.0; 
            }
        }

    } else {
        real_T *num = (real_T *) ssGetDWork(S, Coeffs);
        real_T *den = num + lenNUM;
        for (i=0; i < lenNUM; i++) *num++ = *numPoly++;
        for (i=0; i < lenDEN; i++) *den++ = *denPoly++;
    }
}


#ifdef MATLAB_MEX_FILE
#define MDL_START
static void mdlStart (SimStruct *S)
{
    const int_T portWIDTH = ssGetInputPortWidth(S, INPORT);
    int_T       numCHANS  = (int_T) mxGetPr(CHANS_ARG)[0];
    const int_T numIC     = mxGetNumberOfElements(IC_ARG);
    const int_T lenNUM    = mxGetNumberOfElements(NUM_ARG);
    const int_T lenDEN    = mxGetNumberOfElements(DEN_ARG);
    const int_T numDELAYS = MAX(lenNUM, lenDEN); /* One extra state per channel */
    boolean_T   isComplex = (mxIsComplex(NUM_ARG) || mxIsComplex(DEN_ARG) 
                                    || ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    int_T       numELE;

    if (numCHANS == SAMPLE_BASED) numCHANS = portWIDTH;
    numELE = numCHANS * numDELAYS;
    
    if (numCHANS != SAMPLE_BASED && (ssGetInputPortWidth(S, INPORT) % numCHANS)) {
        THROW_ERROR(S, "The port width must be a multiple of the number of channels");
    }
    if (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S,"Input to block must have a discrete sample time");
    }
    if ((numIC != 0) && (numIC != 1)
        && (numIC != numDELAYS-1)
        && (numIC != numELE-numCHANS)) {
        THROW_ERROR(S, "Initial condition vector has incorrect dimensions");
    }
    
    if (mxIsComplex(IC_ARG) && !isComplex) {
        THROW_ERROR(S,"Use real initial conditions when the data "
            "and filter coefficients are both real.\n"
            "If you really want to use complex initial conditions, "
            "make either the data or the coefficients complex");
    }

    /*
     * Cache the filter values into DWork:
     */
    mdlProcessParameters(S);
}
#endif


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    real_T      *pIC        = mxGetPr(IC_ARG);   /* Initial Conditions vector */
    real_T      *pICI       = mxGetPi(IC_ARG);   /* Initial Conditions vector */
    real_T      *DlyBuf     = ssGetDWork(S, DiscState); /* Delay buffer storage      */
    real_T      *numPoly    = mxGetPr(NUM_ARG);
    real_T      *denPoly    = mxGetPr(DEN_ARG);
    const int_T lenNUM      = mxGetNumberOfElements(NUM_ARG);
    const int_T lenDEN      = mxGetNumberOfElements(DEN_ARG);
    const int_T numIC       = mxGetNumberOfElements(IC_ARG);
    int_T       numCHANS    = (int_T) mxGetPr(CHANS_ARG)[0];
    const int_T portWIDTH   = ssGetInputPortWidth(S, INPORT);
    const int_T numDELAYS   = MAX(lenNUM, lenDEN); /* One extra state per channel */
    boolean_T   isComplex   = (mxIsComplex(NUM_ARG) || mxIsComplex(DEN_ARG) 
                                || ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    int_T       i, j;
    
    if (numCHANS == SAMPLE_BASED) numCHANS = portWIDTH;

    /*
     * Initialize the state buffers with initial conditions.
     * There is one extra memory element for each channel that is set
     * to zero.  It simplifies the filtering algorithm.
     */
    if (numIC <= 1) {
        /* Scalar expansion, or no IC_ARG's given: */
        real_T ic = (numIC == 0) ? (real_T)0.0 : *pIC;
        if (!isComplex) {
            for (i=0; i < numCHANS; i++) {
                for (j=0; j < numDELAYS-1; j++) *DlyBuf++ = ic;
                *DlyBuf++ = (real_T)0.0;  /* Extra state is zero */
            }
        }
        else {
            real_T ici = (pICI != NULL) ? *pICI : (real_T) 0.0;
            for (i=0; i < numCHANS; i++) {
                for (j=0; j < numDELAYS-1; j++) { *DlyBuf++ = ic; *DlyBuf++ = ici; }
                *DlyBuf++ = (real_T)0.0;  *DlyBuf++ = (real_T)0.0;
            }
        }
    }
    else if (numIC == numDELAYS-1) {
        /* Same IC's for all channels: */
        if (!isComplex) {
            for (i=0; i < numCHANS; i++) {
                for (j=0; j < numDELAYS-1; j++) *DlyBuf++ = pIC[j];
                *DlyBuf++ = (real_T)0.0;  /* Extra state is zero */
            }
        }
        else {
            for (i=0; i < numCHANS; i++) {
                if (pICI != NULL) for (j=0; j < numDELAYS-1; j++) { 
                    *DlyBuf++ = pIC[j]; *DlyBuf++ = pICI[j]; 
                }
                else for (j=0; j < numDELAYS-1; j++) { 
                    *DlyBuf++ = pIC[j]; *DlyBuf++ = (real_T)0.0; 
                }
                *DlyBuf++ = (real_T)0.0;  *DlyBuf++ = (real_T)0.0;
            }
        }
    }
    else {
       /*
        * Matrix of IC's:
        * Assume numDELAYS rows and numCHANS columns
        */
        if (!isComplex) {
            for (i=0; i < numCHANS; i++) {
                for (j=0; j < numDELAYS-1; j++) *DlyBuf++ = *pIC++;
                *DlyBuf++ = (real_T)0.0;  /* Last state is zero */
            }
        }
        else {
            for (i=0; i < numCHANS; i++) {
                if (pICI != NULL) for (j=0; j < numDELAYS-1; j++) { 
                    *DlyBuf++ = *pIC++; *DlyBuf++ = *pICI++; 
                }
                else for (j=0; j < numDELAYS-1; j++) { 
                    *DlyBuf++ = *pIC++; *DlyBuf++ = (real_T)0.0; 
                }
                *DlyBuf++ = (real_T)0.0;  *DlyBuf++ = (real_T)0.0;
            }
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
/*
* Algorithm: Direct Form-II Transposed
*
*   y  = x*b0        + D0   (output)       b# = numerator polynomial,
*   D0 = x*b1 - y*a1 + D1   (delay         a# = denominator polynomial,
*   D1 = x*b2 - y*a2 + D2    updates)      D# = delay buffers
*   ...                                    y  = output value
*   DN = x*bN - y*aN                       x  = input value
*
* Implementation:
*   *y++  = x * *b++             + *DR++;
*   *DL++ = x * *b++ - y * *a+++ + *DR++;
*   *DL++ = x * *b++ - y * *a+++ + *DR++;
*   ...
*   *DL++ = x * *b   - y * *a;
*
* Buffer storage:
*   ----------------------------------------------
*   |    Channel 0     |     Channel 1      |  ...
*   |D0 | D1 | D2 |... | D0 | D1 | D2 | ... |  ...
*   ----------------------------------------------
    */
    int_T       ordNUM      = mxGetNumberOfElements(NUM_ARG) - 1;
    int_T       ordDEN      = mxGetNumberOfElements(DEN_ARG) - 1;
    const int_T numDELAYS   = MAX(ordNUM, ordDEN) + 1; /* One extra "state" element */
    int_T       lenMIN      = MIN(ordNUM, ordDEN);
    const int_T portWIDTH   = ssGetInputPortWidth(S, INPORT);
    int_T       numCHANS    = (int_T) mxGetPr(CHANS_ARG)[0];
    int_T j, i, k, frame;
    
    if (numCHANS == SAMPLE_BASED) {
        numCHANS = portWIDTH;
        frame = 1;
    } else {
        frame = portWIDTH / numCHANS;
    }
    
    if (ssGetInputPortComplexSignal(S,0) == COMPLEX_YES) { /* COMPLEX DATA */
        InputPtrsType   uptr        = ssGetInputPortSignalPtrs(S, INPORT);
        creal_T         *mem_base   = (creal_T *) ssGetDWork(S, DiscState); /* Start of state memory buffer */
        creal_T         *y          = (creal_T *) ssGetOutputPortSignal(S, OUTPORT);
        
        if (mxIsComplex (NUM_ARG) || mxIsComplex (DEN_ARG)) { /* Complex data, complex filter */
            /* Loop over each input channel: */
            for (k=0; k < numCHANS; k++) {
                for (i=0; i < frame; i++) {
                    creal_T *num        = (creal_T *) ssGetDWork(S, Coeffs);
                    creal_T *den        = num + ordNUM + 2; /* Start at a(2) */
                    creal_T *u          = (creal_T *) *uptr++;  /* Get next channel input sample */
                    creal_T *filt_mem   = mem_base + k * numDELAYS;
                    creal_T *next_mem   = filt_mem + 1;
                    creal_T out;	
                    
                    /* Compute the output value */
                    y->re     = out.re = CMULT_RE(*u, *num) + filt_mem->re;
                    (y++)->im = out.im = CMULT_IM(*u, *num) + filt_mem->im;
                    ++num;
                    
                    /* Update states having both numerator and denominator coeffs */
                    for (j=0; j < lenMIN; j++) {
                        filt_mem->re     = next_mem->re     + CMULT_RE(*u, *num) - CMULT_RE(out, *den);
                        (filt_mem++)->im = (next_mem++)->im + CMULT_IM(*u, *num) - CMULT_IM(out, *den);
                        ++num;  ++den;
                    }
                    /* Update the rest of the states. At most one of these two statements
                    * will execute
                    */
                    for (   ; j < ordNUM; j++) {
                        filt_mem->re     = next_mem->re     + CMULT_RE(*u, *num);
                        (filt_mem++)->im = (next_mem++)->im + CMULT_IM(*u, *num);
                        ++num;
                    }
                    for (   ; j < ordDEN; j++) {
                        filt_mem->re     = next_mem->re     - CMULT_RE(out, *den);
                        (filt_mem++)->im = (next_mem++)->im - CMULT_IM(out, *den);
                        ++den;
                    }
                } /* frame loop */
            } /* channel loop */
            
        }
        else {   /* Complex data, real filter */
            /* Loop over each input channel: */
            for (k=0; k < numCHANS; k++) {
                for (i=0; i < frame; i++) {
                    real_T  *num        = ssGetDWork(S, Coeffs);
                    real_T  *den        = num + ordNUM + 2;
                    creal_T *u          = (creal_T *) *uptr++;  /* Get next channel input sample */
                    creal_T *filt_mem   = mem_base + k * numDELAYS;
                    creal_T *next_mem   = filt_mem + 1;
                    creal_T out;	
                    
                    /* Compute the output value */
                    y->re     = out.re = u->re * *num    + filt_mem->re;
                    (y++)->im = out.im = u->im * *num++  + filt_mem->im;
                    
                    /* Update states having both numerator and denominator coeffs */
                    for (j=0; j < lenMIN; j++) {
                        filt_mem->re     = next_mem->re     + u->re * *num   - out.re * *den;
                        (filt_mem++)->im = (next_mem++)->im + u->im * *num++ - out.im * *den++;
                    }
                    /* Update the rest of the states. At most one of these two statements
                    * will execute
                    */
                    for (   ; j < ordNUM; j++) {
                        filt_mem->re     = next_mem->re     + u->re  * *num;
                        (filt_mem++)->im = (next_mem++)->im + u->im  * *num++;
                    }
                    for (   ; j < ordDEN; j++) {
                        filt_mem->re     = next_mem->re     - out.re * *den;
                        (filt_mem++)->im = (next_mem++)->im - out.im * *den++;
                    }
                } /* frame loop */
            } /* channel loop */
        }
    }
    else {  /* REAL DATA */
        InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT);
        
        if (mxIsComplex (NUM_ARG) || mxIsComplex (DEN_ARG)) { /* Real data, complex filter */
            creal_T *mem_base   = (creal_T *) ssGetDWork(S, DiscState); /* Start of state memory buffer */
            creal_T *y          = (creal_T *) ssGetOutputPortSignal(S, OUTPORT);
            
            /* Loop over each input channel: */
            for (k=0; k < numCHANS; k++) {
                for (i=0; i < frame; i++) {
                    creal_T *num        = (creal_T *) ssGetDWork(S, Coeffs);
                    creal_T *den        = num + ordNUM + 2;
                    creal_T *filt_mem   = mem_base + k * numDELAYS;
                    creal_T *next_mem   = filt_mem + 1;
                    real_T  in          = **uptr++;  /* Get next channel input sample */
                    creal_T out;
                    
                    /* Compute the output value */
                    y->re     = out.re = in * num->re     + filt_mem->re;
                    (y++)->im = out.im = in * (num++)->im + filt_mem->im;
                    
                    /* Update states having both numerator and denominator coeffs */
                    for (j=0; j < lenMIN; j++) {
                        filt_mem->re     = next_mem->re     + in * num->re     - CMULT_RE(out, *den);
                        (filt_mem++)->im = (next_mem++)->im + in * (num++)->im - CMULT_IM(out, *den);
                        ++den;
                    }
                    /* Update the rest of the states. At most one of these two statements
                    * will execute
                    */
                    for (   ; j < ordNUM; j++) {
                        filt_mem->re     = next_mem->re     + in  * num->re;
                        (filt_mem++)->im = (next_mem++)->im + in  * (num++)->im;
                    }
                    for (   ; j < ordDEN; j++) {
                        filt_mem->re     = next_mem->re     - CMULT_RE(out, *den);
                        (filt_mem++)->im = (next_mem++)->im - CMULT_IM(out, *den);
                        ++den;
                    }
                } /* frame loop */
            } /* channel loop */
        }
        else { /* Real data, real filter */
            real_T  *mem_base   = ssGetDWork(S, DiscState); /* Start of state memory buffer */
            real_T  *y          = ssGetOutputPortRealSignal(S, OUTPORT);
            
            /* Loop over each input channel: */
            for (k=0; k < numCHANS; k++) {
                for (i=0; i++ < frame;    ) {
                    real_T  *num        = ssGetDWork(S, Coeffs);
                    real_T  *den        = num + ordNUM + 2;  /* Start at a(2) */
                    real_T  in          = **uptr++;  /* Get next channel input sample */
                    real_T  *filt_mem   = mem_base + k * numDELAYS;
                    real_T  *next_mem   = filt_mem + 1;
                    real_T  out;	
                    
                    /* Compute the output value */
                    *y++ = out = in * *num++ + *filt_mem;
                    
                    /* Update states having both numerator and denominator coeffs */
                    for (j=0; j < lenMIN; j++) *filt_mem++ = *next_mem++ + in * *num++ - out * *den++;
                    /* Update the rest of the states. At most one of these two statements
                    * will execute
                    */
                    for ( ; j < ordNUM; j++) *filt_mem++ = *next_mem++ + in  * *num++;
                    for ( ; j < ordDEN; j++) *filt_mem++ = *next_mem++ - out * *den++;
                } /* frame loop */
            } /* channel loop */
        }
    }
    /* Note:  If you modify this code, make sure that the last state memory
    * value for each channel is always zero.  This extra zero-valued state
    * greatly simplifies the algorithm.
    */
}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
   /* Allocate delay buffer.
    *
    * The delay buffer has numCHANS "segments", each with numDELAYS
    * indices for each filter channel, for storing the delay values
    * for each IIR filter.
    */
    const int_T	lenNUM		= mxGetNumberOfElements(NUM_ARG);
    const int_T	lenDEN		= mxGetNumberOfElements(DEN_ARG);
    const int_T	portWIDTH	= ssGetInputPortWidth(S, INPORT);
    const int_T	numDELAYS	= MAX(lenNUM, lenDEN); /* One extra state per channel */
    const boolean_T isFiltCplx  = mxIsComplex(NUM_ARG) || mxIsComplex(DEN_ARG);
    int_T	numCHANS	= (int_T) mxGetPr(CHANS_ARG)[0]; 
    int_T	numCOEFFS	= lenNUM + lenDEN;
    int_T	numELE;
    
    if (numCHANS == SAMPLE_BASED) numCHANS = portWIDTH;
    numELE = numCHANS * numDELAYS;
    
    ssSetNumDWork(          S, NUM_DWORKS);

    ssSetDWorkWidth(        S, Coeffs, numCOEFFS);
    ssSetDWorkDataType(     S, Coeffs, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, Coeffs, (isFiltCplx) ? COMPLEX_YES : COMPLEX_NO);

    ssSetDWorkWidth(S, DiscState, numELE);
    if (isFiltCplx || (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES)) {
        ssSetDWorkComplexSignal(S, DiscState, COMPLEX_YES);
    }
}
#endif


#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    int_T outputPortWidth = ssGetOutputPortWidth(S, port);
    
    ssSetInputPortWidth (S, port, inputPortWidth);
    if (outputPortWidth == -1) {
        ssSetOutputPortWidth(S, port, inputPortWidth);
    } else if (outputPortWidth != inputPortWidth) {
        ssSetErrorStatus (S, "Input/Output port pairs must have the same width");
        return;
    }
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    int_T inputPortWidth = ssGetInputPortWidth(S, port);
    
    ssSetOutputPortWidth (S, port, outputPortWidth);
    if (inputPortWidth == -1) {
        ssSetInputPortWidth(S, port, outputPortWidth);
    } else if (inputPortWidth != outputPortWidth) {
        ssSetErrorStatus (S, "Input/Output port pairs must have the same width");
        return;
    }
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);
    if (mxIsComplex(NUM_ARG) || mxIsComplex(DEN_ARG)) {
        ssSetOutputPortComplexSignal(S, portIdx, COMPLEX_YES);
    } else {
        ssSetOutputPortComplexSignal(S, portIdx, iPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);
    }
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx,
                                          CSignal_T      oPortComplexSignal)
{
    ssSetOutputPortComplexSignal(S, portIdx, oPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);
    
    if (!oPortComplexSignal) {
        ssSetInputPortComplexSignal(S, portIdx, COMPLEX_NO);
    } else if (!(mxIsComplex(NUM_ARG) || mxIsComplex(DEN_ARG))) {
        ssSetInputPortComplexSignal(S, portIdx, COMPLEX_YES);
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
    const int_T lenNUM   = mxGetNumberOfElements(NUM_ARG);
    const int_T lenDEN   = mxGetNumberOfElements(DEN_ARG);
    real_T      dummy    = 0.0;
    int32_T     numChans = (int32_T)mxGetPr(CHANS_ARG)[0];

    if (numIC == 0) {
        /* SSWRITE_VALUE_*_VECT does not support empty vectors */
        numIC = 1;
        ICr = ICi = &dummy;
    }
     
    if (!ssWriteRTWParamSettings(S, 4,

        SSWRITE_VALUE_DTYPE_ML_VECT, "NUM", 
        mxGetPr(NUM_ARG), mxGetPi(NUM_ARG),
        lenNUM, DTINFO(SS_DOUBLE, mxIsComplex(NUM_ARG)),

        SSWRITE_VALUE_DTYPE_ML_VECT, "DEN", 
        mxGetPr(DEN_ARG), mxGetPi(DEN_ARG),
        lenDEN, DTINFO(SS_DOUBLE, mxIsComplex(DEN_ARG)),

        SSWRITE_VALUE_DTYPE_ML_VECT, "IC", ICr, ICi,
        numIC, DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG)),

        SSWRITE_VALUE_DTYPE_NUM,  "NUM_CHANS",   
        &numChans, DTINFO(SS_INT32, 0))) {

        return;
    }
}
#endif


#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] sdspdf2t.c */
