// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:33:46 $

#if !defined WAVEIN_H
#define WAVEIN_H

#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>
#include "util.h"
//
// WAVEFORMATEX is the structure used by Windows for waveform audio data.
// CWaveInFormat is simply a wrapper class created for convenience.
//
class CWaveInCaps : public WAVEINCAPS
{
public:
    CWaveInCaps () 
    {
    }   
    
    MMRESULT ReadCaps(UINT idDev)
    {
        return waveInGetDevCaps(idDev, this, sizeof(WAVEINCAPS));
    }
    // return the name of the device
    bstr_t GetDeviceName(UINT idDev)
    {
        WAVEINCAPS waveInCaps;
        if (waveInGetDevCaps(idDev, &waveInCaps, sizeof(WAVEINCAPS))==MMSYSERR_NOERROR )
            return bstr_t(waveInCaps.szPname);
        else 
            return bstr_t();
        
    }
    double GetMaxSampleRate(UINT idDev)
    {
        WAVEINCAPS waveInCaps;
        waveInGetDevCaps(idDev, &waveInCaps, sizeof(WAVEINCAPS));
        
	if (waveInCaps.dwFormats & (WAVE_FORMAT_4M16 | WAVE_FORMAT_4S16 | WAVE_FORMAT_4M08 | WAVE_FORMAT_4S08))
            return 44100.0;
	if (waveInCaps.dwFormats & (WAVE_FORMAT_2M16 | WAVE_FORMAT_2S16 | WAVE_FORMAT_2M08 | WAVE_FORMAT_2S08))
            return 22050.0;
	if (waveInCaps.dwFormats & (WAVE_FORMAT_1M16 | WAVE_FORMAT_1S16 | WAVE_FORMAT_1M08 | WAVE_FORMAT_1S08))
            return 11025.0;
        return 0;
    }

    // returns true for 16-bit support
    bool Supports16Bit(UINT idDev)
    {
        WAVEINCAPS waveInCaps;
        waveInGetDevCaps(idDev, &waveInCaps, sizeof(WAVEINCAPS));
        
	if (waveInCaps.dwFormats & (WAVE_FORMAT_4M16 | WAVE_FORMAT_2M16 | WAVE_FORMAT_1M16
                                    | WAVE_FORMAT_4S16 | WAVE_FORMAT_2S16 | WAVE_FORMAT_1S16) )
	{
	    return true;
	}

	return false;
    }

    bool IsStereo(UINT idDev)
    {
        WAVEINCAPS waveInCaps;
        waveInGetDevCaps(idDev, &waveInCaps, sizeof(WAVEINCAPS));
        return waveInCaps.wChannels>=2;
    }

    // return the Windows driver version for DaqHwInfo
    LPWSTR GetDriverVersion(UINT idDev)
    {
	WAVEINCAPS waveInCaps;
        waveInGetDevCaps(idDev, &waveInCaps, sizeof(WAVEINCAPS));

        BYTE majorVer = (waveInCaps.vDriverVersion & 0xFF00) >> 8;
	BYTE minorVer = (waveInCaps.vDriverVersion & 0x00FF);
	
	static wchar_t ver[16];
	swprintf(ver, L"%d.%d", majorVer, minorVer);
	return ver;
    }
    

   
};


// This is the A/D device class 
class WaveInDevice 
{
public:
    WaveInDevice ();
    ~WaveInDevice ();
    bool    Open (UINT idDev, CWaveFormat& format, DWORD dwCallback,DWORD instance,DWORD fdwOpen);
    void    Reset ();
    bool    Close ();
    bool    Prepare (WaveHeader * pHeader);
    bool    UnPrepare (WaveHeader * pHeader);
    bool    SendBuffer (WaveHeader * pHeader);
    bool    Ok () 
    { 
#ifdef _DEBUG
        if (_status!=MMSYSERR_NOERROR)
        {
            TCHAR cs[100];
            GetErrorText(cs,100);
            ATLTRACE("Error from sound card :");
            ATLTRACE(cs);
            ATLTRACE("\n");
        }
#endif
        return _status == MMSYSERR_NOERROR; 
    }
    void    Start () { waveInStart(_handle); }
    void    Stop () { waveInStop(_handle); }
    bool    isInUse () { return _status == MMSYSERR_ALLOCATED; }
    DWORD   GetPosSample ();
    UINT    GetError () { return _status; }
    void    GetErrorText (TCHAR* buf, int len);
private:
    HWAVEIN	_handle;
    MMRESULT	_status;
};


// constructor
inline WaveInDevice::WaveInDevice () :
_handle(NULL),
_status(MMSYSERR_NOERROR)
{

}

// destructor
inline WaveInDevice::~WaveInDevice ()
{
    if (_status == MMSYSERR_NOERROR)
    {
        waveInReset(_handle);
        waveInClose (_handle);
    }
}

// This is called to Open the device
inline bool WaveInDevice::Open (UINT idDev, CWaveFormat& format, DWORD dwCallback,DWORD instance,DWORD fdwOpen)
{
    if (_handle)
        Close();
    _status = waveInOpen (
        &_handle, 
        idDev, 
        &format, 
        dwCallback,
        instance, // callback instance data
        fdwOpen);
    
    return Ok();
}

inline void WaveInDevice::Reset ()
{
    _status = MMSYSERR_NOERROR;
    if (Ok())
        waveInReset (_handle);
}

inline bool WaveInDevice::Close ()
{
    if (  _status == MMSYSERR_NOERROR && waveInClose (_handle) == 0)
    {
        _handle=NULL;
        _status = MMSYSERR_BADDEVICEID;
        return TRUE;
    }
    else
        return FALSE;
}

// Headers must be prepared before sending them to the device
inline bool WaveInDevice::Prepare (WaveHeader * pHeader)
{
    _status = waveInPrepareHeader(_handle, pHeader, sizeof(WAVEHDR));

    return Ok();
}

// this sends the buffer down to the hardware
inline bool WaveInDevice::SendBuffer (WaveHeader * pHeader)
{
    _status =waveInAddBuffer (_handle, pHeader, sizeof(WAVEHDR));
    return Ok();
}

// Headers are unprepared when the buffers have played.
inline bool WaveInDevice::UnPrepare (WaveHeader * pHeader)
{
    if (_handle)
    {
        _status = waveInUnprepareHeader (_handle, pHeader, sizeof(WAVEHDR));

        return Ok();
    }
    else return false;
}

// Get the position of the current sample
inline DWORD WaveInDevice::GetPosSample ()
{
    MMTIME mtime;
    mtime.wType = TIME_SAMPLES;
    waveInGetPosition (_handle, &mtime, sizeof (MMTIME));
    return mtime.u.sample;
}

// Return any error string generated by the device
inline void WaveInDevice::GetErrorText (TCHAR* buf, int len)
{
    waveInGetErrorText (_status, buf, len);
}

#endif
