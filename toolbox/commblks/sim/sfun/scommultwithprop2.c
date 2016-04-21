/*
 * SCOMMULTWITHPROP2
 *
 * This block performs a multiplication with real and complex numbers.
 * The operation is just as the Simulink multiply with the exception that
 * there is a different definition of propagation applied to the ports.
 *
 * The backprop port will always be non-frame, unoriented.
 * The length of the backprop input will be the same as the width and
 * channels product of the other input.
 *
 * Copyright 1996-2004 The MathWorks, Inc.
 *  $Revision: 1.9.4.6 $  $Date: 2004/04/12 23:03:32 $
 */


#define S_FUNCTION_NAME scommultwithprop2
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

#ifdef COMMBLKS_SIM_SFCN
#include "dsp_mtrx_sim.h"
#endif

/* --- Define i/o signals */
enum {
    INPORT_0 = 0, INPORT_1, NUM_INPORTS
};
enum {
    OUTPORT_0 = 0, NUM_OUTPORTS
};

/* --- Define mask parameters */
enum {
    BACKPROP_PORT_A = 0, SAMPLE_TIME_A, NUM_CHANS_A, NUM_ARGS
};

#define BACKPROP_PORT ssGetSFcnParam(S, BACKPROP_PORT_A)
#define SAMPLE_TIME   ssGetSFcnParam(S, SAMPLE_TIME_A)
#define NUM_CHANS     ssGetSFcnParam(S, NUM_CHANS_A)

/* Function: mdlCheckParameters ======================================== */
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct * S)
{
    if (OK_TO_CHECK_VAR(S, BACKPROP_PORT)) {
	if (!IS_FLINT_IN_RANGE(BACKPROP_PORT, 1, 2) || !IS_SCALAR_DOUBLE(BACKPROP_PORT)) {
	    THROW_ERROR(S, "The back propagation port must be either 1 or 2.");
	}
    }
    if (OK_TO_CHECK_VAR(S, SAMPLE_TIME)) {
	if (((real_T) mxGetPr(SAMPLE_TIME)[0] <= 0.0) || !IS_SCALAR_DOUBLE(SAMPLE_TIME)) {
	    THROW_ERROR(S, "The sample time must be a scalar greater than zero.");
	}
    }
    if (OK_TO_CHECK_VAR(S, NUM_CHANS)) {
	if (!IS_FLINT_GE(NUM_CHANS, 1) || !IS_SCALAR_DOUBLE(NUM_CHANS)) {
	    THROW_ERROR(S, "The number of channels must be an integer greater than 0.");
	}
    }
}/* end mdlCheckParameters */
#endif

/* Function: mdlInitializeSizes ======================================== */
static void mdlInitializeSizes(SimStruct * S)
{
    int_T i;
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
	return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL)
	return;
#endif

    /* Set parameters to be non-tunable */
    for (i = 0; i < NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);
        
    {
	const int_T backPropPort = (int_T) mxGetPr(BACKPROP_PORT)[0] - 1;
	const int_T inputSignalPort = ((backPropPort == INPORT_0) ? INPORT_1 : INPORT_0);

    ssSetNumSampleTimes(S, 1);
    
	/* --- Inputs: */
	if (!ssSetNumInputPorts(S, NUM_INPORTS))
	    return;

	if (!ssSetInputPortDimensionInfo(S, inputSignalPort, DYNAMIC_DIMENSION))
	    return;
	ssSetInputPortFrameData(S, inputSignalPort, FRAME_INHERITED);
	ssSetInputPortComplexSignal(S, inputSignalPort, COMPLEX_INHERITED);
	ssSetInputPortDirectFeedThrough(S, inputSignalPort, 1);
	ssSetInputPortReusable(S, inputSignalPort, 0);
	ssSetInputPortOverWritable(S, inputSignalPort, 0);
        
	if (!ssSetInputPortDimensionInfo(S, backPropPort, DYNAMIC_DIMENSION))
	    return;
	ssSetInputPortFrameData(S, backPropPort, FRAME_YES);
	ssSetInputPortComplexSignal(S, backPropPort, COMPLEX_INHERITED);
	ssSetInputPortDirectFeedThrough(S, backPropPort, 1);
	ssSetInputPortReusable(S, backPropPort, 0);
	ssSetInputPortOverWritable(S, backPropPort, 0);
        
	/* --- Outputs: */
	if (!ssSetNumOutputPorts(S, NUM_OUTPORTS))
	    return;
	if (!ssSetOutputPortDimensionInfo(S, OUTPORT_0, DYNAMIC_DIMENSION))
	    return;
	ssSetOutputPortFrameData(S, OUTPORT_0, FRAME_INHERITED);
	ssSetOutputPortComplexSignal(S, OUTPORT_0, COMPLEX_INHERITED);
	ssSetOutputPortReusable(S, OUTPORT_0, 0);

    }
    
    ssSetOptions( S, SS_OPTION_CAN_BE_CALLED_CONDITIONALLY );
    
}/* End of mdlInitializeSizes(SimStruct *S) */


