/* $Revision: 1.1 $ */
#include <math.h>
#include <stdlib.h>
#include "ToWaveFileBlock.h"
#include "ToWaveFileException.h"

/*
 * Error message functions
 */

extern "C"
{

void MWDSP_Wafo_SetErrorCode(int code)
{
    ToWaveFileBlock::SetErrorCode(code);
}

int MWDSP_Wafo_GetErrorCode()
{
    return ToWaveFileBlock::GetErrorCode();
}

const char* MWDSP_Wafo_GetErrorMessage()
{
	return ToWaveFileBlock::GetErrorMessage();
}


void* MWDSP_Wafo_Create(char* outputFilename, unsigned short bits, 
		    int minSampsToWrite, int chans, int inputBufSize,
		    double rate, int dType)
{
	ToWaveFileBlock::SetErrorCode(ERR_NO_ERROR);

    ToWaveFileBlock* block = NULL;
    
	try
    {
		block = ToWaveFileBlock::New(outputFilename, bits, minSampsToWrite, chans, inputBufSize, 
						    rate, dType);
    }
    catch(ToWaveFileException* ex)
    {
		delete block;  block = NULL;
		ToWaveFileBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }

    return (void*) block;
}


void MWDSP_Wafo_Outputs(const void * obj, const void* signal)
{
	if(signal == NULL)
		return;

    ToWaveFileBlock* block = (ToWaveFileBlock*)obj;
    
    try
    {
		block->Outputs(signal);
    }
    catch(ToWaveFileException* ex)
    {
		ToWaveFileBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }
}


int MWDSP_Wafo_Terminate(const void* obj)
{
    if(obj == NULL)
		return ToWaveFileBlock::NumberOfInstances();

    ToWaveFileBlock* block = (ToWaveFileBlock*)obj;
    
    try
    {
		block->Terminate();
    }
    catch(ToWaveFileException* ex)
    {
		ToWaveFileBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }

    delete block;

    return ToWaveFileBlock::NumberOfInstances();
}

}		// extern "C"