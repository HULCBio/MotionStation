/* 
 * playsnd_nt.c - audio driver for PC platform (asynchronous/non-blocking only)
 *
 * $Revision: 1.1.6.1 $ $Date: 2003/07/11 15:54:00 $
 * Copyright 1984-2002 The MathWorks, Inc.
 */

#include <windows.h>
#include <mmsystem.h>
#include <math.h>
#include "mex.h"

#define ALLOC_ERROR_MSG   "Unable to allocate memory."
#define LOCK_ERROR_MSG    "Unable to lock memory.";
#define DEFAULT_ERROR_MSG "Invalid sndMemError code";

typedef enum {ALLOC_ERROR, LOCK_ERROR} sndMemErrorCode;
 
/*  NUM_MEMHANDLES:
 *  Number of entries in the memHandles structure. There will
 *  be two entries per buffer, to indicate if a GlobalLock was 
 *  successful.
 */
#define NUM_MEMHANDLES 4

void * memHandles[NUM_MEMHANDLES];

int mem_handle_count;

#define NUM_WAV_FORMATS 3

#define WMAIN_DX        207
#define WMAIN_DY        120

enum {X_ARGC=0, FS_ARGC, BITS_ARGC, NUM_INPUTS};
#define X_ARG      prhs[X_ARGC]
#define FS_ARG     prhs[FS_ARGC]
#define BITS_ARG   prhs[BITS_ARGC]


typedef struct SOUNDDATA_TAG {
  unsigned int sFreq;             // Sampling freq for data
  unsigned short nChannels;       // Number of channels
  unsigned int numSamples;        // Number of samples in data
  unsigned short nBits;           // num bits requested by used
  double *mChannelData;           // if mono, data is here
  double *lChannelData;           // If stereo, left channel data
  double *rChannelData;           // If stereo, right channel data
} SOUNDDATA;


/*
 * Global variables.
 */
char        szAppName[] = "tsound";     // application name
HANDLE      hInstApp    = NULL;         // instance handle
HANDLE      hInst       = NULL;         // instance handle
HWND        hwndApp     = NULL;         // main window handle
HWND        hwndName    = NULL;         // filename window handle
HWND        hwndPlay    = NULL;         // "Play" button window handle
HWND        hwndQuit    = NULL;         // "Exit" button window handle
HWAVEOUT    hWaveOut    = NULL;
LPWAVEHDR   pWaveOutHdr = NULL;
BOOL        bClassRegistered = FALSE;
DWORD       dwFormat;
WAVEOUTCAPS wcCaps;       /* hardware capabilities */


/*
 * Function: ValidateInputs
 * Abstract:
 *      
 */
void ValidateInputs(
   int            nlhs,
   mxArray       *plhs[],
   int            nrhs,
   const mxArray *prhs[]
   )
{
  int tmpNRows, tmpNCols, i;
  int numBits;
  double freq;


  if(nrhs != 3)
    mexErrMsgTxt("Wrong number of input arguments to playsnd\n");
  
  // Make sure Fs is a scalar
  tmpNRows = mxGetM(prhs[1]); tmpNCols = mxGetN(prhs[1]);
  if((tmpNRows != 1)||(tmpNCols != 1))
    mexErrMsgTxt("Frequency must be a scalar\n");


    if ((mxGetNumberOfElements(FS_ARG) != 1) ||
         mxIsComplex(FS_ARG) || mxIsSparse(FS_ARG) || !mxIsDouble(FS_ARG)) {
        mexErrMsgTxt("Sample rate must be a real, double-precision scalar.");
    }

    if (mxIsComplex(X_ARG) || mxIsSparse(X_ARG) || !mxIsDouble(X_ARG)) {
        mexErrMsgTxt("Audio data must be real and double-precision.");
    }


  // Make sure numBits is a scalar
  tmpNRows = mxGetM(prhs[2]); tmpNCols = mxGetN(prhs[2]);
  if((tmpNRows != 1)||(tmpNCols != 1))
    mexErrMsgTxt("The Number of bits  must be a scalar.\n");

  // Make sure data is a 1 or 2 column array.
  tmpNCols = mxGetN(prhs[0]);
  if((tmpNCols != 1) && (tmpNCols != 2))
    mexErrMsgTxt("Data must have one or two columns.\n");

  // Make sure all arguments are real
  for(i=0; i<3; i++)
    {
      if(mxIsComplex(prhs[i]))
        mexErrMsgTxt("All arguments must be real.\n");
    }

  numBits = (int)mxGetScalar(prhs[2]);
  //  numBits = (int)*mxGetPr(prhs[2]);
  if((numBits < 2) || (numBits > 16))
    mexErrMsgTxt("Number of bits must be between 2 and 16.\n");

  freq = mxGetScalar(prhs[1]);
  if(freq < 1)
    mexErrMsgTxt("Playback frequency must be greater or equal to 1.\n");
}


void setSndInputData(SOUNDDATA *sndData, const mxArray *prhs[])
{
  sndData->sFreq = (unsigned int)mxGetScalar(prhs[1]);
  //  sndData->sFreq = (unsigned int)*mxGetPr(prhs[1]);
  sndData->nBits = (unsigned short)mxGetScalar(prhs[2]);
  //  sndData->nBits = (unsigned short)*mxGetPr(prhs[2]);
  sndData->nChannels = (unsigned short)mxGetN(prhs[0]);
  sndData->numSamples = (unsigned int)mxGetM(prhs[0]);

  if(sndData->nChannels == 1)
    {
      sndData->mChannelData = mxGetPr(prhs[0]);
      sndData->lChannelData = NULL;
      sndData->rChannelData = NULL;
    }
  else
    {
      sndData->mChannelData = NULL;
      sndData->lChannelData = mxGetPr(prhs[0]);
      sndData->rChannelData = sndData->lChannelData + 
        sndData->numSamples;
    }
}

void setSndPlayData(SOUNDDATA *pSndPlayData,
		    SOUNDDATA sndInputData,
		    unsigned int nChannelsUsed,
		    unsigned nAvailBits)
{
  pSndPlayData->sFreq = sndInputData.sFreq;
  pSndPlayData->nChannels = nChannelsUsed;
  pSndPlayData->numSamples = sndInputData.numSamples;
  pSndPlayData->nBits = min(sndInputData.nBits, nAvailBits);
  pSndPlayData->mChannelData = sndInputData.mChannelData;
  pSndPlayData->lChannelData = sndInputData.lChannelData;

  // If nChannels == 1, and rChannelData != NULL, this means
  // that we need to combine both channels into one (stereo
  // requested, but not supported
  pSndPlayData->rChannelData = sndInputData.rChannelData;
}

  

/*
 * Given the number of channels, we need to find the best format
 * in terms of sampling frequency and quantization level.
 */
DWORD getBestFormat(int nChannels, int *nBits)
{
  int i;

  DWORD dwMonoFormats16[NUM_WAV_FORMATS] = {
    WAVE_FORMAT_4M16,
    WAVE_FORMAT_2M16,
    WAVE_FORMAT_1M16
  };

  DWORD dwMonoFormats8[NUM_WAV_FORMATS] = {
    WAVE_FORMAT_4M08,
    WAVE_FORMAT_2M08,
    WAVE_FORMAT_1M08
  };

  DWORD dwStereoFormats16[NUM_WAV_FORMATS] = {
    WAVE_FORMAT_4S16,
    WAVE_FORMAT_2S16,
    WAVE_FORMAT_1S16
  };

  DWORD dwStereoFormats8[NUM_WAV_FORMATS] = {
    WAVE_FORMAT_4S08,
    WAVE_FORMAT_2S08,
    WAVE_FORMAT_1S08
  };
  
  
  if(nChannels == 1) { // Case mono sound
    for(i=0; i<NUM_WAV_FORMATS; i++) {
      if(wcCaps.dwFormats & dwMonoFormats16[i]) {
	*nBits = 16;
	return(dwMonoFormats16[i]);
      }
      else if(wcCaps.dwFormats & dwMonoFormats8[i]) {
	*nBits = 8;
	return(dwMonoFormats8[i]);
      }
    }
  }
  else if(nChannels == 2) { // Case stereo
    for(i=0; i<NUM_WAV_FORMATS; i++) {
      if(wcCaps.dwFormats & dwStereoFormats16[i]) {
	*nBits = 16;
	return(dwStereoFormats16[i]);
      }
      else if(wcCaps.dwFormats & dwStereoFormats8[i]) {
	*nBits = 8;
	return(dwStereoFormats8[i]);
      }
    }
  }
  else {
    mexErrMsgTxt("Invalid number of channels in GetBestFormat\n");
  }

  return(-1);
}


