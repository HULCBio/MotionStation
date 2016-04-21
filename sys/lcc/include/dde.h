/* $Revision: 1.2 $ */
#ifndef _LCCDDE_
#define _LCCDDE_
#pragma pack(push,1)
#ifndef _GNU_H_WIN32Headers
#include <win.h>
#endif
#define WM_DDE_FIRST	0x03E0
#define WM_DDE_INITIATE	(WM_DDE_FIRST)
#define WM_DDE_TERMINATE	(WM_DDE_FIRST+1)
#define WM_DDE_ADVISE	(WM_DDE_FIRST+2)
#define WM_DDE_UNADVISE	(WM_DDE_FIRST+3)
#define WM_DDE_ACK	(WM_DDE_FIRST+4)
#define WM_DDE_DATA	(WM_DDE_FIRST+5)
#define WM_DDE_REQUEST	(WM_DDE_FIRST+6)
#define WM_DDE_POKE	(WM_DDE_FIRST+7)
#define WM_DDE_EXECUTE	(WM_DDE_FIRST+8)
#define WM_DDE_LAST	(WM_DDE_FIRST+8)
typedef struct {
	unsigned int bAppReturnCode:8, reserved:6, fBusy:1,fAck:1;
} DDEACK;
typedef struct {
	unsigned int reserved:14,fDeferUpd:1,fAckReq:1;short cfFormat;
} DDEADVISE;
typedef struct {
	unsigned int unused:12,fResponse:1,fRelease:1,reserved:1,fAckReq:1;
	short	 cfFormat; BYTE	 Value[1];
} DDEDATA;
typedef struct {
	unsigned int unused:13,fRelease:1,fReserved:2;
	short    cfFormat; BYTE	 Value[1];
} DDEPOKE;
typedef struct {
	unsigned int unused:13,fRelease:1,fDeferUpd:1,fAckReq:1;short cfFormat;
} DDELN;
typedef struct {
	unsigned int unused:12,fAck:1,fRelease:1,fReserved:1,fAckReq:1;
	short	cfFormat;	BYTE rgb[1];
} DDEUP;
BOOL WINAPI DdeSetQualityOfService(HWND,SECURITY_QUALITY_OF_SERVICE *,
	PSECURITY_QUALITY_OF_SERVICE);
BOOL WINAPI ImpersonateDdeClientWindow(HWND,HWND);
LONG APIENTRY PackDDElParam(UINT,UINT,UINT);
BOOL APIENTRY UnpackDDElParam(UINT,LONG,PUINT,PUINT);
BOOL APIENTRY FreeDDElParam(UINT,LONG);
LONG APIENTRY ReuseDDElParam(LONG,UINT,UINT,UINT,UINT);
#pragma pack(pop)
#endif
