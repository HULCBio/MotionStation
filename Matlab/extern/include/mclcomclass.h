/* $Revision: 1.23.4.5 $ */

#ifndef _MCLCOMCLASS_H_
#define _MCLCOMCLASS_H_

#pragma warning( disable : 4786 )
#include "mclmcr.h"
#include "mclcom.h"
#include "mwcomutil.h"
#include <olectl.h>

#ifdef __cplusplus

#include <vector>
#include <map>
using namespace std;

/*------------------------------------------------------------------------------
  CMCLModule class definition. The CMCLModule class is used as the global
  DLL controller object for all COM DLL's. Manages global lock count, 
  registration/de-registration, and class factory services for the DLL.
------------------------------------------------------------------------------*/
class CMCLModule
{
/*--------------------------------------
  Construction/destruction
--------------------------------------*/
public:
	CMCLModule()
    {
		m_cLockCount = 0;
		m_hInstance = NULL;
		m_pObjectMap = NULL;
		m_plibid = NULL;
		m_wMajor = 0;
		m_wMinor = 0;
		m_bInitialized = FALSE;
        m_szPath[0] = '\0';
    }
	virtual ~CMCLModule()
    {
    }
/*--------------------------------------
  Methods
--------------------------------------*/
public:
	// Initialization/uninitialization method to be called from DLLMain
	virtual BOOL InitMain(MCLOBJECT_MAP_ENTRY pobjectmap, const GUID* plibid, WORD wMajor, WORD wMinor,
						  HINSTANCE hInstance, DWORD dwReason, void* pv)
    {
        if (dwReason == DLL_PROCESS_ATTACH)
        {
            char szDllPath[_MAX_PATH];
            char szDir[_MAX_DIR];
            Init(pobjectmap, hInstance, plibid, wMajor, wMinor);
            DisableThreadLibraryCalls(hInstance);
            if (GetModuleFileName(hInstance, szDllPath, _MAX_PATH) > 0)
            {
                _splitpath(szDllPath, m_szPath, szDir, NULL, NULL);
                strcat(m_szPath, szDir);
            }
            mclInhibitShutdown();
        }
        else if (dwReason == DLL_PROCESS_DETACH)
	    {
		    Term();
	    }
        return TRUE;
    }
	// Initializes the class with object, instance, and type lib info
	virtual void Init(MCLOBJECT_MAP_ENTRY pobjectmap, HINSTANCE hInstance, const GUID* plibid, WORD wMajor, WORD wMinor)
    {
        if (m_bInitialized)
		    Term();
	    m_hInstance = hInstance;
	    m_plibid = plibid;
	    m_wMajor = wMajor;
	    m_wMinor = wMinor;
	    m_pObjectMap = pobjectmap;
	    m_bInitialized = TRUE;
    }
	// Uninitializes the class
	virtual void Term()
    {
        if (!m_bInitialized)
		    return;
	    m_hInstance = NULL;
	    m_plibid = NULL;
	    m_wMajor = 0;
	    m_wMinor = 0;
	    m_bInitialized = FALSE;
    }
	// Returns the current lock count
	long GetLockCount() {    
            long cCount = 0;
            InterlockedExchange(&cCount, m_cLockCount);
            return cCount;
        }
	// Updates the registry for all classes in list and type lib. TRUE = Register, FALSE = Unregister
	virtual HRESULT UpdateRegistry(BOOL bRegister)
    {
        HRESULT hr = S_OK;

	    if (!m_bInitialized)
		    return E_FAIL;
	    if (bRegister)
	    {
		    char szDllPath[MAX_PATH];
		    OLECHAR wDllPath[MAX_PATH];
		    ITypeLib* pTypeLib = 0;

		    GetModuleFileName(m_hInstance, szDllPath, MAX_PATH);
		    mbstowcs(wDllPath, szDllPath, MAX_PATH);
		    hr = LoadTypeLibEx(wDllPath, REGKIND_REGISTER, &pTypeLib);
		    if(FAILED(hr))
			    return hr;
		    pTypeLib->Release();
		    if (m_pObjectMap == NULL)
			    return S_OK;
		    int i = 0;
		    while (m_pObjectMap[i].pclsid != NULL)
		    {
			    hr = m_pObjectMap[i].pfnRegisterClass(m_plibid, m_wMajor, m_wMinor, m_pObjectMap[i].lpszFriendlyName, 
                                                      m_pObjectMap[i].lpszVerIndProgID, m_pObjectMap[i].lpszProgID, szDllPath);
			    if (FAILED(hr))
				    return hr;
			    i++;
		    }
	    }
	    else
	    {
		    hr = UnRegisterTypeLib(*m_plibid, m_wMajor, m_wMinor, LANG_NEUTRAL, SYS_WIN32);
		    int i = 0;
		    while (m_pObjectMap[i].pclsid != NULL)
		    {
			    hr = m_pObjectMap[i].pfnUnregisterClass(m_pObjectMap[i].lpszVerIndProgID, m_pObjectMap[i].lpszProgID);
		    	i++;
		    }
	    }
	    return S_OK;
    }
	// Returns a class factory pointer for the specified CLSID
	virtual HRESULT GetClassObject(REFCLSID clsid, REFIID iid, void** ppv)
    {
        if (!m_bInitialized)
		    return CLASS_E_CLASSNOTAVAILABLE;
	    if (m_pObjectMap == NULL)
		    return CLASS_E_CLASSNOTAVAILABLE;
	    int i = 0;
	    while (m_pObjectMap[i].pclsid != NULL)
	    {
		    if (*(m_pObjectMap[i].pclsid) == clsid)
			    return m_pObjectMap[i].pfnGetClassObject(clsid, iid, ppv);
		    i++;
	    }
	    return CLASS_E_CLASSNOTAVAILABLE;
    }
	// Increments the lock count
	long Lock() {return InterlockedIncrement(&m_cLockCount);}
	// Decrements the lock count
	long Unlock() {return InterlockedDecrement(&m_cLockCount);}
	// Returns a new type info pointer for the module's type lib
	HRESULT GetTypeInfo(REFGUID riid, ITypeInfo** ppTypeInfo)
    {
        HRESULT hr = S_OK;
	    ITypeLib* pTypeLib = NULL;

	    if (!m_bInitialized)
		    return E_FAIL;
	    if(FAILED(hr = LoadRegTypeLib(*m_plibid, m_wMajor, m_wMinor, LANG_NEUTRAL, &pTypeLib)))
		    return hr;
	    hr = pTypeLib->GetTypeInfoOfGuid(riid, ppTypeInfo);
	    pTypeLib->Release();
	    return hr;
    }
	// Returns the progid for a given clsid, returns null if invalid clsid
	const char* GetProgID(REFCLSID clsid)
    {
        int i = 0;
        while (m_pObjectMap[i].pclsid != NULL)
	    {
		    if (*(m_pObjectMap[i].pclsid) == clsid)
			    return m_pObjectMap[i].lpszProgID;
		    i++;
	    }
	    return NULL;
    }
    // Returns the path to the Dll
    const char* getPath()
    {
        return m_szPath;
    }
/*--------------------------------------
  Properties
--------------------------------------*/
private:
	long m_cLockCount;						// Lock count on module
	HINSTANCE m_hInstance;					// HINSTANCE passed from DLLMain
	MCLOBJECT_MAP_ENTRY m_pObjectMap;		// Object info array
	const GUID* m_plibid;					// LIBID of type lib
	BOOL m_bInitialized;					// Is-initialized flag
	WORD m_wMajor;							// Major rev number of type lib
	WORD m_wMinor;							// Minor rev number of type lib
    char m_szPath[_MAX_PATH];               // Stores the location of the Dll
};

