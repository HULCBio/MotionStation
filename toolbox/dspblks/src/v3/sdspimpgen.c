/*
 * SDSPIMPGEN DSP Blockset S-Function to generate a frame-based discrete impulse.
 *
 *  The delay indicates the number of zeros preceeding the discrete impulse.
 *  The output can be Double, Single, or Boolean.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.10 $  $Date: 2002/04/14 20:44:24 $
 */
#define S_FUNCTION_LEVEL 2 
#define S_FUNCTION_NAME  sdspimpgen

#include "dsp_sim.h"

enum {NUM_INPORTS=0};
enum {OUTPORT=0, NUM_OUTPORTS};

enum {COUNT_IDX=0, NUM_DWORK};
enum {DELAY_ARGC=0, SAMP_TIME_ARGC, FRAME_ARGC, DATA_TYPE_ARGC, NUM_PARAMS};

#define DELAY_ARG       (ssGetSFcnParam(S, DELAY_ARGC))
#define SAMP_TIME_ARG   (ssGetSFcnParam(S, SAMP_TIME_ARGC))
#define FRAME_ARG       (ssGetSFcnParam(S, FRAME_ARGC))
#define DATA_TYPE_ARG   (ssGetSFcnParam(S, DATA_TYPE_ARGC))

typedef enum {
    fcnDouble = 1,
    fcnSingle,
    fcnBoolean
} OutType;


/* getOutputDTypeFromArgs
 * Determine the output datatype from the input arguments.
 */
static BuiltInDTypeId getOutputDTypeFromArgs(SimStruct *S)
{ 
    OutType  oType  = (OutType)((int_T)(mxGetPr(DATA_TYPE_ARG)[0])); 
    BuiltInDTypeId dType;

    if      (oType == fcnDouble) dType = SS_DOUBLE;
    else if (oType == fcnSingle) dType = SS_SINGLE;
    else                         dType = SS_BOOLEAN;

    return(dType);
}


/*  getMaxDelayArg
 *  Get the maximum delay element
 */
static real_T getMaxDelayArg(SimStruct *S)
{
    /* Safe for even an empty DELAY_ARG */
    const int_T NumEle   = mxGetNumberOfElements(DELAY_ARG);
    real_T     *delays   = mxGetPr(DELAY_ARG);
    real_T      MaxDelay = 0;  /* This is the minimum we can expect in DELAY_ARG */
    int_T       i;

    for (i=0; i<NumEle; i++) {
        MaxDelay = MAX(MaxDelay, delays[i]);
    }

    return(MaxDelay);
}


/*  getDWorkDType
 *  Determine the DWork storage datatype based on the maximum delay element
 */
static BuiltInDTypeId getDWorkDType(SimStruct *S)
{
    const real_T   delay = getMaxDelayArg(S);
    BuiltInDTypeId dWorkType;

    /*
     *  Since we need to add ONE to the delay, we must be very careful
     *  of the data types.  For example, an 8-bit integer can only hold
     *  255, so the user-delay can be 254 maximum before we add one...
     */
    if      (delay < MAX_uint8_T)  dWorkType = SS_UINT8;
    else if (delay < MAX_uint16_T) dWorkType = SS_UINT16;
    else if (delay < MAX_uint32_T) dWorkType = SS_UINT32;
    else                           dWorkType = SS_DOUBLE;
        
    return(dWorkType);
}


/* Preset DWork/COUNT_IDX to (delay + 1) so that we can output
 * the impulse when the decremented COUNT_IDX equals one.
 *
 * This allows us to also stop decrementing the COUNT_IDX once
 * it equals zero.
 */
#define InitializeDWork(dWorkType) {                            \
    dWorkType  *pDWork = (dWorkType *)ssGetDWork(S, COUNT_IDX); \
    const int_T NumEle = mxGetNumberOfElements(DELAY_ARG);      \
    real_T     *pDelay = mxGetPr(DELAY_ARG);                    \
    int_T       i;                                              \
                                                                \
    for (i=0;i<NumEle;i++) {                                    \
            *pDWork++ = (dWorkType)(*pDelay++ + 1);             \
    }                                                           \
}


