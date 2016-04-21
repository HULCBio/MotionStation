/*
 * SDSPPOLYVAL Apply input to a polynomial function with specified coefficients
 *
 *  COEFFS: A vector of polynomial coefficients (in decreasing order) of the
 *          standard form: an*(x^n) + ... + a3*(x^3) + a2*(x^2) + a1*x + a0.
 *
 *  Example: [1 -2 3 4 5] represents x^4 - 2(x^3) + 3(x^2) + 4x + 5
 *
 *  NOTE: The coefficients may be constant coefficients parameters from the
 *        S-function block OR as time-varying inputs to the S-function block.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.10 $  $Date: 2002/04/14 20:42:08 $
 */
#define S_FUNCTION_NAME sdsppolyval
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT1=0, INPORT2};
enum {OUTPORT=0};

/* Enumerated constants for passed-in parameters */
enum {
    CONST_COEFFS_ARGC=0,
    USE_CONST_COF_ARGC,
    NUM_ARGS
};

/* Macros to obtain params easily */
#define CONST_COEFFS_ARG  (ssGetSFcnParam(S,CONST_COEFFS_ARGC))
#define USE_CONST_COF_ARG (ssGetSFcnParam(S,USE_CONST_COF_ARGC))

/* The following subfunctions are defined below. They are used to compute the */
/* outputs for various combinations of numerical formats of inputs and coeffs */
static void RealInputsRealCoeffs(   SimStruct *S, boolean_T useConstantCoeffs );
static void RealInputsCmplxCoeffs(  SimStruct *S, boolean_T useConstantCoeffs );
static void CmplxInputsRealCoeffs(  SimStruct *S, boolean_T useConstantCoeffs );
static void CmplxInputsCmplxCoeffs( SimStruct *S, boolean_T useConstantCoeffs );

