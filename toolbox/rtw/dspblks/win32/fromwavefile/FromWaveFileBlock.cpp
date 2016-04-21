/* $Revision: 1.5 $ */
#include "FromWaveFileBlock.h"
#include "FromWaveFileException.h"

#include <limits.h>
#include <math.h>

int FromWaveFileBlock::numFromWaveFileBlocks = 0;
int FromWaveFileBlock::lastErrorCode = ERR_NO_ERROR;

/*
 * Globals
 */

static const char* errorMessageTable[] = 
{
    "No error reported",
    "File name too long",
    "File name must not contain a \"+\" character",
	"Error opening file",
	"Error reading file header",
	"Wave file is not in PCM or IEEE floating-point format",
	"File contains wrong number of channels",
	"File has wrong sample rate",
	"Error exiting data chunk",
	"Error exiting wave chunk",
	"Error reading file",
	"File contains wrong number of bits",
	"Unsupported data type",
	"For 24- and 32-bit files, only single- and double-precision\noutput is supported",
	"File must either be 8- or 16-bit for uint8 or int16 output",
	"Error seeking to beginning of data chunk",
	"Invalid restart mode",
	"Invalid error code"
};


static void ConvertSamples_Double_24bit(const void* outputSignal, unsigned char* buffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    unsigned char *data = buffer;
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


static void ConvertSamples_Single_24bit(const void* outputSignal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    unsigned char *data = sampleBuffer;
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



static void ConvertSamples_Double_32bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    float* buf = (float*)sampleBuffer;
    double* y = (double*)signal;
	int i;
	int channel;

    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++)
            y[numSamples * channel + i] = (double) *buf++;
    }
}


static void ConvertSamples_Single_32bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    float* buf = (float*)sampleBuffer;
    float* y = (float*)signal;
	int i;
	int channel;

    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++)
            y[numSamples * channel + i] = *buf++;
    }
}


static void ConvertSamples_Double_16bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    short *buf = (short *)sampleBuffer;
    double* y = (double*)signal;
	int i;
	int channel;
    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++)
            y[numSamples * channel + i] = *buf++ / 32768.0;
    }
}

static void ConvertSamples_Double_8bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
	double* y = (double*) signal;
    int i;
	int channel;
    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++) {
            y[numSamples * channel + i] = (*sampleBuffer++ - 128.0) / 128.0;
        }
    }
}


static void ConvertSamples_Single_16bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    short *buf = (short *)sampleBuffer;
    float* y = (float*)signal;
	int i;
	int channel;
    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++)
            y[numSamples * channel + i] = *buf++ / 32768.0;
    }
}

static void ConvertSamples_Single_8bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
	float* y = (float*) signal;
    int i;
	int channel;
    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++) {
            y[numSamples * channel + i] = (*sampleBuffer++ - 128.0) / 128.0;
        }
    }
}


static void ConvertSamples_Int16_16bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    short *buf = (short *)sampleBuffer;
    short* y = (short*)signal;
	int i;
	int channel;
    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++)
            y[numSamples * channel + i] = *buf++;
    }
}


static void ConvertSamples_Int16_8bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
	short* y = (short*) signal;
    int i;
	int channel;
    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++) {
            y[numSamples * channel + i] = (*sampleBuffer++ - 128) * 256;
        }
    }
}


static void ConvertSamples_Uint8_16bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
	unsigned char* y = (unsigned char*) signal;
	short* buf = (short*)sampleBuffer;

    int i;
	int channel;
    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++) {
            y[numSamples * channel + i] = ((*buf++) / 256) + 128;
        }
    }
}


static void ConvertSamples_Uint8_8bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    unsigned char* buf = (unsigned char*)sampleBuffer;
    unsigned char* y = (unsigned char*)signal;
	int i;
	int channel;
    for (i=0; i < numSamples; i++) 
	{
        for (channel=0; channel < numChannels; channel++)
            y[numSamples * channel + i] = *buf++;
    }
}



