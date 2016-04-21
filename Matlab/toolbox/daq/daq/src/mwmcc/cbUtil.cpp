// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.3 $  $Date: 2003/12/22 00:48:10 $


// cbUtil.cpp: implementation of the CbDevice class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include <Winver.h> // For GetDriverMinorRevision
#include <stdio.h>
#include <vector>
#include <math.h>
#include "daqmex.h"
//#include "daqtypes.h"	// data types
#include "cbUtil.h"
#include "mwmcc.h"
#include "DaqmexStructs.h"
#include <map>
//#include <cbw.h


//#define MAKERANGE(name,min,max)  name,(float)min,(float)max,#name

#define MAKERANGE(name,min,max)  name,(float)min,(float)max

RANGE_INFO Ranges[]={
   MAKERANGE(BIP20VOLTS		,-20,20),
    MAKERANGE(BIP10VOLTS	,-10,10), 
    MAKERANGE(BIP5VOLTS     ,-5,5),
    MAKERANGE(BIP4VOLTS		,-4,4),
    MAKERANGE(BIP2PT5VOLTS  ,-2.5,2.5),
	MAKERANGE(BIP2VOLTS		,-2,2),
    MAKERANGE(BIP1PT25VOLTS ,-1.25,1.25),
    MAKERANGE(BIP1VOLTS     ,-1,1),
    MAKERANGE(BIPPT625VOLTS ,-0.625,0.625),
    MAKERANGE(BIPPT5VOLTS   ,-0.5,0.5),
	MAKERANGE(BIPPT25VOLTS  ,-0.25,0.25),
	MAKERANGE(BIPPT2VOLTS   ,-0.2,0.2),
    MAKERANGE(BIPPT1VOLTS   ,-0.1,0.1),
    MAKERANGE(BIPPT05VOLTS  ,-0.05,0.05),
    MAKERANGE(BIPPT01VOLTS  ,-0.01,0.01),
    MAKERANGE(BIPPT005VOLTS ,-0.005,0.005),
    MAKERANGE(BIP1PT67VOLTS ,-1.67,1.67),

    MAKERANGE(UNI10VOLTS     ,0,10),
    MAKERANGE(UNI5VOLTS      ,0,5),
    MAKERANGE(UNI2PT5VOLTS   ,0,2.5),
    MAKERANGE(UNI2VOLTS      ,0,2),
    MAKERANGE(UNI1PT25VOLTS  ,0,1.25),
    MAKERANGE(UNI1VOLTS      ,0,1),
	MAKERANGE(UNIPT5VOLTS    ,0,0.5),
	MAKERANGE(UNIPT25VOLTS   ,0,0.25),
	MAKERANGE(UNIPT2VOLTS    ,0,0.2),
    MAKERANGE(UNIPT1VOLTS    ,0,.1),
    MAKERANGE(UNIPT01VOLTS   ,0,0.01),
    MAKERANGE(UNIPT02VOLTS   ,0,0.02),
    MAKERANGE(UNI1PT67VOLTS  ,0,1.67),
/*  Not currently supported 
    MAKERANGE(MA4TO20     ,4,20),
    MAKERANGE(MA2TO10     ,2,10),
    MAKERANGE(MA1TO5      ,1,5),
    MAKERANGE(MAPT5TO2PT5 ,0.5,2.5)
    */ 
};


#define NUM_RANGES (sizeof(Ranges)/sizeof(RANGE_INFO))


// Use the Windows API to obtain the minor revision data from the file information structure
float GetDriverMinorRevision()
{

	// Get the info structure size for this DLL
	DWORD Zero = 0;
	DWORD Size = 0;
	
	Size = GetFileVersionInfoSize("cbw32.dll", &Zero);
	
	// Proceed only if the call to GetFileVersionInfoSize was successful
	if( Size != 0)
	{
		// Create a character array to hold this data
		LPVOID VersionData = new char[Size];
		UINT TextSize = 0;
	
		// Retrieve all file data
		GetFileVersionInfo("cbw32.dll", Zero, Size, VersionData);

		// Create a structure pointer and have it point to the VersionData
		VS_FIXEDFILEINFO *InfoStructure;
		VerQueryValue(VersionData, "\\", (VOID **) &InfoStructure, &TextSize);

		// Calculate the Minor revision number and add it to the Major revision number
		float minor = static_cast<float>(InfoStructure->dwProductVersionMS & 0xffff);

		// Convert to decimal representation of revision number (.xxx)
		while(minor >= 1)
			minor = minor / 10;

		// Clean up
		delete VersionData;
		
		return minor;
	}

	return 0;
}

