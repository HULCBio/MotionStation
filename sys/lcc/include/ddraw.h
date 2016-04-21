/* $Revision: 1.2 $ */
#ifndef __DDRAW_INCLUDED__
#define __DDRAW_INCLUDED__
#include <objbase.h>
#define _FACDD	0x876
#define MAKE_DDHRESULT( code )	MAKE_HRESULT( 1, _FACDD, code )
#if defined( _WIN32 ) && !defined( _NO_COM )
DEFINE_GUID( CLSID_DirectDraw,	0xD7B70EE0,0x4340,0x11CF,0xB0,0x63,0x,0x20,0xAF,0xC2,0xCD,0x35 );
DEFINE_GUID( CLSID_DirectDrawClipper, 0x593817A0,0x7DB3,0x11CF,0xA2,0xDE,0x,0xAA,0x,0xb9,0x33,0x56 );
DEFINE_GUID( IID_IDirectDraw,		0x6C14DB80,0xA733,0x11CE,0xA5,0x21,0x,0x20,0xAF,0xB,0xE5,0x60 );
DEFINE_GUID( IID_IDirectDraw2, 0xB3A6F3E0,0x2B43,0x11CF,0xA2,0xDE,0x,0xAA,0x,0xB9,0x33,0x56 );
DEFINE_GUID( IID_IDirectDrawSurface,	0x6C14DB81,0xA733,0x11CE,0xA5,0x21,0x,0x20,0xAF,0xB,0xE5,0x60 );
DEFINE_GUID( IID_IDirectDrawSurface2,	0x57805885,0x6eec,0x11cf,0x94,0x41,0xa8,0x23,0x3,0xc1,0x0e,0x27 );
DEFINE_GUID( IID_IDirectDrawPalette,		0x6C14DB84,0xA733,0x11CE,0xA5,0x21,0x,0x20,0xAF,0xB,0xE5,0x60 );
DEFINE_GUID( IID_IDirectDrawClipper,		0x6C14DB85,0xA733,0x11CE,0xA5,0x21,0x,0x20,0xAF,0xB,0xE5,0x60 );
#endif
struct IDirectDraw;
struct IDirectDrawSurface;
struct IDirectDrawPalette;
struct IDirectDrawClipper;
typedef struct IDirectDraw	*LPDIRECTDRAW;
typedef struct IDirectDraw2	*LPDIRECTDRAW2;
typedef struct IDirectDrawSurface	*LPDIRECTDRAWSURFACE;
typedef struct IDirectDrawSurface2	*LPDIRECTDRAWSURFACE2;
typedef struct IDirectDrawPalette	*LPDIRECTDRAWPALETTE;
typedef struct IDirectDrawClipper	*LPDIRECTDRAWCLIPPER;
typedef struct _DDFXROP			*LPDDFXROP;
typedef struct _DDSURFACEDESC		*LPDDSURFACEDESC;
typedef BOOL (PASCAL * LPDDENUMCALLBACKA)(GUID *, LPSTR, LPSTR, LPVOID);
typedef BOOL (PASCAL * LPDDENUMCALLBACKW)(GUID *, LPWSTR, LPWSTR, LPVOID);
extern HRESULT WINAPI DirectDrawEnumerateW( LPDDENUMCALLBACKW lpCallback, LPVOID lpContext );
extern HRESULT WINAPI DirectDrawEnumerateA( LPDDENUMCALLBACKA lpCallback, LPVOID lpContext );
#ifdef UNICODE
typedef LPDDENUMCALLBACKW 	LPDDENUMCALLBACK;
#define DirectDrawEnumerate	DirectDrawEnumerateW
#else
typedef LPDDENUMCALLBACKA 	LPDDENUMCALLBACK;
#define DirectDrawEnumerate	DirectDrawEnumerateA
#endif
extern HRESULT WINAPI DirectDrawCreate(GUID *, LPDIRECTDRAW *, IUnknown *);
extern HRESULT WINAPI DirectDrawCreateClipper(DWORD,LPDIRECTDRAWCLIPPER *,IUnknown *);
extern HRESULT NtDirectDrawCreate( GUID *,HANDLE *,IUnknown *);
#define REGSTR_KEY_DDHW_DESCRIPTION	"Description"
#define REGSTR_KEY_DDHW_DRIVERNAME	"DriverName"
#define REGSTR_PATH_DDHW		"Hardware\\DirectDrawDrivers"
#define DDCREATE_HARDWAREONLY		1
#define DDCREATE_EMULATIONONLY		2
#ifdef WINNT
typedef long HRESULT;
#endif

typedef HRESULT (PASCAL * LPDDENUMMODESCALLBACK)(LPDDSURFACEDESC, LPVOID);
typedef HRESULT (PASCAL * LPDDENUMSURFACESCALLBACK)(LPDIRECTDRAWSURFACE, LPDDSURFACEDESC, LPVOID);
typedef struct _DDCOLORKEY {
	DWORD	dwColorSpaceLowValue;	
					
	DWORD	dwColorSpaceHighValue;	
					
} DDCOLORKEY;
typedef DDCOLORKEY * LPDDCOLORKEY;
typedef struct _DDBLTFX {
	DWORD	dwSize;				
	DWORD	dwDDFX;				
	DWORD	dwROP;				
	DWORD	dwDDROP;			
	DWORD	dwRotationAngle;		
	DWORD	dwZBufferOpCode;		
	DWORD	dwZBufferLow;			
	DWORD	dwZBufferHigh;			
	DWORD	dwZBufferBaseDest;		
	DWORD	dwZDestConstBitDepth;		
	union {
	DWORD	dwZDestConst;			
	LPDIRECTDRAWSURFACE lpDDSZBufferDest;	
	};
	DWORD	dwZSrcConstBitDepth;		
	union {
	DWORD	dwZSrcConst;			
	LPDIRECTDRAWSURFACE lpDDSZBufferSrc;	
	};
	DWORD	dwAlphaEdgeBlendBitDepth;	
	DWORD	dwAlphaEdgeBlend;		
	DWORD	dwReserved;
	DWORD	dwAlphaDestConstBitDepth;	
	union
	{
	DWORD	dwAlphaDestConst;		
	LPDIRECTDRAWSURFACE lpDDSAlphaDest;	
	};
	DWORD	dwAlphaSrcConstBitDepth;	
	union
	{
	DWORD	dwAlphaSrcConst;		
	LPDIRECTDRAWSURFACE lpDDSAlphaSrc;	
	};
	union
	{
	DWORD	dwFillColor;			
	DWORD dwFillDepth; 
	LPDIRECTDRAWSURFACE lpDDSPattern;	
	};
	DDCOLORKEY	ddckDestColorkey;		
	DDCOLORKEY	ddckSrcColorkey;		
} DDBLTFX;
typedef DDBLTFX * LPDDBLTFX;
typedef struct _DDSCAPS { DWORD	dwCaps;	} DDSCAPS;
typedef DDSCAPS * LPDDSCAPS; 
#define DD_ROP_SPACE		(256/32)	
typedef struct _DDCAPS {
	DWORD	dwSize;			
	DWORD	dwCaps;			
	DWORD	dwCaps2;		
	DWORD	dwCKeyCaps;		
	DWORD	dwFXCaps;		
	DWORD	dwFXAlphaCaps;		
	DWORD	dwPalCaps;		
	DWORD	dwSVCaps;		
	DWORD	dwAlphaBltConstBitDepths;	
	DWORD	dwAlphaBltPixelBitDepths;	
	DWORD	dwAlphaBltSurfaceBitDepths;	
	DWORD	dwAlphaOverlayConstBitDepths;	
	DWORD	dwAlphaOverlayPixelBitDepths;	
	DWORD	dwAlphaOverlaySurfaceBitDepths; 
	DWORD	dwZBufferBitDepths;		
	DWORD	dwVidMemTotal;		
	DWORD	dwVidMemFree;		
	DWORD	dwMaxVisibleOverlays;	
	DWORD	dwCurrVisibleOverlays;	
	DWORD	dwNumFourCCCodes;	
	DWORD	dwAlignBoundarySrc;	
	DWORD	dwAlignSizeSrc;		
	DWORD	dwAlignBoundaryDest;	
	DWORD	dwAlignSizeDest;	
	DWORD	dwAlignStrideAlign;	
	DWORD	dwRops[DD_ROP_SPACE];	
	DDSCAPS	ddsCaps;		
	DWORD	dwMinOverlayStretch;	
	DWORD	dwMaxOverlayStretch;	
	DWORD	dwMinLiveVideoStretch;	
	DWORD	dwMaxLiveVideoStretch;	
	DWORD	dwMinHwCodecStretch;	
	DWORD	dwMaxHwCodecStretch;	
	DWORD	dwReserved1;		
	DWORD	dwReserved2;		
	DWORD	dwReserved3;		
	DWORD	dwSVBCaps;		
	DWORD	dwSVBCKeyCaps;		
	DWORD	dwSVBFXCaps;		
	DWORD	dwSVBRops[DD_ROP_SPACE];
	DWORD	dwVSBCaps;		
	DWORD	dwVSBCKeyCaps;		
	DWORD	dwVSBFXCaps;		
	DWORD	dwVSBRops[DD_ROP_SPACE];
	DWORD	dwSSBCaps;		
	DWORD	dwSSBCKeyCaps;		
	DWORD	dwSSBFXCaps;		
	DWORD	dwSSBRops[DD_ROP_SPACE];
	DWORD	dwReserved4;		
	DWORD	dwReserved5;		
	DWORD	dwReserved6;		
} DDCAPS;
typedef DDCAPS * LPDDCAPS;
typedef struct _DDPIXELFORMAT {
	DWORD	dwSize;			
	DWORD	dwFlags;		
	DWORD	dwFourCC;		
	union {
	DWORD	dwRGBBitCount;		
	DWORD	dwYUVBitCount;		
	DWORD	dwZBufferBitDepth;	
	DWORD	dwAlphaBitDepth;	
	};
	union {
	DWORD	dwRBitMask;		
	DWORD	dwYBitMask;		
	};
	union { DWORD	dwGBitMask; DWORD dwUBitMask;};
	union {
	DWORD	dwBBitMask;		
	DWORD	dwVBitMask;		
	};
	union {
	DWORD	dwRGBAlphaBitMask;	
	DWORD	dwYUVAlphaBitMask;	
	};
} DDPIXELFORMAT;
typedef DDPIXELFORMAT * LPDDPIXELFORMAT;
typedef struct _DDOVERLAYFX {
	DWORD	dwSize;				
	DWORD	dwAlphaEdgeBlendBitDepth;	
	DWORD	dwAlphaEdgeBlend;		
	DWORD	dwReserved;
	DWORD	dwAlphaDestConstBitDepth;	
	union
	{
	DWORD	dwAlphaDestConst;		
	LPDIRECTDRAWSURFACE lpDDSAlphaDest;	
	};
	DWORD	dwAlphaSrcConstBitDepth;	
	union
	{
	DWORD	dwAlphaSrcConst;		
	LPDIRECTDRAWSURFACE lpDDSAlphaSrc;	
	};
	DDCOLORKEY	dckDestColorkey;		
	DDCOLORKEY	dckSrcColorkey;			
	DWORD dwDDFX; 
	DWORD	dwFlags;			
} DDOVERLAYFX;
typedef DDOVERLAYFX *LPDDOVERLAYFX;
typedef struct _DDBLTBATCH {
	LPRECT		lprDest;
	LPDIRECTDRAWSURFACE	lpDDSSrc;
	LPRECT		lprSrc;
	DWORD		dwFlags;
	LPDDBLTFX		lpDDBltFx;
} DDBLTBATCH;