/* Function: mdlInitializeSampleTimes ================================== */
static void mdlInitializeSampleTimes(SimStruct * S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}


/* Function: mdlStart ================================================== */
#define MDL_START
static void mdlStart(SimStruct *S)
{
    const int_T backPropPort = (int_T) mxGetPr(BACKPROP_PORT)[0] - 1;
    const int_T inputSignalPort = ((backPropPort == INPORT_0) ? INPORT_1 : INPORT_0);
        
    real_T Ts = ssGetSampleTime(S, 0);
    real_T sigTs;
    real_T paramTs = (real_T) mxGetPr(SAMPLE_TIME)[0];

    if ( ssGetInputPortFrameData(S, inputSignalPort)){
        int_T *dims;
        dims = ssGetInputPortDimensions(S, inputSignalPort);
        sigTs = Ts/(real_T) dims[0];
    } else {
        sigTs = Ts;
    }

    if (fabs((paramTs - sigTs)/sigTs) >= 1e-15){
        THROW_ERROR(S, "Input signal's sample time must be equal to the specified sample time.");
    }
}


/* Function: mdlOutputs ================================================ */
static void mdlOutputs(SimStruct * S, int_T tid)
{
    const boolean_T cplx = (ssGetInputPortComplexSignal(S, INPORT_0) == COMPLEX_YES);
    const int_T inWidth = ssGetInputPortWidth(S, INPORT_0);
            
    int_T sampleIdx = 0;

    if (!cplx) {
        InputRealPtrsType inport0Signal = ssGetInputPortRealSignalPtrs(S, INPORT_0);
        InputRealPtrsType inport1Signal = ssGetInputPortRealSignalPtrs(S, INPORT_1);
        real_T *outport0Signal = ssGetOutputPortRealSignal(S, OUTPORT_0);
        
        for (sampleIdx = 0; sampleIdx < inWidth; sampleIdx++)
            outport0Signal[sampleIdx] = *inport0Signal[sampleIdx] * *inport1Signal[sampleIdx];

    } else {
                
        InputPtrsType ptrInport0Signal = ssGetInputPortSignalPtrs(S, INPORT_0);
        const creal_T *inport0Signal = (creal_T *) * ptrInport0Signal;
        
        InputPtrsType ptrInport1Signal = ssGetInputPortSignalPtrs(S, INPORT_1);
        const creal_T *inport1Signal = (creal_T *) * ptrInport1Signal;
        
        creal_T *outport0Signal = (creal_T *) ssGetOutputPortSignal(S, OUTPORT_0);
        
        for (sampleIdx = 0; sampleIdx < inWidth; sampleIdx++) {
            outport0Signal[sampleIdx].re = inport0Signal[sampleIdx].re * inport1Signal[sampleIdx].re
        	- inport0Signal[sampleIdx].im * inport1Signal[sampleIdx].im;
            outport0Signal[sampleIdx].im = inport0Signal[sampleIdx].re * inport1Signal[sampleIdx].im
        	+ inport0Signal[sampleIdx].im * inport1Signal[sampleIdx].re;
        }
    }    
}


static void mdlTerminate(SimStruct * S)
{
}


#ifdef  MATLAB_MEX_FILE

#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct * S,
				     int_T port,
				     Frame_T frameData)
{
    const int_T backPropPort = (int_T) mxGetPr(BACKPROP_PORT)[0] - 1;
    const int_T inputSignalPort = ((backPropPort == INPORT_0) ? INPORT_1 : INPORT_0);

    if (port == inputSignalPort) {
        ssSetInputPortFrameData(S, port, frameData);
        ssSetOutputPortFrameData(S, port, frameData);
    }
}


#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct * S,
					  int_T port,
					  const DimsInfo_T * dimsInfo)
{
    const int_T backPropPort = (int_T) mxGetPr(BACKPROP_PORT)[0] - 1;
    const int_T inputSignalPort = ((backPropPort == INPORT_0) ? INPORT_1 : INPORT_0);
    const int_T inRows = dimsInfo->dims[0];
    const int_T inCols = dimsInfo->dims[1];
    const int_T inWidth = dimsInfo->width;

    if (!ssSetOutputPortDimensionInfo(S, port, dimsInfo))
	return;

    if (!isOutputFrameDataOn(S, port) && !(isOutputVector(S, port) || isOutputScalar(S, port))) {
	THROW_ERROR(S, "The output may be either a single channel frame or a sample based scalar.");
    }
    if (isInputDynamicallySized(S, inputSignalPort)) {

	/* --- Set the input port */
	if (isOutput2D(S, port)) {
	    ssSetInputPortDimensionInfo(S, inputSignalPort, dimsInfo);
	} else {
	    ssSetInputPortVectorDimension(S, inputSignalPort, inWidth);
	}

	/* --- If the backprop input has not been set, set it. */
	if (isInputDynamicallySized(S, backPropPort)) {
	    if (isOutput2D(S, port)) {
		ssSetInputPortDimensionInfo(S, backPropPort, dimsInfo);
	    } else {
		/* initialize a dynamically-dimensioned DimsInfo_T */
		DECL_AND_INIT_DIMSINFO(dInfo);
		int_T dims[2];

		/* select valid port dimensions */
		dims[0] = inWidth;
		dims[1] = 1;
		dInfo.width = inWidth;
		dInfo.numDims = 2;
		dInfo.dims = dims;
		ssSetInputPortDimensionInfo(S, backPropPort, &dInfo);
	    }
	} else {
	    if (ssGetInputPortWidth(S, backPropPort) != inWidth) {
		THROW_ERROR(S, "Port width propagation error.");
	    }
	}
    } else {
	THROW_ERROR(S, "Port width propagation error.");
    }
}


