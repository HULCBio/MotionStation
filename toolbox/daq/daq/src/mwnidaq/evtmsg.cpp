//
// EVTMSG.CPP
// Event message handling for NI-DAQ
// Copyright 1998-2004 The MathWorks, Inc.
// $Revision: 1.4.4.2 $  $Date: 2004/04/08 20:49:43 $
//
#include "stdafx.h"
//#include <stdio.h>
//#include "evtmsg.h"
#include "daqmex.h"
#include "messagew.h"
#include "DaqmexStructs.h"
#include "nia2d.h"
#include "nid2a.h"
#include "niutil.h"

#include <nidaq.h>
#include <nidaqcns.h>





/*
 * Clear out any configured messages
 */
void ClearEventMessages(short id)
{
    Config_DAQ_Event_Message(id, CLR_MSGS, "", 0, 0, 
	0L, 0L, 0L, 0L, NULL, 0, 0L);
}


/*
 * Convert a list of channels into a string for NI-DAQ
 * Turn [0 2 4 6] into "SS0,SS2,SS4,SS6" (SS is the subsystem type passed in)
 * This also supports the (:) operator for consecutive channels:
 * [0:4] => SS0:4
 */
char *ChanList2Str(short *chanList, int numChans, SSType ss, char *chanStr)
{
    _ASSERT(chanList!=NULL);
    char *subsys;    
    chanStr[0]='\0';

    switch (ss)
    {
    case AI:
        subsys="AI";	
	break;
    case AO:
        subsys="AO";
	break;
    case DIO:
	subsys="DIO";
	break;
    case CT:
	subsys="CT";
	break;
    default:
	break;
    }
    char *tptr=chanStr;
    for (int i=0; i<numChans-1; i++) {
	/* 
	 * if the chanlist has more than one entry, we need a 
	 * comma seperated list:
	 */
	tptr+=sprintf (tptr, "%s%d,", subsys, chanList[i]);
    }
    sprintf (tptr, "%s%d", subsys, chanList[numChans-1]);
    return(chanStr);	
}


/* 
 * WndProc - Just to get the window registered
 */
LONG FAR PASCAL MessageWindow::WndProc(HWND hWnd, unsigned msg, UINT wParam, LONG lParam)
{   
#ifdef _DEBUG
    if (msg>=WM_MWDAQ && msg <=WM_MWDAQ+100)
    {
    short DeviceId = (wParam & 0x00FF);
    short doneFlag = (wParam & 0xFF00) >> 8;
    long scansDone = lParam;   
        MessageWindow* Window=(MessageWindow*)GetWindowLong(hWnd, GWL_USERDATA);
        //CLock lock(Window->_mutex);
        void  *obj = Window->GetDevFromId(DeviceId);
        if (obj==NULL) 
        {
            ATLTRACE("NIDAQ message on device id %d after stopping\n",DeviceId); 
        }
        switch (msg)
        {
        case WM_NOTIFY_WHEN_DONE_OR_ERR:
            _RPT1(_CRT_WARN,"Device id=%d Stopped Message recieved\n",(long)DeviceId);
            break;
        case WM_NOTIFY_AO_READY:
            _RPT0(_CRT_WARN,"WM_NOTIFY_AO_READY message\n");
            break;
        }
        
    }
#endif // _DEBUG

    return DefWindowProc(hWnd,msg,wParam,lParam);
}

/*
 * Register a class and create an invisible window for message handling
 */
#ifdef _DEBUG
#define TRACEERROR TraceError
void TraceError(long error=GetLastError())
{
    LPVOID lpMsgBuf;
    FormatMessage( 
        FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,    NULL,
        error,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
        (LPTSTR) &lpMsgBuf,    
        0,    
        NULL );
    
    // Display the string.        
    AtlTrace((LPCSTR)lpMsgBuf);
    
    // Free the buffer.
    LocalFree( lpMsgBuf );                                 
    
}
#else
#define TRACEERROR / ## /
#endif

MessageWindow::MessageWindow(LPCSTR name) : _ErrorFlag(false), _bClassRegistered(false)
{

    WNDCLASS    wc;
    
    //HINSTANCE _hInst =  _Module.GetModuleInstance();
    HINSTANCE _hInst =  _Module.GetModuleInstance();;

    wc.hCursor        = 0;
    wc.hIcon          = 0;
    wc.lpszMenuName   = NULL;
    wc.lpszClassName  = name;
    wc.hbrBackground  = 0;
    wc.hInstance      = _hInst;
    wc.style          = 0;
    wc.lpfnWndProc    = WndProc;
    wc.cbWndExtra     = 0;
    wc.cbClsExtra     = sizeof(long*);

    if (!_bClassRegistered)
    {
        if (!RegisterClass(&wc)) 
        {
            _bClassRegistered=false;
            
            ATLTRACE("Registration of %s failed\n",name);
            if (!GetClassInfo(_hInst, name, &wc))  // is class already registered
            {
                TRACEERROR();
            }            
        }
        else
            _bClassRegistered=true;
    }
    
    _hWnd = CreateWindow (
        name,           // class name
        name,           // caption
        WS_DISABLED,    // style bits
        CW_USEDEFAULT,  // x position
        CW_USEDEFAULT,  // y position
        CW_USEDEFAULT,  // x size
        CW_USEDEFAULT,  // y size
        (HWND)NULL,     // parent window
        (HMENU)NULL,    // use class menu
        _hInst,         // instance handle
        (LPSTR)NULL     // no params to pass on
        );
    if (_hWnd==NULL)
    {
        TRACEERROR();
    }
    else
    {
        SetWindowLong(_hWnd, GWL_USERDATA, reinterpret_cast<DWORD>(this));
        _name = name;    
    }
    
}

HRESULT MessageWindow::AddDev(short id,void *dev)
{
    CLock lock(_mutex);
    if (id >= static_cast<short>(OpenDevs.size()))
    {
        OpenDevs.resize(id+1);
    }
    if (OpenDevs[id]!=NULL)
        return E_FAIL;
    ++((long&)OpenDevs[0]);
    OpenDevs[id]=dev; // should actualy assert if already existing...
    return S_OK;
}

HRESULT MessageWindow::DeleteDev(short id)
{
    CLock lock(_mutex);
    if (id >= static_cast<short>(OpenDevs.size()) )
    {
        return E_FAIL;
    }
    --reinterpret_cast<long&>(OpenDevs[0]);

    OpenDevs[id]=NULL;
    return S_OK;
}

MessageWindow::~MessageWindow()
{    
    HINSTANCE _hInst =  _Module.GetModuleInstance();
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
            OpenDevs.resize(0);
        }
    }
#endif
}

// Analog output message handler

void WfmCallback(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    short DeviceId = (wParam & 0x00FF);
    short doneFlag = (wParam & 0xFF00) >> 8;
    long scansDone = lParam;   
    MessageWindow* Window=(MessageWindow*)GetWindowLong(hWnd, GWL_USERDATA);
    //CLock lock(Window->_mutex);
    Cnid2a *ao = (Cnid2a*)Window->GetDevFromId(DeviceId);
    if (ao==NULL) 
    {
        ATLTRACE("NIDAQ callback on device id %d after stopping\n",DeviceId); 
        return;
    }
    switch (msg) 
    {
    case WM_NOTIFY_AO_READY:
        {            

            ao->SyncAndLoadData();            
//	    ATLTRACE("%d points transfered in callback\n", ao->SamplesOutput());
	    break;
        }
    case WM_NOTIFY_WHEN_DONE_OR_ERR:
        {
            short doneFlag = (wParam & 0xFF00) >> 8;

            if (doneFlag)
            {
                char str[40];                
                sprintf(str, "%d scans done\n", (long)ao->SamplesOutput());
		OutputDebugStr(str); 
                double time;
                ao->GetEngine()->GetTime(&time);
                ao->GetEngine()->DaqEvent(EVENT_STOP, time, ao->SamplesOutput(), NULL);
            }
            else
            {
                double time;
                ao->GetEngine()->GetTime(&time);
                ao->GetEngine()->DaqEvent(EVENT_ERR, time, ao->SamplesOutput(), L"Unknown error");
                OutputDebugString("Unknown error message posted\n");
            }
            
        }
    default:	
	break;

    }
}


