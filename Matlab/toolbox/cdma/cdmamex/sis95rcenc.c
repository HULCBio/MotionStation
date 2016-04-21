/*
 *   Module Name: sis95rcenc.c
 *
 *  Description:
 *      Convolutionally encodes the CRC-added frame according to the IS-95A 
 *      specifications. The constraint length is 9. For Access Channel and rate 
 *      set 1 of Traffic Channel, the convolutional code rate is 1/3 and  
 *      generator functions for are 557 (octal) 663 (octal) and 711 (octal). 
 *      For rate set 2 of Traffic Channel the convolutional code rate is 1/2   
 *      and generator functions are 753 (octal) and 561 (octal).
 *
 *  Inputs:
 *      Rate
 *          Integer scalar indicating the data rate; 0 for full, 1 for half,  
 *          2 for quarter, and 4 for 1/8th data rates.
 *      Frame In
 *          Input Frame: binary vector representing a frame.
 * 
 *  Outputs:
 *      Frame Out
 *          Convolutionally encoded output: binary vector representing a frame.
 *		
 *  Parameters:
 *      Channel Type 
 *          Logical Channel Type (ACCESS/TRAFFIC): 1 for ACCESS and 2 for 
 *          TRAFFIC.
 *      Rate Set 
 *          Rate Set number (Rate Set 1 or Rate Set 2).
 *      Initial Encoder State 
 *          Integer scalar, that provides the initial state of the convolutional 
 *          encoder.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.13.2.1 $  $Date: 2004/04/12 22:59:52 $
 */
#define S_FUNCTION_NAME sis95rcenc
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"

#define NUM_ARGS    3
#define CH_TYPE_ARG     ssGetSFcnParam(S,0)
#define RATE_SET_ARG    ssGetSFcnParam(S,1)
#define ENC_STATE_ARG   ssGetSFcnParam(S,2)

#define SIM_MAX_RL_ENC_FR_SIZE    576
#define SIM_MAX_RL_TAIL_FR_SIZE   288
#define TOTAL_PORTS               3

#define IN_ARRAY_LEN    params.inArrayLen
#define N_ST            params.nSt
#define INT_ENC_STATE   params.intEncState

enum {ACCESS=1, TRAFFIC};
enum {RATESET1=0, RATESET2};

enum {RATE_96=0, RATE_48, RATE_24, RATE_12};
enum {RATE_144=0, RATE_72, RATE_36, RATE_18};

typedef struct rlEnc{
    
    int inArrayLen;
    int nSt;
    long *intEncState;
    
} rlenc_par;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    int chType, rateSet;
    
    
    if ((mxGetM(CH_TYPE_ARG)*mxGetN(CH_TYPE_ARG) != 1) ||
        ((mxGetPr(CH_TYPE_ARG)[0] != (real_T) 1.0) &&
        (mxGetPr(CH_TYPE_ARG)[0] != (real_T) 2.0))) {
        msg = "Channel type must be 1 or 2";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(RATE_SET_ARG)*mxGetN(RATE_SET_ARG) != 1) ||
        ((mxGetPr(RATE_SET_ARG)[0] != (real_T) 1.0) &&
        (mxGetPr(RATE_SET_ARG)[0] != (real_T) 2.0))) {
        msg = "Rate set must be 1 or 2";
        goto ERROR_EXIT;
    }
    chType  = (int) mxGetScalar(CH_TYPE_ARG);
    rateSet = (int) mxGetScalar(RATE_SET_ARG) - 1;
    
    if ((chType != TRAFFIC) && (rateSet != RATESET1)){
        msg = 	"Rate set for Access channel must be Rate Set I";
        goto ERROR_EXIT;
    }
    
    
    if ((mxGetM(ENC_STATE_ARG)*mxGetN(ENC_STATE_ARG) != 0) &&
        ((mxGetM(ENC_STATE_ARG)*mxGetN(ENC_STATE_ARG) != 3) ||
        (mxGetPr(ENC_STATE_ARG)[0] < 0.0) || (mxGetPr(ENC_STATE_ARG)[1] < 0.0) ||
        (mxGetPr(ENC_STATE_ARG)[2] < 0.0) ||
        (((int) mxGetPr(ENC_STATE_ARG)[0]) - mxGetPr(ENC_STATE_ARG)[0]) ||
        (((int) mxGetPr(ENC_STATE_ARG)[1]) - mxGetPr(ENC_STATE_ARG)[1]) ||
        (((int) mxGetPr(ENC_STATE_ARG)[2]) - mxGetPr(ENC_STATE_ARG)[2]))) {
        msg = "Initial encoder state must be a 3-element positive integer vector or empty";
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
    ssSetOptions(          S, SS_OPTION_EXCEPTION_FREE_CODE);
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
    widths[1] = SIM_MAX_RL_TAIL_FR_SIZE;

    /* Outputs */
    widths[2] = SIM_MAX_RL_ENC_FR_SIZE;
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
    long  *encState = (long *) calloc(3, sizeof(long));
    int   chType    = (int) mxGetScalar(CH_TYPE_ARG);
    real_T *pEncStPar = mxGetPr(ENC_STATE_ARG);
    
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
        encState[2] = 0;
    } else{
        encState[0] = (long) pEncStPar[0];
        encState[1] = (long) pEncStPar[1];
        encState[2] = (long) pEncStPar[2];
    }
}
#endif	/* MDL_INITIALIZE_CONDITIONS */  


