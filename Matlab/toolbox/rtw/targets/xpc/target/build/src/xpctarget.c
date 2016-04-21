/* $Revision: 1.16.6.6 $ */
/* $Date: 2004/03/02 03:03:47 $ */

/*
 * Abstract: interface between xPC Target kernel and model DLM
 *
 * Copyright 1996-2004 The MathWorks, Inc.
 *
 */


#define  QUOTE1(name) #name
#define  QUOTE(name) QUOTE1(name)

#include <windows.h>
#include <stdio.h>

#include "devio_shared.h"

#include "rtwtypes.h"
#include "rtmodel.h"
#include "rt_nonfinite.h"

#include "xpcoptions.h"

#include "xpcmdlinfo.h"

#include "xpctarget.bio"
#include "xpctarget.pt"
#include "xpcsctgft.ft"

#ifndef MODEL
# error "must define MODEL"
#endif

#define EXPAND_CONCAT(name1,name2) name1 ## name2
#define CONCAT(name1,name2) EXPAND_CONCAT(name1,name2)
#define RT_MODEL            CONCAT(rtModel_,MODEL)

extern RT_MODEL *MODEL(void);
extern void MdlInitializeSizes(void);
extern void MdlInitializeSampleTimes(void);

static RT_MODEL *rtm;

void XPCCALLCONV updateDiscreteEvents(void) {
#ifdef MULTITASKING
    real_T tnext;
    tnext = rt_SimUpdateDiscreteEvents(rtmGetNumSampleTimes(rtm),
                                       rtmGetTimingData(rtm),
                                       rtmGetSampleHitPtr(rtm),
                                       rtmGetPerTaskSampleHitsPtr(rtm));
    rtsiSetSolverStopTime(rtmGetRTWSolverInfo(rtm), tnext);
#endif
}
BOOL LibMain(HANDLE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved);

static rlmdlinfo_type mdlInfo = { QUOTE(MODEL),
                                  NUMST,
                                  TID01EQ,
                                  NCSTATES,
                                  SIMMODE,
                                  MT,
                                  LOGTET,
                                  0,
                                  LOGBUFSIZE,
                                  IRQ_NO,
                                  IO_IRQ,
                                  WWW_ACCESS_LEVEL,
                                  CPUCLOCK };

BOOL LibMain(HANDLE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved) {
    return(TRUE);
}

rlmdlinfo_type * XPCCALLCONV getrlmdlinfo(void) {
    xPCModelInfo_T *mdl;

    int (* xpceSetVar)(char *, char *);

    rtm = MODEL();

    rt_InitInfAndNaN(sizeof(real_T));

    MdlInitializeSizes();
    MdlInitializeSampleTimes();

    xpceSetVar = (void*) GetProcAddress(GetModuleHandle(NULL), "xpceSetVar");
    if (xpceSetVar==NULL) {
        //printf("Error: xpceSetVar not found");
    } else {
#ifndef XPCMSVISUALC
#pragma disable_message(1055)
#include "xpctgscvariable.ini"
#pragma enable_message(1055)
#endif
    }
    mdlInfo.paramSize = SIZEOF_PARAMS;

    mdl = &mdlInfo.mdl;

    /**** Model Status ****/
    mdl->errorStatus         = &rtmGetErrorStatusFlag(rtm);
    mdl->stopRequested       = &rtmGetStopRequestedFlag(rtm);

    /**** Time info ****/
    mdl->t                   = &rtmGetTPtr(rtm);
    mdl->tFinal              = &rtmGetTFinal(rtm);
    mdl->stepSize            = &rtmGetStepSize(rtm);

    /**** Sample times, timing, solver stuff ****/
    mdl->numSampTimes        =  rtmGetNumSampleTimes(rtm);
    mdl->sampleTimes         =  rtmGetSampleTimePtr(rtm);
    mdl->sampleHitPtr        =  rtmGetSampleHitPtr(rtm);

    /**** Data logging ****/
    mdl->logInfo             =  rtmGetRTWLogInfo(rtm);
    mdl->numTotalStates      =  rtmGetNumContStates(rtm);
    mdl->numOutputs          =  rtmGetNumY(rtm);
    mdl->contStates          =  rtmGetContStates(rtm);
    mdl->outputs             =  rtmGetY(rtm);

    /**** External mode ****/
    mdl->checksums           =  rtmGetChecksums(rtm);

    /**** RTW Data structures we need ****/
    mdl->MMI                 =  rtmGetModelMappingInfo(rtm);
    mdl->dtInfo              =  rtmGetReservedForXPC(rtm);

    /**** Data areas of the model ****/
    mdl->rtP                 =  rtmGetDefaultParam(rtm);
    mdl->rtB                 =  rtmGetBlockIO(rtm);

    /**** xPC Target specific data ****/
    mdl->bio                 =  sortedBIO;
    mdl->pt                  =  sortedPT;
    mdl->scFmt               =  ftstr;

    /**** Set up the function pointers ***/
    mdlInfo.updateDiscEvents = updateDiscreteEvents;
    mdlInfo.changeStepSize   = changeStepSize;

    return &mdlInfo;
}
