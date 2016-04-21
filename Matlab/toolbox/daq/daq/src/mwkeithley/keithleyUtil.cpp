// keithleyUtil.cpp : Get the current driver version using Windows API
// $Revision: 1.1.6.2 $
// $Date:
// Copyright 2002-2004 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#include "stdafx.h"
#include "winver.h"


// Use the Windows API to obtain the revision data from the file information structure
void GetKeithleyVersion(int &maxver, int &minver)
{


        // Get the info structure size for this DLL
        DWORD Zero = 0;
        DWORD Size = 0;
        
        Size = GetFileVersionInfoSize("DLWin32.dll", &Zero);
        
        // Proceed only if the call to GetFileVersionInfoSize was successful
        if( Size != 0)
        {
                // Create a character array to hold this data
                LPVOID VersionData = new char[Size];
                UINT TextSize = 0;
        
                // Retrieve all file data
                GetFileVersionInfo("DLWin32.dll", Zero, Size, VersionData);


                // Create a structure pointer and have it point to the VersionData
                VS_FIXEDFILEINFO *InfoStructure;
                VerQueryValue(VersionData, "\\", (VOID **) &InfoStructure, &TextSize);


                // Calculate the Minor revision number and add it to the Major revision number
		
                minver = InfoStructure->dwProductVersionMS & 0xffff;
		maxver = (InfoStructure->dwProductVersionMS>>16) & 0xffff;

                // Clean up
                delete VersionData;
                
        }

}
