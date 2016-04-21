/*
 * DSP_WAO_WIN32: DSP Blockset S-function implementing
 *                wave audio output device
 *
 * Based on an implementation by:
 *      Steve Mitchell
 *      Department of Electrical Engineering
 *      Cornell University
 *      Ithaca, NY  14853
 *
 * Code adapted and used by permission from
 * the Cornell Laboratory of Ornithology.
 *
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.6 $ $Date: 2002/04/14 20:43:28 $
 */

#include <windows.h>
#include <mmsystem.h>
#include <time.h>

#include "dsp_sim.h"

/*
 * Uses Windows API "wave audio" functions.
 *
 * The width of the input vector is BUFFER_SIZE * NUM_CHANS(S).
 * The inherited sample time Ts = BUFFER_SIZE / SAMPLE_RATE.
 * The input samples should lie numerically between -1.0 and +1.0.
 *
 * Parameters are:
 *	Number of channels	(1 or 2)
 *	Bits per sample		(8 or 16)
 *	Buffer duration		(seconds)
 *      Initial delay           (seconds)
 *
 *
 * FIFO_NODATA: Queue of empty buffers returned from audio device,
 *              waiting to be filled by Simulink
 *   FIFO_DATA: Queue of filled buffers waiting to be passed to the
 *              audio device
 *
 * The audio device is assumed to accept only MAX_DEVICE_BUFFERS
 * number of buffers.  The input queue is generally much larger
 * than this.  The initial delay is used to combat start-up glitches
 * in the audio stream, and cannot exceed MAX_DEVICE_BUFFERS before
 * the driver is started.  The minimum number of input queue buffers
 * is set to 3.
 *
 * Code must be linked against "winmm.lib".
 */

/*
 * S-Function arguments:
 */
enum {
    NUM_CHANS_ARGC,        /* 1 = mono, 2 = stereo      */
    BITS_PER_SAMPLE_ARGC,  /* 8 or 16	                */
    BUFFER_DURATION_ARGC,  /* time, in seconds	        */
    INIT_DELAY_ARGC,       /* time, in seconds          */
    DEVICE_ID_ARGC,        /* Audio device ID (1,2,...) */
    NUM_ARGS
};

#define NUM_CHANS_ARG(S)       ssGetSFcnParam(S, NUM_CHANS_ARGC      )
#define BITS_PER_SAMPLE_ARG(S) ssGetSFcnParam(S, BITS_PER_SAMPLE_ARGC)
#define BUFFER_DURATION_ARG(S) ssGetSFcnParam(S, BUFFER_DURATION_ARGC)
#define INIT_DELAY_ARG(S)      ssGetSFcnParam(S, INIT_DELAY_ARGC     )
#define DEVICE_ID_ARG(S)       ssGetSFcnParam(S, DEVICE_ID_ARGC      )

#define NUM_CHANS(S)		((unsigned short)*mxGetPr(NUM_CHANS_ARG(S)      ))
#define BITS_PER_SAMPLE(S)	((unsigned short)*mxGetPr(BITS_PER_SAMPLE_ARG(S)))
#define BUFFER_DURATION(S)	((double)        *mxGetPr(BUFFER_DURATION_ARG(S)))
#define INIT_DELAY(S)           ((double)        *mxGetPr(INIT_DELAY_ARG(S)     ))
#define DEVICE_ID(S)            ((UINT)          *mxGetPr(DEVICE_ID_ARG(S)      ))

enum {
    kWAVE_OUT_DEVICE,	 /* Win32 API audio device handle	 */
    kFIRST_WAVEHDR,	 /* First of NUM_BUFFERS WAVEHDR buffers */
    kFIFO_DATA_NEWEST,	 /* First element of FIFO_DATA		 */
    kFIFO_DATA_OLDEST,	 /* Last element of FIFO_DATA		 */
    kFIFO_NODATA_NEWEST, /* First element of FIFO_NODATA	 */
    kFIFO_NODATA_OLDEST, /* Last element of FIFO_NODATA		 */
    kMUTEX_OBJECTS,      /* Pointer to array of mutex objects    */
    NUM_PWORK
};

enum {
    kNUM_BUFFERS_IN_DEVICE,    /* Number of buffers sent to wave device     */
    kDEVICE_STARTUP_DELAY_CNT, /* # buffers to queue before starting device */
    kNUM_BUFFERS,	       /* at least 3				    */
    kIS_WINNT,                 /* Flag indicating if this is WinNT          */
    NUM_IWORK
};

