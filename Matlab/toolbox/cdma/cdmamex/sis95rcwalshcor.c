/*
 *  Module Name: sis95rcwalshcor.c
 *
 *  Description:
 *      Simulates the IS95 Walsh correlator for the reverse channel. 
 *      Each of the two quadrature components of the received signal goes 
 *      through a bank of orthogonal non coherent correlators. 
 *      The correlator sends out the output of all correlators.
 * 
 *  Inputs:
 *      Symbol In
 *          Binary vector containing the input data frame to be corrolated.
 * 
 *  Outputs:
 *      Chip Out
 *          Binary vector containing the Walsh Code corrolated data frame.
 *	
 *  Parameters:
 *      Output Size
 *          Number of output chips.
 *      Walsh Size
 *          Scalar that specifies the number of input bits that determine  
 *          the index of the output walsh code function.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.9.2.1 $  $Date: 2004/04/12 22:59:56 $
 */
 
#define S_FUNCTION_NAME sis95rcwalshcor
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"

#define NUM_ARGS        2
#define WLSH_ORD_ARG    ssGetSFcnParam(S,0)
#define NUM_SYMB_IN_ARG ssGetSFcnParam(S,1)

#define WLSH_ORD        params.wlshOrd
#define SEQ_LEN         params.seqLen
#define WLSH_COD        params.wlshcod
#define NUM_SYMB        params.numSymb

typedef struct rlwlsh{
    
    int *wlshcod;
    int wlshOrd;
    int seqLen;
    int numSymb; 
    
} rlwlsh_par;

static int parity_check( int a, int N)
{
    int pChk=0, j;
    
    for (j=0; j<N; j++){
        pChk ^= a;
        a >>= 1;
    } 
    pChk &= 0x1;
    return ( pChk);
}

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    /* int i, n=0; */
    
    if ((mxGetM(WLSH_ORD_ARG)*mxGetN(WLSH_ORD_ARG) != 1) ||
        (mxGetPr(WLSH_ORD_ARG)[0] <= (real_T) 0.0)  ||
        (((int) mxGetPr(WLSH_ORD_ARG)[0]) - mxGetPr(WLSH_ORD_ARG)[0])) {
        msg = "Walsh order must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(NUM_SYMB_IN_ARG)*mxGetN(NUM_SYMB_IN_ARG) != 1) ||
        (mxGetPr(NUM_SYMB_IN_ARG)[0] < 1.0) ||
        (mxGetPr(NUM_SYMB_IN_ARG)[0] > 96.0) ||
        (((int) mxGetPr(NUM_SYMB_IN_ARG)[0]) - mxGetPr(NUM_SYMB_IN_ARG)[0])){
        msg = "Number of input symbols must be an integer between 1 and 96";
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
    
    if (!ssSetNumInputPorts(S, 1)) return;
    if (!ssSetInputPortDimensionInfo(	S, 0, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         	S, 0, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough(	S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    if (!ssSetOutputPortDimensionInfo(	S, 0, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         	S, 0, FRAME_INHERITED);
    
    ssSetNumContStates(    S, 0);       /* number of continuous states       */
    ssSetNumDiscStates(    S, 0);           /* number of discrete states     */
    ssSetNumSampleTimes(   S, 1);               /* number of sample times    */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 1);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 1);   /* number of pointer work vector elements*/
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
    int wlshOrder  = (int) mxGetScalar(WLSH_ORD_ARG);
    int numChipIn  = (int) mxGetScalar(NUM_SYMB_IN_ARG) * (1 << wlshOrder);

    widths[0] = numChipIn;
    widths[1] = numChipIn;
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
    int numChipIn  = (int) mxGetScalar(NUM_SYMB_IN_ARG) * (1 << wlshOrder);
    
    int *wlshcod = (int *) calloc(numChipIn, sizeof(int));
    
#ifdef MATLAB_MEX_FILE
    if (wlshcod==NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vector");
        return;
    }
#endif
    
    ssSetIWorkValue(S, 0, (1 << wlshOrder));
    ssSetPWorkValue(S, 0, wlshcod);
}
#endif	/* MDL_INITIALIZE_CONDITIONS */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    rlwlsh_par params;
    int i, j, k;
    
    real_T  *pOut = ssGetOutputPortRealSignal(S,0);
    InputRealPtrsType ppIn =  ssGetInputPortRealSignalPtrs( S, 0);
    
    params.wlshOrd = (int) mxGetScalar(WLSH_ORD_ARG);
    params.numSymb = (int) mxGetScalar(NUM_SYMB_IN_ARG);
    params.seqLen  = ssGetIWorkValue(S, 0);
    params.wlshcod = ssGetPWorkValue(S, 0);
  
    for (k=0; k<NUM_SYMB; k++){
        for (i=0; i<SEQ_LEN; i++){
            real_T  tmp = 0;
            
            for (j=0; j<SEQ_LEN; j++){
                WLSH_COD[j] =  parity_check((j & i), WLSH_ORD);
                tmp += (1 - 2 * WLSH_COD[j]) * *ppIn[j + k*SEQ_LEN];
            }
            pOut[i + k*SEQ_LEN] = tmp / SEQ_LEN;
            pOut[i + k*SEQ_LEN] *= pOut[i + k*SEQ_LEN];
        }
    }

}


static void mdlTerminate(SimStruct *S)
{
    
    real_T *wlshcod = ssGetPWorkValue(S, 0);
    
    free(wlshcod);   
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