static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* Set the input/output pointers */
    int i, rlencError; 
    int rate = (int) *( *(ssGetInputPortRealSignalPtrs( S, 0)));
    
    InputRealPtrsType ppEncIn =  ssGetInputPortRealSignalPtrs( S, 1);
    
    real_T	*encOut =  ssGetOutputPortRealSignal(S,0);
    int index;
    int chType  = (int) mxGetScalar(CH_TYPE_ARG);
    int rateSet = (int) mxGetScalar(RATE_SET_ARG) - 1;
    
    rlenc_par params;
    params.intEncState = (long *) ssGetPWorkValue(S, 0);
    
    
    /* First determining size of output and repetion rate */
    switch(chType){
    case ACCESS:
        if (rate == RATE_48){
            params.inArrayLen = 96;
            params.nSt = 3;
        }else{
#ifdef MATLAB_MEX_FILE
            ssSetErrorStatus(S,"Data rate for Access channel must be half rate");
            return;
#endif
        }
        break; 
    case TRAFFIC:
        switch (rateSet){
        case RATESET1:
            params.nSt = 3;
            switch (rate){
            case RATE_96:
                params.inArrayLen = 192;       
                break;
            case RATE_48:
                params.inArrayLen = 96;   
                break;
            case RATE_24:
                params.inArrayLen = 48;   
                break;
            case RATE_12:
                params.inArrayLen = 24;   
                break;
                break;
            default:
#ifdef MATLAB_MEX_FILE
                ssSetErrorStatus(S,"Data rate for Traffic channel is incorrect");
                return;
#endif
            }
            break;
            case RATESET2:
                params.nSt = 2;
                switch (rate){
                case RATE_144:
                    params.inArrayLen = 288;       
                    break;
                case RATE_72:
                    params.inArrayLen = 144;   
                    break;
                case RATE_36:
                    params.inArrayLen = 72;   
                    break;
                case RATE_18:
                    params.inArrayLen = 36;   
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
    {
        int gen11=0x1ED, gen12=0x19B, gen13=0x127, gen21=0x1AF, gen22=0x11D;
        int i, temp, gen1, gen2, encError=0;
        
        INT_ENC_STATE[0] &= 0xff;
        INT_ENC_STATE[1] &= 0xff;
        if (N_ST==3){
            INT_ENC_STATE[2] &= 0xff;
            gen1 = gen11;
            gen2 = gen12;
        } else{
            gen1 = gen21;
            gen2 = gen22;
        }
        
        for (i=0; i<IN_ARRAY_LEN; i++){
            /* Collect data to check at end of loop if error in input data */
            encError |= (int)(*ppEncIn[i]);
            
            /* Get next SR pEncSt & Output*/
            temp = (int) *ppEncIn[i];
            INT_ENC_STATE[0] ^= temp * gen1;
            encOut[N_ST*i] = (real_T) (INT_ENC_STATE[0] & 0x1);
            INT_ENC_STATE[0] >>= 1;
            
            /* Get next SR pEncSt & Output*/
            INT_ENC_STATE[1] ^= temp * gen2;
            encOut[N_ST*i + 1] = (real_T) (INT_ENC_STATE[1] & 0x1);
            INT_ENC_STATE[1] >>= 1;
            
            if (N_ST==3){
                /* Get next SR pEncSt & Output*/
                INT_ENC_STATE[2] ^= temp * gen13;
                encOut[N_ST*i + 2] = (real_T) (INT_ENC_STATE[2] & 0x1);
                INT_ENC_STATE[2] >>= 1;
            }
        }
        /* If error in input data then inform user */
        if ((encError != 0) && (encError != 1)) {
            ssSetErrorStatus(S, "Input must be a binary vector");
            return;
        }
    }
    
   
    for (index=params.nSt*params.inArrayLen; index<SIM_MAX_RL_ENC_FR_SIZE; index++)
        encOut[index] = 0.0;
    
    params.intEncState[0] = 0;
    params.intEncState[1] = 0;
    params.intEncState[2] = 0;
    
}




static void mdlTerminate(SimStruct *S)
{
    long  *encState = (long *) ssGetPWorkValue(S, 0);
    free(encState);
}


/*=============================*
* Required S-function trailer *
*=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