/* The following subfcns are defined below to assist with setting port complexity */
static void CheckAndSetInport1Real(    SimStruct *S );
static void CheckAndSetInport1Complex( SimStruct *S );
static void CheckAndSetInport2Real(    SimStruct *S );
static void CheckAndSetInport2Complex( SimStruct *S );
static void CheckAndSetOutportReal(    SimStruct *S );
static void CheckAndSetOutportComplex( SimStruct *S );


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /* Make sure that the "use const coeffs" parameter is a scalar */
    if ( !IS_SCALAR(USE_CONST_COF_ARG) ) {
        ssSetErrorStatus(
            S, "Use-constant-coeffs param is not a scalar. Unexpected size.");
    }

    /* If we are currently using constant coefficients, check if they are valid */
    else if ((*mxGetPr(USE_CONST_COF_ARG)) != 0.0)
    {
        /* Make sure that coeffs parameter is a vector */
        if ( (!IS_VECTOR(CONST_COEFFS_ARG)) || (!mxIsNumeric(CONST_COEFFS_ARG)) ) {
            ssSetErrorStatus(
                S, "Coefficients must be specified as a valid single row-vector");
        }
    }    
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* Constrain non-tunable parameters - not allowed to change    */
    /* coefficient source (constant or input port src) on-the-fly. */
    ssSetSFcnParamNotTunable(S, USE_CONST_COF_ARGC);

    /* The actual coefficients in the S-Fcn block parameters are           */
    /* currently set to NOT TUNABLE due to multiple code generation        */
    /* complications. This could be changed in the future if necessary...  */
    /*                                                                     */
    /* The basic issue is that because different code is generated based   */
    /* on both the complexity and the number of coefficients, the actual   */
    /* coeffs complexity and order cannot be modified in the parameter box */
    /* (through changing them in an unsupported way) after the code has    */
    /* been generated. This rules out tunability for this block parameter. */
    /*                                                                     */
    /* Note: if the customer requires tunable or time-varying coeffs, then */
    /*       the second input port of the block should instead be used for */
    /*       the coefficients source.                                      */
    ssSetSFcnParamNotTunable(S, CONST_COEFFS_ARGC);

    /* Inputs: */
    {
        
        /* This block may have one or two input ports depending on the    */
        /* "Use-constant-coefficients" parameter. Set size appropriately. */
        const boolean_T useConstCoeffs =
            (boolean_T)((*mxGetPr(USE_CONST_COF_ARG)) != 0.0);
        
        const int_T     numInports = useConstCoeffs ? 1 : 2;
        
        if (!ssSetNumInputPorts(S,numInports)) return;
        
        /* Always setup first input port (input to the polynomial) */
        ssSetInputPortWidth(            S, INPORT1, DYNAMICALLY_SIZED);
        ssSetInputPortComplexSignal(    S, INPORT1, COMPLEX_INHERITED);
        ssSetInputPortDirectFeedThrough(S, INPORT1, 1);
        ssSetInputPortReusable(         S, INPORT1, 1); /* Changed 02/23/1999 */
        ssSetInputPortOverWritable(     S, INPORT1, 0);
        
        /* Only setup second input port if necessary */
        if (!useConstCoeffs) {
            ssSetInputPortWidth(            S, INPORT2, DYNAMICALLY_SIZED);
            ssSetInputPortComplexSignal(    S, INPORT2, COMPLEX_INHERITED);
            ssSetInputPortDirectFeedThrough(S, INPORT2, 1);
            ssSetInputPortReusable(         S, INPORT2, 0);
            ssSetInputPortOverWritable(     S, INPORT2, 0);
        }
    }
    
    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 0);
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T coeffsAreComplex;
    
    /* This block may have one or two input ports depending on the    */
    /* "Use-constant-coefficients" parameter. Set size appropriately. */
    const boolean_T useConstCoeffs =
        (boolean_T)((*mxGetPr(USE_CONST_COF_ARG)) != 0.0);
    
    const boolean_T inputIsComplex =
        (boolean_T)(ssGetInputPortComplexSignal(S,INPORT1) == COMPLEX_YES);
    
    if(useConstCoeffs) {
        coeffsAreComplex = (boolean_T) mxIsComplex(CONST_COEFFS_ARG);
    }

    else {
        coeffsAreComplex =
            (boolean_T)(ssGetInputPortComplexSignal(S,INPORT2) == COMPLEX_YES);
    }
    

    /* Based on the characteristics of the inputs and coefficients, */
    /* call the appropriate private function defined for each case. */
    if(!inputIsComplex) {
        if(!coeffsAreComplex) {
            RealInputsRealCoeffs(   S, useConstCoeffs );
        }

        else {
            RealInputsCmplxCoeffs(  S, useConstCoeffs );
        }
    }
    
    else {
        if(!coeffsAreComplex) {
            CmplxInputsRealCoeffs(  S, useConstCoeffs );
        }

        else {
            CmplxInputsCmplxCoeffs( S, useConstCoeffs );
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    /* The following block variable denotes the choice of input port (#2) */
    /* or block parameter as source for polynomial coeffs. NON-TUNABLE!!! */
    const boolean_T useConstCoeffsNotInport =
        (boolean_T)((*mxGetPr(USE_CONST_COF_ARG)) != 0.0);
    
    /* Write out parameters for RTW (currently all non-tunable) */
    if (useConstCoeffsNotInport) {
        const real_T   *pReCoeffs        = mxGetPr(CONST_COEFFS_ARG);
        const boolean_T coeffsAreComplex = (boolean_T) mxIsComplex(CONST_COEFFS_ARG);
        const int_T     numCoeffs        = mxGetNumberOfElements(CONST_COEFFS_ARG);
        
        if (coeffsAreComplex) {
            const real_T *pImCoeffs = mxGetPi(CONST_COEFFS_ARG);
            
            if (!ssWriteRTWParamSettings(S, 5,
                SSWRITE_VALUE_DTYPE_VECT, "pReCoeffs", pReCoeffs, numCoeffs,
                DTINFO(SS_DOUBLE,COMPLEX_NO),
                
                SSWRITE_VALUE_DTYPE_VECT, "pImCoeffs", pImCoeffs, numCoeffs,
                DTINFO(SS_DOUBLE,COMPLEX_NO),
                
                SSWRITE_VALUE_DTYPE_NUM,  "NumCoeffs", &numCoeffs,
                DTINFO(SS_INT32,COMPLEX_NO),
                
                SSWRITE_VALUE_DTYPE_NUM,  "CoeffsAreComplex", &coeffsAreComplex,
                DTINFO(SS_BOOLEAN,COMPLEX_NO),
                
                SSWRITE_VALUE_DTYPE_NUM, "UseConstCoeffsNotInport", &useConstCoeffsNotInport,
                DTINFO(SS_BOOLEAN,COMPLEX_NO)
                ))  {
                return; /* An error occurred which will be reported by Simulink */
            }
        }

        else {
            if (!ssWriteRTWParamSettings(S, 4,
                SSWRITE_VALUE_DTYPE_VECT, "pReCoeffs", pReCoeffs, numCoeffs,
                DTINFO(SS_DOUBLE,COMPLEX_NO),
                
                SSWRITE_VALUE_DTYPE_NUM,  "NumCoeffs", &numCoeffs,
                DTINFO(SS_INT32,COMPLEX_NO),
                
                SSWRITE_VALUE_DTYPE_NUM,  "CoeffsAreComplex", &coeffsAreComplex,
                DTINFO(SS_BOOLEAN,COMPLEX_NO),
                
                SSWRITE_VALUE_DTYPE_NUM, "UseConstCoeffsNotInport", &useConstCoeffsNotInport,
                DTINFO(SS_BOOLEAN,COMPLEX_NO)
                ))  {
                return; /* An error occurred which will be reported by Simulink */
            }
        }
    }
    
    else {
        if (!ssWriteRTWParamSettings(S, 1,
            SSWRITE_VALUE_DTYPE_NUM, "UseConstCoeffsNotInport", &useConstCoeffsNotInport,
            DTINFO(SS_BOOLEAN,COMPLEX_NO)
            ))  {
            return; /* An error occurred which will be reported by Simulink */
        }
    }
}
#endif


#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T iport, int_T iwidth)
{
    ssSetInputPortWidth(S, iport, iwidth);

    /* The output port width MUST match the INPORT1 width.  */
    /* It DOES NOT depend on the INPORT2 width by any means */
    /* (i.e. the INPORT2 width is completely independent).  */
    if (iport == INPORT1) {
        int_T owidth = ssGetOutputPortWidth(S, OUTPORT);

        if (owidth == DYNAMICALLY_SIZED) {
            ssSetOutputPortWidth(S, OUTPORT, iwidth);
        }

        else if (owidth != iwidth) {
            THROW_ERROR(S, "Input port 1 width must equal output width");
        }
    }
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T oport, int_T owidth)
{
    /* The INPORT1 width MUST match the number of outputs. */
    /* The INPORT2 width is completely independent...      */
    int_T inWidth1 = ssGetInputPortWidth(S, INPORT1);

    ssSetOutputPortWidth(S, oport, owidth);

    if (inWidth1 == DYNAMICALLY_SIZED) {
        /* Input port has not yet been set */
        ssSetInputPortWidth(S, INPORT1, owidth);
    }

    else if (inWidth1 != owidth)
        THROW_ERROR(S, "Output port width must equal Input port 1 width");
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S,
					 int_T      portIdx,
					 CSignal_T  iPortComplexSignal)
{
    /* First do what Simulink told us to do... */
    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal);
    
    /* No matter what, if EITHER input ports are complex, then set the   */
    /* output port to be complex (but only if we are allowed to do so).  */
    /* The input ports are independent and there can be one OR two input */
    /* ports depending on block params. The optional second input port   */
    /* contains the coeffs for the polynomial when the const coeff param */
    /* is not to be used.                                                */
    if(iPortComplexSignal == COMPLEX_YES) {
        CheckAndSetOutportComplex(S);
    }
    
    else {
        /* An input port was set to REAL to get into this case. */

        const int_T numInports = ssGetNumInputPorts(S);
        
        if (numInports == 2) {
            if ( (ssGetInputPortComplexSignal(S,INPORT1) == COMPLEX_YES)
                || (ssGetInputPortComplexSignal(S,INPORT2) == COMPLEX_YES) ) {

                CheckAndSetOutportComplex(S);
            }
            
            else if ( (ssGetInputPortComplexSignal(S,INPORT1) == COMPLEX_NO)
                     && (ssGetInputPortComplexSignal(S,INPORT2) == COMPLEX_NO) ) {

                CheckAndSetOutportReal(S);
            }

            /* ELSE all bets are off...not enough information yet to set output port complexity! */
        }

        /* If EITHER input or params are complex, try to set output port to complex */
        else if ( (ssGetInputPortComplexSignal(S,INPORT1) == COMPLEX_YES)
            || mxIsComplex(CONST_COEFFS_ARG) ) {
            
            CheckAndSetOutportComplex(S);
        }

        /* BOTH input and params should be real for this case to occur... */
        else {
            CheckAndSetOutportReal(S);
        }
    }
}


