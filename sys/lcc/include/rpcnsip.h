/* $Revision: 1.2 $ */
#ifndef __LCC__RPCNSIP__
#define __LCC__RPCNSIP__
typedef struct {
   RPC_NS_HANDLE        LookupContext;
   RPC_BINDING_HANDLE   ProposedHandle;
   RPC_BINDING_VECTOR * Bindings;
} RPC_IMPORT_CONTEXT_P, * PRPC_IMPORT_CONTEXT_P;
RPC_STATUS RPC_ENTRY I_RpcNsGetBuffer( PRPC_MESSAGE);
RPC_STATUS RPC_ENTRY I_RpcNsSendReceive(PRPC_MESSAGE,RPC_BINDING_HANDLE  *);
void RPC_ENTRY I_RpcNsRaiseException(PRPC_MESSAGE,RPC_STATUS);
RPC_STATUS RPC_ENTRY I_RpcReBindBuffer(PRPC_MESSAGE);
RPC_STATUS RPC_ENTRY I_NsServerBindSearch( );
RPC_STATUS RPC_ENTRY I_NsClientBindSearch( );
void RPC_ENTRY I_NsClientBindDone( );
#endif
