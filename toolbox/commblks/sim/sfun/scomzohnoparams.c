/*
 * SCOMZOHNOPARAMS   A zero order hold with no parameters.
 * 
 * This utility S-function samples and holds the input vector.
 * It inherits the output sample time from the sample time of a reference input
 * rather than from a mask parameter.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $ $Date: 2004/04/12 23:03:42 $
 */


#define S_FUNCTION_NAME scomzohnoparams
#define S_FUNCTION_LEVEL 2

#define NUM_ARGS                  0
#define DIRECT_FEEDTHROUGH_YES    1
#define DIRECT_FEEDTHROUGH_NO     0
#define REQUIRED_CONTIGUOUS       1
#define IS_REUSABLE               1

/* List input and output ports */
enum {INPUT_SIG=0, CTRL_SIG, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

#include "comm_defs.h"

/* ------------------------------  Function mdlInitializeSizes -------------------------- */
static void mdlInitializeSizes(SimStruct *S)
{
    /* Entire block characteristics */
    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(  S) != ssGetSFcnParamsCount(S)) return;
    if (!ssSetNumInputPorts( S, NUM_INPORTS)) return;
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    ssSetNumSampleTimes(     S, PORT_BASED_SAMPLE_TIMES);   /* Multirate block dictates port-based sample times */
       
    /* Input signal characteristics */
    if (!ssSetInputPortDimensionInfo(S, INPUT_SIG, DYNAMIC_DIMENSION)) return;    
    ssSetInputPortSampleTime(        S, INPUT_SIG, INHERITED_SAMPLE_TIME);
    ssSetInputPortFrameData(         S, INPUT_SIG, FRAME_INHERITED);
    ssSetInputPortComplexSignal(     S, INPUT_SIG, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough( S, INPUT_SIG, DIRECT_FEEDTHROUGH_YES);
    ssSetInputPortRequiredContiguous(S, INPUT_SIG, REQUIRED_CONTIGUOUS);
    
    /* Control signal characteristics */
    if (!ssSetInputPortDimensionInfo(S, CTRL_SIG, DYNAMIC_DIMENSION)) return;
    ssSetInputPortSampleTime(        S, CTRL_SIG, INHERITED_SAMPLE_TIME);
    ssSetInputPortFrameData(         S, CTRL_SIG, FRAME_INHERITED);
    ssSetInputPortComplexSignal(     S, CTRL_SIG, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough( S, CTRL_SIG, DIRECT_FEEDTHROUGH_NO);         
    
    /* Output signal characteristics */
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortSampleTime(        S, OUTPORT, INHERITED_SAMPLE_TIME);
    ssSetOutputPortFrameData(         S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(          S, OUTPORT, IS_REUSABLE);
    
    /* Extras */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
    
}       /* End of function mdlInitializeSizes */


/* ------------------------------- Function mdlSetInputPortFrameData --------------------- */
#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, int_T port,
                                     const Frame_T frameData)
{
    /* We assume that whatever frame type that the input signal has is OK.  We then propagate it
       to the output signal.  We do not propagate the frame type of the control signal anywhere. */
    const int_T outFrameBased = ssGetOutputPortFrameData(S, OUTPORT);

    ssSetInputPortFrameData(S, port, frameData);
    if (port == INPUT_SIG) {
        /* Determine if the output port can be set */
        if (outFrameBased == FRAME_INHERITED) {
            ssSetOutputPortFrameData(S, OUTPORT, frameData);
        }
        else {  /* The output has been set, so do error checking */
            if (frameData != outFrameBased) {
                THROW_ERROR(S, "Input to output frame type propagation failed.");
            }
        }
    }
}       /* End of function mdlSetInputPortFrameData */
#endif


/* ------------------------------- Function mdlSetInputPortDimensionInfo ----------------- */
#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port,
                                         const DimsInfo_T *dimsInfo)

/* The dimensionality of the CTRL_SIG port can be anything, since only its sample time is
   of any interest.  The following table governs the dimension possibilities for the 
   INPUT_SIG port:


   Frame mode  |  Input type  | Input dims  | Output dims  | Error condition
   --------------------------------------------------------------------------------------------
       Off     |    Scalar    |     [1]     |     [1]      |
   --------------------------------------------------------------------------------------------
               |    Scalar    |    [1x1]    |    [1x1]     |
   --------------------------------------------------------------------------------------------
    	       |    Vector    |    [Rx1]    |              | Comms Blockset blocks will not support
               |              |             |              | sample-based vectors or matrices
   --------------------------------------------------------------------------------------------
               |    Vector    |    [1xC]    |              | Comms Blockset blocks will not support
    	       |              |             |              | sample-based vectors or matrices
   --------------------------------------------------------------------------------------------
               |    Matrix    |    [RxC]    |              | Comms Blockset blocks will not support
	           |              |             |              | sample-based vectors or matrices
   --------------------------------------------------------------------------------------------
       On      |    Scalar    |             |              | Not supported by Simulink
   --------------------------------------------------------------------------------------------
               |    Scalar    |    [1x1]    |    [1x1]     |
   --------------------------------------------------------------------------------------------
	           |    Vector    |    [Rx1]    |    [Rx1]     | 
   --------------------------------------------------------------------------------------------
               |    Vector    |    [1xC]    |    [1xC]     | 
   --------------------------------------------------------------------------------------------
               |    Matrix    |    [RxC]    |    [RxC]     |
   --------------------------------------------------------------------------------------------
*/

{
    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    /* Both input ports must be connected for the function to work properly */
    if (!ssGetInputPortConnected(S, INPUT_SIG) || !ssGetInputPortConnected(S, CTRL_SIG)) {
        THROW_ERROR(S, "Both input ports must be connected.");
    }

    if (port == INPUT_SIG) {
        /* Port info */
        const int_T     numDims        = ssGetInputPortNumDimensions(S, INPUT_SIG);
        const boolean_T frameBased     = (boolean_T)ssGetInputPortFrameData(S,INPUT_SIG);
        const int_T     inRows         = dimsInfo->dims[0];
        const int_T     outRows        = inRows;
        const int_T     inCols         = dimsInfo->dims[1];
        const int_T     outCols        = inCols;
    
        if ((numDims != 1) && (numDims != 2)) {
            THROW_ERROR(S, "The input signal must be 1-D or 2-D.");
        }

	    if (!frameBased) {
	        if ((inRows != 1) || (inCols != 1)) {
	            THROW_ERROR(S, "In sample-based mode, the input must be a scalar.");
            }
        }

        /* Determine if the output port can be set */
        if (ssGetOutputPortWidth(S, OUTPORT) == DYNAMICALLY_SIZED) {
            if (numDims == 1) { 
                if(!ssSetOutputPortVectorDimension(S, OUTPORT, outRows)) return;
            } 
            else {
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, outCols)) return;
            }
        }
        else {               /* Output has been set, so do error checking. */ 
            const int_T *outDims    = ssGetOutputPortDimensions(S, OUTPORT);
            const int_T  outRowsSet = outDims[0];
            const int_T  outColsSet = outDims[1];
            
            if((outRowsSet != outRows) || (outColsSet != outCols)) {
                THROW_ERROR(S, "Input to output port width propagation failed.");
            }
        }
    }
}           /* End of function mdlSetInputPortDimensionInfo */
#endif


