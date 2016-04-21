/*
 * SCOMTIMRECLIN - Implements 3 Symbol Timing phase estimation algorithms
 * for linear baseband modulations.
 *
 * Operates for both Sample and Frame-based input signals.
 *
 * Assumptions made:
 * o The input signal is oversampled by an integer number of samples per 
 *   symbol (SAMP_PER_SYMB_ARG).
 * o PROP_GAIN_ARG is the error update parameter between sucessive symbols
 *   (proportional gain).
 *
 * o Outputs of the block are:
 *   Port1: the signal values at the estimated symbol sampling instants. 
 *          
 *   Port2: the estimated timing phase as a real number in terms of samples
 *          per symbol (nonnegative real number less than SAMP_PER_SYMB_ARG).
 * 
 *  References:
 *   [1] B. Sklar, "Digital Communications", Prentice Hall, NJ, 1988. 
 *   [2] Mengali and D'Andrea, "Synchronization Techniques in Digital 
 *         Receivers", Plenum Press, NY, 1997. 
 *   [3] F. M. Gardner, "A BPSK/QPSK Timing-Error detector for Sampled 
 *         Receivers", IEEE Trans. Comm, May 1986, pp. 423-9. 
 *   [4] Mueller and Muller, "Timing Recovery in Digital Synchronous Data
 *         Receivers", IEEE Trans. Comm., May 1976, pp. 516-31.
 *          
 *   Copyright 1996-2003 The MathWorks, Inc.
 *   $Revision: 1.1.6.3 $  $Date: 2003/12/01 19:00:22 $
 */


#define S_FUNCTION_NAME scomtimreclin
#define S_FUNCTION_LEVEL 2

#include "timrec_hs.h"

/* D-work vectors */
enum {TAU_IDX = 0, INBUFF_IDX, NUM_DWORKS};

/* TED algorithm option */
enum {GARDNER = 1, ELGATE, MMULLER};

/* List the TED sfunction mask input */
#define TED_ARGC             3
#define TED_ARG(S)           (ssGetSFcnParam(S, TED_ARGC))
#define TED_METHOD(S)        ((int_T)(mxGetPr(TED_ARG(S))[0]))


/* Function: mdlCheckParameters ============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    /* Samples per symbol parameter - integer scalar > 1 */
    if (OK_TO_CHECK_VAR(S, SAMP_PER_SYMB_ARG(S))) 
    {
        if ( !(IS_FLINT_GE(SAMP_PER_SYMB_ARG(S),2)) ) 
           THROW_ERROR(S, COMM_EMSG_SAMPSYMB_PARAM);
    }

    /* Proportional Gain parameter - real scalar > 0 */
    if (OK_TO_CHECK_VAR(S, PROP_GAIN_ARG(S))) 
    {
        if ( !mxIsDouble(PROP_GAIN_ARG(S)) || mxIsComplex(PROP_GAIN_ARG(S)) || 
             (mxGetNumberOfElements(PROP_GAIN_ARG(S)) != 1) ||
             (mxGetPr(PROP_GAIN_ARG(S))[0] <= 0) )
        {
            THROW_ERROR(S, COMM_EMSG_PROPGAIN_PARAM);
        }
    }
}
#endif


