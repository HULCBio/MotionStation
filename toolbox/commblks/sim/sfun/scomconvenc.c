/*
 *   SCOMCONVENC Communications Toolbox S-Function for Convolutional
 *   encoder block with trellis parameter.
 *
 *    Copyright 1996-2003 The MathWorks, Inc.
 *    $Revision: 1.22.4.4 $, $Date: 2004/04/12 23:03:19 $
 *    Author: Mojdeh Shakeri
 */

#define S_FUNCTION_NAME  scomconvenc
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "comm_defs.h"
#include "comm_mtrx.h"


enum {INPUT, RESET_INPUT};
enum {OUTPUT= 0};
enum {CURR_STATE, NUM_DWORK};

enum {NO_RESET = 1, RESET_EACH_FRAME, RESET_PORT};

enum {TRELLIS_U_NUMBITS_ARGC,   /* number of input bits    */
      TRELLIS_C_NUMBITS_ARGC,   /* number of output bits   */
      TRELLIS_NUM_STATES_ARGC,  /* number of states        */
      TRELLIS_OUTPUT_ARGC,      /* output matrix (decimal) */
      TRELLIS_NEXT_STATE_ARGC,  /* next state matrix       */
      RESET_ARGC,               /* reset signal            */
      NUM_ARGS};


#define TRELLIS_U_NUMBITS_ARG   (ssGetSFcnParam(S, TRELLIS_U_NUMBITS_ARGC))
#define TRELLIS_C_NUMBITS_ARG   (ssGetSFcnParam(S, TRELLIS_C_NUMBITS_ARGC))
#define TRELLIS_NUM_STATES_ARG  (ssGetSFcnParam(S, TRELLIS_NUM_STATES_ARGC))
#define TRELLIS_OUTPUT_ARG      (ssGetSFcnParam(S, TRELLIS_OUTPUT_ARGC))
#define TRELLIS_NEXT_STATE_ARG  (ssGetSFcnParam(S, TRELLIS_NEXT_STATE_ARGC))
#define RESET_ARG               (ssGetSFcnParam(S, RESET_ARGC))


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

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);


    /* Inputs and Outputs */
    {
        /* Inputs: */
        /* Since Reset port is a checkbox, do not need to check for [] */
        const boolean_T rstPort=(boolean_T)((int_T)(mxGetPr(RESET_ARG)[0]) ==
                                            RESET_PORT);


        int   numInputs = rstPort ? 2 : 1;
        if (!ssSetNumInputPorts(S, numInputs)) return;
        for(i = 0; i < numInputs; ++i){
            if(i == 1){ /* reset port */
                /* 1-D or 2-D scalar */
                ssSetInputPortKnownWidthUnknownDims(S, i, 1);
            }else{
                if(!ssSetInputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
            }
            ssSetInputPortFrameData(S, i, FRAME_INHERITED);
            ssSetInputPortDirectFeedThrough( S, i, 1);
            ssSetInputPortReusable(          S, i, 1);
            ssSetInputPortComplexSignal(     S, i, COMPLEX_NO);
            ssSetInputPortSampleTime(        S, i, INHERITED_SAMPLE_TIME);
            ssSetInputPortRequiredContiguous(S, i, 1);
        }

        /* Outputs: */
        if (!ssSetNumOutputPorts(        S, 1)) return;
        if(!ssSetOutputPortDimensionInfo(S, OUTPUT, DYNAMIC_DIMENSION)) return;
        ssSetOutputPortFrameData(        S, OUTPUT, FRAME_INHERITED);
        ssSetOutputPortReusable(         S, OUTPUT, 1);
        ssSetOutputPortComplexSignal(    S, OUTPUT, COMPLEX_NO);
        ssSetOutputPortSampleTime(       S, OUTPUT, INHERITED_SAMPLE_TIME);

        if (!ssSetNumDWork(S, 1)) return;
        ssSetDWorkWidth(        S, CURR_STATE, 1);
        ssSetDWorkDataType(     S, CURR_STATE, SS_INT32);
        ssSetDWorkComplexSignal(S, CURR_STATE, COMPLEX_NO);

        ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
    }
}

/* Use DSP sample time functions to set the input and output port sample times*/
#ifdef COMMBLKS_SIM_SFCN
#include "dsp_ts_sim.h"
#else
#include "dsp_ts.c"
#endif
#include "dsp_ctrl_ts.c"

