/*
 * SFUN_CPLX.c complex signal example. 
 *
 *   C-MEX S-function for complex signal add with one input port and 
 *   one parameter.
 *
 *
 *   Input        parameter     output
 *   --------------------------------
 *   scalar       scalar        scalar
 *   scalar       1-D vector    1-D vector
 *   1-D vector   scalar        1-D vector
 *   1-D vector   1-D vector    1-D vector
 *
 *
 *   Input        parameter     output
 *   --------------------------------
 *   real         real          real
 *   real         complex       complex
 *   complex      real          complex
 *   complex      complex       complex
 *
 *
 *  Author: M. Shakeri
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.5.4.3 $  $Date: 2004/04/14 23:49:43 $
 */
#define S_FUNCTION_NAME  sfun_cplx
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

/* use utility function IsRealMatrix() */
#if defined(MATLAB_MEX_FILE)
#include "sfun_slutils.h"
#endif

enum {PARAM = 0, NUM_PARAMS};

#define PARAM_ARG ssGetSFcnParam(S, PARAM)

#define EDIT_OK(S, ARG) \
       (!((ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ARG)))


#ifdef MATLAB_MEX_FILE 
#define MDL_CHECK_PARAMETERS 
/* Function: mdlCheckParameters =============================================
 * Abstract:
 *    Verify parameter settings.
 */
static void mdlCheckParameters(SimStruct *S) 
{
    if(EDIT_OK(S, PARAM_ARG)){
        /* Non-empty, double, real or complex vector */
        if( mxIsEmpty(PARAM_ARG)     || 
            !IsDoubleVect(PARAM_ARG)){
            ssSetErrorStatus(S, "Invalid parameter specified. The parameter "
                             "must be a non-empty, double, real or complex "
                             "vector.");
            return;
        }      
    }
} /* mdlCheckParameters */
#endif 

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_PARAMS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S); 
    if (ssGetErrorStatus(S) != NULL) return; 
#endif

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            ssSetSFcnParamTunable( S, iParam, SS_PRM_TUNABLE );
        }
    }

    /* Set number of input and output ports */
    if (!ssSetNumInputPorts(S, 1)) return;
    if (!ssSetNumOutputPorts(S,1)) return;

    /* Set input and output port width. Allow scalar expansion. */
    {
        int_T pWidth = mxGetNumberOfElements(PARAM_ARG);
        int_T uWidth = DYNAMICALLY_SIZED;
        int_T yWidth = (pWidth == 1) ? DYNAMICALLY_SIZED : pWidth;

        ssSetInputPortWidth( S, 0, uWidth);
        ssSetOutputPortWidth(S, 0, yWidth);
    }

    /* Set input and output port complex flag */
    {
        boolean_T pIsComplex = mxIsComplex(PARAM_ARG);
        CSignal_T uCplxFlag  = COMPLEX_INHERITED;
        CSignal_T yCplxFlag  = (pIsComplex) ? COMPLEX_YES : COMPLEX_INHERITED;

        ssSetInputPortComplexSignal( S, 0, uCplxFlag);
        ssSetOutputPortComplexSignal(S, 0, yCplxFlag);
    }

    ssSetInputPortDirectFeedThrough(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_ALLOW_INPUT_SCALAR_EXPANSION);
} /* mdlInitializeSizes */

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Initialize the sample times array.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);

}/* mdlInitializeSampleTimes */

