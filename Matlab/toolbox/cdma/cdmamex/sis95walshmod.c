/*
 *  Module Name: sis95walshmod.c 
 *
 *  Description:
 *      Modulates the input data frame with the Walsh Code.
 *      This Modulation is 64-ary orthogonal modulation. 
 *      One of 64 possible modulation symbols is transmitted 
 *      for each six repeated code symbols. These modulation 
 *      symbols are given in a table in IS-95A specifications.
 * 
 *  Inputs:
 *      Symbol In
 *      Binary vector containing the input data frame to be modulated.
 * 
 *  Outputs:
 *      Chip Out
 *          Binary vector containing the Walsh Code modulated data frame.
 *
 *  Parameters:
 *      Walsh Sequence Order.
 *          Scalar that specifies the number of input bits that determine 
 *          the index of the output walsh code function.
 *      Output Frame Size (Must be a Multiple of Walsh Function Length).
 *          The length of the Output vector.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.13.2.1 $  $Date: 2004/04/12 23:00:01 $
 */

#define S_FUNCTION_NAME sis95walshmod
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"

#define NUM_ARGS        2
#define WLSH_ORD_ARG    ssGetSFcnParam(S,0)
#define NUM_SYM_IN_ARG  ssGetSFcnParam(S,1)

#define X_WLSH_ORD      params.wlshOrd
#define NUM_MOD         params.numMod 
#define SEQ_LEN         params.seqLen

typedef struct wlMod{
    
    int wlshOrd;
    int numMod;
    int seqLen;
    
} rlwlmod_par;


int parity_check(int a, int N)
{
    int pChk=0, j;
    
    for (j=0; j<N; j++){
        pChk ^= a;
        a >>= 1;
    } 
    pChk &= 0x1;

    return (pChk);
}

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    int wlshOrder  = (int) mxGetScalar(WLSH_ORD_ARG);
    int numSymbIn  = (int) mxGetScalar(NUM_SYM_IN_ARG);
    
    if ((mxGetM(WLSH_ORD_ARG)*mxGetN(WLSH_ORD_ARG) != 1) ||
        (mxGetPr(WLSH_ORD_ARG)[0] <= (real_T) 0.0)  ||
        (((int) mxGetPr(WLSH_ORD_ARG)[0]) - mxGetPr(WLSH_ORD_ARG)[0])) {
        msg = "Walsh order must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(NUM_SYM_IN_ARG)*mxGetN(NUM_SYM_IN_ARG) != 1) ||
        (mxGetPr(NUM_SYM_IN_ARG)[0] < 1.0) ||
        (mxGetPr(NUM_SYM_IN_ARG)[0] > 576.0) ||
        (numSymbIn - wlshOrder * (numSymbIn / wlshOrder)) ||
        (((int) mxGetPr(NUM_SYM_IN_ARG)[0]) - mxGetPr(NUM_SYM_IN_ARG)[0])){
        msg = "Number of input symbols must be an integer between 1 and 576 and must be divisible by the Walsh order";
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
        ssSetSFcnParamNotTunable(S, i);

    if (!ssSetNumInputPorts(S, 1)) return;
    if (!ssSetInputPortDimensionInfo(	S, 0, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         	S, 0, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough(	S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    if (!ssSetOutputPortDimensionInfo(	S, 0, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         	S, 0, FRAME_INHERITED);
        
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 2);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)    */
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
    int wlshOrder, numSymbIn, numSymbOut;

    wlshOrder  = (int) mxGetScalar(WLSH_ORD_ARG);
    numSymbIn  = (int) mxGetScalar(NUM_SYM_IN_ARG);
    numSymbOut = (1 << wlshOrder) * (numSymbIn / wlshOrder);

    widths[0] = numSymbIn;  /* input */
    widths[1] = numSymbOut; /* output */
}

/* For dimension propagation and frame support */
#define NUM_INPORTS_TO_SET  1
#define FIRST_INPORTIDX_TO_SET 0  
#define NUM_OUTPORTS_TO_SET 1
#define TOTAL_PORTS_TO_SET  2  /* = TOTAL_PORTS */

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
    int wlshOrder  = (int) mxGetScalar(WLSH_ORD_ARG);
    int numSymbIn  = (int) mxGetScalar(NUM_SYM_IN_ARG);
    
    ssSetIWorkValue(S, 0, (numSymbIn / wlshOrder));
    ssSetIWorkValue(S, 1, (1 << wlshOrder));
}
#endif	/* MDL_INITIALIZE_CONDITIONS */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    const char *msg = NULL;
    InputRealPtrsType ppModIn =  ssGetInputPortRealSignalPtrs( S, 0);
    real_T	*modOut =  ssGetOutputPortRealSignal(S,0);
    int numSymbIn  = (int) mxGetScalar(NUM_SYM_IN_ARG);
    int i, j, index=0;
    int error=0;

    rlwlmod_par params;
    
    params.wlshOrd = (int) mxGetScalar(WLSH_ORD_ARG);
    params.numMod  = ssGetIWorkValue(S, 0);
    params.seqLen  = ssGetIWorkValue(S, 1);
    
    for (i=0; i<NUM_MOD; i++){
        index = 0;
        
        /* Collect data to check at end of loop if error in input data */
        error |= (int)*ppModIn[i];
        
        for (j=0; j<X_WLSH_ORD; j++){
            index += ((int) **ppModIn++) * (1 << j);
        }
        for (j=0; j<SEQ_LEN; j++)
            *modOut++ = 1.0 - 2.0 * (real_T) parity_check((j & index), X_WLSH_ORD);
    }
    
    /* If error in input data then inform user */
    if ((error != 0) && (error != 1)) {
        ssSetErrorStatus(S,"Input must be a binary vector");
        return;
    }
    
}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
