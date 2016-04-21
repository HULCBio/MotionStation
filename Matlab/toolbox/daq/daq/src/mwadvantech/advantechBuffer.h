// advantechBuffer.h : Declaration of CadvBuffer class
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:30:22 $


#ifndef __advBuffer_H_
#define __advBuffer_H_

#include "cirbuf.h"


////////////////////////////////////////////////////////////////////////////////////
// This class has been overloaded from cirbuf.h to handle Advantech transfers and
// buffer allocation for DMA.
////////////////////////////////////////////////////////////////////////////////////
class CadvBuffer : public  TCircBuffer<unsigned short>
{
private:
	bool m_transferDMA;		// Local storage of Transfer Mode: True for DMA transfers
	USHORT m_transferOverrun; 
	
public:
	// Need to overload the initialise and destroy methods to handle DMA transfers
	long m_driverHandle;	// Local storage of Advantech Driver Handle
	PT_FAITransfer m_ptFAITransfer;
	CadvBuffer():
	  m_transferDMA(false),
	  m_driverHandle(NULL),
	  m_transferOverrun(0)
	  {
	    Initialize(0, false, 0); 
	  }
    ~CadvBuffer()
    {
		//DEBUG: ATLTRACE("In buffer destructor..");
        if (m_Buffer)
		{
			if (m_transferDMA)
			{
				// Free the DMA buffer through Advantech
				if (m_driverHandle)
				{
					//DEBUG: ATLTRACE("Freeing DMA buffer from %x..", m_Buffer);
					LRESULT FreeDMABuffererror = DRV_FreeDMABuffer(m_driverHandle, (LPARAM)&m_Buffer);
					//DEBUG: ATLTRACE("Now m_Buffer is %x..", m_Buffer);
				}
			}
			else
			{
				VirtualFree(m_Buffer,0,MEM_RELEASE);
			}
		}
        m_Buffer=NULL;
		//DEBUG: ATLTRACE("Done.\n");
    }
	void SetDriverHandle(long driverHandle) {m_driverHandle = driverHandle;}
	
    HRESULT Initialize(int Size, bool isDMA, USHORT cyclicMode)
    {
		ULONG actSize;
		LONG errCode;
		if (!m_driverHandle)
		{
			return E_BUFDRVHANDLE;
		}
		ATLTRACE("In Initialize..");
        m_ptFAITransfer.ActiveBuf = 0;   
        m_ptFAITransfer.DataType = 0; // 0 => USORT, 1 => FLOAT
        m_ptFAITransfer.overrun  = &m_transferOverrun;

        if ((Size!=m_Size) || (m_transferDMA!=isDMA))
        {
            if (m_Buffer)	// Free the buffer if it exists
			{
				if (m_transferDMA)
				{
					ATLTRACE("Freeing DMA buffer from %x..", m_Buffer);
					// Free the DMA buffer through Advantech
					LRESULT FreeDMABuffererror = DRV_FreeDMABuffer(m_driverHandle, (LPARAM)&m_Buffer);
					ATLTRACE("Now m_Buffer is %x..", m_Buffer);
				}
				else
				{
					VirtualFree(m_Buffer,0,MEM_RELEASE);
				}
				m_transferDMA = isDMA; // If 
				ATLTRACE("Done.\n");
			}
			m_transferDMA = isDMA; // We want to free the memory (in the correct way) of the last buffer if it exists
            
			if(Size)	// Create a buffer if Size > 0
            {
				if (m_transferDMA)
				{					
					// Now we allocate memory for the DMA transfer
					PT_AllocateDMABuffer  ptAllocateDMABuffer;
					ptAllocateDMABuffer.CyclicMode = cyclicMode;
					ptAllocateDMABuffer.RequestBufSize = Size * sizeof(CBT);
					ptAllocateDMABuffer.ActualBufSize = &actSize;
					ptAllocateDMABuffer.buffer = (long *)&m_Buffer;
					errCode = DRV_AllocateDMABuffer(m_driverHandle, (LPT_AllocateDMABuffer)&ptAllocateDMABuffer);
					if ((errCode != SUCCESS) || (actSize != Size * sizeof(CBT)))
					{
						return E_ADVALLOCDMA;
					}
					//DEBUG: ATLTRACE("Wanted %d BYTES, got %d BYTES!\n", Size*sizeof(CBT), actSize);
				}
				else
				{
					m_Buffer = (CBT*)VirtualAlloc(NULL, Size * sizeof(CBT), MEM_COMMIT, PAGE_READWRITE);
					if (m_Buffer==NULL) return E_OUTOFMEMORY;
				}
            }
            else
            {
				m_Buffer=NULL;
			}
            m_Size=Size;
        }
        m_ReadLoc=0;
        m_WriteLoc=0;
        return S_OK;
    }

};
#endif __advBuffer_H_
