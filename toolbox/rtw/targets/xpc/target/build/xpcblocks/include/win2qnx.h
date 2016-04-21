/* $Revision: 1.1.6.1 $ */
//===========================================================================
//
// NAME:    win2qnx.h
//
// DESCRIPTION:
//
// Windows DDK types conversion into QNX types
//
// AUTHOR:  Alex Ivchenko
//
// DATE:    12-APR-2000
//
// REV:     0.8
//
// R DATE:  
//
// HISTORY:
//
//      Rev 0.8,     12-MAR-2000,     Initial version.
//
//---------------------------------------------------------------------------
//      Copyright (C) 2000 United Electronic Industries, Inc.
//      All rights reserved.
//---------------------------------------------------------------------------
//


#ifndef __WIN_DDK_TYPES
#define __WIN_DDK_TYPES

#define u8 char
#define u16 unsigned short
#define u32 unsigned long  
#define uint16_t unsigned short
#define uint32_t unsigned long
//#define ULONG unsigned long
//#define DWORD unsigned long
//#define USHORT unsigned short
//#define WORD unsigned short
//#define UCHAR char
//#define BYTE char
//#define PBYTE BYTE*
//#define PDWORD DWORD*
//#define PWORD WORD*
//#define PULONG ULONG*
//#define PUSHORT USHORT*
//#define PUCHAR UCHAR*
//#define HANDLE void*
//#define PHANDLE HANDLE*
//#define BOOLEAN unsigned long
#define TRUE 1
//#define true 1
#define FALSE 0
//#define false 0


#endif //__WIN_DDK_TYPES
