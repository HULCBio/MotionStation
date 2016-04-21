/*
 * DSP_WAFI_WIN32: DSP Blockset S-function implementing
 *                 Win32 wave audio file input
 *
 * Original implementation by:
 *      Steve Mitchell
 *      Department of Electrical Engineering
 *      Cornell University
 *      Ithaca, NY  14853
 *
 * Code adapted and used by permission from the
 * Cornell Laboratory of Ornithology at Cornell University.
 *
 * Initial DSP Blockset version: D. Orofino
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.4 $ $Date: 2002/04/14 20:43:19 $
 */

#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>

#include "dsp_sim.h"

/* 
 * ReadWavHeader
 * OpenWavFile
 * MakeSampleBuffer
 * FreeBuffer
 * InitPointers
 * CloseFile
 * CleanUp
 */


enum {
    kFILENAME_MX,	/* ".wav" will be added		*/
    kSAMPLE_RATE_ARG,	/* in Hertz			*/
    kNUM_CHANNELS_ARG,	/* 1 = mono, 2 = stereo		*/
    kBUFFER_SIZE,	/* Samples per frame		*/
    kNUM_PARAMETERS
};

#define FILENAME_MX		((mxArray*)                        (ssGetSFcnParam (S, kFILENAME_MX)))
#define SAMPLE_RATE_ARG		((double)                  *mxGetPr(ssGetSFcnParam (S, kSAMPLE_RATE_ARG)))
#define NUM_CHANNELS_ARG	((unsigned short)floor(0.5+*mxGetPr(ssGetSFcnParam (S, kNUM_CHANNELS_ARG))))
#define BUFFER_SIZE		((long)          floor(0.5+*mxGetPr(ssGetSFcnParam (S, kBUFFER_SIZE))))


/* Integer work vector items */
enum {
	kBYTES_IN_FILE,	        	/* Number of samples in file			*/
	kBITS_PER_SAMPLE,		/* Number of bits per sample in file		*/
	kSAMPLE_RATE,			/* Samples per second				*/
	kNUM_CHANNELS,			/* Number of channels (1=mono, 2=stereo)	*/
	kBLOCK_ALIGN,			/* Bytes per sample * num channels		*/
	kIN_WAVE_CHUNK,			/* Boolean -- in wave chunk			*/
	kIN_DATA_CHUNK,			/* Boolean -- in data chunk			*/
	kNUMIWORKITEMS
};

#define BYTES_IN_FILE		(ssGetIWorkValue (S, kBYTES_IN_FILE))
#define BITS_PER_SAMPLE		(ssGetIWorkValue (S, kBITS_PER_SAMPLE))
#define SAMPLE_RATE		(ssGetIWorkValue (S, kSAMPLE_RATE))
#define NUM_CHANNELS		(ssGetIWorkValue (S, kNUM_CHANNELS))
#define BLOCK_ALIGN		(ssGetIWorkValue (S, kBLOCK_ALIGN))
#define IN_WAVE_CHUNK		(ssGetIWorkValue (S, kIN_WAVE_CHUNK))
#define IN_DATA_CHUNK		(ssGetIWorkValue (S, kIN_DATA_CHUNK))

/* Pointer work vector items */
enum {
	kSAMPLE_BUF,			/* Work space for integer samples	*/
	kFILE_DESC,			/* File descriptor			*/
	kFILENAME,			/* C-string file name			*/
	kDATA_CK_INFO,			/* Data chunk info record		*/
	kWAVE_CK_INFO,			/* Wave chunk info record		*/
	kNUMPWORKITEMS
};

#define SAMPLE_BUF		((char*)       (ssGetPWorkValue (S, kSAMPLE_BUF)))
#define FILE_DESC		((HMMIO)       (ssGetPWorkValue (S, kFILE_DESC)))
#define FILENAME		((char*)       (ssGetPWorkValue (S, kFILENAME)))
#define DATA_CK_INFO		((MMCKINFO*)   (ssGetPWorkValue (S, kDATA_CK_INFO)))
#define WAVE_CK_INFO		((MMCKINFO*)   (ssGetPWorkValue (S, kWAVE_CK_INFO)))


/* Macros */
#define BYTES_PER_SAMPLE	((BITS_PER_SAMPLE + 7) / 8)
#define BUFSIZE			(BUFFER_SIZE * BLOCK_ALIGN)

#define RETURN_IF_ERROR		if (ssGetErrorStatus (S) != NULL) return;
#define ERROR_STRING(a)		a
#define MMERROR			(mmResult != MMSYSERR_NOERROR)


