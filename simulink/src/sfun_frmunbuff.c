/*
 * File : sfun_frmunbuff.c
 * Abstract:
 *    An example of a frame-based unbuffer block. The block helps unbuffer
 *    a multi-channel frame-based signal.
 *
 * Copyright 1990-2004 The MathWorks, Inc.
 * $Revision: 1.6.4.3 $
 */

#define S_FUNCTION_NAME sfun_frmunbuff
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include <string.h>
#include <math.h>
#include "simstruc.h"

#include "sfun_frmunbuff_wrapper.h"

enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

/* Parameters */
enum {NUM_ARGS = 0};

/* Definition of some useful macros */
#define OK_TO_CHECK_VAR(S, ARG) ((ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) \
                                 || !mxIsEmpty(ARG))
#define IS_SCALAR(X)        (mxGetNumberOfElements(X) == 1)
#define IS_VECTOR(X)        ((mxGetM(X) == 1) || (mxGetN(X) == 1))
#define IS_DOUBLE(X)        (!mxIsComplex(X) && !mxIsSparse(X) && mxIsDouble(X))
#define IS_SCALAR_DOUBLE(X) (IS_DOUBLE(X) && IS_SCALAR(X))
#define IS_VECTOR_DOUBLE(X) (IS_DOUBLE(X) && IS_VECTOR(X))
#define THROW_ERROR(S,MSG)  {ssSetErrorStatus(S,MSG); return;}
#define PI 3.14159265358979
#define MAX(a,b) (((a) >= (b)) ? (a) : (b))

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    
    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    /* Set input */
    ssSetInputPortFrameData(         S, INPORT, FRAME_YES);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_NO);
    ssSetInputPortMatrixDimensions(  S ,INPORT, DYNAMICALLY_SIZED, DYNAMICALLY_SIZED);    
    ssSetInputPortSampleTime(        S, INPORT, INHERITED_SAMPLE_TIME);
    ssSetInputPortRequiredContiguous(S, INPORT, 1); 
    ssSetInputPortOverWritable(      S, INPORT, 0);

    /* Set output */
    {
        DECL_AND_INIT_DIMSINFO(oDims);
        int_T dims = DYNAMICALLY_SIZED;
        
        oDims.width   = DYNAMICALLY_SIZED;
        oDims.numDims = 1;
        oDims.dims    = &dims;
        ssSetOutputPortDimensionInfo(S, OUTPORT, &oDims);
    }
    ssSetOutputPortFrameData(    S, OUTPORT, FRAME_NO);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortSampleTime(   S, OUTPORT, INHERITED_SAMPLE_TIME);

    ssSetNumIWork(S, 1);

    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE);
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    int *dims = ssGetInputPortDimensions(S, 0);

    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed.");
    }
    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed.");
    }    

    ssSetInputPortSampleTime(S, INPORT, sampleTime);
    ssSetInputPortOffsetTime(S, INPORT, 0.0);
    
    ssSetOutputPortSampleTime(S, OUTPORT, sampleTime/dims[0]);
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    int *dims = ssGetInputPortDimensions(S, 0);

    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed.");
    }
    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed.");
    }    

    ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);

    ssSetInputPortSampleTime(S, INPORT, sampleTime * dims[0]);
    ssSetInputPortOffsetTime(S, INPORT, 0.0);
    
}
#endif


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *dimsInfo)
{
   
    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
    
    if (ssGetOutputPortWidth(S,port) == DYNAMICALLY_SIZED &&
        dimsInfo->numDims != DYNAMICALLY_SIZED) {
        DECL_AND_INIT_DIMSINFO(oDims);
        int_T dims = dimsInfo->dims[1];
        
        oDims.width   = dimsInfo->dims[1];
        oDims.numDims = 1;
        oDims.dims    = &dims;
        ssSetOutputPortDimensionInfo(S, OUTPORT, &oDims);
    }
}

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *dimsInfo)
{
    int *dims  = ssGetInputPortDimensions(S, 0);
    int oWidth = dimsInfo->width;

    if(!ssSetOutputPortDimensionInfo (S, port, dimsInfo)) return;
    
    if(oWidth != DYNAMICALLY_SIZED &&
       dims[1] == DYNAMICALLY_SIZED && 
       ((dims[0] == 1) || (oWidth == 1))) {
        DECL_AND_INIT_DIMSINFO(iDims);
        int_T dims_new[2];
        int   iWidth = DYNAMICALLY_SIZED;
        
        dims_new[0] = dims[0];
        dims_new[1] = oWidth;

        if (dims_new[0] != DYNAMICALLY_SIZED && dims_new[1] != DYNAMICALLY_SIZED) {
            iWidth = dims_new[0] * dims_new[1];
        }

        iDims.width   = iWidth;
        iDims.dims    = dims_new;
        iDims.numDims = 2;

        if(!ssSetInputPortDimensionInfo(S, port, &iDims)) return;
    } 
}
#endif

static void mdlInitializeSampleTimes(SimStruct *S)
{
    if(ssGetInputPortConnected(S,INPORT) && ssGetOutputPortConnected(S,OUTPORT)) {
        
        /* Check port sample times: */
        const real_T Tsi = ssGetInputPortSampleTime(S, INPORT);     
        const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);   
        
        if ((Tsi == INHERITED_SAMPLE_TIME)  ||                      
            (Tso == INHERITED_SAMPLE_TIME)   ) {                    
            THROW_ERROR(S, "Sample time propagation failed.");        
        }                                                           
        if ((Tsi == CONTINUOUS_SAMPLE_TIME)  ||                         
            (Tso == CONTINUOUS_SAMPLE_TIME)   ) {                       
            THROW_ERROR(S, "Continuous sample times are not allowed.");   
        }                                                               
        ssSetModelReferenceSampleTimeDefaultInheritance(S);
    } 
}

#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    int *dims   = ssGetInputPortDimensions(S, 0);
    int frmSize = dims[0];
    int *count = ssGetIWork(S);
    const boolean_T isMultiTasking = (boolean_T)(ssGetSolverMode(S) == 
                                                 SOLVER_MODE_MULTITASKING);
    if (isMultiTasking) {
        *count = frmSize-1;
    } else {
        *count = 0;        
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int *count  = ssGetIWork(S);
    int *dims   = ssGetInputPortDimensions(S, 0);
    int frmSize = dims[0];
    int nChans  = dims[1];
    real_T *y   = (real_T *)ssGetOutputPortSignal(S,OUTPORT);
    real_T *u   = (real_T *)ssGetInputPortSignal(S,INPORT);   
    const int_T OutportTid  = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    if (ssIsSampleHit(S, OutportTid, tid)) {
        
        sfun_frm_unbuff_wrapper(*count, nChans, frmSize, y, u);

        (*count)++;
        if ((*count) == frmSize) {
            *count = 0;
        }
    }
}

static void mdlTerminate(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
#endif
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
}
#endif

#ifdef	MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif


/* [EOF] sfun_frmunbuff.c */

