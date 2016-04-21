// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.6 $  $Date: 2004/01/16 19:58:38 $


/******************************************************************************
 *
 * NIUTIL.CPP
 * Utitlities for the MWNIDAQ DLL
 * 
 * GBL
 * 2/5/97
 */

#include "stdafx.h"
#include <stdio.h>
#include <vector>
#include <math.h>
#include "daqmex.h"
#include "daqtypes.h"	// data types
#include <nidaq.h>	// required for NI-DAQ
#include <nidaqcns.h>	// required for NI-DAQ
#include "niutil.h"

double round(double x);

CComBSTR TranslateErrorCode(HRESULT code)
{
	//first try the resource file
    CComBSTR retval;
	// Must cast to USHORT for CComBSTR::LoadString to work
    if(!retval.LoadString((USHORT)code)) 
    {
        code=-code;
        if(!retval.LoadString((USHORT)code))
            return CComBSTR();
            // translate error message?
    }
    if (code>-20000 && code <-10000)
    {
       CComBSTR nd(L"NI-DAQ: ");
       nd+=retval;
       return nd;
    }

    return retval; 
}




//
//  Use the nidaq ini file to gather information about the device
//

template <class T>
long ParseStringToFixed(char *string, T** ptr)
{
    std::vector<T> output;
    while (string!=NULL && *string!=0) 
    {
        output.push_back(static_cast<T>(strtol(string,&string,10)));
        string=strchr(string,',');
        if (string)
        {
            string++;
        }
    }
    *ptr=new T[output.size()];
    memcpy(*ptr,&output[0],output.size()*sizeof(T));
    return output.size();
}

long ParseStringToDouble(char *string,double **ptr)
{
	std::vector<double> output;
    while (string!=NULL && *string!=0) 
    {
        output.push_back(strtod(string,&string));
        string=strchr(string,',');
        if (string)
        {
            string++;
        }
    }
    *ptr=new double[output.size()];
	memcpy(*ptr,&output[0],output.size()*sizeof(double));
	return output.size();
}

short *ParseStringToShorts(int count,char *string)
{
    short *p=new short[count];
    memset(p,0,sizeof(*p)*count);
    for (int i=0;i<count;i++)
    {
        p[i]=static_cast<short>(strtol(string,&string,10));
        string=strchr(string,',');
        if (string==NULL || *string==0 || *++string==0)
        {
            _ASSERTE(i==count-1);
            break;
        }
    }
    return p;
}