/* Function: mdlInitializeSizes ============================================*/
static void mdlInitializeSizes(SimStruct *S)
{
    int_T numInports;

    ssSetNumSFcnParams(S, 4);

#ifdef MATLAB_MEX_FILE
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    /* Inputs */
    numInports = (HAS_RST_PORT(S)) ? 2 : 1;
    if (!ssSetNumInputPorts(S, numInports)) return;
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_YES);
    ssSetInputPortSampleTime(        S, INPORT, INHERITED_SAMPLE_TIME);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortRequiredContiguous(S, INPORT, 1);
    ssSetInputPortReusable(          S, INPORT, 1);
    
    if (HAS_RST_PORT(S))
    {
        if (!ssSetInputPortDimensionInfo(S, RSTPORT, DYNAMIC_DIMENSION))return;
        ssSetInputPortFrameData(         S, RSTPORT, FRAME_INHERITED);
        ssSetInputPortComplexSignal(     S, RSTPORT, COMPLEX_NO);
        ssSetInputPortSampleTime(        S, RSTPORT, INHERITED_SAMPLE_TIME);
        ssSetInputPortDirectFeedThrough( S, RSTPORT, 1);
        ssSetInputPortRequiredContiguous(S, RSTPORT, 1);
        ssSetInputPortReusable(          S, RSTPORT, 1);
    }

    /* Output: */
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT1, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT1, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(     S, OUTPORT1, COMPLEX_YES);
    ssSetOutputPortSampleTime(        S, OUTPORT1, INHERITED_SAMPLE_TIME);
    ssSetOutputPortReusable(          S, OUTPORT1, 1);

    if (!ssSetOutputPortDimensionInfo(S, OUTPORT2, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT2, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(     S, OUTPORT2, COMPLEX_NO);
    ssSetOutputPortSampleTime(        S, OUTPORT2, INHERITED_SAMPLE_TIME);
    ssSetOutputPortReusable(          S, OUTPORT2, 1);
    
    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                    SS_OPTION_REQ_INPUT_SAMPLE_TIME_MATCH);

    /* Parameter Tunability */
    ssSetSFcnParamTunable(S, SAMP_PER_SYMB_ARGC, 0); 
    ssSetSFcnParamTunable(S, PROP_GAIN_ARGC, 1);  /* Is tunable */
    ssSetSFcnParamTunable(S, RESET_ARGC, 0); 
    ssSetSFcnParamTunable(S, TED_ARGC, 0); 
}


/* Function: mdlInitializeSampleTimes =====================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    /* Checks for correct propagation of sample times */
    const real_T Tsi = ssGetInputPortSampleTime(S, INPORT);
    const real_T Tso1 = ssGetOutputPortSampleTime(S, OUTPORT1);
    const real_T Tso2 = ssGetOutputPortSampleTime(S, OUTPORT2);
    
    if (HAS_RST_PORT(S))
    {
        const int_T     N            = (int_T)mxGetPr(SAMP_PER_SYMB_ARG(S))[0];
        const boolean_T isFrameBased = (boolean_T)
                         (ssGetInputPortFrameData(S, INPORT) == FRAME_YES);
        const real_T TsRst = ssGetInputPortSampleTime(S, RSTPORT);
            
        if ( (TsRst != Tso1) || (TsRst != Tso2) )
            THROW_ERROR(S, COMM_EMSG_RST_TS_OUT);

        if (isFrameBased)  {
            if (TsRst != Tsi) THROW_ERROR(S, COMM_EMSG_RST_TS_IN);
        } else {  /* Sample-based */
            if (TsRst != N*Tsi) THROW_ERROR(S, COMM_EMSG_RST_TS_SYMB);
        }
    }
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);

#endif
} /* End mdlInitializeSampleTimes */


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
          int_T numSymb, buffLenSymb, buffLen;
    const int_T N            = (int_T)mxGetPr(SAMP_PER_SYMB_ARG(S))[0];
    const int_T inPortWidth  = ssGetInputPortWidth(S, INPORT);

    const boolean_T isFrameBased = (boolean_T)
                         (ssGetInputPortFrameData(S, INPORT) == FRAME_YES);

    if (isFrameBased)
        numSymb = (inPortWidth/N);
    else 
        numSymb = 1;              /* single symbol */

    buffLenSymb = numSymb+2;      /* +2 symbol overlap */
    buffLen     = buffLenSymb * N;    
              
    /* Set DWork vectos */
    if (!ssSetNumDWork(S, NUM_DWORKS)) return;

    /* Phase update vector */
    ssSetDWorkName(         S, TAU_IDX, "Phase");
    ssSetDWorkWidth(        S, TAU_IDX, buffLenSymb);
    ssSetDWorkDataType(     S, TAU_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TAU_IDX, COMPLEX_NO);
    ssSetDWorkUsedAsDState( S, TAU_IDX, 1);

    /* Input Signal buffer */
    ssSetDWorkName(         S, INBUFF_IDX, "Input");
    ssSetDWorkWidth(        S, INBUFF_IDX, buffLen);
    ssSetDWorkDataType(     S, INBUFF_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, INBUFF_IDX, COMPLEX_YES);
    ssSetDWorkUsedAsDState( S, INBUFF_IDX, 1);
}
#endif


