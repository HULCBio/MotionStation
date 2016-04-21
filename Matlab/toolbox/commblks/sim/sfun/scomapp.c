/*
 *   SCOMAPP Communications Blockset S-Function for Soft Input Soft Output
 *   A posterior probability (APP) algorithm.
 *
 *    Copyright 1996-2003 The MathWorks, Inc.
 *    $Revision: 1.9.4.2 $
 *    $Date: 2004/04/12 23:03:15 $
 *    Author: Mojdeh Shakeri
 */
#define S_FUNCTION_NAME scomapp
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include "simstruc.h"
#include "trellis.h"
#include "app.h"
#include "comm_mtrx.h"


enum {U_INPUT = 0, C_INPUT };
enum {U_OUTPUT= 0, C_OUTPUT};

enum {TRELLIS_U_NUMBITS_ARGC = 0,   /* number of input bits    */
      TRELLIS_C_NUMBITS_ARGC,       /* number of output bits   */
      TRELLIS_NUM_STATES_ARGC,      /* number of states        */
      TRELLIS_OUTPUT_ARGC,          /* output matrix (decimal) */
      TRELLIS_NEXT_STATE_ARGC,      /* next state matrix       */
      TERMINATION_METHOD_ARGC,      /* termination methods:
                                     * continuous, truncated, terminated. */
      ALGORITHM_ARGC,               /* algorithm: true APP, max, max*     */
      MAX_START_TBL_ARGC,           /* table used in max* algorithm       */
      MAX_START_TBL_LEN_ARGC,       /* length of table used in max* alg   */
      MAX_START_SCALE_ARGC,         /* Used only in max* algorithm        */
      NUM_ARGS
};

enum {INT32_MATRICES_UPDATED = 0,
      INT32_NEXT_STATE,
      INT32_OUTPUT,
      BRANCH_METRIC,
      ALPHA,
      BETA,
      CURR_ALPHA_FLAG,
      MAX_STAR_U_INPUT,
      MAX_STAR_C_INPUT,
      NUM_DWORK};


#define TRELLIS_U_NUMBITS_ARG   (ssGetSFcnParam(S, TRELLIS_U_NUMBITS_ARGC))
#define TRELLIS_C_NUMBITS_ARG   (ssGetSFcnParam(S, TRELLIS_C_NUMBITS_ARGC))
#define TRELLIS_NUM_STATES_ARG  (ssGetSFcnParam(S, TRELLIS_NUM_STATES_ARGC))
#define TRELLIS_OUTPUT_ARG      (ssGetSFcnParam(S, TRELLIS_OUTPUT_ARGC))
#define TRELLIS_NEXT_STATE_ARG  (ssGetSFcnParam(S, TRELLIS_NEXT_STATE_ARGC))
#define TERMINATION_METHOD_ARG  (ssGetSFcnParam(S, TERMINATION_METHOD_ARGC))
#define ALGORITHM_ARG           (ssGetSFcnParam(S, ALGORITHM_ARGC))
#define MAX_START_TBL_ARG       (ssGetSFcnParam(S, MAX_START_TBL_ARGC))
#define MAX_START_TBL_LEN_ARG   (ssGetSFcnParam(S, MAX_START_TBL_LEN_ARGC))
#define MAX_START_SCALE_ARG \
              (ssGetSFcnParam(S, MAX_START_SCALE_ARGC))


#define EDIT_OK(S, ARG) \
       (!((ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ARG)))

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
#if 0
    /*
     * Cannot use port based sample time in a triggered subsystem block.
     * This will be supported very soon.
     */
    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);
