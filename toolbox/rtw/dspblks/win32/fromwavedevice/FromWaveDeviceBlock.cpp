/* $Revision: 1.7 $ */
#include <limits.h>
#include <math.h>
#include "FromWaveDeviceBlock.h"
#include "FromWaveDeviceException.h"

#include <math.h>
#include <ks.h>
#include <ksmedia.h>

/*
 * Globals
 */

static const char* errorMessageTable[] = 
{
    "No error reported",
	"No audio input devices found",
	"Unsupported format",
	"Out of memory",
	"Cannot open audio input device",
	"Cannot start audio input device",
	"Unsupported data type",
	"Invalid error code"
};


int FromWaveDeviceBlock::numFromWaveDeviceBlocks = 0;
int FromWaveDeviceBlock::lastErrorCode = ERR_NO_ERROR;

static void OutputSamples_24Bit_Double(char* buffer, const void* outputSignal, 
								const int numSamples, const int numChannels)
{
    unsigned char *data = (unsigned char *)buffer;
    int i;
	int intSample;
	unsigned char* bytePtr;
	double* y = (double*)outputSignal;

	bytePtr = (unsigned char*) &intSample;

    if (numChannels == 1)	//mono
	{
		for(i=0; i < numSamples; i++)
		{
			bytePtr[1] = *data++;
			bytePtr[2] = *data++;
			bytePtr[3] = *data++;
			bytePtr[0] = intSample > 0 ? 0x00 : 0xFF;
			*y++ = (double) ((double)intSample / INT_MAX);
		}
	}
    else // stereo
	{
		for(i=0; i < numSamples; i++)
		{
			bytePtr[1] = *data++;
			bytePtr[2] = *data++;
			bytePtr[3] = *data++;
			bytePtr[0] = intSample > 0 ? 0x00 : 0xFF;
			*y = (double) ((double)intSample / INT_MAX);

			bytePtr[1] = *data++;
			bytePtr[2] = *data++;
			bytePtr[3] = *data++;
			bytePtr[0] = intSample > 0 ? 0x00 : 0xFF;
			y[numSamples] = (double) ((double)intSample / INT_MAX);
			y++;
		}
	}
}

static void OutputSamples_16Bit_Double(char* buffer, const void* outputSignal, 
								const int numSamples, const int numChannels)
{
    short *data = (short *)buffer;
    int i;
	double* y = (double*)outputSignal;

    if (numChannels == 1)	//mono
	{
		for(i=0; i < numSamples; i++)
			*y++ = *data++ / 32768.0;
	}
    else // stereo
	{
		for(i=0; i < numSamples; i++)
		{
			*y = *data++ / 32768.0;
			y[numSamples] = *data++ / 32768.0;
			y++;
		}
	}
}

static void OutputSamples_8Bit_Double(char* buffer, const void* outputSignal, 
								const int numSamples, const int numChannels)
{
    int i;
	double* y = (double*)outputSignal;
	unsigned char* buf = (unsigned char*) buffer;

    if (numChannels == 1)	// mono
	{
		for(i=0; i < numSamples; i++)
			*y++ = (*buf++ - 128.0) / 128.0;
	} 
	else	// stereo
	{
		for(i=0; i < numSamples; i++) 
		{
			*y = (*buf++ - 128.0) / 128.0;
			y[numSamples] = (*buf++ - 128.0) / 128.0;
			y++;
		}
	}
}


static void OutputSamples_24Bit_Single(char* buffer, const void* outputSignal, 
								const int numSamples, const int numChannels)
{
    unsigned char *data = (unsigned char *)buffer;
    int i;
	int intSample;
	unsigned char* bytePtr;
	float* y = (float*)outputSignal;

	bytePtr = (unsigned char*) &intSample;

    if (numChannels == 1)	//mono
	{
		for(i=0; i < numSamples; i++)
		{
			bytePtr[1] = *data++;
			bytePtr[2] = *data++;
			bytePtr[3] = *data++;
			bytePtr[0] = intSample > 0 ? 0x00 : 0xFF;
			*y++ = (float) ((float)intSample / INT_MAX);
		}
	}
    else // stereo
	{
		for(i=0; i < numSamples; i++)
		{
			bytePtr[1] = *data++;
			bytePtr[2] = *data++;
			bytePtr[3] = *data++;
			bytePtr[0] = intSample > 0 ? 0x00 : 0xFF;
			*y = (float) ((float)intSample / INT_MAX);

			bytePtr[1] = *data++;
			bytePtr[2] = *data++;
			bytePtr[3] = *data++;
			bytePtr[0] = intSample > 0 ? 0x00 : 0xFF;
			y[numSamples] = (float) ((float)intSample / INT_MAX);
			y++;
		}
	}
}


