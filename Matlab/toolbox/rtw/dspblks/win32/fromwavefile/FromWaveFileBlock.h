/* $Revision: 1.3 $ */
#ifndef FROMWAVEFILEBLOCK_H
#define FROMWAVEFILEBLOCK_H


#include <windows.h>
#include <mmreg.h>
#include <mmsystem.h>

/*
 * Error codes
 */

#define ERR_NO_ERROR				0
#define ERR_FILENAME_TOO_LONG		1
#define ERR_ILLEGAL_CHAR_IN_FNAME	2
#define ERR_ERROR_OPENING_FILE		3
#define ERR_READING_HEADER			4
#define ERR_NOT_PCM_NOR_IEEE_FLOAT	5
#define ERR_WRONG_NUM_CHANNELS		6
#define ERR_WRONG_SAMPLE_RATE		7
#define ERR_EXITING_DATA_CK			8
#define ERR_EXITING_WAVE_CK			9
#define ERR_READING_FILE			10
#define ERR_WRONG_NUM_BITS			11
#define ERR_UNSUPPORTED_DTYPE		12
#define ERR_24_32_FLTPOINT_ONLY		13
#define ERR_UINT8_INT16_NATIVE_ONLY	14
#define ERR_SEEKING_BEG_DATA		15
#define	ERR_INVALID_RESTART_MODE	16
#define ERR_NUMBER_OF_ERRORS		17

typedef void (*CONVERT_SAMPLES_FUNC) (const void*, unsigned char*, unsigned short, unsigned long);

typedef struct 
{
    unsigned char   *data;          /* Pointer to allocated memory       */
    unsigned long   SizeInSamples;  /* Size of the cache, in samples  */
    unsigned long   SizeInBytes;    /* Size of the cache, in bytes	*/
    unsigned long   SampleCount;    /* Number of samples cached         */
    unsigned long   ByteCount;      /* Total number of bytes in cache    */
	long			lastSampleIdx;	/* index to the last valid sample (once file ends) */
	long			firstSampleIdx;	/* index to the first sample read from the file */

} DataCache;

typedef enum
{
	IMMEDIATE_RESTART = 0,
	FULL_FRAME_RESTART = 1
} RestartMode;


// FromWaveFileBlock class

class FromWaveFileBlock
{
private:
    unsigned short  bitsPerSample;
    unsigned short  bytesPerSample;
	unsigned short  blockAlign;
    unsigned short  numChannels;
    unsigned long   numSamplesPerOutputFrame;
    double			sampleRate;
    int				minSamplesToRead;
	unsigned long	numBytesToReadFromFile;
    int				dataType;

	// number of times to *repeat* file -> numRepeats == 1 plays through file twice
	// numRepeats == 0 -> don't repeat, just play through file once
	// numRepeats == -1 -> repeat forever
	long		numRepeats;
	// which repeat is currently in process
	// first time through the file currentRepeat == 0
	long		currentRepeat;
	RestartMode	theRestartMode;

	bool		lastSampleOutputFlag;
	bool		firstSampleOutputFlag;

    bool	    inWaveChunk;
    bool	    inDataChunk;

    char*	    filename;
    HMMIO	    fileHandle;

    MMCKINFO*	    dataChunkInfo;
    MMCKINFO*	    waveChunkInfo;
	int			numBytesInFile;
	int			bytesLeftToReadInFile;

    WAVEFORMATEXTENSIBLE*  waveFormat;

	DataCache*		dataCache;

	CONVERT_SAMPLES_FUNC	convertSamplesFcn;

    static int	    numFromWaveFileBlocks;
	static int		lastErrorCode;

private:
    FromWaveFileBlock(unsigned short bits, int minSampsToWrite, int chans, 
						int inputBufSize, double rate, int dType);
    void Init(const char* filename);
	void ReadWavHeader();
	void ConstructDataCache();
	void ReadSamplesFromFile();
	void ShuffleSamplesInDataCache();
	void CloseWavFile();
	void SetConvertSamplesFcn();

    void makeStuffNull();

public:
	static FromWaveFileBlock* New(const char* filename, unsigned short bits, 
			int minSampsToWrite, int chans, int inputBufSize, double rate, int dType);

    ~FromWaveFileBlock();
    
    void Outputs(const void* signal);
    void Terminate();

    static int NumberOfInstances() {    return numFromWaveFileBlocks; }
	
	static void SetErrorCode(int code);
	static int GetErrorCode();
	static const char* GetErrorMessage();

	long	GetNumRepeats() {	return	numRepeats;	}
	void	SetNumRepeats(long rpts);

	RestartMode	GetRestartMode()	{	return theRestartMode;	}
	void	SetRestartMode(RestartMode restart);

	bool	LastOutputsHadFirstSample();
	bool	LastOutputsHadLastSample();		
};

#endif //FROMWAVEFILEBLOCK_H