typedef DDBLTBATCH * LPDDBLTBATCH;
typedef DWORD	(PASCAL *LPCLIPPERCALLBACK)(LPDIRECTDRAWCLIPPER lpDDClipper, HWND hWnd, DWORD code, LPVOID lpContext );
#ifdef STREAMING
typedef DWORD	(PASCAL *LPSURFACESTREAMINGCALLBACK)(DWORD);
#endif
#if defined( _WIN32 ) && !defined( _NO_COM )
#undef INTERFACE
#define INTERFACE IDirectDraw
DECLARE_INTERFACE_( IDirectDraw, IUnknown )
{
	STDMETHOD(QueryInterface) (THIS_ REFIID riid, LPVOID * ppvObj);
	STDMETHOD_(ULONG,AddRef) (THIS) ;
	STDMETHOD_(ULONG,Release) (THIS);
	STDMETHOD(Compact)(THIS);
	STDMETHOD(CreateClipper)(THIS_ DWORD, LPDIRECTDRAWCLIPPER *, IUnknown * );
	STDMETHOD(CreatePalette)(THIS_ DWORD, LPPALETTEENTRY, LPDIRECTDRAWPALETTE *, IUnknown * );
	STDMETHOD(CreateSurface)(THIS_ LPDDSURFACEDESC, LPDIRECTDRAWSURFACE *, IUnknown *);
	STDMETHOD(DuplicateSurface)( THIS_ LPDIRECTDRAWSURFACE, LPDIRECTDRAWSURFACE * );
	STDMETHOD(EnumDisplayModes)( THIS_ DWORD, LPDDSURFACEDESC, LPVOID, LPDDENUMMODESCALLBACK );
	STDMETHOD(EnumSurfaces)(THIS_ DWORD, LPDDSURFACEDESC, LPVOID,LPDDENUMSURFACESCALLBACK );
	STDMETHOD(FlipToGDISurface)(THIS);
	STDMETHOD(GetCaps)( THIS_ LPDDCAPS, LPDDCAPS);
	STDMETHOD(GetDisplayMode)( THIS_ LPDDSURFACEDESC);
	STDMETHOD(GetFourCCCodes)(THIS_ LPDWORD, LPDWORD );
	STDMETHOD(GetGDISurface)(THIS_ LPDIRECTDRAWSURFACE *);
	STDMETHOD(GetMonitorFrequency)(THIS_ LPDWORD);
	STDMETHOD(GetScanLine)(THIS_ LPDWORD);
	STDMETHOD(GetVerticalBlankStatus)(THIS_ LPBOOL );
	STDMETHOD(Initialize)(THIS_ GUID *);
	STDMETHOD(RestoreDisplayMode)(THIS);
	STDMETHOD(SetCooperativeLevel)(THIS_ HWND, DWORD);
	STDMETHOD(SetDisplayMode)(THIS_ DWORD, DWORD,DWORD);
	STDMETHOD(WaitForVerticalBlank)(THIS_ DWORD, HANDLE );
};

#define IDirectDraw_QueryInterface(p, a, b) (p)->lpVtbl->QueryInterface(p, a, b)
#define IDirectDraw_AddRef(p) (p)->lpVtbl->AddRef(p)
#define IDirectDraw_Release(p) (p)->lpVtbl->Release(p)
#define IDirectDraw_Compact(p) (p)->lpVtbl->Compact(p)
#define IDirectDraw_CreateClipper(p, a, b, c) (p)->lpVtbl->CreateClipper(p, a, b, c)
#define IDirectDraw_CreatePalette(p, a, b, c, d) (p)->lpVtbl->CreatePalette(p, a, b, c, d)
#define IDirectDraw_CreateSurface(p, a, b, c) (p)->lpVtbl->CreateSurface(p, a, b, c)
#define IDirectDraw_DuplicateSurface(p, a, b) (p)->lpVtbl->DuplicateSurface(p, a, b)
#define IDirectDraw_EnumDisplayModes(p, a, b, c, d) (p)->lpVtbl->EnumDisplayModes(p, a, b, c, d)
#define IDirectDraw_EnumSurfaces(p, a, b, c, d) (p)->lpVtbl->EnumSurfaces(p, a, b, c, d)
#define IDirectDraw_FlipToGDISurface(p) (p)->lpVtbl->FlipToGDISurface(p)
#define IDirectDraw_GetCaps(p, a, b) (p)->lpVtbl->GetCaps(p, a, b)
#define IDirectDraw_GetDisplayMode(p, a) (p)->lpVtbl->GetDisplayMode(p, a)
#define IDirectDraw_GetFourCCCodes(p, a, b) (p)->lpVtbl->GetFourCCCodes(p, a, b)
#define IDirectDraw_GetGDISurface(p, a) (p)->lpVtbl->GetGDISurface(p, a)
#define IDirectDraw_GetMonitorFrequency(p, a) (p)->lpVtbl->GetMonitorFrequency(p, a)
#define IDirectDraw_GetScanLine(p, a) (p)->lpVtbl->GetScanLine(p, a)
#define IDirectDraw_GetVerticalBlankStatus(p, a) (p)->lpVtbl->GetVerticalBlankStatus(p, a)
#define IDirectDraw_Initialize(p, a) (p)->lpVtbl->Initialize(p, a)
#define IDirectDraw_RestoreDisplayMode(p) (p)->lpVtbl->RestoreDisplayMode(p)
#define IDirectDraw_SetCooperativeLevel(p, a, b) (p)->lpVtbl->SetCooperativeLevel(p, a, b)
#define IDirectDraw_SetDisplayMode(p, a, b, c) (p)->lpVtbl->SetDisplayMode(p, a, b, c)
#define IDirectDraw_WaitForVerticalBlank(p, a, b) (p)->lpVtbl->WaitForVerticalBlank(p, a, b)
#endif

