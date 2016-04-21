/* $Revision: 1.2 $ */
#ifndef	_LCC_WINSOCK2API_
#define	_LCC_WINSOCK2API_
#define	_WINSOCK
#ifndef	_GNU_H_WIN32Headers
#include	<windows.h>
#endif
#pragma pack(push,4)
#define	WINSOCK_API_LINKAGE
typedef	unsigned char u_char;
typedef	unsigned short u_short;
typedef	unsigned int u_int;
typedef	unsigned long u_long;
typedef	u_int SOCKET;
#ifndef	FD_SETSIZE
#define	FD_SETSIZE 64
#endif
typedef	struct fd_set { u_int fd_count; SOCKET fd_array[FD_SETSIZE];} fd_set;
extern	int PASCAL __WSAFDIsSet(SOCKET,fd_set *);
#define	FD_CLR(fd,set) do { \
	u_int __i; \
	for (__i = 0; __i < ((fd_set *)(set))->fd_count ; __i++) { \
	if (((fd_set *)(set))->fd_array[__i] == fd) { \
	while (__i < ((fd_set *)(set))->fd_count-1) { \
	((fd_set *)(set))->fd_array[__i] = \
	((fd_set *)(set))->fd_array[__i+1]; \
	__i++; \
	} \
	((fd_set *)(set))->fd_count--; \
	break; \
	} \
	} \
}	while(0)
#define	FD_SET(fd,set) do { \
	u_int __i; \
	for (__i = 0; __i < ((fd_set *)(set))->fd_count; __i++) { \
	if (((fd_set *)(set))->fd_array[__i] == (fd)) { \
	break; \
	} \
	} \
	if (__i == ((fd_set *)(set))->fd_count) { \
	if (((fd_set *)(set))->fd_count < FD_SETSIZE) { \
	((fd_set *)(set))->fd_array[__i] = (fd); \
	((fd_set *)(set))->fd_count++; \
	} \
	} \
}	while(0)
#define	FD_ZERO(set) (((fd_set *)(set))->fd_count=0)
#define	FD_ISSET(fd,set) __WSAFDIsSet((SOCKET)(fd),(fd_set *)(set))
struct	timeval {
	long tv_sec;
	long tv_usec;
};
#define	timerisset(tvp) ((tvp)->tv_sec || (tvp)->tv_usec)
#define	timercmp(tvp,uvp,cmp) \
	((tvp)->tv_sec cmp (uvp)->tv_sec || \
	(tvp)->tv_sec == (uvp)->tv_sec && (tvp)->tv_usec cmp (uvp)->tv_usec)
#define	timerclear(tvp) (tvp)->tv_sec = (tvp)->tv_usec = 0
#define	IOCPARM_MASK 0x7f
#define	IOC_VOID 0x20000000
#define	IOC_OUT 0x40000000
#define	IOC_IN 0x80000000
#define	IOC_INOUT (IOC_IN|IOC_OUT)
#define	_IO(x,y) (IOC_VOID|((x)<<8)|(y))
#define	_IOR(x,y,t) (IOC_OUT|(((long)sizeof(t)&IOCPARM_MASK)<<16)|((x)<<8)|(y))
#define	_IOW(x,y,t) (IOC_IN|(((long)sizeof(t)&IOCPARM_MASK)<<16)|((x)<<8)|(y))
#define	FIONREAD _IOR('f',127,u_long)
#define	FIONBIO _IOW('f',126,u_long)
#define	FIOASYNC _IOW('f',125,u_long)
#define	SIOCSHIWAT _IOW('s',0,u_long)
#define	SIOCGHIWAT _IOR('s',1,u_long)
#define	SIOCSLOWAT _IOW('s',2,u_long)
#define	SIOCGLOWAT _IOR('s',3,u_long)
#define	SIOCATMARK _IOR('s',7,u_long)
struct	hostent {
	char * h_name;
	char * * h_aliases;
	short h_addrtype;
	short h_length;
	char * * h_addr_list;
#define	h_addr h_addr_list[0]
};
struct	netent { char *n_name; char **n_aliases; short n_addrtype; u_long n_net;};
struct	servent { char *s_name; char **s_aliases; short s_port; char * s_proto; };
struct	protoent { char *p_name; char **p_aliases; short p_proto; };
#define	IPPROTO_IP 0
#define	IPPROTO_ICMP 1 
#define	IPPROTO_IGMP 2 
#define	IPPROTO_GGP 3 
#define	IPPROTO_TCP 6 
#define	IPPROTO_PUP 12 
#define	IPPROTO_UDP 17 
#define	IPPROTO_IDP 22 
#define	IPPROTO_ND 77 
#define	IPPROTO_RAW 255 
#define	IPPROTO_MAX 256
#define	IPPORT_ECHO 7
#define	IPPORT_DISCARD 9
#define	IPPORT_SYSTAT 11
#define	IPPORT_DAYTIME 13
#define	IPPORT_NETSTAT 15
#define	IPPORT_FTP 21
#define	IPPORT_TELNET 23
#define	IPPORT_SMTP 25
#define	IPPORT_TIMESERVER 37
#define	IPPORT_NAMESERVER 42
#define	IPPORT_WHOIS 43
#define	IPPORT_MTP 57
#define	IPPORT_TFTP 69
#define	IPPORT_RJE 77
#define	IPPORT_FINGER 79
#define	IPPORT_TTYLINK 87
#define	IPPORT_SUPDUP 95
#define	IPPORT_EXECSERVER 512
#define	IPPORT_LOGINSERVER 513
#define	IPPORT_CMDSERVER 514
#define	IPPORT_EFSSERVER 520
#define	IPPORT_BIFFUDP 512
#define	IPPORT_WHOSERVER 513
#define	IPPORT_ROUTESERVER 520
#define	IPPORT_RESERVED 1024
#define	IMPLINK_IP 155
#define	IMPLINK_LOWEXPER 156
#define	IMPLINK_HIGHEXPER 158
struct	in_addr {
	union {
	struct { u_char s_b1,s_b2,s_b3,s_b4; } S_un_b;
	struct { u_short s_w1,s_w2; } S_un_w;
	u_long S_addr;
	} S_un;
#define	s_addr S_un.S_addr
#define	s_host S_un.S_un_b.s_b2
#define	s_net S_un.S_un_b.s_b1
#define	s_imp S_un.S_un_w.s_w2
#define	s_impno S_un.S_un_b.s_b4
#define	s_lh S_un.S_un_b.s_b3
};
#define	IN_CLASSA(i) (((long)(i) & 0x80000000) == 0)
#define	IN_CLASSA_NET 0xff000000
#define	IN_CLASSA_NSHIFT 24
#define	IN_CLASSA_HOST 0x00ffffff
#define	IN_CLASSA_MAX 128
#define	IN_CLASSB(i) (((long)(i) & 0xc0000000) == 0x80000000)
#define	IN_CLASSB_NET 0xffff0000
#define	IN_CLASSB_NSHIFT 16
#define	IN_CLASSB_HOST 0x0000ffff
#define	IN_CLASSB_MAX 65536
#define	IN_CLASSC(i) (((long)(i) & 0xe0000000) == 0xc0000000)
#define	IN_CLASSC_NET 0xffffff00
#define	IN_CLASSC_NSHIFT 8
#define	IN_CLASSC_HOST 0x000000ff
#define	IN_CLASSD(i) (((long)(i) & 0xf0000000) == 0xe0000000)
#define	IN_CLASSD_NET 0xf0000000 
#define	IN_CLASSD_NSHIFT 28 
#define	IN_CLASSD_HOST 0x0fffffff 
#define	IN_MULTICAST(i) IN_CLASSD(i)
#define	INADDR_ANY (u_long)0x00000000
#define	INADDR_LOOPBACK 0x7f000001
#define	INADDR_BROADCAST (u_long)0xffffffff
#define	INADDR_NONE 0xffffffff
#define	ADDR_ANY INADDR_ANY
struct	sockaddr_in { short sin_family; u_short sin_port; struct in_addr sin_addr; char sin_zero[8]; };
#define	WSADESCRIPTION_LEN 256
#define	WSASYS_STATUS_LEN 128
typedef	struct WSAData {
	WORD wVersion;
	WORD wHighVersion;
	char szDescription[WSADESCRIPTION_LEN+1];
	char szSystemStatus[WSASYS_STATUS_LEN+1];
	unsigned short iMaxSockets;
	unsigned short iMaxUdpDg;
	char * lpVendorInfo;
}	WSADATA,* LPWSADATA;
#if	!defined(MAKEWORD)
#define	MAKEWORD(low,high) \
	((WORD)((BYTE)(low)) | (((WORD)(BYTE)(high))<<8)))
