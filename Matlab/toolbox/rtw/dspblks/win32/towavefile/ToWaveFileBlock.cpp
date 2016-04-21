/* $Revision: 1.4 $ */
#include "ToWaveFileBlock.h"
#include "ToWaveFileException.h"

#include <limits.h>
#include <math.h>
#include <ks.h>
#include <ksmedia.h>

int ToWaveFileBlock::numToWaveFileBlocks = 0;
int ToWaveFileBlock::lastErrorCode = ERR_NO_ERROR;

/*
 * Globals
 */

static const char* errorMessageTable[] = 
{
    "No error reported",
    "File name too long",
    "File name must not contain a \"+\" character",
    "Error opening file",
    "Error writing file header",
    "Failed to allocate data cache",
    "Failed to allocate sample buffer",
    "Error writing samples to file",
    "Error closing file",
	"Unsupported data type",
	"Only double- and single-precision signals can be used\nfor 24- or 32-bit file output",
	"Invalid error code"
};


static void ReadSamples_Double_16bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    double *uptr = (double *)signal;

    short *buf = (short *)sampleBuffer;
    short channel;
    int i;
    for (channel=0; channel < numChannels; channel++)
	{
        for (i=0; i < numSamples; i++) 
		{
            double u = floor(*uptr * 32768);  uptr++;
            buf[channel + i * numChannels] = (short)max(-32768, min(32767, u));
        }
    }
}


static void ReadSamples_Double_24bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    const double *u = (double *)signal;
	unsigned char* buffer = (unsigned char*)sampleBuffer;
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

			*buffer++ = (unsigned char)((intSample >> 8 ) & 0x000000FF);
			*buffer++ = (unsigned char)((intSample >> 16) & 0x000000FF);
			*buffer++ = (unsigned char)((intSample >> 24) & 0x000000FF);
        }
    }
}


static void ReadSamples_Double_32bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    double *uptr = (double *)signal;

    float *buf = (float *)sampleBuffer;
    short channel;
    int i;
    for (channel=0; channel < numChannels; channel++)
	{
        for (i=0; i < numSamples; i++) 
		{
            float u = *uptr;  uptr++;
            buf[channel + i * numChannels] = (float)u;
        }
    }
}


static void ReadSamples_Double_8bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    double *uptr = (double *)signal;

    unsigned char *buf = (unsigned char *)sampleBuffer;
    int i;
    short channel;
    for (i=0; i < numSamples; i++) 
    {
		for (channel=0; channel < numChannels; channel++) 
		{
			buf[channel + i * numChannels] = 
				(unsigned char)max(0, min(255,
				floor(uptr[numSamples * channel + i] * 128 + 128)));
		}
    }
}


static void ReadSamples_Single_16bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    float *uptr = (float *)signal;

    short *buf = (short *)sampleBuffer;
    int i;
    short channel;
    for (channel=0; channel < numChannels; channel++) 
    {
        for (i=0; i < numSamples; i++) 
		{
            float u = floor(*uptr * 32768);  uptr++;
            buf[channel + i * numChannels] = (short)max(-32768, min(32767, u));
        }
    }
}



static void ReadSamples_Single_24bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    const float *u = (float *)signal;
	unsigned char* buffer = (unsigned char*)sampleBuffer;
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

			*buffer++ = (unsigned char)((intSample >> 8 ) & 0x000000FF);
			*buffer++ = (unsigned char)((intSample >> 16) & 0x000000FF);
			*buffer++ = (unsigned char)((intSample >> 24) & 0x000000FF);
        }
    }
}




static void ReadSamples_Single_32bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    float *uptr = (float *)signal;

    float *buf = (float *)sampleBuffer;
    short channel;
    int i;
    for (channel=0; channel < numChannels; channel++)
	{
        for (i=0; i < numSamples; i++) 
		{
            float u = *uptr;  uptr++;
            buf[channel + i * numChannels] = u;
        }
    }
}




static void ReadSamples_Single_8bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    float *uptr = (float *)signal;

    unsigned char *buf = (unsigned char *)sampleBuffer;
    int i;
    short channel;
    for (i=0; i < numSamples; i++) 
    {
        for (channel=0; channel < numChannels; channel++)
		{
            buf[channel + i * numChannels] = 
                (unsigned char)max(0, min(255,
                floor(uptr[numSamples * channel + i] * 128 + 128)));
        }
    }
}


static void ReadSamples_Int16_16bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
	short* uptr = (short*)signal;
	short* buf = (short*)sampleBuffer;
	int i;
	short channel;
	for(i=0; i < numSamples; i++)
	{
		for(channel = 0; channel < numChannels; channel++)
			buf[channel + i * numChannels] = uptr[numSamples * channel + i];
	}
}


static void ReadSamples_Int16_8bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
	short* uptr = (short*)signal;
	int i;
	short channel;
	for(i=0; i < numSamples; i++)
	{
		for(channel = 0; channel < numChannels; channel++)
		{
            sampleBuffer[channel + i * numChannels] = 
                (unsigned char)max(0, min(255,
                floor(uptr[numSamples * channel + i] / 255 + 128)));
		}
	}
}


static void ReadSamples_Uint8_16bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
    unsigned char *uptr = (unsigned char *)signal;
    short *buf = (short *)sampleBuffer;
    short channel;
    int i;
    for (channel=0; channel < numChannels; channel++)
	{
        for (i=0; i < numSamples; i++) 
		{
            double u = *uptr - 128;
			u = floor(u * 255);  uptr++;
            buf[channel + i * numChannels] = (short)max(-32768, min(32767, u));
        }
    }
}


static void ReadSamples_Uint8_8bit(const void* signal, unsigned char* sampleBuffer, 
				    unsigned short numChannels, unsigned long numSamples)
{
	unsigned char* uptr = (unsigned char*)signal;
	int i;
	short channel;
	for(i=0; i < numSamples; i++)
	{
		for(channel = 0; channel < numChannels; channel++)
			sampleBuffer[channel + i * numChannels] = uptr[numSamples * channel + i];
	}
}


const READ_SAMPLES_FUNC ReadSamplesFcnTable[] = 
{
    ReadSamples_Double_8bit,
    ReadSamples_Double_16bit,
	ReadSamples_Double_24bit,
	ReadSamples_Double_32bit,

    ReadSamples_Single_8bit,
    ReadSamples_Single_16bit,
	ReadSamples_Single_24bit,
	ReadSamples_Single_32bit,

	ReadSamples_Uint8_8bit,
	ReadSamples_Uint8_16bit,

	ReadSamples_Int16_8bit,
	ReadSamples_Int16_16bit
};

ToWaveFileBlock::ToWaveFileBlock(unsigned short bits, int minSampsToWrite, 
			int chans, int inputBufSize, double rate, int dType)
{
    makeStuffNull();

    bitsPerSample = bits;
    bytesPerSample = bits / 8;
    minSamplesToWrite = minSampsToWrite;
    numChannels = chans;
    numSamplesPerInputFrame = inputBufSize;
    sampleRate = rate;
    dataType = dType;

    numToWaveFileBlocks++;
}

