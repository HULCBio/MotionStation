// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.1.6.3 $  $Date: 2003/12/22 00:48:11 $


// cbUtil.h: interface for the CDeviceInfo class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CBUTIL_H__043B8A03_232C_11D3_A2F2_00A024E7DC56__INCLUDED_)
#define AFX_CBUTIL_H__043B8A03_232C_11D3_A2F2_00A024E7DC56__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
#include <vector>
#include <map>
#include <adaptorkit.h>
#include "cbw.h"

#define ERR_XLATE(x) (-(x+1000))
#define ERR_XLATE_INV(x) (-x-1000))
#define CBI_XLATE_INV(x) (-x)
#define IS_CBI_ERROR(x) (x<0 && x>-1000)
#define IS_LOCAL_ERROR(x) (x<-1000 && x>-65537)
#ifdef _DEBUG
inline long _CheckResult(long status,char *Message,char *file,int line)
{
    if (status)
    {
        if ((1 == _CrtDbgReport(_CRT_WARN, file, line, NULL,"%s Returned %d\n", Message, status)))
            _CrtDbgBreak();
    }
    return status;
}
#define CBI_XLATE(function) (-_CheckResult(function,#function,__FILE__,__LINE__))
#define CBI_CHECK(function) { long stat=_CheckResult(function,#function,__FILE__,__LINE__);if (stat!=0) return -stat;}
#define DAQ_CHECK(function) { long stat=_CheckResult(function,#function,__FILE__,__LINE__);if (stat<0) return stat;}
//#define DAQ_CHECK(status) { _CrtCheckMemory() ;long stat=status; _CrtCheckMemory(); if (stat) return stat;}
#define DAQ_ASSERT(function) {long stat=function; if (stat) {_RPTF1(_CRT_ASSERT,#function " Returned %d\n",stat);}}
#else
#define CBI_XLATE(x) (-x)
#define DAQ_CHECK(function) { long stat=function; if (stat < 0) return stat;}
#define CBI_CHECK(function) { long stat=function; if (stat != 0) return CBI_XLATE(stat);}
#define DAQ_ASSERT
#endif

#include <comdef.h>

#ifdef _DEBUG
#define DEBUG_NEW new(_NORMAL_BLOCK, __FILE__, __LINE__)
#define new DEBUG_NEW
#endif

float GetDriverMinorRevision();
void GetInstalledBoardInfo(short * idVec, short * len);
void EnumSubsystems(short id, bool *ai, bool *ao, bool *dio);

struct RANGE_INFO {
    int rangeInt;
    float minVal;
    float maxVal;
//    char  name[16];
};

double GetPrivateProfileDouble(    LPCTSTR lpAppName,LPCTSTR lpKeyName,double Default, LPCTSTR lpFileName);
// cbRoot includes dio CbDevice is used by ai and ao devices
class ATL_NO_VTABLE CbRoot: public CmwDevice
{
public:
    CbRoot() :_BoardNum(-1) {}
    bstr_t  _iniSection;
    bstr_t _iniFileName;
    bstr_t _boardName;
    int     _BoardNum;          // Currently selected board target
    int _BoardType;   // BIBOARDTYPE from cbGetConfig
    HRESULT SetBaseHwInfo();
    template <class T>
    T GetFromIni(LPCTSTR lpKeyName,T DefaultValue)
    {
        return static_cast<T>(GetPrivateProfileInt(_iniSection,lpKeyName, DefaultValue, _iniFileName));
    }
    bool GetFromIni(LPCTSTR lpKeyName,bool DefaultValue)
    {
        return GetPrivateProfileInt(_iniSection,lpKeyName, DefaultValue, _iniFileName) == 0 ? false : true;;
    }
    double GetFromIni(LPCTSTR lpKeyName,double DefaultValue)
    {
        return GetPrivateProfileDouble(_iniSection,lpKeyName, DefaultValue, _iniFileName);
    }
    float GetFromIni(LPCTSTR lpKeyName,float DefaultValue)
    {
        return static_cast<float>(GetPrivateProfileDouble(_iniSection,lpKeyName, DefaultValue, _iniFileName));
    }

};

//template <class T>
class ATL_NO_VTABLE CbDevice : public CbRoot ,public  ImwAdaptor
{
public:
    CbDevice();
    ~CbDevice();
    typedef unsigned short RawDataType;
    int LoadDeviceInfo(const TCHAR* prefix);
    int LoadRangeInfo(char *tag,int inputType=-1);
    HRESULT EnableSwClocking();

    // Member variabes to store .INI file data.
    double _maxSampleRate;
	double _maxContinuousSampleRate;
    double _minSampleRate;
    //short _adcResolution;
    short _Resolution;
    short _FifoSize;
    bool _scanning;
    //    bool _swRangeConfig;        // Does board support sw Range config.
    bool _chanGainQueue;        // board has a chanGain queue
    bool    _UseSoftwareClock;
    enum CLOCKING_TYPES {NORMAL,DIVBY2,CASCADED,SOFTWARE}; // Do not change this without fixing ini file
    CLOCKING_TYPES  _ClockingType;
    double _ClockBaseFrequency;   // Base clock frequency
    HRESULT SetClockSource();  // switch between sw and hardware clocking

    void FixupSampleRates();
    double RoundRate(const double& rate) const;
    double Das16Rate(const double& PacerRate) const;
    virtual HRESULT UpdateRateAndSkew()
    {
        double newrate=RoundRate(pSampleRate);
        if (newrate!=pSampleRate)
            pSampleRate=newrate;
        return S_OK;
    }

    virtual HRESULT UpdateDefaultChannelValue(int channel,double value)
        {ATLTRACENOTIMPL("UpdateDefaultChannelValue");}
    HRESULT Open(IUnknown *Interface);


    // Bipolar ranges only specify max. values. Min is assumed to be
    // negative value of max.
    typedef std::vector<RANGE_INFO*> RangeList_t;
    RangeList_t _validRanges;
    typedef std::map<short,RANGE_INFO*> RangeMap_t;
    RangeMap_t _rangemap;

    HRESULT PutSingleValue( int chanindex, int value)
    { return CBI_XLATE(cbAOut(_BoardNum,_chanList[chanindex],_chanRange[chanindex],value)); }

    HRESULT     GetSingleValue(int chan,unsigned short *loc)
    {
        int status=CBI_XLATE(cbAIn(_BoardNum,_chanList[chan],_chanRange[chan],loc));
//        if (_convertData==12)
//            *loc>>=4;
        return status;
    }


    STDMETHOD(AdaptorInfo)(IPropContainer * Container);
    STDMETHOD(OpenDevice)(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
        REFIID EngineIID,
        IUnknown __RPC_FAR *pIEngine,
        void __RPC_FAR *__RPC_FAR *ppIDevice);

    STDMETHOD(TranslateError)(HRESULT code,BSTR *retVal);
    HRESULT FindRange(float low,float high,RANGE_INFO* &pRange);
    static CComBSTR GetErrMsg(short code);
    virtual long UpdateChans(bool ForStart=true);         // check the dirty bit and update if needed (clear dirty)
    HRESULT CheckChansForBackround();
    int _MaxChannels;           // BINUMADCHANS  or BINUMDACHANS from cbGetConfig

    std::vector<short> _chanRange;
//    std::vector<short> _chanList;
    STDMETHOD(ChildChange)(ULONG typeofchange,  tagNESTABLEPROP * pChan);
    // common properties
    TCachedProp<double> pSampleRate;
    std::vector<short> _chanList;
    long    _nChannels;
    CachedEnumProp     pTransferMode;
};
#endif
