/* $Revision: 1.2 $ */
#include <stdlib.h>
#include "FromWaveDeviceBlock.h"
#include "FromWaveDeviceException.h"

/*
 * Error message functions
 */

extern "C"
{

void MWDSP_Wai_SetErrorCode(int code)
{
	FromWaveDeviceBlock::SetErrorCode(code);
}

int MWDSP_Wai_GetErrorCode()
{
    return FromWaveDeviceBlock::GetErrorCode();
}

const char* MWDSP_Wai_GetErrorMessage()
{
    return FromWaveDeviceBlock::GetErrorMessage();
}


void* MWDSP_Wai_Create(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, unsigned int whichDevice, unsigned short useTheWaveMapper)
{
	FromWaveDeviceBlock::SetErrorCode(ERR_NO_ERROR);

    FromWaveDeviceBlock* block = NULL;
    try
    {
		block = FromWaveDeviceBlock::New(rate, bits, chans, inputBufSize, dType,
						bufSizeInSeconds, whichDevice, useTheWaveMapper == 1);
    }
    catch(FromWaveDeviceException* ex)
    {
		FromWaveDeviceBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }

    return (void*) block;
}

void MWDSP_Wai_Start(const void* obj)
{
    FromWaveDeviceBlock* block = (FromWaveDeviceBlock*)obj;
    
    try
    {
		block->Start();
    }
    catch(FromWaveDeviceException* ex)
    {
		FromWaveDeviceBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }
}

void MWDSP_Wai_Outputs(const void * obj, const void* signal)
{
    FromWaveDeviceBlock* block = (FromWaveDeviceBlock*)obj;
    
    try
    {
		block->Outputs(signal);
    }
    catch(FromWaveDeviceException* ex)
    {
		FromWaveDeviceBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }
}


int MWDSP_Wai_Terminate(const void* obj)
{
    if(obj == NULL)
		return FromWaveDeviceBlock::NumberOfInstances();

    FromWaveDeviceBlock* block = (FromWaveDeviceBlock*)obj;
	block->Terminate();

    delete block;

    return FromWaveDeviceBlock::NumberOfInstances();
}

}	// extern "C"