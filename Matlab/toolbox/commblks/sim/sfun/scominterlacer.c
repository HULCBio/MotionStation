/*
* SCOMINTERLACER Communications Blockset S-Function for combining
* the two input streams.
*
*  Author: Ramesh Kumar
*  Copyright 1996-2004 The MathWorks, Inc.
*  $Revision: 1.10.4.3 $  $Date: 2004/04/12 23:03:28 $
*/


#define S_FUNCTION_NAME scominterlacer
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

/* List input & output ports*/
/* Interlacer operation */
enum {INPORT1=0, INPORT2, NUM_INT_INPORTS};
enum {OUTPORT=0, NUM_INT_OUTPORTS};

/* Deinterlacer operation */
enum {INPORT=0, NUM_DEINT_INPORTS};
enum {OUTPORT1=0, OUTPORT2, NUM_DEINT_OUTPORTS};

enum {MODEC=0, NUM_ARGS};
#define MODE					(ssGetSFcnParam(S,MODEC))
enum {DEINTERLACER=1,INTERLACER};
#define DEINTERLACER_MODE		((int_T)mxGetPr(MODE)[0] == DEINTERLACER)
#define INTERLACER_MODE			((int_T)mxGetPr(MODE)[0] == INTERLACER)
#define OPERATION_MODE			((int_T)mxGetPr(MODE)[0])

/* Function: mdlCheckParameters ===============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{	/*---Check to see if the Mode parameter is either 1 or 2 ------*/
	if (!IS_FLINT_IN_RANGE(MODE,1,2))
	{
		THROW_ERROR(S,"Mode parameter is outside of expected range.");
	}
}
#endif

