/*  File    : sftable2.c
 *  Abstract:
 *
 *      A two dimensional table lookup in S-Function form.
 *
 *      Syntax:  [sys, x0] = sftable2(t,x,u,flag, XINDEX, Y_INDEX, TABLE)
 *
 *      This file is designed to be used in a Simulink S-Function block.
 *      It performs a 2-D lookup on the table passed in through the
 *      parameter list.  It makes use of the variables XINDEX, YINDEX,
 *      TABLE, XO, and YO, where the first three of these are passed in
 *      through the parameter list, and the last two, XO and YO, are
 *      passed in as the inputs, respectively u(1) and u(2).
 *
 *      The section of code in the mdlOutputs function returns a linearly
 *      interpolated intersection from the array TABLE, looking up X0
 *      first with the vector XINDEX, then looking up Y0 with the vector
 *      YINDEX.  The matrix TABLE has entries that correspond to the
 *      X and Y indices and therefore must have the same number of rows as the
 *      vector XINDEX and the same number of columns as the vector
 *      YINDEX.  TABLE contains the output values to be interpolated among.
 *
 *      Both XINDEX and YINDEX must increase monotonically.
 *      Extrapolation is used for values outside the limits of XINDEX
 *      and YINDEX based on the four closest points.
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.11.4.3 $
 */

#define S_FUNCTION_NAME sftable2
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define XINDEX_IDX 0
#define XINDEX_PARAM(S) ssGetSFcnParam(S,XINDEX_IDX)
 
#define YINDEX_IDX 1
#define YINDEX_PARAM(S) ssGetSFcnParam(S,YINDEX_IDX)
 
#define TABLE_IDX 2
#define TABLE_PARAM(S) ssGetSFcnParam(S,TABLE_IDX)
 
#define NPARAMS 3


/*====================*
 * S-function methods *
 *====================*/
 
#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlCheckParameters =============================================
 * Abstract:
 *    Validate our parameters to verify they are okay.
 */
static void mdlCheckParameters(SimStruct *S)
{
    /* Check 1st parameter: X-Index (XINDEX) parameter */
    {
        if (!mxIsDouble(XINDEX_PARAM(S)) ||
            ((mxGetM(XINDEX_PARAM(S)) > 1) &&
             (mxGetN(XINDEX_PARAM(S)) > 1))) {
            ssSetErrorStatus(S,"1st parameter to S-function must be either "
                             "a double scalar or vector \"X-Index\" which "
                             "is the X-Index into the lookup table");
            return;
        }
    }
 
    /* Check 2nd parameter: Y-Index (YINDEX) parameter */
    {
        if (!mxIsDouble(YINDEX_PARAM(S)) ||
            ((mxGetM(YINDEX_PARAM(S)) > 1) &&
             (mxGetN(YINDEX_PARAM(S)) > 1))) {
            ssSetErrorStatus(S,"2nd parameter to S-function must be either "
                             "a double scalar or vector \"Y-Index\" which "
                             "is the Y-Index into the lookup table");
            return;
        }
    }
    
    /* Check 3rd parameter: Y-Index (TABLE) parameter */
    {
        if (!mxIsDouble(TABLE_PARAM(S))) {
            ssSetErrorStatus(S,"3rd parameter to S-function must be "
                             "a double matrix \"Table\" which contains "
                             "the output values of the lookup table");
            return;
        }
    }
}
#endif /* MDL_CHECK_PARAMETERS */
 


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
        }
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 2);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = f(U1(XINDEX),U2(YINDEX))
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T            *y    = ssGetOutputPortRealSignal(S,0);
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);

    const real_T *xIndex = mxGetPr(XINDEX_PARAM(S));
    const real_T *yIndex = mxGetPr(YINDEX_PARAM(S));
    const real_T *table  = mxGetPr(TABLE_PARAM(S));
    
#define NUMEL(m)    mxGetM(m)*mxGetN(m)
    int_T xIndexLen = NUMEL(XINDEX_PARAM(S));
    int_T yIndexLen = NUMEL(YINDEX_PARAM(S));