static CONVERT_SAMPLES_FUNC ConvertSamplesFcnTable[] =
{
	ConvertSamples_Double_8bit,
	ConvertSamples_Double_16bit,
	ConvertSamples_Double_24bit,
	ConvertSamples_Double_32bit,

	ConvertSamples_Single_8bit,
	ConvertSamples_Single_16bit,
	ConvertSamples_Single_24bit,
	ConvertSamples_Single_32bit,

	ConvertSamples_Uint8_8bit,
	ConvertSamples_Uint8_16bit,

	ConvertSamples_Int16_8bit,
	ConvertSamples_Int16_16bit
};

void FromWaveFileBlock::makeStuffNull()
{
    inWaveChunk = false;
    inDataChunk = false;
    
    filename = NULL;
    fileHandle = NULL;

    dataChunkInfo = NULL;
    waveChunkInfo = NULL;
	numBytesInFile = 0;

    waveFormat = NULL;

    dataCache = NULL;
}

FromWaveFileBlock::FromWaveFileBlock(unsigned short bits, int minSampsToRead, 
			int chans, int inputBufSize, double rate, int dType)
{
    makeStuffNull();

    bitsPerSample = bits;
    bytesPerSample = bits / 8;
    minSamplesToRead = minSampsToRead;
    numChannels = chans;
    numSamplesPerOutputFrame = inputBufSize;
    sampleRate = rate;
    dataType = dType;

	numRepeats = 0;
	currentRepeat = 0;
	theRestartMode = IMMEDIATE_RESTART;

	lastSampleOutputFlag = false;
	firstSampleOutputFlag = false;

    numFromWaveFileBlocks++;
}

void FromWaveFileBlock::Init(const char* inputFilename)
{
	if(dataType != 0 && dataType != 1 && (bitsPerSample == 24 || bitsPerSample == 32))
		throw new FromWaveFileException(ERR_24_32_FLTPOINT_ONLY);

	if((dataType == 3 || dataType == 4) && (bitsPerSample != 8 && bitsPerSample != 16))
		throw new FromWaveFileException(ERR_UINT8_INT16_NATIVE_ONLY);

    int filenameLength = strlen(inputFilename);
    if (filenameLength > _MAX_PATH)
		throw new FromWaveFileException(ERR_FILENAME_TOO_LONG);

    if (strchr (inputFilename, '+') != NULL)
		throw new FromWaveFileException(ERR_ILLEGAL_CHAR_IN_FNAME);
	
    filename = new char[filenameLength + 1];
    strcpy(filename, inputFilename);

    dataChunkInfo = new MMCKINFO;
    waveChunkInfo = new MMCKINFO;

	fileHandle = mmioOpen(filename, NULL, MMIO_READ | MMIO_ALLOCBUF);
    if(fileHandle == NULL)
		throw new FromWaveFileException(ERR_ERROR_OPENING_FILE);

	ReadWavHeader();

	MMRESULT  mmResult = mmioSetBuffer(fileHandle, NULL, numBytesToReadFromFile, 0);
	if(mmResult)
		throw new FromWaveFileException(ERR_ERROR_OPENING_FILE);

	ConstructDataCache();
	SetConvertSamplesFcn();
}


void FromWaveFileBlock::SetConvertSamplesFcn()
{
	if( dataType != 0 && 
		dataType != 1 &&
		dataType != 3 &&
		dataType != 4)
		throw new FromWaveFileException(ERR_UNSUPPORTED_DTYPE);

	if(dataType < 2)	// double or single
		convertSamplesFcn = ConvertSamplesFcnTable[(4 * dataType) + bytesPerSample - 1];
	else				// uint8 or int16
		convertSamplesFcn = ConvertSamplesFcnTable[8 + 2 * (dataType - 3) + bytesPerSample - 1];
}


