/*
 * SCOMVFDLY A SIMULINK variable fractional delay block.
 *
 * h is a "polyphase filter matrix", with one filter phase per column
 * - Each filter phase occupies one column of the polyphase matrix
 * - The first column contains the "0 delay" interpolation filter
 * - The number of columns is the number of intersample interpolation points.
 * - The number of rows is the order of the interpolator function.
 * - If h is empty, linear interpolation is used.
 *
 * maxDelay is the maximum sample delay to support.  If the requested delay
 * exceeds maxDelay, the maximum delay is substituted.
 *
 * If the requested delay time is less than half the interpolation filter length,
 * i.e., a small delay time, the algorithm falls back to linear interpolation.
 *         d < size(filt,1)/2
 *
 *  Copyright 1996-2004 The MathWorks, Inc.
 *  $Revision: 1.1.6.5 $  $Date: 2004/04/12 23:02:18 $
 */

/* The polyphase filter bank is generated in MATLAB by the
 * helper function commblkvfdly.m
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME scomvfdly

#include "simstruc.h"
#include "comm_defs.h"

/* --- Add the delay mode input to the argument list */
enum {ARGC_MAX_DELAY, ARGC_FILTERS, ARGC_IC, ARGC_CHANNELS, ARGC_DELAYMODE, NUM_ARGS};
#define DMAX_ARG  ssGetSFcnParam(S,ARGC_MAX_DELAY)
#define FILT_ARG  ssGetSFcnParam(S,ARGC_FILTERS)
#define IC_ARG	  ssGetSFcnParam(S,ARGC_IC)
#define CHANS_ARG ssGetSFcnParam(S,ARGC_CHANNELS)

/* --- Add the delay mode input definition*/
#define DELAYMODE_ARG ssGetSFcnParam(S,ARGC_DELAYMODE)

/* An invalid number of channels is used to flag channel-based operation */
const int_T SAMPLE_BASED = -1;

enum {InPort, DelayPort, INPORTS};
enum {OutPort, OUTPORTS};
enum {BufOffset, DiscState, NUM_DWORKS};

