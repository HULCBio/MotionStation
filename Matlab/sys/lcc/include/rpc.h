#include <windows.h>
#ifndef __LCC_RPC_
#define __LCC_RPC_
#define __RPC_WIN32__
#define __RPC_NT__
#ifndef __MIDL_USER_DEFINED
#define midl_user_allocate MIDL_user_allocate
#define midl_user_free     MIDL_user_free
#define __MIDL_USER_DEFINED
#endif
typedef void * I_RPC_HANDLE;
typedef long RPC_STATUS;
#define RPC_UNICODE_SUPPORTED
#define __RPC_FAR
#define __RPC_API  _stdcall
#define __RPC_USER _stdcall
#define __RPC_STUB _stdcall
#define RPC_ENTRY  _stdcall
#ifdef IN
#undef IN
#undef OUT
#undef OPTIONAL
#endif
#include <rpcdce.h>
#include <rpcnsi.h>
#include <rpcnterr.h>
#include <excpt.h>
#include <winerror.h>
#define RpcTryExcept  __try  { 
#define RpcExcept(expr)  }  __except (expr)  {
#define RpcEndExcept  }
#define RpcTryFinally  __try  {
#define RpcFinally  }  __finally  {
#define RpcEndFinally  }
#define RpcExceptionCode() GetExceptionCode()
#define RpcAbnormalTermination() AbnormalTermination()
RPC_STATUS RPC_ENTRY RpcImpersonateClient ( RPC_BINDING_HANDLE);
RPC_STATUS RPC_ENTRY RpcRevertToSelfEx (RPC_BINDING_HANDLE);
RPC_STATUS RPC_ENTRY RpcRevertToSelf ( );
long RPC_ENTRY I_RpcMapWin32Status (RPC_STATUS Status );
#endif