void GetInstalledBoardInfo(short *ids, short *len)
{
    short   cnt=0;
    int     MaxBoards=0;      // Maximum number of boards UL will support.   
    char    BoardName[BOARDNAMELEN];
    _ASSERT(ids);

    cbGetConfig(GLOBALINFO,0,0,GINUMBOARDS,&MaxBoards);

    for (int i=0; i<MaxBoards; i++)
    {
        // Just use this call to determine if board num is valid. 
        if (!cbGetBoardName(i,BoardName))
            ids[cnt++]=i;
    }
    *len=cnt;    
}

// id is the BoardNumber
void EnumSubsystems(short id, bool *ai, bool *ao, bool *dio)
{
    // The following information, for now, is only used to determine
    // what subsytems the HW supports.
    int ADchans;        // Number of A/D chans.
    int DAchans;        // Number of D/A chans.
    int DIOdevs;        // Number of Digital IO devices on board.

    // Determine the capability of each board, AIn, AOut, DIO
    cbGetConfig(BOARDINFO, id, 0, BINUMADCHANS, &ADchans);
    if (ADchans) *ai=true;

    cbGetConfig(BOARDINFO, id, 0, BINUMDACHANS, &DAchans);
    if (DAchans) *ao=true;
    
    cbGetConfig(BOARDINFO, id, 0, BIDINUMDEVS, &DIOdevs);
    if (DIOdevs) *dio=true;
}
//
//  Use the cbidaq ini file to gather information about the device
//

template <class T>
void ParseStringToFixed(char *string, std::vector<T> &output)
{
    while (string!=NULL && *string!=0) 
    {
        output.push_back(static_cast<T>(strtol(string,&string,10)));
        string=strchr(string,',');
        if (string)
        {
            string++;
        }
    }
}

void ParseStringToDouble(char *string,std::vector<double> &output)
{
    while (string!=NULL && *string!=0) 
    {
        output.push_back(strtod(string,&string));
        string=strchr(string,',');
        if (string)
        {
            string++;
        }
    }
}



inline bool GetPrivateProfileBool(    LPCTSTR lpAppName,LPCTSTR lpKeyName,bool nDefault, LPCTSTR lpFileName)
{
    return GetPrivateProfileInt( lpAppName,lpKeyName,nDefault,lpFileName) == 0 ? false : true;
}

double GetPrivateProfileDouble(    LPCTSTR lpAppName,LPCTSTR lpKeyName,double Default, LPCTSTR lpFileName)
{
    char buf[30],*ptr;
    int outLen=GetPrivateProfileString(lpAppName,lpKeyName,"",buf,29,lpFileName);
    if (outLen==0) return Default;
    double outval=strtod(buf,&ptr);
    if(ptr!=buf)
        return outval;
    else
        return Default;
}

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

int CbDevice::LoadRangeInfo(char *tag, int inputType /* = -1 */)
{
    //  Initialize the Range map
    for (int j=0;j<NUM_RANGES;j++)
    {
        _rangemap[Ranges[j].rangeInt]=&Ranges[j];
    }

    // NOTE: the following method only works if InputType is non-selectable.
    // If we ever implement run-time selectable InputType, then this must 
    // change (see _selectableInputType).

    // Get ranges for both single ended and differential (e.g. InputRanges)
    // Default to "0" if none.
    char sRanges[512];
    GetPrivateProfileString(_iniSection,tag,"0",sRanges,512,_iniFileName);

    char sTemp[512];
    char sType[512];
    DWORD outLen = 0; 
    if (inputType == INPUT_TYPE_DIFFERENTIAL)
    {
        // See if there is a specific range key for differential (e.g. DIInputRanges)
        strcpy( sType, "DI" ); 
        strcat( sType, tag );
        outLen = GetPrivateProfileString(_iniSection,sType,"",sTemp,512,_iniFileName);
    }
    else if (inputType == INPUT_TYPE_SINGLEENDED)
    {
        // See if there is a specific range key for single-ended (e.g. SEInputRanges)
        strcpy( sType, "SE" );
        strcat( sType, tag );
        outLen = GetPrivateProfileString(_iniSection,sType,"",sTemp,512,_iniFileName);
    }

    // If found, use it. Otherwise use default (non-SE or DI prefixed)
    if ( outLen > 0 )
    {
        strcpy(sRanges,sTemp);
    }

    // Parse CSV string into a vector
    std::vector<short> ranges;
    ParseStringToFixed(sRanges,ranges);

    _validRanges.reserve(ranges.size());

    for (std::vector<short>::iterator i=ranges.begin();i!=ranges.end();i++)
    {
        _validRanges.push_back((_rangemap.find(*i)->second));
    }
    ranges.clear();
    return S_OK;
}

static TCHAR* mkName(TCHAR* base,TCHAR* value)
{
    strcpy(base+2,value);
    return base;
}

int CbDevice::LoadDeviceInfo(const TCHAR* prefix)
{  
    
    // we expect the ini file to be in the same directory as the application,
    // namely, this DLL. It's the only way to find the file if it's not
    // in the windows subdirectory

    _ASSERTE(_iniSection.length()>0);
    TCHAR keyname[64];
    strcpy(keyname,prefix);
    int clockMHz=0;
    CBI_CHECK(cbGetConfig(BOARDINFO, _BoardNum, 0, BICLOCK, &clockMHz));
    _ClockBaseFrequency=clockMHz*1e6;
    _FifoSize=GetFromIni(mkName(keyname,_T("FIFO")),0);
    _maxSampleRate = GetFromIni(mkName(keyname,_T("MaxSR")),0);
    _maxContinuousSampleRate = GetFromIni(mkName(keyname,_T("MaxContSR")),0);
    _minSampleRate = GetFromIni(mkName(keyname,_T("MinSR")),0);
    _Resolution= GetFromIni(mkName(keyname,_T("Resolution")),12);
    return S_OK;
}

CbDevice::CbDevice()
:
_chanGainQueue(false),
_MaxChannels(0),
_nChannels(0),
_UseSoftwareClock(false),
pTransferMode(DEFAULTIO) 
{
}

CbDevice::~CbDevice()
{
}


HRESULT CbRoot::SetBaseHwInfo()
{
    CComPtr<IProp> prop;        

    char tmpString[512];
    
    // we expect the ini file to be in the same directory as the application,
    // namely, this DLL. It's the only way to find the file if it's not
    // in the windows subdirectory

    if (GetModuleFileName(_Module.GetModuleInstance(), tmpString, 512)==0)
        return E_FAIL;
    // replace .dll with .ini
    strrchr(tmpString, '.' )[1]='\0';
    strcat(tmpString,"ini"); 
    _iniFileName=tmpString;


    cbGetBoardName(_BoardNum,tmpString);
    _boardName=tmpString;
    _iniSection=_boardName;  

    CBI_CHECK(cbGetConfig(BOARDINFO, _BoardNum, 0, BIBOARDTYPE, &_BoardType));
    long id=GetFromIni(_T("ID"),0L);
    if (id==0)
    {
        _engine->WarningMessage(CComBSTR("Board not found in mwmcc.ini file.  Board is not supported but may work.")); 
    }
    else if (id!=_BoardType)
    {
        _engine->WarningMessage(CComBSTR("BoardType from Ini file does not match that returned from universal libray."));
        _RPT2(_CRT_WARN,"BoardType from ini file is %d board type from unilib is %d\n",id,_BoardType);
    }
    

    // device Id
    wchar_t Str[80];
    swprintf(Str, L"%d", _BoardNum);
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"id"), CComVariant(Str)));		
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"adaptorname"), CComVariant(L"mcc")));

    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverdescription"),
	CComVariant(L"Measurement Computing Universal Library")));
    
    
    // Get the UL Revision numbers
    float DllRevNum, DriverRevNum;
    
	cbGetRevision (&DllRevNum, &DriverRevNum);

	// Make a call to get the decimal (.xxx) value of the minor revision number.
	// Add this to the major revision number (y.xxx)
	DllRevNum += GetDriverMinorRevision();

	CComVariant var = DllRevNum;
	var.ChangeType(VT_BSTR);

    DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverversion"), var));

    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"devicename"),variant_t(_boardName)));
    
    return S_OK;
}