static void mdlInitializeConditions(SimStruct *S)
{
    int32_T *currState = (int32_T *) ssGetDWork(S, CURR_STATE);
    currState[0] = 0;
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T            ib, ub, cb;
    int32_T          *currState = (int32_T *) ssGetDWork(S, CURR_STATE);
    int_T            rstMode    = (int_T)(mxGetPr(RESET_ARG)[0]);
    boolean_T        rstInput   = (rstMode == RESET_EACH_FRAME);
    /* Initialize siso */
    real_T           *in  = (real_T *) ssGetInputPortSignal( S, INPUT);
    real_T           *out = (real_T *) ssGetOutputPortSignal(S, OUTPUT);
    int_T            blockSize;

    /* Initialize trellis */
    int_T        uNumBits      = (int32_T)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);
    int_T        cNumBits      = (int32_T)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);
    int_T        numStates     = (int32_T)(mxGetPr(TRELLIS_NUM_STATES_ARG)[0]);
    int_T        uNumAlphabets = ( 1 << uNumBits);
    const real_T *output       = mxGetPr(TRELLIS_OUTPUT_ARG);
    const real_T *nextState    = mxGetPr(TRELLIS_NEXT_STATE_ARG);

    /* Check the inputs, make sure they are binary*/
    if((*in!=0)&&(*in!=1)){ ssSetErrorStatus(S,"The input data must be binary");}

    if (!rstInput && rstMode == RESET_PORT) {
        real_T *pRstIn = (real_T *) ssGetInputPortSignal(S, RESET_INPUT);
        if (pRstIn[0] != 0.0) {
            rstInput = 1;
        }
    }

    if(rstInput){
       mdlInitializeConditions(S);
    }

    blockSize = ssGetInputPortWidth(S, INPUT)/(uNumBits);
    for(ib = 0; ib < blockSize; ++ib){
        int    uOffset       = ib  * uNumBits;
        int    cOffset       = ib  * cNumBits;
        real_T *thisBlockIn  = in  + uOffset;
        real_T *thisBlockOut = out + cOffset;
        int inIdx = 0;
        int tmp;

        for(ub = 0; ub < uNumBits ; ++ub){  /* ub-th input(u) bits */
            inIdx += ((int_T)thisBlockIn[ub] << (uNumBits-ub-1));
        }
	tmp = (int_T)(output[currState[0]+(numStates*inIdx)]);
        currState[0] = (int_T)(nextState[currState[0]+(numStates*inIdx)]);

        for(cb = 0; cb < cNumBits ; ++cb){  /* ub-th input(c) bits */
            thisBlockOut[cNumBits - cb - 1] = (tmp & 01);
            tmp >>= 1;
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S,
                                         int_T            port,
                                         const DimsInfo_T *thisInfo)
{
    if(port == RESET_INPUT){
        if(!ssSetInputPortDimensionInfo( S, port, thisInfo))  return;
        goto EXIT_POINT;
    }else{
        const int32_T thisFactor  = (int)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);
        const int32_T otherFactor = (int)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);

        /* Check input port dimensions */
        CommCheckConvCodPortDimensions(S, port, IS_INPORT, thisFactor, thisInfo);
        if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;

        /* Set input and output port dimensions */
        CommSetInputAndOutputPortDimsInfo(S,port,IS_INPORT,thisFactor,thisInfo,otherFactor);
    }

 EXIT_POINT:
    return;
}

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S,
                                          int_T            port,
                                          const DimsInfo_T *thisInfo)
{
    const int32_T thisFactor  = (int)(mxGetPr(TRELLIS_C_NUMBITS_ARG)[0]);
    const int32_T otherFactor = (int)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);

    /* Check input port dimensions */
    CommCheckConvCodPortDimensions(S, port, IS_OUTPORT, thisFactor, thisInfo);
    if(ssGetErrorStatus(S) != NULL) goto EXIT_POINT;

    /* Set input and output port dimensions */
    CommSetInputAndOutputPortDimsInfo(S,port,IS_OUTPORT,thisFactor,thisInfo,otherFactor);
 EXIT_POINT:
    return;
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    const boolean_T hasRstPort = (boolean_T)((int_T)(mxGetPr(RESET_ARG)[0]) != 0);
    if(hasRstPort){
        SetDefaultInputPortDimsWithKnownWidth(S, RESET_INPUT);
    }

    /* Set default input and output port dimensions */
    {
        boolean_T portDimsKnown = true;
        const int32_T uNumBits = (int)(mxGetPr(TRELLIS_U_NUMBITS_ARG)[0]);
        DECL_AND_INIT_DIMSINFO(dInfo);
        int_T           dims[2] = {1, 1};
        dInfo.dims = dims;

        portDimsKnown = GetDefaultInputDimsIfPortDimsUnknown(S,INPUT,
                                                             uNumBits,&dInfo);
        if(!portDimsKnown){
            /* This will set the output port dimensions */
            mdlSetInputPortDimensionInfo(S, INPUT, &dInfo);
        }
    }
}

#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S,
                                     int_T     port,
                                     Frame_T   frameData)
{
    ssSetInputPortFrameData( S, port, frameData);
    if( port == INPUT){
        ssSetOutputPortFrameData(S, OUTPUT, frameData);
    }
}
#endif



#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