class IMCLEvent
{
public:
    virtual void mclRaiseEvent(const char* lpszName, int nargin, ...) = 0;
    virtual void mclRaiseEventV(const char* lpszName, int nargin, va_list vargs) = 0;
    virtual void mclRaiseEventA(const char* lpszName, int nargin, mxArray** prhs) = 0;
};

class mclmxarray_list {
	int count;
	mxArray **list;
public:
	mclmxarray_list( int icount, mxArray **ilist ) : count(icount), list(ilist) { }
	~mclmxarray_list( ) {
		for (int i =0; i<count; i++) {
			mxDestroyArray( list[i] );
		}
	}
};
// Class for managing global list of event listeners.
class mclEventMap
{
public:
    mclEventMap(){}
    virtual ~mclEventMap(){}
    // Returns current number of listeners
    int size()
    {
        mwLock lock;
        return (int)m_events.size();
    }
    // Adds a listener
    void add(int id, IMCLEvent* pEvent)
    {
        mwLock lock;
        if (!pEvent)
            return;
        std::map<int, IMCLEvent*>::iterator it = m_events.find(id);
        if (it == m_events.end())
            m_events[id] = pEvent;
    }
    // Removes a listener
    void remove(int id)
    {
        mwLock lock;
        std::map<int, IMCLEvent*>::iterator it = m_events.find(id);
        if (it != m_events.end())
            m_events.erase(it);
    }
    // Invokes the named event in the listener of current call context.
    void invoke(int id, const char* lpszName, int nargin, ...)
    {
        mwLock lock;
        std::map<int, IMCLEvent*>::iterator it = m_events.find(id);
        if (it != m_events.end())
        {
            va_list args;
            va_start(args, nargin);
            ((*it).second)->mclRaiseEventV(lpszName, nargin, args);
            va_end(args);
        }
    }
    // Invokes the named event in the listener of current call context.
    void invokeA(int id, const char* lpszName, int nargin, mxArray** prhs)
    {
        mwLock lock;
        std::map<int, IMCLEvent*>::iterator it = m_events.find(id);
        if (it != m_events.end())
            ((*it).second)->mclRaiseEventA(lpszName, nargin, prhs);
    }
    // Invokes the named event in the listener of current call context.
    void invokeV(int id, const char* lpszName, int nargin, va_list vargs)
    {
        mwLock lock;
        std::map<int, IMCLEvent*>::iterator it = m_events.find(id);
        if (it != m_events.end())
            ((*it).second)->mclRaiseEventV(lpszName, nargin, vargs);
    }
private:
    std::map<int, IMCLEvent*> m_events; // Array of listeners
};

// Globals
extern CMCLModule g_Module;
extern mclEventMap g_EventMap;

template<class T, const IID* piid, class T1, const CLSID* pclsid, const IID* piidEvents = NULL>
class CMCLBaseImpl: public T, public ISupportErrorInfo, public IConnectionPointContainer
{
/*--------------------------------------
  Construction/destruction
--------------------------------------*/
public:
	// CMCLBaseImpl constructor
	CMCLBaseImpl()
	{
		m_cRef = 1;
        m_pTypeInfo = NULL;
        m_pEvents = NULL;
		g_Module.Lock();
	}
	// CMCLBaseImpl destructor
	virtual ~CMCLBaseImpl()
	{
        if (m_pEvents != NULL)
            m_pEvents->Release();
        if (m_pTypeInfo != NULL)
            m_pTypeInfo->Release();
        g_Module.Unlock();
	}

/*--------------------------------------
  IUnknown implementation
--------------------------------------*/
public:
	// IUnknown::AddRef implementation
	ULONG __stdcall AddRef()
	{
		return InterlockedIncrement(&m_cRef);
	}
	// IUnknown::Release implementation
	ULONG __stdcall Release()
	{
        ULONG cRef = InterlockedDecrement(&m_cRef);
		if(cRef != 0)
			return cRef;
		delete this;
		return 0;
	}
	// IUnknown::QueryInterface implementation
	HRESULT __stdcall QueryInterface(REFIID riid, void** ppv)
	{
		if(riid == *piid)
			*ppv = static_cast<T*>(this);
		else if(riid == IID_IUnknown)
			*ppv = reinterpret_cast<IUnknown*>(this);
		else if(riid == IID_IDispatch)
			*ppv = reinterpret_cast<IDispatch*>(this);
		else if(riid == IID_ISupportErrorInfo)
			*ppv = static_cast<ISupportErrorInfo*>(this);
        else if (riid == IID_IConnectionPointContainer)
            *ppv = static_cast<IConnectionPointContainer*>(this);
		else 
		{
			*ppv = NULL;
			return E_NOINTERFACE;
		}
		AddRef();
		return S_OK;
	}
/*--------------------------------------
  IDispatch implementation
--------------------------------------*/
	// IDispatch::GetTypeInfoCount implementation
	HRESULT __stdcall GetTypeInfoCount(UINT* pCountTypeInfo)
	{
        if (pCountTypeInfo != NULL)
		    *pCountTypeInfo = 1;
		return S_OK;
	}
	// IDispatch::GetTypeInfo implementation
	HRESULT __stdcall GetTypeInfo(UINT iTypeInfo, LCID lcid, ITypeInfo** ppITypeInfo)
	{
        if (ppITypeInfo != NULL)
        {
		    *ppITypeInfo = NULL;
		    if(iTypeInfo != 0)
			    return DISP_E_BADINDEX;
            if (m_pTypeInfo != NULL)
		        m_pTypeInfo->AddRef();
		    *ppITypeInfo = m_pTypeInfo;
        }
		return S_OK;
	}
	// IDispatch::GetIDsOfNames implementation
	HRESULT __stdcall GetIDsOfNames(REFIID riid, LPOLESTR* rgszNames, UINT cNames, 
									LCID lcid, DISPID* rgDispId)
	{
		if(riid != IID_NULL)
			return DISP_E_UNKNOWNINTERFACE;
		return DispGetIDsOfNames(m_pTypeInfo, rgszNames, cNames, rgDispId);
	}
	// IDispatch::Invoke implementation
	HRESULT __stdcall Invoke(DISPID dispIdMember, REFIID riid, LCID lcid, WORD wFlags, 
							 DISPPARAMS* pDispParams, VARIANT* pVarResult, EXCEPINFO* pExcepInfo, 
							 UINT* puArgErr)
	{
		if(riid != IID_NULL)
			return DISP_E_UNKNOWNINTERFACE;
		return DispInvoke(this, m_pTypeInfo, dispIdMember, wFlags, pDispParams, pVarResult, pExcepInfo, puArgErr); 
	}
/*--------------------------------------
  ISupportErrorInfo implementation
--------------------------------------*/
    // ISupportErrorInfo::InterfaceSupportsErrorInfo implementation
	HRESULT __stdcall InterfaceSupportsErrorInfo(REFIID riid)
	{
		if(riid == *piid)
			return S_OK;
		else
			return S_FALSE;
	}
/*--------------------------------------
  IConnectionPointContainer implementation
--------------------------------------*/
    // IConnectionPointContainer::EnumConnectionPoints implementation
    HRESULT __stdcall EnumConnectionPoints(IEnumConnectionPoints** ppEnum)
    {
        HRESULT hr = S_OK;
        ULONG cConnections = 0;
        CMCLEnumConnectionPoints* pEnum = NULL;

        if (ppEnum == NULL)
            return E_POINTER;
        if (m_pEvents != NULL)
            cConnections = 1;
        pEnum = new CMCLEnumConnectionPoints(reinterpret_cast<IUnknown*>(this), cConnections, &m_pEvents);
        if (pEnum == NULL)
            return E_OUTOFMEMORY;
        hr = pEnum->QueryInterface(IID_IEnumConnectionPoints, (void**)ppEnum);
        pEnum->Release();
        return hr;
    }
    // IConnectionPointContainer::FindConnectionPoint implementation
    HRESULT __stdcall FindConnectionPoint(REFIID riid, IConnectionPoint** ppCP)
    {
        if (ppCP == NULL)
            return E_POINTER;
        if (piidEvents == NULL)
            return CONNECT_E_NOCONNECTION;
        if (riid == *piidEvents)
        {
            if (m_pEvents == NULL)
                return CONNECT_E_NOCONNECTION;
            *ppCP = m_pEvents;
            (*ppCP)->AddRef();
            return S_OK;
        }
        return CONNECT_E_NOCONNECTION;
    }
/*--------------------------------------
  CMCLBaseImpl Methods
--------------------------------------*/
	// Initializes class, loads type info stuff and initializes connection point if necessary.
    // Put any additional init stuff in here.
	virtual bool Init(void)
	{
        HRESULT hr = S_OK;

        hr = g_Module.GetTypeInfo(*piid, &m_pTypeInfo);
		if(FAILED(hr))
            return false;
        if (piidEvents != NULL)
        {
            CMCLConnectionPointImpl<piidEvents>* pEvents 
                = new CMCLConnectionPointImpl<piidEvents>(static_cast<IConnectionPointContainer*>(this));
            if (pEvents == NULL)
                return false;
            if (pEvents != NULL)
            {
                if (FAILED(pEvents->QueryInterface(IID_IConnectionPoint, (void**)&m_pEvents)))
                    return false;
                pEvents->Release();
            }
        }
        return true;
	}
    // Registers the class
	static HRESULT __stdcall RegisterClass(const GUID* plibid, unsigned short wMajor, unsigned short wMinor, const char* lpszFriendlyName, 
                                           const char* lpszVerIndProgID, const char* lpszProgID, const char* lpszModuleName)
	{
		return mclRegisterServer(lpszModuleName, *pclsid, *plibid, wMajor, wMinor, lpszFriendlyName,
                                 lpszVerIndProgID, lpszProgID, "Both");
	}
	// Unregisters the class
	static HRESULT __stdcall UnregisterClass(const char* lpszVerIndProgID, const char* lpszProgID)
	{
		return mclUnregisterServer(*pclsid, lpszVerIndProgID, lpszProgID);
	}
	// Called by COM framework to get IClassFactory pointer on which to create new instances of object
	static HRESULT __stdcall GetClassObject(REFCLSID clsid, REFIID iid, void** ppv)
	{	
		if(clsid != *pclsid)
			return CLASS_E_CLASSNOTAVAILABLE;

		CMCLFactoryImpl<T1>* pFactory = new CMCLFactoryImpl<T1>;
		if(pFactory == NULL)
			return E_OUTOFMEMORY;

		// QueryInterface for IClassFactory
		HRESULT hr = pFactory->QueryInterface(iid, ppv);
		pFactory->Release();
		return hr;
	}
	// Method to report an error
	static HRESULT __stdcall Error(const char* lpszMessage)
	{
		ICreateErrorInfo* pCreateErrorInfo = NULL;
		IErrorInfo* pErrorInfo = NULL;
		HRESULT hr = S_OK;
		OLECHAR* lpwszMessage = NULL;
		OLECHAR* lpwszSource = NULL;
		const char* lpszSource = NULL;
		int nLen = 0;

		if (FAILED(hr = CreateErrorInfo(&pCreateErrorInfo)))
			goto EXIT;
		// Set message text
		if (lpszMessage != NULL)
		{
			nLen = mbstowcs(NULL, lpszMessage, 0);
			lpwszMessage = new OLECHAR[nLen+1];
			if (lpwszMessage != NULL)
			{
				if (mbstowcs(lpwszMessage, lpszMessage, nLen+1) != -1)
					pCreateErrorInfo->SetDescription(lpwszMessage);
				else
					pCreateErrorInfo->SetDescription(L"");
			}
			else
				pCreateErrorInfo->SetDescription(L"");
		}
		else
			pCreateErrorInfo->SetDescription(L"");
		// Set IID
		pCreateErrorInfo->SetGUID(*piid);
		// Set error source
		lpszSource = g_Module.GetProgID(*pclsid);
		if (lpszSource != NULL)
		{
			nLen = mbstowcs(NULL, lpszSource, 0);
			lpwszSource = new OLECHAR[nLen+1];
			if (lpwszSource != NULL)
			{
				if (mbstowcs(lpwszSource, lpszSource, nLen+1) != -1)
					pCreateErrorInfo->SetSource(lpwszSource);
				else
					pCreateErrorInfo->SetSource(L"");
			}
			else
				pCreateErrorInfo->SetSource(L"");
		}
		else
			pCreateErrorInfo->SetSource(L"");
		// Set error info
		if (FAILED(hr = pCreateErrorInfo->QueryInterface(IID_IErrorInfo, (void**)&pErrorInfo)))
			goto EXIT;
		hr = SetErrorInfo(0, pErrorInfo);
	EXIT:
		if (lpwszMessage != NULL)
			delete [] lpwszMessage;
		if (lpwszSource != NULL)
			delete [] lpwszSource;
		if (pErrorInfo != NULL)
			pErrorInfo->Release();
		if (pCreateErrorInfo != NULL)
			pCreateErrorInfo->Release();
		return hr;
	}
    // Method to report an error from an EXCEPINFO structure (note: does not use template *piid in SetGUID)
    static HRESULT __stdcall Error(REFIID riid, EXCEPINFO* pExcepInfo)
    {
	    ICreateErrorInfo* pCreateErrorInfo = NULL;
	    IErrorInfo* pErrorInfo = NULL;
	    HRESULT hr = S_OK;

        if (pExcepInfo == NULL)
            goto EXIT;
	    if (FAILED(hr = CreateErrorInfo(&pCreateErrorInfo)))
		    goto EXIT;
	    // Set message text
	    pCreateErrorInfo->SetDescription(pExcepInfo->bstrDescription);
	    // Set IID
	    pCreateErrorInfo->SetGUID(riid);
	    // Set error source
	    pCreateErrorInfo->SetSource(pExcepInfo->bstrSource);
	    // Set error info
	    if (FAILED(hr = pCreateErrorInfo->QueryInterface(IID_IErrorInfo, (void**)&pErrorInfo)))
		    goto EXIT;
	    hr = SetErrorInfo(0, pErrorInfo);
    EXIT:
	    if (pErrorInfo != NULL)
		    pErrorInfo->Release();
	    if (pCreateErrorInfo != NULL)
		    pCreateErrorInfo->Release();
    	return hr;
    }
protected:
    int RequestLocalLock()
    {
        mclAcquireMutex();
        return 0;
    }
    int ReleaseLocalLock()
    {
        mclReleaseMutex();
        return 0;
    }
/*--------------------------------------
  CMCLBaseImpl Properties
--------------------------------------*/
private:
	long m_cRef;				// Reference count
	ITypeInfo* m_pTypeInfo;		// Type Info pointer
protected:
    IConnectionPoint* m_pEvents;// Connection point for objects that implement an event interface
};

template<class T, const IID* piid, class T1, const CLSID* pclsid, const IID* piidEvents = NULL>
class CMCLSingleBaseImpl: public CMCLBaseImpl<T, piid, T1, pclsid, piidEvents>
{
/*--------------------------------------
  Construction/destruction
--------------------------------------*/
public:
	// CMCLSingleBaseImpl constructor
	CMCLSingleBaseImpl(){}
	// CMCLSingleBaseImpl destructor
	virtual ~CMCLSingleBaseImpl(){}
/*--------------------------------------
  IUnknown implementation
--------------------------------------*/
public:
	// IUnknown::AddRef implementation
	ULONG __stdcall AddRef()
	{
        return 2;
	}
	// IUnknown::Release implementation
	ULONG __stdcall Release()
	{
        return 1;
	}
	// Called by COM framework to get IClassFactory pointer on which to create new instances of object
	static HRESULT __stdcall GetClassObject(REFCLSID clsid, REFIID iid, void** ppv)
	{	
		if(clsid != *pclsid)
			return CLASS_E_CLASSNOTAVAILABLE;

		CMCLSingleFactoryImpl<T1>* pFactory = new CMCLSingleFactoryImpl<T1>;
		if(pFactory == NULL)
			return E_OUTOFMEMORY;

		// QueryInterface for IClassFactory
		HRESULT hr = pFactory->QueryInterface(iid, ppv);
		pFactory->Release();
		return hr;
	}
};

