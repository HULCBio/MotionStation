/*
 *   SCOMSELECT - Communications Blockset S-function
 *   for implementing puncture and insert zero blocks.
 *
 *   Copyright 1996-2004 The MathWorks, Inc.
 *   $Revision: 1.9.4.3 $
 *   $Date: 2004/04/12 23:03:39 $
 *   Author: Mojdeh Shakeri
 */

#define S_FUNCTION_NAME  scomselect
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "comm_mtrx.h"
/* Compile with "mex scomselect.c comm_mtrx.c" */

enum{
    ELEMENTS_ARGC = 0,    
    METHOD_ARGC,
    NUM_ARGS
};

enum {INPORT = 0, NUM_INPORTS};
enum {OUTPORT = 0, NUM_OUTPORTS};

typedef enum{
    PUNCTURE = 1,
    INSERT_ZERO
}method_T;

#define ELEMENTS_ARG    ssGetSFcnParam(S, ELEMENTS_ARGC)
#define METHOD_ARG      ssGetSFcnParam(S, METHOD_ARGC)


/* Frame signal */
#define COMM_ERR_FRM_INVALID_INPUT_PUNCTURE                                 \
  "Invalid dimensions are specified for the input port of the block. "      \
  "The number of elements in the input signal must be an integer multiple " \
  "of the parameter length."

#define COMM_ERR_FRM_INVALID_OUTPUT_PUNCTURE                                 \
  "Invalid dimensions are specified for the output port of the block. "      \
  "The number of elements in the output signal must be an integer multiple " \
  "of the number of ones in the parameter vector."

#define COMM_ERR_FRM_INVALID_INPUT_INSERT_ZERO                               \
  "Invalid dimensions are specified for the input port of the block. "       \
  "The number of elements in the input signal must be an integer multiple "  \
  "of the number of ones in the parameter vector."

#define COMM_ERR_FRM_INVALID_OUTPUT_INSERT_ZERO                              \
  "Invalid dimensions are specified for the output port of the block. "      \
  "The number of elements in the output signal must be an integer multiple " \
  "of the parameter length."

/* Non-Frame signal */
#define COMM_ERR_NONFRM_INVALID_INPUT_PUNCTURE                          \
  "Invalid dimensions are specified for the input port of the block. "  \
  "The number of elements in the input signal must be the same as "     \
  "the parameter length."

#define COMM_ERR_NONFRM_INVALID_OUTPUT_PUNCTURE                          \
  "Invalid dimensions are specified for the output port of the block. "  \
  "The number of elements in the output signal must be the same as "     \
  "the number of ones in the parameter vector."

#define COMM_ERR_NONFRM_INVALID_INPUT_INSERT_ZERO                       \
  "Invalid dimensions are specified for the input port of the block. "  \
  "The number of elements in the input signal must be the same as "     \
  "the number of ones in the parameter vector."

#define COMM_ERR_NONFRM_INVALID_OUTPUT_INSERT_ZERO                      \
  "Invalid dimensions are specified for the output port of the block. " \
  "The number of elements in the output signal must be the same as "    \
  "the parameter length."

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
    {
        if (!ssSetNumInputPorts(S, 1)) return;
        if(!ssSetInputPortDimensionInfo( S, 0, DYNAMIC_DIMENSION)) return;
        ssSetInputPortFrameData(         S, 0, FRAME_INHERITED);
        ssSetInputPortDirectFeedThrough( S, 0, 1);
        ssSetInputPortReusable(          S, 0, 1);
        ssSetInputPortComplexSignal(     S, 0, COMPLEX_INHERITED);
        ssSetInputPortSampleTime(        S, 0, INHERITED_SAMPLE_TIME);
        

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
    int_T             i,j,k;
    const real_T      *elements = mxGetPr(ELEMENTS_ARG);
    InputRealPtrsType uPtrs     = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y        = ssGetOutputPortRealSignal(S,0);
    int_T             yWidth    = ssGetOutputPortWidth(S,0);
    int_T             uWidth    = ssGetInputPortWidth(S,0);
    int_T             numElms   = mxGetNumberOfElements(ELEMENTS_ARG);
    method_T          method    = (method_T)(mxGetPr(METHOD_ARG)[0]); 
    boolean_T         isComplex = ssGetInputPortComplexSignal(S, 0) == 
                                                   COMPLEX_YES;
    int_T             elmSize   = ((isComplex)? 2 : 1) * sizeof(real_T);

    switch(method){
      case PUNCTURE:
          {
              char_T *yCPtr  = (char_T *)y;
              for(i = 0, k = 0, j = 0; i < uWidth; ++i, ++k){
                  int_T kn = k % numElms;
                  if(elements[kn] == 0) continue;
                  
                  (void)memcpy(yCPtr, uPtrs[i], elmSize);
                  yCPtr += elmSize;
              }
              break;
          }
      case INSERT_ZERO:
          {
              (void)memset(y, 0, elmSize*yWidth);
              for(i = 0, k = 0, j = 0; j < yWidth; ++j, ++k){
                  char_T   *yCPtr;
                  int_T    kn = k % numElms;

                  if(elements[kn] == 0) continue;

                  yCPtr  = (char_T *)y + (j*elmSize);
                  (void)memcpy(yCPtr, uPtrs[i++], elmSize);
              }
              break;
          }
    }
}


static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE

static int_T GetNumOfElementsParam(SimStruct *S)
{
    int_T  num  = mxGetNumberOfElements(ELEMENTS_ARG);
    return num;
}