typedef struct {
    int_T nIC1, nIC2;
} SFcnCache;

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const int_T	    numDlyArg   = mxGetNumberOfElements(DMAX_ARG);
    const int_T	    numChanArg  = mxGetNumberOfElements(CHANS_ARG);
    const int_T	    numFiltArg  = mxGetNumberOfElements(FILT_ARG);
    const boolean_T runTime     = (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);

    /* Check filter: */
    if (runTime) {
        if (!mxIsEmpty(FILT_ARG) && (!mxIsDouble(FILT_ARG) || mxIsComplex(FILT_ARG))) {
            THROW_ERROR(S, "Interpolation filter must be a real double matrix");
        }
    }

    /* Check max delay: */
    if (runTime || numDlyArg >= 1) {
        int_T  i;
        real_T d;

        if (numDlyArg != 1) {
            THROW_ERROR(S, "Maximum delay must be a positive scalar integer");
        }

        d = mxGetPr(DMAX_ARG)[0];
        i = (int_T)d;
        if ((i != d) || (d<=0)) {
            THROW_ERROR(S, "Maximum delay must be a scalar integer > 0");
        }
    }

    if (runTime || numChanArg >= 1) {
        if (numChanArg != 1
            || (mxGetPr(CHANS_ARG)[0] < 1 && mxGetPr(CHANS_ARG)[0] != -1)
            || (int_T) mxGetPr(CHANS_ARG)[0] != mxGetPr(CHANS_ARG)[0]) {
            THROW_ERROR(S, "Number of channels should be a positive scalar integer. "
                         "If it is -1, the number of channels equals the port width");
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

    ssSetSFcnParamNotTunable(S, ARGC_MAX_DELAY);
    ssSetSFcnParamNotTunable(S, ARGC_IC);
    ssSetSFcnParamNotTunable(S, ARGC_FILTERS);
    ssSetSFcnParamNotTunable(S, ARGC_CHANNELS);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    if (!ssSetNumInputPorts(S, INPORTS)) return;

    ssSetInputPortComplexSignal(    S, InPort, COMPLEX_INHERITED);
    ssSetInputPortWidth(            S, InPort, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, InPort, 1); /* Zero delay is allowed */
    ssSetInputPortReusable(         S, InPort, 1);
    ssSetInputPortOverWritable(     S, InPort, 0);
    ssSetInputPortSampleTime(       S, InPort, INHERITED_SAMPLE_TIME);

    ssSetInputPortComplexSignal(    S, DelayPort, COMPLEX_NO);
    ssSetInputPortWidth(            S, DelayPort, DYNAMICALLY_SIZED);  /* UPDATE for frame-based */
    ssSetInputPortDirectFeedThrough(S, DelayPort, 1); /* Most recent delay value is used */
    ssSetInputPortReusable(         S, DelayPort, 1);
    ssSetInputPortOverWritable(     S, DelayPort, 0);
    ssSetInputPortSampleTime(       S, DelayPort, INHERITED_SAMPLE_TIME);

    if (!ssSetNumOutputPorts(S, OUTPORTS)) return;

    ssSetOutputPortWidth(        S, OutPort, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OutPort, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OutPort, 1);
    ssSetOutputPortSampleTime(   S, OutPort, INHERITED_SAMPLE_TIME);

    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetOptions(S, (SS_OPTION_EXCEPTION_FREE_CODE));
}


/* Set all ports to the identical, discrete rates: */
#ifdef COMMBLKS_SIM_SFCN
#include "dsp_ts_sim.h"
#else
#include "dsp_ts.c"
#endif
#include "dsp_ctrl_ts.c"


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    int_T       maxDly  = (int_T) mxGetPr(DMAX_ARG)[0];
    const int_T nDims   = mxGetNumberOfDimensions(IC_ARG);
    const int_T *dims   = mxGetDimensions(IC_ARG);
    int_T       nChans  = (int_T) mxGetPr(CHANS_ARG)[0];
    int_T       nIC1, nIC2, frame;

    /* --- Set the per-channel delay flag */
	const boolean_T delayMode  = (boolean_T)(mxGetPr(DELAYMODE_ARG)[0] != 0.0);

    /* --- Assign the delay width to a variable */
    int_T delayPortWidth    = ssGetInputPortWidth(S, DelayPort);

    SFcnCache *cache = (SFcnCache *)mxCalloc(1,sizeof(SFcnCache));
    if (cache == NULL) {
        THROW_ERROR(S, "Memory allocation failure");
    }

    /* prevent MATLAB from deallocating behind our backs */
    mexMakeMemoryPersistent(cache);
    ssSetUserData(S, cache);

    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
        ssSetErrorStatus(S,"Inputs to block must have discrete sample times");
        return;
    }

    if (nChans == SAMPLE_BASED) {
        nChans = ssGetInputPortWidth(S, InPort);
        frame = 1;
    } else {
        frame = ssGetInputPortWidth(S, InPort) / nChans;
    }

	/* --- Perform the width checks based upon the per-channel mode */
	if(delayMode) {
		if (nChans != delayPortWidth) {
			THROW_ERROR(S, "When using per-channel delay mode, the delay port width must equal the number of channels");
		}
	} else {
		if (delayPortWidth != frame) {
        THROW_ERROR(S,"The width of the delay port must equal the frame size");
		}
	}


    /* Valid initial conditions:
     * 1) An empty vector:          treated as zero.
     * 2) A single scalar:          scalar expanded.
     * 3) A vector:                 Number of elements must equal the number of channels.
     * 4) A 2-D matrix:             First dimension equal to the number of channels,
     *                              second dimension equal to the maximum delay.
     * 5) A 2-D matrix:             Product of dimensions equal to the number of channels.
     *                              Each matrix element is used for all delay elements
     *                              in one channel.
     * 6) A 3-D matrix:             The product of the first two dimensions must equal
     *                              the number of channels.  The third dimension must
     *                              equal the maximum delay.
     */
    if (!mxIsNumeric(IC_ARG)) {
        ssSetErrorStatus(S,"The initial conditions must be numeric.  No strings, cell arrays, etc");
        return;
    }
    if (nDims > 3) {
        ssSetErrorStatus(S,"The maximum dimensionality for the initial condition "
                        "matrix is three");
        return;
    }
    if (mxGetNumberOfElements(IC_ARG) <= 1) {  /* Single or empty IC, scalar expand */
        nIC1 = nIC2 = 1;
    } else if (dims[0]*dims[1] == nChans) { /* vector or 2-D matrix of IC's per time step */
        nIC1 = nChans;
        if (nDims < 3) nIC2 = 1;
        else {
            nIC2 = dims[2];  /* An array of IC's per time step */
            if (nIC2 != maxDly) {
                ssSetErrorStatus(S,"The third dimension of the IC's must equal the maximum delay");
                return;
            }
        }
    } else { /* Vector of IC's per time step.  Number of rows must equal nChans */
        nIC1 = dims[0];
        nIC2 = dims[1];
        if (nIC1 != nChans || nIC2 != maxDly) {
            if (nIC1 == 1 || nIC2 == 1) {
                ssSetErrorStatus(S, "For vector initial conditions, the number of elements must equal "
                    "one or the number of channels");
            } else {
                ssSetErrorStatus(S, "For array initial conditions, the last dimension of the matrix must "
                "be either one or the maximum delay.  The product of the preceding dimensions must "
                "equal the number of channels");
            }
            return;
        }
    }
    cache->nIC1 = nIC1;
    cache->nIC2 = nIC2;

    if (mxIsComplex(IC_ARG) && !ssGetInputPortComplexSignal(S, InPort)) {
        THROW_ERROR(S,"Use real initial conditions with real data");
    }
#endif
}

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const int_T     dmax        = (int_T) mxGetPr(DMAX_ARG)[0];
    const int_T     hlen        = mxGetM(FILT_ARG)/2;
    const int_T     buflen      = dmax + hlen + 1;
    int_T           *bufOffset  = (int_T *) ssGetDWork(S, BufOffset);
    const int_T     portWidth   = ssGetInputPortWidth(S, InPort);
    const int_T     nRows       = mxGetM(IC_ARG);
    const int_T     nCols       = mxGetN(IC_ARG);
    const int_T     nElems      = mxGetNumberOfElements(IC_ARG);
    int_T           nChans      = (int_T) *mxGetPr(CHANS_ARG);
    const int_T     nDims       = mxGetNumberOfDimensions(IC_ARG);
    const int_T     *dims       = mxGetDimensions(IC_ARG);
    const boolean_T cplx        = (ssGetInputPortComplexSignal(S, InPort) == COMPLEX_YES);
    SFcnCache       *cache      = ssGetUserData(S);
    int_T           nIC1        = cache->nIC1;
    int_T           nIC2        = cache->nIC2;
    int_T           i, j;

    *bufOffset = dmax + hlen - 1;
    if (nChans == SAMPLE_BASED) nChans = portWidth;

    if (nIC1*nIC2 == 1) { /* Use a single IC for all states */
        int_T numElements = ssGetDWorkWidth(S, DiscState);
        if (cplx) {
            creal_T *buff   = (creal_T *) ssGetDWork(S, DiscState);
            creal_T ic;

            ic.re = (mxGetPr(IC_ARG) == NULL) ? (real_T) 0.0 : mxGetPr(IC_ARG)[0];
            ic.im = (mxGetPi(IC_ARG) == NULL) ? (real_T) 0.0 : mxGetPi(IC_ARG)[0];

            for (j=0; j++ < numElements;    ) *buff++ = ic;

        } else {
            real_T  *buff   = (real_T *) ssGetDWork(S, DiscState);
            real_T  ic = (mxGetPr(IC_ARG) == NULL) ? (real_T) 0.0 : mxGetPr(IC_ARG)[0];
            for (j=0; j++ < numElements;    ) *buff++ = ic;
        }
    } else if (nIC2 == 1) { /* nIC1 == nChans */
        /* For each channel, use a single IC for every delay element */
        if (cplx) {
            creal_T *buff   = (creal_T *) ssGetDWork(S, DiscState);
            real_T  *re     = mxGetPr(IC_ARG);
            real_T  *im     = mxGetPi(IC_ARG);

            for (i=0; i < nChans; i++) {
                creal_T	ic;

                ic.re = *re++;
                ic.im = (im == NULL) ? (real_T) 0.0 : *im++;
                for (j=0; j++ < dmax;    ) *buff++ = ic;
                buff += (hlen + 1);
            }
        } else {
            real_T  *buff   = (real_T *) ssGetDWork(S, DiscState);
            real_T  *ic     = mxGetPr(IC_ARG);
            for (i=0; i < nChans; i++) {
                for (j=0; j++ < dmax;   ) *buff++ = *ic;
                ++ic;
                buff += (hlen + 1);
            }
        }
    } else { /* Matrix of IC's */

        if (cplx) {
            creal_T *buff   = (creal_T *) ssGetDWork(S, DiscState);

            for (i=0; i < nChans; i++) {
	        real_T  *re = mxGetPr(IC_ARG) + i;
                real_T  *im = mxGetPi(IC_ARG);
	        creal_T	ic;

                if (im != NULL) {
                    im = im + i;
                }

                for (j=0; j++ < dmax;    ) {
                    ic.re = *re;
                    ic.im = (im == NULL) ? (real_T) 0.0 : *im;
                    *buff++ = ic;
                    re += nChans;
                    im += (im == NULL ? 0 : nChans);
                }
                buff += (hlen + 1);
            }
        } else {
            real_T  *buff   = (real_T *) ssGetDWork(S, DiscState);
            for (i=0; i < nChans; i++) {
                real_T	*ic = mxGetPr(IC_ARG) + i;
                for (j=0; j++ < dmax;    ) {
                    *buff++ = *ic;
                    ic += nChans;
                }
                buff += (hlen + 1);
            }
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T portWidth   = ssGetInputPortWidth(S, InPort);  /* input signals */
    int_T       *bufOff	    = ssGetDWork(S, BufOffset);
    int_T       nChans      = (int_T)(mxGetPr(CHANS_ARG)[0]);
    const int_T hlen        = mxGetM(FILT_ARG)/2;
    const int_T dmax        = (int_T) mxGetPr(DMAX_ARG)[0];
    const int_T buflen      = dmax + hlen + 1;

    /* --- Set the per-channel delay flag */
	const boolean_T delayMode  = (boolean_T)(mxGetPr(DELAYMODE_ARG)[0] != 0.0);

    /* --- delayPort is not a constant */
    InputRealPtrsType delayPort = ssGetInputPortRealSignalPtrs(S, DelayPort);
    InputRealPtrsType	    dptr;

    int_T    i, k, ti, buffstart, frame;
    real_T   t;

    if (nChans == SAMPLE_BASED) { /* Channel mode */
        nChans = portWidth;
        frame = 1;
    } else {  /* Frame mode */
        frame = portWidth / nChans;
    }

    if (ssGetInputPortComplexSignal (S, InPort)) {
        /* Complex Data */

        /* Store new input samples: */
        InputPtrsType uptr   = ssGetInputPortSignalPtrs(S, InPort);
        creal_T      *buff   = (creal_T *) ssGetDWork(S, DiscState);
        creal_T	     *y      = (creal_T *) ssGetOutputPortSignal(S, OutPort);
        creal_T      *in_curr;

        for (i=0; i < nChans; i++) {   /* Get input samples */
            buffstart = *bufOff;

			/* --- Assign the delay port pointer according to the mode of operation */
			if(delayMode) {
				dptr = delayPort++;
			} else {
				dptr = delayPort;	/* Assigned later for each element in all channels */
			}

			/* --- Begin processing each element in each channel */
            for (k=0; k < frame; k++) {
                if (++buffstart == buflen) buffstart = 0;  /* Rotate circular buffer */
                *(buff + buffstart) = *((creal_T *) *uptr++);

				/* --- Assign the delay */
				if(delayMode) {
					t = **(dptr);	 /* This could be moved into the delay mode check outside of this loop */
				} else {
	                t = **(dptr++);  /* Get delay time from 2nd input port */
				}

                /* Output new interpolation point */
                in_curr = buff;
                /* Clip delay time to legal range: [0,dmax] */
                if (t < 0) t = 0;
                else if (t > dmax) t = dmax;
                ti = (int_T) t;         /* Integer part of delay time */

                /* Check if we need to use linear interp: */
                if (mxIsEmpty(FILT_ARG) || (ti < (hlen-1))) {
                    /* Linear interpolation: */
                    real_T frac  = t - ti;    /* Fractional part of delay time */
                    real_T frac1 = 1 - frac;

                    /* Add offset to current input pos'n in buffer, backing up by
                    * the integer number of delay samples.  If we've backed up too
                    * far past the start of the buffer, wrap to the end:
                    */
                    ti = buffstart - ti;
                    if (ti < 0) ti += buflen;
                    in_curr += ti; /* Get pointer into buffer */

                    if (ti > 0) {
                        /* The two points are adjacent in memory: */
                        y->re     = in_curr[0].re * frac1 + in_curr[-1].re * frac;
                        (y++)->im = in_curr[0].im * frac1 + in_curr[-1].im * frac;
                    } else {
                        /* The two points are at the end and start of buffer: */
                        y->re     = in_curr[0].re * frac1 + in_curr[buflen-1].re * frac;
                        (y++)->im = in_curr[0].im * frac1 + in_curr[buflen-1].im * frac;
                    }
                } else {
                    /* FIR Interpolation: */
                    const real_T frac  = t - ti;    /* Fractional part of delay time */
                    const int_T  filtlen = mxGetM(FILT_ARG);
                    const int_T  nphases = mxGetN(FILT_ARG);
                    int_T        phase   = (int_T) (nphases * frac + 0.5); /* [0,nphases] */

                    ti    += phase/nphases;
                    phase %= nphases;

                    /* Add offset to current input pos'n in buffer, backing up by the
                    * integer number of delay samples then incrementing by half the
                    * filter length.  If we've backed up too far past the start of the
                    * buffer, wrap:
                    */
                    ti = buffstart - ti + (hlen-1);

                    if (ti < 0) ti += buflen;
                    in_curr += ti; /* Get pointer into buffer */

                    if (ti+1 >= filtlen) {
                        /* Contiguous input samples in buffer: */
                        real_T *filt = mxGetPr(FILT_ARG) + phase*filtlen; /* Point to correct polyphase filter */
                        int_T   kn;
                        y->re = y->im = 0.0;
                        for(kn=0; kn<filtlen; kn++) {
                            y->re += in_curr[-kn].re * *filt;
                            y->im += in_curr[-kn].im * *filt++;
                        }
                        ++y;
                    } else {
                        /* Discontiguous input samples in buffer: */
                        real_T       *filt    = mxGetPr(FILT_ARG) + phase*filtlen;
                        const int_T   k1      = ti+1;
                        const int_T   k2      = filtlen-k1;
                        const creal_T *in_last = in_curr-ti+buflen-1;
                        int_T kn;

                        y->re = y->im = 0.0;
                        for(kn=0; kn<k1; kn++) {
                            y->re += in_curr[-kn].re * *filt;
                            y->im += in_curr[-kn].im * *filt++;
                        }
                        for(kn=0; kn<k2; kn++) {
                            y->re += in_last[-kn].re * *filt;
                            y->im += in_last[-kn].im * *filt++;
                        }
                        ++y;
                    }
                } /* FIR interpolation */
            } /* frame */
            buff += buflen;
        } /* channel */

    } else {
        /* Real Data */

        /* Store new input samples: */
        InputRealPtrsType   uptr    = ssGetInputPortRealSignalPtrs(S, InPort);
        real_T              *buff   = ssGetDWork(S, DiscState);
        real_T              *y      = ssGetOutputPortRealSignal(S, OutPort);
        real_T              *in_curr;

        for (i=0; i < nChans; i++) {   /* Get input samples */
            buffstart = *bufOff;

			/* --- Assign the delay port pointer according to the mode of operation */
			if(delayMode) {
				dptr = delayPort++;
			} else {
				dptr = delayPort;	/* Assigned later for each element in all channels */
			}

            for (k=0; k < frame; k++) {
                if (++buffstart == buflen) buffstart = 0;  /* Rotate circular buffer */
                *(buff + buffstart) = **uptr++;

				/* --- Assign the delay */
				if(delayMode) {
					t = **(dptr);	 /* This could be moved into the delay mode check outside of this loop */
				} else {
	                t = **(dptr++);  /* Get delay time from 2nd input port */
				}

                /* Output new interpolation point */
                in_curr = buff;
                /* Clip delay time to legal range: [0,dmax] */
                if (t < 0) t = 0;
                else if (t > dmax) t = dmax;
                ti = (int_T) t;         /* Integer part of delay time */

                /* Check if we need to use linear interp: */
                if (mxIsEmpty(FILT_ARG) || (ti < (hlen-1))) {
                    /* Linear interpolation: */
                    real_T frac  = t - ti;    /* Fractional part of delay time */
                    real_T frac1 = 1 - frac;

                    /* Add offset to current input pos'n in buffer, backing up by
                    * the integer number of delay samples.  If we've backed up too
                    * far past the start of the buffer, wrap to the end:
                    */
                    ti = buffstart - ti;
                    if (ti < 0) ti += buflen;
                    in_curr += ti; /* Get pointer into buffer */

                    if (ti > 0) {
                        /* The two points are adjacent in memory: */
                        *y++ = in_curr[0]*frac1 + in_curr[-1]*frac;
                    } else {
                        /* The two points are at the end and start of buffer: */
                        *y++ = in_curr[0]*frac1 + in_curr[buflen-1]*frac;
                    }
                } else {
                    /* FIR Interpolation: */
                    const real_T    frac    = t - ti;    /* Fractional part of delay time */
                    const int_T     filtlen = mxGetM(FILT_ARG);
                    const int_T     nphases = mxGetN(FILT_ARG);
                    int_T           phase   = (int_T) (nphases * frac + 0.5); /* [0,nphases] */

                    if (phase == nphases) { ++ti; phase = 0; }

                    /* Add offset to current input pos'n in buffer, backing up by the
                    * integer number of delay samples then incrementing by half the
                    * filter length.  If we've backed up too far past the start of the
                    * buffer, wrap:
                    */
                    ti = buffstart - ti + (hlen-1);

                    if (ti < 0) ti += buflen;
                    in_curr += ti; /* Get pointer into buffer */

                    if (ti+1 >= filtlen) {
                        /* Contiguous input samples in buffer: */
                        /* Point to correct polyphase filter */
                        real_T  *filt   = mxGetPr(FILT_ARG) + phase*filtlen;
                        int_T   kn;
                        *y = 0.0;
                        for(kn=0; kn<filtlen; kn++) {
                            *y += in_curr[-kn] * *filt++;
                        }
                        ++y;
                    } else {
                        /* Discontiguous input samples in buffer: */
                        real_T  *filt   = mxGetPr(FILT_ARG) + phase*filtlen;
                        const int_T   k1      = ti+1;
                        const int_T   k2      = filtlen-k1;
                        const real_T *in_last = in_curr-ti+buflen-1;
                        int_T kn;

                        *y = 0.0;
                        for(kn=0; kn<k1; kn++) {
                            *y += in_curr[-kn] * *filt++;
                        }
                        for(kn=0; kn<k2; kn++) {
                            *y += in_last[-kn] * *filt++;
                        }
                        ++y;
                    }
                } /* FIR interpolation */
            } /* frame */
            buff += buflen;
        } /* channel */
    }
    *bufOff += frame;
    while (*bufOff >= buflen) *bufOff -= buflen;
}


static void mdlTerminate(SimStruct *S)
{
    SFcnCache *cache = (SFcnCache *)ssGetUserData(S);
    if (cache != NULL) {
        mxFree(cache);
    }
}


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    /*
     * Extend buffer to allow delays up to DMAX without
     * having to fall back to linear interpolation.
     */
    const int_T hlen        = mxGetM(FILT_ARG)/2;
    const int_T dmax        = (int_T) mxGetPr(DMAX_ARG)[0];
    const int_T portWidth   = ssGetInputPortWidth(S, InPort);
    int_T       nChans      = (int_T) *mxGetPr(CHANS_ARG);

    if (nChans == SAMPLE_BASED) nChans = portWidth;

    if(!ssSetNumDWork( S, NUM_DWORKS)) return;

    ssSetDWorkWidth(   S, BufOffset, 1);
    ssSetDWorkDataType(S, BufOffset, SS_INT32);

     ssSetDWorkWidth(S, DiscState, (dmax+1 + hlen) * nChans );
    if (ssGetInputPortComplexSignal(S, InPort) == COMPLEX_YES) {
        ssSetDWorkComplexSignal(S, DiscState, COMPLEX_YES);
    }
}


#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    int_T outputPortWidth   = ssGetOutputPortWidth(S, port);
    int_T delayPortWidth    = ssGetInputPortWidth(S, DelayPort);
    int_T nChans            = (int_T) *mxGetPr(CHANS_ARG);
	int_T frame;

    /* --- Set the per-channel delay flag */
	const boolean_T delayMode  = (boolean_T)(mxGetPr(DELAYMODE_ARG)[0] != 0.0);


    if (port == InPort) {
        if (nChans != SAMPLE_BASED && (inputPortWidth % nChans) != 0) {
            THROW_ERROR(S, "Input port width must be a multiple of the number of channels");
        }
        if (nChans == SAMPLE_BASED) {
            nChans = inputPortWidth;
            frame = 1;
        } else {
            frame = inputPortWidth / nChans;
        }

        ssSetInputPortWidth (S, port, inputPortWidth);
        if (outputPortWidth == -1) {
            ssSetOutputPortWidth(S, port, inputPortWidth);

        } else if (ssGetOutputPortWidth(S, port) != inputPortWidth) {
            THROW_ERROR(S, "Input/Output port pairs must have the same width");
        }


		/* --- If this is not in the per-channel model, we can set the port width if required*/
		if(!delayMode) {
			if(delayPortWidth == -1) {
		        ssSetInputPortWidth (S, DelayPort, frame);
			} else {
				if (delayPortWidth != frame) {
					THROW_ERROR(S, "Delay port width must equal the frame size");
				}

			}

		}
    } else if (port == DelayPort) {
        ssSetInputPortWidth (S, port, inputPortWidth);

		if(delayMode) {
			if (nChans != inputPortWidth) {
				THROW_ERROR(S, "When using per-channel delay mode, the delay port width must equal the number of channels");
			}
		}

	}
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    int_T inputPortWidth    = ssGetInputPortWidth(S, port);
    int_T delayPortWidth    = ssGetInputPortWidth(S, DelayPort);
    int_T nChans            = (int_T) mxGetPr(CHANS_ARG)[0];
    int_T frame;

    /* --- Set the per-channel delay flag */
	const boolean_T delayMode  = (boolean_T)(mxGetPr(DELAYMODE_ARG)[0] != 0.0);

    if (nChans != SAMPLE_BASED && (outputPortWidth % nChans) != 0) {
        THROW_ERROR(S, "Output port width must be a multiple of the number of channels");
    }

    if (nChans == SAMPLE_BASED) {
        nChans = outputPortWidth;
        frame = 1;
    } else {
        frame = outputPortWidth / nChans;
    }

    ssSetOutputPortWidth (S, port, outputPortWidth);
    if (inputPortWidth == -1) {
        ssSetInputPortWidth(S, port, outputPortWidth);

    } else if (ssGetInputPortWidth(S, port) != outputPortWidth) {
        THROW_ERROR(S, "Input/Output port pairs must have the same width");
    }


	/* --- If this is not in the per-channel model, we can set the input port width if required*/
	if(!delayMode) {
		if(delayPortWidth == -1) {
		    ssSetInputPortWidth (S, DelayPort, frame);
		} else {
			if (delayPortWidth != frame) {
				THROW_ERROR(S, "Delay port width must equal the frame size");
			}

		}
	}


}

/* Port complexity handshake */
#include "dsp_cplxhs11.c"

#endif


#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] scomvfdly.c */
