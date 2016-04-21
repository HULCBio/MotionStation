/******************************************************************************
 *                                                                            *
 * File    : simstruc.c                                     $Revision: 1.7 $  *
 * Abstract:                                                                  *
 *      Access methods to set and get selected fields of the SimStruct.       *
 *                                                                            *
 * Author : Murali Yeddanapudi, 19-May-1999                                   *
 *                                                                            *
 * Copyright 1990-2002 The MathWorks, Inc.
 *                                                                            *
 ******************************************************************************/


/* Required Definitions */

#ifndef S_FUNCTION_NAME
# error "Must Define S_FUNCTION_NAME"
#endif

#ifndef S_FUNCTION_LEVEL
# error "Must Define S_FUNCTION_LEVEL"
#endif

#include "simstruc.h"

#define MAX_STR_LEN 4096


/******************************************************************************
 *********************** Other Model-Specific Attributes **********************
 ******************************************************************************/


/* Function: slGetT ============================================================
 *
 */
real_T slGetT(SimStruct *S)
{
    return( ssGetT(S) );

} /* end: ssGetT */


/* Function: slGetTStart =======================================================
 *
 */
real_T slGetTStart(SimStruct *S)
{
    return( ssGetTStart(S) );

} /* end: ssGetTStart */


/* Function: slGetTFinal =======================================================
 *
 */
real_T slGetTFinal(SimStruct *S)
{
    return( ssGetTFinal(S) );

} /* end: ssGetTFinal */


/* Function: slIsMajorTimeStep =================================================
 *
 */
int_T slIsMajorTimeStep(SimStruct *S)
{
    return( ssIsMajorTimeStep(S) );

} /* end: slIsMajorTimeStep */


/* Function: slIsMinorTimeStep =================================================
 *
 */
int_T slIsMinorTimeStep(SimStruct *S)
{
    return( ssIsMinorTimeStep(S) );

} /* end: slIsMinorTimeStep */


/* Function: slG(S)etErrorStatus ===============================================
 *
 */
const char * slGetErrorStatus(SimStruct *S)
{
    return( ssGetErrorStatus(S) );
}

void slSetErrorStatus(SimStruct *S, const char *msg)
{
    static char errMsg[MAX_STR_LEN]="\0";

    (void)strncpy(errMsg, msg, MAX_STR_LEN-1);
    ssSetErrorStatus(S, errMsg);
}
/* end: slG(S)etErrorStatus */


/* Function: slDisplayMessage ==================================================
 *
 */
void slDisplayMessage(const char *msg)
{
    ssPrintf("%s\n", msg);
}
/* end: slDisplayMessage */



/******************************************************************************
 *********************** Other Block-Specific Attributes **********************
 ******************************************************************************/


/* Function: slGetPath =========================================================
 *
 */
const char *slGetPath(SimStruct *S)
{
    return( ssGetPath(S) );

} /* end: ssGetPath */


/* Function: slGetSampleTimePeriod =============================================
 *
 */
time_T slGetSampleTimePeriod(SimStruct *S)
{
    return( ssGetSampleTime(S,0) );
}

/* Function: slGetSampleTimeOffset =============================================
 *
 */
time_T slGetSampleTimeOffset(SimStruct *S)
{
    return( ssGetOffsetTime(S,0) );
}


/* Function: slSetSampleTime ===================================================
 *
 */
int_T slSetSampleTime(SimStruct *S, time_T period, time_T offset)
{
    LocalData *ud = ssGetUserData(S);

    if (ud == NULL) {
        return(0);
    }

    ud->sampleTime.period = period;
    ud->sampleTime.offset = offset;

    return(1);

} /* end: slSetSampleTime */


/* Function: slSetOptionInputScalarExpansion ===================================
 *
 */
void slSetOptionInputScalarExpansion(SimStruct *S, int_T val)
{
    if (val) {
        ssSetOptions(S, (ssGetOptions(S)) |
                        SS_OPTION_ALLOW_INPUT_SCALAR_EXPANSION );
    } else {
        ssSetOptions(S, (ssGetOptions(S)) &
                        (~SS_OPTION_ALLOW_INPUT_SCALAR_EXPANSION) );
    }
} /* end: slSetOptionInputScalarExpansion */



/******************************************************************************
 ************************* Continuous State Attributes ************************
 ******************************************************************************/


/* Function: slG(S)etNumContStates =============================================
 *
 */
