/*
 * SDSPINVDCT  IDCT S-function.
 * DSP Blockset S-Function to perform an IDCT.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.24 $  $Date: 2002/12/23 22:25:06 $
 */
#define S_FUNCTION_NAME sdspinvdct
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"
#include "dspfft_rt.h"

enum {INPORT=0, NUM_INPORTS}; 
enum {OUTPORT=0, NUM_OUTPORTS}; 
enum {NCHANS_ARGC=0, NUM_ARGS};
enum {WEIGHTS_IDX=0, BUFF_IDX, NUM_DWORK};

#define NCHANS_ARG (ssGetSFcnParam(S,NCHANS_ARGC))

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /* Number of channels */
    if (OK_TO_CHECK_VAR(S, NCHANS_ARG)) {
        if (!IS_FLINT_GE(NCHANS_ARG, 1)) {
            THROW_ERROR(S, "Number of channels must be a scalar integer > 0.");
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

	/* Parameters */
    ssSetSFcnParamNotTunable(S, NCHANS_ARGC);

    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 0);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    /* DWorks: */
    if(!ssSetNumDWork(  S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE );
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
    const int_T   nChans    = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T   FrameSize = ssGetInputPortWidth(S,INPORT) / nChans;
	const real_T  piN2      = 2.0*atan(1.0)/FrameSize;

    const boolean_T c0 = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);

    real_T        fac  = (c0) ? sqrt(2*FrameSize) : sqrt(2*FrameSize)/FrameSize;
    creal_T      *ww   = (creal_T *)ssGetDWork(S, WEIGHTS_IDX);
    int_T         i;

#ifdef MATLAB_MEX_FILE
    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for IDCT block.");
    }
    
    /* Check to make sure input size is a power of 2: */
    if (frexp((real_T)FrameSize, &i) != 0.5) {
        THROW_ERROR(S,"Width of input to IDCT must be a power of 2");
    }
    if (FrameSize == 1) {
      mexWarnMsgTxt("Computing the IDCT of a scalar input.\n");
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
        ww[i].re = cos(i*piN2) * fac;
        ww[i].im = sin(i*piN2) * fac;
    }

    if (!c0){
        ww[0].re /= sqrt(2.0);
    } else {
        ww[0].re *= sqrt(2.0);
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T c0 = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    const int_T     nChans    = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T     FrameSize = ssGetInputPortWidth(S,INPORT) / nChans;
	      int_T     ch;

	if (!c0) { /* REAL Input */

        InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT);
        real_T           *y    = ssGetOutputPortRealSignal(S,OUTPORT);


        if (FrameSize == 1) {
			for(ch=0; ch<nChans; ch++) {
                *y++ = **uptr++;
			}
            
		} else {
            const int_T  N2   = FrameSize/2; /* length of complex FFT       */
            int_T        i;

			for(ch=0; ch<nChans; ch++) {
				creal_T *ww   = ssGetDWork(S, WEIGHTS_IDX);
				creal_T *buff = ssGetDWork(S, BUFF_IDX);
				
				/* Multipy by weights */
				for (i = 0; i< FrameSize; i++) {
					buff[i].re =   **uptr * ww->re;
					buff[i].im = -(**uptr++ * (ww++)->im);
				}
				
                MWDSP_R2BR_Z(buff, 1, FrameSize, FrameSize);
                MWDSP_R2DIT_TRIG_Z(buff, 1, FrameSize, FrameSize, 0);
				
				for (i=0; i<N2; i++) {
					*y++ = buff[i].re;
					*y++ = buff[FrameSize-1-i].re;
				}
			}
        }

    } else {  /* COMPLEX Input */

        InputPtrsType uptr = ssGetInputPortSignalPtrs(S, INPORT);
        creal_T      *y    = (creal_T *)ssGetOutputPortRealSignal(S,OUTPORT);

		for(ch=0; ch<nChans; ch++) {
			
			creal_T      *ww   = (creal_T *)ssGetDWork(S, WEIGHTS_IDX);
			creal_T      *buff = (creal_T *)ssGetDWork(S, BUFF_IDX);
			int_T         i;
			
			/* Multiply by weights */
			for (i = 0; i< FrameSize; i++) {
				const creal_T *u = (creal_T *)uptr[i];
				buff[i].re = CMULT_RE(*u,ww[i]);
				buff[i].im = CMULT_IM(*u,ww[i]);
			}
			
			buff[FrameSize].re = 0.0;
			buff[FrameSize].im = 0.0;
			
			for(i = 1; i < FrameSize; i++) {
				const creal_T *u = (creal_T *)uptr[FrameSize-i];
				buff[FrameSize+i].re = CMULT_IM(*u, ww[i]);
				buff[FrameSize+i].im = -CMULT_XYCONJ_RE(*u, ww[i]);
			}
			
            MWDSP_R2BR_Z(buff, 1, 2*FrameSize, 2*FrameSize);
            MWDSP_R2DIT_TRIG_Z(buff, 1, 2*FrameSize, 2*FrameSize, 1);
            MWDSP_ScaleData_DZ(buff, 2*FrameSize, 1.0 / (2*FrameSize));
			
			for(i=0; i<FrameSize; i++) {
				*y++ = *buff++;
			}

			uptr += FrameSize;  /* Move to next channel input */

		} /* for(nChans) */
	}
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const boolean_T c0 = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    const int_T     nChans    = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T     FrameSize = ssGetInputPortWidth(S,INPORT) / nChans;

    if(!ssSetNumDWork(      S, NUM_DWORK)) return;

    ssSetDWorkWidth(        S, WEIGHTS_IDX, FrameSize);
    ssSetDWorkDataType(     S, WEIGHTS_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, WEIGHTS_IDX, COMPLEX_YES);

    ssSetDWorkWidth(        S, BUFF_IDX, (c0) ? 2*FrameSize : FrameSize); /* Length of IFFT */
    ssSetDWorkDataType(     S, BUFF_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, BUFF_IDX, COMPLEX_YES);
}
#endif

#include "dsp_cplxhs11.c"

#include "dsp_trailer.c"

/* [EOF] sdspinvdct.c */

