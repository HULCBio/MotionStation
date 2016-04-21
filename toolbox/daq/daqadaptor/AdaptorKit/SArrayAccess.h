// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.2.4.3 $  $Date: 2003/08/29 04:44:07 $

#ifndef __SArrayAccess__
#define __SArrayAccess__
#include <typeinfo.h>

class CSafeArrayAccess
{
protected:
    CSafeArrayAccess():ps(NULL)
    {
    }

public:
    CSafeArrayAccess(const VARIANT *Source)
    {
        if (V_ISARRAY (Source) || V_ISVECTOR (Source))
        {
            ps   = V_ARRAY(Source);
            if (ps==NULL) 
            {
                _RPT0(_CRT_ERROR,"Invalid SafeArray passed to CSafeArrayAccess.");
            }
        }
    }
    int Size() 
    {
        int nDims = SafeArrayGetDim(ps);
        
        // get the lower and upper bound of each dimension of the array
        int totsize=1;
        for (int i = 0; i < nDims; i++)
        {
            long	uBound, lBound;	
            SafeArrayGetLBound (ps, i+1, &lBound);
            SafeArrayGetUBound (ps, i+1, &uBound);
            totsize*=uBound-lBound+1;
        }
        return totsize;        
    }

    int Dims()
    {
        return SafeArrayGetDim(ps);
    }

    int SizeDim(int Dim)
    {
        long	uBound, lBound;	
        SafeArrayGetLBound (ps, Dim+1, &lBound);
        SafeArrayGetUBound (ps, Dim+1, &uBound);
        return uBound-lBound+1;
    }
    SAFEARRAY *ps;
};

template <class T> class TSafeArrayAccess :public CSafeArrayAccess
{
protected:
    TSafeArrayAccess(): pData(NULL)
    {
    }

public:
    TSafeArrayAccess(const VARIANT *Source): pData(NULL)
    {
        if (V_ISARRAY (Source) || V_ISVECTOR (Source))
        {
            ps   = V_ARRAY(Source);
            if (ps==NULL) 
            {
                _RPT0(_CRT_ERROR,"Invalid SafeArray passed to TSafeArrayAccess.");
                return;
            }

            if (GetArgVarType()!= (V_VT(Source) & VT_TYPEMASK))
            {
                _RPT0(_CRT_ERROR,"Variant SafeArray is incorrect type for TSafeArrayAccess");
                return;
            }
            CHECK_HRESULT(SafeArrayAccessData (ps, (void **) &pData));
        }
    }
    ~TSafeArrayAccess()
    {
        if (pData)
            SafeArrayUnaccessData(ps);
    }
    T& operator [](int i)
    {
        _ASSERTE(pData);
        return pData[i];
    }
    T* Ptr()
    {
        _ASSERTE(pData);
        return pData;
    }

    static VARTYPE GetArgVarType()
    {
        typedef T TYPE;
        if(typeid(TYPE) == typeid(double))
            return VT_R8;
        
        if(typeid(TYPE) == typeid(float))
            return VT_R4;
        
        if(typeid(TYPE) == typeid(long) ||
            typeid(TYPE) == typeid(int))
            return VT_I4;

        if(typeid(TYPE) == typeid(unsigned long) ||
            typeid(TYPE) == typeid(unsigned int))
            return VT_UI4;
        
        if(typeid(TYPE) == typeid(BOOL))
            return VT_BOOL;
        
        if(typeid(TYPE) == typeid(short))
            return VT_I2;

        if(typeid(TYPE) == typeid(unsigned short))
            return VT_UI2;
        
        if(typeid(TYPE) == typeid(unsigned char))
            return VT_UI1;
        
        if(typeid(TYPE) == typeid(char)) // why unsigned ?
            return VT_I1;
        
        if (typeid(TYPE) == typeid(BSTR))
            return VT_BSTR;
        
        if(typeid(TYPE)== typeid(CComBSTR))
            return VT_BSTR;
        
        if(typeid(TYPE) == typeid(VARIANT))
            return VT_VARIANT;
        
        if(typeid(TYPE) == typeid(LPDISPATCH))
            return VT_DISPATCH;
        
        if(typeid(TYPE) == typeid(LPUNKNOWN))
            return VT_UNKNOWN;
        
        return 0;
    }

    T* pData;
    private:
    // no copy constructor
    TSafeArrayAccess(TSafeArrayAccess<T> &);
    // no equals operator
    TSafeArrayAccess<T> & operator =(TSafeArrayAccess<T> &);

};

template <class T> class TSafeArrayVector :public TSafeArrayAccess<T>
{
public:
    TSafeArrayVector()
    {
    }
    HRESULT Allocate(int size)
    {
        _ASSERTE(var.vt==VT_EMPTY);
        ps = SafeArrayCreateVector(GetArgVarType(), 0, size);
        if (ps==NULL) return ERROR_OUTOFMEMORY;
        HRESULT hRes = SafeArrayAccessData (ps, (void **) &pData);
        if (FAILED (hRes)) 
        {
            SafeArrayDestroy (ps);
            return ERROR_OUTOFMEMORY;
        }
                
        // set the data type and values
        var.vt=VT_ARRAY | GetArgVarType();
        var.parray=ps;
        return S_OK;
    }
    ~TSafeArrayVector() 
    {
        if (pData)
            SafeArrayUnaccessData(ps);
        pData=NULL;
        ps=NULL;
    }
    HRESULT Clear()
    {
        if (pData)
            SafeArrayUnaccessData(ps);
        pData=NULL;
        ps=NULL;
        return var.Clear();
    }
    HRESULT Detach(VARIANT* pDest)
    {
        HRESULT status=var.Detach(pDest);
        Clear();
        return status;
    }
    operator const CComVariant&() { return var;}
    VARIANT* operator&()
    {
        return &var;
    }

private:
    // no copy constructor
    TSafeArrayVector(TSafeArrayVector<T> &);
    // no equals operator
    TSafeArrayVector<T> & operator =(TSafeArrayVector<T> &);
    
    CComVariant var;
};

template <class T >
HRESULT CreateSafeVector(const T *Values,int size,CComVariant *Dest)
{
    HRESULT hRes =Dest->Clear();
    if (FAILED(hRes))
    {
        ATLTRACE("VariantClear Failed with status %x",hRes);
        return hRes;
    }
    SAFEARRAY *ps = SafeArrayCreateVector(TSafeArrayAccess<T>::GetArgVarType(), 0, size);
    if (ps==NULL) return ERROR_OUTOFMEMORY;
    
    T *sdata;
    

    hRes = SafeArrayAccessData (ps, (void **) &sdata);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        return ERROR_OUTOFMEMORY;
    }
    _ASSERT(TSafeArrayAccess<T>::GetArgVarType() !=VT_BSTR);  // BSTRS not supported
    if (Values) 
        memcpy(sdata,Values,size*sizeof(T));
    
    SafeArrayUnaccessData (ps);

    // set the data type and values
    V_VT(Dest)=VT_ARRAY | TSafeArrayAccess<T>::GetArgVarType();
    V_ARRAY(Dest)=ps;
    return S_OK;
}

template <>
inline HRESULT CreateSafeVector(const LPCOLESTR  *Values,int size,CComVariant *Dest)
{
    HRESULT hRes =Dest->Clear();
    if (FAILED(hRes))
    {
        ATLTRACE("VariantClear Failed with status %x",hRes);
        return hRes;
    }
    SAFEARRAY *ps = SafeArrayCreateVector(VT_BSTR, 0, size);
    if (ps==NULL) return ERROR_OUTOFMEMORY;
    
    CComBSTR* sdata;
    

    hRes = SafeArrayAccessData (ps, (void **) &sdata);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        return hRes;
    }
    
    for (int i=0;i<size;i++)
        sdata[i]=Values[i];
    
    SafeArrayUnaccessData (ps);

    // set the data type and values
    V_VT(Dest)=VT_ARRAY | VT_BSTR;
    V_ARRAY(Dest)=ps;
    return S_OK;
}
// This function should replace the one above 
/*
template <class T >
inline HRESULT CreateSafeVector(const T *Values,int size,CComVariant *Dest)
{
    HRESULT hRes =Dest->Clear();
    if (FAILED(hRes))
    {
        ATLTRACE("VariantClear Failed with status %x",hRes);
        return hRes;
    }

    VARTYPE ty=TSafeArrayAccess<T>::GetArgVarType();

    SAFEARRAY *ps = SafeArrayCreateVector(ty, 0, size);
    if (ps==NULL) return ERROR_OUTOFMEMORY;
    
    V_VT(Dest)=VT_ARRAY | ty;
    V_ARRAY(Dest)=ps;

    TSafeArrayAccess<T> sa(Dest);
    
    for (int i=0;i<size;i++)
        sa[i]=Values[i];
    
    // set the data type and values
    return S_OK;
}
*/
#if 0
template <>
inline HRESULT CreateSafeVector(const LPCOLESTR  *Values,int size,CComVariant *Dest)
{
    // this code is a slight kludge and may brake 
    // if the implementatioon of CComBSTR or CreateSeveVector(CComBSTR...) changes 
    return CreateSafeVector((const CComBSTR *)Values,size,Dest);
}
#endif

#endif // __SArrayAccess__