#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S,
					 int_T      portIdx,
					 CSignal_T  oPortComplexSignal)
{
    const int_T numInports = ssGetNumInputPorts(S);
    
    /* First do what Simulink told us to do... */
    ssSetOutputPortComplexSignal(S, portIdx, oPortComplexSignal);

    /* If the output port is real, then the input port(s) must be real. */
    if (oPortComplexSignal == COMPLEX_NO) {
        CheckAndSetInport1Real(S);
        
        if (numInports == 2) {
            CheckAndSetInport2Real(S);
        }
    }
    
    else {
        /* Output was set to COMPLEX, which means either or both inputs should */
        /* be complex. We can't tell which one(s) to set complex unless we     */
        /* already know that one of them is NOT complex. Otherwise, all bets   */
        /* are off since the two input ports are independent!                  */
        if (numInports == 2) {
            if (ssGetInputPortComplexSignal(S,INPORT1) == COMPLEX_NO) {
                CheckAndSetInport2Complex(S);
            }
            
            else if (ssGetInputPortComplexSignal(S,INPORT2) == COMPLEX_NO) {
                CheckAndSetInport1Complex(S);
            }

            /* ELSE all bets are off...not enough information to do anything more here */
        }
        
        else {
            const boolean_T coeffsAreReal = ( !mxIsComplex(CONST_COEFFS_ARG) );
            
            if (coeffsAreReal) {
                CheckAndSetInport1Complex(S);
            }
            
            /* ELSE all bets are off...not enough information to do anything more here */
        }
    }
}


