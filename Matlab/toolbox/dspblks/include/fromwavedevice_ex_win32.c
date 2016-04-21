/* $Revision: 1.1 $
 *
 * fromwavedevice_ex_win32.c
 * Runtime library source file for Windows "From Wave Device" block.
 * Link:  (no import library needed)
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#include <windows.h>
#include "fromwavedevice_ex_win32.h"
#include "fromwavedevice_win32.h"
#include "audio_utils_win32.h"

static HMODULE		hWAIModule = NULL;

static MWDSP_WAI_GETERRCODE_FUNC	waiGetErrorCode = NULL;
static MWDSP_WAI_GETERRMSG_FUNC		waiGetErrorMessage = NULL;

static MWDSP_WAI_CREATE_FUNC		waiCreate = NULL;
static MWDSP_WAI_START_FUNC			waiStart = NULL;
static MWDSP_WAI_OUTPUTS_FUNC		waiOutputs = NULL;
static MWDSP_WAI_TERMINATE_FUNC		waiTerminate = NULL;

static unsigned short LoadFromWaveDeviceLibrary(void)
{
	hWAIModule = LoadLibrary(MWDSP_WAI_LIB_NAME);
	if(hWAIModule == NULL)
	{
		MWDSP_audio_error_LoadLibraryFailed(MWDSP_WAI_LIB_NAME, &waiGetErrorCode, &waiGetErrorMessage);
		return 0;
	}

	waiGetErrorCode = (MWDSP_WAI_GETERRCODE_FUNC) GetProcAddress(hWAIModule, MWDSP_WAI_GETERRCODE_NAME);
	waiGetErrorMessage = (MWDSP_WAI_GETERRMSG_FUNC) GetProcAddress(hWAIModule, MWDSP_WAI_GETERRMSG_NAME);

	waiCreate = (MWDSP_WAI_CREATE_FUNC) GetProcAddress(hWAIModule, MWDSP_WAI_CREATE_NAME);
	waiStart = (MWDSP_WAI_START_FUNC) GetProcAddress(hWAIModule, MWDSP_WAI_START_NAME);
	waiOutputs = (MWDSP_WAI_OUTPUTS_FUNC) GetProcAddress(hWAIModule, MWDSP_WAI_OUTPUTS_NAME);
	waiTerminate = (MWDSP_WAI_TERMINATE_FUNC) GetProcAddress(hWAIModule, MWDSP_WAI_TERMINATE_NAME);
	return 1;
}

static void UnloadFromWaveDeviceLibrary(void)
{
	FreeLibrary(hWAIModule);
	hWAIModule = NULL;
}

int exMWDSP_Wai_GetErrorCode(void)
{
	return waiGetErrorCode();
}

const char* exMWDSP_Wai_GetErrorMessage(void)
{
	return waiGetErrorMessage();
}

void* exMWDSP_Wai_Create(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, unsigned int whichDevice, unsigned short useTheWaveMapper)
{
	if(hWAIModule == NULL)
	{
		if(LoadFromWaveDeviceLibrary() == 0)
			return NULL;
	}

	return waiCreate(rate, bits, chans, inputBufSize, dType, bufSizeInSeconds, 
						 whichDevice, useTheWaveMapper);
}

void exMWDSP_Wai_Start(void* obj)
{
	waiStart(obj);
}


void exMWDSP_Wai_Outputs(const void * obj, const void* signal)
{
	waiOutputs(obj, signal);
}

void exMWDSP_Wai_Terminate(const void* obj)
{
	if(hWAIModule == NULL)
		return;

	if(waiTerminate(obj) == 0)
		UnloadFromWaveDeviceLibrary();
}
