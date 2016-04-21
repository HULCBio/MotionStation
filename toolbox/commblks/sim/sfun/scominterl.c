/*
 *   SCOMINTERL - Communications Blockset S-function
 *   for interleaver and deinterleaver blocks.
 *
 *   Copyright 1996-2004 The MathWorks, Inc.
 *   $Revision: 1.9.4.3 $
 *   $Date: 2004/04/12 23:03:27 $
 *   Author: Mojdeh Shakeri
 */

#define S_FUNCTION_NAME  scominterl
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "comm_mtrx.h"
/* Compile with "mex scominterl.c comm_mtrx.c" */

enum{
    ELEMENTS_ARGC = 0,    
    METHOD_ARGC,
    NUM_ARGS
};

enum {INPORT = 0, NUM_INPORTS};
enum {OUTPORT = 0, NUM_OUTPORTS};

typedef enum{
    INTERLEAVE = 1,
    DEINTERLEAVE
}method_T;

#define ELEMENTS_ARG    ssGetSFcnParam(S, ELEMENTS_ARGC)
#define METHOD_ARG      ssGetSFcnParam(S, METHOD_ARGC)

#define COMM_ERR_INTERLEAVE_INVALID_DIMS                     \
  "Invalid dimensions are specified for the input or "       \
  "output port of the block. The number of elements in the " \
  "input and output signals must match the length of "       \
  "the Elements parameter."

#define EDIT_OK(S, ARG) \
   (!((ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY) &&  mxIsEmpty(ARG)))


/* Parameter check for limited frame support */
static void checkParam(SimStruct *S)
{
    const int_T  isFrame   = ssGetInputPortFrameData(S, INPORT);
    const int_T *paramDims = mxGetDimensions(ELEMENTS_ARG);

    if (isFrame && (paramDims[1] != 1)) {
        ssSetErrorStatus(S, 
            "Parameter must be a column vector in frame-based mode.");
    }
}


#ifdef MATLAB_MEX_FILE 
#define MDL_CHECK_PARAMETERS 
static void mdlCheckParameters(SimStruct *S) 
{ 
    /* mask will check the parameters */
}
#endif 