static void FreeBuffer(SimStruct *S)
{
    {
        char *sample_buf = SAMPLE_BUF;
        if (sample_buf != NULL) free(sample_buf);
        ssSetPWorkValue(S, kSAMPLE_BUF, NULL);
    }
    {
        char *filename = FILENAME;
        if (filename != NULL) free (filename);
        ssSetPWorkValue (S, kFILENAME, NULL);
    }
    {
	MMCKINFO *dataCkInfo = DATA_CK_INFO;
        if (dataCkInfo != NULL) {
            free (dataCkInfo);
        }
	ssSetPWorkValue(S, kDATA_CK_INFO, NULL);
    }
    {
	MMCKINFO *waveCkInfo = WAVE_CK_INFO;
	if (waveCkInfo != NULL) free(waveCkInfo);
	ssSetPWorkValue(S, kWAVE_CK_INFO, NULL);
    }
}


static void CloseFile(SimStruct *S)
{
    if (FILE_DESC != NULL) {
        mmioClose(FILE_DESC, 0);
    }
    ssSetPWorkValue(S, kFILE_DESC, NULL);
}


static void CleanUp(SimStruct *S)
{
    CloseFile(S);
    FreeBuffer(S);
}


static void ReadWavHeader(SimStruct *S)
{
    MMRESULT		mmResult;
    MMCKINFO		mmFMTCkInfo;
    PCMWAVEFORMAT	pcmWaveFormat;
    long		m;
    static char		msg[256];

    /* Find 'WAVE' chunk */
    WAVE_CK_INFO->fccType = mmioFOURCC('W', 'A', 'V', 'E'); 
    mmResult = mmioDescend(FILE_DESC, WAVE_CK_INFO, NULL, MMIO_FINDRIFF);
    if (MMERROR) {
	CleanUp(S);
	THROW_ERROR(S,"Error reading file header")
    }
    ssSetIWorkValue(S, kIN_WAVE_CHUNK, 1);

    /* Find 'fmt ' chunk */
    mmFMTCkInfo.ckid = mmioFOURCC('f', 'm', 't', ' '); 
    mmResult = mmioDescend(FILE_DESC, &mmFMTCkInfo, WAVE_CK_INFO, MMIO_FINDCHUNK);
    if (MMERROR) {
	CleanUp(S);
	THROW_ERROR(S,"Error reading file header")
    }

    /* Read 'fmt ' chunk */
    m = mmioRead(FILE_DESC, (char *) &pcmWaveFormat, sizeof(PCMWAVEFORMAT));
    if (m != sizeof(PCMWAVEFORMAT)) {
	CleanUp (S);
	THROW_ERROR(S,"Error reading file header")
    }

    /* Ascend from format chunk */
    mmResult = mmioAscend(FILE_DESC, &mmFMTCkInfo, 0); 
    if (MMERROR) {
	CleanUp(S);
	THROW_ERROR(S, "Error reading file header")
    }

    /* Check for PCM format */
    if (pcmWaveFormat.wf.wFormatTag != WAVE_FORMAT_PCM) {
	CleanUp(S);
	THROW_ERROR(S, "Wave file is not in PCM format")
    }

    /* Read PCM format parameters */
    ssSetIWorkValue(S, kBITS_PER_SAMPLE, pcmWaveFormat.wBitsPerSample);
    ssSetIWorkValue(S, kSAMPLE_RATE,     pcmWaveFormat.wf.nSamplesPerSec);
    ssSetIWorkValue(S, kNUM_CHANNELS,    pcmWaveFormat.wf.nChannels);
    ssSetIWorkValue(S, kBLOCK_ALIGN,     pcmWaveFormat.wf.nBlockAlign);

    /* Verify numChannels and sampleRate arguments */
    if (NUM_CHANNELS_ARG != NUM_CHANNELS) {
	CleanUp(S);
	sprintf(msg, "File contains wrong number of channels (%ld)", NUM_CHANNELS);
	THROW_ERROR(S, msg)
    }

    if (SAMPLE_RATE_ARG != SAMPLE_RATE) {
	CleanUp(S);
	sprintf(msg, "File has wrong sample rate (%ld Hz)", SAMPLE_RATE);
	THROW_ERROR(S, msg)
    }

    /* Find 'data' chunk */
    DATA_CK_INFO->ckid = mmioFOURCC('d', 'a', 't', 'a'); 
    mmResult = mmioDescend(FILE_DESC, DATA_CK_INFO, WAVE_CK_INFO, MMIO_FINDCHUNK);
    if (MMERROR) {
	CleanUp(S);
	THROW_ERROR(S, "Error reading file header")
    }

    ssSetIWorkValue(S, kIN_DATA_CHUNK, 1);
    ssSetIWorkValue(S, kBYTES_IN_FILE, DATA_CK_INFO->cksize);
}


