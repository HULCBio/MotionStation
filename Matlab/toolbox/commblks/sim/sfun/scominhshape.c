/*
 *  SCOMINHSHAPE C-MEX S-function for inheirting signal shape.
 *  Block has two input ports (Data port and Reference port), and one
 *  output port. The block reshapes the Data input signal using the shape and
 *  frame status of the Reference signal. The Data input can be a real or
 *  complex double signal. Output signal has the same number of elements as
 *  Data input, and has the same shape as Reference input.
 *
 *  Authors: M. Shakeri
 *
 *  Copyright 1996-2004 The MathWorks, Inc.
 *
 *  $Revision: 1.11.4.3 $  $Date: 2004/04/12 23:03:26 $
 */
#define S_FUNCTION_NAME scominhshape
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "comm_mtrx.h"


enum {DATA_INPUT = 0, CTRL_INPUT, NINPUTS};
enum {DATA_OUTPUT = 0, NOUTPUTS};
enum {NUM_PARAMS = 0};


/* Error messages in this file */    
#define COMM_ERR_CTRL_PORT_MATRIX                                              \
  "Input port 2 of this block is a [m x n] matrix signal where m,n > 1. "      \
  "Since the numbers of elements in the two input signals are not the same, "  \
  "the block behavior is undefined."

#define COMM_ERR_1D_FRAME                                                      \
  "Since the Data input is a one-dimensional signal, and the Reference input " \
  "is a scalar frame, the block behavior is undefined."

#define COMM_ERR_CONTINUOUS_FRAME                                              \
  "Since the Data input is a continuous-time signal, and the Reference input " \
  "is a frame signal, the block behavior is undefined."

#define COMM_ERR_INVALID_PORT_DIMENSIONS                                       \
  "Input and output frame status or dimensions are invalid."

#define EDIT_OK(S, ARG) \
       (!((ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ARG)))


#ifdef MATLAB_MEX_FILE 
#define MDL_CHECK_PARAMETERS 
static void mdlCheckParameters(SimStruct *S) 
{
   
}
#endif 

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

    ssSetNumSFcnParams(S, NUM_PARAMS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S); 
    if (ssGetErrorStatus(S) != NULL) return; 
