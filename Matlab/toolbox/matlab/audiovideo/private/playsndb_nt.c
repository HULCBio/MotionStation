/*
 * Synchronous (blocking) playback of sound using Microsoft Windows WAVE device.
 *
 * Y = PLAYSNDB(X', FS)
 *       X: Input signal, double, int16, or uint8
 *      FS: Sample rate in Hz
 *
 * NOTE: This algorithm is synchronous and thus blocks until finished.
 * NOTE: X is constructed with one signal per column, one column per channel.
 *       X' is passed in, not X, so that adjacent samples are across channels.
 *
 *  $RCSfile: playsndb_nt.c,v $
 *  Author: D. Orofino
 *  Copyright 1988-2002 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/07/11 15:54:03 $
 */
#include <time.h>
#include <windows.h>
#include <mmsystem.h>
#include <math.h>
#include "mex.h"

enum {NUM_OUTPUTS};
enum {X_ARGC=0, FS_ARGC, NUM_INPUTS};

#define X_ARG      prhs[X_ARGC]
#define FS_ARG     prhs[FS_ARGC]

typedef struct {
    int nsamps;
    int nchans;
    int fs;
    int bits;
    
    void       *dataBuff;
    boolean_T   isTemp;

    LPWAVEHDR  lpwh;
    HWAVEOUT   hwo;
} UserInfo;


/*
* Returns TRUE if device finished before timeout occurred.
* Returns FALSE if timeout occurred before device finished.
*/
bool waitForAudio(LPWAVEHDR lpwh, const double timeout)
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
       /* Only free u->lpwh->lpData (u.dataBuff) if it points to
        * a temporary allocation.
        */
        if (u->isTemp) {
            mxFree(u->dataBuff);
        }
        mxFree(u->lpwh);
    }
}


void Terminate(UserInfo *u)
{
    /* NOTE: Do not call CheckError here
     * (recursion can result)
     */
    if (u != NULL) {
        if (u->hwo != NULL) {
            waveOutReset(u->hwo);
            
            if (u->lpwh != NULL) {
                /* Wait up to 1 sec for device to reset: */
                (void)waitForAudio(u->lpwh, (double)1.0);
                waveOutUnprepareHeader(u->hwo, u->lpwh, sizeof(WAVEHDR));
            }
            waveOutClose(u->hwo);
        }
        FreeBuffers(u);
    }
}


static void CheckError(UserInfo *u, MMRESULT mmResult) 
{
    static char	msg[MAXERRORLENGTH];
    
    if(mmResult != MMSYSERR_NOERROR) {
        /* Get error message from device driver */
        MMRESULT myMMResult = waveOutGetErrorText(mmResult, msg, MAXERRORLENGTH);
        
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
    lpwfx->cbSize	    = 0;
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
    if ((mxGetNumberOfElements(FS_ARG) != 1) ||
         mxIsComplex(FS_ARG) || mxIsSparse(FS_ARG) || !mxIsDouble(FS_ARG)) {
        mexErrMsgTxt("Sample rate must be a real, double-precision scalar.");
    }

    if ( mxIsComplex(X_ARG) || mxIsSparse(X_ARG) ||
         !(mxIsDouble(X_ARG) || mxIsSingle(X_ARG) || mxIsUint8(X_ARG) || mxIsInt16(X_ARG))
       ) {
        mexErrMsgTxt("Input arguments must be real uint8, int16, single, or double-precision.");
    }
    
    {
        int M = mxGetM(X_ARG);
        int N = mxGetN(X_ARG);
        u.nsamps = (N==1) ? M : N;
        u.nchans = (N==1) ? N : M;
    }

    u.fs = (int)mxGetPr(FS_ARG)[0];
    if (u.fs<=0) {
        mexErrMsgTxt("Invalid sample rate.");
    }
    
    if (mxIsUint8(X_ARG)) {
        u.bits = 8;
    } else {
        /* Int16, single, double */
        u.bits = 16;
    }

    u.isTemp = (boolean_T)(mxIsDouble(X_ARG) || mxIsSingle(X_ARG));
    if (u.isTemp) {
        /* Create temp buffer: */
        const int_T  N = u.nsamps * u.nchans;
        int16_T     *y = (int16_T *)mxMalloc(2*N);

        u.dataBuff = (void *)y;

        /* Normalize and copy into temp buffer: */
        if (mxIsSingle(X_ARG)) {
            float *x = (float *)mxGetPr(X_ARG);

            for (i=0; i < N; i++) {
                double t = *x++ * 32768.0;  /* use double-prec for temp */
                if      (t> 32767.0) t= 32767.0;
                else if (t<-32768.0) t=-32768.0;

                *y++ = (int16_T)t;
            }

        } else {
            double *x = (double *)mxGetPr(X_ARG);

            for (i=0; i < N; i++) {
                double t = *x++ * 32768.0;
                if      (t> 32767.0) t= 32767.0;
                else if (t<-32768.0) t=-32768.0;

                *y++ = (int16_T)t;
            }
        }

    } else {
        u.dataBuff = (void *)mxGetPr(X_ARG);
    }
    
    return(u);
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    UINT numOutputDevices = waveOutGetNumDevs();
    
    UserInfo u;
    
    if (numOutputDevices == 0) {
        mexErrMsgTxt("No audio output devices.");
    }

    u = parseInputs(nlhs, plhs, nrhs, prhs);

    /* Setup WAVE hardware and headers: */
    {
        WAVEFORMATEX wfx;
        MakeWaveFormatEX(&u, &wfx);
        MakeBuffers(&u); /* Allocate sample buffers */

       /*
        * The waveOutOpen call checks that the hardware
        * supports requested options:
        */
        PlaySound(NULL, NULL, SND_PURGE);
        CheckError(&u, waveOutOpen(&(u.hwo), WAVE_MAPPER, &wfx,
            (DWORD)NULL, (DWORD)NULL, CALLBACK_NULL));
    }
    CheckError(&u, waveOutPrepareHeader(u.hwo, u.lpwh, sizeof(WAVEHDR)));
    CheckError(&u, waveOutWrite(        u.hwo, u.lpwh, sizeof(WAVEHDR)));

    /* Wait for audio to become available: */
    if (!waitForAudio(u.lpwh, 2.0 + ((double)(u.nsamps)) / (u.fs))) {
        Terminate(&u);
        mexErrMsgTxt("Audio device failed to respond before timeout occurred.");
    }
    
    Terminate(&u);
}

/* [EOF] playsndb_nt.c */