static void OpenWavFile(SimStruct *S)
{
    /* Check file name */
    if (strlen (FILENAME) > 127) {
	CleanUp(S);
	THROW_ERROR(S, "File name too long")
    }

    if (strchr (FILENAME, '+') != NULL) {
	CleanUp(S);
	THROW_ERROR(S, "File name must not contain a \"+\" character")
    }

    /* Open file */
    {
	HMMIO fp = mmioOpen(FILENAME, NULL, MMIO_READ | MMIO_ALLOCBUF);
	if (fp == NULL) {
	    CleanUp(S);
	    THROW_ERROR(S, "Error opening file");
	}
	ssSetPWorkValue (S, kFILE_DESC, fp);
    }
    
    /* Read header */
    ReadWavHeader(S); RETURN_IF_ERROR;

    /* Set internal buffer size 
     *
     * Note: for faster access, supply a custom I/O buffer 
     *       and access with mmioAdvance()
     */
    {
	MMRESULT  mmResult = mmioSetBuffer(FILE_DESC, NULL, BUFSIZE, 0);
	if (MMERROR) {
	    CleanUp(S);
	    THROW_ERROR(S, "Error opening file")
	}
    }
}


static void InitPointers(SimStruct *S)
{
    ssSetPWorkValue(S, kSAMPLE_BUF,   NULL);
    ssSetPWorkValue(S, kFILE_DESC,    NULL);
    ssSetPWorkValue(S, kFILENAME,     NULL);
    ssSetPWorkValue(S, kDATA_CK_INFO, NULL);
    ssSetPWorkValue(S, kWAVE_CK_INFO, NULL);

    ssSetIWorkValue(S, kIN_WAVE_CHUNK, 0);
    ssSetIWorkValue(S, kIN_DATA_CHUNK, 0);
}


/* Function: MakeBuffer =======================================================
 * Abstract:
 *		Allocate file name, and FILE
 * Can fail.
 */
static void MakeBuffer(SimStruct *S)
{
    char *filename;
    long  filename_len;
    
    /* Allocate file name */
    filename_len = 1 + mxGetNumberOfElements(FILENAME_MX);
    filename = (char *)calloc(filename_len, sizeof(char));
    if (filename == NULL) {
	CleanUp(S);
	THROW_ERROR(S, "Error allocating memory")
    }
    ssSetPWorkValue (S, kFILENAME, filename);

    /* Initialize filename */
    if (mxGetString(FILENAME_MX, filename, filename_len)) {
	CleanUp(S);
	THROW_ERROR(S, "File name must be a string")
    }
    
    {
	MMCKINFO *dataCkInfo, *waveCkInfo;

	/* Allocate data chunk info */
	dataCkInfo = (MMCKINFO *)calloc(1, sizeof (MMCKINFO));
	if (dataCkInfo == NULL) {
	    CleanUp(S);
	    THROW_ERROR(S, "Error allocating memory")
	}
	ssSetPWorkValue (S, kDATA_CK_INFO, dataCkInfo);

	/* Allocate wave chunk info */
	waveCkInfo = (MMCKINFO *)calloc(1, sizeof (MMCKINFO));
	if (waveCkInfo == NULL) {
	    CleanUp (S);
	    THROW_ERROR(S, "Error allocating memory")
	}
	ssSetPWorkValue (S, kWAVE_CK_INFO, waveCkInfo);
    }
}


/* Function: MakeSampleBuffer =======================================================
 * Abstract:
 *		Allocate sample buffer
 * Can fail.
 */
static void MakeSampleBuffer (SimStruct *S)
{
    /* Allocate sample buffer */
    char *sample_buf = (char *)calloc(BUFSIZE, 1);
    if (sample_buf == NULL) {
	CleanUp(S);
	THROW_ERROR(S, "Error allocating memory")
    }
    ssSetPWorkValue (S, kSAMPLE_BUF, sample_buf);
}


# if defined(MATLAB_MEX_FILE)
# define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if (mxGetNumberOfElements(ssGetSFcnParam(S,kSAMPLE_RATE_ARG)) != 1)
        THROW_ERROR(S, "Sample Frequency must be a scalar");
    if (mxGetNumberOfElements(ssGetSFcnParam(S,kBUFFER_SIZE)) != 1)
        THROW_ERROR(S, "Buffer size must be a scalar");
    if (mxGetNumberOfElements(ssGetSFcnParam(S,kNUM_CHANNELS_ARG)) != 1)
        THROW_ERROR(S, "Number of channels must be a scalar");
    if (!mxIsChar(ssGetSFcnParam(S,kFILENAME_MX)))
        THROW_ERROR(S, "File Name must be a string");

    switch (NUM_CHANNELS_ARG) {
    case 1:
    case 2:
        break;
    default:
        THROW_ERROR(S, "Number of channels must be 1 or 2");
    }
}
# endif