#undef NUMEL
    
    real_T x0, y0;
    real_T xLo, xHi, yLo, yHi;
    real_T zxLoyLo, zxLoyHi, zxHiyLo, zxHiyHi;
    real_T xRatio, zx0yLo, zx0yHi;
    int_T  i, xPtrLo, xPtrHi, yPtrLo, yPtrHi;
    
    UNUSED_ARG(tid); /* not used in single tasking mode */

    /* Perform the desired 2-D table lookup */
    x0 = U(0);
    for (i = 0; (i < xIndexLen) && (xIndex[i] < x0); i++) {
        ;
    }
 
    /*
     * if i is equal to the length of the xIndex array, then x0 is less
     * than all values in xIndex, use the last two points in xIndex
     * else if i is zero, x0 is greater than all values in xIndex,
     * use the first two points in xIndex. If the index is a scalar
     * handle that as a special case of a 1-d look-up table
     */
 
    if ((i == xIndexLen) && (xIndexLen != 1)) {
        xPtrLo = xIndexLen - 2;
        xPtrHi = xIndexLen - 1;
    } else if ((i == 0) && (xIndexLen != 1)) {
        xPtrLo = 0;
        xPtrHi = 1;
    } else if (xIndexLen == 1) {
        xPtrLo = 0;
        xPtrHi = 0;
    }  else {
        xPtrLo = i - 1;
        xPtrHi = i;
    }
 
    xLo = xIndex[xPtrLo];
    xHi = xIndex[xPtrHi];
 
    /* Now repeat the process for yIndex */
    y0 = U(1);
    for (i = 0; (i < yIndexLen) && (yIndex[i] < y0); i++) {
        ;
    }
 
    /*
     * if i is equal to the length of the yIndex array, then y0 is less
     * than all values in yIndex, use the last two points in yIndex
     * else if i is zero, y0 is greater than all values in yIndex,
     * use the first two points in yIndex.
     */
 
 
    if ((i == yIndexLen) && (yIndexLen != 1)) {
        yPtrLo = yIndexLen - 2;
        yPtrHi = yIndexLen - 1;
    } else if ((i == 0) && (yIndexLen != 1)) {
        yPtrLo = 0;
        yPtrHi = 1;
    } else if (yIndexLen == 1) {
        yPtrLo = 0;
        yPtrHi = 0;
    } else {
        yPtrLo = i - 1;
        yPtrHi = i;
    }
 
    yLo = yIndex[yPtrLo];
    yHi = yIndex[yPtrHi];
 
    /* Find the four z values on the table that bracket (x0,y0) */
    zxLoyLo = table[xPtrLo + yPtrLo*xIndexLen];
    zxLoyHi = table[xPtrLo + yPtrHi*xIndexLen];
    zxHiyLo = table[xPtrHi + yPtrLo*xIndexLen];
    zxHiyHi = table[xPtrHi + yPtrHi*xIndexLen];
 
    /*
     * Now interpolate to find the desired answer
     * First the intermediate step at "yLo"
     * Calculate xRatio only once, as it is used twice below.
     * Avoid divide by zero caused by scalar case of xIndex
     */
 
    if (xHi-xLo != 0) {
        xRatio = (x0-xLo)/(xHi-xLo);
    } else {
        xRatio = (x0-xLo);
    }
    zx0yLo = xRatio*(zxHiyLo-zxLoyLo) + zxLoyLo;
 
    /* then the intermediate value at "yHi" */
    zx0yHi = xRatio*(zxHiyHi-zxLoyHi) + zxLoyHi;
 
    /*
     * Finally, interpolate to find the value at (x0,y0)
     * Where y[0] = zx0y0, the desired interpolated value .
     * Avoid divide by zero caused by scalar indeces
     */
 
    if (yHi-yLo != 0) {
        y[0] = (y0-yLo)/(yHi-yLo)*(zx0yHi-zx0yLo) + zx0yLo;
    } else {
        y[0] = (y0-yLo) * (zx0yHi-zx0yLo) + zx0yLo;
    }
}



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
