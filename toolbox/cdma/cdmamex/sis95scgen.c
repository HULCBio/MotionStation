/*			
 *  Module Name: sis95scgen.c
 *
 *  Description:
 *      Generates I and Q short PN code sequences.
 *      These sequences are periodic with period 215 chips and are based on
 *      the specified characteristic polynomials in IS-95A specifications. 
 *      The sequences repeat exactly 75 times in every 2 seconds. 
 * 
 *  Inputs:
 *      PN Mask
 *          It is the short PN code mask for IN-phase and Quadrature components,
 *          given as a complex number where real and imaginary parts are  
 *          integers between 0 and 215-1.If a real mask is given, then real  
 *          and imaginary parts are assumed to be equal.If the mask given is 0, 
 *          then the default value used is 1 + i.  
 *
 *  Outputs:
 *      PN-I
 *          Integer vector containing the In-Phase PN sequence in the 
 *          bipolar (+1/-1) format.
 *      PN-Q
 *          Integer vector containing the Quadrature PN sequence in the 
 *          bipolar (+1/-1) format.
 *
 *  Parameters:
 *      Output Frame Size	
 *          It is the length of the PN-I and PN-Q vectors.
 *      Sampling Time (in Seconds).
 *          Duration of the output generated at the execution of the block.
 * 
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.14.2.1 $  $Date: 2004/04/12 22:59:59 $
 */
#define S_FUNCTION_NAME sis95scgen
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include <math.h>

#define NUM_ARGS        2
#define NUM_OUT_ARG     ssGetSFcnParam(S,0)
#define SAMP_TIME_ARG   ssGetSFcnParam(S,1)

#define NUM_STALL       0
#define MAX_NUM_STALL   64


void is95PNGen(real_T *pOutRealData, real_T *pOutImagData, unsigned long *mask,
               int codeLen, unsigned long *state)
{
    unsigned int inPhGen = 0x85C4, quadPhGen = 0x9E38;
    /* Will not change for different instances */
    int inPhMaskedWord, quadMaskedWord, inPhOutBit, quadOutBit, i, bitNo;
    
    state[0] &= 0x7fff;
    state[1] &= 0x7fff;
    
    for (i=0; i<codeLen; i++){
        
        if (state[2] == 14){
            pOutRealData[i] = 1.0; /* Insert the Erasure for in-phase   */
            pOutImagData[i] = 1.0; /* Insert the Erasure for quadrature */
            i++;
            state[2] = 0;
        }
        
        if (i != codeLen){
            /* Get in-Phase and quadrature masked words */
            inPhMaskedWord = state[0]  & mask[0];
            quadMaskedWord = state[1]  & mask[1];
            
            /* Get output bits */
            inPhOutBit = quadOutBit = 0;   
            for (bitNo=0; bitNo<15; bitNo++){
                inPhOutBit ^= inPhMaskedWord;
                quadOutBit ^= quadMaskedWord;
                inPhMaskedWord >>= 1;
                quadMaskedWord >>= 1;
            }
            inPhOutBit &= 0x1;
            quadOutBit &= 0x1;
            
            if (inPhOutBit)                      /* Test for consequetive Zeros */
                state[2] = 0;
            else
                state[2]++;
            
            pOutRealData[i] = 1.0 - 2.0 * ((real_T) inPhOutBit);
            pOutImagData[i] = 1.0 - 2.0 * ((real_T) quadOutBit);
            
            /* Get next LFSR State for in phase */
            state[0] ^= ((state[0] & 0x1) * inPhGen);
            state[0] >>= 1;
            
            /* Get next LFSR State for quadrature phase */
            state[1] ^= ((state[1] & 0x1) * quadPhGen);
            state[1] >>= 1;
        }
    }                        
    state[0] &= 0x7fff;
    state[1] &= 0x7fff;
}


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    
    if ((mxGetM(NUM_OUT_ARG)*mxGetN(NUM_OUT_ARG) != 1) ||
        (mxGetPr(NUM_OUT_ARG)[0] <= (real_T) 0.0)  ||
        (floor(mxGetPr(NUM_OUT_ARG)[0]) != mxGetPr(NUM_OUT_ARG)[0])) {
        msg = "Output frame size must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(SAMP_TIME_ARG)*mxGetN(SAMP_TIME_ARG) != 1) ||
        ((mxGetPr(SAMP_TIME_ARG)[0] <= (real_T) 0.0) && (mxGetPr(SAMP_TIME_ARG)[0] != -1.0))) {
        msg = "Sample time must be a positive scalar or -1";
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
    int numSymb = (int) mxGetScalar(NUM_OUT_ARG);
    
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
    
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 2);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    
    if (!ssSetNumOutputPorts(S, 2)) return;
    ssSetOutputPortWidth(S, 0, numSymb);
    ssSetOutputPortWidth(S, 1, numSymb);
    
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */ 
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 1);   /* number of pointer work vector elements*/
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)        */
    
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    real_T ts = mxGetScalar(SAMP_TIME_ARG);
    ssSetSampleTime(S, 0, ts);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)

{
    unsigned long *pState, pTemp[3], pMask[2];
    int numOut    = (int) mxGetScalar(NUM_OUT_ARG);
    
#ifdef MATLAB_MEX_FILE
    if (numOut < NUM_STALL){
        ssSetErrorStatus(S,"Number of symbols to be repeated must be less than or equal to number of outputs");
        return;
    }
#endif
    
    pState = (unsigned long *) calloc(3, sizeof(unsigned long));
    
#ifdef MATLAB_MEX_FILE
    if (pState==NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
#endif
    
    ssSetPWorkValue(S, 0, pState);
    
    pState[0] = (unsigned long) 0x1;
    pState[1] = (unsigned long) 0x1;
    pState[2] = (unsigned long) 0;
    
    pTemp[0] = pState[0];
    pTemp[1] = pState[1];
    pTemp[2] = pState[2];
    pMask[0] = 0x1;
    pMask[1] = 0x1;


}
#endif	/* MDL_INITIALIZE_CONDITIONS */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int numOut    = (int) mxGetScalar(NUM_OUT_ARG);
    int numIter;
    unsigned long pMask[2];
    unsigned long *pState = (unsigned long *) ssGetPWorkValue(S, 0);
    
    /* Set the output pointers */
    
    real_T	*pInPhase =  ssGetOutputPortRealSignal(S,0);
    real_T	*pQuad =  ssGetOutputPortRealSignal(S,1);
    
    InputRealPtrsType ppMaskIn =  ssGetInputPortRealSignalPtrs( S, 0);
    pMask[0] = (unsigned long) *(ppMaskIn[0]);
    pMask[1] = (unsigned long) *(ppMaskIn[1]);
    
#ifdef MATLAB_MEX_FILE
    if (numOut < NUM_STALL){
        ssSetErrorStatus(S,"Number of PN symbols to be delayed must be less than or equal to number of outputs");
        return;
    }
#endif
    
    if (pMask[0] == (unsigned long) 0)
        pMask[0] = (unsigned long) 0x1;
    if (pMask[1] == (unsigned long) 0)
        pMask[1] = pMask[0];
    
    numIter = numOut;
    if (numIter > 0){
        /* Performs IS95 short PN code generation */
        is95PNGen(pInPhase, pQuad, pMask, numIter, pState);
    }
}


static void mdlTerminate(SimStruct *S)
{
    unsigned long *pState = (unsigned long *) ssGetPWorkValue(S, 0);
    
    free(pState);

}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif




