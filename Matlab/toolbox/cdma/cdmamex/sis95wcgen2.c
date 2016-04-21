/*			
 *  Module Name: sis95wcgen2.c
 *
 *  Description:             
 *      Generates the Walsh Code sequences corresponding to the specified  
 *      indices, according to the IS-95A specifications. One of sixty-four  
 *      time-orthogonal Walsh functions is generated for each channel index.  
 *      The period of Walsh function spreading sequence is equal to the  
 *      duration of one Forward Traffic Channel modulation symbol.
 * 
 *  Inputs:
 *      None
 * 
 *  Outputs:
 *      Walsh Code.
 *          Integer vector containing the Walsh sequence in the bipolar 
 *          (+1/-1) format. Output is a 2D frame signal.
 *
 *  Parameters:
 *      Walsh Sequence Order
 *          Integer scalar representing the Walsh Code order. The output of 
 *          the block will consist of a vector(s) of 2order elements.   
 *          This value is set to 6 by default for IS-95A
 *      Walsh Indices
 *          Integer scalar or integer vector. It specifies the index or 
 *          indices of the generated Walsh Code sequence. If only one index  
 *          is given, the output is just a vector of length 2order elements,  
 *          containing the Walsh Sequence of the given index. If a vector of x 
 *          scalars is given, the output will be x vectors, one after the other, 
 *          each one of 2order elements, containing the Walsh Sequences of the 
 *          indices given in the vector. The bloc SWLSHGEN generates the walsh 
 *          sequences corresponding to the specified indices.
 *      Block Sampling Time (in Seconds)
 *          Simulink block sampling time, the Simulink block samples the output  
 *          every such interval. 
 *
 *  Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.3 $  $Date: 2002/04/14 16:33:04 $
 */
#define S_FUNCTION_NAME sis95wcgen2
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define NUM_ARGS        3
#define WLSH_ORD_ARG    ssGetSFcnParam(S,0)
#define INDICES_ARG     ssGetSFcnParam(S,1)
#define SAMPLE_TIME_ARG ssGetSFcnParam(S,2)

#define NUM_IND         params.numInd
#define PINDICES        params.pIndices
#define WLSHORD         params.wlshOrd

typedef struct wls{
    int       numInd;
    int       wlshOrd;
    real_T    *pIndices;
           
} wls_par;

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
    int i, m, n=0;
    
    if ((mxGetM(WLSH_ORD_ARG)*mxGetN(WLSH_ORD_ARG) != 1) ||
        (mxGetPr(WLSH_ORD_ARG)[0] <= (real_T) 0.0)  ||
        (((int) mxGetPr(WLSH_ORD_ARG)[0]) - mxGetPr(WLSH_ORD_ARG)[0])) {
        msg = "Walsh order must be a positive integer";
        goto ERROR_EXIT;
    }
    
    m = 1 << (int) mxGetPr(WLSH_ORD_ARG)[0];
    
    for (i=0; i<mxGetM(INDICES_ARG)*mxGetN(INDICES_ARG); i++){
        if ((mxGetPr(INDICES_ARG)[i] < (real_T) 0.0)  ||
            (mxGetPr(INDICES_ARG)[i] >= (real_T) m) ||
            (((int) mxGetPr(INDICES_ARG)[i]) - mxGetPr(INDICES_ARG)[i]))
            n = 1;
    }
    
    if ((mxGetM(INDICES_ARG)*mxGetN(INDICES_ARG) == 0) || (n != 0)) {
        msg = "Walsh indices must be non-negative integers less than 2^(Walsh order)";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(SAMPLE_TIME_ARG)*mxGetN(SAMPLE_TIME_ARG) != 1) ||
        ((mxGetPr(SAMPLE_TIME_ARG)[0] <= (real_T) 0.0) &&
        (mxGetPr(SAMPLE_TIME_ARG)[0] != (real_T) -1.0))) {
        msg = "Sample time must be a positive scalar";
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
    int numOut;
    
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
    
    numOut = (1 << (int) mxGetScalar(WLSH_ORD_ARG)) * mxGetN(INDICES_ARG) * mxGetM(INDICES_ARG);
    
    ssSetSFcnParamNotTunable(S, 0);
    ssSetSFcnParamNotTunable(S, 1);
    ssSetSFcnParamNotTunable(S, 2);
    
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortFrameData(           S, 0, FRAME_YES);
    if(!ssSetOutputPortMatrixDimensions(S, 0, numOut, 1)) return;
    
    ssSetNumContStates(    S, 0);   /* number of continuous states       */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states     */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times    */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 1);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 1);   /* number of pointer work vector elements*/
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)    */
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetScalar(SAMPLE_TIME_ARG));
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)
{
    wls_par params;
    real_T *wlshOut;
    int numOut, i, j, temp, seqLen;
        
    params.wlshOrd  = (int) mxGetScalar(WLSH_ORD_ARG);
    params.numInd   = mxGetN(INDICES_ARG) * mxGetM(INDICES_ARG);
    params.pIndices = mxGetPr(INDICES_ARG);
    
    numOut          = (1 << params.wlshOrd) * params.numInd;
    wlshOut         = (real_T *) calloc(numOut, sizeof(real_T));
    
#ifdef MATLAB_MEX_FILE
    if (wlshOut==NULL){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
#endif
    
    /* Calculate output vector here because for given parameter output vector is constant*/
    seqLen  = 1 << WLSHORD;
    
    for (i=0; i<NUM_IND; i++){
        for (j=0; j<seqLen; j++){
            temp = j & ((int) PINDICES[i]);
            *wlshOut++ = 1.0 - 2.0 * (real_T) parity_check(temp, WLSHORD);
        }
    }
    wlshOut -= numOut;
    
    ssSetPWorkValue(S, 0, wlshOut);
    ssSetIWorkValue(S, 0, numOut);
    
}
#endif	/* MDL_INITIALIZE_CONDITIONS */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *wlshOut, *Output;
    int numOut, i;
    
    Output  = ssGetOutputPortRealSignal(S,0);
    numOut  = ssGetIWorkValue(S, 0);
    wlshOut = ssGetPWorkValue(S, 0);
    
    /* copy Pwork values to the output vector*/
    for(i=0; i<numOut; i++)
        Output[i] = wlshOut[i];
}


static void mdlTerminate(SimStruct *S)
{
    real_T *wlshOut = ssGetPWorkValue(S, 0);
    free(wlshOut);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif




