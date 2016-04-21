/*
 * SRESHAPE C-MEX S-function for reshaping the input signal.
 *
 *  Input Signal: a vector or matrix.  Can be real or complex with
 *                any Simulink built-in or user defined data type.
 *  Parameter: 1- Output orientation: (1) Unoriendted vector, (2) row vector,
 *                (3) column vector, or (4) Matrix or vector with specified
 *                dimensions
 *             2- Dimensions: This parameter is ignored when Output
 *                orientation is (1) Unoriendted vector, (2) row vector,
 *                (3) column vector.  If the output orientation is "Matrix or
 *                vector", this parameter specifies output port width or
 *                dimensions.
 *
 *  Output Signal: a vector or matrix based on the parameter. Output has the
 *                 same data type and signal type (real/complex) as the input.
 *
 *  Authors: M. Shakeri
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *
 *  $Revision: 1.19.4.7 $  $Date: 2004/04/14 23:50:17 $
 */
#define S_FUNCTION_NAME sreshape
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

enum {UNORIENTED = 1, COL_VECTOR, ROW_VECTOR, MATRIX_OR_VECTOR};
enum {ORIENTATION_IDX,DIMENSIONS_IDX,NUM_PARAMS};
enum {INPORT=0};
enum {OUTPORT=0};

#define ORIENTATION_ARG ssGetSFcnParam(S,ORIENTATION_IDX)
#define MATRIX_ARG      ssGetSFcnParam(S,DIMENSIONS_IDX)

#define IS_OKREAL_PARAM(p) \
(!mxIsSparse(p) && !mxIsEmpty(p) && !mxIsComplex(p) && \
   mxIsDouble(p) && mxIsNumeric(p))

#define EDIT_OK(S, ARG) \
       (!((ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ARG)))

static char *orientationError =
"Invalid value specified for 'Output dimensionality'. 'Output dimensionality' "
"must be a scalar, integer valued of type double. The valid values are 1, 2, "
"3, 4";


