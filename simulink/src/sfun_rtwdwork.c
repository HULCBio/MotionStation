/*  File    : rtwdwork.c
 *  Abstract:
 *
 *      Example MEX-file for a block that allows the RTW properties of 
 *      its dwork to be controlled
 *
 *      Syntax:  [sys, x0] = rtwdwork(t,x,u,flag,id,sc,tq)
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.5.4.3 $
 */

#define S_FUNCTION_NAME sfun_rtwdwork
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define ID_IDX 0
#define ID_PARAM(S) ssGetSFcnParam(S,ID_IDX)
 
#define SC_IDX 1
#define SC_PARAM(S) ssGetSFcnParam(S,SC_IDX)
 
#define TQ_IDX 2
#define TQ_PARAM(S) ssGetSFcnParam(S,TQ_IDX)
 
#define NPARAMS 3

#define IS_PARAM_DOUBLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal))
 
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

      if ( !mxIsChar(ID_PARAM(S)) || !IS_PARAM_DOUBLE(SC_PARAM(S)) || !mxIsChar(TQ_PARAM(S))) {
          ssSetErrorStatus(S,"The parameters RTW Identifier and RTW Type Qualifier must be "
                               "strings");
          return;
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
    char *id;
    char *tq;
    int_T sc;

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
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumDWork(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    ssSetDWorkWidth(S, 0, 1);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);

    /* Identifier; free any old setting and update */
    id = ssGetDWorkRTWIdentifier(S, 0);
    if (id != NULL) {
        free(id);
    }
    id = malloc(80);
    mxGetString(ID_PARAM(S), id, 80);
    ssSetDWorkRTWIdentifier(S, 0, id);

    /* Type Qualifier; free any old setting and update */
    tq = ssGetDWorkRTWTypeQualifier(S, 0);
    if (tq != NULL) {
        free(tq);
    }
    tq = malloc(80);
    mxGetString(TQ_PARAM(S), tq, 80);
    ssSetDWorkRTWTypeQualifier(S, 0, tq);

    /* Storage class */
    sc = ((int_T) *((real_T*) mxGetPr(SC_PARAM(S)))) - 1;
    ssSetDWorkRTWStorageClass(S, 0, sc);

    /* Call terminate on exit to free memory for RTW dwork props */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_CALL_TERMINATE_ON_EXIT);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    One sample time, and it's passed in as the fourth S-function parameter
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, 1);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize both continuous states to zero
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x = (real_T*) ssGetDWork(S,0);

    /* 
     * Initialize the dwork to 0
     */
    x[0] = 0.0;
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = x
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *y = ssGetOutputPortRealSignal(S,0);
    real_T *x = (real_T*) ssGetDWork(S,0);

    /* Return the current state as the output */
    y[0] = x[0];
}



#define MDL_UPDATE
/* Function: mdlUpdate ========================================================
 * Abstract:
 *    This function is called once for every major integration time step.
 *    Discrete states are typically updated here, but this function is useful
 *    for performing any tasks that should only take place once per integration
 *    step.
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{
    real_T *x = (real_T*) ssGetDWork(S,0);
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
        
    /*
     * Increment the state by the input 
     */
    x[0] += U(0);
}



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    char* id;
    char* tq;

    /* Identifier; free any old setting and update */
    id = ssGetDWorkRTWIdentifier(S, 0);
    if (id != NULL) {
        free(id);
    }
    ssSetDWorkRTWIdentifier(S, 0, NULL);

    /* Type Qualifier; free any old setting and update */
    tq = ssGetDWorkRTWTypeQualifier(S, 0);
    if (tq != NULL) {
        free(tq);
    }
    ssSetDWorkRTWTypeQualifier(S, 0, NULL);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif





