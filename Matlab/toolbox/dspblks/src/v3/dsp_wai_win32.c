/*
 * DSP_WAI_WIN32: DSP Blockset S-function implementing
 *                wave audio input device.
 *
 * Based on an implementation by:
 *      Steve Mitchell
 *      Department of Electrical Engineering
 *      Cornell University
 *      Ithaca, NY  14853
 * Code adapted and used by permission from
 * the Cornell Laboratory of Ornithology.
 *
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.5 $ $Date: 2002/04/14 20:43:25 $
 */

#include <windows.h>
#include <mmsystem.h>
#include <time.h>

#include "dsp_sim.h"

/*
 * Uses Windows API "wave audio" functions.
 *
 * The width of the output vector is BUFFER_SIZE * NUM_CHANNELS.
 * The sample time is BUFFER_SIZE / SAMPLE_RATE.
 * The output sample values are in the range [-1.0, +1.0].
 *
 * Parameters are:
 *	Number of channels	(1 or 2)
 *	Sample rate		(8000, 11025, 22050, or 44100)
 *	Bits per sample		(8 or 16)
 *	Buffer size		(at least 1)
 *	Number of buffers	(at least 3)
 *
 * FIFO_NODATA: Queue of empty buffers waiting to be passed to the
 *              audio device
 *   FIFO_DATA: Queue of filled buffers returned from audio device,
 *              waiting to be read by Simulink
 *
 * Code must be linked against "winmm.lib".
 */

/*
 * S-Function arguments:
 */
enum {
    NUM_CHANS_ARGC,	  /* 1 = mono, 2 = stereo	*/
    SAMPLE_RATE_ARGC,     /* 8000, 11025, 22050, 44100  */
    BITS_PER_SAMPLE_ARGC, /* 8 or 16		        */
    BUFFER_SIZE_ARGC,     /* eg, 512 samples	        */
    NUM_BUFFERS_ARGC,     /* at least 3		        */
    DEVICE_ID_ARGC,       /* Audio device ID (1,2,...)  */
    NUM_ARGS
};

#define NUM_CHANS_ARG(S)       ssGetSFcnParam(S, NUM_CHANS_ARGC      )
#define SAMPLE_RATE_ARG(S)     ssGetSFcnParam(S, SAMPLE_RATE_ARGC    )
#define BITS_PER_SAMPLE_ARG(S) ssGetSFcnParam(S, BITS_PER_SAMPLE_ARGC)
#define BUFFER_SIZE_ARG(S)     ssGetSFcnParam(S, BUFFER_SIZE_ARGC    )
#define NUM_BUFFERS_ARG(S)     ssGetSFcnParam(S, NUM_BUFFERS_ARGC    )
#define DEVICE_ID_ARG(S)       ssGetSFcnParam(S, DEVICE_ID_ARGC      )

#define NUM_CHANS(S)	    ((unsigned short)*mxGetPr(NUM_CHANS_ARG(S)      ))
#define SAMPLE_RATE(S)	    ((double)        *mxGetPr(SAMPLE_RATE_ARG(S)    ))
#define BITS_PER_SAMPLE(S)  ((unsigned short)*mxGetPr(BITS_PER_SAMPLE_ARG(S)))
#define BUFFER_SIZE(S)      ((long)          *mxGetPr(BUFFER_SIZE_ARG(S)    ))
#define NUM_USER_BUFFERS(S) ((long)          *mxGetPr(NUM_BUFFERS_ARG(S)    ))
#define DEVICE_ID(S)        ((UINT)          *mxGetPr(DEVICE_ID_ARG(S)      ))

enum {
    kWAVE_IN_DEVICE,	 /* Win32 API audio device handle	 */
    kFIRST_WAVEHDR,	 /* First of NUM_BUFFERS WAVEHDR buffers */
    kFIFO_DATA_NEWEST,	 /* First element of FIFO_DATA		 */
    kFIFO_DATA_OLDEST,	 /* Last element of FIFO_DATA		 */
    kFIFO_NODATA_NEWEST, /* First element of FIFO_NODATA	 */
    kFIFO_NODATA_OLDEST, /* Last element of FIFO_NODATA		 */
    kMUTEX_OBJECTS,      /* Pointer to array of mutex objects    */
    NUM_PWORK
};

