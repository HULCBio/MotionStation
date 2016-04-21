/*
 *  Module Name: sis95rcdespread.c
 *
 *  Description:		
 *      Simulates a rake with complex (I & Q) data outputs. 
 *      This block down samples the input I and Q signal and correlates
 *      it with PN I and PN Q codes. It also effectively seperates signals 
 *      received from different mobiles or through different propagation paths.
 *
 *  Inputs:
 *      In I
 *          Real vector containing the In-phase component of the received 
 *          data sequence.
 *      In Q
 *          Real vector containing the Quadrature component of the received 
 *          data sequence.
 *      PN I
 *          Binary vector containing the In-Phase components of the PN code 
 *          sequence.
 *      PN Q
 *          Binary vector containing the Quadrature components of the PN code 
 *          sequence.
 *      PN Phase
 *          Positive integer scalar. It contains the PN phase offset in number 
 *          of ticks that will be applied to each finger. Each finger will be  
 *          slewed and de-skewed by the corresponding initial PN phase offset.
 *
 *  Outputs: 
 *      Out I
 *          Real vector representing the In-Phase component of the correlated 
 *          signal.
 *      Out Q
 *          Real vector representing the Quadrature component of the correlated 
 *          signal.
 *
 *  Parameters:
 *      Buffer Size 
 *          This parameter let you choose the length of the buffer needed in 
 *          the correlator.  The bigger this buffer is, the bigger the PN phase 
 *          offset can be.
 *      Walsh Size
 *          Scalar that specifies the number of input bits that determine the 
 *          index of the output walsh code function.
 *      Oversampling Rate
 *          It corresponds to the number of ticks per chip.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.13.2.1 $  $Date: 2004/04/12 22:59:51 $
 */
#define S_FUNCTION_NAME sis95rcdespread
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"
#include <math.h>

#define NUM_ARGS        4
#define NUM_SYMB_ARG    ssGetSFcnParam(S,0)
#define BUFF_SIZE_ARG   ssGetSFcnParam(S,1)
#define INTEG_LEN_ARG   ssGetSFcnParam(S,2)
#define OVR_SAMP_ARG    ssGetSFcnParam(S,3)

#define NUM_CHP_PER_SYM 64

/* For dimension propagation and frame support */
#define NUM_INPORTS_TO_SET  4  /* There are 5 input ports, but set frameness
                                  for only first 4. */
#define FIRST_INPORTIDX_TO_SET 0                                  
#define NUM_OUTPORTS_TO_SET 2
#define TOTAL_PORTS_TO_SET  6

#define BUFOFFSET       params->bufOffset
#define NUM_RK_SYM      params->numRkSym
#define RK_INT_SIZE     params->rkIntSize
#define RK_OVR_SMP      params->rkOvrSmp
#define CIRC_BUF_LEN    params->circBufLen
#define NUM_RK_TICK     params->numRkTick

