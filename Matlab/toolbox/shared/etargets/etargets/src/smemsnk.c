/*
 *  smemsnk.c - CMEX S-function, currently functions as a stub
 *                   in simulation, and utilizes tlc for code generation
 *
 *  Copyright 2001-2004 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2004/04/01 16:17:43 $
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME	smemsnk

#include "dsp_sim.h"

enum {INPORT=0};
enum {NUM_OUTPORTS=0};
enum {MEM_ADDRESS_ARGC=0,
      DATA_TYPE_ARGC,
      USE_INIT_VALUE_ARGC,
      INIT_VALUE_ARGC,
      USE_TERM_VALUE_ARGC,
      TERM_VALUE_ARGC,
      IS_REALTIME_ENABLED_ARGC,
      NUM_ARGS};

/* Must correspond to the order in the pop-up */
enum {DT_DOUBLE=1,
      DT_SINGLE,
      DT_INT8,
      DT_UINT8,
      DT_INT16,
      DT_UINT16,
      DT_INT32,
      DT_UINT32,
      DT_BOOLEAN,
      DT_INHERITED};

#define MEM_ADDRESS_ARG(S)  		(ssGetSFcnParam(S,MEM_ADDRESS_ARGC))
#define DATA_TYPE_ARG(S)    		(ssGetSFcnParam(S,DATA_TYPE_ARGC))
#define USE_INIT_VALUE_ARG(S)   	(ssGetSFcnParam(S,USE_INIT_VALUE_ARGC))
#define INIT_VALUE_ARG(S)   		(ssGetSFcnParam(S,INIT_VALUE_ARGC))
#define USE_TERM_VALUE_ARG(S)   	(ssGetSFcnParam(S,USE_TERM_VALUE_ARGC))
#define TERM_VALUE_ARG(S)   		(ssGetSFcnParam(S,TERM_VALUE_ARGC))
#define IS_REALTIME_ENABLED_ARG(S)	(ssGetSFcnParam(S,IS_REALTIME_ENABLED_ARGC))


static DTypeId getInputDataType(SimStruct *S)
{
	const int_T type = (int_T)mxGetPr(DATA_TYPE_ARG(S))[0];
    DTypeId dtype;

    // find matching Simulink data type
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
    if (!IS_FLINT_IN_RANGE(DATA_TYPE_ARG(S),1,10)) {
        THROW_ERROR(S,"Data type must be: double, single, int8, uint8, int16, uint16, int32, uint32, boolean or inherited.");
    }

    if ( (mxGetPr(DATA_TYPE_ARG(S))[0]==DT_INHERITED) && (mxGetPr(IS_REALTIME_ENABLED_ARG(S))[0] == 0) ) {
        THROW_ERROR(S,"Cannot inherit data type unless 'Write at every sample time' is enabled.");
    }

    if (!IS_FLINT_IN_RANGE(USE_INIT_VALUE_ARG(S),0,1)) {
        THROW_ERROR(S,"Checkbox to use initial value must be 0 (off) or 1 (on).");
    }

    if (OK_TO_CHECK_VAR(S,INIT_VALUE_ARG(S))) {
        if (!IS_SCALAR_DOUBLE(INIT_VALUE_ARG(S),0,1)) {
            THROW_ERROR(S,"Initial value must be a real scalar in double precision floating-point format.");
        }
    }

    if (!IS_FLINT_IN_RANGE(USE_TERM_VALUE_ARG(S),0,1)) {
        THROW_ERROR(S,"Checkbox to use termination value must be 0 (off) or 1 (on).");
    }

    if (OK_TO_CHECK_VAR(S,TERM_VALUE_ARG(S))) {
        if (!IS_SCALAR_DOUBLE(TERM_VALUE_ARG(S),0,1)) {
            THROW_ERROR(S,"Termination value must be a real scalar in double precision floating-point format.");
        }
    }

    if (!IS_FLINT_IN_RANGE(IS_REALTIME_ENABLED_ARG(S),0,1)) {
        THROW_ERROR(S,"Checkbox to enable real-time must be 0 (off) or 1 (on).");
    }
}