/* Function: mdlInitializeSizes ===============================================*/
static void mdlInitializeSizes(SimStruct *S)
{
	ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
	if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

	ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

	switch (OPERATION_MODE)
	{
		case INTERLACER:
			/* Input: */
			if (!ssSetNumInputPorts(S, NUM_INT_INPORTS)) return;
		    if (!ssSetInputPortDimensionInfo(S, INPORT1, DYNAMIC_DIMENSION)) return;
		    ssSetInputPortFrameData(         S, INPORT1, FRAME_INHERITED);
 			ssSetInputPortDirectFeedThrough( S, INPORT1, 1);
			ssSetInputPortComplexSignal(     S, INPORT1, COMPLEX_INHERITED);
			ssSetInputPortReusable(		     S, INPORT1, 0);
			ssSetInputPortRequiredContiguous(S, INPORT1, 1);
			ssSetInputPortSampleTime(        S, INPORT1, INHERITED_SAMPLE_TIME);

 		    if (!ssSetInputPortDimensionInfo(S, INPORT2, DYNAMIC_DIMENSION)) return;
		    ssSetInputPortFrameData(         S, INPORT2, FRAME_INHERITED);
			ssSetInputPortDirectFeedThrough( S, INPORT2, 1);
			ssSetInputPortComplexSignal(     S, INPORT2, COMPLEX_INHERITED);
			ssSetInputPortReusable(		     S, INPORT2, 0);
			ssSetInputPortRequiredContiguous(S, INPORT2, 1);
			ssSetInputPortSampleTime(        S, INPORT2, INHERITED_SAMPLE_TIME);

			/* Output: */
			if (!ssSetNumOutputPorts(S,NUM_INT_OUTPORTS)) return;
  		    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
		    ssSetOutputPortFrameData(         S, OUTPORT, FRAME_INHERITED);
 			ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_INHERITED);
			ssSetOutputPortReusable(	      S, OUTPORT, 0);
			ssSetOutputPortSampleTime(        S, OUTPORT, INHERITED_SAMPLE_TIME);
			break;

		case DEINTERLACER:
			/* Input: */
			if (!ssSetNumInputPorts(S, NUM_DEINT_INPORTS)) return;
		    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
		    ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
 			ssSetInputPortDirectFeedThrough( S, INPORT, 1);
			ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_INHERITED);
			ssSetInputPortReusable(		     S, INPORT, 0);
			ssSetInputPortRequiredContiguous(S, INPORT, 1);
			ssSetInputPortSampleTime(        S, INPORT, INHERITED_SAMPLE_TIME);

			/* Output: */
			if (!ssSetNumOutputPorts(S,NUM_DEINT_OUTPORTS)) return;
  		    if (!ssSetOutputPortDimensionInfo(S, OUTPORT1, DYNAMIC_DIMENSION)) return;
		    ssSetOutputPortFrameData(         S, OUTPORT1, FRAME_INHERITED);
			ssSetOutputPortComplexSignal(     S, OUTPORT1, COMPLEX_INHERITED);
			ssSetOutputPortReusable(	      S, OUTPORT1, 0);
			ssSetOutputPortSampleTime(        S, OUTPORT1, INHERITED_SAMPLE_TIME);

		    if (!ssSetOutputPortDimensionInfo(S, OUTPORT2, DYNAMIC_DIMENSION)) return;
		    ssSetOutputPortFrameData(         S, OUTPORT2, FRAME_INHERITED);
			ssSetOutputPortComplexSignal(     S, OUTPORT2, COMPLEX_INHERITED);
			ssSetOutputPortReusable(	      S, OUTPORT2, 0);
			ssSetOutputPortSampleTime(        S, OUTPORT2, INHERITED_SAMPLE_TIME);
			break;
		default:
			THROW_ERROR(S,"Invalid mode of operation.");
	}

	ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE         |
                     SS_OPTION_CAN_BE_CALLED_CONDITIONALLY );
	ssSetSFcnParamNotTunable(S, MODEC);
}
 /* End of mdlInitializeSizes(SimStruct *S) */


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    if (sampleTime == CONTINUOUS_SAMPLE_TIME)
	{
		THROW_ERROR(S,"Input signal must be discrete.");
	}
	if (offsetTime != 0.0)
	{
		THROW_ERROR(S,"Non-zero sample time offsets not allowed.");
	} 

	if (INTERLACER_MODE)
	{
		switch (portIdx)
		{
			case INPORT1:
				ssSetInputPortSampleTime(S, INPORT1, sampleTime);
				ssSetInputPortOffsetTime(S, INPORT1, offsetTime);

				ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
				ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);

				if (ssGetInputPortSampleTime(S, INPORT2) == INHERITED_SAMPLE_TIME)
				{
					ssSetInputPortSampleTime( S, INPORT2, sampleTime);
					ssSetInputPortOffsetTime( S, INPORT2, offsetTime);
				}
				else if (ssGetInputPortSampleTime(S, INPORT2) != sampleTime)
				{
					THROW_ERROR(S,"Sample time propagation failed.");
				}
				break;

			case INPORT2:
				ssSetInputPortSampleTime(S, INPORT2, sampleTime);
				ssSetInputPortOffsetTime(S, INPORT2, offsetTime);

				ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
				ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);

				if (ssGetInputPortSampleTime(S, INPORT1) == INHERITED_SAMPLE_TIME)
				{
					ssSetInputPortSampleTime( S, INPORT1, sampleTime);
					ssSetInputPortOffsetTime( S, INPORT1, offsetTime);
				}
				else if (ssGetInputPortSampleTime(S, INPORT1) != sampleTime)
				{
					THROW_ERROR(S,"Sample time propagation failed.");
				}
				break;
			default:
				THROW_ERROR(S,"Invalid port index for sample time propagation.");
		}

	} /* End of if (INTERLACER_MODE) */
	else /* (DEINTERLACER_MODE) */
	{
		switch (portIdx)
		{
			case INPORT:
				ssSetInputPortSampleTime(S, INPORT, sampleTime);
				ssSetInputPortOffsetTime(S, INPORT, offsetTime);

				ssSetOutputPortSampleTime(S, OUTPORT1, sampleTime);
				ssSetOutputPortOffsetTime(S, OUTPORT1, 0.0);
				ssSetOutputPortSampleTime(S, OUTPORT2, sampleTime);
				ssSetOutputPortOffsetTime(S, OUTPORT2, 0.0);
				break;
			default:
				THROW_ERROR(S,"Invalid port index for sample time propagation.");
		}
	}
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
	if (sampleTime == CONTINUOUS_SAMPLE_TIME)
	{
		THROW_ERROR(S,"Output signal must be discrete.");
	}
	if (offsetTime != 0.0)
	{
		THROW_ERROR(S,"Non-zero sample time offsets not allowed.");
	}

	if (INTERLACER_MODE)
	{
		switch (portIdx)
		{
			case OUTPORT:
				ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
				ssSetOutputPortOffsetTime(S, OUTPORT, offsetTime);

				ssSetInputPortSampleTime(S, INPORT1, sampleTime);
				ssSetInputPortOffsetTime(S, INPORT1, offsetTime);
				ssSetInputPortSampleTime(S, INPORT2, sampleTime);
				ssSetInputPortOffsetTime(S, INPORT2, offsetTime);
				break;
			default:
				THROW_ERROR(S,"Invalid port index for sample time propagation.");
		}
	} /* End of if (INTERLACER_MODE) */
	else /* (DEINTERLACER_MODE) */
	{
		switch (portIdx)
		{
			case OUTPORT1:
				ssSetOutputPortSampleTime(S, OUTPORT1, sampleTime);
				ssSetOutputPortOffsetTime(S, OUTPORT1, offsetTime);

				ssSetInputPortSampleTime(S, INPORT, sampleTime);
				ssSetInputPortOffsetTime(S, INPORT, offsetTime);

				if (ssGetOutputPortSampleTime(S, OUTPORT2) == INHERITED_SAMPLE_TIME)
				{
					ssSetOutputPortSampleTime( S, OUTPORT2, sampleTime);
					ssSetOutputPortOffsetTime( S, OUTPORT2, offsetTime);
				}
				else if (ssGetOutputPortSampleTime(S, OUTPORT2) != sampleTime)
				{
					THROW_ERROR(S,"Sample time propagation failed.");
				}
				break;

			case OUTPORT2:
				ssSetOutputPortSampleTime(S, OUTPORT2, sampleTime);
				ssSetOutputPortOffsetTime(S, OUTPORT2, 0.0);

				ssSetInputPortSampleTime(S, INPORT, sampleTime);
				ssSetInputPortOffsetTime(S, INPORT, offsetTime);

				if (ssGetOutputPortSampleTime(S, OUTPORT1) == INHERITED_SAMPLE_TIME)
				{
					ssSetOutputPortSampleTime( S, OUTPORT1, sampleTime);
					ssSetOutputPortOffsetTime( S, OUTPORT1, offsetTime);
				}
				else if (ssGetOutputPortSampleTime(S, OUTPORT1) != sampleTime)
				{
					THROW_ERROR(S,"Sample time propagation failed.");
				}
				break;
			default:
				THROW_ERROR(S,"Invalid port index for sample time propagation.");
		}
	}
}
#endif

