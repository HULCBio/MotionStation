/*
 * DSP_WAFO_WIN32: DSP Blockset S-function implementing
 *                 wave audio file input
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
 * $Revision: 1.4 $ $Date: 2002/04/14 20:43:22 $
 */

#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>

#include "dsp_sim.h"

/* Simulink block parameters */
enum {
    kFILENAME_MX,
    kBITS_PER_SAMPLE,	/* 8 or 16		*/
    kNUM_CHANNELS,	/* 1 = mono, 2 = stereo	*/
    kNUM_PARAMETERS
};

#define FILENAME_MX		((mxArray*)             (ssGetSFcnParam(S, kFILENAME_MX)))
#define BITS_PER_SAMPLE		((unsigned short)(*mxGetPr(ssGetSFcnParam(S, kBITS_PER_SAMPLE))))
#define NUM_CHANNELS		((unsigned short)(*mxGetPr(ssGetSFcnParam(S, kNUM_CHANNELS))))

enum {
	kIN_WAVE_CHUNK,			/* Boolean -- in wave chunk			*/
	kIN_DATA_CHUNK,			/* Boolean -- in data chunk			*/
	kNUMIWORKITEMS
};

#define IN_WAVE_CHUNK	(ssGetIWorkValue(S, kIN_WAVE_CHUNK))
#define IN_DATA_CHUNK	(ssGetIWorkValue(S, kIN_DATA_CHUNK))

enum {
	kSAMPLE_BUF,			/* Work space for integer samples	*/
	kFILE_DESC,			/* File descriptor			*/
	kFILENAME,			/* C-string file name			*/
	kDATA_CK_INFO,			/* Data chunk info record		*/
	kWAVE_CK_INFO,			/* Wave chunk info record		*/
	kNUMPWORKITEMS
};

#define SAMPLE_BUF		((char *)    (ssGetPWorkValue(S, kSAMPLE_BUF)))
#define FILE_DESC		((HMMIO)     (ssGetPWorkValue(S, kFILE_DESC)))
#define FILENAME		((char *)    (ssGetPWorkValue(S, kFILENAME)))
#define DATA_CK_INFO		((MMCKINFO *)(ssGetPWorkValue(S, kDATA_CK_INFO)))
#define WAVE_CK_INFO		((MMCKINFO *)(ssGetPWorkValue(S, kWAVE_CK_INFO)))

#define NUM_INPUTS		(ssGetInputPortWidth(S, 0))
#define NUM_SAMPLES		(NUM_INPUTS / NUM_CHANNELS)
#define BYTES_PER_SAMPLE	(BITS_PER_SAMPLE  / 8)
#define BUFSIZE			(NUM_INPUTS * BYTES_PER_SAMPLE)
#define SAMPLE_RATE		(NUM_SAMPLES / ssGetSampleTime(S,0))

#define RETURN_IF_ERROR		if (ssGetErrorStatus(S) != NULL) return;
#define MMERROR			(mmResult != MMSYSERR_NOERROR)


static void CloseFile (SimStruct *S)
{
    if (FILE_DESC != NULL) {
        mmioClose(FILE_DESC, 0);
    }
    ssSetPWorkValue(S, kFILE_DESC, NULL);
    ssSetIWorkValue(S, kIN_WAVE_CHUNK, 0);
    ssSetIWorkValue(S, kIN_DATA_CHUNK, 0);
}


static void FreeBuffer(SimStruct *S)
{
    {
	char *sample_buf = SAMPLE_BUF;
        if (sample_buf != NULL) {
            free(sample_buf);
        }
	ssSetPWorkValue(S, kSAMPLE_BUF,  NULL);
    }
    {
        char *filename = FILENAME;
        if (filename != NULL) {
            free(filename);
        }
        ssSetPWorkValue(S, kFILENAME,    NULL);
    }
    {
	MMCKINFO *dataCkInfo = DATA_CK_INFO;
	if (dataCkInfo != NULL) free (dataCkInfo);
	ssSetPWorkValue(S, kDATA_CK_INFO, NULL);
	ssSetIWorkValue(S, kIN_DATA_CHUNK, 0);
    }
    {
	MMCKINFO *waveCkInfo = WAVE_CK_INFO;
	if (waveCkInfo != NULL) free (waveCkInfo);
	ssSetPWorkValue(S, kWAVE_CK_INFO, NULL);
	ssSetIWorkValue(S, kIN_WAVE_CHUNK, 0);
    }
}


