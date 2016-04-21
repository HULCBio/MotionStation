/* $Revision: 1.6 $ */
/*
 * File    : sl_ada_entry.c                                  $ Revision:  $
 * Abstract:
 *      The C-Entry Point for S-Functions written in Ada.
 *
 * Author : Murali Yeddanapudi, 19-May-1999
 *
 * Copyright 1990-2002 The MathWorks, Inc.
 *
 */


/* Required Definitions */

#define   ADA_S_FUNCTION
#define   S_FUNCTION_LEVEL   2

#ifndef S_FUNCTION_NAME
# error "Must Define S_FUNCTION_NAME"
#endif

/* Required headers */

#include "simstruc.h"


/* Function prototypes. The actual functions are in Ada */

#if defined(MDL_CHECK_PARAMETERS)
  extern void mdlCheckParameters(SimStruct *S);
#endif

#if defined(MDL_PROCESS_PARAMETERS)
  extern void mdlProcessParameters(SimStruct *S);
#endif

#if !defined(MDL_INITIALIZE_SIZES)
# error "Must have mdlInitializeSizes"
#else
  extern void mdlInitializeSizes(SimStruct *S);
#endif

#if defined(ADA_MDL_SET_WORK_WIDTHS)
  extern void mdlSetWorkWidths(SimStruct *S);
#endif
#if defined(MDL_START)
  extern void mdlStart(SimStruct *S);
#endif
#if defined(MDL_INITIALIZE_CONDITIONS)
  extern void mdlInitializeConditions(SimStruct *S);
#endif
#if defined(MDL_UPDATE)
  extern void mdlUpdate(SimStruct *S, int_T tid);
#endif
#if defined(MDL_DERIVATIVES)
  extern void mdlDerivatives(SimStruct *S);
#endif
#if defined(MDL_TERMINATE)
  extern void mdlTerminate(SimStruct *S);
#endif


/* Ada initialization and finalization routines, generated using 'gnatbind' */

extern void adainit(); extern void adafinal();

/* User data structure, we allocate one for each instance of this S-Function */

typedef struct LocalData_Tag {

    struct {
        time_T period;
        time_T offset;
    } sampleTime;

    char **parameterNames;
    char **workVectorNames;

} LocalData;


/* Function: __mdlInitializeSizes ==============================================
 * Abstract:
 *      Before calling the mdlInitializeSizes function in the Ada S-Function
 *      we need to make sure that the ada initialization code is executed.
 *      Also register adafinal to be executed when this mex file is unloaded.
 */
static void __mdlInitializeSizes(SimStruct *S)
{
    static bool initializeAda = true;

    if (initializeAda) {
        adainit();
        mexAtExit(adafinal);
        initializeAda = false;
    }

    /*
     * Verify that the parameters passed to this  S-Function are numeric or
     * character arrays. We do not support parameters with the following Matlab
     * objects types:
     *         0) Complex Valed Arrays
     *         1) Sparse Arrays
     *         2) Structures
     *         3) Cell Arrays
     *         4) Vertically concatanated strings (string matrices)
     */
    {
        int_T numParams = ssGetSFcnParamsCount(S);
        int   pIdx;

        ssSetNumSFcnParams(S, numParams);

        for (pIdx = 0; pIdx < numParams; pIdx++) {
            const mxArray *pm = ssGetSFcnParam(S,pIdx);

            if ( mxIsComplex(pm) ||
                 mxIsSparse(pm) ||
                 mxIsStruct(pm) ||
                 mxIsCell(pm) ||
                 (mxIsChar(pm) && (mxGetNumberOfDimensions(pm) > 2 ||
                                   mxGetM(pm) > 1)) ) {
                ssSetErrorStatus(S, "Invalid parameter to Ada S-Function");
                return;
            }
        }
    }

#if defined(MDL_CHECK_PARAMETERS)
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) {
        return;
    }
#endif

    {
        int_T     nPrms = ssGetSFcnParamsCount(S);
        LocalData *ud   = mxCalloc(1, sizeof(LocalData) );

        if (ud == NULL) {
            ssSetErrorStatus(S, "Memory Allocation Error");
            return;
        }
        mexMakeMemoryPersistent(ud);
        ssSetUserData(S,ud);

        if (nPrms > 0) {
            ud->parameterNames = mxCalloc(nPrms, sizeof(char*));
            if (ud->parameterNames == NULL) {
                ssSetErrorStatus(S, "Memory Allocation Error");
                return;
            }
            mexMakeMemoryPersistent(ud->parameterNames);
        }
    }

    mdlInitializeSizes(S);
    if (ssGetErrorStatus(S) != NULL) {
        return;
    }

    /* Require the input ports to be contiguous */
    {
        int_T iPort;

        for (iPort = 0; iPort < ssGetNumInputPorts(S); iPort++) {
            ssSetInputPortRequiredContiguous(S, iPort, 1);
        }
    }

    ssSetOptions(S, ( (ssGetOptions(S)) |
                      SS_OPTION_ADA_S_FUNCTION |
                      SS_OPTION_EXCEPTION_FREE_CODE |
                      SS_OPTION_CALL_TERMINATE_ON_EXIT ));

} /* end: __mdlInitializeSizes */



/* Function: mdlInitializeSampleTimes ==========================================
 * Abstract:
 *      The Ada S-Function sets the sample time in the mdlInitializeSizes
 *      function. Since the sample time fields in the SimStruct are not
 *      allocated at this time, the sample time value set in the Ada code
 *      is written (temporarily) into the S-Function's user data. In this
 *      mdlInitializeSampleTimes function we copy over the sample times set
 *      in the user data into sample time slot in the SimStruct.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    LocalData *ud = ssGetUserData(S);

    if (ud == NULL) {
        ssSetErrorStatus(S, "Invalid User Data");
        return;
    }

    ssSetSampleTime(S, 0, ud->sampleTime.period);
    ssSetOffsetTime(S, 0, ud->sampleTime.offset);

} /* end: mdlInitializeSampleTimes */



/* Function: __mdlSetWorkWidths ================================================
 * Abstract:
 *
 */
#define MDL_SET_WORK_WIDTHS
static void __mdlSetWorkWidths(SimStruct *S)
{
    int_T nPrms = ssGetSFcnParamsCount(S);

#if defined(ADA_MDL_SET_WORK_WIDTHS)
    mdlSetWorkWidths(S);
#endif

    if (nPrms > 0) {
        int_T      i, iRTP;
        LocalData  *ud          = ssGetUserData(S);
        char       **prmNames   = ud->parameterNames;
        char       **rtPrmNames;

        if ( (rtPrmNames = mxMalloc(nPrms*sizeof(char*)))  == NULL ) {
            ssSetErrorStatus(S, "Memory Allocation Error");
            return;
        }
        for (iRTP = i = 0; i < nPrms; i++) {
            if ( !ssGetSFcnParamTunable(S,i) ) {
                continue;
            }
            if (prmNames[i] == NULL) {
                ssSetErrorStatus(S, "All tunable parameters must have a name");
                return;
            }
            rtPrmNames[iRTP++] = prmNames[i];
        }
        ssRegAllTunableParamsAsRunTimeParams(S, rtPrmNames);
        mxFree(rtPrmNames);
    }
}


#if defined(MDL_OUTPUTS)
  extern void mdlOutputs(SimStruct *S, int_T tid);
#else
  /* Function: mdlOutputs ======================================================
   * Abstract:
   *      Empty mdlOutputs function because the ada s-fcn does not have it.
   */
  static void mdlOutputs(SimStruct *S)
  {
  }
#endif /* MDL_OUTPUTS */


/* Function: __adaSFcnDestroyUserData ==========================================
 * Abstract:
 *   Destroy the user data.
 */
static void __adaSFcnDestroyUserData(SimStruct *S)
{
    LocalData *ud = ssGetUserData(S);

    if (ud != NULL) {
        if (ud->parameterNames != NULL) {
            int_T i;
            for (i = 0; i < ssGetSFcnParamsCount(S); i++) {
                if (ud->parameterNames[i] != NULL) {
                    mxFree(ud->parameterNames[i]);
                    ud->parameterNames[i] = NULL;
                }
            }
            mxFree(ud->parameterNames);
        }
        if (ud->workVectorNames != NULL) {
            int_T i;
            for (i = 0; i < ssGetNumDWork(S); i++) {
                char *name = ud->workVectorNames[i];
                if (name != NULL) {
                    mxFree(name);
                    ssSetDWorkName(S,i,NULL);
                    ud->workVectorNames[i] = NULL;
                }
            }
            mxFree(ud->workVectorNames);
        }
        mxFree(ud);
        ssSetUserData(S, NULL);
    }
} /* end: __adaSFcnDestroyUserData */