double *ParseStringToDoubles(int count,char *string)
{
    double *p=new double[count];
    memset(p,0,sizeof(*p)*count);
    for (int i=0;i<count;i++)
    {
        p[i]=strtod(string,&string);
        string=strchr(string,',');
        if (string==NULL || *string==0 || *++string==0)
        {
            _ASSERTE(i==count-1);
            break;
        }
    }
    return p;
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

int DevCaps::LoadDeviceInfo()
{  
    
    char Section[16];
    
    char fname[512];
    char tmpString[512];
    
    // we expect the ini file to be in the same directory as the application,
    // namely, this DLL. It's the only way to find the file if it's not
    // in the windows subdirectory

    if (GetModuleFileName(_Module.GetModuleInstance(), fname, 512)==0)
        return E_FAIL;
    
    // replace .dll with .ini
    strrchr(fname, '.' )[1]='\0';
    strcat(fname,"ini"); 
    
    // create a key to search on
    sprintf(Section, "board%d", deviceCode);
    

    DWORD outLen = GetPrivateProfileString(Section,
        "name", "unknown", tmpString, 32, fname);

    deviceName = new char [strlen(tmpString)+1];
    strcpy(deviceName, tmpString);    

    deviceType= GetPrivateProfileInt(Section, "device", 0, fname);

    adcResolution = GetPrivateProfileInt(Section, 
        "adcResolution", 12, fname);

    dacResolution = GetPrivateProfileInt(Section, 
        "dacResolution", 12, fname);

    minSampleRate = GetPrivateProfileDouble(Section,
        "minSR", .006 , fname);

    maxAISampleRate = GetPrivateProfileDouble(Section,
        "maxAISR", 100000, fname);

    maxAOSampleRate = GetPrivateProfileDouble(Section,
        "maxAOSR", 100000, fname);

    AIFifoSize = GetPrivateProfileInt(Section,
        "ADCFIFO", 512, fname);

    AOFifoSize = GetPrivateProfileInt(Section,
        "DACFIFO", 2048, fname);
    
    HasMite= GetPrivateProfileBool(Section,
        "MITE", 0, fname);

    settleTime = GetPrivateProfileDouble(Section,
        "settleTime", 10, fname);

    nInputs = GetPrivateProfileInt(Section,
        "inputs", 0, fname);

    outLen=GetPrivateProfileString(Section,"coupling","DC",tmpString, 
        512, fname);
    Coupling=tmpString;
    
    outLen=GetPrivateProfileString(Section,"SEInputIDs","",tmpString, 
        512, fname);
    if (outLen==0)
    {
        nSEInputIDs=nInputs;
        SEInputIDs=new short[nInputs];
        for (int i=0;i<nInputs;i++)
            SEInputIDs[i]=i;
    }
    else
    {
        nSEInputIDs=static_cast<short>(ParseStringToFixed(tmpString,&SEInputIDs));
    }

    outLen=GetPrivateProfileString(Section,"DIInputIDs","",tmpString, 
        512, fname);
    if (outLen==0)
    {
        nDIInputIDs=nInputs/2;
        DIInputIDs=new short[nInputs/2];
        for (int i=0;i<nInputs/2;i++)
            DIInputIDs[i]=i;
    }
    else
    {
        nDIInputIDs=static_cast<short>(ParseStringToFixed(tmpString,&DIInputIDs));
    }

    nOutputs = GetPrivateProfileInt(Section,
        "outputs", 0, fname);

    nDIOLines= GetPrivateProfileInt(Section,"diolines", 0, fname);

    scanning = GetPrivateProfileBool(Section,
        "scanning", true, fname);

    analogTrig = GetPrivateProfileBool(Section,
        "analogTrig", true, fname);

    digitalTrig = GetPrivateProfileBool(Section,
        "digitalTrig",true, fname);


    unipolarRange=GetPrivateProfileDouble(Section, "unipolarRange", 0, fname);
    bipolarRange=GetPrivateProfileDouble(Section, "bipolarRange", 5, fname);
    supportsUnipolar=unipolarRange!=0;

    dacUnipolarRange=GetPrivateProfileDouble(Section, "dacUnipolarRange", 0, fname);
    dacBipolarRange=GetPrivateProfileDouble(Section, "dacBipolarRange", 0, fname);

    // now read in the gain info unipolar first
 //   sprintf(GainSection, "GainType%d", unipolarGainType);
    //numUnipolarGains=GetPrivateProfileInt(GainSection, "NumGains", 0, fname);
    if (supportsUnipolar)
    {
        outLen = GetPrivateProfileString(Section, "unipolarGains", "", tmpString, 512, fname);
        numUnipolarGains=static_cast<short>(ParseStringToDouble(tmpString,&unipolarGains));
        outLen = GetPrivateProfileString(Section, "unipolarGainsInt", tmpString , tmpString, 512, fname);
        ParseStringToFixed(tmpString,&unipolarGainSettings);
    }
    else
        numUnipolarGains=0;
    
    outLen = GetPrivateProfileString(Section, "bipolarGains", "", tmpString, 512, fname);
    numBipolarGains=static_cast<short>(ParseStringToDouble(tmpString,&bipolarGains));
    outLen = GetPrivateProfileString(Section, "bipolarGainsInt", tmpString , tmpString, 512, fname);
    ParseStringToFixed(tmpString,&bipolarGainSettings);



    return S_OK;

}

DevCaps::DevCaps():
deviceType(-1),
deviceCode(0),
deviceName(NULL),
unipolarGains(NULL),
unipolarGainSettings(NULL),
bipolarGains(NULL),
bipolarGainSettings(NULL),
DIInputIDs(NULL),
SEInputIDs(NULL)
{
}

DevCaps::~DevCaps()
{
    delete [] deviceName;
    
    if (bipolarGains!=unipolarGains)
    {
        delete [] bipolarGains;
        delete [] bipolarGainSettings;
    }
    delete [] unipolarGains;
    delete [] unipolarGainSettings;
    delete [] DIInputIDs;
    delete [] SEInputIDs;

 }

int DevCaps::GetDeviceData(int deviceNum)
{
    int status;	
    
    status = Get_DAQ_Device_Info(deviceNum, 
        ND_DEVICE_TYPE_CODE, 
        &deviceCode);
    DAQ_CHECK(status);      


//   should we use other options like : ND_AI_CHANNEL_COUNT?
    status = Get_DAQ_Device_Info(deviceNum, 
        ND_DATA_XFER_MODE_AI,
        &transferModeAI);
    
    if (status) transferModeAI=0L;

    status = Get_DAQ_Device_Info(deviceNum, 
        ND_DATA_XFER_MODE_AO_GR1,
        &transferModeAO);
    
    if (status) transferModeAO=0L;
        
    status = Get_DAQ_Device_Info(deviceNum,
        ND_DMA_A_LEVEL,
        &dmaLevelA);
    
    if (status) dmaLevelA=0L;
    
    status = Get_DAQ_Device_Info(deviceNum,
        ND_DMA_B_LEVEL,
        &dmaLevelB);
    
    if (status) dmaLevelB=0L;
    
    status = Get_DAQ_Device_Info(deviceNum,
        ND_DMA_C_LEVEL,
        &dmaLevelC);
    
    if (status) dmaLevelC=0L;
    
    
    status = Get_DAQ_Device_Info(deviceNum,
        ND_INTERRUPT_A_LEVEL,
        &irqLevelA);
    
    if (status) irqLevelA=0L;
    
    
    status = Get_DAQ_Device_Info(deviceNum,
        ND_INTERRUPT_B_LEVEL,
        &irqLevelB);
    
    if (status) irqLevelB=0L;
    
    status = GetDriverVersion((char*)drvVersion);
    DAQ_CHECK(status);
        
    return LoadDeviceInfo();
       
}

double round(double x)
{
	// Trivial implementation of integer rounding operation
	// If fractional part of X is greater or equal than .5, then return
	// integer part + 1.  If it's less, then return integer part + 0.
	double intpart;

	if(modf(x,&intpart) >= 0.5)
		return intpart + 1.0;
	else
		return intpart;
}

double DevCaps::FindRate(double rate, short *pTimeBase,unsigned short *pInterval)
{
	// Trial fix to geck 194165
	// if this is an eseries board, and the the requested rate is above 500KS/sec,
	// we need to shift to the 20MHz clock, which DAQ_Rate will not do
	if(rate > 500000 && IsESeries())
	{
		*pTimeBase = -3;
		*pInterval = (int)round(1/(rate * Timebase2ClockResolution(*pTimeBase)));
	}
	else
	{
		// Call DAQ_Rate() to calculate timebase and interval
		DAQ_Rate(rate, 0, pTimeBase, pInterval);
	}

	// Return SampleRate calculated from timebase/interval
	return (1.0/ (*pInterval * Timebase2ClockResolution(*pTimeBase)));
}


/*
 * Get the NI-DAQ driver version. The version is stored in the lower
 * two bytes of the value passed in.
 */
int GetDriverVersion(char *version)
{
    ULONG ver;
    
    int	status = Get_NI_DAQ_Version(&ver);
    DAQ_CHECK(status);
    
    ver &= 0xFFFF;		
    
    char tmpBuf[8];		
    sprintf(tmpBuf,"%x",ver);	
    
    sprintf(version, "%c.%c.%c",tmpBuf[0],tmpBuf[1],tmpBuf[2]);

    return 0;
}


double Timebase2ClockResolution(int timeBase)
{
    switch (timeBase)
    {
    case -3:
        return 50e-9;
    case -1:
        return 200e-9;
    case 1:
        return 1e-6;
    case 2:
		return 10e-6;
    case 3:
        return 100e-6;
    case 4:
        return 1e-3;
    case 5:
        return 10e-3;
    }

    return 0.;
}

_bstr_t StringToLower(const _bstr_t& in) 
{
    _bstr_t out(in,true);
    LPWSTR p=in;
    LPWSTR pout=out;
    for (unsigned int i=0;i<in.length();i++)
    {
        *pout++=towlower(*p++);
    }
    return out;
}



