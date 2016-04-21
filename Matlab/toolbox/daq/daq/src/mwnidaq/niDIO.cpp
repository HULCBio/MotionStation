// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.5 $  $Date: 2003/10/15 18:32:53 $


// niDIO.cpp : Implementation of CMwnidaqApp and DLL registration.

#include "stdafx.h"
#include "mwnidaq.h"
#include <nidaq.h>
#include "niDIO.h"
#include "niutil.h"
#include <stdio.h>
/////////////////////////////////////////////////////////////////////////////
//

HRESULT CniDIO::Open(IDaqEngine *engine, int id,DevCaps* DeviceCaps)
{
    // assign the engine access pointer
    CmwDevice::Open(engine);

    if (id<1) return E_INVALID_DEVICE_ID;
    DAQ_CHECK(CniDisp::Open(id,DeviceCaps));
    DAQ_CHECK(Initialize());


    
    //CComPtr<IProp> prop;     
    //CComQIPtr<IPropContainer, &__uuidof(IPropContainer)>  pCont;   
    
    // common properties  
    
        SetDaqHwInfo();

    ATLTRACE("Dio Initialization complete\n");
        
    return S_OK;
}

int CniDIO::Initialize()
{
		    
    if (!GetDevCaps()->HasDIO()) 
        return E_DIO_UNSUPPORTED;
    
    return S_OK;	

}



STDMETHODIMP CniDIO::ReadValues(LONG NumberOfPorts, LONG * PortList, ULONG * Data)
{
    if (Data == NULL)
        return E_POINTER;
    for (int i=0;i<NumberOfPorts;i++)
    {
        short val;
        DAQ_CHECK(DIG_In_Port(_id,(short)PortList[i],&val));
        Data[i]=val;
    }
    return S_OK;
}

STDMETHODIMP CniDIO::WriteValues(LONG NumberOfPorts, LONG * PortList, ULONG * Data, ULONG * Mask)
{
    for (int i=0;i<NumberOfPorts;i++)
    {
        if (Mask[i]==0xff)
        {
            DAQ_CHECK(DIG_Out_Port(_id,(short)PortList[i],(short)Data[i]));
        }
        else
        {
            for (int j=0;j<8;j++)
            {
                if (Mask[i] & (1<<j))
                {
                    DAQ_CHECK(DIG_Out_Line(_id,(short)PortList[i],j,(short)(Data[i]>>j) & 1));
                }
            }
        }
    }
    return S_OK;
}

STDMETHODIMP CniDIO::SetPortDirection(LONG Port, ULONG DirectionValues)
{
    // this code as is will only work on e series boards
    if (DirectionValues==0)
    {
        DAQ_CHECK(DIG_Prt_Config(_id,(short)Port,0,0));
    }
    else if (DirectionValues==0xff)
    {
        DAQ_CHECK(DIG_Prt_Config(_id,(short)Port,0,1));
    }
    else 
    {
        for (int i=0;i<8;i++)
        {
         DAQ_CHECK(DIG_Line_Config(_id,(short)Port,i,(short)(DirectionValues>>i) & 1));
        }           
    }
    return S_OK;
}

HRESULT CniDIO::SetDaqHwInfo()
{
    //CComPtr<IProp> prop;        
    
    // hwinfo property container
   
    // device name
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"devicename"), CComVariant(GetDevCaps()->deviceName)));	
    
    // driver name
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"adaptorname"),CComVariant(L"nidaq")));
      
    // device Id
    wchar_t idStr[8];
    swprintf(idStr, L"%d", _id);
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"id"), CComVariant(idStr)));		

    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totallines"),CComVariant(GetDevCaps()->nDIOLines)) );

    if (GetDevCaps()->IsESeries() || GetDevCaps()->IsDSA() || GetDevCaps()->IsAODC())
    {
        if ( GetDevCaps()->nDIOLines==8)
        {
            // directions 0:in 1:out 2:in/out 
            RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portdirections"),CComVariant(2L)) );
            RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portids"),CComVariant(0L)) );
            // port line config 0:port 1: line
            RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlineconfig"),CComVariant(1L)) );
            RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlinemasks"),CComVariant(255L)) );
        }
        else
        {
            long portdir[]={2, 2, 2 ,2};
            long ids[]={0, 2, 3, 4};
            long linecfg[]={1, 0, 0, 0};
            long linemasks[]={255, 255, 255, 255} ;
            CComVariant var;
            int size=max(GetDevCaps()->nDIOLines/8,sizeof(portdir)/sizeof(portdir[0]));
             // directions 0:in 1:out 2:in/out 
            CreateSafeVector(portdir,size,&var);
            RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portdirections"),var) );

            CreateSafeVector(ids,size,&var);
            RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portids"),var) );

            // port line config 0:port 1: line
            CreateSafeVector(linecfg,size,&var);
            RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlineconfig"),var) );
            CreateSafeVector(linemasks,size,&var);
            RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlinemasks"),var) );
        }
    }
    else
    {

        CComVariant var;
        
        long ports=GetDevCaps()->nDIOLines/8;
        if (ports*8!=GetDevCaps()->nDIOLines)
        {
            ports++;
            _RPT0(_CRT_WARN,"Port has less then 8 lines\n");
        }
        SAFEARRAY *ps = SafeArrayCreateVector(VT_I4, 0, ports );
        if (ps==NULL) E_SAFEARRAY_ERR;    
        // set the data type and values
        V_VT(&var)=VT_ARRAY | VT_I4;
        V_ARRAY(&var)=ps;
        TSafeArrayAccess <long> ar(&var);  // used to access the array
        int i;
        if (GetDevCaps()->Is700())
        {
            ar[0]=1; // Port 0 is output
            ar[1]=0; // Port 1 is input
        }
        else
        {
        // all ports are bydirectional
        for (i=0;i<ports;i++)
            ar[i]=2;
        }
        RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"portdirections",var) );

        for (i=0;i<ports;i++)
            ar[i]=i;
        RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"portids",var) );
        
        // port line config 0:port 1: line
        for (i=0;i<ports;i++)
            ar[i]=0;
        RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"portlineconfig",var) );

        for (i=0;i<ports;i++)
            ar[i]=255;  //does not work for <8 bit ports...?
        RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"portlinemasks",var) );
    }

    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"vendordriverdescription",
        CComVariant(L"National Instruments Data Acquisition Driver")));

    char version[16];
    GetDriverVersion(version);    
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"vendordriverversion",CComVariant(version)));
    return S_OK;
}
