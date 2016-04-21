/* $Revision: 1.2 $ */
#ifndef _GNU_SHELLAPI
#define _GNU_SHELLAPI
// SHELLAPI.H definitions and structures
#ifdef UNICODE
#define DragQueryFile  DragQueryFileW
#define ShellExecute  ShellExecuteW
#define FindExecutable  FindExecutableW
#define ShellAbout  ShellAboutW
#define ExtractAssociatedIcon  ExtractAssociatedIconW
#define ExtractIcon  ExtractIconW
#define DoEnvironmentSubst  DoEnvironmentSubstW
#define FindEnvironmentString  FindEnvironmentStringW
#define ExtractIconEx  ExtractIconExW
#define SHFileOperation  SHFileOperationW
#define ShellExecuteEx  ShellExecuteExW
#define WinExecError  WinExecErrorW
#define Shell_NotifyIcon  Shell_NotifyIconW
#define SHGetFileInfo  SHGetFileInfoW
#define SHGetNewLinkInfo  SHGetNewLinkInfoW
#else
#define DragQueryFile  DragQueryFileA
#define ShellExecute  ShellExecuteA
#define FindExecutable  FindExecutableA
#define ShellAbout  ShellAboutA
#define ExtractAssociatedIcon  ExtractAssociatedIconA
#define ExtractIcon  ExtractIconA
#define DoEnvironmentSubst  DoEnvironmentSubstA
#define FindEnvironmentString  FindEnvironmentStringA
#define ExtractIconEx  ExtractIconExA
#define SHFileOperation  SHFileOperationA
#define ShellExecuteEx  ShellExecuteExA
#define WinExecError  WinExecErrorA
#define Shell_NotifyIcon  Shell_NotifyIconA
#define SHGetFileInfo  SHGetFileInfoA
#define SHGetNewLinkInfo  SHGetNewLinkInfoA
#endif
typedef struct _DRAGINFOA {
	UINT uSize;
	POINT pt;
	BOOL fNC;
	LPSTR   lpFileList;
	DWORD grfKeyState;
} DRAGINFOA, * LPDRAGINFOA;
typedef struct _DRAGINFOW {
	UINT uSize;
	POINT pt;
	BOOL fNC;
	LPWSTR  lpFileList;
	DWORD grfKeyState;
} DRAGINFOW, * LPDRAGINFOW;
typedef struct _AppBarData {
	DWORD cbSize;
	HWND hWnd;
	UINT uCallbackMessage;
	UINT uEdge;
	RECT rc;
	LPARAM lParam;
} APPBARDATA, *PAPPBARDATA;
typedef struct tagSHFILEOPSTRUCTA {
	HWND	hwnd;
	UINT	wFunc;
	LPCSTR	pFrom;
	LPCSTR	pTo;
	FILEOP_FLAGS	fFlags;
	BOOL	fAnyOperationsAborted;
	LPVOID	hNameMappings;
	LPCSTR	lpszProgressTitle;
} SHFILEOPSTRUCTA, *LPSHFILEOPSTRUCTA;
typedef struct tagSHFILEOPSTRUCTW {
	HWND	hwnd;
	UINT	wFunc;
	LPCWSTR	pFrom;
	LPCWSTR	pTo;
	FILEOP_FLAGS	fFlags;
	BOOL	fAnyOperationsAborted;
	LPVOID	hNameMappings;
	LPCWSTR	lpszProgressTitle;
} SHFILEOPSTRUCTW, *LPSHFILEOPSTRUCTW;
typedef struct _SHNAMEMAPPINGA {
	LPSTR   pszOldPath;
	LPSTR   pszNewPath;
	int   cchOldPath;
	int   cchNewPath;
} SHNAMEMAPPINGA, *LPSHNAMEMAPPINGA;
typedef struct _SHNAMEMAPPINGW {
	LPWSTR  pszOldPath;
	LPWSTR  pszNewPath;
	int   cchOldPath;
	int   cchNewPath;
} SHNAMEMAPPINGW, *LPSHNAMEMAPPINGW;
typedef struct _SHELLEXECUTEINFOA {
	DWORD cbSize;
	ULONG fMask;
	HWND hwnd;
	LPCSTR   lpVerb;
	LPCSTR   lpFile;
	LPCSTR   lpParameters;
	LPCSTR   lpDirectory;
	int nShow;
	HINSTANCE hInstApp;
	LPVOID lpIDList;
	LPCSTR   lpClass;
	HKEY hkeyClass;
	DWORD dwHotKey;
	HANDLE hIcon;
	HANDLE hProcess;
} SHELLEXECUTEINFOA, *LPSHELLEXECUTEINFOA;
typedef struct _SHELLEXECUTEINFOW {
	DWORD cbSize;
	ULONG fMask;
	HWND hwnd;
	LPCWSTR  lpVerb;
	LPCWSTR  lpFile;
	LPCWSTR  lpParameters;
	LPCWSTR  lpDirectory;
	int nShow;
	HINSTANCE hInstApp;
	LPVOID lpIDList;
	LPCWSTR  lpClass;
	HKEY hkeyClass;
	DWORD dwHotKey;
	HANDLE hIcon;
	HANDLE hProcess;
} SHELLEXECUTEINFOW, *LPSHELLEXECUTEINFOW;
typedef struct _NOTIFYICONDATAA {
	DWORD cbSize;
	HWND hWnd;
	UINT uID;
	UINT uFlags;
	UINT uCallbackMessage;
	HICON hIcon;
	CHAR   szTip[64];
} NOTIFYICONDATAA, *PNOTIFYICONDATAA;
typedef struct _NOTIFYICONDATAW {
	DWORD cbSize;
	HWND hWnd;
	UINT uID;
	UINT uFlags;
	UINT uCallbackMessage;
	HICON hIcon;
	WCHAR  szTip[64];
} NOTIFYICONDATAW, *PNOTIFYICONDATAW;
typedef struct _SHFILEINFOA {
	HICON       hIcon;
	int         iIcon;
	DWORD       dwAttributes;
	CHAR        szDisplayName[MAX_PATH];
	CHAR        szTypeName[80];
} SHFILEINFOA;
typedef struct _SHFILEINFOW {
	HICON       hIcon;
	int         iIcon;
	DWORD       dwAttributes;
	WCHAR       szDisplayName[MAX_PATH];
	WCHAR       szTypeName[80];
} SHFILEINFOW;
#ifdef UNICODE
typedef DRAGINFOW DRAGINFO;
typedef LPDRAGINFOW LPDRAGINFO;
typedef NOTIFYICONDATAW NOTIFYICONDATA;
typedef PNOTIFYICONDATAW PNOTIFYICONDATA;
typedef SHELLEXECUTEINFOW SHELLEXECUTEINFO;
typedef LPSHELLEXECUTEINFOW LPSHELLEXECUTEINFO;
typedef SHFILEOPSTRUCTW SHFILEOPSTRUCT;
typedef LPSHFILEOPSTRUCTW LPSHFILEOPSTRUCT;
typedef SHNAMEMAPPINGW SHNAMEMAPPING;
typedef LPSHNAMEMAPPINGW LPSHNAMEMAPPING;
typedef SHFILEINFOW SHFILEINFO;
#else
typedef DRAGINFOA DRAGINFO;
typedef LPDRAGINFOA LPDRAGINFO;
typedef SHFILEOPSTRUCTA SHFILEOPSTRUCT;
typedef LPSHFILEOPSTRUCTA LPSHFILEOPSTRUCT;
typedef NOTIFYICONDATAA NOTIFYICONDATA;
typedef PNOTIFYICONDATAA PNOTIFYICONDATA;
typedef SHELLEXECUTEINFOA SHELLEXECUTEINFO;
typedef LPSHELLEXECUTEINFOA LPSHELLEXECUTEINFO;
typedef SHNAMEMAPPINGA SHNAMEMAPPING;
typedef LPSHNAMEMAPPINGA LPSHNAMEMAPPING;
typedef SHFILEINFOA SHFILEINFO;
#endif
#define SHGetNameMappingCount(h)  DSA_GetItemCount(h)
#define SHGetNameMappingPtr(h,i) (LPSHNAMEMAPPING)DSA_GetItemPtr(h,i)
#define SHGNLI_PIDL             1
#define SHGNLI_PREFIXNAME       2
#define SE_ERR_FNF              2
#define SE_ERR_PNF              3
#define SE_ERR_ACCESSDENIED     5
#define SE_ERR_OOM              8
#define SE_ERR_DLLNOTFOUND              32
#define SE_ERR_SHARE                    26
#define SE_ERR_ASSOCINCOMPLETE          27
#define SE_ERR_DDETIMEOUT               28
#define SE_ERR_DDEFAIL                  29
#define SE_ERR_DDEBUSY                  30
#define SE_ERR_NOASSOC                  31
#define SEE_MASK_CLASSNAME      1
#define SEE_MASK_CLASSKEY       3
#define SEE_MASK_IDLIST         4
#define SEE_MASK_INVOKEIDLIST   0xc
#define SEE_MASK_ICON           0x10
#define SEE_MASK_HOTKEY         0x20
#define SEE_MASK_NOCLOSEPROCESS 0x40
#define SEE_MASK_CONNECTNETDRV  0x80
#define SEE_MASK_FLAG_DDEWAIT   0x100
#define SEE_MASK_DOENVSUBST     0x200
#define SEE_MASK_FLAG_NO_UI     0x400
#define SEE_MASK_UNICODE        0x10000
#define NIM_ADD         0
#define NIM_MODIFY      1
#define NIM_DELETE      2
#define NIF_MESSAGE     1
#define NIF_ICON        2
#define NIF_TIP         4
#define ABM_NEW           0
#define ABM_REMOVE        1
#define ABM_QUERYPOS      2
#define ABM_SETPOS        3
#define ABM_GETSTATE      4
#define ABM_GETTASKBARPOS 5
#define ABM_ACTIVATE      6
#define ABM_GETAUTOHIDEBAR 7
#define ABM_SETAUTOHIDEBAR 8
#define ABM_WINDOWPOSCHANGED 9
#define ABN_STATECHANGE    0
#define ABN_POSCHANGED     1
#define ABN_FULLSCREENAPP  2
#define ABN_WINDOWARRANGE  3
#define ABS_AUTOHIDE    1
#define ABS_ALWAYSONTOP 2
#define ABE_LEFT        0
#define ABE_TOP         1
#define ABE_RIGHT       2
#define ABE_BOTTOM      3
#define PO_DELETE       0x13
#define PO_RENAME       0x14
#define PO_PORTCHANGE   0x20
#define PO_REN_PORT     0x34
#define EIRESID(x) (-1 * (int)(x))
#define SHGFI_ICON              0x100
#define SHGFI_DISPLAYNAME       0x200
#define SHGFI_TYPENAME          0x400
#define SHGFI_ATTRIBUTES        0x800
#define SHGFI_ICONLOCATION      0x1000
#define SHGFI_EXETYPE           0x2000
#define SHGFI_SYSICONINDEX      0x4000
#define SHGFI_LINKOVERLAY       0x8000
#define SHGFI_SELECTED          0x10000
#define SHGFI_LARGEICON         0
#define SHGFI_SMALLICON         1
#define SHGFI_OPENICON          2
#define SHGFI_SHELLICONSIZE     4
#define SHGFI_PIDL              8
#define SHGFI_USEFILEATTRIBUTES 16
#define SHGNLI_PIDL             1
#define SHGNLI_PREFIXNAME       2
#ifndef FO_MOVE
#define FO_MOVE           1
#define FO_COPY           2
#define FO_DELETE         3
#define FO_RENAME         4
#define FOF_MULTIDESTFILES         1
#define FOF_CONFIRMMOUSE           2
#define FOF_SILENT                 4
#define FOF_RENAMEONCOLLISION      8
#define FOF_NOCONFIRMATION         16
#define FOF_WANTMAPPINGHANDLE       32
#define FOF_ALLOWUNDO             64
#define FOF_FILESONLY              128
#define FOF_SIMPLEPROGRESS         256
#define FOF_NOCONFIRMMKDIR         512
typedef WORD PRINTEROP_FLAGS;
#endif
typedef WORD FILEOP_FLAGS;
typedef HANDLE HDROP;
UINT _stdcall DragQueryFileA(HDROP,UINT,LPSTR,UINT);
UINT _stdcall DragQueryFileW(HDROP,UINT,LPWSTR,UINT);
UINT _stdcall SHAppBarMessage(DWORD,PAPPBARDATA);
DWORD _stdcall DoEnvironmentSubstA(LPSTR,UINT);
DWORD _stdcall DoEnvironmentSubstW(LPWSTR,UINT);
LPSTR _stdcall FindEnvironmentStringA(LPSTR);
LPWSTR _stdcall FindEnvironmentStringW(LPWSTR);
UINT WINAPI ExtractIconExA(LPCSTR,int,HICON *,HICON *,UINT);
UINT WINAPI ExtractIconExW(LPCWSTR,int,HICON *,HICON *,UINT);
int WINAPI SHFileOperationA(LPSHFILEOPSTRUCTA);
int WINAPI SHFileOperationW(LPSHFILEOPSTRUCTW);
void WINAPI SHFreeNameMappings(HANDLE);
BOOL WINAPI ShellExecuteExA(LPSHELLEXECUTEINFOA);
BOOL WINAPI ShellExecuteExW(LPSHELLEXECUTEINFOW);
void WINAPI WinExecErrorA(HWND,int,LPCSTR,LPCSTR);
void WINAPI WinExecErrorW(HWND,int,LPCWSTR,LPCWSTR);
BOOL WINAPI Shell_NotifyIconA(DWORD,PNOTIFYICONDATAA);
BOOL WINAPI Shell_NotifyIconW(DWORD,PNOTIFYICONDATAW);
DWORD WINAPI SHGetFileInfoA(LPCSTR,DWORD,SHFILEINFOA *,UINT,UINT);
DWORD WINAPI SHGetFileInfoW(LPCWSTR,DWORD,SHFILEINFOW *,UINT,UINT);
BOOL WINAPI SHGetNewLinkInfoA(LPCSTR,LPCSTR,LPSTR,BOOL *,UINT);
BOOL WINAPI SHGetNewLinkInfoW(LPCWSTR,LPCWSTR,LPWSTR,BOOL *,UINT);
BOOL _stdcall DragQueryPoint(HDROP,LPPOINT);
VOID _stdcall DragFinish(HDROP);
VOID _stdcall DragAcceptFiles(HWND,BOOL);
HINSTANCE _stdcall ShellExecuteA(HWND,LPCSTR,LPCSTR,LPCSTR,LPCSTR,INT);
HINSTANCE _stdcall ShellExecuteW(HWND,LPCWSTR,LPCWSTR,LPCWSTR,LPCWSTR,INT);
HINSTANCE _stdcall FindExecutableA(LPCSTR,LPCSTR,LPSTR);
HINSTANCE _stdcall FindExecutableW(LPCWSTR,LPCWSTR,LPWSTR);
LPWSTR *_stdcall CommandLineToArgvW(LPCWSTR,int*);
int _stdcall ShellAboutA(HWND,LPCSTR,LPCSTR,HICON);
int _stdcall ShellAboutW(HWND,LPCWSTR,LPCWSTR,HICON);
HICON _stdcall DuplicateIcon(HINSTANCE,HICON);
HICON _stdcall ExtractAssociatedIconA(HINSTANCE,LPSTR,LPWORD);
HICON _stdcall ExtractAssociatedIconW(HINSTANCE,LPWSTR,LPWORD);
HICON _stdcall ExtractIconA(HINSTANCE,LPCSTR,UINT);
HICON _stdcall ExtractIconW(HINSTANCE,LPCWSTR,UINT);
#endif