#endif
#define	INVALID_SOCKET (SOCKET)(~0)
#define	SOCKET_ERROR (-1)
#define	FROM_PROTOCOL_INFO (-1)
#define	SOCK_STREAM 1 
#define	SOCK_DGRAM 2 
#define	SOCK_RAW 3 
#define	SOCK_RDM 4 
#define	SOCK_SEQPACKET 5 
#define	SO_DEBUG 1 
#define	SO_ACCEPTCONN 2 
#define	SO_REUSEADDR 4 
#define	SO_KEEPALIVE 8 
#define	SO_DONTROUTE 16 
#define	SO_BROADCAST 0x20 
#define	SO_USELOOPBACK 0x40 
#define	SO_LINGER 0x80 
#define	SO_OOBINLINE 0x100 
#define	SO_DONTLINGER (int)(~SO_LINGER)
#define	SO_SNDBUF 0x1001 
#define	SO_RCVBUF 0x1002 
#define	SO_SNDLOWAT 0x1003 
#define	SO_RCVLOWAT 0x1004 
#define	SO_SNDTIMEO 0x1005 
#define	SO_RCVTIMEO 0x1006 
#define	SO_ERROR 0x1007 
#define	SO_TYPE 0x1008 
#define	SO_GROUP_ID 0x2001 
#define	SO_GROUP_PRIORITY 0x2002 
#define	SO_MAX_MSG_SIZE 0x2003 
#define	SO_PROTOCOL_INFOA 0x2004 
#define	SO_PROTOCOL_INFOW 0x2005 
#ifdef	UNICODE
#define	SO_PROTOCOL_INFO SO_PROTOCOL_INFOW
#else
#define	SO_PROTOCOL_INFO SO_PROTOCOL_INFOA
#endif	
#define	PVD_CONFIG 0x3001 
#define	TCP_NODELAY 1
#define	AF_UNSPEC 0 
#define	AF_UNIX 1 
#define	AF_INET 2 
#define	AF_IMPLINK 3 
#define	AF_PUP 4 
#define	AF_CHAOS 5 
#define	AF_NS 6 
#define	AF_IPX AF_NS 
#define	AF_ISO 7 
#define	AF_OSI AF_ISO 
#define	AF_ECMA 8 
#define	AF_DATAKIT 9 
#define	AF_CCITT 10 
#define	AF_SNA 11 
#define	AF_DECnet 12 
#define	AF_DLI 13 
#define	AF_LAT 14 
#define	AF_HYLINK 15 
#define	AF_APPLETALK 16 
#define	AF_NETBIOS 17 
#define	AF_VOICEVIEW 18 
#define	AF_FIREFOX 19 
#define	AF_UNKNOWN1 20 
#define	AF_BAN 21 
#define	AF_ATM 22 
#define	AF_INET6 23 
#define	AF_MAX 24
struct	sockaddr { u_short sa_family; char sa_data[14];};
struct	sockproto { u_short sp_family; u_short sp_protocol;};
#define	PF_UNSPEC AF_UNSPEC
#define	PF_UNIX AF_UNIX
#define	PF_INET AF_INET
#define	PF_IMPLINK AF_IMPLINK
#define	PF_PUP AF_PUP
#define	PF_CHAOS AF_CHAOS
#define	PF_NS AF_NS
#define	PF_IPX AF_IPX
#define	PF_ISO AF_ISO
#define	PF_OSI AF_OSI
#define	PF_ECMA AF_ECMA
#define	PF_DATAKIT AF_DATAKIT
#define	PF_CCITT AF_CCITT
#define	PF_SNA AF_SNA
#define	PF_DECnet AF_DECnet
#define	PF_DLI AF_DLI
#define	PF_LAT AF_LAT
#define	PF_HYLINK AF_HYLINK
#define	PF_APPLETALK AF_APPLETALK
#define	PF_VOICEVIEW AF_VOICEVIEW
#define	PF_FIREFOX AF_FIREFOX
#define	PF_UNKNOWN1 AF_UNKNOWN1
#define	PF_BAN AF_BAN
#define	PF_ATM AF_ATM
#define	PF_INET6 AF_INET6
#define	PF_MAX AF_MAX
struct	linger { u_short l_onoff; u_short l_linger;};
#define	SOL_SOCKET 0xffff 
#define	SOMAXCONN 0x7fffffff
#define	MSG_OOB 0x1 
#define	MSG_PEEK 0x2 
#define	MSG_DONTROUTE 0x4 
#define	MSG_PARTIAL 0x8000 
#define	MSG_INTERRUPT 0x10 
#define	MSG_MAXIOVLEN 16
#define	MAXGETHOSTSTRUCT 1024
#define	FD_READ_BIT 0
#define	FD_READ (1 << FD_READ_BIT)
#define	FD_WRITE_BIT 1
#define	FD_WRITE (1 << FD_WRITE_BIT)
#define	FD_OOB_BIT 2
#define	FD_OOB (1 << FD_OOB_BIT)
#define	FD_ACCEPT_BIT 3
#define	FD_ACCEPT (1 << FD_ACCEPT_BIT)
#define	FD_CONNECT_BIT 4
#define	FD_CONNECT (1 << FD_CONNECT_BIT)
#define	FD_CLOSE_BIT 5
#define	FD_CLOSE (1 << FD_CLOSE_BIT)
#define	FD_QOS_BIT 6
#define	FD_QOS (1 << FD_QOS_BIT)
#define	FD_GROUP_QOS_BIT 7
#define	FD_GROUP_QOS (1 << FD_GROUP_QOS_BIT)
#define	FD_MAX_EVENTS 8
#define	FD_ALL_EVENTS ((1 << FD_MAX_EVENTS) - 1)
#define	WSABASEERR 10000
#define	WSAEINTR (WSABASEERR+4)
#define	WSAEBADF (WSABASEERR+9)
#define	WSAEACCES (WSABASEERR+13)
#define	WSAEFAULT (WSABASEERR+14)
#define	WSAEINVAL (WSABASEERR+22)
#define	WSAEMFILE (WSABASEERR+24)
#define	WSAEWOULDBLOCK (WSABASEERR+35)
#define	WSAEINPROGRESS (WSABASEERR+36)
#define	WSAEALREADY (WSABASEERR+37)
#define	WSAENOTSOCK (WSABASEERR+38)
#define	WSAEDESTADDRREQ (WSABASEERR+39)
#define	WSAEMSGSIZE (WSABASEERR+40)
#define	WSAEPROTOTYPE (WSABASEERR+41)
#define	WSAENOPROTOOPT (WSABASEERR+42)
#define	WSAEPROTONOSUPPORT (WSABASEERR+43)
#define	WSAESOCKTNOSUPPORT (WSABASEERR+44)
#define	WSAEOPNOTSUPP (WSABASEERR+45)
#define	WSAEPFNOSUPPORT (WSABASEERR+46)
#define	WSAEAFNOSUPPORT (WSABASEERR+47)
#define	WSAEADDRINUSE (WSABASEERR+48)
#define	WSAEADDRNOTAVAIL (WSABASEERR+49)
#define	WSAENETDOWN (WSABASEERR+50)
#define	WSAENETUNREACH (WSABASEERR+51)
#define	WSAENETRESET (WSABASEERR+52)
#define	WSAECONNABORTED (WSABASEERR+53)
#define	WSAECONNRESET (WSABASEERR+54)
#define	WSAENOBUFS (WSABASEERR+55)
#define	WSAEISCONN (WSABASEERR+56)
#define	WSAENOTCONN (WSABASEERR+57)
#define	WSAESHUTDOWN (WSABASEERR+58)
#define	WSAETOOMANYREFS (WSABASEERR+59)
#define	WSAETIMEDOUT (WSABASEERR+60)
#define	WSAECONNREFUSED (WSABASEERR+61)
#define	WSAELOOP (WSABASEERR+62)
#define	WSAENAMETOOLONG (WSABASEERR+63)
#define	WSAEHOSTDOWN (WSABASEERR+64)
#define	WSAEHOSTUNREACH (WSABASEERR+65)
#define	WSAENOTEMPTY (WSABASEERR+66)
#define	WSAEPROCLIM (WSABASEERR+67)
#define	WSAEUSERS (WSABASEERR+68)
#define	WSAEDQUOT (WSABASEERR+69)
#define	WSAESTALE (WSABASEERR+70)
#define	WSAEREMOTE (WSABASEERR+71)
#define	WSASYSNOTREADY (WSABASEERR+91)
#define	WSAVERNOTSUPPORTED (WSABASEERR+92)
#define	WSANOTINITIALISED (WSABASEERR+93)
#define	WSAEDISCON (WSABASEERR+101)
#define	WSAENOMORE (WSABASEERR+102)
#define	WSAECANCELLED (WSABASEERR+103)
#define	WSAEINVALIDPROCTABLE (WSABASEERR+104)
#define	WSAEINVALIDPROVIDER (WSABASEERR+105)
#define	WSAEPROVIDERFAILEDINIT (WSABASEERR+106)
#define	WSASYSCALLFAILURE (WSABASEERR+107)
#define	WSASERVICE_NOT_FOUND (WSABASEERR+108)
#define	WSATYPE_NOT_FOUND (WSABASEERR+109)
#define	WSA_E_NO_MORE (WSABASEERR+110)
#define	WSA_E_CANCELLED (WSABASEERR+111)
#define	WSAEREFUSED (WSABASEERR+112)
#define	h_errno WSAGetLastError()
#define	WSAHOST_NOT_FOUND (WSABASEERR+1001)
#define	HOST_NOT_FOUND WSAHOST_NOT_FOUND
#define	WSATRY_AGAIN (WSABASEERR+1002)
#define	TRY_AGAIN WSATRY_AGAIN
#define	WSANO_RECOVERY (WSABASEERR+1003)
#define	NO_RECOVERY WSANO_RECOVERY
#define	WSANO_DATA (WSABASEERR+1004)
#define	NO_DATA WSANO_DATA
#define	WSANO_ADDRESS WSANO_DATA
#define	NO_ADDRESS WSANO_ADDRESS
#define	WSAAPI PASCAL
#define	WSAEVENT HANDLE
#define	LPWSAEVENT LPHANDLE
#define	WSAOVERLAPPED OVERLAPPED
typedef	struct _OVERLAPPED * LPWSAOVERLAPPED;
#define	WSA_IO_PENDING (ERROR_IO_PENDING)
#define	WSA_IO_INCOMPLETE (ERROR_IO_INCOMPLETE)
#define	WSA_INVALID_HANDLE (ERROR_INVALID_HANDLE)
#define	WSA_INVALID_PARAMETER (ERROR_INVALID_PARAMETER)
#define	WSA_NOT_ENOUGH_MEMORY (ERROR_NOT_ENOUGH_MEMORY)
#define	WSA_OPERATION_ABORTED (ERROR_OPERATION_ABORTED)
#define	WSA_INVALID_EVENT ((WSAEVENT)NULL)
#define	WSA_MAXIMUM_WAIT_EVENTS (MAXIMUM_WAIT_OBJECTS)
#define	WSA_WAIT_FAILED ((DWORD)-1L)
#define	WSA_WAIT_EVENT_0 (WAIT_OBJECT_0)
#define	WSA_WAIT_IO_COMPLETION (WAIT_IO_COMPLETION)
#define	WSA_WAIT_TIMEOUT (WAIT_TIMEOUT)
#define	WSA_INFINITE (INFINITE)
typedef	struct _WSABUF { u_long len; char *buf; } WSABUF,* LPWSABUF;
typedef	enum { BestEffortService,ControlledLoadService,PredictiveService,
	GuaranteedDelayService,GuaranteedService } GUARANTEE;
typedef	long int32;
typedef	struct _flowspec {
	int32 TokenRate; 
	int32 TokenBucketSize; 
	int32 PeakBandwidth; 
	int32 Latency; 
	int32 DelayVariation; 
	GUARANTEE LevelOfGuarantee; 
	int32 CostOfCall; 
	int32 NetworkAvailability; 
}	FLOWSPEC,* LPFLOWSPEC;
typedef	struct _QualityOfService {
	FLOWSPEC SendingFlowspec; 
	FLOWSPEC ReceivingFlowspec; 
	WSABUF ProviderSpecific; 
}	QOS,* LPQOS;
#define	CF_ACCEPT 0
#define	CF_REJECT 1
#define	CF_DEFER 2
#define	SD_RECEIVE 0
#define	SD_SEND 1
#define	SD_BOTH 2
typedef	unsigned int GROUP;
#define	SG_UNCONSTRAINED_GROUP 0x01
#define	SG_CONSTRAINED_GROUP 0x02
typedef	struct _WSANETWORKEVENTS { long lNetworkEvents; int iErrorCode[FD_MAX_EVENTS];
}	WSANETWORKEVENTS,* LPWSANETWORKEVENTS;
#ifndef	GUID_DEFINED
#define	GUID_DEFINED
typedef	struct _GUID {
	unsigned long Data1;
	unsigned short Data2;
	unsigned short Data3;
	unsigned char Data4[8];
}	GUID;
typedef	GUID *LPGUID;
#endif
#define	MAX_PROTOCOL_CHAIN 7
#define	BASE_PROTOCOL 1
#define	LAYERED_PROTOCOL 0
typedef	struct _WSAPROTOCOLCHAIN {
	int ChainLen; 
	DWORD ChainEntries[MAX_PROTOCOL_CHAIN]; 
}	WSAPROTOCOLCHAIN,* LPWSAPROTOCOLCHAIN;
#define	WSAPROTOCOL_LEN 255
typedef	struct _WSAPROTOCOL_INFOA {
	DWORD dwServiceFlags1;
	DWORD dwServiceFlags2;
	DWORD dwServiceFlags3;
	DWORD dwServiceFlags4;
	DWORD dwProviderFlags;
	GUID ProviderId;
	DWORD dwCatalogEntryId;
	WSAPROTOCOLCHAIN ProtocolChain;
	int iVersion;
	int iAddressFamily;
	int iMaxSockAddr;
	int iMinSockAddr;
	int iSocketType;
	int iProtocol;
	int iProtocolMaxOffset;
	int iNetworkByteOrder;
	int iSecurityScheme;
	DWORD dwMessageSize;
	DWORD dwProviderReserved;
	CHAR szProtocol[WSAPROTOCOL_LEN+1];
}	WSAPROTOCOL_INFOA,* LPWSAPROTOCOL_INFOA;
typedef	struct _WSAPROTOCOL_INFOW {
	DWORD dwServiceFlags1;
	DWORD dwServiceFlags2;
	DWORD dwServiceFlags3;
	DWORD dwServiceFlags4;
	DWORD dwProviderFlags;
	GUID ProviderId;
	DWORD dwCatalogEntryId;
	WSAPROTOCOLCHAIN ProtocolChain;
	int iVersion;
	int iAddressFamily;
	int iMaxSockAddr;
	int iMinSockAddr;
	int iSocketType;
	int iProtocol;
	int iProtocolMaxOffset;
	int iNetworkByteOrder;
	int iSecurityScheme;
	DWORD dwMessageSize;
	DWORD dwProviderReserved;
	WCHAR szProtocol[WSAPROTOCOL_LEN+1];
}	WSAPROTOCOL_INFOW,* LPWSAPROTOCOL_INFOW;
#ifdef	UNICODE
typedef	WSAPROTOCOL_INFOW WSAPROTOCOL_INFO;
typedef	LPWSAPROTOCOL_INFOW LPWSAPROTOCOL_INFO;
#else
typedef	WSAPROTOCOL_INFOA WSAPROTOCOL_INFO;
typedef	LPWSAPROTOCOL_INFOA LPWSAPROTOCOL_INFO;
#endif
#define	PFL_MULTIPLE_PROTO_ENTRIES 1
#define	PFL_RECOMMENDED_PROTO_ENTRY 2
#define	PFL_HIDDEN 0x00000004
#define	PFL_MATCHES_PROTOCOL_ZERO 8
#define	XP1_CONNECTIONLESS 1
#define	XP1_GUARANTEED_DELIVERY 2
#define	XP1_GUARANTEED_ORDER 4
#define	XP1_MESSAGE_ORIENTED 8
#define	XP1_PSEUDO_STREAM 0x10
#define	XP1_GRACEFUL_CLOSE 0x20
#define	XP1_EXPEDITED_DATA 0x40
#define	XP1_CONNECT_DATA 0x080
#define	XP1_DISCONNECT_DATA 0x0100
#define	XP1_SUPPORT_BROADCAST 0x200
#define	XP1_SUPPORT_MULTIPOINT 0x400
#define	XP1_MULTIPOINT_CONTROL_PLANE 0x800
#define	XP1_MULTIPOINT_DATA_PLANE 0x1000
#define	XP1_QOS_SUPPORTED 0x2000
#define	XP1_INTERRUPT 0x4000
#define	XP1_UNI_SEND 0x8000
#define	XP1_UNI_RECV 0x10000
#define	XP1_IFS_HANDLES 0x20000
#define	XP1_PARTIAL_MESSAGE 0x40000
#define	BIGENDIAN 0
#define	LITTLEENDIAN 1
#define	SECURITY_PROTOCOL_NONE 0
#define	JL_SENDER_ONLY 1
#define	JL_RECEIVER_ONLY 2
#define	JL_BOTH 4
#define	WSA_FLAG_OVERLAPPED 1
#define	WSA_FLAG_MULTIPOINT_C_ROOT 2
#define	WSA_FLAG_MULTIPOINT_C_LEAF 4
#define	WSA_FLAG_MULTIPOINT_D_ROOT 8
#define	WSA_FLAG_MULTIPOINT_D_LEAF 16
#define	IOC_UNIX 0
#define	IOC_WS2 0x08000000
#define	IOC_PROTOCOL 0x10000000
#define	IOC_VENDOR 0x18000000
#define	_WSAIO(x,y) (IOC_VOID|(x)|(y))
#define	_WSAIOR(x,y) (IOC_OUT|(x)|(y))
#define	_WSAIOW(x,y) (IOC_IN|(x)|(y))
#define	_WSAIORW(x,y) (IOC_INOUT|(x)|(y))
#define	SIO_ASSOCIATE_HANDLE _WSAIOW(IOC_WS2,1)
#define	SIO_ENABLE_CIRCULAR_QUEUEING _WSAIO(IOC_WS2,2)
#define	SIO_FIND_ROUTE _WSAIOR(IOC_WS2,3)
#define	SIO_FLUSH _WSAIO(IOC_WS2,4)
#define	SIO_GET_BROADCAST_ADDRESS _WSAIOR(IOC_WS2,5)
#define	SIO_GET_EXTENSION_FUNCTION_POINTER _WSAIORW(IOC_WS2,6)
#define	SIO_GET_QOS _WSAIORW(IOC_WS2,7)
#define	SIO_GET_GROUP_QOS _WSAIORW(IOC_WS2,8)
#define	SIO_MULTIPOINT_LOOPBACK _WSAIOW(IOC_WS2,9)
#define	SIO_MULTICAST_SCOPE _WSAIOW(IOC_WS2,10)
#define	SIO_SET_QOS _WSAIOW(IOC_WS2,11)
#define	SIO_SET_GROUP_QOS _WSAIOW(IOC_WS2,12)
#define	SIO_TRANSLATE_HANDLE _WSAIORW(IOC_WS2,13)
#define	TH_NETDEV 1
#define	TH_TAPI 2
typedef	struct sockaddr SOCKADDR;
typedef	struct sockaddr *PSOCKADDR;
typedef	struct sockaddr *LPSOCKADDR;
#define	SERVICE_MULTIPLE 1
#define	NS_ALL 0
#define	NS_SAP 1
#define	NS_NDS 2
#define	NS_PEER_BROWSE 3
#define	NS_TCPIP_LOCAL 10
#define	NS_TCPIP_HOSTS 11
#define	NS_DNS 12
#define	NS_NETBT 13
#define	NS_WINS 14
#define	NS_NBP 20
#define	NS_MS 30
#define	NS_STDA 31
#define	NS_NTDS 32
#define	NS_X500 40
#define	NS_NIS 41
#define	NS_NISPLUS 42
#define	NS_WRQ 50
#define	RES_UNUSED_1 1
#define	RES_FLUSH_CACHE 2
#ifndef	RES_SERVICE
#define	RES_SERVICE 4
#endif	
#define	SERVICE_TYPE_VALUE_IPXPORTA "IpxSocket"
#define	SERVICE_TYPE_VALUE_IPXPORTW L"IpxSocket"
#define	SERVICE_TYPE_VALUE_SAPIDA "SapId"
#define	SERVICE_TYPE_VALUE_SAPIDW L"SapId"
#define	SERVICE_TYPE_VALUE_TCPPORTA "TcpPort"
#define	SERVICE_TYPE_VALUE_TCPPORTW L"TcpPort"
#define	SERVICE_TYPE_VALUE_UDPPORTA "UdpPort"
#define	SERVICE_TYPE_VALUE_UDPPORTW L"UdpPort"
#define	SERVICE_TYPE_VALUE_OBJECTIDA "ObjectId"
#define	SERVICE_TYPE_VALUE_OBJECTIDW L"ObjectId"
#ifdef	UNICODE
#define	SERVICE_TYPE_VALUE_SAPID SERVICE_TYPE_VALUE_SAPIDW
#define	SERVICE_TYPE_VALUE_TCPPORT SERVICE_TYPE_VALUE_TCPPORTW
#define	SERVICE_TYPE_VALUE_UDPPORT SERVICE_TYPE_VALUE_UDPPORTW
#define	SERVICE_TYPE_VALUE_OBJECTID SERVICE_TYPE_VALUE_OBJECTIDW
#else	
#define	SERVICE_TYPE_VALUE_SAPID SERVICE_TYPE_VALUE_SAPIDA
#define	SERVICE_TYPE_VALUE_TCPPORT SERVICE_TYPE_VALUE_TCPPORTA
#define	SERVICE_TYPE_VALUE_UDPPORT SERVICE_TYPE_VALUE_UDPPORTA
#define	SERVICE_TYPE_VALUE_OBJECTID SERVICE_TYPE_VALUE_OBJECTIDA
#endif
#ifndef	__CSADDR_DEFINED__
#define	__CSADDR_DEFINED__
typedef	struct _SOCKET_ADDRESS {
	LPSOCKADDR lpSockaddr ; INT iSockaddrLength ;
}	SOCKET_ADDRESS,*PSOCKET_ADDRESS,* LPSOCKET_ADDRESS ;
typedef	struct _CSADDR_INFO {
	SOCKET_ADDRESS LocalAddr ; SOCKET_ADDRESS RemoteAddr ;
	INT iSocketType ; INT iProtocol ;
}	CSADDR_INFO,*PCSADDR_INFO,* LPCSADDR_INFO ;
#endif
typedef	struct _AFPROTOCOLS { INT iAddressFamily; INT iProtocol; } AFPROTOCOLS,*PAFPROTOCOLS,*LPAFPROTOCOLS;
typedef	enum _WSAEcomparator { COMP_EQUAL = 0,COMP_NOTLESS } WSAECOMPARATOR,*PWSAECOMPARATOR,*LPWSAECOMPARATOR;
typedef	struct _WSAVersion { DWORD dwVersion; WSAECOMPARATOR ecHow; }WSAVERSION,*PWSAVERSION,*LPWSAVERSION;
typedef	struct _WSAQuerySetA {
	DWORD dwSize; LPSTR lpszServiceInstanceName; LPGUID lpServiceClassId;
	LPWSAVERSION lpVersion; LPSTR lpszComment; DWORD dwNameSpace;
	LPGUID lpNSProviderId; LPSTR lpszContext; DWORD dwNumberOfProtocols;
	LPAFPROTOCOLS lpafpProtocols; LPSTR lpszQueryString; DWORD dwNumberOfCsAddrs;
	LPCSADDR_INFO lpcsaBuffer; DWORD dwOutputFlags; LPBLOB lpBlob;
}	WSAQUERYSETA,*PWSAQUERYSETA,*LPWSAQUERYSETA;
typedef	struct _WSAQuerySetW {
	DWORD dwSize; LPWSTR lpszServiceInstanceName; LPGUID lpServiceClassId;
	LPWSAVERSION lpVersion; LPWSTR lpszComment; DWORD dwNameSpace;
	LPGUID lpNSProviderId; LPWSTR lpszContext; DWORD dwNumberOfProtocols;
	LPAFPROTOCOLS lpafpProtocols; LPWSTR lpszQueryString; DWORD dwNumberOfCsAddrs;
	LPCSADDR_INFO lpcsaBuffer; DWORD dwOutputFlags; LPBLOB lpBlob;
}	WSAQUERYSETW,*PWSAQUERYSETW,*LPWSAQUERYSETW;
#ifdef	UNICODE
typedef	WSAQUERYSETW WSAQUERYSET;
typedef	PWSAQUERYSETW PWSAQUERYSET;
typedef	LPWSAQUERYSETW LPWSAQUERYSET;
#else
typedef	WSAQUERYSETA WSAQUERYSET;
typedef	PWSAQUERYSETA PWSAQUERYSET;
typedef	LPWSAQUERYSETA LPWSAQUERYSET;
#endif
#define	LUP_DEEP 1
#define	LUP_CONTAINERS 2
#define	LUP_NOCONTAINERS 4
#define	LUP_NEAREST 8
#define	LUP_RETURN_NAME 0x10
#define	LUP_RETURN_TYPE 0x20
#define	LUP_RETURN_VERSION 0x40
#define	LUP_RETURN_COMMENT 0x80
#define	LUP_RETURN_ADDR 0x100
#define	LUP_RETURN_BLOB 0x200
#define	LUP_RETURN_ALIASES 0x400
#define	LUP_RETURN_QUERY_STRING 0x800
#define	LUP_RETURN_ALL 0x0FF0
#define	LUP_RES_SERVICE 0x8000
#define	LUP_FLUSHCACHE 0x1000
#define	LUP_FLUSHPREVIOUS 0x2000
#define	RESULT_IS_ALIAS 1
typedef	enum _WSAESETSERVICEOP { RNRSERVICE_REGISTER=0, RNRSERVICE_DEREGISTER,
	RNRSERVICE_DELETE
}	WSAESETSERVICEOP,*PWSAESETSERVICEOP,*LPWSAESETSERVICEOP;
typedef	struct _WSANSClassInfoA {
	LPSTR lpszName; DWORD dwNameSpace;
	DWORD dwValueType; DWORD dwValueSize; LPVOID lpValue;
}WSANSCLASSINFOA,*PWSANSCLASSINFOA,*LPWSANSCLASSINFOA;
typedef	struct _WSANSClassInfoW {
	LPWSTR lpszName; DWORD dwNameSpace; DWORD dwValueType;
	DWORD dwValueSize; LPVOID lpValue;
}WSANSCLASSINFOW,*PWSANSCLASSINFOW,*LPWSANSCLASSINFOW;
typedef	struct _WSAServiceClassInfoA {
	LPGUID lpServiceClassId; LPSTR lpszServiceClassName;
	DWORD dwCount; LPWSANSCLASSINFOA lpClassInfos;
}WSASERVICECLASSINFOA,*PWSASERVICECLASSINFOA,*LPWSASERVICECLASSINFOA;
typedef	struct _WSAServiceClassInfoW {
	LPGUID lpServiceClassId; LPWSTR lpszServiceClassName; DWORD dwCount;
	LPWSANSCLASSINFOW lpClassInfos;
}WSASERVICECLASSINFOW,*PWSASERVICECLASSINFOW,*LPWSASERVICECLASSINFOW;
typedef	struct _WSANAMESPACE_INFOA { GUID NSProviderId;
	DWORD dwNameSpace; BOOL fActive; DWORD dwVersion; LPSTR lpszIdentifier;
}	WSANAMESPACE_INFOA,*PWSANAMESPACE_INFOA,*LPWSANAMESPACE_INFOA;
typedef	struct _WSANAMESPACE_INFOW {
	GUID NSProviderId; DWORD dwNameSpace; BOOL fActive; DWORD dwVersion;
	LPWSTR lpszIdentifier;
}	WSANAMESPACE_INFOW,*PWSANAMESPACE_INFOW,*LPWSANAMESPACE_INFOW;
#ifdef	UNICODE
typedef	WSANSCLASSINFOW WSANSCLASSINFO;
typedef	PWSANSCLASSINFOW PWSANSCLASSINFO;
typedef	LPWSANSCLASSINFOW LPWSANSCLASSINFO;
typedef	WSASERVICECLASSINFOW WSASERVICECLASSINFO;
typedef	PWSASERVICECLASSINFOW PWSASERVICECLASSINFO;
typedef	LPWSASERVICECLASSINFOW LPWSASERVICECLASSINFO;
typedef	WSANAMESPACE_INFOW WSANAMESPACE_INFO;
typedef	PWSANAMESPACE_INFOW PWSANAMESPACE_INFO;
typedef	LPWSANAMESPACE_INFOW LPWSANAMESPACE_INFO;
#else
typedef	WSANSCLASSINFOA WSANSCLASSINFO;
typedef	PWSANSCLASSINFOA PWSANSCLASSINFO;
typedef	LPWSANSCLASSINFOA LPWSANSCLASSINFO;
typedef	WSASERVICECLASSINFOA WSASERVICECLASSINFO;
typedef	PWSASERVICECLASSINFOA PWSASERVICECLASSINFO;
typedef	LPWSASERVICECLASSINFOA LPWSASERVICECLASSINFO;
typedef	WSANAMESPACE_INFOA WSANAMESPACE_INFO;
typedef	PWSANAMESPACE_INFOA PWSANAMESPACE_INFO;
typedef	LPWSANAMESPACE_INFOA LPWSANAMESPACE_INFO;
#endif
SOCKET	WSAAPI accept(SOCKET,struct sockaddr *,int *);
typedef	SOCKET (WSAAPI * LPFN_ACCEPT)(SOCKET,struct sockaddr *,int *);
int	WSAAPI bind(SOCKET,const struct sockaddr *,int);
typedef	int (WSAAPI * LPFN_BIND)(SOCKET,const struct sockaddr *,int);
int	WSAAPI closesocket(SOCKET);
typedef	int (WSAAPI * LPFN_CLOSESOCKET)(SOCKET );
int	WSAAPI connect(SOCKET,const struct sockaddr *,int);
typedef	int (WSAAPI * LPFN_CONNECT)(SOCKET,const struct sockaddr *,int);
int	WSAAPI ioctlsocket(SOCKET,long,u_long *);
typedef	int (WSAAPI * LPFN_IOCTLSOCKET)(SOCKET,long,u_long *);
int	WSAAPI getpeername(SOCKET,struct sockaddr *,int *);
typedef	int (WSAAPI * LPFN_GETPEERNAME)(SOCKET,struct sockaddr *,int *);
int	WSAAPI getsockname(SOCKET,struct sockaddr *,int *);
typedef	int (WSAAPI * LPFN_GETSOCKNAME)(SOCKET,struct sockaddr *,int *);
int	WSAAPI getsockopt(SOCKET,int,int,char *,int *);
typedef	int (WSAAPI * LPFN_GETSOCKOPT)(SOCKET,int,int,char *,int *);
u_long	WSAAPI htonl(u_long);
typedef	u_long (WSAAPI * LPFN_HTONL)(u_long);
u_short	WSAAPI htons(u_short);
typedef	u_short (WSAAPI * LPFN_HTONS)(u_short);
unsigned	long WSAAPI inet_addr(const char *);
typedef	unsigned long (WSAAPI * LPFN_INET_ADDR)(const char *);
char	*WSAAPI inet_ntoa(struct in_addr);
typedef	char * (WSAAPI * LPFN_INET_NTOA)(struct in_addr);
int	WSAAPI listen(SOCKET,int);
typedef	int (WSAAPI * LPFN_LISTEN)(SOCKET,int);
u_long	WSAAPI ntohl(u_long);
typedef	u_long (WSAAPI * LPFN_NTOHL)(u_long);
u_short	WSAAPI ntohs(u_short);
typedef	u_short (WSAAPI * LPFN_NTOHS)(u_short);
int	WSAAPI recv(SOCKET,char *,int,int);
typedef	int (WSAAPI * LPFN_RECV)(SOCKET,char *,int,int);
int	WSAAPI recvfrom(SOCKET,char *,int,int,struct sockaddr *,int *);
typedef	int (WSAAPI * LPFN_RECVFROM)(SOCKET,char *,int,int,struct sockaddr *,int *);
int	WSAAPI select(int,fd_set *,fd_set *,fd_set *,const struct timeval *);
typedef	int (WSAAPI * LPFN_SELECT)(int,fd_set *,fd_set *,fd_set *,const struct timeval *);
int	WSAAPI send(SOCKET,const char *,int,int);
typedef	int (WSAAPI * LPFN_SEND)(SOCKET,const char *,int,int);
int	WSAAPI sendto(SOCKET,const char *,int,int,const struct sockaddr *,int);
typedef	int (WSAAPI * LPFN_SENDTO)(SOCKET,const char *,int,int,const struct sockaddr *,int);
int	WSAAPI setsockopt(SOCKET,int,int,const char *,int);
typedef	int (WSAAPI * LPFN_SETSOCKOPT)(SOCKET,int,int,const char *,int);
int	WSAAPI shutdown(SOCKET,int);
typedef	int (WSAAPI * LPFN_SHUTDOWN)(SOCKET,int);
SOCKET	WSAAPI socket(int,int,int);
typedef	SOCKET (WSAAPI * LPFN_SOCKET)(int,int,int);
struct	hostent *WSAAPI gethostbyaddr(const char *,int,int);
typedef	struct hostent *(WSAAPI * LPFN_GETHOSTBYADDR)(const char *,int,int);
struct	hostent *WSAAPI gethostbyname(const char *);
typedef	struct hostent *(WSAAPI * LPFN_GETHOSTBYNAME)(const char *);
int	WSAAPI gethostname(char *,int);
typedef	int (WSAAPI * LPFN_GETHOSTNAME)(char *,int);
struct	servent *WSAAPI getservbyport(int,const char *);
typedef	struct servent * (WSAAPI * LPFN_GETSERVBYPORT)(int,const char *);
struct	servent * WSAAPI getservbyname(const char *,const char *);
typedef	struct servent * (WSAAPI * LPFN_GETSERVBYNAME)(const char *,const char *);
struct	protoent * WSAAPI getprotobynumber(int);
typedef	struct protoent *(WSAAPI * LPFN_GETPROTOBYNUMBER)(int);
struct	protoent * WSAAPI getprotobyname(const char *);
typedef	struct protoent * (WSAAPI * LPFN_GETPROTOBYNAME)(const char *);
int	WSAAPI WSAStartup(WORD,LPWSADATA);
typedef	int (WSAAPI * LPFN_WSASTARTUP)(WORD,LPWSADATA);
int	WSAAPI WSACleanup(void);
typedef	int (WSAAPI * LPFN_WSACLEANUP)(void);
void	WSAAPI WSASetLastError(int);
typedef	void (WSAAPI * LPFN_WSASETLASTERROR)(int);
int	WSAAPI WSAGetLastError(void);
typedef	int (WSAAPI * LPFN_WSAGETLASTERROR)(void);
BOOL	WSAAPI WSAIsBlocking(void);
typedef	BOOL (WSAAPI * LPFN_WSAISBLOCKING)(void);
int	WSAAPI WSAUnhookBlockingHook(void);
typedef	int (WSAAPI * LPFN_WSAUNHOOKBLOCKINGHOOK)(void);
FARPROC	WSAAPI WSASetBlockingHook(FARPROC);
typedef	FARPROC (WSAAPI * LPFN_WSASETBLOCKINGHOOK)(FARPROC);
int	WSAAPI WSACancelBlockingCall(void);
typedef	int (WSAAPI * LPFN_WSACANCELBLOCKINGCALL)(void); 
HANDLE	WSAAPI WSAAsyncGetServByName(HWND,u_int,const char *,const char *,char *,int);
typedef	HANDLE (WSAAPI * LPFN_WSAASYNCGETSERVBYNAME)(HWND,u_int,const char *,const char *,char *,int);
HANDLE	WSAAPI WSAAsyncGetServByPort(HWND,u_int,int,const char *,char *,int);
typedef	HANDLE (WSAAPI * LPFN_WSAASYNCGETSERVBYPORT)(HWND,u_int,int,const char *,char *,int);
HANDLE	WSAAPI WSAAsyncGetProtoByName(HWND,u_int,const char *,char *,int);
typedef	HANDLE (WSAAPI *LPFN_WSAASYNCGETPROTOBYNAME)(HWND,u_int,const char *,char *,int);
HANDLE	WSAAPI WSAAsyncGetProtoByNumber(HWND,u_int,int,char *,int);
typedef	HANDLE (WSAAPI * LPFN_WSAASYNCGETPROTOBYNUMBER)(HWND,u_int,int,char *,int);
HANDLE	WSAAPI WSAAsyncGetHostByName(HWND,u_int,const char *,char *,int);
typedef	HANDLE (WSAAPI * LPFN_WSAASYNCGETHOSTBYNAME)(HWND,u_int,const char *,char *,int);
HANDLE	WSAAPI WSAAsyncGetHostByAddr(HWND,u_int,const char *,int,int,char *,int);
typedef	HANDLE (WSAAPI * LPFN_WSAASYNCGETHOSTBYADDR)(HWND,u_int,const char *,int,int,char *,int);
int	WSAAPI WSACancelAsyncRequest(HANDLE);
typedef	int (WSAAPI * LPFN_WSACANCELASYNCREQUEST)(HANDLE);
int	WSAAPI WSAAsyncSelect(SOCKET,HWND,u_int,long);
typedef	int (WSAAPI * LPFN_WSAASYNCSELECT)(SOCKET,HWND,u_int,long);
typedef	int (CALLBACK * LPCONDITIONPROC)(LPWSABUF,LPWSABUF,LPQOS,LPQOS,LPWSABUF,LPWSABUF,GROUP *,DWORD);
typedef	void (CALLBACK * LPWSAOVERLAPPED_COMPLETION_ROUTINE)(DWORD,DWORD,LPWSAOVERLAPPED,DWORD);
SOCKET	WSAAPI WSAAccept(SOCKET,struct sockaddr *,LPINT,LPCONDITIONPROC,DWORD);
typedef	SOCKET (WSAAPI * LPFN_WSAACCEPT)(SOCKET,struct sockaddr *,LPINT,LPCONDITIONPROC,DWORD);
BOOL	WSAAPI WSACloseEvent(WSAEVENT);
typedef	BOOL (WSAAPI * LPFN_WSACLOSEEVENT)(WSAEVENT);
int	WSAAPI WSAConnect(SOCKET,const struct sockaddr *,int,LPWSABUF,LPWSABUF,LPQOS,LPQOS);
typedef	int (WSAAPI * LPFN_WSACONNECT)(SOCKET,const struct sockaddr *,int,LPWSABUF,LPWSABUF,LPQOS,LPQOS);
WSAEVENT	WSAAPI WSACreateEvent(void );
typedef	WSAEVENT (WSAAPI * LPFN_WSACREATEEVENT)(void );
int	WSAAPI WSADuplicateSocketA(SOCKET ,DWORD ,LPWSAPROTOCOL_INFOA );
int	WSAAPI WSADuplicateSocketW(SOCKET,DWORD ,LPWSAPROTOCOL_INFOW);
typedef	int (WSAAPI * LPFN_WSADUPLICATESOCKETA)(SOCKET,DWORD,LPWSAPROTOCOL_INFOA);
typedef	int (WSAAPI * LPFN_WSADUPLICATESOCKETW)(SOCKET,DWORD,LPWSAPROTOCOL_INFOW);
int	WSAAPI WSAEnumNetworkEvents(SOCKET,WSAEVENT,LPWSANETWORKEVENTS);
typedef	int (WSAAPI * LPFN_WSAENUMNETWORKEVENTS)(SOCKET,WSAEVENT,LPWSANETWORKEVENTS);
int	WSAAPI WSAEnumProtocolsA(LPINT,LPWSAPROTOCOL_INFOA,LPDWORD);
int	WSAAPI WSAEnumProtocolsW(LPINT,LPWSAPROTOCOL_INFOW,LPDWORD);
typedef	int (WSAAPI * LPFN_WSAENUMPROTOCOLSA)(LPINT,LPWSAPROTOCOL_INFOA,LPDWORD);
typedef	int (WSAAPI * LPFN_WSAENUMPROTOCOLSW)(LPINT,LPWSAPROTOCOL_INFOW,LPDWORD);
int	WSAAPI WSAEventSelect(SOCKET,WSAEVENT,long);
typedef	int (WSAAPI * LPFN_WSAEVENTSELECT)(SOCKET,WSAEVENT,long);
BOOL	WSAAPI WSAGetOverlappedResult(SOCKET,LPWSAOVERLAPPED,LPDWORD,BOOL,LPDWORD);
typedef	BOOL (WSAAPI * LPFN_WSAGETOVERLAPPEDRESULT)(SOCKET,LPWSAOVERLAPPED,LPDWORD,BOOL,LPDWORD);
BOOL	WSAAPI WSAGetQOSByName(SOCKET,LPWSABUF,LPQOS);
typedef	BOOL (WSAAPI * LPFN_WSAGETQOSBYNAME)(SOCKET,LPWSABUF,LPQOS);
int	WSAAPI WSAHtonl(SOCKET,u_long,u_long *);
typedef	int (WSAAPI * LPFN_WSAHTONL)(SOCKET,u_long,u_long *);
int	WSAAPI WSAHtons(SOCKET,u_short,u_short *);
typedef	int (WSAAPI * LPFN_WSAHTONS)(SOCKET,u_short,u_short *);
int	WSAAPI WSAIoctl(SOCKET,DWORD,LPVOID,DWORD,LPVOID,DWORD,LPDWORD,LPWSAOVERLAPPED,LPWSAOVERLAPPED_COMPLETION_ROUTINE);
typedef	int (WSAAPI * LPFN_WSAIOCTL)(SOCKET,DWORD,LPVOID,DWORD,LPVOID,DWORD,LPDWORD,LPWSAOVERLAPPED,LPWSAOVERLAPPED_COMPLETION_ROUTINE);
SOCKET	WSAAPI WSAJoinLeaf(SOCKET,const struct sockaddr *,int,LPWSABUF,LPWSABUF,LPQOS,LPQOS,DWORD);
typedef	SOCKET (WSAAPI * LPFN_WSAJOINLEAF)(SOCKET,const struct sockaddr *,int,LPWSABUF,LPWSABUF,LPQOS,LPQOS,DWORD);
int	WSAAPI WSANtohl(SOCKET,u_long,u_long * );
typedef	int (WSAAPI * LPFN_WSANTOHL)(SOCKET,u_long ,u_long * );
int	WSAAPI WSANtohs(SOCKET,u_short,u_short * );
typedef	int (WSAAPI * LPFN_WSANTOHS)(SOCKET,u_short,u_short *);
int	WSAAPI WSARecv(SOCKET,LPWSABUF,DWORD ,LPDWORD ,LPDWORD,LPWSAOVERLAPPED,LPWSAOVERLAPPED_COMPLETION_ROUTINE);
typedef	int (WSAAPI * LPFN_WSARECV)(SOCKET,LPWSABUF,DWORD,LPDWORD,LPDWORD ,LPWSAOVERLAPPED,LPWSAOVERLAPPED_COMPLETION_ROUTINE);
int	WSAAPI WSARecvDisconnect(SOCKET ,LPWSABUF);
typedef	int (WSAAPI * LPFN_WSARECVDISCONNECT)(SOCKET,LPWSABUF);
int	WSAAPI WSARecvFrom(SOCKET,LPWSABUF,DWORD,LPDWORD,LPDWORD,struct sockaddr *,LPINT,LPWSAOVERLAPPED,LPWSAOVERLAPPED_COMPLETION_ROUTINE);
typedef	int (WSAAPI * LPFN_WSARECVFROM)(SOCKET,LPWSABUF,DWORD,LPDWORD,LPDWORD,struct sockaddr *,LPINT,LPWSAOVERLAPPED,LPWSAOVERLAPPED_COMPLETION_ROUTINE);
BOOL	WSAAPI WSAResetEvent(WSAEVENT);
typedef	BOOL (WSAAPI * LPFN_WSARESETEVENT)(WSAEVENT );
int	WSAAPI WSASend(SOCKET,LPWSABUF,DWORD,LPDWORD,DWORD,LPWSAOVERLAPPED,LPWSAOVERLAPPED_COMPLETION_ROUTINE );
typedef	int (WSAAPI * LPFN_WSASEND)(SOCKET,LPWSABUF,DWORD,LPDWORD,DWORD,LPWSAOVERLAPPED,LPWSAOVERLAPPED_COMPLETION_ROUTINE);
int	WSAAPI WSASendDisconnect(SOCKET ,LPWSABUF );
typedef	int (WSAAPI * LPFN_WSASENDDISCONNECT)(SOCKET,LPWSABUF);
int	WSAAPI WSASendTo(SOCKET,LPWSABUF,DWORD,LPDWORD,DWORD,const struct sockaddr *,int,LPWSAOVERLAPPED,LPWSAOVERLAPPED_COMPLETION_ROUTINE);
typedef	int (WSAAPI * LPFN_WSASENDTO)(SOCKET,LPWSABUF,DWORD,LPDWORD,DWORD,const struct sockaddr *,int,LPWSAOVERLAPPED,LPWSAOVERLAPPED_COMPLETION_ROUTINE);
BOOL	WSAAPI WSASetEvent(WSAEVENT);
typedef	BOOL (WSAAPI * LPFN_WSASETEVENT)(WSAEVENT);
SOCKET	WSAAPI WSASocketA(int,int,int,LPWSAPROTOCOL_INFOA,GROUP,DWORD);
SOCKET	WSAAPI WSASocketW(int,int,int,LPWSAPROTOCOL_INFOW,GROUP,DWORD);
typedef	SOCKET (WSAAPI * LPFN_WSASOCKETA)(int,int,int,LPWSAPROTOCOL_INFOA,GROUP,DWORD);
typedef	SOCKET (WSAAPI * LPFN_WSASOCKETW)(int,int,int,LPWSAPROTOCOL_INFOW,GROUP,DWORD);
DWORD	WSAAPI WSAWaitForMultipleEvents(DWORD,const WSAEVENT *,BOOL,DWORD,BOOL);
typedef	DWORD (WSAAPI * LPFN_WSAWAITFORMULTIPLEEVENTS)(DWORD,const WSAEVENT *,BOOL,DWORD,BOOL);
INT	WSAAPI WSAAddressToStringA(LPSOCKADDR,DWORD,LPWSAPROTOCOL_INFOA,LPSTR,LPDWORD);
INT	WSAAPI WSAAddressToStringW(LPSOCKADDR,DWORD,LPWSAPROTOCOL_INFOW,LPWSTR,LPDWORD);
typedef	INT (WSAAPI * LPFN_WSAADDRESSTOSTRINGA)(LPSOCKADDR,DWORD,LPWSAPROTOCOL_INFOA,LPSTR,LPDWORD);
typedef	INT (WSAAPI * LPFN_WSAADDRESSTOSTRINGW)(LPSOCKADDR,DWORD,LPWSAPROTOCOL_INFOW,LPWSTR,LPDWORD);
INT	WSAAPI WSAStringToAddressA(LPSTR,INT,LPWSAPROTOCOL_INFOA,LPSOCKADDR,LPINT);
INT	WSAAPI WSAStringToAddressW(LPWSTR,INT,LPWSAPROTOCOL_INFOW,LPSOCKADDR,LPINT);
typedef	INT (WSAAPI *LPFN_WSASTRINGTOADDRESSA)(LPSTR,INT,LPWSAPROTOCOL_INFOA,LPSOCKADDR,LPINT);
typedef	INT (WSAAPI * LPFN_WSASTRINGTOADDRESSW)(LPWSTR,INT,LPWSAPROTOCOL_INFOW,LPSOCKADDR,LPINT);
INT	WSAAPI WSALookupServiceBeginA(LPWSAQUERYSETA,DWORD,LPHANDLE);
INT	WSAAPI WSALookupServiceBeginW(LPWSAQUERYSETW,DWORD,LPHANDLE);
typedef	INT (WSAAPI * LPFN_WSALOOKUPSERVICEBEGINA)(LPWSAQUERYSETA,DWORD,LPHANDLE);
typedef	INT (WSAAPI * LPFN_WSALOOKUPSERVICEBEGINW)(LPWSAQUERYSETW,DWORD,LPHANDLE);
INT	WSAAPI WSALookupServiceNextA(HANDLE,DWORD,LPDWORD,LPWSAQUERYSETA);
INT	WSAAPI WSALookupServiceNextW(HANDLE,DWORD,LPDWORD,LPWSAQUERYSETW);
typedef	INT (WSAAPI * LPFN_WSALOOKUPSERVICENEXTA)(HANDLE,DWORD,LPDWORD,LPWSAQUERYSETA);
typedef	INT (WSAAPI *LPFN_WSALOOKUPSERVICENEXTW)(HANDLE,DWORD,LPDWORD,LPWSAQUERYSETW);
INT	WSAAPI WSALookupServiceEnd(HANDLE);
typedef	INT (WSAAPI * LPFN_WSALOOKUPSERVICEEND)(HANDLE);
INT	WSAAPI WSAInstallServiceClassA(LPWSASERVICECLASSINFOA);
INT	WSAAPI WSAInstallServiceClassW(LPWSASERVICECLASSINFOW);
typedef	INT (WSAAPI * LPFN_WSAINSTALLSERVICECLASSA)(LPWSASERVICECLASSINFOA);
typedef	INT (WSAAPI * LPFN_WSAINSTALLSERVICECLASSW)(LPWSASERVICECLASSINFOW);
INT	WSAAPI WSARemoveServiceClass(LPGUID);
typedef	INT (WSAAPI * LPFN_WSAREMOVESERVICECLASS)(LPGUID);
INT	WSAAPI WSAGetServiceClassInfoA(LPGUID,LPGUID,LPDWORD,LPWSASERVICECLASSINFOA);
INT	WSAAPI WSAGetServiceClassInfoW(LPGUID,LPGUID,LPDWORD,LPWSASERVICECLASSINFOW);
typedef	INT (WSAAPI * LPFN_WSAGETSERVICECLASSINFOA)(LPGUID,LPGUID,LPDWORD,LPWSASERVICECLASSINFOA);
typedef	INT (WSAAPI * LPFN_WSAGETSERVICECLASSINFOW)(LPGUID,LPGUID,LPDWORD,LPWSASERVICECLASSINFOW);
INT	WSAAPI WSAEnumNameSpaceProvidersA(LPDWORD,LPWSANAMESPACE_INFOA );
INT	WSAAPI WSAEnumNameSpaceProvidersW(LPDWORD,LPWSANAMESPACE_INFOW);
typedef	INT (WSAAPI *LPFN_WSAENUMNAMESPACEPROVIDERSA)(LPDWORD,LPWSANAMESPACE_INFOA);
typedef	INT (WSAAPI * LPFN_WSAENUMNAMESPACEPROVIDERSW)(LPDWORD,LPWSANAMESPACE_INFOW);
INT	WSAAPI WSAGetServiceClassNameByClassIdA(LPGUID,LPSTR,LPDWORD);
INT	WSAAPI WSAGetServiceClassNameByClassIdW(LPGUID,LPWSTR,LPDWORD);
typedef	INT (WSAAPI * LPFN_WSAGETSERVICECLASSNAMEBYCLASSIDA)(LPGUID,LPSTR,LPDWORD);
typedef	INT (WSAAPI * LPFN_WSAGETSERVICECLASSNAMEBYCLASSIDW)(LPGUID,LPWSTR,LPDWORD);
INT	WSAAPI WSASetServiceA(LPWSAQUERYSETA,WSAESETSERVICEOP,DWORD);
INT	WSAAPI WSASetServiceW(LPWSAQUERYSETW,WSAESETSERVICEOP,DWORD);
typedef	INT (WSAAPI * LPFN_WSASETSERVICEA)(LPWSAQUERYSETA,WSAESETSERVICEOP,DWORD);
typedef	INT (WSAAPI * LPFN_WSASETSERVICEW)(LPWSAQUERYSETW,WSAESETSERVICEOP,DWORD);
#ifdef	UNICODE
#define	WSAEnumProtocols WSAEnumProtocolsW
#define	LPFN_WSAENUMPROTOCOLS LPFN_WSAENUMPROTOCOLSW
#define	WSASocket WSASocketW
#define	WSAInstallServiceClass WSAInstallServiceClassW
#define	LPFN_WSALOOKUPSERVICENEXT LPFN_WSALOOKUPSERVICENEXTW
#define	WSALookupServiceNext WSALookupServiceNextW
#define	LPFN_WSALOOKUPSERVICEBEGIN LPFN_WSALOOKUPSERVICEBEGINW
#define	LPFN_WSASETSERVICE LPFN_WSASETSERVICEW
#define	LPFN_WSAADDRESSTOSTRING LPFN_WSAADDRESSTOSTRINGW
#define	WSAGetServiceClassNameByClassId WSAGetServiceClassNameByClassIdW
#define	LPFN_WSAENUMNAMESPACEPROVIDERS LPFN_WSAENUMNAMESPACEPROVIDERSW
#define	WSALookupServiceBegin WSALookupServiceBeginW
#define	LPFN_WSASOCKET LPFN_WSASOCKETW
#define	WSASetService WSASetServiceW
#define	WSAEnumNameSpaceProviders WSAEnumNameSpaceProvidersW
#define	WSAGetServiceClassInfo WSAGetServiceClassInfoW
#define	LPFN_WSAGETSERVICECLASSINFO LPFN_WSAGETSERVICECLASSINFOW
#define	LPFN_WSAINSTALLSERVICECLASS LPFN_WSAINSTALLSERVICECLASSW
#define	WSADuplicateSocket WSADuplicateSocketW
#define	WSAAddressToString WSAAddressToStringW
#define	LPFN_WSAGETSERVICECLASSNAMEBYCLASSID LPFN_WSAGETSERVICECLASSNAMEBYCLASSIDW
#define	WSAStringToAddress WSAStringToAddressW
#define	LPFN_WSASTRINGTOADDRESS LPFN_WSASTRINGTOADDRESSW
#define	WSASocket WSASocketA
#define	LPFN_WSADUPLICATESOCKET LPFN_WSADUPLICATESOCKETW
#else
#define	LPFN_WSADUPLICATESOCKET LPFN_WSADUPLICATESOCKETA
#define	WSAEnumProtocols WSAEnumProtocolsA
#define	LPFN_WSASOCKET LPFN_WSASOCKETA
#define	LPFN_WSAADDRESSTOSTRING LPFN_WSAADDRESSTOSTRINGA
#define	WSAAddressToString WSAAddressToStringA
#define	LPFN_WSASTRINGTOADDRESS LPFN_WSASTRINGTOADDRESSA
#define	LPFN_WSAENUMPROTOCOLS LPFN_WSAENUMPROTOCOLSA
#define	LPFN_WSAGETSERVICECLASSNAMEBYCLASSID LPFN_WSAGETSERVICECLASSNAMEBYCLASSIDA
#define	WSALookupServiceBegin WSALookupServiceBeginA
#define	LPFN_WSALOOKUPSERVICENEXT LPFN_WSALOOKUPSERVICENEXTA
#define	WSALookupServiceNext WSALookupServiceNextA
#define	LPFN_WSALOOKUPSERVICEBEGIN LPFN_WSALOOKUPSERVICEBEGINA
#define	WSAStringToAddress WSAStringToAddressA
#define	WSAGetServiceClassNameByClassId WSAGetServiceClassNameByClassIdA
#define	LPFN_WSAENUMNAMESPACEPROVIDERS LPFN_WSAENUMNAMESPACEPROVIDERSA
#define	WSASetService WSASetServiceA
#define	WSAEnumNameSpaceProviders WSAEnumNameSpaceProvidersA
#define	WSAGetServiceClassInfo WSAGetServiceClassInfoA
#define	WSAInstallServiceClass WSAInstallServiceClassA
#define	LPFN_WSASETSERVICE LPFN_WSASETSERVICEA
#define	LPFN_WSAGETSERVICECLASSINFO LPFN_WSAGETSERVICECLASSINFOA
#define	LPFN_WSAINSTALLSERVICECLASS LPFN_WSAINSTALLSERVICECLASSA
#define	WSADuplicateSocket WSADuplicateSocketA
#endif	
typedef	struct sockaddr_in SOCKADDR_IN;
typedef	struct sockaddr_in *PSOCKADDR_IN;
typedef	struct sockaddr_in *LPSOCKADDR_IN;
typedef	struct linger LINGER;
typedef	struct linger *PLINGER;
typedef	struct linger *LPLINGER;
typedef	struct in_addr IN_ADDR;
typedef	struct in_addr *PIN_ADDR;
typedef	struct in_addr *LPIN_ADDR;
typedef	struct fd_set FD_SET;
typedef	struct fd_set *PFD_SET;
typedef	struct fd_set *LPFD_SET;
typedef	struct hostent HOSTENT;
typedef	struct hostent *PHOSTENT;
typedef	struct hostent *LPHOSTENT;
typedef	struct servent SERVENT;
typedef	struct servent *PSERVENT;
typedef	struct servent *LPSERVENT;
typedef	struct protoent PROTOENT;
typedef	struct protoent *PPROTOENT;
typedef	struct protoent *LPPROTOENT;
typedef	struct timeval TIMEVAL;
typedef	struct timeval *PTIMEVAL;
typedef	struct timeval *LPTIMEVAL;
#define	WSAMAKEASYNCREPLY(b,e) MAKELONG(b,e)
#define	WSAMAKESELECTREPLY(e,error) MAKELONG(e,error)
#define	WSAGETASYNCBUFLEN(l) LOWORD(l)
#define	WSAGETASYNCERROR(l) HIWORD(l)
#define	WSAGETSELECTEVENT(l) LOWORD(l)
#define	WSAGETSELECTERROR(l) HIWORD(l)
#pragma	pack(pop)
#endif	
