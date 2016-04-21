/*
 *  SDSPBURG - Burg method of AR parameter estimation.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.27 $ $Date: 2002/04/14 20:43:46 $
 */
#define S_FUNCTION_NAME sdspburg
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {OUTPORT, NUM_OUTPORTS};
enum {INPORT=0, NUM_INPORTS};
enum {FERR_IDX=0, BERR_IDX, ANEW_IDX, ACOEF_IDX, NUM_DWORKS};
enum {ORDER_ARGC=0, FCN_TYPE_ARGC, NUM_ARGS};

#define ORDER_ARG    ssGetSFcnParam(S,ORDER_ARGC)
#define FCN_TYPE_ARG ssGetSFcnParam(S,FCN_TYPE_ARGC)

typedef enum {fcnAandK=1, fcnA, fcnK} FcnType;


/*
 * Determine output port number of reflection coefficients,
 * gain, or polynomial.  If not output, return -1.
 */

/* Polynomial port: */
static int_T getAPort(SimStruct *S)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    int_T port = (ftype == fcnK) ? -1 : 0;
    return(port);
}

/* Reflection coefficient port: */
static int_T getRCPort(SimStruct *S)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    int_T port = -1;

    if (ftype == fcnAandK) {
        port = 1;
    } else if (ftype == fcnK) {
        port = 0;
    }

    return(port);
}

/* Gain port: */
static int_T getGPort(SimStruct *S)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    int_T port = (ftype == fcnAandK) ? 2 : 1;
    return(port);
}



#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
#ifdef MATLAB_MEX_FILE
    FcnType ftype;

    /* Check function popup: */
    if (!IS_FLINT_IN_RANGE(FCN_TYPE_ARG, 1, 3)) {
        THROW_ERROR(S, "Function parameter must be a scalar in the range [1,3].");
    }
    ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);

    /* Check ORDER_ARG: */
    if (OK_TO_CHECK_VAR(S, ORDER_ARG)) {
        if (!IS_FLINT_GE(ORDER_ARG, -1)) {
            THROW_ERROR(S, "Order must be a scalar integer >= 0.  (Use -1 for order=length(u)-1)");
        }

        if ((ftype!=fcnA) && (mxGetPr(ORDER_ARG)[0] < 2.0)) {
            THROW_ERROR(S, "Order must be > 1 when returning reflection coefficients.");
        }
    }
#endif
}



