/*
* SCOMTRIGBUFF
*
* This block rebuffers data from an input port to an output port.
* The output data is sourced from an internal circular buffer.  If there is
* insufficent data in the internal buffer, the block will generate a function
* call event on port 0 to trigger generation of the data from an
* 'upstream' block.
*
* Be aware:
*
*  1) The sample time is block based.
*  2) The port complexity is inherited and input and output must be the same.
*  3) The output port width is always inherited.
*  4) The input port width is controlled by a mode variable.
*
* Input width mode notes:
*
* INPUT_WIDTH_MODE = 1 -> Input width is inherited
* INPUT_WIDTH_MODE = 2 -> Input width is given by INPUT_WIDTH
* INPUT_WIDTH_MODE = 3 -> Input width is based on OUTPUT_WIDTH. A minimum, step size
*                         and maximum are specified.  If the input width is
*                         not a multiple of the step size (when started from the minimum),
*                         the next highest increment is chosen. The input width will be
*                         hard limited to the maximum input width value.
*
* In addition, the block permits the user the opportunity of issuing
* pre-trigger function calls in the event that the upstream block has
* a deterministic startup transient.  The block pre-triggers by specifying the
* input sample offset before output samples become available.
*
*  Copyright 1996-2002 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:45:18 $
*
*/

#define S_FUNCTION_NAME scomtrigbuff
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "comm_defs.h"

/* --- The following defines how the block works in an enabled subsystem
*
*      When true, the block will consider its internal buffer empty upon
*      being re-enabled and re-execute any pre-triggers
*
* NOTE: When included in a trigered sub-system, this pre-triggering only occurs
*      on the initial trigger.
*/
#define RESET_POINTERS_ON_ENABLE true

/* --- Define i/o signals */
enum {INPORT_SIGNAL=0, NUM_INPORTS};
enum {OUTPORT_FCNCALL=0, OUTPORT_SIGNAL, NUM_OUTPORTS};

/* --- Define mask parameters */
enum {SAMPLE_START_A=0, CHANNELS_A, INPUT_WIDTH_MODE_A, INPUT_WIDTH_A, INPUT_WIDTH_MIN_A, INPUT_WIDTH_STEP_A, INPUT_WIDTH_MAX_A, NUM_ARGS};
#define SAMPLE_START		(ssGetSFcnParam(S, SAMPLE_START_A))
#define CHANNELS			(ssGetSFcnParam(S, CHANNELS_A))
#define INPUT_WIDTH_MODE	(ssGetSFcnParam(S, INPUT_WIDTH_MODE_A))
#define INPUT_WIDTH			(ssGetSFcnParam(S, INPUT_WIDTH_A))
#define INPUT_WIDTH_MIN		(ssGetSFcnParam(S, INPUT_WIDTH_MIN_A))
#define INPUT_WIDTH_STEP	(ssGetSFcnParam(S, INPUT_WIDTH_STEP_A))
#define INPUT_WIDTH_MAX		(ssGetSFcnParam(S, INPUT_WIDTH_MAX_A))

/* --- Define integer work vectors */
enum {DATA_AVAIL=0, IDX_BOTTOM, IDX_TOP, INT_BUFF_LEN, PRE_TRIGGER_COMPLETE, NUM_IWORK};

/* --- Define pointer work vectors */
enum {INTBUF_PTR=0, NUM_PWORK};


/* --- Define the modes of input width selection */
enum {INPUT_WIDTH_INHERITED=1, INPUT_WIDTH_SPECIFIED, INPUT_WIDTH_BASED_ON_OUTPUT, NUM_MODES};

