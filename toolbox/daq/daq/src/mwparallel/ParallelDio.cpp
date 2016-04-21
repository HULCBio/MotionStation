// ParallelDio.cpp : Implementation of CParallelDio
//
// Copyright 1998-2003 The MathWorks, Inc.
// $Author: batserve $
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:40:10 $

#include "stdafx.h"
#include "mwparallel.h"
#include "ParallelDriver.h"
#include "ParallelDio.h"
#include "ParallelAdapt.h"

// Define DioLine Names
CComBSTR PinName[] =
{L"Pin2",	// Data0
 L"Pin3",	// Data1
 L"Pin4",	// Data2
 L"Pin5",	// Data3
 L"Pin6",	// Data4
 L"Pin7",	// Data5
 L"Pin8",	// Data6
 L"Pin9",	// Data7
 L"Pin15",	// nError
 L"Pin13",	// Select
 L"Pin12",	// PaperOut
 L"Pin10",	// nAck
 L"Pin11",	// Busy
 L"Pin1",	// nStrobe
 L"Pin14",	// nAutoFeed
 L"Pin16",	// nInitialize
 L"Pin17"};	// nSelectPrinter

/////////////////////////////////////////////////////////////////////////////
// CParallelDio

CParallelDio::CParallelDio()
{
    // Set BiDirectionalBit default value
    BiDirectionalBitProp = 5;
}

/////////////////////////////////////////////////////////////////////////////
CParallelDio::~CParallelDio()
{

}


/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CParallelDio::Open(IUnknown *Interface, CComBSTR port, long PortAddress)
{
    HRESULT hRes;
    VARIANT PPvar;

    // Load the selected PortAddress for this object
    CParallelDio::PortAddress = PortAddress;

    // Open Port
    PPortDriver.OpenPort(PortAddress);
    

    // Call MwDEVICE OPEN to initialize Engine pointers
    RETURN_HRESULT(TBaseObj::Open(Interface));

    // Define DAQHWINFO::SubSystemType
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"subsystemtype",CComVariant(L"DigitalIO")));

    SAFEARRAY *pSafeArr;
    long *plarray;
    SAFEARRAYBOUND arrayBounds[1];
    
    arrayBounds[0].lLbound = 0;
    arrayBounds[0].cElements = 3;  // Number of Ports 
    
    // Construct a SafeArray
    pSafeArr = SafeArrayCreate(VT_I4, 1, arrayBounds);
    if (pSafeArr != NULL)
    {        
	// Associate SafeArray with Variant
	PPvar.parray = pSafeArr;
	PPvar.vt = VT_ARRAY | VT_I4;
	hRes = SafeArrayAccessData(pSafeArr, (void **)&plarray);
	
	if (SUCCEEDED(hRes))
	{
	    // Define Port Line Masks
	    plarray[0] = 0xff; // 8 lines <DATA>
	    plarray[1] = 0x1f; // 5 lines <STATUS>
	    plarray[2] = 0xf; // 4 lines <CONTROL>
	    
	    // Total number of lines
	    int NumOfLines = 8+5+4;
	    
	    HRESULT hRes2 = _DaqHwInfo->put_MemberValue(L"portlinemasks",PPvar);
	    
	    HRESULT hRes3 = _DaqHwInfo->put_MemberValue(L"totallines",CComVariant(NumOfLines));
	    
	    // Define Port Directions
	    plarray[0] = DIO_BIDIRECTIONAL; // BIDIRECTIONAL <DATA>
	    plarray[1] = DIO_INPUT;	    // INPUT ONLY <STATUS>
	    plarray[2] = DIO_BIDIRECTIONAL; // BIDIRECTIONAL <CONTROL>
	    
	    HRESULT hRes4 = _DaqHwInfo->put_MemberValue(L"portdirections",PPvar);
	    
	    // Define Port IDs
	    plarray[0] = 0; // <DATA>
	    plarray[1] = 1; // <STATUS>
	    plarray[2] = 2; // <CONTROL>
	    
	    
	    HRESULT hRes5 = _DaqHwInfo->put_MemberValue(L"portids",PPvar);
	    
	    // Define Port/Line Configuration
	    plarray[0] = 0; // PORT <DATA>
	    plarray[1] = 0; // PORT <STATUS>
	    plarray[2] = 0; // PORT <CONTROL>
	    
	    HRESULT hRes6 = _DaqHwInfo->put_MemberValue(L"portlineconfig",PPvar);
	    
	    // Define the PORT ID 
	    HRESULT hRes7 = _DaqHwInfo->put_MemberValue(L"id", CComVariant(port));		
	    
	    // Define the AdaptorName
	    HRESULT hRes8 = _DaqHwInfo->put_MemberValue(L"adaptorname",variant_t(CParallelAdapt::ConstructorName));
	    
	    // Get the Parallel Port Driver description and version number
	    CComBSTR pDesc;
	    CComBSTR pID;
	    HRESULT hRes9 = PPortDriver.GetDriverInfo(pDesc, pID);
	    
	    HRESULT hRes10 = _DaqHwInfo->put_MemberValue(L"vendordriverdescription", CComVariant(pDesc));
	    
	    HRESULT hRes11 = _DaqHwInfo->put_MemberValue(L"vendordriverversion",CComVariant(pID));
	    
	    // Define the BoardName/DeviceName
	    HRESULT hRes12 = _DaqHwInfo->put_MemberValue(L"devicename",CParallelAdapt::DeviceName);
	    
	    if (FAILED(hRes2) | FAILED(hRes3) | FAILED(hRes4) | FAILED(hRes5) | FAILED(hRes6) | FAILED(hRes7) | FAILED(hRes8) | FAILED(hRes9) | FAILED(hRes10) | FAILED(hRes11) | FAILED(hRes12))
		hRes = E_FAIL;
	    else
		hRes = S_OK;
    
	    // Release Safearray
	    SafeArrayUnaccessData (pSafeArr);  
	}
    }

    // Destroy SafeArray
    SafeArrayDestroy (pSafeArr);
   
    if (hRes == E_FAIL)
	return hRes;
    

    // Create Parallel Port specific property 
    // BiDirectionalBit - which bit in the control word enables bi-directional data port
    CComPtr<IProp> PropPtr;
    PropPtr = BiDirectionalBitProp.Create(GetPropRoot(), L"BiDirectionalBit", BiDirectionalBitProp);
	
    PropPtr->put_DefaultValue(CComVariant((BiDirectionalBitProp)));

    // Define the valid range to be 5 ~ 7
    PropPtr->SetRange(&CComVariant(5), &CComVariant(7));

    // Set the initial value
    PropPtr->put_Value(CComVariant((BiDirectionalBitProp)));


    // PortAddress - Read Only address of port
    PropPtr = PortAddressProp.Create(GetPropRoot(), L"PortAddress", PortAddressProp);

    //Convert hex address to string
    CComBSTR bstrPA;
    WCHAR temp[6];
    _itow(PortAddress, temp, 16);
    bstrPA = L"0x";
    bstrPA.Append(temp);
 
    // Set value
    PropPtr->AddMappedEnumValue(0, bstrPA);
    PropPtr->put_DefaultValue(CComVariant(0));
    PropPtr->put_Value(CComVariant(0));
    PropPtr->put_IsReadOnly(TRUE);


    return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CParallelDio::ReadValues(long NumberOfPorts, long *PortList, unsigned long *Data)
{   
    int iLoop;
    HRESULT hr = S_OK;
    USHORT sData;
    USHORT shiftvalue = 0;

    if (Data == NULL)
	return E_FAIL;

    // Loop through each port, reading data and then placing it at Data Pointer
    // NOTE: Each port place data into consecutive locations at Data.

    for (iLoop = 0; iLoop<NumberOfPorts; iLoop++)
    {
	if (*(PortList+iLoop) == 0)
	{
	    // Port 0
	    hr = PPortDriver.GetDigInput(PortAddress, (USHORT*)Data++);
	}
	else if (*(PortList+iLoop) == 1)
	{
	    // Port 1
	    hr = PPortDriver.GetDigInput(PortAddress+1, &sData);
	    // Return upper 5 bits
	    sData = sData>>3;
	    *Data++ = sData;
	}
	else if (*(PortList+iLoop) == 2)
	{
	    // Port 2
	    hr = PPortDriver.GetDigInput(PortAddress+2, &sData);
	    // Return only lower 4 bits
	    sData = sData & 0x0f;
	    *Data++ = sData;
	}

	if (!SUCCEEDED(hr))
	    return E_FAIL;
    }
    return hr;
}

/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CParallelDio::WriteValues(long NumberOfPorts, long *PortList, unsigned long *Data, unsigned long *Mask)
{
    // TODO: Add your implementation code here
    
    int iLoop;
    HRESULT hr;
    USHORT sData = 0;
    USHORT shiftvalue = 0;
    
    if (Data == NULL)
	return E_FAIL;
    
    // Loop through each port, reading data and then placing it at Data Pointer
    // NOTE: Each port place data into consecutive locations at Data.
    
    for (iLoop = 0; iLoop<NumberOfPorts; iLoop++)
    {
	sData = static_cast<USHORT>(*Data & *Mask);
	if (*(PortList+iLoop) == 0)
	{
	    // Port 0
	    hr =  PPortDriver.PutDigOutput(PortAddress, (USHORT*)Data);
	    Data++;
	    Mask++;
	}
	else if (*(PortList+iLoop) == 1)
	{
	    // Port 1
	    return E_FAIL;
	}
	else if (*(PortList+iLoop) == 2)
	{
	    // Port 2
	    // Return only lower 4 bits
	    sData = sData & 0x0f;
	    hr = PPortDriver.PutDigOutput(PortAddress+2, (USHORT*)&sData);
	    Data++;
	    Mask++;
	}
	if (!SUCCEEDED(hr))
	    return E_FAIL;
	
    }
    return hr;
}

/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CParallelDio::SetPortDirection(long Port, unsigned long DirectionValues)
{
    
    // Port 0, set the bidirectional Bit as needed
    if (Port == 0)
    {
	if (!SUCCEEDED(PPortDriver.SetPort0Direction(DirectionValues, BiDirectionalBitProp)))
	    return E_FAIL;
    }
    return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CParallelDio::ChildChange (ULONG typeofchange,  tagNESTABLEPROP * pChan)
{
    typeofchange = (typeofchange & 0xff);
    if (typeofchange == ADD_CHILD)
    {
	// adding a line
			
	CComPtr<IPropContainer >  cont;       
	CComVariant val;
	UINT port;
	
	// Get the correct Channel List Ptr
	GetChannelContainer((pChan->Index)-1, &cont);
	
	// Get the channel's PORT number
	HRESULT hRes = cont->get_MemberValue(CComBSTR(L"port"), &val);
	port = (UINT)val.lVal;
	
	// Set the LineName to the correct PinName
	if (port == 0)	    
	    // check which line number
	{	
	    val = PinName[(pChan->HwChan)];            
	}
	else if (port == 1)	    
	    // check which line number
	{
	    val = PinName[(pChan->HwChan)+8];            
	}
	else if (port == 2)	    
	    // check which line number
	{
	    val = PinName[(pChan->HwChan)+13];            
	    
	}

	hRes = cont->put_MemberValue(CComBSTR(L"linename"), val);
	if (FAILED(hRes)) return hRes;         		
    }    
    return S_OK;
}
