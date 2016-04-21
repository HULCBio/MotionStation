/*
 * SDSPUENCODE Uniform encode block.
 * DSP Blockset S-Function to perform a uniform quantization 
 * and encoding of input into N-bits. Input is saturated 
 * at +- peak value. The output is in the range of [0 2^N-1]. 
 * Output datatype is either a 8, 16, or 32-bit signed or 
 * unsigned integer, based on the least number of bits needed. 
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.10 $  $Date: 2002/04/14 20:44:30 $
 */
#define S_FUNCTION_NAME sdspuencode
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};
enum {PEAK_ARGC=0, BITS_ARGC, SIGN_ARGC, NUM_ARGS};

#define PEAK_ARG    ssGetSFcnParam(S, PEAK_ARGC)
#define BITS_ARG    ssGetSFcnParam(S, BITS_ARGC)
#define SIGN_ARG    ssGetSFcnParam(S, SIGN_ARGC)

typedef enum {
    fcnUnsigned = 1,
    fcnSigned
} SignType;


/* getIntBytes
 * Examines the desired # bits argument (which can run from
 * 2 to 32), and determines the smallest ANSI integer size
 * that can hold the given number of bits.
 *
 * Possible integer sizes are 1, 2, or 4 bytes, therefore
 * we return 1, 2, or 4 only.  If the desired # bits exceeds
 * 32, we still return 32.
 */
static int_T getIntBytes(SimStruct *S)
{
    const int_T Nbits = (int_T)(mxGetPr(BITS_ARG)[0]);
    int_T Nbytes;

    if      (Nbits <= 8)  Nbytes=1;
    else if (Nbits <= 16) Nbytes=2;
    else                  Nbytes=4;

    return(Nbytes);
}


/* getOutputDTypeFromArgs
 * Determine the output datatype from the input arguments.
 */
static BuiltInDTypeId getOutputDTypeFromArgs(SimStruct *S)
{
    const int_T    isSign = (int_T)(mxGetPr(SIGN_ARG)[0]); 
    int_T          Nbytes = getIntBytes(S);
    BuiltInDTypeId dType;

    if      (Nbytes==1) dType = (isSign == fcnUnsigned) ? SS_UINT8  : SS_INT8;
    else if (Nbytes==2) dType = (isSign == fcnUnsigned) ? SS_UINT16 : SS_INT16;
    else                dType = (isSign == fcnUnsigned) ? SS_UINT32 : SS_INT32;

    return(dType);
}


/* FloatTo32Scalar, FloatTo32Real, FloatTo32Cplx
 * Execute the main body of the quantizer
 * This is a macro with a definable input data type
 * inType MUST BE one of: 
 *          real32_T,  real_T (Real)
 *          creal32_T, creal_T (Cplx)
 */

#define FloatTo32Scalar(inType, V, UnSignMax, SignMax, SignMin, u, x, isSign)\
{                                               \
    inType Qr = (inType)UnSignMax;              \
    inType Vr = (inType)V;                      \
    inType T  = (Qr+1)/(2*Vr);                  \
    u = (u+Vr)*T;                               \
                                                \
    if (isSign == fcnUnsigned) {                \
        if      (u < 0) u = 0;                  \
        else if (u > Qr) u = Qr;                \
    } else {                                    \
        inType SignMaxr = (inType)SignMax;      \
        inType SignMinr = (inType)SignMin;      \
                                                \
        u += SignMinr;                          \
        if      (u < SignMinr) u = SignMinr;    \
        else if (u > SignMaxr) u = SignMaxr;    \
    }                                           \
    *x = (isSign == fcnUnsigned)                \
       ? (uint32_T)floor((real_T)u)             \
       : ( int32_T)floor((real_T)u);            \
}   


#define FloatTo32Real(inType, V, UnSignMax, SignMax, SignMin, uptr, x, isSign)  \
{                                                                               \
    inType u = *((inType *)(*uptr++));                                          \
    FloatTo32Scalar(inType, V, UnSignMax, SignMax, SignMin, u, x, isSign)       \
}


#define FloatTo32Cplx(inType, V, UnSignMax, SignMax, SignMin, uptr, x, isSign)  \
{                                                                               \
    c##inType u  = *((c##inType *)(*uptr++));                                   \
    FloatTo32Scalar(inType, V, UnSignMax, SignMax, SignMin, u.re, x.re, isSign);\
    FloatTo32Scalar(inType, V, UnSignMax, SignMax, SignMin, u.im, x.im, isSign);\
}


/* copyInt32ToIntNReal, copyInt32ToIntNCplx
 * Copy int32_T to an 8, 16, or 32 bit integer.
 * The int32_T value must already be "in range" of the desired
 * output integer.  We will simply copy the lower 1, 2, or 4
 * bytes from the input to the output area.
 */
#define copyInt32ToIntNReal(y, x, N)    \
{                                       \
    if (N==1) {                         \
        *((int8_T *)y) = x;             \
    } else if (N==2) {                  \
        *((int16_T *)y) = x;            \
    } else {                            \
        *((int32_T *)y) = x;            \
    }                                   \
    y+=N;                               \
}

