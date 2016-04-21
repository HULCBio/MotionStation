/* $Revision: 1.6 $ */
#include <limits.h>
#include <math.h>
#include "ToWaveDeviceBlock.h"
#include "ToWaveDeviceException.h"

#include <math.h>
#include <ks.h>
#include <ksmedia.h>

/*
 * Globals
 */

static const char* errorMessageTable[] = 
{
    "No error reported",
	"Unsupported data type",
	"Unsupported format",
	"Out of memory",
	"No audio output devices detected",
	"Unable to open audio device for output",
	"Invalid error code"
};


int ToWaveDeviceBlock::numToWaveDeviceBlocks = 0;
int ToWaveDeviceBlock::lastErrorCode = ERR_NO_ERROR;


static DWORD WINAPI outputMessageThread(LPVOID param)
{
	ToWaveDeviceBlock* block = (ToWaveDeviceBlock*) param;
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
					case MM_WOM_DONE:
						block->BufferDone((LPWAVEHDR)msg.lParam);
						break;
					case MM_WOM_CLOSE:
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



DWORD WINAPI initialWaitTimer(LPVOID param)
{
	ToWaveDeviceBlock* block = (ToWaveDeviceBlock*) param;

	Sleep(block->initialDelayInSeconds * 1000);
	
	if(! block->terminateHasBeenCalled)
		block->startPlaying();

	return(0);
}


/* Function: GetInputBuffer_Double ===========================================
 * Abstract:
 *    Get data from double-precision input.
 *    Record as 16-bit signed integers.
 */
static void GetInputBuffer_Double(char* buffer, const void* signal, 
								  const int numSamples, const int numChannels)
{
    const double *u = (double *)signal;
    short *buf = (short *)buffer;
    int i;
	int channel;
	double sample;

    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++) 
		{
			sample = u[numSamples * channel + i] * 32768;
			if(sample < -32768) 
				sample =-32768;
			else 
			if (sample >  32767)
				sample = 32767;
			
			*buf++ = (short)sample;
        }
    }
}


/* Function: GetInputBuffer_Double_24Bit ===========================================
 * Abstract:
 *    Get data from double-precision input (scaled from -1 to +1)
 *    Record as 24-bit signed integers.
 */
static void GetInputBuffer_Double_24Bit(char* buffer, const void* signal, 
								  const int numSamples, const int numChannels)
{
    const double *u = (double *)signal;
	unsigned char* sampleBuffer = (unsigned char*)buffer;
    int i;
	int intSample;
	int channel;
	double sample;

    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++) 
		{
			sample = u[numSamples * channel + i] * INT_MAX;
			if(sample < INT_MIN) 
				sample = INT_MIN;
			else 
			if (sample >  INT_MAX)
				sample = INT_MAX;

			intSample = (int) sample;

			*sampleBuffer++ = (unsigned char)((intSample >> 8 ) & 0x000000FF);
			*sampleBuffer++ = (unsigned char)((intSample >> 16) & 0x000000FF);
			*sampleBuffer++ = (unsigned char)((intSample >> 24) & 0x000000FF);
        }
    }
}


/* Function: GetInputBuffer_Single_24Bit ===========================================
 * Abstract:
 *    Get data from single-precision input (scaled from -1 to +1)
 *    Record as 24-bit signed integers.
 */
static void GetInputBuffer_Single_24Bit(char* buffer, const void* signal, 
								  const int numSamples, const int numChannels)
{
    const float *u = (float *)signal;
	unsigned char* sampleBuffer = (unsigned char*)buffer;
    int i;
	int intSample;
	int channel;
	float sample;

    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++) 
		{
			sample = u[numSamples * channel + i] * INT_MAX;
			if(sample < INT_MIN) 
				sample = (float) INT_MIN;
			else 
			if (sample >  INT_MAX)
				sample = (float) INT_MAX;

			intSample = (int) sample;

			*sampleBuffer++ = (unsigned char)((intSample >> 8 ) & 0x000000FF);
			*sampleBuffer++ = (unsigned char)((intSample >> 16) & 0x000000FF);
			*sampleBuffer++ = (unsigned char)((intSample >> 24) & 0x000000FF);
        }
    }
}