/* Function: mdlCheckParameters ===============================================
 */
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if ( OK_TO_CHECK_VAR(S, CHANNELS) ){
        if ((!IS_FLINT_GE(CHANNELS,1)) || (!IS_SCALAR_DOUBLE(CHANNELS))) {
            THROW_ERROR(S, "The number of channels must be an integer scalar > 0.");
        }
    }

    if ( OK_TO_CHECK_VAR(S, SAMPLE_START) ){
        if ((!IS_FLINT_GE(SAMPLE_START,0)) || (!IS_SCALAR_DOUBLE(SAMPLE_START))) {
            THROW_ERROR(S, "The start sample must be an integer scalar >= 0.");
        }
    }

	/* --- Check the input width parameters */
    if (!IS_FLINT_IN_RANGE(INPUT_WIDTH_MODE,1,3)) {
        THROW_ERROR(S, "Input width mode must be 1, 2 or 3.");
    }

	/* --- If the mode is 2, then check the specified input width*/
	if(((int_T)mxGetPr(INPUT_WIDTH_MODE)[0] == INPUT_WIDTH_SPECIFIED) && OK_TO_CHECK_VAR(S, INPUT_WIDTH)) {
		if ((!IS_FLINT_GE(INPUT_WIDTH,1) || !IS_SCALAR_DOUBLE(INPUT_WIDTH) || mxIsInf(mxGetPr(INPUT_WIDTH)[0]))) {
			THROW_ERROR(S, "The input width must an integer scalar > 0.");
		}
	}

	/* --- If the mode is 3, then check the specified minimum, step and maximum input widths*/
	if(((int_T)mxGetPr(INPUT_WIDTH_MODE)[0] == INPUT_WIDTH_BASED_ON_OUTPUT) && OK_TO_CHECK_VAR(S, INPUT_WIDTH)) {
		if ((!IS_FLINT_GE(INPUT_WIDTH_MIN,1) || !IS_SCALAR_DOUBLE(INPUT_WIDTH_MIN) || mxIsInf(mxGetPr(INPUT_WIDTH_MIN)[0]))) {
			THROW_ERROR(S, "The minimum input width must an integer scalar > 0.");
		}
		if ((!IS_FLINT_GE(INPUT_WIDTH_STEP,1) || !IS_SCALAR_DOUBLE(INPUT_WIDTH_STEP) || mxIsInf(mxGetPr(INPUT_WIDTH_STEP)[0]))) {
			THROW_ERROR(S, "The input width step size must an integer scalar > 0.");
		}
		if(!mxIsInf(mxGetPr(INPUT_WIDTH_MAX)[0])) {
			if ( !IS_FLINT_GE(INPUT_WIDTH_MAX,(int_T)mxGetPr(INPUT_WIDTH_MIN)[0]) || !IS_SCALAR_DOUBLE(INPUT_WIDTH_MAX) )
			{
				THROW_ERROR(S, "The maximum input width must an integer scalar not less than than the minimum input parameter.");
			}
		}
	}

} /* end mdlCheckParameters */
#endif

/* Function: mdlInitializeSizes ===============================================
 */