/* ------------------------------- Function mdlSetOutputPortDimensionInfo ---------------- */
#if defined(MATLAB_MEX_FILE)
#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port,
                                         const DimsInfo_T *dimsInfo)
{
    /* Port info */
    const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT);
    const boolean_T framebased     = (boolean_T)ssGetOutputPortFrameData(S, OUTPORT);
    const int_T     outRows        = dimsInfo->dims[0];
    const int_T     inRows         = outRows;
    const int_T     outCols        = dimsInfo->dims[1];
    const int_T     inCols         = outCols;
    
    if ((numDims != 1) && (numDims != 2)) {
        THROW_ERROR(S, "The output signal must be 1-D or 2-D.");
    }

    if (!framebased) {
        if ((outRows != 1) || (outCols != 1)) {
            THROW_ERROR(S, "In sample-based mode, the output must be a scalar.");
        }
    }
    else {
        if (numDims == 1) {
            THROW_ERROR(S, "In frame-based mode, the output must be 2-D.");
        }
    }

    /* Determine if the input signal port can be set */
    if (ssGetInputPortWidth(S, INPUT_SIG) == DYNAMICALLY_SIZED) {
        if (numDims == 1) { 
            if(!ssSetInputPortVectorDimension(S, INPUT_SIG, inRows)) return;
        } 
        else {
            if(!ssSetInputPortMatrixDimensions(S, INPUT_SIG, inRows, inCols)) return;
        }
    }
    else {               /* Input has been set, so do error checking. */
        const int_T *inDims    = ssGetInputPortDimensions(S, INPUT_SIG);
        const int_T  inRowsSet = inDims[0];
        const int_T  inColsSet = inDims[1];
            
        if((inRowsSet != inRows) || (inColsSet != inCols)) {
            THROW_ERROR(S, "Output to input port width propagation failed.");
        }
    } 
}           /* End of function mdlSetOutputPortDimensionInfo */
#endif


/* --------------------------------- Function mdlSetInputPortSampleTime ------------------ */
#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S, 
                                      int_T     portIdx, 
                                      real_T    sampleTime, 
                                      real_T    offsetTime) 
{
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for this block.");
    }

    if (offsetTime != 0.0) { 
        THROW_ERROR(S, "Non-zero sample time offsets not allowed for this block."); 
    }
    
    if (ssGetInputPortSampleTime(S, portIdx) == INHERITED_SAMPLE_TIME) {
        ssSetInputPortSampleTime(S, portIdx, sampleTime);
        ssSetInputPortOffsetTime(S, portIdx, offsetTime); 
    }

    /* Set the output port sample time after the sample time of the reference port has been set */
    if (portIdx == CTRL_SIG) {
        ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
        ssSetOutputPortOffsetTime(S, OUTPORT, offsetTime);
    }
}       /* End of function mdlSetInputPortSampleTime */
#endif


