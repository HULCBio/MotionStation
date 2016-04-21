// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:33:58 $
#include <adaptorkit.h>

#ifndef _UTIL_H
#define _UTIL_H

int GlobalAdaptorInfo(IPropContainer *, UINT);
//
// The WAVEHDR structure defines the header used to identify a waveform-audio buffer.
// WaveHeader is simply a wrapper class created for convenience
//
class WaveHeader: public WAVEHDR
{
public:
    WaveHeader()
    {
        lpData = 0;
        dwBufferLength = 0;
        dwFlags = 0;
        dwLoops = 0;
        dwBytesRecorded=0;
        dwUser=0;

    }
    bool IsDone () const { 
			    // Checks to see if the header flag is marked done
			    return dwFlags & WHDR_DONE; 
			  }
};

class CWaveFormat : public WAVEFORMATEX
{
public:
    CWaveFormat ( 
        WORD    nCh, // number of channels (mono, stereo)
        DWORD   nSampleRate, // sample rate
        WORD    BitsPerSample)
    {
        wFormatTag = WAVE_FORMAT_PCM;
        nChannels = nCh;
        nSamplesPerSec = nSampleRate;
        nBlockAlign = (nChannels * BitsPerSample+7)/8; //round up
        nAvgBytesPerSec = nSampleRate * nBlockAlign;

        wBitsPerSample = BitsPerSample;
        cbSize = 0;
    }   
    
    void SetRate(DWORD NewRate)
    {
        nSamplesPerSec = NewRate;
        nAvgBytesPerSec = nSamplesPerSec * nBlockAlign;
    }
    void SetBits(WORD BitsPerSample)
    {
        wBitsPerSample = BitsPerSample;
        nBlockAlign = (nChannels * BitsPerSample+7)/8; //round up
        nAvgBytesPerSec = nSamplesPerSec * nBlockAlign;
    }
    void SetChannels(WORD    nCh)
    {
        nChannels = nCh;
        nBlockAlign = (nChannels * wBitsPerSample+7)/8; //round up
        nAvgBytesPerSec = nSamplesPerSec * nBlockAlign;
    }
    long Bytes2Points(long bytes)
    {
        return bytes*nChannels/nBlockAlign;
    }
    long Points2Bytes(long points)
    {
        return points/nChannels*nBlockAlign;
    }

    // Is this format supported?
};

class ATL_NO_VTABLE CSoundDevice :public CmwDevice
{
public:
    enum {DEFAULT_SAMPLE_RATE=8000}; 
    CSoundDevice(): WaveFormat(1,DEFAULT_SAMPLE_RATE,16),_nChannels(0)
    {} // format is set to one channel to be legal

    STDMETHOD(ChildChange)(DWORD,  NESTABLEPROP *);
    STDMETHOD(AllocBufferData)(BUFFER_ST*);
    CWaveFormat WaveFormat;
    static long SnapSampleRates(double newvalue);
    HRESULT SetSampleRateRange(long min,long max);
    static WaveHeader* GetBufferHeader(BUFFER_ST* pBuf) {return (WaveHeader*) (pBuf->dwAdaptorData);}
    int _nChannels;
    TCachedProp<long>  _cSamplesPerSec;

};


#endif //_UTIL_H