static void mdlInitializeSizes(SimStruct *S)
    {

	const int_T widthMode = (int_T)mxGetPr(INPUT_WIDTH_MODE)[0];

	ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetSFcnParamNotTunable(S, CHANNELS_A);
    ssSetSFcnParamNotTunable(S, SAMPLE_START_A);
    ssSetSFcnParamNotTunable(S, INPUT_WIDTH_MODE_A);
    ssSetSFcnParamNotTunable(S, INPUT_WIDTH_A);

    ssSetNumSampleTimes(S, 1);

    /* --- Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

	if( (widthMode == INPUT_WIDTH_SPECIFIED)) {
	    ssSetInputPortWidth( S, INPORT_SIGNAL, (int_T)mxGetPr(INPUT_WIDTH)[0] * (int_T)mxGetPr(CHANNELS)[0]);
	} else {
	    ssSetInputPortWidth( S, INPORT_SIGNAL, DYNAMICALLY_SIZED);
	}

    ssSetInputPortDirectFeedThrough(S, INPORT_SIGNAL, 1);
    ssSetInputPortComplexSignal(    S, INPORT_SIGNAL, COMPLEX_INHERITED);
	ssSetInputPortReusable(		    S, INPORT_SIGNAL, 0);

    /* --- Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;

    ssSetOutputPortWidth(        S, OUTPORT_FCNCALL, 1);
    ssSetOutputPortComplexSignal(S, OUTPORT_FCNCALL, COMPLEX_NO);
	ssSetOutputPortReusable(	 S, OUTPORT_FCNCALL, 0);

	ssSetOutputPortWidth(        S, OUTPORT_SIGNAL, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT_SIGNAL, COMPLEX_INHERITED);
	ssSetOutputPortReusable(     S, OUTPORT_SIGNAL, 0);


	ssSetNumIWork(S, NUM_IWORK);
	ssSetNumPWork(S, NUM_PWORK);
    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;


} /* End of mdlInitializeSizes(SimStruct *S) */


/* Function: mdlInitializeSampleTimes =========================================
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

	ssSetCallSystemOutput(S,OUTPORT_FCNCALL);

}

#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)
{

	/* --- Allocate memory on the first pass */
	if(ssIsFirstInitCond(S)) {
		const boolean_T cplx = (ssGetInputPortComplexSignal(S, INPORT_SIGNAL) == COMPLEX_YES);

		const int_T numChan  = (int_T)mxGetPr(CHANNELS)[0];
		const int_T inPortWidth  = ssGetInputPortWidth(S, INPORT_SIGNAL);
		const int_T outPortWidth = ssGetOutputPortWidth(S, OUTPORT_SIGNAL);

		const int_T inWidth  = inPortWidth/numChan;
		const int_T outWidth = outPortWidth/numChan;

		/* --- Determine internal buffer required for each channel and allocate to a pointer work vector*/
		const int_T sampleStart = (int_T)mxGetPr(SAMPLE_START)[0];
		int_T intBuffLen = MAX(inWidth, outWidth) + (MIN(inWidth, outWidth) % MAX(inWidth,outWidth));

		intBuffLen += ((sampleStart % inWidth) == 0) ? 0 : (inWidth - (sampleStart % inWidth));

		if(!cplx)
			ssSetPWorkValue(S, INTBUF_PTR, (real_T *)mxCalloc(intBuffLen*numChan, sizeof(real_T)));
		else
			ssSetPWorkValue(S, INTBUF_PTR, (creal_T *)mxCalloc(intBuffLen*numChan, sizeof(creal_T)));

 		if(ssGetPWorkValue(S, INTBUF_PTR) == NULL)
			THROW_ERROR(S, "Unable to allocate internal buffer.");

        /* prevent MATLAB from deallocating behind our backs */
        mexMakeMemoryPersistent(ssGetPWorkValue(S, INTBUF_PTR));

		/* --- Set the buffer length work area (this is to avoid calculation later) */
		ssSetIWorkValue(S, INT_BUFF_LEN, intBuffLen);
	}

	/* --- If this is the first pass or the block is re-enabling, set the index values */
	if(ssIsFirstInitCond(S) || RESET_POINTERS_ON_ENABLE) {

		/* --- Set the index and data available values as required */
		ssSetIWorkValue(S, DATA_AVAIL,   0);
		ssSetIWorkValue(S, IDX_BOTTOM,   0);
		ssSetIWorkValue(S, IDX_TOP,      0);
		ssSetIWorkValue(S, PRE_TRIGGER_COMPLETE, 0);
	}

}
#endif /* MDL_INITIALIZE_CONDITIONS */