void FromWaveFileBlock::ReadWavHeader()
{
	MMRESULT mmResult = 0;
	MMCKINFO mmFMTCkInfo;
    long m;
    static char msg[256];

    /* Find 'WAVE' chunk */
    waveChunkInfo->fccType = mmioFOURCC('W', 'A', 'V', 'E'); 
    mmResult = mmioDescend(fileHandle, waveChunkInfo, NULL, MMIO_FINDRIFF);
    if (mmResult)
		throw new FromWaveFileException(ERR_READING_HEADER);

    inWaveChunk = true;

    /* Find 'fmt ' chunk */
    mmFMTCkInfo.ckid = mmioFOURCC('f', 'm', 't', ' '); 
    mmResult = mmioDescend(fileHandle, &mmFMTCkInfo, waveChunkInfo, MMIO_FINDCHUNK);
    if (mmResult)
		throw new FromWaveFileException(ERR_READING_HEADER);
    
    /* Read 'fmt ' chunk */
	waveFormat = new WAVEFORMATEXTENSIBLE;
    m = mmioRead(fileHandle, (char *) waveFormat, sizeof(WAVEFORMATEXTENSIBLE));
    if (m != sizeof(WAVEFORMATEXTENSIBLE))
		throw new FromWaveFileException(ERR_READING_HEADER);

    /* Ascend from format chunk */
    mmResult = mmioAscend(fileHandle, &mmFMTCkInfo, 0); 
    if (mmResult)
		throw new FromWaveFileException(ERR_READING_HEADER);

    /* Check for PCM format */
    if (waveFormat->Format.wFormatTag != WAVE_FORMAT_PCM &&
		waveFormat->Format.wFormatTag != WAVE_FORMAT_IEEE_FLOAT)
		throw new FromWaveFileException(ERR_NOT_PCM_NOR_IEEE_FLOAT);

    /* Read PCM format parameters */
    //bitsPerSample = waveFormat->Format.wBitsPerSample;
	bitsPerSample = waveFormat->Format.nBlockAlign / waveFormat->Format.nChannels * 8;
	bytesPerSample = bitsPerSample / 8;
	blockAlign = bytesPerSample * numChannels;
	numBytesToReadFromFile = max((minSamplesToRead * numChannels), numSamplesPerOutputFrame) * blockAlign;

    /* Verify numChannels and sampleRate arguments */
    if (waveFormat->Format.nChannels != numChannels)
		throw new FromWaveFileException(ERR_WRONG_NUM_CHANNELS);

    if (waveFormat->Format.nSamplesPerSec != sampleRate)
		throw new FromWaveFileException(ERR_WRONG_SAMPLE_RATE);

	if(waveFormat->Format.wFormatTag == WAVE_FORMAT_PCM && 
		waveFormat->Format.wBitsPerSample != bitsPerSample)
		throw new FromWaveFileException(ERR_WRONG_NUM_BITS);

    /* Find 'data' chunk */
    dataChunkInfo->ckid = mmioFOURCC('d', 'a', 't', 'a'); 
    mmResult = mmioDescend(fileHandle, dataChunkInfo, waveChunkInfo, MMIO_FINDCHUNK);
    if (mmResult)
		throw new FromWaveFileException(ERR_READING_HEADER);

    inDataChunk = true;
    numBytesInFile = dataChunkInfo->cksize;
	bytesLeftToReadInFile = numBytesInFile;
}


void FromWaveFileBlock::ConstructDataCache()
{
    dataCache = new DataCache; 

    dataCache->data = NULL;
    dataCache->SizeInSamples = max(minSamplesToRead, numSamplesPerOutputFrame) * numChannels;
    dataCache->SizeInBytes = dataCache->SizeInSamples * blockAlign;

    dataCache->data = new unsigned char[dataCache->SizeInBytes];
    
    dataCache->SampleCount = 0;
    dataCache->ByteCount = 0;
	dataCache->firstSampleIdx = 0;
	dataCache->lastSampleIdx = 0;
}


FromWaveFileBlock* FromWaveFileBlock::New(const char* filename, unsigned short bits, 
			int minSampsToRead, int chans, int inputBufSize, double rate, int dType)
{
	FromWaveFileBlock* block = new FromWaveFileBlock(bits, minSampsToRead, chans,
										inputBufSize, rate, dType);
	block->Init(filename);
	
	return block;
}


FromWaveFileBlock::~FromWaveFileBlock()
{
    if(dataCache != NULL)
    {
		if(dataCache->data != NULL)
		{
			delete dataCache->data;  dataCache->data = NULL;
		}
		delete dataCache;  dataCache = NULL;
    }

    if(waveFormat != NULL)
    {
		delete waveFormat;  waveFormat = NULL;
    }

    if(waveChunkInfo != NULL)
    {
		delete waveChunkInfo;  waveChunkInfo = NULL;
    }

    if(dataChunkInfo != NULL)
    {
		delete dataChunkInfo;  dataChunkInfo = NULL;
    }

    if(filename != NULL)
    {
		delete filename;    filename = NULL;
    }

    numFromWaveFileBlocks--;
}


