// WSADATA *InitWS2(void)
// Routine Description:
//
// Calls WSAStartup, makes sure we have a good version of WinSock2
//
//
// Return Value:
//  A pointer to a WSADATA structure - WinSock 2 DLL successfully started up
//  NULL - Error starting up WinSock 2 DLL.
//
WSADATA *InitWS2(void)
{
    int           Error;              // catches return value of WSAStartup
    WORD          VersionRequested;   // passed to WSAStartup
    static WSADATA       WsaData;            // receives data from WSAStartup
    BOOL          ReturnValue = TRUE; // return value flag
    
    // Start WinSock 2.  If it fails, we don't need to call
    // WSACleanup().
    VersionRequested = MAKEWORD(2, 0); 
    Error = WSAStartup(VersionRequested, &WsaData);
    if (Error) {
        MessageBox(hwndMain,
                   "Could not find high enough version of WinSock",
                   "Error", MB_OK | MB_ICONSTOP | MB_SETFOREGROUND);
        ReturnValue = FALSE;
    } else {

        // Now confirm that the WinSock 2 DLL supports the exact version
        // we want. If not, make sure to call WSACleanup().
        if (LOBYTE(WsaData.wVersion) != 2) { 
            MessageBox(hwndMain,
                       "Could not find the correct version of WinSock",
                       "Error",  MB_OK | MB_ICONSTOP | MB_SETFOREGROUND);
            WSACleanup();
            ReturnValue = FALSE;
        }
    }
    if (ReturnValue)
        return &WsaData;
    return(NULL);
    
} // InitWS2()
