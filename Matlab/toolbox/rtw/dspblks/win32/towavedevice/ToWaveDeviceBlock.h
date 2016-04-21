/* $Revision: 1.3 $ */
#ifndef TOWAVEDEVICEBLOCK_H
#define TOWAVEDEVICEBLOCK_H


#include <windows.h>
#include <mmreg.h>
#include <mmsystem.h>

/*
 * Error codes
 */

#define ERR_NO_ERROR		    0
#define ERR_UNSPPTD_DTYPE		1
#define	ERR_UNPPTD_FMT			2
#define	ERR_NO_MEMORY			3
#define	ERR_NO_AUDIO			4
#define ERR_CANNOT_OPEN_DEV		5
#define ERR_NUMBER_OF_ERRORS	6


// Macros

#define MIN_NUM_BUFFERS			3
#define	MAX_NUM_BUFFERS			1024
#define	MAX_BUFFERS_IN_DEVICE	63

// Types

typedef void (*GET_INPUT_BUFFER_FUNC) (char*, const void*, const int, const int);

// Function Prototypes

DWORD WINAPI playThread(LPVOID param);

// ToWaveDeviceBlock class

class ToWaveDeviceBlock
{
private:
	double			bufferSizeInSeconds;
	double			initialDelayInSeconds;
	bool			useWaveMapper;
	UINT			deviceID;
	
	static int		numToWaveDeviceBlocks;
	static int		lastErrorCode;

    unsigned short  bitsPerSample;
    unsigned short  bytesPerSample;
    unsigned short  numChannels;
    unsigned long   numSamplesPerInputFrame;
    double			sampleRate;
    int				dataType;

	WAVEFORMATEXTENSIBLE	waveFormat;
	HWAVEOUT				hWaveOut;

	HANDLE			initialWaitTimerHandle;
	DWORD			initialWaitTimerID;

	HANDLE			outputMessageThreadHandle;
	DWORD			outputMessageThreadID;

	LPWAVEHDR		buffers;
	unsigned int	bufSizeInBytes;
	int				numBuffers;
	LONG			numBuffersInDevice;
	
	LPWAVEHDR		newestEmpty;	// the one the device just gave back
	LPWAVEHDR		oldestEmpty;	// next one to fill with new data from SL
	LONG			numEmpty;		// number of empty buffers

	LPWAVEHDR		newestFilled;	// most recently filled with data by SL
	LPWAVEHDR		oldestFilled;	// next one to give to device
	LONG			numFilled;		//number of filled buffers

	//bool			currentlyModifyingAnOutputQueue;
	HANDLE			hMutex;

	GET_INPUT_BUFFER_FUNC	getInputBufferFcn;

	bool			terminateHasBeenCalled;
	bool			dataHasBeenReceived;

private:
	ToWaveDeviceBlock(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, double initialDelay, unsigned int whichDevice, 
						bool useTheWaveMapper);
	void			Init();

	bool			startPlaying();
	void			closeDevice();

	void			sendAllFilledBuffersToDevice();

	void			addToFilledQueue(LPWAVEHDR hdr);
	LPWAVEHDR		popFromFilledQueue();

	void			addToEmptyQueue(LPWAVEHDR hdr);
	LPWAVEHDR		popFromEmptyQueue();

	void			getMutex();
	void			freeMutex();

	bool			isDonePlaying();

public:
	
	static ToWaveDeviceBlock* New(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, double initialDelay, unsigned int whichDevice, 
						bool useTheWaveMapper = true);
    ~ToWaveDeviceBlock();
    
	void Start();
    void Update(const void* signal);
    void Terminate();

	void BufferDone(LPWAVEHDR done);
	void StopPlaying() {	closeDevice();	}

    static int NumberOfInstances() {    return numToWaveDeviceBlocks; }

	static void SetErrorCode(int code);
	static int GetErrorCode();
	static const char* GetErrorMessage();

	friend DWORD WINAPI initialWaitTimer(LPVOID param);

};

#endif //TOWAVEDEVICEBLOCK_H