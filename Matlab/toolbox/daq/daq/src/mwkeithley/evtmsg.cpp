// evtmsg.cpp : Message Handling Implementation for the Keithley Adaptor
// $Revision: 1.1.6.2 $
// $Date: 2003/12/04 18:39:35 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#include "stdafx.h"
#include "daqmex.h"
#include "messagew.h"
#include "DaqmexStructs.h"
#include "drvLINX.h"
#include "keithleyain.h"
#include "keithleyaout.h"
#include "keithleypropdef.h"

static UINT WM_DRIVERLINX = RegisterWindowMessage(_T(DL_MESSAGE));
//////////////////////////////////////////////////////////////////////////
// MainWndProc()
// 
// Window message handler. Receives DriverLINX and normal window messages.
//////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK MessageWindow::MainWndProc(HWND hWnd, unsigned msg, UINT wParam, LONG lParam)
{   
	const UINT DeviceId = getDevice(lParam);
	MessageWindow* Window=(MessageWindow*)GetWindowLong(hWnd, GWL_USERDATA);
 
    // Was the Message Posted By DriverLINX?
	if (msg == WM_DRIVERLINX)
	{
		Ckeithleyain *ai = NULL;
		Ckeithleyaout *ao = NULL;
		switch(getSubSystem(lParam))
			{
			case AO:
				ao = (Ckeithleyaout*)Window->GetDevFromId(analogoutputMask + DeviceId);
				if (ao==NULL) 
				{
					ATLTRACE("KEITHLEY AO callback on device id %d after stopping: Msg code was %d\n",DeviceId, wParam); 
					return 1;
				}
				ao->ReceivedMessage(wParam, lParam);
				break;
			case AI:
				ai = (Ckeithleyain*)Window->GetDevFromId(analoginputMask + DeviceId);
				if (ai==NULL) 
				{
					ATLTRACE("KEITHLEY AI callback on device id %d after stopping: Msg code was %d\n",DeviceId, wParam); 
					return 1;
				}
				ai->ReceivedMessage(wParam, lParam);
				break;
			case DO:
				break;
			case DI:
				break;
			}
		return 0;

	}

	// Handle normal window messages
	switch (msg)
	{
	case WM_DESTROY:
		//Destroy Window
		PostQuitMessage(0);
		break;
	default:
		//Pass If Unprocessed
		return DefWindowProc(hWnd, msg, wParam, lParam);
	}
	return 0;
}

MessageWindow *MessageWindow::TheKeithleyWnd=NULL;

////////////////////////////////////////////////////////////////////////
// MessageWindow()
// 
// Registers the Keithley window class and creates the message window 
// thread. The message window is actually created by the thread 
// processing routine.
////////////////////////////////////////////////////////////////////////
MessageWindow::MessageWindow(LPCSTR name) : 
_ErrorFlag(false), 
_bClassRegistered(false),
RefCount(1)
{
    TheKeithleyWnd=this;
	WNDCLASS wc;
    ATLTRACE("Created MessageWindow Class\n");
	LoadDeviceDetails();
	OpenAllDrivers();
    // Save the window Name
	_name = name;
	HINSTANCE _hInst = _Module.GetModuleInstance();
    wc.lpfnWndProc = MainWndProc;
    wc.style          = 0;
    wc.hInstance      = _hInst;
	wc.hIcon          = 0;
	wc.hCursor        = 0;
    wc.hbrBackground  = 0;
    wc.lpszMenuName   = NULL;
    wc.lpszClassName  = _name;
    wc.cbWndExtra     = 0;
    wc.cbClsExtra     = sizeof(long*);

    if (!_bClassRegistered)
    {
        if (!RegisterClass(&wc)) 
        {
            _bClassRegistered=false;
            
            if (!GetClassInfo(_hInst, _name, &wc))  // is class already registered
            {
				_ErrorFlag = true;
				sprintf(m_errorMessage, "Could not Create Window, Class already registered.");
            }            
        }
        else
            _bClassRegistered=true;
    }
    
    _isDying = 0;
    _thread = new Thread(ThreadProc,this);
    _windowEvent.Reset();
    _thread->Resume();

    ATLTRACE("My thread's handle is 0x%x.\n",_thread->GetId());

    // For Win98, don't use TIME_CRITICAL, but bump up priority by 2 levels
    _thread->SetThreadPriority(GetThreadPriority(GetCurrentThread())+2);
	_windowEvent.Wait();
}

//////////////////////////////////////////////////////////////////////////
// CreateMyWindow()
// 
// The code to create the Keithley message window. This window is used by
// all running subsystems of all Keithley devices.
//////////////////////////////////////////////////////////////////////////
void MessageWindow::CreateMyWindow()
{
    ATLTRACE("Really Created Window\n");
    _hWnd = CreateWindow (
        _name,           // class name
        _name,           // caption
        WS_DISABLED,    // style bits
        CW_USEDEFAULT,  // x position
        CW_USEDEFAULT,  // y position
        CW_USEDEFAULT,  // x size
        CW_USEDEFAULT,  // y size
        (HWND)NULL,     // parent window
        (HMENU)NULL,    // use class menu
        _Module.GetModuleInstance(),         // instance handle
        (LPSTR)NULL     // no params to pass on
        );
    
	if (_hWnd==NULL)
    {
		_ErrorFlag = true;
		sprintf(m_errorMessage, "Could not Create Window, CreateWindow returned a NULL window Handle.");
    }
    else
    {
        SetWindowLong(_hWnd, GWL_USERDATA, reinterpret_cast<DWORD>(this));
    }
}

