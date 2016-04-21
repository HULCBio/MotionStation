/*
 *  Module Name: sis95enc.c
 *
 *  Description:
 *      Convolutionally encodes the CRC and tail bits added frame according to 
 *      the IS-95A specifications. The convolutional encoding involves the  
 *      modulo-2 addition of selected taps of serial time-delayed data sequence. 
 *      It is rate 1/2, with a constraint length 9. The generator functions of 
 *      the code are 753 (octal) and 561 (octal). The state of the convolutional 
 *      encoder, upon initialization, is the all-zero state.
 * 
 *  Inputs:
 *      Rate
 *          Integer scalar indicating the data rate; 0 for full,
 *          1 for half, 2 for quarter, and 4 for 1/8th data rates.
 *      Frame In
 *          Binary vector representing the CRC and tail-bit added input frame.
 * 
 *  Outputs:
 *      Frame Out
 *          Binary vector representing the convolutionally encoded output frame.
 *	
 *  Parameters:
 *      Channel Type 
 *          Logical Channel Type (SYNC/PAGING/TRAFFIC): 1 for SYNC, 
 *          2 for PAGING and 3 for TRAFFIC.
 *      Rate Set
 *          Rate Set number (Rate Set 1 or Rate Set 2).
 *      Encoder Initial State
 *          Integer scalar, that provides the initial state of the 
 *          convolutional encoder.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.11.2.1 $  $Date: 2004/04/12 22:59:44 $
 */
#define S_FUNCTION_NAME sis95enc
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"

#define NUM_ARGS        3
#define CH_TYPE_ARG     ssGetSFcnParam(S,0)
#define RATE_SET_ARG    ssGetSFcnParam(S,1)
#define ENC_STATE_ARG   ssGetSFcnParam(S,2)

#define SIM_MAX_ENC_FR_SIZE    576
#define SIM_MAX_TAIL_FR_SIZE   288

#define SYNC    0
#define PAGING  1
#define ACCESS  1
#define TRAFFIC 2

enum {RATESET1=0, RATESET2};
enum {RATE_96=0, RATE_48, RATE_24, RATE_12};
enum {RATE_144=0, RATE_72, RATE_36, RATE_18};


/* Encodes the incoming frame using convolution encoder */

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    int chType, rateSet;
    
    if ((mxGetM(CH_TYPE_ARG)*mxGetN(CH_TYPE_ARG) != 1) ||
        ((mxGetPr(CH_TYPE_ARG)[0] != (real_T) 1.0) &&
        (mxGetPr(CH_TYPE_ARG)[0] != (real_T) 2.0) &&
        (mxGetPr(CH_TYPE_ARG)[0] != (real_T) 3.0))) {
        msg = "Channel type must be 1, 2 or 3";
        goto ERROR_EXIT;
    }
    chType  = (int) mxGetScalar(CH_TYPE_ARG) - 1;
    
    if ((mxGetM(RATE_SET_ARG)*mxGetN(RATE_SET_ARG) != 1) ||
        ((mxGetPr(RATE_SET_ARG)[0] != (real_T) 1.0) &&
        (mxGetPr(RATE_SET_ARG)[0] != (real_T) 2.0))) {
        msg = "Rate set must be 1 or 2";
        goto ERROR_EXIT;
    }
    rateSet = (int) mxGetScalar(RATE_SET_ARG) - 1;
#ifdef MATLAB_MEX_FILE
    if ((chType != TRAFFIC) && (rateSet != RATESET1)){
        ssSetErrorStatus(S,"Rate set for Paging and Sync channel must be Rate Set I");
        return;
    }
#endif
    
    if ((mxGetM(ENC_STATE_ARG)*mxGetN(ENC_STATE_ARG) != 0) &&
        ((mxGetM(ENC_STATE_ARG)*mxGetN(ENC_STATE_ARG) != 2) &&
        ((mxGetPr(ENC_STATE_ARG)[0] < 0.0)|| (mxGetPr(ENC_STATE_ARG)[1] < 0.0) ||
        (floor(mxGetPr(ENC_STATE_ARG)[0]) != mxGetPr(ENC_STATE_ARG)[0]) ||
        (floor(mxGetPr(ENC_STATE_ARG)[1]) != mxGetPr(ENC_STATE_ARG)[1])))){
        msg = "Initial encoder state must be a 2-element positive integer vector or empty";
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
    ssSetNumPWork(         S, 1);   /* number of pointer work vector elements*/   
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)        */
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in. The widths are stored in an int
 *          array with first the input widths and then the outputs.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
    /* Inputs */
    widths[0] = 1;
    widths[1] = SIM_MAX_TAIL_FR_SIZE;

    /* Outputs */
    widths[2] = SIM_MAX_ENC_FR_SIZE;
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
#define TOTAL_PORTS_TO_SET  3

#include "cdma_dim_hs.c"

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)