/* Function: mdlOutputs =======================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
	const boolean_T cplx = (ssGetInputPortComplexSignal(S, INPORT_SIGNAL) == COMPLEX_YES);

	const int_T sampleStart = (int_T)mxGetPr(SAMPLE_START)[0];

	const int_T numChan  = (int_T)mxGetPr(CHANNELS)[0];
	const int_T inPortWidth  = ssGetInputPortWidth(S, INPORT_SIGNAL);
	const int_T outPortWidth = ssGetOutputPortWidth(S, OUTPORT_SIGNAL);

	const int_T inWidth  = inPortWidth/numChan;
	const int_T outWidth = outPortWidth/numChan;

	int_T dataAvail = ssGetIWorkValue(S, DATA_AVAIL);
	int_T idxBottom = ssGetIWorkValue(S, IDX_BOTTOM);
	int_T idxTop    = ssGetIWorkValue(S, IDX_TOP);
	const int_T intBuffLen = ssGetIWorkValue(S, INT_BUFF_LEN);

	int_T chanIdx=0, sampleIdx=0;

	/* --- Determine which input frame the required sample is in */
	if(ssGetIWorkValue(S, PRE_TRIGGER_COMPLETE) == 0) {
		const int_T startFrame  = (int_T)(((real_T)sampleStart)/((real_T)inWidth));

		/* --- Set the flag so that this code is not entered again */
		ssSetIWorkValue(S, PRE_TRIGGER_COMPLETE, 1);

		/* --- Trigger the source function call until the frame before the required frame */
		/*     NOTE: The error checking has been removed from the system call for R11 */
		for(sampleIdx=0; sampleIdx < startFrame; sampleIdx++) {
			ssCallSystemWithTid(S, OUTPORT_FCNCALL, tid);
		}

		/* --- The sample offset will need to be added to the bottom index.
			   On the first pass through, dataAvail will be zero and hence
			   negative after this operation, so the while(dataAvail < outWidth)
			   statement will be executed as expected on the first pass.
		*/
		idxBottom = (idxBottom + (sampleStart % inWidth)) % intBuffLen;
		dataAvail -= (sampleStart % inWidth);

	}

	/* --- Add data to the internal buffer if required */
	while(dataAvail < outWidth)
	{
		/* --- Trigger the source function call */
		/*     NOTE: The error checking has been removed from the system call for R11 */
		ssCallSystemWithTid(S, OUTPORT_FCNCALL, tid);

		if(!cplx)
		{
			real_T *ptrIntBuff = (real_T *)ssGetPWorkValue(S, INTBUF_PTR);
			InputRealPtrsType inportSignal = ssGetInputPortRealSignalPtrs(S, INPORT_SIGNAL);

			/* --- Load input samples channel-by-channel into the internal buffer */
			for(chanIdx=0;chanIdx<numChan;chanIdx++) {
				for(sampleIdx=0;sampleIdx<inWidth;sampleIdx++)
					ptrIntBuff[(chanIdx*intBuffLen)+((idxTop+sampleIdx) % intBuffLen)] = *inportSignal[(chanIdx*inWidth)+sampleIdx];

			}

		} else {
			creal_T *ptrIntBuff = (creal_T *)ssGetPWorkValue(S, INTBUF_PTR);

			InputPtrsType ptrInportSignal = ssGetInputPortSignalPtrs(S, INPORT_SIGNAL);
			const creal_T *inportSignal = (creal_T *)*ptrInportSignal;

			/* --- Load input samples channel-by-channel into the internal buffer */
			for(chanIdx=0;chanIdx<numChan;chanIdx++) {
				for(sampleIdx=0;sampleIdx<inWidth;sampleIdx++) {
					ptrIntBuff[(chanIdx*intBuffLen)+((idxTop+sampleIdx) % intBuffLen)].re = inportSignal[(chanIdx*inWidth)+sampleIdx].re;
					ptrIntBuff[(chanIdx*intBuffLen)+((idxTop+sampleIdx) % intBuffLen)].im = inportSignal[(chanIdx*inWidth)+sampleIdx].im;
				}
			}

		}

		/* --- Update index values */
		idxTop     = (idxTop+inWidth) % intBuffLen;
		dataAvail += inWidth;


	} /* End of while(dataAvail < outWidth) */

	/* --- Read out a frame of data */
	if(!cplx)
	{
		const real_T *ptrIntBuff = (real_T *)ssGetPWorkValue(S, INTBUF_PTR);
	    real_T  *outportSignal = ssGetOutputPortRealSignal(S, OUTPORT_SIGNAL);

		for(chanIdx=0;chanIdx<numChan;chanIdx++) {
			for(sampleIdx=0;sampleIdx<outWidth;sampleIdx++)
				outportSignal[(chanIdx*outWidth)+sampleIdx] = ptrIntBuff[(chanIdx*intBuffLen)+((idxBottom+sampleIdx) % intBuffLen)];

		}
	} else {
		const creal_T *ptrIntBuff = (creal_T *)ssGetPWorkValue(S, INTBUF_PTR);
		creal_T *outportSignal = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_SIGNAL);

		for(chanIdx=0;chanIdx<numChan;chanIdx++) {
			for(sampleIdx=0;sampleIdx<outWidth;sampleIdx++) {
				outportSignal[(chanIdx*outWidth)+sampleIdx].re = ptrIntBuff[(chanIdx*intBuffLen)+((idxBottom+sampleIdx) % intBuffLen)].re;
				outportSignal[(chanIdx*outWidth)+sampleIdx].im = ptrIntBuff[(chanIdx*intBuffLen)+((idxBottom+sampleIdx) % intBuffLen)].im;
			}
		}
	} /* End of if(!cplx) ... else ... */


	/* --- Update index values */
	idxBottom  = (idxBottom+outWidth) % intBuffLen;
	dataAvail -= outWidth;

	/* --- Store work values */
	ssSetIWorkValue(S, DATA_AVAIL,   dataAvail);
	ssSetIWorkValue(S, IDX_BOTTOM,   idxBottom);
	ssSetIWorkValue(S, IDX_TOP,      idxTop);

}


