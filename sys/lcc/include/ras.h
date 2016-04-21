#ifndef	_LCC_RAS_H_
#define	_LCC_RAS_H_
#ifndef	_LCC_NETCONS_INCLUDED
#include	<lmcons.h>
#endif
#pragma	pack(push,4)
#define	RAS_MaxDeviceType 16
#define	RAS_MaxPhoneNumber 128
#define	RAS_MaxIpAddress 15
#define	RAS_MaxIpxAddress 21
#define	RAS_MaxEntryName 256
#define	RAS_MaxDeviceName 128
#define	RAS_MaxCallbackNumber RAS_MaxPhoneNumber
#define	RAS_MaxAreaCode 10
#define	RAS_MaxPadType 32
#define	RAS_MaxX25Address 200
#define	RAS_MaxFacilities 200
#define	RAS_MaxUserData 200
DECLARE_HANDLE(HRASCONN);
#define	LPHRASCONN HRASCONN*
#define	RASCONNW struct tagRASCONNW
RASCONNW
{
	DWORD dwSize;
	HRASCONN hrasconn;
	WCHAR szEntryName[ RAS_MaxEntryName + 1 ];
	WCHAR szDeviceType[ RAS_MaxDeviceType + 1 ];
	WCHAR szDeviceName[ RAS_MaxDeviceName + 1 ];
	WCHAR szPhonebook [ MAX_PATH ];
	DWORD dwSubEntry;
};

#define	RASCONNA struct tagRASCONNA
RASCONNA
{
	DWORD dwSize;
	HRASCONN hrasconn;
	CHAR szEntryName[ RAS_MaxEntryName + 1 ];

	CHAR szDeviceType[ RAS_MaxDeviceType + 1 ];
	CHAR szDeviceName[ RAS_MaxDeviceName + 1 ];
	CHAR szPhonebook [ MAX_PATH ];
	DWORD dwSubEntry;
};

