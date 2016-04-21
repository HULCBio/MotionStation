/* $Revision: 1.2 $ */
#ifndef TOWAVEFILEBLOCK_H
#define TOWAVEFILEBLOCK_H


#include <windows.h>
#include <mmreg.h>
#include <mmsystem.h>

/*
 * Error codes
 */

#define ERR_NO_ERROR				0
#define ERR_FILENAME_TOO_LONG	    1
#define ERR_ILLEGAL_CHAR_IN_FNAME   2

#define	ERR_ERROR_OPENING_FILE	    3

#define ERR_WRITING_WAV_HEADER	    4

#define ERR_FAILED_TO_WRITE_DCACHE  5
#define ERR_FAILED_TO_WRITE_DBUF    6

#define ERR_WRITING_SAMPS_TO_FILE   7
#define ERR_CLOSING_FILE			8

#define ERR_UNSUPPORTED_DTYPE		9
#define ERR_24_32_BIT_FLT_PT_ONLY	10

#define ERR_NUMBER_OF_ERRORS		11

/*
 * Types
 */


typedef void (*READ_SAMPLES_FUNC) (const void*, unsigned char*, unsigned short, unsigned long);

typedef struct 
{
    unsigned char   *data;           /* Pointer to allocated memory       */
    unsigned long   SizeInSamples;  /* Size of the cache, in samples  */
    unsigned long   SizeInBytes;    /* Size of the cache, in bytes	*/
    unsigned long   SampleCount;    /* Number of samples cached         */
    unsigned long   ByteCount;      /* Total number of bytes in cache    */

} DataCache;


// ToWaveFileBlock class

class ToWaveFileBlock
{
private:
    unsigned short  bitsPerSample;
    unsigned short  bytesPerSample;
    unsigned short  numChannels;
    unsigned long   numSamplesPerInputFrame;
    double	    sampleRate;
    int		    minSamplesToWrite;
    int		    dataType;

    bool	    inWaveChunk;
    bool	    inDataChunk;

    char*	    filename;
    HMMIO	    fileHandle;

    MMCKINFO*	    dataChunkInfo;
    MMCKINFO*	    waveChunkInfo;

    WAVEFORMATEXTENSIBLE*  waveFormat;

    DataCache*		dataCache;

    READ_SAMPLES_FUNC	readSamplesFcn;

    static int	    numToWaveFileBlocks;
	static int		lastErrorCode;

private:
    ToWaveFileBlock(unsigned short bitsPerSample, int minSampsToWrite, int numChannels, 
		    int inputBufSize, double rate, int dataType);
    void Init(const char* outputFilename);

    void makeStuffNull();
    void MakeBuffer();
    void CloseWavFile();
    void WriteWavHeader();
    void ConstructDataCache();

    void SetReadSamplesFcn();
    void WriteSamplesToFile();

public:
	static ToWaveFileBlock* New(const char* outputFilename, unsigned short bitsPerSample, 
			int minSampsToWrite, int numChannels, int inputBufSize, double rate, int dataType);

    ~ToWaveFileBlock();
    
    void Outputs(const void* signal);
    void Terminate();

    static int NumberOfInstances() {    return numToWaveFileBlocks; }
	
	static void SetErrorCode(int code);
	static int GetErrorCode();
	static const char* GetErrorMessage();

};

#endif //TOWAVEFILEBLOCK_H