/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_svr.h     $Revision: 1.1.6.3 $
 *
 * Abstract:
 *	Function prototypes for The MathWorks provided TCP socket based
 *	external mode implementation.
 */

#ifndef __EXT_SVR__
#define __EXT_SVR__

#include "ext_share.h"

extern boolean_T SendPktToHost(const ExtModeAction action,
                               const int           size,
                               const char          *data);

extern boolean_T rt_ExtModeInit(int_T numSampTimes);

extern void      rt_PktServerWork(RTWExtModeInfo *ei,
                                  int_T          numSampTimes,
                                  boolean_T      *stopReq);

extern void      rt_UploadServerWork(int_T numSampTimes);

extern boolean_T rt_ExtModeShutdown(int_T numSampTimes);

extern void      rt_UploadCheckTrigger(int_T numSampTimes);

extern void      rt_UploadCheckEndTrigger(void);

extern void      rt_UploadBufAddTimePoint(int_T tid,
                                          real_T taskTime);

#ifndef VXWORKS
extern void      rt_ExtModeSleep(long sec,   /* number of seconds to wait      */
                                 long usec); /* number of micro seconds to wait*/
#else
extern void      rt_UploadServer(int_T numSampTimes);

extern void      rt_PktServer(RTWExtModeInfo *ei,
                              int_T          numSampTimes,
                              boolean_T      *stopReq);

extern void      rt_SetPortInExtUD(const int_T port);
#endif

extern const char_T *ExtParseArgsAndInitUD(const int_T  argc,
                                           const char_T *argv[]);
extern boolean_T  ExtWaitForStartPkt(void);

#endif /* __EXT_SVR__ */

/* [EOF] ext_svr.h */
