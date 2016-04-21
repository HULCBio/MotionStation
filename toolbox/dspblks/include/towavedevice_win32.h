/* $Revision: 1.4 $ 
 *
 * towavedevice_win32.h
 * Runtime library header file for Windows "To Wave Device" block.
 * Link:  toolbox/dspblks/lib/win32/towavedevice.lib
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#ifndef TOWAVEDEVICE_H
#define TOWAVEDEVICE_H

/*
 * Exported function types
 */

typedef void	(*MWDSP_WAO_SETERRCODE_FUNC) (int);
typedef int	    (*MWDSP_WAO_GETERRCODE_FUNC) (void);
typedef const char* (*MWDSP_WAO_GETERRMSG_FUNC) (void);

typedef void* (*MWDSP_WAO_CREATE_FUNC)		(double, unsigned short, int, int, int, double, 
											 double, unsigned int, unsigned short);
typedef void  (*MWDSP_WAO_START_FUNC)		(const void*);
typedef void  (*MWDSP_WAO_UPDATE_FUNC)		(const void*, const void*);
typedef int  (*MWDSP_WAO_TERMINATE_FUNC)	(const void*);

#define MWDSP_WAO_LIB_NAME	    "ToWaveDevice.dll"

#define MWDSP_WAO_SETERRCODE_NAME  "MWDSP_Wao_SetErrorCode"
#define MWDSP_WAO_GETERRCODE_NAME  "MWDSP_Wao_GetErrorCode"
#define MWDSP_WAO_GETERRMSG_NAME   "MWDSP_Wao_GetErrorMessage"

#define MWDSP_WAO_CREATE_NAME	    "MWDSP_Wao_Create"
#define MWDSP_WAO_START_NAME		"MWDSP_Wao_Start"
#define MWDSP_WAO_UPDATE_NAME	    "MWDSP_Wao_Update"
#define MWDSP_WAO_TERMINATE_NAME   "MWDSP_Wao_Terminate"

/*
 * Error message function prototypes
 */

void MWDSP_Wao_SetErrorCode(int code);
int MWDSP_Wao_GetErrorCode(void);
const char* MWDSP_Wao_GetErrorMessage(void);

/*
 * The public interface
 */

void* MWDSP_Wao_Create(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, double initialDelay, unsigned int whichDevice, 
						unsigned short useTheWaveMapper);

void MWDSP_Wao_Start(const void* obj);

void MWDSP_Wao_Update(const void * obj, const void* signal);

/* returns the number of instances of the "block" after this one is destroyed */
int MWDSP_Wao_Terminate(const void* obj);

#endif /* TOWAVEDEVICE_H */