static void CleanUp(SimStruct *S)
{
    CloseFile(S);
    FreeBuffer(S);
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


static void MakeBuffer(SimStruct *S)
{
    char *filename;
    long filename_len;

    /* Allocate sample buffer */
    char *sample_buf = (char *)calloc(BUFSIZE, sizeof(char));
    if (sample_buf == NULL) {
	CleanUp(S);
	THROW_ERROR(S, "Error allocating memory")
    }
    ssSetPWorkValue(S, kSAMPLE_BUF, sample_buf);


    /* Allocate file name */
    filename_len = mxGetNumberOfElements(FILENAME_MX) + 1;
    filename = (char *)calloc(filename_len, 1);
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
    
    /* Allocate data chunk info */
    {
	MMCKINFO *dataCkInfo = (MMCKINFO *)calloc(1, sizeof (MMCKINFO));
	if (dataCkInfo == NULL) {
	    CleanUp(S);
	    THROW_ERROR(S, "Error allocating memory")
	}
	ssSetPWorkValue(S, kDATA_CK_INFO, dataCkInfo);
    }

    /* Allocate wave chunk info */
    {
	MMCKINFO *waveCkInfo = (MMCKINFO *)calloc(1, sizeof (MMCKINFO));
	if (waveCkInfo == NULL) {
	    CleanUp(S);
	    THROW_ERROR(S, "Error allocating memory")
	}
	ssSetPWorkValue (S, kWAVE_CK_INFO, waveCkInfo);
    }
}


static void MakePCMWaveFormat(SimStruct *S, LPPCMWAVEFORMAT lpwf)
{
    lpwf->wf.wFormatTag		= WAVE_FORMAT_PCM;
    lpwf->wf.nChannels		= (short)NUM_CHANNELS;
    lpwf->wf.nSamplesPerSec	= (long)floor(0.5 + SAMPLE_RATE);
    lpwf->wBitsPerSample	= BITS_PER_SAMPLE;
    lpwf->wf.nBlockAlign	= lpwf->wf.nChannels * (lpwf->wBitsPerSample / 8);
    lpwf->wf.nAvgBytesPerSec	= lpwf->wf.nSamplesPerSec * lpwf->wf.nBlockAlign;
}


static void WriteWavHeader(SimStruct *S)
{
    MMRESULT		mmResult;
    MMCKINFO		mmFMTCkInfo;
    PCMWAVEFORMAT	pcmWaveFormat;
    long		m;

    const long length     = 0;  /* This will be corrected when ascending from the chunk */
    long       dataLength = length * NUM_CHANNELS * sizeof (short);

    /* Create 'WAVE' chunk */
    WAVE_CK_INFO->fccType = mmioFOURCC('W', 'A', 'V', 'E'); 
    /* 'WAVE' + 'fmt ' + size + 'data' + size = 20 */
    WAVE_CK_INFO->cksize = 20 + sizeof (PCMWAVEFORMAT) + dataLength; 
    mmResult = mmioCreateChunk(FILE_DESC, WAVE_CK_INFO, MMIO_CREATERIFF);
    if (MMERROR) {
	CleanUp(S);
	THROW_ERROR(S, "Error writing file header")
    }
    ssSetIWorkValue(S, kIN_WAVE_CHUNK, 1);

    /* Create 'fmt ' chunk */
    mmFMTCkInfo.ckid = mmioFOURCC('f', 'm', 't', ' '); 
    mmFMTCkInfo.cksize = sizeof(PCMWAVEFORMAT); 
    mmResult = mmioCreateChunk(FILE_DESC, &mmFMTCkInfo, 0);
    if (MMERROR) {
	CleanUp(S);
	THROW_ERROR(S, "Error writing file header")
    }
    MakePCMWaveFormat(S, &pcmWaveFormat);

    /* Write format chunk */
    m = mmioWrite (FILE_DESC, (char*) &pcmWaveFormat, sizeof (PCMWAVEFORMAT));
    if (m != sizeof(PCMWAVEFORMAT)) {
	CleanUp(S);
	THROW_ERROR(S, "Error writing file header")
    }

    /* End format chunk */
    mmResult = mmioAscend (FILE_DESC, &mmFMTCkInfo, 0);
    if (MMERROR) {
	CleanUp(S);
	THROW_ERROR(S, "Error writing file header")
    }

    /* Create 'data' chunk */
    DATA_CK_INFO->ckid = mmioFOURCC('d', 'a', 't', 'a'); 
    DATA_CK_INFO->cksize = dataLength; 
    mmResult = mmioCreateChunk(FILE_DESC, DATA_CK_INFO, 0);
    if (MMERROR) {
	CleanUp(S);
	THROW_ERROR(S, "Error writing file header")
    }

    ssSetIWorkValue(S, kIN_DATA_CHUNK, 1);
}


static void OpenWavFile (SimStruct *S)
{
    HMMIO	fp;
    MMRESULT	mmResult;

    /* Check file name */
    if (strlen(FILENAME) > 127) {
	CleanUp(S);
	THROW_ERROR(S, "File name too long")
    }

    if (strchr (FILENAME, '+') != NULL) {
	CleanUp(S);
	THROW_ERROR(S, "File name must not contain a \"+\" character")
    }

    fp = mmioOpen(FILENAME, NULL, MMIO_WRITE | MMIO_CREATE | MMIO_ALLOCBUF);
    if (fp == NULL) {
	CleanUp(S);
	THROW_ERROR(S, "Error opening file");
    }
    ssSetPWorkValue(S, kFILE_DESC, fp);

    /* Set internal buffer size 
     *
     * Note -- for faster access, supply a custom I/O buffer 
     * and access with mmioAdvance () */
    mmResult = mmioSetBuffer (FILE_DESC, NULL, BUFSIZE, 0);
    if (MMERROR) {
	CleanUp (S);
	THROW_ERROR(S, "Error opening file")
    }
}


# if defined(MATLAB_MEX_FILE)
# define MDL_CHECK_PARAMETERS
static void mdlCheckParameters (SimStruct *S)
{
    if (mxGetNumberOfElements(ssGetSFcnParam(S,kNUM_CHANNELS)) != 1)
	    THROW_ERROR(S, "Number of channels must be a scalar");
    if (mxGetNumberOfElements(ssGetSFcnParam(S,kBITS_PER_SAMPLE)) != 1)
	    THROW_ERROR(S, "Sample Width must be a scalar");
    if (!mxIsChar(ssGetSFcnParam(S,kFILENAME_MX)))
	    THROW_ERROR(S, "File Name must be a string");

    switch (NUM_CHANNELS) {
	case 1:
	case 2:
	    break;
	default:
	    THROW_ERROR(S, "Number of channels must be 1 or 2");
    }

    switch (BITS_PER_SAMPLE) {
	case 8:
	case 16:
	    break;
	default:
	    THROW_ERROR(S, "Number of bits per sample must be 8 or 16");
    }
}
# endif


static void mdlInitializeSizes (SimStruct *S)
{	
    ssSetNumSFcnParams(S, kNUM_PARAMETERS);  /* Number of expected parameters */

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))  return;
    mdlCheckParameters(S);
    RETURN_IF_ERROR;
