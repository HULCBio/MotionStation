/*
 *  smemsrc.c - CMEX S-function, currently functions as a stub
 *                   in simulation, and utilizes tlc for code generation
 *
 *  Copyright 2001-2004 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2004/04/01 16:17:44 $
 */

#define S_FUNCTION_NAME	smemsrc
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {NUM_INPORTS=0};
enum {OUTPORT=0,NUM_OUTPORTS};
enum {MEM_ADDRESS_ARGC=0,
      DATA_TYPE_ARGC,
      SAMPLE_TIME_ARGC,
      FRAME_SIZE_ARGC,
      NUM_ARGS};
     
enum {DT_DOUBLE=1,
      DT_SINGLE,
      DT_INT8,
      DT_UINT8,
      DT_INT16,
      DT_UINT16,
      DT_INT32,
      DT_UINT32,
      DT_BOOLEAN};

#define MEM_ADDRESS_ARG(S)  (ssGetSFcnParam(S,MEM_ADDRESS_ARGC))
#define DATA_TYPE_ARG(S)    (ssGetSFcnParam(S,DATA_TYPE_ARGC))
#define SAMPLE_TIME_ARG(S)  (ssGetSFcnParam(S,SAMPLE_TIME_ARGC))
#define FRAME_SIZE_ARG(S)   (ssGetSFcnParam(S,FRAME_SIZE_ARGC))

static DTypeId getOutputDataType(SimStruct *S)
{
    const int_T type = (int_T)mxGetPr(DATA_TYPE_ARG(S))[0];
    DTypeId dtype;

    /* find matching dtype */
    switch (type){
    case DT_DOUBLE:
        dtype = SS_DOUBLE;  break;
    case DT_SINGLE:
        dtype = SS_SINGLE;  break;
    case DT_INT8:
        dtype = SS_INT8;    break;
    case DT_UINT8:
        dtype = SS_UINT8;   break;
    case DT_INT16:
        dtype = SS_INT16;   break;
    case DT_UINT16:
        dtype = SS_UINT16;  break;
    case DT_INT32:
        dtype = SS_INT32;   break;
    case DT_UINT32:
        dtype = SS_UINT32;  break;
    case DT_BOOLEAN:
        dtype = SS_BOOLEAN; break;
    default:
        dtype = SS_INT16;   break;
    }
    return dtype;
}
  

#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if (!IS_FLINT_IN_RANGE(DATA_TYPE_ARG(S),1,8)) {
        THROW_ERROR(S,"Data type must be: int8, uint8, int16, uint16, int32, uint32, single or double.");
    }

    if (OK_TO_CHECK_VAR(S, SAMPLE_TIME_ARG(S))) {
        if (!IS_SCALAR_DOUBLE(SAMPLE_TIME_ARG(S)) ||
            (mxGetPr(SAMPLE_TIME_ARG(S))[0] == (real_T)0.0)) {
            THROW_ERROR(S, "The sample time must be a scalar != 0.");
        }
    }

    if (OK_TO_CHECK_VAR(S, FRAME_SIZE_ARG(S))) {
        if (!IS_SCALAR_DOUBLE(FRAME_SIZE_ARG(S)) || !IS_FLINT_GE(FRAME_SIZE_ARG(S),1)) {
            THROW_ERROR(S,"Samples per frame must be an integer scalar > 0.");
        }
    }
}


static void mdlInitializeSizes(SimStruct *S)
{
    REGISTER_SFCN_PARAMS(S,NUM_ARGS);

    /* non-tunable */
    ssSetSFcnParamTunable(S,MEM_ADDRESS_ARGC, 0);
    ssSetSFcnParamTunable(S,DATA_TYPE_ARGC,   0);
    ssSetSFcnParamTunable(S,SAMPLE_TIME_ARGC, 0);
    ssSetSFcnParamTunable(S, FRAME_SIZE_ARGC, 0);

    /* input ports */
    if (!ssSetNumInputPorts(S,NUM_INPORTS)) return;

    /* output ports */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;

    if (!IS_SCALAR_DOUBLE(FRAME_SIZE_ARG(S)) || !IS_FLINT_GE(FRAME_SIZE_ARG(S),1)) {
        THROW_ERROR(S,"Samples per frame must be an integer scalar > 0.");
    }

    {
        const int_T samplesPerFrame = (int_T)mxGetPr(FRAME_SIZE_ARG(S))[0];
        ssSetOutputPortMatrixDimensions(S, OUTPORT, samplesPerFrame, 1); // One channel
        ssSetOutputPortFrameData(S,OUTPORT,(samplesPerFrame > 1));
    }

    ssSetOutputPortComplexSignal(S,OUTPORT,COMPLEX_NO);
  
    ssSetOutputPortDataType(S,OUTPORT,getOutputDataType(S));

    ssSetNumSampleTimes(S, 1);
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE    |
                    SS_OPTION_CALL_TERMINATE_ON_EXIT |
                    SS_OPTION_WORKS_WITH_CODE_REUSE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    const real_T Ts = mxGetPr(SAMPLE_TIME_ARG(S))[0];

    if ( Ts<0 )
		ssSetSampleTime(S,0,INHERITED_SAMPLE_TIME);
	else
	    ssSetSampleTime(S,0,Ts);
    ssSetOffsetTime(S,0,0.0);
}


static void mdlOutputs(SimStruct *S, int tid)
{
}


static void mdlTerminate(SimStruct *S)
{
}


#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    const uint32_T memAddress = (uint32_T) mxGetPr(MEM_ADDRESS_ARG(S))[0];
    const uint32_T frameSize  = (int_T)mxGetPr(FRAME_SIZE_ARG(S))[0];

    /* Non-tunable parameters */
    if (!ssWriteRTWParamSettings(S, 2,
        	SSWRITE_VALUE_DTYPE_NUM, "memAddress", &memAddress, DTINFO(SS_UINT32,COMPLEX_NO),
                SSWRITE_VALUE_DTYPE_NUM, "frameSize",  &frameSize, DTINFO(SS_INT32,COMPLEX_NO)
        )) {
        return;
    }
}

#include "dsp_trailer.c"

/* [EOF] smemsrc.c */

