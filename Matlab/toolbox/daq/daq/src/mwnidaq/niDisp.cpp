// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.5 $  $Date: 2003/12/04 18:40:05 $


// niDisp.cpp : Implementation of CMwnidaqApp and DLL registration.

#include "stdafx.h"
#include <nidaq.h>	// required for NI-DAQ
#include <nidaqcns.h>	// required for NI-DAQ
#include "daqtypes.h"
#include "niutil.h"
#include "mwnidaq.h"
#include "niDisp.h"

#ifdef _DEBUG
#define PROCESS_NIDAQ_STATUS(_function) SetNIDAQError(static_cast<short>(_CheckNIResult(_function,#_function,__FILE__,__LINE__)))
#else
#define PROCESS_NIDAQ_STATUS(_function) SetNIDAQError(_function)
//#define DAQ_TRACE(_function) _function
#endif


/////////////////////////////////////////////////////////////////////////////
//


STDMETHODIMP CniDisp::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IniDisp,
	};

	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


CniDisp::~CniDisp()
{
    if (_id!=0)
        InterlockedDecrement(&IdOpenCount[_id]);
}

long CniDisp::Open(short id,DevCaps *DeviceCaps)
{
    if (IdOpenCount[id]==0)
    {    
        short deviceCode;
        DAQ_CHECK(Init_DA_Brds(id, &deviceCode));
    }
    InterlockedIncrement(&IdOpenCount[id]);
    _id=id;
    _DevCaps=DeviceCaps;
    return S_OK;
}

long CniDisp::IdOpenCount[17]={0};

STDMETHODIMP CniDisp::Select_Signal(unsigned long signal, unsigned long source, unsigned long sourceSpec)
{
	// TODO: Add your implementation code here
    i16 result=::Select_Signal(_id,signal,source,sourceSpec);
    if (result!=0)
    {
        return SetNIDAQError(result);
    }
    else
	return S_OK;
}

STDMETHODIMP CniDisp::Calibrate_1200(short calOP, short saveNewCal, short EEPROMloc, short calRevChan, short gndRefChan, short DAC0chan, short DAC1chan, double calRefVolts, double gain)
{

    DAQ_CHECK(::Calibrate_1200(_id, calOP,  saveNewCal,  EEPROMloc,  calRevChan,  gndRefChan,  DAC0chan,  DAC1chan,  calRefVolts,  gain));
	return S_OK;
}

STDMETHODIMP CniDisp::Calibrate_DSA(unsigned long operation, double refVoltage)
{
    DAQ_CHECK(::Calibrate_DSA(_id, operation, refVoltage));
    return S_OK;
}

STDMETHODIMP CniDisp::Calibrate_E_Series(unsigned long calOP, unsigned long setOfCalConst, double calRefVolts)
{
	// TODO: Add your implementation code here
    DAQ_CHECK(::Calibrate_E_Series(_id, calOP,  setOfCalConst,  calRefVolts));

	return S_OK;
}

STDMETHODIMP CniDisp::AO_Calibrate(short operation, short EEPROMloc)
{
    DAQ_CHECK(::AO_Calibrate(_id, operation,  EEPROMloc));

	return S_OK;
}

STDMETHODIMP CniDisp::AI_Change_Parameter(short channel, unsigned long paramID, unsigned long paramValue)
{
	// TODO: Add your implementation code here
        return PROCESS_NIDAQ_STATUS(::AI_Change_Parameter(_id, channel,  paramID,  paramValue));
}