void ToWaveFileBlock::Init(const char* outputFilename)
{
	if(dataType != 0 && dataType != 1 && dataType != 3 && dataType != 4)
		throw new ToWaveFileException(ERR_UNSUPPORTED_DTYPE);

	if(dataType != 0 && dataType != 1 && bitsPerSample > 16)
		throw new ToWaveFileException(ERR_24_32_BIT_FLT_PT_ONLY);

    int filenameLength = strlen(outputFilename);
    if (filenameLength > _MAX_PATH)
		throw new ToWaveFileException(ERR_FILENAME_TOO_LONG);

    if (strchr (outputFilename, '+') != NULL)
		throw new ToWaveFileException(ERR_ILLEGAL_CHAR_IN_FNAME);
	
    filename = new char[filenameLength + 1];
    strcpy(filename, outputFilename);

    dataChunkInfo = new MMCKINFO;
    waveChunkInfo = new MMCKINFO;

    fileHandle = mmioOpen(filename, NULL, MMIO_WRITE | MMIO_CREATE | MMIO_ALLOCBUF);
    if(fileHandle == NULL)
		throw new ToWaveFileException(ERR_ERROR_OPENING_FILE);

    /* Set internal buffer size 
     *
     * Note -- for faster access, supply a custom I/O buffer 
     * and access with mmioAdvance () */

    long bufSize = max((minSamplesToWrite * numChannels) , numChannels);
    MMRESULT mmResult = mmioSetBuffer (fileHandle, NULL, bufSize, 0);

	waveFormat = new WAVEFORMATEXTENSIBLE;
    
	//waveFormat->Format.wFormatTag = WAVE_FORMAT_EXTENSIBLE; 
	if(bitsPerSample <= 24)
		waveFormat->Format.wFormatTag = WAVE_FORMAT_PCM;
	else
		waveFormat->Format.wFormatTag = WAVE_FORMAT_IEEE_FLOAT;
    waveFormat->Format.nChannels = numChannels; 
    waveFormat->Format.nSamplesPerSec = (long)floor(0.5 + sampleRate); 
    waveFormat->Format.nBlockAlign = numChannels * (bitsPerSample / 8);
	waveFormat->Format.nAvgBytesPerSec = waveFormat->Format.nSamplesPerSec * waveFormat->Format.nBlockAlign; 
    waveFormat->Format.wBitsPerSample = bitsPerSample; 
    waveFormat->Format.cbSize = 22;
	if(bitsPerSample != 32)
		waveFormat->Samples.wValidBitsPerSample = bitsPerSample;
	waveFormat->dwChannelMask = SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT;
	if(bitsPerSample <= 24)
		waveFormat->SubFormat = KSDATAFORMAT_SUBTYPE_PCM;
	else
		waveFormat->SubFormat = KSDATAFORMAT_SUBTYPE_IEEE_FLOAT;

    WriteWavHeader();
    ConstructDataCache();
    SetReadSamplesFcn();
}

ToWaveFileBlock* ToWaveFileBlock::New(const char* outputFilename, unsigned short bitsPerSample, 
			int minSampsToWrite, int numChannels, int inputBufSize, double rate, int dataType)
{
	ToWaveFileBlock* block = new ToWaveFileBlock(bitsPerSample, minSampsToWrite, numChannels, 
												inputBufSize, rate, dataType);
	block->Init(outputFilename);
	
	return block;
}

void ToWaveFileBlock::ConstructDataCache()
{
    dataCache = new DataCache; 

    dataCache->data = NULL;
    dataCache->SizeInSamples = max(minSamplesToWrite, numSamplesPerInputFrame) * numChannels;
    dataCache->SizeInBytes = dataCache->SizeInSamples * bytesPerSample * numChannels;

    dataCache->data = new unsigned char[dataCache->SizeInBytes];
    
    dataCache->SampleCount = 0;
    dataCache->ByteCount = 0;
}



ToWaveFileBlock::~ToWaveFileBlock()
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

    numToWaveFileBlocks--;
}

void ToWaveFileBlock::makeStuffNull()
{
    inWaveChunk = false;
    inDataChunk = false;
    
    filename = NULL;
    fileHandle = NULL;

    dataChunkInfo = NULL;
    waveChunkInfo = NULL;

    waveFormat = NULL;

    dataCache = NULL;
}


void ToWaveFileBlock::WriteWavHeader()
{
    MMCKINFO		mmFMTCkInfo;
    long		m;

    const long length     = 0;  /* This will be corrected when ascending from the chunk */
    long       dataLength = length * numChannels * sizeof (short);

    /* Create 'WAVE' chunk */
    waveChunkInfo->fccType = mmioFOURCC('W', 'A', 'V', 'E'); 
    /* 'WAVE' + 'fmt ' + size + 'data' + size = 20 */
    waveChunkInfo->cksize = 20 + sizeof (WAVEFORMATEXTENSIBLE) + dataLength; 
    if(mmioCreateChunk(fileHandle, waveChunkInfo, MMIO_CREATERIFF))
		throw new ToWaveFileException(ERR_WRITING_WAV_HEADER);
    inWaveChunk = true;

    /* Create 'fmt ' chunk */
    mmFMTCkInfo.ckid = mmioFOURCC('f', 'm', 't', ' '); 
    mmFMTCkInfo.cksize = sizeof(WAVEFORMATEXTENSIBLE); 
    if(mmioCreateChunk(fileHandle, &mmFMTCkInfo, 0))
		throw new ToWaveFileException(ERR_WRITING_WAV_HEADER);

    /* Write format chunk */
    m = mmioWrite (fileHandle, (char*) waveFormat, sizeof (WAVEFORMATEXTENSIBLE));
    if (m != sizeof(WAVEFORMATEXTENSIBLE))
		throw new ToWaveFileException(ERR_WRITING_WAV_HEADER);

    /* End format chunk */
    if(mmioAscend (fileHandle, &mmFMTCkInfo, 0))
		throw new ToWaveFileException(ERR_WRITING_WAV_HEADER);

    /* Create 'data' chunk */
    dataChunkInfo->ckid = mmioFOURCC('d', 'a', 't', 'a'); 
    dataChunkInfo->cksize = dataLength; 
    if(mmioCreateChunk(fileHandle, dataChunkInfo, 0))
		throw new ToWaveFileException(ERR_WRITING_WAV_HEADER);

    inDataChunk = true;
}


void ToWaveFileBlock::CloseWavFile()
{
    if (fileHandle != NULL) {
        mmioClose(fileHandle, 0);
    }
    fileHandle = NULL;
    inDataChunk = false;
    inWaveChunk = false;
}

void ToWaveFileBlock::SetReadSamplesFcn()
{
	if(dataType == 0 || dataType == 1)
		readSamplesFcn = ReadSamplesFcnTable[(dataType * 4) + bytesPerSample - 1];
	else
		readSamplesFcn = ReadSamplesFcnTable[8 + 2 * (dataType - 3) + (bytesPerSample - 1)];
}


void ToWaveFileBlock::WriteSamplesToFile()
{
    const int bufsize = dataCache->SampleCount * bytesPerSample;

    if (mmioWrite(fileHandle, (const char*)dataCache->data, bufsize) != bufsize)
		throw new ToWaveFileException(ERR_WRITING_SAMPS_TO_FILE);

    dataCache->SampleCount = 0;
}


void ToWaveFileBlock::Outputs(const void* signal)
{
    int  offset;
    unsigned char* sampleBuffer;
    
    /* Empty buffer to file if not enough space for next set of inputs. */
    if(dataCache->SampleCount + max(numSamplesPerInputFrame, numChannels) > dataCache->SizeInSamples)
		WriteSamplesToFile();
	
    offset       = dataCache->SampleCount * bytesPerSample;
    sampleBuffer = dataCache->data + offset;
    
    dataCache->SampleCount += numChannels * numSamplesPerInputFrame;

    readSamplesFcn(signal, sampleBuffer, numChannels, numSamplesPerInputFrame);
}


void ToWaveFileBlock::Terminate()
{
    if(dataCache != NULL)
    {
        if(dataCache->SampleCount > 0)
			WriteSamplesToFile();
        
        /* End data chunk */
        if (inDataChunk && dataChunkInfo != NULL && fileHandle != NULL) 
		{
            if (mmioAscend (fileHandle, dataChunkInfo, 0))
				throw new ToWaveFileException(ERR_CLOSING_FILE);

            inDataChunk = false;
        }
        
        /* End WAVE chunk */
        if (inWaveChunk && waveChunkInfo != NULL && fileHandle != NULL) 
		{
            if(mmioAscend (fileHandle, waveChunkInfo, 0))
				throw new ToWaveFileException(ERR_CLOSING_FILE);	
		
            inWaveChunk = false;
        }
    }

    CloseWavFile();
}


void ToWaveFileBlock::SetErrorCode(int code)
{
    lastErrorCode = code;
}

int ToWaveFileBlock::GetErrorCode()
{
    return lastErrorCode;
}

const char* ToWaveFileBlock::GetErrorMessage()
{
	if(GetErrorCode() >= ERR_NUMBER_OF_ERRORS)
		SetErrorCode(ERR_NUMBER_OF_ERRORS);

    const char* msg = errorMessageTable[lastErrorCode];
    SetErrorCode(ERR_NO_ERROR);
    return msg;
}
