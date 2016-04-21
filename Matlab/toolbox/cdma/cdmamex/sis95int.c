/*
 *  Module Name: sis95int.c
 *  
 *  Description:
 *      Interleaves or de-interleaves the symbols of the incoming frame. 
 *      It spans 20ms equivalent to 384 modulation symbols at the full  
 *      symbol rate.  The input (array write) and output (array read) symbol 
 *      sequence for the four data rates are given in the specified tables 
 *      in the IS-95A specifications.
 * 
 *  Inputs:
 *      Frame In
 *          Integer vector containing the symbols of the frame to be 
 *          interleaved.			
 * 
 *  Outputs:
 *      Frame Out
 *          Binary vector representing the interleaved output frame.
 *					
 *  Parameters:
 *      Interleaving Option
 *          Integer scalar, that enables to run either interleaving (1) 
 *          or de-interleaving (0).
 *      Channel Type
 *          Logical Channel Type (SYNC/PAGING/TRAFFIC): 1 for SYNC,
 *          2 for PAGING and 3 for TRAFFIC.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.13.2.1 $  $Date: 2004/04/12 22:59:45 $
 */

#define S_FUNCTION_NAME sis95int
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"
#include <stdlib.h>
#include <math.h>

#define NUM_ARGS        3
#define CH_TYPE_ARG     ssGetSFcnParam(S,0)
#define INT_TBL_ARG     ssGetSFcnParam(S,1)
#define INT_SWITCH_ARG  ssGetSFcnParam(S,2)

#define SIM_MAX_INT_FR_SIZE    384

#define PINT_LV         params.pIntLvTb1
#define CH_TYPE         params.chType
#define SYMB_LEN        params.symbLen
#define INT_SWITCH      params.intSwitch

#define SYNC    0
#define PAGING  1
#define ACCESS  1
#define TRAFFIC 2