enum {
    kNUM_BUFFERS_IN_DEVICE, /* Number of buffers sent to wave device */
    kNUM_BUFFERS,	    /* at least 3			     */
    kIS_WINNT,              /* Flag indicating if this is WinNT      */
    NUM_IWORK
};

/* Minimum and maximum number of buffers to use in FIFOs: */
#define MIN_FIFO_BUFFERS 3
#define MAX_FIFO_BUFFERS 1024

/* Maximum number of buffers to prepare (lock)
 * NOTE: This is usually much smaller than MAX_FIFO_BUFFERS
 */
#define MAX_DEVICE_BUFFERS 64

#define WAVE_IN_DEVICE(S) ((HWAVEIN) (ssGetPWorkValue(S, kWAVE_IN_DEVICE)))
#define FIRST_WAVEHDR(S)  ((LPWAVEHDR)(ssGetPWorkValue(S, kFIRST_WAVEHDR)))
#define IS_RUNNING_NT(S)  (ssGetIWorkValue(S, kIS_WINNT) != 0)

#define NUM_BUFFERS(S)	         (ssGetIWorkValue(S, kNUM_BUFFERS))
#define NUM_BUFFERS_IN_DEVICE(S) (ssGetIWorkValue(S, kNUM_BUFFERS_IN_DEVICE))
#define RETURN_IF_ERROR(S)       if(ssGetErrorStatus(S) != NULL) return;

enum {FIFO_DATA, FIFO_NODATA};
#define kFIFO_NEWEST(fifoSel)    ( (fifoSel==FIFO_DATA) ? kFIFO_DATA_NEWEST : kFIFO_NODATA_NEWEST )
#define kFIFO_OLDEST(fifoSel)    ( (fifoSel==FIFO_DATA) ? kFIFO_DATA_OLDEST : kFIFO_NODATA_OLDEST )
#define FIFO_NEWEST(S, fifoSel)  ((LPWAVEHDR)(ssGetPWorkValue(S, kFIFO_NEWEST(fifoSel))))
#define FIFO_OLDEST(S, fifoSel)  ((LPWAVEHDR)(ssGetPWorkValue(S, kFIFO_OLDEST(fifoSel))))

enum {kMUTEX_FIFO_DATA, kMUTEX_FIFO_NODATA};
#define MUTEX_OBJECTS(S)       ((CRITICAL_SECTION *)ssGetPWorkValue(S, kMUTEX_OBJECTS))
#define kFIFO_MUTEX(fifoSel)   ((fifoSel==FIFO_DATA) ? kMUTEX_FIFO_DATA : kMUTEX_FIFO_NODATA)
#define FIFO_MUTEX(S, fifoSel) (MUTEX_OBJECTS(S) + kFIFO_MUTEX(fifoSel))

#define EnterFIFOMutex(S, fifoSel) EnterCriticalSection(FIFO_MUTEX(S, fifoSel));
#define LeaveFIFOMutex(S, fifoSel) LeaveCriticalSection(FIFO_MUTEX(S, fifoSel))


/* Function: setNumberOfBuffers ==============================================
 * Abstract:
 *
 *  Compute and store the number of buffers to maintain in FIFOs
 */
static void setNumberOfBuffers(SimStruct *S)
{
    /* Convert buffer duration to an integer number of buffers: */
    int_T numBuffs = NUM_USER_BUFFERS(S);

    if      (numBuffs < MIN_FIFO_BUFFERS) numBuffs = MIN_FIFO_BUFFERS;
    else if (numBuffs > MAX_FIFO_BUFFERS) numBuffs = MAX_FIFO_BUFFERS;

    ssSetIWorkValue(S, kNUM_BUFFERS, numBuffs);
}


/* Function: CreateAndInitializeMutexes ==================================
 * Abstract:
 *
 *  Use mutex objects to control access to shared resources
 *  Each of 2 FIFO stacks is shared across 2 threads
 *  Allocate & initialize critical section objects, one for each
 *    resource shared across threads:
 *
 * Can fail.
 */