static void mdlInitializeSizes(SimStruct *S) 
{ 
    int i;
    /* Parameters: */ 
    ssSetNumSFcnParams(S, NUM_ARGS); 

#if defined(MATLAB_MEX_FILE) 
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return; 
    mdlCheckParameters(S); 
    if (ssGetErrorStatus(S) != NULL) return; 
#endif 

    /* Cannot change params while running: */
    for( i = 0; i < NUM_ARGS; ++i){
        ssSetSFcnParamNotTunable(S, i);
    }
    
    ssSetNumSampleTimes(S, 1); 

    /* Inputs and Outputs */ 
    if (!ssSetNumInputPorts(S, 1)) return;
    if(!ssSetInputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(        S, 0, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortReusable(         S, 0, 1);
    ssSetInputPortComplexSignal(    S, 0, COMPLEX_INHERITED);
    ssSetInputPortSampleTime(       S, 0, INHERITED_SAMPLE_TIME);
    
    /* Outputs: */ 
    if (!ssSetNumOutputPorts(S, 1)) return; 
    if(!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(        S, 0, FRAME_INHERITED);
    ssSetOutputPortReusable(         S, 0, 1);
    ssSetOutputPortComplexSignal(    S, 0, COMPLEX_INHERITED);
    ssSetOutputPortSampleTime(       S, 0, INHERITED_SAMPLE_TIME);
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE         |
                    SS_OPTION_CAN_BE_CALLED_CONDITIONALLY );
}
  

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    checkParam(S);
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T            *elements = (real_T *)mxGetPr(ELEMENTS_ARG);
    InputRealPtrsType uPtrs     = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y        = ssGetOutputPortRealSignal(S,0);
    int_T             yWidth    = ssGetOutputPortWidth(S,0);
    method_T          method    = (method_T)(mxGetPr(METHOD_ARG)[0]); 
    boolean_T         isComplex = ssGetInputPortComplexSignal(S, 0) == 
                                    COMPLEX_YES;
    int_T             elmSize   = ((isComplex)? 2 : 1) * sizeof(real_T);
    int_T             i;

    switch(method){
      case INTERLEAVE:
          {
              char_T *yCPtr = (char_T *)y;

              for(i = 0; i < yWidth; ++i){
                  (void)memcpy(yCPtr, uPtrs[(int_T)elements[i]-1], elmSize);
                  yCPtr += elmSize;
              }
              break;
          }
      case DEINTERLEAVE:
          {
              for(i = 0; i < yWidth; ++i){
                  char_T *yCPtr = (char_T *)y + ((int_T)elements[i]-1)*elmSize;
                  (void)memcpy(yCPtr, uPtrs[i], elmSize);
              }
              break;
          }
    }
}


static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE
/* Function: CheckPortDimensions ==========================================
 * Abstarct: Error out if the port dimensions are not valid.
 */
static void CheckPortDimensions(SimStruct        *S,
                                const DimsInfo_T *thisInfo)
{
    int_T         paramWidth = mxGetNumberOfElements(ELEMENTS_ARG);
    ssDimsType_T  dimsType   = GetDimsInfoType(thisInfo);

    /* Single-input/Single-output. Input and output frame status are the same */
    const Frame_T frameData  = ssGetInputPortFrameData( S, 0);

    if(dimsType == N_D_ARRAY_DIMS){
        ssSetErrorStatus(S, COMM_ERR_INVALID_N_D_ARRAY);
        goto EXIT_POINT;
    }
    
    if(frameData == FRAME_NO){
        if(dimsType == MATRIX_DIMS){
            ssSetErrorStatus(S, COMM_ERR_INVALID_MATRIX);
            goto EXIT_POINT;
        }
    }else{ /* Frame signal */
        if(dimsType == MATRIX_DIMS || dimsType == ROW_VECTOR_DIMS){
            ssSetErrorStatus(S, COMM_ERR_INVALID_MULTI_CHANNEL);
            goto EXIT_POINT;
        }
    }

    if(thisInfo->width != paramWidth){
        ssSetErrorStatus(S, COMM_ERR_INTERLEAVE_INVALID_DIMS);
        goto EXIT_POINT;
    }

 EXIT_POINT:
    return;
}

static void CheckAndSetPortDimensions(SimStruct        *S, 
                                      const DimsInfo_T *thisInfo)
{
    CheckPortDimensions(S, thisInfo);
    if(ssGetErrorStatus(S) != NULL) return;

    if(!ssSetInputPortDimensionInfo( S, 0, thisInfo)) return;
    if(!ssSetOutputPortDimensionInfo(S, 0, thisInfo)) return;
}

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *thisInfo)
{
    (void) port; /* unused */
    CheckAndSetPortDimensions(S, thisInfo);
}

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *thisInfo)
{
    (void) port; /* unused */
    CheckAndSetPortDimensions(S, thisInfo);
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    int_T         paramWidth = mxGetNumberOfElements(ELEMENTS_ARG);
    const Frame_T frameData  = ssGetInputPortFrameData( S, 0);

    if(frameData == FRAME_YES){
        /* Set input and output dimensions to column-vector */
        if(!ssSetInputPortMatrixDimensions( S, 0, paramWidth,1)) return;
        if(!ssSetOutputPortMatrixDimensions(S, 0, paramWidth,1)) return;
    }else{
        /* Set input and output dimensions to 1-D vector */
        if(!ssSetInputPortVectorDimension(  S, 0, paramWidth)) return;
        if(!ssSetOutputPortVectorDimension( S, 0, paramWidth)) return;
    }
}

#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, 
                                     int_T     port,
                                     Frame_T   frameData)
{
    (void) port;
    /* Single-input single-output block */
    ssSetInputPortFrameData( S, 0, frameData);
    ssSetOutputPortFrameData(S, 0, frameData);
}
#endif


#ifdef  MATLAB_MEX_FILE
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif
