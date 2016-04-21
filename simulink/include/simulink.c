/* Copyright 1990-2003 The MathWorks, Inc.
 *
 * File    : simulink.c                                  $Revision: 1.89.4.8 $
 * Abstract:
 *      Epilog C include file used when compiling MEX-file S-functions.
 *
 *      This file should be included at the end of a MEX-file system.  It
 *      provides an interface to the MEX-file mechanism that allows blocks
 *      and systems to be entered only as their corresponding mathematical
 *      functions without the need for addition interface code
 *
 *      All local functions and defines begin with an underscore "_" to help
 *      in avoiding name conflicts with user functions and defines.
 *
 *      This file supports both level 1 and level 2 S-functions.
 */

#undef   printf   /* don't want to redefine mexPrintf! */
#include <stdio.h>

/*LINTLIBRARY*/

/*==============================*
 * Pre-processor error checking *
 *==============================*/

#ifndef S_FUNCTION_NAME
#error S_FUNCTION_NAME must be defined
#endif

#if defined(_S_FUNCTION_NAME_NOT_DEFINED_BEFORE_SIMSTRUCT)
#error S_FUNCTION_NAME must be defined before include of simstruc.h
#endif

#if S_FUNCTION_LEVEL == 2
# if defined(MDL_GET_INPUT_PORT_WIDTH)
#   error mdlGetInputPortWidth(S,outputWidth) cannot be used in \
        level 2 S-functions see mdlSetInputPortWidth(S,port,width) and \
        mdlSetOutputPortWidth(S,port,width)
# endif
# if defined(MDL_GET_OUTPUT_PORT_WIDTH)
#   error mdlGetOutputPortWidth(S,inputWidth) cannot be used in \
        level 2 S-functions see mdlSetInputPortWidth(S,port,width) and \
        mdlSetOutputPortWidth(S,port,width)
# endif


# if (defined(MDL_SET_INPUT_PORT_WIDTH) || \
      defined(MDL_SET_OUTPUT_PORT_WIDTH)) && \
     (defined(MDL_SET_INPUT_PORT_DIMENSION_INFO) || \
      defined(MDL_SET_OUTPUT_PORT_DIMENSION_INFO))
#   error Cannot use mdlSetInput(Output)PortWidth \
and mdlSetInput(Output)PortDimensionInfo at the same time in an S-function; \
Use either a width or dimension method, but not both

#endif
#endif

/*=========*
 * Defines *
 *=========*/

#define _QUOTE1(name) #name
#define _QUOTE(name) _QUOTE1(name)   /* need to expand name */


#define _LHS_RET    0    /* return (sizes, derivs, dstates, output, tnext)   */
#define _LHS_X0     1    /* initial state conditions                         */
#define _LHS_STR    2    /* state strings                                    */
#define _LHS_TS     3    /* sample times (sampling period, offset)           */
#define _LHS_XTS    4    /* state sample times (sampling period, offset)     */

#define _LHS_SS     1    /* Pointer to SimStruct if (nlhs < 0)               */

#define _RHS_T      0    /* Time                                             */
#define _RHS_X      1    /* States                                           */
#define _RHS_U      2    /* Inputs                                           */
#define _RHS_FLAG   3    /* mode flag                                        */


#define _GetNumEl(pm) (mxGetM(pm)*mxGetN(pm))


/*===========================*
 * Data local to this module *
 *===========================*/

static char_T _sfcnName[] = "MEX level" _QUOTE(S_FUNCTION_LEVEL) 
     " S-function \"" _QUOTE(S_FUNCTION_NAME) "\"";


const DimsInfo_T DYNAMIC_DIMENSION_DEF = {-1, -1, NULL, NULL}; 
const DimsInfo_T *DYNAMIC_DIMENSION    = &DYNAMIC_DIMENSION_DEF;

/*===================*
 * Private functions *
 *===================*/


#ifndef MDL_ZERO_CROSSINGS
  /* Function: mdlZeroCrossings ===============================================
   * Abstract:
   *    This routine is present for S-functions which register that they
   *    have nonsampled zero crossings, but don't register this routine.
   */
  static void mdlZeroCrossings(SimStruct *S)
  {
      ssSetErrorStatus(S,
                       "To have nonsampled zero crossings, you must define "
                       "MDL_ZERO_CROSSINGS and have a "
                       "mdlZeroCrossings routine");
      return;
  }
#endif


#ifndef MDL_GET_TIME_OF_NEXT_VAR_HIT
  /* Function: mdlGetTimeOfNextVarHit =========================================
   * Abstract:
   *    This routine is present for backwards compatibility with
   *    Simulink 1.3 S-function which didn't have mdlGetTimeOfNextVarHit
   */
  static void mdlGetTimeOfNextVarHit(SimStruct *S)
  {
      ssSetErrorStatus(S,
                       "To have a variable sample time, "
                       "you must define MDL_GET_TIME_OF_NEXT_VAR_HIT "
                       "and add a mdlGetTimeOfNextVarHit routine");
      return;
  } /* end mdlGetTimeOfNextVarHit */
#endif


#if S_FUNCTION_LEVEL==2
/* Function: _RegNumInputPortsCB ==============================================
 * Abstract:
 *      Called by a level 2 S-function during mdlInitializeSizes.
 *
 * Returns:
 *      1  - register was successful
 *      0 - register was not successful
 */
static int_T _RegNumInputPortsCB(void *Sptr, int_T nInputPorts) {
    SimStruct *S = (SimStruct *)Sptr;

    if (nInputPorts < 0) {
        return(0);
    }

    _ssSetNumInputPorts(S,nInputPorts);
    _ssSetSfcnUsesNumPorts(S, 1);

    if (nInputPorts > 0) {
        ssSetPortInfoForInputs(S,
           (struct _ssPortInputs*)mxCalloc((size_t)nInputPorts,
                                           sizeof(struct _ssPortInputs)));
    }

    return(1);

} /* end _RegNumInputPortsCB */



/* Function: _RegNumOutputPortsCB =============================================
 * Abstract:
 *      Called by a level 2 S-function during mdlInitializeSizes.
 *
 * Returns:
 *      1  - register was successful
 *      0 - register was not successful
 */
static int_T _RegNumOutputPortsCB(void *Sptr, int_T nOutputPorts) {
    SimStruct *S = (SimStruct *)Sptr;

    if (nOutputPorts < 0) {
        return(0);
    }

    _ssSetNumOutputPorts(S,nOutputPorts);
    _ssSetSfcnUsesNumPorts(S, 1);

    if (nOutputPorts > 0) {
        ssSetPortInfoForOutputs(S,
            (struct _ssPortOutputs*)mxCalloc((size_t)nOutputPorts,
                                             sizeof(struct _ssPortOutputs)));
    }

    return(1);

} /* end _RegNumOutputPortsCB */

/* Function:  _ssSetInputPortMatrixDimensions ===================================
 * Returns:
 *      1 - set was successful
 *      0 - set was not successful
 */
int_T _ssSetInputPortMatrixDimensions(SimStruct *S, int_T port, int_T m, int_T n)
{   
    int_T      status;
    DimsInfo_T dimsInfo = *DYNAMIC_DIMENSION;
    int_T      dims[2];
    
    dims[0]            = m;
    dims[1]            = n;
    
    dimsInfo.numDims   = 2;
    dimsInfo.dims      = dims;
    dimsInfo.width     = ((m == DYNAMICALLY_SIZED) || (n == DYNAMICALLY_SIZED))?
                           DYNAMICALLY_SIZED : (m * n);
  
    status = ssSetInputPortDimensionInfo(S, port, &dimsInfo);

    return(status);
} /* end _ssSetInputPortMatrixDimensions */


/* Function:  _ssSetOutputPortMatrixDimensions ====================================
 * Returns:
 *      1 - set was successful
 *      0 - set was not successful
 */
int_T _ssSetOutputPortMatrixDimensions(SimStruct *S, int_T port, int_T m, int_T n)
{   
    int_T      status;
    DimsInfo_T dimsInfo = *DYNAMIC_DIMENSION;
    int_T      dims[2];

    dims[0]            = m;
    dims[1]            = n;

    dimsInfo.numDims   = 2;
    dimsInfo.dims      = dims;
    dimsInfo.width     = ((m == DYNAMICALLY_SIZED) || (n == DYNAMICALLY_SIZED))?
                           DYNAMICALLY_SIZED : (m * n);

    status = ssSetOutputPortDimensionInfo(S, port, &dimsInfo);

    return(status);
} /* end _ssSetOutputPortMatrixDimensions */

/* Function:  _ssSetInputPortVectorDimension ====================================
 * Returns:
 *      1 - set was successful
 *      0 - set was not successful
 */
int_T _ssSetInputPortVectorDimension(SimStruct *S, int_T port, int_T m)
{   
    int_T      status;
    DimsInfo_T dimsInfo = *DYNAMIC_DIMENSION;
    
    dimsInfo.numDims   = 1;
    dimsInfo.dims      = &(dimsInfo.width);
    dimsInfo.width     = m;
  
    status = ssSetInputPortDimensionInfo(S, port, &dimsInfo);

    return(status);
} /* end _ssSetInputPortVectorDimension */


/* Function:  _ssSetOutputPortVectorDimension ====================================
 * Returns:
 *      1 - set was successful
 *      0 - set was not successful
 */
int_T _ssSetOutputPortVectorDimension(SimStruct *S, int_T port, int_T m)
{   
    int_T      status;
    DimsInfo_T dimsInfo = *DYNAMIC_DIMENSION;
    
    dimsInfo.numDims   = 1;
    dimsInfo.dims      = &(dimsInfo.width);
    dimsInfo.width     = m;

    status = ssSetOutputPortDimensionInfo(S, port, &dimsInfo);

    return(status);
} /* end _ssSetOutputPortVectorDimension */


/* Function:  ssIsRunTimeParamTunable ==========================================
 * Returns:
 *      1 - if tunable
 *      0 - otherwise
 */
int_T ssIsRunTimeParamTunable(SimStruct *S, const int_T rtPIdx)
{
    int_T result = 0;

    _ssIsRunTimeParamTunable(S,rtPIdx,&result);
    return(result);
} /* end _ssSetOutputPortVectorDimension */


/* Function:  ssGetSFuncBlockHandle ============================================
 * Returns:
 *      A double - the handle to the owner block.
 */
double ssGetSFuncBlockHandle(SimStruct *S)
{
    double result = 0;

    _ssGetSFuncBlockHandle(S, &result);
    return(result);
} /* end _ssSetOutputPortVectorDimension */


#endif



/* Function: _CreateSimStruct =================================================
 * Abstract:
 *      Allocate the simulation structure.
 */
#ifdef V4_COMPAT /* Use MATLAB 4 prototyping */
static SimStruct *_CreateSimStruct(int_T nrhs, Matrix *prhs[])
#else
static SimStruct *_CreateSimStruct(int_T nrhs, const mxArray *prhs[])
#endif /* V4_COMPAT */
{
    int_T               nParams  = (nrhs > 4)? nrhs - 4: 0;
    SimStruct         *S       = (SimStruct *) mxCalloc((size_t)1,
                                                        sizeof(SimStruct));
    struct _ssMdlInfo *mdlInfo = 
        (struct _ssMdlInfo*) mxCalloc((size_t)1,sizeof(*mdlInfo));


    _ssSetRootSS(S, S);
    _ssSetMdlInfoPtr(S, mdlInfo);
    _ssSetSimMode(S, SS_SIMMODE_SIZES_CALL_ONLY);
    _ssSetSFcnParamsCount(S,nParams);

    _ssSetPath(S,_QUOTE(S_FUNCTION_NAME));
    _ssSetModelName(S,_QUOTE(S_FUNCTION_NAME));

    if (nParams > 0) {
        /******************************
         * Load S-function parameters *
         ******************************/
        mxArray **ppa = (mxArray**)mxCalloc((size_t)nParams, sizeof(ppa[0]));
        int_T           i;

        _ssSetSFcnParamsPtr(S, ppa);

        for (i = 0; i < nParams; i++) _ssSetSFcnParam(S, i, (mxArray *)(prhs[4+i]));
    }

    /*
     * Setup to handle level 2, ssSetNum[Out|In]putPorts.
     */
#   if S_FUNCTION_LEVEL == 2
    ssSetRegNumInputPortsFcn(S, _RegNumInputPortsCB);
    ssSetRegNumInputPortsFcnArg(S, (void *)S);
    ssSetRegNumOutputPortsFcn(S, _RegNumOutputPortsCB);
    ssSetRegNumOutputPortsFcnArg(S, (void *)S);
#   endif

    return(S);

} /* end _CreateSimStruct */


/*==================*
 * Global functions *
 *==================*/


/* Function: ssWarning ========================================================
 * Abstract:
 *	Call mexWarnMstTxt to issue the specified warning message
 */
void ssWarning(SimStruct *S, const char *msg)
{
    const char fmt[] = "block '%s': %s";
    char *warnMsg = (ssGetPath(S) != NULL?
                     (char *)malloc(strlen(msg)+
                                    sizeof(fmt)+strlen(ssGetPath(S))+1):
                     NULL);
    if (warnMsg == NULL) {
        mexWarnMsgTxt(msg);
    } else {
        (void)sprintf(warnMsg,fmt,ssGetPath(S),msg);
        mexWarnMsgTxt(warnMsg);
        free(warnMsg);
    }
} /* end ssWarning */


#if S_FUNCTION_LEVEL == 1 && !defined(NDEBUG)
const char _ssBadLevel1UAccessMsg[] = 
"S-function '%s' in block '%s' is about to "
"access its input signal in either mdlOutput() or "
"mdlGetTimeOfNextVarHit(). This is not permitted because "
"this S-function did not register in its mdlInitializeSizes() "
"that it has has direct feedthrough using "
"ssSetDirectFeedThrough(S,1). Please "
"update the S-function to have direct feedthrough or "
"remove the calls to ssGetU()/ssGetUPtrs() in mdlOutputs() and "
"mdlGetTimeOfNextVarHit(). Illegally accessing the input "
"will cause a segmentation violation by dereferencing the NULL pointer.\n";
#endif

#if S_FUNCTION_LEVEL == 2 && !defined(NDEBUG)

const char _ssBadLevel2InputAccessMsg[] = 
  "S-function '%s' in block '%s' is attempting to access the signal from "
  "input port '%d' in one its methods. However, the S-function's "
  "mdlInitializeSizes routine has configured the block to have only "
  "%d input port(s). The incorrect access will cause a segmentation violation. "
  "Please verify that all calls to ssGetInputPort[Real]Signal[Ptrs]() are using "
  "port indices in the range [0..%d].\n";

const char _ssBadLevel2DirectFeedMsg[] = 
  "S-function '%s' in block '%s' is setting or clearing the direct feedthrough "
  "flag for port %d. However, the S-function's "
  "mdlInitializeSizes routine has configured the block to have only "
  "%d input port(s). Setting of clearing the direct feedthrough flag for an " 
  "invalid port index will cause a segmentation violation. Please verify that "
  "all calls to ssSetInputPortDirectFeedThrough are using port indices in the range "
  "[0..%d].\n";

const char _ssBadLevel2ZeroDirectFeedMsg[] = 
  "S-function '%s' in block '%s' is attempting to access the signal from "
  "input port '%d' in one its methods. However, the S-function's "
  "mdlInitializeSizes routine did not register the ssSetInputPortDirectFeedThrough "
  "macro or the direct feedthrough flag has been set to zero. This will cause a "
  "segmentation violation. Please verify that the ssSetInputPortDirectFeedThrough "
  "is declared in mdlInitializeSizes and the direct feedthrough flag is set to "
  "one when accessing the input port signals in the mdlOutputs and/or "
  "mdlGetTimeOfNextVarHit method(s).";
#endif

/* Function: _ssFatalError =====================================================
 * Abstract:
 *   Display a fatal error modal dialog.
 */
#if !defined(NDEBUG)
static void _ssFatalError(const SimStruct *S, char *NagMsg)
{

    mxArray *prhs[3];
    mxArray *msgs   = NULL;
    mxArray *title = mxCreateString("Fatal Error");
    mxArray *mode  = mxCreateString("modal");
    msgs   = mxCreateString(NagMsg);
    prhs[0] = msgs;
    prhs[1] = title;
    prhs[2] = mode;

    mexCallMATLAB(0, NULL, sizeof(prhs)/sizeof(prhs[0]), prhs, "errordlg");

    UNUSED_PARAMETER(S);

}
#endif

/* Function: _ssGetUFcn ========================================================
 * Abstract:
 *   Return the input signal for level 1 s-functions. Also detect 
 *   illegal input signal access.
 */
#if S_FUNCTION_LEVEL == 1 && !defined(NDEBUG)
void *_ssGetUFcn(const SimStruct *S)
{
    if (S->states.U.vect == NULL) {
        mexPrintf(_ssBadLevel1UAccessMsg,
                  ssGetPath(S), ssGetModelName(S));
    }

    return(S->states.U.vect);  

} /* end _ssGetUFcn */
#endif


/* Function: _ssGetUPtrsFcn ====================================================
 * Abstract:
 *   Return the input signal for level 1 s-functions. Also detect 
 *   illegal input signal access.
 */
#if S_FUNCTION_LEVEL == 1 && !defined(NDEBUG)
UPtrsType _ssGetUPtrsFcn(const SimStruct *S)
{
 if (S->states.U.uPtrs == NULL) {
        mexPrintf(_ssBadLevel1UAccessMsg,
                  ssGetPath(S), ssGetModelName(S));
    }
 return(S->states.U.uPtrs);

} /* end _ssGetUPtrsFcn */
#endif



/* Function: _ssGetInputPortSignalPtrsFcn ======================================
 * Abstract:
 *   Return the input signal for level 2 s-functions. Also detect 
 *   illegal input signal access.
 */
#if S_FUNCTION_LEVEL == 2 && !defined(NDEBUG)
InputPtrsType _ssGetInputPortSignalPtrsFcn(const SimStruct *S, int ip)
{
    int numports =  ((S)->sizes.in.numInputPorts);

    if (ip < 0 || ip >= numports) {
        char *dialogMessage = (char *)malloc(sizeof(_ssBadLevel2InputAccessMsg)
                                             + strlen(ssGetModelName(S)) 
                                             + strlen(ssGetPath(S)) + 
                                             + 4*3*sizeof(char) + 1);
        if (dialogMessage != NULL) {
            (void)sprintf(dialogMessage, _ssBadLevel2InputAccessMsg,
                          ssGetModelName(S), ssGetPath(S), ip+1, numports,
                          numports-1);
            
            /* Stop the simulation and call _ssFatalError */ 
            ssSetStopRequested(S,1);
            _ssFatalError(S,dialogMessage);
            free(dialogMessage);
        }
        return(NULL);
    }

    /* In case the user did not include ssSetInputPortDirectFeedThrough
     * in the mdlInitializeSizes method the direct feedtrhough flag is 
     * set to zero. Call the _ssFatalError to report such error.
     */
    if ((S)->portInfo.inputs[(ip)].signal.ptrs == NULL) {
        char *dialogMessage = (char *)malloc(sizeof(_ssBadLevel2ZeroDirectFeedMsg)
                                             + strlen(ssGetModelName(S)) 
                                             + strlen(ssGetPath(S)) + 
                                             + 4*sizeof(char) + 1);
        if(dialogMessage != NULL){
            (void)sprintf(dialogMessage,_ssBadLevel2ZeroDirectFeedMsg,
                          ssGetModelName(S), ssGetPath(S), ip+1);
            /* Stop the simulation and call _ssFatalError */ 
            ssSetStopRequested(S,1);
            _ssFatalError(S,dialogMessage);
            free(dialogMessage);
            return(NULL);
        }
    }

    return((S)->portInfo.inputs[(ip)].signal.ptrs);
}
#endif



/* Function: _ssGetInputPortSignalFcn ======================================
 * Abstract:
 *   Return the input signal for level 2 s-functions. Also detect 
 *   illegal input signal access.
 */
#if S_FUNCTION_LEVEL == 2 && !defined(NDEBUG)
const void *_ssGetInputPortSignalFcn(const SimStruct *S, int ip)
{

    int numports =  ((S)->sizes.in.numInputPorts);

    if (ip < 0 || ip >= numports) {
        char *dialogMessage = (char *)malloc(sizeof(_ssBadLevel2InputAccessMsg)
                                             + strlen(ssGetModelName(S)) 
                                             + strlen(ssGetPath(S)) + 
                                             + 4*3*sizeof(char) + 1);
        if (dialogMessage != NULL) { 
            (void)sprintf(dialogMessage, _ssBadLevel2InputAccessMsg,
                          ssGetModelName(S), ssGetPath(S), ip+1, numports,
                          numports-1);

            /* Stop the simulation and call _ssFatalError */ 
            ssSetStopRequested(S,1);
            _ssFatalError(S,dialogMessage);
            free(dialogMessage);
        }
        return(NULL);
    }

    /* In case the user did not include ssSetInputPortDirectFeedThrough
     * in the mdlInitializeSizes method the direct feedthrough flag is 
     * set to zero. Call the _ssFatalError to report such error.
     */
    if ((S)->portInfo.inputs[(ip)].signal.vect == NULL) {
        char *dialogMessage = (char *)malloc(sizeof(_ssBadLevel2ZeroDirectFeedMsg)
                                             + strlen(ssGetModelName(S)) 
                                             + strlen(ssGetPath(S)) + 
                                             + 4*sizeof(char) + 1);
        if (dialogMessage != NULL) {
            (void)sprintf(dialogMessage,_ssBadLevel2ZeroDirectFeedMsg,
                          ssGetModelName(S), ssGetPath(S), ip+1);
            /* Stop the simulation and call _ssFatalError */ 
            ssSetStopRequested(S,1);
            _ssFatalError(S,dialogMessage);
            free(dialogMessage);
            return(NULL);
        }
    }

    return ((S)->portInfo.inputs[(ip)].signal.vect); 
}
#endif

/* Function: ssSetInputPortDirectFeedThrough  ===========================================
* Abstract:
*   Set the direct feedthrough flag. Also detect for illegal settings
*/
#if S_FUNCTION_LEVEL == 2 && !defined(NDEBUG)
void _ssSetInputPortDirectFeedThroughFcn(const SimStruct *S, int ip,
                                             int dirFeed)
{
    /* Call _ssFatalError if
       Num input ports == 1 and ssSetInputPortDirectFeedThrough(S, 1, 1)
       This is is a common mistake. It should be (S, 0, 1).
     */
    int numports = ((S)->sizes.in.numInputPorts);
    if (ip < 0 || ip >= numports) {
        char *dialogMessage = (char *)malloc(sizeof(_ssBadLevel2DirectFeedMsg)
                                                 + strlen(ssGetModelName(S)) 
                                                 + strlen(ssGetPath(S)) + 
                                                 + 4*3*sizeof(char) + 1);
        if (dialogMessage != NULL) {
            (void)sprintf(dialogMessage,_ssBadLevel2DirectFeedMsg,
                          ssGetModelName(S), ssGetPath(S), ip+1, numports,
                          numports-1);
            /* Stop the simulation and call _ssFatalError */ 
            ssSetStopRequested(S,1);
            _ssFatalError(S,dialogMessage);
            free(dialogMessage);
        }
    } else {
        (S)->portInfo.inputs[(ip)].directFeedThrough = (dirFeed);
    }
}

/* Function: ssSetInputPortReusableFcn =========================================
 * Abstract: 
 *   Issue a wanring that the macro ssSetInputPortReusableFcn is invalid
 */
void _ssSetInputPortReusableFcn(SimStruct* S, int ip, int val)
{
    char msg[1024];

    (void)sprintf(msg, "The macro ssSetInputPortReusable is obsolete, "
                  "please update the %s to use the macro "
                  "ssSetInputPortOptimOpts", _sfcnName);
    ssWarning(S, msg);
    S->portInfo.inputs[ip].attributes.optimOpts = (val) ?
        SS_REUSABLE_AND_LOCAL : SS_NOT_REUSABLE_AND_GLOBAL;
}

/* Function: ssSetOutputPortReusableFcn ========================================
 * Abstract: 
 *   Issue a wanring that the macro ssSetOutputPortReusableFcn is invalid
 */
void _ssSetOutputPortReusableFcn(SimStruct* S, int op, int val)
{
    char msg[1024];

    (void)sprintf(msg, "The macro ssSetOutputPortReusable is obsolete, "
                  "please update the %s to use the macro "
                  "ssSetOutputPortOptimOpts", _sfcnName);
    ssWarning(S, msg);
    S->portInfo.outputs[op].attributes.optimOpts = (val) ?
        SS_REUSABLE_AND_LOCAL : SS_NOT_REUSABLE_AND_GLOBAL;
}

#endif

/* Function: ssGetDTypeIdFromMxArray ===========================================
 * Abstract:
 *      Utility to translate the mxClassId of an mxArray to one of Simulink's
 *      built-in data type indices. The return value is of type DTypeId, which
 *      is defined in simstruc.h
 *
 *      This function returns INVALID_DTYPE_ID if the mxClassId does not map to
 *      any built-in Simulink data type. For example, if mxId == mxSTRUCT_CLASS
 *      then the return value is INVALID_DTYPE_ID.
 *      Otherwise the return value is one of the enum values in BuiltInDTypeId.
 *      For example if mxId == mxUINT16_CLASS then the return value is SS_UINT16
 */
DTypeId ssGetDTypeIdFromMxArray(const mxArray *m)
{
    DTypeId dTypeId;
    mxClassID mxId = mxGetClassID(m);

    switch (mxId) {
      case mxCELL_CLASS:
      case mxSTRUCT_CLASS:
      case mxOBJECT_CLASS:
      case mxCHAR_CLASS:
        dTypeId = INVALID_DTYPE_ID;
        break;
      case mxDOUBLE_CLASS:
        dTypeId = SS_DOUBLE;
        break;
      case mxSINGLE_CLASS:
        dTypeId = SS_SINGLE;
        break;
      case mxINT8_CLASS:
        dTypeId = SS_INT8;
        break;
      case mxUINT8_CLASS:
        if (mxIsLogical(m)) {
            dTypeId = SS_BOOLEAN;
        } else {
            dTypeId = SS_UINT8;
        }
        break;
      case mxINT16_CLASS:
        dTypeId = SS_INT16;
        break;
      case mxUINT16_CLASS:
        dTypeId = SS_UINT16;
        break;
      case mxINT32_CLASS:
        dTypeId = SS_INT32;
        break;
      case mxUINT32_CLASS:
        dTypeId = SS_UINT32;
        break;
      case mxINT64_CLASS:
      case mxUINT64_CLASS:
      case mxUNKNOWN_CLASS:
        dTypeId = INVALID_DTYPE_ID;
        break;
      default:
        dTypeId = INVALID_DTYPE_ID;
        break;
    }
    return(dTypeId);

} /* end ssGetDTypeIdFromMxArray */


/*===============================================*
 * Global functions (can be used only in mdlRTW) *
 *===============================================*/


/* Function: ssWriteRTWStr ====================================================
 * Abstract:
 *	Only for use in the mdlRTW method. This is a "low-level" routine
 *	for writing strings directly into the model.rtw file. It typically
 *	shouldn't be used by S-functions, unless you need to create 
 *	"sub" Block record. These records should start with SFcn to
 *	avoid future compatibility problems. For example:
 *
 *	mdlRTW()
 *	{
 *	   if (!ssWriteRTWStr(S, "SFcnMySpecialRecord {")) return;
 *	   <snip>
 *	   if (!ssWriteRTWStr(S, "}")) return;
 *      }
 *
 */
int_T ssWriteRTWStr(SimStruct *S, const char_T *str)
{
    int_T ans = 0;
#   if SS_DO_FCN_CALL_ON_MAC && defined(__MWERKS__)
#   pragma mpwc on
#   endif
    ans = (*S->mdlInfo->writeRTWStrFcn)(S->mdlInfo->writeRTWFcnArg, str);
#   if SS_DO_FCN_CALL_ON_MAC && defined(__MWERKS__)
#   pragma mpwc off
#   endif
    return(ans);

} /* end ssWriteRTWStr */


/* Function: ssWriteRTWMxVectParam =============================================
 * Abstract:
 *	Only for use in the mdlRTW method. This is a "low-level" routine for
 *      writing Matlab style vectors (could be complex valued) into the mdl.rtw
 *      file. Typically this function should not be used by S-functions, the
 *      function ssWriteRTWParamSettings is more appropriate in most cases.
 *      However, this function is useful when you are writing out custom data
 *      structures directly in the mdl.rtw file.
 */
int_T ssWriteRTWMxVectParam(SimStruct    *S,
                            const char_T *name,
                            const void   *rVal,
                            const void   *iVal,
                            int_T        dtInfo,
                            int_T        numEl)
{
    const void *pD[2];

    pD[0] = rVal;
    pD[1] = iVal;
    return( ssWriteRTWNameValuePair(S,SSWRITE_VALUE_DTYPE_ML_VECT,
                                    name, pD, dtInfo, numEl) );

} /* end ssWriteRTWMxVectParam */


/* Function: ssWriteRTWMx2dMatParam ============================================
 * Abstract:
 *	Only for use in the mdlRTW method. This is a "low-level" routine for
 *      writing Matlab style matrices (could be complex valued) into the mdl.rtw
 *      file. Typically this function should not be used by S-functions, the
 *      function ssWriteRTWParamSettings is more appropriate in most cases.
 *      However, this function is useful when you are writing out custom data
 *      structures directly in the mdl.rtw file.
 */
int_T ssWriteRTWMx2dMatParam(SimStruct    *S,
                             const char_T *name,
                             const void   *rVal,
                             const void   *iVal,
                             int_T        dtInfo,
                             int_T        nRows,
                             int_T        nCols)
{
    const void *pD[2];
    pD[0] = rVal;
    pD[1] = iVal;
    return( ssWriteRTWNameValuePair(S,SSWRITE_VALUE_DTYPE_ML_2DMAT,
                                    name, pD, dtInfo, nRows, nCols) );

} /* end ssWriteRTWMx2dMatParam */


/* Function: ssWriteRTWNameValuePair ===========================================
 * Abstract:
 *	Only for use in the mdlRTW method. This is a "low-level" routine for
 *      writing name-value pairs directly into the model.rtw file. The input
 *      arguments for this function are subject to change, therefore you should
 *      not invoke this function directly. Instead, use the ssWriteRTWxxxParam()
 *      macros documented in matlabroot/simulink/src/sfuntmpl.doc (also see
 *      matlabroot/simulink/src/ml2rtw.c for examples of usage). The macros will
 *      in turn invoke this function with the appropriate arguments. Using these
 *      macros you will be able to write custom sub-records into your S-Function
 *      block record in the .rtw file. For example:
 *
 *	   mdlRTW()
 *	   {
 *	      if (!ssWriteRTWStr(S, "SFcnMySpecialRecord {")) return;
 *	      if (!ssWriteRTWStrParam(S, SSWRITE_VALUE_STR, "MyFieldName",
 *                                         "IsVeryVeryCool")) return;
 *	      if (!ssWriteRTWStr(S, "}")) return;
 *         }
 *
 *      will create the following sub-record in the Block's record:
 *
 *         Block {
 *            :
 *            :
 *            SFcnMySpecialRecord {
 *               MyFieldName   IsVeryVeryCool
 *            }
 *            :
 *            :
 *         }
 *
 *      Beware that you can easily corrupt the model.rtw file via these macros.
 *
 * Returns:
 *     1 - success
 *     0 - error. The appropriate error message is set in ssGetErrorStatus(S)
 */
int_T ssWriteRTWNameValuePair(SimStruct    *S,
                              int_T        type,
                              const char_T *name,
                              const void   *value,
                              ...)
{
    int_T      ans        = 1;      /* assume */
    int_T      dtInfo     = 0;      /* real and double */
    int_T      nRows      = 1;
    int_T      nCols      = 1;
    int_T      haveImData = 0;      /* assume */
    int_T      haveNCols  = 0;
    const void *pValue    = NULL;

    va_list    ap;
    va_start(ap, value);
    pValue = value;

    switch (type) {
      case SSWRITE_VALUE_STR:
      case SSWRITE_VALUE_QSTR:
        /* No additional args */
        break;
      case SSWRITE_VALUE_VECT_STR:
        nRows     = va_arg(ap, int_T);  /* nItems e.g. ["a", "b", "c"] has 3 */
        break;
      case SSWRITE_VALUE_NUM:
      case SSWRITE_VALUE_DTYPE_NUM:
        dtInfo = va_arg(ap, int_T);
        break;
      case SSWRITE_VALUE_VECT:
      case SSWRITE_VALUE_DTYPE_VECT:
        dtInfo     = va_arg(ap, int_T);
        nRows      = va_arg(ap, int_T);
        break;
      case SSWRITE_VALUE_2DMAT:
      case SSWRITE_VALUE_DTYPE_2DMAT:
        dtInfo    = va_arg(ap, int_T);
        nRows     = va_arg(ap, int_T);
        nCols     = va_arg(ap, int_T);
        haveNCols = 1;
        break;
      case SSWRITE_VALUE_DTYPE_ML_VECT:
        {
            haveImData = 1;
            dtInfo     = va_arg(ap, int_T);
            nRows      = va_arg(ap, int_T);
            break;
        }
      case SSWRITE_VALUE_DTYPE_ML_2DMAT:
        {
            haveImData = 1;
            haveNCols  = 1;
            dtInfo     = va_arg(ap, int_T);
            nRows      = va_arg(ap, int_T);
            nCols      = va_arg(ap, int_T);
            break;
        }
      default:
        ssSetErrorStatus(S, "Invalid SSWRITE_VALUE_type passed to "
                         "ssWriteRTWNameValuePair");
        ans = 0;
        goto EXIT_POINT;
    }

    if (name == NULL || name[0] == '\0') {
        ssSetErrorStatus(S, "Invalid name passed to "
                            "ssWriteRTWNameValuePair");
        ans = 0;
        goto EXIT_POINT;
    }

    if (nRows < 0 || nCols < 0 ||
        (haveNCols && ((nRows==0 && nCols!=0) || (nRows!=0 && nCols==0)))) {
        ssSetErrorStatus(S, "Invalid number of rows or columns passed to "
                         "ssWriteRTWNameValuePair");
        ans = 0;
        goto EXIT_POINT;
    }
            
    if (nRows != 0) {
        int_T ok = 1; 

        if (haveImData) {
            const void **v2 = (const void **)value;
            if (v2[0] == NULL ||
                (GET_COMPLEX_SIGNAL(dtInfo) && v2[1] == NULL)) {
                ok = 0;
            }
        } else if (value == NULL) {
            ok = 0;
        }

        if (!ok) {
            ssSetErrorStatus(S, "Invalid value (NULL) passed to "
                             "ssWriteRTWNameValuePair");
            ans = 0;
            goto EXIT_POINT;
        }
    }


#   if SS_DO_FCN_CALL_ON_MAC && defined(__MWERKS__)
#   pragma mpwc on
#   endif
    ans = (*S->mdlInfo->writeRTWNameValuePairFcn)(S->mdlInfo->writeRTWFcnArg,
                                        type, name, pValue,  dtInfo, nRows, nCols);
#   if SS_DO_FCN_CALL_ON_MAC && defined(__MWERKS__)
#   pragma mpwc off
#   endif

EXIT_POINT:

    va_end(ap);
    return(ans);

} /* end ssWriteRTWNameValuePair */



/* Function: ssWriteRTWParameters =============================================
 * Abstract:
 *	Used in mdlRTW to create Parameter records for your S-function.
 *      nParams is the number of tunable S-function parameters. Each parameter
 *	starts with an SSWRITE_VALUE_type which can be:
 *
 *         SSWRITE_VALUE_VECT,
 *           const char_T   *paramName,
 *           const char_T   *stringInfo,
 *           const real_T   *valueVect,
 *           int_T          vectLen
 *
 *         SSWRITE_VALUE_2DMAT,
 *           const char_T   *paramName,
 *           const char_T   *stringInfo,
 *           const real_T   *valueMat,
 *           int_T          nRows,
 *           int_T          nCols
 *
 *         SSWRITE_VALUE_DTYPE_VECT,
 *           const char_T   *paramName,
 *           const char_T   *stringInfo,
 *           const void     *valueVect,
 *           int_T          vectLen,
 *           int_T          dtInfo
 *
 *         SSWRITE_VALUE_DTYPE_2DMAT,
 *           const char_T   *paramName,
 *           const char_T   *stringInfo,
 *           const void     *valueMat,
 *           int_T          nRows,
 *           int_T          nCols,
 *           int_T          dtInfo
 *
 *         SSWRITE_VALUE_DTYPE_ML_VECT,
 *           const char_T   *paramName,
 *           const char_T   *stringInfo,
 *           const void     *rValueVect,
 *           const void     *iValueVect,
 *           int_T          vectLen,
 *           int_T          dtInfo
 *
 *         SSWRITE_VALUE_DTYPE_ML_2DMAT,
 *           const char_T   *paramName,
 *           const char_T   *stringInfo,
 *           const void     *rValueMat,
 *           const void     *iValueMat,
 *           int_T          nRows,
 *           int_T          nCols,
 *           int_T          dtInfo
 *	
 */
int_T ssWriteRTWParameters(SimStruct *S, int_T nParams, ...)
{
    int_T     i;
    int_T     ans = 1; /* assume */
    va_list   ap;
    va_start(ap, nParams);

    for (i=0; i< nParams; i++) {
        int_T        type   = va_arg(ap, int_T);
        const char_T *name  = va_arg(ap, const char_T *);
        const char_T *str   = va_arg(ap, const char_T *);
        int_T        dtInfo = 0; /* real and double */
        int_T        nRows;
        int_T        nCols;
        const void   *ppValue[2];
        const void   *pValue;


        switch (type) {
          case SSWRITE_VALUE_VECT:
            {
                pValue = va_arg(ap, const real_T *);
                nRows  = va_arg(ap, int_T);
                nCols  = (nRows == 0)? 0: 1;
                dtInfo = 0; /* real, double */
            }
            break;
          case SSWRITE_VALUE_2DMAT:
            {
                pValue = va_arg(ap, const real_T *);
                nRows  = va_arg(ap, int_T);
                nCols  = va_arg(ap, int_T);
                dtInfo = 0; /* real, double */
            }
            break;
          case SSWRITE_VALUE_DTYPE_VECT:
            {
                pValue = va_arg(ap, const void *);
                nRows  = va_arg(ap, int_T);
                nCols  = (nRows == 0)? 0: 1;
                dtInfo = va_arg(ap, int_T);
            }
            break;
          case SSWRITE_VALUE_DTYPE_2DMAT:
            {
                pValue = va_arg(ap, const void *);
                nRows  = va_arg(ap, int_T);
                nCols  = va_arg(ap, int_T);
                dtInfo = va_arg(ap, int_T);
            }
            break;
          case SSWRITE_VALUE_DTYPE_ML_VECT:
            {
                ppValue[0] = va_arg(ap, const void *); /* real part */
                ppValue[1] = va_arg(ap, const void *); /* imag part */
                pValue     = ppValue;

                nRows      = va_arg(ap, int_T);
                nCols      = (nRows == 0)? 0: 1;
                dtInfo     = va_arg(ap, int_T);
            }
            break;
          case SSWRITE_VALUE_DTYPE_ML_2DMAT:
            {
                ppValue[0] = va_arg(ap, const void *);
                ppValue[1] = va_arg(ap, const void *); 
                pValue     = ppValue;

                nRows      = va_arg(ap, int_T);
                nCols      = va_arg(ap, int_T);
                dtInfo     = va_arg(ap, int_T);
            }
            break;
          default:
            ssSetErrorStatus(S, "Invalid SSWRITE_VALUE_type passed to "
                             "ssWriteRTWParameters");
            ans = 0;
            goto EXIT_POINT;
        }

        if ( name == NULL || name[0] == '\0' ||
             (pValue == NULL && nRows != 0) || 
             nRows < 0 || nCols < 0 ||
             (nRows == 0 && nCols != 0) || (nRows != 0 && nCols == 0)) {
             ssSetErrorStatus(S, "Invalid arguments passed to "
                              "ssWriteRTWParameters");
            ans = 0;
            goto EXIT_POINT;
        }
            
#       if SS_DO_FCN_CALL_ON_MAC && defined(__MWERKS__)
#       pragma mpwc on
#       endif
        ans = (*S->mdlInfo->writeRTWParameterFcn)(S->mdlInfo->writeRTWFcnArg,
                                                  type, name, str, pValue, 
                                                  dtInfo, nRows, nCols);
#       if SS_DO_FCN_CALL_ON_MAC && defined(__MWERKS__)
#       pragma mpwc off
#       endif

        if (ans == 0) {
            goto EXIT_POINT;
        }
    }

  EXIT_POINT:

    va_end(ap);
    return(ans);

} /* end ssWriteRTWParameters */



/* Function: ssWriteRTWParamSettings ==========================================
 * Abstract:
 *	Used in mdlRTW to create the SFcnParameterSettings record for
 *	your S-function (these are generally derived from the non-tunable
 *	parameters). For each parameter a "group" of values must be specified.
 *	These adhear to the the following format:
 *
 *         SSWRITE_VALUE_STR,              - Used to write (un)quoted strings
 *           const char_T *settingName,      example:
 *           const char_T *value,              Country      USA
 *
 *         SSWRITE_VALUE_QSTR,             - Used to write quoted strings
 *           const char_T *settingName,      example:
 *           const char_T *value,              Country      "U.S.A"
 *
 *         SSWRITE_VALUE_VECT_STR,         - Used to write vector of strings
 *           const char_T *settingName,      example:
 *           const char_T *value,              Countries    ["USA", "Mexico"]
 *           int_T        nItemsInVect
 *
 *         SSWRITE_VALUE_NUM,              - Used to write numbers
 *           const char_T *settingName,      example:
 *           const real_T value                 NumCountries  2
 *
 *
 *         SSWRITE_VALUE_VECT,             - Used to write numeric vectors
 *           const char_T *settingName,      example:
 *           const real_T *settingValue,       PopInMil        [300, 100]
 *           int_T        vectLen
 *
 *         SSWRITE_VALUE_2DMAT,            - Used to write 2D matrices
 *           const char_T *settingName,      example:
 *           const real_T *settingValue,       PopInMilBySex  Matrix(2,2)
 *           int_T        nRows,                   [[170, 130],[60, 40]]
 *           int_T        nCols
 *
 *         SSWRITE_VALUE_DTYPE_NUM,        - Used to write numeric vectors
 *           const char_T   *settingName,    example: int8 Num 3+4i
 *           const void     *settingValue,   written as: [3+4i]
 *           int_T          dtInfo
 *
 *
 *         SSWRITE_VALUE_DTYPE_VECT,       - Used to write data typed vectors
 *           const char_T   *settingName,    example: int8 CArray [1+2i 3+4i]
 *           const void     *settingValue,   written as:
 *           int_T          vectLen             CArray  [1+2i, 3+4i]
 *           int_T          dtInfo
 *
 *
 *         SSWRITE_VALUE_DTYPE_2DMAT,      - Used to write data typed 2D
 *           const char_T   *settingName     matrices
 *           const void     *settingValue,   example:
 *           int_T          nRow ,            int8 CMatrix  [1+2i 3+4i; 5 6]
 *           int_T          nCols,            written as:
 *           int_T          dtInfo               CMatrix         Matrix(2,2)
 *                                                [[1+2i, 3+4i]; [5+0i, 6+0i]]
 *
 *
 *         SSWRITE_VALUE_DTYPE_ML_VECT,    - Used to write complex matlab data
 *           const char_T   *settingName,    typed vectors example:
 *           const void     *settingRValue,  example: int8 CArray [1+2i 3+4i]
 *           const void     *settingIValue,      settingRValue: [1 3]
 *           int_T          vectLen              settingIValue: [2 4]
 *           int_T          dtInfo
 *                                             written as:
 *                                                CArray    [1+2i, 3+4i]
 *
 *         SSWRITE_VALUE_DTYPE_ML_2DMAT,   - Used to write matlab complex
 *           const char_T   *settingName,    data typed 2D matrices
 *           const void     *settingRValue,  example
 *           const void     *settingIValue,      int8 CMatrix [1+2i 3+4i; 5 6]
 *           int_T          nRows                settingRValue: [1 5 3 6]
 *           int_T          nCols,               settingIValue: [2 0 4 0]
 *           int_T          dtInfo
 *                                              written as:
 *                                              CMatrix         Matrix(2,2)
 *                                                [[1+2i, 3+4i]; [5+0i, 6+0i]]
 *
 *-----------------------------------------------------------------------------
 */
int_T ssWriteRTWParamSettings(SimStruct *S, int_T nParams, ...)
{
    int_T i;
    int_T ans   = 1; /* assume */

    va_list   ap;
    va_start(ap, nParams);

    if (nParams <= 0) {
        ans = 0;
        goto EXIT_POINT;
    }

    if ( (ans = ssWriteRTWStr(S, "SFcnParamSettings {")) != 1 ) {
        goto EXIT_POINT;
    }
    for (i=0; i< nParams; i++) {
        int_T        type   = va_arg(ap, int_T);
        const char_T *name  = va_arg(ap, const char_T *);
        int_T        dtInfo = 0; /* real and double */
        int_T        nRows;
        int_T        nCols;

        switch (type) {
          case SSWRITE_VALUE_STR:
            /*FALLTHROUGH*/
          case SSWRITE_VALUE_QSTR: {
            const char_T *pValue = va_arg(ap, const char_T *);
            ans = ssWriteRTWNameValuePair(S,type,name,pValue);
            break;
          }
          case SSWRITE_VALUE_VECT_STR: {
            const char_T *pValue = va_arg(ap, const char_T *);
            nRows = va_arg(ap, int_T);
            ans = ssWriteRTWNameValuePair(S,type,name,pValue,nRows);
            break;
          }
          case SSWRITE_VALUE_NUM: {
            real_T value = va_arg(ap, real_T);
            ans = ssWriteRTWNameValuePair(S,type,name,&value,dtInfo);
            break;
          }
          case SSWRITE_VALUE_VECT: {
            const real_T *pValue = va_arg(ap, const real_T *);
            nRows = va_arg(ap, int_T);
            ans = ssWriteRTWNameValuePair(S,type,name,pValue,dtInfo,nRows);
            break;
          }
          case SSWRITE_VALUE_2DMAT: {
            const real_T *pValue = va_arg(ap, const real_T *);
            nRows = va_arg(ap, int_T);
            nCols = va_arg(ap, int_T);
            ans= ssWriteRTWNameValuePair(S,type,name,pValue,
                                         dtInfo,nRows,nCols);
            break;
          }
          case SSWRITE_VALUE_DTYPE_NUM: {
            const void *pValue = va_arg(ap, const void *);
            dtInfo = va_arg(ap, int_T);
            ans    = ssWriteRTWNameValuePair(S,type,name,pValue,dtInfo);
            break;
          }
          case SSWRITE_VALUE_DTYPE_VECT: {
            const void *pValue = va_arg(ap, const void *);
            nRows  = va_arg(ap, int_T);
            dtInfo = va_arg(ap, int_T);
            ans    = ssWriteRTWNameValuePair(S,type,name,pValue,dtInfo,nRows);
            break;
          }
          case SSWRITE_VALUE_DTYPE_2DMAT: {
            const void *pValue = va_arg(ap, const void *);
            nRows  = va_arg(ap, int_T);
            nCols  = va_arg(ap, int_T);
            dtInfo = va_arg(ap, int_T);
            ans    = ssWriteRTWNameValuePair(S,type,name,pValue,
                                             dtInfo,nRows,nCols);
            break;
          }
          case SSWRITE_VALUE_DTYPE_ML_VECT: {
            const void *pValue[2];
            pValue[0] = va_arg(ap, const void *);
            pValue[1] = va_arg(ap, const void *);
            nRows  = va_arg(ap, int_T);
            dtInfo = va_arg(ap, int_T);
            ans    = ssWriteRTWNameValuePair(S,type,name,pValue,dtInfo,nRows);
            break;
          }
          case SSWRITE_VALUE_DTYPE_ML_2DMAT: {
            const void *pValue[2];
            pValue[0] = va_arg(ap, const void *);
            pValue[1] = va_arg(ap, const void *);
            nRows  = va_arg(ap, int_T);
            nCols  = va_arg(ap, int_T);
            dtInfo = va_arg(ap, int_T);
            ans    = ssWriteRTWNameValuePair(S,type,name,pValue,
                                             dtInfo,nRows,nCols);
            break;
          }
          default:
            ssSetErrorStatus(S, "Invalid SSWRITE_VALUE_type passed to "
                                "ssWriteRTWParamSettings");
            ans = 0;
            goto EXIT_POINT;
        }
        if (ans != 1) {
            goto EXIT_POINT;
        }
    }
    if ( (ans = ssWriteRTWStr(S, "}")) != 1 ) {
        goto EXIT_POINT;
    }

  EXIT_POINT:

    va_end(ap);
    return(ans);

} /* end ssWriteRTWParamSettings */



/* Function: ssWriteRTWWorkVect ===============================================
 * Abstract:
 *    Used in mdlRTW to create work vector records for S-functions:
 *
 *       if (!ssWriteRTWWorkVect(S, vectName, nNames,
 *
 *                            name, size,   (must have nNames of these pairs)
 *                                 :
 *                           ) ) {
 *           return;  (error reporting will be handled by SL)
 *       }
 *
 *       Notes:
 *         a) vectName must be either "RWork", "IWork" or "PWork"
 *         b) nNames is an int_T, name is a const char_T* and size is int_T, and
 *            there must be nNames number of [name, size] pairs passed to the
 *            function.
 *         b) intSize1+intSize2+ ... +intSizeN = ssGetNum<vectName>(S)
 *            Recall that you would have to set ssSetNum<vectName>(S)
 *            in one of the initialization functions (mdlInitializeSizes
 *            or mdlSetWorkVectorWidths).
 *	
 */
int_T ssWriteRTWWorkVect(SimStruct    *S,
                         const char_T *vectName,
                         int_T        nNames,
                         ...)
{
    int_T     i;
    int_T     nElementsWritten  = 0;
    int_T     nElementsExpected = 0;
    int_T     ans               = 1; /* assume */
    char_T    strBuf[40]        = "\0";
    va_list   ap;
    va_start(ap, nNames);

    /* vectName must be RWork, IWork or PWork */
    if ( (strcmp(vectName,"RWork") != 0 &&
          strcmp(vectName,"IWork") != 0 &&
          strcmp(vectName,"PWork") != 0) ||
         (strlen(vectName) + sizeof("NumDefines") > sizeof(strBuf))) {
        ssSetErrorStatus(S, "Invalid work vector name (vectName) passed to "
                         "ssWriteRTWWorkVect (must be RWork, IWork, or PWork");
        ans = 0;
        goto EXIT_POINT;
    }

    if (nNames <= 0) {
        ssSetErrorStatus(S, "nNames argument to ssWriteRTWWorkVect must be "
                         "greater than 0");
        ans = 0;
        goto EXIT_POINT;
    }


    if (strcmp(vectName, "RWork") == 0) {
        nElementsExpected = ssGetNumRWork(S);
    } else if (strcmp(vectName, "IWork") == 0) {
        nElementsExpected = ssGetNumIWork(S);
    }  else if (strcmp(vectName, "PWork") == 0) {
        nElementsExpected = ssGetNumPWork(S);
    } else {
        ssSetErrorStatus(S, "Invalid arguments passed to ssWriteRTWWorkVect");
        ans = 0;
        goto EXIT_POINT;
    }
        

    (void)sprintf(strBuf,"Num%sDefines",vectName);
    ans = ssWriteRTWNameValuePair(S,SSWRITE_VALUE_DTYPE_NUM,strBuf,
                                  &nNames, DTINFO(SS_INT32, 0));
    if (ans != 1) goto EXIT_POINT;
        
    for (i = 0; i < nNames; i++) {
        const char_T *name = va_arg(ap, const char_T *);
        int_T        width = va_arg(ap, int_T);

        (void)sprintf(strBuf, "%sDefine {",vectName);
        ans = ssWriteRTWStr(S,strBuf);
        if (ans != 1) goto EXIT_POINT;

        ans = ssWriteRTWNameValuePair(S,SSWRITE_VALUE_QSTR,"Name",name);
        if (ans != 1) goto EXIT_POINT;

        ans = ssWriteRTWNameValuePair(S,SSWRITE_VALUE_DTYPE_NUM,"Width",
                                      &width, DTINFO(SS_INT32, 0));
        if (ans != 1) goto EXIT_POINT;

        ans = ssWriteRTWNameValuePair(S,SSWRITE_VALUE_DTYPE_NUM,"StartIndex",
                                      &nElementsWritten, DTINFO(SS_INT32,0));
        if (ans != 1) goto EXIT_POINT;

        ans = ssWriteRTWStr(S, "}");
        if (ans != 1) goto EXIT_POINT;

        nElementsWritten += width;
    }

    if (nElementsWritten != nElementsExpected) {
        static char_T errmsg[200];
        (void)sprintf(errmsg,
                      "Error in ssWriteRTWWorkVect.  The total number of "
                      "%sDefines written to the .rtw file (= %d), should be "
                      "equal to number of %s (= %d), registered in "
                      "mdlInitializeSizes",
                      vectName, nElementsWritten,
                      vectName, nElementsExpected);
        ssSetErrorStatus(S, errmsg);
        ans = 0;
    }

  EXIT_POINT:
    va_end(ap);
    return(ans);

} /* end ssWriteRTWWorkVect */



/*===================================*
 * Fix for MrC optimization problems *
 *===================================*/

/*
 * MAC - Require local stack frames for routines placed in the function
 * pointer table to work around bugs in MrC compiler.
 */

#if defined(__MRC__)

#define REQUIRE_LOCAL_STACK_FRAME volatile int_T __requireLocalStackFrame = 0

static void __mdlInitializeSizes(SimStruct *S)
{
    REQUIRE_LOCAL_STACK_FRAME;
    mdlInitializeSizes(S);
}

#if S_FUNCTION_LEVEL == 1
# if defined(MDL_GET_INPUT_PORT_WIDTH)
    static int_T __mdlGetInputPortWidth(SimStruct *S, int_T outputWidth)
    {
        REQUIRE_LOCAL_STACK_FRAME;
        return mdlGetInputPortWidth(S, outputWidth);
    }
#  endif

# if defined(MDL_GET_OUTPUT_PORT_WIDTH)
    static int_T __mdlGetOutputPortWidth(SimStruct *S, int_T inputWidth)
    {
        REQUIRE_LOCAL_STACK_FRAME;
        return mdlGetOutputPortWidth(S, inputWidth);
    }
# endif
#endif


#if S_FUNCTION_LEVEL == 2

# if defined(MDL_SET_INPUT_PORT_WIDTH)
    static void __mdlSetInputPortWidth(SimStruct *S, int_T port, int_T width)
    {
        REQUIRE_LOCAL_STACK_FRAME;
        mdlSetInputPortWidth(S, port, width);
    }
# endif

# if defined(MDL_SET_OUTPUT_PORT_WIDTH)
    static void __mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T width)
    {
        REQUIRE_LOCAL_STACK_FRAME;
        mdlSetOutputPortWidth(S, port, width);
    }
# endif

# if defined(MDL_SET_INPUT_PORT_DIMENSION_INFO)
    static void __mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                               int_T            port, 
                                               const DimsInfo_T *dimsInfo)
    {
        REQUIRE_LOCAL_STACK_FRAME;
        mdlSetInputPortDimensionInfo(S, port, dimsInfo);
    }
# endif

# if defined(MDL_SET_OUTPUT_PORT_DIMENSION_INFO)
    static void __mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                                int_T            port, 
                                                const DimsInfo_T *dimsInfo)
    {
        REQUIRE_LOCAL_STACK_FRAME;
        mdlSetOutputPortDimensionInfo(S, port, dimsInfo);
    }
# endif

# if defined(MDL_SET_DEFAULT_PORT_DIMENSION_INFO)
    static void __mdlSetDefaultPortDimensionInfo(SimStruct *S)
    {
        REQUIRE_LOCAL_STACK_FRAME;
        mdlSetDefaultPortDimensionInfo(S);
    }
# endif

# if defined(MDL_SET_INPUT_PORT_SAMPLE_TIME)
    static void __mdlSetInputPortSampleTime(SimStruct *S, int_T port, 
                                            real_T sampleTime, 
                                            real_T offsetTime)
    {
        REQUIRE_LOCAL_STACK_FRAME;
        mdlSetInputPortSampleTime(S, port, sampleTime, offsetTime);
    }
# endif

# if defined(MDL_SET_OUTPUT_PORT_SAMPLE_TIME)
    static void __mdlSetOutputPortSampleTime(SimStruct *S, int_T port, 
                                             real_T sampleTime,
                                             real_T offsetTime)
    {
        REQUIRE_LOCAL_STACK_FRAME;
        mdlSetOutputPortSampleTime(S, port, sampleTime, offsetTime);
    }
# endif

#   if defined(MDL_SET_INPUT_PORT_DATA_TYPE)
      static void __mdlSetInputPortDataType(SimStruct *S, int_T port,
                                            DTypeId   inputPortDataType)
      {
          REQUIRE_LOCAL_STACK_FRAME;
          mdlSetInputPortDataType(S, port, inputPortDataType);
      }
#   endif
  
#   if defined(MDL_SET_OUTPUT_PORT_DATA_TYPE)
      static void __mdlSetOutputPortDataType(SimStruct *S, int_T port,
                                             DTypeId   outputPortDataType)
      {
          REQUIRE_LOCAL_STACK_FRAME;
          mdlSetOutputPortDataType(S, port, outputPortDataType);
      }
#   endif

#   if defined(MDL_SET_DEFAULT_PORT_DATA_TYPES)
      static void __mdlSetDefaultPortDataTypes(SimStruct *S)
      {
          REQUIRE_LOCAL_STACK_FRAME;
          mdlSetDefaultPortDataTypes(S);
      }
#   endif



#   if defined(MDL_SET_INPUT_PORT_COMPLEX_SIGNAL)
      static void __mdlSetInputPortComplexSignal(SimStruct *S, int_T port,
                                                 int_T iPortComplexSignal)
      {
          REQUIRE_LOCAL_STACK_FRAME;
          mdlSetInputPortComplexSignal(S, port, iPortComplexSignal);
      }
#   endif
  
#   if defined(MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL)
      static void __mdlSetOutputPortComplexSignal(SimStruct *S, int_T port,
                                                 int_T oPortComplexSignal)
      {
          REQUIRE_LOCAL_STACK_FRAME;
          mdlSetOutputPortComplexSignal(S, port, oPortComplexSignal);
      }
#   endif

#   if defined(MDL_SET_DEFAULT_PORT_COMPLEX_SIGNALS)
      static void __mdlSetDefaultPortComplexSignals(SimStruct *S)
      {
          REQUIRE_LOCAL_STACK_FRAME;
          mdlSetDefaultPortComplexSignals(S);
      }
#   endif


#   if defined(MDL_SET_INPUT_PORT_FRAME_DATA)
      static void __mdlSetInputPortFrameData(SimStruct *S, int_T port,
                                            Frame_T   iPortFrameData)
      {
          REQUIRE_LOCAL_STACK_FRAME;
          mdlSetInputPortFrameData(S, port, iPortFrameData);
      }
#   endif
  
#endif

static void __mdlInitializeSampleTimes(SimStruct *S)
{
    REQUIRE_LOCAL_STACK_FRAME;
    mdlInitializeSampleTimes(S);
}

#if defined(MDL_SET_WORK_WIDTHS)
static void __mdlSetWorkWidths(SimStruct *S)
{
    REQUIRE_LOCAL_STACK_FRAME;
    mdlSetWorkWidths(S);
}
#endif

#if S_FUNCTION_LEVEL == 2 && defined(MDL_RTW)
  static void __mdlRTW(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlRTW(S);
  }
#endif

#if S_FUNCTION_LEVEL == 2 && defined(MDL_HAVESIMULATIONCONTEXTIO)
  static void __mdlSimulationContextIO(SimStruct *S, const char io, FILE *fp)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlSimulationContextIO(S, io, fp);
  }
#endif


#if S_FUNCTION_LEVEL == 1
  static void __mdlInitializeConditions(real_T *x0, SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlInitializeConditions(x0, S);
  }
#elif defined(MDL_INITIALIZE_CONDITIONS)
  static void __mdlInitializeConditions(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlInitializeConditions(S);
  }
#endif

#if S_FUNCTION_LEVEL == 2 && defined(MDL_START)
  static void __mdlStart(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlStart(S);
  }
#endif

#if defined(RTW_GENERATED_ENABLE) && defined(MDL_ENABLE)
# error MDL_ENABLE and RTW_GENERATED_ENABLE can not be defined simultaneously
#endif

#if S_FUNCTION_LEVEL == 2 && \
 (defined(RTW_GENERATED_ENABLE) || defined(MDL_ENABLE))
  static void __mdlEnable(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlEnable(S);
  }
#endif

#if defined(RTW_GENERATED_DISABLE) && defined(MDL_DISABLE)
# error MDL_DISABLE and RTW_GENERATED_DISABLE can not be defined simultaneously
#endif

#if S_FUNCTION_LEVEL == 2 && \
 (defined(RTW_GENERATED_DISABLE) || defined(MDL_DISABLE))
  static void __mdlDisable(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlDisable(S);
  }
#endif

#if defined(MDL_CHECK_PARAMETERS)
  static void __mdlCheckParameters(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlCheckParameters(S);
  }
#endif

#if S_FUNCTION_LEVEL == 2 && defined(MDL_PROCESS_PARAMETERS)
  static void __mdlProcessParameters(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlProcessParameters(S);
  }
#endif

#if S_FUNCTION_LEVEL == 2 && defined(MDL_SIM_STATUS_CHANGE)
  static void __mdlSimStatusChange(SimStruct *S, ssSimStatusChangeType simStatus)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlSimStatusChange(S, simeStatus);
  }
#endif


#if defined(MDL_EXT_NODE_EXEC)
  static void __mdlExtModeExec(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlExtModeExec(S);
  }
#endif

static void __mdlGetTimeOfNextVarHit(SimStruct *S)
{
    REQUIRE_LOCAL_STACK_FRAME;
    mdlGetTimeOfNextVarHit(S);
}

#if S_FUNCTION_LEVEL == 1
  static void __mdlOutputs(real_T *y, real_T *x, real_T *u, SimStruct *S,
                           int_T tid)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlOutputs(y, x, u, S, tid);
  }
#else
  static void __mdlOutputs(SimStruct *S, int_T tid)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlOutputs(S, tid);
  }
#endif

#if S_FUNCTION_LEVEL == 1
  static void __mdlUpdate(real_T *x, real_T *u, SimStruct *S, int_T tid)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlUpdate(x, u, S, tid);
  }
#elif defined(MDL_UPDATE)
  static void __mdlUpdate(SimStruct *S, int_T tid)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlUpdate(S, tid);
  }
#endif

#if S_FUNCTION_LEVEL == 1
  static void __mdlDerivatives(real_T *dx, real_T *x, real_T *u, SimStruct *S,
                               int_T tid)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlDerivatives(dx, x, u, S, tid);
  }
#elif defined(MDL_DERIVATIVES)
  static void __mdlDerivatives(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlDerivatives(S);
  }
#endif

#if defined(MDL_JACOBIAN)
  static void __mdlJacobian(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlJacobian(S);
  }
#endif

#if defined(MDL_PROJECTION)
  static void __mdlProjection(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlProjection(S);
  }
#endif

#if defined(MDL_MASSMATRIX)
  static void __mdlMassMatrix(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlMassMatrix(S);
  }
#endif

#if defined(MDL_FORCINGFUNCTION)
  static void __mdlForcingFunction(SimStruct *S)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlForcingFunction(S);
  }
#endif

#if defined(MDL_RTWCG)
  static void __mdlRTWCG(SimStruct *S, RTWCGInterface *iObj)
  {
      REQUIRE_LOCAL_STACK_FRAME;
      mdlRTWCG(S,iObj);
  }
#endif

static void __mdlZeroCrossings(SimStruct *S)
{
    REQUIRE_LOCAL_STACK_FRAME;
    mdlZeroCrossings(S);
}

static void __mdlTerminate(SimStruct *S)
{
    REQUIRE_LOCAL_STACK_FRAME;
    mdlTerminate(S);
}

#else

#if !defined(ADA_S_FUNCTION)
/* Ada S-Function's mdlInitializeSizes is called from __mdlInitializeSizes */
# define __mdlInitializeSizes          mdlInitializeSizes
#endif

#if S_FUNCTION_LEVEL == 1

# if defined(MDL_GET_INPUT_PORT_WIDTH)
#  define __mdlGetInputPortWidth      mdlGetInputPortWidth
# endif

# if defined(MDL_GET_OUTPUT_PORT_WIDTH)
#  define __mdlGetOutputPortWidth     mdlGetOutputPortWidth
# endif

#else /* level 2 */

# if defined(MDL_SET_INPUT_PORT_WIDTH)
#  define __mdlSetInputPortWidth      mdlSetInputPortWidth
# endif

# if defined(MDL_SET_OUTPUT_PORT_WIDTH)
#  define __mdlSetOutputPortWidth     mdlSetOutputPortWidth
# endif

# if defined(MDL_SET_INPUT_PORT_DIMENSION_INFO)
#  define __mdlSetInputPortDimensionInfo      mdlSetInputPortDimensionInfo
# endif

# if defined(MDL_SET_OUTPUT_PORT_DIMENSION_INFO)
#  define __mdlSetOutputPortDimensionInfo     mdlSetOutputPortDimensionInfo
# endif

# if defined(MDL_SET_DEFAULT_PORT_DIMENSION_INFO)
#  define __mdlSetDefaultPortDimensionInfo     mdlSetDefaultPortDimensionInfo
# endif

# if defined(MDL_SET_INPUT_PORT_SAMPLE_TIME)
#  define __mdlSetInputPortSampleTime   mdlSetInputPortSampleTime
# endif

# if defined(MDL_SET_OUTPUT_PORT_SAMPLE_TIME)
#  define __mdlSetOutputPortSampleTime  mdlSetOutputPortSampleTime
# endif



# if defined(MDL_SET_INPUT_PORT_DATA_TYPE)
#  define __mdlSetInputPortDataType   mdlSetInputPortDataType
# endif

# if defined(MDL_SET_OUTPUT_PORT_DATA_TYPE)
#  define __mdlSetOutputPortDataType  mdlSetOutputPortDataType
# endif

# if defined(MDL_SET_DEFAULT_PORT_DATA_TYPES)
#  define __mdlSetDefaultPortDataTypes  mdlSetDefaultPortDataTypes
# endif


# if defined(MDL_SET_INPUT_PORT_COMPLEX_SIGNAL)
#  define __mdlSetInputPortComplexSignal   mdlSetInputPortComplexSignal
# endif

# if defined(MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL)
#  define __mdlSetOutputPortComplexSignal  mdlSetOutputPortComplexSignal
# endif

# if defined(MDL_SET_DEFAULT_PORT_COMPLEX_SIGNALS)
#  define __mdlSetDefaultPortComplexSignals  mdlSetDefaultPortComplexSignals
# endif


# if defined(MDL_SET_INPUT_PORT_FRAME_DATA)
#  define __mdlSetInputPortFrameData   mdlSetInputPortFrameData
# endif

#endif

#define __mdlInitializeSampleTimes    mdlInitializeSampleTimes

#if !defined(ADA_S_FUNCTION)
/* Ada S-Function's mdlSetWorkWidths is called from __mdlSetWorkWidths */
#define __mdlSetWorkWidths            mdlSetWorkWidths
#endif

#if S_FUNCTION_LEVEL == 2 && defined(MDL_RTW)
# define __mdlRTW                     mdlRTW
#endif

#if S_FUNCTION_LEVEL == 2 && defined(SS_HAVESIMULATIONCONTEXTIO)
# define __mdlSimulationContextIO     mdlSimulationContextIO
#endif

#if S_FUNCTION_LEVEL == 1 || defined(MDL_INITIALIZE_CONDITIONS)
# define __mdlInitializeConditions    mdlInitializeConditions
#endif

#if S_FUNCTION_LEVEL == 2 && defined(MDL_START)
# define __mdlStart                   mdlStart
#endif

#if S_FUNCTION_LEVEL == 2 && \
 (defined(RTW_GENERATED_ENABLE) || defined(MDL_ENABLE))
# define __mdlEnable                  mdlEnable
#endif

#if S_FUNCTION_LEVEL == 2 && \
 (defined(RTW_GENERATED_DISABLE) || defined(MDL_DISABLE))
# define __mdlDisable                  mdlDisable
#endif

#if defined(MDL_CHECK_PARAMETERS)
# define __mdlCheckParameters         mdlCheckParameters
#endif

#if S_FUNCTION_LEVEL == 2 && defined(MDL_PROCESS_PARAMETERS)
# define __mdlProcessParameters       mdlProcessParameters
#endif

#if defined(MDL_EXT_MODE_EXEC)
# define __mdlExtModeExec             mdlExtModeExec
#endif

#define __mdlGetTimeOfNextVarHit      mdlGetTimeOfNextVarHit

#define __mdlOutputs                  mdlOutputs

#if S_FUNCTION_LEVEL == 1 || defined(MDL_UPDATE)
# define __mdlUpdate                  mdlUpdate
#endif

#if S_FUNCTION_LEVEL == 1 || defined(MDL_DERIVATIVES)
# define __mdlDerivatives             mdlDerivatives
#endif

#if defined(MDL_JACOBIAN)
# define __mdlJacobian                mdlJacobian
#endif

#if defined(MDL_PROJECTION)
# define __mdlProjection              mdlProjection
#endif

#if defined(MDL_MASSMATRIX)
# define __mdlMassMatrix              mdlMassMatrix
#endif

#if defined(MDL_FORCINGFUNCTION)
# define __mdlForcingFunction         mdlForcingFunction
#endif

#if defined(MDL_RTWCG)
# define __mdlRTWCG                   mdlRTWCG
#endif

#if S_FUNCTION_LEVEL == 2 && defined(MDL_SIM_STATUS_CHANGE)
# define __mdlSimStatusChange         mdlSimStatusChange
#endif

#define __mdlZeroCrossings            mdlZeroCrossings

#if !defined(ADA_S_FUNCTION)
/* Ada S-Function's mdlTerminate is called from __mdlTerminate */
#define __mdlTerminate                mdlTerminate
#endif

#endif /* defined __MRC__ */



/* Function: _ProcessMexSfunctionCmdLineCall ==================================
 * Abstract:
 *      Process a MEX S-function call which was issued at the MATLAB
 *      command line.
 *
 *      The only vaild command is the sizes initialization:
 *
 *      [sizes,x0,str,ts,xts]=sfunc([],[],[],0)
 *
 *      Thrid parameter U is required if we have dynamically sized
 *      vector(s).
 */
