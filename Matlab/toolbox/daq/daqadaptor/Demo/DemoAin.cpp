// demoin.cpp : Implementation of CDemoAin class
// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.1.4.3 $  $Date: 2003/08/29 04:44:10 $


#include "stdafx.h"
#include "Demo.h"
#include "DemoAin.h"
#include "DemoAdapt.h"
#include "math.h"

#define PI 3.14159265358979

/////////////////////////////////////////////////////////////////////////////
// CDemoAin()  default constructor
//
// Function performs all the necessary initializations.
// Function MUST BE MODIFIED by the adaptor programmer. It may use HW API calls.
/////////////////////////////////////////////////////////////////////////////
CDemoAin::CDemoAin(): DeviceId(0),Buffer(256)
{
//TO_DO: replace the following bogus initialization of the buffer ..
//..by the actual initialization, required by the adaptor program and the HW.
    //here we fill the buffer by the sine wave -- just for illustration.
	long size=Buffer.size();
    double scale=2*PI/size;
    NextPoint=Buffer.begin();
    for (int i=0;i<size;++i,++NextPoint)
    {
        *NextPoint=((1<<(Bits-1))-0.5)*sin(i*scale)-0.5;
    }
    NextPoint=Buffer.begin();
//END TO_DO

} // end of default constructor


/////////////////////////////////////////////////////////////////////////////
// Open()
//
// Function is called by the OpenDevice(), which is in turn called by the engine.
// CDemoAin::Open() function's main goals are ..
// 1)to initialize the hardware and hardware dependent properties..
// 2)to expose pointers to the engine and the adaptor to each other..
// 3)to process the device ID, which is input by a user in the ML command line.
// The call to this function goes through the hierarchical chain: ..
//..CDemoAin::Open() -> CswClockedDevice::Open() -> CmwDevice::Open()
// CmwDevice::Open() in its turn populates the pointer to the..
//..engine (CmwDevice::_engine), which allows to access all engine interfaces.
// Function MUST BE MODIFIED by the adaptor programmer.
//////////////////////////////////////////////////////////////////////////////
HRESULT CDemoAin::Open(IUnknown *Interface,long ID)
{
	RETURN_HRESULT(TBaseObj::Open(Interface));
    EnableSwClocking(true);
    TRemoteProp<long>  pClockSource;
    pClockSource.Attach(_EnginePropRoot,L"ClockSource");
    pClockSource->AddMappedEnumValue(CLOCKSOURCE_SOFTWARE, L"Software");
    pClockSource->RemoveEnumValue(CComVariant(L"internal"));
    pClockSource.SetDefaultValue(CLOCKSOURCE_SOFTWARE);
    pClockSource=CLOCKSOURCE_SOFTWARE;

    TRemoteProp<long>  pInputType;
    pInputType.Attach(_EnginePropRoot,L"InputType");
    pInputType->AddMappedEnumValue(0, L"Simulated");

//TO_DO: 1) Deal with the device ID is necessary.
//		 2) Initialize properties in accordance with the HW requirements..
//..	 3)	Initialize the hardware if necessary
//END TO_DO
    RETURN_HRESULT(InitHwInfo(VT_I2,Bits,4,DI_INPUT,CDemoAdapt::ConstructorName,L"SwDemo"));

    return S_OK;
} // end of Open()


/////////////////////////////////////////////////////////////////////////////
// GetSingleValue()
//
// This function gets one single data point form one A/D channel, specified..
//..as a parameter.
// Function is called by GetSingleValues() of the TADDevice class, which..
// ..in turn is called by the engine as a responce to the ML user command GETSAMPLE.
// Function MUST BE MODIFIED by the adaptor programmer.
/////////////////////////////////////////////////////////////////////////////
HRESULT CDemoAin::GetSingleValue(int chan,RawDataType *value)
{

//TO_DO: use HW API to elicit the data point on the specified channel..
//..and assign it to *value.
//The following code is for getting bogus samples. Remove it in the "real" adaptor.
    *value=*NextPoint++;
    if (NextPoint==Buffer.end())
        NextPoint=Buffer.begin();
    return S_OK;
//END TO_DO

} // end of GetSingleValue()


/////////////////////////////////////////////////////////////////////////////
// InterfaceSupportsErrorInfo()
//
// Function indicates whether or not an interface supports the IErrorInfo..
//..interface. It is created by the wizard.
// Function is NOT MODIFIED by the adaptor programmer.
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CDemoAin::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] =
	{
		&IID_IDemoAin
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
} // end of InterfaceSupportsErrorInfo()
