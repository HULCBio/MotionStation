/**
 * Utility functions to traverse and access information from ModelMappingInfo
 *
 * $Revision: 1.1.6.5 $
 *
 */

#ifdef SL_INTERNAL

# include "version.h"
# include "util.h"

#else

# include <stdlib.h>
# include <assert.h>

# define  utFree(arg)    if (arg) free(arg)
# define  utMalloc(arg)  malloc(arg)
# define  utAssert(exp)  assert(exp)

#endif

#include <string.h>
#include "simstruc_types.h"
#include "rtw_modelmap.h"


/** Function: rtwCAPI_EncodePath ===============================================
 *  Abatract:
 *     Escape all '|' characters in bpath. For examples 'aaa|b' will become
 *     'aaa~|b'. The caller is responsible for freeing the returned string
 *
 *
 * NOTE: returned string can be nULL in two cases:
 *     (1) string passed in was NULL
 *     (2) a memory allocation error occurred
 * In the second case, the caller need to report the error
 */
char* rtwCAPI_EncodePath(const char* path)
{
    char* encodedPath     = NULL;
    size_t pathLen        = (path==NULL) ? 0:strlen(path) + 1;
    size_t encodedPathLen = pathLen;
    unsigned i;
    unsigned j = 0;

    if (path == NULL) return NULL;

    for (i = 0; i < pathLen; ++i) {
        if (path[i] == '|' || path[i] == '~') ++encodedPathLen;
    }

    encodedPath = (char_T*)utMalloc(encodedPathLen*sizeof(char_T));
    if (encodedPath == NULL) return encodedPath;
 
    for (i = 0; i < pathLen; ++i) {
        char ch = path[i];
        if (ch == '~' || ch == '|') encodedPath[j++] = '~';
        encodedPath[j++] = ch;
    }
    utAssert(j == encodedPathLen);
    utAssert(encodedPath[j-1] == '\0');

    return encodedPath;

} /* rtwCAPI_EncodePath */



/** Function: rtwCAPI_HasStates ================================================
 *
 */
boolean_T rtwCAPI_HasStates(const rtwCAPI_ModelMappingInfo* mmi)
{
    int_T i;
    int_T nCMMI;

    if (mmi == NULL) return(0U);

    if (rtwCAPI_GetNumStates(mmi) > 0) return(1U);

    nCMMI = rtwCAPI_GetChildMMIArrayLen(mmi);
    for (i = 0; i < nCMMI; ++i) {
        if (rtwCAPI_HasStates(rtwCAPI_GetChildMMI(mmi,i))) return(1U);
    }
    return(0U);

} /* rtwCAPI_HasStates */



/** Function: rtwCAPI_GetNumStateRecords =======================================
 *
 */
int_T rtwCAPI_GetNumStateRecords(const rtwCAPI_ModelMappingInfo* mmi)
{
    int_T i;
    int_T nRecs;
    int_T nCMMI;

    if (mmi == NULL) return(0);

    nRecs = rtwCAPI_GetNumStates(mmi);
    nCMMI = rtwCAPI_GetChildMMIArrayLen(mmi);
    for (i = 0; i < nCMMI; ++i) {
        const rtwCAPI_ModelMappingInfo* cMMI = rtwCAPI_GetChildMMI(mmi,i);
        nRecs += rtwCAPI_GetNumStateRecords(cMMI);
    }
    return(nRecs);

} /* rtwCAPI_GetNumStateRecords */


/** Function: rtwCAPI_FreeFullPaths ============================================
 *
 */
void rtwCAPI_FreeFullPaths(rtwCAPI_ModelMappingInfo* mmi)
{
    int_T   i;
    int_T   nCMMI;
    char_T* fullPath;

    if (mmi == NULL) return;

    fullPath = rtwCAPI_GetFullPath(mmi);
    utAssert(fullPath != NULL);
    utFree(fullPath);
    rtwCAPI_SetFullPath(*mmi, NULL);

    nCMMI = rtwCAPI_GetChildMMIArrayLen(mmi);
    for (i = 0; i < nCMMI; ++i) {
        rtwCAPI_ModelMappingInfo* cMMI = rtwCAPI_GetChildMMI(mmi,i);
        rtwCAPI_FreeFullPaths(cMMI);
    }

} /* rtwCAPI_FreeFullPaths */


/** Function: rtwCAPI_UpdateFullPaths =========================================*
 *
 */