#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct * S,
					 int_T port,
					 const DimsInfo_T * dimsInfo)
{
    const int_T backPropPort = (int_T) mxGetPr(BACKPROP_PORT)[0] - 1;
    const int_T inRows = dimsInfo->dims[0];
    const int_T inCols = dimsInfo->dims[1];
    const int_T inWidth = dimsInfo->width;

    if (!ssSetInputPortDimensionInfo(S, port, dimsInfo))
	return;

    if (port != backPropPort) {
	if (!isInputFrameDataOn(S, port) && !(isInputVector(S, port) || isInputScalar(S, port))) {
	    THROW_ERROR(S, "The input may be either a single channel frame or a sample based scalar.");
	}
	if (isOutputDynamicallySized(S, OUTPORT_0)) {

	    /* --- Set the output port */
	    if (isInput2D(S, port)) {
		ssSetOutputPortDimensionInfo(S, OUTPORT_0, dimsInfo);
	    } else {
		ssSetOutputPortVectorDimension(S, OUTPORT_0, inWidth);
	    }

	    /* --- If the backprop input has not been set, set it. */
	    /*     The backprop port is always frame based.        */
	    if (isInputDynamicallySized(S, backPropPort)) {
		if (isInput2D(S, port)) {
		    ssSetInputPortDimensionInfo(S, backPropPort, dimsInfo);
		} else {
		    /* initialize a dynamically-dimensioned DimsInfo_T */
		    DECL_AND_INIT_DIMSINFO(dInfo);
		    int_T dims[2];

		    /* select valid port dimensions */
		    dims[0] = inWidth;
		    dims[1] = 1;
		    dInfo.width = inWidth;
		    dInfo.numDims = 2;
		    dInfo.dims = dims;
		    ssSetInputPortDimensionInfo(S, backPropPort, &dInfo);
		}
	    } else {
		if (ssGetInputPortWidth(S, backPropPort) != inWidth) {
		    THROW_ERROR(S, "Port width propagation error.");
		}
	    }
	} else {
	    THROW_ERROR(S, "Port width propagation error.");
	}
    }
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct * S,
					 int_T port,
					 CSignal_T portComplex)
{
    const int_T backPropPort = (int_T) mxGetPr(BACKPROP_PORT)[0] - 1;

    ssSetInputPortComplexSignal(S, port, portComplex);

    if (port != backPropPort) {

	if (ssGetOutputPortComplexSignal(S, OUTPORT_0) == COMPLEX_INHERITED) {

	    ssSetOutputPortComplexSignal(S, OUTPORT_0, portComplex);

	    if (ssGetInputPortComplexSignal(S, backPropPort) == COMPLEX_INHERITED) {
		ssSetInputPortComplexSignal(S, backPropPort, portComplex);
	    } else {
		if (ssGetInputPortComplexSignal(S, backPropPort) != portComplex) {
		    THROW_ERROR(S, "Port complexity propagation error.");
		}
	    }
	} else {
	    THROW_ERROR(S, "Port complexity propagation error.");
	}

    }
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct * S,
					  int_T port,
					  CSignal_T portComplex)
{
    const int_T backPropPort = (int_T) mxGetPr(BACKPROP_PORT)[0] - 1;
    const int_T inputSignalPort = ((backPropPort == INPORT_0) ? INPORT_1 : INPORT_0);

    ssSetOutputPortComplexSignal(S, port, portComplex);

    if (ssGetInputPortComplexSignal(S, inputSignalPort) == COMPLEX_INHERITED) {

	ssSetInputPortComplexSignal(S, inputSignalPort, portComplex);

	if (ssGetInputPortComplexSignal(S, backPropPort) == COMPLEX_INHERITED) {
	    ssSetInputPortComplexSignal(S, backPropPort, portComplex);
	} else {
	    if (ssGetInputPortComplexSignal(S, backPropPort) != portComplex) {
		THROW_ERROR(S, "Port complexity propagation error.");
	    }
	}
    } else {
	THROW_ERROR(S, "Port complexity propagation error.");
    }

}
#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
