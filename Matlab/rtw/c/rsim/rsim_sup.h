/*
 * $Revision: 1.2.4.1 $
 * Copyright 1994-2002 The MathWorks, Inc.
 *
 */

#ifndef __RSIM_SUP_H__
#define __RSIM_SUP_H__


/* data */
extern double      gblFinalTime;
extern const char* gblMatLoggingFilename;

/* functions */
extern void FreeGbls(void);
extern const char *CheckRemappings(void);
extern int InstallRunTimeLimitHandler(void);
extern const char *ParseArgs(int_T argc, char_T *argv[]);
extern const char *ReadMatFileAndUpdateParams(const SimStruct *S);

#endif /* __RSIM_SUP_H__ */
