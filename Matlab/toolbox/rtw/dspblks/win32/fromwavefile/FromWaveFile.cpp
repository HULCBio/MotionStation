/* $Revision: 1.2 $ */
#include <math.h>
#include <stdlib.h>
#include "FromWaveFileBlock.h"
#include "FromWaveFileException.h"

/*
 * Error message functions
 */

extern "C"
{

void MWDSP_Wafi_SetErrorCode(int code)
{
    FromWaveFileBlock::SetErrorCode(code);
}

int MWDSP_Wafi_GetErrorCode()
{
    return FromWaveFileBlock::GetErrorCode();
}

const char* MWDSP_Wafi_GetErrorMessage()
{
	return FromWaveFileBlock::GetErrorMessage();
}


void* MWDSP_Wafi_Create(const char* filename, unsigned short bits, 
			int minSampsToRead, int chans, int inputBufSize, double rate, 
			int dType)
{
	FromWaveFileBlock::SetErrorCode(ERR_NO_ERROR);

    FromWaveFileBlock* block = NULL;
    
	try
    {
		block = FromWaveFileBlock::New(filename, bits, minSampsToRead, chans, 
										inputBufSize, rate, dType);
    }
    catch(FromWaveFileException* ex)
    {
		delete block;  block = NULL;
		FromWaveFileBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }

    return (void*) block;
}


void MWDSP_Wafi_Outputs(const void * obj, const void* signal)
{
	if(signal == NULL)
		return;

    FromWaveFileBlock* block = (FromWaveFileBlock*)obj;
    
    try
    {
		block->Outputs(signal);
    }
    catch(FromWaveFileException* ex)
    {
		FromWaveFileBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }
}


int MWDSP_Wafi_Terminate(const void* obj)
{
    if(obj == NULL)
		return FromWaveFileBlock::NumberOfInstances();

    FromWaveFileBlock* block = (FromWaveFileBlock*)obj;
    
    try
    {
		block->Terminate();
    }
    catch(FromWaveFileException* ex)
    {
		FromWaveFileBlock::SetErrorCode(ex->GetErrorCode());
		delete ex;
    }

    delete block;

    return FromWaveFileBlock::NumberOfInstances();
}

void MWDSP_Wafi_SetNumRepeats(void* obj, long rpts)
{
	FromWaveFileBlock* block = (FromWaveFileBlock*)obj;

	block->SetNumRepeats(rpts);
}


long MWDSP_Wafi_GetNumRepeats(void* obj)
{
	FromWaveFileBlock* block = (FromWaveFileBlock*)obj;

	return block->GetNumRepeats();
}


void MWDSP_Wafi_SetRestartMode(void* obj, int restart)
{
	FromWaveFileBlock* block = (FromWaveFileBlock*)obj;
	block->SetRestartMode((RestartMode)restart);
}


int MWDSP_Wafi_GetRestartMode(void* obj)
{
	FromWaveFileBlock* block = (FromWaveFileBlock*)obj;
	return (int) block->GetRestartMode();
}


unsigned short MWDSP_Wafi_JustOutputFirstSample(void* obj)
{
	FromWaveFileBlock* block = (FromWaveFileBlock*)obj;
	unsigned short ret = block->LastOutputsHadFirstSample() ? 1 : 0;
	return ret;
}

unsigned short MWDSP_Wafi_JustOutputLastSample(void* obj)
{
	FromWaveFileBlock* block = (FromWaveFileBlock*)obj;
	unsigned short ret = block->LastOutputsHadLastSample() ? 1 : 0;
	return ret;
}

}		// extern "C"