typedef struct RLrakeCor{
    
    int bufOffset;
    int	numRkSym;
    int	rkIntSize;	
    int	circBufLen;
    int	numRkTick;
    int	rkOvrSmp;
    
} rlRake_par;

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    
    
    if ((mxGetM(BUFF_SIZE_ARG)*mxGetN(BUFF_SIZE_ARG) != 1) ||
        (mxGetPr(BUFF_SIZE_ARG)[0] <= (real_T) 0.0)  ||
        (floor(mxGetPr(BUFF_SIZE_ARG)[0]) != mxGetPr(BUFF_SIZE_ARG)[0])) {
        msg = "Tracking buffer size must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(INTEG_LEN_ARG)*mxGetN(INTEG_LEN_ARG) != 1) ||
        (mxGetPr(INTEG_LEN_ARG)[0] <= (real_T) 0.0)  ||
        (floor(mxGetPr(INTEG_LEN_ARG)[0]) != mxGetPr(INTEG_LEN_ARG)[0])) {
        msg = "Walsh size must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(OVR_SAMP_ARG)*mxGetN(OVR_SAMP_ARG) != 1) ||
        (mxGetPr(OVR_SAMP_ARG)[0] <= (real_T) 0.0)  ||
        (floor(mxGetPr(OVR_SAMP_ARG)[0]) != mxGetPr(OVR_SAMP_ARG)[0])) {
        msg = "Oversampling rate must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(NUM_SYMB_ARG)*mxGetN(NUM_SYMB_ARG) != 1) ||
        (mxGetPr(NUM_SYMB_ARG)[0] <= (real_T) 0.0)  ||
        (floor(mxGetPr(NUM_SYMB_ARG)[0]) != mxGetPr(NUM_SYMB_ARG)[0])) {
        msg = "Input frame size must be a positive integer";
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
    int i;
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
        
    /* Input Ports */    
    if (!ssSetNumInputPorts(S, 5)) return;
    for (i = 0; i < NUM_INPORTS_TO_SET; i++) {
        if (!ssSetInputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
        ssSetInputPortFrameData(         S, i, FRAME_INHERITED);
    	ssSetInputPortDirectFeedThrough( S, i, 1);
    }
	/* Set the 5th one to a 1D scalar */
    ssSetInputPortVectorDimension(  S, 4, 1);
    ssSetInputPortFrameData(        S, 4, FRAME_NO);
	ssSetInputPortDirectFeedThrough(S, 4, 1);

    /* Output Ports */    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS_TO_SET)) return;
    for (i = 0; i < NUM_OUTPORTS_TO_SET; i++){
        if (!ssSetOutputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
        ssSetOutputPortFrameData(         S, i, FRAME_INHERITED);          
    }
        
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 3);   /* number of pointer work vector elements*/
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in. The widths are stored in an int
 *          array with first the input widths and then the outputs.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
	int num_symb, integ_len, over_samp, i;

	num_symb     = (int) mxGetScalar(NUM_SYMB_ARG);
    integ_len    = (int) mxGetScalar(INTEG_LEN_ARG);
    over_samp    = (int) mxGetScalar(OVR_SAMP_ARG);
    
    /* Input port widths */
    widths[0] = num_symb * integ_len * over_samp;
    widths[1] = num_symb * integ_len * over_samp;
    widths[2] = num_symb * integ_len;
    widths[3] = num_symb * integ_len;
    /* Output port widths */
    for (i = NUM_INPORTS_TO_SET; i < TOTAL_PORTS_TO_SET; i++){
        widths[i] = integ_len;
    }
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, int_T portIdx,
                                        Frame_T frameData)
{
    int i;
	(void) portIdx; /* not used */

    /* Set all inputs to same frameness */
    for (i = 0; i < NUM_INPORTS_TO_SET; i++){
		if (ssGetInputPortFrameData(S, i) == FRAME_INHERITED) {
    		ssSetInputPortFrameData(S, i, frameData);
		} 
    }
    
    /* Set all outputs to same frameness */
    for (i = 0; i < NUM_OUTPORTS_TO_SET; i++){
		if (ssGetOutputPortFrameData(S, i) == FRAME_INHERITED) {
            ssSetOutputPortFrameData(S, i, frameData);
        }
    }
}
#endif

/* For dimension propagation and frame support */
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
    int buffLen, index;
    real_T *in_pntr, *rakeBuff;
    
    rlRake_par *params = (rlRake_par *) calloc(1, sizeof(rlRake_par));
    