/* Minimum and maximum number of buffers to use in FIFOs: */
#define MIN_FIFO_BUFFERS 3
#define MAX_FIFO_BUFFERS 1024

/* Maximum number of buffers to prepare (lock)
 * NOTE: This is usually much smaller than MAX_FIFO_BUFFERS
 */
#define MAX_DEVICE_BUFFERS 64

#define WAVE_OUT_DEVICE(S)	((HWAVEOUT) (ssGetPWorkValue(S, kWAVE_OUT_DEVICE)))
#define FIRST_WAVEHDR(S)	((LPWAVEHDR)(ssGetPWorkValue(S, kFIRST_WAVEHDR)))
#define IS_RUNNING_NT(S)        (ssGetIWorkValue(S, kIS_WINNT) != 0)

#define NUM_BUFFERS(S)	         (ssGetIWorkValue(S, kNUM_BUFFERS))
#define NUM_BUFFERS_IN_DEVICE(S) (ssGetIWorkValue(S, kNUM_BUFFERS_IN_DEVICE))
#define BUFFER_SIZE(S)	         (ssGetInputPortWidth(S,0) / NUM_CHANS(S))

#if !defined(RETURN_IF_ERROR)
#  define RETURN_IF_ERROR(S)	 if(ssGetErrorStatus(S) != NULL) return;
#endif

enum {FIFO_DATA, FIFO_NODATA};
#define kFIFO_NEWEST(fifoSel)   ( (fifoSel==FIFO_DATA) ? kFIFO_DATA_NEWEST : kFIFO_NODATA_NEWEST )
#define kFIFO_OLDEST(fifoSel)   ( (fifoSel==FIFO_DATA) ? kFIFO_DATA_OLDEST : kFIFO_NODATA_OLDEST )
#define FIFO_NEWEST(S, fifoSel) ((LPWAVEHDR)(ssGetPWorkValue(S, kFIFO_NEWEST(fifoSel))))
#define FIFO_OLDEST(S, fifoSel) ((LPWAVEHDR)(ssGetPWorkValue(S, kFIFO_OLDEST(fifoSel))))

enum {kMUTEX_FIFO_DATA, kMUTEX_FIFO_NODATA};
#define MUTEX_OBJECTS(S)       ((CRITICAL_SECTION *)ssGetPWorkValue(S, kMUTEX_OBJECTS))
#define kFIFO_MUTEX(fifoSel)   ((fifoSel==FIFO_DATA) ? kMUTEX_FIFO_DATA : kMUTEX_FIFO_NODATA)
#define FIFO_MUTEX(S, fifoSel) (MUTEX_OBJECTS(S) + kFIFO_MUTEX(fifoSel))

#define EnterFIFOMutex(S, fifoSel) EnterCriticalSection(FIFO_MUTEX(S, fifoSel));
#define LeaveFIFOMutex(S, fifoSel) LeaveCriticalSection(FIFO_MUTEX(S, fifoSel))

#define DEVICE_PAUSED(S)  (ssGetIWorkValue(S, kDEVICE_STARTUP_DELAY_CNT) != 0)
#define DEVICE_RUNNING(S) (ssGetIWorkValue(S, kDEVICE_STARTUP_DELAY_CNT) == 0)
#define DEVICE_TIMEOUT(S) (NUM_BUFFERS(S) * ssGetSampleTime(S,0) + 1)


/* Function: setStartupDelayCnt =============================================
 * Abstract:
 *
 *  Compute and store the initial number of buffers to enqueue before
 *  starting the audio device.  This initial delay is used to prevent
 *  audio glitches due to a lack of data.
 *
 *  NOTE: The maximum possible delay is clipped to NUM_BUFFERS, which
 *  in turn is clipped to MAX_FIFO_DELAY.  Hence, the actual initial
 *  delay may be shorter than what the user indicated.  We must not
 *  allow the maximum delay to exceed NUM_BUFFERS, otherwise the device
 *  will never get started!
 *
 *  NOTE: There should be at least ONE initial buffer enqueued before
 *  starting device; however, zero is properly handled in the code.
 *  One is a good minimum.  No delay is really incurred, as no "valid"
 *  data could possibly play until the first buffer is filled and sent
 *  to the device!  One simply indicates that the device should remain
 *  paused until this first buffer is queued up.  Zero would allow the
 *  device to begin running before any data whatsoever is queued ... a
 *  timeout error is likely to occur, depending on the timeout delay.
 */