void FromWaveFileBlock::ReadSamplesFromFile()
{
	unsigned char* sampleBuf = dataCache->data + (dataCache->SampleCount * blockAlign);
	int nBytesReadFromFile = 0;
	int bytesInCacheAvailAfterFullRead = dataCache->SizeInBytes - (dataCache->SampleCount * blockAlign + numBytesToReadFromFile);
	int bytesToRead = numBytesToReadFromFile + bytesInCacheAvailAfterFullRead;
    
	if (bytesLeftToReadInFile > 0) 
	{
        /* Read integer samples from file */

		if(bytesLeftToReadInFile == numBytesInFile)
		{
			firstSampleOutputFlag = true;
			dataCache->firstSampleIdx = dataCache->SampleCount;
		}

        nBytesReadFromFile = mmioRead(fileHandle, (char*)sampleBuf, min(bytesLeftToReadInFile, bytesToRead));
        if (nBytesReadFromFile == -1)
			throw new FromWaveFileException(ERR_READING_FILE);

        /* update counts */
        bytesLeftToReadInFile -= nBytesReadFromFile;
		dataCache->SampleCount += (nBytesReadFromFile / blockAlign);
	}

	if (nBytesReadFromFile < bytesToRead || bytesLeftToReadInFile == 0)	// we've reached the end of the file
	{
		if(nBytesReadFromFile > 0)	// if no bytes were read this time the file has been done already
		{
			lastSampleOutputFlag = true;
			dataCache->lastSampleIdx = dataCache->SampleCount - 1;
		}

		// If we need to repeat, start the file over again, otherwise fill with 0's
		if(numRepeats == -1 || currentRepeat < numRepeats)
		{
			currentRepeat++;

			if(theRestartMode == IMMEDIATE_RESTART)
			{
				// go back to the beginning of the data chunk
				if(mmioSeek(fileHandle, (-1 * numBytesInFile), SEEK_CUR) == -1)
					throw new FromWaveFileException(ERR_SEEKING_BEG_DATA);

				bytesLeftToReadInFile = numBytesInFile;

				ReadSamplesFromFile();	// re-enter!
			}
			else	// theRestartMode == FULL_FRAME_RESTART
			{
				//just fill with zeros to an integral frame
				bool restartingThisTime = true;	// may not restart this time...
				int numZerosToAdd = dataCache->SampleCount < numSamplesPerOutputFrame ? 
					(numSamplesPerOutputFrame - dataCache->SampleCount) : 
					(numSamplesPerOutputFrame - (dataCache->SampleCount % numSamplesPerOutputFrame));
				
				if(numZerosToAdd > (dataCache->SizeInSamples - dataCache->SampleCount))
				{
					// if there isn't enough space in the cache to put in zeros until the
					// beginning of the next output frame, we must only fill in zeros until
					// the end of the cache and NOT restart the file yet
					numZerosToAdd = dataCache->SizeInSamples - dataCache->SampleCount;
					restartingThisTime = false;
					currentRepeat--;
				}
				int numBytesOfZerosToAdd = numZerosToAdd * blockAlign;
				unsigned char zero = (bitsPerSample == 8) ? 128 : 0;
				int offset = (dataCache->SampleCount * blockAlign);
				
				memset(dataCache->data + offset, zero, numBytesOfZerosToAdd);
				dataCache->SampleCount = dataCache->SampleCount + numZerosToAdd;

				if(restartingThisTime)
				{
					// go back to the beginning of the data chunk, so the next time it's
					// at the beginning
					if(mmioSeek(fileHandle, (-1 * numBytesInFile), SEEK_CUR) == -1)
						throw new FromWaveFileException(ERR_SEEKING_BEG_DATA);

					bytesLeftToReadInFile = numBytesInFile;
				}
			}
		}
		else
		{
			// we're not looping/repeating, so fill in with zeros
			unsigned char zero = (bitsPerSample == 8) ? 128 : 0;
			int offset = (dataCache->SampleCount * blockAlign);
			memset(dataCache->data + offset, zero, dataCache->SizeInBytes - offset);
			dataCache->SampleCount = dataCache->SizeInSamples;
		}
    }
}


