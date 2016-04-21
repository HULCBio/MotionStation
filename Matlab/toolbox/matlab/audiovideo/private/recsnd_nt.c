/*
 * recsnd_nt.c: Record sound using Microsoft Windows WAVE device.
 *
 * Y = RECSND(NSAMPS, FS, BITS, NCHANS, PREC)
 *  NSAMPS: # samples to return in rows of Y
 *  NCHANS: # channels of audio to return in columns of Y
 *      FS: Sample rate in Hz
 *    BITS: # bits per sample, 8 or 16
 *    PREC: Output matrix precision, 0=double, 1=int (uint8 or int16)
 *
 * NOTE: This algorithm does not allocate a second audio buffer.
 *       We re-use the return matrix for recording, then reformat
 *       the data (for double-precision only) in-place.
 *
 * NOTE: This algorithm is synchronous and thus blocks until finished.
 *
 *  Author: D. Orofino
 *  Copyright 1988-2002 The MathWorks, Inc. 
 *  $Revision: 1.1.6.1 $  $Date: 2003/07/11 15:54:08 $
 */
#include <time.h>
#include <windows.h>
#include <mmsystem.h>
#include <math.h>
#include "mex.h"


#define DOUBLE_REQUESTED ((int)mxGetPr(PREC_ARG)[0] == 0)
#define SINGLE_REQUESTED ((int)mxGetPr(PREC_ARG)[0] == 2)
#define FLOAT_REQUESTED  (DOUBLE_REQUESTED || SINGLE_REQUESTED)


enum {NSAMPS_ARGC=0, FS_ARGC, BITS_ARGC, NCHANS_ARGC, PREC_ARGC, NUM_INPUTS};
enum {Y_ARGC=0, NUM_OUTPUTS};

#define NSAMPS_ARG prhs[NSAMPS_ARGC]
#define FS_ARG     prhs[FS_ARGC]
#define BITS_ARG   prhs[BITS_ARGC]
#define NCHANS_ARG prhs[NCHANS_ARGC]
#define PREC_ARG   prhs[PREC_ARGC]

#define Y_ARG      plhs[Y_ARGC]

typedef struct {
    int nsamps;
    int nchans;
    int fs;
    int bits;
    
    void      *dataBuff;
    LPWAVEHDR  lpwh;
    HWAVEIN    hwi;
} UserInfo;


/*
 * Returns TRUE if device finished before timeout occurred.
 * Returns FALSE if timeout occurred before device finished.
 */
static unsigned long waitForAudio(LPWAVEHDR lpwh, const double timeout)
{
    /* Wait for device to reset: */
    time_t loopTime, startTime;
    
    /* Poll for data to become available */
    time(&startTime);
    loopTime = startTime;
    while( (difftime(loopTime, startTime) < timeout) &&
        !(lpwh->dwFlags & WHDR_DONE)) {
        time(&loopTime);
    }
    return( lpwh->dwFlags & WHDR_DONE );
}


static void FreeBuffers(UserInfo *u)
{
    if(u->lpwh != NULL) {
        /* Do not free u->lpwh->lpData, as it points
         * directly into the returned matrix data area.
         * We maintain that and return it to the user.
         */
        mxFree(u->lpwh);
    }
}


void Terminate(UserInfo *u)
{
    /* NOTE: Do not call CheckError here
     * (recursion can result)
     */
    if (u != NULL) {
        if (u->hwi != NULL) {
            waveInReset(u->hwi);
            
            if (u->lpwh != NULL) {
                /* Wait up to 1 sec for device to reset: */
                (void)waitForAudio(u->lpwh, (double)1.0);
                waveInUnprepareHeader(u->hwi, u->lpwh, sizeof(WAVEHDR));
            }
            waveInClose(u->hwi);
        }
        FreeBuffers(u);
    }
}


static void CheckError(UserInfo *u, MMRESULT mmResult) 
{
    static char	msg[MAXERRORLENGTH];
    
    if(mmResult != MMSYSERR_NOERROR) {
        /* Get error message from device driver */
        MMRESULT myMMResult = waveInGetErrorText(mmResult, msg, MAXERRORLENGTH);
        
        Terminate(u);
        
        if(myMMResult == MMSYSERR_NOERROR) {
            mexErrMsgTxt(msg);
        } else {
            mexErrMsgTxt("Unknown error occurred.");
        }
    }
}


