/* $Revision: 1.2 $ */
#ifndef __RPCDCE_H__
#define __RPCDCE_H__

#define IN
#define OUT
typedef I_RPC_HANDLE RPC_BINDING_HANDLE;
typedef RPC_BINDING_HANDLE handle_t;
#define rpc_binding_handle_t RPC_BINDING_HANDLE
#ifndef GUID_DEFINED
#define GUID_DEFINED
typedef struct _GUID {
	unsigned long Data1;
	unsigned short Data2;
	unsigned short Data3;
	unsigned char Data4[8];
} GUID;
#endif
#ifndef UUID_DEFINED
#define UUID_DEFINED
typedef GUID UUID;
#ifndef uuid_t
#define uuid_t UUID
#endif
#endif
typedef struct _RPC_BINDING_VECTOR {
	unsigned long Count;
	RPC_BINDING_HANDLE BindingH[1];
} RPC_BINDING_VECTOR;
#ifndef rpc_binding_vector_t
#define rpc_binding_vector_t RPC_BINDING_VECTOR
#endif
typedef struct _UUID_VECTOR {
	unsigned long Count;
	UUID *Uuid[1];
} UUID_VECTOR;
#ifndef uuid_vector_t
#define uuid_vector_t UUID_VECTOR
#endif

typedef void * RPC_IF_HANDLE;

#ifndef IFID_DEFINED
#define IFID_DEFINED
typedef struct _RPC_IF_ID {
	UUID Uuid;
	unsigned short VersMajor;
	unsigned short VersMinor;
} RPC_IF_ID;
#endif

#define RPC_C_BINDING_INFINITE_TIMEOUT 10
#define RPC_C_BINDING_MIN_TIMEOUT 0
#define RPC_C_BINDING_DEFAULT_TIMEOUT 5
#define RPC_C_BINDING_MAX_TIMEOUT 9
#define RPC_C_CANCEL_INFINITE_TIMEOUT -1
#define RPC_C_LISTEN_MAX_CALLS_DEFAULT 1234
#define RPC_C_PROTSEQ_MAX_REQS_DEFAULT 10
#define RPC_C_BIND_TO_ALL_NICS 1
#define RPC_C_USE_INTERNET_PORT 1
#define RPC_C_USE_INTRANET_PORT 2
#ifdef RPC_UNICODE_SUPPORTED
typedef struct _RPC_PROTSEQ_VECTORA {
	unsigned int Count;
	unsigned char * Protseq[1];
} RPC_PROTSEQ_VECTORA;
typedef struct _RPC_PROTSEQ_VECTORW {
	unsigned int Count;
	unsigned short * Protseq[1];
} RPC_PROTSEQ_VECTORW;

#ifdef UNICODE
#define RPC_PROTSEQ_VECTOR RPC_PROTSEQ_VECTORW
#else 
#define RPC_PROTSEQ_VECTOR RPC_PROTSEQ_VECTORA
#endif
#else
typedef struct _RPC_PROTSEQ_VECTOR {
	unsigned int Count;
	unsigned char * Protseq[1];
} RPC_PROTSEQ_VECTOR;
#endif
typedef struct _RPC_POLICY {
	unsigned int Length ;
	unsigned long EndpointFlags ;
	unsigned long NICFlags ;
	} RPC_POLICY,*PRPC_POLICY ;
typedef void __RPC_USER RPC_OBJECT_INQ_FN(
	UUID * ObjectUuid,
	UUID * TypeUuid,
	RPC_STATUS * Status
	);

typedef RPC_STATUS
RPC_IF_CALLBACK_FN(
	 RPC_IF_HANDLE InterfaceUuid,
	 void *Context
	) ;

#define RPC_MGR_EPV void
typedef struct {
	unsigned int Count;
	unsigned long Stats[1];
} RPC_STATS_VECTOR;
#define RPC_C_STATS_CALLS_IN 0
#define RPC_C_STATS_CALLS_OUT 1
#define RPC_C_STATS_PKTS_IN 2
#define RPC_C_STATS_PKTS_OUT 3
typedef struct {
	unsigned long Count;
	RPC_IF_ID * IfId[1];
} RPC_IF_ID_VECTOR;
RPC_STATUS RPC_ENTRY RpcBindingCopy(RPC_BINDING_HANDLE,RPC_BINDING_HANDLE *);
RPC_STATUS RPC_ENTRY RpcBindingFree(RPC_BINDING_HANDLE *);
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcBindingFromStringBindingA(unsigned char *,RPC_BINDING_HANDLE *);
RPC_STATUS RPC_ENTRY RpcBindingFromStringBindingW(unsigned short *,RPC_BINDING_HANDLE *);
#ifdef UNICODE
#define RpcBindingFromStringBinding RpcBindingFromStringBindingW
#else 
#define RpcBindingFromStringBinding RpcBindingFromStringBindingA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcBindingFromStringBinding(unsigned char *,RPC_BINDING_HANDLE *);
#endif 
RPC_STATUS RPC_ENTRY RpcBindingInqObject(RPC_BINDING_HANDLE,UUID *);
RPC_STATUS RPC_ENTRY RpcBindingReset(RPC_BINDING_HANDLE);
RPC_STATUS RPC_ENTRY RpcBindingSetObject(RPC_BINDING_HANDLE,UUID *);
RPC_STATUS RPC_ENTRY RpcMgmtInqDefaultProtectLevel(unsigned long,unsigned long *);
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcBindingToStringBindingA(
	 RPC_BINDING_HANDLE Binding,
	 unsigned char * * StringBinding
	);