static void setStartupDelayCnt(SimStruct *S)
{
    int_T cnt = (int_T) ceil(INIT_DELAY(S) / ssGetSampleTime(S,0));

    if      (cnt > NUM_BUFFERS(S)) cnt = NUM_BUFFERS(S);
    else if (cnt < 1             ) cnt = 1;

    ssSetIWorkValue(S, kDEVICE_STARTUP_DELAY_CNT, cnt);
}


/* Function: setNumberOfBuffers ==============================================
 * Abstract:
 *
 *  Compute and store the number of buffers to maintain in FIFOs
 */
static void setNumberOfBuffers(SimStruct *S)
{
    /* Convert buffer duration to an integer number of buffers: */
    int_T numBuffs = (int_T) ceil(BUFFER_DURATION(S) / ssGetSampleTime(S,0));

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
	    /* assert(FIFO_OLDEST == NULL); */
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
	MMRESULT local_errStatus = waveOutGetErrorText(errStatus, msg, MAXERRORLENGTH);
	
	if (local_errStatus == MMSYSERR_NOERROR) {
            ssSetErrorStatus(S, msg);
        } else {

            switch (errStatus) {
		case MMSYSERR_ALLOCATED:
		    ssSetErrorStatus(S, "Sound output device busy");
		    break;
		    
		case MMSYSERR_BADDEVICEID:
		    ssSetErrorStatus(S, "Missing sound output device");
		    break;
		    
		case MMSYSERR_INVALHANDLE:
		    ssSetErrorStatus(S, "Invalid device handle");
		    break;
		   		    
		case WAVERR_BADFORMAT:
		    ssSetErrorStatus(S, "Sound format unsupported");
		    break;
		    
		case WAVERR_STILLPLAYING:
		    ssSetErrorStatus(S, "Active buffers prevent operation");
		    break;
		    
		case WAVERR_UNPREPARED:
		    ssSetErrorStatus(S, "Buffer unprepared");
		    break;

		case MMSYSERR_NODRIVER:
		    ssSetErrorStatus(S, "No device driver is present.");
		    break;
		case MMSYSERR_NOMEM:
		    ssSetErrorStatus(S, "Unable to allocate or lock memory.");
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
 *   Checks if at least one wave audio output device exists.
 *
 *   If there's no audio device, should we implement a "no op"
 *   (with a warning), or should we error out?  Currently, an
 *   error is generated.
 *
 * Can fail.
 */
static void checkWaveDevice(SimStruct *S)
{
    UINT numOutputDevices = waveOutGetNumDevs();
    if (numOutputDevices < 1) {
        THROW_ERROR(S, "No audio output devices detected.");
    }
}


/* Function: UnprepareBuffer =======================================================
 * Abstract:
 *
 *  "Unprepare" a buffer.
 *
 * Can fail.
 */
static void UnprepareBuffer(SimStruct *S, LPWAVEHDR lpwh) 
{
    CheckError(S, waveOutUnprepareHeader(WAVE_OUT_DEVICE(S), lpwh, sizeof (WAVEHDR)));
}


/* Function: PrepareBuffer =======================================================
 * Abstract:
 *
 *  "Prepare" a buffer.  Not sure what it really does, but it
 *  needs to be undone before freeing the buffer.
 *
 * Can fail.
 */
static void PrepareBuffer(SimStruct *S, LPWAVEHDR lpwh) 
{
    CheckError(S, waveOutPrepareHeader(WAVE_OUT_DEVICE(S), lpwh, sizeof (WAVEHDR)));
}


/* Function: MakeWaveFormatEX =======================================================
 * Abstract:
 *
 *  Utility for building wave output format struct.
 */
static void MakeWaveFormatEX(SimStruct *S, LPWAVEFORMATEX lpwfx)
{
    lpwfx->wFormatTag	   = WAVE_FORMAT_PCM;
    lpwfx->nChannels	   = NUM_CHANS(S);
    lpwfx->nSamplesPerSec  = (unsigned long)(BUFFER_SIZE(S) / ssGetSampleTime(S,0));
    lpwfx->wBitsPerSample  = BITS_PER_SAMPLE(S);
    lpwfx->nBlockAlign	   = lpwfx->nChannels * (lpwfx->wBitsPerSample / 8);
    lpwfx->nAvgBytesPerSec = lpwfx->nSamplesPerSec * lpwfx->nBlockAlign;
    lpwfx->cbSize	   = 0;
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
        uDeviceID--;  /* Translate 1,2,... to 0,1,... */
    }

    /*
     * No need to check that device exists;
     * the device-open call will do that for us.
     */
    return(uDeviceID);
}


/* Function: ResetDevice =======================================================
 * Abstract:
 *
 *		Resets wave output device
 *
 * Can fail.
 */
static void ResetDevice(SimStruct *S) 
{
    CheckError(S, waveOutReset(WAVE_OUT_DEVICE(S)));
}


/* Function: RestartDevice =======================================================
 * Abstract:
 *
 *		Restarts wave output device
 *
 * Can fail.
 */
static void RestartDevice(SimStruct *S) 
{
    CheckError(S, waveOutRestart(WAVE_OUT_DEVICE(S)));
}


/* Function: PauseDevice =======================================================
 * Abstract:
 *
 *		Pauses wave output device
 *
 * Can fail.
 */
static void PauseDevice(SimStruct *S) 
{
    CheckError(S, waveOutPause(WAVE_OUT_DEVICE(S)));
}


/* Function: CloseDevice =======================================================
 * Abstract:
 *
 *		Closes wave output device
 *
 * Can fail.
 */
static void CloseDevice(SimStruct *S) 
{
    CheckError(S, waveOutClose(WAVE_OUT_DEVICE(S)));
}


/* Function: SendBufferToDevice =======================================================
 * Abstract:
 *
 *		Add a buffer to the wave audio device queue
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

    if(CheckError(S, waveOutWrite(WAVE_OUT_DEVICE(S), lpwh, sizeof(WAVEHDR)))) {
        /* Failed - reduce queue count */
	InterlockedDecrement(ssGetIWork(S) + kNUM_BUFFERS_IN_DEVICE);
    }
}