STDMETHODIMP CbDevice::ChildChange(ULONG typeofchange,  tagNESTABLEPROP * pChan)
{
    HRESULT retval=S_OK;
    //int progress=typeofchange & ~CHILDCHANGE_REASON_MASK;
    int type=typeofchange & CHILDCHANGE_REASON_MASK;
    if (pChan) // if we have a channel
    {
        switch (type)
        {
        case ADD_CHILD  : 
            ++_nChannels;
            retval=UpdateChans(false); // must exist in base class // resizes channel arrrays
            _updateChildren=true;
            // now set the new range 
            RANGE_INFO *NewInfo;
            if (!retval)
            {
                 retval=FindRange(static_cast<float>(reinterpret_cast<AICHANNEL*>(pChan)->VoltRange[0]),
					              static_cast<float>(reinterpret_cast<AICHANNEL*>(pChan)->VoltRange[1]),NewInfo);
                if (!retval) _chanRange[_nChannels-1]=NewInfo->rangeInt;
            }
            if (retval)
               --_nChannels;
            return retval;
        case DELETE_CHILD  :
            --_nChannels;
            break;
        case REINDEX_CHILD :

            break;
        }
    }
    if (typeofchange & END_CHANGE)
    {
        retval=UpdateChans(false); // must exist in base class
        _updateChildren=true;
    }
    return retval;
}


CComBSTR CbDevice::GetErrMsg(short code)
{
    char ErrMsg[ERRSTRLEN+16];
    strcpy(ErrMsg,"MCC: ");
    cbGetErrMsg((short)code,ErrMsg+strlen(ErrMsg));
    
    // Allocate memory and copy input retVal. The Detach is required
    // so that the memory will not be freed. We need the string to be 
    // returned to the 'engine'.
    
    return ErrMsg;
}

STDMETHODIMP CbDevice::TranslateError(HRESULT code,BSTR *retVal)
{
    if (IS_CBI_ERROR(code) ) // if a cbi error
    {
        
        // Allocate memory and copy input retVal. The Detach is required
        // so that the memory will not be freed. We need the string to be 
        // returned to the 'engine'.
        
        *retVal = GetErrMsg((short)CBI_XLATE_INV(code)).Detach();
    }
    if (IS_LOCAL_ERROR(code))
    {
		// Must cast to USHORT for CComBSTR::LoadString to work
		CComBSTR retval;
        if(!retval.LoadString((USHORT)(ERR_XLATE_INV(code)))
        {
            retval=L"Unknown adaptor error.";
            // translate error message?
        }
        *retVal=retval.Detach();
    }
    return S_OK;
}

//
// AdaptorInfo
//
// Description:
//  Invoked by MatLab function daqhwinfo('cbi'). The function
//  is used to extract relavent info about the current HW
//  configuration. Need to get the board names, the board number
//  and what subsystems are supported, AnalogInput, AnalogOutput,
//  and DigitalIO.
//
// UL Routines:
//  cbGetConfig()
//  cbGetBoardName()
//
HRESULT CbDevice::AdaptorInfo(IPropContainer * Container)
{
    int i = 0;          // Index variable
    wchar_t str[40];    // Temp variable for BoardName

    // Place the adaptor name, 'cbi', in the appropriate struct in the engine.
    HRESULT hRes = Container->put_MemberValue(CComBSTR(L"adaptorname"),CComVariant(L"mcc"));
    if (!(SUCCEEDED(hRes))) return hRes;

    TCHAR name[256];
    GetModuleFileName(_Module.GetModuleInstance(),name,256); // null returns MATLABs version (non existant)

    hRes = Container->put_MemberValue(CComBSTR(L"adaptordllname"),CComVariant(name));
    if (!(SUCCEEDED(hRes))) return hRes;

    // First determine the number of boards installed.
    short idVec[16]={0};        // List of board Numbers
    short len=0;                  // Number of boards installed

    // Return a list of board numbers and number of installed boards. 
    GetInstalledBoardInfo(idVec,&len);      

    SAFEARRAY *boardids = SafeArrayCreateVector(VT_BSTR, 0, len);
    if (boardids==NULL) 
        throw "Failure to create SafeArray.";   
    
    CComBSTR *stringids=NULL;
    CComVariant bids;   
    
    bids.parray=boardids;
    bids.vt = VT_ARRAY | VT_BSTR;           
    
    hRes = SafeArrayAccessData(boardids, (void **) &stringids);
    if (FAILED (hRes)) {
        SafeArrayDestroy (boardids);
        throw "Failure to access SafeArray data.";
    }

    for (i=0;i<len;i++) {	
		swprintf(str,L"%d",(int)idVec[i]);
		stringids[i] = str;
    }  

    SafeArrayUnaccessData(boardids);
    
    // Return the board numbers to the 'engine'
    hRes = Container->put_MemberValue(CComBSTR(L"installedboardids"),bids);   
    if (!(SUCCEEDED(hRes))) return hRes;    

    bids.Clear();

    // build up an array of device names
    CComVariant val;    
    CComBSTR *strings;
    
    SAFEARRAY *ps = SafeArrayCreateVector(VT_BSTR, 0, len);
    if (ps==NULL) 
	throw "Failure to create SafeArray.";    

    val.parray=ps;
    val.vt = VT_ARRAY | VT_BSTR;

    HRESULT hr = SafeArrayAccessData(ps, (void **) &strings);
    if (FAILED (hr)) 
    {
        SafeArrayDestroy (ps);
        throw "Failure to access SafeArray data.";
    }             

    
    char bName[BOARDNAMELEN];

    for (i=0;i<len;i++)
    {
        if (!cbGetBoardName(idVec[i], bName))
            strings[i] = CComBSTR(bName);
    }
                        

    hRes = Container->put_MemberValue(CComBSTR(L"boardnames"),val);
    if (!(SUCCEEDED(hRes))) return hRes;

    SafeArrayUnaccessData(ps);

    // up to 3 subsystems per board
    CComBSTR *subsystems;
    SAFEARRAYBOUND arrayBounds[2];  
        arrayBounds[0].lLbound = 0;
        arrayBounds[0].cElements = len;    
        arrayBounds[1].lLbound = 0;
        arrayBounds[1].cElements = 3;    

    ps = SafeArrayCreate(VT_BSTR, 2, arrayBounds);
    if (ps==NULL)
        throw "Failure to access SafeArray.";      
   
    val.Clear();
    val.parray=ps;
    val.vt = VT_ARRAY | VT_BSTR;
    hr = SafeArrayAccessData(ps, (void **) &subsystems);
    if (FAILED (hr)) 
    {
        SafeArrayDestroy (ps);
        throw "Failure to access SafeArray data.";
    }       
   
    // walk through the board list and determine the available subsystems
    for (i=0;i<len;i++)
    {	
	bool ai=false;
	bool ao=false;
	bool dio=false;
       
	EnumSubsystems(idVec[i], &ai, &ao, &dio);
	if (ai)
        {
            swprintf(str,L"analoginput('mcc',%d)", idVec[i]);
	    subsystems[i]=str;
        }
        else
            subsystems[i]=(BSTR)NULL;
	if (ao)
        {
            swprintf(str,L"analogoutput('mcc',%d)", idVec[i]);
	    subsystems[i+len]=str;
        }
        else
            subsystems[i+len]=(BSTR)NULL;
	if (dio)
        {
            swprintf(str,L"digitalio('mcc',%d)", idVec[i]);
	    subsystems[i+2*len]=str;
        }
        else
            subsystems[i+2*len]=(BSTR)NULL;
    }

    hRes = Container->put_MemberValue(CComBSTR(L"objectconstructorname"),val);
    if (!(SUCCEEDED(hRes))) return hRes;
  
    SafeArrayUnaccessData (ps);    
    
    
    return S_OK;
}

HRESULT CbDevice::EnableSwClocking()
{    
    double maxRate, minRate;

    //
    // It is possible that the hardware will not have the same capabilities as our software clocking
    // In this case we must adjust our assumptions as to what the MIN and MAX sampling rates 
    // should be.
    //

    // Decide the true maximum sampling rate
    if(_maxSampleRate < MAX_SW_SAMPLERATE)
		maxRate = _maxSampleRate;
    else
		maxRate = MAX_SW_SAMPLERATE;

    // Decide the true minimum sampling rate
    if(_minSampleRate > MIN_SW_SAMPLERATE)
		minRate = _minSampleRate;
    else
		minRate = MIN_SW_SAMPLERATE;
    
    RETURN_HRESULT(pSampleRate.SetRange(minRate, maxRate));

	// Set the default rate to 1/5 the max rate
	double defaultRate = int(maxRate/5);
	pSampleRate.SetDefaultValue(defaultRate);

	// Range check the existing sample rate
    if (pSampleRate>maxRate)
	{
        pSampleRate=maxRate;
	}
    else if (pSampleRate<minRate)
	{
        pSampleRate=minRate;
	}

	// If this HW only supports SW Clocking then set the sample rate to the default
    if ( _ClockingType == SOFTWARE )
	{
		pSampleRate = defaultRate;
	}

    pSampleRate=RoundRate(pSampleRate);

    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"minsamplerate", CComVariant(minRate)));	
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"maxsamplerate", CComVariant(maxRate)));	
    return S_OK;
}

HRESULT CbDevice::Open(IUnknown *Interface)
{
    RETURN_HRESULT(CmwDevice::Open(Interface));
    ATTACH_PROP(SampleRate);
    return S_OK;
    //EnableSwClocking();
}
HRESULT CbDevice::FindRange(float low,float high,RANGE_INFO* &pRange)
{

    if (low>high)
        return DE_INVALID_CHAN_RANGE;
    if (low==high)
    {
        return CComCoClass<Ain>::Error(_T("Low value must not be the same as high value."));
    }
    pRange=NULL;
    double range=HUGE_VAL;
    // search all reanges (saves having a sort (sort by what? range.)
    for (RangeList_t::iterator i=_validRanges.begin();i!=_validRanges.end();i++)
    {
        if ((*i)->minVal<=low && (*i)->maxVal >=high && range>(*i)->maxVal-(*i)->minVal)
        {
            // range is valid and better 
            pRange=*i;
            range=(*i)->maxVal-(*i)->minVal;
        }
    }
    if (!pRange)
        return DE_INVALID_CHAN_RANGE;
    return S_OK;

}

HRESULT CbDevice::UpdateChans(bool ForStart)
{
    _chanList.resize(_nChannels);
    _chanRange.resize(_nChannels);
     AICHANNEL *aichan=NULL;
    if (_updateChildren && ForStart)
    {
#ifdef _DEBUG
        long chancheck=0;
        _EngineChannelList->GetNumberOfChannels(&chancheck);
        _ASSERTE(chancheck==_nChannels);
#endif
        for (int i=0; i<_nChannels; i++) 
        {    
            _EngineChannelList->GetChannelStructLocal(i, (NESTABLEPROP**)&aichan);
            _ASSERTE(aichan);
            _chanList[i]=static_cast<short>(aichan->Nestable.HwChan);
            RANGE_INFO *NewInfo;
            RETURN_HRESULT(FindRange(static_cast<float>(aichan->VoltRange[0]),
				                     static_cast<float>(aichan->VoltRange[1]),NewInfo));
            _chanRange[i]=NewInfo->rangeInt;
            if (aichan->Nestable.Type==NPAOCHANNEL)
            {
                RETURN_HRESULT(UpdateDefaultChannelValue(i,((AOCHANNEL*)aichan)->DefaultValue));
            }
            
        }
        
        _updateChildren=false;
    }
    else
    {
        // we still need working chanlist and rangelist if no gainlist
    }
    return S_OK;
}

