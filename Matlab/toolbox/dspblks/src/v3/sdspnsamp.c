/*
 * SDSPNSAMP  N-Sample Enable block.
 * DSP Blockset S-Function which transitions from inactive to active level.
 * A high active level, outputs FALSE (0) for the first N samples; 
 * thereafter, outputs TRUE (1). A low active level, outputs TRUE (0) 
 * for the first N sample;thereafter, outputs FALSE (0).
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.24.4.1 $  $Date: 2004/01/25 22:39:39 $
 */
#define S_FUNCTION_NAME sdspnsamp
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

/*
 * ----------------------------------------------------------
 * Simulink/RTW zero-crossing detector function prototype:
 *
 * OBSOLETE FOR DSP BLOCKSET 5.0 (Release 13) AND LATER
 * THIS IS JUST FOR CERTAIN S-FCNS FROM RELEASE 11.x !!!
 * ----------------------------------------------------------
 */
extern ZCEventType rt_ZCFcn(ZCDirection direction,
                            ZCSigState *prevSigState, 
                            real_T      zcSig);

enum {RESET_INPORT=0};
enum {OUTPORT=0};
enum {PREV_RESET_STATE=0, NUM_IWORKS};
enum {CURRCNT_IDX=0, NUM_DWORK};
enum {ACTIVE_HIGH=1, ACTIVE_LOW};
enum {TRIGTYPE_ARGC=0, TARGETCNT_ARGC, SAMPLETIME_ARGC, ACTLEVEL_ARGC, NUM_ARGS};

#define TRIGTYPE_ARG   (ssGetSFcnParam(S, TRIGTYPE_ARGC))
#define TARGETCNT_ARG  (ssGetSFcnParam(S, TARGETCNT_ARGC))
#define SAMPLETIME_ARG (ssGetSFcnParam(S, SAMPLETIME_ARGC))
#define ACTLEVEL_ARG   (ssGetSFcnParam(S, ACTLEVEL_ARGC))

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    /* Target counter */
    if (OK_TO_CHECK_VAR(S, TARGETCNT_ARG)) { 
        if (!IS_FLINT_GE(TARGETCNT_ARG, 0)) {
            THROW_ERROR(S, "The sample count must be a real, scalar integer >= 0.");
        }
    }
    
    /* Active level */
    if(!IS_FLINT_IN_RANGE(ACTLEVEL_ARG,1,2)) {
        THROW_ERROR(S, "Active level must be 1 (High) or 2 (Low)");
    }
    
    /* Trigger Type */
    if(!IS_FLINT_IN_RANGE(TRIGTYPE_ARG,0,3)) {
        THROW_ERROR(S, "Trigger type must be 0=none, 1=rising, 2=falling, or 3=either");
    }
    
    /* Check Sample time if defined and trigger type is zero. (no reset port) */
    if (OK_TO_CHECK_VAR(S, SAMPLETIME_ARG) && (mxGetPr(TRIGTYPE_ARG)[0] == 0) ) { 
        
        if (!IS_SCALAR_DOUBLE(SAMPLETIME_ARG)) {
            THROW_ERROR(S, "The sample time must be a scalar.");
        }
        
        if (mxGetPr(SAMPLETIME_ARG)[0] <= CONTINUOUS_SAMPLE_TIME) {
            THROW_ERROR(S, "Continuous sample times not permitted.");
        }
    }    
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    real_T sampleTime;
    int_T  numInputs;

    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetSFcnParamNotTunable(S, SAMPLETIME_ARGC);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES); 

    /* Inputs: */
    {
        int_T trigtype = (int_T)(mxGetPr(TRIGTYPE_ARG)[0]);        
        numInputs = (trigtype == 0) ? 0 : 1;
        if (!ssSetNumInputPorts(S, numInputs)) return;

        if (numInputs>0) {
            ssSetInputPortWidth(            S, RESET_INPORT, 1);
            ssSetInputPortComplexSignal(    S, RESET_INPORT, COMPLEX_NO);
            ssSetInputPortReusable(         S, RESET_INPORT, 1);
            ssSetInputPortSampleTime(       S, RESET_INPORT, INHERITED_SAMPLE_TIME);
            ssSetInputPortDirectFeedThrough(S, RESET_INPORT, 1);
        }
    }

    /* Only get sampletime arg if edit box variable is defined
     * and if there is no input port.
     */
    if ( OK_TO_CHECK_VAR(S, SAMPLETIME_ARG) && (numInputs == 0) ) { 
        sampleTime = mxGetPr(SAMPLETIME_ARG)[0];
    } else {
        sampleTime = INHERITED_SAMPLE_TIME;
    }

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(        S, OUTPORT, 1);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);  
    ssSetOutputPortReusable(     S, OUTPORT, 1);
    ssSetOutputPortSampleTime(   S, OUTPORT, sampleTime);

    /* Set output port data type: */
    ssSetOutputPortDataType(S, OUTPORT, SS_DOUBLE);

    /* DWorks: */
    if(!ssSetNumDWork(      S, NUM_DWORK)) return;
    ssSetDWorkWidth(        S, CURRCNT_IDX, 1);
    ssSetDWorkDataType(     S, CURRCNT_IDX, SS_UINT32);
    ssSetDWorkComplexSignal(S, CURRCNT_IDX, COMPLEX_NO);

    ssSetNumIWork(          S, NUM_IWORKS);
    ssSetOptions(           S, SS_OPTION_EXCEPTION_FREE_CODE |
                            SS_OPTION_DISCRETE_VALUED_OUTPUT);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
