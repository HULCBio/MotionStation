/*
 *  Module Name: sis95rep.c
 *  
 *  Description:
 *      Repeats the symbols of the convolutionally encoded frame according to 
 *      the IS-95A specifications for the Forward channel based on the current  
 *      data rate.  For rate set 1 it repeats each convolutionally encoded  
 *      symbol prior to block interleaving whenever the information rate is  
 *      lower than full rate.  For all data rate this results in a constant 
 *      modulation symbol rate.  For rate set 2, beside repeating, punctures  
 *      some symbols to have the same out put  rate as in ret set1.  
 *      The de-repeater averages over the repeated data and inserts zeros in 
 *      the location of punctured symbols.
 *
 *  Inputs:
 *      Rate
 *          Integer scalar indicating the data rate; 0 for full, 1 for half, 
 *          2 for quarter, and 4 for 1/8th data rates.
 *      Frame In
 *          Binary vector representing the convolutionally-encoded input frame.
 * 
 *  Outputs:
 *      Frame Out
 *          Binary vector representing the repeated output frame.
 *
 *		
 *  Parameters:
 *      Channel Type
 *          Logical Channel Type (SYNC/PAGING/TRAFFIC): 1 for SYNC, 2 for PAGING 
 *          and 3 for TRAFFIC.
 *      Rate Set
 *          Rate Set number (Rate Set 1 or Rate Set 2).
 *      Repeater Option
 *          Integer Scalar, that enables to run either repeater (1) or 
 *          de-repeater (0).
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.10.2.1 $  $Date: 2004/04/12 22:59:58 $
 */
#define S_FUNCTION_NAME sis95rep
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"

#define NUM_ARGS        3
#define CH_TYPE_ARG     ssGetSFcnParam(S,0)
#define RATE_SET_ARG    ssGetSFcnParam(S,1)
#define REP_SWTCH_ARG   ssGetSFcnParam(S,2)

#define SIM_MAX_ENC_FR_SIZE     576
#define SIM_MAX_REP_FR_SIZE     384
#define TOTAL_PORTS             3

enum {SYNC=0, PAGING, TRAFFIC};
enum {RATESET1=0, RATESET2};

enum {RATE_96=0,RATE_48, RATE_24, RATE_12};
enum {RATE_144=0, RATE_72, RATE_36, RATE_18};

#define REP_RATE        params.repRate
#define SYMB_LEN        params.symbLen
#define REP_SWITCH      params.repSwitch
#define NO_PUNCT        params.noPunct

typedef struct Repater{
    int repRate;
    int symbLen;
    int repSwitch;
    int noPunct;
} Repater_par;

/* Performs symbol repetition according is95 Standard */
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
    
    if ((mxGetM(RATE_SET_ARG)*mxGetN(RATE_SET_ARG) != 1) ||
        ((mxGetPr(RATE_SET_ARG)[0] != (real_T) 1.0) &&
        (mxGetPr(RATE_SET_ARG)[0] != (real_T) 2.0))) {
        msg = "Rate set must be 1 or 2";
        goto ERROR_EXIT;
    }
    chType  = (int) mxGetScalar(CH_TYPE_ARG) - 1;
    rateSet = (int) mxGetScalar(RATE_SET_ARG) - 1;
    
    if ((chType != TRAFFIC) && (rateSet != RATESET1)){
        msg = 	"Rate set for Paging and Sync channel must be Rate Set I";
        goto ERROR_EXIT;
    }
    
    if (mxGetM(REP_SWTCH_ARG)*mxGetN(REP_SWTCH_ARG) != 1) {
        msg = "Repeater switch must be a scalar";
        goto ERROR_EXIT;
    }
    
    