HRESULT CbDevice::CheckChansForBackround()
{
    if (!_chanGainQueue) // if the device does not have a chanGainQueue then check
    {
        bool haserror=false;
        long range=_chanRange[0];
        int channel=_chanList[0];
        for (int i=1;i<_nChannels;i++)
        {
            if (_chanRange[i]!=range)
            {
                    return CComCoClass<ImwDevice>::Error("All InputRanges must be the same on Devices that do not have a channel gain queue.");
            }
            if (_chanList[i]!=++channel)
            {
                    return CComCoClass<ImwDevice>::Error("Devices that do not have a channel gain queue must scan a channel range.");
            }
        }

    }
    return S_OK;
}

HRESULT CbDevice::SetClockSource()
{
    if (_UseSoftwareClock)
    {
        return EnableSwClocking();
    }
    else
    {
        RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"minsamplerate", CComVariant(_minSampleRate)));	
        RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"maxsamplerate", CComVariant(_maxSampleRate)));	
        pSampleRate.SetRange(_minSampleRate,_maxSampleRate);
        UpdateRateAndSkew();
    }
    return S_OK;
}

double CbDevice::Das16Rate(const double& PacerRate) const
{
    UINT Count1, Count2;
    DOUBLE  FCount;
    
    
    // Calculate the actual pacer rate.
    
    // Calculate the counts for each of the pacer counters
    /*** _ClockBaseFrequency = 10 MHz or 1 MHz***/
    FCount = floor(_ClockBaseFrequency / PacerRate);
    if (FCount > 65536.0)
        Count1 = (UINT)(FCount / 32767.0) + 1;
    else
        Count1 = 2;
    
    Count2 = (UINT)(FCount / (DOUBLE)Count1);
    ATLTRACE("Das16Rate found sr=%f with c1=%d c2=%2 Base=%f\n",_ClockBaseFrequency / (DOUBLE)(Count1 * Count2),Count1,Count2,_ClockBaseFrequency);
    return _ClockBaseFrequency / (DOUBLE)(Count1 * Count2);
    
}

void CbDevice::FixupSampleRates()
{
    if (!_UseSoftwareClock)
    {
        if (_ClockingType==DIVBY2)
        _ClockBaseFrequency/=2;
        double newmax=RoundRate(_maxSampleRate);
        if (newmax>_maxSampleRate)
        {
            long div=static_cast<long>(_ClockBaseFrequency/newmax);
            while (newmax>_maxSampleRate)
            {
                newmax=RoundRate(_ClockBaseFrequency/++div);
            }
            _maxSampleRate=newmax;
        }
    }
    if (_maxSampleRate<_minSampleRate)
        _minSampleRate=_maxSampleRate;
}

double CbDevice::RoundRate(const double& rate) const
{
    if (_UseSoftwareClock)
    {
        return CswClockedDevice::RoundRate(rate);
    }
    else
    {
        if (_ClockingType==CASCADED)
            return Das16Rate(rate);
        else
        {
            // may need to try twice ...
            double newrate= _ClockBaseFrequency/floor(_ClockBaseFrequency/floor(rate)); // allow 0.1% roundoff error
            if (newrate >= rate)
                return newrate;
            else 
                return _ClockBaseFrequency/floor(_ClockBaseFrequency/ceil(rate)); // allow 0.1% roundoff error
        }
    }
}
