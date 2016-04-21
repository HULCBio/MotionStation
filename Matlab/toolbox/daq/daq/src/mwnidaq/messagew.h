// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.5 $  $Date: 2003/12/04 18:40:00 $


#ifndef _MSGWND_H
#define _MSGWND_H

#pragma once
#include <comdef.h>
#include <vector>
#include <thread.h>

class MessageWindow{
public:
    MessageWindow(LPCSTR name);
    ~MessageWindow();
    HWND GetHandle() { return _hWnd; }
    static LONG FAR PASCAL WndProc(HWND hWnd, unsigned msg, UINT wParam, LONG lParam);
    bool IsOpen(short id) 
    {
        CLock lock(_mutex);
        if (id < static_cast<short>(OpenDevs.size())) 
            return OpenDevs[id]!=NULL;
        else return false;
    }
    void *GetDevFromId(short id) 
    {
        if (this==NULL) return NULL; // safety check for shutdown problems
        CLock lock(_mutex);
        if (id < static_cast<short>(OpenDevs.size())) 
            return OpenDevs[id];
        else return NULL;
    }
    HRESULT AddDev(short id,void *dev);
    HRESULT DeleteDev(short id);
    CMutex _mutex;
private:
    typedef std::vector <void *> PTRLIST;
    PTRLIST OpenDevs;
    bool _bClassRegistered;
    bool _ErrorFlag;
    HWND _hWnd;
    
    bstr_t _name;    // device type
    
};

#endif