/* $Revision: 1.4 $ 
 *
 * towavefile_win32.h
 * Runtime library header file for Windows "To Wave File" block.
 * Link:  toolbox/dspblks/lib/win32/towavefile.lib
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#ifndef TOWAVEFILE_H
#define TOWAVEFILE_H

/*
 * Exported function types
 */

typedef int			(*MWDSP_WAFO_GETERRCODE_FUNC) (void);
typedef const char* (*MWDSP_WAFO_GETERRMSG_FUNC) (void);

typedef void* (*MWDSP_WAFO_CREATE_FUNC)    (char*, unsigned short, int, int, int,double, int);
typedef void  (*MWDSP_WAFO_OUTPUTS_FUNC)   (const void*, const void*);
typedef int  (*MWDSP_WAFO_TERMINATE_FUNC) (const void*);

#define MWDSP_WAFO_LIB_NAME			"ToWaveFile.dll"

#define MWDSP_WAFO_GETERRCODE_NAME  "MWDSP_Wafo_GetErrorCode"
#define MWDSP_WAFO_GETERRMSG_NAME   "MWDSP_Wafo_GetErrorMessage"

#define MWDSP_WAFO_CREATE_NAME	    "MWDSP_Wafo_Create"
#define MWDSP_WAFO_OUTPUTS_NAME	    "MWDSP_Wafo_Outputs"
#define MWDSP_WAFO_TERMINATE_NAME   "MWDSP_Wafo_Terminate"

/*
 * Error message function prototypes
 */

int MWDSP_Wafo_GetErrorCode(void);
const char* MWDSP_Wafo_GetErrorMessage(void);

/*
 * The public interface
 */

void* MWDSP_Wafo_Create(char* outputFilename, unsigned short bits, 
		    int minSampsToWrite, int chans, int inputBufSize,
		    double rate, int dType);

void MWDSP_Wafo_Outputs(const void * obj, const void* signal);

int MWDSP_Wafo_Terminate(const void* obj);	/* returns number of instances of block remaining */

#endif /* TOWAVEFILE_H */