/* Function: mdlInitializeSampleTimes =========================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
#if defined(MATLAB_MEX_FILE)

	if (INTERLACER_MODE)
	{
		const real_T Tsi = ssGetInputPortSampleTime( S, INPORT1);
		const real_T Tsq = ssGetInputPortSampleTime( S, INPORT2);
		const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);

		if ((Tsi == INHERITED_SAMPLE_TIME) || (Tsq == INHERITED_SAMPLE_TIME) || (Tso == INHERITED_SAMPLE_TIME))
		{
			THROW_ERROR(S,"Sample time propagation failed.");
		}

		if ((Tsi != Tsq) || (Tsi != Tso))
		{
			THROW_ERROR(S,"Sample time propagation failed.");
		}

		/* All the ports must be set by now */
		if ( (ssGetInputPortWidth(S,INPORT1) == DYNAMICALLY_SIZED) || (ssGetInputPortWidth(S,INPORT2) == DYNAMICALLY_SIZED) ||
			(ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) ) {
				THROW_ERROR(S, "Port width propagation failed.");
		}
	}
	else /* DEINTERLACER_MODE */
	{
	    const real_T Tsi = ssGetOutputPortSampleTime(S, OUTPORT1);
		const real_T Tsq = ssGetOutputPortSampleTime(S, OUTPORT2);
		const real_T Tso = ssGetInputPortSampleTime( S, INPORT);

		if ((Tsi == INHERITED_SAMPLE_TIME) || (Tsq == INHERITED_SAMPLE_TIME) || (Tso == INHERITED_SAMPLE_TIME))
		{
			THROW_ERROR(S,"Sample time propagation failed.");
		}

		if ((Tsi != Tsq) || (Tsi != Tso))
		{
			THROW_ERROR(S,"Sample time propagation failed.");
		}

		/* All the ports must be set by now */
		if ( (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) || (ssGetOutputPortWidth(S,OUTPORT1) == DYNAMICALLY_SIZED) ||
			(ssGetOutputPortWidth(S,OUTPORT2) == DYNAMICALLY_SIZED) ) {
				THROW_ERROR(S, "Port width propagation failed.");
		}
	}
    
#endif

    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);

}


/* Function: mdlInitializeConditions ========================================*/
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
}

/* Function: mdlProcessParameters ===========================================*/
#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
}

/* Function: mdlStart =======================================================*/
#define MDL_START
static void mdlStart (SimStruct *S)
{
}
/* End of mdlStart (SimStruct *S) */