static char *dimsError =
"Invalid value specified for 'Output dimensions' parameter. For a "
"one-dimensional array, the 'Output dimensions' parameter must be a positive, "
"scalar, integer valued of type double. For a matrix signal, the parameter "
"must be a positive, integer valued vector of type double and length 2";

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if(EDIT_OK(S,ORIENTATION_ARG)) {
        boolean_T orientationIsOk = false;
        int_T     orientation     = UNORIENTED;

        if(IS_OKREAL_PARAM(ORIENTATION_ARG)) {
            int_T     numElms = mxGetNumberOfElements(ORIENTATION_ARG);
            if(numElms == 1) {
                orientation = (int_T)(mxGetPr(ORIENTATION_ARG)[0]);
                if((real_T)orientation == mxGetPr(ORIENTATION_ARG)[0]) {
                    orientationIsOk = (orientation >= 1 &&  orientation <= 4);
                }
            }
        }

        if(!orientationIsOk) {
            ssSetErrorStatus(S,orientationError);
            return;
        }

        if(EDIT_OK(S, MATRIX_ARG) && (orientation == MATRIX_OR_VECTOR)){
            boolean_T dimsIsOk = false;
            if(IS_OKREAL_PARAM(MATRIX_ARG)) {
                int_T  numElms = mxGetNumberOfElements(MATRIX_ARG);
                if(numElms == 1 || numElms == 2) {
                    int_T m = (int_T)(mxGetPr(MATRIX_ARG)[0]);
                    int_T n = (numElms == 2)?(int_T)(mxGetPr(MATRIX_ARG)[1]): 1;
                    dimsIsOk = !(m < 1 || n < 1 ||
                                 (real_T)m != (mxGetPr(MATRIX_ARG)[0]) ||
                                 ((numElms == 2) &&
                                  (real_T)n !=(int_T)(mxGetPr(MATRIX_ARG)[1])));
                }
            }

            if(!dimsIsOk) {
                ssSetErrorStatus(S,dimsError);
                return;
            }
        }
    }
}
#endif

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_PARAMS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* Cannot change params while running: */
    {
        int i;
        for( i = 0; i < NUM_PARAMS; ++i){
            ssSetSFcnParamTunable(S, i, false);
        }
    }

    /* Input: */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortFrameData(        S, INPORT, FRAME_INHERITED);
    ssSetInputPortDataType(         S, INPORT, DYNAMICALLY_TYPED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortOptimOpts(        S, INPORT, SS_REUSABLE_AND_LOCAL);
    ssSetInputPortOverWritable(     S, INPORT, 1);

     /* Output: */
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortDataType(     S, OUTPORT, DYNAMICALLY_TYPED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortOptimOpts(    S, OUTPORT, SS_REUSABLE_AND_LOCAL);

    /* Input and output dimensions. Output frame Data */
    if(EDIT_OK(S,ORIENTATION_ARG)) {
        int_T     orientation   = (int_T)(mxGetPr(ORIENTATION_ARG)[0]);
        boolean_T outFrmDynamic = true; /* assume */

        switch(orientation){
          case MATRIX_OR_VECTOR:
            {
              int_T      m = 1;
              int_T      n = 1;
              DimsInfo_T input   = {DYNAMICALLY_SIZED, DYNAMICALLY_SIZED, NULL};
              int        numElms = mxGetNumberOfElements(MATRIX_ARG);

              if(EDIT_OK(S, MATRIX_ARG)){
                  m  = (int_T)(mxGetPr(MATRIX_ARG)[0]);
                  n  = (numElms == 2) ? (int_T)(mxGetPr(MATRIX_ARG)[1]) : 1;
              }

              if(numElms == 2) {
                  /* Set the output port dimensions */
                  if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, m, n)) return;
              }else{
                  /* Set the output port width */
                  if(!ssSetOutputPortVectorDimension(S, OUTPORT, m)) return;
                  outFrmDynamic = false; /* Because 1-D vector */
              }

              /* Set the input port dimensions */
              input.numDims = DYNAMICALLY_SIZED;
              input.width   = m * n;
              if(!ssSetInputPortDimensionInfo(S, INPORT, &input)) return;
              break;
          }
          case ROW_VECTOR:
          case COL_VECTOR:
          {
              int_T      m = 1;
              int_T      n = 1;

              if(orientation == COL_VECTOR){
                  m = DYNAMICALLY_SIZED;
              }else{
                  n = DYNAMICALLY_SIZED;
              }
              /* Set the input and output port dimensions */
              if(!ssSetInputPortDimensionInfo(S,INPORT,DYNAMIC_DIMENSION))
                  return;
              if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, m, n)) return;
              break;
          }
          case UNORIENTED:
          {
              /* Set the input and output port dimensions */
              if(!ssSetInputPortDimensionInfo(S,INPORT,DYNAMIC_DIMENSION))
                  return;
              if(!ssSetOutputPortVectorDimension(S,OUTPORT,DYNAMICALLY_SIZED))
                  return;
              outFrmDynamic = false;
          }
          break;
        }
        if (outFrmDynamic) {
            ssSetOutputPortFrameData(S, OUTPORT, FRAME_INHERITED);
        } else {
            ssSetOutputPortFrameData(S, OUTPORT, FRAME_NO);
        }
    }else{
        /* assume UNORIENTED */
        if(!ssSetInputPortDimensionInfo(S,INPORT,DYNAMIC_DIMENSION))  return;
        if(!ssSetOutputPortVectorDimension(S,OUTPORT,DYNAMICALLY_SIZED))  return;
        ssSetOutputPortFrameData(S, OUTPORT, FRAME_NO);
    }

    ssSetNumSampleTimes(S, 1);

    /*
     * Reduce this block if it is in RTW code generation
     */
    if (ssRTWGenIsCodeGen(S) || ssIsExternalSim(S)) {
        ssSetBlockReduction(S, true);
    }

    /*
     * This block can accept partial dimension call.  Simulink may
     * call mdlSetInputPortDimensionInfo or mdlSetOutputPortDimensionInfo
     * with partial information.
     */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_SUPPORTS_ALIAS_DATA_TYPES |
                 SS_OPTION_ALLOW_PARTIAL_DIMENSIONS_CALL |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                 SS_OPTION_CAN_BE_CALLED_CONDITIONALLY |
                 SS_OPTION_NONVOLATILE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



