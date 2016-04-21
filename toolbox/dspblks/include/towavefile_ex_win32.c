/* $Revision: 1.1 $ 
 *
 * towavefile_ex_win32.c
 * Runtime library source file for Windows "To Wave File" block.
 * Link:  (no import library needed)
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#include <windows.h>
#include "towavefile_ex_win32.h"
#include "towavefile_win32.h"
#include "audio_utils_win32.h"

static HMODULE		hWAFOModule = NULL;

static MWDSP_WAFO_GETERRCODE_FUNC	wafoGetErrorCode = NULL;
static MWDSP_WAFO_GETERRMSG_FUNC	wafoGetErrorMessage = NULL;

static MWDSP_WAFO_CREATE_FUNC		wafoCreate = NULL;
static MWDSP_WAFO_OUTPUTS_FUNC		wafoOutputs = NULL;
static MWDSP_WAFO_TERMINATE_FUNC	wafoTerminate = NULL;

static unsigned short LoadToWaveFileLibrary(void)
{
	hWAFOModule = LoadLibrary(MWDSP_WAFO_LIB_NAME);
	if(hWAFOModule == NULL)
	{
		MWDSP_audio_error_LoadLibraryFailed(MWDSP_WAFO_LIB_NAME, &wafoGetErrorCode, &wafoGetErrorMessage);
		return 0;
	}

	wafoGetErrorCode = (MWDSP_WAFO_GETERRCODE_FUNC) GetProcAddress(hWAFOModule, MWDSP_WAFO_GETERRCODE_NAME);
	wafoGetErrorMessage = (MWDSP_WAFO_GETERRMSG_FUNC) GetProcAddress(hWAFOModule, MWDSP_WAFO_GETERRMSG_NAME);

	wafoCreate = (MWDSP_WAFO_CREATE_FUNC) GetProcAddress(hWAFOModule, MWDSP_WAFO_CREATE_NAME);
	wafoOutputs = (MWDSP_WAFO_OUTPUTS_FUNC) GetProcAddress(hWAFOModule, MWDSP_WAFO_OUTPUTS_NAME);
	wafoTerminate = (MWDSP_WAFO_TERMINATE_FUNC) GetProcAddress(hWAFOModule, MWDSP_WAFO_TERMINATE_NAME);
	return 1;
}

static void UnloadToWaveFileLibrary(void)
{
	FreeLibrary(hWAFOModule);
	hWAFOModule = NULL;
}

int exMWDSP_Wafo_GetErrorCode(void)
{
	return wafoGetErrorCode();
}
const char* exMWDSP_Wafo_GetErrorMessage(void)
{
	return wafoGetErrorMessage();
}

void* exMWDSP_Wafo_Create(char* outputFilename, unsigned short bits, 
		    int minSampsToWrite, int chans, int inputBufSize,
		    double rate, int dType)
{
	if(hWAFOModule == NULL)
	{
		if(LoadToWaveFileLibrary() == 0)
			return NULL;
	}

	return wafoCreate(outputFilename, bits, minSampsToWrite, chans,
						inputBufSize, rate, dType);
}

void exMWDSP_Wafo_Outputs(const void * obj, const void* signal)
{
	wafoOutputs(obj, signal);
}

void exMWDSP_Wafo_Terminate(const void* obj)
{
	if(hWAFOModule == NULL)
		return;

	if(wafoTerminate(obj) == 0)
		UnloadToWaveFileLibrary();
}