static void CreateAndInitializeMutexes(SimStruct *S)
{
    CRITICAL_SECTION *cs = (CRITICAL_SECTION *)calloc(2, sizeof(CRITICAL_SECTION));

    ssSetPWorkValue(S, kMUTEX_OBJECTS, cs);
    if (cs == NULL) THROW_ERROR(S, "Failed to allocate memory.");

    InitializeCriticalSection(FIFO_MUTEX(S, FIFO_DATA));
    InitializeCriticalSection(FIFO_MUTEX(S, FIFO_NODATA));
}


/* Function: DeleteAndFreeMutexes ========================================
 * Abstract:
 *
 * Delete critical section objects and free allocations.
 *
 */
static void DeleteAndFreeMutexes(SimStruct *S)
{
    CRITICAL_SECTION *cs = (CRITICAL_SECTION *)ssGetPWorkValue(S, kMUTEX_OBJECTS);
    if (cs != NULL) {
        DeleteCriticalSection(FIFO_MUTEX(S, FIFO_DATA));
        DeleteCriticalSection(FIFO_MUTEX(S, FIFO_NODATA));
        free(cs);
    }
}


/* Function: InitFIFO =======================================================
 * Abstract:
 *
 *  Initialize a FIFO
 */
static void InitFIFO(SimStruct *S, const int_T fifoSel)
{
    ssSetPWorkValue(S, kFIFO_NEWEST(fifoSel), NULL);
    ssSetPWorkValue(S, kFIFO_OLDEST(fifoSel), NULL);
}


/* Function: InitFIFOs =======================================================
 * Abstract:
 *
 *  Initialize all FIFOs
 */
static void InitFIFOs(SimStruct *S)
{
    InitFIFO(S, FIFO_DATA);
    InitFIFO(S, FIFO_NODATA);
}


/* Function: FIFOEmpty =======================================================
 * Abstract:
 *
 *  Returns non-zero if the FIFO is empty
 */
static boolean_T FIFOEmpty(SimStruct *S, const int_T fifoSel)
{
    boolean_T isEmpty;
    EnterFIFOMutex(S, fifoSel);

    isEmpty = (boolean_T)(FIFO_OLDEST(S,fifoSel) == NULL);

    LeaveFIFOMutex(S, fifoSel);
    return(isEmpty);
}


/* Function: PushFIFO =======================================================
 * Abstract:
 *
 *  Add a buffer (WaveHeader) to the start of the FIFO
 */
static void PushFIFO(SimStruct *S, const int_T fifoSel, LPWAVEHDR lpwh)
{
    EnterFIFOMutex(S, fifoSel);

    {
        /* The FIFO is implemented as a reverse-linked list
         * New buffers added to tail of queue, oldest buffer is at head
         * dwUser is link to the next buffer closer to the tail
         * Buffer at tail of queue points to NULL.
         */
        const LPWAVEHDR lpwhNewest = FIFO_NEWEST(S,fifoSel);

        /* Incoming buffer will be the newest in fifo */
        lpwh->dwUser = (DWORD)NULL;

        if(lpwhNewest != NULL) {
	    /* Other entries in queue - link old tail buffer to this one */
            lpwhNewest->dwUser = (DWORD)lpwh;

        } else {
	    /* This is the only entry in queue - head points to this buffer */
	    /* assert(FIFO_OLDEST() == NULL); */
            ssSetPWorkValue(S, kFIFO_OLDEST(fifoSel), lpwh);
        }

        ssSetPWorkValue(S, kFIFO_NEWEST(fifoSel), lpwh);
    }

    LeaveFIFOMutex(S, fifoSel);
}


/* Function: PopFIFO =======================================================
 * Abstract:
 *
 *  Pop a buffer from the end of the FIFO
 */
static LPWAVEHDR PopFIFO(SimStruct *S, const int_T fifoSel)
{
    /* The FIFO is implemented as a reverse-linked list */

    LPWAVEHDR lpwhOldest;
    EnterFIFOMutex(S, fifoSel);

    lpwhOldest = FIFO_OLDEST(S,fifoSel);

    if(lpwhOldest != NULL) {
	/* Queue is not empty */

	/* Reset end of queue to "2nd oldest" buffer in list */
	ssSetPWorkValue(S, kFIFO_OLDEST(fifoSel), (LPWAVEHDR)(lpwhOldest->dwUser));

	if(FIFO_NEWEST(S,fifoSel) == lpwhOldest) {
	    /* buffer was the only one in list - so list is now empty: */
	    /* assert(FIFO_END == NULL); */
	    ssSetPWorkValue(S, kFIFO_NEWEST(fifoSel), NULL);
	}
    }

    LeaveFIFOMutex(S, fifoSel);
    return(lpwhOldest);
}


/* Function: CheckError =======================================================
 * Abstract:
 *
 *  If a wave audio API error occurs, set Simulink error status
 *  and return non-zero, else return zero.
 */
static boolean_T CheckError(SimStruct *S, MMRESULT errStatus)
{
    const boolean_T isErr = (errStatus != MMSYSERR_NOERROR);
    static char     msg[MAXERRORLENGTH];

    if (isErr) {
	/* Get error message from device driver */
	MMRESULT local_errStatus = waveInGetErrorText(errStatus, msg, MAXERRORLENGTH);

	if (local_errStatus == MMSYSERR_NOERROR) {
            ssSetErrorStatus(S, msg);
        } else {

            switch (errStatus) {
		case MMSYSERR_ALLOCATED:
		    ssSetErrorStatus(S, "Sound input device busy.");
		    break;
	
		case MMSYSERR_BADDEVICEID:
		    ssSetErrorStatus(S, "Missing sound input device.");
		    break;
	
		case MMSYSERR_INVALHANDLE:
		    ssSetErrorStatus(S, "Invalid device handle.");
		    break;

		case WAVERR_BADFORMAT:
		    ssSetErrorStatus(S, "Sound format unsupported.");
		    break;

		case WAVERR_STILLPLAYING:
		    ssSetErrorStatus(S, "Active buffers prevent operation.");
		    break;

		case WAVERR_UNPREPARED:
		    ssSetErrorStatus(S, "Buffer unprepared.");
		    break;
		case MMSYSERR_NODRIVER:
		    ssSetErrorStatus(S, "No sound input device driver.");
		    break;
	
		case MMSYSERR_NOMEM:
		    ssSetErrorStatus(S, "Error allocating memory.");
		    break;
	
		case MMSYSERR_BADERRNUM:
		    ssSetErrorStatus(S, "Specified error number is out of range.");
		    break;

		default:
		    ssSetErrorStatus(S, "Unknown error.");
		    break;
	    }
	}
    }
    return(isErr);
}


/* Function: checkWaveDevice =================================================
 * Abstract:
 *
 *   Checks if at least one wave audio input device exists.
 *
 * Can fail.
 */
static void checkWaveDevice(SimStruct *S)
{
    UINT numInputDevices = waveInGetNumDevs();
    if (numInputDevices < 1) {
        THROW_ERROR(S, "No audio input devices detected.");
    }
}


/* Function: UnprepareBuffer =================================================
 * Abstract:
 *
 *  Unlock buffer.
 *
 * Using WHDR_DONE as a test that the buffer is no longer being used.
 * Must preset dwFlags to WHDR_DONE in all buffers in order for this
 * to work.
 */
static void UnprepareBuffer(SimStruct *S, LPWAVEHDR lpwh) 
{
    if (!(lpwh->dwFlags & WHDR_DONE) |
         (lpwh->dwFlags & WHDR_INQUEUE)
       ) {
        THROW_ERROR(S, "Attempt to unprepare input buffer that is still in use.");
    }

    CheckError(S, waveInUnprepareHeader(WAVE_IN_DEVICE(S), lpwh, sizeof (WAVEHDR)));
}


/* Function: PrepareBuffer =======================================================
 * Abstract:
 *
 *  Manage the locking and unlocking of FIFO buffers sent to the audio device.
 *
 * Can fail.
 */
static void PrepareBuffer(SimStruct *S, LPWAVEHDR lpwh) 
{
    CheckError(S, waveInPrepareHeader(WAVE_IN_DEVICE(S), lpwh, sizeof (WAVEHDR)));
}


