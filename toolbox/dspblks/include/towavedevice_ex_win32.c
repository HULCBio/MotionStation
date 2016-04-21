/* $Revision: 1.1 $ 
 *
 * towavedevice_ex_win32.c
 * Runtime library source file for Windows "To Wave Device" block.
 * Link:  (no import library needed)
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#include <windows.h>
#include "towavedevice_ex_win32.h"
#include "towavedevice_win32.h"
#include "audio_utils_win32.h"

static HMODULE		hWAOModule = NULL;

static MWDSP_WAO_GETERRCODE_FUNC	waoGetErrorCode = NULL;
static MWDSP_WAO_GETERRMSG_FUNC		waoGetErrorMessage = NULL;

static MWDSP_WAO_CREATE_FUNC		waoCreate = NULL;
static MWDSP_WAO_START_FUNC			waoStart = NULL;
static MWDSP_WAO_UPDATE_FUNC		waoUpdate = NULL;
static MWDSP_WAO_TERMINATE_FUNC		waoTerminate = NULL;

static unsigned short LoadToWaveDeviceLibrary(void)
{
	hWAOModule = LoadLibrary(MWDSP_WAO_LIB_NAME);
	if(hWAOModule == NULL)
	{
		MWDSP_audio_error_LoadLibraryFailed(MWDSP_WAO_LIB_NAME, &waoGetErrorCode, &waoGetErrorMessage);
		return 0;
	}

	waoGetErrorCode = (MWDSP_WAO_GETERRCODE_FUNC) GetProcAddress(hWAOModule, MWDSP_WAO_GETERRCODE_NAME);
	waoGetErrorMessage = (MWDSP_WAO_GETERRMSG_FUNC) GetProcAddress(hWAOModule, MWDSP_WAO_GETERRMSG_NAME);

	waoCreate = (MWDSP_WAO_CREATE_FUNC) GetProcAddress(hWAOModule, MWDSP_WAO_CREATE_NAME);
	waoStart = (MWDSP_WAO_START_FUNC) GetProcAddress(hWAOModule, MWDSP_WAO_START_NAME);
	waoUpdate = (MWDSP_WAO_UPDATE_FUNC) GetProcAddress(hWAOModule, MWDSP_WAO_UPDATE_NAME);
	waoTerminate = (MWDSP_WAO_TERMINATE_FUNC) GetProcAddress(hWAOModule, MWDSP_WAO_TERMINATE_NAME);
	return 1;
}

static void UnloadToWaveDeviceLibrary(void)
{
	FreeLibrary(hWAOModule);
	hWAOModule = NULL;
}

int exMWDSP_Wao_GetErrorCode(void)
{
	return waoGetErrorCode();
}

const char* exMWDSP_Wao_GetErrorMessage(void)
{
	return waoGetErrorMessage();
}

void* exMWDSP_Wao_Create(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, double initialDelay, unsigned int whichDevice, 
						unsigned short useTheWaveMapper)
{
	if(hWAOModule == NULL)
	{
		if(LoadToWaveDeviceLibrary() == 0)
			return NULL;
	}
	return waoCreate(rate, bits, chans, inputBufSize, dType, bufSizeInSeconds, initialDelay, 
						whichDevice, useTheWaveMapper);
}

void exMWDSP_Wao_Start(void* obj)
{
	waoStart(obj);
}


void exMWDSP_Wao_Update(const void * obj, const void* signal)
{
	waoUpdate(obj, signal);
}

void exMWDSP_Wao_Terminate(const void* obj)
{
	if(hWAOModule == NULL)
		return;

	if(waoTerminate(obj) == 0)
		UnloadToWaveDeviceLibrary();
}