/* Function: GetInputBuffer_Single ===========================================
 * Abstract:
 *    Get data from single-precision input.
 *    Record as 16-bit signed integers.
 */
static void GetInputBuffer_Single(char* buffer, const void* signal, 
								  const int numSamples, const int numChannels)
{
    const float *u = (float *)signal;
    short *buf = (short *)buffer;
    int i;
	int channel;
	float sample;

    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++) 
		{
			sample = u[numSamples * channel + i] * 32768;
			if(sample < -32768) 
				sample =-32768;
			else 
				if (sample >  32767) sample = 32767;
			*buf++ = (short)sample;
        }
    }
}


/* Function: GetInputBuffer_Int16 ============================================
 * Abstract:
 *    Get data from int16 input.
 *    Record as 16-bit signed integers.
 */
static void GetInputBuffer_Int16(char* buffer, const void* signal, 
								  const int numSamples, const int numChannels)
{
    const short *u = (short *)signal;
    short *buf = (short *)buffer;
    int i;
	int channel;

    for (i=0; i < numSamples; i++) {
        for (channel=0; channel < numChannels; channel++) 
		{
			*buf++ = (short)u[numSamples * channel + i];
        }
    }
}


/* Function: GetInputBuffer_Uint8 ============================================
 * Abstract:
 *    Get data from uint8 input.
 *    Record as 8-bit unsigned integers.
 */
static void GetInputBuffer_Uint8(char* buffer, const void* signal, 
								  const int numSamples, const int numChannels)
{
    const unsigned char *u = (unsigned char *)signal;
    unsigned char *buf = (unsigned char *)buffer;
    int i;
	int channel;

    for (i=0; i < numSamples; i++) 
	{
		for (channel=0; channel < numChannels; channel++)
			*buf++ = (unsigned char)u[numSamples * channel + i];
    }
}

GET_INPUT_BUFFER_FUNC getInputBufFcnTable[] = 
{
	GetInputBuffer_Double,
	GetInputBuffer_Single,
	GetInputBuffer_Int16,
	GetInputBuffer_Uint8,
	GetInputBuffer_Double_24Bit,
	GetInputBuffer_Single_24Bit
};


ToWaveDeviceBlock::ToWaveDeviceBlock(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, double initialDelay, unsigned int whichDevice, 
						bool useTheWaveMapper)
{
	bufferSizeInSeconds = bufSizeInSeconds;
	initialDelayInSeconds = initialDelay;
	useWaveMapper = useTheWaveMapper;
	if(useWaveMapper)
		deviceID = WAVE_MAPPER;
	else
		deviceID = whichDevice;

    bitsPerSample = bits;
    bytesPerSample = bitsPerSample / 8;
    numChannels = chans;
    numSamplesPerInputFrame = inputBufSize;
    sampleRate = rate;
    dataType = dType;

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
	
	hWaveOut = NULL;

	buffers = NULL;
	bufSizeInBytes = numSamplesPerInputFrame * bytesPerSample * numChannels;
	numBuffers = ceil(bufferSizeInSeconds * sampleRate / inputBufSize);
	numBuffersInDevice = 0;
	
	newestEmpty = NULL; oldestEmpty = NULL; newestFilled = NULL; oldestFilled = NULL;
	numEmpty = 0;	numFilled = 0;
	//currentlyModifyingAnOutputQueue = false;
	outputMessageThreadHandle = NULL;
	initialWaitTimerHandle = NULL;
	hMutex = NULL;

	getInputBufferFcn = NULL;

	terminateHasBeenCalled = false;
	dataHasBeenReceived = false;
	
	numToWaveDeviceBlocks++;
}