#endif

    /* Inputs and Outputs */
    {
        /* Inputs: */
        int   numInputs  = 2;
        int   numOutputs = 2;

        if (!ssSetNumInputPorts(S, numInputs)) return;
        for(i = 0; i < numInputs; ++i){
            if(!ssSetInputPortDimensionInfo( S, i, DYNAMIC_DIMENSION)) return;
            ssSetInputPortFrameData(         S, i, FRAME_INHERITED);
            ssSetInputPortDirectFeedThrough( S, i, 1);
            ssSetInputPortReusable(          S, i, 1);
            ssSetInputPortComplexSignal(     S, i, COMPLEX_NO);
            ssSetInputPortSampleTime(        S, i, INHERITED_SAMPLE_TIME);
            ssSetInputPortRequiredContiguous(S, i, 1);
        }

        /* Outputs: */
        if (!ssSetNumOutputPorts(S, numOutputs)) return;
        for(i = 0; i < numOutputs; ++i){
            if(!ssSetOutputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
            ssSetOutputPortFrameData(        S, i, FRAME_INHERITED);
            ssSetOutputPortReusable(         S, i, 1);
            ssSetOutputPortComplexSignal(    S, i, COMPLEX_NO);
            ssSetOutputPortSampleTime(       S, i, INHERITED_SAMPLE_TIME);
        }

        if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

        ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
    }
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);

}
#if 0
/* Use dsp sample time functions to set the input and output port sample times*/
#include "comm_defs.h"
#include "dsp_ctrl_ts.c"
#endif

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    int     is;
    real_T  *alpha         = (real_T *) ssGetDWork(S, ALPHA);
    int     numStates      = (int32_T)(mxGetPr(TRELLIS_NUM_STATES_ARG)[0]);
    int32_T *currAlphaFlag = (int32_T *)ssGetDWork(S, CURR_ALPHA_FLAG);
    int32_T *int32Matrices = (int32_T *)ssGetDWork(S, INT32_MATRICES_UPDATED);
    algorithm_T alg        = (algorithm_T)(mxGetPr(ALGORITHM_ARG)[0]);
    /* mexPrintf("Init \n"); */
    /* Initialize Alpha */
    currAlphaFlag[0] = 1; /* true */
    for(is = 0; is < numStates; is++) { /* is-th state */
	alpha[is] = - APP_INT_MAX(alg);
    }
    alpha[0] = 0;

    /* Cast the input matrices to int32 data type. Do it once.*/
    if(int32Matrices[0] == 0){
        int i;
        int uNumBits      = (int32_T)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);
        int uNumAlphabets = ( 1 << uNumBits);
        int numStates     = (int32_T)(mxGetPr(TRELLIS_NUM_STATES_ARG)[0]);
        int numElms       = numStates * uNumAlphabets;

        int32_T *int32NextState = (int32_T *)ssGetDWork(S, INT32_NEXT_STATE);
        int32_T *int32Output    = (int32_T *)ssGetDWork(S, INT32_OUTPUT);
        real_T  *output         = (real_T *)mxGetPr(TRELLIS_OUTPUT_ARG);
        real_T  *nextState      = (real_T *)mxGetPr(TRELLIS_NEXT_STATE_ARG);
        for(i = 0; i < numElms; ++i){
            int32NextState[i] = (int32_T)nextState[i];
            int32Output[i]    = (int32_T)output[i];
        }
        int32Matrices[0] = 1;
    }
}

static double RoundFcn(double arg)
{
    double y = floor(fabs(arg) + 0.5);
    return((arg < 0.0) ? -y : y);
}
#ifdef DEBUG_APP
#define RoundFcn(arg) \
     (((arg) < 0.0) ? -(floor(fabs(arg) + 0.5)) : (floor(fabs(arg) + 0.5)))
#endif