#ifdef	UNICODE
#define	RASCONN RASCONNW
#else
#define	RASCONN RASCONNA
#endif
#define	LPRASCONNW RASCONNW*
#define	LPRASCONNA RASCONNA*
#define	LPRASCONN RASCONN*
#define	RASCS_PAUSED 0x1000
#define	RASCS_DONE 0x2000
#define	RASCONNSTATE enum tagRASCONNSTATE
RASCONNSTATE {
	RASCS_OpenPort = 0,
	RASCS_PortOpened,
	RASCS_ConnectDevice,
	RASCS_DeviceConnected,
	RASCS_AllDevicesConnected,
	RASCS_Authenticate,
	RASCS_AuthNotify,
	RASCS_AuthRetry,
	RASCS_AuthCallback,
	RASCS_AuthChangePassword,
	RASCS_AuthProject,
	RASCS_AuthLinkSpeed,
	RASCS_AuthAck,
	RASCS_ReAuthenticate,
	RASCS_Authenticated,
	RASCS_PrepareForCallback,
	RASCS_WaitForModemReset,
	RASCS_WaitForCallback,
	RASCS_Projected,
	RASCS_StartAuthentication,
	RASCS_CallbackComplete,
	RASCS_LogonNetwork,
	RASCS_SubEntryConnected,
	RASCS_SubEntryDisconnected,
	RASCS_Interactive = RASCS_PAUSED,
	RASCS_RetryAuthentication,
	RASCS_CallbackSetByCaller,
	RASCS_PasswordExpired,
	RASCS_Connected = RASCS_DONE,
	RASCS_Disconnected
};
#define	LPRASCONNSTATE RASCONNSTATE*
#define	RASCONNSTATUSW struct tagRASCONNSTATUSW
RASCONNSTATUSW
{
	DWORD dwSize;
	RASCONNSTATE rasconnstate;
	DWORD dwError;
	WCHAR szDeviceType[ RAS_MaxDeviceType + 1 ];
	WCHAR szDeviceName[ RAS_MaxDeviceName + 1 ];
	WCHAR szPhoneNumber[ RAS_MaxPhoneNumber + 1 ];
};
#define	RASCONNSTATUSA struct tagRASCONNSTATUSA
RASCONNSTATUSA
{
	DWORD dwSize;
	RASCONNSTATE rasconnstate;
	DWORD dwError;
	CHAR szDeviceType[ RAS_MaxDeviceType + 1 ];
	CHAR szDeviceName[ RAS_MaxDeviceName + 1 ];
	CHAR szPhoneNumber[ RAS_MaxPhoneNumber + 1 ];
};
#ifdef	UNICODE
#define	RASCONNSTATUS RASCONNSTATUSW
#else
#define	RASCONNSTATUS RASCONNSTATUSA
#endif
#define	LPRASCONNSTATUSW RASCONNSTATUSW*
#define	LPRASCONNSTATUSA RASCONNSTATUSA*
#define	LPRASCONNSTATUS RASCONNSTATUS*
#define	RASDIALPARAMSW struct tagRASDIALPARAMSW
RASDIALPARAMSW {
	DWORD dwSize;
	WCHAR szEntryName[ RAS_MaxEntryName + 1 ];
	WCHAR szPhoneNumber[ RAS_MaxPhoneNumber + 1 ];
	WCHAR szCallbackNumber[ RAS_MaxCallbackNumber + 1 ];
	WCHAR szUserName[ UNLEN + 1 ];
	WCHAR szPassword[ PWLEN + 1 ];
	WCHAR szDomain[ DNLEN + 1 ];
	DWORD dwSubEntry;
	DWORD dwCallbackId;
};
#define	RASDIALPARAMSA struct tagRASDIALPARAMSA
RASDIALPARAMSA {
	DWORD dwSize;
	CHAR szEntryName[ RAS_MaxEntryName + 1 ];
	CHAR szPhoneNumber[ RAS_MaxPhoneNumber + 1 ];
	CHAR szCallbackNumber[ RAS_MaxCallbackNumber + 1 ];
	CHAR szUserName[ UNLEN + 1 ];
	CHAR szPassword[ PWLEN + 1 ];
	CHAR szDomain[ DNLEN + 1 ];
	DWORD dwSubEntry;
	DWORD dwCallbackId;
};
#ifdef	UNICODE
#define	RASDIALPARAMS RASDIALPARAMSW
#else
#define	RASDIALPARAMS RASDIALPARAMSA
#endif
#define	LPRASDIALPARAMSW RASDIALPARAMSW*
#define	LPRASDIALPARAMSA RASDIALPARAMSA*
#define	LPRASDIALPARAMS RASDIALPARAMS*
#define	RASDIALEXTENSIONS struct tagRASDIALEXTENSIONS
RASDIALEXTENSIONS {
	DWORD dwSize;
	DWORD dwfOptions;
	HWND hwndParent;
	DWORD reserved;
};
#define	LPRASDIALEXTENSIONS RASDIALEXTENSIONS*
#define	RDEOPT_UsePrefixSuffix 1
#define	RDEOPT_PausedStates 2
#define	RDEOPT_IgnoreModemSpeaker 4
#define	RDEOPT_SetModemSpeaker 8
#define	RDEOPT_IgnoreSoftwareCompression 16
#define	RDEOPT_SetSoftwareCompression 32
#define	RDEOPT_DisableConnectedUI 64
#define	RDEOPT_DisableReconnectUI 0x80
#define	RDEOPT_DisableReconnect 0x100
#define	RDEOPT_NoUser 0x200
#define	RASENTRYNAMEW struct tagRASENTRYNAMEW
RASENTRYNAMEW {
	DWORD dwSize;
	WCHAR szEntryName[ RAS_MaxEntryName + 1 ];
};
#define	RASENTRYNAMEA struct tagRASENTRYNAMEA
RASENTRYNAMEA {
	DWORD dwSize;
	CHAR szEntryName[ RAS_MaxEntryName + 1 ];
};
#ifdef	UNICODE
#define	RASENTRYNAME RASENTRYNAMEW
#else
#define	RASENTRYNAME RASENTRYNAMEA
#endif
#define	LPRASENTRYNAMEW RASENTRYNAMEW*
#define	LPRASENTRYNAMEA RASENTRYNAMEA*
#define	LPRASENTRYNAME RASENTRYNAME*
#define	RASPROJECTION enum tagRASPROJECTION
RASPROJECTION {
	RASP_Amb = 0x10000,
	RASP_PppNbf = 0x803F,
	RASP_PppIpx = 0x802B,
	RASP_PppIp = 0x8021,
	RASP_PppLcp = 0xC021,
	RASP_Slip = 0x20000
};
#define	LPRASPROJECTION RASPROJECTION*
#define	RASAMBW struct tagRASAMBW
RASAMBW {
	DWORD dwSize;
	DWORD dwError;
	WCHAR szNetBiosError[ NETBIOS_NAME_LEN + 1 ];
	BYTE bLana;
};
#define	RASAMBA struct tagRASAMBA
RASAMBA {
	DWORD dwSize;
	DWORD dwError;
	CHAR szNetBiosError[ NETBIOS_NAME_LEN + 1 ];
	BYTE bLana;
};
#ifdef	UNICODE
#define	RASAMB RASAMBW
#else
#define	RASAMB RASAMBA
#endif
#define	LPRASAMBW RASAMBW*
#define	LPRASAMBA RASAMBA*
#define	LPRASAMB RASAMB*
#define	RASPPPNBFW struct tagRASPPPNBFW
RASPPPNBFW {
	DWORD dwSize;
	DWORD dwError;
	DWORD dwNetBiosError;
	WCHAR szNetBiosError[ NETBIOS_NAME_LEN + 1 ];
	WCHAR szWorkstationName[ NETBIOS_NAME_LEN + 1 ];
	BYTE bLana;
};
#define	RASPPPNBFA struct tagRASPPPNBFA
RASPPPNBFA {
	DWORD dwSize;
	DWORD dwError;
	DWORD dwNetBiosError;
	CHAR szNetBiosError[ NETBIOS_NAME_LEN + 1 ];
	CHAR szWorkstationName[ NETBIOS_NAME_LEN + 1 ];
	BYTE bLana;
};
#ifdef	UNICODE
#define	RASPPPNBF RASPPPNBFW
#else
#define	RASPPPNBF RASPPPNBFA
#endif
#define	LPRASPPPNBFW RASPPPNBFW*
#define	LPRASPPPNBFA RASPPPNBFA*
#define	LPRASPPPNBF RASPPPNBF*
#define	RASPPPIPXW struct tagRASIPXW
RASPPPIPXW {
	DWORD dwSize;
	DWORD dwError;
	WCHAR szIpxAddress[ RAS_MaxIpxAddress + 1 ];
};
#define	RASPPPIPXA struct tagRASPPPIPXA
RASPPPIPXA {
	DWORD dwSize;
	DWORD dwError;
	CHAR szIpxAddress[ RAS_MaxIpxAddress + 1 ];
};
#ifdef	UNICODE
#define	RASPPPIPX RASPPPIPXW
#else
#define	RASPPPIPX RASPPPIPXA
#endif
#define	LPRASPPPIPXW RASPPPIPXW*
#define	LPRASPPPIPXA RASPPPIPXA*
#define	LPRASPPPIPX RASPPPIPX*
#define	RASPPPIPW struct tagRASPPPIPW
RASPPPIPW {
	DWORD dwSize;
	DWORD dwError;
	WCHAR szIpAddress[ RAS_MaxIpAddress + 1 ];
	WCHAR szServerIpAddress[ RAS_MaxIpAddress + 1 ];
};
#define	RASPPPIPA struct tagRASPPPIPA
RASPPPIPA {
	DWORD dwSize;
	DWORD dwError;
	CHAR szIpAddress[ RAS_MaxIpAddress + 1 ];
	CHAR szServerIpAddress[ RAS_MaxIpAddress + 1 ];
};
#ifdef	UNICODE
#define	RASPPPIP RASPPPIPW
#else
#define	RASPPPIP RASPPPIPA
#endif
#define	LPRASPPPIPW RASPPPIPW*
#define	LPRASPPPIPA RASPPPIPA*
#define	LPRASPPPIP RASPPPIP*
#define	RASPPPLCP struct tagRASPPPLCP
RASPPPLCP {
	DWORD dwSize;
	BOOL fBundled;
};
#define	LPRASPPPLCP RASPPPLCP*
#define	RASSLIPW struct tagRASSLIPW
RASSLIPW {
	DWORD dwSize;
	DWORD dwError;
	WCHAR szIpAddress[ RAS_MaxIpAddress + 1 ];
};
#define	RASSLIPA struct tagRASSLIPA
RASSLIPA {
	DWORD dwSize;
	DWORD dwError;
	CHAR szIpAddress[ RAS_MaxIpAddress + 1 ];
};
#ifdef	UNICODE
#define	RASSLIP RASSLIPW
#else
#define	RASSLIP RASSLIPA
#endif
#define	LPRASSLIPW RASSLIPW*
#define	LPRASSLIPA RASSLIPA*
#define	LPRASSLIP RASSLIP*
#define	RASDIALEVENT "RasDialEvent"
#define	WM_RASDIALEVENT 0xCCCD
typedef	VOID (WINAPI *RASDIALFUNC)(UINT,RASCONNSTATE,DWORD);
typedef	VOID (WINAPI *RASDIALFUNC1)(HRASCONN,UINT,RASCONNSTATE,DWORD,DWORD);
typedef	DWORD (WINAPI *RASDIALFUNC2)(DWORD,DWORD,HRASCONN,UINT,RASCONNSTATE,DWORD,DWORD);
#define	RASDEVINFOW struct tagRASDEVINFOW
RASDEVINFOW {
	DWORD dwSize;
	WCHAR szDeviceType[ RAS_MaxDeviceType + 1 ];
	WCHAR szDeviceName[ RAS_MaxDeviceName + 1 ];
};
#define	RASDEVINFOA struct tagRASDEVINFOA
RASDEVINFOA {
	DWORD dwSize;
	CHAR szDeviceType[ RAS_MaxDeviceType + 1 ];
	CHAR szDeviceName[ RAS_MaxDeviceName + 1 ];
};
#ifdef	UNICODE
#define	RASDEVINFO RASDEVINFOW
#else
#define	RASDEVINFO RASDEVINFOA
#endif
#define	LPRASDEVINFOW RASDEVINFOW*
#define	LPRASDEVINFOA RASDEVINFOA*
#define	LPRASDEVINFO RASDEVINFO*
#define	RASCTRYINFO struct RASCTRYINFO
RASCTRYINFO {
	DWORD dwSize;
	DWORD dwCountryID;
	DWORD dwNextCountryID;
	DWORD dwCountryCode;
	DWORD dwCountryNameOffset;
};
#define	RASCTRYINFOW RASCTRYINFO
#define	RASCTRYINFOA RASCTRYINFO
#define	LPRASCTRYINFOW RASCTRYINFOW*
#define	LPRASCTRYINFOA RASCTRYINFOW*
#define	LPRASCTRYINFO RASCTRYINFO*
#define	RASIPADDR struct RASIPADDR
RASIPADDR {
	BYTE a;
	BYTE b;
	BYTE c;
	BYTE d;
};
#define	RASENTRYA struct tagRASENTRYA
RASENTRYA {
	DWORD dwSize;
	DWORD dwfOptions;
	DWORD dwCountryID;
	DWORD dwCountryCode;
	CHAR szAreaCode[ RAS_MaxAreaCode + 1 ];
	CHAR szLocalPhoneNumber[ RAS_MaxPhoneNumber + 1 ];
	DWORD dwAlternateOffset;
	RASIPADDR ipaddr;
	RASIPADDR ipaddrDns;
	RASIPADDR ipaddrDnsAlt;
	RASIPADDR ipaddrWins;
	RASIPADDR ipaddrWinsAlt;
	DWORD dwFrameSize;
	DWORD dwfNetProtocols;
	DWORD dwFramingProtocol;
	CHAR szScript[ MAX_PATH ];
	CHAR szAutodialDll[ MAX_PATH ];
	CHAR szAutodialFunc[ MAX_PATH ];
	CHAR szDeviceType[ RAS_MaxDeviceType + 1 ];
	CHAR szDeviceName[ RAS_MaxDeviceName + 1 ];
	CHAR szX25PadType[ RAS_MaxPadType + 1 ];
	CHAR szX25Address[ RAS_MaxX25Address + 1 ];
	CHAR szX25Facilities[ RAS_MaxFacilities + 1 ];
	CHAR szX25UserData[ RAS_MaxUserData + 1 ];
	DWORD dwChannels;
	DWORD dwReserved1;
	DWORD dwReserved2;
	DWORD dwSubEntries;
	DWORD dwDialMode;
	DWORD dwDialExtraPercent;
	DWORD dwDialExtraSampleSeconds;
	DWORD dwHangUpExtraPercent;
	DWORD dwHangUpExtraSampleSeconds;
	DWORD dwIdleDisconnectSeconds;
};
#define	RASENTRYW struct tagRASENTRYW
RASENTRYW {
	DWORD dwSize;
	DWORD dwfOptions;
	DWORD dwCountryID;
	DWORD dwCountryCode;
	WCHAR szAreaCode[ RAS_MaxAreaCode + 1 ];
	WCHAR szLocalPhoneNumber[ RAS_MaxPhoneNumber + 1 ];
	DWORD dwAlternateOffset;
	RASIPADDR ipaddr;
	RASIPADDR ipaddrDns;
	RASIPADDR ipaddrDnsAlt;
	RASIPADDR ipaddrWins;
	RASIPADDR ipaddrWinsAlt;
	DWORD dwFrameSize;
	DWORD dwfNetProtocols;
	DWORD dwFramingProtocol;
	WCHAR szScript[ MAX_PATH ];
	WCHAR szAutodialDll[ MAX_PATH ];
	WCHAR szAutodialFunc[ MAX_PATH ];
	WCHAR szDeviceType[ RAS_MaxDeviceType + 1 ];
	WCHAR szDeviceName[ RAS_MaxDeviceName + 1 ];
	WCHAR szX25PadType[ RAS_MaxPadType + 1 ];
	WCHAR szX25Address[ RAS_MaxX25Address + 1 ];
	WCHAR szX25Facilities[ RAS_MaxFacilities + 1 ];
	WCHAR szX25UserData[ RAS_MaxUserData + 1 ];
	DWORD dwChannels;
	DWORD dwReserved1;
	DWORD dwReserved2;
	DWORD dwSubEntries;
	DWORD dwDialMode;
	DWORD dwDialExtraPercent;
	DWORD dwDialExtraSampleSeconds;
	DWORD dwHangUpExtraPercent;
	DWORD dwHangUpExtraSampleSeconds;
	DWORD dwIdleDisconnectSeconds;
};
#ifdef	UNICODE
#define	RASENTRY RASENTRYW
#else
#define	RASENTRY RASENTRYA
#endif
#define	LPRASENTRYW RASENTRYW*
#define	LPRASENTRYA RASENTRYA*
#define	LPRASENTRY RASENTRY*
#define	RASEO_UseCountryAndAreaCodes 1
#define	RASEO_SpecificIpAddr 2
#define	RASEO_SpecificNameServers 4
#define	RASEO_IpHeaderCompression 8
#define	RASEO_RemoteDefaultGateway 16
#define	RASEO_DisableLcpExtensions 32
#define	RASEO_TerminalBeforeDial 64
#define	RASEO_TerminalAfterDial 0x80
#define	RASEO_ModemLights 0x100
#define	RASEO_SwCompression 0x200
#define	RASEO_RequireEncryptedPw 0x400
#define	RASEO_RequireMsEncryptedPw 0x800
#define	RASEO_RequireDataEncryption 0x1000
#define	RASEO_NetworkLogon 0x2000
#define	RASEO_UseLogonCredentials 0x4000
#define	RASEO_PromoteAlternates 0x08000
#define	RASEO_SecureLocalFiles 0x10000
#define	RASNP_NetBEUI 1
#define	RASNP_Ipx 2
#define	RASNP_Ip 4
#define	RASFP_Ppp 1
#define	RASFP_Slip 2
#define	RASFP_Ras 4
#define	RASDT_Modem TEXT("modem")
#define	RASDT_Isdn TEXT("isdn")
#define	RASDT_X25 TEXT("x25")
typedef	BOOL (WINAPI *ORASADFUNC)(HWND,LPSTR,DWORD,LPDWORD);
#define	RASCN_Connection 1
#define	RASCN_Disconnection 2
#define	RASCN_BandwidthAdded 4
#define	RASCN_BandwidthRemoved 8
#define	RASEDM_DialAll 1
#define	RASEDM_DialAsNeeded 2
#define	RASIDS_Disabled 0xffffffff
#define	RASIDS_UseGlobalValue 0
#define	RASADPARAMS struct tagRASADPARAMS
RASADPARAMS
{
	DWORD dwSize;
	HWND hwndOwner;
	DWORD dwFlags;
	LONG xDlg;
	LONG yDlg;
};
#define	LPRASADPARAMS RASADPARAMS*
#define	RASADFLG_PositionDlg 1
typedef	BOOL (WINAPI *RASADFUNCA)(LPSTR,LPSTR,LPRASADPARAMS,LPDWORD);
typedef	BOOL (WINAPI *RASADFUNCW)(LPWSTR,LPWSTR,LPRASADPARAMS,LPDWORD);
#ifdef	UNICODE
#define	RASADFUNC RASADFUNCW
#else
#define	RASADFUNC RASADFUNCA
#endif
#define	RASSUBENTRYA struct tagRASSUBENTRYA
RASSUBENTRYA
{
	DWORD dwSize;
	DWORD dwfFlags;
	CHAR szDeviceType[ RAS_MaxDeviceType + 1 ];
	CHAR szDeviceName[ RAS_MaxDeviceName + 1 ];
	CHAR szLocalPhoneNumber[ RAS_MaxPhoneNumber + 1 ];
	DWORD dwAlternateOffset;
};
#define	RASSUBENTRYW struct tagRASSUBENTRYW
RASSUBENTRYW
{
	DWORD dwSize;
	DWORD dwfFlags;
	WCHAR szDeviceType[ RAS_MaxDeviceType + 1 ];
	WCHAR szDeviceName[ RAS_MaxDeviceName + 1 ];
	WCHAR szLocalPhoneNumber[ RAS_MaxPhoneNumber + 1 ];
	DWORD dwAlternateOffset;
};
#ifdef	UNICODE
#define	RASSUBENTRY RASSUBENTRYW
#else
#define	RASSUBENTRY RASSUBENTRYA
#endif
#define	LPRASSUBENTRYW RASSUBENTRYW*
#define	LPRASSUBENTRYA RASSUBENTRYA*
#define	LPRASSUBENTRY RASSUBENTRY*
#define	RASCREDENTIALSA struct tagRASCREDENTIALSA
RASCREDENTIALSA
{
	DWORD dwSize;
	DWORD dwMask;
	CHAR szUserName[ UNLEN + 1 ];
	CHAR szPassword[ PWLEN + 1 ];
	CHAR szDomain[ DNLEN + 1 ];
};

