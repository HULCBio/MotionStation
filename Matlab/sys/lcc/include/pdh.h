/* $Revision: 1.2 $ */
#ifndef	_PDH_H_
#define	_PDH_H_
#include	<windows.h>	
#include	<winperf.h>	
#ifndef LONGLONG
#define LONGLONG long long
#endif
typedef	LONG	PDH_STATUS;
#define	PDH_FUNCTION	PDH_STATUS	__stdcall	
#define	PDH_CVERSION_WIN40	0x0400
#define	PDH_VERSION	PDH_CVERSION_WIN40
#define	IsSuccessSeverity(ErrorCode)((((DWORD)(ErrorCode)	&(0xC0000000L))	==	0x00000000L)	?	TRUE	:	FALSE)
#define	IsInformationalSeverity(ErrorCode)((((DWORD)(ErrorCode)	&(0xC0000000L))	==	0x40000000L)	?	TRUE	:	FALSE)
#define	IsWarningSeverity(ErrorCode)((((DWORD)(ErrorCode)	&(0xC0000000L))	==	0x80000000L)	?	TRUE	:	FALSE)
#define	IsErrorSeverity(ErrorCode)((((DWORD)(ErrorCode)	&(0xC0000000L))	==	0xC0000000L)	?	TRUE	:	FALSE)
typedef	HANDLE	HCOUNTER;
typedef	HANDLE	HQUERY;
typedef	struct	_PDH_RAW_COUNTER	{
	DWORD	CStatus;
	FILETIME	TimeStamp;
	LONGLONG	FirstValue;
	LONGLONG	SecondValue;
	DWORD	MultiCount;
}	PDH_RAW_COUNTER,*PPDH_RAW_COUNTER;
typedef	struct	_PDH_FMT_COUNTERVALUE	{
	DWORD	CStatus;
	union	{
	LONG	longValue;
	double	doubleValue;
	LONGLONG	largeValue;
	};
}	PDH_FMT_COUNTERVALUE,*PPDH_FMT_COUNTERVALUE;
typedef	struct	_PDH_STATISTICS	{
	DWORD	dwFormat;
	DWORD	count;
	PDH_FMT_COUNTERVALUE	min;
	PDH_FMT_COUNTERVALUE	max;
	PDH_FMT_COUNTERVALUE	mean;
}	PDH_STATISTICS,*PPDH_STATISTICS;
typedef	struct	_PDH_COUNTER_PATH_ELEMENTS_A	{
	LPSTR	szMachineName;
	LPSTR	szObjectName;
	LPSTR	szInstanceName;
	LPSTR	szParentInstance;
	DWORD	dwInstanceIndex;
	LPSTR	szCounterName;
}	PDH_COUNTER_PATH_ELEMENTS_A,*PPDH_COUNTER_PATH_ELEMENTS_A;
typedef	struct	_PDH_COUNTER_PATH_ELEMENTS_W	{
	LPWSTR	szMachineName;
	LPWSTR	szObjectName;
	LPWSTR	szInstanceName;
	LPWSTR	szParentInstance;
	DWORD	dwInstanceIndex;
	LPWSTR	szCounterName;
}	PDH_COUNTER_PATH_ELEMENTS_W,*PPDH_COUNTER_PATH_ELEMENTS_W;
typedef	struct	_PDH_COUNTER_INFO_A	{
	DWORD	dwLength;
	DWORD	dwType;
	DWORD	CVersion;
	DWORD	CStatus;
	LONG	lScale;
	LONG	lDefaultScale;
	DWORD	dwUserData;
	DWORD	dwQueryUserData;
	LPSTR	szFullPath;
	union	{
	PDH_COUNTER_PATH_ELEMENTS_A	CounterPath;
	struct	{
	LPSTR	szMachineName;
	LPSTR	szObjectName;
	LPSTR	szInstanceName;
	LPSTR	szParentInstance;
	DWORD	dwInstanceIndex;
	LPSTR	szCounterName;
	};
	};
	LPSTR	szExplainText;
	DWORD	DataBuffer[1];
}	PDH_COUNTER_INFO_A,*PPDH_COUNTER_INFO_A;
typedef	struct	_PDH_COUNTER_INFO_W	{
	DWORD	dwLength;
	DWORD	dwType;
	DWORD	CVersion;
	DWORD	CStatus;
	LONG	lScale;
	LONG	lDefaultScale;
	DWORD	dwUserData;
	DWORD	dwQueryUserData;
	LPWSTR	szFullPath;
	union	{
	PDH_COUNTER_PATH_ELEMENTS_W	CounterPath;
	struct	{
	LPWSTR	szMachineName;
	LPWSTR	szObjectName;
	LPWSTR	szInstanceName;
	LPWSTR	szParentInstance;
	DWORD	dwInstanceIndex;
	LPWSTR	szCounterName;
	};
	};
	LPWSTR	szExplainText;
	DWORD	DataBuffer[1];
}	PDH_COUNTER_INFO_W,*PPDH_COUNTER_INFO_W;
PDH_FUNCTION	PdhGetDllVersion(LPDWORD);
PDH_FUNCTION	PdhOpenQuery(LPVOID,DWORD,HQUERY	*);
PDH_FUNCTION	PdhAddCounterW(HQUERY,LPCWSTR,DWORD,HCOUNTER	*);
PDH_FUNCTION	PdhAddCounterA(HQUERY,LPCSTR,DWORD,HCOUNTER	*);
PDH_FUNCTION	PdhRemoveCounter(HCOUNTER);
PDH_FUNCTION	PdhCollectQueryData(HQUERY);
PDH_FUNCTION	PdhCloseQuery(HQUERY);
PDH_FUNCTION	PdhGetFormattedCounterValue(HCOUNTER,DWORD,LPDWORD,PPDH_FMT_COUNTERVALUE);
#define	PDH_FMT_RAW 0x00000010
#define	PDH_FMT_ANSI 0x00000020
#define	PDH_FMT_UNICODE 0x00000040
#define	PDH_FMT_LONG 0x00000100
#define	PDH_FMT_DOUBLE 0x00000200
#define	PDH_FMT_LARGE 0x00000400
#define	PDH_FMT_NOSCALE 0x00001000
#define	PDH_FMT_1000 0x00002000
#define	PDH_FMT_NODATA 0x00004000
PDH_FUNCTION	PdhGetRawCounterValue(HCOUNTER,LPDWORD,PPDH_RAW_COUNTER);
PDH_FUNCTION	PdhCalculateCounterFromRawValue(HCOUNTER,DWORD,PPDH_RAW_COUNTER,PPDH_RAW_COUNTER,PPDH_FMT_COUNTERVALUE);
PDH_FUNCTION	PdhComputeCounterStatistics(HCOUNTER,DWORD,DWORD,DWORD,PPDH_RAW_COUNTER,PPDH_STATISTICS);
PDH_FUNCTION	PdhGetCounterInfoW(HCOUNTER,BOOLEAN,LPDWORD,PPDH_COUNTER_INFO_W);
PDH_FUNCTION	PdhGetCounterInfoA(HCOUNTER,BOOLEAN,LPDWORD,PPDH_COUNTER_INFO_A);
#define	PDH_MAX_SCALE 7
#define	PDH_MIN_SCALE -7
PDH_FUNCTION	PdhSetCounterScaleFactor(HCOUNTER,LONG);
PDH_FUNCTION	PdhConnectMachineW(LPCWSTR);
PDH_FUNCTION	PdhConnectMachineA(LPCSTR);
PDH_FUNCTION	PdhEnumMachinesW(LPCWSTR,LPWSTR,LPDWORD);
PDH_FUNCTION	PdhEnumMachinesA(LPCSTR,LPSTR,LPDWORD);
PDH_FUNCTION	PdhEnumObjectsW(LPCWSTR,LPCWSTR,LPWSTR,LPDWORD,DWORD,BOOL);
PDH_FUNCTION	PdhEnumObjectsA(LPCSTR,LPCSTR,LPSTR,LPDWORD,DWORD,BOOL);
PDH_FUNCTION	PdhEnumObjectItemsW(LPCWSTR,LPCWSTR,LPCWSTR,LPWSTR,LPDWORD,LPWSTR,LPDWORD,DWORD,DWORD);
PDH_FUNCTION	PdhEnumObjectItemsA(LPCSTR,LPCSTR,LPCSTR,LPSTR,LPDWORD,LPSTR,LPDWORD,DWORD,DWORD);
PDH_FUNCTION	PdhMakeCounterPathW(PDH_COUNTER_PATH_ELEMENTS_W	*,LPWSTR,LPDWORD,DWORD);
PDH_FUNCTION	PdhMakeCounterPathA(PDH_COUNTER_PATH_ELEMENTS_A	*,LPSTR,LPDWORD,DWORD);
PDH_FUNCTION	PdhParseCounterPathW(LPCWSTR,PDH_COUNTER_PATH_ELEMENTS_W	*,LPDWORD,DWORD);
PDH_FUNCTION	PdhParseCounterPathA(LPCSTR,PDH_COUNTER_PATH_ELEMENTS_A	*,LPDWORD,DWORD);	
PDH_FUNCTION	PdhParseInstanceNameW(LPCWSTR,LPWSTR,LPDWORD,LPWSTR,LPDWORD,LPDWORD);
PDH_FUNCTION	PdhParseInstanceNameA(LPCSTR,LPSTR,LPDWORD,LPSTR,LPDWORD,LPDWORD);
PDH_FUNCTION	PdhValidatePathW(LPCWSTR);	
PDH_FUNCTION	PdhValidatePathA(LPCSTR);
PDH_FUNCTION	PdhGetDefaultPerfObjectW(LPCWSTR,LPCWSTR,LPWSTR,LPDWORD);	
PDH_FUNCTION	PdhGetDefaultPerfObjectA(LPCSTR,LPCSTR,LPSTR,LPDWORD);
PDH_FUNCTION	PdhGetDefaultPerfCounterW(LPCWSTR,LPCWSTR,LPCWSTR,LPWSTR,LPDWORD);
PDH_FUNCTION	PdhGetDefaultPerfCounterA(LPCSTR,LPCSTR,LPCSTR,LPSTR,LPDWORD);
typedef	PDH_STATUS(__stdcall	*CounterPathCallBack)(DWORD);
typedef	struct	_BrowseDlgConfig_W	{
	int	bIncludeInstanceIndex:1,
	bSingleCounterPerAdd:1,
	bSingleCounterPerDialog:1,
	bLocalCountersOnly:1,
	bWildCardInstances:1,
	bHideDetailBox:1,
	bInitializePath:1,
	bDisableMachineSelection:1,
	bReserved:24;
	HWND	hWndOwner;
	LPWSTR	szReserved;
	LPWSTR	szReturnPathBuffer;
	DWORD	cchReturnPathLength;
	CounterPathCallBack	pCallBack;
	DWORD	dwCallBackArg;
	PDH_STATUS	CallBackStatus;
	DWORD	dwDefaultDetailLevel;
	LPWSTR	szDialogBoxCaption;
}	PDH_BROWSE_DLG_CONFIG_W,*PPDH_BROWSE_DLG_CONFIG_W;
typedef	struct	_BrowseDlgConfig_A	{
	int	bIncludeInstanceIndex:1,
	bSingleCounterPerAdd:1,
	bSingleCounterPerDialog:1,
	bLocalCountersOnly:1,
	bWildCardInstances:1,
	bHideDetailBox:1,
	bInitializePath:1,
	bDisableMachineSelection:1,
	bReserved:24;

	HWND	hWndOwner;
	LPSTR	szReserved;
	LPSTR	szReturnPathBuffer;
	DWORD	cchReturnPathLength;
	CounterPathCallBack	pCallBack;
	DWORD	dwCallBackArg;
	PDH_STATUS	CallBackStatus;
	DWORD	dwDefaultDetailLevel;
	LPSTR	szDialogBoxCaption;
}	PDH_BROWSE_DLG_CONFIG_A,*PPDH_BROWSE_DLG_CONFIG_A;

PDH_FUNCTION	PdhBrowseCountersW(PPDH_BROWSE_DLG_CONFIG_W);
PDH_FUNCTION	PdhBrowseCountersA(PPDH_BROWSE_DLG_CONFIG_A);
PDH_FUNCTION	PdhExpandCounterPathW(LPCWSTR,LPWSTR,LPDWORD);
PDH_FUNCTION	PdhExpandCounterPathA(LPCSTR,LPSTR,LPDWORD);
#ifdef	UNICODE
#ifndef	_UNICODE
#define	_UNICODE
#endif
#endif

#ifdef	_UNICODE
#ifndef	UNICODE
#define	UNICODE
#endif
#endif

#ifdef	UNICODE

#define	PdhAddCounter	PdhAddCounterW
#define	PdhGetCounterInfo	PdhGetCounterInfoW
#define	PDH_COUNTER_INFO	PDH_COUNTER_INFO_W
#define	PPDH_COUNTER_INFO	PPDH_COUNTER_INFO_W
#define	PdhConnectMachine	PdhConnectMachineW
#define	PdhEnumMachines	PdhEnumMachinesW
#define	PdhEnumObjects	PdhEnumObjectsW
#define	PdhEnumObjectItems	PdhEnumObjectItemsW
#define	PdhMakeCounterPath	PdhMakeCounterPathW
#define	PDH_COUNTER_PATH_ELEMENTS	PDH_COUNTER_PATH_ELEMENTS_W
#define	PPDH_COUNTER_PATH_ELEMENTS	PPDH_COUNTER_PATH_ELEMENTS_W
#define	PdhParseCounterPath	PdhParseCounterPathW
#define	PdhParseInstanceName	PdhParseInstanceNameW
#define	PdhValidatePath	PdhValidatePathW
#define	PdhGetDefaultPerfObject	PdhGetDefaultPerfObjectW
#define	PdhGetDefaultPerfCounter	PdhGetDefaultPerfCounterW
#define	PdhBrowseCounters	PdhBrowseCountersW
#define	PDH_BROWSE_DLG_CONFIG	PDH_BROWSE_DLG_CONFIG_W
#define	PPDH_BROWSE_DLG_CONFIG	PPDH_BROWSE_DLG_CONFIG_W
#define	PdhExpandCounterPath	PdhExpandCounterPathW
#else	
#define	PdhAddCounter	PdhAddCounterA
#define	PdhGetCounterInfo	PdhGetCounterInfoA
#define	PDH_COUNTER_INFO	PDH_COUNTER_INFO_A
#define	PPDH_COUNTER_INFO	PPDH_COUNTER_INFO_A
#define	PdhConnectMachine	PdhConnectMachineA
#define	PdhEnumMachines	PdhEnumMachinesA
#define	PdhEnumObjects	PdhEnumObjectsA
#define	PdhEnumObjectItems	PdhEnumObjectItemsA
#define	PdhMakeCounterPath	PdhMakeCounterPathA
#define	PDH_COUNTER_PATH_ELEMENTS	PDH_COUNTER_PATH_ELEMENTS_A
#define	PPDH_COUNTER_PATH_ELEMENTS	PPDH_COUNTER_PATH_ELEMENTS_A
#define	PdhParseCounterPath	PdhParseCounterPathA
#define	PdhParseInstanceName	PdhParseInstanceNameA
#define	PdhValidatePath	PdhValidatePathA
#define	PdhGetDefaultPerfObject	PdhGetDefaultPerfObjectA
#define	PdhGetDefaultPerfCounter	PdhGetDefaultPerfCounterA
#define	PdhBrowseCounters	PdhBrowseCountersA
#define	PDH_BROWSE_DLG_CONFIG	PDH_BROWSE_DLG_CONFIG_A
#define	PPDH_BROWSE_DLG_CONFIG	PPDH_BROWSE_DLG_CONFIG_A
#define	PdhExpandCounterPath	PdhExpandCounterPathA

#endif	

#endif	