template<class T, const IID* piid, class T1, const CLSID* pclsid, const IID* piidEvents = (const IID *)NULL>
class CMCLClassImpl: public CMCLBaseImpl<T, piid, T1, pclsid, piidEvents>, public IMCLEvent
{
/*--------------------------------------
  Construction/destruction
--------------------------------------*/
public:
	// CMCLClassImpl constructor
	CMCLClassImpl()
    {
            m_pFlags = NULL;
            m_hinst = NULL;
	}
	// CMCLClassImpl destructor
	virtual ~CMCLClassImpl()
	{
            if (m_pFlags != NULL)
                m_pFlags->Release();
	}
protected:
    void RegisterListener(HMCRINSTANCE hinst = NULL)
    {
        g_EventMap.add(mclGetID((hinst ? hinst : m_hinst)), static_cast<IMCLEvent*>(this));
    }
    void UnregisterListener(HMCRINSTANCE hinst = NULL)
    {
        g_EventMap.remove(mclGetID((hinst ? hinst : m_hinst)));
    }
public:
/*--------------------------------------
  CMCLClassImpl Methods
--------------------------------------*/
    // Registers the class and adds it to the MatLab XL component catagory
	static HRESULT __stdcall RegisterClass(const GUID* plibid, unsigned short wMajor, unsigned short wMinor, const char* lpszFriendlyName,
                                           const char* lpszVerIndProgID, const char* lpszProgID, const char* lpszModuleName)
	{
		return RegisterMatLabComponent(lpszModuleName, *pclsid, *plibid, wMajor, wMinor, lpszFriendlyName, lpszVerIndProgID, lpszProgID);
	}
	// Unregisters the class and removes it from the MatLab XL component catagory
	static HRESULT __stdcall UnregisterClass(const char* lpszVerIndProgID, const char* lpszProgID)
	{
		return UnRegisterMatLabComponent(*pclsid, lpszVerIndProgID, lpszProgID);
	}
    // Returns a pointer to the contained MWFlags object
    HRESULT __stdcall get_MWFlags(IMWFlags** ppFlags)
    {
        HRESULT hr = S_OK;       // Return code
        mwLock lock;
        if (ppFlags == NULL)
            return E_INVALIDARG;
        *ppFlags = NULL;
        // If there is not one already allocated, creat a new one.
        if (m_pFlags == NULL)
        {
            hr = CoCreateInstance(CLSID_MWFlags, NULL, CLSCTX_INPROC_SERVER, 
                                  IID_IMWFlags, (void**)&m_pFlags);
            if (FAILED(hr))
            {
                return hr;
            }
        }
        *ppFlags = m_pFlags;
        m_pFlags->AddRef();
        return hr;
    }
    // Sets the array-formatting-object
    HRESULT __stdcall put_MWFlags(IMWFlags* pFlags)
    {
        HRESULT hr = S_OK;      // Return code
        mwLock lock;
        if (pFlags == NULL)
            return E_INVALIDARG;
        // Set internal object to new one. 
        if (m_pFlags != NULL)
            m_pFlags->Release();
        m_pFlags = pFlags;
        m_pFlags->AddRef();
        return hr;
    }
    // Call the MatLab mex funtion pointed to by mlxF
    HRESULT CallComFcn(const char* name, int nargout, int fnout, int fnin, ...)
    {
        mxArray **plhs;
        //int nargout:  comes in as ip param to this function
        int alloc_nargout = (nargout == 0) ? 1: nargout;
        mxArray **prhs;
        int nargin = 0;

        VARIANT **plvar;
        const VARIANT **prvar;

        bool bVarargout = fnout < 0;
        bool bVarargin = fnin < 0;

        mxArray *varargout = NULL;
        mxArray *varargin = NULL;

        int i;
        int new_nargin;
        va_list ap;
        bool bFoundDefault = false;
        HRESULT retval = S_OK;
        _MCLCONVERSION_FLAGS flags;
        IMWFlags* pFlags = NULL;
        bool bRet = false;

        mwLock lock;
        // Check MCR instance
        if (!m_hinst)
        {
            Error("MCR instance is not available");
            return E_FAIL;
        }
        // Get Conversion flags
        if (FAILED(get_MWFlags(&pFlags)))
        {
            Error("Error getting data conversion flags");
            return E_FAIL;
        }
        if (FAILED(GetConversionFlags(pFlags, &flags)))
        {
            Error("Error getting data conversion flags");
            return E_FAIL;
        }
        pFlags->Release();
        try 
        {    
            // O/P from mclMlxFeval (lhs)
            va_start( ap, fnin );
            if (bVarargout) 
            {
                fnout = -fnout;
            }
            plvar = (VARIANT **) _alloca( fnout * sizeof( VARIANT * ) );
            for (i=0; i< fnout; i++) 
            {
                plvar[i] = va_arg( ap, VARIANT *);
            }
            plhs = (mxArray **) _alloca( alloc_nargout * sizeof( mxArray * ));
            for (i=0; i< alloc_nargout; i++) 
            {
                plhs[i] = NULL;
            }
            // I/P to mclMlxFeval (rhs)
            if (bVarargin) 
            {
                fnin = -fnin;      
            }
            prvar = (const VARIANT **) _alloca( fnin * sizeof(VARIANT *));
            for (i = 0; i< fnin; i++) 
            {
                prvar[i] = va_arg( ap, VARIANT *);
                if (IsVisualBasicDefault( prvar[i] )) 
                {
                    bFoundDefault = true;
                }
                else 
                {
                    if (bFoundDefault) 
                    {
                        Error( "Error: Arguments may only be defaulted at the end of an argument list" );
                        retval = E_FAIL;
                        goto finish;
                    }
                    nargin++;
				}
            }
            if (bVarargin && !bFoundDefault) 
            {
                flags.nInputInd += 1;
                Variant2mxArray( prvar[fnin-1], &varargin, &flags);
                flags.nInputInd -= 1;
                if (varargin == NULL)
                    nargin -= 1;
                else if (mxGetClassID(varargin) == mxCELL_CLASS)
                    nargin += mxGetN( varargin ) - 1;
            }
            prhs = (mxArray **) _alloca( nargin * sizeof(mxArray *));
            for (i = 0; i< nargin; i++) 
                prhs[i] = NULL;
            mclmxarray_list protect_plhs( nargout, plhs );
            mclmxarray_list protect_prhs( nargin, prhs );
            for (i = 0; i< nargin; i++) 
            {
                if (i < fnin-1 || (!bVarargin && i == fnin-1)) {
		            Variant2mxArray( prvar[i], &prhs[i], &flags);
                }
                else
                {
                    if ( varargin != NULL && mxGetClassID(varargin) == mxCELL_CLASS)
                        prhs[i] = mclCreateSharedCopy(((mxArray **)mxGetData(varargin))[i-fnin+1]);
                    else
                        prhs[i] = mclCreateSharedCopy(varargin);
                }
            }
            bFoundDefault = false;
            new_nargin = nargin;
            for (i = 0; i< nargin; i++) 
            {
                if (!bFoundDefault) {
                    if (prhs[i] == NULL) {
                        bFoundDefault = true;
                        new_nargin = i;
                     }
                }
                else {
                    if (prhs[i] != NULL) {
                        Error( "Error: Arguments may only be defaulted at the end of an argument list" );
                        retval = E_FAIL;
                    }
                }
            }
            if (retval != E_FAIL) {
                nargin = new_nargin;
                // call mclMlxFeval
                bRet = mclFeval(m_hinst, name, nargout, plhs, nargin, prhs);
                if (!bRet)
                    goto finish;
                // translate o/p (lhs) of  mclMlxFeval back to variant
                if (nargout == 0 && plhs[0] != NULL )
                {
                    mxDestroyArray( plhs[0] );
                    plhs[0] = NULL;
                }
                if (bVarargout && nargout >= fnout) 
                {
                    varargout = mclCreateCellArrayFromArrayList(nargout-fnout+1, &plhs[fnout-1]);
                }
                for (i = 0; i<fnout && i<nargout; i++) 
                {     
                    if (i < fnout -1 || (!bVarargout && i == fnout-1 ))
                        mxArray2Variant( plhs[i], plvar[i], &flags);
                    else
                    {
                        flags.nOutputInd += 1;
                        flags.nTransposeInd += 1;
                        mxArray2Variant( varargout, plvar[i], &flags);
                        flags.nOutputInd -= 1;
                        flags.nTransposeInd -= 1;
                    }
                }
            }
        }
        catch (...)
        {
            Error("Unexpected Error Thrown");
            retval = E_FAIL;       
        }
    finish:
        if (varargin != NULL)
            mxDestroyArray( varargin );
        if (varargout != NULL)
            mxDestroyArray( varargout );
        if (!bRet)
        {
            const char* msg = mclGetLastErrorMessage(m_hinst);
            Error((msg ? msg : "Unspecified error"));
            retval = E_FAIL;
        }
        return(retval); 
    }
    void mclRaiseEvent(const char* lpszName, int nargin, ...)
    {
        va_list vargs;                  // Arg list of mxArray* values to process
        
        va_start(vargs, nargin);
        mclRaiseEventV(lpszName, nargin, vargs);
        va_end(vargs);
    }
    void mclRaiseEventV(const char* lpszName, int nargin, va_list vargs)
    {
        mxArray** prhs = NULL;          // Temp array for inputs

        if (nargin > 0)
        {
            if ((prhs = (mxArray **)_alloca(nargin*sizeof(mxArray*))) == NULL)
                return;
        }
        for (int i=0;i<nargin;i++)
            prhs[i] = va_arg(vargs, mxArray*);
        mclRaiseEventA(lpszName, nargin, prhs);
    }
    void mclRaiseEventA(const char* lpszName, int nargin, mxArray** prhs)
    {
        HRESULT hr = S_OK;              // Return code
        IEnumConnections* pEnum = NULL; // Pointer to enum of all connections
        CONNECTDATA ConnData = {0,0};   // CONNECTDATA structure for each connection
        ULONG cFetched = 0;             // Number of connections fetched in a call
        IDispatch* pDisp = NULL;        // IDispatch pointer to make call on
        VARIANT varResult;              // Result from call
        VARIANT* pvars = NULL;          // Varaibles to send into call
        DISPPARAMS disp = {NULL,NULL,0,0};// Disparams used to make call
        DISPID dispid = 0;              // DISPID of method to invoke
        OLECHAR* lpwszName = NULL;      // Temp buffer for method name
        int nLen = 0;                   // Length of name string
        int i = 0;                      // Loop counter
        _MCLCONVERSION_FLAGS flags;     // Temp flags struct
        IMWFlags* pFlags = NULL;        // Temp flags object

        // If no connection point available or invalid name, return
        if (m_pEvents == NULL || lpszName == NULL)
            return;
        if (nargin < 0 || (prhs == NULL && nargin > 0))
            nargin = 0;
        // Get Conversion flags
        if (FAILED(get_MWFlags(&pFlags)))
            InitConversionFlags(&flags);
        else
        {
            if (FAILED(GetConversionFlags(pFlags, &flags)))
                InitConversionFlags(&flags);
            pFlags->Release();
        }
        // Enum all connections 
        hr = m_pEvents->EnumConnections(&pEnum);
        if (FAILED(hr))
            goto EXIT;
        VariantInit(&varResult);
        // Create Array of Variants for call
        if (nargin > 0)
        {
            pvars = new VARIANT[nargin];
            if (pvars == NULL)
                goto EXIT;
            for (i=0;i<nargin;i++)
                VariantInit(&pvars[i]);
	        disp.rgvarg = pvars;
	        disp.cArgs = nargin;
        }
        for (i=0;i<nargin;i++)
        {
            if (prhs[i] != NULL)
                mxArray2Variant(prhs[i], &pvars[nargin-i-1], &flags);
        }
        // Get name
        nLen = mbstowcs(NULL, lpszName, 0);
        lpwszName = new OLECHAR[nLen+1];
        if (lpwszName == NULL)
            goto EXIT;
        if (mbstowcs(lpwszName, lpszName, nLen+1) == -1)
            goto EXIT;
        // Loop over all connections and call each one
        pEnum->Reset();
        for(;;)
        {
            hr = pEnum->Next(1, &ConnData, &cFetched);
            if (cFetched == 0)
                break;
            if (ConnData.pUnk != NULL)
            {
                hr = ConnData.pUnk->QueryInterface(IID_IDispatch, (void**)&pDisp);
                ConnData.pUnk->Release();
                if (SUCCEEDED(hr) && pDisp != NULL)
                {
                    hr = pDisp->GetIDsOfNames(IID_NULL, &lpwszName, 1, LOCALE_USER_DEFAULT, &dispid);
                    if (SUCCEEDED(hr))
                    {
                        hr = pDisp->Invoke(dispid, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD, &disp, 
                                           &varResult, NULL, NULL);
                        pDisp->Release();
                        pDisp = NULL;
                        VariantClear(&varResult);
                    }
                }
            }
        }
    EXIT:
        if (pEnum != NULL)
            pEnum->Release();
        if (pDisp != NULL)
            pDisp->Release();
        if (lpwszName != NULL)
            delete [] lpwszName;
        if (pvars != NULL)
        {
            for (i=0;i<nargin;i++)
                VariantClear(&pvars[i]);
            delete [] pvars;
        }
    }
    // Gets a property from the array
    HRESULT GetProperty(const char* name, VARIANT* pvarValue)
    {
        _MCLCONVERSION_FLAGS flags;
        HRESULT hr = S_OK;
        IMWFlags* pFlags = NULL;
        mxArray* px = NULL;

        mwLock lock;
        // Check MCR instance
        if (!m_hinst)
        {
            Error("MCR instance is not available");
            return E_FAIL;
        }
        if (pvarValue == NULL)
            return E_INVALIDARG;
        // Get Conversion flags
        if (FAILED(get_MWFlags(&pFlags)))
        {
            Error("Error getting data conversion flags");
            return E_FAIL;
        }
        if (FAILED(GetConversionFlags(pFlags, &flags)))
        {
            Error("Error getting data conversion flags");
            return E_FAIL;
        }
        pFlags->Release();
        try
        {
            if (!mclGetGlobal(m_hinst, name, &px))
            {
                const char* msg = mclGetLastErrorMessage(m_hinst);
                Error((msg ? msg : "Unspecified error"));
                hr = E_FAIL;
            }
            else
            {
                if (pvarValue->vt != VT_EMPTY)
                    VariantClear(pvarValue);
                mxArray2Variant(px, pvarValue, &flags);
            }
        }
        catch (...)
        {
            Error("Unexpected Error Thrown");
            hr = E_FAIL;       
        }
        if (px)
            mxDestroyArray(px);
        return hr;
    }
    // Sets a property in the array
    HRESULT PutProperty(const char* name, const VARIANT* pvarValue)
    {
        _MCLCONVERSION_FLAGS flags;
        HRESULT hr = S_OK;
        IMWFlags* pFlags = NULL;
        mxArray* px = NULL;

        mwLock lock;
        // Check MCR instance
        if (!m_hinst)
        {
            Error("MCR instance is not available");
            return E_FAIL;
        }
        if (pvarValue == NULL)
            return E_INVALIDARG;
        // Get Conversion flags
        if (FAILED(get_MWFlags(&pFlags)))
        {
            Error("Error getting data conversion flags");
            return E_FAIL;
        }
        if (FAILED(GetConversionFlags(pFlags, &flags)))
        {
            Error("Error getting data conversion flags");
            return E_FAIL;
        }
        pFlags->Release();
        try
        {
            Variant2mxArray(pvarValue, &px, &flags);
            if (!mclSetGlobal(m_hinst, name, px))
            {
                const char* msg = mclGetLastErrorMessage(m_hinst);
                Error((msg ? msg : "Unspecified error"));
                hr = E_FAIL;
            }
        }
        catch (...)
        {
            Error("Unexpected Error Thrown");
            hr = E_FAIL;       
        }
        if (px)
            mxDestroyArray(px);
        return hr;
    }
/*--------------------------------------
  CMCLClassImpl Properties
--------------------------------------*/
private:
    IMWFlags* m_pFlags;             // Pointer to a formatting/conversion-flags object
protected:
    HMCRINSTANCE m_hinst;           // MCR instance
};

