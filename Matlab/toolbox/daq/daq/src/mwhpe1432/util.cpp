// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:31 $



#include <stdafx.h>
#include <stdio.h>
#include <daqmex.h>
#include <comdef.h>
#include <hpe1432.h>
#include <daqmexstructs.h>
#include "util.h"
#include "errors.h"
#include "sarrayaccess.h"


//
// This function is called by both AI and AO and creates the output for 
// DaqHwInfo('hpe1432')
//

int Find1432Boards()
{
    ViChar rsrc[255];
    // Need to initialize for all hardware at once.
    // get info on installed hardware.
    
    // 0        (input ) - not used so can be 0.
    // addList  (output) - An array to hold VXI logical addresses of HP E1432 modules.
    // 255      (input ) - the size of addList;
    // numFound (output) - the number of HP E1432 modules found.
    // rsrc -   (output) - resource name for the first module found.
    // 255 -    (input ) - size of the rsrc buffer.
    ViStatus findStatus = hpe1432_find(0, addList, 255, &numFound, rsrc, 255);
    if (findStatus != 0){
        return E_DEVICE_NOT_FOUND;
    }
    return 0;
}

ViSession GlobalInfo::globalSession = NULL;
//long globalIdList[] = {0};
long GlobalInfo::globalCount = 0;


HRESULT GlobalInfo::GetGlobalSession(ViSession &_session)
{
    int i;
    if (globalSession == NULL){
        
        if (numFound == 0){
            DAQ_CHECK(Find1432Boards());
        }
        
        // Create a string VXI0::8,32::INSTR from all the available hardware ids.
        wchar_t idBase[400];
        wchar_t *idList=idBase;
        
        // Build up the string VXI+chasis+::.
        idList+=swprintf(idList, L"VXI");
        //idList+=swprintf(idList, L"%d", _chasis);
        idList+=swprintf(idList, L"::");
        
        // Add the available hardware ids to the string.
        for (i=0;i<numFound;i++){
            idList+=swprintf(idList, L"%d", addList[i]);	
            if (i<numFound-1)
                idList+=swprintf(idList, L",");	
        }   
        
        // Close out the string.
        wcscat(idList,L"::INSTR");  
        
        // Convert wchar_t to a char which can be used in the hpe1432_init call.
        char initList[400];
        wcstombs(initList, idBase, 400);
        
        ViStatus openStatus = hpe1432_init(initList, 0,1,&_session);
        if (openStatus != 0){
            return E_DEVICE_NOT_FOUND;
        }
        
        // Store away the session handle.
        globalSession = _session;
        
        // Create vector of id information.  [id numAI numAO scaleFactor].
        CalculateIdList();
        
        // Initialize variables.
        long numSource;
        long numInput;
        long numTach;
        long numTotal;
        
        DAQ_CHECK(hpe1432_getNumChans(_session, &numTotal, &numInput, &numSource, &numTach));
        
        ViInt32 *chans;
        chans = new ViInt32[numSource+numInput];
        for (i=0;i<numSource;i++){
            chans[i] = i+4097;
        }
        for (i=0;i<numInput;i++){
            chans[i+numSource] = i+1;
        }
        
        ViInt32 group;
        
        // Unactivate all channels.
        DAQ_CHECK(hpe1432_createChannelGroup(_session, numSource+numInput, chans, &group));
        DAQ_CHECK(hpe1432_setActive(_session, group, HPE1432_CHANNEL_OFF));
        
        delete [] chans;
        
        // No longer need the channel group and it can be deleted.
        DAQ_CHECK(hpe1432_deleteChannelGroup(_session, group));
        
    }else{
        // Already initialized.  Use stored session handle.
        _session=globalSession;
    }
        return S_OK;
}

void GlobalInfo::CalculateIdList(){
    
	// Return harsware configuration information.
    ViInt32 *configInfo = new ViInt32[27*numFound];        
    memset(configInfo, 0, sizeof(configInfo));
    
	// configInfo (output) - returns 27 numbers for each module. 
    ViStatus vierr=hpe1432_getHWConfig(0, numFound, addList, configInfo);    
    
	// Translate the error message.
	if(vierr) {            
        TCHAR  errStr[401];
        hpe1432_error_message(globalSession,vierr,errStr);                        
        hpe1432_errorDetails(globalSession, errStr, 400);
        ATLTRACE("getHWConfig error detail: %s\n", errStr);                        
    }    

	for (int j=0; j<numFound; j++){
		// Device id.
		globalIdList.push_back(addList[j]);

		// Analog Input 
		globalIdList.push_back(configInfo[21+(27*j)]);

		// Analog Output.
		globalIdList.push_back(configInfo[22+(27*j)]);

		// Scale Factor.
		switch (configInfo[6+(27*j)]) {
		case HPE1432_SCA_ID_VIBRATO:
			globalIdList.push_back(1);
			break;
		case HPE1432_SCA_ID_SONATA:
			globalIdList.push_back(2);
			break;
		case -842150451:
			globalIdList.push_back(2);
			break;
		default:
			globalIdList.push_back(1);
			break;
		}	
	}

	delete [] configInfo;
}

void GlobalInfo::rmDev(int id){
	// Decrement the installedID count.
	if (id < static_cast<int>(_installedCallbackIDs.size()))
	{
		_installedCallbackIDs[id] = _installedCallbackIDs[id]-1;

		// A sanity check.  This should never be less than zero.
		if (_installedCallbackIDs[id] < 0)
		{
			_installedCallbackIDs[id] = 0;
		}

		// Another sanity check.  Everything should be zero because there are no objects left.
		for (unsigned int i = 0; i<_installedCallbackIDs.size();i++){
			_installedCallbackIDs[i] = 0;
		}
	}
}

GlobalInfo::~GlobalInfo()
{
    if (InterlockedDecrement(&globalCount)==0){
        // Close the VXI Plug&Play library and release all resources.
        hpe1432_deleteAllChanGroups(globalSession);
        hpe1432_close(globalSession);
        globalCallbackInstalled = false;
        globalSession = NULL;
        rmDev(0); // UserId[0]);

    }
}