/* Function: mdlStart =====================================================*/
#define MDL_START
static void mdlStart (SimStruct *S)
{
    UNUSED_ARG(S);
}


/* Function: mdlInitializeConditions ======================================*/
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    int_T    k;

    real_T  *tau          = (real_T *)ssGetDWork(S, TAU_IDX);
    int_T    buffLenSymb  = ssGetDWorkWidth(S, TAU_IDX);

    creal_T *in           = (creal_T *)ssGetDWork(S, INBUFF_IDX);
    int_T    buffLen      = ssGetDWorkWidth(S, INBUFF_IDX);
            
    /* Initialize to all zeros */    
    for(k = 0; k < buffLenSymb; k++) 
        tau[k] = 0.0;

    for(k = 0; k < buffLen; k++) {
        in[k].re = 0.0;
        in[k].im = 0.0;
    }
} /* End mdlInitializeConditions */


/* Function: linInterpRe() linearly interpolates to get the signal value
 *           (real part only) at the fractional instant (as per "fltIdx") 
 *           after "dn" samples in the input complex buffer given by "in". 
 *           Note: The input is assumed to be stored in reverse order. */
static real_T linInterpRe(creal_T *in, int_T dn, real_T fltIdx)
{   
    return (in[dn].re + (fltIdx - floor(fltIdx)) * (in[dn-1].re - in[dn].re));
}


/* Function: linInterpIm() linearly interpolates to get the signal value
 *           (imag part only) at the fractional instant (as per "fltIdx") 
 *           after "dn" samples in the input complex buffer given by "in". 
 *           Note: The input is assumed to be stored in reverse order. */
static real_T linInterpIm(creal_T *in, int_T dn, real_T fltIdx)
{   
    return (in[dn].im + (fltIdx - floor(fltIdx)) * (in[dn-1].im - in[dn].im));
}


/* Function: GardnerPLL() implements the Phase Locked Loop (or the TED)
 *           using the GARDNER timing error detector, [3, 4].  */
static void GardnerPLL(int_T numSymb, int_T N, int_T buffLen,
                       real_T g, real_T *tau, creal_T *in)
{
    int_T    k, idx1_dn, idx2_dn, idx3_dn; 
    real_T   eK, fltIdx1, fltIdx2, fltIdx3;
    real_T   a1, a2, a1_re, a2_re, a3_re, a1_im, a2_im, a3_im;

    real_T T  = 1.0; /* Normalized symbol period */
    real_T Ts = T/2; /* Half a symbol period */

    /* Start algorithm loop for eK and tau */
    for (k = 0; k < numSymb; k++) 
    {            
        /* Sampling instants for tau calculation */
        fltIdx1 = N*(   (k)*T      + tau[k]);
        fltIdx2 = N*( (k+1)*T      + tau[k+1]); 
        fltIdx3 = N*( (k+1)*T - Ts + tau[k]);

        /* Select the second symbol as the current symbol so as to have 
         * a buffer of a symbol on both sides [-T..T..+T] */
        idx1_dn = (buffLen-N-1) - ( (int_T)floor(fltIdx1) ); 
        idx2_dn = (buffLen-N-1) - ( (int_T)floor(fltIdx2) ); 
        idx3_dn = (buffLen-N-1) - ( (int_T)floor(fltIdx3) );
        
        /* Signal values at sampling instants */
        /*  -linearly interpolate between 2 available points */
        a1_re = linInterpRe(in, idx1_dn, fltIdx1);
        a1_im = linInterpIm(in, idx1_dn, fltIdx1);

        a2_re = linInterpRe(in, idx2_dn, fltIdx2);
        a2_im = linInterpIm(in, idx2_dn, fltIdx2);

        a3_re = linInterpRe(in, idx3_dn, fltIdx3);
        a3_im = linInterpIm(in, idx3_dn, fltIdx3);

        /* Timing error calculation */
        a1 = (a1_re - a2_re) * a3_re;
        a2 = (a1_im - a2_im) * a3_im;
        
        eK = a1 + a2;       /* error */
        tau[k+2] = tau[k+1] + g * eK; /* Apply current estimate to next */
                    
        /* Wrap tau to be within [-T/2, +T/2] range */
        if (fabs(tau[k+2]) > T/2)
        {
            tau[k+2] = fmod(tau[k+2] + T/2, T); /* [-T, T], due to fmod */
            if (tau[k+2] < 0.0) tau[k+2] += T;  /* [0, T] */
            tau[k+2] -= T/2;                    /* [-T/2, T/2] */
        }
    } /* end for loop */

} /* end GardnerPLL() */


