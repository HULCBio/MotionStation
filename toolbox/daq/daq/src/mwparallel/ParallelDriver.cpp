// ParallelDriver.cpp: implementation of the CParallelDriver class.
//
// Copyright 1998-2003 The MathWorks, Inc.
// $Author: batserve $
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:40:11 $
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "mwparallel.h"
#include "ParallelDriver.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

bool CParallelDriver::bInitialized = FALSE;

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CParallelDriver::CParallelDriver()
{

}

//////////////////////////////////////////////////////////////////////

CParallelDriver::~CParallelDriver()
{

}

//////////////////////////////////////////////////////////////////////
// InitDriver:: Loads and intialize driver
HRESULT CParallelDriver::InitDriver()
{
    bool bresults;

    // Call to initialize WINIO
    bresults = InitializeWinIo();

    // If initialization fails, return FAIL
    if (!bresults)
    {
	// Not loaded on first attempt, pause and try again
	Sleep(1000);
        bresults = InitializeWinIo();
    }
    _ASSERT(bresults);

    // Check resutls and return 
    if (!bresults)
	return E_FAIL; 
    else
	return S_OK;
}

//////////////////////////////////////////////////////////////////////
// CloseDriver:: Closes and unloads driver
HRESULT CParallelDriver::CloseDriver()
{
    ShutdownWinIo();

    return S_OK;
}

//////////////////////////////////////////////////////////////////////
// OpenPort:: Open port at address specified
HRESULT CParallelDriver::OpenPort(long portaddress)
{
    // store Port Address
    PPortAddress = portaddress;
    return S_OK;
}

//////////////////////////////////////////////////////////////////////
// ClosePort:: Close port at address specified
HRESULT CParallelDriver::ClosePort(long portaddress)
{
	// Clear port address
    PPortAddress = NULL;
    return S_OK;
}

//////////////////////////////////////////////////////////////////////
// GetAvailPorts:: Returns Available Port IDs and Adddresses
HRESULT CParallelDriver::GetAvailPorts(CComBSTR& rBoardIDs, long *portaddrs)
{
    
    // Initialize port info to empty
    rBoardIDs = (L"");
    portaddrs[0] = NULL;
    portaddrs[1] = NULL;
    portaddrs[2] = NULL;
    
    // Return a list of board numbers and number of installed boards. 
    
    DWORD port;
    BOOL bresult;

    // Lookup physical address to of where (LPT1) is specified
    bresult = GetPhysLong((PBYTE)0x0408, &port);
    
    // If lookup fails
    if (!bresult)
    {
	return E_FAIL;
    }
    else
    {
	// Determine if LPT1 is available
	if ((short)port != NULL)
	{
	    rBoardIDs.Append(L"1");
	    portaddrs[0] = (short)port;
	}		
    }	
    // Lookup physical address to of where (LPT2) is specified
    bresult = GetPhysLong((PBYTE)0x040A, &port);
    if (!bresult)
    {
	return E_FAIL;
    }
    else
    {	
	if ((short)port != NULL)
	{
	    rBoardIDs.Append(L"2");
	    portaddrs[1] = (short)port;
	}	   
    }
    
    // Lookup physical address to of where (LPT3) is specified
    bresult = GetPhysLong((PBYTE)0x040C, &port);
    if (!bresult)
    {
	return E_FAIL;
    }
    else
    {	    
	if ((short)port != NULL)
	{
	    rBoardIDs.Append(L"3");
	    portaddrs[2] = (short)port;	    		    
	}
    }
    return S_OK;
}


//////////////////////////////////////////////////////////////////////
// GETDRIVERINFO: Get a description and version STRING from the driver
HRESULT CParallelDriver::GetDriverInfo(CComBSTR& pDescription, CComBSTR& pVersion)
{
   // Define Description and Verison number
    pDescription = "Win I/O";
    pVersion = "1.3";
    
    return S_OK;
	
}