ERROR_EXIT:
    
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
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
    
    ssSetNumContStates(    S, 0);   /* number of continuous states       */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states         */ 
    ssSetNumSampleTimes(   S, 1);   /* number of sample times        */
    ssSetNumRWork(     S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(     S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(     S, 0);   /* number of pointer work vector elements*/
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)*/
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in. The widths are stored in an int
 *          array with first the input widths and then the outputs.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
    int chType   = (int) mxGetPr(CH_TYPE_ARG)[0] - 1;
    int repSwtch = (int) mxGetScalar(REP_SWTCH_ARG);
    int aux = 1;
    
    if (chType == SYNC)
        aux = 3;

    widths[0]  = 1;
    if (repSwtch){ /* Repeater */
        widths[1]  = SIM_MAX_ENC_FR_SIZE;
        widths[2]  = SIM_MAX_REP_FR_SIZE/aux;
    } else { /* Derepeater */
        widths[1]  = SIM_MAX_REP_FR_SIZE/aux;
        widths[2] = SIM_MAX_ENC_FR_SIZE;
    }
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

#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)

{
    int chType   = (int) mxGetPr(CH_TYPE_ARG)[0] - 1;
    int aux = 1, numSymb;
    
    if (chType == SYNC)
        aux = 3;
    
    numSymb = SIM_MAX_REP_FR_SIZE / aux;
    
}
#endif	/* MDL_INITIALIZE_CONDITIONS */


static void mdlOutputs(SimStruct *S, int_T tid)
{
    Repater_par params;
    
    int chType   = (int) mxGetPr(CH_TYPE_ARG)[0] - 1;
    int rateSet  = (int) mxGetPr(RATE_SET_ARG)[0] - 1;
    int numOut   = ssGetOutputPortWidth(S,0);
    int repSwtch = (int) mxGetScalar(REP_SWTCH_ARG);
    int inSymbLen, outSymbLen, index, repError;
    int aux = 1, numSymb, rate;
    const char *msg = NULL;
    int i, j, k, repNum, error=0;
    real_T *pVec;
    
    InputRealPtrsType pprepIn =  ssGetInputPortRealSignalPtrs( S, 1);
    real_T *repOut =  ssGetOutputPortRealSignal(S,0);
    
    params.repSwitch = (int) mxGetPr(REP_SWTCH_ARG)[0];
    if (chType == SYNC)
        aux = 3;
    
    numSymb = SIM_MAX_REP_FR_SIZE / aux;
    
    rate = (int) *( *(ssGetInputPortRealSignalPtrs( S, 0)));
    
    switch(chType){
    case SYNC: 
        if (rate != RATE_12){
            msg = "Data rate for Sync channel must be eighth rate";
            goto ERROR_EXIT;
        }
        
        break;
    case PAGING:
        if ((rate!=RATE_96) && (rate!=RATE_48)){
            msg = "Data rate for Paging channel must be full or half rate";
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
    
    /* First determine size of output and repetition rate */
    if (chType){
        outSymbLen = 384;
        params.repRate = 1 << rate;
        /* Holds true for either rate sets and traffic or paging channels */
        if ((chType == 2) && (rateSet == 1)){
            params.symbLen = 576 / params.repRate;
            params.noPunct = 0;
        } else{
            params.symbLen = 384 / params.repRate;
            params.noPunct = 1;
        }
    } else{
        outSymbLen = 128;
        params.repRate = 2;
        params.symbLen = 64;
        params.noPunct = 1;
    }
    
    if (params.repSwitch){
        inSymbLen  = params.symbLen;
    }else{
        inSymbLen  = outSymbLen;
        outSymbLen = params.symbLen;
    }
    
    
    
    /* Perform IS95 symbol repetition tasks */
    switch(REP_SWITCH){
    case 1:         /* Repeat (& Puncture) Input Symbols */
        pVec = repOut;
        for (i=0; i<SYMB_LEN; i++){
            
            /* Collect data to check at end of loop if error in input data */
            error |= (int)(*pprepIn[i]);
            
            for (j=0; j<REP_RATE; j++){
                /* k = i*REP_RATE + j*/
                k = i*REP_RATE + j;
                if ( NO_PUNCT || ((k%6 != 2) && (k%6 != 4)) ) 
                    *pVec++ = *pprepIn[i];
            }
        }
        
        break;
    case 0:     /* De-repeat (& De-puncture) Input Symbols */
        pVec = (real_T *) *pprepIn;
        for (i=0; i<SYMB_LEN; i++){
            repOut[i] = 0.0;
            repNum = (real_T) 0.0;
            for (j=0; j<REP_RATE; j++){
                /* k = i*REP_RATE + j*/
                k = i*REP_RATE + j;
                if ( NO_PUNCT || ((k%6 != 2) && (k%6 != 4)) ){
                    
                    /* repOut[i] += *pVec++; */
                    
                    repOut[i] += *pVec++;
                    repNum += 1;
                }
                
            }
            
            repOut[i] /= (repNum + (repNum==0)); 
            
        }
        break;
        
    default:        /* Repeat (& Puncture) Input Symbols */
        pVec = repOut;
        for (i=0; i<SYMB_LEN; i++){
            for (j=0; j<REP_RATE; j++){
                k = i*REP_RATE + j;
                if ( NO_PUNCT || ((k%6 != 2) && (k%6 != 4)) )
                    *pVec++ = *pprepIn[i];
            }
        }
        
    }
    /* If error in input data then inform user */
    if ((error != 0) && (error != 1))
        repError = 1;
    else
        repError = 0;
    
    if (repError != 0){
        msg = "Input must be a binary vector";
        goto ERROR_EXIT;
    }
    
    for (index=outSymbLen; index<numOut; index++)
        repOut[index] = 0.0;
    

ERROR_EXIT:
#ifdef MATLAB_MEX_FILE
    if (msg != NULL)
        ssSetErrorStatus(S,msg);
#endif
}


static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