static void MakeBuffers(UserInfo *u)
{
    /* Allocate WAVEHDR: */
    const int bufSiz = u->nsamps * u->nchans * (u->bits / 8);
    
    LPWAVEHDR lpwh = u->lpwh = (LPWAVEHDR)mxCalloc(1, sizeof(WAVEHDR));
    if(lpwh == NULL) {
        CheckError(u, MMSYSERR_NOMEM);
    }
    
    /* The sample buffer points directly to the return
     * matrix data storage area.
     *
     * For int16 and uint8, it is exactly the right size
     * For double, it is always a larger storage area.
     */
    lpwh->lpData = u->dataBuff;
    
    /* Initialize WAVEHDR: */
    lpwh->dwBufferLength = bufSiz;
    lpwh->dwFlags        = 0;
}


static void MakeWaveFormatEX(UserInfo *u, LPWAVEFORMATEX lpwfx)
{
    lpwfx->wFormatTag	    = WAVE_FORMAT_PCM;
    lpwfx->nChannels	    = u->nchans;
    lpwfx->nSamplesPerSec   = u->fs;
    lpwfx->wBitsPerSample   = u->bits;
    lpwfx->nBlockAlign      = lpwfx->nChannels * (u->bits / 8);
    lpwfx->nAvgBytesPerSec  = u->fs * lpwfx->nBlockAlign;
    lpwfx->cbSize           = 0;
}


/* Function: CheckFormatSupport =================================================
 * Abstract:
 *
 *  Checks if the device supports the requested format.
 */
static void CheckFormatSupport(UserInfo *u, LPWAVEFORMATEX pwfx, UINT uDeviceID)
{
    CheckError(u, waveInOpen( 
        NULL,                 /* ptr can be NULL for query      */
        uDeviceID,            /* the device identifier          */
        pwfx,                 /* defines requested format       */
        0,                    /* no callback                    */
        0,                    /* no instance data               */
        WAVE_FORMAT_QUERY));  /* query only, do not open device */
}


static void assignUserInfoDefaults(UserInfo *u)
{
    u->nsamps = -1;
    u->nchans = -1;
    u->fs     = -1;
    u->bits   = -1;

    u->dataBuff = NULL;
    u->lpwh     = NULL;
    u->hwi      = NULL;
}


/*
 * parseInputs
 *
 * Check input arguments and copy into data structure
 * Create output matrix
 */
