/* $Revision: 1.2 $ */
#include <stdlib.h>
#include "ToWaveDeviceBlock.h"
#include "ToWaveDeviceException.h"

/*
 * Error message functions
 */

extern "C"
{

void MWDSP_Wao_SetErrorCode(int code)
{
	ToWaveDeviceBlock::SetErrorCode(code);
}

int MWDSP_Wao_GetErrorCode()
{
    return ToWaveDeviceBlock::GetErrorCode();
}

const char* MWDSP_Wao_GetErrorMessage()
{
    return ToWaveDeviceBlock::GetErrorMessage();
}


void* MWDSP_Wao_Create(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, double initialDelay, unsigned int whichDevice, 
						unsigned short useTheWaveMapper)
{
	ToWaveDeviceBlock::SetErrorCode(ERR_NO_ERROR);

    ToWaveDeviceBlock* block = NULL;
    try
    {
		block = ToWaveDeviceBlock::New(rate, bits, chans, inputBufSize, dType,
						bufSizeInSeconds, initialDelay, whichDevice, useTheWaveMapper == 1);
    }
    catch(ToWaveDeviceException* ex)
    {
		ToWaveDeviceBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }

    return (void*) block;
}

void MWDSP_Wao_Start(const void* obj)
{
    ToWaveDeviceBlock* block = (ToWaveDeviceBlock*)obj;
    
    try
    {
		block->Start();
    }
    catch(ToWaveDeviceException* ex)
    {
		ToWaveDeviceBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }
}

void MWDSP_Wao_Update(const void * obj, const void* signal)
{
    ToWaveDeviceBlock* block = (ToWaveDeviceBlock*)obj;
    
    try
    {
		block->Update(signal);
    }
    catch(ToWaveDeviceException* ex)
    {
		ToWaveDeviceBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }
}


int MWDSP_Wao_Terminate(const void* obj)
{
    if(obj == NULL)
		return ToWaveDeviceBlock::NumberOfInstances();

    ToWaveDeviceBlock* block = (ToWaveDeviceBlock*)obj;
	block->Terminate();

    delete block;

    return ToWaveDeviceBlock::NumberOfInstances();
}

}	// extern "C"