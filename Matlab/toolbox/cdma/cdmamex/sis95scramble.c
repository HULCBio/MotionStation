/*
 *  Module Name: sis95scramble.c
 *
 *  Description:
 *      Performs the scrambling of the Forward Traffic Channel data by the  
 *      long code and the insertion of power bits in the data. Each power bit  
 *      is inserted in one power group. Performs required scrambling of the  
 *      data by the long code before data is sent to the transmitter.   
 *      The required tasks depend on the CDMA channel. In the Paging Channel, 
 *      symbols are scrambled and power level is adjusted. In the Traffic 
 *      channel, symbols are scrambled, power symbols are inserted and power 
 *      level is adjusted for different rates.
 *
 *  Inputs:
 *      Rate
 *          Integer scalar indicating the data rate: 0 for full, 1 for half, 
 *          2 for quarter,and 4 for 1/8th data rates.
 *      Frame In
 *          Binary vector, which contains the frame to be scrambled.
 *      Long Code
 *          Binary vector containing the decimated long code to be used for  
 *          scrambling of the input frame and determining the location of 
 *          power bits.
 *      Power Bits
 *          Binary vector containing the Power bits that will be inserted in 
 *          the scrambled frame at locations determined by the decimated 
 *          long code.
 * 
 *  Outputs:
 *      Frame Out
 *          Integer vector with bits represented in bipolar (± 1) format  
 *          containing the scrambled and power-bit-inserted frame, which will 
 *          be fed to the multiple-access interface for Walsh-spreading.
 * 
 *  Parameters:
 *      Rate Set
 *          Rate Set number (Rate Set 1 or Rate Set 2).
 *      Channel Type 
 *          Logical Channel Type (PAGING/TRAFFIC): 1 for PAGING and 
 *          2 for TRAFFIC.
 * 
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.13.2.1 $  $Date: 2004/04/12 23:00:00 $
 */
#define S_FUNCTION_NAME sis95scramble
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"
#include <math.h>

#define NUM_ARGS        2
#define CH_TYPE_ARG     ssGetSFcnParam(S,0)
#define RATE_SET_ARG    ssGetSFcnParam(S,1)

#define SYNC_FRAME_SIZE     512
#define TRAFFIC_FRAME_SIZE  384
#define NUM_PWR_GP_SYM      24
#define NUM_PWR_SYM         16
#define NUM_LOC_BITS        20
#define TOTAL_PORTS         5

enum {SYNC=0, PAGING, TRAFFIC};
enum {INIT_LOC=0, NUM_SP_SYMBOLS};
enum {RATESET1=0, RATESET2};

enum {RATE_96=0,RATE_48, RATE_24, RATE_12};
enum {RATE_144=0, RATE_72, RATE_36, RATE_18};

typedef struct scramblSymb{
    real_T  *decLngCd;
    real_T  *pwrBits;
    int     chType;
    int     rate;
    int     rateSet;
    int     numSpSymbols;
    int     SymbCounter;
    int     pwrSymbLoc;
    
} scrsym_par;

/* Set the power factor according to the rate */
double getGainFctr(int rate)
{
    double gainFac;
    switch (rate){
    case RATE_96:    /* Sames as RATE_144 */
        gainFac = 1.0;
        break;
    case RATE_48:    /* Sames as RATE_72 */
        gainFac = 0.70710678118655;
        break;
    case RATE_24:    /* Sames as RATE_36 */
        gainFac = 0.5;
        break;
    case RATE_12:    /* Sames as RATE_18 */
        gainFac = 0.35355339059327;
        break;
    }
    return(gainFac);       
} 


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
#ifdef MATLAB_MEX_FILE
    if ((chType != TRAFFIC) && (rateSet != RATESET1)){
        ssSetErrorStatus(S,"Rate set for Paging, Sync channel must be Rate Set I");
        return;
    }
#endif
    
    
ERROR_EXIT:
    
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
        return;
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    int numSpSymbols =  NUM_SP_SYMBOLS;
    
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
    
    for (i=0; i< NUM_ARGS; i++)
        ssSetSFcnParamNotTunable( S, i);

    if (!ssSetNumInputPorts(S, 4)) return;
    /* Rate input */
    ssSetInputPortVectorDimension(   S, 0, 1);
    ssSetInputPortFrameData(         S, 0, FRAME_NO);
	ssSetInputPortDirectFeedThrough( S, 0, 1);
    
    /* Data inputs */
    for (i = 1; i < 4; i++){
        if (!ssSetInputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
        ssSetInputPortFrameData(         S, i, FRAME_INHERITED);
    	ssSetInputPortDirectFeedThrough( S, i, 1);
    }

    /* Output */
	if (!ssSetNumOutputPorts(S,1)) return;
    if (!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, 0, FRAME_INHERITED);
    
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */ 
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 2);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)    */
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in. The widths are stored in an int
 *          array with first the input widths and then the outputs.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
    int chType = (int) mxGetScalar(CH_TYPE_ARG) - 1;
        
    widths[0]  = 1;
    widths[1]  = 1;
    widths[2]  = 1;
    widths[3]  = (int) ceil( 1.0 * NUM_SP_SYMBOLS / NUM_PWR_GP_SYM);
    switch (chType){
    case SYNC:
        widths[4] = NUM_SP_SYMBOLS * 4;
        break;
    case PAGING:
    case TRAFFIC:
        widths[4] = NUM_SP_SYMBOLS;
        break;
    }
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, int_T portIdx,
                                         Frame_T frameData)
{
    if (portIdx != 0){
        ssSetInputPortFrameData(S, 1, frameData);
        ssSetInputPortFrameData(S, 2, frameData);
        ssSetInputPortFrameData(S, 3, frameData);
	    ssSetOutputPortFrameData(S, 0, frameData);
    }
}
#endif

/* For dimension propagation and frame support */
#define NUM_INPORTS_TO_SET  4
#define FIRST_INPORTIDX_TO_SET 1  /* Start from second port */
#define NUM_OUTPORTS_TO_SET 1
#define TOTAL_PORTS_TO_SET  5  /* = TOTAL_PORTS */

#include "cdma_dim_hs.c"


static void mdlInitializeSampleTimes(SimStruct *S)
{
    int numSymbOut	= ssGetOutputPortWidth(S, 0);
    int chType = (int) mxGetScalar(CH_TYPE_ARG) - 1;
    double sample_time;
    
    switch (chType){
    case SYNC:
        sample_time = 1.0/50/SYNC_FRAME_SIZE * numSymbOut;
        break;
    case PAGING:           
    case TRAFFIC:
        sample_time = 1.0/50/TRAFFIC_FRAME_SIZE * numSymbOut;
        break;
    }
    ssSetSampleTime(S, 0, sample_time);
    ssSetOffsetTime(S, 0, 0.0);
}

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
    int numSymbIn	= ssGetInputPortWidth(S, 1);
    int numSymbOut	= ssGetOutputPortWidth(S, 0);
    int numLCIn		= ssGetInputPortWidth(S, 2);
    int numPwrIn	= ssGetInputPortWidth(S, 3);
    int chType = (int) mxGetScalar(CH_TYPE_ARG) - 1;
    int numSpSymbols =  NUM_SP_SYMBOLS;
    const char *msg = NULL;
    
#if defined(MATLAB_MEX_FILE)
    switch (chType){
    case SYNC:
        if ((numSymbIn < numSpSymbols / 4) || (numSymbOut < numSpSymbols))
            msg = "Insufficient number of inputs or outputs";
        break;
    case PAGING:
        if ((numSymbIn < numSpSymbols) || (numLCIn < numSpSymbols) || (numSymbOut < numSpSymbols))
            msg = "Insufficient number of inputs or outputs";
        break;
    case TRAFFIC:
        if ((numSymbIn < numSpSymbols) || (numPwrIn < ceil( 1.0 * numSpSymbols / NUM_PWR_GP_SYM)) 
            || (numSymbOut < numSpSymbols))
            msg = "Insufficient number of inputs or outputs";
        break;
    }
    
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
        return;
    }
    
#endif
    
    /* Get the initial bit location */
    ssSetIWorkValue(S, 0, INIT_LOC); /*initial power bit location*/
    ssSetIWorkValue(S, 1, 0); /*symbol counter*/
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    scrsym_par params;
    int index;
    real_T  *scrmblOut;
    /* Set the input  pointer*/
    InputRealPtrsType scrmblIn = ssGetInputPortRealSignalPtrs( S, 1);
    const char *msg = NULL;
    int i, inIndex=0, j, coef, auxXor, error=0;
    double gainFac;
    
    int numSymbIn	= ssGetInputPortWidth(S, 1);
    int numSymbOut	= ssGetOutputPortWidth(S, 0);
    int numLCIn		= ssGetInputPortWidth(S, 2);
    int numPwrIn	= ssGetInputPortWidth(S, 3);
    
    params.chType       = (int) mxGetScalar(CH_TYPE_ARG) - 1;
    params.rateSet      = (int) mxGetScalar(RATE_SET_ARG) - 1;
    params.numSpSymbols =  NUM_SP_SYMBOLS;
    params.pwrSymbLoc	= (int) ssGetIWorkValue(S, 0);  
    params.SymbCounter	= (int) ssGetIWorkValue(S, 1);
    params.rate         = (int) *( * (ssGetInputPortRealSignalPtrs(S, 0)));                
    
    
#if defined(MATLAB_MEX_FILE)
    
    switch (params.chType){
    case SYNC:
        {
            if ((numSymbIn < params.numSpSymbols / 4) || (numSymbOut < params.numSpSymbols))
                msg = "Insufficient number of inputs or outputs";
            if (params.rate != RATE_12)
                msg = "Data rate for Sync channel must be eighth rate";
        }
        break;
    case PAGING:
        {
            if ((numSymbIn < params.numSpSymbols) || (numLCIn < params.numSpSymbols) || (numSymbOut < params.numSpSymbols))
                msg = "Insufficient number of inputs or outputs";
            if ((params.rate!=RATE_96) && (params.rate!=RATE_48))
                msg = "Data rate for Paging channel must be full or half rate";
        } 
        break;
    case TRAFFIC:
        {
            if ((numSymbIn < params.numSpSymbols) || (numPwrIn < ceil( params.numSpSymbols / NUM_PWR_GP_SYM)) 
                || (numSymbOut < params.numSpSymbols))
                msg = "Insufficient number of inputs or outputs";
            if ((params.rate!=RATE_96) && (params.rate!=RATE_48) && (params.rate!=RATE_24) && (params.rate!=RATE_12))
                msg = "Data rate for Traffic channel is incorrect";
        }
        break;
    }
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
        return;
    }
    
#endif
    
    if (params.chType){
        params.decLngCd = (real_T *) (ssGetInputPortRealSignalPtrs(S, 2)[0]);
        if (params.chType==TRAFFIC)
            params.pwrBits = (real_T *) (ssGetInputPortRealSignalPtrs(S, 3)[0]);
    }
    /* Set the  output pointers */
    scrmblOut = (real_T *) ssGetOutputPortRealSignal(S, 0);
    
    /* Perform IS95 scrambling tasks */
    switch (params.chType){
    case SYNC:
        for (i=0; i<params.numSpSymbols*4; i++){
            inIndex =i/4;
            
            /* Collect data to check at end of loop if error in input data */
            error |= (int)(*scrmblIn[inIndex]);
            
            *(scrmblOut + i) = 1.0 - (2.0* *scrmblIn[inIndex]);
        }
        break;
        
    case PAGING:
        gainFac = getGainFctr(params.rate);
        for(i=0; i<params.numSpSymbols; i++){
            
            /* Collect data to check at end of loop if error in input data */
            error |= (int)(*scrmblIn[i]);
            
            /* Perform scrambling of incomming data and make it biploar (expects data bits in LSB). */
            auxXor = ((int) *scrmblIn[i])^((int) *(params.decLngCd +i));
            *(scrmblOut + i) = -2 * gainFac * (auxXor - 0.5);
        }
        break;
        
    case TRAFFIC:
        gainFac = getGainFctr(params.rate);
        for(i=0; i<params.numSpSymbols; i++){
            
            /* Collect data to check at end of loop if error in input data */
            error |= (int)(*scrmblIn[i]);
            
            /* Perform data scrambling. */
            auxXor = ((int) *scrmblIn[i])^((int) *(params.decLngCd +i));
            *(scrmblOut + i) = -2 * gainFac * (auxXor - 0.5);
            
            /* If a second power bit is needed (in rate set one)*/
            if ( params.pwrSymbLoc == -1){
                *(scrmblOut + i) = 1.0 - 2* *(params.pwrBits + i / NUM_PWR_GP_SYM);
                params.pwrSymbLoc = -2;
            }
            
            /* If the current location is the location of a power bit */
            else if ( params.SymbCounter == params.pwrSymbLoc){
                *(scrmblOut + i) = 1.0 - 2* *(params.pwrBits + i / NUM_PWR_GP_SYM);		
                if (params.rateSet == 0)
                    params.pwrSymbLoc = -1;
            }
            
            /* If the current location is part of the {20, 21, 22, 23} bits */
            /* used to determine the next power bit location */
            else if ( params.SymbCounter >= NUM_LOC_BITS ){
                if (params.SymbCounter == NUM_LOC_BITS )
                    params.pwrSymbLoc = 0;
                coef = 1;
                for (j=20; j< params.SymbCounter; j++)
                    coef *= 2;
                params.pwrSymbLoc += (int) floor(*(params.decLngCd + i)) * coef;				
            }
            params.SymbCounter = (params.SymbCounter+1) % NUM_PWR_GP_SYM;
        } /* for */
        break;
    } /* switch */
    
    /* If error in input data then inform user */
    if ((error != 0) && (error != 1)) {
        ssSetErrorStatus(S,"Input must be a binary vector");
        return;
    }
        
    /* store the location of the power symbol */
    ssSetIWorkValue(S, 0, params.pwrSymbLoc);
    ssSetIWorkValue(S, 1, params.SymbCounter);
}


static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
