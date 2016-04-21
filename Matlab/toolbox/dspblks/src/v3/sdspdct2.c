/*
 * SDSPDCT2  DCT S-function.
 * DSP Blockset S-Function to perform a DCT.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.26 $  $Date: 2002/12/23 22:25:03 $
 */
#define S_FUNCTION_NAME sdspdct2
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"
#include "dspfft_rt.h"

enum {INPORT=0, NUM_INPORTS}; 
enum {OUTPORT=0, NUM_OUTPORTS}; 
enum {NCHANS_ARGC=0, NUM_ARGS};
enum {WEIGHTS_IDX=0, BUFF_IDX, MAX_NUM_DWORKS}; 
/*
 *  Real input port: one dwork (WEIGHTS_ID) 
 *  Complex input port: two dworks (WEIGHTS, BUFF_IDX)
 */

#define NCHANS_ARG (ssGetSFcnParam(S,NCHANS_ARGC))


#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE

    /* Number of channels */
    if OK_TO_CHECK_VAR(S, NCHANS_ARG) { 
        if(!IS_FLINT_GE(NCHANS_ARG,1)) {
            THROW_ERROR(S, "Number of channels must be an integer > 0.");
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

	/* Parameters */
    ssSetSFcnParamNotTunable(S, NCHANS_ARGC);


    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT, 0);
    ssSetInputPortOverWritable(     S, INPORT, 0); 

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 0);


    /* DWorks: */
    if(!ssSetNumDWork(     S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(   S, 1);
    ssSetOptions(          S, SS_OPTION_EXCEPTION_FREE_CODE );
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
    const int_T  nChans    = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T  FrameSize = ssGetInputPortWidth(S,INPORT) / nChans;
    const real_T piN2      = 2.0*atan(1.0)/FrameSize;  /* pi / (2*N) */
    const real_T den       = sqrt(2*FrameSize)/2.0;
    creal_T      *ww       = (creal_T *)ssGetDWork(S, WEIGHTS_IDX);
    int_T         i;

#ifdef MATLAB_MEX_FILE

    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for DCT block.");
    }

    /* Check to make sure input size is a power of 2: */
    if (frexp((real_T)FrameSize, &i) != 0.5) {
        THROW_ERROR(S,"Width of input to DCT must be a power of 2");
    }
    if (FrameSize == 1) {
      mexWarnMsgTxt("Computing the DCT of a scalar input.\n");
    }
#endif

  /*
   * Need to compute weights to multiply DFT coefficients.
   * By computing the real and imag parts
   *
   * ww = (exp(-i*(0:n-1)*pi/(2*n))/sqrt(2*n)).';
   * ww(1) = ww(1) / sqrt(2);
   *
   * exp(-i*x) = cos(x) - i*sin(x) 
   */
    
   /* Only need FrameSize number of coefficients */

    for (i = 0; i < FrameSize; i++) {
        ww[i].re =  cos(i*piN2) / den;
        ww[i].im = -sin(i*piN2) / den;
    }
    ww[0].re /= sqrt(2.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T cmplx  = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    const int_T     nChans = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T     N      = ssGetInputPortWidth(S,INPORT) / nChans;
    
    if (!cmplx) {
        /* Real */
        InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT);
        creal_T          *yout = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
        const int_T       N2   = N  >> 1; /* length of complex FFT       */
        const int_T       N4   = N2 >> 1; /* half length of complex FFT  */
        real_T            N2ele;         /* Store the N2 element */
        int_T ch;
        
        /* Scalar input */
        if (N == 1) {
            real_T *y = ssGetOutputPortRealSignal(S,OUTPORT);
            
            for(ch=0; ch<nChans; ch++) {
                *y++ = **uptr++;
            }
            return;
        }
        
        for(ch=0; ch<nChans; ch++) {
            
            /* NOTE: All remaining code is for N >= 2 */
            if (N == 2) {
                yout->re = **uptr++;
                yout->im = **uptr++;
                
            } else {
                int_T i;
                
                for (i=0; i<N4; i++) {
                    yout[i].re    = **(uptr + 4*i);
                    yout[i].im    = **(uptr + 4*i + 2);
                    yout[N4+i].re = **(uptr - 4*i + N-1);
                    yout[N4+i].im = **(uptr - 4*i + N-1 - 2);
                }
                uptr += N; /* Increment to next frame */
            }	
            
            /* Compute length N/2 FFT: */
            MWDSP_R2BR_Z(yout, 1, N2, N2);
            MWDSP_R2DIT_TRIG_Z(yout, 1, N2, N2, 0);
            
            {
                real_T  theta = -8 * atan(1.0) / N;
                creal_T W     = {1.0, 0.0};
                creal_T twid;
                int_T   i;
                
                /* Complex exponential: cos+jsin */
                twid.re = cos(theta);
                twid.im = sin(theta);
                
                /* Store y[N2] element (always real) */
                N2ele = yout[0].re - yout[0].im;
                
                yout[0].re += yout[0].im; 
                yout[0].im  = 0.0;
                
                for (i = 1; i < N4; i++) {
                    creal_T a, b, c, d;
                    
                    a = yout[i];
                    b = yout[N2-i];
                    
                    c.re = 0.5 * (a.re + b.re);
                    c.im = 0.5 * (a.im - b.im);
                    
                    d.re =  0.5 * (a.im + b.im);
                    d.im = -0.5 * (a.re - b.re);
                    
                    {
                        creal_T ctemp;
                        
                        /* W *= twid */
                        ctemp.re = CMULT_RE(W, twid);
                        ctemp.im = CMULT_IM(W, twid);
                        W = ctemp;
                        
                        /* Precompute W*d: */
                        ctemp.re = CMULT_RE(W, d);
                        ctemp.im = CMULT_IM(W, d);
                        
                        /* y[i] = c + W * d */
                        yout[i].re      =  c.re + ctemp.re;
                        yout[i].im      =  c.im + ctemp.im;
                        
                        /* y[N2 - i] = conj(c - W*d) */
                        yout[N2 - i].re =  c.re - ctemp.re;
                        yout[N2 - i].im = -c.im + ctemp.im;
                    }
                }
                yout[N4].im = -yout[N4].im;
            }
            
            /* Multiply by weights: */
            {
                /* Start y at the beginning of the next frame */
                real_T  *y  = ssGetOutputPortRealSignal(S,OUTPORT) + (ch*N);
                creal_T *ww = (creal_T *)ssGetDWork(S, WEIGHTS_IDX);
                int_T    i;
                
                /* Note: There's N2-1 values are conjugates of each other:
                 *   for (i = 1; i < N2; i++) {
                 *       yr[i + N2] =  yr[N2 - i];
                 *       yi[i + N2] = -yi[N2 - i];
                 *   }
                 */
                
                *y++ = CMULT_RE(yout[0],ww[0]);
                
                for (i=1; i<N2; i++) {
                    creal_T ctemp  = yout[i];
                    *y++ = CMULT_RE(ctemp,ww[i]);
                    *y++ = CMULT_XCONJ_RE(ctemp,ww[N-i]);
                }
                y -= N-1;
                
                {
                    real_T *ya = y+2;
                    real_T *yb = y+N-1;
                    int_T  j   = N2-1;
                    
                    while (j-- > 0) {
                        *yb = *ya;
                        for (i=0; i<(yb-ya); i++) {
                            ya[i] = ya[i+1];
                        }
                        ya++;
                        yb--;
                    }
                    y[N2] = N2ele * ww[N2].re;
                }
            }
            
            yout += N2; /* Increment to next frame. Increment by N2 because 
                         * yout is a pointer to complex values. 
                         */
            
                } /* End loop over channels */
                
    } else {
        /* Complex */
        InputPtrsType uptr = ssGetInputPortSignalPtrs(S, INPORT);
        creal_T      *y    = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
        creal_T      *buff = (creal_T *)ssGetDWork(S, BUFF_IDX); 
        const int_T   Nfft = 2*N;
        int_T         i;
        int_T         ch;
        
        for(ch=0; ch < nChans; ch++) {
            
        /* Copy input to buffer. First half of buffer is the input in order,
         * second half is the input in reverse order
         */
            for (i=0; i<N; i++) {
                buff[i] = buff[2*N-1-i] = *((creal_T *)(*uptr++));
            }
            
            MWDSP_R2BR_Z(buff, 1, Nfft, Nfft);
            MWDSP_R2DIT_TRIG_Z(buff, 1, Nfft, Nfft, 0);

            
            /* Multiply by weights: */
            {
                creal_T *ww = (creal_T *)ssGetDWork(S, WEIGHTS_IDX);
                
                for (i=0; i<N; i++) {
                    y->re     = 0.5*CMULT_RE(buff[i],ww[i]);
                    (y++)->im = 0.5*CMULT_IM(buff[i],ww[i]);
                }
            }        
        } /* End loop over channels */
    } /* End else complex */
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const boolean_T cmplx     = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    const int_T     nChans    = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T     FrameSize = ssGetInputPortWidth(S,INPORT) / nChans;

    const int_T     nDWorks = (cmplx)? MAX_NUM_DWORKS : (MAX_NUM_DWORKS - 1);

    if(!ssSetNumDWork(      S, nDWorks)) return;

    ssSetDWorkWidth(        S, WEIGHTS_IDX, FrameSize);
    ssSetDWorkDataType(     S, WEIGHTS_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, WEIGHTS_IDX, COMPLEX_YES);
    ssSetDWorkName(         S, WEIGHTS_IDX, "Weights"); 


    if (cmplx) {
        ssSetDWorkWidth(        S, BUFF_IDX, 2*FrameSize);   /* length of complex FFT */
        ssSetDWorkDataType(     S, BUFF_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, BUFF_IDX, COMPLEX_YES);
        ssSetDWorkName(         S, BUFF_IDX, "Buffer"); 
    } 
}
#endif

#include "dsp_cplxhs11.c"

#include "dsp_trailer.c"
/* [EOF] sdspdct2.c */

