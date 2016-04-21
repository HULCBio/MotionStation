#if !defined THREAD_H
#define THREAD_H

// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.3 $  $Date: 2003/08/29 04:43:11 $

#include <windows.h>
#include <process.h>


class Thread
{
public:
    Thread (unsigned (WINAPI * pFun) (void* arg), void* pArg) :
      _tid(0)
    {
	/*Create Thread*/
        _handle = (HANDLE) _beginthreadex(
            0,	    // Security attributes 
            0,	    // Stack size
            pFun,   // Start Address
            pArg,   // Argument List
            CREATE_SUSPENDED, // Initialize attributes
            &_tid); // Thread Identifier
	_RPT1(_CRT_WARN, "\nCreated Thread %d.\n", _tid);
        _ASSERTE(_handle);
    }
    ~Thread () { CloseHandle (_handle);_handle=NULL; _tid=0xDEAD;}
    long Resume () { return ResumeThread (_handle); } // windows prototype is dword but these will return -1 on 9X
    long Suspend () { return  SuspendThread (_handle); }
    BOOL  SetThreadPriority(int priority) {return ::SetThreadPriority(_handle,priority);}
    unsigned GetId() { return _tid;}
    bool IsCurrentThread() { return _tid==GetCurrentThreadId();}
    void WaitForDeath ()
    {
        DWORD result=WaitForSingleObject (_handle, 10000);
        if (result==WAIT_TIMEOUT)
        {
            _RPT0(_CRT_ERROR,"Forcing thread to terminate\n");
            TerminateThread(_handle,0xdead);
        }
    }
private:
    HANDLE _handle;
    unsigned  _tid;     // thread id
};

class CMutex
{
    friend class CLock;
    friend class CSmartLock;
public:
    CMutex () { InitializeCriticalSection (&_critSection); }
    ~CMutex () { DeleteCriticalSection (&_critSection); }
private:
    void Acquire () 
    { 
        EnterCriticalSection (&_critSection);
    }
    void Release () 
    { 
        LeaveCriticalSection (&_critSection);
    }

    CRITICAL_SECTION _critSection;
    CMutex(const CMutex& in);// will be unresolved external {_RPT0(_CRT_ERROR,("Invalid Copy contructor for  CMutex called"));}
    CMutex& operator =(const CMutex& in); // will be unresolved external {_RPT0(_CRT_ERROR,("Invalid assignment operator for  CMutex called")); return *this;}

};

#ifdef DEBUG_THREADS
#define ASSERTLOCKED(_x) _ASSERTE(_x._critSection.LockCount>=0)
#define ASSERTUNLOCKED(_x) _ASSERTE(_x._critSection.LockCount<0 || _x._critSection.OwningThread != (HANDLE)GetCurrentThreadId()) 
#else
#define ASSERTLOCKED(_x)
#define ASSERTUNLOCKED(_x)
#endif

class CLock 
{
public:
	// Acquire the state of the semaphore
	CLock ( CMutex& mutex ) 
		: _mutex(mutex) 
	{
		_mutex.Acquire();
	}
	// Release the state of the semaphore
	~CLock ()
	{
		_mutex.Release();
	}
private:
	CMutex& _mutex;
};

class CSmartLock 
{
public:
    // Acquire the state of the semaphore
    CSmartLock ( CMutex& mutex ,bool lock=true ) 
        : _mutex(mutex) ,_Locked(false) 
    {
        if (lock)
            Lock();
    }
    void Lock()
    {
        if (!_Locked)
        {
            _mutex.Acquire();
            _Locked=true;
        }
    }
    void UnLock()
    {
        if (_Locked)
        {
            _mutex.Release();
            _Locked=false;
        }
    }
    // Release the state of the semaphore
    ~CSmartLock ()
    {
        if (_Locked)
            _mutex.Release();
    }
private:
    CMutex& _mutex;
    bool _Locked;
};


class CEvent
{
public:
    CEvent (BOOL  manualreset=FALSE)
    {
        // auto reset after every Wait
        // start in non-signaled state (red light)
        _handle = CreateEvent (0, manualreset, FALSE, 0);
    }
    
    ~CEvent ()
    {
        CloseHandle (_handle);
    }
    
    // put into signaled state
    void Reset() { ResetEvent(_handle);} // only need for manualreset events
    void Set() {  SetEvent (_handle); }
    void Pulse() { PulseEvent(_handle); }
    
    int Wait (int Timeout=INFINITE)
    {
        // Wait until event is in signaled (green) state
        return WaitForSingleObject(_handle, Timeout);
    }
    operator HANDLE () { return _handle; }
private:
    HANDLE _handle;
};

class CSemaphore
{
public:
    CSemaphore (int initialCount,LPCTSTR name=NULL,int maxcount=0X10000)
    {
        // start in non-signaled state (red light)
        // auto reset after every Wait
        _handle = CreateSemaphore (0, initialCount, maxcount, name);
        _ASSERTE(_handle!=NULL);
    }

    ~CSemaphore ()
    {
        CloseHandle (_handle);
    }

    // put into signaled state
    void Release () {  ReleaseSemaphore (_handle,1,NULL); }
    long Release(int count)
    { long prevvalue;int status=ReleaseSemaphore(_handle,count,&prevvalue); _ASSERTE(status==TRUE);return prevvalue;}
    int Wait (int Timeout=INFINITE)
    {
        // Wait until event is in signaled (green) state
        return WaitForSingleObject(_handle, Timeout);
    }
    HANDLE GetHandle() { return _handle; } // for use with WaiteForMultipleObjects ...
#ifdef _DEBUG
    long GetCount() 
    {
        long count=Release(1); // returns previous count
        int status=Wait(0);
        _ASSERTE(status==WAIT_OBJECT_0);
        return count-1;
    }
#endif
private:
    HANDLE _handle;
};


#endif