/* Function: ELGatePLL() implements the Phase Locked Loop (or the TED)
 *           using the early-late gate method.  */
static void ELGatePLL(int_T numSymb, int_T N, int_T buffLen,
                       real_T g, real_T *tau, creal_T *in)
{
    int_T    k, idx1_dn, idx2_dn, idx3_dn; 
    real_T   eK, fltIdx1, fltIdx2, fltIdx3;
    real_T   a1, a2, a1_re, a2_re, a3_re, a1_im, a2_im, a3_im;

    real_T T  = 1.0;    /* Normalized symbol period */
    real_T Ts = T/2;    /* Half a symbol period */

    /* Start algorithm loop for eK and tau */
    for (k = 0; k < numSymb; k++) 
    {    
        /* Sampling instants for tau calculation */
        fltIdx1 = N*( (k+1)*T      + tau[k+1]);
        fltIdx2 = N*( (k+1)*T + Ts + tau[k+1]);
        fltIdx3 = N*( (k+1)*T - Ts + tau[k]);
        
        /* Select the second symbol as the current symbol so as to have 
         * a buffer of a symbol on both sides [-T..T..+T] */
        idx1_dn = (buffLen-N-1) - ( (int_T)floor(fltIdx1) ); 
        idx2_dn = (buffLen-N-1) - ( (int_T)floor(fltIdx2) ); 
        idx3_dn = (buffLen-N-1) - ( (int_T)floor(fltIdx3) );
        
        /* Signal values at sampling instants */
        /* linearly interpolate between 2 available points */
        a1_re = linInterpRe(in, idx1_dn, fltIdx1);
        a1_im = linInterpIm(in, idx1_dn, fltIdx1);

        a2_re = linInterpRe(in, idx2_dn, fltIdx2);
        a2_im = linInterpIm(in, idx2_dn, fltIdx2);

        a3_re = linInterpRe(in, idx3_dn, fltIdx3);
        a3_im = linInterpIm(in, idx3_dn, fltIdx3);

        /* Timing error calculation */
        a1 = a1_re * (a2_re - a3_re);
        a2 = a1_im * (a2_im - a3_im);
        
        eK = a1 + a2;       /* error */
        tau[k+2] = tau[k+1] + g * eK; /* Apply current estimate to next */

        /* Wrap tau to be within [-T/2, +T/2] range */
        if (fabs(tau[k+2]) > T/2)
        {
            tau[k+2] = fmod(tau[k+2] + T/2, T); /* [-T, T], due to fmod */
            if (tau[k+2] < 0.0) tau[k+2] += 1;  /* [0, T] */
            tau[k+2] -= T/2;                    /* [-T/2, T/2] */
        }
    } /* end for loop */

} /* end ELGatePLL() */


/* Function: signNum() returns the sign of a real number */
static real_T signNum(real_T x)
{
    return ((x < 0.0) ? -1 : 1);
}