{
    long  *encState;
    int chType  = (int) mxGetScalar(CH_TYPE_ARG) - 1;
    real_T *pEncStPar = mxGetPr(ENC_STATE_ARG);
    
    encState = (long *) calloc(2, sizeof(long));
#ifdef MATLAB_MEX_FILE
    if (encState==NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
    
#endif
    
    ssSetPWorkValue(S, 0, encState);
    
    if ((mxGetM(ENC_STATE_ARG)*mxGetN(ENC_STATE_ARG) == 0) || (chType == TRAFFIC)){
        encState[0] = 0;
        encState[1] = 0;
    } else{
        encState[0] = (long) pEncStPar[0];
        encState[1] = (long) pEncStPar[1];
    }
}
#endif	/* MDL_INITIALIZE_CONDITIONS */   

static void mdlOutputs(SimStruct *S, int_T tid)
{
    const char *msg = NULL;
    int inCodeLen, index, i, is95encError;
    long  *encState = (long *) ssGetPWorkValue(S, 0);
    /* Set the input/output pointers */
    real_T	*encOut =  ssGetOutputPortRealSignal(S,0);
    int chType  = (int) mxGetScalar(CH_TYPE_ARG) - 1;
    int rateSet = (int) mxGetScalar(RATE_SET_ARG) - 1;
    int rate = (int) *( *(ssGetInputPortRealSignalPtrs( S, 0)));
    InputRealPtrsType ppEncIn =  ssGetInputPortRealSignalPtrs( S, 1);
    
    /* gen1, and gen2 do not change between different instances */
    int gen1 = 0x1AF, gen2 = 0x11D; 
    int temp, encError=0;
    
    
    /* First determining size of output and repetition rate */
    switch(chType){
    case SYNC: 
        if (rate == RATE_12)
            inCodeLen = 32;    
        else{
#ifdef MATLAB_MEX_FILE
            ssSetErrorStatus(S,"Data rate for Sync channel must be eighth rate");
            return;
#endif
        }
        
        break;
    case PAGING:
        switch (rate){
        case RATE_96:
            inCodeLen = 192;       
            break;
        case RATE_48:
            inCodeLen = 96;   
            break;
        default:
#ifdef MATLAB_MEX_FILE
            ssSetErrorStatus(S,"Data rate for Paging channel must be full or half rate");
            return;
#endif
            
        }
        break; 
        case TRAFFIC:
            switch (rateSet){
            case RATESET1:
                switch (rate){
                case RATE_96:
                    inCodeLen = 192;       
                    break;
                case RATE_48:
                    inCodeLen = 96;   
                    break;
                case RATE_24:
                    inCodeLen = 48;   
                    break;
                case RATE_12:
                    inCodeLen = 24;   
                    break;
                default:
#ifdef MATLAB_MEX_FILE
                    ssSetErrorStatus(S,"Data rate for Traffic channel is incorrect");
                    return;
#endif
                }
                break;
                case RATESET2:
                    switch (rate){
                    case RATE_144:
                        inCodeLen = 288;       
                        break;
                    case RATE_72:
                        inCodeLen = 144;   
                        break;
                    case RATE_36:
                        inCodeLen = 72;   
                        break;
                    case RATE_18:
                        inCodeLen = 36;   
                        break;
                    default:
#ifdef MATLAB_MEX_FILE
                        ssSetErrorStatus(S,"Data rate for Traffic channel is incorrect");
                        return;
#endif
                    }
                    break;
            }
            break;   
    }
    
    /* Perform IS95 convolutional encoder tasks */
    encState[0] &= (long) 0xff;
    encState[1] &= (long) 0xff;
    
    for (i=0; i<inCodeLen; i++){
        /* Collect data to check at end of loop if error in input data */
        encError |= (int)(*ppEncIn[i]);
        
        /* Get next SR encState & Output*/
        temp = (int) *(*ppEncIn + i);
        encState[0] ^= temp * gen1;
        *(encOut + 2*i) = (real_T) (encState[0] & 0x1);
        encState[0] >>= 1;
        
        /* Get next SR encState & Output*/
        encState[1] ^= temp * gen2;
        *(encOut + 2*i + 1) = (real_T) (encState[1] & 0x1);
        encState[1] >>= 1;
    }
    
    /* If error in input data then inform user */
    if ((encError != 0) && (encError != 1)) {
        msg = "Input must be a binary vector";
        goto ERROR_EXIT;
    }
    
    for (index=2*inCodeLen; index<SIM_MAX_ENC_FR_SIZE; index++)
        encOut[index] = 0.0;
    
    /* reset the encoder state for TRAFFIC frames */
    if (chType == TRAFFIC){
        encState[0] = 0;
        encState[1] = 0;
    } 
    
ERROR_EXIT:
    
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
        return;
    }
}


static void mdlTerminate(SimStruct *S)
{
    long  *encState = (long *) ssGetPWorkValue(S, 0);
    free(encState);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