#endif

    if (!ssSetNumOutputPorts(S, 0)) return;

    if (!ssSetNumInputPorts(        S, 1)) return;
    ssSetInputPortWidth(            S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumIWork(      S, kNUMIWORKITEMS);
    ssSetNumPWork(      S, kNUMPWORKITEMS);
    ssSetOptions(       S, 0);	/* SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE */
}


static void mdlInitializeSampleTimes (SimStruct *S)
{
    ssSetSampleTime (S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime (S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
    InitPointers(S);

    /* Allocate buffers, initialize filename & waveheader */
    MakeBuffer(S); RETURN_IF_ERROR;

    /* Open file */
    OpenWavFile(S); RETURN_IF_ERROR;

    /* Write file header */
    WriteWavHeader(S); RETURN_IF_ERROR;
}


static void mdlOutputs (SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S, 0);

    /* Convert input to integer samples */
    const long  numChannels = NUM_CHANNELS;
    const long  numSamples  = NUM_SAMPLES;
    char *sample_buf  = SAMPLE_BUF;

    switch (BITS_PER_SAMPLE) {
	case 8:
            {
                unsigned char *buf = (unsigned char *)sample_buf;
		int_T i;
		for (i=0; i < numSamples; i++) {
		    int_T channel;
		    for (channel=0; channel < numChannels; channel++) {
			    buf[channel + i * numChannels] = 
				    (unsigned char)MAX(0, MIN(255,
					floor(*uPtrs[numSamples * channel + i] * 128 + 128)));
		    }
		}
            }
	    break;

	case 16:
             {
                short *buf = (short *)sample_buf;
		int_T channel;
                for (channel=0; channel < numChannels; channel++) {
		    int_T i;
                    for (i=0; i < numSamples; i++) {
#if 0
			buf[channel + i * numChannels] = 
			    (short)MAX(-32768, MIN(32767, floor(*uPtrs[numSamples * channel + i] * 32768)));
#else
			real_T u = floor(**(uPtrs++) * 32768);
			buf[channel + i * numChannels] = 
			    (short)MAX(-32768, MIN(32767, u));
#endif
                    }
                }
             }
             break;
    }

    /* Write integer samples to file */
    if (mmioWrite(FILE_DESC, sample_buf, BUFSIZE) != BUFSIZE) {
	CleanUp(S);
	THROW_ERROR(S,"Error writing file");
    }
}


static void mdlTerminate (SimStruct *S)
{
    MMRESULT mmResult;

    /* End data chunk */
    if (IN_DATA_CHUNK && DATA_CK_INFO != NULL && FILE_DESC != NULL) {
	mmResult = mmioAscend (FILE_DESC, DATA_CK_INFO, 0);
	if (MMERROR) {
	    CleanUp(S);
	    THROW_ERROR(S, "Error writing file")
	}
	ssSetIWorkValue(S, kIN_DATA_CHUNK, 0);
    }

    /* End WAVE chunk */
    if (IN_WAVE_CHUNK && WAVE_CK_INFO != NULL && FILE_DESC != NULL) {
	mmResult = mmioAscend (FILE_DESC, WAVE_CK_INFO, 0);
	if (MMERROR) {
	    CleanUp(S);
	    THROW_ERROR(S, "Error writing file")
	}
	ssSetIWorkValue(S, kIN_WAVE_CHUNK, 0);
    }

    CleanUp(S);
}


#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] dsp_wafo_win32.c */