RPC_STATUS RPC_ENTRY
RpcBindingToStringBindingW(
	 RPC_BINDING_HANDLE Binding,
	 unsigned short * * StringBinding
	);

#ifdef UNICODE
#define RpcBindingToStringBinding RpcBindingToStringBindingW
#else 
#define RpcBindingToStringBinding RpcBindingToStringBindingA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcBindingToStringBinding(RPC_BINDING_HANDLE,unsigned char * *);
#endif 
RPC_STATUS RPC_ENTRY RpcBindingVectorFree(RPC_BINDING_VECTOR * *);
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcStringBindingComposeA(unsigned char *,unsigned char *,unsigned char *,unsigned char *,unsigned char *,unsigned char * *);
RPC_STATUS RPC_ENTRY RpcStringBindingComposeW(unsigned short *,unsigned short *,unsigned short *,unsigned short *,unsigned short *,unsigned short * *);
#ifdef UNICODE
#define RpcStringBindingCompose RpcStringBindingComposeW
#else 
#define RpcStringBindingCompose RpcStringBindingComposeA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcStringBindingCompose(unsigned char *,unsigned char *,unsigned char *,unsigned char *,unsigned char *,unsigned char * *);
#endif 
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcStringBindingParseA(unsigned char *,unsigned char * *,unsigned char * *,unsigned char * *,unsigned char * *,unsigned char * *);
RPC_STATUS RPC_ENTRY RpcStringBindingParseW(unsigned short *,unsigned short **,unsigned short **,unsigned short **,unsigned short **,unsigned short **);
#ifdef UNICODE
#define RpcStringBindingParse RpcStringBindingParseW
#else 
#define RpcStringBindingParse RpcStringBindingParseA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcStringBindingParse(unsigned char *,unsigned char * *,unsigned char * *,unsigned char * *,unsigned char * *,unsigned char * *);
#endif 

#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcStringFreeA(unsigned char * *);
RPC_STATUS RPC_ENTRY RpcStringFreeW(unsigned short * *);
#ifdef UNICODE
#define RpcStringFree RpcStringFreeW
#else 
#define RpcStringFree RpcStringFreeA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcStringFree(unsigned char * *);
#endif 
RPC_STATUS RPC_ENTRY RpcIfInqId(RPC_IF_HANDLE,RPC_IF_ID *);
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcNetworkIsProtseqValidA(unsigned char *);
RPC_STATUS RPC_ENTRY RpcNetworkIsProtseqValidW(unsigned short * Protseq);
#ifdef UNICODE
#define RpcNetworkIsProtseqValid RpcNetworkIsProtseqValidW
#else 
#define RpcNetworkIsProtseqValid RpcNetworkIsProtseqValidA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcNetworkIsProtseqValid(unsigned char * Protseq);
#endif 


RPC_STATUS RPC_ENTRY RpcMgmtInqComTimeout(RPC_BINDING_HANDLE,unsigned int *);
RPC_STATUS RPC_ENTRY RpcMgmtSetComTimeout(RPC_BINDING_HANDLE,unsigned int);
RPC_STATUS RPC_ENTRY RpcMgmtSetCancelTimeout(long Timeout);

#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcNetworkInqProtseqsA(RPC_PROTSEQ_VECTORA * *);
RPC_STATUS RPC_ENTRY RpcNetworkInqProtseqsW(RPC_PROTSEQ_VECTORW * *);
#ifdef UNICODE
#define RpcNetworkInqProtseqs RpcNetworkInqProtseqsW
#else 
#define RpcNetworkInqProtseqs RpcNetworkInqProtseqsA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcNetworkInqProtseqs(RPC_PROTSEQ_VECTOR * *);
#endif 
RPC_STATUS RPC_ENTRY RpcObjectInqType(UUID *,UUID *);
RPC_STATUS RPC_ENTRY RpcObjectSetInqFn(RPC_OBJECT_INQ_FN *);
RPC_STATUS RPC_ENTRY RpcObjectSetType(UUID *,UUID *);
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcProtseqVectorFreeA(RPC_PROTSEQ_VECTORA * *);
RPC_STATUS RPC_ENTRY RpcProtseqVectorFreeW(RPC_PROTSEQ_VECTORW * *);
#ifdef UNICODE
#define RpcProtseqVectorFree RpcProtseqVectorFreeW
#else 
#define RpcProtseqVectorFree RpcProtseqVectorFreeA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcProtseqVectorFree(RPC_PROTSEQ_VECTOR * *);
#endif 
RPC_STATUS RPC_ENTRY RpcServerInqBindings(RPC_BINDING_VECTOR * *);
RPC_STATUS RPC_ENTRY
RpcServerInqIf(
	 RPC_IF_HANDLE IfSpec,
	 UUID * MgrTypeUuid,
	 RPC_MGR_EPV * * MgrEpv
	);


