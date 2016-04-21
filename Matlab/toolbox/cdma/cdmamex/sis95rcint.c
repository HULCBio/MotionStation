/*
 *  Module Name: sis95rcint.c
 *
 *  Description:
 *      Interleaves or de-interleaves the symbols of the repeated frame for 
 *      the Reverse channel. A block interleaver spanning 20ms is used. 
 *      The interleaver is an array with32 rows and 18 columns. Code symbols are 
 *      written into the interleaver by column filling the complete 32x18 matrix 
 *      according to the specified tables in IS-95A specifications. Reverse 
 *      Traffic Channel code symbols are output from the interleaver by rows.
 * 
 *  Inputs:
 *      Rate	
 *          Scalar integer indicating the data rate for the frame to be processed 
 *          (0, 1, 2, 3 for respectively Full, Half, 1/4th, 1/8th rates).
 *      Frame In
 *          Binary vector representing the input frame.
 * 
 *  Outputs:
 *      Frame Out
 *          Binary vector representing the interleaved output frame.
 *		
 *  Parameters:
 *      Interleaving option
 *          This parameter enables to run interleaving (1) or de-interleaving (0).
 *      Interleaving Table
 *          Real vector that shows the order of writting operations of bits into 
 *          the interleaver array
 *      Channel Type 
 *          Logical Channel Type (ACCESS/TRAFFIC): 1 for ACCESS and 2 for TRAFFIC.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.14.2.1 $  $Date: 2004/04/12 22:59:53 $
 */
#define S_FUNCTION_NAME sis95rcint
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"

#define NUM_ARGS        3
#define CH_TYPE_ARG     ssGetSFcnParam(S,0)
#define INT_TBL_ARG     ssGetSFcnParam(S,1)
#define INT_SWTCH_ARG   ssGetSFcnParam(S,2)

#define SIM_MAX_RL_INT_FR_SIZE  576
#define NUM_PWR_GRP_CHIPS       384
#define NUM_PWR_GRP_SYMBS       36
#define NUM_PWR_GRPS            16
#define TOTAL_PORTS             3

enum {ACCESS=1, TRAFFIC};
enum {RATE_96=0, RATE_48, RATE_24, RATE_12};

#define	PINTLVTBL       param.pIntLvTbl
#define	SYMBLEN         param.symbLen
#define	INTSWITCH       param.intSwtch

typedef struct rlInt{
    
    int   *pIntLvTbl; 
    int   symbLen;
    int   intSwtch;
    
} rl_Int;


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
    
    if (((mxGetM(INT_TBL_ARG)*mxGetN(INT_TBL_ARG) != 32) &&
        (mxGetPr(CH_TYPE_ARG)[0] == (real_T) ACCESS)) ||
        ((mxGetM(INT_TBL_ARG)*mxGetN(INT_TBL_ARG) != 0) &&
        (((int) mxGetPr(INT_TBL_ARG)[0]) - mxGetPr(INT_TBL_ARG)[0]) &&
        (mxGetPr(CH_TYPE_ARG)[0] == (real_T) TRAFFIC))){
        msg = "For the ACCESS Channel, Interleave Table must be 32 elements long. For the TRAFFIC Channel, it must be integer or empty";
        goto ERROR_EXIT;
    }
    
    if (mxGetM(INT_SWTCH_ARG)*mxGetN(INT_SWTCH_ARG) != 1) {
        msg = "Interleaver switch must be a scalar";
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
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
    ssSetOptions(      S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx) */
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
    widths[1] = SIM_MAX_RL_INT_FR_SIZE;
    /* Outputs */
    widths[2] = SIM_MAX_RL_INT_FR_SIZE;
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
    int  *intLvTbl = (int *) calloc(32*4, sizeof(int));
    int  chType    = (int) mxGetScalar(CH_TYPE_ARG);
    int  index, j, k, l, numRep=1;
    
#ifdef MATLAB_MEX_FILE
    if (intLvTbl==NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
#endif
    
    ssSetPWorkValue(S, 0, intLvTbl);
    
    if (chType == ACCESS){
        real_T *pIntLv = mxGetPr(INT_TBL_ARG);
        
        for (index=0; index<32; index++)
            intLvTbl[index] = (int) pIntLv[index];
        
    } else if (chType == TRAFFIC){
        while (numRep < 16){
            for (j=0; j<(16 / numRep); j++)
                for (k=0; k<numRep; k++)
                    for (l=0; l<2; l++)
                        *intLvTbl++ = (numRep * l) + k + (2 * numRep * j);
                    numRep *= 2;
        }
        
    }
}
#endif	/* MDL_INITIALIZE_CONDITIONS */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    rl_Int param;
    int j, chType, repSwtch, rlError;
    const char *msg = NULL;
    
    int rate                    = (int) *( *(ssGetInputPortRealSignalPtrs( S, 0)));
    InputRealPtrsType ppSigIn   =  ssGetInputPortRealSignalPtrs( S, 1);
    real_T *sigOut              =  ssGetOutputPortRealSignal(S,0);
    
    param.pIntLvTbl = (int *) ssGetPWorkValue(S, 0);
    param.intSwtch  = (int) mxGetScalar(INT_SWTCH_ARG);
    chType          = (int) mxGetScalar(CH_TYPE_ARG);
    param.symbLen   = SIM_MAX_RL_INT_FR_SIZE;
    
#ifdef MATLAB_MEX_FILE
    switch(chType){
    case ACCESS:
        if (rate!=RATE_48)
            msg = "Data rate for Access channel must be half rate";
        
        break;
    case TRAFFIC:
        if ((rate!=RATE_96) && (rate!=RATE_48) && (rate!=RATE_24) && (rate!=RATE_12))
            msg = "Data rate for Traffic channel is incorrect";
        
        break;
    }
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
        return;
    }
#endif
    
    if (chType == TRAFFIC )
        param.pIntLvTbl += (rate * 32);
    
    /* Perfrom IS95 interleaving tasks */
    {
        real_T *pVec;
        int i, j, intError=0;
        
        switch(INTSWITCH){
            
        case 1:              /* Interleave Input Symbols */
            pVec =  sigOut;
            for (i=0; i<SYMBLEN/18; i++){
                /* Collect data to check at end of loop if error in input data */
                intError |= (int)(*ppSigIn[i]);
                
                for (j=0; j<18; j++)
                    *pVec++ = *ppSigIn[j*SYMBLEN/18 + PINTLVTBL[i]];
            }
            break;
            
        case 0:              /* De-interleave Input Symbols */
            pVec =  (real_T *) *ppSigIn;
            for (i=0; i<SYMBLEN/18; i++){
                for (j=0; j<18; j++)
                    sigOut[j*SYMBLEN/18 + PINTLVTBL[i]] = *pVec++;
            }
            break;
            
        default:
            pVec = sigOut;
            for (i=0; i<SYMBLEN/18; i++){
                for (j=0; j<18; j++)
                    *pVec++ = *ppSigIn[j*SYMBLEN/18 + PINTLVTBL[i]];
            }
            break;           
        }
        /* If error in input data then inform user */
        if ((intError != 0) && (intError != 1))
        {
            ssSetErrorStatus(S,"Input must be a binary vector");
            return;
        }

    }


   
}

static void mdlTerminate(SimStruct *S)
{
    int  *pIntLv = (int *) ssGetPWorkValue(S, 0);
    
    free(pIntLv);
}


/*=============================*
* Required S-function trailer *
*=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
