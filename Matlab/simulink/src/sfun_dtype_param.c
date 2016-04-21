/*
 *   SFUN_DTYPE_PARAM C-MEX S-function example for data typed parameter.
 *
 *
 *   The real purpose of this example is to serve as a very simple 
 *   introduction to the use of simulink data types for parameters.
 *
 *   PORT PROPERTIES:
 *   - The block has one scalar input and one scalar output.
 *   - The block has one scalar parameter. The parameter must be an unsigned 
 *     integer, i.e., uint8, uint16, uint32.
 *   - The input and output port data types are the same as parameter data type.
 *
 *   BLOCK OPERATION:
 *     The nominal operation is as follows:
 *           y0 = p BITWISE_AND u0
 *     where u0 is the input signal, y0 is the output signal, and p is the 
 *     parameter.
 *
 *  Authors: M. Shakeri
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.5.4.3 $  $Date: 2004/04/14 23:49:46 $
 */

/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/
#define S_FUNCTION_NAME  sfun_dtype_param
#define S_FUNCTION_LEVEL 2

/*========================*
g* General Defines/macros *
*========================*/

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h" 

#define TRUE 1
#define FALSE 0

#define ERR_INVALID_PARAM \
  "Invalid parameter. The parameter must be a scalar, unsigned integer number."

/* total number of block parameters */
enum {PARAM = 0, NUM_PARAMS};


#define PARAM_ARG  (ssGetSFcnParam(S, PARAM))

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
    if(EDIT_OK(S, PARAM_ARG)) {
        boolean_T isOk = (mxIsNumeric(PARAM_ARG)  &&  
                          !mxIsLogical(PARAM_ARG) &&
                          !mxIsComplex(PARAM_ARG) &&  
                          !mxIsSparse(PARAM_ARG)  && 
                          !mxIsEmpty(PARAM_ARG)   &&
                          mxGetNumberOfElements(PARAM_ARG) == 1);

        if(isOk){
            /* 
             * Translate the mxClassId of an mxArray to one of Simulink's
             * built-in data type ids. (see simulink.c)
             */
            DTypeId  dtype = ssGetDTypeIdFromMxArray(PARAM_ARG);
            isOk = (dtype == SS_UINT8  || 
                    dtype == SS_UINT16 || 
                    dtype == SS_UINT32);
        }
        if(!isOk){   
            ssSetErrorStatus(S,ERR_INVALID_PARAM);
            return;
        }      
    }
}
#endif 

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    DTypeId dtype = DYNAMICALLY_TYPED;
    /* Set and Check parameter count  */
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

    if(EDIT_OK(S, PARAM_ARG)) {
        dtype = ssGetDTypeIdFromMxArray(PARAM_ARG);
    }

    /* Inputs */
    if(!ssSetNumInputPorts(S, 1)) return;            
    ssSetInputPortWidth(             S, 0, 1 );
    ssSetInputPortDataType(          S, 0, dtype );
    ssSetInputPortDirectFeedThrough( S, 0, TRUE );

    /* outputs */
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(   S, 0, 1);
    ssSetOutputPortDataType(S, 0, dtype);

    /* sample times */
    ssSetNumSampleTimes(S, 1 );
    
    /* options */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE);
    
} /* end mdlInitializeSizes */



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Initialize the sample times array.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime( S, 0, INHERITED_SAMPLE_TIME );
    ssSetOffsetTime( S, 0, FIXED_IN_MINOR_STEP_OFFSET );
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
} /* end mdlInitializeSampleTimes */

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


#define AND_OP(x,y) ((x) & (y))

/* Function: mdlOutputs =======================================================
* Abstract:
*   Compute the outputs of the S-function.
*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* Get "pPtr" for the parameter */
    const void *pPtr = mxGetData(PARAM_ARG);
    /* 
     * Get "uPtrs" for the input port.  
     * uPtrs is essentially a vector of pointers because the input signal may 
     * not be contiguous.  
     */

    InputPtrsType uPtrs = ssGetInputPortSignalPtrs(S,0);
    
    /* 
     * Get data type Identifier for the output port. Note, this matches the 
     * data type ID for the input port.
     */
    DTypeId   yDataType = ssGetOutputPortDataType(S, 0);

    /* This s-function must work for three different data type cases.
     * In essence, three different versions of mdlOutputs are needed.
     * Using the data type ID obtained above, a switch will control
     * which "version" of mdlOutputs is used
     */
    switch (yDataType)
    {
        case SS_UINT8:
            {
            uint8_T            *pY = (uint8_T *)ssGetOutputPortSignal(S,0);
            InputUInt8PtrsType pU  = (InputUInt8PtrsType)uPtrs;
            const  uint8_T    *pP  = (const uint8_T *)pPtr;

            pY[0] = AND_OP(*pU[0],pP[0]);
            break;
        }
        case SS_UINT16:
        {
            uint16_T            *pY = (uint16_T *)ssGetOutputPortSignal(S,0);
            InputUInt16PtrsType pU  = (InputUInt16PtrsType)uPtrs;
            const  uint16_T    *pP  = (const uint16_T *)pPtr;

            pY[0] = AND_OP(*pU[0],pP[0]);
            break;
        }
        case SS_UINT32:
        {
           uint32_T            *pY = (uint32_T *)ssGetOutputPortSignal(S,0);
            InputUInt32PtrsType pU  = (InputUInt32PtrsType)uPtrs;
            const  uint32_T    *pP  = (const uint32_T *)pPtr;

            pY[0] = AND_OP(*pU[0],pP[0]);
            break;
        }
    } /* end switch (y0DataType) */

} /* end mdlOutputs */



/* Function: mdlTerminate =====================================================
* Abstract:
*    Called when the simulation is terminated.
*/
static void mdlTerminate(SimStruct *S)
{
} /* end mdlTerminate */

/*=======================================*
 * Required closing for C MEX S-Function *
 *=======================================*/

#ifdef    MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
# include "simulink.c"     /* MEX-file interface mechanism               */
#else
# include "cg_sfun.h"      /* Code generation registration function      */
#endif


/* [EOF] sfun_dtype_param.c */