#ifdef MATLAB_MEX_FILE
    if (params == NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
#endif
    
    NUM_RK_SYM   = (int) mxGetScalar(NUM_SYMB_ARG);
    RK_INT_SIZE  = (int) mxGetScalar(INTEG_LEN_ARG);
    RK_OVR_SMP   = (int) mxGetScalar(OVR_SAMP_ARG);
    NUM_RK_TICK  = NUM_RK_SYM * RK_INT_SIZE * RK_OVR_SMP;
    CIRC_BUF_LEN = (int) mxGetScalar(BUFF_SIZE_ARG) * RK_INT_SIZE * RK_OVR_SMP + NUM_RK_TICK; 
    buffLen      = (int) mxGetScalar(BUFF_SIZE_ARG) * RK_INT_SIZE * RK_OVR_SMP;
    BUFOFFSET    = 0;
    
    rakeBuff           = (real_T *) calloc(2 * CIRC_BUF_LEN, sizeof(real_T));
#ifdef MATLAB_MEX_FILE
    if (rakeBuff == NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
#endif
    
    for(index=0; index<buffLen; index++)
        rakeBuff[index] = 0.0;
    
    in_pntr  = rakeBuff + buffLen;
    
    ssSetPWorkValue(S, 0,  params);
    ssSetPWorkValue(S, 1,  rakeBuff);
    ssSetPWorkValue(S, 2,  in_pntr);
    
}

#endif	/* MDL_INITIALIZE_CONDITIONS */   

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int k;
    real_T *pSigI, *pSigQ;
    
    real_T  *pOutI = ssGetOutputPortRealSignal(S,0);
    real_T  *pOutQ = ssGetOutputPortRealSignal(S,1);
    
    InputRealPtrsType ppInSigI =  ssGetInputPortRealSignalPtrs( S, 0);
    InputRealPtrsType ppInSigQ =  ssGetInputPortRealSignalPtrs( S, 1);
    InputRealPtrsType ppInPnI  =  ssGetInputPortRealSignalPtrs( S, 2);
    InputRealPtrsType ppInPnQ  =  ssGetInputPortRealSignalPtrs( S, 3);
    int rkPhase                = (int) *(*(ssGetInputPortRealSignalPtrs( S, 4)));
    
    real_T *rkCircBuff = (real_T *) ssGetPWorkValue(S, 1);
    real_T *bufInPtr   = (real_T *) ssGetPWorkValue(S, 2);
    
    rlRake_par *params = ssGetPWorkValue(S, 0);
    
    for (k=0; k<NUM_RK_TICK; k++){
        *bufInPtr = **ppInSigI;
        *(bufInPtr++ + CIRC_BUF_LEN) = **ppInSigQ++;
        
        if (bufInPtr == (rkCircBuff + CIRC_BUF_LEN))
            bufInPtr = rkCircBuff;
    }
    
    ssSetPWorkValue(S, 2, bufInPtr);
    
    pSigI  = rkCircBuff;
    pSigQ  = pSigI + CIRC_BUF_LEN;
    
    if (rkPhase < 0){
        ssSetErrorStatus(S, "Rake finger phase offset must be positive");
        return;
    }
    
    {
        int k, m, index, smpOffset, smpOffset4;
        real_T pnI, pnQ;
        /* perform the correlator function */
        for (m=0; m<NUM_RK_SYM; m++) {
            for (k=0; k<RK_INT_SIZE; k++) {
                
                index = RK_INT_SIZE * m + k;
                pnI = *ppInPnI[index];
                pnQ = *ppInPnQ[index];
                
                index = BUFOFFSET + rkPhase + (RK_OVR_SMP * index);
                
                /* compute the signal correlation */
                smpOffset  = (index + CIRC_BUF_LEN) % CIRC_BUF_LEN;
                smpOffset4 = (index + CIRC_BUF_LEN + 4) % CIRC_BUF_LEN;
                pOutI[k] = pnI * pSigI[smpOffset] + pnQ * pSigQ[smpOffset4];
                pOutQ[k] = pnI * pSigQ[smpOffset4] - pnQ * pSigI[smpOffset];
                
            }
        }
    }
    
    BUFOFFSET += NUM_RK_TICK;
    BUFOFFSET %= CIRC_BUF_LEN;
}


static void mdlTerminate(SimStruct *S)
{
    rlRake_par *params = (rlRake_par *) ssGetPWorkValue(S, 0);
    real_T *rkCircBuff = (real_T *) ssGetPWorkValue(S, 1);
    
    free(params);
    free(rkCircBuff);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