const char_T* rtwCAPI_UpdateFullPaths(rtwCAPI_ModelMappingInfo* mmi,
                                      const char_T* path)
{
    int_T         i;
    int_T         nCMMI;
    size_t        pathLen;
    char_T*       mmiPath;
    size_t        mmiPathLen;
    char_T*       relMMIPath;
    size_t        relMMIPathLen;

    const char_T* mallocError = "Memory Allocation Error";

    if (mmi == NULL) return NULL;

    utAssert(path != NULL);
    utAssert( rtwCAPI_GetFullPath(mmi) == NULL );

    pathLen = strlen(path)+1;

    relMMIPath = rtwCAPI_EncodePath(rtwCAPI_GetPath(mmi));
    if ( (relMMIPath== NULL) && (rtwCAPI_GetPath(mmi) != NULL)) {
        return mallocError;
    }
    relMMIPathLen = relMMIPath ? (strlen(relMMIPath) + 1) : 0;

    mmiPathLen = pathLen + relMMIPathLen;

    mmiPath = (char_T*)utMalloc(mmiPathLen*sizeof(char_T));
    if (mmiPath == NULL) return mallocError;
    (void)memcpy(mmiPath, path, pathLen*sizeof(char_T));
    utAssert(mmiPath[pathLen-1] == '\0');

    if (relMMIPath) {
        /* mmiPath = path + | + relMMIPath + '\0' */
        mmiPath[pathLen-1] = '|';
        (void)memcpy(&(mmiPath[pathLen]),
                     relMMIPath, relMMIPathLen*sizeof(char_T));
        utAssert(mmiPath[mmiPathLen-1] == '\0');
        utFree(relMMIPath);
    }
    rtwCAPI_SetFullPath(*mmi, mmiPath);

    nCMMI = rtwCAPI_GetChildMMIArrayLen(mmi);
    for (i = 0; i < nCMMI; ++i) {
        rtwCAPI_ModelMappingInfo* cMMI = rtwCAPI_GetChildMMI(mmi,i);
        const char_T* errstr = rtwCAPI_UpdateFullPaths(cMMI, mmiPath);
        if (errstr != NULL) return errstr;
    }
    return NULL;

} /* rtwCAPI_UpdateFullPaths */


/** Function: rtwCAPI_GetStateRecordInfo =======================================
 *
 */
