/*
 *  Module Name: sis95rcwalshdemod.c
 *
 *  Description:
 *      Simulates the Walsh demodulator for the reverse channel.
 *      Using the correlators output this block calculates metrics for each  
 *      symbol of the Walsh sequence. These metrics differences are then  
 *	calculated. The decision for each symbol is then made for '0' if the 
 *	difference is greater than 0 and for '1' otherwise.
 *
 *  Inputs:
 *      Chip In
 *          Binary vector containing the input data frame to be decoded.
 * 
 *  Outputs:
 *      Hard Decision
 *          Binary vector, containing the hard decision demodulated signal 
 *          (6 bits per each set of inputs).
 *      Soft Decision
 *          Real vector, containing the soft decision demodulated signal 
 *          (6 values (soft-decision) per each set of inputs).
 * 
 *  Parameters:
 *      Walsh Size
 *          Scalar that specifies the number of input bits that determine  
 *          the index of the output Walsh code function.
 *      Input Size 
 *          Number of input chips.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.12.2.1 $  $Date: 2004/04/12 22:59:57 $
 */
 
#define S_FUNCTION_NAME sis95rcwalshdemod
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"

#define NUM_ARGS        2
#define WLSH_ORD_ARG    ssGetSFcnParam(S,0)
#define NUM_SYMB_IN_ARG ssGetSFcnParam(S,1)

/* For dimension propagation and frame support */
#define NUM_INPORTS  1  
#define NUM_OUTPORTS 2
#define TOTAL_PORTS  3

#define WLSH_ORD        params.wlshOrd
#define NUM_SYMB_IN     params.numSymb
#define	SEQ_LEN         params.seqLen
#define	WLSH_COD        params.wlshcod
#define	MXSB            params.mxsb
#define	MXS             params.mxs

typedef struct rlwlsh{
    
    int     wlshOrd;
    int     numSymb;
    int     seqLen;
    int     *wlshcod;
    double  *mxsb;
    double  *mxs;
    
} rlwlsh_par;

#ifdef  MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS

static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    
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
    
    if (!ssSetNumInputPorts(S, 1)) return;
    if (!ssSetInputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, 0, FRAME_INHERITED);
	ssSetInputPortDirectFeedThrough( S, 0, 1);
    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    for (i = 0; i< NUM_OUTPORTS; i++) {
    	if (!ssSetOutputPortDimensionInfo(S, i, DYNAMIC_DIMENSION)) return;
	    ssSetOutputPortFrameData(         S, i, FRAME_INHERITED);
    }

    ssSetNumContStates(    S, 0);       /* number of continuous states       */
    ssSetNumDiscStates(    S, 0);           /* number of discrete states     */
    ssSetNumSampleTimes(   S, 1);               /* number of sample times    */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 1);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 3);   /* number of pointer work vector elements*/
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)    */
}

/* Function: detAllPortWidths
 * Purpose: Determine the widths for the input and output ports based 
 *          on the parameters passed in. The widths are stored in an int
 *          array with first the input widths and then the outputs.
 */
void detAllPortWidths(SimStruct *S, int *widths)
{
    int wlshOrder  = (int) mxGetScalar(WLSH_ORD_ARG);
    int numSymbIn  = (int) mxGetScalar(NUM_SYMB_IN_ARG);
    int numChipIn  = (int) numSymbIn * (1 << wlshOrder);

    /* Inputs */
    widths[0] = numChipIn;
    /* Outputs */
    widths[1] = wlshOrder  * numSymbIn;
    widths[2] = wlshOrder  * numSymbIn;  
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S, int_T portIdx,
                                         Frame_T frameData)
{
    (void) portIdx; /* not used */
    ssSetInputPortFrameData( S, 0, frameData);
    ssSetOutputPortFrameData(S, 0, frameData);
    ssSetOutputPortFrameData(S, 1, frameData);
}
#endif