static void mdlInitializeSizes(SimStruct *S)
{

    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetSFcnParamNotTunable(S, ORDER_ARGC);
    ssSetSFcnParamNotTunable(S, FCN_TYPE_ARGC);

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT, 1);

    /* Outputs: */
    {
        const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
        int_T gain_port = getGPort(S);

        if (ftype == fcnAandK) {
            /* 3 outputs (both polynomial and reflection coefficients,
             *  plus gain) - set the 2nd port properties now:
             */
            if (!ssSetNumOutputPorts(S,3)) return;
            ssSetOutputPortWidth(        S, 1, DYNAMICALLY_SIZED);
            ssSetOutputPortComplexSignal(S, 1, COMPLEX_INHERITED); 
            ssSetOutputPortReusable(     S, 1, 1);

        } else {
            /* 2 Outputs (either polynomial or reflection coefficients,
             * plus gain port)
             */
            if (!ssSetNumOutputPorts(S,2)) return;
        }

        /* Set the first port (same for any mode) */
        ssSetOutputPortWidth(        S, 0, DYNAMICALLY_SIZED);
        ssSetOutputPortComplexSignal(S, 0, COMPLEX_INHERITED); 
        ssSetOutputPortReusable(     S, 0, 1);

        /* Setup gain port: */
        ssSetOutputPortWidth(        S, gain_port, 1);
        ssSetOutputPortComplexSignal(S, gain_port, COMPLEX_NO);
        ssSetOutputPortReusable(     S, gain_port, 1);
    }

    if(!ssSetNumDWork(  S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE );
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


static void mdlCheckParametersPostProp(SimStruct *S)
{
    /* Check arguments relying on port widths, etc: */

    const int_T N     = ssGetInputPortWidth(S, INPORT);
    const int_T order = (int_T)(mxGetPr(ORDER_ARG)[0]);

    /*
     * Check number of requested ACF coefficients.
     * Don't automatically zero-pad the input sequence.
     */
    if (order+1 > N) {  /* Works even when order=-1 (i.e., inherit input width) */
        THROW_ERROR(S, "Order exceeds number of input samples.");
    }
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    mdlCheckParametersPostProp(S);
#endif
}



static void mdlOutputs(SimStruct *S, int_T tid)
{
    const FcnType   ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T cplx  = (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const int_T     N     = ssGetInputPortWidth(S, INPORT);
    const int_T     order = (int_T)(mxGetPr(ORDER_ARG)[0]);
    real_T          E     = 0.0;

    if (cplx) {
        /*
         * Complex inputs:
         */
        InputPtrsType uptr = ssGetInputPortSignalPtrs(S, INPORT);
        creal_T      *ef   = (creal_T *)ssGetDWork(S, FERR_IDX);
        creal_T      *eb   = (creal_T *)ssGetDWork(S, BERR_IDX);
        int_T         k;

        creal_T      *Acoef  = (ftype == fcnK)
                             ? (creal_T *)ssGetDWork(S, ACOEF_IDX)
                             : (creal_T *)ssGetOutputPortSignal(S, getAPort(S));
        creal_T      *RCcoef = (ftype == fcnA)
                             ? NULL
                             : (creal_T *)ssGetOutputPortSignal(S, getRCPort(S));

        /* Preset AR coefficients: */
        {
            creal_T *a = Acoef;
            a->re      = 1.0;          /* First AR coefficient is 1 */
            (a++)->im  = 0.0;

            for(k=1; k <= order; k++) {
                a->re     = 0.0;
                (a++)->im = 0.0;       /* All remaining are zero */
            }
        }
        
        /* Copy inputs and compute initial prediction error: */
        for (k=0; k<N; k++) {
            creal_T x = *((creal_T *)(*uptr++));
            ef[k] = eb[k] = x;
            E += CMAGSQ(x);
        }
        E /= N;
        
        for(k=1; k<=order; k++) {
            int_T   n;
            creal_T KK;

            /* Calculate reflection coefficient: */
            {
                creal_T *efp = ef+k;
                creal_T *ebp = eb+k-1;
                creal_T  num = {0.0, 0.0};
                real_T   den = 0.0;
                
                for (n=k; n <= N-1; n++) {
                    const creal_T v1 = *efp++;
                    const creal_T v2 = *ebp++;
                    den    += CMAGSQ(v1) + CMAGSQ(v2);
                    num.re += CMULT_YCONJ_RE(v1, v2);
                    num.im += CMULT_YCONJ_IM(v1, v2);
                }
                KK.re = -2 * num.re / den;
                KK.im = -2 * num.im / den;
            }

            /* Record reflection coefficient: */
            if (RCcoef != NULL) {
                RCcoef[k-1] = KK;
            }

            /* Update AR polynomial: */
            {
                int_T    i;
                creal_T *a    = Acoef;
                creal_T *anew = (creal_T *)ssGetDWork(S, ANEW_IDX);  /* point to output area + 1*/

                for (i=1; i <= k-1; i++) {
                    creal_T Ka;
                    Ka.re = CMULT_YCONJ_RE(KK, a[k-i]);
                    Ka.im = CMULT_YCONJ_IM(KK, a[k-i]);
                    anew[i].re = a[i].re + Ka.re;
                    anew[i].im = a[i].im + Ka.im;
                }
                anew[k] = KK;

                /* Update polynomial for next iteration: */
                for (i=1; i <= k; i++) {
                    a[i] = anew[i];
                }
            }
            
            /* Update prediction error terms: */
            for (n=N-1; n >= k+1; n--) {
                creal_T t;

                /* ef[j] += K * eb[n-1]; */
                t.re = CMULT_RE(KK, eb[n-1]);
                t.im = CMULT_IM(KK, eb[n-1]);
                ef[n].re += t.re;
                ef[n].im += t.im;

                /* eb[j]  = eb[n-1] + K * ef_old; */
                t.re = CMULT_XCONJ_RE(KK, ef[n-1]);
                t.im = CMULT_XCONJ_IM(KK, ef[n-1]);
                eb[n-1].re = eb[n-2].re + t.re;
                eb[n-1].im = eb[n-2].im + t.im;
            }
            
            /* Update prediction error: */
            E *= (1.0 - CMAGSQ(KK));
        }

    } else {
        /*
         * Real inputs:
         */
        InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT);
        real_T           *ef   = (real_T *)ssGetDWork(S, FERR_IDX);
        real_T           *eb   = (real_T *)ssGetDWork(S, BERR_IDX);
        int_T             k;
        
        real_T      *Acoef  = (ftype == fcnK)
                            ? (real_T *)ssGetDWork(S, ACOEF_IDX)
                            : ssGetOutputPortRealSignal(S, getAPort(S));
        real_T      *RCcoef = (ftype == fcnA)
                            ? NULL
                            : ssGetOutputPortRealSignal(S, getRCPort(S));

        /* Preset AR coefficients: */
        {
            real_T *a = Acoef;
            *a++ = 1.0;             /* First AR coefficient is 1 */

            /* xxx Unnecessary? */
            for(k=1; k <= order; k++) {
                *a++ = 0.0;         /* All remaining are zero */
            }
        }
        
        /* Copy inputs and compute initial prediction error: */
        for (k=0; k<N; k++) {
            real_T x = **uptr++;
            ef[k] = eb[k] = x;
            E += x*x;
        }
        E /= N;
        
        for(k=1; k<=order; k++) {
            int_T   n;
            real_T KK;

            /* Calculate reflection coefficient: */
            {
                real_T *efp = ef+k;
                real_T *ebp = eb+k-1;
                real_T  num = 0.0;
                real_T  den = 0.0;
                
                for (n=k; n <= N-1; n++) {
                    const real_T v1 = *efp++;
                    const real_T v2 = *ebp++;
                    den    += v1*v1 + v2*v2;
                    num    += v1*v2;
                }
                KK = -2 * num / den;
            }

            /* Record reflection coefficient: */
            if (RCcoef != NULL) {
                RCcoef[k-1] = KK;
            }

            /* Update AR polynomial: */
            {
                int_T   i;
                real_T *a    = Acoef;
                real_T *anew = (real_T *)ssGetDWork(S, ANEW_IDX);  /* point to output area + 1*/

                for (i=1; i <= k-1; i++) {
                    anew[i]= a[i] + KK * a[k-i];
                }
                anew[k] = KK;

                /* Update polynomial for next iteration: */
                for (i=1; i <= k; i++) {
                    a[i] = anew[i];
                }
            }
            
            /* Update prediction error terms: */
            for (n=N-1; n >= k+1; n--) {
                ef[n] += KK * eb[n-1];
                eb[n-1] = eb[n-2] + KK * ef[n-1];
            }
            
            /* Update prediction error: */
            E *= (1.0 - KK*KK);
        }
    }

    /*
     * Save gain term:
     */
    *ssGetOutputPortRealSignal(S, getGPort(S)) = E;
}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef MATLAB_MEX_FILE

#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
    const FcnType   ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T conn  = (boolean_T)ssGetInputPortConnected(S,0);
    const int_T     order = (int_T)(mxGetPr(ORDER_ARG)[0]);
    int_T A, K;

    if (port != 0) {
        THROW_ERROR(S,"Invalid input port number for input width propagation.");
    }

    ssSetInputPortWidth(S,port,inputPortWidth);

    if (conn) {
        if ( (ftype != fcnA) && (inputPortWidth <= 1) ) {
             THROW_ERROR(S,"Cannot output reflection coefficients when input is a scalar. "
                         "Set output mode to 'A' instead.");
        }

    }

    if (order == -1) {
        A = inputPortWidth;
        K = MAX(1, inputPortWidth-1);
    } else {
        A = order+1;
        K = order;
    }

    switch (ftype) {
        case fcnAandK:
            ssSetOutputPortWidth(S, getAPort(S), A);
            ssSetOutputPortWidth(S, getRCPort(S), K);
            break;

        case fcnA:
            ssSetOutputPortWidth(S, getAPort(S), A);
            break;

        case fcnK:
            ssSetOutputPortWidth(S, getRCPort(S), K);
            break;
    }
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    const FcnType   ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T conn  = (boolean_T)ssGetInputPortConnected(S,0);
    const int_T     order = (int_T)(mxGetPr(ORDER_ARG)[0]);
    int_T           A, K;

    ssSetOutputPortWidth(S,port,outputPortWidth);

    if (port >= 2) {
        /* Should not get a call for gain (3rd) output port, since it is declared (scalar) */
        THROW_ERROR(S,"Invalid input port number for output width propagation.");
    }

    if (conn) {
        /* size(A)==1 implies size(INPUT)==1, which does not allow
         * reflection coefficients to be output (they would be empty)
         */
        if ((ftype != fcnA) && (port==0) && (outputPortWidth == 1)) {
            THROW_ERROR(S,"Cannot output reflection coefficients when input is a scalar. "
                        "Set output mode to 'A' instead.");
        }
    } 

    if (order == -1) {
        if (port == getAPort(S)) {
            A = outputPortWidth;
            K = MAX(1, A-1);
        } else {
            K = outputPortWidth;
            A = K+1;
        }
    } else {
        A = order+1;
        K = MAX(1, order);
    }

    ssSetInputPortWidth(S, INPORT, A);

    switch (ftype) {
        case fcnAandK:
            if (port == getAPort(S)) {
                ssSetOutputPortWidth(S, getRCPort(S), K);
            } else {
                ssSetOutputPortWidth(S, getAPort(S), A);
            }
            break;

        case fcnA:
        case fcnK:
            /* Only need to set input port -- already done */
            break;
    }
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    const int_T N  = ssGetNumOutputPorts(S);

    ssSetInputPortComplexSignal( S, portIdx, iPortComplexSignal);
    ssSetOutputPortComplexSignal(S, 0,       iPortComplexSignal);

    if (N>2) {
        ssSetOutputPortWidth(S,1,iPortComplexSignal);
    } 
}