static int_T GetSumOfElementsParam(SimStruct *S)
{
    int_T  num  = mxGetNumberOfElements(ELEMENTS_ARG);
    int_T  sum = 0;
    real_T *pr = mxGetPr(ELEMENTS_ARG);
    int_T  i;
    for( i = 0; i < num; ++i){
        sum += (((int_T)(pr[i]) == 1)? 1: 0);
    }
    return sum;
}


/* Function: CheckPortDimensions ==========================================
 * Abstract: Check the port dimension info and report an error if necessary.
 */
static void CheckPortDimensions(SimStruct        *S,
                                PortType_T       portType,
                                const DimsInfo_T *thisInfo,
                                boolean_T        isPuncture)
{
    ssDimsType_T  dimsType   = GetDimsInfoType(thisInfo);

    /* 
     * Single-input/Single-output. 
     * Input and output frame status are the same.
     */
    const Frame_T   frameData = ssGetInputPortFrameData( S, 0);

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

    {
        int_T     width      = thisInfo->width;
        boolean_T isInput    = (portType == IS_INPORT);
        int_T     paramWidth = mxGetNumberOfElements(ELEMENTS_ARG);

        if((isInput && isPuncture) || (!isInput && !isPuncture)){
            int_T     num  = GetNumOfElementsParam(S);
            boolean_T isOk = (width % num) == 0;
            if(frameData == FRAME_NO && isOk){
                isOk = (width == num);
            }
           
            if(!isOk){
                if((portType == IS_INPORT)){ /* Puncture */
                    ssSetErrorStatus(S, ((frameData == FRAME_YES) ? 
                                  COMM_ERR_FRM_INVALID_INPUT_PUNCTURE:
                                  COMM_ERR_NONFRM_INVALID_INPUT_PUNCTURE));
                }else{ /* Insert zero */
                    ssSetErrorStatus(S, ((frameData == FRAME_YES) ? 
                                  COMM_ERR_FRM_INVALID_OUTPUT_INSERT_ZERO:
                                  COMM_ERR_NONFRM_INVALID_OUTPUT_INSERT_ZERO));
                }
            }
        }else{
            int_T     sum  = GetSumOfElementsParam(S);
            boolean_T isOk = (width % sum) == 0;
            if(frameData == FRAME_NO && isOk){
                isOk = (width == sum);
            }
            if(!isOk){
                if((portType == IS_OUTPORT)){ /* Puncture */
                    ssSetErrorStatus(S, ((frameData == FRAME_YES) ? 
                                   COMM_ERR_FRM_INVALID_OUTPUT_PUNCTURE:
                                   COMM_ERR_NONFRM_INVALID_OUTPUT_PUNCTURE));  
                }else{ /* Insert zero */
                    ssSetErrorStatus(S, ((frameData == FRAME_YES) ? 
                                   COMM_ERR_FRM_INVALID_INPUT_INSERT_ZERO:
                                   COMM_ERR_NONFRM_INVALID_INPUT_INSERT_ZERO));
                }
            }
        }
    }

 EXIT_POINT:
    return;
}


#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *thisInfo)
{
    const method_T  method      = (method_T)(mxGetPr(METHOD_ARG)[0]); 
    const boolean_T isPuncture  = (method == PUNCTURE);
    const int32_T   numElms     = GetNumOfElementsParam(S);
    const int32_T   sumElms     = GetSumOfElementsParam(S);
    const int32_T   thisFactor  = (isPuncture) ? numElms : sumElms;
    const int32_T   otherFactor = (isPuncture) ? sumElms : numElms;
    
    
    /* Check input port dimensions */
    CheckPortDimensions(S, IS_INPORT, thisInfo, isPuncture);
    if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;
    
    /* Set input and output port dimensions */
    CommSetInputAndOutputPortDimsInfo(S,port,IS_INPORT,thisFactor,
                                      thisInfo,otherFactor);

 EXIT_POINT:
    return;
}

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *thisInfo)
{
    const method_T  method      = (method_T)(mxGetPr(METHOD_ARG)[0]); 
    const boolean_T isPuncture  = (method == PUNCTURE);
    const int32_T   numElms     = GetNumOfElementsParam(S);
    const int32_T   sumElms     = GetSumOfElementsParam(S);
    const int32_T   thisFactor  = (isPuncture) ? sumElms : numElms;
    const int32_T   otherFactor = (isPuncture) ? numElms : sumElms;
    
    /* Check input port dimensions */
    CheckPortDimensions(S, IS_OUTPORT, thisInfo, isPuncture);
    if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;
    
    /* Set input and output port dimensions */
    CommSetInputAndOutputPortDimsInfo(S,port,IS_OUTPORT,thisFactor,
                                      thisInfo,otherFactor);

 EXIT_POINT:
    return;
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    boolean_T       portDimsKnown = true;
    const method_T  method        = (method_T)(mxGetPr(METHOD_ARG)[0]); 
    const boolean_T isPuncture    = (method == PUNCTURE);
    const int32_T   numElms       = GetNumOfElementsParam(S);
    const int32_T   sumElms       = GetSumOfElementsParam(S);
    const int32_T   thisFactor    = (isPuncture) ? numElms : sumElms;
    
    DECL_AND_INIT_DIMSINFO(dInfo);
    int_T           dims[2] = {1, 1};
    dInfo.dims = dims;
    
    portDimsKnown =GetDefaultInputDimsIfPortDimsUnknown(S,0,thisFactor,&dInfo);
    if(!portDimsKnown){
        /* This will set the output port dimensions */
        mdlSetInputPortDimensionInfo(S, 0, &dInfo);
    }
}

#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, 
                                     int_T     port,
                                     Frame_T   frameData)
{
    ssSetInputPortFrameData( S, port, frameData);
    ssSetOutputPortFrameData(S, port, frameData);
}
#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif
