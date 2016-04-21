/*
* SCOMRICIANLOS
*
* Add Rician line-of-sight components to the input signal
*
* This performs two functions:
*
*    1) Generate the complex Doppler frequency required by GSM RA model.
*
*    2) Determine the magnitude of the complex phasor to acheive the
*       required K-factor.
*
* If the Doppler 'spur' frequency is zero, the offset required for the Rician
* distribution will be added directly to the real path. (i.e. the trig terms are
* not computed).
*
*  Copyright 1996-2002 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:45:15 $
*
*/

#define S_FUNCTION_NAME scomricianlos
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include <math.h>
#include "comm_defs.h"

/* --- Define i/o signals */
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

/* --- Define mask parameters */
enum {DOPPLER_A=0, K_FACTOR_A, OP_POWER_A, SAMPLE_TIME_A, NUM_CHANS_A, NUM_ARGS};
#define DOPPLER     ssGetSFcnParam(S, DOPPLER_A)
#define K_FACTOR    ssGetSFcnParam(S, K_FACTOR_A)
#define OP_POWER    ssGetSFcnParam(S, OP_POWER_A)
#define SAMPLE_TIME ssGetSFcnParam(S, SAMPLE_TIME_A)
#define NUM_CHANS   ssGetSFcnParam(S, NUM_CHANS_A)

/* --- Define work vectors */
enum {START_PHASE=0, PHASE_DELTA, K_OFFSET, K_SIGMA, NUM_DWORK};


/* Function: mdlCheckParameters ===============================================
 */
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{


    if ( OK_TO_CHECK_VAR(S, DOPPLER) ) {
        if (!IS_VECTOR_DOUBLE(DOPPLER)) {
            THROW_ERROR(S, "The Doppler frequency must be a real scalar.");
        }
    }

    if ( OK_TO_CHECK_VAR(S, K_FACTOR) ) {
        if ( ( mxGetN(K_FACTOR)==0)||((real_T)mxGetPr(K_FACTOR)[0] < 0.0) || !IS_VECTOR_DOUBLE(K_FACTOR)) { 
            THROW_ERROR(S, "K-factor must be a real scalar or vector >= zero.");}       
    }
    if ( OK_TO_CHECK_VAR(S, OP_POWER) ) {
        if ( ( mxGetN(OP_POWER)==0)||((real_T)mxGetPr(OP_POWER)[0] < 0.0) || !IS_VECTOR_DOUBLE(OP_POWER) || mxIsInf(mxGetPr(OP_POWER)[0])) {
            THROW_ERROR(S, "Output power must be a real scalar or vector >= zero and less than Inf.");
        }
    }

    if ( OK_TO_CHECK_VAR(S, SAMPLE_TIME) ) {
        if (((real_T)mxGetPr(SAMPLE_TIME)[0] <= 0.0) || !IS_SCALAR_DOUBLE(SAMPLE_TIME)) {
            THROW_ERROR(S, "The sample time must be a real scalar greater than zero.");
        }
    }

    if ( OK_TO_CHECK_VAR(S, NUM_CHANS) ) {
        if (!IS_FLINT_GE(NUM_CHANS,1) || !IS_SCALAR_DOUBLE(NUM_CHANS)) {
            THROW_ERROR(S, "The number of channels must be an integer greater than 0.");
        }
    }


	if ( OK_TO_CHECK_VAR(S, DOPPLER) && OK_TO_CHECK_VAR(S, K_FACTOR) && OK_TO_CHECK_VAR(S, OP_POWER) && OK_TO_CHECK_VAR(S, NUM_CHANS)) {
		const int_T nDoppler = mxGetNumberOfElements(DOPPLER);
		const int_T nKFactor = mxGetNumberOfElements(K_FACTOR);
		const int_T nOpPower = mxGetNumberOfElements(OP_POWER);
		const int_T numChan  = (int_T)mxGetPr(NUM_CHANS)[0];

		if( ((nDoppler > 1) && (nDoppler != numChan)) ||
			((nKFactor > 1) && (nKFactor != numChan)) ||
			((nOpPower > 1) && (nOpPower != numChan)) ) {

			THROW_ERROR(S, "The length of vector parameters used for Doppler, K-Factor and Output power must be either unity or the same as the number of channels.");
		}

	}

} /* end mdlCheckParameters */
#endif

/* Function: mdlInitializeSizes ===============================================
 */
static void mdlInitializeSizes(SimStruct *S)
    {

	ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetNumSampleTimes(S, 1);

    /* --- Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_YES);
	ssSetInputPortReusable(		    S, INPORT, 0);

    /* --- Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;

	ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_YES);
	ssSetOutputPortReusable(     S, OUTPORT, 0);

	if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);

} /* End of mdlInitializeSizes(SimStruct *S) */


/* Function: mdlInitializeSampleTimes =========================================
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
	const int_T  portWidth = (int_T)ssGetInputPortWidth(S, INPORT);
	const int_T  numChan   = (int_T)mxGetPr(NUM_CHANS)[0];
	const real_T Ts        = (real_T)mxGetPr(SAMPLE_TIME)[0];

	ssSetSampleTime(S, 0, Ts*(real_T)(portWidth/numChan));
    ssSetOffsetTime(S, 0, 0.0);
}

/* Function: mdlStart =======================================================
*/
#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE

	const int_T  numChan = (int_T)mxGetPr(NUM_CHANS)[0];
	const real_T Pi2     = 8.0 * atan(1.0);
	const real_T Ts      = (real_T)mxGetPr(SAMPLE_TIME)[0];

	const real_T nDoppler       = mxGetNumberOfElements(DOPPLER);
	const real_T scalarDoppler  = mxGetPr(DOPPLER)[0];

	const real_T nKFactor       = mxGetNumberOfElements(K_FACTOR);
	const real_T scalarKFactor  = mxGetPr(K_FACTOR)[0];

	const real_T nOpPower       = mxGetNumberOfElements(OP_POWER);
	const real_T scalarOpPower  = mxGetPr(OP_POWER)[0];

	real_T *phaseDelta   = (real_T *)ssGetDWork(S, PHASE_DELTA);
	real_T *kOffset      = (real_T *)ssGetDWork(S, K_OFFSET);
	real_T *kSigma       = (real_T *)ssGetDWork(S, K_SIGMA);
	real_T K = 0.0, P = 1.0;

	int_T chanIdx=0;

	for(chanIdx=0;chanIdx<numChan;chanIdx++) {

		/* --- Compute the phase step */
		phaseDelta[chanIdx] = Pi2*Ts* (nDoppler > 1 ? (real_T)mxGetPr(DOPPLER)[chanIdx] : scalarDoppler);

		K = (nKFactor > 1 ? (real_T)mxGetPr(K_FACTOR)[chanIdx] : scalarKFactor);
		P = (nOpPower > 1 ? (real_T)mxGetPr(OP_POWER)[chanIdx] : scalarOpPower);

		/* --- Ensure that K==Inf is handled */
		if(mxIsInf(K)) {
			kOffset[chanIdx]    = sqrt(P);
			kSigma[chanIdx]     = 0.0;
		} else {
			kOffset[chanIdx]    = sqrt((K*P)/(1.0+K));
			kSigma[chanIdx]     = sqrt(P/(1.0+K));
		}
	}

#endif
}

/* Function: mdlOutputs =======================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
	const int_T numChan      = (int_T)mxGetPr(NUM_CHANS)[0];
	const int_T inPortWidth  = ssGetInputPortWidth(S,  INPORT);
	const int_T outPortWidth = ssGetOutputPortWidth(S, OUTPORT);

	const int_T inWidth      = inPortWidth/numChan;
	const int_T outWidth     = outPortWidth/numChan;

	const real_T Pi2         = 8.0 * atan(1.0);

	InputPtrsType ptrInportSignal = ssGetInputPortSignalPtrs(S, INPORT);
	const creal_T *inportSignal   = (creal_T *)*ptrInportSignal;
	creal_T *outportSignal        = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);

	real_T *startPhase = (real_T *)ssGetDWork(S, START_PHASE);
	const real_T *phaseDelta = (real_T *)ssGetDWork(S, PHASE_DELTA);
	const real_T *kOffset    = (real_T *)ssGetDWork(S, K_OFFSET);
	const real_T *kSigma     = (real_T *)ssGetDWork(S, K_SIGMA);

	int_T chanIdx=0, sampleIdx=0;

	for(chanIdx=0;chanIdx<numChan;chanIdx++) {
		for(sampleIdx=0;sampleIdx<inWidth;sampleIdx++) {

			if(phaseDelta[chanIdx] == 0.0) {
				outportSignal[(chanIdx*inWidth)+sampleIdx].re = kSigma[chanIdx]*inportSignal[(chanIdx*inWidth)+sampleIdx].re + kOffset[chanIdx];
				outportSignal[(chanIdx*inWidth)+sampleIdx].im = kSigma[chanIdx]*inportSignal[(chanIdx*inWidth)+sampleIdx].im;
			} else {
				outportSignal[(chanIdx*inWidth)+sampleIdx].re = kSigma[chanIdx]*inportSignal[(chanIdx*inWidth)+sampleIdx].re + kOffset[chanIdx]*cos(startPhase[chanIdx]);
				outportSignal[(chanIdx*inWidth)+sampleIdx].im = kSigma[chanIdx]*inportSignal[(chanIdx*inWidth)+sampleIdx].im + kOffset[chanIdx]*sin(startPhase[chanIdx]);

				/* --- Increment the phase */
				startPhase[chanIdx] = fmod(startPhase[chanIdx] += phaseDelta[chanIdx],Pi2);
			}

		}	/* End of for(sampleIdx=0;sampleIdx<inWidth;sampleIdx++) */

	}		/* End of for(chanIdx=0;chanIdx<numChan;chanIdx++) */

}


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{

    ssSetNumDWork(S, NUM_DWORK);

    ssSetDWorkWidth(        S, START_PHASE, (int_T)mxGetPr(NUM_CHANS)[0]);
    ssSetDWorkDataType(     S, START_PHASE, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, START_PHASE, COMPLEX_NO);

    ssSetDWorkWidth(        S, PHASE_DELTA, (int_T)mxGetPr(NUM_CHANS)[0]);
    ssSetDWorkDataType(     S, PHASE_DELTA, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, PHASE_DELTA, COMPLEX_NO);

    ssSetDWorkWidth(        S, K_OFFSET, (int_T)mxGetPr(NUM_CHANS)[0]);
    ssSetDWorkDataType(     S, K_OFFSET, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, K_OFFSET, COMPLEX_NO);

    ssSetDWorkWidth(        S, K_SIGMA, (int_T)mxGetPr(NUM_CHANS)[0]);
    ssSetDWorkDataType(     S, K_SIGMA, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, K_SIGMA, COMPLEX_NO);
}
#endif

static void mdlTerminate(SimStruct *S)
{
}


#ifdef  MATLAB_MEX_FILE
# define MDL_SET_INPUT_PORT_WIDTH
  static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
	const int_T numChan = (int_T)mxGetPr(NUM_CHANS)[0];

	if(inputPortWidth % numChan != 0) {
        THROW_ERROR(S, "Input port width must be a multiple of the number of channels.");
	}

	ssSetInputPortWidth(S, port, inputPortWidth);

	if(ssGetOutputPortWidth(S, OUTPORT) == DYNAMICALLY_SIZED) {

		ssSetOutputPortWidth(S, OUTPORT, inputPortWidth);
	} else {
		THROW_ERROR(S, "Port width propagation error.");
	}

}


# define MDL_SET_OUTPUT_PORT_WIDTH
  static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
	const int_T numChan = (int_T)mxGetPr(NUM_CHANS)[0];

	if(outputPortWidth % numChan != 0) {
        THROW_ERROR(S, "Output port width must be a multiple of the number of channels.");
	}

	ssSetOutputPortWidth(S, port, outputPortWidth);

	if(ssGetInputPortWidth(S, INPORT) == DYNAMICALLY_SIZED) {
		ssSetInputPortWidth(S, INPORT, outputPortWidth);
	} else {
		THROW_ERROR(S, "Port width propagation error.");
	}

}


#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