RPC_STATUS RPC_ENTRY
RpcServerListen(
	 unsigned int MinimumCallThreads,
	 unsigned int MaxCalls,
	 unsigned int DontWait
	);


RPC_STATUS RPC_ENTRY
RpcServerRegisterIf(
	 RPC_IF_HANDLE IfSpec,
	 UUID * MgrTypeUuid,
	 RPC_MGR_EPV * MgrEpv 
	);


RPC_STATUS RPC_ENTRY
RpcServerRegisterIfEx(
	 RPC_IF_HANDLE IfSpec,
	 UUID * MgrTypeUuid,
	 RPC_MGR_EPV * MgrEpv,
	 unsigned int Flags,
	 unsigned int MaxCalls,
	 RPC_IF_CALLBACK_FN *IfCallback
	);


RPC_STATUS RPC_ENTRY
RpcServerUnregisterIf(
	 RPC_IF_HANDLE IfSpec,
	 UUID * MgrTypeUuid,
	 unsigned int WaitForCallsToComplete
	);


RPC_STATUS RPC_ENTRY
RpcServerUseAllProtseqs(
	 unsigned int MaxCalls,
	 void * SecurityDescriptor 
	);


RPC_STATUS RPC_ENTRY
RpcServerUseAllProtseqsEx(
	 unsigned int MaxCalls,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);


RPC_STATUS RPC_ENTRY
RpcServerUseAllProtseqsIf(
	 unsigned int MaxCalls,
	 RPC_IF_HANDLE IfSpec,
	 void * SecurityDescriptor 
	);


RPC_STATUS RPC_ENTRY
RpcServerUseAllProtseqsIfEx(
	 unsigned int MaxCalls,
	 RPC_IF_HANDLE IfSpec,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);




#ifdef RPC_UNICODE_SUPPORTED

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqA(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 void * SecurityDescriptor 
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqExA(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqW(
	 unsigned short * Protseq,
	 unsigned int MaxCalls,
	 void * SecurityDescriptor 
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqExW(
	 unsigned short * Protseq,
	 unsigned int MaxCalls,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);

#ifdef UNICODE
#define RpcServerUseProtseq RpcServerUseProtseqW
#define RpcServerUseProtseqEx RpcServerUseProtseqExW
#else 
#define RpcServerUseProtseq RpcServerUseProtseqA
#define RpcServerUseProtseqEx RpcServerUseProtseqExA
#endif 

#else 

RPC_STATUS RPC_ENTRY
RpcServerUseProtseq(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 void * SecurityDescriptor 
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqEx(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);

#endif 



#ifdef RPC_UNICODE_SUPPORTED

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqEpA(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 unsigned char * Endpoint,
	 void * SecurityDescriptor 
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqEpExA(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 unsigned char * Endpoint,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqEpW(
	 unsigned short * Protseq,
	 unsigned int MaxCalls,
	 unsigned short * Endpoint,
	 void * SecurityDescriptor 
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqEpExW(
	 unsigned short * Protseq,
	 unsigned int MaxCalls,
	 unsigned short * Endpoint,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);

#ifdef UNICODE
#define RpcServerUseProtseqEp RpcServerUseProtseqEpW
#define RpcServerUseProtseqEpEx RpcServerUseProtseqEpExW
#else 
#define RpcServerUseProtseqEp RpcServerUseProtseqEpA
#define RpcServerUseProtseqEpEx RpcServerUseProtseqEpExA
#endif 

#else 

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqEp(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 unsigned char * Endpoint,
	 void * SecurityDescriptor 
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqEpEx(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 unsigned char * Endpoint,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);

#endif 



#ifdef RPC_UNICODE_SUPPORTED

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqIfA(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 RPC_IF_HANDLE IfSpec,
	 void * SecurityDescriptor 
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqIfExA(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 RPC_IF_HANDLE IfSpec,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqIfW(
	 unsigned short * Protseq,
	 unsigned int MaxCalls,
	 RPC_IF_HANDLE IfSpec,
	 void * SecurityDescriptor 
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqIfExW(
	 unsigned short * Protseq,
	 unsigned int MaxCalls,
	 RPC_IF_HANDLE IfSpec,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);

#ifdef UNICODE
#define RpcServerUseProtseqIf RpcServerUseProtseqIfW
#define RpcServerUseProtseqIfEx RpcServerUseProtseqIfExW
#else 
#define RpcServerUseProtseqIf RpcServerUseProtseqIfA
#define RpcServerUseProtseqIfEx RpcServerUseProtseqIfExA
#endif 

#else 

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqIf(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 RPC_IF_HANDLE IfSpec,
	 void * SecurityDescriptor 
	);

RPC_STATUS RPC_ENTRY
RpcServerUseProtseqIfEx(
	 unsigned char * Protseq,
	 unsigned int MaxCalls,
	 RPC_IF_HANDLE IfSpec,
	 void * SecurityDescriptor,
	 PRPC_POLICY Policy
	);

#endif 


RPC_STATUS RPC_ENTRY
RpcMgmtStatsVectorFree(
	 RPC_STATS_VECTOR ** StatsVector
	);


RPC_STATUS RPC_ENTRY
RpcMgmtInqStats(
	 RPC_BINDING_HANDLE Binding,
	 RPC_STATS_VECTOR ** Statistics
	);


RPC_STATUS RPC_ENTRY
RpcMgmtIsServerListening(
	 RPC_BINDING_HANDLE Binding
	);


RPC_STATUS RPC_ENTRY
RpcMgmtStopServerListening(
	 RPC_BINDING_HANDLE Binding
	);


RPC_STATUS RPC_ENTRY
RpcMgmtWaitServerListen(
	void
	);


RPC_STATUS RPC_ENTRY
RpcMgmtSetServerStackSize(
	 unsigned long ThreadStackSize
	);


void RPC_ENTRY
RpcSsDontSerializeContext(
	void
	);


RPC_STATUS RPC_ENTRY
RpcMgmtEnableIdleCleanup(
	void
	);

RPC_STATUS RPC_ENTRY
RpcMgmtInqIfIds(
	 RPC_BINDING_HANDLE Binding,
	 RPC_IF_ID_VECTOR * * IfIdVector
	);

RPC_STATUS RPC_ENTRY
RpcIfIdVectorFree(
	 RPC_IF_ID_VECTOR * * IfIdVector
	);

#ifdef RPC_UNICODE_SUPPORTED

RPC_STATUS RPC_ENTRY
RpcMgmtInqServerPrincNameA(
	 RPC_BINDING_HANDLE Binding,
	 unsigned long AuthnSvc,
	 unsigned char * * ServerPrincName
	);

RPC_STATUS RPC_ENTRY
RpcMgmtInqServerPrincNameW(
	 RPC_BINDING_HANDLE Binding,
	 unsigned long AuthnSvc,
	 unsigned short * * ServerPrincName
	);

#ifdef UNICODE
#define RpcMgmtInqServerPrincName RpcMgmtInqServerPrincNameW
#else 
#define RpcMgmtInqServerPrincName RpcMgmtInqServerPrincNameA
#endif 

#else 

RPC_STATUS RPC_ENTRY
RpcMgmtInqServerPrincName(
	 RPC_BINDING_HANDLE Binding,
	 unsigned long AuthnSvc,
	 unsigned char * * ServerPrincName
	);

#endif 

#ifdef RPC_UNICODE_SUPPORTED

RPC_STATUS RPC_ENTRY
RpcServerInqDefaultPrincNameA(
	 unsigned long AuthnSvc,
	 unsigned char * * PrincName
	);

RPC_STATUS RPC_ENTRY
RpcServerInqDefaultPrincNameW(
	 unsigned long AuthnSvc,
	 unsigned short * * PrincName
	);

#ifdef UNICODE
#define RpcServerInqDefaultPrincName RpcServerInqDefaultPrincNameW
#else 
#define RpcServerInqDefaultPrincName RpcServerInqDefaultPrincNameA
#endif 
#else 
RPC_STATUS RPC_ENTRY
RpcServerInqDefaultPrincName(
	 unsigned long AuthnSvc,
	 unsigned char * * PrincName
	);
#endif 
RPC_STATUS RPC_ENTRY
RpcEpResolveBinding(
	 RPC_BINDING_HANDLE Binding,
	 RPC_IF_HANDLE IfSpec
	);
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcNsBindingInqEntryNameA(
	 RPC_BINDING_HANDLE Binding,
	 unsigned long EntryNameSyntax,
	 unsigned char * * EntryName
	);
RPC_STATUS RPC_ENTRY RpcNsBindingInqEntryNameW(
	 RPC_BINDING_HANDLE Binding,
	 unsigned long EntryNameSyntax,
	 unsigned short * * EntryName
	);

#ifdef UNICODE
#define RpcNsBindingInqEntryName RpcNsBindingInqEntryNameW
#else 
#define RpcNsBindingInqEntryName RpcNsBindingInqEntryNameA
#endif 
#else 
RPC_STATUS RPC_ENTRY
RpcNsBindingInqEntryName(
	 RPC_BINDING_HANDLE Binding,
	 unsigned long EntryNameSyntax,
	 unsigned char * * EntryName
	);

#endif 
typedef void * RPC_AUTH_IDENTITY_HANDLE;
typedef void * RPC_AUTHZ_HANDLE;
#define RPC_C_AUTHN_LEVEL_DEFAULT 0
#define RPC_C_AUTHN_LEVEL_NONE 1
#define RPC_C_AUTHN_LEVEL_CONNECT 2
#define RPC_C_AUTHN_LEVEL_CALL 3
#define RPC_C_AUTHN_LEVEL_PKT 4
#define RPC_C_AUTHN_LEVEL_PKT_INTEGRITY 5
#define RPC_C_AUTHN_LEVEL_PKT_PRIVACY 6
#define RPC_C_IMP_LEVEL_ANONYMOUS 1
#define RPC_C_IMP_LEVEL_IDENTIFY 2
#define RPC_C_IMP_LEVEL_IMPERSONATE 3
#define RPC_C_IMP_LEVEL_DELEGATE 4
#define RPC_C_QOS_IDENTITY_STATIC 0
#define RPC_C_QOS_IDENTITY_DYNAMIC 1
#define RPC_C_QOS_CAPABILITIES_DEFAULT 0
#define RPC_C_QOS_CAPABILITIES_MUTUAL_AUTH 1
#define RPC_C_PROTECT_LEVEL_DEFAULT(RPC_C_AUTHN_LEVEL_DEFAULT)
#define RPC_C_PROTECT_LEVEL_NONE(RPC_C_AUTHN_LEVEL_NONE)
#define RPC_C_PROTECT_LEVEL_CONNECT(RPC_C_AUTHN_LEVEL_CONNECT)
#define RPC_C_PROTECT_LEVEL_CALL(RPC_C_AUTHN_LEVEL_CALL)
#define RPC_C_PROTECT_LEVEL_PKT(RPC_C_AUTHN_LEVEL_PKT)
#define RPC_C_PROTECT_LEVEL_PKT_INTEGRITY(RPC_C_AUTHN_LEVEL_PKT_INTEGRITY)
#define RPC_C_PROTECT_LEVEL_PKT_PRIVACY(RPC_C_AUTHN_LEVEL_PKT_PRIVACY)
#define RPC_C_AUTHN_NONE 0
#define RPC_C_AUTHN_DCE_PRIVATE 1
#define RPC_C_AUTHN_DCE_PUBLIC 2
#define RPC_C_AUTHN_DEC_PUBLIC 4
#define RPC_C_AUTHN_WINNT 10
#define RPC_C_AUTHN_DEFAULT 0xFFFFFFFF
#define RPC_C_SECURITY_QOS_VERSION L
typedef struct _RPC_SECURITY_QOS {
	unsigned long Version;
	unsigned long Capabilities;
	unsigned long IdentityTracking;
	unsigned long ImpersonationType;
} RPC_SECURITY_QOS,*PRPC_SECURITY_QOS;

#define SEC_WINNT_AUTH_IDENTITY_ANSI 0x1
#define SEC_WINNT_AUTH_IDENTITY_UNICODE 0x2
typedef struct _SEC_WINNT_AUTH_IDENTITY_W {
	unsigned short *User;
	unsigned long UserLength;
	unsigned short *Domain;
	unsigned long DomainLength;
	unsigned short *Password;
	unsigned long PasswordLength;
	unsigned long Flags;
} SEC_WINNT_AUTH_IDENTITY_W,*PSEC_WINNT_AUTH_IDENTITY_W;
typedef struct _SEC_WINNT_AUTH_IDENTITY_A {
	unsigned char *User;
	unsigned long UserLength;
	unsigned char *Domain;
	unsigned long DomainLength;
	unsigned char *Password;
	unsigned long PasswordLength;
	unsigned long Flags;
} SEC_WINNT_AUTH_IDENTITY_A,*PSEC_WINNT_AUTH_IDENTITY_A;
#ifdef UNICODE
#define SEC_WINNT_AUTH_IDENTITY SEC_WINNT_AUTH_IDENTITY_W
#define PSEC_WINNT_AUTH_IDENTITY PSEC_WINNT_AUTH_IDENTITY_W
#define _SEC_WINNT_AUTH_IDENTITY _SEC_WINNT_AUTH_IDENTITY_W
#else 
#define SEC_WINNT_AUTH_IDENTITY SEC_WINNT_AUTH_IDENTITY_A
#define PSEC_WINNT_AUTH_IDENTITY PSEC_WINNT_AUTH_IDENTITY_A
#define _SEC_WINNT_AUTH_IDENTITY _SEC_WINNT_AUTH_IDENTITY_A
#endif 
#define RPC_C_AUTHZ_NONE 0
#define RPC_C_AUTHZ_NAME 1
#define RPC_C_AUTHZ_DCE 2
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcBindingInqAuthClientA(RPC_BINDING_HANDLE,RPC_AUTHZ_HANDLE * , unsigned char * * , unsigned long * , unsigned long * , unsigned long * );
RPC_STATUS RPC_ENTRY RpcBindingInqAuthClientW(RPC_BINDING_HANDLE,RPC_AUTHZ_HANDLE * , unsigned short * * , unsigned long * , unsigned long * , unsigned long *);
RPC_STATUS RPC_ENTRY RpcBindingInqAuthInfoA(RPC_BINDING_HANDLE,unsigned char * *, unsigned long * , unsigned long * , RPC_AUTH_IDENTITY_HANDLE * , unsigned long *);
RPC_STATUS RPC_ENTRY RpcBindingInqAuthInfoW(
	 RPC_BINDING_HANDLE Binding,
	 unsigned short * * ServerPrincName,
	 unsigned long * AuthnLevel,
	 unsigned long * AuthnSvc,
	 RPC_AUTH_IDENTITY_HANDLE * AuthIdentity,
	 unsigned long * AuthzSvc 
	);

RPC_STATUS RPC_ENTRY RpcBindingSetAuthInfoA(
	 RPC_BINDING_HANDLE Binding,
	 unsigned char * ServerPrincName,
	 unsigned long AuthnLevel,
	 unsigned long AuthnSvc,
	 RPC_AUTH_IDENTITY_HANDLE AuthIdentity,
	 unsigned long AuthzSvc
	);

RPC_STATUS RPC_ENTRY RpcBindingSetAuthInfoExA(
	 RPC_BINDING_HANDLE Binding,
	 unsigned char * ServerPrincName,
	 unsigned long AuthnLevel,
	 unsigned long AuthnSvc,
	 RPC_AUTH_IDENTITY_HANDLE AuthIdentity,
	 unsigned long AuthzSvc,
	 RPC_SECURITY_QOS *SecurityQos 
	);

RPC_STATUS RPC_ENTRY RpcBindingSetAuthInfoW(
	 RPC_BINDING_HANDLE Binding,
	 unsigned short * ServerPrincName,
	 unsigned long AuthnLevel,
	 unsigned long AuthnSvc,
	 RPC_AUTH_IDENTITY_HANDLE AuthIdentity,
	 unsigned long AuthzSvc
	);
RPC_STATUS RPC_ENTRY RpcBindingSetAuthInfoExW(
	 RPC_BINDING_HANDLE Binding,
	 unsigned short * ServerPrincName,
	 unsigned long AuthnLevel,
	 unsigned long AuthnSvc,
	 RPC_AUTH_IDENTITY_HANDLE AuthIdentity,
	 unsigned long AuthzSvc,
	 RPC_SECURITY_QOS *SecurityQOS
	);
RPC_STATUS RPC_ENTRY RpcBindingInqAuthInfoExA(
	 RPC_BINDING_HANDLE Binding,
	 unsigned char * * ServerPrincName,
	 unsigned long * AuthnLevel,
	 unsigned long * AuthnSvc,
	 RPC_AUTH_IDENTITY_HANDLE * AuthIdentity,
	 unsigned long * AuthzSvc,
	 unsigned long RpcQosVersion,
	 RPC_SECURITY_QOS *SecurityQOS
	);
RPC_STATUS RPC_ENTRY RpcBindingInqAuthInfoExW(RPC_BINDING_HANDLE,unsigned short * * , unsigned long * , unsigned long * , RPC_AUTH_IDENTITY_HANDLE * , unsigned long * , unsigned long , RPC_SECURITY_QOS *);
typedef void (__RPC_USER * RPC_AUTH_KEY_RETRIEVAL_FN)(void *,unsigned short *, unsigned long , void * * , RPC_STATUS *);
RPC_STATUS RPC_ENTRY RpcServerRegisterAuthInfoA(unsigned char *,unsigned long, RPC_AUTH_KEY_RETRIEVAL_FN, void * );
RPC_STATUS RPC_ENTRY RpcServerRegisterAuthInfoW(unsigned short *,unsigned long,RPC_AUTH_KEY_RETRIEVAL_FN,void *);
#ifdef UNICODE
#define RpcBindingInqAuthClient RpcBindingInqAuthClientW
#define RpcBindingInqAuthInfo RpcBindingInqAuthInfoW
#define RpcBindingSetAuthInfo RpcBindingSetAuthInfoW
#define RpcServerRegisterAuthInfo RpcServerRegisterAuthInfoW
#define RpcBindingInqAuthInfoEx RpcBindingInqAuthInfoExW
#define RpcBindingSetAuthInfoEx RpcBindingSetAuthInfoExW
#else 
#define RpcBindingInqAuthClient RpcBindingInqAuthClientA
#define RpcBindingInqAuthInfo RpcBindingInqAuthInfoA
#define RpcBindingSetAuthInfo RpcBindingSetAuthInfoA
#define RpcServerRegisterAuthInfo RpcServerRegisterAuthInfoA
#define RpcBindingInqAuthInfoEx RpcBindingInqAuthInfoExA
#define RpcBindingSetAuthInfoEx RpcBindingSetAuthInfoExA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcBindingInqAuthClient(RPC_BINDING_HANDLE,RPC_AUTHZ_HANDLE *,unsigned char * *,unsigned long *,unsigned long *,unsigned long *);
RPC_STATUS RPC_ENTRY RpcBindingInqAuthInfo(RPC_BINDING_HANDLE,unsigned char * *,unsigned long *,unsigned long *,RPC_AUTH_IDENTITY_HANDLE *,unsigned long *);
RPC_STATUS RPC_ENTRY RpcBindingSetAuthInfo(RPC_BINDING_HANDLE,unsigned char *,unsigned long,unsigned long,RPC_AUTH_IDENTITY_HANDLE,unsigned long);
typedef void(__RPC_USER * RPC_AUTH_KEY_RETRIEVAL_FN) (void *,unsigned char *,unsigned long,void * *,RPC_STATUS *);
RPC_STATUS RPC_ENTRY RpcServerRegisterAuthInfo(unsigned char *,unsigned long,RPC_AUTH_KEY_RETRIEVAL_FN,void *);
#endif 
typedef struct {
	unsigned char * UserName;
	unsigned char * ComputerName;
	unsigned short Privilege;
	unsigned long AuthFlags;
} RPC_CLIENT_INFORMATION1,* PRPC_CLIENT_INFORMATION1;

RPC_STATUS RPC_ENTRY RpcBindingServerFromClient(RPC_BINDING_HANDLE,RPC_BINDING_HANDLE *);
void RPC_ENTRY RpcRaiseException(RPC_STATUS exception);
RPC_STATUS RPC_ENTRY RpcTestCancel();
RPC_STATUS RPC_ENTRY RpcCancelThread(void * Thread);
RPC_STATUS RPC_ENTRY UuidCreate(UUID * Uuid);
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY UuidToStringA(UUID *,unsigned char * *);
RPC_STATUS RPC_ENTRY UuidFromStringA(unsigned char *,UUID *);
RPC_STATUS RPC_ENTRY UuidToStringW(UUID *,unsigned short * *);
RPC_STATUS RPC_ENTRY UuidFromStringW(unsigned short *,UUID *);
#ifdef UNICODE
#define UuidFromString UuidFromStringW
#define UuidToString UuidToStringW
#else 
#define UuidFromString UuidFromStringA
#define UuidToString UuidToStringA
#endif 

#else 
RPC_STATUS RPC_ENTRY UuidToString(UUID *,unsigned char * *);
RPC_STATUS RPC_ENTRY UuidFromString(unsigned char *,UUID *);
#endif 
signed int RPC_ENTRY UuidCompare(UUID *,UUID *, RPC_STATUS *);
RPC_STATUS RPC_ENTRY UuidCreateNil(UUID *);
int RPC_ENTRY UuidEqual(UUID *,UUID * , RPC_STATUS *);
unsigned short RPC_ENTRY UuidHash(UUID *,RPC_STATUS *);
int RPC_ENTRY UuidIsNil(UUID *,RPC_STATUS *);
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcEpRegisterNoReplaceA(RPC_IF_HANDLE,RPC_BINDING_VECTOR *,UUID_VECTOR * , unsigned char *);
RPC_STATUS RPC_ENTRY RpcEpRegisterNoReplaceW(RPC_IF_HANDLE,RPC_BINDING_VECTOR * , UUID_VECTOR * , unsigned short *);
RPC_STATUS RPC_ENTRY RpcEpRegisterA(RPC_IF_HANDLE,RPC_BINDING_VECTOR * , UUID_VECTOR * , unsigned char *);
RPC_STATUS RPC_ENTRY RpcEpRegisterW(RPC_IF_HANDLE,RPC_BINDING_VECTOR * , UUID_VECTOR * , unsigned short *);
#ifdef UNICODE
#define RpcEpRegisterNoReplace RpcEpRegisterNoReplaceW
#define RpcEpRegister RpcEpRegisterW
#else 
#define RpcEpRegisterNoReplace RpcEpRegisterNoReplaceA
#define RpcEpRegister RpcEpRegisterA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcEpRegisterNoReplace(RPC_IF_HANDLE,RPC_BINDING_VECTOR * , UUID_VECTOR * , unsigned char *);
RPC_STATUS RPC_ENTRY RpcEpRegister(RPC_IF_HANDLE,RPC_BINDING_VECTOR * , UUID_VECTOR * , unsigned char *);
#endif 
RPC_STATUS RPC_ENTRY RpcEpUnregister(RPC_IF_HANDLE,RPC_BINDING_VECTOR *,UUID_VECTOR *);
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY DceErrorInqTextA(RPC_STATUS,unsigned char *);
RPC_STATUS RPC_ENTRY DceErrorInqTextW(RPC_STATUS,unsigned short *);
#ifdef UNICODE
#define DceErrorInqText DceErrorInqTextW
#else 
#define DceErrorInqText DceErrorInqTextA
#endif 
#else 
RPC_STATUS RPC_ENTRY DceErrorInqText(RPC_STATUS,unsigned char *);
#endif 
#define DCE_C_ERROR_STRING_LEN 256
typedef I_RPC_HANDLE * RPC_EP_INQ_HANDLE;
#define RPC_C_EP_ALL_ELTS 0
#define RPC_C_EP_MATCH_BY_IF 1
#define RPC_C_EP_MATCH_BY_OBJ 2
#define RPC_C_EP_MATCH_BY_BOTH 3
#define RPC_C_VERS_ALL 1
#define RPC_C_VERS_COMPATIBLE 2
#define RPC_C_VERS_EXACT 3
#define RPC_C_VERS_MAJOR_ONLY 4
#define RPC_C_VERS_UPTO 5
RPC_STATUS RPC_ENTRY RpcMgmtEpEltInqBegin(RPC_BINDING_HANDLE,unsigned long,RPC_IF_ID *,unsigned long,UUID *,RPC_EP_INQ_HANDLE *);
RPC_STATUS RPC_ENTRY RpcMgmtEpEltInqDone(RPC_EP_INQ_HANDLE *);
#ifdef RPC_UNICODE_SUPPORTED
RPC_STATUS RPC_ENTRY RpcMgmtEpEltInqNextA(RPC_EP_INQ_HANDLE,RPC_IF_ID *,RPC_BINDING_HANDLE *,UUID *,unsigned char * *);
RPC_STATUS RPC_ENTRY RpcMgmtEpEltInqNextW(RPC_EP_INQ_HANDLE,RPC_IF_ID *,RPC_BINDING_HANDLE *,UUID *,unsigned short * *);
#ifdef UNICODE
#define RpcMgmtEpEltInqNext RpcMgmtEpEltInqNextW
#else 
#define RpcMgmtEpEltInqNext RpcMgmtEpEltInqNextA
#endif 
#else 
RPC_STATUS RPC_ENTRY RpcMgmtEpEltInqNext(RPC_EP_INQ_HANDLE,RPC_IF_ID *,RPC_BINDING_HANDLE *,unsigned char * *);
#endif 
RPC_STATUS RPC_ENTRY RpcMgmtEpUnregister(RPC_BINDING_HANDLE,RPC_IF_ID *,RPC_BINDING_HANDLE,UUID *);
typedef int(__RPC_API * RPC_MGMT_AUTHORIZATION_FN) (RPC_BINDING_HANDLE,unsigned long,RPC_STATUS *);
#define RPC_C_MGMT_INQ_IF_IDS 0
#define RPC_C_MGMT_INQ_PRINC_NAME 1
#define RPC_C_MGMT_INQ_STATS 2
#define RPC_C_MGMT_IS_SERVER_LISTEN 3
#define RPC_C_MGMT_STOP_SERVER_LISTEN 4
RPC_STATUS RPC_ENTRY RpcMgmtSetAuthorizationFn(RPC_MGMT_AUTHORIZATION_FN);
#define RPC_C_PARM_MAX_PACKET_LENGTH 1
#define RPC_C_PARM_BUFFER_LENGTH 2
RPC_STATUS RPC_ENTRY RpcMgmtInqParameter(unsigned int,unsigned long *);
RPC_STATUS RPC_ENTRY RpcMgmtSetParameter(unsigned int,unsigned long);
RPC_STATUS RPC_ENTRY RpcMgmtBindingInqParameter(RPC_BINDING_HANDLE,unsigned int,unsigned long *);
RPC_STATUS RPC_ENTRY RpcMgmtBindingSetParameter(RPC_BINDING_HANDLE,unsigned int,unsigned long);
#define RPC_IF_AUTOLISTEN 0x0001
#define RPC_IF_OLE 2
#include <rpcdcep.h>
#endif