/* Function: SendMaxFilledBuffersToDevice =======================================================
 * Abstract:
 *
 *		Send as many buffers to the audio output queue as possible.
 *
 * Can fail.
 */
static void SendMaxFilledBuffersToDevice(SimStruct *S) 
{
    while( (NUM_BUFFERS_IN_DEVICE(S) < MAX_DEVICE_BUFFERS) &&
           !FIFOEmpty(S, FIFO_DATA)
         ) {

        SendBufferToDevice(S, PopFIFO(S,FIFO_DATA)); RETURN_IF_ERROR(S);
    }
}


/* Function: waveOutProc =======================================================
 * Abstract:
 *
 *  Callback function for wave output device
 */
static void CALLBACK waveOutProc(
    HWAVEOUT	hwo, 
    UINT	uMsg, 
    DWORD	dwInstance, 
    DWORD	dwParam1, 
    DWORD	dwParam2)
{
    if (uMsg == WOM_DONE) {
        SimStruct *S = (SimStruct*)dwInstance;
        /* One buffer returned from device - decrement device buffer counter: */
	/* assert(NUM_BUFFERS_IN_DEVICE(S) > 0) */
	InterlockedDecrement(ssGetIWork(S) + kNUM_BUFFERS_IN_DEVICE);

	/* Return used buffer to the FIFO_NODATA queue */
        {
            LPWAVEHDR lpwh = (LPWAVEHDR)dwParam1;
            if (!IS_RUNNING_NT(S)) {
                UnprepareBuffer(S, lpwh);
            }
            PushFIFO(S, FIFO_NODATA, lpwh);
        }
    }
}


/* Function: CheckFormatSupport =================================================
 * Abstract:
 *
 *  Checks if the device supports the requested format.
 */
static void CheckFormatSupport(SimStruct *S, LPWAVEFORMATEX pwfx, UINT uDeviceID)
{ 
    CheckError(S, waveOutOpen( 
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
 *  Opens wave output device, and returns a handle to it
 *
 * Can fail.
 */
static void OpenDevice(SimStruct *S) 
{
    UINT         uDeviceID = getDeviceID(S);
    WAVEFORMATEX wfx;
    HWAVEOUT     hwo;

    ssSetPWorkValue(S, kWAVE_OUT_DEVICE,       NULL);
    ssSetIWorkValue(S, kNUM_BUFFERS_IN_DEVICE, 0);

    MakeWaveFormatEX(S, &wfx);
    
    /* Check that device supports requested format: */
    CheckFormatSupport(S, &wfx, uDeviceID); RETURN_IF_ERROR(S);

    /* Attempt to open device: */
    CheckError(S, waveOutOpen(&hwo, uDeviceID, &wfx,
	   (DWORD)waveOutProc, (DWORD) S, CALLBACK_FUNCTION));
    RETURN_IF_ERROR(S);

    ssSetPWorkValue(S, kWAVE_OUT_DEVICE, hwo);
}


/* Function: FreeBuffers =======================================================
 * Abstract:
 *
 *		Free allocated sample buffers
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


/* Function: CreateBuffers =======================================================
 * Abstract:
 *
 *		Allocate sample buffers
 *
 * Can fail.
 */
static void CreateBuffers(SimStruct *S)
{
    /* Compute buffer size, in bytes: */
    const int_T bufSiz  = BUFFER_SIZE(S) * (BITS_PER_SAMPLE(S) / 8) * NUM_CHANS(S);
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
static void mdlCheckParameters (SimStruct *S)
{
    if (!IS_FLINT_IN_RANGE(NUM_CHANS_ARG(S),1,2)) {
        THROW_ERROR(S,"Number of channels must be 1 or 2.");
    }

    if ( !IS_SCALAR_DOUBLE(BITS_PER_SAMPLE_ARG(S)) ||
         (BITS_PER_SAMPLE(S)!=8) && (BITS_PER_SAMPLE(S)!=16)) {
        THROW_ERROR(S,"Number of bits per sample must be 8 or 16.");
    }

    if (!IS_SCALAR_DOUBLE(BUFFER_DURATION_ARG(S)) ||
        (BUFFER_DURATION(S) <= 0.0) ) {
	THROW_ERROR(S,"Buffer duration must be > 0.");
    }

    if (!IS_SCALAR_DOUBLE(INIT_DELAY_ARG(S)) ||
        (INIT_DELAY(S) < 0.0) ) {
	THROW_ERROR(S,"Initial delay must be >= 0.");
    }
    if (INIT_DELAY(S) > BUFFER_DURATION(S)) {
	THROW_ERROR(S,"Initial delay must be less than the buffer duration.");
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
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    RETURN_IF_ERROR(S);
#endif

    ssSetSFcnParamNotTunable(S, NUM_CHANS_ARGC);
    ssSetSFcnParamNotTunable(S, BITS_PER_SAMPLE_ARGC);
    ssSetSFcnParamNotTunable(S, BUFFER_DURATION_ARGC);
    ssSetSFcnParamNotTunable(S, INIT_DELAY_ARGC);
    ssSetSFcnParamNotTunable(S, DEVICE_ID_ARGC);

    if (!ssSetNumOutputPorts(S, 0)) return;

    if (!ssSetNumInputPorts(        S, 1)) return;
    ssSetInputPortWidth(            S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 0);  /* Not reading inputs in mdlOutput */

    ssSetNumSampleTimes (S, 1);
    ssSetNumIWork (      S, NUM_IWORK);
    ssSetNumPWork (      S, NUM_PWORK);
    ssSetOptions (       S, SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes (SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    /* Check that the specified # of channels is appropriate for the input buffer width: */
    if (ssGetInputPortWidth(S, 0) % NUM_CHANS(S) != 0) {
        THROW_ERROR(S, "Invalid number of channels specified - input source is probably not Stereo.");
    }
    if (BUFFER_SIZE(S) < 1) {  /* This is the per-channel buffer length (in samples, not bytes) */
        THROW_ERROR(S, "Input width must be >= 1.");
    }

    /* Check that input rate is not continuous: */
    if (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S,"Input to block must have a discrete sample time.");
    }
#endif

    checkWindowsOS(S);
    checkWaveDevice(S);            RETURN_IF_ERROR(S);
    InitFIFOs(S);
    CreateAndInitializeMutexes(S); RETURN_IF_ERROR(S);
    setNumberOfBuffers(S);         RETURN_IF_ERROR(S);
    CreateBuffers(S);              RETURN_IF_ERROR(S);
    setStartupDelayCnt(S);

    /* Send all buffers to FIFO_NODATA */
    {
	LPWAVEHDR nextWaveHdr = FIRST_WAVEHDR(S);
	int_T i = NUM_BUFFERS(S);
        while(i-- > 0) {
	    PushFIFO(S, FIFO_NODATA, nextWaveHdr++);
	}
    }

    /* Purge any remaining sound samples: */
    PlaySound(NULL, NULL, SND_PURGE);
    OpenDevice(S);  RETURN_IF_ERROR(S);
    ResetDevice(S); RETURN_IF_ERROR(S);

    /* Pause device until queue has partially filled
     * This is needed to prevent sound glitch at start-up
     * Device is restarted in SendMaxFilledBuffersToDevice() and mdlTerminate()
     */
    /* Pause device until initial queue count has been reached.
     * If the initial buffer delay count is set to zero (a poor choice indeed!),
     * do not pause the device.
     */
    if (DEVICE_PAUSED(S)) {
        PauseDevice(S);
    } else {
        RestartDevice(S);  /* Not a great idea... but initial delay is zero! */
    }
    RETURN_IF_ERROR(S);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
}


#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid)
{
    /* Wait for an empty buffer to become available: */
    {
        /* Calculate appropriate time-out duration */
        const double timeout = DEVICE_TIMEOUT(S);
        double       dtime;
        time_t	     loopTime, startTime;

        time(&startTime);
        loopTime = startTime;

        /* Poll for empty buffer to become available */
        while( ((dtime=difftime(loopTime, startTime)) < timeout) &&
               FIFOEmpty(S,FIFO_NODATA) ) {
            Sleep(0);  /* relinquish CPU for remainder of time slice */
	    time(&loopTime);
        }

        if (dtime >= timeout) {
	    THROW_ERROR(S,"Audio output device timed-out.");
        }
    }

    /* Write block input to empty buffer: */
    {
        const int_T  numSamples  = BUFFER_SIZE(S);
        const int_T  numChannels = NUM_CHANS(S);

        InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S, 0);

        /* Pop oldest buffer from the "unfilled bucket" FIFO: */
        LPWAVEHDR lpwh = PopFIFO(S, FIFO_NODATA);
        /* assert(lpwh != NULL); */

        /* Convert to proper data type and output */
        switch (BITS_PER_SAMPLE(S)) {
	    case 8:
	        {
		    unsigned char *buf = (unsigned char *)lpwh->lpData;
		    int_T i;
		    for (i=0; i < numSamples; i++) {
		        int_T channel;
		        for (channel=0; channel < numChannels; channel++) {
			    real_T u = *uPtrs[numSamples * channel + i] * 128 + 128;
			    if      (u < 0  ) u = 0;
			    else if (u > 255) u = 255;
			    *buf++ = (unsigned char)u;
		        }
		    }
	        }
	        break;

	    case 16:
	        {
		    short *buf = (short *)lpwh->lpData;
		    int_T i;
		    for (i=0; i < numSamples; i++) {
		        int_T channel;
		        for (channel=0; channel < numChannels; channel++) {
			    real_T u = *uPtrs[numSamples * channel + i] * 32768;
			    if      (u <-32768) u =-32768;
			    else if (u > 32767) u = 32767;
			    *buf++ = (short)u;
		        }
		    }
	        }
	        break;
	}

        /* Move buffer to the "filled bucket" FIFO: */
        PushFIFO(S, FIFO_DATA, lpwh);
    }

    SendMaxFilledBuffersToDevice(S); RETURN_IF_ERROR(S);

    /* Start audio device if paused.
     *
     * NOTE: Do not start device until queued buffers have been sent
     * to the device, i.e., call after SendMaxFilledBuffersToDevice.
     */
    if (DEVICE_PAUSED(S)) {
        int *cnt = ssGetIWork(S) + kDEVICE_STARTUP_DELAY_CNT;
        if (--(*cnt) == 0) {
            RestartDevice(S); RETURN_IF_ERROR(S);
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
    /* If device is still paused, an error occurred prior
     * to the INIT_DELAY buffers being sent to the driver.
     * In that case, don't play out queued buffers; just
     * flush the queue.
     *
     * If the device is running, the simulation ended but
     * the driver still has queued buffers.  Allow these
     * buffers to play out.
     */
    if (ssGetErrorStatus(S) == NULL) {
        if (DEVICE_RUNNING(S)) {
            time_t loopTime, startTime;
            const double timeout = DEVICE_TIMEOUT(S);

            time(&startTime);
            loopTime = startTime;

            /* Send remaining queued buffers */
            while ( (!FIFOEmpty(S, FIFO_DATA) || (NUM_BUFFERS_IN_DEVICE(S) > 0))
		             && (difftime(loopTime, startTime) < timeout)) {
	        SendMaxFilledBuffersToDevice(S);

                Sleep(0);
	        time(&loopTime);
            }
        }
    }

    /*
     * Reset device and free allocations.
     * Ignore any errors which might occur.
     */
    ResetDevice(S);
    FreeBuffers(S);
    CloseDevice(S);

    DeleteAndFreeMutexes(S);
}

#include "dsp_trailer.c"

/* [EOF] dsp_wao_win32.c */
