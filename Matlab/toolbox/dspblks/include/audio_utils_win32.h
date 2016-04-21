/* $Revision: 1.3 $ 
 *
 * audio_utils_win32.h
 * Only used by "external mode" (_ex_ in filename) audio block headers.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#ifndef AUDIO_UTILS_H
#define AUDIO_UTILS_H

typedef int (*getErrCode)(void);
typedef const char* (*getErrMsg)(void);

#define		ERR_NO_ERROR				0
#define		ERR_LOAD_LIBRARY_FAILED		1

int MWDSP_audio_error_GetErrorCode(void);

const char* MWDSP_audio_error_GetErrorMessage(void);

void MWDSP_audio_error_SetErrorFunctionPtrs(getErrCode* errCodeFcn,
												getErrMsg* errMsgFcn);

void MWDSP_audio_error_SetErrorMessage(void);

void MWDSP_audio_error_LoadLibraryFailed(char* libName, 
												getErrCode* errCodeFcn,
												getErrMsg* errMsgFcn);


#endif /* AUDIO_UTILS_H */
