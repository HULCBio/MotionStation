/* $Revision: 1.2 $ */
#ifndef __LCC__RPCDCEP__
#define __LCC__RPCDCEP__
typedef struct _RPC_VERSION { unsigned short MajorVersion; unsigned short MinorVersion; } RPC_VERSION;
typedef struct _RPC_SYNTAX_IDENTIFIER {
	GUID SyntaxGUID;
	RPC_VERSION SyntaxVersion;
} RPC_SYNTAX_IDENTIFIER, * PRPC_SYNTAX_IDENTIFIER;
typedef struct _RPC_MESSAGE {
	HANDLE Handle;
	unsigned long DataRepresentation;
	void * Buffer;
	unsigned int BufferLength;
	unsigned int ProcNum;
	PRPC_SYNTAX_IDENTIFIER TransferSyntax;
	void * RpcInterfaceInformation;
	void * ReservedForRuntime;
	void * ManagerEpv;
	void * ImportContext;
	unsigned long RpcFlags;
} RPC_MESSAGE, * PRPC_MESSAGE;
typedef long _stdcall RPC_FORWARD_FUNCTION(GUID *,RPC_VERSION *,GUID *,unsigned char *, void **);
#define RPC_NCA_FLAGS_DEFAULT 0 
#define RPC_NCA_FLAGS_IDEMPOTENT 1 
#define RPC_NCA_FLAGS_BROADCAST 2 
#define RPC_NCA_FLAGS_MAYBE 4 
#define RPCFLG_ASYNCHRONOUS 0x40000000
#define RPCFLG_INPUT_SYNCHRONOUS 0x20000000
#define RPC_FLAGS_VALID_BIT 0x00008000
typedef void(_stdcall * RPC_DISPATCH_FUNCTION) ( PRPC_MESSAGE Message);
typedef struct {
	unsigned int DispatchTableCount;
	RPC_DISPATCH_FUNCTION * DispatchTable;
	int Reserved;
} RPC_DISPATCH_TABLE, * PRPC_DISPATCH_TABLE;
typedef struct _RPC_PROTSEQ_ENDPOINT {
	unsigned char * RpcProtocolSequence;
	unsigned char * Endpoint;
} RPC_PROTSEQ_ENDPOINT, * PRPC_PROTSEQ_ENDPOINT;
typedef struct _RPC_SERVER_INTERFACE {
	unsigned int Length;
	RPC_SYNTAX_IDENTIFIER InterfaceId;
	RPC_SYNTAX_IDENTIFIER TransferSyntax;
	PRPC_DISPATCH_TABLE DispatchTable;
	unsigned int RpcProtseqEndpointCount;
	PRPC_PROTSEQ_ENDPOINT RpcProtseqEndpoint;
	void *DefaultManagerEpv;
	void const *InterpreterInfo;
} RPC_SERVER_INTERFACE, * PRPC_SERVER_INTERFACE;
typedef struct _RPC_CLIENT_INTERFACE {
	unsigned int Length;
	RPC_SYNTAX_IDENTIFIER InterfaceId;
	RPC_SYNTAX_IDENTIFIER TransferSyntax;
	PRPC_DISPATCH_TABLE DispatchTable;
	unsigned int RpcProtseqEndpointCount;
	PRPC_PROTSEQ_ENDPOINT RpcProtseqEndpoint;
	unsigned long Reserved;
	void const * InterpreterInfo;
} RPC_CLIENT_INTERFACE, * PRPC_CLIENT_INTERFACE;
long _stdcall I_RpcGetBuffer( RPC_MESSAGE * Message);
long _stdcall I_RpcSendReceive( RPC_MESSAGE * Message);
long _stdcall I_RpcFreeBuffer( RPC_MESSAGE * Message);
typedef void * I_RPC_MUTEX;
void _stdcall I_RpcRequestMutex( I_RPC_MUTEX * Mutex);
void _stdcall I_RpcClearMutex( I_RPC_MUTEX Mutex);
void _stdcall I_RpcDeleteMutex( I_RPC_MUTEX Mutex);
void * _stdcall I_RpcAllocate( unsigned int Size);
void _stdcall I_RpcFree( void *);
void _stdcall I_RpcPauseExecution( unsigned long);
typedef void(_stdcall * PRPC_RUNDOWN) ( void * AssociationContext);
long _stdcall I_RpcMonitorAssociation( HANDLE Handle, PRPC_RUNDOWN RundownRoutine, void * Context);
long _stdcall I_RpcStopMonitorAssociation( HANDLE Handle);
HANDLE _stdcall I_RpcGetCurrentCallHandle( void);
long _stdcall I_RpcGetAssociationContext( void * * AssociationContext);
long _stdcall I_RpcSetAssociationContext( void * AssociationContext);
#ifdef __RPC_NT__
long _stdcall I_RpcNsBindingSetEntryName( HANDLE Binding, unsigned long EntryNameSyntax, unsigned short * EntryName);
#else 
long _stdcall I_RpcNsBindingSetEntryName( HANDLE Binding, unsigned long EntryNameSyntax, unsigned char * EntryName);
#endif 
#ifdef __RPC_NT__
long _stdcall I_RpcBindingInqDynamicEndpoint( HANDLE Binding, unsigned short * * DynamicEndpoint);
#else 
long _stdcall I_RpcBindingInqDynamicEndpoint( HANDLE Binding, unsigned char * * DynamicEndpoint);
#endif 
#define TRANSPORT_TYPE_CN 1
#define TRANSPORT_TYPE_DG 2
#define TRANSPORT_TYPE_LPC 4
#define TRANSPORT_TYPE_WMSG 8
long _stdcall I_RpcBindingInqTransportType( HANDLE Binding, unsigned int * Type);
typedef struct _RPC_TRANSFER_SYNTAX {
	GUID Uuid;
	unsigned short VersMajor;
	unsigned short VersMinor;
} RPC_TRANSFER_SYNTAX;
long _stdcall I_RpcIfInqTransferSyntaxes(HANDLE,RPC_TRANSFER_SYNTAX *,unsigned int, unsigned int *);
long _stdcall I_UuidCreate( GUID * Uuid);
long _stdcall I_RpcBindingCopy( HANDLE SourceBinding, HANDLE * DestinationBinding);
long _stdcall I_RpcBindingIsClientLocal( HANDLE BindingHandle, unsigned int * ClientLocalFlag);
void _stdcall I_RpcSsDontSerializeContext( void);
long _stdcall I_RpcServerRegisterForwardFunction( RPC_FORWARD_FUNCTION * pForwardFunction);
long _stdcall I_RpcConnectionInqSockBuffSize( unsigned long * RecvBuffSize, unsigned long * SendBuffSize);
long _stdcall I_RpcConnectionSetSockBuffSize( unsigned long RecvBuffSize, unsigned long SendBuffSize);
#ifdef __RPC_WIN32__
typedef long(_stdcall * RPC_BLOCKING_FUNCTION) ( void *RpcWindowHandle, void *Context);
long _stdcall I_RpcBindingSetAsync( HANDLE Binding, RPC_BLOCKING_FUNCTION BlockingHook);
long _stdcall I_RpcAsyncSendReceive( RPC_MESSAGE * Message, void * Context);
long _stdcall I_RpcGetThreadWindowHandle( void * * WindowHandle);
long _stdcall I_RpcServerThreadPauseListening();
long _stdcall I_RpcServerThreadContinueListening();
long _stdcall I_RpcServerUnregisterEndpointA(unsigned char *, unsigned char *);
long _stdcall I_RpcServerUnregisterEndpointW(unsigned short *,unsigned short *);
#ifdef UNICODE
#define I_RpcServerUnregisterEndpoint I_RpcServerUnregisterEndpointW
#else
#define I_RpcServerUnregisterEndpoint I_RpcServerUnregisterEndpointA
#endif
#endif 
#endif 
