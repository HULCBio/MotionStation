/*
 * SDSPUDECODE Uniform decoder block.
 * Uniformly decode the input with positive and negative Peak value.  
 * The output datatype is double or single. Saturate or wrap in overflow
 * mode.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.11 $  $Date: 2002/04/14 20:44:27 $
 */
#define S_FUNCTION_NAME sdspudecode
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};
enum {PEAK_ARGC=0, BITS_ARGC, OTYPE_ARGC, OVERFLOW_ARGC, NUM_ARGS};

#define PEAK_ARG  ssGetSFcnParam(S, PEAK_ARGC)
#define BITS_ARG  ssGetSFcnParam(S, BITS_ARGC)
#define OTYPE_ARG ssGetSFcnParam(S, OTYPE_ARGC)
#define OVERFLOW_ARG ssGetSFcnParam(S, OVERFLOW_ARGC)

typedef enum {
    fcnDouble = 1,
    fcnSingle
} OutType;

typedef enum {
    fcnSaturate = 1,
    fcnWrap
} OverFlowType;


typedef enum {
    fcnUnsigned = 1,
    fcnSigned
} SignType;


static int_T getInputSign(SimStruct *S)
{
    BuiltInDTypeId dtype = (BuiltInDTypeId)((int_T)ssGetInputPortDataType(S,INPORT));
    int_T isSign;

    switch (dtype) {
    case SS_UINT8:
    case SS_UINT16:
    case SS_UINT32:
    case SS_BOOLEAN:
        isSign = fcnUnsigned;
	break;
    case SS_INT8:
    case SS_INT16:
    case SS_INT32:
    default:
        isSign = fcnSigned;
	break;
    }

    return(isSign);
}


/* getOutputDTypeFromArgs
 * Determine the output datatype from the input arguments.
 */