/* ------------------------------------------------------------------------ */
/* SUB-FUNCTION DEFINITIONS (FILE-PRIVATE FCNS) ARE LOCATED BELOW THIS LINE */
/* ------------------------------------------------------------------------ */


static void RealInputsRealCoeffs( SimStruct *S, boolean_T useConstantCoeffs )
{
    /* Real Inputs, Real Coefficients -> Real Outputs */
    real_T            *y    = ssGetOutputPortRealSignal(S,OUTPORT);
    InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,INPORT1);
    const int_T        n    = ssGetInputPortWidth(S,INPORT1);
    real_T             reInputToPower;
    int_T              i;
    int_T              j;
    int_T              a0_Index;

    /* NOTE: pReCoeffs is REQUIRED to point to a contiguous real_T array */
    if (useConstantCoeffs) {
        real_T *pReCoeffs;

        pReCoeffs = mxGetPr(CONST_COEFFS_ARG);
        a0_Index  = mxGetNumberOfElements(CONST_COEFFS_ARG) - 1;
        
        /* Loop through each of the real-valued inputs and compute    */
        /* REAL output. Perform polynomial based on INPUT port size.  */
        for (i = 0; i < n; i++) {
            /* Initial accumulated real result (CONST a0 value) */
            *y = *(pReCoeffs + a0_Index);
            
            /* Reset initial (input^power) value to unity */
            reInputToPower = 1;
            
            /* Loop through each input and assoc coeff beginning with a1 */
            for (j = (a0_Index - 1); j >= 0; j--) {
                reInputToPower = reInputToPower * ( *((real_T *) *uptr) );
                *y += ( *(pReCoeffs + j) * reInputToPower );
            }
            
            /* Increment input and output pointers for next time through loop */
            uptr++;
            y++;
        }
    }
    
    else {
        InputRealPtrsType uptrRealCoeffs = ssGetInputPortRealSignalPtrs(S,INPORT2);

        a0_Index  = ssGetInputPortWidth(S,INPORT2) - 1;
        
        /* Loop through each of the real-valued inputs and compute    */
        /* REAL output. Perform polynomial based on INPUT port size.  */
        for (i = 0; i < n; i++) {
            /* Initial accumulated real result (CONST a0 value) */
            *y = *(*(uptrRealCoeffs + a0_Index));
            
            /* Reset initial (input^power) value to unity */
            reInputToPower = 1;
            
            /* Loop through each input and assoc coeff beginning with a1 */
            for (j = (a0_Index - 1); j >= 0; j--) {
                reInputToPower = reInputToPower * ( *((real_T *) *uptr) );
                *y += ( ( *(*(uptrRealCoeffs + j)) ) * reInputToPower );
            }
            
            /* Increment input and output pointers for next time through loop */
            uptr++;
            y++;
        }
    }
}