/* Function: MakeWaveFormatEX =======================================================
 * Abstract:
 *
 *		Utility for building wave input format struct.
 */
static void MakeWaveFormatEX(SimStruct *S, LPWAVEFORMATEX lpwfx)
{
    lpwfx->wFormatTag	        = WAVE_FORMAT_PCM;
    lpwfx->nChannels		= NUM_CHANS(S);
    lpwfx->nSamplesPerSec	= (unsigned long)SAMPLE_RATE(S);
    lpwfx->wBitsPerSample	= BITS_PER_SAMPLE(S);
    lpwfx->nBlockAlign		= lpwfx->nChannels * (lpwfx->wBitsPerSample / 8);
    lpwfx->nAvgBytesPerSec	= lpwfx->nSamplesPerSec * lpwfx->nBlockAlign;
    lpwfx->cbSize		= 0;
}


/*
 * Unless you're absolutely positive that this is NT,
 * default to responding "false", i.e., you're Win95/98.
 * An incorrect decision on NT may cause MATLAB to hang.
 * However, an incorrect decision on 95/98 may cause system
 * resource leakage and/or OS failure.
 */
static void checkWindowsOS(SimStruct *S)
{
    boolean_T     is_NT;
    OSVERSIONINFO osvi;

    osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
    is_NT = GetVersionEx(&osvi) && (osvi.dwPlatformId == VER_PLATFORM_WIN32_NT);

    ssSetIWorkValue(S, kIS_WINNT, is_NT);
}


/* Function: waveInProc =======================================================
 * Abstract:
 *
 * Callback function for wave input device
 */
static void CALLBACK waveInProc(
    HWAVEIN	hwi, 
    UINT	uMsg, 
    DWORD	dwInstance, 
    DWORD	dwParam1, 
    DWORD	dwParam2)
{
    if (uMsg == WIM_DATA) {
        SimStruct *S = (SimStruct*)dwInstance;

        /* A buffer has been returned from the device - decrement counter: */
	/* assert(NUM_BUFFERS_IN_DEVICE(S) > 0); */
	InterlockedDecrement(ssGetIWork(S) + kNUM_BUFFERS_IN_DEVICE);

	/* Return used buffer to the FIFO_NODATA queue */
        {
            LPWAVEHDR lpwh = (LPWAVEHDR)dwParam1;
            if (!IS_RUNNING_NT(S)) {
                UnprepareBuffer(S, lpwh);
            }
            PushFIFO(S, FIFO_DATA, lpwh);
        }
    }
}


/* Function: getDeviceID ======================================================
 * Abstract:
 *
 *  Translate user popup selection of WAVE device.
 *  If default device selected, use WAVE_MAPPER
 */
static UINT getDeviceID(SimStruct *S)
{
    /* Get device OD
     *   0: default device selected
     *  >0: specific device ID selected
     */
    UINT uDeviceID = DEVICE_ID(S);
    if (uDeviceID == 0) {
        uDeviceID = WAVE_MAPPER;  /* Should be -1, but safer to do this */
    } else {
        uDeviceID -= 1;  /* Translate 1,2,... to 0,1,... */
    }

    /*
     * No need to check that device exists;
     * the device-open call will do that for u.
     */
    return(uDeviceID);
}


/* Function: CheckFormatSupport =================================================
 * Abstract:
 *
 *  Checks if the device supports the requested format.
 */
static void CheckFormatSupport(SimStruct *S, LPWAVEFORMATEX pwfx, UINT uDeviceID)
{ 
    CheckError(S, waveInOpen( 
        NULL,                 /* ptr can be NULL for query      */
        uDeviceID,            /* the device identifier          */
        pwfx,                 /* defines requested format       */
        0,                    /* no callback                    */
        0,                    /* no instance data               */
        WAVE_FORMAT_QUERY));  /* query only, do not open device */
}


/* Function: OpenDevice =======================================================
 * Abstract:
 *
 *   Opens wave input device, and returns a handle to it
 *
 * Can fail.
 */