int_T slGetNumContStates(SimStruct *S)
{
    return( ssGetNumContStates(S) );
}

int_T slSetNumContStates(SimStruct *S, int_T nContStates)
{
    return(ssSetNumContStates(S,nContStates));
}
/* end: slG(S)etNumContStates */


/* Function: slGetContStateAddress =============================================
 *
 */
void *slGetContStateAddress(SimStruct *S)
{
    return( ssGetContStates(S) );
}
/* end: slGetContStateAddress */


/******************************************************************************
 **************************** Input Port Attributes ***************************
 ******************************************************************************/


/* Function: slG(S)etNumInputPorts =============================================
 *
 */
int_T slGetNumInputPorts(SimStruct *S)
{
    return( ssGetNumInputPorts(S) );
}

int_T slSetNumInputPorts(SimStruct *S, int_T nInputPorts)
{
    return( ssSetNumInputPorts(S,nInputPorts) );
}
/* end: slG(S)etNumInputPorts */



/* Function: slG(S)etInputPortWidth ============================================
 *
 */
int_T slGetInputPortWidth(SimStruct *S, int_T portIdx)
{
    return( ssGetInputPortWidth(S,portIdx) );
}

void slSetInputPortWidth(SimStruct *S, int_T portIdx, int_T width)
{
    ssSetInputPortWidth(S,portIdx,width);
}
/* end: slG(S)etInputPortWidth */



/* Function: slG(S)etInputPortDataType =========================================
 *
 */
int_T slGetInputPortDataType(SimStruct *S, int_T portIdx)
{
    return( ssGetInputPortDataType(S,portIdx) );
}

void slSetInputPortDataType(SimStruct *S, int_T portIdx, int_T dataType)
{
    ssSetInputPortDataType(S,portIdx,dataType);
}
/* end: slG(S)etInputPortDataType */



/* Function: slG(S)etInputPortDirectFeedThrough ================================
 *
 */
int_T slGetInputPortDirectFeedThrough(SimStruct *S, int_T portIdx)
{
    return( ssGetInputPortDirectFeedThrough(S,portIdx) );
}

void slSetInputPortDirectFeedThrough(SimStruct *S, int_T portIdx, int_T dF)
{
    ssSetInputPortDirectFeedThrough(S,portIdx,dF);
}
/* end: slG(S)etInputPortDirectFeedThrough */



/* Function: slG(S)etInputPortOptimizationLevel ================================
 *
 */
int_T slGetInputPortOptimizationLevel(SimStruct *S, int_T portIdx)
{
    int_T ans = ssGetInputPortOptimOpts(S,portIdx);

    switch (ans) {
      case SS_NOT_REUSABLE_AND_GLOBAL :
        return(0);
      case SS_NOT_REUSABLE_AND_LOCAL  :
        return(1);
      case SS_REUSABLE_AND_GLOBAL     :
        return(2);
      case SS_REUSABLE_AND_LOCAL      :
        return(2);
      default:
        return(0);
    }
}

void slSetInputPortOptimizationLevel(SimStruct *S, int_T portIdx, int_T val)
{
    switch (val) {
      case 1:
        ssSetInputPortOptimOpts(S,portIdx, SS_NOT_REUSABLE_AND_LOCAL);
        break;
      case 2:
        ssSetInputPortOptimOpts(S,portIdx, SS_REUSABLE_AND_GLOBAL);
        break;
      case 3:
        ssSetInputPortOptimOpts(S,portIdx, SS_REUSABLE_AND_LOCAL);
        break;
      default:
        ssSetInputPortOptimOpts(S,portIdx, SS_NOT_REUSABLE_AND_GLOBAL);
        break;
    }
}
/* end: slG(S)etInputPortOptimizationLevel */



/* Function: slG(S)etInputPortOverWritable =====================================
 *
 */
int_T slGetInputPortOverWritable(SimStruct *S, int_T portIdx)
{
    return( ssGetInputPortOverWritable(S,portIdx) );
}

void slSetInputPortOverWritable(SimStruct *S, int_T portIdx, int_T val)
{
    ssSetInputPortOverWritable(S,portIdx,val);
}
/* end: slG(S)etInputPortOverWritable */



/* Function: slGetInputPortSignalAddress =======================================
 *
 */
