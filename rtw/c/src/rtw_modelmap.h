/*
 * Copyright 1994-2004 The MathWorks, Inc.
 *
 * File: rtw_modelmap.h     $Revision: 1.1.6.10 $
 *
 * Abstract:
 *   Model tuning information.  Use the provided structure access methods
 *   whenever possible.
 *
 *   For details about these structures see Real-Time Workshop User's guide.
 */

#ifndef __RTW_MODELMAP__
#define __RTW_MODELMAP__

#ifdef SL_INTERNAL

# include "version.h"
# include "util.h"

#else

# include <stdlib.h>

# define  utFree(arg)    if (arg) free(arg)
# define  utMalloc(arg)  malloc(arg)

#endif

#include <rtwtypes.h>
#include <rtw_capi.h>

typedef struct rtwCAPI_ModelMappingInfo_tag rtwCAPI_ModelMappingInfo;
typedef struct rtwCAPI_ModelMappingStaticInfo_tag rtwCAPI_ModelMappingStaticInfo;

/* ModelMappingStaticInfo */
struct rtwCAPI_ModelMappingStaticInfo_tag {
    /* signals */
    struct {
        rtwCAPI_Signals const *signals;   /* Signals Array */
        uint_T                numSignals; /* Num Signals   */
    } Signals;

    /* parameters */
    struct {
        rtwCAPI_BlockParameters const *blockParameters;   /* Block parameters Array   */
        uint_T                       numBlockParameters; /* Num block parameters     */
        rtwCAPI_ModelParameters const *modelParameters;   /* Model parameters Array*/
        uint_T                       numModelParameters; /* Num Model parameters  */
    } Params;

    /* states */
    struct {
        rtwCAPI_States const *states;   /* States array */
        uint_T              numStates; /* Num States   */
    } States;

    /* Static maps */
    /* datatypes, dimensions, fixed point, structure elements, sample times  */
    struct {
        rtwCAPI_DataTypeMap   const   *dataTypeMap;       /* Data Type Map          */
        rtwCAPI_DimensionMap  const   *dimensionMap;      /* Data Dimension Map     */
        rtwCAPI_FixPtMap      const   *fixPtMap;          /* Fixed Point Map        */
        rtwCAPI_ElementMap    const   *elementMap;        /* Structure Element map  */
        rtwCAPI_SampleTimeMap const   *sampleTimeMap;     /* Sample Times Map       */
        uint_T        const   *dimensionArray;    /* Dimension Array        */
    } Maps;
    
    /* TargetType - string specifying the intended target of the generated  *
     * C-API.                                                               *
     * targetType = "float"   - target supports floats and integer code     *
     *            = "integer" - target supports integer only code           */
    char_T const     *targetType;
};

/* ModelMappingInfo */
struct rtwCAPI_ModelMappingInfo_tag {
    /* ModelMappingInfo version */
    uint8_T                 versionNum; 

    /* Reference to static model data, all model instances share this map   */
    rtwCAPI_ModelMappingStaticInfo *staticMap;

    /* Instance specific Maps, each model instance has a unique InstanceMap */
    struct {
        const char        *path;                /* Path to this instance */     
        char*             fullPath;
        void*             *dataAddrMap;         /* Data Address map      */
        void*             *systemRanArray;    /* array of sys breadcrumbs */
        uint_T             systemRanArrayLen; /* length of systemRanArray */
        rtwCAPI_ModelMappingInfo **childMMIArray;/* array of child MMI    */
        uint_T             childMMIArrayLen;    /* Number of child MMIs  */
    } InstanceMap;
};

/* Macros for accessing ModelMappingInfo fields */

#define rtwCAPI_GetSignals(MMI)         ((MMI)->staticMap->Signals.signals)
#define rtwCAPI_GetNumSignals(MMI)      ((MMI)->staticMap->Signals.numSignals)
#define rtwCAPI_GetLogSignalsArray(MMI) ((MMI)->staticMap->Signals.logSignalsArray)
#define rtwCAPI_GetNumLogSignals(MMI)   ((MMI)->staticMap->Signals.numLogSignals)

#define rtwCAPI_GetBlockParameters(MMI)    ((MMI)->staticMap->Params.blockParameters)
#define rtwCAPI_GetModelParameters(MMI)    ((MMI)->staticMap->Params.modelParameters)
#define rtwCAPI_GetNumBlockParameters(MMI) ((MMI)->staticMap->Params.numBlockParameters)
#define rtwCAPI_GetNumModelParameters(MMI) ((MMI)->staticMap->Params.numModelParameters)

