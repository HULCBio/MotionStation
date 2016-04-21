/* $Revision: 1.2 $ */
#ifndef          _INC_NDDEAPI
#define          _INC_NDDEAPI
#ifndef CNLEN           
#define CNLEN	15                  
#define UNCLEN	(CNLEN+2)           
#endif 
#define SEP_CHAR    ','
#define BAR_CHAR    "|"
#define SEP_WCHAR   L','
#define BAR_WCHAR   L"|"
#define NDDE_NO_ERROR                   0
#define NDDE_ACCESS_DENIED              1
#define NDDE_BUF_TOO_SMALL              2
#define NDDE_ERROR_MORE_DATA            3
#define NDDE_INVALID_SERVER             4
#define NDDE_INVALID_SHARE              5
#define NDDE_INVALID_PARAMETER          6
#define NDDE_INVALID_LEVEL              7
#define NDDE_INVALID_PASSWORD           8
#define NDDE_INVALID_ITEMNAME           9
#define NDDE_INVALID_TOPIC             10
#define NDDE_INTERNAL_ERROR            11
#define NDDE_OUT_OF_MEMORY             12
#define NDDE_INVALID_APPNAME           13
#define NDDE_NOT_IMPLEMENTED           14
#define NDDE_SHARE_ALREADY_EXIST       15
#define NDDE_SHARE_NOT_EXIST           16
#define NDDE_INVALID_FILENAME          17
#define NDDE_NOT_RUNNING               18
#define NDDE_INVALID_WINDOW            19
#define NDDE_INVALID_SESSION           20
#define NDDE_INVALID_ITEM_LIST         21
#define NDDE_SHARE_DATA_CORRUPTED      22
#define NDDE_REGISTRY_ERROR            23
#define NDDE_CANT_ACCESS_SERVER        24
#define NDDE_INVALID_SPECIAL_COMMAND   25
#define NDDE_INVALID_SECURITY_DESC     26
#define NDDE_TRUST_SHARE_FAIL          27
#define MAX_NDDESHARENAME       256
#define MAX_DOMAINNAME          15
#define MAX_USERNAME            15
#define MAX_APPNAME             255
#define MAX_TOPICNAME           255
#define MAX_ITEMNAME            255
#define NDDEF_NOPASSWORDPROMPT  0x0001
#define NDDEF_NOCACHELOOKUP     0x0002
#define NDDEF_STRIP_NDDE 0x0004
struct	NDdeShareInfo_tag {
	LONG	lRevision;
	LPTSTR	lpszShareName;
	LONG	lShareType;
	LPTSTR	lpszAppTopicList;
	LONG	fSharedFlag;
	LONG	fService;
	LONG	fStartAppFlag;
	LONG	nCmdShow;
	LONG	qModifyId[2];
	LONG	cNumItems;
	LPTSTR	lpszItemList;
};
typedef	struct NDdeShareInfo_tag NDDESHAREINFO;
typedef struct NDdeShareInfo_tag * PNDDESHAREINFO;
#define SHARE_TYPE_OLD 0x01     
#define SHARE_TYPE_NEW 0x02            
#define SHARE_TYPE_STATIC 0x04            
UINT WINAPI NDdeShareAddA(LPSTR,UINT,PSECURITY_DESCRIPTOR,LPBYTE,DWORD);
UINT WINAPI NDdeShareAddW(LPWSTR,UINT,PSECURITY_DESCRIPTOR,LPBYTE,DWORD);
UINT WINAPI NDdeShareDelA(LPSTR,LPSTR,UINT);
UINT WINAPI NDdeShareDelW(LPWSTR,LPWSTR,UINT);
UINT WINAPI NDdeGetShareSecurityA(LPSTR,LPSTR,SECURITY_INFORMATION,PSECURITY_DESCRIPTOR,DWORD,LPDWORD);
UINT WINAPI NDdeGetShareSecurityW(LPWSTR,LPWSTR,SECURITY_INFORMATION,PSECURITY_DESCRIPTOR,DWORD,LPDWORD);
UINT WINAPI NDdeSetShareSecurityA(LPSTR,LPSTR,SECURITY_INFORMATION,PSECURITY_DESCRIPTOR);
UINT WINAPI NDdeSetShareSecurityW(LPWSTR,LPWSTR,SECURITY_INFORMATION,PSECURITY_DESCRIPTOR);
UINT WINAPI NDdeShareEnumA(LPSTR,UINT,LPBYTE,DWORD,LPDWORD,LPDWORD);
UINT WINAPI NDdeShareEnumW(LPWSTR,UINT,LPBYTE,DWORD,LPDWORD,LPDWORD);
UINT WINAPI NDdeShareGetInfoA(LPSTR,LPSTR,UINT,LPBYTE,DWORD,LPDWORD,LPWORD);
UINT WINAPI NDdeShareGetInfoW(LPWSTR,LPWSTR,UINT,LPBYTE,DWORD,LPDWORD,LPWORD);
UINT WINAPI NDdeShareSetInfoA(LPSTR,LPSTR,UINT,LPBYTE,DWORD,WORD);
UINT WINAPI NDdeShareSetInfoW(LPWSTR,LPWSTR,UINT,LPBYTE,DWORD,WORD);
UINT WINAPI NDdeSetTrustedShareA(LPSTR,LPSTR,DWORD);
UINT WINAPI NDdeSetTrustedShareW(LPWSTR,LPWSTR,DWORD);
#define NDDE_TRUST_SHARE_START  0x80000000     
#define NDDE_TRUST_SHARE_INIT   0x40000000     
#define NDDE_TRUST_SHARE_DEL    0x20000000     
#define NDDE_TRUST_CMD_SHOW     0x10000000     
#define NDDE_CMD_SHOW_MASK      0xFFFF     
UINT WINAPI NDdeGetTrustedShareA(LPSTR,LPSTR,LPDWORD,LPDWORD,LPDWORD);
UINT WINAPI NDdeGetTrustedShareW(LPWSTR,LPWSTR,LPDWORD,LPDWORD,LPDWORD);
UINT WINAPI NDdeTrustedShareEnumA(LPSTR,UINT,LPBYTE,DWORD,LPDWORD,LPDWORD);
UINT WINAPI NDdeTrustedShareEnumW(LPWSTR,UINT,LPBYTE,DWORD,LPDWORD,LPDWORD);
UINT WINAPI NDdeGetErrorStringA(UINT,LPSTR,DWORD);
UINT WINAPI NDdeGetErrorStringW(UINT,LPWSTR,DWORD);
BOOL WINAPI NDdeIsValidShareNameA(LPSTR);
BOOL WINAPI NDdeIsValidShareNameW(LPWSTR);
BOOL WINAPI NDdeIsValidAppTopicListA(LPSTR);
BOOL WINAPI NDdeIsValidAppTopicListW(LPWSTR);
#ifdef UNICODE
#define NDdeShareAdd	NDdeShareAddW
#define NDdeShareDel	NDdeShareDelW
#define NDdeSetShareSecurity	NDdeSetShareSecurityW
#define NDdeGetShareSecurity	NDdeGetShareSecurityW
#define NDdeShareEnum	NDdeShareEnumW
#define NDdeShareGetInfo	NDdeShareGetInfoW
#define NDdeShareSetInfo	NDdeShareSetInfoW
#define NDdeGetErrorString	NDdeGetErrorStringW
#define NDdeIsValidShareName	NDdeIsValidShareNameW
#define NDdeIsValidAppTopicList	NDdeIsValidAppTopicListW
#define NDdeSetTrustedShare	NDdeSetTrustedShareW
#define NDdeGetTrustedShare	NDdeGetTrustedShareW
#define NDdeTrustedShareEnum	NDdeTrustedShareEnumW
#else
#define NDdeShareAdd	NDdeShareAddA
#define NDdeShareDel	NDdeShareDelA
#define NDdeSetShareSecurity	NDdeSetShareSecurityA
#define NDdeGetShareSecurity	NDdeGetShareSecurityA
#define NDdeShareEnum	NDdeShareEnumA
#define NDdeShareGetInfo	NDdeShareGetInfoA
#define NDdeShareSetInfo	NDdeShareSetInfoA
#define NDdeGetErrorString	NDdeGetErrorStringA
#define NDdeIsValidShareName	NDdeIsValidShareNameA
#define NDdeIsValidAppTopicList	NDdeIsValidAppTopicListA
#define NDdeSetTrustedShare	NDdeSetTrustedShareA
#define NDdeGetTrustedShare	NDdeGetTrustedShareA
#define NDdeTrustedShareEnum	NDdeTrustedShareEnumA
#endif
#endif  