static void mdlInitializeSizes(SimStruct *S)
{
    REGISTER_SFCN_PARAMS(S,NUM_ARGS);

    /* non-tunable parameters */
    ssSetSFcnParamTunable(S,MEM_ADDRESS_ARGC, 0);
    ssSetSFcnParamTunable(S,DATA_TYPE_ARGC, 0);
    ssSetSFcnParamTunable(S,USE_INIT_VALUE_ARGC, 0);
    ssSetSFcnParamTunable(S,INIT_VALUE_ARGC, 0);
    ssSetSFcnParamTunable(S,USE_TERM_VALUE_ARGC, 0);
    ssSetSFcnParamTunable(S,TERM_VALUE_ARGC, 0);
    ssSetSFcnParamTunable(S,IS_REALTIME_ENABLED_ARGC, 0);

    {
		const int_T data_type = mxGetPr(DATA_TYPE_ARG(S))[0];
        const int_T num_inports = (mxGetPr(IS_REALTIME_ENABLED_ARG(S))[0] == 1) ? 1 : 0;

        /* initialize input port(s) */
        if (!ssSetNumInputPorts(S, num_inports)) return;
        if (num_inports > 0) {
            if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
            ssSetInputPortWidth(             S, INPORT, DYNAMICALLY_SIZED);
            ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
            ssSetInputPortDataType(          S, INPORT, data_type == DT_INHERITED ? DYNAMICALLY_TYPED : getInputDataType(S));
            ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_NO);
            ssSetInputPortReusable(          S, INPORT, 1);
            ssSetInputPortDirectFeedThrough( S, INPORT, 1);            /* Accessing inputs during mdlOutput */
        }
    }

    /* initialize output port(s) */
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;

    /* intialize number of sample times */
    ssSetNumSampleTimes(S, 1);

    ssSetOptions(S, SS_OPTION_ALLOW_PORT_SAMPLE_TIME_IN_TRIGSS | 
//                    SS_OPTION_EXCEPTION_FREE_CODE              |
                    SS_OPTION_CALL_TERMINATE_ON_EXIT           |
                    SS_OPTION_WORKS_WITH_CODE_REUSE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}
      

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, 
                                      int_T port,
                                      const DimsInfo_T *portInfo)
{
    if (!ssSetInputPortDimensionInfo(S, port, portInfo)) return;
    ErrorIfInputIsNot1or2D(S,port);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
}	


static void mdlTerminate(SimStruct *S)
{
}

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int_T portIdx, DTypeId inputPortDataType)
{
    switch (inputPortDataType){
	case SS_DOUBLE: 
	case SS_SINGLE: 
	case SS_INT8: 
	case SS_UINT8: 
	case SS_INT16: 
	case SS_UINT16: 
	case SS_INT32: 
	case SS_UINT32: 
	case SS_BOOLEAN:
		break;
    default:
        THROW_ERROR (S,"To Memory cannot accept elements of the specified data type.");
        break;
    }

    ssSetInputPortDataType(S, portIdx, inputPortDataType);
}

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    uint32_T  memAddress        = (uint32_T) mxGetPr(MEM_ADDRESS_ARG(S))[0];
    uint32_T  data_type         = (uint32_T) mxGetPr(DATA_TYPE_ARG(S))[0];
	uint32_T  dataTypeID        = data_type == DT_INHERITED ? (uint32_T) ssGetInputPortDataType(S, INPORT) : getInputDataType(S);

    boolean_T useInitValue      = (mxGetPr(USE_INIT_VALUE_ARG(S))[0] == 1);
    boolean_T useTermValue      = (mxGetPr(USE_TERM_VALUE_ARG(S))[0] == 1);
    boolean_T isRealtimeEnabled = (mxGetPr(IS_REALTIME_ENABLED_ARG(S))[0] == 1);

    /* Always write the init and term values as double-precision floating-point
     * and make appropriate adjustments to the actual data type in TLC
     */
    double initValue = mxGetPr(INIT_VALUE_ARG(S))[0];
    double termValue = mxGetPr(TERM_VALUE_ARG(S))[0];

    /* Non-tunable parameters */
    if (!ssWriteRTWParamSettings(S, 7,
        	SSWRITE_VALUE_DTYPE_NUM, "memAddress",   &memAddress, DTINFO(SS_UINT32,COMPLEX_NO),
        	SSWRITE_VALUE_DTYPE_NUM, "dataTypeID",   &dataTypeID, DTINFO(SS_UINT32,COMPLEX_NO),
        	SSWRITE_VALUE_DTYPE_NUM, "useInitValue", &useInitValue, DTINFO(SS_BOOLEAN,COMPLEX_NO),
        	SSWRITE_VALUE_DTYPE_NUM, "initValue",    &initValue, DTINFO(SS_DOUBLE,COMPLEX_NO),
        	SSWRITE_VALUE_DTYPE_NUM, "useTermValue", &useTermValue, DTINFO(SS_BOOLEAN,COMPLEX_NO),
        	SSWRITE_VALUE_DTYPE_NUM, "termValue",    &termValue, DTINFO(SS_DOUBLE,COMPLEX_NO),
        	SSWRITE_VALUE_DTYPE_NUM, "isRealtimeEnabled", &isRealtimeEnabled, DTINFO(SS_BOOLEAN,COMPLEX_NO)
	  )) {
        return;
    }
}

#include "dsp_trailer.c"

/* [EOF] smemsnk.c */