template<class T, const IID* piid, class T1, const CLSID* pclsid, const IID* piidEvents = NULL>
class CMCLSingleImpl: public CMCLClassImpl<T, piid, T1, pclsid, piidEvents>
{
/*--------------------------------------
  Construction/destruction
--------------------------------------*/
public:
	// CMCLSingleImpl constructor
	CMCLSingleImpl(){}
	// CMCLSingleImpl destructor
	virtual ~CMCLSingleImpl(){}
/*--------------------------------------
  IUnknown implementation
--------------------------------------*/
public:
	// IUnknown::AddRef implementation
	ULONG __stdcall AddRef()
	{
        return 2;
	}
	// IUnknown::Release implementation
	ULONG __stdcall Release()
	{
        return 1;
	}
	// Called by COM framework to get IClassFactory pointer on which to create new instances of object
	static HRESULT __stdcall GetClassObject(REFCLSID clsid, REFIID iid, void** ppv)
	{	
		if(clsid != *pclsid)
			return CLASS_E_CLASSNOTAVAILABLE;

		CMCLSingleFactoryImpl<T1>* pFactory = new CMCLSingleFactoryImpl<T1>;
		if(pFactory == NULL)
			return E_OUTOFMEMORY;

		// QueryInterface for IClassFactory
		HRESULT hr = pFactory->QueryInterface(iid, ppv);
		pFactory->Release();
		return hr;
	}
};

/*------------------------------------------------------------------------------
  Standard Class factory implementation.
------------------------------------------------------------------------------*/
template<class T>
class CMCLFactoryImpl : public IClassFactory
{
public:
	// Construction/destruction
	CMCLFactoryImpl() : m_cRef(1) { }
	virtual ~CMCLFactoryImpl() { }

	// IClassFactory::AddRef implementation
	ULONG __stdcall AddRef()
	{
		return InterlockedIncrement(&m_cRef);
	}
	// IClassFactory::Release implementation
	ULONG __stdcall Release()
	{
        ULONG cRef = InterlockedDecrement(&m_cRef);
		if(cRef != 0)
			return cRef;
		delete this;
		return 0;
	}
	// IClassFactory::QueryInterface implementation
	HRESULT __stdcall QueryInterface(REFIID iid, void** ppv)
	{
		if((iid == IID_IUnknown) || (iid == IID_IClassFactory))
			*ppv = (IClassFactory*)this;
		else
		{
			*ppv = NULL;
			return E_NOINTERFACE;
		}
		AddRef();
		return S_OK;
	}
	// IClassFactory::CreateInstance implementation
	virtual HRESULT __stdcall CreateInstance(IUnknown *pUnknownOuter, REFIID iid, void** ppv)
	{
		if(pUnknownOuter != NULL)
			return CLASS_E_NOAGGREGATION;
		
		T* p = new T;

		if(p == NULL)
			return E_OUTOFMEMORY;

		// Call the Init method to load the type information
		p->Init();

		HRESULT hr = p->QueryInterface(iid, ppv);
		p->Release();
		return hr;
	}
	// IClassFactory::LockServer implementation
	HRESULT __stdcall LockServer(BOOL bLock)
	{
		if(bLock)
			g_Module.Lock();
		else
			g_Module.Unlock();
		return S_OK;
	}
private:
	long m_cRef;	// Ref count
};

/*------------------------------------------------------------------------------
  Singleton Class factory implementation.
------------------------------------------------------------------------------*/
template<class T>
class CMCLSingleFactoryImpl : public CMCLFactoryImpl<T>
{
public:
	// IClassFactory::CreateInstance implementation
	HRESULT __stdcall CreateInstance(IUnknown *pUnknownOuter, REFIID iid, void** ppv)
	{
        mwLock lock;
		if(pUnknownOuter != NULL)
			return CLASS_E_NOAGGREGATION;
        if (m_p == NULL)
        {
            m_p = new T;
            if(m_p == NULL)
            {
			    return E_OUTOFMEMORY;
            }
            m_p->Init();
            m_p->AddRef();
        }
        HRESULT hr = m_p->QueryInterface(iid, ppv);
		m_p->Release();
		return hr;
	}
private:
	long m_cRef;	// Ref count
    static T* m_p;  // Static instance of T
};

class CMCLEnumConnectionPoints : public IEnumConnectionPoints
{
public:
/*--------------------------------------
  Construction/destruction
--------------------------------------*/
    // CMCLEnumConnectionPoints default constructor
    CMCLEnumConnectionPoints()
    {
        m_cRef = 1;
	    m_nIndex = 0;
        m_pThis = NULL;
        m_rgpcn = NULL;
        m_cConnections = 0;
    }
    // CMCLEnumConnectionPoints constructor from container reference and array of connection points
    CMCLEnumConnectionPoints(IUnknown* pThis, ULONG cConnections, IConnectionPoint** rgpcn)
    {
        m_cRef = 1;
	    m_nIndex = 0;
        m_pThis = pThis;
        m_rgpcn = NULL;
        m_cConnections = 0;
        if (cConnections > 0 && rgpcn != NULL)
        {
            m_cConnections = cConnections;
            m_rgpcn = new IConnectionPoint*[m_cConnections];
            if (m_rgpcn != NULL)
            {
	            for(ULONG i=0;i<cConnections;i++)
                {
                    m_rgpcn[i] = NULL;
                    if (rgpcn[i] != NULL)
		                rgpcn[i]->QueryInterface(IID_IConnectionPoint, (void**)&m_rgpcn[i]);
                }
            }
            else
                m_cConnections = 0;
        }
    }
    // CMCLEnumConnectionPoints destructor
	virtual ~CMCLEnumConnectionPoints()
    {
        if (m_rgpcn != NULL)
        {
            for (long i=0;i<m_cConnections;i++)
            {
                if (m_rgpcn[i] != NULL)
                    m_rgpcn[i]->Release();
            }
            delete [] m_rgpcn;
        }
    }
/*--------------------------------------
  IUnknown implementation
--------------------------------------*/
public:
	// IUnknown::AddRef implementation
	ULONG __stdcall AddRef()
    {
        if (m_pThis != NULL)
	        m_pThis->AddRef();
	    return InterlockedIncrement(&m_cRef);
    }
    // IUnknown::Release implementation
	ULONG __stdcall Release()
    {
        if (m_pThis != NULL)
	        m_pThis->Release();
	    ULONG cRef = InterlockedDecrement(&m_cRef);
		if(cRef != 0)
			return cRef;
        delete this;
        return 0;
    }
	// IUnknown::QueryInterface implementation
	HRESULT __stdcall QueryInterface(REFIID riid, void** ppv)
	{
		if(riid == IID_IEnumConnectionPoints)
			*ppv = static_cast<IEnumConnectionPoints*>(this);
		else if(riid == IID_IUnknown)
			*ppv = static_cast<IUnknown*>(this);
		else
		{
			*ppv = NULL;
			return E_NOINTERFACE;
		}
		AddRef();
		return S_OK;
	}
/*--------------------------------------
  IEnumConnectionPoints implementation
--------------------------------------*/
	// IEnumConnectionPoints::Next implementation
	HRESULT __stdcall Next(ULONG cConnections, IConnectionPoint** rgpcn, ULONG* pcFetched)
    {
        long nIndex = 0;
        HRESULT hr = S_OK;

	    if(rgpcn == NULL || pcFetched == NULL)
		    return E_INVALIDARG;
	    *pcFetched = 0;
	    if (cConnections == 0)
            return S_OK;
	    for (ULONG i=0;i<cConnections;i++)
	    {
            InterlockedExchange(&nIndex, m_nIndex);
            if (nIndex >= m_cConnections)
            {
                hr = S_FALSE;
                break;
            }
		    rgpcn[i] = m_rgpcn[nIndex];
		    if(rgpcn[i] != NULL)
			    rgpcn[i]->AddRef();
			(*pcFetched)++;
            InterlockedIncrement(&m_nIndex);
	    }
	    return hr;
    }
    // IEnumConnectionPoints::Skip implementation
	HRESULT __stdcall Skip(ULONG cConnections)
    {
        long nIndex = 0;
        HRESULT hr = S_OK;

        InterlockedExchange(&nIndex, m_nIndex);
        if (nIndex >= m_cConnections)
            return S_FALSE;
        for (ULONG i=0;i<cConnections;i++)
	    {
            nIndex = InterlockedIncrement(&m_nIndex);
            if (nIndex >= m_cConnections)
            {
                hr = S_FALSE;
                break;
            }
        }
        return hr;
    }
    // IEnumConnectionPoints::Reset implementation
	HRESULT __stdcall Reset()
    {
        InterlockedExchange(&m_nIndex, 0);
        return S_OK;
    }
    // IEnumConnectionPoints::Clone implementation
	HRESULT __stdcall Clone(IEnumConnectionPoints** ppEnum)
    {
        CMCLEnumConnectionPoints* pNew = NULL;
        HRESULT hr = S_OK;

	    if(ppEnum == NULL)
		    return E_INVALIDARG;
	    *ppEnum = NULL;
        pNew = new CMCLEnumConnectionPoints(m_pThis, m_cConnections, m_rgpcn);
        if(pNew == NULL)
            return E_OUTOFMEMORY;
        pNew->m_nIndex = m_nIndex;
        hr = pNew->QueryInterface(IID_IEnumConnectionPoints, (void**)ppEnum);
        pNew->Release();
        return hr;
    }
/*--------------------------------------
  CMCLEnumConnectionPoints Properties
--------------------------------------*/
private:
	long m_cRef;
    IUnknown* m_pThis;          // Containing IUnknown for ref counting
    long m_nIndex;              // Index of current element
    IConnectionPoint** m_rgpcn; // Array of connection points
    long m_cConnections;        // Number of connection points in the array
};

class CMCLEnumConnections : public IEnumConnections
{
public:
/*--------------------------------------
  Construction/destruction
--------------------------------------*/
    // CMCLEnumConnections default constructor
    CMCLEnumConnections()
    {
        m_cRef = 1;
	    m_nIndex = 0;
        m_pThis = NULL;
        m_rgpcd = NULL;
        m_cConnections = 0;
    }
    // CMCLEnumConnections constructor from parent connection point reference and array of CONNECTDATA's
    CMCLEnumConnections(IUnknown* pThis, ULONG cConnections, CONNECTDATA* rgpcd)
    {
        m_cRef = 1;
	    m_nIndex = 0;
        m_pThis = pThis;
        m_rgpcd = NULL;
        m_cConnections = 0;
        if (cConnections > 0 && rgpcd != NULL)
        {
            m_cConnections = cConnections;
            m_rgpcd = new CONNECTDATA[m_cConnections];
            if (m_rgpcd != NULL)
            {
	            for(ULONG i=0;i<cConnections;i++)
                {
                    m_rgpcd[i] = rgpcd[i];
                    if (m_rgpcd[i].pUnk != NULL)
                        m_rgpcd[i].pUnk->AddRef();
                }
            }
            else
                m_cConnections = 0;
        }
    }
    // CMCLEnumConnections constructor from parent connection point reference and vector class of CONNECTDATA's
    CMCLEnumConnections(IUnknown* pThis, vector<CONNECTDATA*>& vecpcd)
    {
        vector<CONNECTDATA*>::iterator it;
        CONNECTDATA* pConnData = NULL;
        int i = 0;

        m_cRef = 1;
	    m_nIndex = 0;
        m_pThis = pThis;
        m_rgpcd = NULL;
        m_cConnections = 0;
        if (vecpcd.size() > 0)
        {
            m_cConnections = vecpcd.size();
            m_rgpcd = new CONNECTDATA[m_cConnections];
            if (m_rgpcd != NULL)
            {
	            for(it = vecpcd.begin(); it != vecpcd.end(); it++)
                {
                    pConnData = *it;
                    if (pConnData != NULL)
                    {
                        m_rgpcd[i] = *pConnData;
                        if (m_rgpcd[i].pUnk != NULL)
                            m_rgpcd[i].pUnk->AddRef();
                    }
                    else
                    {
                        m_rgpcd[i].pUnk = NULL;
                        m_rgpcd[i].dwCookie = 0;
                    }
                }
                i++;
            }
            else
                m_cConnections = 0;
        }
    }
    // CMCLEnumConnections destructor
	virtual ~CMCLEnumConnections()
    {
        if (m_rgpcd != NULL)
        {
            for (long i=0;i<m_cConnections;i++)
            {
                if (m_rgpcd[i].pUnk != NULL)
                    m_rgpcd[i].pUnk->Release();
            }
            delete [] m_rgpcd;
        }
    }
/*--------------------------------------
  IUnknown implementation
--------------------------------------*/
public:
	// IUnknown::AddRef implementation
	ULONG __stdcall AddRef()
    {
        if (m_pThis != NULL)
	        m_pThis->AddRef();
	    return InterlockedIncrement(&m_cRef);
    }
    // IUnknown::Release implementation
	ULONG __stdcall Release()
    {
        if (m_pThis != NULL)
	        m_pThis->Release();
	    ULONG cRef = InterlockedDecrement(&m_cRef);
		if(cRef != 0)
			return cRef;
        delete this;
        return 0;
    }
	// IUnknown::QueryInterface implementation
	HRESULT __stdcall QueryInterface(REFIID riid, void** ppv)
	{
		if(riid == IID_IEnumConnections)
			*ppv = static_cast<IEnumConnections*>(this);
		else if(riid == IID_IUnknown)
			*ppv = static_cast<IUnknown*>(this);
		else
		{
			*ppv = NULL;
			return E_NOINTERFACE;
		}
		AddRef();
		return S_OK;
	}
/*--------------------------------------
  IEnumConnections implementation
--------------------------------------*/
public:
    // IEnumConnections::Next implementation
	HRESULT __stdcall Next(ULONG cConnections, CONNECTDATA* rgpcd, ULONG* pcFetched)
    {
        long nIndex = 0;
        HRESULT hr = S_OK;

	    if(rgpcd == NULL || pcFetched == NULL)
		    return E_INVALIDARG;
	    *pcFetched = 0;
	    if (cConnections == 0)
            return S_OK;
	    for (ULONG i=0;i<cConnections;i++)
	    {
            InterlockedExchange(&nIndex, m_nIndex);
            if (nIndex >= m_cConnections)
            {
                hr = S_FALSE;
                break;
            }
		    rgpcd[i] = m_rgpcd[nIndex];
		    if(rgpcd[i].pUnk != NULL)
			    rgpcd[i].pUnk->AddRef();
			(*pcFetched)++;
            InterlockedIncrement(&m_nIndex);
	    }
	    return hr;
    }
    // IEnumConnections::Skip implementation
	HRESULT __stdcall Skip(ULONG cConnections)
    {
        long nIndex = 0;
        HRESULT hr = S_OK;

        InterlockedExchange(&nIndex, m_nIndex);
        if (nIndex >= m_cConnections)
            return S_FALSE;
        for (ULONG i=0;i<cConnections;i++)
	    {
            nIndex = InterlockedIncrement(&m_nIndex);
            if (nIndex >= m_cConnections)
            {
                hr = S_FALSE;
                break;
            }
        }
        return hr;
    }
    // IEnumConnections::Reset implementation
	HRESULT __stdcall Reset()
    {
        InterlockedExchange(&m_nIndex, 0);
        return S_OK;
    }
    // IEnumConnections::Clone implementation
	HRESULT __stdcall Clone(IEnumConnections** ppEnum)
    {
        CMCLEnumConnections* pNew = NULL;
        HRESULT hr = S_OK;

	    if(ppEnum == NULL)
		    return E_INVALIDARG;
	    *ppEnum = NULL;
        pNew = new CMCLEnumConnections(m_pThis, m_cConnections, m_rgpcd);
        if(pNew == NULL)
            return E_OUTOFMEMORY;
        pNew->m_nIndex = m_nIndex;
        hr = pNew->QueryInterface(IID_IEnumConnections, (void**)ppEnum);
        pNew->Release();
        return hr;
    }
/*--------------------------------------
  CMCLEnumConnectionPoints Properties
--------------------------------------*/
private:
	long m_cRef;
    IUnknown* m_pThis;           // Containing IUnknown for ref counting
    long m_nIndex;               // Index of current element
    long m_cConnections;         // Number of connections in the array
    CONNECTDATA* m_rgpcd;        // Array of connections
};

template<const IID* piid>
class CMCLConnectionPointImpl : public IConnectionPoint
{
/*--------------------------------------
  Construction/destruction
--------------------------------------*/
public:
    // CMCLConnectionPointImpl default constructor
    CMCLConnectionPointImpl()
    {
        m_cRef = 1;
	    m_pCPC = NULL;
        m_nNextCookie = 0;
    }
    // CMCLConnectionPointImpl constructor from container reference
    CMCLConnectionPointImpl(IConnectionPointContainer* pCPC)
    {
        m_cRef = 1;
	    m_pCPC = NULL;
        m_nNextCookie = 0;
        m_pCPC = pCPC;
    }
    // CMCLConnectionPointImpl destructor
	~CMCLConnectionPointImpl()
    {
        vector<CONNECTDATA*>::iterator it;
        CONNECTDATA* pConnData = NULL;

        for(it = m_vecpcd.begin(); it != m_vecpcd.end(); it++)
        {
		    pConnData = *it;
            if (pConnData != NULL)
            {
                if (pConnData->pUnk != NULL)
                    pConnData->pUnk->Release();
                delete pConnData;
            }
        }
        m_vecpcd.clear();
    }
/*--------------------------------------
  IUnknown implementation
--------------------------------------*/
public:
	// IUnknown::AddRef implementation
	ULONG __stdcall AddRef()
    {
	    return InterlockedIncrement(&m_cRef);
    }
    // IUnknown::Release implementation
	ULONG __stdcall Release()
    {
	    ULONG cRef = InterlockedDecrement(&m_cRef);
		if(cRef != 0)
			return cRef;
        delete this;
        return 0;
    }
	// IUnknown::QueryInterface implementation
	HRESULT __stdcall QueryInterface(REFIID riid, void** ppv)
	{
		if(riid == IID_IConnectionPoint)
			*ppv = static_cast<IConnectionPoint*>(this);
		else if(riid == IID_IUnknown)
			*ppv = static_cast<IUnknown*>(this);
		else
		{
			*ppv = NULL;
			return E_NOINTERFACE;
		}
		AddRef();
		return S_OK;
	}

/*--------------------------------------
  IConnectionPoint implementation
--------------------------------------*/
    // IConnectionPoint::GetConnectionInterface implementation
	HRESULT __stdcall GetConnectionInterface(IID *pIID)
    {
        if (pIID == NULL)
            return E_INVALIDARG;
        *pIID = *piid;
        return S_OK;
    }
    // IConnectionPoint::GetConnectionPointContainer implementation
	HRESULT __stdcall GetConnectionPointContainer(IConnectionPointContainer** ppCPC)
    {
        if (ppCPC == NULL)
            return E_POINTER;
        if (m_pCPC == NULL)
            return E_UNEXPECTED;
        *ppCPC = m_pCPC;
        if (*ppCPC != NULL)
            (*ppCPC)->AddRef();
        return S_OK;
    }
    // IConnectionPoint::Advise implementation
	HRESULT __stdcall Advise(IUnknown* pUnk, DWORD* pdwCookie)
    {
    	IUnknown* pSink = NULL;
        long nCookie = 0;
        CONNECTDATA* pConnData = NULL;

        mwLock lock;
        if (pUnk == NULL || pdwCookie == NULL)
            return E_POINTER;
	    *pdwCookie = 0;
	    if(FAILED(pUnk->QueryInterface(*piid, (void**)&pSink)))
		    return CONNECT_E_CANNOTCONNECT;
        pConnData = new CONNECTDATA;
        if (pConnData == NULL)
            return E_OUTOFMEMORY;
        nCookie = InterlockedIncrement(&m_nNextCookie);
        pConnData->dwCookie = (DWORD)nCookie;
        pConnData->pUnk = pUnk;
	    m_vecpcd.push_back(pConnData);
        return S_OK;
    }
    // IConnectionPoint::Unadvise implementation
	HRESULT __stdcall Unadvise(DWORD dwCookie)
    {
        vector<CONNECTDATA*>::iterator it;
        CONNECTDATA* pConnData = NULL;
        bool bFound = false;
        
        mwLock lock;
	    if(dwCookie == 0)
		    return CONNECT_E_NOCONNECTION;
	    for(it = m_vecpcd.begin(); it != m_vecpcd.end(); it++)
        {
		    pConnData = *it;
            if (pConnData != NULL)
            {
                if (pConnData->dwCookie == dwCookie)
                {
                    bFound = true;
                    if (pConnData->pUnk != NULL)
                        pConnData->pUnk->Release();
                    delete pConnData;
                    break;
                }
            }
        }
        if (bFound)
        {
            m_vecpcd.erase(it);
            return S_OK;
        }
	    return CONNECT_E_NOCONNECTION;
    }
    // IConnectionPoint::EnumConnections implementation
	HRESULT __stdcall EnumConnections(IEnumConnections** ppEnum)
    {
        CMCLEnumConnections* pEnum = NULL;

        mwLock lock;
        if (ppEnum == NULL)
            return E_POINTER;
	    *ppEnum = NULL;
	    pEnum = new CMCLEnumConnections(this, m_vecpcd);
        if (pEnum == NULL)
            return E_OUTOFMEMORY;
	    if (FAILED(pEnum->QueryInterface(IID_IEnumConnections, (void**)ppEnum)))
            return E_UNEXPECTED;
        return S_OK;
    }
/*--------------------------------------
  CConnectionPoint Properties
--------------------------------------*/
private:
	long m_cRef;                        // Reference count
	IConnectionPointContainer* m_pCPC;  // Pointer to parent container
    long m_nNextCookie;                 // Next available cookie value
    vector<CONNECTDATA*> m_vecpcd;      // Array of connections
};


#endif //ifdef __cplusplus
#endif //ifndef _MCLCOMCLASS_H_
