/* $Revision: 1.1.4.2 $ 
 *
 * audio_utils_win32.c
 * Only used by "external mode" (_ex_ in filename) audio block helpers.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 */

#include <string.h>
#include "audio_utils_win32.h"

static int			errorCode = ERR_NO_ERROR;
static char			errorMessage[256];

static const char*	baseErrorMessageTable[] = 
{
	"No error reported",
	"Unable to load dynamic-link library: "
};

int MWDSP_audio_error_GetErrorCode(void)
{
	return errorCode;	/* it ain't zero! */
}

const char* MWDSP_audio_error_GetErrorMessage(void)
{
	/* reset the error code, then return the error message */
	errorCode = ERR_NO_ERROR;
	return errorMessage;
}

void MWDSP_audio_error_SetErrorFunctionPtrs(getErrCode* errCodeFcn,
												getErrMsg* errMsgFcn)
{
	*errCodeFcn = MWDSP_audio_error_GetErrorCode;
	*errMsgFcn = MWDSP_audio_error_GetErrorMessage;
}

void MWDSP_audio_error_SetErrorMessage(void)
{
	strcpy(errorMessage, baseErrorMessageTable[errorCode]);
}

void MWDSP_audio_error_LoadLibraryFailed(char* libName, 
												getErrCode* errCodeFcn,
												getErrMsg* errMsgFcn)
{
	/* set the error code and error message */
	errorCode = ERR_LOAD_LIBRARY_FAILED;
	MWDSP_audio_error_SetErrorMessage();

	/* add some extra info to the error message */
	strcat(errorMessage, libName);

	/* set the fcn ptrs to tell the S-Fcn what happened */
	MWDSP_audio_error_SetErrorFunctionPtrs(errCodeFcn, errMsgFcn);
}