/* Function: MMullerPLL() implements the Phase Locked Loop (or the TED)
 *           using the Mueller-Muller method.  */
static void MMullerPLL(int_T numSymb, int_T N, int_T buffLen,
                       real_T g, real_T *tau, creal_T *in)
{
    int_T    k, idx1_dn, idx2_dn; 
    real_T   eK, a1, a2, fltIdx1, fltIdx2, a1_re, a2_re, a1_im, a2_im;

    real_T T  = 1.0; /* Normalized symbol period */

    /* Start algorithm loop for eK and tau */
    for (k = 0; k < numSymb; k++) 
    {            
        /* Sampling instants for tau calculation */
        fltIdx1 = N*( (k+1)*T + tau[k+1]);
        fltIdx2 = N*(   (k)*T + tau[k]); 

        /* Select the second symbol as the current symbol so as to have 
         * a buffer of a symbol on both sides [-T..T..+T] */
        idx1_dn = (buffLen-N-1) - ( (int_T)floor(fltIdx1) ); 
        idx2_dn = (buffLen-N-1) - ( (int_T)floor(fltIdx2) ); 
        
        /* Signal values at sampling instants */
        /* linearly interpolate between 2 available points */
        a1_re = linInterpRe(in, idx1_dn, fltIdx1);
        a1_im = linInterpIm(in, idx1_dn, fltIdx1);

        a2_re = linInterpRe(in, idx2_dn, fltIdx2);
        a2_im = linInterpIm(in, idx2_dn, fltIdx2);

        /* Timing error calculation */
        a1 = signNum(a2_re) * a1_re + signNum(a2_im) * a1_im;
        a2 = signNum(a1_re) * a2_re + signNum(a1_im) * a2_im;

        eK = a1 - a2;       /* error */
        tau[k+1 +1] = tau[k+1] + g * eK; /* phase update for current symbol*/

        /* Wrap tau to be within [-T/2, +T/2] range */
        if (fabs(tau[k+2]) > T/2)
        {
            tau[k+2] = fmod(tau[k+2] + T/2, T); /* [-T, T], due to fmod */
            if (tau[k+2] < 0.0) tau[k+2] += 1;  /* [0, T] */
            tau[k+2] -= T/2;                    /* [-T/2, T/2] */
        }
    } /* end for loop */

} /* end MMullerPLL() */


/* Function: evalOutputs() computes and assigns the 2 output values for
 *           the signal and the phase estimate. */
static void evalOutputs(int_T numSymb, int_T N, int_T buffLen, 
                        real_T *tau, creal_T *in, creal_T *y1, real_T *y2)
{                           
    int_T  k, dn, up;
    real_T tauInt, phEst;
    
    for (k = 0; k < numSymb; k++) 
    {
        /* Convert [-1/2 1/2] to [0 1] interval */
        tauInt = (tau[k] < 0.0) ?  (tau[k] + 1.0) : tau[k];

        /* Output symbol phase estimate */
        phEst = tauInt * N; 
        y2[k] = phEst; 

        dn = (buffLen - k*N - 1) - ((int_T) floor(phEst));
        up = dn - 1; /* Due to reverse-storing of the input in buffer */

        /* Output signal symbol value at phEst instant */
        /*  - linearly interpolate between 2 available points */
        y1[k].re = in[dn].re + (phEst - floor(phEst))*(in[up].re - in[dn].re);
        y1[k].im = in[dn].im + (phEst - floor(phEst))*(in[up].im - in[dn].im);

    } /* end for loop */

} /* End evalOutputs() */


