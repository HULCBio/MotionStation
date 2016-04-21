// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.3 $  $Date: 2003/08/29 04:43:08 $
#ifndef __CIRBUF__
#define __CIRBUF__
/*cirbuf.h
This is the interface to a simple class that implements a circular buffer
*/
class CCircBufferBase
{
public:
    CCircBufferBase(): m_Size(0),m_ReadLoc(0),m_WriteLoc(0) {}
    // ValidData returns 0 if m_ReadLoc==m_WriteLoc copyout will copy if called
    int ValidData() {
        return  (m_ReadLoc<=m_WriteLoc ? m_WriteLoc-m_ReadLoc :m_Size-(m_ReadLoc-m_WriteLoc) );
    }

    int MaxRead() {
        return (m_ReadLoc<=m_WriteLoc ? m_WriteLoc-m_ReadLoc :m_Size-m_ReadLoc);
    }
    // returns m_Size if m_ReadLoc==m_WriteLoc
    int FreeSpace() 
    {
        if (m_ReadLoc<=m_WriteLoc)
            return m_Size-(m_WriteLoc-m_ReadLoc);
        else
            return (m_ReadLoc-m_WriteLoc);
    }
    int GetBufferSize() {return m_Size;}
    int GetReadLoc() { return m_ReadLoc;}
    int GetWriteLoc() {return m_WriteLoc;}
    bool IsWriteOverrun(int loc) // returns true for an overrun
    {   
        return  ( m_WriteLoc < m_ReadLoc ? //if  
            (loc < m_WriteLoc) || (loc >= m_ReadLoc) //then
            :(loc < m_WriteLoc) && (loc >= m_ReadLoc) ) ; } //else  false for m_ReadLoc==m_WriteLoc
    void SetReadLocation(int loc)  {m_ReadLoc = loc;};
    void SetWriteLocation(int loc) {m_WriteLoc = loc;};
    void Reset() 
    {         
        m_ReadLoc=0;
        m_WriteLoc=0;
    }

protected:
    int m_Size;
    int m_ReadLoc,m_WriteLoc;
private:
    CCircBufferBase(const CCircBufferBase&); // not defined deliberatly
    CCircBufferBase& operator=(const CCircBufferBase&);
};

template <class T> class TCircBuffer: public CCircBufferBase 
{
public:
    typedef T CBT;
    TCircBuffer():m_Buffer(NULL) {Initialize(0);}
    ~TCircBuffer()
    {
        if (m_Buffer)
            VirtualFree(m_Buffer,0,MEM_RELEASE);
        m_Buffer=NULL;
    }
    HRESULT Initialize(int Size)
    {
        if (Size!=m_Size)
        {
            if (m_Buffer)
                VirtualFree(m_Buffer,0,MEM_RELEASE);
            if(Size)
            {
                m_Buffer=(CBT*)VirtualAlloc(NULL, Size*sizeof(CBT), MEM_COMMIT, PAGE_READWRITE);
                if (m_Buffer==NULL) return E_OUTOFMEMORY;
            }
            else
                m_Buffer=NULL;
            m_Size=Size;
        }
        m_ReadLoc=0;
        m_WriteLoc=0;
        return(S_OK);
    }
    // assumes size is full if m_ReadLoc==m_WriteLoc
    void GetReadPointers(CBT **ptr1, int *size1, CBT **ptr2, int *size2) {
        if (m_ReadLoc<m_WriteLoc) {
            *size1 = m_WriteLoc-m_ReadLoc;
            *ptr1 = &m_Buffer[m_ReadLoc];
            *size2 = 0;
            *ptr2 = NULL;
        }
        else {
            *size1 = m_Size-m_ReadLoc;
            *ptr1 = &m_Buffer[m_ReadLoc];
            *size2 = m_WriteLoc;
            *ptr2 = m_Buffer;
        }
    };
    void GetWritePointers(CBT **ptr1, int *size1, CBT **ptr2, int *size2) {
        if (m_WriteLoc<m_ReadLoc) {
            *size1 = m_ReadLoc-m_WriteLoc;
            *ptr1 = &m_Buffer[m_WriteLoc];
            *size2 = 0;
            *ptr2 = NULL;
        }
        else {
            *size1 = m_Size-m_WriteLoc;
            *ptr1 = &m_Buffer[m_WriteLoc];
            *size2 = m_ReadLoc;
            *ptr2 = m_Buffer;
        }
    };
    // this function will mask the one in the base class
    void SetWriteLocation(CBT *ptr) {m_WriteLoc = ptr - m_Buffer;};
    void SetWriteLocation(int loc) {CCircBufferBase::SetWriteLocation(loc);};

    void CopyIn(CBT *ptr,int size)
    {
        int size1,size2;
        CBT *ptr1, *ptr2;
        GetWritePointers(&ptr1, &size1, &ptr2, &size2);
        int points = min(size1 ,(int)size);
        memcpy(ptr1,ptr,points*sizeof(CBT));
        m_WriteLoc+=points;
        if (m_WriteLoc>m_Size) m_WriteLoc=0;
        //ASSERT(bytes == OutSize);
        if (size2  && points<size) 
        {
            points = min(size2 ,size-points);
            CopyMemory(ptr2,ptr+size1 ,points*sizeof(CBT));
            m_WriteLoc = points;
        }

    }
    // if called when m_ReadLoc==m_WriteLoc assumes that buffer is full
    void CopyOut(CBT *dest,int size)
    {
        int size1,size2;
        CBT *ptr1, *ptr2;
        GetReadPointers(&ptr1, &size1, &ptr2, &size2);
        int points = min(size1 ,(int)size);
        memcpy(dest ,ptr1,points*sizeof(CBT));
        m_ReadLoc+=points;
        if (m_ReadLoc>m_Size) m_ReadLoc=0;
        //ASSERT(bytes == OutSize);
        if (size2  && points<size) 
        {
            points = min(size2 ,size-points);
            CopyMemory(dest+size1 ,ptr2,points*sizeof(CBT));
            m_ReadLoc = points;
        }
        
    }
    CBT *GetPtr() {return m_Buffer;}
    int GetBufferSizeBytes() {return m_Size*sizeof(CBT);}

protected:
    CBT *m_Buffer;
};


#endif  //#ifndef __CIRBUF__
