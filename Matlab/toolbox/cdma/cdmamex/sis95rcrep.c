/*
 *  Module Name: sis95rcrep.c
 *
 *  Description:
 *      Repeats the symbols of the convolutionally encoded frame according to 
 *      the IS-95A specifications for the Reverse channel based on the current  
 *      data rate. For rate set 1 it repeats each convolutional encoded symbol  
 *      prior to block interleaving whenever the information rate is lower  
 *      than full rate. For all data rates this results in a constant modulation  
 *      symbol rate. For rate set 2, beside repeating, it punctures some symbols 
 *      to have the same output rate as in rate set 1.
 * 
 *  Inputs:
 *      Rate 
 *          Integer scalar indicating the data rate; 0 for full, 1 for half,  
 *          2 for quarter, and 4 for 1/8th data rates.
 *      Frame In
 *          Binary vector representing the input data frame,
 * 
 *  Outputs
 *      Frame Out
 *          Binary vector representing the repeated output frame.
 * 		
 *  Parameters:
 *      Channel Type
 *          Logical Channel Type (ACCESS/TRAFFIC): 1 for ACCESS, 2 for TRAFFIC.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.12.2.1 $  $Date: 2004/04/12 22:59:55 $
 */
#define S_FUNCTION_NAME sis95rcrep
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"

#define NUM_ARGS        2
#define CH_TYPE_ARG     ssGetSFcnParam(S,0)
#define REP_SWTCH_ARG   ssGetSFcnParam(S,1)

enum {ACCESS=1, TRAFFIC};

enum {RATE_96=0, RATE_48, RATE_24, RATE_12};
enum {RATE_144=0, RATE_72, RATE_36, RATE_18};

#define SIM_MAX_RL_REP_FR_SIZE  576
#define TOTAL_PORTS             3

#define REP_RATE        params.repRate
#define SYMB_LEN        params.symbLen
#define REP_SWCH        params.repSwch

typedef struct rlrep{
    int repRate;
    int symbLen;
    int repSwch; 
}  rlrep_par;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    
    if ((mxGetM(CH_TYPE_ARG)*mxGetN(CH_TYPE_ARG) != 1) ||
        ((mxGetPr(CH_TYPE_ARG)[0] != (real_T) 1.0) &&
        (mxGetPr(CH_TYPE_ARG)[0] != (real_T) 2.0))) {
        msg = "Channel type must be 1 or 2";
        goto ERROR_EXIT;
    }
    
    if (mxGetM(REP_SWTCH_ARG)*mxGetN(REP_SWTCH_ARG) != 1) {
        msg = "Repeater switch must be a scalar";
        goto ERROR_EXIT;
    }
    
ERROR_EXIT:
    
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
        return;
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Simulink will report a parameter mismatch error */
    }
#endif
    
    ssSetSFcnParamNotTunable(S, 0);

    if (!ssSetNumInputPorts(S, 2)) return;
    /* Rate input */
    ssSetInputPortVectorDimension(   S, 0, 1);
    ssSetInputPortFrameData(         S, 0, FRAME_NO);
	ssSetInputPortDirectFeedThrough( S, 0, 1);

    /* Data input */
    if (!ssSetInputPortDimensionInfo(S, 1, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, 1, FRAME_INHERITED);
	ssSetInputPortDirectFeedThrough( S, 1, 1);

    /* Output */
	if (!ssSetNumOutputPorts(S,1)) return;
    if (!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, 0, FRAME_INHERITED);
    
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)*/
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in. The widths are stored in an int
 *          array with first the input widths and then the outputs.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
    widths[0]  = 1;
    widths[1]  = SIM_MAX_RL_REP_FR_SIZE;
    widths[2]  = SIM_MAX_RL_REP_FR_SIZE; 
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, int_T portIdx,
                                         Frame_T frameData)
{
    if (portIdx == 1){
        ssSetInputPortFrameData(S, 1, frameData);
	    ssSetOutputPortFrameData(S, 0, frameData);
    }
}
#endif

/* For dimension propagation and frame support */
#define NUM_INPORTS_TO_SET  2
#define FIRST_INPORTIDX_TO_SET 1  /* Start from second port */
#define NUM_OUTPORTS_TO_SET 1
#define TOTAL_PORTS_TO_SET  3  /* = TOTAL_PORTS */

#include "cdma_dim_hs.c"

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */


static void mdlOutputs(SimStruct *S, int_T tid)
{
    rlrep_par params;
    int i, index, rate, chType, rlrepError;
    int j, repError=0;
    real_T *pVec;
    const char *msg = NULL;
    
    InputRealPtrsType pprepIn = ssGetInputPortRealSignalPtrs( S, 1);
    real_T *repOut            = ssGetOutputPortRealSignal(S,0);
    
    chType = (int) mxGetPr(CH_TYPE_ARG)[0];
    rate   = (int) *( *(ssGetInputPortRealSignalPtrs( S, 0)));
    
    switch(chType){
    case ACCESS:
        if (rate!=RATE_48){
            msg = "Data rate for Access channel must be half rate";
            goto ERROR_EXIT;
        }
        
        break;
    case TRAFFIC:
        if ((rate!=RATE_96) && (rate!=RATE_48) && (rate!=RATE_24) && (rate!=RATE_12)){
            msg = "Data rate for Traffic channel is incorrect";
            goto ERROR_EXIT;
        }
        
        break;
    }
    
    params.repSwch = (int) mxGetPr(REP_SWTCH_ARG)[0];   
    params.repRate = 1 << rate;
    params.symbLen = SIM_MAX_RL_REP_FR_SIZE /params.repRate;
    
    /* Perfrom IS95 symbol repetition tasks */
    switch(REP_SWCH){
    case 1:             /* Repeat Input Symbols */
        pVec = repOut;
        for (i=0; i<SYMB_LEN; i++){
            
            /* Collect data to check at end of loop if error in input data */
            repError |= (int)(*pprepIn[i]);
            
            for (j=0; j<REP_RATE; j++)
                *pVec++ = *pprepIn[i];
        }
        break;
    case 0:         /* De-repeat Input Symbols */
        pVec = (real_T *) *pprepIn;
        for (i=0; i<SYMB_LEN; i++){
            repOut[i] = 0.0;
            for (j=0; j<REP_RATE; j++)
                repOut[i] += *pVec++;
            repOut[i] /= (real_T) REP_RATE;
        }
        break;
    default:            /* Repeat Input Symbols */
        pVec = repOut;
        for (i=0; i<SYMB_LEN; i++){
            for (j=0; j<REP_RATE; j++)
                *pVec++ = *pprepIn[i];
        }
        break;            
    }
    /* If error in input data then inform user */
    if ((repError != 0) && (repError != 1)) {
        msg = "Input must be a binary vector";
        goto ERROR_EXIT;
    }

    /* De-repeat Input Symbols */
    if (params.repSwch == 0){
        for (i=params.symbLen; i<SIM_MAX_RL_REP_FR_SIZE; i++)
            repOut[i] = 0.0;
    }
    
ERROR_EXIT:
#ifdef MATLAB_MEX_FILE
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
        return;
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{
}


/*=============================*
* Required S-function trailer *
*=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
