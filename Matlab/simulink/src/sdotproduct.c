/*
 * SDOTPRODUCT S-Function to compute dot product (multiply-accumulate)
 *      of two real or complex vectors
 *
 *  D. Orofino, 12-97
 *  D. Boghiu,  03-98
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.20.4.3 $  $Date: 2004/04/14 23:49:38 $
 */

#define S_FUNCTION_NAME sdotproduct
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define NUM_PARAMS (0)

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S,  NUM_PARAMS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 2)) return;

    ssSetInputPortDataType(S, 0, DYNAMICALLY_TYPED);
    ssSetInputPortDataType(S, 1, DYNAMICALLY_TYPED);

    if(!ssSetInputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    if(!ssSetInputPortDimensionInfo(S, 1, DYNAMIC_DIMENSION)) return;

    ssSetInputPortFrameData(S, 0, FRAME_INHERITED);
    ssSetInputPortFrameData(S, 1, FRAME_INHERITED);

    ssSetInputPortComplexSignal(S, 0, COMPLEX_INHERITED);
    ssSetInputPortComplexSignal(S, 1, COMPLEX_INHERITED);

    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);

    ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
    ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);

    ssSetInputPortOverWritable(S, 0, 1);
    ssSetInputPortOverWritable(S, 1, 1);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S, 1)) return;

    ssSetOutputPortDataType(S, 0, DYNAMICALLY_TYPED);

    if(!ssSetOutputPortVectorDimension(S, 0, 1)) return;

    ssSetOutputPortFrameData(S, 0, FRAME_NO);

    ssSetOutputPortComplexSignal(S, 0, COMPLEX_INHERITED);

    ssSetOutputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE      |
                 SS_OPTION_CAN_BE_CALLED_CONDITIONALLY |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                 SS_OPTION_NONVOLATILE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


static void SetPortDataType(SimStruct *S, DTypeId dataTypeId )
{
    switch (dataTypeId) {
      case SS_DOUBLE:
      case SS_SINGLE:
        ssSetInputPortDataType( S, 0, dataTypeId);
        ssSetInputPortDataType( S, 1, dataTypeId);
        ssSetOutputPortDataType(S, 0, dataTypeId);
        break;
      default:
        ssSetErrorStatus(S, "Dot product supports double and single"
			 " datatypes only");

    }
}

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int port, DTypeId dType)
{
   SetPortDataType(S, dType);
}

#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int port, DTypeId dType)
{
    SetPortDataType(S, dType);
}

#define MDL_SET_DEFAULT_PORT_DATA_TYPES
static void mdlSetDefaultPortDataTypes(SimStruct *S)
{
    SetPortDataType(S, SS_DOUBLE);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* 
     * detect which inputs are complex or not
     */
    boolean_T u0IsComplex = ssGetInputPortComplexSignal(S, 0) == COMPLEX_YES;
    boolean_T u1IsComplex = ssGetInputPortComplexSignal(S, 1) == COMPLEX_YES;
    boolean_T yIsComplex  = ssGetOutputPortComplexSignal(S, 0)== COMPLEX_YES;

    DTypeId       dType  = ssGetOutputPortDataType(S,0);
    InputPtrsType u0VPtr = ssGetInputPortSignalPtrs(S,0);  
    InputPtrsType u1VPtr = ssGetInputPortSignalPtrs(S,1);
    int_T         width  = ssGetInputPortWidth(S,0);
    int_T         i;

    switch (dType) {
    case (SS_DOUBLE): {
      real_T *y  = (real_T *)ssGetOutputPortSignal(S,0);
      real_T  yr = 0.0;  /* real part of the result */
      real_T  yi = 0.0;  /* imag part of the result */
      InputRealPtrsType u0Ptr = (InputRealPtrsType)u0VPtr;
      InputRealPtrsType u1Ptr = (InputRealPtrsType)u1VPtr;

      if(!yIsComplex){
	/* both inputs are real */	 
	for (i = 0; i < width; i++) {
	  yr += (**u0Ptr++) * (**u1Ptr++);
	}
      } else {
	/* At least one if the inputs is complex. */
	for (i = 0; i < width; i++) {
	  real_T u0r = u0Ptr[i][0];
	  real_T u0i = (u0IsComplex)? - u0Ptr[i][1] : 0.0;
	  real_T u1r = u1Ptr[i][0];
	  real_T u1i = (u1IsComplex)?   u1Ptr[i][1] : 0.0;
	  
	  yr += (u0r * u1r - u0i * u1i);
	  yi += (u0r * u1i + u0i * u1r);
	}
      }
      
      /* Update ouput */
      y[0] = yr;
      if (yIsComplex) {
	y[1] = yi;
      }
    }
    break;

    case (SS_SINGLE): {
      real32_T *y  = (real32_T *)ssGetOutputPortSignal(S,0);
      real32_T  yr = 0.0F;  /* real part of the result */
      real32_T  yi = 0.0F;  /* imag part of the result */

      if(!yIsComplex){
	/* both inputs are real */	 
	for (i = 0; i < width; i++) {
	  const real32_T *u0Ptr = u0VPtr[i];
	  const real32_T *u1Ptr = u1VPtr[i];
	  yr += (*u0Ptr) * (*u1Ptr);
	}
      } else {
	/* At least one if the inputs is complex. */
	for (i = 0; i < width; i++) {
	  const real32_T *u0Ptr = u0VPtr[i];
	  const real32_T *u1Ptr = u1VPtr[i];
	  
	  real32_T u0r = u0Ptr[0];
	  real32_T u0i = (u0IsComplex)? - u0Ptr[1] : 0.0F;
	  real32_T u1r = u1Ptr[0];
	  real32_T u1i = (u1IsComplex)?   u1Ptr[1] : 0.0F;
	  
	  yr += (u0r * u1r - u0i * u1i);
	  yi += (u0r * u1i + u0i * u1r);
	}
      }
      
      /* Update ouput */
      y[0] = yr;
      if (yIsComplex) {
	y[1] = yi;
      }
    }
    break;
    }
}


