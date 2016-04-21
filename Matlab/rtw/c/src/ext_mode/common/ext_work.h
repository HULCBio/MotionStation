/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_work.h     $Revision: 1.1.6.4 $
 *
 * Abstract:
 *   
 */

#ifndef __EXT_WORK_OBJECT__
#define __EXT_WORK_OBJECT__

/*
 * This enum is defined outside of EXT_MODE because rsim sets the tlc variable
 * ExtMode to 1 even when external mode wasn't specified because it needs the
 * data type transition tables.  Unless this enum is available, the rsim code
 * will not compile.
 */
typedef enum {
    EXTMODE_SUBSYS_DISABLED       = 0,
    EXTMODE_SUBSYS_ENABLED        = 1,
    EXTMODE_SUBSYS_ALWAYS_ENABLED = 2
} ExtModeSubsystemStatus;

#ifdef EXT_MODE

#include "ext_types.h"

#ifdef VXWORKS
/*VxWorks headers*/
#include <vxWorks.h>
#include <taskLib.h>
#include <sysLib.h>
#include <semLib.h>
#include <rebootLib.h>
#include <logLib.h>

#include "rtmodel.h"
extern void rtExtModeTornadoStartup(RTWExtModeInfo *ei,
                                    int_T          numSampTimes,
                                    boolean_T      *stopReqPtr,
                                    int_T          priority,
                                    int32_T        stack_size,
                                    SEM_ID         startStopSem);

extern void rtExtModeTornadoCleanup(int_T numSampTimes);

extern void rtExtModeTornadoSetPortInExtUD(const int_T port);

#else  /* #ifdef VXWORKS */
extern void rtExtModePauseIfNeeded(RTWExtModeInfo *ei,
                                   int_T          numSampTimes,
                                   boolean_T      *stopReqPtr);

extern void rtExtModeWaitForStartPkt(RTWExtModeInfo *ei,
                                     int_T          numSampTimes,
                                     boolean_T      *stopReqPtr);
#endif /* #ifdef VXWORKS */

extern void rtExtModeOneStep(RTWExtModeInfo *ei,
                             int_T          numSampTimes,
                             boolean_T      *stopReqPtr);

extern void rtExtModeCheckEndTrigger(void);

extern void rtExtModeUploadCheckTrigger(int_T numSampTimes);

extern void rtExtModeUpload(int_T tid,
                            real_T taskTime);

extern void rtExtModeCheckInit(int_T numSampTimes);

extern void rtExtModeShutdown(int_T numSampTimes);

extern void rtExtModeParseArgs(int_T        argc, 
                               const char_T *argv[],
                               real_T       *rtmFinal);

extern void rtERTExtModeSetTFinal(real_T *rtmTFinal);

extern void rtERTExtModeParseArgs(int_T        argc, 
                                  const char_T *argv[]);

#else /* #ifdef EXTMODE */

#ifdef VXWORKS
#define rtExtModeTornadoStartup(ei,
                                numSampTimes,
                                stopReqPtr,
                                priority,
                                stack_size,
                                startStopSem) /* do nothing */
#define rtExtModeTornadoCleanup(numSampTimes); /* do nothing */
#define rtExtModeTornadoSetPortInExtUD(port); /* do nothing */
#else  /* #ifdef VXWORKS */
#define rtExtModePauseIfNeeded(ei,st,sr) /* do nothing */
#define rtExtModeWaitForStartPkt(ei,st,sr) /* do nothing */
#endif /* #ifdef VXWORKS */

#define rtExtModeOneStep(ei,st,sr) /* do nothing */
#define rtExtModeCheckEndTrigger() /* do nothing */
#define rtExtModeUploadCheckTrigger(numSampTimes) /* do nothing */
#define rtExtModeUpload(t,ttime) /* do nothing */
#define rtExtModeCheckInit(numSampTimes) /* do nothing */
#define rtExtModeShutdown(numSampTimes) /* do nothing */
#define rtExtModeParseArgs(argc, argv, tf); /* do nothing */
#define rtERTExtModeSetTFinal(tf); /* do nothing */
#define rtERTExtModeParseArgs(argc, argv); /* do nothing */

#endif  /* #ifdef EXTMODE */

#endif /* __EXT_WORK_OBJECT__ */