/* Function: mdlTerminate ======================================================
 * Abstract:
 *      Empty mdlTerminate function because the ada s-fcn does n't have it.
 */
static void __mdlTerminate(SimStruct *S)
{
#if defined(MDL_TERMINATE)
    mdlTerminate(S);
#endif
    /* clean up user data */
    __adaSFcnDestroyUserData(S);

} /* end: __mdlTerminate */


/* Function: mdlRTW ============================================================
 * Abstract:
 *   Write out the non-tunable paramters as param setings.
 */
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    int       i;
    LocalData *ud          = ssGetUserData(S);
    int       nPrms        = ssGetSFcnParamsCount(S);
    char      *strBuffer;
    int       strBufferLen;

    if (nPrms == ssGetNumRunTimeParams(S)) return; /* no param settings */

    if ( (strBuffer=mxMalloc(32*sizeof(char))) == NULL) {
        ssSetErrorStatus(S, "Memory Allocation Error");
        return;
    }
    strBufferLen = 32;

    if ( !ssWriteRTWStr(S, "SFcnParamSettings {") ) {
        ssSetErrorStatus(S," ssWriteRTWStr error in mdlRTW");
        goto EXIT_POINT;
    }

    for (i = 0; i < nPrms; i++) {
        if ( !ssGetSFcnParamTunable(S,i) ) {
            char          *prmName  = ud->parameterNames[i];
            const mxArray *prmVal   = ssGetSFcnParam(S,i);
            int           nRows     = mxGetM(prmVal);
            int           nCols     = mxGetN(prmVal);
            int           nElements = mxGetNumberOfElements(prmVal);

            if (prmName == NULL) {
                char nameBuffer[32];
                (void)sprintf(nameBuffer, "P%d", i);
                prmName = nameBuffer;
            }

            if ( mxIsChar(prmVal) ) {                  /* string param */

                if (strBufferLen <= nElements) {
                    int  newLen  = 2*nElements;
                    char *newBuf = mxRealloc(strBuffer, newLen*sizeof(char));

                    if (newBuf == NULL) {
                        ssSetErrorStatus(S, "Memory Allocation Error");
                        goto EXIT_POINT;
                    }
                    strBuffer    = newBuf;
                    strBufferLen = newLen;
                }
                if ( mxGetString(prmVal,strBuffer,strBufferLen) ) {
                    ssSetErrorStatus(S,"mxGetString error in mdlRTW");
                    goto EXIT_POINT;
                }
                if ( !ssWriteRTWStrParam(S,prmName,strBuffer) ) {
                    ssSetErrorStatus(S,"ssWriteRTWStrParam error in mdlRTW");
                    goto EXIT_POINT;
                }
            } else if (mxIsNumeric(prmVal)) {
                const void *rval   = mxGetData(prmVal);
                DTypeId    dTypeId = ssGetDTypeIdFromMxArray(prmVal);
                int        dtInfo  = DTINFO(dTypeId,0);

                if (nRows == 1 || nCols == 1) {              /* vector param */
                    if ( !ssWriteRTWMxVectParam(S, prmName, rval, NULL,
                                                dtInfo, nElements) ) {
                        ssSetErrorStatus(S,"ssWriteRTWMxVectParam error "
                                         "in mdlRTW");
                        goto EXIT_POINT;
                    }
                } else {                                     /* matrix param */
                    if ( !ssWriteRTWMx2dMatParam(S, prmName, rval, NULL,
                                                 dtInfo, nRows, nCols) ) {
                        ssSetErrorStatus(S,"ssWriteRTWMx2dMatParam error "
                                         "in mdlRTW");
                        goto EXIT_POINT;
                    }
                }
            }
        }
    }
    if ( !ssWriteRTWStr(S, "}") ) {
        goto EXIT_POINT;
    }
 EXIT_POINT:
    mxFree(strBuffer);
    return;

} /* end: mdlRTW */


#include "simulink.c"
#include "simstruc.c"

/* EOF: sl_ada_entry.c */
