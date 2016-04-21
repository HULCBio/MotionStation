/*
 *  Module Name: sis95rakefinger.c
 *
 *  Description:
 *      Simulates a coherent rake correlator with complex (I & Q) pilot and  
 *      data outputs. It correlates the input signal over each Walsh code  
 *      interval with appropriate PN and Walsh code sequences. The pilot and  
 *      the specified user data sequences will be de-spread and extracted as  
 *      a result. It also effectively separates signals received from different 
 *      base stations or through different propagation paths. Initial PN 
 *      Phases are used for appropriate down-sampling of the incoming signal.
 * 
 *  Inputs:
 *      Input
 *          Complex vector representing the received filtered signal, at tick  
 *          level.  The first part of the vector corresponds to the In-phase  
 *          component, and the last part corresponds to the Quadrature
 *          component.
 *      PN
 *          Complex vector representing first the In-Phase components and  
 *          then the Quadrature components of the short PN code sequence.
 *      Walsh
 *          Binary vector representing the Walsh sequence.
 *      PN Phase
 *          Integer scalar representing the rake finger PN phase correction  
 *          in ticks. The rake finger will be slewed by the current value of 
 *          the PN phase.
 * 
 *	Outputs:
 * 	Pilot
 * 	    Complex vector, (I + Q) corresponding to the correlated Pilot 
 *          Symbol at symbol rate.
 *	Signal
 *	    Complex vector, (I + Q) corresponding to the correlated Data 
 *          Symbol at symbol rate.
 *	
 *  Parameters:
 *      Input Frame Size (in No. of Symbols)
 *          It is the number of symbols at the input of the rake correlator.
 *      Integration Length (in chips)
 *          It is the number of chips that will be integrated every sampling 
 *          time.
 *      Correlator Buffer Size (in No. of Symbols)
 *          This parameter let you choose the length of the buffer needed in 
 *          the correlator.  The bigger this buffer is, the bigger the PN phase
 *          offset can be.
 *      Input Over-Sampling Rate
 *          It corresponds to the number of ticks per chip.
 *          This corresponds the time between successive inputs to the block.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.16.2.1 $  $Date: 2004/04/12 22:59:49 $
 */
#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sis95rakefinger

#include "cdma_frm.h"
#include <math.h>

#define NUM_ARGS    4
#define NUM_SYMB_ARG    ssGetSFcnParam(S,0)
#define BUFF_SIZE_ARG   ssGetSFcnParam(S,1)
#define INTEG_LEN_ARG   ssGetSFcnParam(S,2)
#define OVR_SAMP_ARG    ssGetSFcnParam(S,3)

#define DELTA_EL            2 
#define DELTA_SIG           0 
#define NUM_CHP_PER_SYM     64

/* For dimension propagation and frame support */
#define NUM_INPORTS_TO_SET  5  /* There are 6 input ports, but set frameness
                                  for only first 5. */
#define FIRST_INPORTIDX_TO_SET 0  /* Start from first port index */
#define NUM_OUTPORTS_TO_SET 4
#define TOTAL_PORTS_TO_SET  9

#define SIG_I           params->pSigI
#define SIG_Q           params->pSigQ
#define BUFOFFSET       params->bufOffset
#define NUM_RK_SYM      params->numRkSym
#define RK_INT_SIZE     params->rkIntSize
#define RK_OVR_SMP      params->rkOvrSmp
#define RK_EL_DLTA      params->rkElDlta
#define RK_DT_DLTA      params->rkDtDlta
#define NUM_RK_TICK     params->numRkTick
#define CIRC_BUF_LEN    params->circBufLen