static void mdlTerminate(SimStruct *S)
{
}

#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_DIMENSION_INFO
 static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *dimsInfo)
{
    boolean_T isNotVector = ((dimsInfo->numDims == 2 ) &&
                             (dimsInfo->dims[0] > 1 && dimsInfo->dims[1] > 1)) ;
    if(isNotVector){
        ssSetErrorStatus(S, "The block only accepts vector signals. "
                            "It does not accept a [mxn] matrix signal "
                            "where m > 1 and n > 1.");
    }else{
        int otherPort = (port == 0) ? 1 : 0;
        if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

        /* 
         * If other port width is unknown, set the other port width.
         * Note1: we cannot update other port dimension info. 
         * Note2: For simplicity, this block cannot accept partial dimension,
         *        however, it may partially set other port dimension info.
         */
        if(ssGetInputPortWidth(S, otherPort) == DYNAMICALLY_SIZED &&
           ssGetInputPortWidth(S, port)      != DYNAMICALLY_SIZED){

            DECL_AND_INIT_DIMSINFO(dimsInfo);
            dimsInfo.width   = ssGetInputPortWidth        (S, port);
            dimsInfo.numDims = ssGetInputPortNumDimensions(S, otherPort);
            dimsInfo.dims    = ssGetInputPortDimensions   (S, otherPort);

            if(!ssSetInputPortDimensionInfo(S, otherPort, &dimsInfo)) return;

        }
    }
}

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *dimsInfo)
{
    /* This should never occur! */
    ssSetErrorStatus(S, "Error setting output port width.");
}

static void FillInFullDimensions(const DimsInfo_T *di,
                                 DimsInfo_T       *newDI)
{
    int k;

    newDI->width = (di->width == DYNAMICALLY_SIZED) ? 1 : 
                   di->width;
    
    if (di->width   == DYNAMICALLY_SIZED &&
        di->numDims == DYNAMICALLY_SIZED) {
        newDI->width   = 1;
        newDI->numDims = 1;
        newDI->dims[0] = 1;
    } else if (di->numDims == DYNAMICALLY_SIZED) {
        newDI->width   = di->width;
        newDI->numDims = 1;
        newDI->dims[0] = di->width;
    } else if (di->width == DYNAMICALLY_SIZED) {
        newDI->width   = 1;
        newDI->numDims = di->numDims;
        for (k = 0; k < newDI->numDims; k++) {
            newDI->dims[k] = 1;
        }
    } else {
        newDI->width   = di->width;
        newDI->numDims = di->numDims;
        newDI->dims[0] = di->width;
        for (k = 1; k < newDI->numDims; k++) {
            newDI->dims[k] = 1;
        }
    }
}

static bool IsFullInfo(const DimsInfo_T *dI)
{
    bool retVal = true;
    int  k;
    
    if (dI->width == DYNAMICALLY_SIZED || 
        dI->numDims == DYNAMICALLY_SIZED) {
        retVal = false;
        goto EXIT_POINT;
    }
    
    for (k = 0; k < dI->numDims; k++) {
        if (dI->dims[k] == DYNAMICALLY_SIZED) {
            retVal = false;
            goto EXIT_POINT;
        }
    }
 EXIT_POINT:
    return(retVal);
}

# define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    DimsInfo_T inDI;
    int        k;
    
    for (k = 0; k < 2; k++) {
        inDI.width      = ssGetInputPortWidth(        S, k);
        inDI.numDims    = ssGetInputPortNumDimensions(S, k);
        inDI.dims       = ssGetInputPortDimensions(   S, k);
        
        if (!IsFullInfo(&inDI)) {
            DimsInfo_T tmpDims;
            int        dims[2] = {DYNAMICALLY_SIZED, DYNAMICALLY_SIZED};
            
            tmpDims.width   = DYNAMICALLY_SIZED;
            tmpDims.numDims = DYNAMICALLY_SIZED;
            tmpDims.dims    = dims;
            
            FillInFullDimensions(&inDI, &tmpDims);
            
            mdlSetInputPortDimensionInfo(S, k, &tmpDims);
        }
    }
}


# define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct  *S, 
                                     int_T      port,
                                     Frame_T    frameData)
{
    /* Accept frame status silently */
    ssSetInputPortFrameData(S, port, frameData);
}

# define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, 
                                         int_T     port,
					 int_T iPortComplexSignal)
{
    int_T oPortComplexSignal = ssGetOutputPortComplexSignal(S,0);

    /* Set the complex signal of the input ports */
    ssSetInputPortComplexSignal(S, port, iPortComplexSignal);
    
    if(iPortComplexSignal == COMPLEX_YES){
        /* Output port must be a complex signal */
        if(oPortComplexSignal == COMPLEX_INHERITED){
            ssSetOutputPortComplexSignal(S, 0, COMPLEX_YES);
        }else if(oPortComplexSignal == COMPLEX_NO){
	    ssSetErrorStatus(S, "Output port must be complex.");
        }
    }else if(oPortComplexSignal != COMPLEX_NO){ 
	/* 
	 * The current input port is a real signal.  If the other input port 
	 * is a real signal, the output port must be a real signal.
	 */
	int_T otherPort = (port == 0)? 1 : 0;
	int_T otherPortComplexSignal = 
                         ssGetInputPortComplexSignal(S, otherPort);
	if(otherPortComplexSignal == COMPLEX_NO){
            /* Both input ports are real signals */
            if(oPortComplexSignal == COMPLEX_INHERITED){            
                ssSetOutputPortComplexSignal(S, 0, COMPLEX_NO);           
            }else if(oPortComplexSignal == COMPLEX_YES){
		ssSetErrorStatus(S, "Output port must be real.");
	    }           
	}
    }
}

# define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T port,
					  int_T  oPortComplexSignal)
{
    /* Set the complex signal of the output ports */
    ssSetOutputPortComplexSignal(S, 0, oPortComplexSignal);

    if(oPortComplexSignal == COMPLEX_NO){
        /* All inputs must be real */
        int_T i;
        
        for (i = 0; i < 2; i++) {
            int_T iPortComplexSignal = ssGetInputPortComplexSignal(S, i);
            if(iPortComplexSignal == COMPLEX_INHERITED){
                ssSetInputPortComplexSignal(S, i, COMPLEX_NO);
            } else if(iPortComplexSignal == COMPLEX_YES){
		ssSetErrorStatus(S, "The output port is a 'real' signal. "
		                    "All input ports must be 'real' signals.");
            }
        }
    }else{ 
        /* 
         * Output port is a complex signal.  Report an error, if all 
         * inputs are real. 
         */
	int_T i;
        boolean_T realInputs = true;
        for (i = 0; i < 2; i++) {
            if(ssGetInputPortComplexSignal(S, i) != COMPLEX_NO){
		realInputs = false;
		break;
	    }
	}
	if(realInputs){
            ssSetErrorStatus(S, "Input port and output port complex signal "
				"mismatch. All input ports are 'real' signal. "
				"The output port must be a 'real' signal.");
        }
    }
}
#endif /* MATLAB_MEX_FILE */


/* Required S-function trailer */

#ifdef	MATLAB_MEX_FILE
#include "simulink.c"    
#else
#include "cg_sfun.h"     
#endif

/* eof: sdotproduct.c */
