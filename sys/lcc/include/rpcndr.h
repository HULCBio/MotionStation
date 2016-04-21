/* $Revision: 1.2 $ */
#ifndef _LCC__RPCNDR__
#define _LCC__RPCNDR__

#ifndef __LCC_RPCBASE__
#include <rpcbase.h>
#endif
#include <rpcnsip.h>
#define NDR_CHAR_REP_MASK (unsigned long)0X0000000FL
#define NDR_INT_REP_MASK (unsigned long)0X000000F0L
#define NDR_FLOAT_REP_MASK (unsigned long)0X0000FF00L
#define NDR_LITTLE_ENDIAN (unsigned long)0X00000010L
#define NDR_BIG_ENDIAN (unsigned long)0X00000000L
#define NDR_IEEE_FLOAT (unsigned long)0X00000000L
#define NDR_VAX_FLOAT (unsigned long)0X00000100L
#define NDR_ASCII_CHAR (unsigned long)0X00000000L
#define NDR_EBCDIC_CHAR (unsigned long)0X00000001L
#define NDR_LOCAL_DATA_REPRESENTATION (unsigned long)0X00000010L
#define NDR_LOCAL_ENDIAN NDR_LITTLE_ENDIAN
#define small char
typedef unsigned char boolean;
#ifndef _HYPER_DEFINED
#define _HYPER_DEFINED
typedef double hyper;
typedef double MIDL_uhyper;
#endif 
#ifndef _WCHAR_T_DEFINED
typedef unsigned short wchar_t;
#define _WCHAR_T_DEFINED
#endif
#ifndef _SIZE_T_DEFINED
typedef unsigned int size_t;
#define _SIZE_T_DEFINED
#endif
#define __RPC_CALLEE __stdcall
#ifndef __MIDL_USER_DEFINED
#define midl_user_allocate MIDL_user_allocate
#define midl_user_free MIDL_user_free
#define __MIDL_USER_DEFINED
#endif
#ifndef __MIDL_USER_ALLOCATE_DEFINED
#define __MIDL_USER_ALLOCATE_DEFINED
void* _stdcall MIDL_user_allocate(int);
void _stdcall MIDL_user_free(void*); 
#endif
#define RPC_VAR_ENTRY
#if defined(_M_MRX000) || defined(_M_IX86) || defined(_M_ALPHA)
#define __MIDL_DECLSPEC_DLLIMPORT __declspec(dllimport)
#define __MIDL_DECLSPEC_DLLEXPORT __declspec(dllexport)
#else
#define __MIDL_DECLSPEC_DLLIMPORT
#define __MIDL_DECLSPEC_DLLEXPORT
#endif
typedef void * NDR_CCONTEXT;
typedef struct {
	void * pad[2];
	void * userContext;
	} * NDR_SCONTEXT;
#define NDRSContextValue(hContext) (&(hContext)->userContext)
#define cbNDRContext 20 
typedef void (__RPC_USER _stdcall* NDR_RUNDOWN)(void * context);
typedef struct _SCONTEXT_QUEUE {
	unsigned long NumberOfObjects;
	NDR_SCONTEXT* ArrayOfObjects;
	} SCONTEXT_QUEUE,* PSCONTEXT_QUEUE;
