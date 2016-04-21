

/* this ALWAYS GENERATED file contains the IIDs and CLSIDs */

/* link this file in with the server and any clients */


 /* File created by MIDL compiler version 6.00.0361 */
/* at Fri Apr 30 05:40:57 2004
 */
/* Compiler settings for .\mwcomutil.idl:
    Oicf, W1, Zp8, env=Win32 (32b run)
    protocol : dce , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
//@@MIDL_FILE_HEADING(  )

#if !defined(_M_IA64) && !defined(_M_AMD64)


#pragma warning( disable: 4049 )  /* more than 64k source lines */


#ifdef __cplusplus
extern "C"{
#endif 


#include <rpc.h>
#include <rpcndr.h>

#ifdef _MIDL_USE_GUIDDEF_

#ifndef INITGUID
#define INITGUID
#include <guiddef.h>
#undef INITGUID
#else
#include <guiddef.h>
#endif

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
        DEFINE_GUID(name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8)

#else // !_MIDL_USE_GUIDDEF_

#ifndef __IID_DEFINED__
#define __IID_DEFINED__

typedef struct _IID
{
    unsigned long x;
    unsigned short s1;
    unsigned short s2;
    unsigned char  c[8];
} IID;

#endif // __IID_DEFINED__

#ifndef CLSID_DEFINED
#define CLSID_DEFINED
typedef IID CLSID;
#endif // CLSID_DEFINED

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
        const type name = {l,w1,w2,{b1,b2,b3,b4,b5,b6,b7,b8}}

#endif !_MIDL_USE_GUIDDEF_

MIDL_DEFINE_GUID(IID, IID_IMWUtil,0xC47EA90E,0x56D1,0x11d5,0xB1,0x59,0x00,0xD0,0xB7,0xBA,0x75,0x44);


MIDL_DEFINE_GUID(IID, LIBID_MWComUtil,0xE97D1011,0x0AF9,0x48d8,0xA5,0xAA,0xFF,0x5A,0xB9,0x71,0xFB,0xDC);


MIDL_DEFINE_GUID(CLSID, CLSID_MWField,0x2FFC5DD3,0x7477,0x4b94,0x88,0xF0,0xAB,0xC6,0xD7,0x4E,0x64,0x5E);


MIDL_DEFINE_GUID(CLSID, CLSID_MWStruct,0x7DDE28B1,0x77D4,0x43ed,0x97,0x20,0xEE,0x00,0x80,0x5F,0xC3,0xD8);


MIDL_DEFINE_GUID(CLSID, CLSID_MWComplex,0x56B93244,0x9DA1,0x407e,0x9E,0x31,0xC5,0xB8,0xA3,0x40,0xEC,0x07);


MIDL_DEFINE_GUID(CLSID, CLSID_MWSparse,0x539A31C5,0xBAA1,0x47ba,0xBC,0xA4,0x8A,0xA3,0x57,0xD1,0x1E,0x41);


MIDL_DEFINE_GUID(CLSID, CLSID_MWArg,0xB165869D,0xDD96,0x46be,0xA5,0x8F,0x28,0xF7,0x8E,0x34,0x24,0x5A);


MIDL_DEFINE_GUID(CLSID, CLSID_MWArrayFormatFlags,0x5F0CA1D2,0x6C3B,0x4ff5,0xA8,0xFD,0x0B,0x98,0x73,0x3E,0x40,0x9F);


MIDL_DEFINE_GUID(CLSID, CLSID_MWDataConversionFlags,0x2988D42D,0xFA0D,0x430c,0x84,0x92,0x54,0x89,0x06,0x6F,0xDB,0x92);


MIDL_DEFINE_GUID(CLSID, CLSID_MWUtil,0x660FD6A7,0x89BD,0x4ce7,0x88,0x43,0x61,0x2D,0x10,0x91,0x65,0xE3);


MIDL_DEFINE_GUID(CLSID, CLSID_MWFlags,0x133045DA,0x7930,0x478e,0xB9,0x0E,0x71,0x29,0xAB,0x99,0x7A,0x9B);

#undef MIDL_DEFINE_GUID

#ifdef __cplusplus
}
#endif



#endif /* !defined(_M_IA64) && !defined(_M_AMD64)*/

