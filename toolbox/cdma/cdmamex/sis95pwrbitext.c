/*
 *  Module Name: sis95pwrbitext.c
 *
 *  Description:
 *      Extracts power bits from the received scrambled data for a rake finger.
 *      The position of power control bit is determined by Long Code according 
 *      to the IS-95A specifications. This block uses Long Code to find the 
 *      position of power bit. After extracting the power bit its position will 
 *      be filled with zeros. 
 *
 *  Inputs:
 *      Signal In
 *          Real vector, this is the demodulated data for the finger that is 
 *          obtained from the rake demodulator.
 *      Long Code
 *          Binary vector, this is the decimated long-code that is used for the 
 *          determination of the power bit positions as well as the descrambling  
 *          of the signal data.
 * 
 *  Outputs:
 *      Signal Out
 *          Real vector, this contains the demodulated data after zeroing out of  
 *          the symbols corresponding to the power bits.
 *      Power Bits
 *          Real vector, this contains the power bits and the non-power bit data  
 *          is zeroed. 
 * 		
 *  Parameters:
 *      Rate Set
 *          This parameter selects the rate set (1 or 2) for which the power bit 
 *          extraction and descrambling is performed.
 *      Input Frame Size
 *          This parameter provides the number of symbols at the input.
 *      Initial Power Bit Location
 *          This provides the Initial location of the power bits, since the  
 *          current decimated long code is used to determine the power bit location  
 *          in the next power group.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.11.2.1 $  $Date: 2004/04/12 22:59:47 $
 */
 
#define S_FUNCTION_NAME sis95pwrbitext
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"

#define NUM_ARGS            3
#define RATE_SET_ARG        ssGetSFcnParam(S,0)
#define NUM_SYMBOLS_ARG     ssGetSFcnParam(S,1)
#define INIT_LOC_ARG        ssGetSFcnParam(S,2)

/* For dimension propagation and frame support */
#define NUM_INPORTS  2  
#define NUM_OUTPORTS 2
#define TOTAL_PORTS  4

#define NUM_PWR_GP_SYM      24
#define NUM_PWR_SYM         16
#define NUM_LOC_BITS        20
#define LEAST_FRAC          (1.0 / (real_T) (1 << 15))

#define pPwrSum             states.pwrSum
#define	pPwrSymbLoc         states.pwrSymbLoc
#define	pSymbCounter        states.symbCounter

#define	RATESET             params.rateSet
#define	NUMSYMB             params.numSymbols

typedef struct pwrBit_p {
        int rateSet;
        int numSymbols;

} pwrBit_par;

typedef struct pwrBit_s {
     	real_T pwrSum;
        int    pwrSymbLoc;
        int    symbCounter;
        
} pwrBit_state;

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    
    if ((mxGetM(RATE_SET_ARG)*mxGetN(RATE_SET_ARG) != 1) ||
        ((mxGetPr(RATE_SET_ARG)[0] != (real_T) 1.0) &&
        (mxGetPr(RATE_SET_ARG)[0] != (real_T) 2.0))) {
        msg = "Rate set must be 1 or 2";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(NUM_SYMBOLS_ARG)*mxGetN(NUM_SYMBOLS_ARG) != 1) ||
        (mxGetPr(NUM_SYMBOLS_ARG)[0] <= 0.0) ||
        (((int) mxGetPr(NUM_SYMBOLS_ARG)[0]) - mxGetPr(NUM_SYMBOLS_ARG)[0])) {
        msg = "Input frame size must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(INIT_LOC_ARG)*mxGetN(INIT_LOC_ARG) != 0) &&
        ((mxGetM(INIT_LOC_ARG)*mxGetN(INIT_LOC_ARG) != 1) ||
        (mxGetPr(INIT_LOC_ARG)[0] < 0.0) ||
        (mxGetPr(INIT_LOC_ARG)[0] > 15.0) ||
        (((int) mxGetPr(INIT_LOC_ARG)[0]) - mxGetPr(INIT_LOC_ARG)[0]))) {
        msg = "Initial power bit location must be a positive integer less than 16 or empty";
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
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    for (i = 0; i < NUM_INPORTS; i++) {
        if (!ssSetInputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
        ssSetInputPortFrameData(         S, i, FRAME_INHERITED);
    	ssSetInputPortDirectFeedThrough( S, i, 1);
    }

    /* Output Ports */
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    for (i = 0; i < NUM_OUTPORTS; i++){
        if (!ssSetOutputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
        ssSetOutputPortFrameData(         S, i, FRAME_INHERITED);          
    }
    
    ssSetNumContStates(    S, 0);   /* number of continuous states                   */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states                     */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                        */
    ssSetNumRWork(         S, 1);   /* number of real work vector elements           */
    ssSetNumIWork(         S, 2);   /* number of integer work vector elements        */
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements        */
    ssSetNumModes(         S, 0);   /* number of mode work vector elements           */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings           */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)        */
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in. The widths are stored in an int
 *          array with first the input widths and then the outputs.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
    int numSymbols, i;
    numSymbols = (int) mxGetScalar(NUM_SYMBOLS_ARG);

    /* Port widths */
    for (i = 0; i < TOTAL_PORTS; i++){
        widths[i] = numSymbols;
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
    for (i = 0; i < NUM_INPORTS; i++){
		if (ssGetInputPortFrameData(S, i) == FRAME_INHERITED) {
    		ssSetInputPortFrameData(S, i, frameData);
		} 
    }
    
    /* Set all outputs to same frameness */
    for (i = 0; i < NUM_OUTPORTS; i++){
		if (ssGetOutputPortFrameData(S, i) == FRAME_INHERITED) {
            ssSetOutputPortFrameData(S, i, frameData);
        }
    }
}
#endif

/* For dimension propagation and frame support */
#define NUM_INPORTS_TO_SET  2
#define FIRST_INPORTIDX_TO_SET 0  
#define NUM_OUTPORTS_TO_SET 2
#define TOTAL_PORTS_TO_SET  4  

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
    
    ssSetIWorkValue(S, 0, (int) mxGetScalar(INIT_LOC_ARG));
    ssSetIWorkValue(S, 1, 0);
    ssSetRWorkValue(S, 0, 0.0);
}
#endif

static void mdlOutputs(SimStruct *S, int_T tid)
{
    pwrBit_par    params;
    pwrBit_state  states;
    int i, shift, ix;

    /* Set the input and output pointers */
    InputRealPtrsType dscrIn   = ssGetInputPortRealSignalPtrs(S, 0);
    InputRealPtrsType decLngCd = ssGetInputPortRealSignalPtrs(S, 1);
    real_T *dscrOut            = ssGetOutputPortRealSignal(S, 0);
    real_T *pwrBits            = ssGetOutputPortRealSignal(S, 1);
    
    states.pwrSum       = ssGetRWorkValue(S, 0);
    states.pwrSymbLoc   = ssGetIWorkValue(S, 0);
    states.symbCounter  = ssGetIWorkValue(S, 1);
    params.rateSet      = (int) mxGetScalar(RATE_SET_ARG);
    params.numSymbols   = (int) mxGetScalar(NUM_SYMBOLS_ARG);
    
    /* Performs IS95 descrambling tasks */
    for(i=0; i<NUMSYMB; i++){
        /* If a second power bit is needed (in rate set one)*/
        if (pSymbCounter == pPwrSymbLoc){
            *(dscrOut + i) = 0.0;
            pPwrSum = *dscrIn[i];
            if (RATESET != 1){
                ix = (pPwrSum < LEAST_FRAC) && (pPwrSum > (-LEAST_FRAC));
                *(pwrBits + i) = pPwrSum * (1.0 - ix) - LEAST_FRAC * ix;
            }
        }
        
        /* If the current location is the location of a power bit */
        else if ((pSymbCounter == (pPwrSymbLoc + 1)) && (RATESET == 1)){
            pPwrSum += *dscrIn[i];
            *(dscrOut + i) = 0.0;
            ix = (pPwrSum < LEAST_FRAC) && (pPwrSum > (-LEAST_FRAC));
            *(pwrBits + i) = pPwrSum * (1.0 - ix) - LEAST_FRAC * ix; 
        }
        
        else{
            dscrOut[i] = *dscrIn[i];
            pwrBits[i] = 0;
            
            /* If the current location is part of the {20, 21, 22, 23} bits */
            /* used to determine the next power bit location */
            if (pSymbCounter >= NUM_LOC_BITS ){
                pwrBits[0] = 0;
                if (pSymbCounter == NUM_LOC_BITS )
                    pPwrSymbLoc = 0;
                shift = pSymbCounter - NUM_LOC_BITS;
                pPwrSymbLoc += ((int) *decLngCd[i]) * (1 << shift);
            }                             
        }
        
        
        pSymbCounter = (pSymbCounter + 1) % NUM_PWR_GP_SYM;
    } /* for */


    /* Saves the different states */
    ssSetIWorkValue(S, 0, states.pwrSymbLoc);
    ssSetIWorkValue(S, 1, states.symbCounter);
    ssSetRWorkValue(S, 0, states.pwrSum);
} /* end of mdlOutput */

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
