// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.1.4.3 $  $Date: 2003/08/29 04:44:12 $

// DemoOut.cpp : Implementation of CDemoAout
#include "stdafx.h"
#include "Demo.h"
#include "DemoAout.h"
#include "DemoAdapt.h"

/////////////////////////////////////////////////////////////////////////////
// CDemoAout

/////////////////////////////////////////////////////////////////////////////
// Open()
//
// Function is called by the OpenDevice(), which is in turn called by the engine.
// CDemoAout::Open() function's main goals are ..
// 1)to initialize the hardware and hardware dependent properties..
// 2)to expose pointers to the engine and the adaptor to each other..
// 3)to process the device ID, which is Output by a user in the ML command line.
// The

/////////////////////////////////////////////////////////////////////////////
// CDemoAin()  default constructor
//
// Function performs all the necessary initializations.
// Function MUST BE MODIFIED by the adaptor programmer. It may use HW API calls.
/////////////////////////////////////////////////////////////////////////////
CDemoAout::CDemoAout(): DeviceId(0)
{
//TO_DO: replace the following bogus initialization of the buffer ..
//..by the actual initialization, required by the adaptor program and the HW.
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
HRESULT CDemoAout::Open(IUnknown *Interface,long ID)
{
	RETURN_HRESULT(TBaseObj::Open(Interface));
    EnableSwClocking(true);
    TRemoteProp<long>  pClockSource;
    pClockSource.Attach(_EnginePropRoot,L"ClockSource");
    pClockSource->AddMappedEnumValue(CLOCKSOURCE_SOFTWARE, L"Software");
    pClockSource->RemoveEnumValue(CComVariant(L"internal"));
    pClockSource.SetDefaultValue(CLOCKSOURCE_SOFTWARE);
    pClockSource=CLOCKSOURCE_SOFTWARE;

    TRemoteProp<long>  pOutputType;
//    pOutputType.Attach(_EnginePropRoot,L"OutputType");
//    pOutputType->AddMappedEnumValue(0, L"Simulated");

//TO_DO: 1) Deal with the device ID is necessary.
//		 2) Initialize properties in accordance with the HW requirements..
//..	 3)	Initialize the hardware if necessary
//END TO_DO
    RETURN_HRESULT(InitHwInfo(VT_I2,Bits,4,OUTPUT,CDemoAdapt::ConstructorName,L"SwDemo"));

    return S_OK;
} // end of Open()


/////////////////////////////////////////////////////////////////////////////
// PutSingleValue()
//
// This function gets one single data point form one A/D channel, specified..
//..as a parameter.
// Function is called by GetSingleValues() of the TADDevice class, which..
// ..in turn is called by the engine as a responce to the ML user command GETSAMPLE.
// Function MUST BE MODIFIED by the adaptor programmer.
/////////////////////////////////////////////////////////////////////////////
HRESULT CDemoAout::PutSingleValue(int chan,RawDataType value)
{

//TO_DO: use HW API to elicit the data point on the specified channel..
//..and assign it to *value.
//The following code is for sending bogus samples. Remove it in the "real" adaptor.
    return S_OK;
//END TO_DO

} // end of GetSingleValue()