//////////////////////////////////////////////////////////////////////
// GetDigInput:: Reads data in
HRESULT CParallelDriver::GetDigInput(long portaddress, USHORT* pdata)
{
    bool bresult;
    DWORD dwdata=0;
    PDWORD pdwdata = &dwdata;
    
    // Read from port
    bresult = GetPortVal((WORD)portaddress, pdwdata, 1);
    
    if (bresult) {
	// Return data
	*pdata = (USHORT)dwdata;
	return S_OK;
    }
    else
	return E_FAIL;
}


//////////////////////////////////////////////////////////////////////
// PutDigOutput:: Writes data out
HRESULT CParallelDriver::PutDigOutput(long portaddress, USHORT* pdata)
{
    bool bresult;
    DWORD DataToWrite=0;
    
    if (portaddress == PPortAddress)
    {	
	// // Port 0 - Set Bidirectional to Disable (0)
	
	// Write Data to Port 0
	DataToWrite = *pdata;
	bresult = SetPortVal((WORD)PPortAddress, DataToWrite, 1);
	
	if (!bresult)
	    return (E_FAIL);
	
    }
    else if (portaddress == PPortAddress+2)
    {
	//Control Port - Port 2
	// Get the upper control bits
	short maskedControlData;
	DWORD localControlData;
	
	bresult = GetPortVal((WORD)(PPortAddress+2), (PDWORD)&localControlData, 1);
	if (!bresult)
	    return (E_FAIL);
	
	maskedControlData = static_cast<short>(localControlData);
	maskedControlData = maskedControlData & 0xf0;
	
	// add control lines to be output
	maskedControlData = maskedControlData + *pdata;
	
	// Write data out to Control Port
	
	DataToWrite = maskedControlData;
	bresult = SetPortVal((WORD)(PPortAddress+2), DataToWrite, 1);
	
	if (!bresult)
	    return (E_FAIL);
    }
    else return E_FAIL; // Port 1 - Status should fail
    
    
    return S_OK;
}


//////////////////////////////////////////////////////////////////////
// SetPort0Direction:: Specifies whether Port 0 is input or output
HRESULT CParallelDriver::SetPort0Direction(unsigned long DirectionValues, short BiBit)
{
    DWORD localControlData=0;
    DWORD DataToWrite=0;
    short maskedControlData=0;

    if (DirectionValues==0)
    { //Input

	bool bresult;	
	
	// Read control register and save
	bresult = GetPortVal((WORD)(PPortAddress+2), &localControlData, 1);
	
	if (!bresult)
	    return (E_FAIL);

	// Set BiBit to Enable (1)
	short controlmask;
	controlmask = 1<<BiBit;
	maskedControlData = static_cast<short>(localControlData);
	maskedControlData = maskedControlData | controlmask;
	
	// Write Control byte to Control Register
	DataToWrite = maskedControlData;
	bresult = SetPortVal((WORD)(PPortAddress+2), DataToWrite, 1);

	if (!bresult)
	    return (E_FAIL);	
    }
    else
    { //Output
	bool bresult;
	
	// Read control register and save
	bresult = GetPortVal((WORD)(PPortAddress+2), &localControlData, 1);
	if (!bresult)
	    return (E_FAIL);
	
	// Disable bi-directional bit if case  is Port 0
	// // Port 0 - Set Bidirectional to Disable (0)
	short controlmask;
	
	controlmask = 1<<BiBit;
	controlmask = ~controlmask;
	
	// Clear Birectional Bit
	maskedControlData = static_cast<short>(localControlData);
	maskedControlData = maskedControlData & controlmask;
	
	// Write Control byte to Control Register
	DataToWrite = maskedControlData;
	bresult = SetPortVal((WORD)(PPortAddress+2), DataToWrite, 1);
	if (!bresult)
	    return (E_FAIL);	
    }

    return S_OK;
}


