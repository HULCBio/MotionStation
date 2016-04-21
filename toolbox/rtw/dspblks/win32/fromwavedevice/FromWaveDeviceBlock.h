/* $Revision: 1.3 $ */
#ifndef FROMWAVEDEVICEBLOCK_H
#define FROMWAVEDEVICEBLOCK_H


#include <windows.h>
#include <mmreg.h>
#include <mmsystem.h>

/*
 * Error codes
 */

#define ERR_NO_ERROR		    0
#define ERR_NO_AUDIO			1
#define ERR_UNPPTD_FMT			2
#define ERR_NO_MEMORY			3
#define ERR_CANNOT_OPEN_DEV		4
#define ERR_CANNOT_START_DEV	5
#define ERR_UNSUPPORTED_DTYPE	6
#define ERR_NUMBER_OF_ERRORS	7

// Macros

#define MIN_NUM_BUFFERS			3
#define	MAX_NUM_BUFFERS			1024
#define	MAX_BUFFERS_IN_DEVICE	64

// Types

typedef void (*OUTPUT_SAMPLES_FUNC) (char*, const void*, const int, const int);


// FromWaveDeviceBlock class

class FromWaveDeviceBlock
{
private:
	double			bufferSizeInSeconds;
	bool			useWaveMapper;
	UINT			deviceID;
	
	static int		numFromWaveDeviceBlocks;
	static int		lastErrorCode;

    unsigned short  bitsPerSample;
    unsigned short  bytesPerSample;
    unsigned short  numChannels;
    unsigned long   numSamplesPerInputFrame;
    double			sampleRate;
    int				dataType;

	WAVEFORMATEXTENSIBLE	waveFormat;
	HWAVEIN			hWaveIn;

	LPWAVEHDR		newestEmpty;	// the one we just finished sending to the next block
	LPWAVEHDR		oldestEmpty;	// next one to send to the audio input device
	LONG			numEmpty;		// number of empty buffers

	LPWAVEHDR		newestFilled;	// most recently received from the audio device
	LPWAVEHDR		oldestFilled;	// next one to pass on to the next block
	LONG			numFilled;		// number of filled buffers

	LPWAVEHDR		buffers;
	unsigned int	bufSizeInBytes;
	int				numBuffers;
	LONG			numBuffersInDevice;

	HANDLE			inputMessageThreadHandle;
	DWORD			inputMessageThreadID;

	//bool			currentlyModifyingAnInputQueue;
	HANDLE			hMutex;

	OUTPUT_SAMPLES_FUNC		outputSamplesFcn;

	bool			terminateHasBeenCalled;
	bool			blockHasOutputData;

private:
	FromWaveDeviceBlock(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, unsigned int whichDevice, 
						bool useTheWaveMapper);
	void			Init();

	bool			startRecording();
	void			closeDevice();

	void			sendAllEmptyBuffersToDevice();

	void			addToFilledQueue(LPWAVEHDR hdr);
	LPWAVEHDR		popFromFilledQueue();

	void			addToEmptyQueue(LPWAVEHDR hdr);
	LPWAVEHDR		popFromEmptyQueue();

	void			getMutex();
	void			freeMutex();

public:
	
	static FromWaveDeviceBlock* New(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, unsigned int whichDevice, 
						bool useTheWaveMapper = true);
    ~FromWaveDeviceBlock();
    
	void Start();
    void Outputs(const void* signal);
    void Terminate();

	void BufferDone(LPWAVEHDR done);

    static int NumberOfInstances() {    return numFromWaveDeviceBlocks; }

	static void SetErrorCode(int code);
	static int GetErrorCode();
	static const char* GetErrorMessage();

};

#endif //FROMWAVEDEVICEBLOCK_H