/* Function: mdlOutputs =======================================================
 * Abstract:
 *   Compute the outputs of the S-function.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T   uIsComplex = ssGetInputPortComplexSignal (S, 0) == COMPLEX_YES;
    boolean_T   yIsComplex = ssGetOutputPortComplexSignal(S, 0) == COMPLEX_YES;
    boolean_T   pIsComplex = mxIsComplex(PARAM_ARG);


    InputRealPtrsType uPtr   = ssGetInputPortRealSignalPtrs(S,0);  
    real_T            *y     = ssGetOutputPortRealSignal(S,0);
    const real_T      *pr    = mxGetPr(PARAM_ARG);          
    const real_T      *pi    = mxGetPi(PARAM_ARG);

    int_T             uWidth = ssGetInputPortWidth(S,0);
    int_T             pWidth = mxGetNumberOfElements(PARAM_ARG);
    int_T             yWidth = ssGetOutputPortWidth(S,0);

    int               i;

    UNUSED_ARG(tid); /* not used in single tasking mode */

    /*
     * Notes:
     *  - Input complex signal elements are interleaved.
     *  - Output complex signal elements are interleaved.
     *    Example: [1+2i 3+4i] is stored as follows: [1 2 3 4]
     *
     *  - Real and imag parts of parameter are stored separately.
     *    Example: [1+2i 3+4i]
     *             mxGetPr: [1 3]
     *             mxGetPi: [2 4]
     */

    for (i = 0; i < yWidth; i++) {
        /* Add real part */
        int_T uIdx = (uWidth == 1) ? 0 : i;
        int_T pIdx = (pWidth == 1) ? 0 : i;
        int_T yIdx = (yIsComplex)  ? 2*i : i;

        y[yIdx] = *uPtr[uIdx] + pr[pIdx];
        /* Add imag part */
        if(yIsComplex){
            real_T uVal = (uIsComplex) ? *(uPtr[uIdx] + 1) : 0;
            real_T pVal = (pIsComplex) ? pi[pIdx] : 0;

             y[yIdx+1] = uVal + pVal;
        }
    } 
} /* mdlOutputs */


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
/* Function: mdlSetInputPortComplexSignal ======================================
 *    This routine is called with the candidate complex signal flag for a 
 *    dynamically typed port.  If the proposed complex signal flag is 
 *    acceptable, the routine should go ahead and set the actual port 
 *    complex signal flag using ssSetInputPortComplexSignal. If the complex 
 *    signal flag is unacceptable an error should be generated via 
 *    ssSetErrorStatus.  Note that any other dynamically typed input or 
 *    output ports whose complex signal flags are implicitly defined by virtue 
 *    of knowing the complex signal flags of the given port can also have 
 *    their complex signal flags set via calls to ssSetInputPortComplexSignal 
 *    or ssSetOutputPortComplexSignal.
 */
static void mdlSetInputPortComplexSignal(SimStruct  *S, 
                                         int_T      port,
                                         CSignal_T  csig)
{
    CSignal_T yCplxFlag = ssGetOutputPortComplexSignal(S, 0);
    ssSetInputPortComplexSignal(S, port, csig);
    if(yCplxFlag == COMPLEX_INHERITED){
        /* 
         * Block must have a real (non-complex) parameter.
         * Input and output complex flags are the same.
         */
        ssSetOutputPortComplexSignal(S, 0, csig);
    }
}/* mdlSetInputPortComplexSignal */

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
/* Function: mdlSetOutputPortComplexSignal =====================================
 *    This routine is called with the candidate complex signal flag for a 
 *    dynamically typed port.  If the proposed complex signal flag is 
 *    acceptable, the routine should go ahead and set the actual port 
 *    complex signal flag using ssSetOutputPortComplexSignal. If the complex 
 *    signal flag is unacceptable an error should be generated via 
 *    ssSetErrorStatus.  Note that any other dynamically typed input or 
 *    output ports whose complex signal flags are implicitly defined by virtue 
 *    of knowing the complex signal flags of the given port can also have 
 *    their complex signal flags set via calls to ssSetInputPortComplexSignal 
 *    or ssSetOutputPortComplexSignal.
 */
static void mdlSetOutputPortComplexSignal(SimStruct  *S, 
                                         int_T       port,
                                         CSignal_T   csig)
{
    /*
     * Simulink calls this function if the output complex flag is unknown.
     * In this case, the block must have a real (non-complex) parameter, and
     * the input and output complex flags are the same.
     */
    ssSetInputPortComplexSignal( S, port, csig);
    ssSetOutputPortComplexSignal(S, port, csig);
} /* mdlSetOutputPortComplexSignal */

#define MDL_SET_DEFAULT_PORT_COMPLEX_SIGNALS
/* Function: mdlSetDefaultPortComplexSignals ===================================
 *    This routine is called when Simulink is not able to find a candidate 
 *    complex signal flags for dynamically typed ports. This usually happens
 *    when the block is unconnedted or it is in a feedback loop. This routine
 *    must set the complex signal flag of all dynamically typed ports.
 */
static void mdlSetDefaultPortComplexSignals(SimStruct  *S)
{
    CSignal_T uCmplxFlag = ssGetInputPortComplexSignal( S, 0);
    CSignal_T yCmplxFlag = ssGetOutputPortComplexSignal(S, 0);

    if(uCmplxFlag == COMPLEX_INHERITED) {
        ssSetInputPortComplexSignal( S, 0, COMPLEX_NO);
    }

    if(yCmplxFlag == COMPLEX_INHERITED) {
        ssSetOutputPortComplexSignal(S, 0, COMPLEX_NO);
    }
} /* mdlSetDefaultPortComplexSignals */
#endif

/* Function: mdlSetWorkWidths ===============================================
 * Abstract:
 *    Set up run-time parameter. 
 */
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const char_T    *rtParamNames[] = {"Operand"};
    ssRegAllTunableParamsAsRunTimeParams(S, rtParamNames);
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    Called when the simulation is terminated.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */
}/* mdlTerminate */


#ifdef	MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* [EOF] sfun_matadd.c */
