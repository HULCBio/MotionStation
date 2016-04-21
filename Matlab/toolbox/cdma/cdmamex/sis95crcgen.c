/*
 *  Module Name: sis95crcgen.c
 *
 *  Description:
 *      Generates CRC (Cyclic Redundancy Check) bits, using a generator  
 *	polynomial specified in IS-95A specifications, and adds it along  
 *	with the tail bits to the Traffic frame. CRC bits are calculated 
 *      on all bits within the frame.
 *
 *  Inputs:
 *	Rate
 *	    Integer scalar indicating the data rate; 0 for full, 1 for half, 
 *	    2 for quarter, and 4 for 1/8th data rates.
 *	Frame In
 *	    Binary vector representing the input frame.
 * 
 *  Outputs:
 *	Frame Out
 *	    Binary vector representing the CRC and tail bits added output frame.
 * 
 *  Parameters:
 *	Channel Type
 *	Logical Channel Type (SYNC/PAGING/ACCESS/TRAFFIC)
 *	    1 for SYNC, 2 for PAGING, 3 for ACCESS and 4 for TRAFFIC.
 *	Rate Set
 *	    Rate Set number (Rate Set 1 or Rate Set 2).
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.14.2.1 $  $Date: 2004/04/12 22:59:42 $
 */
 
#define S_FUNCTION_NAME sis95crcgen
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"
#include <math.h>

#define NUM_ARGS        3
#define CH_TYPE_ARG     ssGetSFcnParam(S,0)
#define RATE_SET_ARG    ssGetSFcnParam(S,1)
#define CRC_SWTCH_ARG   ssGetSFcnParam(S,2)

#define CRC_STATE       params->crcState
#define CRC_SWITCH      params->crcSwtch
#define GENERATOR       params->generator
#define CRC_ORDER       params->crcorder 
#define FRAME_LEN       params->framelen

#define SIM_MAX_SPEECH_FR_SIZE  268
#define SIM_MAX_CRC_FR_SIZE     280

enum {SYNC=0, PAGING, ACCESS, TRAFFIC};
enum {RATESET1=0, RATESET2};

enum {RATE_96=0,RATE_48, RATE_24, RATE_12};
enum {RATE_144=0, RATE_72, RATE_36, RATE_18};

typedef struct crcEng{
    unsigned long  crcState;
    int            crcSwtch;
    long           generator;
    int            crcorder;
    int            framelen;
} crcEng_par;          

int crcEngine(real_T  *pOut, InputRealPtrsType pIn, crcEng_par *params)
{
    int index, crcOut, inBit, flag=0;
    real_T  dataLen;
    
    dataLen = FRAME_LEN - CRC_ORDER;
    
    if (CRC_ORDER){
        for (index=0; index<FRAME_LEN; index++){
            crcOut = CRC_STATE >> (int)(CRC_ORDER - 1) & 0x1;
            /* Collect data to check at end of loop if error in input data */
            flag |= (int)(*pIn[index]);
            
            if (index < dataLen){
                pOut[index] = *pIn[index];
                inBit = (((int) *pIn[index]) & 0x1) ^ crcOut; 
                
            }else if (CRC_SWITCH){
                pOut[index] = (real_T)crcOut;
                inBit = 0;
            } else{
                inBit = (((int) *pIn[index]) & 0x1) ^ crcOut;
                
            }
            
            CRC_STATE <<= 1;
            CRC_STATE ^=(int) (inBit * GENERATOR);
            
        }
    }else{
        for (index=0; index<FRAME_LEN; index++){
            /* Collect data to check at end of loop if error in input data */
            flag |= (int)(*pIn[index]);
            pOut[index] = *pIn[index];
        }
    }
    
    /* If error in input data then inform user */
    if ((flag != 0) && (flag != 1))  return (1);
    else  return (0);
    
}

int crcSyndrom(real_T  *pOut1, real_T  *pOut2, InputRealPtrsType pIn,
               crcEng_par *params )
{
    int temp, flag;
    long mask;
    
    flag = crcEngine(pOut1, pIn, params);
    mask = (unsigned long) (ldexp(1.0, (int)CRC_ORDER) - 1.0);
    
    if (CRC_ORDER){
        temp = (long) CRC_STATE;
        temp &= mask;
        CRC_STATE = temp;
        *pOut2 = (real_T) (CRC_STATE != 0);
        
    } else
        *pOut2 = -1;
    
    return flag;
    
}

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS

static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    int chType, rateSet;
    
    if ((mxGetM(CH_TYPE_ARG)*mxGetN(CH_TYPE_ARG) != 1) ||
        ((mxGetPr(CH_TYPE_ARG)[0] != (real_T) 1.0) &&
        (mxGetPr(CH_TYPE_ARG)[0] != (real_T) 2.0) &&
        (mxGetPr(CH_TYPE_ARG)[0] != (real_T) 3.0) &&
        (mxGetPr(CH_TYPE_ARG)[0] != (real_T) 4.0))) {
        msg = "Channel type must be 1, 2, 3 or 4";
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
        msg = "Rate set for Paging and Sync channel must be Rate Set I";
        goto ERROR_EXIT;
    }
    
    if (mxGetM(CRC_SWTCH_ARG)*mxGetN(CRC_SWTCH_ARG) != 1) {
        msg = "CRC switch must be a scalar";
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
    int crcSwtch;
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
    
    crcSwtch = (int) mxGetPr(CRC_SWTCH_ARG)[0];
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
    if (crcSwtch){
		if (!ssSetNumOutputPorts(S,1)) return;
	    if (!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
	    ssSetOutputPortFrameData(         S, 0, FRAME_INHERITED);
    } else {
        if (!ssSetNumOutputPorts(S, 2)) return;
	    if (!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
	    ssSetOutputPortFrameData(         S, 0, FRAME_INHERITED);

        ssSetOutputPortVectorDimension(   S, 1, 1);
        ssSetOutputPortFrameData(         S, 1, FRAME_NO);
    }

    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general
                                                      options (SS_OPTION_xx)*/
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in. The widths are stored in an int
 *          array with first the input widths and then the outputs.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
    if (ssGetNumOutputPorts(S) == 1) { /* CRC Generator */
        /* Inputs */
        widths[0] = 1;
        widths[1] = SIM_MAX_SPEECH_FR_SIZE;
        /* Outputs */
        widths[2] = SIM_MAX_CRC_FR_SIZE + 8;

    } else if (ssGetNumOutputPorts(S) == 2) { /* Syndrome Detector */
        /* Inputs */
        widths[0] = 1;
        widths[1] = SIM_MAX_CRC_FR_SIZE + 8;
        /* Outputs */
        widths[2] = SIM_MAX_SPEECH_FR_SIZE;

    }
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, int_T portIdx,
                                         Frame_T frameData)
{
    if (portIdx == 1){
        ssSetInputPortFrameData( S, 1, frameData);
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

/* Sample time initialization */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0,INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */

/* mdlOutputs - compute the outputs */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    crcEng_par params;
    const char *msg = NULL;
    real_T  *crcOut, *crcError;
    int chType   = (int) mxGetPr(CH_TYPE_ARG)[0] - 1;
    int rateSet  = (int) mxGetPr(RATE_SET_ARG)[0] - 1;
    int index, outBlkSize, outFrameLen, flag;
     
    int rate                  = (int) *( *(ssGetInputPortRealSignalPtrs( S, 0)));
    InputRealPtrsType ppCrcIn =  ssGetInputPortRealSignalPtrs( S, 1);
    crcOut                    =  ssGetOutputPortRealSignal(S,0);
    
    params.crcSwtch = (int) mxGetPr(CRC_SWTCH_ARG)[0];
    params.crcState = ~(0x0);
    
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
    case ACCESS:
        if (rate!=RATE_48){
            msg = "Data rate for Access channel must be half rate";
            goto ERROR_EXIT;
        }
        
        break;
    case TRAFFIC:
        if ((rate!=RATE_96) && (rate!=RATE_48)
             && (rate!=RATE_24) && (rate!=RATE_12)){
            msg = "Data rate for Traffic channel is incorrect";
            goto ERROR_EXIT;
        }
        
        break;
    }
    
    
    /* Get the code and size parameters */
    {
        long generator;
        int  codeLen, crcOrder;
        
        switch(chType){
        case SYNC: 
            codeLen = 32;    
            crcOrder = 0;
            
            break;
        case ACCESS: 
            codeLen = 88;    
            crcOrder = 0;
            
            break;
        case PAGING:
            switch (rate){
            case RATE_96:
                codeLen = 192;
                crcOrder = 0;
                break;
            case RATE_48:
                codeLen = 96;
                crcOrder = 0; 
                break;
            }
            break; 
            case TRAFFIC:
                switch (rateSet){
                case RATESET1:
                    switch (rate){
                    case RATE_96:
                        generator = 0xF13;
                        crcOrder = 12;
                        codeLen = 184;       
                        break;
                    case RATE_48:
                        generator = 0x9B;
                        crcOrder = 8;
                        codeLen = 88;   
                        break;
                    case RATE_24:
                        codeLen = 40;
                        crcOrder = 0;   
                        break;
                    case RATE_12:
                        codeLen = 16;
                        crcOrder = 0;   
                        break;
                        
                    }
                    break;
                    case RATESET2:
                        switch (rate){
                        case RATE_144:
                            generator = 0xF13;
                            crcOrder = 12;
                            codeLen =  280;       
                            break;
                        case RATE_72:
                            generator = 0x3D9;
                            crcOrder = 10;
                            codeLen = 136;   
                            break;
                        case RATE_36:
                            generator = 0x9B;
                            crcOrder = 8;
                            codeLen = 64;   
                            break;
                        case RATE_18:
                            generator = 0x7;
                            crcOrder = 6;
                            codeLen = 28;   
                            break;
                            
                        }
                        break;
                }
                break;   
        }
        
        
        params.generator = (int) generator;
        params.crcorder = (int) crcOrder;
        params.framelen = (int) codeLen;
        
    }

    /* Call core function */
    if (params.crcSwtch) {
        outBlkSize  = SIM_MAX_CRC_FR_SIZE + 8;
        outFrameLen = params.framelen;
        flag = crcEngine(crcOut, ppCrcIn, &params);
    } else {
        outBlkSize  = SIM_MAX_SPEECH_FR_SIZE;
        outFrameLen = (params.framelen - params.crcorder); 
        crcError =  ssGetOutputPortRealSignal(S,1);
        flag = crcSyndrom(crcOut, crcError, ppCrcIn, &params);
    }
    
    /*check binary input*/
    if (flag != 0){
        msg = "Input must be a binary vector";
        goto ERROR_EXIT;
    }
    /* Add the tail for the convolutionnal encoder */
    for (index=outFrameLen; index<outBlkSize; index++)
        crcOut[index] = 0.0;
    
ERROR_EXIT:
#ifdef MATLAB_MEX_FILE
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
        return;
    }
#endif
}

#undef MDL_UPDATE /* Change to #undef to remove function*/

#undef MDL_DERIVATIVES /* Change to #undef to remove function*/

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
