/*
 *  Module Name: sis95rakedemod.c
 *                               
 *  Description:
 *      Performs the demodulation of the data obtained from the Rake 
 *      receiver finger. The block works on data from multiple fingers 
 *      of the rake receiver at a time and generates the demodulated 
 *      symbol streams for each finger. Channel estimation from each 
 *      finger is used to demodulate data.
 * 
 *  Inputs:
 *      Pilot In
 *          Complex vector, containing the channel estimates for the four 
 *          rake fingers.
 *      Signal In
 *          Complex vector, containing the correlator output signal for 
 *          the four rake fingers.
 *
 *  Outputs:
 *      Finger 1 Data
 *          Real vector, containing the demodulated symbol data for finger 1.
 *      Finger 2 Data
 *          Real vector, containing the demodulated symbol data for finger 2.
 *      Finger 3 Data
 *          Real vector, containing the demodulated symbol data for finger 3.
 *      Finger 4 Data
 *          Real vector, containing the demodulated symbol data for finger 4.
 *               
 *  Parameters:
 *      Input Frame Size per Finger
 *          This parameter is an integer that provides the number of symbols 
 *          per finger that need to be demodulated.
 *
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.11.2.1 $  $Date: 2004/04/12 22:59:48 $
 */
#define S_FUNCTION_NAME sis95rakedemod
#define S_FUNCTION_LEVEL 2

#include "cdma_frm.h"

#define NUM_ARGS        2
#define NUM_SYMB_ARG    ssGetSFcnParam(S,0)
#define NUM_FING_ARG    ssGetSFcnParam(S,1)

/* For dimension propagation and frame support */
#define NUM_INPORTS  4  
#define NUM_OUTPORTS 4
#define TOTAL_PORTS  8

#define SHIFT           params.shift
#define NUMSYMB         params.numSymb

typedef struct rkDemod{
    
    int shift;
    int numSymb;
    
} rkdemod_par;

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    
    if ((mxGetM(NUM_SYMB_ARG)*mxGetN(NUM_SYMB_ARG) != 1) ||
        (mxGetPr(NUM_SYMB_ARG)[0] <= (real_T) 0.0)  ||
        (((int) mxGetPr(NUM_SYMB_ARG)[0]) - mxGetPr(NUM_SYMB_ARG)[0])) {
        msg = "Input frame size must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(NUM_FING_ARG)*mxGetN(NUM_FING_ARG) != 1) ||
        (mxGetPr(NUM_FING_ARG)[0] <= (real_T) 0.0)  ||
        (((int) mxGetPr(NUM_FING_ARG)[0]) - mxGetPr(NUM_FING_ARG)[0])) {
        msg = "Number of Rake fingers must be a positive integer";
        goto ERROR_EXIT;
    }
    
ERROR_EXIT:
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
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
    
    ssSetSFcnParamNotTunable(S, 0);
    
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
        
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 1);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
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
    int i, numSymb, numFin;
    numSymb = (int) mxGetPr(NUM_SYMB_ARG)[0];
    numFin  = (int) mxGetPr(NUM_FING_ARG)[0];

    /* Input port widths */
    for (i = 0; i < NUM_INPORTS; i++){
        widths[i] = numFin * numSymb;
    }
    /* Output port widths */
    for (i = NUM_INPORTS; i < TOTAL_PORTS; i++){
        widths[i] = numSymb;
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
#define NUM_INPORTS_TO_SET  4
#define FIRST_INPORTIDX_TO_SET 0  
#define NUM_OUTPORTS_TO_SET 4
#define TOTAL_PORTS_TO_SET  8  

#include "cdma_dim_hs.c"

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)
{
}
#endif


static void mdlOutputs(SimStruct *S, int_T tid)
{       
    rkdemod_par params;
    int nSymb   = (int) mxGetScalar(NUM_SYMB_ARG);
    int numFin  = (int) mxGetScalar(NUM_FING_ARG);
    int index = 0;
    
    InputRealPtrsType chEstInI  = ssGetInputPortRealSignalPtrs(S, 0);
    InputRealPtrsType chEstInQ  = ssGetInputPortRealSignalPtrs(S, 1);
    InputRealPtrsType sigInI    = ssGetInputPortRealSignalPtrs(S, 2);
    InputRealPtrsType sigInQ    = ssGetInputPortRealSignalPtrs(S, 3);
    
    params.numSymb = nSymb;
    
    for (index=0 ; index<numFin; index++) {

        int  j;
        real_T *demodOut = (real_T *)  ssGetOutputPortRealSignal(S, index);
 
        params.shift = index * params.numSymb;
 
        for (j=0; j<NUMSYMB; j++)
            demodOut[j] = (*chEstInI[j + SHIFT] * *sigInI[j + SHIFT]) + 
            (*chEstInQ[j + SHIFT] * *sigInQ[j + SHIFT]);
 
    }
}


static void mdlTerminate(SimStruct *S)
{
}

/*=============================*
* Required S-function trailer *
*=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