/* Function: mdlOutputs =======================================================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
	if (INTERLACER_MODE)
	{
		const int_T	  InPortWidth      = ssGetInputPortWidth(S, INPORT1);
		const boolean_T    cplx        = (ssGetInputPortComplexSignal(S, INPORT1) == COMPLEX_YES);
		int_T i = 0;

		if (!cplx) /* Real outputs */
		{
			real_T      *uptr1   = (real_T *)ssGetInputPortRealSignal(S, INPORT1);
			real_T      *uptr2   = (real_T *)ssGetInputPortRealSignal(S, INPORT2);
			real_T      *y       = (real_T *)ssGetOutputPortRealSignal(S, OUTPORT);
			for (i = 0; i < InPortWidth; i++)
			{
				*y++ = *uptr1++;
				*y++ = *uptr2++;
			}
		}
		else /* Complex Outputs */
		{
			creal_T           *uptr1 = (creal_T *)ssGetInputPortSignal(S, INPORT1);
			creal_T           *uptr2 = (creal_T *)ssGetInputPortSignal(S, INPORT2);
			creal_T           *y     = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
			for (i = 0; i < InPortWidth; i++)
			{
				(y)->re   = uptr1->re;
				(y++)->im = (uptr1++)->im;
				(y)->re   = uptr2->re;
				(y++)->im = (uptr2++)->im;
			}
		}
	}
	else /* (MODE == DEINTERLACER) */
	{
		const int_T	  OutPortWidth     = ssGetOutputPortWidth(S, OUTPORT1);
		const boolean_T    cplx        = (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
		int_T i = 0;

		if (!cplx) /* Real outputs */
		{
			real_T				*uptr   = (real_T *)ssGetInputPortRealSignal(S, INPORT);
			real_T              *y1     = (real_T *)ssGetOutputPortRealSignal(S, OUTPORT1);
			real_T              *y2     = (real_T *)ssGetOutputPortRealSignal(S, OUTPORT2);
			for (i = 0; i < OutPortWidth; i++)
			{
				*y1++ = *uptr++;
				*y2++ = *uptr++;
			}
		}
		else /* Complex Outputs */
		{
			creal_T           *uptr   = (creal_T *)ssGetInputPortSignal(S, INPORT);
			creal_T           *y1     = (creal_T *)ssGetOutputPortSignal(S, OUTPORT1);
			creal_T           *y2     = (creal_T *)ssGetOutputPortSignal(S, OUTPORT2);
			for (i = 0; i < OutPortWidth; i++)
			{
				(y1)->re   = uptr->re;
				(y1++)->im = (uptr++)->im;
				(y2)->re   = uptr->re;
				(y2++)->im = (uptr++)->im;
			}
		}
	}
}
/* End of mdlOutputs (SimStruct *S, int_T tid) */

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         int_T InputPortComplexSignal)
{
	if (INTERLACER_MODE)
	{
		switch (portIdx)
		{
			case INPORT1:
				ssSetInputPortComplexSignal(S, INPORT1, InputPortComplexSignal);
				ssSetOutputPortComplexSignal(S, OUTPORT, InputPortComplexSignal);

				if (ssGetInputPortComplexSignal(S, INPORT2) == COMPLEX_INHERITED)
				{
					ssSetInputPortComplexSignal(S, INPORT2, InputPortComplexSignal);
				}
				else if (ssGetInputPortComplexSignal(S, INPORT2) != InputPortComplexSignal)
				{
					THROW_ERROR(S,"Complexity propagation failed.");
				}
				break;

			case INPORT2:
				ssSetInputPortComplexSignal(S, INPORT2, InputPortComplexSignal);
				ssSetOutputPortComplexSignal(S, OUTPORT, InputPortComplexSignal);

				if (ssGetInputPortComplexSignal(S, INPORT1) == COMPLEX_INHERITED)
				{
					ssSetInputPortComplexSignal(S, INPORT1, InputPortComplexSignal);
				}
				else if (ssGetInputPortComplexSignal(S, INPORT1) != InputPortComplexSignal)
				{
					THROW_ERROR(S,"Complexity propagation failed.");
				}
				break;
			default:
				THROW_ERROR(S,"Invalid port index for complexity propagation.");
		}

	} /* End of if (INTERLACER_MODE) */
	else /* (DEINTERLACER_MODE) */
	{
		switch (portIdx)
		{
			case INPORT:
				ssSetInputPortComplexSignal(S, INPORT, InputPortComplexSignal);
				ssSetOutputPortComplexSignal(S, OUTPORT1, InputPortComplexSignal);
				ssSetOutputPortComplexSignal(S, OUTPORT2, InputPortComplexSignal);
				break;
			default:
				THROW_ERROR(S,"Invalid port index for complexity propagation.");
		}
	}
}