void ToWaveDeviceBlock::Init()
{
	//check to see if there's an audio output device on the system
	if(waveOutGetNumDevs() == 0)
		throw new ToWaveDeviceException(ERR_NO_AUDIO);

	// make sure output device supports this format
	MMRESULT mmResult = waveOutOpen(NULL, deviceID, (PWAVEFORMATEX)&waveFormat, NULL, NULL, WAVE_FORMAT_QUERY);
	
	if(mmResult)
		throw new ToWaveDeviceException(ERR_UNPPTD_FMT);

	//build the WAVEHDR array
	buffers = new WAVEHDR[numBuffers];
	if(buffers == NULL)
		throw new ToWaveDeviceException(ERR_NO_MEMORY);

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
			throw new ToWaveDeviceException(ERR_NO_MEMORY);
		buffers[i].dwBufferLength = bufSizeInBytes;
		buffers[i].dwFlags = 0;
		buffers[i].dwUser = (i == numBuffers - 1) ? NULL : (DWORD) temp;
		temp = &(buffers[i]);
	}

	numEmpty = numBuffers;

	switch(dataType)
	{
	case 0:		// SS_DOUBLE
		getInputBufferFcn = bitsPerSample == 24 ? getInputBufFcnTable[4] : getInputBufFcnTable[0];
		break;
	case 1:		// SS_SINGLE
		getInputBufferFcn = bitsPerSample == 24 ? getInputBufFcnTable[5] : getInputBufFcnTable[1];
		break;
	case 4:		// SS_INT16
		getInputBufferFcn = getInputBufFcnTable[2];
		break;
	case 3:		// SS_UINT8
		getInputBufferFcn = getInputBufFcnTable[3];
		break;
	default:
		throw new ToWaveDeviceException(ERR_UNSPPTD_DTYPE);
	}
}


ToWaveDeviceBlock* ToWaveDeviceBlock::New(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, double initialDelay, unsigned int whichDevice, 
						bool useTheWaveMapper)
{
	ToWaveDeviceBlock* block = new ToWaveDeviceBlock(rate, bits, chans, inputBufSize, dType,
						bufSizeInSeconds, initialDelay, whichDevice, useTheWaveMapper);
	try
	{
		block->Init();
	}
	catch(ToWaveDeviceException* ex)
	{
		delete block;  block = NULL;
		throw ex;
	}
	return block;
}


ToWaveDeviceBlock::~ToWaveDeviceBlock()
{
	DWORD exitCode = NULL;
	//make sure the initial wait timer thread has completed
	GetExitCodeThread(initialWaitTimerHandle, &exitCode);
	if(exitCode == STILL_ACTIVE)
		WaitForSingleObject(initialWaitTimerHandle, INFINITE);
	CloseHandle(initialWaitTimerHandle);

	//make sure the output message thread has completed
	if(outputMessageThreadHandle != NULL)
	{
		GetExitCodeThread(outputMessageThreadHandle, &exitCode);
		if(exitCode == STILL_ACTIVE)
			WaitForSingleObject(outputMessageThreadHandle, INFINITE);
		CloseHandle(outputMessageThreadHandle);
	}

	if(hMutex != NULL)
		CloseHandle(hMutex);

	if(buffers != NULL)
	{
		for(int i = 0; i < numBuffers; i++)
		{
			if(buffers[i].lpData != NULL)
				delete buffers[i].lpData;
		}

		delete [] buffers;
	}
	
	numToWaveDeviceBlocks--;
}

void ToWaveDeviceBlock::Start()
{
	hMutex = CreateMutex(NULL, FALSE, NULL);
	initialWaitTimerHandle = CreateThread(NULL, NULL, &initialWaitTimer, (LPVOID)this, 0, &initialWaitTimerID);
}

// called from the MATLAB/Simulink thread
void ToWaveDeviceBlock::Update(const void* signal)
{
	LPWAVEHDR hdr = NULL;
	
	dataHasBeenReceived = true;

	//take a buffer off the empty queue, or wait 'til one's available
	while(GetErrorCode() == ERR_NO_ERROR && (hdr = popFromEmptyQueue()) == NULL)
	{
		Sleep(0);
		sendAllFilledBuffersToDevice();
	}

	if(GetErrorCode())	// something happened
		throw new ToWaveDeviceException(GetErrorCode());

	//pass the data ptr to a fcn to be filled in with the signal
	getInputBufferFcn(hdr->lpData, signal, numSamplesPerInputFrame, numChannels);

	//add this buffer to the filled queue
	addToFilledQueue(hdr);

	//send whatever to the device that you can
	sendAllFilledBuffersToDevice();
}