#if defined( _WIN32 ) && !defined( _NO_COM )
#undef INTERFACE
#define INTERFACE IDirectDraw2
DECLARE_INTERFACE_( IDirectDraw2, IUnknown )
{
	STDMETHOD(QueryInterface) (THIS_ REFIID riid, LPVOID * ppvObj);
	STDMETHOD_(ULONG,AddRef) (THIS) ;
	STDMETHOD_(ULONG,Release) (THIS);
	STDMETHOD(Compact)(THIS);
	STDMETHOD(CreateClipper)(THIS_ DWORD, LPDIRECTDRAWCLIPPER *, IUnknown * );
	STDMETHOD(CreatePalette)(THIS_ DWORD, LPPALETTEENTRY, LPDIRECTDRAWPALETTE *, IUnknown * );
	STDMETHOD(CreateSurface)(THIS_ LPDDSURFACEDESC, LPDIRECTDRAWSURFACE *, IUnknown *);
	STDMETHOD(DuplicateSurface)( THIS_ LPDIRECTDRAWSURFACE, LPDIRECTDRAWSURFACE * );
	STDMETHOD(EnumDisplayModes)( THIS_ DWORD, LPDDSURFACEDESC, LPVOID, LPDDENUMMODESCALLBACK );
	STDMETHOD(EnumSurfaces)(THIS_ DWORD, LPDDSURFACEDESC, LPVOID,LPDDENUMSURFACESCALLBACK );
	STDMETHOD(FlipToGDISurface)(THIS);
	STDMETHOD(GetCaps)( THIS_ LPDDCAPS, LPDDCAPS);
	STDMETHOD(GetDisplayMode)( THIS_ LPDDSURFACEDESC);
	STDMETHOD(GetFourCCCodes)(THIS_ LPDWORD, LPDWORD );
	STDMETHOD(GetGDISurface)(THIS_ LPDIRECTDRAWSURFACE *);
	STDMETHOD(GetMonitorFrequency)(THIS_ LPDWORD);
	STDMETHOD(GetScanLine)(THIS_ LPDWORD);
	STDMETHOD(GetVerticalBlankStatus)(THIS_ LPBOOL );
	STDMETHOD(Initialize)(THIS_ GUID *);
	STDMETHOD(RestoreDisplayMode)(THIS);
	STDMETHOD(SetCooperativeLevel)(THIS_ HWND, DWORD);
	STDMETHOD(SetDisplayMode)(THIS_ DWORD, DWORD,DWORD, DWORD, DWORD);
	STDMETHOD(WaitForVerticalBlank)(THIS_ DWORD, HANDLE );
	/*** Added in the v2 interface ***/
	STDMETHOD(GetAvailableVidMem)(THIS_ LPDDSCAPS, LPDWORD, LPDWORD);
};
#define IDirectDraw2_QueryInterface(p, a, b) (p)->lpVtbl->QueryInterface(p, a, b)
#define IDirectDraw2_AddRef(p) (p)->lpVtbl->AddRef(p)
#define IDirectDraw2_Release(p) (p)->lpVtbl->Release(p)
#define IDirectDraw2_Compact(p) (p)->lpVtbl->Compact(p)
#define IDirectDraw2_CreateClipper(p, a, b, c) (p)->lpVtbl->CreateClipper(p, a, b, c)
#define IDirectDraw2_CreatePalette(p, a, b, c, d) (p)->lpVtbl->CreatePalette(p, a, b, c, d)
#define IDirectDraw2_CreateSurface(p, a, b, c) (p)->lpVtbl->CreateSurface(p, a, b, c)
#define IDirectDraw2_DuplicateSurface(p, a, b) (p)->lpVtbl->DuplicateSurface(p, a, b)
#define IDirectDraw2_EnumDisplayModes(p, a, b, c, d) (p)->lpVtbl->EnumDisplayModes(p, a, b, c, d)
#define IDirectDraw2_EnumSurfaces(p, a, b, c, d) (p)->lpVtbl->EnumSurfaces(p, a, b, c, d)
#define IDirectDraw2_FlipToGDISurface(p) (p)->lpVtbl->FlipToGDISurface(p)
#define IDirectDraw2_GetCaps(p, a, b) (p)->lpVtbl->GetCaps(p, a, b)
#define IDirectDraw2_GetDisplayMode(p, a) (p)->lpVtbl->GetDisplayMode(p, a)
#define IDirectDraw2_GetFourCCCodes(p, a, b) (p)->lpVtbl->GetFourCCCodes(p, a, b)
#define IDirectDraw2_GetGDISurface(p, a) (p)->lpVtbl->GetGDISurface(p, a)
#define IDirectDraw2_GetMonitorFrequency(p, a) (p)->lpVtbl->GetMonitorFrequency(p, a)
#define IDirectDraw2_GetScanLine(p, a) (p)->lpVtbl->GetScanLine(p, a)
#define IDirectDraw2_GetVerticalBlankStatus(p, a) (p)->lpVtbl->GetVerticalBlankStatus(p, a)
#define IDirectDraw2_Initialize(p, a) (p)->lpVtbl->Initialize(p, a)
#define IDirectDraw2_RestoreDisplayMode(p) (p)->lpVtbl->RestoreDisplayMode(p)
#define IDirectDraw2_SetCooperativeLevel(p, a, b) (p)->lpVtbl->SetCooperativeLevel(p, a, b)
#define IDirectDraw2_SetDisplayMode(p, a, b, c, d) (p)->lpVtbl->SetDisplayMode(p, a, b, c, d)
#define IDirectDraw2_WaitForVerticalBlank(p, a, b) (p)->lpVtbl->WaitForVerticalBlank(p, a, b)
#define IDirectDraw2_GetAvailableVidMem(p, a, b, c) (p)->lpVtbl->GetAvailableVidMem(p, a, b, c)

#endif
#if defined( _WIN32 ) && !defined( _NO_COM )
#undef INTERFACE
#define INTERFACE IDirectDrawPalette
DECLARE_INTERFACE_( IDirectDrawPalette, IUnknown )
{
	STDMETHOD(QueryInterface) (THIS_ REFIID riid, LPVOID * ppvObj);
	STDMETHOD_(ULONG,AddRef) (THIS) ;
	STDMETHOD_(ULONG,Release) (THIS);
	STDMETHOD(GetCaps)(THIS_ LPDWORD);
	STDMETHOD(GetEntries)(THIS_ DWORD,DWORD,DWORD,LPPALETTEENTRY);
	STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, DWORD, LPPALETTEENTRY);
	STDMETHOD(SetEntries)(THIS_ DWORD,DWORD,DWORD,LPPALETTEENTRY);
};

#define IDirectDrawPalette_QueryInterface(p, a, b) (p)->lpVtbl->QueryInterface(p, a, b)
#define IDirectDrawPalette_AddRef(p) (p)->lpVtbl->AddRef(p)
#define IDirectDrawPalette_Release(p) (p)->lpVtbl->Release(p)
#define IDirectDrawPalette_GetCaps(p, a) (p)->lpVtbl->GetCaps(p, a)
#define IDirectDrawPalette_GetEntries(p, a, b, c, d) (p)->lpVtbl->GetEntries(p, a, b, c, d)
#define IDirectDrawPalette_Initialize(p, a, b, c) (p)->lpVtbl->Initialize(p, a, b, c)
#define IDirectDrawPalette_SetEntries(p, a, b, c, d) (p)->lpVtbl->SetEntries(p, a, b, c, d)

#endif
#if defined( _WIN32 ) && !defined( _NO_COM )
#undef INTERFACE
#define INTERFACE IDirectDrawClipper
DECLARE_INTERFACE_( IDirectDrawClipper, IUnknown )
{
	STDMETHOD(QueryInterface) (THIS_ REFIID riid, LPVOID * ppvObj);
	STDMETHOD_(ULONG,AddRef) (THIS) ;
	STDMETHOD_(ULONG,Release) (THIS);
	STDMETHOD(GetClipList)(THIS_ LPRECT, LPRGNDATA, LPDWORD);
	STDMETHOD(GetHWnd)(THIS_ HWND *);
	STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, DWORD);
	STDMETHOD(IsClipListChanged)(THIS_ BOOL *);
	STDMETHOD(SetClipList)(THIS_ LPRGNDATA,DWORD);
	STDMETHOD(SetHWnd)(THIS_ DWORD, HWND );
};

#define IDirectDrawClipper_QueryInterface(p, a, b) (p)->lpVtbl->QueryInterface(p, a, b)
#define IDirectDrawClipper_AddRef(p) (p)->lpVtbl->AddRef(p)
#define IDirectDrawClipper_Release(p) (p)->lpVtbl->Release(p)
#define IDirectDrawClipper_GetClipList(p, a, b, c) (p)->lpVtbl->GetClipList(p, a, b, c)
#define IDirectDrawClipper_GetHWnd(p, a) (p)->lpVtbl->GetHWnd(p, a)
#define IDirectDrawClipper_Initialize(p, a, b) (p)->lpVtbl->Initialize(p, a, b)
#define IDirectDrawClipper_IsClipListChanged(p, a) (p)->lpVtbl->IsClipListChanged(p, a)
#define IDirectDrawClipper_SetClipList(p, a, b) (p)->lpVtbl->SetClipList(p, a, b)
#define IDirectDrawClipper_SetHWnd(p, a, b) (p)->lpVtbl->SetHWnd(p, a, b)

#endif
#if defined( _WIN32 ) && !defined( _NO_COM )
#undef INTERFACE
#define INTERFACE IDirectDrawSurface
DECLARE_INTERFACE_( IDirectDrawSurface, IUnknown )
{
	STDMETHOD(QueryInterface) (THIS_ REFIID riid, LPVOID * ppvObj);
	STDMETHOD_(ULONG,AddRef) (THIS) ;
	STDMETHOD_(ULONG,Release) (THIS);
	STDMETHOD(AddAttachedSurface)(THIS_ LPDIRECTDRAWSURFACE);
	STDMETHOD(AddOverlayDirtyRect)(THIS_ LPRECT);
	STDMETHOD(Blt)(THIS_ LPRECT,LPDIRECTDRAWSURFACE, LPRECT,DWORD, LPDDBLTFX);
	STDMETHOD(BltBatch)(THIS_ LPDDBLTBATCH, DWORD, DWORD );
	STDMETHOD(BltFast)(THIS_ DWORD,DWORD,LPDIRECTDRAWSURFACE, LPRECT,DWORD);
	STDMETHOD(DeleteAttachedSurface)(THIS_ DWORD,LPDIRECTDRAWSURFACE);
	STDMETHOD(EnumAttachedSurfaces)(THIS_ LPVOID,LPDDENUMSURFACESCALLBACK);
	STDMETHOD(EnumOverlayZOrders)(THIS_ DWORD,LPVOID,LPDDENUMSURFACESCALLBACK);
	STDMETHOD(Flip)(THIS_ LPDIRECTDRAWSURFACE, DWORD);
	STDMETHOD(GetAttachedSurface)(THIS_ LPDDSCAPS, LPDIRECTDRAWSURFACE *);
	STDMETHOD(GetBltStatus)(THIS_ DWORD);
	STDMETHOD(GetCaps)(THIS_ LPDDSCAPS);
	STDMETHOD(GetClipper)(THIS_ LPDIRECTDRAWCLIPPER *);
	STDMETHOD(GetColorKey)(THIS_ DWORD, LPDDCOLORKEY);
	STDMETHOD(GetDC)(THIS_ HDC *);
	STDMETHOD(GetFlipStatus)(THIS_ DWORD);
	STDMETHOD(GetOverlayPosition)(THIS_ LPLONG, LPLONG );
	STDMETHOD(GetPalette)(THIS_ LPDIRECTDRAWPALETTE *);
	STDMETHOD(GetPixelFormat)(THIS_ LPDDPIXELFORMAT);
	STDMETHOD(GetSurfaceDesc)(THIS_ LPDDSURFACEDESC);
	STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, LPDDSURFACEDESC);
	STDMETHOD(IsLost)(THIS);
	STDMETHOD(Lock)(THIS_ LPRECT,LPDDSURFACEDESC,DWORD,HANDLE);
	STDMETHOD(ReleaseDC)(THIS_ HDC);
	STDMETHOD(Restore)(THIS);
	STDMETHOD(SetClipper)(THIS_ LPDIRECTDRAWCLIPPER);
	STDMETHOD(SetColorKey)(THIS_ DWORD, LPDDCOLORKEY);
	STDMETHOD(SetOverlayPosition)(THIS_ LONG, LONG );
	STDMETHOD(SetPalette)(THIS_ LPDIRECTDRAWPALETTE);
	STDMETHOD(Unlock)(THIS_ LPVOID);
	STDMETHOD(UpdateOverlay)(THIS_ LPRECT, LPDIRECTDRAWSURFACE,LPRECT,DWORD, LPDDOVERLAYFX);
	STDMETHOD(UpdateOverlayDisplay)(THIS_ DWORD);
	STDMETHOD(UpdateOverlayZOrder)(THIS_ DWORD, LPDIRECTDRAWSURFACE);
};

#define IDirectDrawSurface_QueryInterface(p,a,b) (p)->lpVtbl->QueryInterface(p,a,b)
#define IDirectDrawSurface_AddRef(p) (p)->lpVtbl->AddRef(p)
#define IDirectDrawSurface_Release(p) (p)->lpVtbl->Release(p)
#define IDirectDrawSurface_AddAttachedSurface(p,a) (p)->lpVtbl->AddAttachedSurface(p,a)
#define IDirectDrawSurface_AddOverlayDirtyRect(p,a) (p)->lpVtbl->AddOverlayDirtyRect(p,a)
#define IDirectDrawSurface_Blt(p,a,b,c,d,e) (p)->lpVtbl->Blt(p,a,b,c,d,e)
#define IDirectDrawSurface_BltBatch(p,a,b,c) (p)->lpVtbl->BltBatch(p,a,b,c)
#define IDirectDrawSurface_BltFast(p,a,b,c,d,e) (p)->lpVtbl->BltFast(p,a,b,c,d,e)
#define IDirectDrawSurface_DeleteAttachedSurface(p,a,b) (p)->lpVtbl->DeleteAttachedSurface(p,a,b)
#define IDirectDrawSurface_EnumAttachedSurfaces(p,a,b) (p)->lpVtbl->EnumAttachedSurfaces(p,a,b)
#define IDirectDrawSurface_EnumOverlayZOrders(p,a,b,c) (p)->lpVtbl->EnumOverlayZOrders(p,a,b,c)
#define IDirectDrawSurface_Flip(p,a,b) (p)->lpVtbl->Flip(p,a,b)
#define IDirectDrawSurface_GetAttachedSurface(p,a,b) (p)->lpVtbl->GetAttachedSurface(p,a,b)
#define IDirectDrawSurface_GetBltStatus(p,a) (p)->lpVtbl->GetBltStatus(p,a)
#define IDirectDrawSurface_GetCaps(p,b) (p)->lpVtbl->GetCaps(p,b)
#define IDirectDrawSurface_GetClipper(p,a) (p)->lpVtbl->GetClipper(p,a)
#define IDirectDrawSurface_GetColorKey(p,a,b) (p)->lpVtbl->GetColorKey(p,a,b)
#define IDirectDrawSurface_GetDC(p,a) (p)->lpVtbl->GetDC(p,a)
#define IDirectDrawSurface_GetFlipStatus(p,a) (p)->lpVtbl->GetFlipStatus(p,a)
#define IDirectDrawSurface_GetOverlayPosition(p,a,b) (p)->lpVtbl->GetOverlayPosition(p,a,b)
#define IDirectDrawSurface_GetPalette(p,a) (p)->lpVtbl->GetPalette(p,a)
#define IDirectDrawSurface_GetPixelFormat(p,a) (p)->lpVtbl->GetPixelFormat(p,a)
#define IDirectDrawSurface_GetSurfaceDesc(p,a) (p)->lpVtbl->GetSurfaceDesc(p,a)
#define IDirectDrawSurface_Initialize(p,a,b) (p)->lpVtbl->Initialize(p,a,b)
#define IDirectDrawSurface_IsLost(p) (p)->lpVtbl->IsLost(p)
#define IDirectDrawSurface_Lock(p,a,b,c,d) (p)->lpVtbl->Lock(p,a,b,c,d)
#define IDirectDrawSurface_ReleaseDC(p,a) (p)->lpVtbl->ReleaseDC(p,a)
#define IDirectDrawSurface_Restore(p) (p)->lpVtbl->Restore(p)
#define IDirectDrawSurface_SetClipper(p,a) (p)->lpVtbl->SetClipper(p,a)
#define IDirectDrawSurface_SetColorKey(p,a,b) (p)->lpVtbl->SetColorKey(p,a,b)
#define IDirectDrawSurface_SetOverlayPosition(p,a,b) (p)->lpVtbl->SetOverlayPosition(p,a,b)
#define IDirectDrawSurface_SetPalette(p,a) (p)->lpVtbl->SetPalette(p,a)
#define IDirectDrawSurface_Unlock(p,b) (p)->lpVtbl->Unlock(p,b)
#define IDirectDrawSurface_UpdateOverlay(p,a,b,c,d,e) (p)->lpVtbl->UpdateOverlay(p,a,b,c,d,e)
#define IDirectDrawSurface_UpdateOverlayDisplay(p,a) (p)->lpVtbl->UpdateOverlayDisplay(p,a)
#define IDirectDrawSurface_UpdateOverlayZOrder(p,a,b) (p)->lpVtbl->UpdateOverlayZOrder(p,a,b)

#undef INTERFACE
#define INTERFACE IDirectDrawSurface2
DECLARE_INTERFACE_( IDirectDrawSurface2, IUnknown )
{
	STDMETHOD(QueryInterface) (THIS_ REFIID riid, LPVOID * ppvObj);
	STDMETHOD_(ULONG,AddRef) (THIS) ;
	STDMETHOD_(ULONG,Release) (THIS);
	STDMETHOD(AddAttachedSurface)(THIS_ LPDIRECTDRAWSURFACE2);
	STDMETHOD(AddOverlayDirtyRect)(THIS_ LPRECT);
	STDMETHOD(Blt)(THIS_ LPRECT,LPDIRECTDRAWSURFACE2, LPRECT,DWORD, LPDDBLTFX);
	STDMETHOD(BltBatch)(THIS_ LPDDBLTBATCH, DWORD, DWORD );
	STDMETHOD(BltFast)(THIS_ DWORD,DWORD,LPDIRECTDRAWSURFACE2, LPRECT,DWORD);
	STDMETHOD(DeleteAttachedSurface)(THIS_ DWORD,LPDIRECTDRAWSURFACE2);
	STDMETHOD(EnumAttachedSurfaces)(THIS_ LPVOID,LPDDENUMSURFACESCALLBACK);
	STDMETHOD(EnumOverlayZOrders)(THIS_ DWORD,LPVOID,LPDDENUMSURFACESCALLBACK);
	STDMETHOD(Flip)(THIS_ LPDIRECTDRAWSURFACE2, DWORD);
	STDMETHOD(GetAttachedSurface)(THIS_ LPDDSCAPS, LPDIRECTDRAWSURFACE2 *);
	STDMETHOD(GetBltStatus)(THIS_ DWORD);
	STDMETHOD(GetCaps)(THIS_ LPDDSCAPS);
	STDMETHOD(GetClipper)(THIS_ LPDIRECTDRAWCLIPPER *);
	STDMETHOD(GetColorKey)(THIS_ DWORD, LPDDCOLORKEY);
	STDMETHOD(GetDC)(THIS_ HDC *);
	STDMETHOD(GetFlipStatus)(THIS_ DWORD);
	STDMETHOD(GetOverlayPosition)(THIS_ LPLONG, LPLONG );
	STDMETHOD(GetPalette)(THIS_ LPDIRECTDRAWPALETTE *);
	STDMETHOD(GetPixelFormat)(THIS_ LPDDPIXELFORMAT);
	STDMETHOD(GetSurfaceDesc)(THIS_ LPDDSURFACEDESC);
	STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, LPDDSURFACEDESC);
	STDMETHOD(IsLost)(THIS);
	STDMETHOD(Lock)(THIS_ LPRECT,LPDDSURFACEDESC,DWORD,HANDLE);
	STDMETHOD(ReleaseDC)(THIS_ HDC);
	STDMETHOD(Restore)(THIS);
	STDMETHOD(SetClipper)(THIS_ LPDIRECTDRAWCLIPPER);
	STDMETHOD(SetColorKey)(THIS_ DWORD, LPDDCOLORKEY);
	STDMETHOD(SetOverlayPosition)(THIS_ LONG, LONG );
	STDMETHOD(SetPalette)(THIS_ LPDIRECTDRAWPALETTE);
	STDMETHOD(Unlock)(THIS_ LPVOID);
	STDMETHOD(UpdateOverlay)(THIS_ LPRECT, LPDIRECTDRAWSURFACE2,LPRECT,DWORD, LPDDOVERLAYFX);
	STDMETHOD(UpdateOverlayDisplay)(THIS_ DWORD);
	STDMETHOD(UpdateOverlayZOrder)(THIS_ DWORD, LPDIRECTDRAWSURFACE2);
	/*** Added to the v2 interface ***/
	STDMETHOD(GetDDInterface)(THIS_ LPVOID *);
	STDMETHOD(PageLock)(THIS_ DWORD);
	STDMETHOD(PageUnlock)(THIS_ DWORD);
};

#define IDirectDrawSurface2_QueryInterface(p,a,b) (p)->lpVtbl->QueryInterface(p,a,b)
#define IDirectDrawSurface2_AddRef(p) (p)->lpVtbl->AddRef(p)
#define IDirectDrawSurface2_Release(p) (p)->lpVtbl->Release(p)
#define IDirectDrawSurface2_AddAttachedSurface(p,a) (p)->lpVtbl->AddAttachedSurface(p,a)
#define IDirectDrawSurface2_AddOverlayDirtyRect(p,a) (p)->lpVtbl->AddOverlayDirtyRect(p,a)
#define IDirectDrawSurface2_Blt(p,a,b,c,d,e) (p)->lpVtbl->Blt(p,a,b,c,d,e)
#define IDirectDrawSurface2_BltBatch(p,a,b,c) (p)->lpVtbl->BltBatch(p,a,b,c)
#define IDirectDrawSurface2_BltFast(p,a,b,c,d,e) (p)->lpVtbl->BltFast(p,a,b,c,d,e)
#define IDirectDrawSurface2_DeleteAttachedSurface(p,a,b) (p)->lpVtbl->DeleteAttachedSurface(p,a,b)
#define IDirectDrawSurface2_EnumAttachedSurfaces(p,a,b) (p)->lpVtbl->EnumAttachedSurfaces(p,a,b)
#define IDirectDrawSurface2_EnumOverlayZOrders(p,a,b,c) (p)->lpVtbl->EnumOverlayZOrders(p,a,b,c)
#define IDirectDrawSurface2_Flip(p,a,b) (p)->lpVtbl->Flip(p,a,b)
#define IDirectDrawSurface2_GetAttachedSurface(p,a,b) (p)->lpVtbl->GetAttachedSurface(p,a,b)
#define IDirectDrawSurface2_GetBltStatus(p,a) (p)->lpVtbl->GetBltStatus(p,a)
#define IDirectDrawSurface2_GetCaps(p,b) (p)->lpVtbl->GetCaps(p,b)
#define IDirectDrawSurface2_GetClipper(p,a) (p)->lpVtbl->GetClipper(p,a)
#define IDirectDrawSurface2_GetColorKey(p,a,b) (p)->lpVtbl->GetColorKey(p,a,b)
#define IDirectDrawSurface2_GetDC(p,a) (p)->lpVtbl->GetDC(p,a)
#define IDirectDrawSurface2_GetFlipStatus(p,a) (p)->lpVtbl->GetFlipStatus(p,a)
#define IDirectDrawSurface2_GetOverlayPosition(p,a,b) (p)->lpVtbl->GetOverlayPosition(p,a,b)
#define IDirectDrawSurface2_GetPalette(p,a) (p)->lpVtbl->GetPalette(p,a)
#define IDirectDrawSurface2_GetPixelFormat(p,a) (p)->lpVtbl->GetPixelFormat(p,a)
#define IDirectDrawSurface2_GetSurfaceDesc(p,a) (p)->lpVtbl->GetSurfaceDesc(p,a)
#define IDirectDrawSurface2_Initialize(p,a,b) (p)->lpVtbl->Initialize(p,a,b)
#define IDirectDrawSurface2_IsLost(p) (p)->lpVtbl->IsLost(p)
#define IDirectDrawSurface2_Lock(p,a,b,c,d) (p)->lpVtbl->Lock(p,a,b,c,d)
#define IDirectDrawSurface2_ReleaseDC(p,a) (p)->lpVtbl->ReleaseDC(p,a)
#define IDirectDrawSurface2_Restore(p) (p)->lpVtbl->Restore(p)
#define IDirectDrawSurface2_SetClipper(p,a) (p)->lpVtbl->SetClipper(p,a)
#define IDirectDrawSurface2_SetColorKey(p,a,b) (p)->lpVtbl->SetColorKey(p,a,b)
#define IDirectDrawSurface2_SetOverlayPosition(p,a,b) (p)->lpVtbl->SetOverlayPosition(p,a,b)
#define IDirectDrawSurface2_SetPalette(p,a) (p)->lpVtbl->SetPalette(p,a)
#define IDirectDrawSurface2_Unlock(p,b) (p)->lpVtbl->Unlock(p,b)
#define IDirectDrawSurface2_UpdateOverlay(p,a,b,c,d,e) (p)->lpVtbl->UpdateOverlay(p,a,b,c,d,e)
#define IDirectDrawSurface2_UpdateOverlayDisplay(p,a) (p)->lpVtbl->UpdateOverlayDisplay(p,a)
#define IDirectDrawSurface2_UpdateOverlayZOrder(p,a,b) (p)->lpVtbl->UpdateOverlayZOrder(p,a,b)
#define IDirectDrawSurface2_GetDDInterface(p,a)		 (p)->lpVtbl->GetDDInterface(p,a)
#define IDirectDrawSurface2_PageLock(p,a)		 (p)->lpVtbl->PageLock(p,a)
#define IDirectDrawSurface2_PageUnlock(p,a)		 (p)->lpVtbl->PageUnlock(p,a)
#endif
typedef struct _DDSURFACEDESC {
	DWORD		dwSize;			
	DWORD		dwFlags;		
	DWORD		dwHeight;		
	DWORD		dwWidth;		
	LONG		lPitch;			
	DWORD		dwBackBufferCount;	
	union
	{
	DWORD dwMipMapCount; 
	DWORD		dwZBufferBitDepth;	
	DWORD		dwRefreshRate;		
	};
	DWORD		dwAlphaBitDepth;	
	DWORD		dwReserved;		
	LPVOID		lpSurface;		
	DDCOLORKEY		ddckCKDestOverlay;	
	DDCOLORKEY		ddckCKDestBlt;		
	DDCOLORKEY		ddckCKSrcOverlay;	
	DDCOLORKEY		ddckCKSrcBlt;		
	DDPIXELFORMAT	ddpfPixelFormat;	
	DDSCAPS		ddsCaps;		
} DDSURFACEDESC;
#define DDSD_CAPS		1
#define DDSD_HEIGHT		2
#define DDSD_WIDTH		4
#define DDSD_PITCH		8
#define DDSD_BACKBUFFERCOUNT	32
#define DDSD_ZBUFFERBITDEPTH	0x40
#define DDSD_ALPHABITDEPTH	0x80
#define DDSD_PIXELFORMAT	0x1000
#define DDSD_CKDESTOVERLAY	0x2000
#define DDSD_CKDESTBLT		0x4000
#define DDSD_CKSRCOVERLAY	0x8000
#define DDSD_CKSRCBLT		0x10000
#define DDSD_MIPMAPCOUNT	0x20000
#define DDSD_REFRESHRATE	0x40000
#define DDSD_ALL		0x7f9ee
#define DDSCAPS_3D		1
#define DDSCAPS_ALPHA		2
#define DDSCAPS_BACKBUFFER	4
#define DDSCAPS_COMPLEX		8
#define DDSCAPS_FLIP		16
#define DDSCAPS_FRONTBUFFER	32
#define DDSCAPS_OFFSCREENPLAIN	0x40
#define DDSCAPS_OVERLAY				0x80
#define DDSCAPS_PALETTE				0x100
#define DDSCAPS_PRIMARYSURFACE			0x200
#define DDSCAPS_PRIMARYSURFACELEFT		0x400
#define DDSCAPS_SYSTEMMEMORY			0x800
#define DDSCAPS_TEXTURE		 		0x1000
#define DDSCAPS_3DDEVICE			0x2000
#define DDSCAPS_VIDEOMEMORY			0x4000
#define DDSCAPS_VISIBLE				0x8000
#define DDSCAPS_WRITEONLY			0x10000
#define DDSCAPS_ZBUFFER				0x20000
#define DDSCAPS_OWNDC				0x40000
#define DDSCAPS_LIVEVIDEO			0x80000
#define DDSCAPS_HWCODEC				0x100000
#define DDSCAPS_MODEX				0x200000
#define DDSCAPS_MIPMAP 0x400000
#define DDSCAPS_ALLOCONLOAD 0x4000000
#define DDCAPS_3D			1
#define DDCAPS_ALIGNBOUNDARYDEST	2
#define DDCAPS_ALIGNSIZEDEST		4
#define DDCAPS_ALIGNBOUNDARYSRC		8
#define DDCAPS_ALIGNSIZESRC		16
#define DDCAPS_ALIGNSTRIDE		32
#define DDCAPS_BLT			0x40
#define DDCAPS_BLTQUEUE			0x80
#define DDCAPS_BLTFOURCC		0x100
#define DDCAPS_BLTSTRETCH		0x200
#define DDCAPS_GDI			0x400
#define DDCAPS_OVERLAY			0x800
#define DDCAPS_OVERLAYCANTCLIP		0x1000
#define DDCAPS_OVERLAYFOURCC		0x2000
#define DDCAPS_OVERLAYSTRETCH		0x4000
#define DDCAPS_PALETTE			0x8000
#define DDCAPS_PALETTEVSYNC		0x10000
#define DDCAPS_READSCANLINE		0x20000
#define DDCAPS_STEREOVIEW		0x40000
#define DDCAPS_VBI			0x80000
#define DDCAPS_ZBLTS			0x100000
#define DDCAPS_ZOVERLAYS		0x200000
#define DDCAPS_COLORKEY			0x400000
#define DDCAPS_ALPHA			0x800000
#define DDCAPS_COLORKEYHWASSIST		0x1000000
#define DDCAPS_NOHARDWARE		0x2000000
#define DDCAPS_BLTCOLORFILL		0x4000000
#define DDCAPS_BANKSWITCHED		0x8000000
#define DDCAPS_BLTDEPTHFILL		0x10000000
#define DDCAPS_CANCLIP			0x20000000
#define DDCAPS_CANCLIPSTRETCHED		0x40000000
#define DDCAPS_CANBLTSYSMEM		0x80000000
#define DDCAPS2_CERTIFIED		1
#define DDCAPS2_NO2DDURING3DSCENE 2
#define DDFXALPHACAPS_BLTALPHAEDGEBLEND		1
#define DDFXALPHACAPS_BLTALPHAPIXELS		2
#define DDFXALPHACAPS_BLTALPHAPIXELSNEG		4
#define DDFXALPHACAPS_BLTALPHASURFACES		8
#define DDFXALPHACAPS_BLTALPHASURFACESNEG	16
#define DDFXALPHACAPS_OVERLAYALPHAEDGEBLEND	32
#define DDFXALPHACAPS_OVERLAYALPHAPIXELS	0x40
#define DDFXALPHACAPS_OVERLAYALPHAPIXELSNEG	0x80
#define DDFXALPHACAPS_OVERLAYALPHASURFACES	0x100
#define DDFXALPHACAPS_OVERLAYALPHASURFACESNEG	0x200
#define DDFXCAPS_BLTARITHSTRETCHY	32
#define DDFXCAPS_BLTARITHSTRETCHYN	16
#define DDFXCAPS_BLTMIRRORLEFTRIGHT	0x40
#define DDFXCAPS_BLTMIRRORUPDOWN	0x80
#define DDFXCAPS_BLTROTATION		0x100
#define DDFXCAPS_BLTROTATION90		0x200
#define DDFXCAPS_BLTSHRINKX		0x400
#define DDFXCAPS_BLTSHRINKXN		0x800
#define DDFXCAPS_BLTSHRINKY		0x1000
#define DDFXCAPS_BLTSHRINKYN		0x2000
#define DDFXCAPS_BLTSTRETCHX		0x4000
#define DDFXCAPS_BLTSTRETCHXN		0x8000
#define DDFXCAPS_BLTSTRETCHY		0x10000
#define DDFXCAPS_BLTSTRETCHYN		0x20000
#define DDFXCAPS_OVERLAYARITHSTRETCHY	0x40000
#define DDFXCAPS_OVERLAYARITHSTRETCHYN	8
#define DDFXCAPS_OVERLAYSHRINKX		0x80000
#define DDFXCAPS_OVERLAYSHRINKXN	0x100000
#define DDFXCAPS_OVERLAYSHRINKY		0x200000
#define DDFXCAPS_OVERLAYSHRINKYN	0x400000
#define DDFXCAPS_OVERLAYSTRETCHX	0x800000
#define DDFXCAPS_OVERLAYSTRETCHXN	0x1000000
#define DDFXCAPS_OVERLAYSTRETCHY	0x2000000
#define DDFXCAPS_OVERLAYSTRETCHYN	0x4000000
#define DDFXCAPS_OVERLAYMIRRORLEFTRIGHT	0x8000000
#define DDFXCAPS_OVERLAYMIRRORUPDOWN	0x10000000
#define DDSVCAPS_ENIGMA			1
#define DDSVCAPS_FLICKER		2
#define DDSVCAPS_REDBLUE		4
#define DDSVCAPS_SPLIT			8
#define DDPCAPS_4BIT			1
#define DDPCAPS_8BITENTRIES		2
#define DDPCAPS_8BIT			4
#define DDPCAPS_INITIALIZE		8
#define DDPCAPS_PRIMARYSURFACE		16
#define DDPCAPS_PRIMARYSURFACELEFT	32
#define DDPCAPS_ALLOW256		0x40
#define DDPCAPS_VSYNC			0x80
#define DDPCAPS_1BIT			0x100
#define DDPCAPS_2BIT			0x200
#define DDBD_1			0x4000
#define DDBD_2			0x2000
#define DDBD_4			0x1000
#define DDBD_8			0x800
#define DDBD_16			0x400
#define DDBD_24			0x200
#define DDBD_32			0x100
#define DDCKEY_COLORSPACE	1
#define DDCKEY_DESTBLT		2
#define DDCKEY_DESTOVERLAY	4
#define DDCKEY_SRCBLT		8
#define DDCKEY_SRCOVERLAY	16
#define DDCKEYCAPS_DESTBLT			1
#define DDCKEYCAPS_DESTBLTCLRSPACE		2
#define DDCKEYCAPS_DESTBLTCLRSPACEYUV		4
#define DDCKEYCAPS_DESTBLTYUV			8
#define DDCKEYCAPS_DESTOVERLAY			16
#define DDCKEYCAPS_DESTOVERLAYCLRSPACE		32
#define DDCKEYCAPS_DESTOVERLAYCLRSPACEYUV	0x40
#define DDCKEYCAPS_DESTOVERLAYONEACTIVE		0x80
#define DDCKEYCAPS_DESTOVERLAYYUV		0x100
#define DDCKEYCAPS_SRCBLT			0x200
#define DDCKEYCAPS_SRCBLTCLRSPACE		0x400
#define DDCKEYCAPS_SRCBLTCLRSPACEYUV		0x800
#define DDCKEYCAPS_SRCBLTYUV			0x1000
#define DDCKEYCAPS_SRCOVERLAY			0x2000
#define DDCKEYCAPS_SRCOVERLAYCLRSPACE		0x4000
#define DDCKEYCAPS_SRCOVERLAYCLRSPACEYUV	0x8000
#define DDCKEYCAPS_SRCOVERLAYONEACTIVE		0x10000
#define DDCKEYCAPS_SRCOVERLAYYUV		0x20000
#define DDCKEYCAPS_NOCOSTOVERLAY		0x40000
#define DDPF_ALPHAPIXELS			1
#define DDPF_ALPHA				2
#define DDPF_FOURCC				4
#define DDPF_PALETTEINDEXED4			8
#define DDPF_PALETTEINDEXEDTO8			16
#define DDPF_PALETTEINDEXED8			32
#define DDPF_RGB				0x40
#define DDPF_COMPRESSED				0x80
#define DDPF_RGBTOYUV				0x100
#define DDPF_YUV				0x200
#define DDPF_ZBUFFER				0x400
#define DDPF_PALETTEINDEXED1			0x800
#define DDPF_PALETTEINDEXED2			0x1000
#define DDENUMSURFACES_ALL			1
#define DDENUMSURFACES_MATCH			2
#define DDENUMSURFACES_NOMATCH			4
#define DDENUMSURFACES_CANBECREATED		8
#define DDENUMSURFACES_DOESEXIST		16
#define DDEDM_REFRESHRATES			1
#define DDSCL_FULLSCREEN			1
#define DDSCL_ALLOWREBOOT			2
#define DDSCL_NOWINDOWCHANGES			4
#define DDSCL_NORMAL				8
#define DDSCL_EXCLUSIVE				16
#define DDSCL_ALLOWMODEX			0x40
#define DDBLT_ALPHADEST				1
#define DDBLT_ALPHADESTCONSTOVERRIDE		2
#define DDBLT_ALPHADESTNEG			4
#define DDBLT_ALPHADESTSURFACEOVERRIDE		8
#define DDBLT_ALPHAEDGEBLEND			16
#define DDBLT_ALPHASRC				32
#define DDBLT_ALPHASRCCONSTOVERRIDE		0x40
#define DDBLT_ALPHASRCNEG			0x80
#define DDBLT_ALPHASRCSURFACEOVERRIDE		0x100
#define DDBLT_ASYNC				0x200
#define DDBLT_COLORFILL				0x400
#define DDBLT_DDFX				0x800
#define DDBLT_DDROPS				0x1000
#define DDBLT_KEYDEST				0x2000
#define DDBLT_KEYDESTOVERRIDE			0x4000
#define DDBLT_KEYSRC				0x8000
#define DDBLT_KEYSRCOVERRIDE			0x10000
#define DDBLT_ROP				0x20000
#define DDBLT_ROTATIONANGLE			0x40000
#define DDBLT_ZBUFFER				0x80000
#define DDBLT_ZBUFFERDESTCONSTOVERRIDE		0x100000
#define DDBLT_ZBUFFERDESTOVERRIDE		0x200000
#define DDBLT_ZBUFFERSRCCONSTOVERRIDE		0x400000
#define DDBLT_ZBUFFERSRCOVERRIDE		0x800000
#define DDBLT_WAIT				0x1000000
#define DDBLT_DEPTHFILL				0x2000000
#define DDBLTFAST_NOCOLORKEY 0
#define DDBLTFAST_SRCCOLORKEY	1
#define DDBLTFAST_DESTCOLORKEY	2
#define DDBLTFAST_WAIT		16
#define DDFLIP_WAIT		1
#define DDOVER_ALPHADEST		1
#define DDOVER_ALPHADESTCONSTOVERRIDE	2
#define DDOVER_ALPHADESTNEG		4
#define DDOVER_ALPHADESTSURFACEOVERRIDE	8
#define DDOVER_ALPHAEDGEBLEND		16
#define DDOVER_ALPHASRC			32
#define DDOVER_ALPHASRCCONSTOVERRIDE	0x40
#define DDOVER_ALPHASRCNEG		0x80
#define DDOVER_ALPHASRCSURFACEOVERRIDE	0x100
#define DDOVER_HIDE			0x200
#define DDOVER_KEYDEST			0x400
#define DDOVER_KEYDESTOVERRIDE		0x800
#define DDOVER_KEYSRC			0x1000
#define DDOVER_KEYSRCOVERRIDE		0x2000
#define DDOVER_SHOW			0x4000
#define DDOVER_ADDDIRTYRECT 	0x8000
#define DDOVER_REFRESHDIRTYRECTS	0x10000
#define DDOVER_REFRESHALL 		0x20000
#define DDOVER_DDFX			0x80000
#define DDLOCK_SURFACEMEMORYPTR		0	
#define DDLOCK_WAIT			1
#define DDLOCK_EVENT			2
#define DDLOCK_READONLY			16
#define DDLOCK_WRITEONLY		32
#define DDBLTFX_ARITHSTRETCHY		1
#define DDBLTFX_MIRRORLEFTRIGHT		2
#define DDBLTFX_MIRRORUPDOWN		4
#define DDBLTFX_NOTEARING		8
#define DDBLTFX_ROTATE180		16
#define DDBLTFX_ROTATE270		32
#define DDBLTFX_ROTATE90		0x40
#define DDBLTFX_ZBUFFERRANGE		0x80
#define DDBLTFX_ZBUFFERBASEDEST		0x100
#define DDOVERFX_ARITHSTRETCHY		1
#define DDOVERFX_MIRRORLEFTRIGHT	2
#define DDOVERFX_MIRRORUPDOWN		4
#define DDWAITVB_BLOCKBEGIN		1
#define DDWAITVB_BLOCKBEGINEVENT	2
#define DDWAITVB_BLOCKEND		4
#define DDGFS_CANFLIP			1
#define DDGFS_ISFLIPDONE		2
#define DDGBS_CANBLT			1
#define DDGBS_ISBLTDONE			2
#define DDENUMOVERLAYZ_BACKTOFRONT	0
#define DDENUMOVERLAYZ_FRONTTOBACK	1
#define DDOVERZ_SENDTOFRONT		0
#define DDOVERZ_SENDTOBACK		1
#define DDOVERZ_MOVEFORWARD		2
#define DDOVERZ_MOVEBACKWARD		3
#define DDOVERZ_INSERTINFRONTOF		4
#define DDOVERZ_INSERTINBACKOF		5
#define DD_OK					0
#define DDENUMRET_CANCEL			0
#define DDENUMRET_OK				1
#define DDERR_ALREADYINITIALIZED		MAKE_DDHRESULT( 5 )
#define DDERR_CANNOTATTACHSURFACE		MAKE_DDHRESULT( 10 )
#define DDERR_CANNOTDETACHSURFACE		MAKE_DDHRESULT( 20 )
#define DDERR_CURRENTLYNOTAVAIL			MAKE_DDHRESULT( 40 )
#define DDERR_EXCEPTION				MAKE_DDHRESULT( 55 )
#define DDERR_GENERIC				E_FAIL
#define DDERR_HEIGHTALIGN			MAKE_DDHRESULT( 90 )
#define DDERR_INCOMPATIBLEPRIMARY		MAKE_DDHRESULT( 95 )
#define DDERR_INVALIDCAPS			MAKE_DDHRESULT( 100 )
#define DDERR_INVALIDCLIPLIST			MAKE_DDHRESULT( 110 )
#define DDERR_INVALIDMODE			MAKE_DDHRESULT( 120 )
#define DDERR_INVALIDOBJECT			MAKE_DDHRESULT( 130 )
#define DDERR_INVALIDPARAMS			E_INVALIDARG
#define DDERR_INVALIDPIXELFORMAT		MAKE_DDHRESULT( 145 )
#define DDERR_INVALIDRECT			MAKE_DDHRESULT( 150 )
#define DDERR_LOCKEDSURFACES			MAKE_DDHRESULT( 160 )
#define DDERR_NO3D				MAKE_DDHRESULT( 170 )
#define DDERR_NOALPHAHW				MAKE_DDHRESULT( 180 )
#define DDERR_NOCLIPLIST			MAKE_DDHRESULT( 205 )
#define DDERR_NOCOLORCONVHW			MAKE_DDHRESULT( 210 )
#define DDERR_NOCOOPERATIVELEVELSET		MAKE_DDHRESULT( 212 )
#define DDERR_NOCOLORKEY			MAKE_DDHRESULT( 215 )
#define DDERR_NOCOLORKEYHW			MAKE_DDHRESULT( 220 )
#define DDERR_NODIRECTDRAWSUPPORT		MAKE_DDHRESULT( 222 )
#define DDERR_NOEXCLUSIVEMODE			MAKE_DDHRESULT( 225 )
#define DDERR_NOFLIPHW				MAKE_DDHRESULT( 230 )
#define DDERR_NOGDI				MAKE_DDHRESULT( 240 )
#define DDERR_NOMIRRORHW			MAKE_DDHRESULT( 250 )
#define DDERR_NOTFOUND				MAKE_DDHRESULT( 255 )
#define DDERR_NOOVERLAYHW			MAKE_DDHRESULT( 260 )
#define DDERR_NORASTEROPHW			MAKE_DDHRESULT( 280 )
#define DDERR_NOROTATIONHW			MAKE_DDHRESULT( 290 )
#define DDERR_NOSTRETCHHW			MAKE_DDHRESULT( 310 )
#define DDERR_NOT4BITCOLOR			MAKE_DDHRESULT( 316 )
#define DDERR_NOT4BITCOLORINDEX			MAKE_DDHRESULT( 317 )
#define DDERR_NOT8BITCOLOR			MAKE_DDHRESULT( 320 )
#define DDERR_NOTEXTUREHW			MAKE_DDHRESULT( 330 )
#define DDERR_NOVSYNCHW				MAKE_DDHRESULT( 335 )
#define DDERR_NOZBUFFERHW			MAKE_DDHRESULT( 340 )
#define DDERR_NOZOVERLAYHW			MAKE_DDHRESULT( 350 )
#define DDERR_OUTOFCAPS				MAKE_DDHRESULT( 360 )
#define DDERR_OUTOFMEMORY			E_OUTOFMEMORY
#define DDERR_OUTOFVIDEOMEMORY			MAKE_DDHRESULT( 380 )
#define DDERR_OVERLAYCANTCLIP			MAKE_DDHRESULT( 382 )
#define DDERR_OVERLAYCOLORKEYONLYONEACTIVE	MAKE_DDHRESULT( 384 )
#define DDERR_PALETTEBUSY			MAKE_DDHRESULT( 387 )
#define DDERR_COLORKEYNOTSET			MAKE_DDHRESULT( 400 )
#define DDERR_SURFACEALREADYATTACHED		MAKE_DDHRESULT( 410 )
#define DDERR_SURFACEALREADYDEPENDENT		MAKE_DDHRESULT( 420 )
#define DDERR_SURFACEBUSY			MAKE_DDHRESULT( 430 )
#define DDERR_CANTLOCKSURFACE			MAKE_DDHRESULT( 435 )
#define DDERR_SURFACEISOBSCURED			MAKE_DDHRESULT( 440 )
#define DDERR_SURFACELOST			MAKE_DDHRESULT( 450 )
#define DDERR_SURFACENOTATTACHED		MAKE_DDHRESULT( 460 )
#define DDERR_TOOBIGHEIGHT			MAKE_DDHRESULT( 470 )
#define DDERR_TOOBIGSIZE			MAKE_DDHRESULT( 480 )
#define DDERR_TOOBIGWIDTH			MAKE_DDHRESULT( 490 )
#define DDERR_UNSUPPORTED			E_NOTIMPL
#define DDERR_UNSUPPORTEDFORMAT			MAKE_DDHRESULT( 510 )
#define DDERR_UNSUPPORTEDMASK			MAKE_DDHRESULT( 520 )
#define DDERR_VERTICALBLANKINPROGRESS		MAKE_DDHRESULT( 537 )
#define DDERR_WASSTILLDRAWING			MAKE_DDHRESULT( 540 )
#define DDERR_XALIGN				MAKE_DDHRESULT( 560 )
#define DDERR_INVALIDDIRECTDRAWGUID		MAKE_DDHRESULT( 561 )
#define DDERR_DIRECTDRAWALREADYCREATED		MAKE_DDHRESULT( 562 )
#define DDERR_NODIRECTDRAWHW			MAKE_DDHRESULT( 563 )
#define DDERR_PRIMARYSURFACEALREADYEXISTS	MAKE_DDHRESULT( 564 )
#define DDERR_NOEMULATION			MAKE_DDHRESULT( 565 )
#define DDERR_REGIONTOOSMALL			MAKE_DDHRESULT( 566 )
#define DDERR_CLIPPERISUSINGHWND		MAKE_DDHRESULT( 567 )
#define DDERR_NOCLIPPERATTACHED			MAKE_DDHRESULT( 568 )
#define DDERR_NOHWND				MAKE_DDHRESULT( 569 )
#define DDERR_HWNDSUBCLASSED			MAKE_DDHRESULT( 570 )
#define DDERR_HWNDALREADYSET			MAKE_DDHRESULT( 571 )
#define DDERR_NOPALETTEATTACHED			MAKE_DDHRESULT( 572 )
#define DDERR_NOPALETTEHW			MAKE_DDHRESULT( 573 )
#define DDERR_BLTFASTCANTCLIP			MAKE_DDHRESULT( 574 )
#define DDERR_NOBLTHW				MAKE_DDHRESULT( 575 )
#define DDERR_NODDROPSHW			MAKE_DDHRESULT( 576 )
#define DDERR_OVERLAYNOTVISIBLE			MAKE_DDHRESULT( 577 )
#define DDERR_NOOVERLAYDEST			MAKE_DDHRESULT( 578 )
#define DDERR_INVALIDPOSITION			MAKE_DDHRESULT( 579 )
#define DDERR_NOTAOVERLAYSURFACE		MAKE_DDHRESULT( 580 )
#define DDERR_EXCLUSIVEMODEALREADYSET		MAKE_DDHRESULT( 581 )
#define DDERR_NOTFLIPPABLE			MAKE_DDHRESULT( 582 )
#define DDERR_CANTDUPLICATE			MAKE_DDHRESULT( 583 )
#define DDERR_NOTLOCKED				MAKE_DDHRESULT( 584 )
#define DDERR_CANTCREATEDC			MAKE_DDHRESULT( 585 )
#define DDERR_NODC				MAKE_DDHRESULT( 586 )
#define DDERR_WRONGMODE				MAKE_DDHRESULT( 587 )
#define DDERR_IMPLICITLYCREATED			MAKE_DDHRESULT( 588 )
#define DDERR_NOTPALETTIZED			MAKE_DDHRESULT( 589 )
#define DDERR_UNSUPPORTEDMODE			MAKE_DDHRESULT( 590 )
#define DDERR_NOMIPMAPHW			MAKE_DDHRESULT( 591 )
#define DDERR_INVALIDSURFACETYPE		MAKE_DDHRESULT( 592 )
#define DDERR_DCALREADYCREATED			MAKE_DDHRESULT( 620 )
#define DDERR_CANTPAGELOCK			MAKE_DDHRESULT( 640 )
#define DDERR_CANTPAGEUNLOCK			MAKE_DDHRESULT( 660 )
#define DDERR_NOTPAGELOCKED			MAKE_DDHRESULT( 680 )
#define DDERR_NOTINITIALIZED			CO_E_NOTINITIALIZED
#endif