const void *slGetInputPortSignalAddress(SimStruct *S, int_T portIdx)
{
    return( ssGetInputPortSignal(S,portIdx) );
}
/* end: slGetInputPortSignalAddress */



/* Function: slGetInputPortSignalElementAddress ================================
 *
 */
const void *slGetInputPortSignalElementAddress(SimStruct *S,int_T port,int_T el)
{
    return( (ssGetInputPortSignalPtrs(S,port))[el] );
}
/* end: slGetInputPortSignalElementAddress */



/******************************************************************************
 *************************** Output Port Attributes ***************************
 ******************************************************************************/



/* Function: slG(S)etNumOutputPorts ============================================
 *
 */
int_T slGetNumOutputPorts(SimStruct *S)
{
    return( ssGetNumOutputPorts(S) );
}

int_T slSetNumOutputPorts(SimStruct *S, int_T nOutputPorts)
{
    return( ssSetNumOutputPorts(S,nOutputPorts) );
}
/* end: slG(S)etNumOutputPorts */



/* Function: slG(S)etOutputPortWidth ===========================================
 *
 */
int_T slGetOutputPortWidth(SimStruct *S, int_T portIdx)
{
    return( ssGetOutputPortWidth(S,portIdx) );
}

void slSetOutputPortWidth(SimStruct *S, int_T portIdx, int_T width)
{
    ssSetOutputPortWidth(S,portIdx,width);
}
/* end: slG(S)etOutputPortWidth */



/* Function: slG(S)etOutputPortDataType ========================================
 *
 */
int_T slGetOutputPortDataType(SimStruct *S, int_T portIdx)
{
    return( ssGetOutputPortDataType(S,portIdx) );
}

void slSetOutputPortDataType(SimStruct *S, int_T portIdx, int_T dataType)
{
    ssSetOutputPortDataType(S,portIdx,dataType);
}
/* end: slG(S)etOutputPortDataType */



/* Function: slG(S)etOutputPortOptimizationLevel ===============================
 *
 */
int_T slGetOutputPortOptimizationLevel(SimStruct *S, int_T portIdx)
{
    int_T ans = ssGetOutputPortOptimOpts(S,portIdx);

    switch (ans) {
      case SS_NOT_REUSABLE_AND_GLOBAL :
        return(0);
      case SS_NOT_REUSABLE_AND_LOCAL  :
        return(1);
      case SS_REUSABLE_AND_GLOBAL     :
        return(2);
      case SS_REUSABLE_AND_LOCAL      :
        return(2);
      default:
        return(0);
    }
}

void slSetOutputPortOptimizationLevel(SimStruct *S, int_T portIdx, int_T val)
{
    switch (val) {
      case 1:
        ssSetOutputPortOptimOpts(S,portIdx, SS_NOT_REUSABLE_AND_LOCAL);
        break;
      case 2:
        ssSetOutputPortOptimOpts(S,portIdx, SS_REUSABLE_AND_GLOBAL);
        break;
      case 3:
        ssSetOutputPortOptimOpts(S,portIdx, SS_REUSABLE_AND_LOCAL);
        break;
      default:
        ssSetOutputPortOptimOpts(S,portIdx, SS_NOT_REUSABLE_AND_GLOBAL);
        break;
    }
}
/* end: slG(S)etOutputPortOptimizationLevel */



/* Function: slGetOutputPortSignalAddress ======================================
 *
 */
void *slGetOutputPortSignalAddress(SimStruct *S, int_T portIdx)
{
    return( ssGetOutputPortSignal(S,portIdx) );
}

/* end: slGetOutputPortSignalAddress */


/******************************************************************************
 *************************** Work Vector Attributes ***************************
 ******************************************************************************/


/* Function: slG(S)etNumWorkVectors ============================================
 *
 */
int_T slGetNumWorkVectors(SimStruct *S)
{
    return( ssGetNumDWork(S) );
}

int_T slSetNumWorkVectors(SimStruct *S, int_T numVectors)
{
    LocalData *ud = ssGetUserData(S);

    if (ud->workVectorNames != NULL) {
        int_T i;
        for (i = 0; i < ssGetNumDWork(S); i++) {
            char *name = ud->workVectorNames[i];
            if (name != NULL) {
                mxFree(name);
                ssSetDWorkName(S,i,NULL);
            }
        }
        mxFree(ud->workVectorNames);
    }
    if (numVectors > 0) {
        ud->workVectorNames = mxCalloc(numVectors, sizeof(char*));
        if (ud->workVectorNames == NULL) {
            ssSetErrorStatus(S, "Memory Allocation Error");
            return(0);
        }
        mexMakeMemoryPersistent(ud->workVectorNames);
    }
    return(ssSetNumDWork(S,numVectors));
}
/* end: slG(S)etNumWorkVectors */