/* For dimension propagation and frame support */
#define NUM_INPORTS_TO_SET  1
#define FIRST_INPORTIDX_TO_SET 0  
#define NUM_OUTPORTS_TO_SET 2
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
    int wlshOrder  = (int) mxGetScalar(WLSH_ORD_ARG);
    int numSymbIn  = (int) mxGetScalar(NUM_SYMB_IN_ARG);
    int numChipIn  = (int) numSymbIn * (1 << wlshOrder);
    
    int *wlshcod  = (int *) calloc(numChipIn, sizeof(int));
    double *mxsb = (double *) calloc(wlshOrder, sizeof(double));
    double *mxs  = (double *) calloc(wlshOrder, sizeof(double));
    
#ifdef MATLAB_MEX_FILE
    if (wlshcod==NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vector");
        return;
    }
    
    if (mxsb==NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vector");
        return;
    }
    
    if (mxs==NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vector");
        return;
    }
    
#endif
    
    ssSetIWorkValue(S, 0, (1 << wlshOrder));
    ssSetPWorkValue(S, 0, wlshcod);
    ssSetPWorkValue(S, 1, mxsb);
    ssSetPWorkValue(S, 2, mxs);
}
#endif	/* MDL_INITIALIZE_CONDITIONS */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int i, k, j, index;
    real_T  msb;
    real_T  *decOut1 =  ssGetOutputPortRealSignal(S,0);
    real_T  *decOut2 =  ssGetOutputPortRealSignal(S,1);
    

    InputRealPtrsType ppDecIn =  ssGetInputPortRealSignalPtrs( S, 0);
    
    rlwlsh_par params;
    params.wlshOrd	 = (int) mxGetScalar(WLSH_ORD_ARG);
    params.numSymb	 = (int) mxGetScalar(NUM_SYMB_IN_ARG);
    params.seqLen	 = ssGetIWorkValue(S, 0);
    params.wlshcod	 = ssGetPWorkValue(S, 0);
    params.mxsb		 = ssGetPWorkValue(S, 1);
    params.mxs		 = ssGetPWorkValue(S, 2);
    
    
    for (k=0; k<NUM_SYMB_IN; k++){
        for (i=WLSH_ORD-1; i>-1; i--){
            MXS[i]=0;  /* Maximum value of the correlators output with ith component equal to 0 */
            MXSB[i]=0; /* Maximum value of the correlators output with ith component equal to 1 */
            for (j=0; j<SEQ_LEN; j++){
                if (j & (1 << i)){
                    if (*ppDecIn[j + k*SEQ_LEN] > MXSB[i])
                        MXSB[i] = *ppDecIn[j + k*SEQ_LEN];
                }else{
                    if (*ppDecIn[j + k*SEQ_LEN] > MXS[i])
                        MXS[i] = *ppDecIn[j + k*SEQ_LEN];
                }
            }
            
            /* Soft Decision output */
            
            decOut2[i + k*WLSH_ORD] = MXS[i] - MXSB[i]; 
            
            /* Hard Decision Output */
            
            if ((MXS[i] - MXSB[i]) >= 0)
                decOut1[i + k*WLSH_ORD] = 0; 
            else
                decOut1[i + k*WLSH_ORD] = 1;
        }
        
        msb=0.0; /* Maximum value of the correlators output */
        index = 0; /* Index of the maximum value of the correlators output */
        for (j=0; j<SEQ_LEN; j++){
            if (*ppDecIn[j + k*SEQ_LEN] > msb){
                msb = *ppDecIn[j + k*SEQ_LEN];
                index = j; 
            }
        }
    }
    
}


static void mdlTerminate(SimStruct *S)
{
    
    int *wlshcod  = ssGetPWorkValue(S, 0);
    real_T *mxsb  = ssGetPWorkValue(S, 1);
    real_T *mxs   = ssGetPWorkValue(S, 2);
    
    free(wlshcod);
    free(mxsb);
    free(mxs);   
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