#ifdef V4_COMPAT
static void _ProcessMexSfunctionCmdLineCall
(
 int_T       nlhs,
 Matrix      *plhs[],
 int_T       nrhs,
 Matrix      *prhs[]
)
#else
static void _ProcessMexSfunctionCmdLineCall
(
 int_T         nlhs,
 mxArray       *plhs[],
 int_T         nrhs,
 const mxArray *prhs[]
)
#endif /* V4_COMPAT */
{
    char_T    errmsg[256];
#   if defined(ADA_S_FUNCTION)
    int_T     tempSimStruct = 0; /* assume */
#   endif
    SimStruct *S;
    int_T     flag;
    real_T    flagDbl;
    real_T    *dptr;

    /************************************************
     * Verify arguments aren't outside their limits *
     ************************************************/

    if (nrhs < 4) {
        (void)sprintf(errmsg,
                "%s must be called with at least 4 right hand arguments",
                _sfcnName);
        mexErrMsgTxt(errmsg);
    }

    if (nlhs > 1) {
        (void)sprintf(errmsg,
                "%s called with too many left hand arguments",
                _sfcnName);
        mexErrMsgTxt(errmsg);
    }


    /*******************************
     * Get flag and verify it is 0 *
     *******************************/

    if (_GetNumEl(prhs[_RHS_FLAG]) != 1 ||
        mxIsComplex(prhs[_RHS_FLAG]) || !mxIsNumeric(prhs[_RHS_FLAG])) {
        (void)sprintf(errmsg, "The 4th right hand argument, FLAG, "
                      "passed to %s must be an integer",_sfcnName);
        mexErrMsgTxt(errmsg);
    }

    flagDbl = *(real_T*)mxGetPr(prhs[_RHS_FLAG]);
    flag = (int_T) flagDbl;

    if ((real_T)flag != flagDbl) {
        (void)sprintf(errmsg, "The 4th right hand argument, FLAG, "
                      "passed to %s must be an integer",_sfcnName);
        mexErrMsgTxt(errmsg);
    }

    if (flag != 0) {
        (void)sprintf(errmsg,"Invalid flag passed to %s", _sfcnName);
        mexErrMsgTxt(errmsg);
    }



    /*******************************************
     * Get SimStruct or create a temporary one *
     *******************************************/
    {
        int_T    m   = mxGetM(prhs[_RHS_X]);
        real_T   *pr = ((m == sizeof(SimStruct *)/sizeof(int_T) + 1)?
                      (real_T*)mxGetPr(prhs[_RHS_X]): (real_T*)NULL);
        /*
         * If number of rows is equal to a pointer split across int_T's,
         * then the SimStruct pointer is incodede in the X argument.
         * The pointer comes first. The version of the passed SimStruct comes
         * second.
         */
        if (pr != NULL && pr[m-1] == SIMSTRUCT_VERSION_LEVEL2) {
            int_T    *intS = (int_T *)&S;
            int_T    i;

            for (i = 0; i < m - 1; i++) {
                intS[i] = (int_T)pr[i];
            }

            /*
             * Verify that S_FUNCTION_NAME and name entered in the
             * S-function dialog box match
             */
#           if S_FUNCTION_LEVEL == 2
            {
#           else
            if (ssGetSimMode(S) == SS_SIMMODE_RTWGEN) {
#           endif
                const char_T *sfcnName = _QUOTE(S_FUNCTION_NAME);

                if (strcmp(sfcnName,"simulink_only_sfcn") != 0 &&
                    strcmp(ssGetModelName(S),sfcnName) != 0) {
                    (void)sprintf(errmsg, "S-function name mismatch. Name in "
                            "source is \"#define S_FUNCTION_NAME %s\", "
                            "whereas name of the S-function MEX file "
                            "is \"%s\". The source needs to be updated",
                            sfcnName, ssGetModelName(S));
                    mexErrMsgTxt(errmsg);
                }
            }

            /* Since this is Simulink calling us, load function pointers. */

            ssSetmdlInitializeSizes(S,__mdlInitializeSizes);

#           if S_FUNCTION_LEVEL==1 && defined(MDL_GET_INPUT_PORT_WIDTH)
                ssSetmdlGetInputPortWidthLevel1(S,
                    (mdlGetInputPortWidthLevel1Fcn)__mdlGetInputPortWidth);
#           endif

#           if S_FUNCTION_LEVEL==1 && defined(MDL_GET_OUTPUT_PORT_WIDTH)
                ssSetmdlGetOutputPortWidthLevel1(S,
                    (mdlGetOutputPortWidthLevel1Fcn)__mdlGetOutputPortWidth);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(MDL_SET_INPUT_PORT_WIDTH)
                ssSetmdlSetInputPortWidth(S,__mdlSetInputPortWidth);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(MDL_SET_OUTPUT_PORT_WIDTH)
                ssSetmdlSetOutputPortWidth(S,__mdlSetOutputPortWidth);
#           endif

                
#           if S_FUNCTION_LEVEL==2 && defined(MDL_SET_INPUT_PORT_DIMENSION_INFO)
             ssSetmdlSetInputPortDimensions(S,__mdlSetInputPortDimensionInfo);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(MDL_SET_OUTPUT_PORT_DIMENSION_INFO)
             ssSetmdlSetOutputPortDimensions(S,__mdlSetOutputPortDimensionInfo);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(MDL_SET_DEFAULT_PORT_DIMENSION_INFO)
             ssSetmdlSetDefaultPortDimensions(S,__mdlSetDefaultPortDimensionInfo);
#           endif


#           if S_FUNCTION_LEVEL==2 && defined(MDL_SET_INPUT_PORT_SAMPLE_TIME)
                ssSetmdlSetInputPortSampleTime(S,__mdlSetInputPortSampleTime);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(MDL_SET_OUTPUT_PORT_SAMPLE_TIME)
                ssSetmdlSetOutputPortSampleTime(S,__mdlSetOutputPortSampleTime);
#           endif

#           if  S_FUNCTION_LEVEL==2 
#             if defined(MDL_SET_INPUT_PORT_DATA_TYPE)
                  ssSetmdlSetInputPortDataType(S,__mdlSetInputPortDataType);
#             endif

#             if defined(MDL_SET_OUTPUT_PORT_DATA_TYPE)
                  ssSetmdlSetOutputPortDataType(S,__mdlSetOutputPortDataType);
#             endif

#             if defined(MDL_SET_DEFAULT_PORT_DATA_TYPES)
                  ssSetmdlSetDefaultPortDataTypes(S,__mdlSetDefaultPortDataTypes);
#             endif


#             if defined(MDL_SET_INPUT_PORT_COMPLEX_SIGNAL)
                  ssSetmdlSetInputPortComplexSignal(S,
                                              __mdlSetInputPortComplexSignal);
#             endif

#             if defined(MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL)
                  ssSetmdlSetOutputPortComplexSignal(S,
                                              __mdlSetOutputPortComplexSignal);
#             endif

#             if defined(MDL_SET_DEFAULT_PORT_COMPLEX_SIGNALS)
                  ssSetmdlSetDefaultPortComplexSignals(S,
                                              __mdlSetDefaultPortComplexSignals);
#             endif


#             if defined(MDL_SET_INPUT_PORT_FRAME_DATA)
                  ssSetmdlSetInputPortFrameData(S,__mdlSetInputPortFrameData);
#             endif

#           endif

#           if defined(MDL_SET_WORK_WIDTHS)
                ssSetmdlSetWorkWidths(S,__mdlSetWorkWidths);
#           endif
#           if S_FUNCTION_LEVEL==2 && defined(MDL_RTW)
                ssSetmdlRTW(S,__mdlRTW);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(MDL_HASSIMULATIONCONTEXTIO)
                ssSetmdlSimulationContextIO(S,__mdlSimulationContextIO);
#           endif

            ssSetmdlInitializeSampleTimes(S,__mdlInitializeSampleTimes);

#           if S_FUNCTION_LEVEL==1
              ssSetmdlInitializeConditionsLevel1(S,
                (mdlInitializeConditionsLevel1Fcn)__mdlInitializeConditions);
#           elif defined(MDL_INITIALIZE_CONDITIONS)
              ssSetmdlInitializeConditions(S,__mdlInitializeConditions);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(MDL_START)
              ssSetmdlStart(S,__mdlStart);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(RTW_GENERATED_ENABLE)
              ssSetRTWGeneratedEnable(S,__mdlEnable);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(RTW_GENERATED_DISABLE)
              ssSetRTWGeneratedDisable(S,__mdlDisable);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(MDL_ENABLE)
              ssSetmdlEnable(S,__mdlEnable);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(MDL_DISABLE)
              ssSetmdlDisable(S,__mdlDisable);
#           endif

#           if defined(MDL_CHECK_PARAMETERS)
                ssSetmdlCheckParameters(S,__mdlCheckParameters);
#           endif

#           if S_FUNCTION_LEVEL==2 && defined(MDL_PROCESS_PARAMETERS)
                ssSetmdlProcessParameters(S,__mdlProcessParameters);
#           endif

#           if S_FUNCTION_LEVEL == 2 && defined(MDL_SIM_STATUS_CHANGE)
              ssSetmdlSimStatusChange(S,__mdlSimStatusChange);
#           endif

#           if defined(MDL_EXT_MODE_EXEC)
                ssSetmdlExtModeExec(S,__mdlExtModeExec);
#           endif

            ssSetmdlGetTimeOfNextVarHit(S, __mdlGetTimeOfNextVarHit);

#           if S_FUNCTION_LEVEL==1
              ssSetmdlOutputsLevel1(S,(mdlOutputsLevel1Fcn)__mdlOutputs);
#           else
              ssSetmdlOutputs(S,__mdlOutputs);
#           endif

#           if S_FUNCTION_LEVEL==1
              ssSetmdlUpdateLevel1(S,(mdlUpdateLevel1Fcn)__mdlUpdate);
#           elif defined(MDL_UPDATE)
              ssSetmdlUpdate(S,__mdlUpdate);
#           endif

#           if S_FUNCTION_LEVEL==1
            ssSetmdlDerivativesLevel1(S,
              (mdlDerivativesLevel1Fcn)__mdlDerivatives);
#           elif defined(MDL_DERIVATIVES)
            ssSetmdlDerivatives(S,__mdlDerivatives);
#           endif

#           if defined(MDL_JACOBIAN)
              ssSetmdlJacobian(S,__mdlJacobian);
#           endif

#           if defined(MDL_PROJECTION)
              ssSetmdlProjection(S,__mdlProjection);
#           endif

#           if defined(MDL_MASSMATRIX)
              ssSetmdlMassMatrix(S,__mdlMassMatrix);
#           endif

#           if defined(MDL_FORCINGFUNCTION)
              ssSetmdlForcingFunction(S,__mdlForcingFunction);
#           endif

#           if defined(MDL_RTWCG)
              ssSetmdlRTWCG(S,__mdlRTWCG);
#           endif

            ssSetmdlZeroCrossings(S, __mdlZeroCrossings);
            ssSetmdlTerminate(S,__mdlTerminate);

        } else {

#           if defined(ADA_S_FUNCTION)
            tempSimStruct = 1;
#           endif
            S = _CreateSimStruct(nrhs,prhs);
        }
    }

#   if S_FUNCTION_LEVEL == 1
       ssSetVersion(S, SIMSTRUCT_VERSION_LEVEL1);
#   else
       ssSetVersion(S, SIMSTRUCT_VERSION_LEVEL2);
#   endif

    /************************
     * Issue the sizes call *
     ************************/

    __mdlInitializeSizes(S);


    /***********************
     * return sizes vector *
     ***********************/
    {
#       define SETU(sizefield) \
        i = (int_T)((uint_T)((&sizefield(S) - (uint_T*)ssGetSizesPtr(S)))); \
        dptr[i] = (real_T)sizefield(S)

        int_T i;
        plhs[_LHS_RET] = mxCreateDoubleMatrix(SIZES_LENGTH, 1, mxREAL);
        dptr = (real_T*) mxGetPr(plhs[_LHS_RET]);
        for (i=0; i<(int_T)SIZES_LENGTH; i++) {
            dptr[i] = (real_T)ssGetSizesPtr(S)[i];
        }

        ssSetOptions(S, (SS_OPTION_SUPPORTS_MULTITASKING |
                         ssGetOptions(S)));

        /* Fix the unsiged items: */
        SETU(ssGetChecksum0);
        SETU(ssGetChecksum1);
        SETU(ssGetChecksum2);
        SETU(ssGetChecksum3);
        SETU(ssGetOptions);
    }

# if defined(ADA_S_FUNCTION)
    /* We need to do additional clean up if this is an Ada S-Function. */
    if ( tempSimStruct == 1 ) {
        __adaSFcnDestroyUserData(S);
    }
# endif

} /* end _ProcessMexSfunctionCmdLineCall */



/* Function: mexFunction ======================================================
 * Abstract:
 *
 *      Simulink C MEX S-function entry point.
 *
 */
#ifdef V4_COMPAT  /* Use MATLAB 4 prototyping for mexFunction */
void mexFunction
(
 int_T    nlhs,               /* in     - number of left hand side arguments  */
 Matrix   *plhs[],            /* in/out - left hand side arguments            */
 int_T    nrhs,               /* in     - number of right hand side arguments */
 Matrix   *prhs[]             /* in     - right hand side arguments           */
)
#else
void mexFunction
(
 int_T   nlhs,               /* in     - number of left hand side arguments  */
 mxArray *plhs[],            /* in/out - left hand side arguments            */
 int_T   nrhs,               /* in     - number of right hand side arguments */
 const mxArray *prhs[]       /* in     - right hand side arguments           */
)
#endif /* V4_COMPAT */
{

    /*
     * We can get called from either Simulink or the MATLAB command line.
     * When called from Simulink, nlhs is negative and the SimStruct is
     * passed in as a left hand side argument.  When called from MATLAB
     * command line, we must create a temporary SimStruct and try our
     * best to perform the requested function specified by the flag
     * parameter.
     */

#ifdef PROCESS_MEX_SFUNCTION_EVERY_CALL
        if(ProcessMexSfunctionEveryCall(nlhs,plhs,nrhs,prhs)) return;
#endif


    if (nlhs < 0) {
        int_T flag = (int_T)(*(real_T*)mxGetPr(prhs[_RHS_FLAG]));

        /*
         * no need for error checking because we are being called from
         * Simulink
         */

        SimStruct *S = (SimStruct *) plhs[_LHS_SS];

        switch(flag) {

#         if S_FUNCTION_LEVEL == 1
          case SS_CALL_MDL_GET_INPUT_PORT_WIDTH:
            if (ssGetmdlGetInputPortWidthLevel1(S) != NULL) {
                int_T outputPortWidth = ssGetMexApiInt1(S);
                int_T uWidth = sfcnGetInputPortWidthLevel1(S, outputPortWidth);
                  ssSetMexApiInt1(S,uWidth);
            } else {
                ssSetErrorStatus(S, "Unexpected call to mdlGetInputPortWidth");
            }
            break;

          case SS_CALL_MDL_GET_OUTPUT_PORT_WIDTH:
            if (ssGetmdlGetOutputPortWidthLevel1(S) != NULL) {
                int_T inputPortWidth = ssGetMexApiInt1(S);
                int_T yWidth = sfcnGetOutputPortWidthLevel1(S, inputPortWidth);
                ssSetMexApiInt1(S,yWidth);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlGetOutputPortWidth");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2
          case SS_CALL_MDL_SET_INPUT_PORT_WIDTH:
            if (ssGetmdlSetInputPortWidth(S) != NULL) {
                int_T port  = ssGetMexApiInt1(S);
                int_T width = ssGetMexApiInt2(S);
                sfcnSetInputPortWidth(S,port,width);
            } else {
                ssSetErrorStatus(S, "Unexpected call to "
                                 "mdlSetInputPortWidth");
            }
            break;

          case SS_CALL_MDL_SET_OUTPUT_PORT_WIDTH:
            if (ssGetmdlSetOutputPortWidth(S) != NULL) {
                int_T port  = ssGetMexApiInt1(S);
                int_T width = ssGetMexApiInt2(S);
                sfcnSetOutputPortWidth(S,port,width);
            } else {
                ssSetErrorStatus(S, "Unexpected call to "
                                 "mdlSetOutputPortWidth");
            }
            break;

          case SS_CALL_MDL_SET_INPUT_PORT_DIMENSION_INFO:
            if (ssGetmdlSetInputPortDimensions(S) != NULL) {
                int_T            port      = ssGetMexApiInt1(S);
                const DimsInfo_T *dimsInfo = (const DimsInfo_T *)
                                              ssGetMexApiVoidPtr1(S);
                sfcnSetInputPortDimensionInfo(S,port,dimsInfo);
            } else {
                ssSetErrorStatus(S, "Unexpected call to "
                                 "mdlSetInputPortDimensionInfo");
            }
            break;

          case SS_CALL_MDL_SET_OUTPUT_PORT_DIMENSION_INFO:
            if (ssGetmdlSetOutputPortDimensions(S) != NULL) {
                int_T            port      = ssGetMexApiInt1(S);
                const DimsInfo_T *dimsInfo = (const DimsInfo_T *)
                                              ssGetMexApiVoidPtr1(S);
                sfcnSetOutputPortDimensionInfo(S,port,dimsInfo);
            } else {
                ssSetErrorStatus(S, "Unexpected call to "
                                 "mdlSetOutputPortDimensionInfo");
            }
            break;

          case SS_CALL_MDL_SET_DEFAULT_PORT_DIMENSION_INFO:
            if (ssGetmdlSetDefaultPortDimensions(S) != NULL) {
                sfcnSetDefaultPortDimensionInfo(S);
            } else {
                ssSetErrorStatus(S, "Unexpected call to "
                                 "mdlSetDefaultPortDimensionInfo");
            }
            break;

          case SS_CALL_MDL_SET_INPUT_PORT_SAMPLE_TIME:
            if (ssGetmdlSetInputPortSampleTime(S) != NULL) {
                int_T  port        = ssGetMexApiInt1(S);
                real_T sampleTime  = ssGetMexApiReal1(S);
                real_T offsetTime  = ssGetMexApiReal2(S);
                sfcnSetInputPortSampleTime(S,port,sampleTime,offsetTime);
            } else {
                ssSetErrorStatus(S, "Unexpected call to "
                                 "mdlSetInputPortSampleTime");
            }
            break;

          case SS_CALL_MDL_SET_OUTPUT_PORT_SAMPLE_TIME:
            if (ssGetmdlSetOutputPortSampleTime(S) != NULL) {
                int_T  port        = ssGetMexApiInt1(S);
                real_T sampleTime  = ssGetMexApiReal1(S);
                real_T offsetTime  = ssGetMexApiReal2(S);
                sfcnSetOutputPortSampleTime(S,port,sampleTime,offsetTime);
            } else {
                ssSetErrorStatus(S, "Unexpected call to "
                                 "mdlSetOutputPortSampleTime");
            }
            break;

          case SS_CALL_MDL_SET_INPUT_PORT_DATA_TYPE:
            if (ssGetmdlSetInputPortDataType(S) != NULL) {
                int_T     port               = ssGetMexApiInt1(S);
                DTypeId inputPortDataType  = ssGetMexApiInt2(S);
                sfcnSetInputPortDataType(S,port,inputPortDataType);
            } else {
                ssSetErrorStatus(S, "Unexpected call to "
                                 "mdlSetInputPortDataType");
            }
            break;

          case SS_CALL_MDL_SET_OUTPUT_PORT_DATA_TYPE:
            if (ssGetmdlSetOutputPortDataType(S) != NULL) {
                int_T     port                = ssGetMexApiInt1(S);
                DTypeId outputPortDataType  = ssGetMexApiInt2(S);
                sfcnSetOutputPortDataType(S,port,outputPortDataType);
            } else {
                ssSetErrorStatus(S,"Unexpected call to "
                                 "mdlSetOutputPortDataType");
            }
            break;

          case SS_CALL_MDL_SET_DEFAULT_PORT_DATA_TYPES:
            if (ssGetmdlSetDefaultPortDataTypes(S) != NULL) {
                sfcnSetDefaultPortDataTypes(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to "
                                 "mdlSetDefaultPortDataTypes");
            }
            break;


          case SS_CALL_MDL_SET_INPUT_PORT_COMPLEX_SIGNAL:
            if (ssGetmdlSetInputPortComplexSignal(S) != NULL) {
                int_T port               = ssGetMexApiInt1(S);
                int_T iPortComplexSignal = (int_T)ssGetMexApiInt2(S);
                sfcnSetInputPortComplexSignal(S,port,iPortComplexSignal);
            } else {
                ssSetErrorStatus(S, "Unexpected call to "
                                 "mdlSetInputPortComplexSignal");
            }
            break;

          case SS_CALL_MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL:
            if (ssGetmdlSetOutputPortComplexSignal(S) != NULL) {
                int_T port                = ssGetMexApiInt1(S);
                int_T oPortComplexSignal  = (int_T)ssGetMexApiInt2(S);
                sfcnSetOutputPortComplexSignal(S,port,oPortComplexSignal);
            } else {
                ssSetErrorStatus(S,"Unexpected call to "
                                 "mdlSetOutputPortComplexSignal");
            }
            break;

          case SS_CALL_MDL_SET_DEFAULT_PORT_COMPLEX_SIGNALS:
            if (ssGetmdlSetDefaultPortComplexSignals(S) != NULL) {
                sfcnSetDefaultPortComplexSignals(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to "
                                 "mdlSetDefaultPortComplexSignals");
            }
            break;

          case SS_CALL_MDL_SET_INPUT_PORT_FRAME_DATA:
            if (ssGetmdlSetInputPortFrameData(S) != NULL) {
                int_T   port               = ssGetMexApiInt1(S);
                Frame_T inputPortFrameData = (Frame_T)ssGetMexApiInt2(S);
                sfcnSetInputPortFrameData(S,port,inputPortFrameData);
            } else {
                ssSetErrorStatus(S, "Unexpected call to "
                                 "mdlSetInputPortFrameData");
            }
            break;

#         endif

          case SS_CALL_MDL_INITIALIZE_SAMPLE_TIMES:
            mdlInitializeSampleTimes(S);
            break;

          case SS_CALL_MDL_SET_WORK_WIDTHS:
            if (ssGetmdlSetWorkWidths(S) != NULL) {
                sfcnSetWorkWidths(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlSetWorkWidths");
            }
            break;

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_RTW)
          case SS_CALL_MDL_RTW:
            if (ssGetmdlRTW(S) != NULL) {
                sfcnRTW(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlRTW");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 1
          case SS_CALL_MDL_INITIALIZE_CONDITIONS:
            mdlInitializeConditions(ssGetX(S),S);
            break;
#         elif defined(MDL_INITIALIZE_CONDITIONS)
          case SS_CALL_MDL_INITIALIZE_CONDITIONS:
            if (ssGetmdlInitializeConditions(S) != NULL) {
                mdlInitializeConditions(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to "
                                 "mdlInitializeConditions");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_START)
          case SS_CALL_MDL_START:
            if (ssGetmdlStart(S) != NULL) {
                mdlStart(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlStart");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(RTW_GENERATED_ENABLE)
          case SS_CALL_RTW_GENERATED_ENABLE:
            if (ssGetRTWGeneratedEnable(S) != NULL) {
                mdlEnable(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlEnable");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(RTW_GENERATED_DISABLE)
          case SS_CALL_RTW_GENERATED_DISABLE:
            if (ssGetRTWGeneratedDisable(S) != NULL) {
                mdlDisable(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlDisable");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_ENABLE)
          case SS_CALL_MDL_ENABLE:
            if (ssGetmdlEnable(S) != NULL) {
                mdlEnable(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlEnable");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_DISABLE)
          case SS_CALL_MDL_DISABLE:
            if (ssGetmdlDisable(S) != NULL) {
                mdlDisable(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlDisable");
            }
            break;
#         endif

          case SS_CALL_MDL_CHECK_PARAMETERS:
            if (ssGetmdlCheckParameters(S) != NULL) {
                sfcnCheckParameters(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlCheckParameters");
            }
            break;

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_PROCESS_PARAMETERS)
          case SS_CALL_MDL_PROCESS_PARAMETERS:
            if (ssGetmdlProcessParameters(S) != NULL) {
                sfcnProcessParameters(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlProcessParameters");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_EXT_MODE_EXEC)
          case SS_CALL_MDL_EXT_MODE_EXEC:
            if (ssGetmdlExtModeExec(S) != NULL) {
                sfcnExtModeExec(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlExtModeExec");
            }
            break;
#         endif

          case SS_CALL_MDL_GET_TIME_OF_NEXT_VAR_HIT:
            mdlGetTimeOfNextVarHit(S);
            break;

          case SS_CALL_MDL_OUTPUTS:
#           if S_FUNCTION_LEVEL == 1
                mdlOutputs(ssGetY(S),ssGetX(S),ssGetU(S),S,0);
#           else
                if(ssGetMexApiInt1(S) == CONSTANT_TID) {
                    mdlOutputs(S,CONSTANT_TID);
                } else {
                    mdlOutputs(S,0);
                }
#           endif
            break;

#         if S_FUNCTION_LEVEL == 1
          case SS_CALL_MDL_UPDATE:
            mdlUpdate(ssGetX(S),ssGetU(S),S,0);
            break;
#         elif defined(MDL_UPDATE)
          case SS_CALL_MDL_UPDATE:
            if (ssGetmdlUpdate(S) != NULL) {
                mdlUpdate(S,0);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlUpdate");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 1
          case SS_CALL_MDL_DERIVATIVES:
            mdlDerivatives(ssGetdX(S),ssGetX(S),ssGetU(S),S,0);
            break;
#         elif defined(MDL_DERIVATIVES)
          case SS_CALL_MDL_DERIVATIVES:
            if (ssGetmdlDerivatives(S) != NULL) {
                mdlDerivatives(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlDerivatives");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_JACOBIAN)
	  case SS_CALL_MDL_JACOBIAN:
            if (ssGetmdlJacobian(S) != NULL) {
                mdlJacobian(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlJacobian");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_PROJECTION)
	  case SS_CALL_MDL_PROJECTION:
            if (ssGetmdlProjection(S) != NULL) {
                mdlProjection(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlProjection");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_MASSMATRIX)
	  case SS_CALL_MDL_MASSMATRIX:
            if (ssGetmdlMassMatrix(S) != NULL) {
                mdlMassMatrix(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlMassMatrix");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_FORCINGFUNCTION)
	  case SS_CALL_MDL_FORCINGFUNCTION:
            if (ssGetmdlForcingFunction(S) != NULL) {
                mdlForcingFunction(S);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlForcingFunction");
            }
            break;
#         endif

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_RTWCG)
	  case SS_CALL_MDL_RTWCG:
            if (ssGetmdlRTWCG(S) != NULL) {
                RTWCGInterface *iObj = (RTWCGInterface *) ssGetMexApiVoidPtr1(S);
                mdlRTWCG(S,iObj);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlRTWCG");
            }
            break;
#         endif

          case SS_CALL_MDL_ZERO_CROSSINGS:
            mdlZeroCrossings(S);
            break;

          case SS_CALL_MDL_TERMINATE:
            __mdlTerminate(S);
            break;

#         if S_FUNCTION_LEVEL == 2 && defined(MDL_SIM_STATUS_CHANGE)           
          case SS_CALL_MDL_SIM_STATUS_CHANGE:
            if (ssGetmdlSimStatusChange(S) != NULL) {
                ssSimStatusChangeType simStatus = (ssSimStatusChangeType)ssGetMexApiInt1(S);
                __mdlSimStatusChange(S, simStatus);
            } else {
                ssSetErrorStatus(S,"Unexpected call to mdlSimStatusChange");
            }
            break;
#         endif

          default:
            ssSetErrorStatus(S,"Invalid flag encountered in simulink.c");
            break;
        }

    } else {

#ifdef PROCESS_MEX_SFUNCTION_CMD_LINE_CALL
        if(ProcessMexSfunctionCmdLineCall(nlhs,plhs,nrhs,prhs)) {
            return;
        }
#endif
        _ProcessMexSfunctionCmdLineCall(nlhs,plhs,nrhs,prhs);
    }

} /* end mexFunction */



/* EOF simulink.c */