static void OpenDevice(SimStruct *S) 
{
    UINT         uDeviceID = getDeviceID(S);
    WAVEFORMATEX wfx;
    HWAVEIN      hwi;

    ssSetPWorkValue(S, kWAVE_IN_DEVICE,        NULL);
    ssSetIWorkValue(S, kNUM_BUFFERS_IN_DEVICE, 0);

    MakeWaveFormatEX(S, &wfx);

    /* Check that device supports requested format: */
    CheckFormatSupport(S, &wfx, uDeviceID); RETURN_IF_ERROR(S);

    /* Attempt to open device: */
    CheckError(S, waveInOpen(&hwi, uDeviceID, &wfx,
        	   (DWORD)waveInProc, (DWORD)S, CALLBACK_FUNCTION));
    RETURN_IF_ERROR(S);

    ssSetPWorkValue(S, kWAVE_IN_DEVICE, hwi);
}


/* Function: ResetDevice =======================================================
 * Abstract:
 *
 *  Resets wave input device
 *
 * Can fail.
 */
static void ResetDevice(SimStruct *S) 
{
    CheckError(S, waveInReset(WAVE_IN_DEVICE(S)));
}


/* Function: StartDevice =======================================================
 * Abstract:
 *
 *  Starts wave input device
 *
 * Can fail.
 */
static void StartDevice(SimStruct *S) 
{
    CheckError(S, waveInStart(WAVE_IN_DEVICE(S)));
}


/* Function: CloseDevice =======================================================
 * Abstract:
 *
 *  Closes wave input device
 *
 * Can fail.
 */
static void CloseDevice(SimStruct *S) 
{
    CheckError(S, waveInClose(WAVE_IN_DEVICE(S)));
}


/* Function: SendBufferToDevice ================================================
 * Abstract:
 *
 *  Add a buffer to the audio input queue
 *
 * Can fail.
 */
static void SendBufferToDevice(SimStruct *S, LPWAVEHDR lpwh) 
{
    /* Only prepare buffers which get sent to the driver: */
    lpwh->dwFlags = 0;  /* Will be WHDR_DONE after buffer is used by device */
    PrepareBuffer(S, lpwh); RETURN_IF_ERROR(S);

    /* Record the addition of the buffer to the device's queue count
     * before adding buffer to queue, so no race condition develops:
     */
    InterlockedIncrement(ssGetIWork(S) + kNUM_BUFFERS_IN_DEVICE);

    if (CheckError(S, waveInAddBuffer(WAVE_IN_DEVICE(S), lpwh, sizeof(WAVEHDR)))) {
        /* Failed - reduce queue count */
	InterlockedDecrement(ssGetIWork(S) + kNUM_BUFFERS_IN_DEVICE);
    }
}


/* Function: SendMaxEmptyBuffersToDevice ======================================
 * Abstract:
 *
 *  Send as many buffers to the audio input queue as possible.
 *
 * Can fail.
 */
static void SendMaxEmptyBuffersToDevice(SimStruct *S)
{
    while( !FIFOEmpty(S,FIFO_NODATA) &&
           (NUM_BUFFERS_IN_DEVICE(S) < MAX_DEVICE_BUFFERS)
         ) {

        SendBufferToDevice(S, PopFIFO(S,FIFO_NODATA)); RETURN_IF_ERROR(S);
    }
}


/* Function: FreeBuffers =======================================================
 * Abstract:
 *
 *  Free allocated sample buffers
 *
 * Can fail, but will free buffers nonetheless.
 */
static void FreeBuffers(SimStruct *S)
{
    int_T     i;
    LPWAVEHDR nextWaveHdr = FIRST_WAVEHDR(S);
    if(nextWaveHdr == NULL) return;

    /* All WAVEHDR's and sample buffers were allocated in contiguous chunks */
    for(i = NUM_BUFFERS(S); i-- > 0; ) {    /* Necessary if a failure occurred while */
	UnprepareBuffer(S, nextWaveHdr++);  /*   buffers were still in driver queue. */
    }

    if (FIRST_WAVEHDR(S)->lpData != NULL) {
	free(FIRST_WAVEHDR(S)->lpData);
    }
    free(FIRST_WAVEHDR(S));
}


