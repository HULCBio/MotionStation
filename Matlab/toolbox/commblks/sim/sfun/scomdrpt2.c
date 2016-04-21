/*
 * SCOMDRPT2  S-function which decreases the sampling rate
 *            of a signal by derepeating by an integer factor.
 *
 *  Copyright 1996-2004 The MathWorks, Inc.
 *  $Revision: 1.9.4.6 $  $Date: 2004/04/12 23:03:22 $
 */

#define S_FUNCTION_NAME scomdrpt2
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "simstruc.h"

#include "comm_defs.h"


enum {COUNT_IDX=0, BUFF_IDX, NUM_DWORKS};
enum {OUTBUF_PTR=0, INBUF_PTR, NUM_PWORKS};

enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

enum {CONVFACTOR_ARGC=0, IC_ARGREC, IC_ARGIMC, OUTMODE_ARGC, NUM_ARGS};

#define CONVFACTOR_ARG   ssGetSFcnParam(S, CONVFACTOR_ARGC)
#define IC_ARGRE         ssGetSFcnParam(S, IC_ARGREC)
#define IC_ARGIM         ssGetSFcnParam(S, IC_ARGIMC)
#define OUTMODE_ARG      ssGetSFcnParam(S, OUTMODE_ARGC)


typedef enum {
    fcnEqualSizes = 1,
    fcnEqualRates
} FcnType;


boolean_T isInputMultiRate1(SimStruct *S, int_T numIn)
{
    if (numIn < 1) return(false);
    {
        /* Compare all input ports */
        const real_T inTs_old = ssGetInputPortSampleTime(S, 0);
        int_T idx;

        for (idx = 1; idx < numIn; idx++) {
            const real_T inTs_new = ssGetInputPortSampleTime(S, idx);
            if (inTs_old != inTs_new) {
                return(true);
            }
        }
        return(false);
    }
}


boolean_T isOutputMultiRate1(SimStruct *S, int_T numOut)
{
    if (numOut < 1) return(false);
    {
        /* Compare all output ports */
        const real_T outTs_old = ssGetOutputPortSampleTime(S, 0);
        int_T idx;

        for (idx = 1; idx < numOut; idx++) {
            const real_T outTs_new = ssGetOutputPortSampleTime(S, idx);
            if (outTs_old != outTs_new) {
                return(true);
            }
        }
        return(false);
    }
}


boolean_T isBlockMultiRate1(
    SimStruct *S, 
    int_T numIn, 
    int_T numOut)
{
    return((boolean_T)(isInputMultiRate1(S,numIn)
           || isOutputMultiRate1(S,numOut)
           || (ssGetInputPortSampleTime(S, 0) != ssGetOutputPortSampleTime(S, 0)) ));
}



