// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions
// $Revision: 1.1.6.1 $  
// $Date: 2003/10/15 18:31:40 $


#ifndef _MSGWND_H
#define _MSGWND_H

#pragma once
#include <comdef.h>
#include <vector>
#include <thread.h>

typedef struct device
{
	DWORD deviceID;
	void* ptr;
} DEV;

typedef struct tsDriverDetails
{
	CComBSTR boardName;
	HINSTANCE driverHandle;
} DRIVERDETAILS;

typedef struct tsDeviceDetails
{
	WORD deviceID;
	int driverLookup;
} DEVICEDETAILS;

class MessageWindow{
public:
	HRESULT OpenAllDrivers();
	char* GetErrorMessage();
	bool GetError();
    MessageWindow(LPCSTR name);
    ~MessageWindow();
    HWND GetHandle() { return _hWnd; }
    static LRESULT CALLBACK MainWndProc(HWND hWnd, unsigned msg, UINT wParam, LONG lParam);
	
	bool IsOpen(DWORD id) 
	{
		CLock lock(_mutex);
		DEVLIST::iterator devStruct = GetIteratorFromID(id);
		return(devStruct!=NULL);
    }
    void *GetDevFromId(DWORD id) 
    {
		CLock lock(_mutex);
		DEVLIST::iterator devStruct = GetIteratorFromID(id);
		if (devStruct==NULL) return NULL;
		return (*devStruct).ptr;
	}
    HRESULT AddDev(DWORD id,void *dev);
    HRESULT DeleteDev(DWORD id);
	
	
	std::vector<DEV>::iterator GetIteratorFromID( DWORD id )
	{
		for(DEVLIST::iterator dit = OpenDevs.begin(); dit != OpenDevs.end(); dit++)
		{
			if ((*dit).deviceID == id)
				return dit;
		}
		return NULL;
	}
	
    static MessageWindow* GetKeithleyWnd()
    {	
		if (TheKeithleyWnd) 
		{
			TheKeithleyWnd->AddRef();
			return TheKeithleyWnd;
		}
		else 
		{
			return new MessageWindow("Keithley Window");
		}
    }
    
    void AddRef() {RefCount++;}
    
	void Release() 
    {
		if (!--RefCount) 
		{
			TheKeithleyWnd=NULL;
			delete this ; 
		}
    }

	void LoadDeviceDetails();

    HRESULT OpenDriverLINXDriver( CComBSTR driverName, HINSTANCE *handle );
    void CloseDriverLINXDriver( HINSTANCE handle );
    UINT m_numberOfDevices;
	std::vector<DEVICEDETAILS> m_deviceMap;
	std::vector<DRIVERDETAILS> m_driverMap;
    
private:
	CMutex _mutex;
    static MessageWindow* TheKeithleyWnd;
	char m_errorMessage[60];
	typedef std::vector<DEV> DEVLIST;
    DEVLIST OpenDevs;
    bool _bClassRegistered;
    bool _ErrorFlag;
    HWND _hWnd;
    bstr_t _name;    // device type
	
    // Include Thread and Window in the message window class (!)
    Thread *_thread;
    int _isDying;
    CEvent _windowEvent;
    void CreateMyWindow();
    static unsigned WINAPI ThreadProc(void* pArg);
    int RefCount;
};

#endif