#if defined(MATLAB_MEX_FILE)
    /* Check output port sample times: */
    const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);
    
    if (Tso == INHERITED_SAMPLE_TIME) {
        THROW_ERROR(S,"Sample time propagation failed for nsample block.");
    }
    if (Tso == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S,"Continuous sample times not allowed for nsample block.");
    }

    /* Check input port sample times: */
    if (ssGetNumInputPorts(S) > 0) {
        const real_T Tsi = ssGetInputPortSampleTime(S, RESET_INPORT);
        
        if (Tsi == INHERITED_SAMPLE_TIME) {
            THROW_ERROR(S,"Sample time propagation failed for nsample block.");
        }
        if (Tsi == CONTINUOUS_SAMPLE_TIME) {
            THROW_ERROR(S,"Continuous sample times not allowed for nsample block.");
        }
    }
#endif    
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    if (offsetTime != 0.0) {
        ssSetErrorStatus(S, "Non-zero sample time offsets not allowed.");
        return;
    }
    ssSetInputPortSampleTime(S, RESET_INPORT, sampleTime);
    ssSetInputPortOffsetTime(S, RESET_INPORT, 0.0);

    ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    if (offsetTime != 0.0) {
        ssSetErrorStatus(S, "Non-zero sample time offsets not allowed.");
        return;
    }
    ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);

    if (ssGetNumInputPorts(S) > 0) {
        ssSetInputPortSampleTime(S, RESET_INPORT, sampleTime);
        ssSetInputPortOffsetTime(S, RESET_INPORT, 0.0);
    }
}
#endif



#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    boolean_T resetPort = (boolean_T)(ssGetNumInputPorts(S) > 0);

    /* Initialize the target and current sample counts: */
    *((uint32_T *)ssGetDWork(S, CURRCNT_IDX)) = (uint32_T)0;

    if (resetPort) {
        ssSetIWorkValue(S, PREV_RESET_STATE, UNINITIALIZED_ZCSIG);
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    /*
     * Check trigger if reset port is present:
     */
    {
        boolean_T resetPort = (boolean_T)(ssGetNumInputPorts(S) > 0);
        if (resetPort) {

            ZCEventType reset;

            /* Determine triggering operation: */
            int_T       mask_dir = (int_T)mxGetPr(TRIGTYPE_ARG)[0];
            ZCDirection zc_dir   = (mask_dir==1) ? RISING_ZERO_CROSSING :
                                   (mask_dir==2) ? FALLING_ZERO_CROSSING : ANY_ZERO_CROSSING;
        
            /* Push event */
            InputRealPtrsType trig_in = ssGetInputPortRealSignalPtrs(S, RESET_INPORT);
            reset = rt_ZCFcn(zc_dir, (ZCSigState *)(ssGetIWork(S) + PREV_RESET_STATE), **trig_in);

            if (reset) {
                *((uint32_T *)ssGetDWork(S, CURRCNT_IDX)) = (uint32_T)0;
            }
        }
    }


    /*
     * Update sample counter and output value:
     */
    {
        const uint32_T   target_cnt = (uint32_T)(mxGetPr(TARGETCNT_ARG)[0]);
        uint32_T        *sample_cnt = (uint32_T *)ssGetDWork(S, CURRCNT_IDX);
        real_T          *y          = ssGetOutputPortRealSignal(S, OUTPORT);


        /*
         * To generate the appopriate output levels,
         * we use the following table:
         *
         *   -------------------------------------
         *   | Active | popup | active  inactive |
         *   | Level  | enum  | state   state    |
         *   |-----------------------------------|
         *   |  high  |  1.0  |  1.0      0.0    |
         *   |  low   |  2.0  |  0.0      1.0    |
         *   -------------------------------------
         *
         *   To map between the popup and the output states,
         *      active:  output = 2.0 - enum
         *    inactive:  output = enum - 1.0
         */
        if (*sample_cnt == target_cnt) {
            /* Active state: */
            *y = 2.0 - mxGetPr(ACTLEVEL_ARG)[0];
        } else {
            /* Inactive state: */
            *y = mxGetPr(ACTLEVEL_ARG)[0] - 1.0;
            (*sample_cnt)++;
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdspnamp.c */