static void mdlInitializeSizes(SimStruct *S)
{	
    ssSetNumSFcnParams(S, kNUM_PARAMETERS);  /* Number of expected parameters */

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    RETURN_IF_ERROR;
#endif

    if (!ssSetNumInputPorts( S, 0)) return;

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, BUFFER_SIZE * NUM_CHANNELS_ARG);

    ssSetNumSampleTimes(S, 1);
    ssSetNumIWork(      S, kNUMIWORKITEMS);
    ssSetNumPWork(      S, kNUMPWORKITEMS);
    ssSetOptions(       S, 0);	/* SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE */
}


static void mdlInitializeSampleTimes (SimStruct *S)
{
    ssSetSampleTime (S, 0, (double) BUFFER_SIZE / SAMPLE_RATE_ARG);
    ssSetOffsetTime (S, 0, 0.0);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
    InitPointers(S);

    /* Initialize filename & waveheader */
    MakeBuffer(S); RETURN_IF_ERROR;

    /* Open file  & read header */
    OpenWavFile(S); RETURN_IF_ERROR;
    MakeSampleBuffer(S); RETURN_IF_ERROR;
}

static void mdlOutputs (SimStruct *S, int_T tid)
{

    /* Convert input to integer samples */
    int_T    numChannels = NUM_CHANNELS;
    int_T    numSamples  = BUFFER_SIZE;
    char_T  *sampleBuf   = SAMPLE_BUF;
    real_T  *y           = ssGetOutputPortSignal (S, 0);

    /* Read next buffer of samples from file: */
    {
        int_T  nRead   = 0;
        const int_T  dataCnt =  BYTES_IN_FILE;

        if (dataCnt > 0) {
            /* Read integer samples from file */

            nRead = mmioRead(FILE_DESC, sampleBuf, MIN(dataCnt, BUFSIZE));
            if (nRead == -1) {
	        CleanUp (S);
	        THROW_ERROR(S, "Error reading file");

            }
            /* Update sample counter */
            ssSetIWorkValue(S, kBYTES_IN_FILE, dataCnt - nRead);
        }

        if (nRead < BUFSIZE) {
            /*
             * If file is exhausted, append zeros, and record last value
            * (used to prevent glitching)
            */
            unsigned char zero = (BITS_PER_SAMPLE == 8) ? 128 : 0;
            memset(sampleBuf + nRead, zero, BUFSIZE - nRead);
        }
    }

    /*
     * Output samples from buffer:
     */
    switch (BITS_PER_SAMPLE) {
	case 8:
            {
                unsigned char *buf = (unsigned char *)sampleBuf;
                int_T i;
                for (i=0; i < numSamples; i++) {
                    int_T channel;
                    for (channel=0; channel < numChannels; channel++) {
		        y[numSamples * channel + i] = (*buf++ - 128.0) / 128.0;
                    }
                }
            }
	    break;

	case 16:
            {
                short *buf = (short *)sampleBuf;
                int_T i;
                for (i=0; i < numSamples; i++) {
                    int_T channel;
                    for (channel=0; channel < numChannels; channel++) {
		        y[numSamples * channel + i] = *buf++ / 32768.0;
                    }
                }
            }
	    break;
    }
}


static void mdlTerminate (SimStruct *S)
{
    MMRESULT mmResult;

    /* Exit data chunk */
    if (IN_DATA_CHUNK && (DATA_CK_INFO != NULL) && (FILE_DESC != NULL)) {
	mmResult = mmioAscend (FILE_DESC, DATA_CK_INFO, 0);
	if (MMERROR) {
	    CleanUp (S);
	    THROW_ERROR(S, "Error exiting data chunk")
	}
	ssSetIWorkValue (S, kIN_DATA_CHUNK, 0);
    }

    /* Exit WAVE chunk */
    if (IN_WAVE_CHUNK && (WAVE_CK_INFO != NULL) && (FILE_DESC != NULL)) {
	mmResult = mmioAscend (FILE_DESC, WAVE_CK_INFO, 0);
	if (MMERROR) {
	    CleanUp (S);
	    THROW_ERROR(S, "Error exiting wave chunk")
	}
	ssSetIWorkValue (S, kIN_WAVE_CHUNK, 0);
    }

    CleanUp (S);
}


#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] dsp_wafi_win32.c */
