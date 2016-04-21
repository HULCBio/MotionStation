/* $Revision: 1.2 $ */
#ifndef __LCC__MAPIX_H
#define __LCC__MAPIX_H
#ifndef __LCC__MAPIDEFS_H
#include <mapidefs.h>
#endif
#ifndef __LCC__MAPICODE_H
#include <mapicode.h>
#endif
#ifndef __LCC__MAPIGUID_H
#include <mapiguid.h>
#endif
#ifndef __LCC__MAPITAGS_H
#include <mapitags.h>
#endif
#ifndef BEGIN_INTERFACE
#define BEGIN_INTERFACE
#endif
DECLARE_MAPI_INTERFACE_PTR(IProfAdmin,LPPROFADMIN);
DECLARE_MAPI_INTERFACE_PTR(IMsgServiceAdmin,LPSERVICEADMIN);
DECLARE_MAPI_INTERFACE_PTR(IMAPISession,LPMAPISESSION);
typedef ULONG FLAGS;
#define MAPI_LOGON_UI 1 
#define MAPI_NEW_SESSION 2 
#define MAPI_ALLOW_OTHERS 8 
#define MAPI_EXPLICIT_PROFILE 16 
#define MAPI_EXTENDED 32 
#define MAPI_FORCE_DOWNLOAD 0x1000 
#define MAPI_SERVICE_UI_ALWAYS 0x2000 
#define MAPI_NO_MAIL 0x8000 
#ifndef MAPI_PASSWORD_UI
#define MAPI_PASSWORD_UI 0x20000 
#endif
#define MAPI_TIMEOUT_SHORT 0x100000 
#define MAPI_SIMPLE_DEFAULT (MAPI_LOGON_UI | MAPI_FORCE_DOWNLOAD | MAPI_ALLOW_OTHERS)
#define MAPI_SIMPLE_EXPLICIT (MAPI_NEW_SESSION | MAPI_FORCE_DOWNLOAD | MAPI_EXPLICIT_PROFILE)
typedef struct {
 ULONG ulVersion;
 ULONG ulFlags;
} MAPIINIT_0, *LPMAPIINIT_0;
typedef MAPIINIT_0 MAPIINIT;
typedef MAPIINIT *LPMAPIINIT;
#define MAPI_INIT_VERSION 0
#define MAPI_MULTITHREAD_NOTIFICATIONS 1
typedef HRESULT (STDAPICALLTYPE MAPIINITIALIZE)(LPVOID);
typedef MAPIINITIALIZE *LPMAPIINITIALIZE;
typedef void (STDAPICALLTYPE MAPIUNINITIALIZE)(void);
typedef MAPIUNINITIALIZE *LPMAPIUNINITIALIZE;
MAPIINITIALIZE MAPIInitialize;
MAPIUNINITIALIZE MAPIUninitialize;
typedef HRESULT (STDMETHODCALLTYPE MAPILOGONEX)(ULONG,LPTSTR,LPTSTR,ULONG,LPMAPISESSION *);
typedef MAPILOGONEX *LPMAPILOGONEX;
MAPILOGONEX MAPILogonEx;
typedef SCODE (STDMETHODCALLTYPE MAPIALLOCATEBUFFER)(ULONG,LPVOID *);
typedef SCODE (STDMETHODCALLTYPE MAPIALLOCATEMORE)(ULONG,LPVOID,LPVOID *);
typedef ULONG (STDAPICALLTYPE MAPIFREEBUFFER)(LPVOID);
typedef MAPIALLOCATEBUFFER *LPMAPIALLOCATEBUFFER;
typedef MAPIALLOCATEMORE *LPMAPIALLOCATEMORE;
typedef MAPIFREEBUFFER *LPMAPIFREEBUFFER;
MAPIALLOCATEBUFFER MAPIAllocateBuffer;
MAPIALLOCATEMORE MAPIAllocateMore;
MAPIFREEBUFFER MAPIFreeBuffer;
typedef HRESULT (STDMETHODCALLTYPE MAPIADMINPROFILES)(ULONG,LPPROFADMIN *);
typedef MAPIADMINPROFILES *LPMAPIADMINPROFILES;
MAPIADMINPROFILES MAPIAdminProfiles;
#define MAPI_LOGOFF_SHARED 0x00000001 
#define MAPI_LOGOFF_UI 0x00000002 
#define MAPI_DEFAULT_STORE 0x00000001 
#define MAPI_SIMPLE_STORE_TEMPORARY 0x00000002 
#define MAPI_SIMPLE_STORE_PERMANENT 0x00000003 
#define MAPI_PRIMARY_STORE 0x00000004 
#define MAPI_SECONDARY_STORE 0x00000005 
#define MAPI_POST_MESSAGE 0x00000001 
#define MAPI_NEW_MESSAGE 0x00000002 
#define MAPI_IMAPISESSION_METHODS(IPURE) MAPIMETHOD(GetLastError) (THIS_ HRESULT hResult, ULONG ulFlags,\
LPMAPIERROR *lppMAPIError) IPURE;\
 MAPIMETHOD(GetMsgStoresTable) (THIS_ ULONG ulFlags,LPMAPITABLE * lppTable) IPURE;\
 MAPIMETHOD(OpenMsgStore)(THIS_ ULONG ulUIParam,ULONG cbEntryID, \
 LPENTRYID lpEntryID, LPCIID lpInterface, ULONG ulFlags, LPMDB * lppMDB) IPURE; \
 MAPIMETHOD(OpenAddressBook) (THIS_ ULONG ulUIParam,  LPCIID lpInterface, \
 ULONG ulFlags, LPADRBOOK * lppAdrBook) IPURE;  MAPIMETHOD(OpenProfileSection) \
 (THIS_ LPMAPIUID lpUID,  LPCIID lpInterface,  ULONG ulFlags,  LPPROFSECT * lppProfSect) IPURE; \
 MAPIMETHOD(GetStatusTable)  (THIS_ ULONG ulFlags,  LPMAPITABLE * lppTable) IPURE; \
 MAPIMETHOD(OpenEntry)  (THIS_ ULONG cbEntryID,  LPENTRYID lpEntryID, \
 LPCIID lpInterface,  ULONG ulFlags,  ULONG * lpulObjType,  LPUNKNOWN * lppUnk) IPURE; \
 MAPIMETHOD(CompareEntryIDs)  (THIS_ ULONG cbEntryID1,  LPENTRYID lpEntryID1, \
 ULONG cbEntryID2,  LPENTRYID lpEntryID2,  ULONG ulFlags,  ULONG * lpulResult) IPURE; \
 MAPIMETHOD(Advise)  (THIS_ ULONG cbEntryID,  LPENTRYID lpEntryID, \
 ULONG ulEventMask,  LPMAPIADVISESINK lpAdviseSink,  ULONG * lpulConnection) IPURE; \
 MAPIMETHOD(Unadvise)  (THIS_ ULONG ulConnection) IPURE;  MAPIMETHOD(MessageOptions) \
 (THIS_ ULONG ulUIParam,  ULONG ulFlags,  LPTSTR lpszAdrType,  LPMESSAGE lpMessage) IPURE; \
 MAPIMETHOD(QueryDefaultMessageOpt)  (THIS_ LPTSTR lpszAdrType, \
 ULONG ulFlags,  ULONG * lpcValues,  LPSPropValue * lppOptions) IPURE; \
 MAPIMETHOD(EnumAdrTypes)  (THIS_ ULONG ulFlags,  ULONG * lpcAdrTypes, \
 LPTSTR * * lpppszAdrTypes) IPURE;  MAPIMETHOD(QueryIdentity) \
 (THIS_ ULONG * lpcbEntryID,  LPENTRYID * lppEntryID) IPURE; \
 MAPIMETHOD(Logoff)  (THIS_ ULONG ulUIParam, \
 ULONG ulFlags,  ULONG ulReserved) IPURE;  MAPIMETHOD(SetDefaultStore) \
 (THIS_ ULONG ulFlags,  ULONG cbEntryID,  LPENTRYID lpEntryID) IPURE; \
 MAPIMETHOD(AdminServices)  (THIS_ ULONG ulFlags, LPSERVICEADMIN * lppServiceAdmin) IPURE; \
 MAPIMETHOD(ShowForm)  (THIS_ ULONG ulUIParam,  LPMDB lpMsgStore,  LPMAPIFOLDER lpParentFolder, \
 LPCIID lpInterface,  ULONG ulMessageToken,  LPMESSAGE lpMessageSent, \
 ULONG ulFlags,  ULONG ulMessageStatus,  ULONG ulMessageFlags,  ULONG ulAccess, \
 LPSTR lpszMessageClass) IPURE;  MAPIMETHOD(PrepareForm)  (THIS_ LPCIID lpInterface, \
 LPMESSAGE lpMessage,  ULONG * lpulMessageToken) IPURE;  
#undef INTERFACE
#define INTERFACE IMAPISession
DECLARE_MAPI_INTERFACE_(IMAPISession, IUnknown) {
 BEGIN_INTERFACE 
 MAPI_IUNKNOWN_METHODS(PURE)
 MAPI_IMAPISESSION_METHODS(PURE)
};

#define MAPI_IADDRBOOK_METHODS(IPURE) \
 MAPIMETHOD(OpenEntry) \
 (THIS_ ULONG cbEntryID, \
 LPENTRYID lpEntryID, \
 LPCIID lpInterface, \
 ULONG ulFlags, \
 ULONG * lpulObjType, \
 LPUNKNOWN * lppUnk) IPURE; \
 MAPIMETHOD(CompareEntryIDs) \
 (THIS_ ULONG cbEntryID1, \
 LPENTRYID lpEntryID1, \
 ULONG cbEntryID2, \
 LPENTRYID lpEntryID2, \
 ULONG ulFlags, \
 ULONG * lpulResult) IPURE; \
 MAPIMETHOD(Advise) \
 (THIS_ ULONG cbEntryID, \
 LPENTRYID lpEntryID, \
 ULONG ulEventMask, \
 LPMAPIADVISESINK lpAdviseSink, \
 ULONG * lpulConnection) IPURE; \
 MAPIMETHOD(Unadvise) \
 (THIS_ ULONG ulConnection) IPURE; \
 MAPIMETHOD(CreateOneOff) \
 (THIS_ LPTSTR lpszName, \
 LPTSTR lpszAdrType, \
 LPTSTR lpszAddress, \
 ULONG ulFlags, \
 ULONG * lpcbEntryID, \
 LPENTRYID * lppEntryID) IPURE; \
 MAPIMETHOD(NewEntry) \
 (THIS_ ULONG ulUIParam, \
 ULONG ulFlags, \
 ULONG cbEIDContainer, \
 LPENTRYID lpEIDContainer, \
 ULONG cbEIDNewEntryTpl, \
 LPENTRYID lpEIDNewEntryTpl, \
 ULONG * lpcbEIDNewEntry, \
 LPENTRYID * lppEIDNewEntry) IPURE; \
 MAPIMETHOD(ResolveName) \
 (THIS_ ULONG ulUIParam, \
 ULONG ulFlags, \
 LPTSTR lpszNewEntryTitle, \
 LPADRLIST lpAdrList) IPURE; \
 MAPIMETHOD(Address) \
 (THIS_ ULONG * lpulUIParam, \
 LPADRPARM lpAdrParms, \
 LPADRLIST * lppAdrList) IPURE; \
 MAPIMETHOD(Details) \
 (THIS_ ULONG * lpulUIParam, \
 LPFNDISMISS lpfnDismiss, \
 LPVOID lpvDismissContext, \
 ULONG cbEntryID, \
 LPENTRYID lpEntryID, \
 LPFNBUTTON lpfButtonCallback, \
 LPVOID lpvButtonContext, \
 LPTSTR lpszButtonText, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(RecipOptions) \
 (THIS_ ULONG ulUIParam, \
 ULONG ulFlags, \
 LPADRENTRY lpRecip) IPURE; \
 MAPIMETHOD(QueryDefaultRecipOpt) \
 (THIS_ LPTSTR lpszAdrType, \
 ULONG ulFlags, \
 ULONG * lpcValues, \
 LPSPropValue * lppOptions) IPURE; \
 MAPIMETHOD(GetPAB) \
 (THIS_ ULONG * lpcbEntryID, \
 LPENTRYID * lppEntryID) IPURE; \
 MAPIMETHOD(SetPAB) \
 (THIS_ ULONG cbEntryID, \
 LPENTRYID lpEntryID) IPURE; \
 MAPIMETHOD(GetDefaultDir) \
 (THIS_ ULONG * lpcbEntryID, \
 LPENTRYID * lppEntryID) IPURE; \
 MAPIMETHOD(SetDefaultDir) \
 (THIS_ ULONG cbEntryID, \
 LPENTRYID lpEntryID) IPURE; \
 MAPIMETHOD(GetSearchPath) \
 (THIS_ ULONG ulFlags, \
 LPSRowSet * lppSearchPath) IPURE; \
 MAPIMETHOD(SetSearchPath) \
 (THIS_ ULONG ulFlags, \
 LPSRowSet lpSearchPath) IPURE; \
 MAPIMETHOD(PrepareRecips) \
 (THIS_ ULONG ulFlags, \
 LPSPropTagArray lpPropTagArray, \
 LPADRLIST lpRecipList) IPURE; \

#undef INTERFACE
#define INTERFACE IAddrBook
DECLARE_MAPI_INTERFACE_(IAddrBook, IMAPIProp)
{
 BEGIN_INTERFACE 
 MAPI_IUNKNOWN_METHODS(PURE)
 MAPI_IMAPIPROP_METHODS(PURE)
 MAPI_IADDRBOOK_METHODS(PURE)
};

DECLARE_MAPI_INTERFACE_PTR(IAddrBook, LPADRBOOK);
#define MAPI_DEFAULT_SERVICES 0x00000001
#define MAPI_IPROFADMIN_METHODS(IPURE) \
 MAPIMETHOD(GetLastError) \
 (THIS_ HRESULT hResult, \
 ULONG ulFlags, \
 LPMAPIERROR * lppMAPIError) IPURE; \
 MAPIMETHOD(GetProfileTable) \
 (THIS_ ULONG ulFlags, \
 LPMAPITABLE * lppTable) IPURE; \
 MAPIMETHOD(CreateProfile) \
 (THIS_ LPTSTR lpszProfileName, \
 LPTSTR lpszPassword, \
 ULONG ulUIParam, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(DeleteProfile) \
 (THIS_ LPTSTR lpszProfileName, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(ChangeProfilePassword) \
 (THIS_ LPTSTR lpszProfileName, \
 LPTSTR lpszOldPassword, \
 LPTSTR lpszNewPassword, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(CopyProfile) \
 (THIS_ LPTSTR lpszOldProfileName, \
 LPTSTR lpszOldPassword, \
 LPTSTR lpszNewProfileName, \
 ULONG ulUIParam, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(RenameProfile) \
 (THIS_ LPTSTR lpszOldProfileName, \
 LPTSTR lpszOldPassword, \
 LPTSTR lpszNewProfileName, \
 ULONG ulUIParam, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(SetDefaultProfile) \
 (THIS_ LPTSTR lpszProfileName, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(AdminServices) \
 (THIS_ LPTSTR lpszProfileName, \
 LPTSTR lpszPassword, \
 ULONG ulUIParam, \
 ULONG ulFlags, \
 LPSERVICEADMIN * lppServiceAdmin) IPURE; \

#undef INTERFACE
#define INTERFACE IProfAdmin
DECLARE_MAPI_INTERFACE_(IProfAdmin, IUnknown)
{
 BEGIN_INTERFACE 
 MAPI_IUNKNOWN_METHODS(PURE)
 MAPI_IPROFADMIN_METHODS(PURE)
};
#define SERVICE_DEFAULT_STORE 0x00000001
#define SERVICE_SINGLE_COPY 0x00000002
#define SERVICE_CREATE_WITH_STORE 0x00000004
#define SERVICE_PRIMARY_IDENTITY 0x00000008
#define SERVICE_NO_PRIMARY_IDENTITY 0x00000020
#define MAPI_IMSGSERVICEADMIN_METHODS(IPURE) \
 MAPIMETHOD(GetLastError) \
 (THIS_ HRESULT hResult, \
 ULONG ulFlags, \
 LPMAPIERROR * lppMAPIError) IPURE; \
 MAPIMETHOD(GetMsgServiceTable) \
 (THIS_ ULONG ulFlags, \
 LPMAPITABLE * lppTable) IPURE; \
 MAPIMETHOD(CreateMsgService) \
 (THIS_ LPTSTR lpszService, \
 LPTSTR lpszDisplayName, \
 ULONG ulUIParam, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(DeleteMsgService) \
 (THIS_ LPMAPIUID lpUID) IPURE; \
 MAPIMETHOD(CopyMsgService) \
 (THIS_ LPMAPIUID lpUID, \
 LPTSTR lpszDisplayName, \
 LPCIID lpInterfaceToCopy, \
 LPCIID lpInterfaceDst, \
 LPVOID lpObjectDst, \
 ULONG ulUIParam, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(RenameMsgService) \
 (THIS_ LPMAPIUID lpUID, \
 ULONG ulFlags, \
 LPTSTR lpszDisplayName) IPURE; \
 MAPIMETHOD(ConfigureMsgService) \
 (THIS_ LPMAPIUID lpUID, \
 ULONG ulUIParam, \
 ULONG ulFlags, \
 ULONG cValues, \
 LPSPropValue lpProps) IPURE; \
 MAPIMETHOD(OpenProfileSection) \
 (THIS_ LPMAPIUID lpUID, \
 LPCIID lpInterface, \
 ULONG ulFlags, \
 LPPROFSECT * lppProfSect) IPURE; \
 MAPIMETHOD(MsgServiceTransportOrder) \
 (THIS_ ULONG cUID, \
 LPMAPIUID lpUIDList, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(AdminProviders) \
 (THIS_ LPMAPIUID lpUID, \
 ULONG ulFlags, \
 LPPROVIDERADMIN * lppProviderAdmin) IPURE; \
 MAPIMETHOD(SetPrimaryIdentity) \
 (THIS_ LPMAPIUID lpUID, \
 ULONG ulFlags) IPURE; \
 MAPIMETHOD(GetProviderTable) \
 (THIS_ ULONG ulFlags, \
 LPMAPITABLE  * lppTable) IPURE; 
#undef INTERFACE
#define INTERFACE IMsgServiceAdmin
DECLARE_MAPI_INTERFACE_(IMsgServiceAdmin, IUnknown)
{
 BEGIN_INTERFACE 
 MAPI_IUNKNOWN_METHODS(PURE)
 MAPI_IMSGSERVICEADMIN_METHODS(PURE)
};

#endif 
