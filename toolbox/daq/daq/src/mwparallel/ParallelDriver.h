// ParallelDriver.h: interface for the CParallelDriver class.
//
// Copyright 1998-2003 The MathWorks, Inc.
// $Author: batserve $
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:32:37 $
//////////////////////////////////////////////////////////////////////

#if !defined __PARALLELDRIVER_H__
#define __PARALLELDRIVER_H__

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Phys32.h"
#include "Port32.h"
#include "winio.h"


// PARALLELDRIVER:: This class wraps all the lower level parallel port access

class CParallelDriver  
{
public:
	CParallelDriver();	// Constructor
	~CParallelDriver();	// Destructor
	// InitDriver:: Loads and intialize driver
	HRESULT InitDriver();
	// CloseDriver:: Closes and unloads driver
	HRESULT CloseDriver();
	// OpenPort:: Open port at address specified
	HRESULT OpenPort(long portaddress);
	// ClosePort:: Close port at address specified
	HRESULT ClosePort(long portaddress);
	// GetAvailPorts:: Returns Available Port IDs and Adddresses
	HRESULT GetAvailPorts(CComBSTR& pBoardIDs, long* portaddrs);	
	// GetDriverInfo:: Returns Driver Info string
	HRESULT GetDriverInfo(CComBSTR& pDescription, CComBSTR& pVersion);
	// GetDigInput:: Reads data in
	HRESULT GetDigInput(long portaddress, USHORT* data);
	// PutDigOutput:: Writes data out
	HRESULT PutDigOutput(long portaddress, USHORT* data);
	// SetPort0Direction:: Specifies whether Port 0 is input or output
	HRESULT SetPort0Direction(unsigned long DirectionValues, short BitBit);

	// Initialized State 
	static bool bInitialized;

private:
	long PPortAddress;	   // Parallel Port Address
};

#endif // !defined __PARALLELDRIVER_H__