/* Function: slG(S)etWorkVectorWidth ===========================================
 *
 */
int_T slGetWorkVectorWidth(SimStruct *S, int_T idx)
{
    return( ssGetDWorkWidth(S,idx) );
}

void slSetWorkVectorWidth(SimStruct *S, int_T idx, int_T width)
{
    ssSetDWorkWidth(S,idx,width);
}
/* end: slG(S)etWorkVectorWidth */


/* Function: slG(S)etWorkVectorDataType ========================================
 *
 */
int_T slGetWorkVectorDataType(SimStruct *S, int_T idx)
{
    return( ssGetDWorkDataType(S,idx) );
}

void slSetWorkVectorDataType(SimStruct *S, int_T idx, int_T dType)
{
    ssSetDWorkDataType(S,idx,dType);
}
/* end: slG(S)etWorkVectorDataType */


/* Function: slG(S)etWorkVectorName ============================================
 *
 */
const char * slGetWorkVectorName(SimStruct *S, int_T idx)
{
    return( ssGetDWorkName(S,idx) );
}

int_T slSetWorkVectorName(SimStruct *S, int_T idx, const char *name)
{
    int       nameLen  = strlen(name)+1;
    char      *dupName = mxMalloc(nameLen*sizeof(char));
    LocalData *ud      = ssGetUserData(S);
    char      **wNames = ud->workVectorNames;

    if (dupName == NULL) {
        return(0);
    }
    mexMakeMemoryPersistent(dupName);

    (void)strcpy(dupName, name);
    ssSetDWorkName(S, idx, dupName);
    wNames[idx] = dupName;
    return(1);
}
/* end: slG(S)etWorkVectorName */


/* Function: slG(S)etWorkVectorUsedAsState =====================================
 *
 */
int_T slGetWorkVectorUsedAsState(SimStruct *S, int_T idx)
{
    return( ssGetDWorkUsedAsDState(S,idx) );
}

void slSetWorkVectorUsedAsState(SimStruct *S, int_T idx, int_T setting)
{
    ssSetDWorkUsedAsDState(S,idx, setting);
}
/* end: slG(S)etWorkVectorUsedAsState */



/* Function: slGetWorkVectorAddress ============================================
 *
 */
void *slGetWorkVectorAddress(SimStruct *S, int_T portIdx)
{
    return( ssGetDWork(S,portIdx) );
}

/* end: slGetWorkVectorAddress */



/******************************************************************************
 **************************** Parameter Attributes ****************************
 ******************************************************************************/



/* Function: slGetNumParameters ================================================
 *
 */
int_T slGetNumParameters(SimStruct *S)
{
    return( ssGetSFcnParamsCount(S) );
}
/* end: slGetNumParameters */


/* Function: slGetParameterWidth ===============================================
 *
 */
int_T slGetParameterWidth(SimStruct *S, int_T pIdx)
{
    return( mxGetNumberOfElements( ssGetSFcnParam(S,pIdx) ) );

} /* end: slGetParameterWidth */


/* Function: slGetParameterNumDimensions =======================================
 *
 */
int_T slGetParameterNumDimensions(SimStruct *S, int_T pIdx)
{
    return( mxGetNumberOfDimensions( ssGetSFcnParam(S,pIdx) ) );

} /* end: slGetParameterNumDimensions */


/* Function: slGetParameterDimensions ==========================================
 *
 */
const int_T *slGetParameterDimensions(SimStruct *S, int_T pIdx)
{
    return( mxGetDimensions( ssGetSFcnParam(S,pIdx) ) );

} /* end: slGetParameterDimensions */


/* Function: slGetParameterDataType ============================================
 *
 */
int_T slGetParameterDataType(SimStruct *S, int_T pIdx)
{
    int_T dataType;
    const mxArray *pm = ssGetSFcnParam(S,pIdx);

    if (mxGetClassID(pm) == mxCHAR_CLASS) {
        dataType = SS_UINT16;
    } else {
        dataType = ssGetDTypeIdFromMxArray(pm);
    }
    return(dataType);

} /* end: slGetParameterDataType */