const char_T* rtwCAPI_GetStateRecordInfo(const rtwCAPI_ModelMappingInfo* mmi,
                                         const char_T**    sigBlockName,
                                         const char_T**    sigLabel,
                                         int_T*            sigWidth,
                                         int_T*            sigDataType,
                                         int_T*            logDataType,
                                         int_T*            sigComplexity,
                                         const void**      sigDataAddr,
                                         boolean_T*        sigCrossMdlRef,
                                         int_T*            sigIdx,
                                         boolean_T         crossingModel)
{
    int_T               i;
    int_T               nCMMI;
    int_T               nStates;
    const char_T*       mmiPath;
    size_t              mmiPathLen;
    const rtwCAPI_States*  states;
    const rtwCAPI_DimensionMap* dimMap;
    const uint_T*       dimArray;
    const rtwCAPI_DataTypeMap*  dataTypeMap;
    void**              dataAddrMap;
    const char_T*       errstr = NULL;
    const char_T*       mallocError = "Memory Allocation Error";
    uint8_T             isPointer = 0;
    char*               blockPath = NULL;

    if (mmi == NULL) goto EXIT_POINT;

    nCMMI = rtwCAPI_GetChildMMIArrayLen(mmi);
    for (i = 0; i < nCMMI; ++i) {
        rtwCAPI_ModelMappingInfo* cMMI = rtwCAPI_GetChildMMI(mmi,i);


        errstr = rtwCAPI_GetStateRecordInfo(cMMI,
                                            sigBlockName,
                                            sigLabel,
                                            sigWidth,
                                            sigDataType,
                                            logDataType,
                                            sigComplexity,
                                            sigDataAddr,
                                            sigCrossMdlRef,
                                            sigIdx,
                                            true);
        if (errstr != NULL) goto EXIT_POINT;
    }

    nStates = rtwCAPI_GetNumStates(mmi);
    if (nStates < 1) goto EXIT_POINT;

    mmiPath     = rtwCAPI_GetFullPath(mmi);
    mmiPathLen  = (mmiPath==NULL)? 0 : strlen(mmiPath);
    states      = rtwCAPI_GetStates(mmi);
    dimMap      = rtwCAPI_GetDimensionMap(mmi);
    dimArray    = rtwCAPI_GetDimensionArray(mmi);
    dataTypeMap = rtwCAPI_GetDataTypeMap(mmi);
    dataAddrMap = rtwCAPI_GetDataAddressMap(mmi);

    for (i = 0; i < nStates; ++i) {
        uint_T mapIdx;
        size_t sigPathLen;
        char*  sigPath;

        /* sigBlockPath = mmiPath + | + BlockPath + '\0' */
        /* If crossing a model boundary encode, otherwise do not */

        if (crossingModel) {
            blockPath = rtwCAPI_EncodePath(rtwCAPI_GetStateBlockPath(states, i)); 
            if ( (blockPath == NULL) && 
                 (rtwCAPI_GetStateBlockPath(states, i) != NULL)) {
                errstr = mallocError;
                goto EXIT_POINT;
            }
        } else {
            const char* constBlockPath = rtwCAPI_GetStateBlockPath(states, i);
            blockPath = (char*)utMalloc((strlen(constBlockPath)+1)*sizeof(char));
            (void)strcpy(blockPath, constBlockPath);
        }
        utAssert(blockPath != NULL);
        sigPathLen = ( (mmiPath==NULL) ?
                                   strlen(blockPath) + 1 :
                                   mmiPathLen + strlen(blockPath) + 2 );
        sigPath    = (char*)utMalloc(sigPathLen*sizeof(char));
        if (sigPath == NULL) {
            errstr = mallocError;
            goto EXIT_POINT;
        }
        if (mmiPath != NULL) {
            (void)strcpy(sigPath, mmiPath);
            sigPath[mmiPathLen]   = '|';
            sigPath[mmiPathLen+1] =  '\0';
            (void)strcat(sigPath, blockPath);
        } else { 
            (void)strcpy(sigPath, blockPath);
            sigPath[sigPathLen-1] =  '\0';
        }
       /* need to free for every iteration of the loop, but also have 
        * the free below EXIT_POINT in case of error */
        utFree(blockPath);
        blockPath = NULL;
        utAssert(sigPath[sigPathLen-1] == '\0');
        sigBlockName[*sigIdx] = sigPath; /* caller is responsible for free */

        /* Label */
        sigLabel[*sigIdx] = rtwCAPI_GetStateName(states, i);

        /* Width */
        mapIdx = rtwCAPI_GetStateDimensionIdx(states, i);
        utAssert( rtwCAPI_GetNumDims(dimMap,mapIdx) == 2 );
        mapIdx = rtwCAPI_GetDimArrayIndex(dimMap, mapIdx);
        sigWidth[*sigIdx] = dimArray[mapIdx] * dimArray[mapIdx+1];

        /* DataType and logDataType */
        mapIdx = rtwCAPI_GetStateDataTypeIdx(states, i);
        sigDataType[*sigIdx] = rtwCAPI_GetDataTypeSLId(dataTypeMap, mapIdx);
        /* this mimics code in simulink.dll:mapSigDataTypeToLogDataType */
        if ( SS_DOUBLE ||
             SS_SINGLE ||
             SS_INT8   ||
             SS_UINT8  ||
             SS_INT16  ||
             SS_UINT16 ||
             SS_INT32  ||
             SS_UINT32 ||
             SS_BOOLEAN ) {
            logDataType[*sigIdx] = sigDataType[*sigIdx];
        } else {
            logDataType[*sigIdx] = SS_DOUBLE;
        }

        /* Complexity */
        sigComplexity[*sigIdx] = rtwCAPI_GetDataIsComplex(dataTypeMap, mapIdx);

        /* Data Access - Pointer or Direct*/
        isPointer = rtwCAPI_GetDataIsPointer(dataTypeMap, mapIdx);

        /* Address */
        mapIdx = rtwCAPI_GetStateAddrIdx(states, i);
        if (isPointer) {
            /* Dereference pointer and cache the address */
            
            /* Imported Pointers cannot be complex - Assert */
            utAssert(sigComplexity[*sigIdx] != 1);
            
            /* Check for data type and dereference accordingly */
            switch (sigDataType[*sigIdx]) {
              case SS_DOUBLE:
                sigDataAddr[*sigIdx] = \
                    (void*) *((real_T **) dataAddrMap[mapIdx]);
                break;
              case SS_SINGLE:
                sigDataAddr[*sigIdx] = \
                    (void*) *((real32_T **) dataAddrMap[mapIdx]);
                break;
              case SS_UINT32:
                sigDataAddr[*sigIdx] = \
                    (void*) *((uint32_T **) dataAddrMap[mapIdx]);
                break;
              case SS_INT32:
                sigDataAddr[*sigIdx] = \
                    (void*) *((int32_T **) dataAddrMap[mapIdx]);
                break;
              case SS_UINT16:
                sigDataAddr[*sigIdx] = \
                    (void*) *((uint16_T **) dataAddrMap[mapIdx]);
                break;
              case SS_INT16:
                sigDataAddr[*sigIdx] = \
                    (void*) *((int16_T **) dataAddrMap[mapIdx]);
                break;
              case SS_UINT8:
                sigDataAddr[*sigIdx] = \
                    (void*) *((uint8_T **) dataAddrMap[mapIdx]);
                break;
              case SS_INT8:
                sigDataAddr[*sigIdx] = \
                    (void*) *((int8_T **) dataAddrMap[mapIdx]);
                break;
              case SS_BOOLEAN:
                sigDataAddr[*sigIdx] = \
                    (void*) *((boolean_T **) dataAddrMap[mapIdx]);
                break;
              default:
                sigDataAddr[*sigIdx] = \
                    (void*) *((real_T **) dataAddrMap[mapIdx]);
                break; 
            }  /* end switch */
        } else {
            /* if Data is not a pointer store the address directly */
            sigDataAddr[*sigIdx] = dataAddrMap[mapIdx];
        }

        /* CrossingModelBoundary */
        sigCrossMdlRef[*sigIdx] = crossingModel;

        ++(*sigIdx);
    }

  EXIT_POINT:
    utFree(blockPath);
    return(errstr);

} /* rtwCAPI_GetStateRecordInfo */