static BuiltInDTypeId getOutputDTypeFromArgs(SimStruct *S)
{
    const int_T    oType  = (OutType)((int_T)(mxGetPr(OTYPE_ARG)[0])); 
    BuiltInDTypeId dType;

    if (oType == fcnDouble) dType = SS_DOUBLE;
    else                    dType = SS_SINGLE;

    return(dType);
}


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    /* Bits */
    if (OK_TO_CHECK_VAR(S, BITS_ARG)) {
        if (!IS_FLINT_IN_RANGE(BITS_ARG,2,32)) {
            THROW_ERROR(S,"Number of bits must be a scalar from 2 to 32.");
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

    /* Overflow mode */
    if (!IS_FLINT_IN_RANGE(OVERFLOW_ARG,1,2)) {
        THROW_ERROR(S,"Overflow mode parameter must be 1 (saturate) or 2 (wrap).");
    }

    /* Output type */
    if (!IS_FLINT_IN_RANGE(OTYPE_ARG,1,2)) {
        THROW_ERROR(S,"Output type parameter must be 1 (double) or 2 (single).");
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

    /* Only PEAK_ARGC is tunable */
    ssSetSFcnParamNotTunable(S, PEAK_ARGC);
    ssSetSFcnParamNotTunable(S, OTYPE_ARGC);
    ssSetSFcnParamNotTunable(S, BITS_ARGC);
    ssSetSFcnParamNotTunable(S, OVERFLOW_ARGC);

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


/*  NOTE:
 *        T = 2*V / pow(2,Nbits)
 *  which is equivalent to
 *        T = V / (1 << (N-1))
 * 
 * V/2^(N-1) = V*2^(1-N) = ldexp(V,1-N)
 *
 */
#define InitVars(oType, inType)                                                     \
  oType       *y        = (oType *)ssGetOutputPortSignal(S,OUTPORT);                \
  const int_T  N        = (int_T)(mxGetPr(BITS_ARG)[0]);                            \
  const oType  V        = (oType)mxGetPr(PEAK_ARG)[0];                              \
  const oType  T        = (oType)(ldexp((real_T)V,(1-N)));                        \
  const oType  W        = (isSigned) ? (oType)ldexp((real_T)1.0,N-1) : (oType)0.0;\
  const uint32_T Nbits    = (N == 32) ? 0 : (uint32_T)(ldexp((real_T)1.0,N));     \
  const inType   UpperBnd = (inType)((isSigned) ? (inType)(ldexp((real_T)1.0,N-1)-1.0) : (inType)(ldexp((real_T)1.0,N)-1.0));\
  const inType   LowerBnd = (inType)((isSigned) ? (inType)(-ldexp((real_T)1.0,N-1)) : (inType)0);

/*
 * MODN prevents computing the modulus of a negative integer
 * ANSI C indicates that this behavior is platform-dependent,
 * and therefore, we create our own (independent) spec here.
 * The argument to "%" is always kept non-negative.
 */
#define modn(X,M) (((X)<0) ? (-((-(X))%(M))) : ((X)%(M)))

  /*
   * Wrap function for signed values
   */
#define Wraps(uu,inType,Nbits,UpperBnd,LowerBnd)        \
{                                                       \
	if (inDType != SS_INT32) {              			\
           uu = (inType)(modn(uu - LowerBnd, Nbits));   \
           if (uu < 0) uu -= LowerBnd;                  \
           else        uu += LowerBnd;                  \
	}                                                   \
}

/*
 * Wrap function for unsigned values
 */
#define Wrapus(uu,inType,Nbits,UpperBnd,LowerBnd)       \
{                                                       \
	if (inDType != SS_UINT32) {             			\
          uu = (inType)(uu % Nbits);                    \
	}                                                   \
}

#define Saturate(uu,UpperBnd,LowerBnd)       \
{                                            \
    if      (uu > UpperBnd) uu = UpperBnd;   \
    else if (uu < LowerBnd) uu = LowerBnd;   \
} 

#define HandleOverFlow(uu,inType,isSaturate,Nbits,UpperBnd,LowerBnd,issigned) \
{                                                                             \
    if (isSaturate) Saturate(uu,UpperBnd,LowerBnd)                            \
    else            Wrap##issigned(uu,inType,Nbits,UpperBnd,LowerBnd)\
}

#define Decode(y,oType,inType,uu,W,T,V,isSaturate,Nbits,UpperBnd,LowerBnd,issigned)\
{                                                                                  \
    HandleOverFlow(uu,inType,isSaturate,Nbits,UpperBnd,LowerBnd,issigned)          \
    *y++ = ((oType)(uu)+W)*T - V;                                                  \
} 


#define DecodeReal(oType, inType,issigned)           \
{                                                    \
  InitVars(oType, inType)                            \
  for (i=0; i<width; i++) {                          \
      inType uu = (*((inType *)(*uptr++)));          \
      Decode(y,oType,inType,uu,W,T,V,isSaturate,Nbits,UpperBnd,LowerBnd,issigned)\
  }                                                  \
}


#define DecodeCplx(oType, inType,issigned)           \
{                                                    \
  InitVars(oType, inType)                            \
  for (i=0; i<width; i++) {                          \
      c##inType uu = (*((c##inType *)(*uptr++)));    \
      Decode(y,oType,inType,uu.re,W,T,V,isSaturate,Nbits,UpperBnd,LowerBnd,issigned) \
      Decode(y,oType,inType,uu.im,W,T,V,isSaturate,Nbits,UpperBnd,LowerBnd,issigned) \
  }                                                  \
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const BuiltInDTypeId inDType    = (BuiltInDTypeId)((int_T)ssGetInputPortDataType(S,INPORT));
    InputPtrsType        uptr       = ssGetInputPortSignalPtrs(S,INPORT);
    const boolean_T      isDouble   = (boolean_T)(((OutType)((int_T)(mxGetPr(OTYPE_ARG)[0])) == fcnDouble)); 
    const boolean_T      isSaturate = (boolean_T)((OverFlowType)((int_T)(mxGetPr(OVERFLOW_ARG)[0])) == fcnSaturate); 
    const boolean_T      isSigned   = (boolean_T)(getInputSign(S) == fcnSigned);
    const boolean_T      isCplx     = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const int_T          width      = ssGetInputPortWidth(S, INPORT);  
    int_T                i;

    /*
     * "s" and "us" are passed to the macros DecodeCplx and DecodeReal
     * to denote signed and unsigned values respectively.
     * This helps in calling separate wrap macros for these two types
     * to avoid warnings
     */
    if (isCplx) {
        if (isDouble) {
            if (isSigned) {
                if      (inDType == SS_INT8)   DecodeCplx(real_T, int8_T,  s)
                else if (inDType == SS_INT16)  DecodeCplx(real_T, int16_T, s)
                else                           DecodeCplx(real_T, int32_T, s)

            } else {
                if      (inDType == SS_UINT8)  DecodeCplx(real_T, uint8_T,  us)
                else if (inDType == SS_UINT16) DecodeCplx(real_T, uint16_T, us)
                else                           DecodeCplx(real_T, uint32_T, us)

            }
        } else {
            if (isSigned) {
                if      (inDType == SS_INT8)   DecodeCplx(real32_T, int8_T,  s)
                else if (inDType == SS_INT16)  DecodeCplx(real32_T, int16_T, s)
                else                           DecodeCplx(real32_T, int32_T, s)

            } else {
                if      (inDType == SS_UINT8)  DecodeCplx(real32_T, uint8_T,  us)
                else if (inDType == SS_UINT16) DecodeCplx(real32_T, uint16_T, us)
                else                           DecodeCplx(real32_T, uint32_T, us)

            }
        }
    
    } else {
        if (isDouble) {
            if (isSigned) {
                if      (inDType == SS_INT8)   DecodeReal(real_T, int8_T,  s)
                else if (inDType == SS_INT16)  DecodeReal(real_T, int16_T, s)
                else                           DecodeReal(real_T, int32_T, s)

            } else {
                if      (inDType == SS_UINT8)  DecodeReal(real_T, uint8_T,  us)
                else if (inDType == SS_UINT16) DecodeReal(real_T, uint16_T, us)
                else                           DecodeReal(real_T, uint32_T, us)
            }
        } else {
            if (isSigned) {
                if      (inDType == SS_INT8)   DecodeReal(real32_T, int8_T,  s)
                else if (inDType == SS_INT16)  DecodeReal(real32_T, int16_T, s)
                else                           DecodeReal(real32_T, int32_T, s)
            } else {
                if      (inDType == SS_UINT8)  DecodeReal(real32_T, uint8_T,  us)
                else if (inDType == SS_UINT16) DecodeReal(real32_T, uint16_T, us)
                else                           DecodeReal(real32_T, uint32_T, us)
            }
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

    if ( (inputPortDataType != SS_INT8)   && 
         (inputPortDataType != SS_INT16)  &&
         (inputPortDataType != SS_INT32)  &&
         (inputPortDataType != SS_UINT8)  &&
         (inputPortDataType != SS_UINT16) &&
         (inputPortDataType != SS_UINT32)
       ) {
        THROW_ERROR(S, "Input data type must be signed or unsigned integer.");
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
        THROW_ERROR(S, "Output data type must be a double or single.");
    }
}
#endif

#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    const boolean_T isDouble   = (boolean_T)((OutType)((int_T)(mxGetPr(OTYPE_ARG)[0])) == fcnDouble); 
    const boolean_T isSigned   = (boolean_T)(getInputSign(S) == fcnSigned);
    const boolean_T isSaturate = (boolean_T)((OverFlowType)((int_T)(mxGetPr(OVERFLOW_ARG)[0])) == fcnSaturate); 
    const int_T     N          = (int_T)(mxGetPr(BITS_ARG)[0]);

    if (isDouble) {
        const real_T V  = (real_T)mxGetPr(PEAK_ARG)[0];
        const real_T T  = (real_T)ldexp((real_T)V,1-N);
        const real_T W  = (isSigned) ? (real_T)ldexp(1.0,N-1) : (real_T)0.0;

        if (!ssWriteRTWParamSettings(S, 5,
                                     SSWRITE_VALUE_DTYPE_NUM,  "PEAK",
                                     &V,
                                     DTINFO(SS_DOUBLE,COMPLEX_NO),

                                     SSWRITE_VALUE_DTYPE_NUM,  "N",
                                     &N,
                                     DTINFO(SS_INT32,COMPLEX_NO),
        
                                     SSWRITE_VALUE_DTYPE_NUM,  "W",
                                     &W,
                                     DTINFO(SS_DOUBLE,COMPLEX_NO),

                                     SSWRITE_VALUE_DTYPE_NUM,  "T",
                                     &T,
                                     DTINFO(SS_DOUBLE,COMPLEX_NO),

                                     SSWRITE_VALUE_DTYPE_NUM,  "isSaturate",
                                     &isSaturate,
                                     DTINFO(SS_BOOLEAN,COMPLEX_NO)
                                     )) {
            return;
        }



    } else {
        const real32_T V  = (real32_T)mxGetPr(PEAK_ARG)[0];
        const real32_T T  = (real32_T)ldexp((real_T)V,1-N);
        const real32_T W  = (isSigned) ? (real32_T)ldexp(1.0,N-1) : (real32_T)0.0;

        if (!ssWriteRTWParamSettings(S, 5,
                                     SSWRITE_VALUE_DTYPE_NUM,  "PEAK",
                                     &V,
                                     DTINFO(SS_SINGLE,COMPLEX_NO),

                                     SSWRITE_VALUE_DTYPE_NUM,  "N",
                                     &N,
                                     DTINFO(SS_INT32,COMPLEX_NO),

                                     SSWRITE_VALUE_DTYPE_NUM,  "W",
                                     &W,
                                     DTINFO(SS_SINGLE,COMPLEX_NO),

                                     SSWRITE_VALUE_DTYPE_NUM,  "T",
                                     &T,
                                     DTINFO(SS_SINGLE,COMPLEX_NO),

                                     SSWRITE_VALUE_DTYPE_NUM,  "isSaturate",
                                     &isSaturate,
                                     DTINFO(SS_BOOLEAN,COMPLEX_NO)
                                     )) {
            return;
        }
    }
}
#endif

#include "dsp_cplxhs11.c"

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
