/*
 * SFUN_MATADD matrix support example. 
 *   C-MEX S-function for matrix add with one input port, one output port and 
 *   one parameter.
 *
 *  Input Signal:  2-D array
 *  Parameter:     2-D array
 *  Output Signal: 2-D array
 *
 *  Input        parameter     output
 *  --------------------------------
 *  scalar       scalar        scalar
 *  scalar       matrix        matrix     (input scalar expansion)
 *  matrix       scalar        matrix     (parameter scalar expansion)
 *  matrix       matrix        matrix
 *
 *  Author: M. Shakeri
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.5.4.3 $  $Date: 2004/04/14 23:49:58 $
 */
#define S_FUNCTION_NAME  sfun_matadd
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
        /* Non-empty, real 2-D array (matrix) */
        if( mxIsEmpty(PARAM_ARG)     ||  !IsRealMatrix(PARAM_ARG)){
            ssSetErrorStatus(S, "Invalid parameter specified. The parameter "
                             "must be a non-empty real 2-D array (matrix).");
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
    if (!ssSetNumInputPorts( S,1)) return;
    if (!ssSetNumOutputPorts(S,1)) return;

    {
        int_T pWidth = mxGetNumberOfElements(PARAM_ARG);
        /* Input can be a scalar or a matrix signal. */
        if(!ssSetInputPortDimensionInfo( S, 0, DYNAMIC_DIMENSION)) return;

        if( pWidth == 1) { 
            /* Scalar parameter: output dimensions are unknown. */
            if(!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
        }else{
            /* 
             * Non-scalar parameter: output dimensions are the same as 
             * the parameter dimensions.
             */
            int_T m = mxGetM(PARAM_ARG);
            int_T n = mxGetN(PARAM_ARG);
            if(!ssSetOutputPortMatrixDimensions(S, 0, m, n)) return;
        }
    }
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE);
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

/* Function: mdlOutputs =======================================================
 * Abstract:
 *   Compute the outputs of the S-function.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtr   = ssGetInputPortRealSignalPtrs(S,0);  
    real_T            *y     = ssGetOutputPortRealSignal(S,0);
    const real_T      *p     = mxGetPr(PARAM_ARG);          

    int_T             uWidth = ssGetInputPortWidth(S,0);
    int_T             pWidth = mxGetNumberOfElements(PARAM_ARG);
    int_T             yWidth = ssGetOutputPortWidth(S,0);
    int               i;

    UNUSED_ARG(tid); /* not used in single tasking mode */

    /* 
     * Note1: Matrix signals are stored in column major order.
     * Note2: Access each matrix element by one index not two indices.
     *        For example, if the output signal is a [2x2] matrix signal,
     *        -          - 
     *       | y[0]  y[2] |
     *       | y[1]  y[3] |
     *       -           -
     *       Output elements are stored as follows:
     *           y[0] --> row = 0, col = 0
     *           y[1] --> row = 1, col = 0
     *           y[2] --> row = 0, col = 1
     *           y[3] --> row = 1, col = 1
     */
       
    for (i = 0; i < yWidth; i++) {
        int_T uIdx = (uWidth == 1) ? 0 : i;
        int_T pIdx = (pWidth == 1) ? 0 : i;
        
        y[i] = *uPtr[uIdx] + p[pIdx];
    } 
} /* end mdlOutputs */


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
/* Function: mdlSetInputPortDimensionInfo ====================================
 * Abstract:
 *    This routine is called with the candidate dimensions for an input port
 *    with unknown dimensions. If the proposed dimensions are acceptable, the 
 *    routine should go ahead and set the actual port dimensions.  
 *    If they are unacceptable an error should be generated via 
 *    ssSetErrorStatus.  
 *    Note that any other input or output ports whose dimensions are 
 *    implicitly defined by virtue of knowing the dimensions of the given port 
 *    can also have their dimensions set.
 */
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *dimsInfo)
{
    int_T  pWidth   = mxGetNumberOfElements(PARAM_ARG);
    int_T  pM       = mxGetM(PARAM_ARG);
    int_T  pN       = mxGetN(PARAM_ARG);

    int_T  uNumDims = dimsInfo->numDims;
    int_T  uWidth   = dimsInfo->width;
    int_T  *uDims   = dimsInfo->dims;

    boolean_T  isOk = true;
    
    /* Set input port dimension */
    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    /* 
     * The block only accepts 2-D signals. Check number of dimensions. 
     * If the parameter and the input signal are non-scalar, their dimensions
     * must be the same.
     */
    isOk = (uNumDims == 2) && (pWidth == 1 || uWidth == 1 || pWidth == uWidth);
    if(isOk && pWidth > 1 && uWidth > 1){
        isOk = (pM == uDims[0]) &&(pN == uDims[1]);
    }

    if(!isOk){
        ssSetErrorStatus(S, "Invalid input port dimensions. The input must be "
                         "a 2-D scalar signal, or it must be a matrix with the "
                         "same dimensions as the parameter dimensions.");
        return;
    }else{
        /* Set the output port dimensions */
        int_T yM = (pWidth > 1) ? pM : uDims[0];
        int_T yN = (pWidth > 1) ? pN : uDims[1];
        if(!ssSetOutputPortMatrixDimensions(S, port, yM, yN)) return;
    }
}

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
/* Function: mdlSetOutputPortDimensionInfo ===================================
 * Abstract:
 *    This routine is called with the candidate dimensions for an output port 
 *    with unknown dimensions. If the proposed dimensions are acceptable, the 
 *    routine should go ahead and set the actual port dimensions.  
 *    If they are unacceptable an error should be generated via 
 *    ssSetErrorStatus.  
 *    Note that any other input or output ports whose dimensions are  
 *    implicitly defined by virtue of knowing the dimensions of the given 
 *    port can also have their dimensions set.
 */
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *dimsInfo)
{
    /*
     * If the block has scalar parameter, the output dimensions are unknown.
     * Set the input and output port to have the same dimensions.
     */
    if(!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;

    /* The block only accepts 2-D signals. Check number of dimensions. */
    if(dimsInfo->numDims != 2){
        ssSetErrorStatus(S, "Invalid output port dimensions. The output signal "
                         "must be a 2-D array (matrix) signal.");
        return;
    }else{
        /* Set the input port dimensions */
        if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
    }
}

# define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
/* Function: mdlSetDefaultPortDimensionInfo ====================================
 *    This routine is called when Simulink is not able to find dimension
 *    candidates for ports with unknown dimensions. This function must set the
 *    dimensions of all ports with unknown dimensions.
 */
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    int_T outWidth = ssGetOutputPortWidth(S, 0);
    /* Input port dimension must be unknown. Set it to scalar. */
    if(!ssSetInputPortMatrixDimensions(S, 0, 1, 1)) return;
    if(outWidth == DYNAMICALLY_SIZED){
        /* Output dimensions are unknown. Set it to scalar. */
        if(!ssSetOutputPortMatrixDimensions(S, 0, 1, 1)) return;
    }
}
#endif


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    Called when the simulation is terminated.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */

} /* end mdlTerminate */

#ifdef	MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* [EOF] sfun_matadd.c */