// called from outputMessageThread, above
void ToWaveDeviceBlock::BufferDone(LPWAVEHDR done)
{
	//unprepare it
	getMutex();
	waveOutUnprepareHeader(hWaveOut, done, sizeof(WAVEHDR));
	InterlockedDecrement(&numBuffersInDevice);

	//put back in empty queue
	addToEmptyQueue(done);
	freeMutex();

	//play out whatever we have
	sendAllFilledBuffersToDevice();

	if(terminateHasBeenCalled && numFilled == 0 && numBuffersInDevice == 0)	//we're all done, close the device
		closeDevice();
}


void ToWaveDeviceBlock::addToFilledQueue(LPWAVEHDR hdr)
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

LPWAVEHDR ToWaveDeviceBlock::popFromFilledQueue()
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

void ToWaveDeviceBlock::addToEmptyQueue(LPWAVEHDR hdr)
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

LPWAVEHDR ToWaveDeviceBlock::popFromEmptyQueue()
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


void ToWaveDeviceBlock::getMutex()
{
	WaitForSingleObject(hMutex, INFINITE);
}

void ToWaveDeviceBlock::freeMutex()
{
	ReleaseMutex(hMutex);
}


bool ToWaveDeviceBlock::startPlaying()
{
	outputMessageThreadHandle = CreateThread(NULL, NULL, &outputMessageThread, (LPVOID)this, 0, &outputMessageThreadID);
	if(outputMessageThreadHandle == NULL)
	{
		SetErrorCode(ERR_CANNOT_OPEN_DEV);
		return false;
	}

	Sleep(0);	// hack for NT 4.0 - allow new thread to start and create its message queue
				// before opening audio device

	getMutex();
	MMRESULT mmResult = waveOutOpen(&hWaveOut, deviceID, (PWAVEFORMATEX)&waveFormat, outputMessageThreadID, (DWORD) this, 0 | CALLBACK_THREAD);
	freeMutex();

	if(mmResult)
	{
		SetErrorCode(ERR_CANNOT_OPEN_DEV);
		return false;
	}

	return true;
}

void ToWaveDeviceBlock::closeDevice()
{
	getMutex();
	if(hWaveOut != NULL)
	{
		waveOutReset(hWaveOut);    
		waveOutClose(hWaveOut);
	}

	hWaveOut = NULL;
	freeMutex();
}


void ToWaveDeviceBlock::sendAllFilledBuffersToDevice()
{
	if(hWaveOut == NULL)
		return;

	LPWAVEHDR buffer;
	getMutex();
	while(numBuffersInDevice <= MAX_BUFFERS_IN_DEVICE && (buffer = popFromFilledQueue()) != NULL)
	{
		waveOutPrepareHeader(hWaveOut, buffer, sizeof(WAVEHDR));
		waveOutWrite(hWaveOut, buffer, sizeof(WAVEHDR));
		InterlockedIncrement(&numBuffersInDevice);
	}
	freeMutex();
}

bool ToWaveDeviceBlock::isDonePlaying()
{
	if(hWaveOut == NULL)
		return true;
	else
		return false;
}

void ToWaveDeviceBlock::Terminate()
{
	terminateHasBeenCalled = true;
	
	// either codegen (no updates) or everything has already been played
	if(! dataHasBeenReceived || (numFilled == 0 && numBuffersInDevice == 0))
	{
		closeDevice();
	}
    
	while(! isDonePlaying())
	{
		Sleep(0);	//wait 'til we're done playing to return
		if(numFilled == 0 && numBuffersInDevice == 0)
			closeDevice();
	}
}

void ToWaveDeviceBlock::SetErrorCode(int code)
{
    lastErrorCode = code;
}

int ToWaveDeviceBlock::GetErrorCode()
{
    return lastErrorCode;
}

const char* ToWaveDeviceBlock::GetErrorMessage()
{
	if(GetErrorCode() >= ERR_NUMBER_OF_ERRORS)
		SetErrorCode(ERR_NUMBER_OF_ERRORS);

    const char* msg = errorMessageTable[lastErrorCode];
    SetErrorCode(ERR_NO_ERROR);
    return msg;
}