#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx,
                                          int_T OutputPortComplexSignal)
{
	if (INTERLACER_MODE)
	{
		switch (portIdx)
		{
			case OUTPORT:
				ssSetOutputPortComplexSignal(S, OUTPORT, OutputPortComplexSignal);
				ssSetInputPortComplexSignal( S, INPORT1, OutputPortComplexSignal);
				ssSetInputPortComplexSignal( S, INPORT2, OutputPortComplexSignal);
				break;
			default:
				THROW_ERROR(S,"Invalid port index for complexity propagation.");
		}
	} /* End of if (INTERLACER_MODE) */
	else /* (DEINTERLACER_MODE) */
	{
		switch (portIdx)
		{
			case OUTPORT1:
				ssSetInputPortComplexSignal( S, INPORT, OutputPortComplexSignal);
				ssSetOutputPortComplexSignal(S, OUTPORT1, OutputPortComplexSignal);

				if (ssGetOutputPortComplexSignal(S, OUTPORT2) == COMPLEX_INHERITED)
				{
					ssSetOutputPortComplexSignal(S, OUTPORT2, OutputPortComplexSignal);
				}
				else if (ssGetOutputPortComplexSignal(S, OUTPORT2) != OutputPortComplexSignal)
				{
					THROW_ERROR(S,"Complexity propagation failed.");
				}
				break;

			case OUTPORT2:
				ssSetInputPortComplexSignal( S, INPORT, OutputPortComplexSignal);
				ssSetOutputPortComplexSignal(S, OUTPORT2, OutputPortComplexSignal);

				if (ssGetOutputPortComplexSignal(S, OUTPORT1) == COMPLEX_INHERITED)
				{
					ssSetOutputPortComplexSignal(S, OUTPORT1, OutputPortComplexSignal);
				}
				else if (ssGetOutputPortComplexSignal(S, OUTPORT1) != OutputPortComplexSignal)
				{
					THROW_ERROR(S,"Complexity propagation failed.");
				}
				break;
			default:
				THROW_ERROR(S,"Invalid port index for complexity propagation.");
		}
	}
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S,
                                      int_T portIdx,
                                      Frame_T frameData)
{
    if (ssGetNumInputPorts(S) == 2) {
		/* Two input ports - Interlacer */
 		switch (portIdx)
 		{
	 		case INPORT1:
			    ssSetInputPortFrameData(S, INPORT1, frameData);
	 	        ssSetOutputPortFrameData(S, OUTPORT, frameData);
				if (ssGetInputPortFrameData(S, INPORT2) == FRAME_INHERITED) {
		    		ssSetInputPortFrameData(S, INPORT2, frameData);
				}
				else {
					if (ssGetInputPortFrameData(S, INPORT2)!= frameData) {
						THROW_ERROR(S,"Frame data propagation failed.");
					}
				}
	    		break;
	   		case INPORT2:
			    ssSetInputPortFrameData(S, INPORT2, frameData);
	 	        ssSetOutputPortFrameData(S, OUTPORT, frameData);
				if (ssGetInputPortFrameData(S, INPORT1)== FRAME_INHERITED) {
		    		ssSetInputPortFrameData(S, INPORT1, frameData);
				}
				else {
					if (ssGetInputPortFrameData(S, INPORT1)!= frameData) {
						THROW_ERROR(S,"Frame data propagation failed.");
					}
				}
	    		break;
			default:
				THROW_ERROR(S,"Invalid port index.");
		}
	}
	else if (ssGetNumInputPorts(S) == 1) {
		/* One input port - Deinterlacer */
		switch (portIdx)
		{
			case INPORT:
				ssSetInputPortFrameData(S, INPORT, frameData);
		        ssSetOutputPortFrameData(S, OUTPORT1, frameData);
        		ssSetOutputPortFrameData(S, OUTPORT2, frameData);
				break;
			default:
				THROW_ERROR(S,"Invalid port index.");
		}
	}
}
#endif

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                      const DimsInfo_T *dimsInfo)
{

	int_T outCols  = 0;
	int_T outRows  = 0;
	int_T outCols1 = 0;
	int_T outRows1 = 0;
	int_T outCols2 = 0;
	int_T outRows2 = 0;

    if(!ssSetInputPortDimensionInfo(S, portIdx, dimsInfo)) return;

	if (INTERLACER_MODE) { /* Only use outCols and outRows */

		if( ssGetInputPortConnected(S,INPORT1) && ssGetInputPortConnected(S,INPORT2) )
		{
			switch (portIdx)
			{
				case INPORT1:
					{
						/* Port info */
						const boolean_T framebased = (boolean_T)ssGetInputPortFrameData(S,INPORT1);
						const int_T     inCols1     = dimsInfo->dims[1];
						const int_T     inRows1     = dimsInfo->dims[0];
						const int_T     dataPortWidth  = ssGetInputPortWidth(S, INPORT1);
						const int_T     numDims        = ssGetInputPortNumDimensions(S, INPORT1);

						if ((numDims != 1) && (numDims != 2)) {
							THROW_ERROR(S, "Input must be 1-D or 2-D.");
						}

						if (!framebased) {
							if (dataPortWidth != 1) {
								THROW_ERROR(S,"Input must be a scalar.");
							}
						}
						else { /* Frame-based */
							if (inCols1 != 1) {
								THROW_ERROR(S,"The input must be a column vector.");
							}
						}
						outCols = inCols1;
						outRows = 2*inRows1;

						/* Set second input port - same dimensions as first one */
						if (ssGetInputPortWidth(S, INPORT2) == DYNAMICALLY_SIZED) {
							if ( (!framebased) && (numDims==1) ) {
								if(!ssSetInputPortVectorDimension(S,INPORT2,inRows1)) return;
							}
							else {
								if(!ssSetInputPortMatrixDimensions(S, INPORT2, inRows1, inCols1)) return;
							}
						}
						else { /*Check for correct dimensions being set */
							const int_T *inDims2    = ssGetInputPortDimensions(S, INPORT2);
							const int_T  inRowsSet2 = inDims2[0];
							if (inRowsSet2 != inRows1) {
								THROW_ERROR(S,"Port width propagation failed.");
							}
						}

						/* Determine if Output port needs setting */
						if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) {
							if (!framebased) {
								if(!ssSetOutputPortVectorDimension(S,OUTPORT,outRows)) return;
							}
							else {
								if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, outCols)) return;
							}
						}
						else { /* Output has been set, so do error checking. */
							const int_T *outDims    = ssGetOutputPortDimensions(S, OUTPORT);
							const int_T  outRowsSet = outDims[0];
							if(outRowsSet != outRows) {
								THROW_ERROR(S, "Port width propagation failed.");
							}
						}
						break;
					}

				case INPORT2:
					{
						/* Port info */
						const boolean_T framebased = (boolean_T)ssGetInputPortFrameData(S,INPORT2);
						const int_T     inCols2     = dimsInfo->dims[1];
						const int_T     inRows2     = dimsInfo->dims[0];
						const int_T     dataPortWidth  = ssGetInputPortWidth(S, INPORT2);
						const int_T     numDims        = ssGetInputPortNumDimensions(S, INPORT2);

						if ((numDims != 1) && (numDims != 2)) {
							THROW_ERROR(S, "Input must be 1-D or 2-D.");
						}

						if (!framebased) {
							if (dataPortWidth != 1) {
								THROW_ERROR(S,"Input must be a scalar.");
							}
						}
						else { /* Frame-based */
							if (inCols2 != 1) {
								THROW_ERROR(S,"The input must be a column vector.");
							}
						}
						outCols = inCols2;
						outRows = 2*inRows2;

						/* Set first input port - same dimensions as the second one */
						if (ssGetInputPortWidth(S, INPORT1) == DYNAMICALLY_SIZED) {
							if ( (!framebased) && (numDims==1) ) {
								if(!ssSetInputPortVectorDimension(S,INPORT1,inRows2)) return;
							}
							else {
								if(!ssSetInputPortMatrixDimensions(S, INPORT1, inRows2, inCols2)) return;
							}
						}
						else { /*Check for correct dimensions being set */
							const int_T *inDims1    = ssGetInputPortDimensions(S, INPORT1);
							const int_T  inRowsSet1 = inDims1[0];
							if (inRowsSet1 != inRows2) {
								THROW_ERROR(S,"Port width propagation failed.");
							}
						}

						/* Determine if Output port needs setting */
						if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) {
							if (!framebased) {
								if(!ssSetOutputPortVectorDimension(S,OUTPORT,outRows)) return;
							}
							else {
								if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, outCols)) return;
							}
						}
						else { /* Output has been set, so do error checking. */
							const int_T *outDims    = ssGetOutputPortDimensions(S, OUTPORT);
							const int_T  outRowsSet = outDims[0];
							if(outRowsSet != outRows) {
								THROW_ERROR(S, "Port width propagation failed.");
							}
						}
						break;
					}
				default:
					THROW_ERROR(S,"Invalid port index.");
			} /* End of Switch */
		}
	} /* End of if (INTERLACER_MODE) */
	else { /* (DEINTERLACER_MODE) */
		if( ssGetInputPortConnected(S,INPORT) )
		{
			switch (portIdx)
			{
				case INPORT:
					{
						/* Port info */
						const boolean_T framebased = (boolean_T)ssGetInputPortFrameData(S,INPORT);
						const int_T     inCols     = dimsInfo->dims[1];
						const int_T     inRows     = dimsInfo->dims[0];
						const int_T     dataPortWidth  = ssGetInputPortWidth(S, INPORT);
						const int_T     numDims        = ssGetInputPortNumDimensions(S, INPORT);

						if ((numDims != 1) && (numDims != 2)) {
							THROW_ERROR(S, "Input must be 1-D or 2-D.");
						}

						if (!framebased) {
							if (dataPortWidth != 2) {
								THROW_ERROR(S,"In sample-based mode, input must be a 2-element vector.");
							}
							/* To allow, [2], [2x1], [1x2] inputs in sample-based mode.*/
							outCols1 = ( (inRows>inCols) ? inCols : inCols/2);
							outCols2 = ( (inRows>inCols) ? inCols : inCols/2);
							outRows1 = ( (inRows>inCols) ? inRows/2 : inRows);
							outRows2 = ( (inRows>inCols) ? inRows/2 : inRows);
						}
						else { /* Frame-based */
							if (inCols != 1) {
								THROW_ERROR(S,"The output must be a column vector.");
							}
							if ( (dataPortWidth % 2) !=0) {
								THROW_ERROR(S,"The input width must be a multiple of 2.");
							}
							outCols1 = inCols;
							outCols2 = inCols;
							outRows1 = inRows/2;
							outRows2 = inRows/2;
						}

						/* Determine if Output ports need setting */
						if (ssGetOutputPortWidth(S,OUTPORT1) == DYNAMICALLY_SIZED) {
							if (numDims == 1) {
								if(!ssSetOutputPortVectorDimension(S,OUTPORT1,outRows1)) return;
								if(!ssSetOutputPortVectorDimension(S,OUTPORT2,outRows2)) return;
							}
							else {
								if(!ssSetOutputPortMatrixDimensions(S, OUTPORT1, outRows1, outCols1)) return;
								if(!ssSetOutputPortMatrixDimensions(S, OUTPORT2, outRows2, outCols2)) return;
							}
						}
						else if (ssGetOutputPortWidth(S,OUTPORT2) == DYNAMICALLY_SIZED) {
							if (numDims == 1) {
								if(!ssSetOutputPortVectorDimension(S,OUTPORT2,outRows2)) return;
								if(!ssSetOutputPortVectorDimension(S,OUTPORT1,outRows1)) return;
							}
							else {
								if(!ssSetOutputPortMatrixDimensions(S, OUTPORT2, outRows2, outCols2)) return;
								if(!ssSetOutputPortMatrixDimensions(S, OUTPORT1, outRows1, outCols1)) return;
							}
						}
						else { /* Output has been set, so do error checking. */
							const int_T *outDims1    = ssGetOutputPortDimensions(S, OUTPORT1);
							const int_T  outRowsSet1 = outDims1[0];
							const int_T  outColsSet1 = outDims1[1];

							const int_T *outDims2    = ssGetOutputPortDimensions(S, OUTPORT2);
							const int_T  outRowsSet2 = outDims2[0];
							const int_T  outColsSet2 = outDims2[1];

							if (inCols<inRows) {
								if( (outRowsSet1 != outRows1) || (outRowsSet2 != outRows2) ) {
									THROW_ERROR(S, "Port width propagation failed.");
								}
							}
							else {
								 if( (outColsSet1 != outCols1) || (outColsSet2 != outCols2) ) {
									THROW_ERROR(S, "Port width propagation failed.");
								}
							}
						}
						break;
					}
				default:
					THROW_ERROR(S,"Invalid port index for port width propagation.");
			} /* End of Switch */
		}
	} /* End of else (DEINTERLACER_MODE) */
}
#endif

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                          const DimsInfo_T *dimsInfo)
{
	int_T inCols  =0;
	int_T inRows  =0;
	int_T inCols1 =0;
	int_T inRows1 =0;
	int_T inCols2 =0;
	int_T inRows2 =0;

    if(!ssSetOutputPortDimensionInfo(S, portIdx, dimsInfo)) return;

	if (INTERLACER_MODE) { /* Use inCols1,incols2 and inRows1,inRows2 */

		if( ssGetOutputPortConnected(S,OUTPORT) )
		{
			switch (portIdx)
			{
				case OUTPORT:
					{
						/* Port info */
						const int_T     outCols = dimsInfo->dims[1];
						const int_T     outRows = dimsInfo->dims[0];
						const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT);
						const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT);

						const boolean_T framebased1 = (boolean_T)(ssGetInputPortFrameData(S,INPORT1) == FRAME_YES);
						const boolean_T framebased2 = (boolean_T)(ssGetInputPortFrameData(S,INPORT2) == FRAME_YES);

						if ( (numDims != 1) && (numDims != 2) ) {
							THROW_ERROR(S, "Outputs must be 1-D or 2-D.");
						}

						if (framebased1 != framebased2) {
							THROW_ERROR(S, "Frame data propagation failed.");
						}

						if ((dataPortWidth % 2) != 0) {
	    					THROW_ERROR(S, "The output width must be a multiple of 2.");
						}

						if (framebased1)	{
							if (outCols != 1) {
								THROW_ERROR(S,"The output must be a column vector.");
							}
						}

						inCols1 = outCols;
						inCols2 = outCols;
						inRows1 = outRows/2;
						inRows2 = outRows/2;

						/* Determine if inport need setting */
						if (ssGetInputPortWidth(S,INPORT1) == DYNAMICALLY_SIZED) {
							if(framebased1) {
								if(!ssSetInputPortMatrixDimensions(S, INPORT1, inRows1, inCols1)) return;
								if(!ssSetInputPortMatrixDimensions(S, INPORT2, inRows2, inCols2)) return;
							}
							else if(!framebased1) {
								if(!ssSetInputPortVectorDimension(S, INPORT1, inRows1)) return;
								if(!ssSetInputPortVectorDimension(S, INPORT2, inRows2)) return;
							}

						}
						else if (ssGetInputPortWidth(S,INPORT2) == DYNAMICALLY_SIZED) {
							if(framebased2) {
								if(!ssSetInputPortMatrixDimensions(S, INPORT1, inRows1, inCols1)) return;
								if(!ssSetInputPortMatrixDimensions(S, INPORT2, inRows2, inCols2)) return;
							}
							else if(!framebased2) {
								if(!ssSetInputPortVectorDimension(S, INPORT1, inRows1)) return;
								if(!ssSetInputPortVectorDimension(S, INPORT2, inRows2)) return;
							}
						}
						else {/* Input has been set, so do error checking. */
							const int_T *inDims1 = ssGetInputPortDimensions(S, INPORT1);
							const int_T  inRowsSet1 = inDims1[0];
							const int_T *inDims2 = ssGetInputPortDimensions(S, INPORT2);
							const int_T  inRowsSet2 = inDims2[0];

							if( (inRowsSet1 != inRows1) || (inRowsSet2 != inRows2) ) {
								THROW_ERROR(S, "Port width propagation failed.");
							}
						}
						break;
					}
				default:
					THROW_ERROR(S,"Invalid port index.");
			} /* End of switch */
		}
	} /* End of if (INTERLACER_MODE) */
	else { /* (DEINTERLACER_MODE) */

		if( ssGetOutputPortConnected(S,OUTPORT1) && ssGetOutputPortConnected(S,OUTPORT2))
		{
			switch (portIdx)
			{
				case OUTPORT1:
					{
						/* Port info */
						const int_T     outCols1 = dimsInfo->dims[1];
						const int_T     outRows1 = dimsInfo->dims[0];
						const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT1);

						const boolean_T framebased = (boolean_T)(ssGetInputPortFrameData(S,INPORT) == FRAME_YES);
						const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT1);

						if ((numDims != 1) && (numDims != 2) ) {
							THROW_ERROR(S, "Outputs must be 1-D or 2-D.");
						}

						if (framebased)	{
							if (outCols1 != 1) {
								THROW_ERROR(S,"Output must be a column vector.");
							}
						}
						if ((framebased)) {
							inCols = outCols1;
							inRows = 2*outRows1;
						}

						if ((!framebased) && (dataPortWidth != 1)) {
							THROW_ERROR(S,"Output must be a scalar.");
						}

						/* Set the second output port */
						if (ssGetOutputPortWidth(S, OUTPORT2) == DYNAMICALLY_SIZED) {
							if (!framebased) {
								if(!ssSetOutputPortVectorDimension(S,OUTPORT2,outRows1)) return;
							}
							else {
								if(!ssSetOutputPortMatrixDimensions(S, OUTPORT2, outRows1, outCols1)) return;
							}
						}
						else { /*Check for correct dimensions being set */
							const int_T *outDims2    = ssGetOutputPortDimensions(S, OUTPORT2);
							const int_T  outRowsSet2 = outDims2[0];
							if (outRowsSet2 != outRows1) {
								THROW_ERROR(S,"Port width propagation failed.");
							}
						}

						/* Determine if inport need setting */
						/* Only set for the frame-based mode, as in sample based mode, cannot distinguish between [1] and [1x1] */
						if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) {
							if(framebased) {
								if(!ssSetInputPortMatrixDimensions(S, INPORT, inRows, inCols)) return;
							}
							else { /* sample based, only for 1D*/
								 if(!ssSetInputPortVectorDimension(S,INPORT,2*outRows1)) return;
							}
						}
						else {/* Input has been set, so do error checking. */
							const int_T *inDims = ssGetInputPortDimensions(S, INPORT);
							const int_T  inRowsSet = inDims[0];

							if ( ((framebased) || (numDims==1)) && (inRowsSet != inRows) ) {
									THROW_ERROR(S, "Port width propagation failed.");
							}
						}
						break;
					}
				case OUTPORT2:
					{
						/* Port info */
						const int_T     outCols2 = dimsInfo->dims[1];
						const int_T     outRows2 = dimsInfo->dims[0];
						const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT2);

						const boolean_T framebased = (boolean_T)(ssGetInputPortFrameData(S,INPORT) == FRAME_YES);
						const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT2);

						if ( (numDims != 1) && (numDims != 2) ) {
							THROW_ERROR(S, "Outputs must be 1-D or 2-D.");
						}

						if (framebased)	{
							if (outCols2 != 1) {
								THROW_ERROR(S,"Output must be a column vector.");
							}
						}
						if ((framebased)) {
							inCols = outCols2;
							inRows = 2*outRows2;
						}

						if ((!framebased) && (dataPortWidth != 1)) {
							THROW_ERROR(S,"Output must be a scalar.");
						}

						/* Set first output port - same dimensions as second one */
						if (ssGetOutputPortWidth(S, OUTPORT1) == DYNAMICALLY_SIZED) {
							if (!framebased) {
								if(!ssSetOutputPortVectorDimension(S,OUTPORT1,outRows2)) return;
							}
							else {
								if(!ssSetOutputPortMatrixDimensions(S, OUTPORT1, outRows2, outCols2)) return;
							}
						}
						else { /*Check for correct dimensions being set */
							const int_T *outDims1    = ssGetOutputPortDimensions(S, OUTPORT1);
							const int_T  outRowsSet1 = outDims1[0];
							if (outRowsSet1 != outRows2) {
								THROW_ERROR(S,"Port width propagation failed.");
							}
						}

						/* Determine if inport need setting */
						/* Only set for the frame-based mode, as in sample based mode, cannot distinguish between [1x2] and [2x1] */
						if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) {
							if(framebased) {
								if(!ssSetInputPortMatrixDimensions(S, INPORT, inRows, inCols)) return;
							}
							else { /* sample based */
									if(!ssSetInputPortVectorDimension(S,INPORT,2*outRows2)) return;
							}
						}
						else {/* Input has been set, so do error checking. */
							const int_T *inDims = ssGetInputPortDimensions(S, INPORT);
							const int_T  inRowsSet = inDims[0];

							if ( ((framebased) || (numDims==1)) && (inRowsSet != inRows) ) {
								THROW_ERROR(S, "Port width propagation failed.");
							}
						}
						break;
					}
				default:
					THROW_ERROR(S,"Invalid port index.");
			} /* End of switch */
		}
	} /* End of DEINTERLACER_MODE else */
}
#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