#define rtwCAPI_GetStates(MMI)     ((MMI)->staticMap->States.states)
#define rtwCAPI_GetNumStates(MMI)  ((MMI)->staticMap->States.numStates)

#define rtwCAPI_GetDataTypeMap(MMI)       ((MMI)->staticMap->Maps.dataTypeMap)
#define rtwCAPI_GetDimensionMap(MMI)      ((MMI)->staticMap->Maps.dimensionMap)
#define rtwCAPI_GetFixPtMap(MMI)          ((MMI)->staticMap->Maps.fixPtMap)
#define rtwCAPI_GetElementMap(MMI)        ((MMI)->staticMap->Maps.elementMap)
#define rtwCAPI_GetSampleTimeMap(MMI)     ((MMI)->staticMap->Maps.sampleTimeMap)
#define rtwCAPI_GetDimensionArray(MMI)    ((MMI)->staticMap->Maps.dimensionArray)

#define rtwCAPI_GetVersion(MMI)           ((MMI)->versionNum)
#define rtwCAPI_GetDataAddressMap(MMI)    ((MMI)->InstanceMap.dataAddrMap)
#define rtwCAPI_GetSystemRanArray(MMI)    ((MMI)->InstanceMap.systemRanArray)
#define rtwCAPI_GetSystemRanArrayLen(MMI) ((MMI)->InstanceMap.systemRanArrayLen)
#define rtwCAPI_GetPath(MMI)              ((MMI)->InstanceMap.path)
#define rtwCAPI_GetFullPath(MMI)          ((MMI)->InstanceMap.fullPath)
#define rtwCAPI_GetChildMMI(MMI,i)        ((MMI)->InstanceMap.childMMIArray[i])
#define rtwCAPI_GetChildMMIArray(MMI)     ((MMI)->InstanceMap.childMMIArray)
#define rtwCAPI_GetChildMMIArrayLen(MMI)  ((MMI)->InstanceMap.childMMIArrayLen)

/* Macros for setting ModelMappingInfo fields */
#define rtwCAPI_SetVersion(MMI, n)            ((MMI).versionNum = (n))
#define rtwCAPI_SetStaticMap(MMI, statMap)    (MMI).staticMap = (statMap)
#define rtwCAPI_SetDataAddressMap(MMI, dAddr) (MMI).InstanceMap.dataAddrMap = (dAddr)
#define rtwCAPI_SetSystemRanArray(MMI, sArr)  (MMI).InstanceMap.systemRanArray = (sArr)
#define rtwCAPI_SetSystemRanArrayLen(MMI, n)  (MMI).InstanceMap.systemRanArrayLen = (n)
#define rtwCAPI_SetPath(MMI,p)                (MMI).InstanceMap.path = (p)
#define rtwCAPI_SetFullPath(MMI,p)            (MMI).InstanceMap.fullPath = (p)
#define rtwCAPI_SetChildMMI(MMI,i,cMMI)       (MMI).InstanceMap.childMMIArray[i] = (cMMI)
#define rtwCAPI_SetChildMMIArray(MMI,cMMIs)   (MMI).InstanceMap.childMMIArray = (cMMIs)
#define rtwCAPI_SetChildMMIArrayLen(MMI,n)    (MMI).InstanceMap.childMMIArrayLen = (n)

/* Functions in rtw_modelmap.c */
#ifdef __cplusplus
extern "C" {
#endif
extern char* rtwCAPI_EncodePath(const char* path);
extern boolean_T rtwCAPI_HasStates(const rtwCAPI_ModelMappingInfo* mmi);
extern int_T rtwCAPI_GetNumStateRecords(const rtwCAPI_ModelMappingInfo* mmi);
extern void  rtwCAPI_FreeFullPaths(rtwCAPI_ModelMappingInfo* mmi);
extern const char_T* rtwCAPI_UpdateFullPaths(rtwCAPI_ModelMappingInfo* mmi,
                                        const char_T*     path);
extern const char_T* rtwCAPI_GetStateRecordInfo(const rtwCAPI_ModelMappingInfo* mmi,
                                           const char_T**    sigBlockName,
                                           const char_T**    sigLabel,
                                           int_T*            sigWidth,
                                           int_T*            sigDataType,
                                           int_T*            logDataType,
                                           int_T*            sigComplexity,
                                           const void**      sigDataAddr,
                                           boolean_T*        sigCrossMdlRef,
                                           int_T*            sigIdx,
                                           boolean_T         crossingModel);
#ifdef __cplusplus
}
#endif

#endif  /* __RTW_MODELMAP__ */

/* EOF - rtw_modelmap.h */