#define copyInt32ToIntNCplx(y, x, N)    \
{                                       \
    copyInt32ToIntNReal(y, x.re, N)     \
    copyInt32ToIntNReal(y, x.im, N)     \
}


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    /* Bits */
    if (OK_TO_CHECK_VAR(S, BITS_ARG)) {
        if (!IS_FLINT_IN_RANGE(BITS_ARG,2,32)) {
            THROW_ERROR(S,"Number of output bits must be a scalar from 2 to 32.");
        }
    }

    /* Peak volts */
    if (OK_TO_CHECK_VAR(S, PEAK_ARG)) {
        if (!IS_SCALAR_DOUBLE(PEAK_ARG)) {
            THROW_ERROR(S,"Peak input value must be a real scalar.");
        }
        if (mxGetPr(PEAK_ARG)[0] < 0) {
            THROW_ERROR(S,"Peak input value must be positive.");
        }
    }


    /* Signed integer */
    if (!IS_FLINT_IN_RANGE(SIGN_ARG,1,2)) {
        THROW_ERROR(S,"Signed integer parameter must be 1 (unsigned) or 2 (signed).");
    }

}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetSFcnParamNotTunable(S, PEAK_ARGC);
    ssSetSFcnParamNotTunable(S, BITS_ARGC);
    ssSetSFcnParamNotTunable(S, SIGN_ARGC);

    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDataType(         S, INPORT, DYNAMICALLY_TYPED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortReusable(         S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 0);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortDataType(     S, OUTPORT, DYNAMICALLY_TYPED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | 
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T isDouble = (boolean_T)(ssGetInputPortDataType(S, INPORT) == SS_DOUBLE);
    const boolean_T isCplx   = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const int_T     width    = ssGetInputPortWidth(S, INPORT);  
    const real_T    V        = (real_T)(mxGetPr(PEAK_ARG)[0]);
    const int_T     Nbits    = (int_T)(mxGetPr(BITS_ARG)[0]);
    const int_T     isSign   = (SignType)((int_T)(mxGetPr(SIGN_ARG)[0])); 
    const int_T     Nbytes   = getIntBytes(S);
    InputPtrsType   uptr     = ssGetInputPortSignalPtrs(S,INPORT);
    char_T         *y        = (char_T *)ssGetOutputPortSignal(S,OUTPORT);
    int_T           i;

    /* Define upper and lower bounds for signed and unsigned integers: 
     * Unsigned lower bound = UnSignMin = 0; 
     * For signed integers, set to a default of 0, 
     * and calculate if outputing a signed int.
     */
    const real_T  UnSignMax = (real_T)(ldexp((real_T)1.0,Nbits)-1.0);
    real_T        SignMax   = 0.0;
    real_T        SignMin   = 0.0;

    if (isSign) {
        SignMax = (real_T)(ldexp((real_T)1.0,Nbits-1)-1.0);
        SignMin  = -(1.0 + SignMax); /*(real_T)(-ldexp((real_T)1.0,Nbits-1));*/
    }

    /* Quantize input */
    for (i=0; i<width; i++) {
        if (isCplx) {
            cint32_T x; /* Storage for a 8, 16, or 32-bit int */

            if (isDouble) FloatTo32Cplx(real_T, V, UnSignMax, SignMax, SignMin, uptr, &x, isSign)
            else          FloatTo32Cplx(real32_T, V, UnSignMax, SignMax, SignMin, uptr, &x, isSign)

            copyInt32ToIntNCplx(y, x, Nbytes);

        } else {
            int32_T      x; 
           
            if (isDouble) FloatTo32Real(real_T, V, UnSignMax, SignMax, SignMin, uptr, &x, isSign)
            else          FloatTo32Real(real32_T, V, UnSignMax, SignMax, SignMin, uptr, &x, isSign)

            copyInt32ToIntNReal(y, x, Nbytes);
        }
    }
}

static void mdlTerminate(SimStruct *S)
{
}

#define MDL_SET_INPUT_PORT_DATA_TYPE
#ifdef MATLAB_MEX_FILE
static void mdlSetInputPortDataType(SimStruct *S, int_T portIndex, DTypeId inputPortDataType)
{
    ssSetInputPortDataType(S, portIndex, inputPortDataType);

    if ( (inputPortDataType != SS_DOUBLE) && (inputPortDataType != SS_SINGLE) ) {
        THROW_ERROR(S, "Input data type must be double or single.");
    }
    
    if (ssGetOutputPortDataType(S, OUTPORT) == DYNAMICALLY_TYPED) {
        ssSetOutputPortDataType(S, OUTPORT, getOutputDTypeFromArgs(S));
    }
}
#endif

#define MDL_SET_OUTPUT_PORT_DATA_TYPE
#ifdef MATLAB_MEX_FILE
static void mdlSetOutputPortDataType(SimStruct *S, int_T portIndex, DTypeId outputPortDataType)
{
    ssSetOutputPortDataType(S, OUTPORT, outputPortDataType);

    if (outputPortDataType != getOutputDTypeFromArgs(S)) {
        THROW_ERROR(S, "Data type propagation failure.");
    }
}
#endif


#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    real_T V      = (real_T)(mxGetPr(PEAK_ARG)[0]);
    int8_T Nbits  = (int8_T)(mxGetPr(BITS_ARG)[0]);
    int8_T isSign = (int8_T)(mxGetPr(SIGN_ARG)[0]); 

    if (!ssWriteRTWParamSettings(S, 3,
                                 SSWRITE_VALUE_DTYPE_NUM, "PEAK",
                                 &V,
                                 DTINFO(SS_DOUBLE,0),
        
                                 SSWRITE_VALUE_DTYPE_NUM,  "NBITS",
                                 &Nbits,
                                 DTINFO(SS_INT8,0),
        
                                 SSWRITE_VALUE_DTYPE_NUM,  "ISSIGN",
                                 &isSign,
                                 DTINFO(SS_INT8,0))
        ) {
        return;
    }
}
#endif


#include "dsp_cplxhs11.c"

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