#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    static char *msg;
    real_T convfactor_dbl;
    int_T  convfactor_int;

    /* Derepreat factor */
    if (OK_TO_CHECK_VAR(S, CONVFACTOR_ARG)) {
        if (mxGetNumberOfElements(CONVFACTOR_ARG) != 1) {
            	THROW_ERROR(S,"Derepeat factor must be a scalar.");
        }

        convfactor_dbl = mxGetPr(CONVFACTOR_ARG)[0];
        convfactor_int = (int_T)convfactor_dbl;
        if ( (convfactor_dbl != convfactor_int) || (convfactor_dbl <= (real_T)0.0) ) {
  	          THROW_ERROR(S,"Derepeat factor must be an integer greater than 0.");
        }
    }

    /* Initial conditions (Real Part): */
    if (OK_TO_CHECK_VAR(S, IC_ARGRE)) {
        if (!mxIsNumeric(IC_ARGRE) || mxIsSparse(IC_ARGRE) ) {
            THROW_ERROR(S,"Initial conditions must be numeric.");
        }
    }

	/* Initial conditions: (Imaginary Part) */
    if (OK_TO_CHECK_VAR(S, IC_ARGIM)) {
        if (!mxIsNumeric(IC_ARGIM) || mxIsSparse(IC_ARGIM) ) {
            THROW_ERROR(S,"Initial conditions must be numeric.");
        }
    }

    /* Function Mode */
    if ( !mxIsDouble(OUTMODE_ARG)                  ||
         (mxGetNumberOfElements(OUTMODE_ARG) != 1) ||
         ((mxGetPr(OUTMODE_ARG)[0] < 0.0)  &&
          (mxGetPr(OUTMODE_ARG)[0] > 1.0))
       ) {
	        THROW_ERROR(S,"Output mode must be a scalar in the range [0,1].");
    }

}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != NUM_ARGS) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* All parameters are nontunable */
    ssSetSFcnParamNotTunable(S, CONVFACTOR_ARGC);
    ssSetSFcnParamNotTunable(S, IC_ARGREC);
	ssSetSFcnParamNotTunable(S, IC_ARGIMC);
    ssSetSFcnParamNotTunable(S, OUTMODE_ARGC);

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(	S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         	S, INPORT, FRAME_INHERITED);
    ssSetInputPortComplexSignal(    	S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(	S, INPORT, 1);
    ssSetInputPortReusable(         	S, INPORT, 0);
    ssSetInputPortOverWritable(     	S, INPORT, 0);
	ssSetInputPortRequiredContiguous(	S, INPORT, 1);

    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    if (!ssSetOutputPortDimensionInfo(	S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         	S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(		S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     		S, OUTPORT, 0);

    /* Set up inport/outport sample times: */
    ssSetNumSampleTimes(      S, PORT_BASED_SAMPLE_TIMES);
    ssSetInputPortSampleTime( S, INPORT, INHERITED_SAMPLE_TIME);
    ssSetOutputPortSampleTime(S, OUTPORT, INHERITED_SAMPLE_TIME);

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    ssSetNumPWork(S, DYNAMICALLY_SIZED);

    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE         |
                     SS_OPTION_CAN_BE_CALLED_CONDITIONALLY );
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    if (sampleTime == CONTINUOUS_SAMPLE_TIME)  {
       THROW_ERROR(S,"Continuous sample times not allowed for derepeat blocks.");
    }

    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed.");
    }

    ssSetInputPortSampleTime(S, INPORT, sampleTime);
    ssSetInputPortOffsetTime(S, INPORT, offsetTime);

    /* Set output port sample time: */
    {
        const boolean_T frameBased = (boolean_T)(ssGetInputPortFrameData(S,INPORT)==FRAME_YES);
        const FcnType ftype    = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
        const int_T convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
        const real_T  Tso      = ((frameBased) && (ftype == fcnEqualRates))
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
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
       THROW_ERROR(S,"Continuous sample times not allowed for derepeat blocks.");
    }

    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed.");
    }

    ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
    ssSetOutputPortOffsetTime(S, OUTPORT, offsetTime);

    /* Set input port sample time: */
    {
        const boolean_T frameBased = (boolean_T)(ssGetInputPortFrameData(S,INPORT)==FRAME_YES);
        const FcnType ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
        const int_T   convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
        const real_T  Tsi        = ((frameBased) && (ftype == fcnEqualRates)) ? sampleTime
                                                                                     : sampleTime/convfactor;

        ssSetInputPortSampleTime(S, INPORT, Tsi);
    }
    ssSetInputPortOffsetTime(S, INPORT, 0.0);
}
#endif


static void mdlInitializeSampleTimes(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    /* Check port sample times: */
    const real_T Tsi = ssGetInputPortSampleTime(S, INPORT);
    const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);

    if ((Tsi == INHERITED_SAMPLE_TIME)  ||
        (Tso == INHERITED_SAMPLE_TIME)   ) {
        THROW_ERROR(S,"Sample time propagation failed for derepeat block.");
    }
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);

#endif
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const boolean_T frameBased = (boolean_T)(ssGetInputPortFrameData(S,INPORT)==FRAME_YES);
    const FcnType     ftype    = (FcnType)((int_T)(mxGetPr(OUTMODE_ARG)[0]));
    const int_T     convfactor = (int_T)(mxGetPr(CONVFACTOR_ARG)[0]);

    if(!frameBased && (ftype == fcnEqualRates) && (convfactor != 1) ) {
        THROW_ERROR(S,"Cannot maintain input rate for sample-based data.");
    }