static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T        resetAlpha = 0;
    Trellis_T        trellis;
    app_T            app;
    const int_T      uWidth = ssGetInputPortWidth(S, U_INPUT);
    const int_T      cWidth = ssGetInputPortWidth(S, C_INPUT);
    real_T           *uI    = (real_T *) ssGetInputPortSignal( S, U_INPUT);
    real_T           *cI    = (real_T *) ssGetInputPortSignal( S, C_INPUT);
    /* Initialize trellis */
    trellis.uNumBits      = (int32_T)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);
    trellis.cNumBits      = (int32_T)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);
    trellis.numStates     = (int32_T)(mxGetPr(TRELLIS_NUM_STATES_ARG)[0]);
    trellis.uNumAlphabets = ( 1 << trellis.uNumBits);
    trellis.numBranches   = (trellis.numStates) * (trellis.uNumAlphabets);
    trellis.output        = (int32_T *)ssGetDWork(S, INT32_OUTPUT);
    trellis.nextState     = (int32_T *)ssGetDWork(S, INT32_NEXT_STATE);

    /* Initialize app */
    app.branchMetrics     = (real_T *) ssGetDWork(S, BRANCH_METRIC);
    app.alpha             = (real_T *) ssGetDWork(S, ALPHA);
    app.beta              = (real_T *) ssGetDWork(S, BETA);
    app.outputs.uO        = (real_T *) ssGetOutputPortSignal(S, U_OUTPUT);
    app.outputs.cO        = (real_T *) ssGetOutputPortSignal(S, C_OUTPUT);
    app.blockSize         = ssGetInputPortWidth(S, U_INPUT)/(trellis.uNumBits);
    app.currAlphaFlag     = (int32_T *)ssGetDWork(S, CURR_ALPHA_FLAG);
    app.terminationMethod = (terminationMethod_T)
                             (mxGetPr(TERMINATION_METHOD_ARG)[0]);
    app.alg               = (algorithm_T)(mxGetPr(ALGORITHM_ARG)[0]);
    app.scale             = 1;

    if(app.alg == MAX_STAR_ALG){
        app.scale = (int32_T) (mxGetPr(MAX_START_SCALE_ARG)[0]);
        app.maxStarTable = (real64_T *)mxGetPr(MAX_START_TBL_ARG);
        app.maxStarTableLength  = mxGetPr(MAX_START_TBL_LEN_ARG)[0];
    }

    resetAlpha = (app.terminationMethod == TERMINATED ||
                  app.terminationMethod == TRUNCATED);

    if(resetAlpha){
        /* mexPrintf("Reset Alpha \n"); */
        mdlInitializeConditions(S);
    }

    if(app.alg == MAX_STAR_ALG){
        real_T *maxStarUI = (real_T *)ssGetDWork(S, MAX_STAR_U_INPUT);
        real_T *maxStarCI = (real_T *)ssGetDWork(S, MAX_STAR_C_INPUT);
        int    i;
        for(i = 0; i < uWidth; ++i){
            maxStarUI[i] = RoundFcn(app.scale*uI[i]);
        }
        for(i = 0; i < cWidth; ++i){
            maxStarCI[i] = RoundFcn(app.scale*cI[i]);
        }
        app.inputs.uI = maxStarUI;
        app.inputs.cI = maxStarCI;
    }else{
        app.inputs.uI = uI;
        app.inputs.cI = cI;
    }

    app_SoftInputSoftOutput(&trellis, &app);

    if(app.alg == MAX_STAR_ALG){
        int    i;
        for(i = 0; i < uWidth; ++i){
            app.outputs.uO[i] /= (app.scale);
        }
        for(i = 0; i < cWidth; ++i){
            app.outputs.cO[i] /= (app.scale);
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE
static void AppSetPortDimensionInfo(SimStruct        *S,
                                    int_T            port,
                                    const DimsInfo_T *thisInfo)
{
    const Frame_T frameData   = ssGetInputPortFrameData( S, port);

    const int32_T uNumBits    = (int)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);
    const int32_T cNumBits    = (int)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);

    const int32_T thisFactor  = (port ==  U_INPUT) ? uNumBits: cNumBits;
    const int32_T otherFactor = (port ==  U_INPUT) ? cNumBits: uNumBits;
    int_T         otherPort   = (port ==  U_INPUT) ? C_INPUT : U_INPUT;

    DECL_AND_INIT_DIMSINFO(otherInfo);
    int_T         dims[2] = {1, 1};
    boolean_T     status  = true;
    otherInfo.dims = dims;

    /* Check input port dimensions */
    CommCheckConvCodPortDimensions(S, port, IS_INPORT, thisFactor, thisInfo);
    if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;

    status = CommGetOtherDimensions(S,IS_INPORT,
                                    thisFactor,thisInfo,
                                    otherFactor,&otherInfo,
                                    (boolean_T) frameData);
    /* Must be assert */
    if(!status){
        ssSetErrorStatus(S, COMM_ERR_ASSERT);
        goto EXIT_POINT;
    }

    if(frameData == FRAME_NO){
        /*
         * If U_INPUT or U_OUTPUT is scalar, C_INPUT can be unoriented, row or
         * column vector.
         */
        if(thisInfo->width == 1){
            otherInfo.numDims = DYNAMICALLY_SIZED;
        }
    }

    if(!ssSetInputPortDimensionInfo( S, port, thisInfo))   return;
    if(!ssSetOutputPortDimensionInfo(S, port, thisInfo))   return;

    if(!ssIsInputPortDimsInfoFullySet(S, otherPort)){
        if(!ssSetInputPortDimensionInfo( S, otherPort, &otherInfo)) return;
        if(!ssSetOutputPortDimensionInfo(S, otherPort, &otherInfo)) return;
    }

 EXIT_POINT:
    return;
}

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S,
                                         int_T            port,
                                         const DimsInfo_T *thisInfo)
{
    AppSetPortDimensionInfo(S, port, thisInfo);
}

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S,
                                          int_T            port,
                                          const DimsInfo_T *thisInfo)
{
    AppSetPortDimensionInfo(S, port, thisInfo);
}