void setPcmWaveFormat(PCMWAVEFORMAT *pcmWaveFormat, 
		      SOUNDDATA sndPlayData,
		      int nAvailBits)
{
  pcmWaveFormat->wf.wFormatTag = WAVE_FORMAT_PCM;
  pcmWaveFormat->wf.nChannels = sndPlayData.nChannels;
  pcmWaveFormat->wf.nSamplesPerSec = sndPlayData.sFreq;
  pcmWaveFormat->wf.nAvgBytesPerSec = (LONG)(sndPlayData.nChannels * 
					     sndPlayData.sFreq *
					     nAvailBits / 8);
  pcmWaveFormat->wf.nBlockAlign = (unsigned short)(sndPlayData.nChannels * nAvailBits / 8);
  pcmWaveFormat->wBitsPerSample = (unsigned short)nAvailBits;
}



void formatData(
   LPSTR     pcDataBuffer,
   DWORD     dwBestFormat,
   SOUNDDATA sndPlayData
   )
{
  short tmpValue;
  unsigned int i;
  int hwBits, preValue, scalingFactor;
  double quantizingFactor;
  

  // Process the 16-case
  if((dwBestFormat & WAVE_FORMAT_4M16) || 
     (dwBestFormat & WAVE_FORMAT_2M16) ||
     (dwBestFormat & WAVE_FORMAT_1M16)) {
    // We have 16-bit mono data:
    // Need to map the data between -32768 and 32767
    hwBits = 16;
    scalingFactor = (int)(pow(2.0, (double)(hwBits -
                                            sndPlayData.nBits)));

    quantizingFactor = pow(2.0, (double)(sndPlayData.nBits - 1));

    for( i=0; i<sndPlayData.numSamples; i++) 
      {
        // We are doing mono. If there's data in any of the
        // stereo channels, average the two channels to obtain
        // a single one.
        if(sndPlayData.lChannelData)
          preValue =  scalingFactor * (int)(
                                            ((sndPlayData.lChannelData[i] +
                                              sndPlayData.rChannelData[i])/2.)*
                                            quantizingFactor);
        else
          preValue =  scalingFactor * (int)(
                                            sndPlayData.mChannelData[i]*
                                            quantizingFactor);

        tmpValue = (short)min(32767, preValue);
      

        // Don't get confused here! The resulting vector will always be
        // BUFFER_SIZE bytes-long.
        pcDataBuffer[2*i] = LOBYTE(tmpValue); // This fills up the low-byte
        pcDataBuffer[2*i+1]=HIBYTE(tmpValue); // This fills up the high-byte
      }
  }
  // Process the 8-bit case
  else if((dwBestFormat & WAVE_FORMAT_4M08) ||
	  (dwBestFormat & WAVE_FORMAT_2M08) || 
	  (dwBestFormat & WAVE_FORMAT_1M08)) 
    {
      // We have 8-bit mono data
      // Need to map it between 0 and 255
      hwBits = 8;
      scalingFactor = (int)(pow(2.0, (double)(hwBits -
                                              sndPlayData.nBits)));

      quantizingFactor = pow(2.0, (double)(sndPlayData.nBits));

      for(i=0; i<sndPlayData.numSamples; i++) 
        {
          // We are doing mono. If there's data in any of the
          // stereo channels, average the two channels to obtain
          // a single one.
          if(sndPlayData.lChannelData)
            preValue =  scalingFactor * (int)(
                                              ((((sndPlayData.lChannelData[i] + 
                                                  sndPlayData.rChannelData[i])/2.)
                                                +1.)/2.)*quantizingFactor);
          else
            preValue =  scalingFactor * (int)(
                                              ((sndPlayData.mChannelData[i]+1.)/2.)*
                                              quantizingFactor);

          pcDataBuffer[i] = (unsigned char)min(255, preValue);

        }

    }

  // Process the 16-bit stereo case
  else if((dwBestFormat & WAVE_FORMAT_4S16) || 
	  (dwBestFormat & WAVE_FORMAT_2S16) ||
	  (dwBestFormat & WAVE_FORMAT_1S16)) 
    {
      // We have 16-bit stereo data:
      // Need to map the data between -32768 and 32767
      hwBits = 16;
      scalingFactor = (int)(pow(2.0, (double)(hwBits -
                                              sndPlayData.nBits)));

      quantizingFactor = pow(2.0, (double)(sndPlayData.nBits - 1));

      for( i=0; i<sndPlayData.numSamples; i++) 
        {
          // left channel
          preValue = scalingFactor * (int)(
                                           sndPlayData.lChannelData[i]*
                                           quantizingFactor);
          tmpValue = (short)min(32767, preValue);

          pcDataBuffer[4*i] = LOBYTE(tmpValue);
          pcDataBuffer[4*i+1]=HIBYTE(tmpValue);
      
          // right channel
          preValue = scalingFactor * (int)(
                                           sndPlayData.rChannelData[i]*
                                           quantizingFactor);
          tmpValue = (short)min(32767, preValue);

          pcDataBuffer[4*i+2] = LOBYTE(tmpValue);
          pcDataBuffer[4*i+3] = HIBYTE(tmpValue);
        }
    }
  
  // Process the 8-bit stereo case
  else if((dwBestFormat & WAVE_FORMAT_4S08) ||
	  (dwBestFormat & WAVE_FORMAT_2S08) || 
	  (dwBestFormat & WAVE_FORMAT_1S08)) 
    {

      // We have 8-bit stereo data
      // Need to map it between 0 and 255
      hwBits = 8;
      scalingFactor = (int)(pow(2.0, (double)(hwBits -
                                              sndPlayData.nBits)));

      quantizingFactor = pow(2.0, (double)(sndPlayData.nBits));

      for(i=0; i<sndPlayData.numSamples; i++) 
        {

          preValue =  scalingFactor * (int)(
                                            ((sndPlayData.lChannelData[i]+1.)/2.)*
                                            quantizingFactor);
          pcDataBuffer[2*i] = (unsigned char)min(155, preValue);

          preValue =  scalingFactor * (int)(
                                            ((sndPlayData.rChannelData[i]+1.)/2.)*
                                            quantizingFactor);
          pcDataBuffer[2*i+1] = (unsigned char)min(155, preValue);
      
        }
    }
}