/* Function: slGetParameterAddress =============================================
 *
 */
void *slGetParameterAddress(SimStruct *S, int_T pIdx)
{
    return( mxGetData( ssGetSFcnParam(S,pIdx) ) );

} /* end: slGetParameterAddress */


/* Function: slGetParameterIsChar ============================================
 *
 */
int_T slGetParameterIsChar(SimStruct *S, int_T pIdx)
{
    return( mxIsChar( ssGetSFcnParam(S,pIdx) ) );

} /* end: slGetParameterIsChar */


/* Function: slGetParameterIsComplex =========================================
 *
 */
int_T slGetParameterIsComplex(SimStruct *S, int_T pIdx)
{
    return( mxIsComplex( ssGetSFcnParam(S,pIdx) ) );

} /* end: slGetParameterIsComplex */


/* Function: slGetParameterIsDouble ==========================================
 *
 */
int_T slGetParameterIsDouble(SimStruct *S, int_T pIdx)
{
    return( mxIsDouble( ssGetSFcnParam(S,pIdx) ) );

} /* end: slGetParameterIsDouble */


/* Function: slGetParameterIsLogical =========================================
 *
 */
int_T slGetParameterIsLogical(SimStruct *S, int_T pIdx)
{
    return( mxIsLogical( ssGetSFcnParam(S,pIdx) ) );

} /* end: slGetParameterIsLogical */


/* Function: slGetParameterIsNumeric ===========================================
 *
 */
int_T slGetParameterIsNumeric(SimStruct *S, int_T pIdx)
{
    return( mxIsNumeric( ssGetSFcnParam(S,pIdx) ) );

} /* end: slParameterIsNumeric */


/* Function: slGetParameterIsFinite ============================================
 *
 */
int_T slGetParameterIsFinite(SimStruct *S, int_T pIdx)
{
    const mxArray *m = ssGetSFcnParam(S,pIdx);

    if ( mxIsDouble(m) ) {
        real_T *data = mxGetPr(m);
        int_T  numEl = mxGetNumberOfElements(m);
        int_T  i;

        for (i = 0; i < numEl; i++) {
            if ( !mxIsFinite(data[i]) ) {
                return(0);
            }
        }
    }

    return(1);

} /* end: slGetParameterIsFinite */


/* Function: slGetStringParameter ==============================================
 *
 */
const char *slGetStringParameter(SimStruct *S, int_T pIdx)
{
    static char   strBuf[MAX_STR_LEN] = "\0";
    const char    *ans                = NULL;
    const mxArray *pm                 = ssGetSFcnParam(S,pIdx);

    if (mxGetClassID(pm) == mxCHAR_CLASS) {
        if ( mxGetString(pm, strBuf, MAX_STR_LEN) == 0 ) {
            ans = strBuf;
        } else if (ssGetErrorStatus(S) == NULL) {
            ssSetErrorStatus(S,"Error :: in slGetParameterCastAsString, "
                             "String too long.");
        }
    }

    return(ans);

} /* end: slGetStringParameter */


/* Function: slG(S)etParameterTunable ==========================================
 *
 */
int_T slGetParameterTunable(SimStruct *S, int_T pIdx)
{
    return(ssGetSFcnParamTunable(S,pIdx));
}
void slSetParameterTunable(SimStruct *S, int_T pIdx, int_T val)
{
    ssSetSFcnParamTunable(S,pIdx,val);
}
/* end: slG(S)etParameterTunable */


/* Function: slG(S)etParameterName ============================================
 *
 */
const char *slGetParameterName(SimStruct *S, int_T pIdx)
{
    LocalData  *ud      = ssGetUserData(S);
    char       **pNames = ud->parameterNames;
    return( pNames[pIdx] );
}

int_T slSetParameterName(SimStruct *S, int_T pIdx, const char *name)
{
    int       nameLen  = strlen(name)+1;
    char      *dupName = mxMalloc(nameLen*sizeof(char));
    LocalData *ud      = ssGetUserData(S);
    char      **pNames = ud->parameterNames;

    if (dupName == NULL) {
        return(0);
    }
    mexMakeMemoryPersistent(dupName);

    (void)strcpy(dupName, name);
    pNames[pIdx] = dupName;
    return(1);
}
/* end: slG(S)etParameterName */


/****************************** EOF: simstruc.c *******************************/