#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    boolean_T portDimsKnown = true;
    const int32_T uNumBits  = (int)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);
    const int32_T cNumBits  = (int)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);

    DECL_AND_INIT_DIMSINFO(dInfo);
    int_T           dims[2] = {1, 1};
    dInfo.dims = dims;

    portDimsKnown = GetDefaultInputDimsIfPortDimsUnknown(S, U_INPUT,
                                                         uNumBits,&dInfo);
    if(!portDimsKnown){
        mdlSetInputPortDimensionInfo(S, U_INPUT, &dInfo);
    }

    portDimsKnown = GetDefaultInputDimsIfPortDimsUnknown(S, C_INPUT,
                                                         cNumBits,&dInfo);
    if(!portDimsKnown){
        mdlSetOutputPortDimensionInfo(S, C_INPUT, &dInfo);
    }
}

#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S,
                                     int_T     port,
                                     Frame_T   frameData)
{
    (void) port; /* unused: we know that it is data port */
    ssSetInputPortFrameData( S, 0, frameData);
    ssSetInputPortFrameData( S, 1, frameData);
    ssSetOutputPortFrameData(S, 0, frameData);
    ssSetOutputPortFrameData(S, 1, frameData);
}

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T        uInputWidth = ssGetInputPortWidth(S, U_INPUT);
    const int_T        cInputWidth = ssGetInputPortWidth(S, C_INPUT);
    const int32_T      uNumBits    = (int)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);
    const int32_T      numStates   = (int)(mxGetPr(TRELLIS_NUM_STATES_ARG)[0]);
    const int_T        blockSize   = uInputWidth/uNumBits;
    const int_T        uNumAlphabets = ( 1 << uNumBits);
    const algorithm_T  alg           = (algorithm_T)(mxGetPr(ALGORITHM_ARG)[0]);

    if(alg == MAX_STAR_ALG){
        if(!ssSetNumDWork(S, NUM_DWORK)) return;
    }else{
        if(!ssSetNumDWork(S, NUM_DWORK - 2)) return;
    }

    ssSetDWorkWidth(        S, INT32_MATRICES_UPDATED, 1);
    ssSetDWorkDataType(     S, INT32_MATRICES_UPDATED, SS_INT32);
    ssSetDWorkComplexSignal(S, INT32_MATRICES_UPDATED, COMPLEX_NO);

    ssSetDWorkWidth(        S, INT32_NEXT_STATE, numStates * uNumAlphabets);
    ssSetDWorkDataType(     S, INT32_NEXT_STATE, SS_INT32);
    ssSetDWorkComplexSignal(S, INT32_NEXT_STATE, COMPLEX_NO);

    ssSetDWorkWidth(        S, INT32_OUTPUT, numStates * uNumAlphabets);
    ssSetDWorkDataType(     S, INT32_OUTPUT, SS_INT32);
    ssSetDWorkComplexSignal(S, INT32_OUTPUT, COMPLEX_NO);

    ssSetDWorkWidth(        S, BRANCH_METRIC, numStates * uNumAlphabets);
    ssSetDWorkDataType(     S, BRANCH_METRIC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, BRANCH_METRIC, COMPLEX_NO);

    ssSetDWorkWidth(        S, ALPHA, numStates * 2);
    ssSetDWorkDataType(     S, ALPHA, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, ALPHA, COMPLEX_NO);

    ssSetDWorkWidth(        S, BETA, numStates * blockSize);
    ssSetDWorkDataType(     S, BETA, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, BETA, COMPLEX_NO);

    ssSetDWorkWidth(        S, CURR_ALPHA_FLAG, 1);
    ssSetDWorkDataType(     S, CURR_ALPHA_FLAG, SS_INT32);
    ssSetDWorkComplexSignal(S, CURR_ALPHA_FLAG, COMPLEX_NO);

    if(alg == MAX_STAR_ALG){
        ssSetDWorkWidth(        S, MAX_STAR_U_INPUT, uInputWidth);
        ssSetDWorkDataType(     S, MAX_STAR_U_INPUT, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, MAX_STAR_U_INPUT, COMPLEX_NO);

        ssSetDWorkWidth(        S, MAX_STAR_C_INPUT, cInputWidth);
        ssSetDWorkDataType(     S, MAX_STAR_C_INPUT, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, MAX_STAR_C_INPUT, COMPLEX_NO);
    }
}
#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