typedef struct rakeCor{
    
    real_T *pSigI;
    real_T *pSigQ;
    int bufOffset;
    int	numRkSym;
    int	rkIntSize;	
    int	circBufLen;
    int	numRkTick;	
    int	rkDtDlta;	
    int	rkElDlta;
    int	rkOvrSmp;
    
} rake_par;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    
    if ((mxGetM(NUM_SYMB_ARG)*mxGetN(NUM_SYMB_ARG) != 1) ||
        (mxGetPr(NUM_SYMB_ARG)[0] <= (real_T) 0.0)  ||
        (floor(mxGetPr(NUM_SYMB_ARG)[0]) != mxGetPr(NUM_SYMB_ARG)[0])) {
        msg = "Input frame size must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(BUFF_SIZE_ARG)*mxGetN(BUFF_SIZE_ARG) != 1) ||
        (mxGetPr(BUFF_SIZE_ARG)[0] <= (real_T) 0.0)  ||
        (floor(mxGetPr(BUFF_SIZE_ARG)[0]) != mxGetPr(BUFF_SIZE_ARG)[0])) {
        msg = "Tracking buffer size must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(INTEG_LEN_ARG)*mxGetN(INTEG_LEN_ARG) != 1) ||
        (mxGetPr(INTEG_LEN_ARG)[0] <= (real_T) 0.0)  ||
        (floor(mxGetPr(INTEG_LEN_ARG)[0]) != mxGetPr(INTEG_LEN_ARG)[0])) {
        msg = "Walsh order must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(OVR_SAMP_ARG)*mxGetN(OVR_SAMP_ARG) != 1) ||
        (mxGetPr(OVR_SAMP_ARG)[0] <= (real_T) 0.0)  ||
        (floor(mxGetPr(OVR_SAMP_ARG)[0]) != mxGetPr(OVR_SAMP_ARG)[0])) {
        msg = "Oversampling rate must be a positive integer";
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
        
    for (i = 0; i< NUM_ARGS; i++)
        ssSetSFcnParamNotTunable( S, i);
        
    /* Input Ports */
    if (!ssSetNumInputPorts(S, 6)) return;
    for (i = 0; i < NUM_INPORTS_TO_SET; i++) {
        if (!ssSetInputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
        ssSetInputPortFrameData(         S, i, FRAME_INHERITED);
    	ssSetInputPortDirectFeedThrough( S, i, 1);
    }
	/* Set the 6th one to a 1D scalar */
    ssSetInputPortVectorDimension(  S, 5, 1);
    ssSetInputPortFrameData(        S, 5, FRAME_NO);
	ssSetInputPortDirectFeedThrough(S, 5, 1);

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
    widths[4] = NUM_CHP_PER_SYM;
    /* Output port widths */
    for (i = NUM_INPORTS_TO_SET; i < TOTAL_PORTS_TO_SET; i++){
        widths[i] = num_symb;
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
    real_T *in_pntr;
    
    rake_par *params = (rake_par *) calloc(1, sizeof(rake_par));
    
#ifdef MATLAB_MEX_FILE
    if (params == NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
#endif
    
    NUM_RK_SYM   = (int) mxGetScalar(NUM_SYMB_ARG);
    RK_INT_SIZE  = (int) mxGetScalar(INTEG_LEN_ARG);
    RK_OVR_SMP   = (int) mxGetScalar(OVR_SAMP_ARG);
    RK_EL_DLTA   = DELTA_EL;
    RK_DT_DLTA   = DELTA_SIG;
    NUM_RK_TICK  = NUM_RK_SYM * RK_INT_SIZE * RK_OVR_SMP;
    CIRC_BUF_LEN = (int) mxGetScalar(BUFF_SIZE_ARG) * RK_INT_SIZE * RK_OVR_SMP + NUM_RK_TICK; 
    buffLen      = (int) mxGetScalar(BUFF_SIZE_ARG) * RK_INT_SIZE * RK_OVR_SMP;
    BUFOFFSET    = 0;
    
    SIG_I        = (real_T *) calloc(2 * CIRC_BUF_LEN, sizeof(real_T));
    
#ifdef MATLAB_MEX_FILE
    if (SIG_I == NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
#endif
    
    for(index=0; index<buffLen; index++)
        SIG_I[index] = 0.0;
    
    in_pntr  = SIG_I + buffLen;
    
    ssSetPWorkValue(S, 0,  params);
    ssSetPWorkValue(S, 1,  SIG_I);
    ssSetPWorkValue(S, 2,  in_pntr);
    
}

#endif	/* MDL_INITIALIZE_CONDITIONS */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int index;

    real_T  *pOutPilI = ssGetOutputPortRealSignal(S,0);
    real_T  *pOutPilQ = ssGetOutputPortRealSignal(S,1);
    real_T  *pOutSigI = ssGetOutputPortRealSignal(S,2);
    real_T  *pOutSigQ = ssGetOutputPortRealSignal(S,3);
    
    InputRealPtrsType ppInSigI = ssGetInputPortRealSignalPtrs( S, 0);
    InputRealPtrsType ppInSigQ = ssGetInputPortRealSignalPtrs( S, 1);
    InputRealPtrsType ppInPnI  = ssGetInputPortRealSignalPtrs( S, 2);
    InputRealPtrsType ppInPnQ  = ssGetInputPortRealSignalPtrs( S, 3);
    InputRealPtrsType ppInWlsh = ssGetInputPortRealSignalPtrs( S, 4);
    int ppInPh                 = (int) *(*(ssGetInputPortRealSignalPtrs( S, 5)));
    
    rake_par *params = (rake_par *) ssGetPWorkValue(S,0);
    
    
    real_T *rkCircBuff = ssGetPWorkValue(S, 1);
    real_T *bufInPtr   = ssGetPWorkValue(S, 2);
    
    for (index=0; index<NUM_RK_TICK; index++){
        *bufInPtr = **ppInSigI++;
        
        *(bufInPtr++ + CIRC_BUF_LEN ) = **ppInSigQ++;
        
        if (bufInPtr == (rkCircBuff + CIRC_BUF_LEN))
            bufInPtr = rkCircBuff;
    }
    
    ssSetPWorkValue(S, 2, bufInPtr);
    
    SIG_I  = rkCircBuff;
    SIG_Q  = SIG_I + CIRC_BUF_LEN;
    
    if (ppInPh < 0){
        ssSetErrorStatus(S, "Rake finger phase offset must be positive");
        return;
    }
    
    {
        real_T YpI, YpQ, YdI, YdQ;
        real_T wn, pnI, pnQ;
        int    index, k, m, sampOffset;
        
        /* perform the correlator function */
        for (m=0; m<NUM_RK_SYM; m++) {
            YpI = 0.0;  /* Pilot I */
            YpQ = 0.0;  /* Pilot Q */
            YdI = 0.0;  /* Data I  */
            YdQ = 0.0;  /* Data Q  */
            
            for (k=0; k<RK_INT_SIZE; k++) {
                index = RK_INT_SIZE * m + k;
                pnI = *ppInPnI[index];
                pnQ = *ppInPnQ[index];
                wn  = *ppInWlsh[k % NUM_CHP_PER_SYM];
                index = BUFOFFSET + ppInPh + (RK_OVR_SMP * index);
                
                /* compute the pilot correlation */
                sampOffset = index % CIRC_BUF_LEN;
                YpI += pnI * SIG_I[sampOffset];
                YpI += pnQ * SIG_Q[sampOffset];
                YpQ -= pnQ * SIG_I[sampOffset];
                YpQ += pnI * SIG_Q[sampOffset];
                
                /* compute the signal correlation */
                sampOffset = (index + RK_DT_DLTA + CIRC_BUF_LEN) % CIRC_BUF_LEN;
                YdI += wn * pnI * SIG_I[sampOffset];
                YdI += wn * pnQ * SIG_Q[sampOffset];
                YdQ -= wn * pnQ * SIG_I[sampOffset];
                YdQ += wn * pnI * SIG_Q[sampOffset];
                
            }
            
            pOutPilI[m]  = (0.5/RK_INT_SIZE)*YpI;
            pOutPilQ[m]  = (0.5/RK_INT_SIZE)*YpQ;
            pOutSigI[m] = (0.5/RK_INT_SIZE)*YdI;
            pOutSigQ[m] = (0.5/RK_INT_SIZE)*YdQ;
        }
        
    }
    
    BUFOFFSET += NUM_RK_TICK;
    BUFOFFSET %= CIRC_BUF_LEN;
    
}


static void mdlTerminate(SimStruct *S)
{
    rake_par  *params = (rake_par *) ssGetPWorkValue(S, 0);
    
    free(SIG_I);
    free(params);
    
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