static void mdlOutputs(SimStruct *S, int_T tid)
{

    int_T     width       = ssGetInputPortWidth(S,0);
    DTypeId   dType       = ssGetInputPortDataType(S, 0);
    boolean_T isComplex   = ssGetInputPortComplexSignal(S, 0) == COMPLEX_YES;

    int_T     dTypeSize   = ssGetDataTypeSize(S, dType);
    int_T     elmSize     = ((isComplex)? 2 : 1) * dTypeSize;

    InputPtrsType u0Ptr   = ssGetInputPortSignalPtrs(S,0);
    void          *y      = ssGetOutputPortSignal(S,0);
    char_T        *yCPtr  = (char_T *)y;
    int i;

    UNUSED_ARG(tid); /* not used in single tasking mode */

    if (ssGetInputPortBufferDstPort(S,0) != 0) {
        for (i = 0; i < width; i++) {
            (void)memcpy(yCPtr, u0Ptr[i], elmSize);
            yCPtr += elmSize;
        }
    }
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S,
                                      int_T port,
                                      const DimsInfo_T *dimsInfo)
{

    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    if(ssGetOutputPortWidth(S,port) == DYNAMICALLY_SIZED &&
       dimsInfo->width != DYNAMICALLY_SIZED){

        int_T orientation  = (int_T)(mxGetPr(ORIENTATION_ARG)[0]);
        int_T width        = dimsInfo->width;

        if(orientation == COL_VECTOR){
            if(!ssSetOutputPortMatrixDimensions(S, port, width, 1)) return;
        }else if(orientation == ROW_VECTOR){
            if(!ssSetOutputPortMatrixDimensions(S, port, 1, width)) return;
        }else{ /* it must be UNORIENTED */
            if(!ssSetOutputPortVectorDimension(S, port, width)) return;
        }

    }
}

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S,
                                          int_T            port,
                                          const DimsInfo_T *dimsInfo)
{
    if(!ssSetOutputPortDimensionInfo (S, port, dimsInfo)) return;

    if(ssGetInputPortWidth(S,port) == DYNAMICALLY_SIZED &&
       dimsInfo->width != DYNAMICALLY_SIZED){

        DECL_AND_INIT_DIMSINFO(input);

        input.width   = dimsInfo->width;
        input.dims    = ssGetInputPortDimensions(S, 0);
        input.numDims = ssGetInputPortNumDimensions(S, 0);

        if(!ssSetInputPortDimensionInfo(S, port, &input)) return;
    }
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


# define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    DimsInfo_T inDI;

    DimsInfo_T tmpDims;
    int        dims[2] = {DYNAMICALLY_SIZED, DYNAMICALLY_SIZED};

    inDI.width      = ssGetInputPortWidth(        S, 0);
    inDI.numDims    = ssGetInputPortNumDimensions(S, 0);
    inDI.dims       = ssGetInputPortDimensions(   S, 0);

    tmpDims.width   = DYNAMICALLY_SIZED;
    tmpDims.numDims = DYNAMICALLY_SIZED;
    tmpDims.dims    = dims;

    FillInFullDimensions(&inDI, &tmpDims);

    mdlSetInputPortDimensionInfo(S, 0, &tmpDims);

}

#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S,
                                     int_T     port,
                                     Frame_T   frameData)
{
    ssSetInputPortFrameData(S, port, frameData);

    /* If output is dynamic, apply same frame data to it */
    if (ssGetOutputPortFrameData(S, 0) == FRAME_INHERITED) {
        ssSetOutputPortFrameData(S, 0, frameData);
    }
}
#endif

#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW( SimStruct *S )
{
    UNUSED_ARG(S); /* unused input argument */
}
#endif

static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */
}


#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sreshape.c */
