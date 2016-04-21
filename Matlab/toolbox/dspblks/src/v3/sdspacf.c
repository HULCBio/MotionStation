/*
*  SDSPACF.c - complex autocorrelation function.
*  DSP Blockset S-Function to compute the complex autocorrelation function.
*
*  Computes positive lags (0,1,...,M-1) for a real length-N input
*  with M <= N.
*
*  Bias flag: 1=none, 2=biased, 3=unbiased,
*             4="unity at zero-lag" (corresponds to "coeff" in xcorr.m)
*
*  Update: J. Faneuff  23-Jan-98
*  14-Jul-97
*  Copyright 1995-2002 The MathWorks, Inc.
*  $Revision: 1.19 $ $Date: 2002/04/14 20:43:16 $
*/

#define S_FUNCTION_NAME sdspacf
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0};
enum {OUTPORT=0};

enum {MAXLAG_IDX=0, BIAS_IDX, NUM_PARAMS};

#define MAXLAG_PARAM ssGetSFcnParam(S, MAXLAG_IDX)
#define BIAS_PARAM   ssGetSFcnParam(S, BIAS_IDX)

typedef enum {NO_BIAS=1, BIASED, UNBIASED, COEFF} Scale;

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    static char *msg;
    int_T       i;
    real_T      d;
    
    msg = NULL;
    
    /* Check MAXLAG_PARAM: */
    if ((mxGetNumberOfElements(MAXLAG_PARAM) != 1) || !mxIsDouble(MAXLAG_PARAM)    ) {
        msg = "Maximum lag must be a scalar double.";
        goto FCN_EXIT;
    }
    d = mxGetPr(MAXLAG_PARAM)[0];
    i = (int_T)d;
    if ((d != i) || (d < -1)) {
        msg = "Maximum lag must be a scalar integer >= 0.  (Use -1 for all positive lags)";
        goto FCN_EXIT;
    }
    
    /* Check BIAS_PARAM: */
    if ((mxGetNumberOfElements(BIAS_PARAM) != 1) || !mxIsDouble(BIAS_PARAM)    ) {
        msg = "Bias type must be specified as a scalar";
        goto FCN_EXIT;
    }
    d = mxGetPr(BIAS_PARAM)[0];
    i = (int_T)d;
    if ((d != i) || (d<1) || (d>4)) {
        msg = "Bias flag be one of the following:\n"
            "1=None, 2=Biased, 3=Unbiased, or 4=Coeff";
        goto FCN_EXIT;
    }
    