/* Function: mdlOutputs ===================================================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
          int_T k, numSymb;

    const int_T inPortTid   = ssGetInputPortSampleTimeIndex(S,INPORT);
    const int_T outPort1Tid = ssGetOutputPortSampleTimeIndex(S,OUTPORT1);

    const int_T     inPortWidth  = ssGetInputPortWidth(S, INPORT);
    const boolean_T isSampBased = (boolean_T)
                    (ssGetInputPortFrameData(S, INPORT) == FRAME_NO);

    const int_T   N      = (int_T)mxGetPr(SAMP_PER_SYMB_ARG(S))[0];
          real_T  g      = (real_T)mxGetPr(PROP_GAIN_ARG(S))[0];

    real_T  *tau         = (real_T *)ssGetDWork(S, TAU_IDX);

    creal_T *in          = (creal_T *)ssGetDWork(S, INBUFF_IDX);
    int_T   buffLen      = ssGetDWorkWidth(S, INBUFF_IDX);

    creal_T *u    = (creal_T *) ssGetInputPortSignal(S, INPORT);
    creal_T *y1   = (creal_T *) ssGetOutputPortSignal(S, OUTPORT1);
    real_T  *y2   = (real_T *)  ssGetOutputPortSignal(S, OUTPORT2);

    if (isSampBased)  /* Sample-based */
    {
        numSymb = 1; /* single symbol */

        /* Check resetting options */
        if (HAS_RST_PORT(S)) 
        {
            const int_T rstPortTid = ssGetInputPortSampleTimeIndex(S,RSTPORT);
                  real_T *rst  = (real_T *)ssGetInputPortSignal(S, RSTPORT);

            if (ssIsSampleHit(S, rstPortTid, tid)) 
            {           
                if (rst[0] != 0.0)
                    mdlInitializeConditions(S);
            }
        } /* End if (HAS_RST_PORT) */       

        /* At every output hit, compute the phase estimate.
        /* Compute the output first and then the input to prevent 
         * misalignment of samples. This adds the extra 1 symbol delay. */
        if (ssIsSampleHit(S, outPort1Tid, tid)) 
        {
            /* Maintain continuity for estimates (last 2 symbols) */
            for (k = 0; k < 2; k++) 
                tau[k] = tau[k+numSymb];

            /* Call the appropriate PLL method*/
            switch (TED_METHOD(S)){
            case GARDNER :
                GardnerPLL(numSymb, N, buffLen, g, tau, in);
                break;
            case ELGATE :
                ELGatePLL(numSymb, N, buffLen, g, tau, in);
                break;
            case MMULLER :
                MMullerPLL(numSymb, N, buffLen, g, tau, in);
                break;
            default :
                break;
            }

            /* Compute and assign the outputs */
            evalOutputs(numSymb, N, buffLen, tau, in, y1, y2);
            
        } /* end if ssIsSampleHit(S,Outport) */

        /* Buffer at every input hit */
        if (ssIsSampleHit(S, inPortTid, tid)) 
        {
            /* Buffer the input: first input stored in last index. 
             *  Input:  | 1 | 2 | 3 | 4 | 5| ,in symbols
             *
             *  Buffer: | 1 | 2 | 3 | 4 | 5|
             *          | 0 | 1 | 2 | 3 | 4|
             *          | 0 | 0 | 1 | 2 | 3|
             */           
            /* Move data down by one sample, discarding the last one */
            for (k = buffLen-1; k > 0; k--) {
                in[k].re = in[k-1].re;
                in[k].im = in[k-1].im;
            }
            
            /* Fill incoming sample at the topmost position */ 
            in[0].re = u[0].re; 
            in[0].im = u[0].im;  
        } /* End if (ssIsSampleHit(S, inPortTid, tid)) */
                
    } else  /* Frame-Based */
    {   
        int_T rstInput = 0;
        numSymb = inPortWidth/N;

        /* Check resetting options */
        switch ((int_T)(mxGetPr(RESET_ARG(S))[0])) {
        case RESET_EVERY_FRAME :
            rstInput = 1;
            break;
        case RESET_PORT :
            {
                real_T *rst  = (real_T *)ssGetInputPortSignal(S, RSTPORT);
                if (rst[0] != 0.0) 
                    rstInput = 1;
            }
            break;
        case NO_RESET :
            rstInput = 0;
            break;
        default :
            break;
        }

        /* Reset as required */
        if (rstInput) {
              mdlInitializeConditions(S);
        } else { /* No reset */
            /* Move top 2 symbols in buffer to last 2 positions, bottom-up. */
            for (k = 0; k < 2*N; k++) {
                in[buffLen-1-k].re = in[2*N-1-k].re;
                in[buffLen-1-k].im = in[2*N-1-k].im;
            }

            /* Maintain continuity for estimates (last 2 symbols) */
            for (k = 0; k < 2; k++) 
                tau[k] = tau[k+numSymb];

        } /* End if (rstInput) */

        /* Buffer the input: first input stored in last index. 
         *  Input:  | 1 | 3 | 5 | 7 |
         *          | 2 | 4 | 6 | 8 |
         *
         *  Buffer: | 2 | 4 | 6 | 8 |
         *          | 1 | 3 | 5 | 7 |
         *          | 0 | 2 | 4 | 6 |
         *          | 0 | 1 | 3 | 5 |
         * Fill the incoming frame in descending order at the top */ 
        for (k = inPortWidth; k > 0; k--){
            in[inPortWidth-k].re = u[k-1].re;
            in[inPortWidth-k].im = u[k-1].im;  
        }

        /* Call the appropriate PLL method*/
        switch (TED_METHOD(S)){
        case GARDNER :
            GardnerPLL(numSymb, N, buffLen, g, tau, in);
            break;
        case ELGATE :
            ELGatePLL(numSymb, N, buffLen, g, tau, in);
            break;
        case MMULLER :
            MMullerPLL(numSymb, N, buffLen, g, tau, in);
            break;
        default :
            break;
        }

        /* Compute and assign the outputs */
        evalOutputs(numSymb, N, buffLen, tau, in, y1, y2);

    } /* End if(isSampBased) */             
} /* End mdlOutputs */


static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S);
}


#ifdef MATLAB_MEX_FILE /* Matching endif at close to end of file */

#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    timRecSetInputPortSampleTime(S, portIdx, sampleTime, offsetTime);

} /* end mdlSetInputPortSampleTime */

#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    timRecSetOutputPortSampleTime(S, portIdx, sampleTime, offsetTime);

} /* end mdlSetOutputPortSampleTime */

#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S,
                                      int_T portIdx,
                                      Frame_T frameData)
{
    timRecSetInputPortFrameData(S, portIdx, frameData);

} /* end mdlSetInputPortFrameData */

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                      const DimsInfo_T *dimsInfo)
{
    timRecSetInputPortDimensionInfo(S, portIdx, dimsInfo);

} /* end mdlSetInputPortDimensionInfo */

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                          const DimsInfo_T *dimsInfo)
{
    timRecSetOutputPortDimensionInfo(S, portIdx, dimsInfo);

} /* end mdlSetOutputPortDimensionInfo */

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    /* initialize a dynamically-dimensioned DimsInfo_T */
    DECL_AND_INIT_DIMSINFO(dInfo); 
    int_T dims[2] = {1, 1};

    /* select scalar 2D dimensions */
    dInfo.width     = 1;
    dInfo.numDims   = 2;
    dInfo.dims      = dims;

    /* call the output functions */
    if (ssGetOutputPortWidth(S,OUTPORT1) == DYNAMICALLY_SIZED)
        mdlSetOutputPortDimensionInfo(S, OUTPORT1, &dInfo);

    if (ssGetOutputPortWidth(S,OUTPORT2) == DYNAMICALLY_SIZED) 
        mdlSetOutputPortDimensionInfo(S, OUTPORT2, &dInfo);

    /* call the input functions */
    if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) 
        mdlSetInputPortDimensionInfo(S, INPORT, &dInfo);

    if (HAS_RST_PORT(S)) {
        if (ssGetInputPortWidth(S, RSTPORT) == DYNAMICALLY_SIZED) 
            mdlSetInputPortDimensionInfo(S, RSTPORT, &dInfo);
    }
}

#endif /* for matching ifdef MATLAB_MEX_FILE at mdlSetInputPortSampleTime() */

#ifdef MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif
