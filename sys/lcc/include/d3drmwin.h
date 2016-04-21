/* $Revision: 1.2 $ */
#ifndef _LCC__D3DRMWIN_H__ 
#define _LCC__D3DRMWIN_H__ 
#include "d3drm.h" 
#include "ddraw.h" 
#include "d3d.h" 
DEFINE_GUID(IID_IDirect3DRMWinDevice,   0xc5016cc0, 0xd273, 0x11ce, 0xac, 0x48, 0x0, 0x0, 0xc0, 0x38, 0x25, 0xa1); 
WIN_TYPES(IDirect3DRMWinDevice, DIRECT3DRMWINDEVICE); 
#undef INTERFACE 
#define INTERFACE IDirect3DRMWinDevice 
DECLARE_INTERFACE_(IDirect3DRMWinDevice, IDirect3DRMObject) { 
    IUNKNOWN_METHODS(PURE); 
    IDIRECT3DRMOBJECT_METHODS(PURE); 
    STDMETHOD(HandlePaint)(THIS_ HDC hdc) PURE; 
    STDMETHOD(HandleActivate)(THIS_ WORD wparam) PURE; 
}; 
#endif 
