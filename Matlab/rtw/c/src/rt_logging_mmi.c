/* $Revision: 1.1.6.5 $
 *
 * Copyright 1994-2004 The MathWorks, Inc.
 *
 * File: rt_logging_mmi.c
 *
 * Abstract:
 */

#ifndef rt_logging_c
#define rt_logging_c

#include <stdlib.h>
#include "rtwtypes.h"
#include "rtw_matlogging.h"
#include "rtw_modelmap.h"

static const char_T rtMemAllocError[] = "Memory allocation error";
#define FREE(m) if (m != NULL) free(m)

/* Function: rt_FillStateSigInfoFromMMI =======================================
 * Abstract:
 * 
 * Returns:
 *	== NULL  => success.
 *	~= NULL  => failure, the return value is a pointer to the error
 *                           message, which is also set in the simstruct.
 */
const char_T * rt_FillStateSigInfoFromMMI(RTWLogInfo   *li,
                                                 const char_T **errStatus)
{
    int_T                  i;
    int_T                  nSignals     = 0;
    int_T                  *dims        = NULL;
    BuiltInDTypeId         *dTypes      = NULL;
    int_T                  *cSgnls      = NULL;
    const char_T           **labels     = NULL;
    const char_T           **blockNames = NULL;
    boolean_T              *crossMdlRef = NULL;
    const void             **sigDataAddr = NULL;
    int_T                  *logDataType = NULL;

    const rtwCAPI_ModelMappingInfo *mmi         = (const rtwCAPI_ModelMappingInfo *)rtliGetMMI(li);

    int_T                  sigIdx       = 0;

    RTWLogSignalInfo *     sigInfo;
    /* reset error status */
    *errStatus = NULL;

    sigInfo = (RTWLogSignalInfo *)calloc(1,sizeof(RTWLogSignalInfo));
    if (sigInfo == NULL) goto ERROR_EXIT;

    nSignals = rtwCAPI_GetNumStateRecords(mmi);

    if (nSignals >0) {
        /* These are all freed before exiting this function */
        dims        = (int_T *)calloc(nSignals,sizeof(int_T));
        if (dims == NULL) goto ERROR_EXIT;
        dTypes      = (BuiltInDTypeId *)calloc(nSignals,sizeof(BuiltInDTypeId));
        if (dTypes == NULL) goto ERROR_EXIT;
        cSgnls      = (int_T *)calloc(nSignals,sizeof(int_T));
        if (cSgnls == NULL) goto ERROR_EXIT;
        labels      = (const char **)calloc(nSignals, sizeof(char*));
        if (labels == NULL) goto ERROR_EXIT;
        blockNames  = (const char**)calloc(nSignals, sizeof(const char*));
        if (blockNames == NULL) goto ERROR_EXIT;
        crossMdlRef  = (boolean_T*)calloc(nSignals, sizeof(boolean_T));
        if (crossMdlRef == NULL) goto ERROR_EXIT;
        logDataType = (int_T *)calloc(nSignals,sizeof(int_T));
        if (logDataType == NULL) goto ERROR_EXIT;
        
        /* This is freed in stopDataLogging (it's needed in the meantime) */
        sigDataAddr = (const void **)calloc(nSignals,sizeof(void *));
        if (sigDataAddr == NULL) goto ERROR_EXIT;
        
        *errStatus = rtwCAPI_GetStateRecordInfo(mmi,
                                                blockNames,
                                                labels,
                                                dims,
                                                (int_T*)dTypes,
                                                logDataType,
                                                cSgnls,
                                                sigDataAddr,
                                                crossMdlRef,
                                                &sigIdx,
                                                false);
        
        if (*errStatus != NULL) goto ERROR_EXIT;
        
        rtliSetLogXSignalPtrs(li,(LogSignalPtrsType)sigDataAddr);
    }
    
    sigInfo->numSignals = nSignals;
    sigInfo->numCols = dims;
    sigInfo->numDims = NULL;
    sigInfo->dims = dims;
    sigInfo->dataTypes = dTypes;
    sigInfo->complexSignals = cSgnls;
    sigInfo->frameData = NULL;
    sigInfo->labels = labels;
    sigInfo->titles = NULL;
    sigInfo->titleLengths = NULL;
    sigInfo->plotStyles = NULL;
    sigInfo->blockNames = blockNames;
    sigInfo->crossMdlRef = crossMdlRef;
    sigInfo->dataTypeConvert = NULL;

    rtliSetLogXSignalInfo(li,sigInfo);

    /* Free logDataType it's not needed any more,
     * the rest of them will be freed later */
    FREE(logDataType);
    return(NULL); /* NORMAL_EXIT */

  ERROR_EXIT: 
    if (*errStatus == NULL) {
        *errStatus = rtMemAllocError;
    }
    /* Free local stuff that was allocated. It is no longer needed */
    for (i = 0; i < nSignals; ++i) utFree((void*)(blockNames[i]));
    FREE(blockNames);
    FREE(labels);
    FREE(dims);
    FREE(dTypes);
    FREE(logDataType);
    FREE(cSgnls);

    return(*errStatus);

} /* end rt_InitSignalsStruct */

void rt_CleanUpForStateLogWithMMI(RTWLogInfo *li)
{
    int_T i;
    const RTWLogSignalInfo *sigInfo = rtliGetLogXSignalInfo(li);

    for (i = 0; i < sigInfo->numSignals; ++i) utFree((void*)(sigInfo->blockNames[i]));
    FREE(sigInfo->blockNames);
    FREE(sigInfo->crossMdlRef);
    FREE(sigInfo->labels);
    FREE(sigInfo->dims);
    FREE(sigInfo->dataTypes);
    FREE(sigInfo->complexSignals);

    FREE((RTWLogSignalInfo *)sigInfo);
    rtliSetLogXSignalInfo(li, NULL);

    FREE((void**)rtliGetLogXSignalPtrs(li));
    rtliSetLogXSignalPtrs(li,NULL);
}


#endif /*  rt_logging_c */