static void CmplxInputsRealCoeffs( SimStruct *S, boolean_T useConstantCoeffs )
{
    /* Complex Inputs, Real Coefficients -> Complex Outputs */
    creal_T       *y    = ssGetOutputPortSignal(S,OUTPORT);
    InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT1);
    const int_T    n    = ssGetInputPortWidth(S,INPORT1);
    creal_T        u;
    volatile creal_T cmplxInputToPower;
    int_T          i;
    int_T          j;
    int_T          a0_Index;
    
    /* NOTE: pReCoeffs is REQUIRED to point to a contiguous real_T array */
    if (useConstantCoeffs) {
        real_T *pReCoeffs;
        
        pReCoeffs = mxGetPr(CONST_COEFFS_ARG);
        a0_Index  = mxGetNumberOfElements(CONST_COEFFS_ARG) - 1;
        
        /* Loop through each of the complex-valued inputs and compute */
        /* COMPLEX output. Perform polynomial based on INPUT prt size */
        for (i = 0; i < n; i++) {
            /* Initial accumulated complex result (CONST a0 value) */
            y->re = *(pReCoeffs + a0_Index);
            y->im = 0;
            
            /* Reset initial (input^power) value to unity */
            cmplxInputToPower.re = 1;
            cmplxInputToPower.im = 0;
            
            /* Get next input value and increment input pointer for next time */
            u = *((creal_T *) *uptr++);
            
            /* Loop through each input and assoc coeff beginning with a1 */
            for (j = (a0_Index - 1); j >= 0; j--) {
                volatile real_T reInputProduct;
                volatile real_T imInputProduct;
                
                /* NOTE: Need to use temp variable to not change intermediate */
                /*       value of cmplxInputToPower for this calculation.     */
                reInputProduct = CMULT_RE( cmplxInputToPower, u );
                imInputProduct = CMULT_IM( cmplxInputToPower, u );
                
                cmplxInputToPower.re = reInputProduct;
                cmplxInputToPower.im = imInputProduct;
                
                y->re += ( (*(pReCoeffs + j)) * reInputProduct );
                y->im += ( (*(pReCoeffs + j)) * imInputProduct );
            }
            
            /* Increment output pointer for next time through loop */
            y++;
        }
    }
    
    else {
        InputRealPtrsType uptrRealCoeffs = ssGetInputPortRealSignalPtrs(S,INPORT2);

        a0_Index = ssGetInputPortWidth(S,INPORT2) - 1;
        
        /* Loop through each of the complex-valued inputs and compute */
        /* COMPLEX output. Perform polynomial based on INPUT prt size */
        for (i = 0; i < n; i++) {
            /* Initial accumulated complex result (CONST a0 value) */
            y->re = *(*(uptrRealCoeffs + a0_Index));
            y->im = 0;
            
            /* Reset initial (input^power) value to unity */
            cmplxInputToPower.re = 1;
            cmplxInputToPower.im = 0;
            
            /* Get next input value and increment input pointer for next time */
            u = *((creal_T *) *uptr++);
            
            /* Loop through each input and assoc coeff beginning with a1 */
            for (j = (a0_Index - 1); j >= 0; j--) {
                volatile real_T reInputProduct;
                volatile real_T imInputProduct;
                
                /* NOTE: Need to use temp variable to not change intermediate */
                /*       value of cmplxInputToPower for this calculation.     */
                reInputProduct = CMULT_RE( cmplxInputToPower, u );
                imInputProduct = CMULT_IM( cmplxInputToPower, u );
                
                cmplxInputToPower.re = reInputProduct;
                cmplxInputToPower.im = imInputProduct;
                
                y->re += ( ( *(*(uptrRealCoeffs + j)) ) * reInputProduct );
                y->im += ( ( *(*(uptrRealCoeffs + j)) ) * imInputProduct );
            }
            
            /* Increment output pointer for next time through loop */
            y++;
        }
    }
}


static void RealInputsCmplxCoeffs( SimStruct *S, boolean_T useConstantCoeffs )
{
    /* Real Inputs, Complex Coefficients -> Complex Outputs */
    creal_T           *y    = ssGetOutputPortSignal(S,OUTPORT);
    InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,INPORT1);
    const int_T        n    = ssGetInputPortWidth(S,INPORT1);
    volatile real_T    reInputToPower;
    int_T              i;
    int_T              j;
    int_T              a0_Index;
    
    if (useConstantCoeffs) {
        real_T *pReCoeffs;
        real_T *pImCoeffs;

        pReCoeffs = mxGetPr(CONST_COEFFS_ARG);
        pImCoeffs = mxGetPi(CONST_COEFFS_ARG);
        a0_Index  = mxGetNumberOfElements(CONST_COEFFS_ARG) - 1;
        
        /* Loop through each of the real-valued inputs and compute */
        /* COMPLEX output. Perform polynomial based on INPUT size. */
        for (i = 0; i < n; i++) {
            /* Initial accumulated complex result (CONST a0 value) */
            y->re = *(pReCoeffs + a0_Index);
            y->im = *(pImCoeffs + a0_Index);
            
            /* Reset initial (input^power) value to unity */
            reInputToPower = 1;
            
            /* Loop through each input and assoc coeff beginning with a1 */
            for (j = (a0_Index - 1); j >= 0; j--) {
                reInputToPower = reInputToPower * ( *((real_T *) *uptr) );
                
                y->re += ( (*(pReCoeffs + j)) * reInputToPower );
                y->im += ( (*(pImCoeffs + j)) * reInputToPower );
            }
            
            /* Increment input and output pointers for next time through loop */
            uptr++;
            y++;
        }
    }
    
    else {
        InputPtrsType uptrCmplxCofs = ssGetInputPortSignalPtrs(S,INPORT2);

        a0_Index = ssGetInputPortWidth(S,INPORT2) - 1;
        
        /* Loop through each of the real-valued inputs and compute */
        /* COMPLEX output. Perform polynomial based on INPUT size. */
        for (i = 0; i < n; i++) {
            /* Initial accumulated complex result (CONST a0 value) */
            creal_T *pCmplxX0Coeff;
            
            pCmplxX0Coeff = (creal_T *) *(uptrCmplxCofs + a0_Index);
            
            y->re = (pCmplxX0Coeff->re);
            y->im = (pCmplxX0Coeff->im);
            
            /* Reset initial (input^power) value to unity */
            reInputToPower = 1;
            
            /* Loop through each input and assoc coeff beginning with a1 */
            for (j = (a0_Index - 1); j >= 0; j--) {
                reInputToPower = reInputToPower * ( *((real_T *) *uptr) );
                {
                    creal_T *pCurrentCmplxCoeff;
                    
                    pCurrentCmplxCoeff = (creal_T *) *(uptrCmplxCofs + j);
                    
                    y->re += (pCurrentCmplxCoeff->re) * reInputToPower;
                    y->im += (pCurrentCmplxCoeff->im) * reInputToPower;
                }
            }
            
            /* Increment input and output pointers for next time through loop */
            uptr++;
            y++;
        }
    }
}


static void CmplxInputsCmplxCoeffs( SimStruct *S, boolean_T useConstantCoeffs )
{
    /* Complex Inputs, Complex Coefficients -> Complex Outputs */
    creal_T       *y    = ssGetOutputPortSignal(S,OUTPORT);
    InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT1);
    const int_T    n    = ssGetInputPortWidth(S,INPORT1);
    creal_T        u;
    volatile creal_T cmplxInputToPower;
    int_T          i;
    int_T          j;
    int_T          a0_Index;
        
    if (useConstantCoeffs) {
        real_T *pReCoeffs;
        real_T *pImCoeffs;
        
        pReCoeffs = mxGetPr(CONST_COEFFS_ARG);
        pImCoeffs = mxGetPi(CONST_COEFFS_ARG);
        a0_Index  = mxGetNumberOfElements(CONST_COEFFS_ARG) - 1;
        
        /* Loop through each of the complex-valued inputs and  */
        /* compute COMPLEX output. Perform polynomial based on */
        /* INPUT port size.                                    */
        for (i = 0; i < n; i++) {
            /* Initial accumulated complex result (CONST a0 value) */
            y->re = *(pReCoeffs + a0_Index);
            y->im = *(pImCoeffs + a0_Index);
            
            /* Reset initial (input^power) value to unity */
            cmplxInputToPower.re = 1;
            cmplxInputToPower.im = 0;
            
            /* Get next input value and increment input pointer for next time */
            u = *((creal_T *) *uptr++);
            
            /* Loop through each input and assoc coeff beginning with a1 */
            for (j = (a0_Index - 1); j >= 0; j--) {
                volatile real_T reInputProduct;
                volatile real_T imInputProduct;
                
                /* NOTE: Need to use temp variable to not change intermediate */
                /*       value of cmplxInputToPower for this calculation.     */
                reInputProduct = CMULT_RE( cmplxInputToPower, u );
                imInputProduct = CMULT_IM( cmplxInputToPower, u );
                
                cmplxInputToPower.re = reInputProduct;
                cmplxInputToPower.im = imInputProduct;
                
                y->re += (*(pReCoeffs + j)) * reInputProduct
                    - (*(pImCoeffs + j)) * imInputProduct;
                
                y->im += (*(pReCoeffs + j)) * imInputProduct
                    + (*(pImCoeffs + j)) * reInputProduct;
            }
            
            /* Increment output pointer for next time through loop */
            y++;
        }
    }

    else {
        InputPtrsType uptrCmplxCofs = (InputPtrsType) ssGetInputPortSignalPtrs(S,INPORT2);

        a0_Index = ssGetInputPortWidth(S,INPORT2) - 1;
        
        /* Loop through each of the complex-valued inputs and  */
        /* compute COMPLEX output. Perform polynomial based on */
        /* INPUT port size.                                    */
        for (i = 0; i < n; i++) {
            /* Initial accumulated complex result (CONST a0 value) */
            creal_T *pCmplxX0Coeff;
            
            pCmplxX0Coeff = (creal_T *) *(uptrCmplxCofs + a0_Index);
            
            y->re = (pCmplxX0Coeff->re);
            y->im = (pCmplxX0Coeff->im);
            
            /* Reset initial (input^power) value to unity */
            cmplxInputToPower.re = 1;
            cmplxInputToPower.im = 0;
            
            /* Get next input value and increment input pointer for next time */
            u = *((creal_T *) *uptr++);
            
            /* Loop through each input and assoc coeff beginning with a1 */
            for (j = (a0_Index - 1); j >= 0; j--) {
                volatile real_T reInputProduct;
                volatile real_T imInputProduct;
                
                reInputProduct = CMULT_RE( cmplxInputToPower, u );
                imInputProduct = CMULT_IM( cmplxInputToPower, u );
                
                cmplxInputToPower.re = reInputProduct;
                cmplxInputToPower.im = imInputProduct;
                
                {
                    creal_T *pCurrentCmplxCoeff;
                    creal_T currentCmplxCoeff;
                    
                    pCurrentCmplxCoeff = (creal_T *) *(uptrCmplxCofs + j);
                    
                    currentCmplxCoeff = *pCurrentCmplxCoeff;
                    
                    y->re += CMULT_RE( currentCmplxCoeff, cmplxInputToPower);                
                    y->im += CMULT_IM( currentCmplxCoeff, cmplxInputToPower);
                }
            }
            
            /* Increment output pointer for next time through loop */
            y++;
        }
    }
}