#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx, 
                                          CSignal_T oPortComplexSignal)
{
    const int_T N  = ssGetNumOutputPorts(S);

    ssSetInputPortComplexSignal( S, INPORT,  oPortComplexSignal);
    ssSetOutputPortComplexSignal(S, portIdx, oPortComplexSignal);

    if (N>2) {
        ssSetOutputPortComplexSignal(S,1-portIdx,oPortComplexSignal);
    }
}

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    /* Allocate storage for:
     *     ef: N  (forward error)
     *     eb: N  (backward error)
     *   anew: temp scratchpad for reversed poly coeff's
     *  ACoef: Polynomial coeffs if they are not output directly
     */
    const int_T     N         = ssGetInputPortWidth(S,INPORT);
    const CSignal_T cplx      = ssGetInputPortComplexSignal(S,INPORT);
    const FcnType   ftype     = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    int_T           numDWork  = NUM_DWORKS;

    /* If we are outputting A, we don't need extra DWork
     * storage for it (it will be stored directly in the
     * output area).
     */
    const boolean_T needACoef = (ftype == fcnK);

    if (!needACoef) numDWork--;

    if(!ssSetNumDWork(      S, numDWork)) return;

    ssSetDWorkWidth(        S, FERR_IDX, N);
    ssSetDWorkDataType(     S, FERR_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, FERR_IDX, cplx);

    ssSetDWorkWidth(        S, BERR_IDX, N);
    ssSetDWorkDataType(     S, BERR_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, BERR_IDX, cplx);

    ssSetDWorkWidth(        S, ANEW_IDX, N);
    ssSetDWorkDataType(     S, ANEW_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, ANEW_IDX, cplx);

    if (needACoef) {
        ssSetDWorkWidth(        S, ACOEF_IDX, N);
        ssSetDWorkDataType(     S, ACOEF_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, ACOEF_IDX, cplx);
    }
}

#endif /* MATLAB_MEX_FILE */


#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] sdspburg.c */