#endif
}

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const boolean_T isMultiRate = isBlockMultiRate1(S,INPORT,OUTPORT);
    const boolean_T cplx       = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);

    const int_T     outWidth   = ssGetOutputPortWidth(S, OUTPORT);
    const int_T     convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);

    /* Latency (ICs) is required for all multi-rate modes  */
    const boolean_T  needICs  = isMultiRate;

    /* Reset counter */
    *((int32_T *)ssGetDWork(S, COUNT_IDX)) = 0;

	/* Set the first PWork for all modes */
	if (!cplx) {
		real_T  *outBuf = (real_T *)ssGetDWork(S, BUFF_IDX);
		ssSetPWorkValue(S, OUTBUF_PTR, outBuf);
	} else {
		creal_T *outBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);
		ssSetPWorkValue(S, OUTBUF_PTR, outBuf);
	}


    if (needICs) {
        /* Initialize buffer for modes that require ICs */

	    const int_T     numIC      = mxGetNumberOfElements(IC_ARGRE);

        if (!cplx) {
            /* Real input */
            real_T *pIC    = (real_T *)mxGetPr(IC_ARGRE);
            real_T *outBuf = (real_T *)ssGetDWork(S, BUFF_IDX);

            /* Set the second PWork */
			ssSetPWorkValue(S, INBUF_PTR,  outBuf + outWidth);

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
			real_T          *prIC    = (real_T *)mxGetPr(IC_ARGRE);
			real_T          *piIC    = (real_T *)mxGetPr(IC_ARGIM);
            creal_T         *outBuf  = (creal_T *)ssGetDWork(S, BUFF_IDX);
            const boolean_T  ic_cplx = (boolean_T)(piIC != NULL);
            int_T            i;

            /* Set the second PWork */
            ssSetPWorkValue(S, INBUF_PTR,  outBuf + outWidth);

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
    const boolean_T isMultiRate = isBlockMultiRate1(S,INPORT,OUTPORT);

    const int_T OutportTid = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    const int_T InportTid  = ssGetInputPortSampleTimeIndex(S, INPORT);

    const boolean_T  cplx                  = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    int32_T          *counter              = (int32_T *)ssGetDWork(S, COUNT_IDX);
    const int_T      convfactor            = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
    const boolean_T  isInputFrameBased     = (boolean_T)(ssGetInputPortFrameData(S,INPORT)==FRAME_YES);
    const int_T      inWidth               = ssGetInputPortWidth(S, INPORT);
    const int_T      outWidth              = ssGetOutputPortWidth(S, OUTPORT);
    const int_T      *inDims			   = ssGetInputPortDimensions(S, INPORT);
    const int_T      inCols 			   = inDims[1];
    const int_T      nChans                = (isInputFrameBased) ? inCols : inWidth;
    const int_T      SamplesPerInputFrame  = inWidth/nChans;
    int_T n;
    int_T c;

    /* Latency (ICs) is required for all multi-rate modes */
    const boolean_T  needICs  = isMultiRate;

    if (!needICs) {
        if (!cplx) {
            /* Real input */
            real_T          *y      =           ssGetOutputPortRealSignal(S, OUTPORT);
            real_T  		*uptr   = (real_T *)ssGetInputPortRealSignal(S,INPORT);
            real_T          *outBuf = (real_T *)ssGetPWorkValue(S, OUTBUF_PTR);

            for (n = 0; n < nChans; n++) {
                int_T i;
                c = *counter; /* Reset counter for each channel */

                for (i=0; i<SamplesPerInputFrame; i++) {
					if (c++ == 0) *outBuf = *uptr++;
					else *outBuf += *uptr++;
					if (c == convfactor) {
						c = 0;
						*y++ = *outBuf/convfactor;
					}
				}
				outBuf++;
            }
            *counter = c; /* Update counter for next sample hit */

			{
				real_T *aBuf = (real_T *)ssGetDWork(S, BUFF_IDX);
				if (outBuf == aBuf + outWidth) {
					outBuf = aBuf;
				}
				ssSetPWorkValue(S, OUTBUF_PTR, outBuf);
			}
        } else {
            /* Complex input */
            creal_T       *y      = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
			creal_T		  *uptr   = (creal_T *)ssGetInputPortSignal(S,INPORT);
            creal_T       *outBuf = (creal_T *)ssGetPWorkValue(S, OUTBUF_PTR);

            for (n = 0; n < nChans; n++) {
                int_T i;
                c = *counter; /* Reset counter for each channel */

                for (i=0; i<SamplesPerInputFrame; i++) {
                    if (c++ == 0) {
						*outBuf = *uptr;
					} else {
						outBuf->re += uptr->re;
						outBuf->im += uptr->im;
					}
					if (c == convfactor) {
						c = 0;
						y->re = outBuf->re/convfactor;
						y++->im = outBuf->im/convfactor;
					}
					*uptr++;
                }
				outBuf++;
            }
            *counter = c; /* Update counter for next sample hit */
			{
				creal_T *aBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);
				if (outBuf == aBuf + outWidth) {
					outBuf = aBuf ;
				}
				ssSetPWorkValue(S, OUTBUF_PTR, outBuf);
			}
        }

    } else {

		if (ssIsSampleHit(S, OutportTid, tid)) {
			const int_T     outWidth = ssGetOutputPortWidth(S, OUTPORT);

			if (!cplx) {
				/* Real */
				real_T *y      =           ssGetOutputPortRealSignal(S, OUTPORT);
				real_T *outBuf = (real_T *)ssGetPWorkValue(S, OUTBUF_PTR);
				int_T   i      =           outWidth;

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
				int_T    i      =            outWidth;

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
					real_T  		*uptr  = (real_T *)ssGetInputPortRealSignal(S,INPORT);
					real_T          *inBuf;

					for (n = 0; n < nChans; n++) {
						int_T   i;

						 /* Point to current channel */
						inBuf = (real_T *)ssGetPWorkValue(S, INBUF_PTR) + n*SamplesPerInputFrame;

						c = *counter; /* Reset counter for each channel */

						for (i=0; i<SamplesPerInputFrame; i++) {
							if (c++ == 0) *inBuf = *uptr++;
							else *inBuf += *uptr++;
							if (c == convfactor) {
								c = 0;
								*inBuf++ /= convfactor;
							}
						}
					}
					*counter = c; /* Update counter for next sample hit */

					{
						real_T *aBuf = (real_T *)ssGetDWork(S, BUFF_IDX);

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
					creal_T		   *uptr   = (creal_T *)ssGetInputPortSignal(S,INPORT);
					creal_T        *inBuf  = (creal_T *)ssGetPWorkValue(S, INBUF_PTR);

					for (n = 0; n < nChans; n++) {
						int_T   i;

						 /* Point to current channel */
						inBuf = (creal_T *)ssGetPWorkValue(S, INBUF_PTR) + n*SamplesPerInputFrame;

						c = *counter; /* Reset counter for each channel */

						for (i=0; i<SamplesPerInputFrame; i++) {
							if (c++ == 0) {
								*inBuf = *uptr;
							} else {
								inBuf->re += uptr->re;
								inBuf->im += uptr->im;
							}

							if (c == convfactor) {
								c = 0;
								inBuf->re /= convfactor;
								inBuf++->im /= convfactor;
							}
							*uptr++;
						}
					}
					*counter = c; /* Update counter for next sample hit */

					{
						creal_T *aBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);

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
					real_T 			*uptr  = (real_T *)ssGetInputPortRealSignal(S, INPORT);
					real_T          *inBuf = (real_T *)ssGetPWorkValue(S, INBUF_PTR);

					for (n = 0; n < nChans; n++) {
						int_T   i;

						c = *counter; /* Reset counter for each channel */

						for (i=0; i<SamplesPerInputFrame; i++) {
							if (c++ == 0) *inBuf = *uptr++;
							else *inBuf += *uptr++;

							if (c == convfactor) {
								*inBuf /= convfactor;
								c = 0;
							}
						}
						inBuf++;
					}

					*counter = c; /* Update counter for next sample hit */

					{
						real_T *aBuf = (real_T *)ssGetDWork(S, BUFF_IDX);
						if (c == 0) {
							if (inBuf == aBuf + 2*outWidth) inBuf = aBuf;
						} else {
							if (inBuf == aBuf + outWidth) inBuf = aBuf;
							if (inBuf == aBuf + 2*outWidth) inBuf = aBuf + outWidth;
						}
						ssSetPWorkValue(S, INBUF_PTR, inBuf);
					}


				} else {
					/* Complex input */

					creal_T   		*uptr  = (creal_T *)ssGetInputPortSignal(S, INPORT);
					creal_T         *inBuf = (creal_T *)ssGetPWorkValue(S, INBUF_PTR);

					for (n = 0; n < nChans; n++) {
						int_T   i;
						c = *counter; /* Reset counter for each channel */

						for (i=0; i<SamplesPerInputFrame; i++) {
							if (c++ == 0) {
								*inBuf = *uptr;
							} else {
								inBuf->re += uptr->re;
								inBuf->im += uptr->im;
							}
							if (c == convfactor) {
								c = 0;
								inBuf->re /= convfactor;
								inBuf->im /= convfactor;
							}
							*uptr++;
						}
						inBuf++;
					}

					*counter = c; /* Update counter for next sample hit */

					{
						creal_T *aBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);
						if (c == 0) {
							if (inBuf == aBuf + 2*outWidth) inBuf = aBuf;
						} else {
							if (inBuf == aBuf + outWidth) inBuf = aBuf;
							if (inBuf == aBuf + 2*outWidth) inBuf = aBuf + outWidth;
						}
						ssSetPWorkValue(S, INBUF_PTR, inBuf);
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
    const boolean_T isMultiRate = isBlockMultiRate1(S,INPORT,OUTPORT);

    const FcnType   ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
    const int_T     convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
    const int_T     outWidth   = ssGetOutputPortWidth(S, OUTPORT);
    const CSignal_T cplx       = ssGetInputPortComplexSignal(S, INPORT);

    /* Latency (ICs) is required for all multi-rate modes     */
    const boolean_T  needICs  = isMultiRate;

	boolean_T  cplx_ic = 0;
	int_T      i = 0;

	real_T *ic_pi = mxGetPr(IC_ARGIM);

    /* Set PWorks and DWorks: */
	if (!ssSetNumDWork(S, NUM_DWORKS)) return;         /* Counter and ICs */
    ssSetNumPWork(S, NUM_PWORKS);

    /* Counter */
    ssSetDWorkWidth(        S, COUNT_IDX, 1);
    ssSetDWorkDataType(     S, COUNT_IDX, SS_INT32);
    ssSetDWorkComplexSignal(S, COUNT_IDX, COMPLEX_NO);
    ssSetDWorkName(         S, COUNT_IDX, "Count");
    ssSetDWorkUsedAsDState( S, COUNT_IDX, 1);

    /* Buffer */
    ssSetDWorkWidth(        S, BUFF_IDX, (outWidth * ( needICs ? 2 : 1)));
    ssSetDWorkDataType(     S, BUFF_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, BUFF_IDX, cplx ? COMPLEX_YES : COMPLEX_NO);
    ssSetDWorkName(         S, BUFF_IDX, "Buffer");
    ssSetDWorkUsedAsDState( S, BUFF_IDX, 1);

    if (needICs) {
        /* IC checking */
        {
            const int_T numIC   = mxGetNumberOfElements(IC_ARGRE);
            const int_T inWidth = ssGetInputPortWidth(S, INPORT);

            /* We need to make sure the IC vector is not bigger than our output width
             * because we are allocating the dwork storage based on the output width.
             * The output width can be smaller than the input width when the mode is
             * set to "equal rates" and the derepeat factor is greater than one.
             */
            if ((numIC != 0) && (numIC != 1) && (numIC != outWidth)) {
                THROW_ERROR(S, "Initial condition vector does not match output dimensions.");
            }

			/* Determine if Initial Condition is complex */
			for (i = 0; i < numIC; i++)
			{
				cplx_ic = cplx_ic || mxGetPr(IC_ARGIM)[i];
			}

			if ((cplx == COMPLEX_NO) && cplx_ic) {
	        	THROW_ERROR(S, "Complex initial conditions are not allowed with real inputs.");
            }
        }
    }
}


#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port,
                                      const DimsInfo_T *dimsInfo)
{
	int_T outRows = 0;
	int_T outCols = 0;

    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    if(ssGetInputPortConnected(S,INPORT)) {

        /* Block parameters */
	   const FcnType ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
	   const int_T   convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);

        /* Port info */
        const boolean_T frameBased = (boolean_T)ssGetInputPortFrameData(S,INPORT);
        const int_T     inCols     = dimsInfo->dims[1];
        const int_T     inRows     = dimsInfo->dims[0];
        const int_T 	numDims	   = ssGetInputPortNumDimensions(S, INPORT);

		if ( (numDims != 1) && (numDims != 2) ) {
			THROW_ERROR(S, "Input must be 1D or 2D.");
		}

        outRows  = (frameBased && (ftype == fcnEqualRates)) ? inRows/convfactor : inRows;
		outCols  = inCols;

        /* Determine if Output port need setting */
        if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) {
            if ( (frameBased) || (numDims==2) ) {
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, outCols)) return;
            } else {
                if(!ssSetOutputPortVectorDimension(S, OUTPORT, outRows)) return;
            }
        } else {
            /* Output has been set, so do error checking. */
            const int_T *outDims    = ssGetOutputPortDimensions(S, OUTPORT);
            const int_T  outRowsSet = outDims[0];

            if (frameBased && ftype == fcnEqualRates) {
                if(outRowsSet != inRows/convfactor) {
                    THROW_ERROR(S, "Output frame size must equal input frame size divided by the downsample factor.");
                }
            } else {
                if(outRowsSet != inRows) {
                    THROW_ERROR(S, "Output frame size must equal input frame size.");
                }
            }
        }
    }
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port,
                                          const DimsInfo_T *dimsInfo)
{
	int_T inRows =0;
	int_T inCols =0;

    if(!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;

    if(ssGetOutputPortConnected(S,OUTPORT)) {

        /* Block parameters */
 	    const FcnType ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
    	const int_T   convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);

        /* Port info */
        const boolean_T frameBased = (boolean_T)(ssGetInputPortFrameData(S,INPORT) == FRAME_YES);
        const int_T     outCols    = dimsInfo->dims[1];
        const int_T     outRows    = dimsInfo->dims[0];
        const int_T 	numDims	   = ssGetOutputPortNumDimensions(S, OUTPORT);

		if ( (numDims != 1) && (numDims != 2) ) {
			THROW_ERROR(S, "Outputs must be 1-D or 2-D.");
		}

        inRows  = ((frameBased) && (ftype == fcnEqualRates)) ? outRows * convfactor : outRows;
		inCols  = outCols;

	    /* Determine if inport need setting */
        if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) {
            if ( (frameBased) || (numDims==2) ) {
                if(!ssSetInputPortMatrixDimensions(S, INPORT, inRows, inCols)) return;
            } else {
                if(!ssSetInputPortVectorDimension(S, INPORT, inRows)) return;
            }
        } else {
            /* Input has been set, so do error checking. */
            const int_T *inDims = ssGetInputPortDimensions(S, INPORT);
            const int_T  inRowsSet = inDims[0];

            if (frameBased && ftype == fcnEqualRates) {
                if(inRowsSet != outRows * convfactor) {
                    THROW_ERROR(S, "Input frame size must equal output frame size multiplied by the downsample factor.");
                }
            } else {
                if(inRowsSet != outRows) {
                    THROW_ERROR(S, "Input frame size must equal output frame size.");
                }
            }
        }
    }
}
#endif

#include "dsp_cplxhs11.c"

#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