#define	RASCREDENTIALSW struct tagRASCREDENTIALSW
RASCREDENTIALSW
{
	DWORD dwSize;
	DWORD dwMask;
	WCHAR szUserName[ UNLEN + 1 ];
	WCHAR szPassword[ PWLEN + 1 ];
	WCHAR szDomain[ DNLEN + 1 ];
};
#ifdef	UNICODE
#define	RASCREDENTIALS RASCREDENTIALSW
#else
#define	RASCREDENTIALS RASCREDENTIALSA
#endif
#define	LPRASCREDENTIALSW RASCREDENTIALSW*
#define	LPRASCREDENTIALSA RASCREDENTIALSA*
#define	LPRASCREDENTIALS RASCREDENTIALS*
#define	RASCM_UserName 1
#define	RASCM_Password 2
#define	RASCM_Domain 4
#define	RASAUTODIALENTRYA struct tagRASAUTODIALENTRYA
RASAUTODIALENTRYA
{
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwDialingLocation;
	CHAR szPhonebook[ MAX_PATH ];
	CHAR szEntry[ RAS_MaxEntryName + 1];
};

#define	RASAUTODIALENTRYW struct tagRASAUTODIALENTRYW
RASAUTODIALENTRYW
{
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwDialingLocation;
	WCHAR szPhonebook[ MAX_PATH ];
	WCHAR szEntry[ RAS_MaxEntryName + 1];
};
#ifdef	UNICODE
#define	RASAUTODIALENTRY RASAUTODIALENTRYW
#else
#define	RASAUTODIALENTRY RASAUTODIALENTRYA
#endif
#define	LPRASAUTODIALENTRYW RASAUTODIALENTRYW*
#define	LPRASAUTODIALENTRYA RASAUTODIALENTRYA*
#define	LPRASAUTODIALENTRY RASAUTODIALENTRY*
#define	RASADP_DisableConnectionQuery 0
#define	RASADP_LoginSessionDisable 1
#define	RASADP_SavedAddressesLimit 2
#define	RASADP_FailedConnectionTimeout 3
#define	RASADP_ConnectionQueryTimeout 4
DWORD	APIENTRY RasDialA(LPRASDIALEXTENSIONS,LPSTR,LPRASDIALPARAMSA,DWORD,LPVOID,LPHRASCONN);
DWORD	APIENTRY RasDialW(LPRASDIALEXTENSIONS,LPWSTR,LPRASDIALPARAMSW,DWORD,LPVOID,LPHRASCONN);
DWORD	APIENTRY RasEnumConnectionsA(LPRASCONNA,LPDWORD,LPDWORD);
DWORD	APIENTRY RasEnumConnectionsW(LPRASCONNW,LPDWORD,LPDWORD);
DWORD	APIENTRY RasEnumEntriesA(LPSTR,LPSTR,LPRASENTRYNAMEA,LPDWORD,LPDWORD);
DWORD	APIENTRY RasEnumEntriesW(LPWSTR,LPWSTR,LPRASENTRYNAMEW,LPDWORD,LPDWORD);
DWORD	APIENTRY RasGetConnectStatusA(HRASCONN,LPRASCONNSTATUSA);
DWORD	APIENTRY RasGetConnectStatusW(HRASCONN,LPRASCONNSTATUSW);
DWORD	APIENTRY RasGetErrorStringA(UINT,LPSTR,DWORD);
DWORD	APIENTRY RasGetErrorStringW(UINT,LPWSTR,DWORD);
DWORD	APIENTRY RasHangUpA(HRASCONN);
DWORD	APIENTRY RasHangUpW(HRASCONN);
DWORD	APIENTRY RasGetProjectionInfoA(HRASCONN,RASPROJECTION,LPVOID,LPDWORD);
DWORD	APIENTRY RasGetProjectionInfoW(HRASCONN,RASPROJECTION,LPVOID,LPDWORD);
DWORD	APIENTRY RasCreatePhonebookEntryA(HWND,LPSTR);
DWORD	APIENTRY RasCreatePhonebookEntryW(HWND,LPWSTR);
DWORD	APIENTRY RasEditPhonebookEntryA(HWND,LPSTR,LPSTR);
DWORD	APIENTRY RasEditPhonebookEntryW(HWND,LPWSTR,LPWSTR);
DWORD	APIENTRY RasSetEntryDialParamsA(LPSTR,LPRASDIALPARAMSA,BOOL);
DWORD	APIENTRY RasSetEntryDialParamsW(LPWSTR,LPRASDIALPARAMSW,BOOL);
DWORD	APIENTRY RasGetEntryDialParamsA(LPSTR,LPRASDIALPARAMSA,LPBOOL);
DWORD	APIENTRY RasGetEntryDialParamsW(LPWSTR,LPRASDIALPARAMSW,LPBOOL);
DWORD	APIENTRY RasEnumDevicesA(LPRASDEVINFOA,LPDWORD,LPDWORD);
DWORD	APIENTRY RasEnumDevicesW(LPRASDEVINFOW,LPDWORD,LPDWORD);
DWORD	APIENTRY RasGetCountryInfoA(LPRASCTRYINFOA,LPDWORD);
DWORD	APIENTRY RasGetCountryInfoW(LPRASCTRYINFOW,LPDWORD);
DWORD	APIENTRY RasGetEntryPropertiesA(LPSTR,LPSTR,LPRASENTRYA,LPDWORD,LPBYTE,LPDWORD);
DWORD	APIENTRY RasGetEntryPropertiesW(LPWSTR,LPWSTR,LPRASENTRYW,LPDWORD,LPBYTE,LPDWORD);
DWORD	APIENTRY RasSetEntryPropertiesA(LPSTR,LPSTR,LPRASENTRYA,DWORD,LPBYTE,DWORD);
DWORD	APIENTRY RasSetEntryPropertiesW(LPWSTR,LPWSTR,LPRASENTRYW,DWORD,LPBYTE,DWORD);
DWORD	APIENTRY RasRenameEntryA(LPSTR,LPSTR,LPSTR);
DWORD	APIENTRY RasRenameEntryW(LPWSTR,LPWSTR,LPWSTR);
DWORD	APIENTRY RasDeleteEntryA(LPSTR,LPSTR);
DWORD	APIENTRY RasDeleteEntryW(LPWSTR,LPWSTR);
DWORD	APIENTRY RasValidateEntryNameA(LPSTR,LPSTR);
DWORD	APIENTRY RasValidateEntryNameW(LPWSTR,LPWSTR);
DWORD	APIENTRY RasGetSubEntryHandleA(HRASCONN,DWORD,LPHRASCONN);
DWORD	APIENTRY RasGetSubEntryHandleW(HRASCONN,DWORD,LPHRASCONN);
DWORD	APIENTRY RasGetCredentialsA(LPSTR,LPSTR,LPRASCREDENTIALSA);
DWORD	APIENTRY RasGetCredentialsW(LPWSTR,LPWSTR,LPRASCREDENTIALSW);
DWORD	APIENTRY RasSetCredentialsA(LPSTR,LPSTR,LPRASCREDENTIALSA,BOOL);
DWORD	APIENTRY RasSetCredentialsW(LPWSTR,LPWSTR,LPRASCREDENTIALSW,BOOL);
DWORD	APIENTRY RasConnectionNotificationA(HRASCONN,HANDLE,DWORD);
DWORD	APIENTRY RasConnectionNotificationW(HRASCONN,HANDLE,DWORD);
DWORD	APIENTRY RasGetSubEntryPropertiesA(LPSTR,LPSTR,DWORD,LPRASSUBENTRYA,LPDWORD,LPBYTE,LPDWORD);
DWORD	APIENTRY RasGetSubEntryPropertiesW(LPWSTR,LPWSTR,DWORD,LPRASSUBENTRYW,LPDWORD,LPBYTE,LPDWORD);
DWORD	APIENTRY RasSetSubEntryPropertiesA(LPSTR,LPSTR,DWORD,LPRASSUBENTRYA,DWORD,LPBYTE,DWORD);
DWORD	APIENTRY RasSetSubEntryPropertiesW(LPWSTR,LPWSTR,DWORD,LPRASSUBENTRYW,DWORD,LPBYTE,DWORD);
DWORD	APIENTRY RasGetAutodialAddressA(LPSTR,LPDWORD,LPRASAUTODIALENTRYA,LPDWORD,LPDWORD);
DWORD	APIENTRY RasGetAutodialAddressW(LPWSTR,LPDWORD,LPRASAUTODIALENTRYW,LPDWORD,LPDWORD);
DWORD	APIENTRY RasSetAutodialAddressA(LPSTR,DWORD,LPRASAUTODIALENTRYA,DWORD,DWORD);
DWORD	APIENTRY RasSetAutodialAddressW(LPWSTR,DWORD,LPRASAUTODIALENTRYW,DWORD,DWORD);
DWORD	APIENTRY RasEnumAutodialAddressesA(LPSTR *,LPDWORD,LPDWORD);
DWORD	APIENTRY RasEnumAutodialAddressesW(LPWSTR *,LPDWORD,LPDWORD);
DWORD	APIENTRY RasGetAutodialEnableA(DWORD,LPBOOL);
DWORD	APIENTRY RasGetAutodialEnableW(DWORD,LPBOOL);
DWORD	APIENTRY RasSetAutodialEnableA(DWORD,BOOL);
DWORD	APIENTRY RasSetAutodialEnableW(DWORD,BOOL);
DWORD	APIENTRY RasGetAutodialParamA(DWORD,LPVOID,LPDWORD);
DWORD	APIENTRY RasGetAutodialParamW(DWORD,LPVOID,LPDWORD);
DWORD	APIENTRY RasSetAutodialParamA(DWORD,LPVOID,DWORD);
DWORD	APIENTRY RasSetAutodialParamW(DWORD,LPVOID,DWORD);
#ifdef	UNICODE
#define	RasDial RasDialW
#define	RasEnumConnections RasEnumConnectionsW
#define	RasEnumEntries RasEnumEntriesW
#define	RasGetConnectStatus RasGetConnectStatusW
#define	RasGetErrorString RasGetErrorStringW
#define	RasHangUp RasHangUpW
#define	RasGetProjectionInfo RasGetProjectionInfoW
#define	RasCreatePhonebookEntry RasCreatePhonebookEntryW
#define	RasEditPhonebookEntry RasEditPhonebookEntryW
#define	RasSetEntryDialParams RasSetEntryDialParamsW
#define	RasGetEntryDialParams RasGetEntryDialParamsW
#define	RasEnumDevices RasEnumDevicesW
#define	RasGetCountryInfo RasGetCountryInfoW
#define	RasGetEntryProperties RasGetEntryPropertiesW
#define	RasSetEntryProperties RasSetEntryPropertiesW
#define	RasRenameEntry RasRenameEntryW
#define	RasDeleteEntry RasDeleteEntryW
#define	RasValidateEntryName RasValidateEntryNameW
#define	RasGetSubEntryHandle RasGetSubEntryHandleW
#define	RasConnectionNotification RasConnectionNotificationW
#define	RasGetSubEntryProperties RasGetSubEntryPropertiesW
#define	RasSetSubEntryProperties RasSetSubEntryPropertiesW
#define	RasGetCredentials RasGetCredentialsW
#define	RasSetCredentials RasSetCredentialsW
#define	RasGetAutodialAddress RasGetAutodialAddressW
#define	RasSetAutodialAddress RasSetAutodialAddressW
#define	RasEnumAutodialAddresses RasEnumAutodialAddressesW
#define	RasGetAutodialEnable RasGetAutodialEnableW
#define	RasSetAutodialEnable RasSetAutodialEnableW
#define	RasGetAutodialParam RasGetAutodialParamW
#define	RasSetAutodialParam RasSetAutodialParamW
#else
#define	RasDial RasDialA
#define	RasEnumConnections RasEnumConnectionsA
#define	RasEnumEntries RasEnumEntriesA
#define	RasGetConnectStatus RasGetConnectStatusA
#define	RasGetErrorString RasGetErrorStringA
#define	RasHangUp RasHangUpA
#define	RasGetProjectionInfo RasGetProjectionInfoA
#define	RasCreatePhonebookEntry RasCreatePhonebookEntryA
#define	RasEditPhonebookEntry RasEditPhonebookEntryA
#define	RasSetEntryDialParams RasSetEntryDialParamsA
#define	RasGetEntryDialParams RasGetEntryDialParamsA
#define	RasEnumDevices RasEnumDevicesA
#define	RasGetCountryInfo RasGetCountryInfoA
#define	RasGetEntryProperties RasGetEntryPropertiesA
#define	RasSetEntryProperties RasSetEntryPropertiesA
#define	RasRenameEntry RasRenameEntryA
#define	RasDeleteEntry RasDeleteEntryA
#define	RasValidateEntryName RasValidateEntryNameA
#define	RasGetSubEntryHandle RasGetSubEntryHandleA
#define	RasConnectionNotification RasConnectionNotificationA
#define	RasGetSubEntryProperties RasGetSubEntryPropertiesA
#define	RasSetSubEntryProperties RasSetSubEntryPropertiesA
#define	RasGetCredentials RasGetCredentialsA
#define	RasSetCredentials RasSetCredentialsA
#define	RasGetAutodialAddress RasGetAutodialAddressA
#define	RasSetAutodialAddress RasSetAutodialAddressA
#define	RasEnumAutodialAddresses RasEnumAutodialAddressesA
#define	RasGetAutodialEnable RasGetAutodialEnableA
#define	RasSetAutodialEnable RasSetAutodialEnableA
#define	RasGetAutodialParam RasGetAutodialParamA
#define	RasSetAutodialParam RasSetAutodialParamA
#endif
#pragma	pack(pop)
#endif