static void CheckAndSetInport1Real( SimStruct *S )
{
    const CSignal_T inport1_Complexity = ssGetInputPortComplexSignal(S,INPORT1);

    if (inport1_Complexity == COMPLEX_INHERITED) {
        ssSetInputPortComplexSignal(S, INPORT1, COMPLEX_NO);
    }
    
    else if (inport1_Complexity == COMPLEX_YES) {
        THROW_ERROR(S,"Inport 1 was complex prior to an attempt to set it to real");
    }
    
    /* ELSE Inport 1 was already set to real -> nothing to do here */
}


static void CheckAndSetInport1Complex( SimStruct *S )
{
    const CSignal_T inport1_Complexity = ssGetInputPortComplexSignal(S,INPORT1);

    if (inport1_Complexity == COMPLEX_INHERITED) {
        ssSetInputPortComplexSignal(S, INPORT1, COMPLEX_YES);
    }
                
    else if (inport1_Complexity == COMPLEX_NO) {
        THROW_ERROR(S,"Inport 1 was real prior to an attempt to set it to complex");
    }
                
    /* ELSE Inport 1 was already set to complex -> nothing to do here */
}


static void CheckAndSetInport2Real( SimStruct *S )
{
    const CSignal_T inport2_Complexity = ssGetInputPortComplexSignal(S,INPORT2);

    if (inport2_Complexity == COMPLEX_INHERITED) {
        ssSetInputPortComplexSignal(S, INPORT2, COMPLEX_NO);
    }
            
    else if (inport2_Complexity == COMPLEX_YES) {
        THROW_ERROR(S,"Inport 2 was complex prior to an attempt to set it to real");
    }
            
    /* ELSE Inport 2 was already set to real -> nothing to do here */
}

            
static void CheckAndSetInport2Complex( SimStruct *S )
{
    const CSignal_T inport2_Complexity = ssGetInputPortComplexSignal(S,INPORT2);

    if (inport2_Complexity == COMPLEX_INHERITED) {
        ssSetInputPortComplexSignal(S, INPORT2, COMPLEX_YES);
    }
                
    else if (inport2_Complexity == COMPLEX_NO) {
        THROW_ERROR(S,"Inport 2 was real prior to an attempt to set it to complex");
    }
                
    /* ELSE Inport 2 was already set to complex -> nothing to do here */
}


static void CheckAndSetOutportComplex( SimStruct *S )
{
    const CSignal_T outputComplexity = ssGetOutputPortComplexSignal(S,OUTPORT);

    if (outputComplexity == COMPLEX_INHERITED) {
        ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_YES);
    }
    
    else if (outputComplexity == COMPLEX_NO) {
        THROW_ERROR(S,"Output port was real prior to attempt to setting it to complex");
    }
    
    /* ELSE Output was already set to complex -> nothing to do here */
}


static void CheckAndSetOutportReal( SimStruct *S )
{
    const CSignal_T outputComplexity = ssGetOutputPortComplexSignal(S,OUTPORT);

    if (outputComplexity == COMPLEX_INHERITED) {
        ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
    }
    
    else if (outputComplexity == COMPLEX_YES) {
        THROW_ERROR(S,"Output port was complex prior to attempt to setting it to real");
    }
    
    /* ELSE Output was already set to real -> nothing to do here */
}


#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
