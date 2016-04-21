/* $Revision: 1.2 $ 
 *
 * fromwavefile_ex_win32.c
 * Runtime library source file for Windows "From Wave File" block.
 * Link:  (no import library needed)
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#include <windows.h>
#include "fromwavefile_ex_win32.h"
#include "fromwavefile_win32.h"
#include "audio_utils_win32.h"

static HMODULE		hWAFIModule = NULL;

static MWDSP_WAFI_GETERRCODE_FUNC	wafiGetErrorCode = NULL;
static MWDSP_WAFI_GETERRMSG_FUNC	wafiGetErrorMessage = NULL;

static MWDSP_WAFI_CREATE_FUNC		wafiCreate = NULL;
static MWDSP_WAFI_OUTPUTS_FUNC		wafiOutputs = NULL;
static MWDSP_WAFI_TERMINATE_FUNC	wafiTerminate = NULL;

static MWDSP_WAFI_SETRPTS_FUNC		wafiSetRepeats = NULL;
static MWDSP_WAFI_GETRPTS_FUNC		wafiGetRepeats = NULL;

static MWDSP_SET_RSTRT_MODE_FUNC	wafiSetRestartMode = NULL;
static MWDSP_GET_RSTRT_MODE_FUNC	wafiGetRestartMode = NULL;

static MWDSP_WAFI_FRST_SAMPLE_FUNC	wafiOutputFirstSample = NULL;
static MWDSP_WAFI_LAST_SAMPLE_FUNC	wafiOutputLastSample = NULL;

static unsigned short LoadFromWaveFileLibrary(void)
{
	hWAFIModule = LoadLibrary(MWDSP_WAFI_LIB_NAME);
	if(hWAFIModule == NULL)
	{
		MWDSP_audio_error_LoadLibraryFailed(MWDSP_WAFI_LIB_NAME, &wafiGetErrorCode, &wafiGetErrorMessage);
		return 0;
	}

	wafiGetErrorCode = (MWDSP_WAFI_GETERRCODE_FUNC) GetProcAddress(hWAFIModule, MWDSP_WAFI_GETERRCODE_NAME);
	wafiGetErrorMessage = (MWDSP_WAFI_GETERRMSG_FUNC) GetProcAddress(hWAFIModule, MWDSP_WAFI_GETERRMSG_NAME);

	wafiCreate = (MWDSP_WAFI_CREATE_FUNC) GetProcAddress(hWAFIModule, MWDSP_WAFI_CREATE_NAME);
	wafiOutputs = (MWDSP_WAFI_OUTPUTS_FUNC) GetProcAddress(hWAFIModule, MWDSP_WAFI_OUTPUTS_NAME);
	wafiTerminate = (MWDSP_WAFI_TERMINATE_FUNC) GetProcAddress(hWAFIModule, MWDSP_WAFI_TERMINATE_NAME);

	wafiSetRepeats = (MWDSP_WAFI_SETRPTS_FUNC) GetProcAddress(hWAFIModule, MWDSP_WAFI_SETRPTS_NAME);
	wafiGetRepeats = (MWDSP_WAFI_GETRPTS_FUNC) GetProcAddress(hWAFIModule, MWDSP_WAFI_GETRPTS_NAME);

	wafiSetRestartMode = (MWDSP_SET_RSTRT_MODE_FUNC) GetProcAddress(hWAFIModule, MWDSP_SET_RSTRT_MODE_NAME);
	wafiGetRestartMode = (MWDSP_GET_RSTRT_MODE_FUNC) GetProcAddress(hWAFIModule, MWDSP_GET_RSTRT_MODE_NAME);

	wafiOutputFirstSample = (MWDSP_WAFI_FRST_SAMPLE_FUNC) GetProcAddress(hWAFIModule, MWDSP_WAFI_FRST_SAMPLE_NAME);
	wafiOutputLastSample = (MWDSP_WAFI_LAST_SAMPLE_FUNC) GetProcAddress(hWAFIModule, MWDSP_WAFI_LAST_SAMPLE_NAME);

	return 1;
}

static void UnloadFromWaveFileLibrary(void)
{
	FreeLibrary(hWAFIModule);
	hWAFIModule = NULL;
}

int exMWDSP_Wafi_GetErrorCode(void)
{
	return wafiGetErrorCode();
}
const char* exMWDSP_Wafi_GetErrorMessage(void)
{
	return wafiGetErrorMessage();
}

void* exMWDSP_Wafi_Create(const char* filename, unsigned short bits, 
			int minSampsToRead, int chans, int outputFrameSize, double rate, 
			int dType)
{
	if(hWAFIModule == NULL)
	{
		if(LoadFromWaveFileLibrary() == 0)
			return NULL;
	}
	return wafiCreate(filename, bits, minSampsToRead, chans, outputFrameSize, rate, dType);
}

void exMWDSP_Wafi_Outputs(const void * obj, const void* signal)
{
	wafiOutputs(obj, signal);
}

void exMWDSP_Wafi_Terminate(const void* obj)
{
	if(hWAFIModule == NULL)
		return;

	if(wafiTerminate(obj) == 0)
		UnloadFromWaveFileLibrary();
}


void exMWDSP_Wafi_SetNumRepeats(void* obj, long rpts)
{
	wafiSetRepeats(obj, rpts);
}


long exMWDSP_Wafi_GetNumRepeats(void* obj)
{
	return wafiGetRepeats(obj);
}


void exMWDSP_Wafi_SetRestartMode(void* obj, int restart)
{
	wafiSetRestartMode(obj, restart);
}


int exMWDSP_Wafi_GetRestartMode(void* obj)
{
	return wafiGetRestartMode(obj);
}


unsigned short exMWDSP_Wafi_JustOutputFirstSample(void* obj)
{
	return wafiOutputFirstSample(obj);
}


unsigned short exMWDSP_Wafi_JustOutputLastSample(void* obj)
{
	return wafiOutputLastSample(obj);
}