/*
 * ImpulseGen:
 *   Output 1 when the COUNT_IDX counts down to one.
 *   Output 0 before and after that count.
 *
 * If the COUNT_IDX is a positive number and does not equal 1, then   
 * the expresion is false and we output a zero and decrement the    
 * COUNT_IDX.  If the COUNT_IDX equals 1, then the expression is true    
 * and we output a 1 and decrement the COUNT_IDX.  When the COUNT_IDX   
 * is not true i.e. equal to zero, then we output a zero and        
 * DO NOT decrement the COUNT_IDX.
 *
 */
#define ImpulseGen(outType, dWorkType) {                                     \
    outType    *y      = (outType *)ssGetOutputPortSignal(S,OUTPORT);        \
    const int_T nChans = mxGetNumberOfElements(DELAY_ARG);                   \
    dWorkType  *cnt    = (dWorkType *)ssGetDWork(S, COUNT_IDX);              \
    int_T       frameSize  = (int_T)ssGetOutputPortWidth(S,OUTPORT)/nChans;  \
    int_T       i,j;                                                         \
                                                                             \
    for (i=0; i++ < nChans;) {                                               \
      for (j=0; j++ < frameSize;) {                                          \
            *y++ = (*cnt != 0) ? (outType)((*cnt)-- == (dWorkType)1) : (outType)0;   \
      }                                                                      \
      cnt++;                                                                 \
    }                                                                        \
}


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters (SimStruct *S)
{
    if (!IS_VECTOR_DOUBLE(DELAY_ARG)) {
            THROW_ERROR(S,"The delay argument must contain real integer values >= 0.");
    }
    
    {
        int_T numEle = mxGetNumberOfElements(DELAY_ARG);
        int_T i;
        
        /* Check that all delays are >= 0: */
        for (i=0; i<numEle; i++) {
            if (!IS_IDX_FLINT_GE(DELAY_ARG,i,0)) {
                THROW_ERROR(S, "The delay argument must contain integer values >= 0.");
            }
        }
    }

    /* Sample Time: */
    if (OK_TO_CHECK_VAR(S, SAMP_TIME_ARG)) {
        if (!IS_SCALAR(SAMP_TIME_ARG) || (mxGetPr(SAMP_TIME_ARG) [0] <= 0.0)) {
            THROW_ERROR(S, "The sample time must be a positive scalar > 0.");
        }
    }

    /* Samples per frame: */
    if (!IS_FLINT_GE(FRAME_ARG,1)) {
       THROW_ERROR(S, "The number of samples per frame must be an integer-valued scalar > 0.");
    }  

    /* Datatype */
    if (!IS_FLINT_IN_RANGE(DATA_TYPE_ARG,1,3)) {
        THROW_ERROR(S,"Output datatype must be a double (1), single (2) or a boolean (3).");
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S) 
{ 
    int_T nchans;
    ssSetNumSFcnParams(S, NUM_PARAMS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    nchans = mxGetNumberOfElements(DELAY_ARG);
    
    ssSetSFcnParamNotTunable(S, DELAY_ARGC);
    ssSetSFcnParamNotTunable(S, SAMP_TIME_ARGC);
    ssSetSFcnParamNotTunable(S, FRAME_ARGC);
    ssSetSFcnParamNotTunable(S, DATA_TYPE_ARGC);

    /* Inputs: */
    if (!ssSetNumInputPorts(S,NUM_INPORTS)) return;
    
    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    {
        int_T framesize = (int_T)mxGetPr(FRAME_ARG)[0];

        ssSetOutputPortWidth(S, OUTPORT, nchans*framesize);
    }
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortDataType(     S, OUTPORT, getOutputDTypeFromArgs(S));
    ssSetOutputPortReusable(     S, OUTPORT, 1);
 
    ssSetNumSampleTimes(S,1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);

    /* DWorks: */
    /* Need to store a COUNT_IDX to keep track of impulse location(s) */
    if(!ssSetNumDWork(      S, NUM_DWORK)) return;

    ssSetDWorkWidth(        S, COUNT_IDX, nchans); 
    ssSetDWorkName(         S, COUNT_IDX, "Counter");
    ssSetDWorkDataType(     S, COUNT_IDX, getDWorkDType(S));
    ssSetDWorkComplexSignal(S, COUNT_IDX, COMPLEX_NO); 
} 

  
static void mdlInitializeSampleTimes(SimStruct *S) 
{ 
    const real_T Ts  = mxGetPr(SAMP_TIME_ARG)[0];
    const int_T  spf = (int_T)mxGetPr(FRAME_ARG)[0];

    ssSetSampleTime(S, 0, Ts*spf);
    ssSetOffsetTime(S, 0, 0.0);
} 


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    BuiltInDTypeId dWorkType = getDWorkDType(S);
    
    switch(dWorkType) {
        case SS_UINT8:
            InitializeDWork(uint8_T); 
            break;
        case SS_UINT16:
             InitializeDWork(uint16_T);
             break;
        case SS_UINT32:
             InitializeDWork(uint32_T);
             break;
        case SS_DOUBLE:
             InitializeDWork(real_T);
             break;
        default:
            THROW_ERROR(S, "Invalid delay DWork precision selected.");
            break;
        }
}

  
static void mdlOutputs(SimStruct *S, int_T tid) 
{ 
    BuiltInDTypeId OutputType = getOutputDTypeFromArgs(S);
    BuiltInDTypeId dWorkType  = getDWorkDType(S);

    /*
     * Usage: ImpulseGen(output_dtype, work_dtype)
     */
    if (OutputType == SS_DOUBLE) {
        if (dWorkType == SS_UINT8)  ImpulseGen(real_T, uint8_T);
        if (dWorkType == SS_UINT16) ImpulseGen(real_T, uint16_T);
        if (dWorkType == SS_UINT32) ImpulseGen(real_T, uint32_T);
        if (dWorkType == SS_DOUBLE) ImpulseGen(real_T, uint32_T);

    } else if (OutputType == SS_SINGLE) {
        if (dWorkType == SS_UINT8)  ImpulseGen(real32_T, uint8_T);
        if (dWorkType == SS_UINT16) ImpulseGen(real32_T, uint16_T);
        if (dWorkType == SS_UINT32) ImpulseGen(real32_T, uint32_T);
        if (dWorkType == SS_DOUBLE) ImpulseGen(real32_T, uint32_T);

    } else if (OutputType == SS_BOOLEAN) {
        if (dWorkType == SS_UINT8)  ImpulseGen(boolean_T, uint8_T);
        if (dWorkType == SS_UINT16) ImpulseGen(boolean_T, uint16_T);
        if (dWorkType == SS_UINT32) ImpulseGen(boolean_T, uint32_T);
        if (dWorkType == SS_DOUBLE) ImpulseGen(boolean_T, uint32_T);

    } else
        THROW_ERROR(S, "Invalid output data type selected.");    
}

  
static void mdlTerminate(SimStruct *S) 
{ 
} 


#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    const int_T delayLen = mxGetNumberOfElements(DELAY_ARG);
    real_T     *delay    = mxGetPr(DELAY_ARG);

    if (!ssWriteRTWParamSettings(S, 1,
                                 SSWRITE_VALUE_DTYPE_VECT, "DELAY", 
                                 delay, delayLen,
                                 DTINFO(SS_DOUBLE,COMPLEX_NO)
                                 )) {
        return;
    }
}
#endif
  
#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"                     
#else 
#include "cg_sfun.h"                     
#endif 

/* [EOF] sdspimpgen.c */