static void mdlTerminate(SimStruct *S)
{
	mxFree(ssGetPWorkValue(S, INTBUF_PTR));
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
}


#ifdef  MATLAB_MEX_FILE

# define MDL_SET_INPUT_PORT_WIDTH
  static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
	const int_T widthMode = (int_T)mxGetPr(INPUT_WIDTH_MODE)[0];
	const int_T numChan   = (int_T)mxGetPr(CHANNELS)[0];

	if(widthMode == INPUT_WIDTH_INHERITED) {
		if(inputPortWidth % numChan != 0) {
		    THROW_ERROR(S, "Input port width must be a multiple of the number of channels.");
		}
		ssSetInputPortWidth(S, port, inputPortWidth);
	} else {
        THROW_ERROR(S, "Port width propagation error. Input mode is 'based on output' but input is being set before output.");
	}

}



# define MDL_SET_OUTPUT_PORT_WIDTH
  static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
	const int_T widthMode = (int_T)mxGetPr(INPUT_WIDTH_MODE)[0];
	const int_T numChan   = (int_T)mxGetPr(CHANNELS)[0];

	if(port != OUTPORT_SIGNAL) {
        THROW_ERROR(S, "Invalid output port used in width propagation.");
	}

	if(outputPortWidth % numChan != 0) {
        THROW_ERROR(S, "Output port width must be a multiple of the number of channels.");
	}

	ssSetOutputPortWidth(S, port, outputPortWidth);
	/* --- If the based on output mode is being used, set the input if possible */
	if(widthMode == INPUT_WIDTH_BASED_ON_OUTPUT) {
		if(ssGetInputPortWidth(S, INPORT_SIGNAL) == DYNAMICALLY_SIZED) {

			int_T inWidth = 0;

			const int_T outPortWidth = ssGetOutputPortWidth(S, OUTPORT_SIGNAL);
			const int_T outWidth  = outPortWidth/numChan;

			const int_T inputMin  = (int_T)mxGetPr(INPUT_WIDTH_MIN)[0];
			const int_T inputStep = (int_T)mxGetPr(INPUT_WIDTH_STEP)[0];
			const real_T inputMax = (real_T)mxGetPr(INPUT_WIDTH_MAX)[0]; /* This is a real as a test is performed later to see if it's Inf */

			if(outWidth < inputMin)
				inWidth = inputMin;
			else {
				if( ((outWidth-inputMin) % inputStep) == 0) {
					inWidth = inputMin + inputStep*((int_T)((real_T)(outWidth-inputMin)/(real_T)inputStep));
				} else {
					/* --- Round up the number of steps used */
					inWidth = inputMin + inputStep*(1+(int_T)((real_T)(outWidth-inputMin)/(real_T)inputStep));
				}
			}

			/* --- Ensure that the maximum is not exceeded */
			if(!mxIsInf(inputMax)) {
				inWidth = MIN(inWidth, (int_T)inputMax);
			}

			ssSetInputPortWidth(S, INPORT_SIGNAL, inWidth*numChan);

		} else {
	        THROW_ERROR(S, "Port width propagation error. Input mode is 'based on output' but input width has already been set.");
		}

	}

}


#endif

#include "com_cplxhs_ic_orc.c"

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