//////////////////////////////////////////////////////////////////////////////
// AddDev()
//
// Used to maintain a list of running device IDs and subsytems.
//////////////////////////////////////////////////////////////////////////////
HRESULT MessageWindow::AddDev(DWORD id,void *dev)
{
    CLock lock(_mutex);
	DEVLIST::iterator devStruct = GetIteratorFromID(id);
	if (devStruct==NULL)
	{
		DEV newStruct;
		newStruct.deviceID = id;
		newStruct.ptr = dev;
		OpenDevs.push_back(newStruct);
	    return S_OK;
	}
	else
	{
		return E_FAIL;
	}
}

//////////////////////////////////////////////////////////////////////////////
// DeleteDev()
//
// Used to maintain a list of running device IDs and subsytems.
//////////////////////////////////////////////////////////////////////////////
HRESULT MessageWindow::DeleteDev(DWORD id)
{
    CLock lock(_mutex);
	DEVLIST::iterator devStruct = GetIteratorFromID(id);
	if (devStruct==NULL)
	{
		return E_FAIL;
	}
	else
	{
		OpenDevs.erase(devStruct);
	    return S_OK;
	}
}

MessageWindow::~MessageWindow()
{    
    ATLTRACE("Entered Window Destructor\n");
    HINSTANCE _hInst = _Module.GetModuleInstance();
    
    ATLTRACE("Killing Thread\n");
    _isDying++;
    SendMessage(_hWnd,WM_CLOSE,0,0);
    _thread->WaitForDeath();
	delete _thread;

	// Loop Through and close all the drivers
   	for(std::vector<DRIVERDETAILS>::iterator it = m_driverMap.begin(); it != m_driverMap.end(); it++)
    {
		SelectDriverLINX((*it).driverHandle);
		CloseDriverLINXDriver((*it).driverHandle);
		(*it).driverHandle = NULL;
	}
	m_driverMap.clear();

    DestroyWindow(_hWnd);    
    if (_bClassRegistered)  
        UnregisterClass(_name, _hInst);
#ifdef _DEBUG
    if (OpenDevs.size()>=1)
    {
        long opencount=reinterpret_cast<long&>(OpenDevs.front());
        if (opencount>0)
        {
            _RPT0(_CRT_ERROR,"Deleting Message window with open devices\n");
            OpenDevs.clear();
        }
    }
#endif

	//DEBUG: ATLTRACE("Calling DumpUnfreed() in messageWindow.\n");
	//DEBUG: DumpUnfreed();
}


/////////////////////////////////////////////////////////////////////////////////
// ThreadProc()
//
// 
unsigned WINAPI MessageWindow::ThreadProc(void* pArg)
{
    MSG msg;
    try 
    {
		std::vector<HINSTANCE> driverLINXHandles;
		CoInitialize(NULL);
		MessageWindow* thisptr=(MessageWindow*) pArg;
		thisptr->CreateMyWindow();	
		
		// No need to restore the window focus since DriverLINX is already open.
		for(std::vector<DRIVERDETAILS>::iterator itDD = thisptr->m_driverMap.begin(); 
				itDD != thisptr->m_driverMap.end(); itDD++)
		{
			HINSTANCE hinst = NULL;	
			thisptr->OpenDriverLINXDriver( (*itDD).boardName, &hinst);
			driverLINXHandles.push_back(hinst);
		}
		thisptr->_windowEvent.Set();
		
		// Main message loop:
		ATLTRACE("Entering message loop in thread.\n");
		while (!thisptr->_isDying) 
		{
			GetMessage(&msg, NULL, 0, 0);
			TranslateMessage(&msg);    
			DispatchMessage(&msg);
		}
		
		ATLTRACE("Passed the end of the thread loop. Closing DLinx in the thread.\n");
		for( std::vector<HINSTANCE>::iterator itHI = driverLINXHandles.begin(); 
				itHI != driverLINXHandles.end(); itHI++)
		{
			SelectDriverLINX((*itHI));
			CloseDriverLINX((*itHI));
		}
		driverLINXHandles.clear();
		CoUninitialize();
    }
    catch (...)
    {
        _RPT0(_CRT_ERROR,"***** Exception in Keithley Thread Terminating Thread\n");
    }
    return 0;
}

bool MessageWindow::GetError()
{
	return _ErrorFlag;
}

char* MessageWindow::GetErrorMessage()
{
	return m_errorMessage;
}