#define FORMAT_STRING_SIZE  128
void showSoundCaps(WAVEOUTCAPS caps)
{
  int numFormats = 0, i;
  int numFunctions = 0;
  char *formats[12], *functions[5];


  for(i=0; i<12; i++)
    formats[i] = NULL;

  for(i=0; i<5; i++)
    functions[i] = NULL;

  /* Ok, Now we have the caps. Lets get the specifics. */
  if( caps.dwFormats & WAVE_FORMAT_1M08 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "11.025 KHz, Mono, 8-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_1S08 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "11.025 KHz, Stereo, 8-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_1M16 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "11.025 KHz, Mono, 16-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_1S16 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "11.025 KHz, Stereo, 16-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_2M08 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "22.05 KHz, Mono, 8-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_2S08 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "22.05 KHz, Stereo, 8-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_2M16 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "22.05 KHz, Mono, 16-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_2S16 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "22.05 KHz, Stereo, 16-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_4M08 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "44.1 KHz, Mono, 8-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_4S08 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "44.1KHz, Stereo, 8-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_4M16 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "44.1 KHz, Mono, 16-bit");
    numFormats++;
  }

  if( caps.dwFormats & WAVE_FORMAT_4S16 ) {
    formats[numFormats] = (char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(formats[numFormats], "44.1 KHz, Stereo, 16-bit");
    numFormats++;
  }


  /* Now get the extra functionality supported by the sound hardware */

  if(caps.dwSupport & WAVECAPS_PITCH) {
    functions[numFunctions]=(char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(functions[numFunctions], "Supports pitch control");
    numFunctions++;
  }

  if(caps.dwSupport & WAVECAPS_PLAYBACKRATE) {
    functions[numFunctions]=(char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(functions[numFunctions], "Supports playback rate control");
    numFunctions++;
  }

  if(caps.dwSupport & WAVECAPS_SYNC) {
    functions[numFunctions]=(char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(functions[numFunctions], 
           "Specifies that the driver is synchronous and will block while playing.");
    numFunctions++;
  }

  if(caps.dwSupport & WAVECAPS_VOLUME) {
    functions[numFunctions]=(char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(functions[numFunctions], "Supports volume cntrol");
    numFunctions++;
  }

  if(caps.dwSupport & WAVECAPS_LRVOLUME) {
    functions[numFunctions]=(char *)mxCalloc(FORMAT_STRING_SIZE, sizeof(char));
    strcpy(functions[numFunctions], 
           "Supports separate left and right volume control");
    numFunctions++;
  }

  /* Ok, now time to print these results */

  mexPrintf("\nAUDIO HARDWARE CAPS:\n\n");
  mexPrintf("1. Driver Version:\n");
  mexPrintf("\tMajor version: %d, minor version: %d\n\n", 
            (caps.vDriverVersion & 0xFF00)>> 8,
            caps.vDriverVersion & 0x00FF);
  mexPrintf("2. Product name:\n");
  mexPrintf("\t%s\n\n", caps.szPname);
  mexPrintf("3. Sound formats supported\n");
  for(i=0; i<numFormats; i++)
    mexPrintf("\t3.%d- %s\n", i+1, formats[i]);
  mexPrintf("\n");
  mexPrintf("4. Number of channels: %d\n\n", caps.wChannels);
  mexPrintf("5. Additional Functionality\n");
  for(i=0; i<numFunctions; i++)
    mexPrintf("\t5.%d- %s\n", i+1, functions[i]);
    
  /* Clean up allocated memory */
  for(i=0; i<12; i++)
    {
      if(formats[i])
        mxFree(formats[i]);
    }		

  for(i=0; i<5; i++)
    {
      if(functions[i])
        mxFree(functions[i]);
    }


}



/* *************  END OF UTILITIES ****************** */



/*
  ***************************************************
  **             MEMORY MANAGEMENT                 **
  ***************************************************
*/
/*  These functions allocate the memory needed for playsnd.c.
 *  They keep track of the handles to the memory that's been
 *  allocated and clean up when the file is done playing, or
 *  if something goes wrong while attemting to play a sound.
 *  The correct way of doing this would be to used linked lists,
 *  but since only two buffers will be allocated (the header, and
 *  the data buffer itself), I'll just imnplement them statically.
 */

void sndMemCleanUp(void)
{
  int i;

  for(i=mem_handle_count-1; i>=0; i--) {
      if(memHandles[i])
        {
          /* Even elements have pointers, odd elements have
           * handles.
           */
          if((i % 2))
            GlobalUnlock(memHandles[i]);
          else
            GlobalFree((HGLOBAL)memHandles[i]);
      
          memHandles[i] = NULL;
        }
    }
  mem_handle_count = 0;
}


void sndInitMemHandler(void)
{
  int i;
  
  mem_handle_count = 0;

  for(i=0; i<NUM_MEMHANDLES; i++)
    memHandles[i] = NULL;
}


void sndMemError(const sndMemErrorCode errCode)
{
  char *errMsg;

  sndMemCleanUp();

  switch(errCode) {
    case ALLOC_ERROR:
      errMsg = ALLOC_ERROR_MSG;
      break;
    case LOCK_ERROR:
      errMsg = LOCK_ERROR_MSG;
      break;
    default:
      errMsg = DEFAULT_ERROR_MSG;
      break;
  }

    mexErrMsgTxt(errMsg);
}

void * sndAllocMem(int size, DWORD dwFlags)
{
  HGLOBAL hMem;
  void *pMem;

  if((hMem = GlobalAlloc( dwFlags, size))==NULL)
    sndMemError(ALLOC_ERROR);
  memHandles[mem_handle_count] = (void *)hMem;
  mem_handle_count++;

  if((pMem = (void *)GlobalLock(hMem)) == NULL)
    sndMemError(LOCK_ERROR);
  memHandles[mem_handle_count] = pMem;
  mem_handle_count++;
  
  // initialize the memory to zero
  memset(pMem, '\0', size);

  return(pMem);
}



/* ***************** END OF MEMORY MANAGEMENT *************** */


/* WndProc - Sound window procedure function.
 */
LONG FAR PASCAL WndProc(HWND hWnd, unsigned msg, UINT wParam, LONG lParam)
{
  switch (msg)
    {
    case WM_DESTROY:
      if (hWaveOut)
        {
          waveOutReset(hWaveOut);    
          waveOutUnprepareHeader(hWaveOut, pWaveOutHdr, sizeof(WAVEHDR) );
          waveOutClose(hWaveOut);        
        }
      break;

    case MM_WOM_DONE:
      /* This message indicates a waveform data block has
       * been played and can be freed. Clean up the preparation
       * done previously on the header.
       */
      waveOutUnprepareHeader( (HWAVEOUT) wParam,
                              (LPWAVEHDR) lParam, sizeof(WAVEHDR) );

      sndMemCleanUp();
      /* Close the waveform output device.
       */
      waveOutClose( (HWAVEOUT) wParam );
      break;
    }

  return DefWindowProc(hWnd,msg,wParam,lParam);
}


void PlayData(
   int            nlhs,
   mxArray       *plhs[],
   int            nrhs,
   const mxArray *prhs[]
   )
{
  int nChannelsUsed;        // num of Channels to be used
  int nAvailBits;
  int nBufferSize;
  LPSTR sndFormattedData;   // Pointer to formatted data
  SOUNDDATA sndInputData;   // struct containing the user
  // specified data

  SOUNDDATA  sndPlayData;   // struct containing the data
  // that will be played
  
  

  PCMWAVEFORMAT pcmWaveFormat;
  MMRESULT mmResult;
  
  
  // Set up the sound data structure
  setSndInputData(&sndInputData, prhs);

  // We will use stereo only if it's requested and supported
  if((sndInputData.nChannels == 2)&&(wcCaps.wChannels ==2))
    nChannelsUsed = 2;
  else
    nChannelsUsed = 1;
  
  dwFormat = getBestFormat(nChannelsUsed, &nAvailBits);

  // Set the "playable" data structure
  setSndPlayData(&sndPlayData, 
                 sndInputData,
                 nChannelsUsed, 
                 nAvailBits);

  // Prepare the PCMWaveFormat struct
  setPcmWaveFormat(&pcmWaveFormat, sndPlayData, nAvailBits);

  // Initialize memory handler
  sndInitMemHandler();
  
  //Find the mount of memory needed for the buffer
  nBufferSize = sndPlayData.numSamples *
    sndPlayData.nChannels  *
    nAvailBits / 8;

  // Allocate memory for header
  pWaveOutHdr = (LPWAVEHDR)sndAllocMem(sizeof(WAVEHDR), 
                                       GMEM_MOVEABLE | GMEM_SHARE);
  // Allocate memory for buffer
  sndFormattedData = (LPSTR)sndAllocMem(nBufferSize, 
                                        GMEM_FIXED | GMEM_SHARE);
  
  //Set the header info
  pWaveOutHdr->lpData = sndFormattedData;
  pWaveOutHdr->dwBufferLength = nBufferSize;

  // format the data
  formatData(sndFormattedData, dwFormat, sndPlayData);
  
  // Open device
  mmResult = waveOutOpen((LPHWAVEOUT)&hWaveOut, 
                         WAVE_MAPPER, 
                         (LPWAVEFORMAT)&pcmWaveFormat, 
                         (UINT)hwndApp, 
                         0L,
                         CALLBACK_WINDOW | WAVE_ALLOWSYNC );
  if(mmResult) 
    {
      sndMemCleanUp();
      mexErrMsgTxt("Unable to open sound device.\n");
    }

  // Now we need to prepare the output device
  if((mmResult = waveOutPrepareHeader(hWaveOut, 
                                      pWaveOutHdr, 
                                      sizeof(WAVEHDR)  ))
     != MMSYSERR_NOERROR)
    {
      waveOutClose(hWaveOut);
      sndMemCleanUp();        
      mexErrMsgTxt("Unable to prepare header.\n");
    }


  if((mmResult = waveOutWrite((HWAVEOUT)hWaveOut, 
                              (LPWAVEHDR)pWaveOutHdr, 
                              (UINT)sizeof(WAVEHDR)))
     != MMSYSERR_NOERROR)
    {
      waveOutUnprepareHeader(hWaveOut, 
                             pWaveOutHdr, 
                             sizeof(WAVEHDR));
      waveOutClose(hWaveOut);
      sndMemCleanUp();
      mexErrMsgTxt("Unable to write into sound device\n");
    }

}


void CleanWindow(void)
{
  DestroyWindow(hwndApp);
  UnregisterClass(szAppName, hInst);
}


void mexFunction(
  INT            nlhs,
  mxArray       *plhs[],
  INT            nrhs,
  const mxArray *prhs[]
  )
{

  WNDCLASS    wc;

  // Make sure there's sound hardware:
  if(waveOutGetNumDevs() < 1)
    mexErrMsgTxt("No sound hardware detected.\n");
  
  // Get hardware caps
  waveOutGetDevCaps(WAVE_MAPPER, &wcCaps, sizeof(WAVEOUTCAPS));

    if(nrhs == 0) {
        showSoundCaps(wcCaps);
        return;
    }

  ValidateInputs(nlhs, plhs, nrhs, prhs);

  hInstApp =  (HINSTANCE)GetWindowLong(GetFocus(), GWL_HINSTANCE);
  hInst =  (HINSTANCE)GetWindowLong(GetFocus(), GWL_HINSTANCE);

  /* Define and register a window class for the tsound window.
   */
  wc.hCursor        = LoadCursor(NULL, IDC_ARROW);
  wc.hIcon          = LoadIcon(hInst, szAppName);
  wc.lpszMenuName   = szAppName;
  wc.lpszClassName  = szAppName;
  wc.hbrBackground  = GetStockObject(LTGRAY_BRUSH);
  wc.hInstance      = hInst;
  wc.style          = 0;
  wc.lpfnWndProc    = WndProc;
  wc.cbWndExtra     = 0;
  wc.cbClsExtra     = 0;

  if (!bClassRegistered) {
    if (!RegisterClass(&wc)) {
      MessageBox(hwndApp, "Can't register sound window",
                 NULL, MB_OK | MB_ICONEXCLAMATION);
      return;
    } else
      bClassRegistered = TRUE;
  }

  /* Create and show the main window.
   */
  if (!hwndApp)
    hwndApp = CreateWindow (szAppName,              // class name
			    szAppName,              // caption
			    WS_DISABLED,    // style bits
			    CW_USEDEFAULT,          // x position
			    CW_USEDEFAULT,          // y position
			    WMAIN_DX,               // x size
			    WMAIN_DY,               // y size
			    (HWND)NULL,             // parent window
			    (HMENU)NULL,            // use class menu
			    (HANDLE)hInst,          // instance handle
			    (LPSTR)NULL             // no params to pass on
                            );

  mexAtExit(CleanWindow);

  PlayData(nlhs, plhs, nrhs, prhs);
}

/* [EOF] playsnd_nt.c */
