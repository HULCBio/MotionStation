// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.4 $  $Date: 2003/10/15 18:32:56 $


// niDisp.h: Definition of the CniDisp class
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_NIDISP_H__D96CE0F3_066A_11D4_A55A_00902757EA8D__INCLUDED_)
#define AFX_NIDISP_H__D96CE0F3_066A_11D4_A55A_00902757EA8D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CniDisp

class ATL_NO_VTABLE CniDisp : 
public IDispatchImpl<IniDisp, &IID_IniDisp, &LIBID_MWNIDAQLib>, 
public ISupportErrorInfo,
public CComObjectRootEx<CComMultiThreadModel>
{
public:
    CniDisp():_id(0),_nChannels(0) {}
    ~CniDisp();
    long Open(short id,DevCaps *DeviceCaps);
    DevCaps* GetDevCaps() {return _DevCaps;}
    long GetOpenCount() {return IdOpenCount[_id];}
    short _id;
    long _nChannels;
private:
    DevCaps*            _DevCaps; // do not delete not owned here

    static long IdOpenCount[17];
    BEGIN_COM_MAP(CniDisp)
        COM_INTERFACE_ENTRY(IDispatch)
        COM_INTERFACE_ENTRY(IniDisp)
        COM_INTERFACE_ENTRY(ISupportErrorInfo)
        END_COM_MAP()
        //DECLARE_NOT_AGGREGATABLE(CniDisp) 
        // Remove the comment from the line above if you don't want your object to 
        // support aggregation. 
        
        //DECLARE_REGISTRY_RESOURCEID(IDR_niDisp)
        // ISupportsErrorInfo
        STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
        virtual HRESULT SetNIDAQError(short status,const IID& iid = IID_IniDisp) =0;
    // IniDisp
public:
	STDMETHOD(AI_Change_Parameter)(short channel, unsigned long paramID, unsigned long paramValue);
	STDMETHOD(AO_Calibrate)(short operation,short EEPROMloc);
	STDMETHOD(Calibrate_E_Series)(unsigned long calOP,unsigned long setOfCalConst,double calRefVolts);
	STDMETHOD(Calibrate_DSA)(unsigned long operation,double refVoltage);
	STDMETHOD(Calibrate_1200)(short calOP,short saveNewCal,short EEPROMloc,short calRevChan,short gndRefChan,short DAC0chan,short DAC1chan,double calRefVolts,double gain);
	STDMETHOD(Select_Signal)(unsigned long signal,unsigned long source,unsigned long sourceSpec);
};

#endif // !defined(AFX_NIDISP_H__D96CE0F3_066A_11D4_A55A_00902757EA8D__INCLUDED_)
