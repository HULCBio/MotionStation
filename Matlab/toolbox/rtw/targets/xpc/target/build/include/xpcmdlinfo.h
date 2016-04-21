/**
 * Abstract:
 *     Contains data structure definitions needed by both kernel and build
 *     process.
 *
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: $ $Date: $
 */

#include "mdl_info.h"
#include "dt_info.h"
#include "simstruc_types.h"

typedef struct SortedBlockIOSignals_tag {
  int_T   map;      /* mapping between unsorted and sorted list */
  int_T   sigIdx;   /* xPC Signal numbers                       */
  int_T   width;    /* Signal Width                             */
} SortedBlockIOSignals;

typedef uint_T SortedBlockParameters;

typedef struct ScTgblockNumformat_tag {
  int_T   scIdx;
  char_T  *Numformatstr;
} ScTgblockNumformat;

typedef struct xPCModelInfo_tag {
    /**** Model status ****/
    const char                 **errorStatus;
    boolean_T                   *stopRequested;

    /**** Time info ****/
    time_T                     **t;
    time_T                      *tFinal;
    time_T                      *stepSize;

    /**** Sample times, timing, solver stuff ****/
    int                          numSampTimes;
    time_T                      *sampleTimes;
    int_T                       *sampleHitPtr;

    /**** Data logging ****/
    const RTWLogInfo            *logInfo;
    int                          numTotalStates;
    int                          numOutputs;
    real_T                      *contStates;
    real_T                      *outputs;

    /**** External mode ****/
    const uint32_T              *checksums;

    /**** RTW Data structures we need ****/
    const ModelMappingInfo      *MMI;
    const DataTypeTransInfo     *dtInfo;

    /**** Data areas of the model ****/
    void                        *rtP;
    void                        *rtB;

    /**** xPC Target specific data ****/
    const SortedBlockIOSignals  *bio;
    const SortedBlockParameters *pt;
    const ScTgblockNumformat    *scFmt;

} xPCModelInfo_T;

#ifndef XPCCALLCONV
#ifdef _MSC_VER
#define XPCCALLCONV /*__stdcall*/
#else
#define XPCCALLCONV __syscall
#endif
#endif

typedef struct {
    char *modelname;
    int numst;
    int tid01eq;
    int ncstates;
    int simmode;
    int multitasking;
    int logtet;
    int paramSize;
    int logbufsize;
    int irq_no;
    int io_irq;
    int www_access_level;
    int cpu_clock;
    xPCModelInfo_T mdl;
    /**** function pointers that we need ****/
    void (XPCCALLCONV *updateDiscEvents)(void);
    void (XPCCALLCONV *changeStepSize)(double);
} rlmdlinfo_type;

#define MDLINFO(M)          ((M)->mdl)

#define mdlGetMdlName(mdl) (mdl)->modelname

/**** Model status ****/
#define mdlGetErrorStatus(mdl)      MDLINFO(mdl).errorStatus[0]
#define mdlSetErrorStatus(mdl, val) mdlGetErrorStatus(mdl) = (val)

#define mdlGetStopRequested(mdl)    MDLINFO(mdl).stopRequested[0]

/**** Time info ****/
#define mdlGetTPtr(mdl)             MDLINFO(mdl).t[0]
#define mdlGetT(mdl)                mdlGetTPtr(mdl)[0]
#define mdlSetT(mdl, val)           mdlGetT(mdl) = (val)

#define mdlGetTFinal(mdl)           MDLINFO(mdl).tFinal[0]
#define mdlSetTFinal(mdl, val)      mdlGetTFinal(mdl) = (val)

#define mdlGetStepSize(mdl)         MDLINFO(mdl).stepSize[0]

/**** Sample times, timing, solver stuff ****/
#define mdlGetNumSampTimes(mdl)         MDLINFO(mdl).numSampTimes

#define mdlGetSampleTimePtr(mdl)        MDLINFO(mdl).sampleTimes
#define mdlGetSampleTime(mdl, i)        mdlGetSampleTimePtr(mdl)[i]
#define mdlSetSampleTime(mdl, i, val)   mdlGetSampleTimePtr(mdl)[i] = (val)

#define mdlGetSampleHitPtr(mdl)         MDLINFO(mdl).sampleHitPtr

/**** Data logging ****/
#define mdlGetLogInfo(mdl)        MDLINFO(mdl).logInfo
#define mdlGetLogT(mdl)           rtliGetLogT(mdlGetLogInfo(mdl))
#define mdlGetLogX(mdl)           rtliGetLogX(mdlGetLogInfo(mdl))
#define mdlGetLogY(mdl)           rtliGetLogY(mdlGetLogInfo(mdl))

#define mdlGetNumTotalStates(mdl) MDLINFO(mdl).numTotalStates
#define mdlGetNumOutputs(mdl)     MDLINFO(mdl).numOutputs

#define mdlGetStates(mdl)         MDLINFO(mdl).contStates
#define mdlGetOutputs(mdl)        MDLINFO(mdl).outputs

/**** External mode ****/
#define mdlGetChecksum(mdl, i)   MDLINFO(mdl).checksums[i]

/**** RTW Data Structures ****/
#define mdlGetMMI(mdl)           MDLINFO(mdl).MMI
#define mdlGetDTInfo(mdl)        MDLINFO(mdl).dtInfo

/**** Data areas of the model ****/
#define mdlGetrtP(mdl)           MDLINFO(mdl).rtP
#define mdlGetrtB(mdl)           MDLINFO(mdl).rtB

/**** Function calls ****/
#define mdlUpdateDiscEvents(mdl)  ((mdl)->updateDiscEvents)()
#define mdlSetStepSize(mdl,ts)    ((mdl)->changeStepSize)(ts)
