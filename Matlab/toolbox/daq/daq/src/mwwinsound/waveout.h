// Copyright 1998-2004 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2004/04/08 20:49:50 $

#if !defined WAVEOUT_H
#define WAVEOUT_H

#include <windows.h>
#include <mmsystem.h>

class CWaveOutCaps: public WAVEOUTCAPS
{
public:
    CWaveOutCaps() :idDev(0)
    {
        memset(static_cast<WAVEOUTCAPS*>(this),0,sizeof(WAVEOUTCAPS));
    }
    MMRESULT LoadCaps(UINT _idDev)
    {
        idDev=_idDev;
        return waveOutGetDevCaps(idDev, this, sizeof(WAVEOUTCAPS));
    }
    bstr_t GetDeviceName()
    {
            return bstr_t(szPname);
    }
    bool IsStereo()
    {
        return wChannels>=2;
    }
    bool Supports16Bit()
    {
        
	if (dwFormats & (WAVE_FORMAT_4M16 | WAVE_FORMAT_2M16 | WAVE_FORMAT_1M16
                                    | WAVE_FORMAT_4S16 | WAVE_FORMAT_2S16 | WAVE_FORMAT_1S16) )
	{
	    return true;
	}

	return false;
    }
    double GetMaxSampleRate()
    {
        
	if (dwFormats & (WAVE_FORMAT_4M16 | WAVE_FORMAT_4S16 | WAVE_FORMAT_4M08 | WAVE_FORMAT_4S08))
            return 44100.0;
	if (dwFormats & (WAVE_FORMAT_2M16 | WAVE_FORMAT_2S16 | WAVE_FORMAT_2M08 | WAVE_FORMAT_2S08))
            return 22050.0;
	if (dwFormats & (WAVE_FORMAT_1M16 | WAVE_FORMAT_1S16 | WAVE_FORMAT_1M08 | WAVE_FORMAT_1S08))
            return 11025.0;
        return 0;
    }

    // return the Windows driver version for DaqHwInfo
    LPWSTR GetDriverVersion()
    {

        BYTE majorVer = (vDriverVersion & 0xFF00) >> 8;
	BYTE minorVer = (vDriverVersion & 0x00FF);
	
	static wchar_t ver[16];
	swprintf(ver, L"%d.%d", majorVer, minorVer);
	return ver;
    }
    bool IsSampleAccurate()
    {
        return (dwSupport & WAVECAPS_SAMPLEACCURATE ? true : false);
    }
    UINT idDev;
};


class CWaveOutDevice
{
public:
    CWaveOutDevice ();
    ~CWaveOutDevice ();
    bool    Open (UINT idDev, CWaveFormat& format, DWORD dwCallback,DWORD instance,DWORD fdwOpen);
    bool    Reset ();
    bool    Close ();
    bool    Prepare (WaveHeader * pHeader);
    bool    UnPrepare (WaveHeader * pHeader);
    void    SendBuffer (WaveHeader * pHeader);
    bool    Pause() { _status = waveOutPause(_handle); return Ok();}
    bool    Restart() { _status = waveOutRestart(_handle); return Ok();}
    bool    Ok () {      
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
    bool    isInUse () { return _status == MMSYSERR_ALLOCATED; }
    DWORD   GetPosSample ();
    UINT    GetError () { return _status; }
    void    GetErrorText (TCHAR* buf, int len);
private:
    HWAVEOUT	_handle;
    MMRESULT	_status;
};

inline CWaveOutDevice::CWaveOutDevice () : 
_handle(NULL),
_status(MMSYSERR_NOERROR)
{
    
}


inline CWaveOutDevice::~CWaveOutDevice ()
{
    if (Ok())
    {
        waveOutReset(_handle);
        waveOutClose (_handle);
    }
}

inline bool CWaveOutDevice::Open (UINT idDev, CWaveFormat& format, DWORD dwCallback,DWORD instance,DWORD fdwOpen)
{
    _status = waveOutOpen (
        &_handle, 
        idDev, 
        &format, 
        dwCallback,
        instance, // callback instance data
        fdwOpen);
    
    return Ok();
}

inline bool CWaveOutDevice::Reset ()
{
    _status=MMSYSERR_NOERROR;
    waveOutReset (_handle);
    return Ok();
}

inline bool CWaveOutDevice::Close ()
{
    if ( Ok() && waveOutClose (_handle) == 0)
    {
        _handle=NULL;
        _status = MMSYSERR_BADDEVICEID;
        return TRUE;
    }
    else
        return FALSE;
}

inline bool CWaveOutDevice::Prepare (WaveHeader * pHeader)
{
    _status = waveOutPrepareHeader(_handle, pHeader, sizeof(WAVEHDR));
     return Ok();
}

inline void CWaveOutDevice::SendBuffer (WaveHeader * pHeader)
{
    waveOutWrite (_handle, pHeader, sizeof(WAVEHDR));
}

inline bool CWaveOutDevice::UnPrepare (WaveHeader * pHeader)
{
    _status = waveOutUnprepareHeader (_handle, pHeader, sizeof(WAVEHDR));
     return Ok();
}

inline DWORD CWaveOutDevice::GetPosSample ()
{
    MMTIME mtime;
    mtime.wType = TIME_SAMPLES;
    waveOutGetPosition (_handle, &mtime, sizeof (MMTIME));
    return mtime.u.sample;
}

inline void CWaveOutDevice::GetErrorText (TCHAR* buf, int len)
{
    waveOutGetErrorText (_status, buf, len);
}

#endif