RPC_BINDING_HANDLE RPC_ENTRY NDRCContextBinding (NDR_CCONTEXT CContext);
void RPC_ENTRY NDRCContextMarshall (NDR_CCONTEXT, void *);
void RPC_ENTRY NDRCContextUnmarshall(NDR_CCONTEXT *,RPC_BINDING_HANDLE,void *,unsigned long);
void RPC_ENTRY NDRSContextMarshall (NDR_SCONTEXT,void *,NDR_RUNDOWN);
NDR_SCONTEXT RPC_ENTRY NDRSContextUnmarshall (void *,unsigned long);
void RPC_ENTRY RpcSsDestroyClientContext (void * * ContextHandle);
#define byte_from_ndr(s, t) {*(t) = *(*(char * *)&(s)->Buffer)++; }
#define byte_array_from_ndr(S,L,U,T) {NDRcopy ((((char _stdcall*)(T))+(L)),(S)->Buffer,(unsigned int)((U)-(L))); *(unsigned long _stdcall *)&(S)->Buffer += ((U)-(L));}
#define boolean_from_ndr(s, t) {*(t) = *(*(char _stdcall * *)&(s)->Buffer)++; }
#define boolean_array_from_ndr(S, L, U, T) { NDRcopy ((((char _stdcall*)(T))+(L)),(S)->Buffer, (unsigned int)((U)-(L))); *(unsigned long _stdcall *)&(S)->Buffer += ((U)-(L));}
#define small_from_ndr(s,t) {*(t) = *(*(char _stdcall * *)&(s)->Buffer)++; }
#define small_from_ndr_temp(s, target, format) {*(t) = *(*(char _stdcall * *)(s))++; }
#define small_array_from_ndr(S, L, U, T) { NDRcopy((((char _stdcall*)(T))+(L)),(S)->Buffer,(unsigned int)((U)-(L))); *(unsigned long _stdcall *)&(S)->Buffer += ((U)-(L));}
#define MIDL_ascii_strlen(string) strlen(string)
#define MIDL_ascii_strcpy(target,source) strcpy(target,source)
#define MIDL_memset(s,c,n) memset(s,c,n)
void RPC_ENTRY NDRcopy (void *, void *, unsigned int);
size_t RPC_ENTRY MIDL_wchar_strlen (unsigned short*);
void RPC_ENTRY MIDL_wchar_strcpy (void *,unsigned short *);
void RPC_ENTRY char_from_ndr (PRPC_MESSAGE SourceMessage, unsigned char* Target);
void RPC_ENTRY char_array_from_ndr (PRPC_MESSAGE SourceMessage, unsigned long LowerIndex, unsigned long UpperIndex, unsigned char* Target);
void RPC_ENTRY short_from_ndr (PRPC_MESSAGE source, unsigned short* target);
void RPC_ENTRY short_array_from_ndr(PRPC_MESSAGE SourceMessage, unsigned long LowerIndex, unsigned long UpperIndex, unsigned short* Target);
void RPC_ENTRY short_from_ndr_temp (unsigned char* * source, unsigned short * target, unsigned long format); 
void RPC_ENTRY long_from_ndr (PRPC_MESSAGE source, unsigned long * target);
void RPC_ENTRY long_array_from_ndr(PRPC_MESSAGE SourceMessage, unsigned long LowerIndex, unsigned long UpperIndex, unsigned long * Target); 
void RPC_ENTRY long_from_ndr_temp (unsigned char* * source, unsigned long * target, unsigned long format);
void RPC_ENTRY enum_from_ndr(PRPC_MESSAGE SourceMessage, unsigned int* Target);
void RPC_ENTRY float_from_ndr (PRPC_MESSAGE SourceMessage, void* Target);
void RPC_ENTRY float_array_from_ndr (PRPC_MESSAGE SourceMessage, unsigned long LowerIndex, unsigned long UpperIndex, void* Target);
void RPC_ENTRY double_from_ndr (PRPC_MESSAGE SourceMessage, void * Target);
void RPC_ENTRY double_array_from_ndr (PRPC_MESSAGE SourceMessage, unsigned long LowerIndex, unsigned long UpperIndex, void* Target);
void RPC_ENTRY hyper_from_ndr (PRPC_MESSAGE source, hyper * target);
void RPC_ENTRY hyper_array_from_ndr(PRPC_MESSAGE SourceMessage, unsigned long LowerIndex, unsigned long UpperIndex, hyper * Target); 
void RPC_ENTRY hyper_from_ndr_temp (unsigned char* * source, hyper * target, unsigned long format);
void RPC_ENTRY data_from_ndr (PRPC_MESSAGE source, void* target, char * format, unsigned char MscPak);
void RPC_ENTRY data_into_ndr (void* source, PRPC_MESSAGE target, char * format, unsigned char MscPak);
void RPC_ENTRY tree_into_ndr (void* source, PRPC_MESSAGE target, char * format, unsigned char MscPak);
void RPC_ENTRY data_size_ndr (void* source, PRPC_MESSAGE target, char * format, unsigned char MscPak);
void RPC_ENTRY tree_size_ndr (void* source, PRPC_MESSAGE target, char * format, unsigned char MscPak);
void RPC_ENTRY tree_peek_ndr (PRPC_MESSAGE source, unsigned char * * buffer, char * format, unsigned char MscPak);
void * RPC_ENTRY midl_allocate (size_t size);
typedef unsigned long error_status_t;
#define _midl_ma1(p, cast)*(*( cast **)&p)++
#define _midl_ma2(p, cast)*(*( cast **)&p)++
#define _midl_ma4(p, cast)*(*( cast **)&p)++
#define _midl_ma8(p, cast)*(*( cast **)&p)++
#define _midl_unma1(p, cast)*(( cast *)p)++
#define _midl_unma2(p, cast)*(( cast *)p)++
#define _midl_unma3(p, cast)*(( cast *)p)++
#define _midl_unma4(p, cast)*(( cast *)p)++
#define _midl_fa2(p) (p = (RPC_BUFPTR )((unsigned long)(p+1) & 0xfffffffe))
#define _midl_fa4(p) (p = (RPC_BUFPTR )((unsigned long)(p+3) & 0xfffffffc))
#define _midl_fa8(p) (p = (RPC_BUFPTR )((unsigned long)(p+7) & 0xfffffff8))
#define _midl_addp(p, n) (p += n)
#define _midl_marsh_lhs(p, cast)*(*( cast **)&p)++
#define _midl_marsh_up(mp, p)*(*(unsigned long **)&mp)++ = (unsigned long)p
#define _midl_advmp(mp)*(*(unsigned long **)&mp)++
#define _midl_unmarsh_up(p) (*(*(unsigned long**)&p)++) 
#define NdrMarshConfStringHdr(p, s, l) (_midl_ma4( p, unsigned long) = s, _midl_ma4( p, unsigned long) = 0, _midl_ma4( p, unsigned long) = l) 
#define NdrUnMarshConfStringHdr(p, s, l) ((s=_midl_unma4(p,unsigned long), (_midl_addp(p,4)), (l=_midl_unma4(p,unsigned long))
#define NdrMarshCCtxtHdl(pc,p) (NDRCContextMarshall((NDR_CCONTEXT)pc, p),p+20)
#define NdrUnMarshCCtxtHdl(pc,p,h,drep) (NDRCContextUnmarshall((NDR_CONTEXT)pc,h,p,drep), p+20)
#define NdrUnMarshSCtxtHdl(pc, p,drep) (pc = NdrSContextUnMarshall(p,drep))
#define NdrMarshSCtxtHdl(pc,p,rd) (NdrSContextMarshall((NDR_SCONTEXT)pc,p, (NDR_RUNDOWN)rd)
#define NdrFieldOffset(s,f) (long)(& (((s _stdcall*)0)->f))
#define NdrFieldPad(s,f,p,t) (NdrFieldOffset(s,f) - NdrFieldOffset(s,p) - sizeof(t))
#if defined(__RPC_MAC__)
#define NdrFcShort(s) (unsigned char)(s >> 8), (unsigned char)(s & 0xff)
#define NdrFcLong(s) (unsigned char)(s >> 24), (unsigned char)((s & 0x00ff0000) >> 16), (unsigned char)((s & 0x0000ff00) >> 8), (unsigned char)(s & 0xff)
#else
#define NdrFcShort(s) (unsigned char)(s & 0xff), (unsigned char)(s >> 8)
#define NdrFcLong(s) (unsigned char)(s & 0xff), (unsigned char)((s & 0x0000ff00) >> 8), (unsigned char)((s & 0x00ff0000) >> 16), (unsigned char)(s >> 24)
#endif
struct _MIDL_STUB_MESSAGE;
struct _MIDL_STUB_DESC;
struct _FULL_PTR_XLAT_TABLES;
typedef unsigned char* RPC_BUFPTR;
typedef unsigned long RPC_LENGTH;
typedef void (__RPC_USER _stdcall* EXPR_EVAL)(struct _MIDL_STUB_MESSAGE *);
typedef const unsigned char* PFORMAT_STRING;
typedef struct {
	long Dimension;
	unsigned long* BufferConformanceMark;
	unsigned long* BufferVarianceMark;
	unsigned long* MaxCountArray;
	unsigned long* OffsetArray;
	unsigned long* ActualCountArray;
	} ARRAY_INFO,*PARRAY_INFO;
#pragma pack(push,4)
typedef struct _MIDL_STUB_MESSAGE {
	PRPC_MESSAGE RpcMsg;
	unsigned char* Buffer;
	unsigned char* BufferStart;
	unsigned char* BufferEnd;
	unsigned char* BufferMark;
	unsigned long BufferLength;
	unsigned long MemorySize;
	unsigned char* Memory;
	int IsClient;
	int ReuseBuffer; 
	unsigned char* AllocAllNodesMemory;
	unsigned char* AllocAllNodesMemoryEnd;
	int IgnoreEmbeddedPointers;
	unsigned char* PointerBufferMark;
	unsigned char fBufferValid;
	unsigned char Unused;
	unsigned long MaxCount;
	unsigned long Offset;
	unsigned long ActualCount;
	void* (_stdcall * pfnAllocate)(size_t);
	void (_stdcall* pfnFree)(void *);
	unsigned char* StackTop;
	unsigned char* pPresentedType;
	unsigned char* pTransmitType;
	handle_t SavedHandle;
	const struct _MIDL_STUB_DESC* StubDesc;
	struct _FULL_PTR_XLAT_TABLES* FullPtrXlatTables;
	unsigned long FullPtrRefId;
	int fCheckBounds;
	int fInDontFree :1;
	int fDontCallFreeInst :1;
	int fInOnlyParam :1;
	int fHasReturn :1;
	unsigned long dwDestContext;
	void* pvDestContext;
	NDR_SCONTEXT* SavedContextHandles;
	long ParamNumber;
	struct IRpcChannelBuffer* pRpcChannelBuffer;
	PARRAY_INFO pArrayInfo;
	unsigned long* SizePtrCountArray;
	unsigned long* SizePtrOffsetArray;
	unsigned long* SizePtrLengthArray;
	void* pArgQueue;
	unsigned long dwStubPhase;
	unsigned long Reserved[5];
	} MIDL_STUB_MESSAGE, *PMIDL_STUB_MESSAGE;
#pragma pack(pop)
typedef void * (_stdcall __RPC_API * GENERIC_BINDING_ROUTINE) (void *);
typedef void (_stdcall __RPC_API* GENERIC_UNBIND_ROUTINE) (void *, unsigned char *);
typedef struct _GENERIC_BINDING_ROUTINE_PAIR {
	GENERIC_BINDING_ROUTINE pfnBind;
	GENERIC_UNBIND_ROUTINE pfnUnbind;
	} GENERIC_BINDING_ROUTINE_PAIR,*PGENERIC_BINDING_ROUTINE_PAIR;
typedef struct __GENERIC_BINDING_INFO {
	void* pObj;
	unsigned int Size;
	GENERIC_BINDING_ROUTINE pfnBind;
	GENERIC_UNBIND_ROUTINE pfnUnbind;
	} GENERIC_BINDING_INFO,*PGENERIC_BINDING_INFO;
typedef void (_stdcall __RPC_USER* XMIT_HELPER_ROUTINE)(PMIDL_STUB_MESSAGE);
typedef struct _XMIT_ROUTINE_QUINTUPLE {
	XMIT_HELPER_ROUTINE pfnTranslateToXmit;
	XMIT_HELPER_ROUTINE pfnTranslateFromXmit;
	XMIT_HELPER_ROUTINE pfnFreeXmit;
	XMIT_HELPER_ROUTINE pfnFreeInst;
	} XMIT_ROUTINE_QUINTUPLE,*PXMIT_ROUTINE_QUINTUPLE;
typedef struct _MALLOC_FREE_STRUCT {
	void *	(_stdcall * pfnAllocate)(size_t);
	void (_stdcall __RPC_USER* pfnFree)(void *);
	} MALLOC_FREE_STRUCT;
typedef struct _COMM_FAULT_OFFSETS {
	short CommOffset;
	short FaultOffset;
	} COMM_FAULT_OFFSETS;
typedef struct _MIDL_STUB_DESC {
	void* RpcInterfaceInformation;
	void* (__RPC_API * pfnAllocate)(size_t);
	void (_stdcall __RPC_API* pfnFree)(void *);
	union {
	handle_t * pAutoHandle;
	handle_t * pPrimitiveHandle;
	PGENERIC_BINDING_INFO pGenericBindingInfo;
	} IMPLICIT_HANDLE_INFO;
	const NDR_RUNDOWN * apfnNdrRundownRoutines;
	const GENERIC_BINDING_ROUTINE_PAIR * aGenericBindingRoutinePairs;
	const EXPR_EVAL * apfnExprEval;
	const XMIT_ROUTINE_QUINTUPLE * aXmitQuintuple;
	const unsigned char * pFormatTypes;
	int fCheckBounds;
	unsigned long Version;
	MALLOC_FREE_STRUCT* pMallocFreeStruct;
	long MIDLVersion;
	const COMM_FAULT_OFFSETS * CommFaultOffsets;
	} MIDL_STUB_DESC; 
typedef const MIDL_STUB_DESC * PMIDL_STUB_DESC;
typedef void* PMIDL_XMIT_TYPE;
typedef struct _MIDL_FORMAT_STRING {
	short Pad;
	unsigned char Format[1];
	} MIDL_FORMAT_STRING;
typedef void (_stdcall __RPC_API* STUB_THUNK)(PMIDL_STUB_MESSAGE);
typedef long (_stdcall __RPC_API* SERVER_ROUTINE)();
typedef struct _MIDL_SERVER_INFO_ {
	PMIDL_STUB_DESC pStubDesc;
	const SERVER_ROUTINE* DispatchTable;
	PFORMAT_STRING ProcString;
	const unsigned short* FmtStringOffset;
	const STUB_THUNK* ThunkTable;
	} MIDL_SERVER_INFO,*PMIDL_SERVER_INFO;
typedef struct _MIDL_STUBLESS_PROXY_INFO {
	PMIDL_STUB_DESC pStubDesc;
	PFORMAT_STRING ProcFormatString;
	const unsigned short * FormatStringOffset;
	} MIDL_STUBLESS_PROXY_INFO;
typedef MIDL_STUBLESS_PROXY_INFO* PMIDL_STUBLESS_PROXY_INFO;
typedef union _CLIENT_CALL_RETURN {
	void* Pointer;
	long Simple;
	} CLIENT_CALL_RETURN;
typedef enum {
	XLAT_SERVER = 1,
	XLAT_CLIENT
	} XLAT_SIDE;
typedef struct _FULL_PTR_TO_REFID_ELEMENT {
	struct _FULL_PTR_TO_REFID_ELEMENT* Next;
	void * Pointer;
	unsigned long RefId;
	unsigned char State;
	} FULL_PTR_TO_REFID_ELEMENT,*PFULL_PTR_TO_REFID_ELEMENT;
typedef struct _FULL_PTR_XLAT_TABLES {
	struct {
	void * * XlatTable;
	unsigned char * StateTable;
	unsigned long NumberOfEntries;
	} RefIdToPointer;
	struct {
	PFULL_PTR_TO_REFID_ELEMENT * XlatTable;
	unsigned long NumberOfBuckets;
	unsigned long HashMask;
	} PointerToRefId;
	unsigned long NextRefId;
	XLAT_SIDE XlatSide;
	} FULL_PTR_XLAT_TABLES, *PFULL_PTR_XLAT_TABLES;
void RPC_ENTRY NdrSimpleTypeMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, unsigned char FormatChar);
unsigned char * RPC_ENTRY NdrPointerMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrSimpleStructMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrConformantStructMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrConformantVaryingStructMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrHardStructMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrComplexStructMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrFixedArrayMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrConformantArrayMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrConformantVaryingArrayMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrVaryingArrayMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrComplexArrayMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrNonConformantStringMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrConformantStringMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrEncapsulatedUnionMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrNonEncapsulatedUnionMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrByteCountPointerMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrXmitOrRepAsMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned char * RPC_ENTRY NdrInterfacePointerMarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrClientContextMarshall(PMIDL_STUB_MESSAGE pStubMsg, NDR_CCONTEXT ContextHandle, int fCheck);
void RPC_ENTRY NdrServerContextMarshall(PMIDL_STUB_MESSAGE pStubMsg, NDR_SCONTEXT ContextHandle, NDR_RUNDOWN RundownRoutine);
void RPC_ENTRY NdrSimpleTypeUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, unsigned char FormatChar);
unsigned char* RPC_ENTRY NdrPointerUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrSimpleStructUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrConformantStructUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrConformantVaryingStructUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrHardStructUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrComplexStructUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrFixedArrayUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrConformantArrayUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrConformantVaryingArrayUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrVaryingArrayUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrComplexArrayUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrNonConformantStringUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrConformantStringUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrEncapsulatedUnionUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrNonEncapsulatedUnionUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc); 
unsigned char* RPC_ENTRY NdrByteCountPointerUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc); 
unsigned char* RPC_ENTRY NdrXmitOrRepAsUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc);
unsigned char* RPC_ENTRY NdrInterfacePointerUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * ppMemory, PFORMAT_STRING pFormat, unsigned char fMustAlloc); 
void RPC_ENTRY NdrClientContextUnmarshall(PMIDL_STUB_MESSAGE pStubMsg, NDR_CCONTEXT * pContextHandle, RPC_BINDING_HANDLE BindHandle); 
NDR_SCONTEXT RPC_ENTRY NdrServerContextUnmarshall(PMIDL_STUB_MESSAGE pStubMsg); 
void RPC_ENTRY NdrPointerBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrSimpleStructBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrConformantStructBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrConformantVaryingStructBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrHardStructBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrComplexStructBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrFixedArrayBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrConformantArrayBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrConformantVaryingArrayBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrVaryingArrayBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrComplexArrayBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrConformantStringBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrNonConformantStringBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrEncapsulatedUnionBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrNonEncapsulatedUnionBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrByteCountPointerBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrXmitOrRepAsBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrInterfacePointerBufferSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrContextHandleSize(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
unsigned long RPC_ENTRY NdrPointerMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat);
unsigned long RPC_ENTRY NdrSimpleStructMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat);
unsigned long RPC_ENTRY NdrConformantStructMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat);
unsigned long RPC_ENTRY NdrConformantVaryingStructMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat);
unsigned long RPC_ENTRY NdrHardStructMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat);
unsigned long RPC_ENTRY NdrComplexStructMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat);
unsigned long RPC_ENTRY NdrFixedArrayMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat);
unsigned long RPC_ENTRY NdrConformantArrayMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat );
unsigned long RPC_ENTRY NdrConformantVaryingArrayMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat );
unsigned long RPC_ENTRY NdrVaryingArrayMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat );
unsigned long RPC_ENTRY NdrComplexArrayMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat );
unsigned long RPC_ENTRY NdrConformantStringMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat );
unsigned long RPC_ENTRY NdrNonConformantStringMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat ); 
unsigned long RPC_ENTRY NdrEncapsulatedUnionMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat );
unsigned long RPC_ENTRY NdrNonEncapsulatedUnionMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat );
unsigned long RPC_ENTRY NdrXmitOrRepAsMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat ); 
unsigned long RPC_ENTRY NdrInterfacePointerMemorySize(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat); 
void RPC_ENTRY NdrPointerFree(PMIDL_STUB_MESSAGE,unsigned char * ,PFORMAT_STRING);
void RPC_ENTRY NdrSimpleStructFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrConformantStructFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrConformantVaryingStructFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrHardStructFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrComplexStructFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrFixedArrayFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrConformantArrayFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrConformantVaryingArrayFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char* pMemory, PFORMAT_STRING pFormat); 
void RPC_ENTRY NdrVaryingArrayFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char* pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrComplexArrayFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char* pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrEncapsulatedUnionFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char* pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrNonEncapsulatedUnionFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char* pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrByteCountPointerFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char* pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrXmitOrRepAsFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char* pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrInterfacePointerFree(PMIDL_STUB_MESSAGE pStubMsg, unsigned char* pMemory, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrConvert(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat);
void RPC_ENTRY NdrClientInitializeNew(PRPC_MESSAGE pRpcMsg, PMIDL_STUB_MESSAGE pStubMsg, PMIDL_STUB_DESC pStubDescriptor, unsigned int ProcNum);
unsigned char* RPC_ENTRY NdrServerInitializeNew(PRPC_MESSAGE pRpcMsg, PMIDL_STUB_MESSAGE pStubMsg, PMIDL_STUB_DESC pStubDescriptor);
void RPC_ENTRY NdrClientInitialize(PRPC_MESSAGE pRpcMsg, PMIDL_STUB_MESSAGE pStubMsg, PMIDL_STUB_DESC pStubDescriptor, unsigned int ProcNum);
unsigned char * RPC_ENTRY NdrServerInitialize(PRPC_MESSAGE pRpcMsg, PMIDL_STUB_MESSAGE pStubMsg, PMIDL_STUB_DESC pStubDescriptor);
unsigned char * RPC_ENTRY NdrServerInitializeUnmarshall (PMIDL_STUB_MESSAGE pStubMsg, PMIDL_STUB_DESC pStubDescriptor, PRPC_MESSAGE pRpcMsg);
void RPC_ENTRY NdrServerInitializeMarshall (PRPC_MESSAGE pRpcMsg, PMIDL_STUB_MESSAGE pStubMsg);
unsigned char * RPC_ENTRY NdrGetBuffer(PMIDL_STUB_MESSAGE pStubMsg, unsigned long BufferLength, RPC_BINDING_HANDLE Handle);
unsigned char * RPC_ENTRY NdrNsGetBuffer(PMIDL_STUB_MESSAGE pStubMsg, unsigned long BufferLength, RPC_BINDING_HANDLE Handle);
unsigned char * RPC_ENTRY NdrSendReceive(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pBufferEnd);
unsigned char * RPC_ENTRY NdrNsSendReceive(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * pBufferEnd, RPC_BINDING_HANDLE * pAutoHandle);
void RPC_ENTRY NdrFreeBuffer(PMIDL_STUB_MESSAGE pStubMsg);
CLIENT_CALL_RETURN RPC_VAR_ENTRY NdrClientCall(PMIDL_STUB_DESC pStubDescriptor, PFORMAT_STRING pFormat, ... );
typedef enum {
	STUB_UNMARSHAL,
	STUB_CALL_SERVER,
	STUB_MARSHAL,
	STUB_CALL_SERVER_NO_HRESULT
}STUB_PHASE;
typedef enum {
	PROXY_CALCSIZE,
	PROXY_GETBUFFER,
	PROXY_MARSHAL,
	PROXY_SENDRECEIVE,
	PROXY_UNMARSHAL
}PROXY_PHASE;
long RPC_ENTRY NdrStubCall (struct IRpcStubBuffer* pThis, struct IRpcChannelBuffer * pChannel, PRPC_MESSAGE pRpcMsg, unsigned long * pdwStubPhase); 
void RPC_ENTRY NdrServerCall(PRPC_MESSAGE pRpcMsg);
int RPC_ENTRY NdrServerUnmarshall(struct IRpcChannelBuffer* pChannel, PRPC_MESSAGE pRpcMsg, PMIDL_STUB_MESSAGE pStubMsg, PMIDL_STUB_DESC pStubDescriptor, PFORMAT_STRING pFormat, void * pParamList);
void RPC_ENTRY NdrServerMarshall(struct IRpcStubBuffer * pThis, struct IRpcChannelBuffer * pChannel, PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat);
RPC_STATUS RPC_ENTRY NdrMapCommAndFaultStatus(PMIDL_STUB_MESSAGE pStubMsg, unsigned long* pCommStatus, unsigned long * pFaultStatus, RPC_STATUS Status);
int RPC_ENTRY NdrSH_UPDecision(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * pPtrInMem, RPC_BUFPTR pBuffer); 
int RPC_ENTRY NdrSH_TLUPDecision(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * pPtrInMem);
int RPC_ENTRY NdrSH_TLUPDecisionBuffer(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * pPtrInMem);
int RPC_ENTRY NdrSH_IfAlloc(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * pPtrInMem, unsigned long Count);
int RPC_ENTRY NdrSH_IfAllocRef(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * pPtrInMem, unsigned long Count);
int RPC_ENTRY NdrSH_IfAllocSet(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * pPtrInMem, unsigned long Count);
RPC_BUFPTR RPC_ENTRY NdrSH_IfCopy(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * pPtrInMem, unsigned long Count);
RPC_BUFPTR RPC_ENTRY NdrSH_IfAllocCopy(PMIDL_STUB_MESSAGE pStubMsg, unsigned char * * pPtrInMem, unsigned long Count);
unsigned long RPC_ENTRY NdrSH_Copy(unsigned char* pStubMsg, unsigned char * pPtrInMem, unsigned long Count); 
void RPC_ENTRY NdrSH_IfFree(PMIDL_STUB_MESSAGE pMessage, unsigned char* pPtr); 
RPC_BUFPTR RPC_ENTRY NdrSH_StringMarshall(PMIDL_STUB_MESSAGE pMessage, unsigned char* pMemory, unsigned long Count, int Size); 
RPC_BUFPTR RPC_ENTRY NdrSH_StringUnMarshall(PMIDL_STUB_MESSAGE pMessage, unsigned char* * pMemory, int Size); 
typedef void* RPC_SS_THREAD_HANDLE;
typedef void* __RPC_API RPC_CLIENT_ALLOC (size_t Size);
typedef void __RPC_API RPC_CLIENT_FREE (void * Ptr);
void * RPC_ENTRY RpcSsAllocate (size_t Size);
void RPC_ENTRY RpcSsDisableAllocate (void);
void RPC_ENTRY RpcSsEnableAllocate (void);
void RPC_ENTRY RpcSsFree (void* NodeToFree);
RPC_SS_THREAD_HANDLE RPC_ENTRY RpcSsGetThreadHandle (void);
void RPC_ENTRY RpcSsSetClientAllocFree (RPC_CLIENT_ALLOC* ClientAlloc, RPC_CLIENT_FREE * ClientFree); 
void RPC_ENTRY RpcSsSetThreadHandle (RPC_SS_THREAD_HANDLE Id);
void RPC_ENTRY RpcSsSwapClientAllocFree (RPC_CLIENT_ALLOC* ClientAlloc, RPC_CLIENT_FREE * ClientFree, RPC_CLIENT_ALLOC * * OldClientAlloc, RPC_CLIENT_FREE * * OldClientFree);
void* RPC_ENTRY RpcSmAllocate (size_t, RPC_STATUS *);
RPC_STATUS RPC_ENTRY RpcSmClientFree (void *);
RPC_STATUS RPC_ENTRY RpcSmDestroyClientContext (void* *);
RPC_STATUS RPC_ENTRY RpcSmDisableAllocate (void);
RPC_STATUS RPC_ENTRY RpcSmEnableAllocate (void);
RPC_STATUS RPC_ENTRY RpcSmFree (void*);
RPC_SS_THREAD_HANDLE RPC_ENTRY RpcSmGetThreadHandle(RPC_STATUS*);
RPC_STATUS RPC_ENTRY RpcSmSetClientAllocFree (RPC_CLIENT_ALLOC*, RPC_CLIENT_FREE *);
RPC_STATUS RPC_ENTRY RpcSmSetThreadHandle (RPC_SS_THREAD_HANDLE);
RPC_STATUS RPC_ENTRY RpcSmSwapClientAllocFree (RPC_CLIENT_ALLOC*, RPC_CLIENT_FREE *,RPC_CLIENT_ALLOC * *,RPC_CLIENT_FREE * *);
void RPC_ENTRY NdrRpcSsEnableAllocate(PMIDL_STUB_MESSAGE);
void RPC_ENTRY NdrRpcSsDisableAllocate(PMIDL_STUB_MESSAGE);
void RPC_ENTRY NdrRpcSmSetClientToOsf(PMIDL_STUB_MESSAGE ); 
void * RPC_ENTRY NdrRpcSmClientAllocate (size_t);
void RPC_ENTRY NdrRpcSmClientFree (void *);
void* RPC_ENTRY NdrRpcSsDefaultAllocate (size_t );
void RPC_ENTRY NdrRpcSsDefaultFree (void * );
PFULL_PTR_XLAT_TABLES RPC_ENTRY NdrFullPointerXlatInit(unsigned long,XLAT_SIDE);
void RPC_ENTRY NdrFullPointerXlatFree(PFULL_PTR_XLAT_TABLES);
int RPC_ENTRY NdrFullPointerQueryPointer(PFULL_PTR_XLAT_TABLES,void *,unsigned char,unsigned long *);
int RPC_ENTRY NdrFullPointerQueryRefId(PFULL_PTR_XLAT_TABLES,unsigned long,unsigned char,void * *);
void RPC_ENTRY NdrFullPointerInsertRefId(PFULL_PTR_XLAT_TABLES, unsigned long,void*);
int RPC_ENTRY NdrFullPointerFree(PFULL_PTR_XLAT_TABLES,void *);
void* RPC_ENTRY NdrAllocate(PMIDL_STUB_MESSAGE pStubMsg, size_t Len);
void RPC_ENTRY NdrClearOutParameters(PMIDL_STUB_MESSAGE pStubMsg, PFORMAT_STRING pFormat, void * ArgAddr);
void* RPC_ENTRY NdrOleAllocate (size_t Size);
void RPC_ENTRY NdrOleFree (void* NodeToFree);
#ifdef CONST_VTABLE
#define CONST_VTBL const
#else
#define CONST_VTBL
#endif
#endif 