void FromWaveFileBlock::ShuffleSamplesInDataCache()
{
	if(dataCache->SampleCount == 0)
		return;

	unsigned char* sampleBufBeginning = dataCache->data;
	unsigned char* beginningOfNewSamples = dataCache->data + (numSamplesPerOutputFrame * blockAlign);
	int numBytesToCopy = (dataCache->SampleCount - numSamplesPerOutputFrame) * blockAlign;

    memcpy(sampleBufBeginning, beginningOfNewSamples, numBytesToCopy);

	//update things in the dataCache structure
	dataCache->SampleCount -= numSamplesPerOutputFrame;
}

void FromWaveFileBlock::Outputs(const void* signal)
{	
	//get more samples from the file if we don't have enough to output
	if(dataCache->SampleCount < numSamplesPerOutputFrame)
		ReadSamplesFromFile();

	convertSamplesFcn(signal, dataCache->data, numChannels, numSamplesPerOutputFrame);

	ShuffleSamplesInDataCache();

	if(firstSampleOutputFlag)
	{
		dataCache->firstSampleIdx -= numSamplesPerOutputFrame;
	}

	if(lastSampleOutputFlag)
	{
		dataCache->lastSampleIdx -= numSamplesPerOutputFrame;
	}
}


void FromWaveFileBlock::Terminate()
{
    if (dataCache != NULL) 
	{
        MMRESULT mmResult;
        
        /* Exit data chunk */
        if (inDataChunk && (dataChunkInfo != NULL) && (fileHandle != NULL)) {
            mmResult = mmioAscend(fileHandle, dataChunkInfo, 0);
			if(mmResult)
				throw new FromWaveFileException(ERR_EXITING_DATA_CK);
            inDataChunk = false;
        }
        
        /* Exit WAVE chunk */
        if (inWaveChunk && (waveChunkInfo != NULL) && (fileHandle != NULL)) {
            mmResult = mmioAscend(fileHandle, waveChunkInfo, 0);
            if (mmResult)
				throw new FromWaveFileException(ERR_EXITING_WAVE_CK);
            inWaveChunk = false;
        }
    }

	CloseWavFile();
}

void FromWaveFileBlock::CloseWavFile()
{
    if (fileHandle != NULL)
        mmioClose(fileHandle, 0);

    fileHandle = NULL;
    inDataChunk = false;
    inWaveChunk = false;
}

void FromWaveFileBlock::SetErrorCode(int code)
{
    lastErrorCode = code;
}

int FromWaveFileBlock::GetErrorCode()
{
    return lastErrorCode;
}

const char* FromWaveFileBlock::GetErrorMessage()
{
	if(GetErrorCode() >= ERR_NUMBER_OF_ERRORS)
		SetErrorCode(ERR_NUMBER_OF_ERRORS);

    const char* msg = errorMessageTable[lastErrorCode];
    SetErrorCode(ERR_NO_ERROR);
    return msg;
}

void FromWaveFileBlock::SetNumRepeats(long rpts)
{
	if(rpts < 0)
		numRepeats = -1;
	else
		numRepeats = rpts;
}

void FromWaveFileBlock::SetRestartMode(RestartMode restart)
{
	if(restart != IMMEDIATE_RESTART && restart != FULL_FRAME_RESTART)
	{
		throw new FromWaveFileException(ERR_INVALID_RESTART_MODE);
	}
	else
	{
		theRestartMode = restart;
	}
}


bool FromWaveFileBlock::LastOutputsHadFirstSample()
{
	if(firstSampleOutputFlag && dataCache->firstSampleIdx < 0)
	{
		firstSampleOutputFlag = false;
		return true;
	}
	else
		return false;
}


bool FromWaveFileBlock::LastOutputsHadLastSample()
{
	if(lastSampleOutputFlag && dataCache->lastSampleIdx < 0)
	{
		lastSampleOutputFlag = false;
		return true;
	}
	else
		return false;
}