typedef struct intlv{
     int    *pIntLvTb1;
     int    chType;
     int    symbLen;
     int    intSwitch;   

} intlv_par;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;

    if ((mxGetM(CH_TYPE_ARG)*mxGetN(CH_TYPE_ARG) != 1) ||
        ((mxGetPr(CH_TYPE_ARG)[0] != (real_T) 1.0) &&
         (mxGetPr(CH_TYPE_ARG)[0] != (real_T) 2.0) &&
         (mxGetPr(CH_TYPE_ARG)[0] != (real_T) 3.0))) {
        msg = "Channel type must be 1, 2 or 3";
        goto ERROR_EXIT;
        }
         
    if ((mxGetM(INT_TBL_ARG)*mxGetN(INT_TBL_ARG) != 384) &&
        (mxGetPr(CH_TYPE_ARG)[0] != (real_T) 1.0)){
        msg = "Interleave table must have 384 elements unless it is a Sync Channel";
        goto ERROR_EXIT;
        }
         
    if (mxGetM(INT_SWITCH_ARG)*mxGetN(INT_SWITCH_ARG) != 1) {
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
        
    if (!ssSetNumInputPorts(S, 1)) return;
    if (!ssSetInputPortDimensionInfo(	S, 0, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         	S, 0, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough(	S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    if (!ssSetOutputPortDimensionInfo(	S, 0, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         	S, 0, FRAME_INHERITED);
    
    ssSetNumContStates(    S, 0);   /* number of continuous states       */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states         */ 
    ssSetNumSampleTimes(   S, 1);   /* number of sample times        */
    ssSetNumRWork(     S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(     S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(     S, 1);   /* number of pointer work vector elements*/
    ssSetOptions(      S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general 
                                                  options (SS_OPTION_xx) */
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
    int chType = (int) mxGetScalar(CH_TYPE_ARG) - 1;

    if (chType == SYNC) {
        widths[0] = SIM_MAX_INT_FR_SIZE / 3;
        widths[1] = SIM_MAX_INT_FR_SIZE / 3;
    } else {
        widths[0] = SIM_MAX_INT_FR_SIZE;
        widths[1] = SIM_MAX_INT_FR_SIZE;
    }
}

/* For dimension propagation and frame support */
#define NUM_INPORTS_TO_SET  1
#define FIRST_INPORTIDX_TO_SET 0  
#define NUM_OUTPORTS_TO_SET 1
#define TOTAL_PORTS_TO_SET  2  

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
    real_T  *pIntTbl = mxGetPr(INT_TBL_ARG);
    int chType      = (int) mxGetScalar(CH_TYPE_ARG) - 1;
    int numSymb     = ssGetInputPortWidth(S,0);
    int *intlvTbl, index, symbLen;

    /* First determine size of output and repetition rate */
    switch (chType){
        case SYNC:
           symbLen = SIM_MAX_INT_FR_SIZE / 3;
           break;
        default:
           symbLen = SIM_MAX_INT_FR_SIZE;
           break;
    }

    intlvTbl = (int *) calloc(384, sizeof(int));
    
#ifdef MATLAB_MEX_FILE
    if (numSymb < symbLen){
        ssSetErrorStatus(S, "Insufficient number of inputs and outputs");
        return;
    }         

    if (intlvTbl==NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
#endif

    ssSetPWorkValue(S, 0, intlvTbl);

    for (index=0; index<384; index++)
        intlvTbl[index] = (int) pIntTbl[index];
}
#endif	/* MDL_INITIALIZE_CONDITIONS */   

static void mdlOutputs(SimStruct *S, int_T tid)
{
     int i, j, temp, outIndex, intError=0;
     intlv_par params;
    
     /* Set the input / output pointers */
   
    InputRealPtrsType ppEncIn =  ssGetInputPortRealSignalPtrs( S, 0);
    real_T *intlvOut = ( real_T *) ssGetOutputPortRealSignal(S,0);

    params.pIntLvTb1  = (int *) ssGetPWorkValue(S, 0);
    params.chType     = (int) mxGetScalar(CH_TYPE_ARG) - 1;
    params.intSwitch = (int) mxGetScalar(INT_SWITCH_ARG);
   
    /* First determine size of output and repetition rate */
    switch (params.chType){
        case SYNC:
           params.symbLen = SIM_MAX_INT_FR_SIZE / 3;
           break;
        default:
           params.symbLen = SIM_MAX_INT_FR_SIZE;
           break;
    }

    /* Perform IS95 symbol repetition tasks */
    switch (CH_TYPE){
	
    case SYNC: 
	for (i=0; i<SYMB_LEN; i++){
	    temp = i;
	    outIndex = 0;
	    for (j=0; j<7; j++){
		outIndex = ((temp & 0x1) << (6-j)) | outIndex;
		temp >>= 1;
	    }
	    
	    *(intlvOut + i) = *(*ppEncIn + outIndex);
	    
	    /* Collect data to check at end of loop if error in input data */
	    if(INT_SWITCH){
		intError |= (int)(*(*ppEncIn + outIndex));
	    }
	}
	break;

    default:
	switch(INT_SWITCH){
	case 1:         /* Interleave Input Symbols */
	    for (i=0; i<SYMB_LEN; i++)  {
		*(intlvOut + i) = *(*ppEncIn + (int) PINT_LV[i]);

	    	/* Collect data to check at end of loop if error in input data */
	    	intError |= (int)(*ppEncIn[i]);
	    }
	    break;
	
	case 0:         /* De-interleave Input Symbols */
	    for (i=0; i<SYMB_LEN; i++)
		*(intlvOut + PINT_LV[i]) = *(*ppEncIn + i);
	    break;
	
	default:
            ssSetErrorStatus(S,"Unrecognized interleaver mode.");
            return;
	    break;

	}
    }
    
    /* If error in input data then inform user */
    if ((intError != 0) && (intError != 1)) {
        ssSetErrorStatus(S,"Input must be a binary vector");
        return;
    }
}


static void mdlTerminate(SimStruct *S)
{
    int *intlvTbl = (int *) ssGetPWorkValue(S, 0);

    free(intlvTbl);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