static void OutputSamples_16Bit_Single(char* buffer, const void* outputSignal, 
								const int numSamples, const int numChannels)
{
    short *data = (short *)buffer;
    int i;
	float* y = (float*)outputSignal;

    if (numChannels == 1)	//mono
	{
		for(i=0; i < numSamples; i++)
		{
			*y++ = *data++ / 32768.0;
		}
	}
    else // stereo
	{
		for(i=0; i < numSamples; i++) 
		{
			*y = *data++ / 32768.0;
			y[numSamples] = *data++ / 32768.0;
			y++;
		}
	}
}


static void OutputSamples_8Bit_Single(char* buffer, const void* outputSignal, 
								const int numSamples, const int numChannels)
{
    int i;
	float* y = (float*)outputSignal;
	unsigned char* buf = (unsigned char*) buffer;

    if (numChannels == 1)	// mono
	{
		for(i=0; i < numSamples; i++)
			*y++ = (*buf++ - 128.0) / 128.0;
	} 
	else	// stereo
	{
		for(i=0; i < numSamples; i++) 
		{
			*y = (*buf++ - 128.0) / 128.0;
			y[numSamples] = (*buf++ - 128.0) / 128.0;
			y++;
		}
	}
}


static void OutputSamples_16Bit_Int16(char* buffer, const void* outputSignal, 
								const int numSamples, const int numChannels)
{
    short *data = (short *)buffer;
    int i;
	short* y = (short*)outputSignal;

    if (numChannels == 1)	//mono
	{
		for(i=0; i < numSamples; i++)
		{
			*y++ = *data++;
		}
	}
    else // stereo
	{
		for(i=0; i < numSamples; i++) 
		{
			*y = *data++;
			y[numSamples] = *data++;
			y++;
		}
	}
}


static void OutputSamples_8Bit_Uint8(char* buffer, const void* outputSignal, 
								const int numSamples, const int numChannels)
{
    int i;
	unsigned char* y = (unsigned char*)outputSignal;
	unsigned char* buf = (unsigned char*) buffer;

    if (numChannels == 1)	// mono
	{
		for(i=0; i < numSamples; i++)
			*y++ = *buf++;
	} 
	else	// stereo
	{
		for(i=0; i < numSamples; i++) 
		{
			*y = *buf++;
			y[numSamples] = *buf++;
			y++;
		}
	}
}



OUTPUT_SAMPLES_FUNC outputSamplesFcnTable[] = 
{
	OutputSamples_8Bit_Double,
	OutputSamples_16Bit_Double,
	OutputSamples_24Bit_Double,
	OutputSamples_8Bit_Single,
	OutputSamples_16Bit_Single,
	OutputSamples_24Bit_Single,
	OutputSamples_8Bit_Uint8,
	OutputSamples_16Bit_Int16
};


static DWORD WINAPI inputMessageThread(LPVOID param)
{
	FromWaveDeviceBlock* block = (FromWaveDeviceBlock*) param;
	bool exitLoop = false;

	for (;;)
    {
        // While we have messages, process them.
        MSG msg;
        while (PeekMessage(&msg, NULL, 0, 0, PM_NOREMOVE))
        {
            if (GetMessage(&msg, NULL, 0, 0))
            {
                switch (msg.message)
                {
					case MM_WIM_DATA:
						block->BufferDone((LPWAVEHDR)msg.lParam);
						break;
					case MM_WIM_CLOSE:
						exitLoop = true;
						break;
					default:
						break;
                }
            }
            else
            {
				exitLoop = true;
                break;
            }
        }

        // All messages have been processed. Check if we need to terminate.
        if (exitLoop)
            break;

        // Wait for more messages.
        WaitMessage();
    }
	
	return(0);
}




