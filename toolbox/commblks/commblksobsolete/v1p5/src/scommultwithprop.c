/*
* SCOMMULTWITHPROP
*
* This block performs a multiplication with real and complex numbers.
* The operation is just as the Simulink multiply with the exception that
* there is a different definition of propagation applied to the ports.
*
* Requirements:
*
* Input port 2 and output port 1 must have the same type and width
* This common type and with will be propagated back to input port 1.
*
* Copyright 1996-2002 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:45:14 $
*
*/

#define S_FUNCTION_NAME scommultwithprop
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include <math.h>
#include "comm_defs.h"


/* --- Define i/o signals */
enum {INPORT_0=0, INPORT_1, NUM_INPORTS};
enum {OUTPORT_0=0, NUM_OUTPORTS};

/* --- Define mask parameters */
enum {BACKPROP_PORT_A=0, SAMPLE_TIME_A, NUM_CHANS_A, NUM_ARGS};
#define BACKPROP_PORT ssGetSFcnParam(S, BACKPROP_PORT_A)
#define SAMPLE_TIME   ssGetSFcnParam(S, SAMPLE_TIME_A)
#define NUM_CHANS     ssGetSFcnParam(S, NUM_CHANS_A)

/* Function: mdlCheckParameters ===============================================
 */
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if ( OK_TO_CHECK_VAR(S, BACKPROP_PORT) ) {
        if (!IS_FLINT_IN_RANGE(BACKPROP_PORT,1,2) || !IS_SCALAR_DOUBLE(BACKPROP_PORT)) {
            THROW_ERROR(S, "The back propagation port must be either 1 or 2.");
        }
    }

    if ( OK_TO_CHECK_VAR(S, SAMPLE_TIME) ) {
        if (((real_T)mxGetPr(SAMPLE_TIME)[0] <= 0.0) || !IS_SCALAR_DOUBLE(SAMPLE_TIME)) {
            THROW_ERROR(S, "The sample time must be a scalar greater than zero.");
        }
    }

    if ( OK_TO_CHECK_VAR(S, NUM_CHANS) ) {
        if (!IS_FLINT_GE(NUM_CHANS,1) || !IS_SCALAR_DOUBLE(NUM_CHANS)) {
            THROW_ERROR(S, "The number of channels must be an integer greater than 0.");
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

    ssSetInputPortWidth( S, INPORT_0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_0, 1);
    ssSetInputPortComplexSignal(    S, INPORT_0, COMPLEX_INHERITED);
	ssSetInputPortReusable(		    S, INPORT_0, 0);

    ssSetInputPortWidth( S, INPORT_1, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_1, 1);
    ssSetInputPortComplexSignal(    S, INPORT_1, COMPLEX_INHERITED);
	ssSetInputPortReusable(		    S, INPORT_1, 0);

    /* --- Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;

	ssSetOutputPortWidth(        S, OUTPORT_0, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT_0, COMPLEX_INHERITED);
	ssSetOutputPortReusable(     S, OUTPORT_0, 0);


} /* End of mdlInitializeSizes(SimStruct *S) */


/* Function: mdlInitializeSampleTimes =========================================
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
	const int_T  backPropPort = (int_T)mxGetPr(BACKPROP_PORT)[0] - 1;
	const int_T  portWidth    = (int_T)ssGetInputPortWidth(S, backPropPort);
	const int_T  numChan      = (int_T)mxGetPr(NUM_CHANS)[0];
	const real_T Ts           = (real_T)mxGetPr(SAMPLE_TIME)[0];

	ssSetSampleTime(S, 0, Ts*(real_T)(portWidth/numChan));
    ssSetOffsetTime(S, 0, 0.0);

}


/* Function: mdlOutputs =======================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
	const boolean_T cplx = (ssGetInputPortComplexSignal(S, INPORT_0) == COMPLEX_YES);
	const int_T inWidth  = ssGetInputPortWidth(S, INPORT_0);

	int_T sampleIdx=0;

	if(!cplx)
	{
		InputRealPtrsType inport0Signal = ssGetInputPortRealSignalPtrs(S, INPORT_0);
		InputRealPtrsType inport1Signal = ssGetInputPortRealSignalPtrs(S, INPORT_1);
	    real_T  *outport0Signal = ssGetOutputPortRealSignal(S, OUTPORT_0);

		for(sampleIdx=0;sampleIdx<inWidth;sampleIdx++)
			outport0Signal[sampleIdx] = *inport0Signal[sampleIdx] * *inport1Signal[sampleIdx];


	} else {
		InputPtrsType ptrInport0Signal = ssGetInputPortSignalPtrs(S, INPORT_0);
		const creal_T *inport0Signal = (creal_T *)*ptrInport0Signal;

		InputPtrsType ptrInport1Signal = ssGetInputPortSignalPtrs(S, INPORT_1);
		const creal_T *inport1Signal = (creal_T *)*ptrInport1Signal;

		creal_T *outport0Signal = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_0);

		for(sampleIdx=0;sampleIdx<inWidth;sampleIdx++) {
			outport0Signal[sampleIdx].re =   inport0Signal[sampleIdx].re * inport1Signal[sampleIdx].re
										   - inport0Signal[sampleIdx].im * inport1Signal[sampleIdx].im;
			outport0Signal[sampleIdx].im =   inport0Signal[sampleIdx].re * inport1Signal[sampleIdx].im
										   + inport0Signal[sampleIdx].im * inport1Signal[sampleIdx].re;

		}

	}


}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef  MATLAB_MEX_FILE
# define MDL_SET_INPUT_PORT_WIDTH
  static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
	const int_T backPropPort = (int_T)mxGetPr(BACKPROP_PORT)[0] - 1;
	const int_T numChan      = (int_T)mxGetPr(NUM_CHANS)[0];

	if(inputPortWidth % numChan != 0) {
        THROW_ERROR(S, "Input port width must be a multiple of the number of channels.");
	}

	ssSetInputPortWidth(S, port, inputPortWidth);

	if(port != backPropPort) {

		if(ssGetOutputPortWidth(S, OUTPORT_0) == DYNAMICALLY_SIZED) {

			ssSetOutputPortWidth(S, OUTPORT_0, inputPortWidth);

			if(ssGetInputPortWidth(S, backPropPort) == DYNAMICALLY_SIZED) {
				ssSetInputPortWidth(S, backPropPort, inputPortWidth);
			} else {
				if(ssGetInputPortWidth(S, backPropPort) != inputPortWidth) {
					THROW_ERROR(S, "Port width propagation error.");
				}
			}
		} else {
			THROW_ERROR(S, "Port width propagation error.");
		}

	}

}


# define MDL_SET_OUTPUT_PORT_WIDTH
  static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
	const int_T backPropPort    = (int_T)mxGetPr(BACKPROP_PORT)[0] - 1;
	const int_T inputSignalPort = ((backPropPort == INPORT_0) ? INPORT_1 : INPORT_0);

	const int_T numChan         = (int_T)mxGetPr(NUM_CHANS)[0];

	if(outputPortWidth % numChan != 0) {
        THROW_ERROR(S, "Output port width must be a multiple of the number of channels.");
	}

	ssSetOutputPortWidth(S, port, outputPortWidth);

	if(ssGetInputPortWidth(S, inputSignalPort) == DYNAMICALLY_SIZED) {

		ssSetInputPortWidth(S, inputSignalPort, outputPortWidth);

		if(ssGetInputPortWidth(S, backPropPort) == DYNAMICALLY_SIZED) {
			ssSetInputPortWidth(S, backPropPort, outputPortWidth);
		} else {
			if(ssGetInputPortWidth(S, backPropPort) != outputPortWidth) {
				THROW_ERROR(S, "Port width propagation error.");
			}

		}
	} else {
		THROW_ERROR(S, "Port width propagation error.");
	}

}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S,
					 int_T port,
					 CSignal_T portComplex)
{
	const int_T backPropPort = (int_T)mxGetPr(BACKPROP_PORT)[0] - 1;

	ssSetInputPortComplexSignal(S, port, portComplex);

	if(port != backPropPort) {

		if(ssGetOutputPortComplexSignal(S, OUTPORT_0) == COMPLEX_INHERITED) {

			ssSetOutputPortComplexSignal(S, OUTPORT_0, portComplex);

			if(ssGetInputPortComplexSignal(S, backPropPort) == COMPLEX_INHERITED) {
				ssSetInputPortComplexSignal(S, backPropPort, portComplex);
			} else {
				if(ssGetInputPortComplexSignal(S, backPropPort) != portComplex) {
					THROW_ERROR(S, "Port complexity propagation error.");
				}
			}
		} else {
			THROW_ERROR(S, "Port complexity propagation error.");
		}

	}

}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S,
					  int_T port,
					  CSignal_T portComplex)
{

	const int_T backPropPort    = (int_T)mxGetPr(BACKPROP_PORT)[0] - 1;
	const int_T inputSignalPort = ((backPropPort == INPORT_0) ? INPORT_1 : INPORT_0);

	ssSetOutputPortComplexSignal(S, port, portComplex);

	if(ssGetInputPortComplexSignal(S, inputSignalPort) == COMPLEX_INHERITED) {

		ssSetInputPortComplexSignal(S, inputSignalPort, portComplex);

		if(ssGetInputPortComplexSignal(S, backPropPort) == COMPLEX_INHERITED) {
			ssSetInputPortComplexSignal(S, backPropPort, portComplex);
		} else {
			if(ssGetInputPortComplexSignal(S, backPropPort) != portComplex) {
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