/* Function: CreateBuffers ===================================================
 * Abstract:
 *
 *  Allocate sample buffers.
 *
 * Can fail.
 */
static void CreateBuffers(SimStruct *S)
{
    /* Compute buffer size, in bytes: */
    const int_T bufSiz  = BUFFER_SIZE(S) * NUM_CHANS(S) * (BITS_PER_SAMPLE(S) / 8);
    const int_T numBufs = NUM_BUFFERS(S);
    LPWAVEHDR   lpwh;
    LPSTR       lpData;
    int_T       i;

    /* Allocate and clear WAVEHDR's: */
    lpwh = (LPWAVEHDR)calloc(numBufs, sizeof(WAVEHDR));
    ssSetPWorkValue(S, kFIRST_WAVEHDR, lpwh);    /* Store the first pointer */
    if(lpwh == NULL) goto ERROR_EXIT;

    /* Allocate and clear all sample buffers (one for each WAVEHDR) */
    lpData = (LPSTR)calloc(numBufs, bufSiz);
    if(lpData == NULL) goto ERROR_EXIT;

    /* Initialize WAVEHDR's: */
    for(i=numBufs; i-- > 0; ) {
	lpwh->lpData         = lpData;
	lpwh->dwBufferLength = bufSiz;

        /* Preset flag to WHDR_DONE for error-checking by the PrepareBuffer function. */
        lpwh->dwFlags        = WHDR_DONE;

	lpwh++;	          /* Next WAVEHDR       */
	lpData += bufSiz; /* Next sample buffer */
    }

    return;

ERROR_EXIT:
    FreeBuffers(S);
    CheckError(S, MMSYSERR_NOMEM);
}


/*====================*
 * S-function methods *
 *====================*/