/////////////////////////////////////////////////////////////////////////////
// OpenDriverLINXDriver()
//
// This function creates the DriverLINX driver and links it to the particular 
// hardware series dll.
/////////////////////////////////////////////////////////////////////////////
HRESULT MessageWindow::OpenDriverLINXDriver( CComBSTR driverName, HINSTANCE *handle )
{
	USES_CONVERSION;
    if ((*handle) == NULL)
    {
		ATLTRACE("Opening DriverLINX\n");
	
		// Store the current focus window to set it back after the call.
		HWND fgWindow = GetForegroundWindow();
		*handle = OpenDriverLINX( fgWindow, W2A(driverName.m_str) );
		
		SetForegroundWindow(fgWindow);
		if ((*handle) == NULL )
			return E_FAIL;
		else
			return S_OK;
    }
	return E_FAIL;
}

/////////////////////////////////////////////////////////////////////////////
// CloseDriverLINXDriver()
//
// Closes the DriverLINX driver.
////////////////////////////////////////////////////////////////////////////
void MessageWindow::CloseDriverLINXDriver( HINSTANCE handle )
{
    if (handle != NULL)
    {
		ATLTRACE("Closing DriverLINX in MessageWindow class.\n");
		CloseDriverLINX(handle);
    }
}


/////////////////////////////////////////////////////////////////////////////
// LoadDeviceDetails()
//
//
////////////////////////////////////////////////////////////////////////////
void MessageWindow::LoadDeviceDetails()
{
	// The commented code below is the preferred approach of finding all installed devices,
	// Does not appear to work, so instead search the registry.
	/*
	CoInitialize(NULL);
	char driverLinxGroup[] = "Scientific_Software_Tools\\DriverLINX";

	SSTConf::IDriverLINXInfoLocatorPtr labInfoLocator("DriverLINX.ConfigLocator");
	SSTConf::IDriverGroupInfoPtr driverGroupInfo;

	driverGroupInfo = labInfoLocator->DRIVERGROUPINFO(driverLinxGroup);

	SSTConf::IDriverInfoPtr driverInfo;
	CComBSTR diKey;
	CComVariant diValue;

	if(driverGroupInfo)
	{
		// We have a valid driverGroupInfo entity. What next?
		driverGroupInfo->get_Key(&diKey);
		driverGroupInfo->get_Value(&diValue);
	}
	*/
	HKEY hMainKey = HKEY_LOCAL_MACHINE; // We want to start from the root as this is where the PROGID's are
	HKEY hSubKey;
	
	m_numberOfDevices = 0;
	
	std::vector<int> installedIDs;
	
	if (::RegOpenKey(hMainKey, "HARDWARE", &hSubKey) == ERROR_SUCCESS)
	{
		HKEY hSubKey1;
		if(::RegOpenKey(hSubKey, "DEVICEMAP", &hSubKey1) == ERROR_SUCCESS)
		{
			HKEY hSubKey2;
			if(::RegOpenKey(hSubKey1, "DriverLINX", &hSubKey2) == ERROR_SUCCESS)
			{
				TCHAR subKeyName[256]; // Store the subkey names here
				int Loop = 0;
				while(::RegEnumKey(hSubKey2, Loop, subKeyName, 256) == ERROR_SUCCESS)
				{
					DRIVERDETAILS driverDetails;
					driverDetails.driverHandle = NULL;
					driverDetails.boardName = subKeyName;
					HKEY hSubKey3;
					if(::RegOpenKey(hSubKey2, subKeyName, &hSubKey3) == ERROR_SUCCESS)
					{
						int idLoop = 0;
						TCHAR idSubKey[50];
						while(::RegEnumKey(hSubKey3, idLoop, idSubKey, 50) == ERROR_SUCCESS)
						{
							int id;
							sscanf(idSubKey, "Device%d", &id);							
							installedIDs.push_back(id);						
							idLoop++;
						}
					}
					::RegCloseKey(hSubKey3);
					int lastID = -1;
					int thisID;
					for (unsigned int i = 0; i < installedIDs.size(); i++)
					{
						thisID = 999999;
						for(unsigned int j = 0; j < installedIDs.size(); j++)
						{
							int current = installedIDs[j];
							if((installedIDs[j] > lastID) && (installedIDs[j] < thisID))
							{
								thisID = installedIDs[j];
							}
						}
						
						DEVICEDETAILS deviceDetails;
						deviceDetails.deviceID = thisID;
						deviceDetails.driverLookup = Loop;
						m_deviceMap.push_back(deviceDetails);
						m_numberOfDevices++;
						lastID = thisID;
					}
					installedIDs.clear();
					m_driverMap.push_back(driverDetails);
					Loop++;
				}
			}
			else 
			{
			//	::RegCloseKey(hSubKey1);
			//	::RegCloseKey(hSubKey);
			}
			::RegCloseKey(hSubKey2);
		}
		else
		{
			//::RegCloseKey(hSubKey);
		}
		::RegCloseKey(hSubKey1);
	}
	::RegCloseKey(hSubKey);
}


HRESULT MessageWindow::OpenAllDrivers()
{
 	// Loop through the Drivers and open them
	for(std::vector<DRIVERDETAILS>::iterator it = m_driverMap.begin(); it != m_driverMap.end(); it++)
    {
		OpenDriverLINXDriver( (*it).boardName, &((*it).driverHandle));
	}
	return S_OK;
}