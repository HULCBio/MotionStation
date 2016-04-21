/* $Revision: 1.5 $ 
 *
 * fromwavefile_win32.h
 * Runtime library header file for Windows "From Wave File" block.
 * Link:  toolbox/dspblks/lib/win32/fromwavefile.lib
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#ifndef FROMWAVEFILE_H
#define FROMWAVEFILE_H

/* data types */

typedef enum
{
	IMMEDIATE_RESTART = 0,
	FULL_FRAME_RESTART = 1
};

/*
 * Exported function types
 */

typedef int			(*MWDSP_WAFI_GETERRCODE_FUNC) (void);
typedef const char* (*MWDSP_WAFI_GETERRMSG_FUNC) (void);

typedef void* (*MWDSP_WAFI_CREATE_FUNC)    (const char*, unsigned short, int, int, int,double, int);
typedef void  (*MWDSP_WAFI_OUTPUTS_FUNC)   (const void*, const void*);
typedef int  (*MWDSP_WAFI_TERMINATE_FUNC) (const void*);

typedef void (*MWDSP_WAFI_SETRPTS_FUNC)	(void*, long);
typedef long (*MWDSP_WAFI_GETRPTS_FUNC)	(void*);

typedef void (*MWDSP_SET_RSTRT_MODE_FUNC) (void*, int);
typedef int  (*MWDSP_GET_RSTRT_MODE_FUNC) (void* obj);

typedef unsigned short (*MWDSP_WAFI_FRST_SAMPLE_FUNC) (void*);
typedef unsigned short (*MWDSP_WAFI_LAST_SAMPLE_FUNC) (void*);

#define MWDSP_WAFI_LIB_NAME			"FromWaveFile.dll"

#define MWDSP_WAFI_GETERRCODE_NAME  "MWDSP_Wafi_GetErrorCode"
#define MWDSP_WAFI_GETERRMSG_NAME   "MWDSP_Wafi_GetErrorMessage"

#define MWDSP_WAFI_CREATE_NAME	    "MWDSP_Wafi_Create"
#define MWDSP_WAFI_OUTPUTS_NAME	    "MWDSP_Wafi_Outputs"
#define MWDSP_WAFI_TERMINATE_NAME   "MWDSP_Wafi_Terminate"

#define MWDSP_WAFI_SETRPTS_NAME		"MWDSP_Wafi_SetNumRepeats"
#define MWDSP_WAFI_GETRPTS_NAME		"MWDSP_Wafi_GetNumRepeats"

#define MWDSP_SET_RSTRT_MODE_NAME	"MWDSP_Wafi_SetRestartMode"
#define MWDSP_GET_RSTRT_MODE_NAME	"MWDSP_Wafi_GetRestartMode"

#define	MWDSP_WAFI_FRST_SAMPLE_NAME	"MWDSP_Wafi_JustOutputFirstSample"
#define	MWDSP_WAFI_LAST_SAMPLE_NAME	"MWDSP_Wafi_JustOutputLastSample"


/*
 * Error message function prototypes
 */

int MWDSP_Wafi_GetErrorCode(void);
const char* MWDSP_Wafi_GetErrorMessage(void);

/*
 * The public interface
 */

void* MWDSP_Wafi_Create(const char* filename, unsigned short bits, 
			int minSampsToRead, int chans, int outputFrameSize, double rate, 
			int dType);

void MWDSP_Wafi_Outputs(const void * obj, const void* signal);

int MWDSP_Wafi_Terminate(const void* obj);	/* returns number of instances of block remaining */


/* MWDSP_Wafi_SetNumRepeats / MWDSP_Wafi_GetNumRepeats
   get/set number of times to repeat (loop) file:
   rpts == 0 means don't repeat it at all -- just play through once
   rpts == n (n > 0) means after the first play through, repeat n times
   rpts == -1 means repeat/loop forever
 */
void MWDSP_Wafi_SetNumRepeats(void* obj, long rpts);
long MWDSP_Wafi_GetNumRepeats(void* obj);

/* MWDSP_Wafi_SetRestartMode / MWDSP_Wafi_GetRestartMode
   get/set the restart mode.  Valid restart modes are 
   IMMEDIATE_RESTART (no zero padding) and FULL_FRAME_RESTART
   (beginning of file starts at beginning of next frame).
 */
void MWDSP_Wafi_SetRestartMode(void* obj, int restart);
int MWDSP_Wafi_GetRestartMode(void* obj);

/* MWDSP_Wafi_JustOutputFirstSample / MWDSP_Wafi_JustOutputLastSample
   Used after calling MWDSP_Wafi_Outputs, indicates whether first/last 
   samples read from the file are contained within the frame of data
   obtained from the last call of MWDSP_Wafi_Outputs.  Returns 1 if 
   first/last sample present in frame, 0 otherwise.
 */
unsigned short MWDSP_Wafi_JustOutputFirstSample(void* obj);
unsigned short MWDSP_Wafi_JustOutputLastSample(void* obj);

#endif /* FROMWAVEFILE_H */