/* -------------------------------- Function mdlSetOutputPortSampleTime --------------------- */
#if defined(MATLAB_MEX_FILE)
#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME 
static void mdlSetOutputPortSampleTime(SimStruct *S, 
                                      int_T     portIdx, 
                                      real_T    sampleTime, 
                                      real_T    offsetTime)
{
    real_T Tsi2 = ssGetInputPortSampleTime(S, CTRL_SIG);

    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for this block.");
    }

    if (offsetTime != 0.0) { 
        THROW_ERROR(S, "Non-zero sample time offsets not allowed for this block."); 
    }

    if ((sampleTime != INHERITED_SAMPLE_TIME) && 
        (Tsi2       == INHERITED_SAMPLE_TIME)) {
        THROW_ERROR(S, "This block must derive its output sample time from its reference input.");
    }
}
#endif
/*      End of function mdlSetOutputPortSampleTime */


/* ----------------------------------- Function mdlInitializeSampleTimes -------------------- */
static void mdlInitializeSampleTimes(SimStruct *S) 
{
    /* Check port sample times */ 
    const real_T Tsi1 = ssGetInputPortSampleTime( S, INPUT_SIG); 
    const real_T Tsi2 = ssGetInputPortSampleTime( S, CTRL_SIG);     
    const real_T Tso  = ssGetOutputPortSampleTime(S, OUTPORT); 
    
    if ((Tsi1 == INHERITED_SAMPLE_TIME) || 
        (Tsi2 == INHERITED_SAMPLE_TIME) ||
        (Tso  == INHERITED_SAMPLE_TIME)) { 
        THROW_ERROR(S, "Sample time propagation failed for this block.");
    } 
    if ((Tsi1 == CONTINUOUS_SAMPLE_TIME) || 
        (Tsi2 == CONTINUOUS_SAMPLE_TIME) ||
        (Tso  == CONTINUOUS_SAMPLE_TIME)  ) { 
        THROW_ERROR(S, "Continuous sample times not allowed for this block.");
    }
    if (Tsi2 != Tso) {
        THROW_ERROR(S, "The sample time of input port 2 and the output port must be equal.");
    }
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);

}       /* End of function mdlInitializeSampleTimes */


/* ----------------------------------- Function mdlSetInputPortComplexSignal --------------- */
#if defined (MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T port, 
                                         const CSignal_T csig)
{
    /* We assume that whatever complexity that the input signal has is OK.  We then propagate it
       to the output signal.  We do not propagate the complexity of the control signal anywhere. */
    const int_T outComplexity = ssGetOutputPortComplexSignal(S, OUTPORT);

    ssSetInputPortComplexSignal(S, port, csig);
    if (port == INPUT_SIG) {
        /* Determine if the output port can be set */
        if (outComplexity == COMPLEX_INHERITED) {
            ssSetOutputPortComplexSignal(S, OUTPORT, csig);
        }
        else { /* The output has been set, so do error checking */
            if (csig != outComplexity) {
                THROW_ERROR(S, "Input to output complexity propagation failed.");
            }
        }
    }
}        /* End of function mdlSetInputPortComplexSignal */
#endif


/* ----------------------------------- Function mdlInitializeConditions -------------------- */
static void mdlInitializeConditions(SimStruct *S)
{
}       /* End of function mdlInitializeConditions */


/* ----------------------------------- Function mdlOutputs --------------------------------- */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T InportTid     = ssGetInputPortSampleTimeIndex( S, INPUT_SIG);
    const int_T OutportTid    = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    const int_T InPortWidth   = ssGetInputPortWidth(           S, INPUT_SIG);
    const int_T OutPortWidth  = ssGetOutputPortWidth(          S, OUTPORT);
    int_T ALREADY_HELD        = 0;
    const boolean_T IsComplex = (boolean_T) (ssGetInputPortComplexSignal(S, INPUT_SIG)== COMPLEX_YES);

    if(IsComplex) { /* complex */
        creal_T       *y         = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
        const creal_T *input_sig = (const creal_T *)ssGetInputPortSignal(S, INPUT_SIG);
        if (ssIsSampleHit(S, OutportTid, tid)) {
            int_T i = OutPortWidth;
            while(i-- > 0) {
                *y++ = *input_sig++;           /* get output directly from input */
            }
        }
    }
    else { /* real */
        real_T        *y         = (real_T *)ssGetOutputPortRealSignal(S, OUTPORT);
        const real_T  *input_sig = (const real_T *)ssGetInputPortSignal(S, INPUT_SIG);
        if (ssIsSampleHit(S, OutportTid, tid)) {
            int_T i = OutPortWidth;
            while(i-- > 0) {
                *y++ = *input_sig++;           /* get output directly from input */
            }
        }
    }
}       /* End of function mdlOutputs */


/* -------------------------------------- Function mdlTerminate --------------------------- */
static void mdlTerminate(SimStruct *S)
{
}       /* End of function mdlTerminate */


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"    /* Code generation registration function */
#endif