FCN_EXIT:
    ssSetErrorStatus(S,msg);
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_PARAMS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /*
     * Param index 0 is MAXLAG_PARAM not
     * tunable because it effects output width
     */
    ssSetSFcnParamNotTunable(S, MAXLAG_IDX);     

    /* Bias is not tunable in RTW generated code. */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        
        ssSetSFcnParamNotTunable(S, BIAS_IDX);
    }
        


    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;
    
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 0);  /* revisits inputs multiple times */
    
    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(    S, OUTPORT, 1);
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T N      = ssGetInputPortWidth(S,INPORT);
    const int_T maxlag = (int_T)(mxGetPr(MAXLAG_PARAM)[0]);
    /*
    * Check number of requested ACF coefficients.
    * Don't automatically zero-pad the input sequence.
    */
    if (maxlag+1 > N) {  /* Works even when maglag=-1 (i.e., inherit input width) */
        ssSetErrorStatus(S, "Maximum lag exceeds number of input samples.");
        return;
    }
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T     N     = ssGetInputPortWidth(S,INPORT);
    const int_T     nlags = ssGetOutputPortWidth(S,OUTPORT);
    const boolean_T c0    = (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    Scale           bias  = (Scale)((int_T)mxGetPr(BIAS_PARAM)[0]);
    real_T          norm;
    int_T           i;
    
    if (!c0) {
        /* Real Input */
        
        InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,INPORT);
        real_T            *y    = ssGetOutputPortRealSignal(S,OUTPORT);
        
        for (i=0; i<nlags; i++) {
            InputRealPtrsType p0   = uptr;
            InputRealPtrsType p1   = uptr + i;
            real_T            sum  = 0.0;
            int_T             jcnt = N-i;
            
            while(jcnt-- > 0) {
                sum += **p0++ * **p1++;
            }
            
            switch (bias) {             /* TLC will generate only one case */
                
            case NO_BIAS:
                *y++ = sum;
                break;
                
            case BIASED:
                *y++ = sum / N;
                break;			
                
            case UNBIASED:
                *y++ = sum / (N-i);
                break;			
                
            case COEFF:
                /* Set norm = 1/magnitude of 0th lag for all of the lags. */
                if (i == 0) {
                    *y++ = 1.0;        /* Normalized element at zero lag is 1 */

                    /* Protect against division by zero: */
                    norm = (sum == 0.0) ? 1.0 : 1.0/sum;

                } else {
                    *y++ = sum * norm;
                }
                break;
            }
        }
    } else {
        /* Complex Input */
        
        InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT);
        creal_T       *y    = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
        
        for (i=0; i<nlags; i++) {
            InputPtrsType p0     = uptr; 
            InputPtrsType p1     = uptr + i;
            creal_T       csum   = {0.0, 0.0};
            int_T         jcnt   = N-i;
            
            while(jcnt-- > 0) {
                const creal_T *u0 = (creal_T *)(*p0++);
                const creal_T *u1 = (creal_T *)(*p1++);

                /* add: conj(u0) * u1 */
                csum.re += CMULT_XCONJ_RE(*u0, *u1);
                csum.im += CMULT_XCONJ_IM(*u0, *u1);
            }
            
            switch(bias) {             /* TLC will generate only one case */
                
            case NO_BIAS:
                *y++ = csum;
                break;
                
            case BIASED:
                y->re     = csum.re / N;
                (y++)->im = csum.im / N;
                break;			
                
            case UNBIASED:  
                y->re     = csum.re / (N-i);
                (y++)->im = csum.im / (N-i);
                break;			
                
            case COEFF:     
                /*
                 * Set norm = 1/magnitude of 0th lag. to be used for all lags.
                 */
                if (i == 0) {
                    /* In this special case the imaginary part is zero
                     * because u0 and u1 are the same point at i=0, 
                     * CMULT_XCONJ_IM(*u0, *u1) = 0;
                     */
                    norm = (csum.re == 0.0) ? 1.0 : 1.0/csum.re;
                }

                y->re     = norm * csum.re;
                (y++)->im = norm * csum.im;
                break;
            }
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    int_T maxlag          = (int_T) (mxGetPr(MAXLAG_PARAM)[0]);
    int_T outputPortWidth = ssGetOutputPortWidth(S,OUTPORT);
    
    ssSetInputPortWidth(S, port, inputPortWidth);
    
    if(maxlag == -1) {
        if (outputPortWidth == DYNAMICALLY_SIZED) {
            /* Copy input port width to output: */
            ssSetOutputPortWidth(S, port, inputPortWidth);
        } else {
            /* Verify that input port width matches output port width */
            if (inputPortWidth != outputPortWidth) {
                ssSetErrorStatus(S, "Input port width does not match output port width "
                    "when maxlag=-1.");
            }
        }
    } else {
        /* Non-inherited maxlag */
        if (outputPortWidth ==  DYNAMICALLY_SIZED) {
            ssSetOutputPortWidth(S, port, maxlag+1);
        } else {
            /* Check that output width is maxlag+1 */
            if (outputPortWidth != maxlag+1) {
                ssSetErrorStatus(S, "Output port width does not correspond to maximum lag");
            }
        }
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    int_T maxlag = (int_T) (mxGetPr(MAXLAG_PARAM)[0]);
    
    ssSetOutputPortWidth(S,port,outputPortWidth);
    
    if (maxlag != -1) {
        /* Maximum lag has been set to a finite width: */
        if (outputPortWidth != maxlag+1) {
            ssSetErrorStatus(S, "Output port width does not correspond to maximum lag");
        }
    } else {
        /* Output port "inherits" width from input port: */
        int_T inputPortWidth = ssGetInputPortWidth(S, 0);
        if (inputPortWidth != DYNAMICALLY_SIZED) {
            /* Input port width is known ... check that it matches the output width! */
            if (inputPortWidth != outputPortWidth) {
                ssSetErrorStatus(S, "Output port width does not match input port width "
                    "when maxlag=-1.");
            }
        } else {
            /* Input is not known, so we should set inwidth = outwidth */
            ssSetInputPortWidth(S,port,outputPortWidth);  
        }
    }
}
#endif


/* Complex handshake */
#include "dsp_cplxhs21.c"  


#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