UserInfo parseInputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    UserInfo u;
    int i;

    assignUserInfoDefaults(&u);
    
    /*
     * Check inputs:
     */
    if (nrhs < NUM_INPUTS) {
        mexErrMsgTxt("Not enough input arguments.");
    } else if (nrhs > NUM_INPUTS) {
        mexErrMsgTxt("Too many input arguments.");
    }
    
    if (nlhs>NUM_OUTPUTS) {
        mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Check that all inputs are real, double-prec, scalars: */
    for(i=0; i<NUM_INPUTS; i++) {
        if ( (mxGetNumberOfElements(prhs[i]) != 1) ||
            mxIsComplex(prhs[i]) || !mxIsDouble(prhs[i]) ) {
            mexErrMsgTxt("Input arguments must be real, double-precision scalars.");
        }
    }
    
    u.nsamps = (int)mxGetPr(NSAMPS_ARG)[0];
    if (u.nsamps<0) {
        mexErrMsgTxt("Invalid number of samples.");
    }
    
    u.fs = (int)mxGetPr(FS_ARG)[0];
    if (u.fs<=0) {
        mexErrMsgTxt("Invalid sample rate.");
    }
    
    u.bits = (int)mxGetPr(BITS_ARG)[0];
    if ((u.bits!=8) && (u.bits!=16)) {
        mexErrMsgTxt("Number of bits must be 8 or 16.");
    }
    
    u.nchans = (int)mxGetPr(NCHANS_ARG)[0];
    if ((u.nchans<1) || (u.nchans>2)) {
        mexErrMsgTxt("Invalid number of channels.");
    }
    
    {
        mxClassID prec;
        int       dims[2];
        int       id = (int)mxGetPr(PREC_ARG)[0];
        
        if ((id!=0) && (id!=1) && (id!=2)) {
            mexErrMsgTxt("Precision must be 0=double, 1=int, or 2=single.");
        }
        
        /*
         * Create output matrix:
         */
        if (id == 0) {
            prec = mxDOUBLE_CLASS;
        } else if (id == 2) {
            prec = mxSINGLE_CLASS;
        } else if (u.bits == 8) {
            prec = mxUINT8_CLASS;
        } else {
            prec = mxINT16_CLASS;
        }

        /* Data will need to be transposed once in MATLAB: */
        dims[0] = u.nchans;
        dims[1] = u.nsamps;
        
        Y_ARG = mxCreateNumericArray(2, dims, prec, mxREAL);
        u.dataBuff = (void *)mxGetPr(Y_ARG);
    }
    
    return(u);
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    UINT numInputDevices = waveInGetNumDevs();
    UINT uDeviceID       = WAVE_MAPPER;
        
    UserInfo u = parseInputs(nlhs, plhs, nrhs, prhs);
    
    if (numInputDevices == 0) {
        mexErrMsgTxt("No audio input devices.");
        return;
    }

    /* Setup WAVE hardware and headers: */
    {
        WAVEFORMATEX wfx;
        MakeWaveFormatEX(&u, &wfx);

        CheckFormatSupport(&u, &wfx, uDeviceID);

        MakeBuffers(&u); /* Allocate sample buffers */
        
        CheckError(&u, waveInOpen(&(u.hwi), uDeviceID, &wfx,
            (DWORD)NULL, (DWORD)NULL, CALLBACK_NULL));
    }
    
    CheckError(&u, waveInPrepareHeader(u.hwi, u.lpwh, sizeof(WAVEHDR)));
    CheckError(&u, waveInAddBuffer(    u.hwi, u.lpwh, sizeof(WAVEHDR)));
    CheckError(&u, waveInStart(        u.hwi));
    
    /* Wait for audio to become available: */
    if (waitForAudio(u.lpwh, 2.0 + (double)u.nsamps / u.fs) == 0) {
        Terminate(&u);
        mexErrMsgTxt("Audio device failed to respond before timeout occurred.");
    }
    
#if 0
    /* This should never be needed
     * Zero pad buffer if not completely filled
     */
    memset(u.lpwh->lpData + u.lpwh->dwBytesRecorded, 0,
        u.lpwh->dwBufferLength - u.lpwh->dwBytesRecorded);
#endif

    if (FLOAT_REQUESTED) {
        /*
         * Return floating-point (double- or single-precision) data.
         * Scale values while converting from int's to floating point (in-place).
         *
         * NOTE: Integer return data needs no additional scaling
         * NOTE: mxGetPr(Y_ARG) and u.lpwh->lpData are the same pointers
         *
         * Must loop over data in reverse order, so as to not
         * overwrite data which has not yet been seen...
         */
        const int bufsiz = u.nsamps * u.nchans;
        int       i;

        if ((void *)mxGetPr(Y_ARG) != (void *)u.lpwh->lpData) {
            mexErrMsgTxt("pointer mismatch");
        }
        
        if (SINGLE_REQUESTED) {
            float *y = (float *)mxGetPr(Y_ARG) +  (bufsiz-1);
            switch(u.bits) {
            case 8:
                {
                    unsigned char *data = (unsigned char *)u.lpwh->lpData + (bufsiz-1);
                    for(i=0; i < bufsiz; i++) {
                        /* Maintain in doubles then truncate to single: */
                        *y-- = (float)((*data-- - 128.0) / 128.0);
                    }
                }
                break;
            
            case 16:
                {
                    short *data = (short *)u.lpwh->lpData + bufsiz-1;
                    for(i=0; i < bufsiz; i++) {
                        /* Maintain in doubles then truncate to single: */
                        *y-- = (float)(*data-- / 32768.0);
                    }
                }
                break;
            }

        } else {
            double *y = mxGetPr(Y_ARG) +  bufsiz-1;
            switch(u.bits) {
            case 8:
                {
                    unsigned char *data = (unsigned char *)u.lpwh->lpData + bufsiz-1;
                    for(i=0; i < bufsiz; i++) {
                        *y-- = (*data-- - 128.0) / 128.0;
                    }
                }
                break;
            
            case 16:
                {
                    short *data = (short *)u.lpwh->lpData + bufsiz-1;
                    for(i=0; i < bufsiz; i++) {
                        *y-- = *data-- / 32768.0;
                    }
                }
                break;
            }
        }

    }
    
    Terminate(&u);
}

/* [EOF] recsnd_nt.c */