#if defined(MATLAB_MEX_FILE)
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if (!IS_FLINT_IN_RANGE(NUM_CHANS_ARG(S),1,2)) {
        THROW_ERROR(S,"Number of channels must be 1 or 2.");
    }

    if ( !IS_SCALAR_DOUBLE(SAMPLE_RATE_ARG(S)) ||
         (SAMPLE_RATE(S) <= 0.0)) {
        THROW_ERROR(S,"Sample rate must be > 0.");
    }

    if ( !IS_SCALAR_DOUBLE(BITS_PER_SAMPLE_ARG(S)) ||
         (BITS_PER_SAMPLE(S)!=8) && (BITS_PER_SAMPLE(S)!=16)) {
        THROW_ERROR(S,"Number of bits per sample must be 8 or 16.");
    }

    if (!IS_FLINT_GE(BUFFER_SIZE_ARG(S),1)) {
        THROW_ERROR(S,"Buffer size must be a positive integer.");
    }

    if (!IS_FLINT_GE(NUM_BUFFERS_ARG(S),3)) {
        THROW_ERROR(S,"Number of buffers must be an integer >= 3.");
    }

    if (!IS_FLINT_GE(DEVICE_ID_ARG(S),0)) {
        /* As far as the user knows, the device ID must be >=1
         * The "default" device comes in as device #0 and is translated later on.
         */
        THROW_ERROR(S, "Device ID must be an integer >= 1.");
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{	
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if(ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    RETURN_IF_ERROR(S);
#endif

    ssSetSFcnParamNotTunable(S, NUM_CHANS_ARGC);
    ssSetSFcnParamNotTunable(S, SAMPLE_RATE_ARGC);
    ssSetSFcnParamNotTunable(S, BITS_PER_SAMPLE_ARGC);
    ssSetSFcnParamNotTunable(S, BUFFER_SIZE_ARGC);
    ssSetSFcnParamNotTunable(S, NUM_BUFFERS_ARGC);
    ssSetSFcnParamNotTunable(S, DEVICE_ID_ARGC);

    if(!ssSetNumInputPorts( S, 0)) return;

    if(!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(   S, 0, BUFFER_SIZE(S) * NUM_CHANS(S));

    ssSetNumSampleTimes(S, 1);
    ssSetNumIWork(      S, NUM_IWORK);
    ssSetNumPWork(      S, NUM_PWORK);
    ssSetOptions(       S, SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, (real_T)BUFFER_SIZE(S) / SAMPLE_RATE(S));
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
    checkWindowsOS(S);
    checkWaveDevice(S);            RETURN_IF_ERROR(S);
    InitFIFOs(S);
    CreateAndInitializeMutexes(S); RETURN_IF_ERROR(S);
    setNumberOfBuffers(S);         RETURN_IF_ERROR(S);
    CreateBuffers(S);              RETURN_IF_ERROR(S);
    OpenDevice(S);                 RETURN_IF_ERROR(S);

    /* Send all buffers to input device */
    {
	LPWAVEHDR nextWaveHdr = FIRST_WAVEHDR(S);
	int_T i = NUM_BUFFERS(S);
        while(i-- > 0) {
	    PushFIFO(S, FIFO_NODATA, nextWaveHdr++);
	}
    }

    SendMaxEmptyBuffersToDevice(S); RETURN_IF_ERROR(S);
    StartDevice(S);                 RETURN_IF_ERROR(S);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const long  numSamples  = BUFFER_SIZE(S);
    const long  numChannels = NUM_CHANS(S);

    /* Wait for next audio frame to become available: */
    {
        /* Calculate appropriate time-out duration (seconds) */
        const double timeout = ((double) NUM_BUFFERS(S) * numSamples) / SAMPLE_RATE(S);
        double       dtime;
        time_t	     loopTime, startTime;

        time(&startTime);
        loopTime = startTime;

        /* Poll for data to become available */
        while( ((dtime=difftime(loopTime, startTime)) < timeout) &&
               FIFOEmpty(S,FIFO_DATA)) {
            Sleep(0);
            time(&loopTime);
        }

        if(dtime >= timeout) {
            THROW_ERROR(S,"Audio input device timed-out.");
        }
    }

    /* Send audio frame to block output port: */
    {
        real_T *y = ssGetOutputPortSignal(S, 0);

        /* Pop oldest buffer from data FIFO: */
        LPWAVEHDR lpwh = PopFIFO(S, FIFO_DATA);
        /* assert(lpwh != NULL); */

        /* Zero pad buffer if not completely filled */
        memset(lpwh->lpData + lpwh->dwBytesRecorded, 0, lpwh->dwBufferLength - lpwh->dwBytesRecorded);

        /* Convert to proper data type and output */
        switch(BITS_PER_SAMPLE(S)) {
	    case 8:
                {
                    unsigned char *data = (unsigned char *)lpwh->lpData;
                    int_T i;
                    if (numChannels == 1) {
                        /* Mono */
		        for(i=0; i < numSamples; i++) {
                            *y++ = (*data++ - 128.0) / 128.0;
		        }
                    } else {
                        /* Stereo */
		        for(i=0; i < numSamples; i++) {
                            *y = (*data++ - 128.0) / 128.0;
                            y[numSamples] = (*data++ - 128.0) / 128.0;
                            y++;
		        }
                    }
                }
	        break;

	    case 16:
                {
                    short *data = (short *)lpwh->lpData;
                    int_T i;
                    if (numChannels == 1) {
                        /* Mono */
		        for(i=0; i < numSamples; i++) {
                            *y++ = *data++ / 32768.0;
		        }
                    } else {
                        /* Stereo */
		        for(i=0; i < numSamples; i++) {
                            *y = *data++ / 32768.0;
                            y[numSamples] = *data++ / 32768.0;
                            y++;
		        }
                    }
                }
	        break;
        }

        /* Send the buffer back to the input device */
        PushFIFO(S, FIFO_NODATA, lpwh);
    }

    SendMaxEmptyBuffersToDevice(S); RETURN_IF_ERROR(S);
}


static void mdlTerminate(SimStruct *S)
{
    /*
     * Don't wait for queue buffers to fill.
     *
     * Reset device and free allocations.
     * Ignore any errors which might occur.
     */
    ResetDevice(S);
    FreeBuffers(S);
    CloseDevice(S);

    DeleteAndFreeMutexes(S);
}


#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] dsp_wai_win32.c */
