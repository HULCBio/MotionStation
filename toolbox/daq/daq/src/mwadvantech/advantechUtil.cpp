// AdvantechUtil.cpp: Advantech Utility and Helper Functions.
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:30:23 $

#include "stdafx.h"
#include "advantechUtil.h"
/////////////////////////////////////////////////////////////////////////////
// GetPrivateProfileDouble()
//
// Function is used to obtain doubles from an INI file.
//////////////////////////////////////////////////////////////////////////////
double GetPrivateProfileDouble(LPCTSTR lpAppName, LPCTSTR lpKeyName, double Default, LPCTSTR lpFileName)
{
    char buf[30],*ptr;
    int outLen=GetPrivateProfileString(lpAppName,lpKeyName,"",buf,29,lpFileName);
    if (outLen==0) return Default;
    double outval=strtod(buf,&ptr);
    if(ptr!=buf)
        return outval;
    else
        return Default;
}

/////////////////////////////////////////////////////////////////////////////
// GetPrivateProfileBool()
//
// Function is used to obtain boolean values from an INI file.
// Taken from ComputerBoards implementation; changed to non-inlined.
//////////////////////////////////////////////////////////////////////////////
bool GetPrivateProfileBool(LPCTSTR lpAppName,LPCTSTR lpKeyName,bool nDefault, LPCTSTR lpFileName)
{
    return GetPrivateProfileInt(lpAppName,lpKeyName,nDefault,lpFileName) == 0 ? false : true;
}
