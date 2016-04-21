// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:33:57 $


#include "stdafx.h"
#include <comdef.h>
#include "errors.h"
#include "wavein.h"
#include <mmsystem.h>
#include <vector>
#include <adaptorkit.h>
#include "util.h"
//
// This function is called by both AI and AO and creates the output for 
// DaqHwInfo('winsound')
//
// called when a channel is reordered or deleted
STDMETHODIMP CSoundDevice::ChildChange(DWORD typeofchange,NESTABLEPROP *pChan)
{
    if ((typeofchange & 0xFF)==REINDEX_CHILD) // mask off the START_CHANGE flag
        return E_CHAN_INDEX;
    if (!pChan)
    {
        return S_OK; // if no channel return
    }
    long numChans;
    HRESULT hRes = _EngineChannelList->GetNumberOfChannels(&numChans);
    if (FAILED(hRes)) return hRes;        
    int chan=pChan->Index;
    CComPtr<IPropContainer >  cont;
    GetChannelContainer(chan-1, &cont);

    switch (typeofchange & 0xff)
    {
    case ADD_CHILD:
        
        if (pChan->Index>2) 
            return E_EXCEEDS_MAX_CHANNELS;
        if (numChans!=_nChannels)
            _nChannels = numChans;
    
        if (chan==1 && numChans==1)
        {            

	        if (pChan->HwChan!=chan)
		        return  E_CHAN_ORDER;    

            CComVariant val;            
           
            V_VT(&val) = VT_BSTR;            
            V_BSTR(&val) = CComBSTR(L"Mono").Detach();            
            
            hRes = cont->put_MemberValue(CComBSTR(L"channelname"), val);
            if (FAILED(hRes)) return hRes;          
        }
        else if (chan==2 && numChans==2)
        {
            CComVariant val;   
			
	        if (pChan->HwChan!=chan) 
                return E_CHAN_INUSE; 

            // rename the first channel          
            CComQIPtr<IPropContainer, &__uuidof(IPropContainer)>  pCont;
            hRes = GetChannelContainer(0, &pCont);
            if (FAILED(hRes)) return hRes;
            
            hRes = pCont->get_MemberValue(CComBSTR(L"channelname"), &val);
            if (FAILED(hRes)) return hRes;
           
            // if name is still mono, change it to Left            
            if (bstr_t(val)==bstr_t("Mono"))   
            {                            
                val=L"Left";
                hRes=pCont->put_MemberValue(CComBSTR(L"channelname"), val);
                if (FAILED(hRes)) return hRes;
            }

            // name channel 2
            val=L"Right";
            hRes=cont->put_MemberValue(CComBSTR(L"channelname"), val);
            if (FAILED(hRes)) return hRes;
            
        }      
        break;
        
    case DELETE_CHILD:

        // if we are deleting channel 2, rename 1 to Mono if still Left.
        if (numChans==2 && pChan->Index==2)
        {
            CComVariant val;

            // rename the first channel
            // pCont is a pointer to the IPropContainer interface.
            CComQIPtr<IPropContainer, &__uuidof(IPropContainer)>  pCont;
            hRes = GetChannelContainer(0, &pCont);
            if (FAILED(hRes)) return hRes;

			// Get the ChannelName.
            hRes = pCont->get_MemberValue(CComBSTR(L"channelname"), &val);
            if (FAILED(hRes)) return hRes;
           
			// If the name is still Left, rename to Mono otherwise leave alone.
            if (bstr_t(val)==bstr_t("Left"))  {            
                val = L"Mono";
                hRes=pCont->put_MemberValue(CComBSTR(L"channelname"), val);
                if (FAILED(hRes)) return hRes;
            }
        }
        else if (numChans==2 && pChan->Index==1)
        {
            return E_DEL_CHAN_ERR;
        }
        _nChannels--;
        break;
    }

    return S_OK;

}

STDMETHODIMP CSoundDevice::AllocBufferData(BUFFER_ST* Buf) 
{    
    RETURN_HRESULT(CmwDevice::AllocBufferData(Buf));
    if (Buf->ptr==NULL) return E_OUTOFMEMORY;
    
    WaveHeader *hdr=new WaveHeader();
    if (hdr==NULL) return E_OUTOFMEMORY;

    hdr->lpData = (char *) Buf->ptr;
    hdr->dwBufferLength = Buf->Size;
    hdr->dwFlags = 0;    // must be set to zero
    hdr->dwLoops = 0;               
    
    Buf->dwAdaptorData=(DWORD)hdr;
    
    return S_OK;
}   
// This is called to snap the SampleRate when using Standard SampleRates.
long CSoundDevice::SnapSampleRates(double newValue)
{


    // Define the valid sampleRates.
    long validSR[] = {8000, 11025, 22050, 44100};


    // Loop through and find the next highest standard samplerate.
    for (int i=0; i<(sizeof(validSR)/sizeof(long)); i++){
        if (newValue <= validSR[i] + 0.01*validSR[i]){
            return validSR[i];
	}
    }
    return 44100;
}

HRESULT CSoundDevice::SetSampleRateRange(long min,long max)
{
    CComVariant minVar(min),maxVar(max);
    RETURN_HRESULT(_cSamplesPerSec.SetRange(minVar,maxVar));
    // set the daqHwInfo value which depends on the MaxSampleRate property
    RETURN_HRESULT(GetHwInfo()->put_MemberValue(L"maxsamplerate",maxVar));
    RETURN_HRESULT(GetHwInfo()->put_MemberValue(L"minsamplerate",minVar));
    return S_OK;   
}