#endif

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES); 

    /* Input: */
    if (!ssSetNumInputPorts(S, 2)) return;
    for(i= 0 ; i < NINPUTS; ++ i){
        if(!ssSetInputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
        ssSetInputPortFrameData(        S, i, FRAME_INHERITED);
        ssSetInputPortComplexSignal(    S, i, COMPLEX_INHERITED);
        ssSetInputPortReusable(         S, i, 1);
        ssSetInputPortSampleTime(       S, i, INHERITED_SAMPLE_TIME);
        ssSetInputPortOffsetTime(       S, i, 0.0);
        ssSetInputPortOverWritable(     S, i, 1);
    }
    ssSetInputPortDirectFeedThrough(S, DATA_INPUT, 1);
    ssSetInputPortDirectFeedThrough(S, CTRL_INPUT, 0);

    
     /* Output: */
    if (!ssSetNumOutputPorts(S,1)) return;
    if(!ssSetOutputPortDimensionInfo(S, DATA_OUTPUT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(        S, DATA_OUTPUT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(    S, DATA_OUTPUT, COMPLEX_INHERITED);
    ssSetOutputPortSampleTime(       S, DATA_OUTPUT, INHERITED_SAMPLE_TIME);
    ssSetOutputPortOffsetTime(       S, DATA_OUTPUT, 0.0);
    ssSetOutputPortReusable(         S, DATA_OUTPUT, 1);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE         |
                    SS_OPTION_CAN_BE_CALLED_CONDITIONALLY );
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    ssSetInputPortSampleTime(S, portIdx, sampleTime);
    ssSetInputPortOffsetTime(S, portIdx, offsetTime);

    if (portIdx==0) {
        
        if(ssGetOutputPortFrameData(S, 0) == FRAME_YES &&
           (sampleTime == CONTINUOUS_SAMPLE_TIME)){
            ssSetErrorStatus(S, COMM_ERR_CONTINUOUS_FRAME);
            return;
        }
        ssSetOutputPortSampleTime(S, 0, sampleTime);
        ssSetOutputPortOffsetTime(S, 0, offsetTime);
    }
}

#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    mdlSetInputPortSampleTime(S, 0, sampleTime, offsetTime);
}
#endif /* MATLAB_MEX_FILE */

static void mdlInitializeSampleTimes(SimStruct *S)
{
#if 0   /* set to 1 to see port sample times */
    const char_T *bpath = ssGetPath(S);
    int_T        i;

    for (i = 0; i < NINPUTS; i++) {
        ssPrintf("%s input port %d sample time = [%g, %g]\n", bpath, i,
                 ssGetInputPortSampleTime(S,i),
                 ssGetInputPortOffsetTime(S,i));
    }

    for (i = 0; i < NOUTPUTS; i++) {
        ssPrintf("%s output port %d sample time = [%g, %g]\n", bpath, i,
                 ssGetOutputPortSampleTime(S,i),
                 ssGetOutputPortOffsetTime(S,i));
    }
#endif

    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int outputTid = ssGetOutputPortSampleTimeIndex(S,0);
    int doOutput  = 0;

    if (outputTid < 0) {
        doOutput = 1; /* triggered */
    } else {
        /* If hit on output port, run it */
        if (ssGetOutputPortSampleTime(S,0)==CONTINUOUS_SAMPLE_TIME) {
            /* continous [0,0] or zohcontinous [0,1] */

            if (ssIsContinuousTask(S,tid)) {
                doOutput = 1;
            }
        } else {
            /* discrete */
            if (ssIsSampleHit(S, outputTid, tid)) {
                doOutput = 1;
            }
        }
    }
     
    if (doOutput) {
        const boolean_T in_place = 	
            (boolean_T)(ssGetInputPortBufferDstPort(S,DATA_INPUT)== DATA_INPUT);
        
        if(!in_place){	
            int_T     width     = ssGetInputPortWidth(S,DATA_INPUT);
            boolean_T isComplex = ssGetInputPortComplexSignal(S, DATA_INPUT) == 
                COMPLEX_YES;
            int_T     elmSize   = ((isComplex)? 2 : 1) * sizeof(double);
            
            InputPtrsType u0Ptr = ssGetInputPortSignalPtrs(S,DATA_INPUT);  
            void          *y    = ssGetOutputPortSignal(S,DATA_INPUT);
            char_T        *yCPtr= (char_T *)y;
            int i;
            
            for (i = 0; i < width; i++) {
                (void)memcpy(yCPtr, u0Ptr[i], elmSize);
                yCPtr += elmSize;
            } 
        }
    }
}

#if defined(MATLAB_MEX_FILE)
/* 
 * Both input port dimensions are known. Set output port dimensions.
 * w: width, n: number of dimensions, d: dimensions
 * 
 *  VALID CASES:
 *   Data port (u0)          |  Control port (u1)    |  Output (y)
 *  ==========================================================================
 *   any signal with w_u0    |  1-D                  |  1-D signal (w_y = w_u0)
 *   1-D or 2-D scalar       |  [1x1]                |  [1x1]
 *   wide signal (non-scalar)|  [1x1]                |  u0
 *   any                     |  [w_u1 x 1] col-vector| [w_u0 x 1]
 *   any                     |  [1 x w_u1] row-vector| [1    x w_u0]
 *   any (w_u0 = m*n)        |  [m x n]              | [m    x n]
 *
 *   Output frame status = Control port frame Status
 *
 *  INVALID CASES:
 *   Data port (u0)          |  Control port (u1)    |  Output (y)
 *  ==========================================================================  
 *   wide 1-D signal         |  [1x1] frame          |  1-D frame (invalid)
 *   any (w_u0 != m*n)       |  [mxn]                |  invalid    
 */
static void  SetOutputPortDimension(SimStruct *S)
{
    DECL_AND_INIT_DIMSINFO(outInfo);
    DECL_AND_INIT_DIMSINFO(u1);

    int_T w_u0  = ssGetInputPortWidth(        S, DATA_INPUT);
    int_T n_u0  = ssGetInputPortNumDimensions(S, DATA_INPUT);
    int_T *d_u0 = ssGetInputPortDimensions(   S, DATA_INPUT);
    
    int_T w_u1  = ssGetInputPortWidth(        S, CTRL_INPUT);
    int_T n_u1  = ssGetInputPortNumDimensions(S, CTRL_INPUT);
    int_T *d_u1 = ssGetInputPortDimensions(   S, CTRL_INPUT);
    
    int_T w_y;
    int_T n_y;
    int_T d_y[2];
    
    ssDimsType_T u1_type;

    /* Find control port dimension type */
    u1.width   = w_u1;
    u1.numDims = n_u1;
    u1.dims    = d_u1;
    u1_type    = GetDimsInfoType(&u1);

    w_y = w_u0;
    switch(u1_type){
      case VECTOR_1D_DIMS:
        n_y    = 1;
        d_y[0] = w_y;
        break;
      case SCALAR_2D_DIMS:
        /* Ctrl port is [1x1] */
        if(w_u0 == 1){ /* data port has one element */
            /* Output is [1x1] */
            n_y    = 2;
            d_y[0] = 1;
            d_y[1] = 1;
        }else{
            /* y = u0 */
            n_y = n_u0;
            if(n_u0 == 2){
                d_y[0] = d_u0[0];
                d_y[1] = d_u0[1];
            }else{
                if(ssGetOutputPortFrameData(S,0) == FRAME_YES){
                    ssSetErrorStatus(S, COMM_ERR_1D_FRAME);
                    goto EXIT_POINT;
                }
                d_y[0] = d_u0[0];
            }
        }
        break;
      case COL_VECTOR_DIMS:
        n_y    = 2;
        d_y[0] = w_y;
        d_y[1] = 1;
        break;
      case ROW_VECTOR_DIMS: 
        n_y    = 2;
        d_y[0] = 1;
        d_y[1] = w_y;
        break;
      case MATRIX_DIMS:
        if(w_u0 == w_u1){
            n_y    = 2;
            d_y[0] = d_u1[0]; 
            d_y[1] = d_u1[1]; 
        }else{
            ssSetErrorStatus(S,COMM_ERR_CTRL_PORT_MATRIX);
            goto EXIT_POINT;
        }
        break;
    }
    
    outInfo.width   = w_y;
    outInfo.numDims = n_y;
    outInfo.dims    = d_y;
    if(!ssSetOutputPortDimensionInfo(S, DATA_OUTPUT, &outInfo)) return;
 EXIT_POINT:
    return;
}

/* 
 * Input and output port dimensions are known. Verify that all port 
 * dimensions are valid.
 */
static void CheckPortDimensions(SimStruct *S) {
    DECL_AND_INIT_DIMSINFO(outInfo);
    DECL_AND_INIT_DIMSINFO(u1);
    
    int_T w_u0  = ssGetInputPortWidth(        S, DATA_INPUT);
    int_T n_u0  = ssGetInputPortNumDimensions(S, DATA_INPUT);
    int_T *d_u0 = ssGetInputPortDimensions(   S, DATA_INPUT);
    
    int_T w_u1  = ssGetInputPortWidth(        S, CTRL_INPUT);
    int_T n_u1  = ssGetInputPortNumDimensions(S, CTRL_INPUT);
    int_T *d_u1 = ssGetInputPortDimensions(   S, CTRL_INPUT);
    
    int_T w_y   = ssGetOutputPortWidth(        S, DATA_OUTPUT);
    int_T n_y   = ssGetOutputPortNumDimensions(S, DATA_OUTPUT);
    int_T *d_y  = ssGetOutputPortDimensions(   S, DATA_OUTPUT);
   
    boolean_T    isOk = true; 
    ssDimsType_T u1_type;
   
    
    /* Find control port dimension type */
    u1.width   = w_u1;
    u1.numDims = n_u1;
    u1.dims    = d_u1;
    u1_type    = GetDimsInfoType(&u1);
    
    /* Consistency checking */
    isOk = (w_y == w_u0);
    if(!isOk) goto EXIT_POINT;

    switch(u1_type){
      case VECTOR_1D_DIMS:
        isOk = (n_y == 1);
        if(!isOk) goto EXIT_POINT;
        
        isOk = (d_y[0] == w_y);
        if(!isOk) goto EXIT_POINT;
        break;
      case SCALAR_2D_DIMS:
        /* Ctrl port is [1x1] */
        if(w_u0 == 1){ /* data port has one element */
            /* Output is [1x1] */
            isOk =  (n_y == 2);
            if(!isOk) goto EXIT_POINT;
            
            isOk = (d_y[0] == 1 &&  d_y[1] == 1);
            if(!isOk) goto EXIT_POINT;
        }else{
            /* y = u0 */
            isOk = (n_y == n_u0);
            if(!isOk) goto EXIT_POINT;
            
            if(n_u0 == 2){
                isOk = (d_y[0] == d_u0[0] && d_y[1] == d_u0[1]);
                if(!isOk) goto EXIT_POINT;
            }else{
                /* no need to check for frame */
                isOk = (d_y[0] == d_u0[0]);
                if(!isOk) goto EXIT_POINT;
            }
        }
        break;
      case COL_VECTOR_DIMS:
        isOk = (n_y == 2);
        if(!isOk) goto EXIT_POINT;
        
        isOk = (d_y[0] == w_y && d_y[1] == 1);
        if(!isOk) goto EXIT_POINT;
        break;
      case ROW_VECTOR_DIMS: 
        isOk = (n_y == 2);
        if(!isOk) goto EXIT_POINT;
        
        isOk = (d_y[0] == 1 && d_y[1] == w_y);
        if(!isOk) goto EXIT_POINT;
        break;
      case MATRIX_DIMS:
        if(w_u0 == w_u1){
            isOk = (n_y == 2);
            if(!isOk) goto EXIT_POINT;
            
            isOk = (d_y[0] == d_u1[0] && d_y[1] == d_u1[1]); 
            if(!isOk) goto EXIT_POINT;
        }else{
            isOk = false;
            goto EXIT_POINT;
        }
        break;
    }
 EXIT_POINT: 
    if(!isOk){
        ssSetErrorStatus(S,COMM_ERR_INVALID_PORT_DIMENSIONS);

    }
    return;
}


#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *dimsInfo)
{
    boolean_T knownInputs = false;

    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    knownInputs = ssGetInputPortWidth(S, DATA_INPUT) != DYNAMICALLY_SIZED &&
                  ssGetInputPortWidth(S, CTRL_INPUT) != DYNAMICALLY_SIZED;

    /* Set output port dimensions if both input ports are known */
    if(!knownInputs) goto EXIT_POINT;

    /* Set or check output port dimensions */
    if(ssGetOutputPortWidth(S, 0) == DYNAMICALLY_SIZED){
        SetOutputPortDimension(S);
        if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;
    }else{ 
        CheckPortDimensions(S);
        if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;
    }

 EXIT_POINT:
    return;
}

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *dimsInfo)
{
    if(!ssSetOutputPortDimensionInfo (S, port, dimsInfo)) return; 
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    boolean_T u0_known =ssGetInputPortWidth(S,DATA_INPUT) != DYNAMICALLY_SIZED;
    boolean_T u1_known =ssGetInputPortWidth(S,CTRL_INPUT) != DYNAMICALLY_SIZED;


        DECL_AND_INIT_DIMSINFO(uInfo);
        int_T dims[2] = {1, 1};
        uInfo.width   = 1;
        uInfo.dims    = dims;

        if(!u0_known){
            Frame_T frame = ssGetInputPortFrameData(S, DATA_INPUT);
            uInfo.numDims = (frame == FRAME_YES) ? 2 : 1;

            mdlSetInputPortDimensionInfo(S, DATA_INPUT, &uInfo);
            if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;
        }
        if(!u1_known){
            Frame_T frame = ssGetInputPortFrameData(S, CTRL_INPUT);
            uInfo.numDims = (frame == FRAME_YES) ? 2 : 1;

            mdlSetInputPortDimensionInfo(S, CTRL_INPUT, &uInfo);
            if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;        
        }

 EXIT_POINT:
    return;
}

#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, 
                                     int_T     port,
                                     Frame_T   frameData)
{
    ssSetInputPortFrameData(S, port, frameData);
    if(port == CTRL_INPUT){
        ssSetOutputPortFrameData(S, 0, frameData);
    }
}

# define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, 
                                         int_T     port,
					 int_T     complexSignal)
{
    ssSetInputPortComplexSignal(S, port, complexSignal);
    if(port == DATA_INPUT){
        ssSetOutputPortComplexSignal(S, 0, complexSignal);
    }
}

# define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, 
                                          int_T     port,
					  int_T     complexSignal)
{
    /* Set complex signal of DATA input and output port */
    ssSetInputPortComplexSignal( S, 0, complexSignal);
    ssSetOutputPortComplexSignal(S, 0, complexSignal);
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

/* [EOF] scominhshape.c */