FromWaveDeviceBlock::FromWaveDeviceBlock(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, unsigned int whichDevice, bool useTheWaveMapper)
{
	bufferSizeInSeconds = bufSizeInSeconds;
	useWaveMapper = useTheWaveMapper;
	if(useWaveMapper)
		deviceID = WAVE_MAPPER;
	else
		deviceID = whichDevice;

    bitsPerSample = bits;
	dataType = dType;

	// set to 8- or 16-bit input if output data type is uint8 or int16
	if(dataType == 3)	// uint8, so 8-bit
		bitsPerSample = 8;
	if(dataType == 4)	// int16, so 16-bit
		bitsPerSample = 16;

    bytesPerSample = bitsPerSample / 8;
    numChannels = chans;
    numSamplesPerInputFrame = inputBufSize;
    sampleRate = rate;

    waveFormat.Format.nChannels = numChannels; 
    waveFormat.Format.nSamplesPerSec = (DWORD) sampleRate; 
    waveFormat.Format.nBlockAlign = bytesPerSample * numChannels; 
	waveFormat.Format.nAvgBytesPerSec = waveFormat.Format.nSamplesPerSec * waveFormat.Format.nBlockAlign; 
    waveFormat.Format.wBitsPerSample = bitsPerSample;
	if(bitsPerSample > 16)
	{
		waveFormat.Format.wFormatTag = WAVE_FORMAT_EXTENSIBLE; 
		waveFormat.Format.cbSize = 22;
		waveFormat.Samples.wValidBitsPerSample = bitsPerSample;
		waveFormat.dwChannelMask = SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT;
		waveFormat.SubFormat = KSDATAFORMAT_SUBTYPE_PCM;
	}
	else
	{
		waveFormat.Format.wFormatTag = WAVE_FORMAT_PCM; 
		waveFormat.Format.cbSize = 0;
	}
	
	hWaveIn = NULL;

	buffers = NULL;
	bufSizeInBytes = numSamplesPerInputFrame * bytesPerSample * numChannels;
	numBuffers = ceil(bufferSizeInSeconds * sampleRate / inputBufSize);
	if(numBuffers < MIN_NUM_BUFFERS)
		numBuffers = MIN_NUM_BUFFERS;
	if(numBuffers > MAX_NUM_BUFFERS)
		numBuffers = MAX_NUM_BUFFERS;
	numBuffersInDevice = 0;
	
	newestEmpty = NULL; oldestEmpty = NULL; newestFilled = NULL; oldestFilled = NULL;
	numEmpty = 0;	numFilled = 0;
	//currentlyModifyingAnInputQueue = false;
	hMutex = NULL;
	inputMessageThreadHandle = NULL;

	outputSamplesFcn = NULL;

	terminateHasBeenCalled = false;
	blockHasOutputData = false;

	numFromWaveDeviceBlocks++;
}

void FromWaveDeviceBlock::Init()
{
	//check to see if there's an audio input device on the system
	if(waveInGetNumDevs() == 0)
		throw new FromWaveDeviceException(ERR_NO_AUDIO);

	//make sure input device supports this format
	MMRESULT mmResult = waveInOpen(NULL, deviceID, (PWAVEFORMATEX)&waveFormat, NULL, NULL, WAVE_FORMAT_QUERY);
	if(mmResult)
		throw new FromWaveDeviceException(ERR_UNPPTD_FMT);

	//build the WAVEHDR array
	buffers = new WAVEHDR[numBuffers];
	if(buffers == NULL)
		throw new FromWaveDeviceException(ERR_NO_MEMORY);

	//build the actual data buffers for each WAVEHDR 
	// and initialize WAVEHDR fields
	// - dwUser points to the "next oldest" buffer
	oldestEmpty = buffers;
	newestEmpty = &(buffers[numBuffers - 1]);

	LPWAVEHDR temp = NULL;
	for(int i = numBuffers - 1; i >= 0; i--)
	{
		buffers[i].lpData = new char[bufSizeInBytes];
		if(buffers[i].lpData == NULL)
			throw new FromWaveDeviceException(ERR_NO_MEMORY);
		buffers[i].dwBufferLength = bufSizeInBytes;
		buffers[i].dwFlags = 0;
		buffers[i].dwUser = (i == numBuffers - 1) ? NULL : (DWORD) temp;
		temp = &(buffers[i]);
	}

	numEmpty = numBuffers;

	if( dataType != 0 &&	// double
		dataType != 1 &&	// single
		dataType != 3 &&	// uint8
		dataType != 4)		// int16
		throw new FromWaveDeviceException(ERR_UNSUPPORTED_DTYPE);
	
	if(dataType == 1 || dataType == 0)	// double or single
		outputSamplesFcn = outputSamplesFcnTable[3 * dataType + (bytesPerSample - 1)];
	else
		outputSamplesFcn = outputSamplesFcnTable[6 + bytesPerSample - 1];	// uint8 or int16
}


FromWaveDeviceBlock* FromWaveDeviceBlock::New(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, unsigned int whichDevice, bool useTheWaveMapper)
{
	FromWaveDeviceBlock* block = new FromWaveDeviceBlock(rate, bits, chans, inputBufSize, dType,
						bufSizeInSeconds, whichDevice, useTheWaveMapper);
	try
	{
		block->Init();
	}
	catch(FromWaveDeviceException* ex)
	{
		delete block;  block = NULL;
		throw ex;
	}
	return block;
}


FromWaveDeviceBlock::~FromWaveDeviceBlock()
{
	if(buffers != NULL)
	{
		for(int i = 0; i < numBuffers; i++)
		{
			if(buffers[i].lpData != NULL)
				delete buffers[i].lpData;
		}

		delete [] buffers;
	}

	numFromWaveDeviceBlocks--;
}

//TODO: make this return a bool for success or not?
void FromWaveDeviceBlock::Start()
{
	hMutex = CreateMutex(NULL, false, NULL);
	inputMessageThreadHandle = CreateThread(NULL, NULL, &inputMessageThread, (LPVOID)this, 0, &inputMessageThreadID);
	if(inputMessageThreadHandle == NULL)
	{
		SetErrorCode(ERR_CANNOT_OPEN_DEV);
		return;
	}

	Sleep(0);	// hack for NT 4.0 - allow new thread to start and create its message queue
				// before opening audio device

	MMRESULT mmResult = waveInOpen(&hWaveIn, deviceID, (PWAVEFORMATEX)&waveFormat, inputMessageThreadID, (DWORD) this, 0 | CALLBACK_THREAD);

	if(mmResult)
	{
		SetErrorCode(ERR_CANNOT_OPEN_DEV);
		return;
	}
	else
		sendAllEmptyBuffersToDevice();
	
	mmResult = waveInStart(hWaveIn);
	if(mmResult)
	{
		SetErrorCode(ERR_CANNOT_START_DEV);
		return;
	}
}

void FromWaveDeviceBlock::Outputs(const void* outputSignal)
{
	LPWAVEHDR hdr = NULL;

	// take the oldest filled buffer and output it, or wait for one to 
	// be filled
	while(GetErrorCode() == ERR_NO_ERROR && (hdr = popFromFilledQueue()) == NULL)
		Sleep(0);

	if(GetErrorCode())	// something happened
		throw new FromWaveDeviceException(GetErrorCode());

	// pass the data ptr to a fcn, which will output the signal in the desired 
	// data type
	outputSamplesFcn(hdr->lpData, outputSignal, numSamplesPerInputFrame, numChannels);

	//add this buffer to the empty queue
	addToEmptyQueue(hdr);

	blockHasOutputData = true;

	//send whatever to the device that you can
	sendAllEmptyBuffersToDevice();
}


void FromWaveDeviceBlock::BufferDone(LPWAVEHDR done)
{
	//unprepare it
	getMutex();
	waveInUnprepareHeader(hWaveIn, done, sizeof(WAVEHDR));
	InterlockedDecrement(&numBuffersInDevice);

	//put into filled queue
	addToFilledQueue(done);
	freeMutex();

	//send empties to the input device
	sendAllEmptyBuffersToDevice();
}


void FromWaveDeviceBlock::closeDevice()
{
	getMutex();
	if(hWaveIn != NULL)
	{
		waveInReset(hWaveIn);    
		waveInClose(hWaveIn);
	}

	hWaveIn = NULL;
	freeMutex();
}


void FromWaveDeviceBlock::sendAllEmptyBuffersToDevice()
{
	if(hWaveIn == NULL)
		return;

	LPWAVEHDR buffer;
	getMutex();
	while(numBuffersInDevice <= MAX_BUFFERS_IN_DEVICE && (buffer = popFromEmptyQueue()) != NULL)
	{
		waveInPrepareHeader(hWaveIn, buffer, sizeof(WAVEHDR));
		waveInAddBuffer(hWaveIn, buffer, sizeof(WAVEHDR));
		InterlockedIncrement(&numBuffersInDevice);
	}
	freeMutex();
}

void FromWaveDeviceBlock::Terminate()
{	
	closeDevice();

	if(inputMessageThreadHandle != NULL)
	{
		WaitForSingleObject(inputMessageThreadHandle, INFINITE);
		CloseHandle(inputMessageThreadHandle);
	}

	if(hMutex != NULL)
		CloseHandle(hMutex);
}

void FromWaveDeviceBlock::SetErrorCode(int code)
{
    lastErrorCode = code;
}

int FromWaveDeviceBlock::GetErrorCode()
{
    return lastErrorCode;
}

const char* FromWaveDeviceBlock::GetErrorMessage()
{
	if(GetErrorCode() >= ERR_NUMBER_OF_ERRORS)
		SetErrorCode(ERR_NUMBER_OF_ERRORS);

    const char* msg = errorMessageTable[lastErrorCode];
    SetErrorCode(ERR_NO_ERROR);
    return msg;
}


void FromWaveDeviceBlock::getMutex()
{
	WaitForSingleObject(hMutex, INFINITE);
}

void FromWaveDeviceBlock::freeMutex()
{
	ReleaseMutex(hMutex);
}

void FromWaveDeviceBlock::addToFilledQueue(LPWAVEHDR hdr)
{
	if(hdr == NULL)
		return;

	getMutex();

	if(newestFilled == NULL)
	{
		oldestFilled = hdr;
		newestFilled = oldestFilled;
		oldestFilled->dwUser = NULL;
	}
	else
	{
		newestFilled->dwUser = (DWORD) hdr;
		hdr->dwUser = NULL;
		newestFilled = hdr;
	}

	InterlockedIncrement(&numFilled);

	freeMutex();
}

LPWAVEHDR FromWaveDeviceBlock::popFromFilledQueue()
{
	getMutex();
	if(oldestFilled == NULL)
	{
		freeMutex();
		return NULL;
	}

	LPWAVEHDR ret = oldestFilled;
	oldestFilled = (LPWAVEHDR) oldestFilled->dwUser;
	if(oldestFilled == NULL)	// empty
		newestFilled = NULL;

	InterlockedDecrement(&numFilled);

	freeMutex();

	return ret;
}

void FromWaveDeviceBlock::addToEmptyQueue(LPWAVEHDR hdr)
{
	if(hdr == NULL)
		return;

	getMutex();

	if(newestEmpty == NULL)
	{
		oldestEmpty = hdr;
		newestEmpty = oldestEmpty;
		oldestEmpty->dwUser = NULL;
	}
	else
	{
		newestEmpty->dwUser = (DWORD) hdr;
		hdr->dwUser = NULL;
		newestEmpty = hdr;
	}

	InterlockedIncrement(&numEmpty);

	freeMutex();
}

LPWAVEHDR FromWaveDeviceBlock::popFromEmptyQueue()
{
	getMutex();
	if(oldestEmpty == NULL)
	{
		freeMutex();
		return NULL;
	}

	LPWAVEHDR ret = oldestEmpty;
	oldestEmpty = (LPWAVEHDR) oldestEmpty->dwUser;
	if(oldestEmpty == NULL)		// empty
		newestEmpty = NULL;

	InterlockedDecrement(&numEmpty);

	freeMutex();

	return ret;
}

