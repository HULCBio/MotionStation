/*
 * Copyright 1994-2004 The MathWorks, Inc.
 *
 * File: ext_tcpip_transport.c     $Revision: 1.1.6.3 $
 *
 * Abstract:
 *  Host-side, transport-dependent external mode functions and defs.  This    
 *  example file implements host/target communication using TCPIP.  To implement
 *  a custom transport layer, use the template in ext_custom_transport.c.
 *
 *   Functionality supplied by this module includes:
 *  
 *      o definition of 'UserData'
 *      o is target packet pending
 *      o get bytes from target on comm line
 *      o set bytes on target on comm line
 *      o close connection with target
 *      o open connection with target
 *      o create user data
 *      o destroy user data
 *      o process command line arguments
 *
 * Note: 
 *  This mex file specifies the signal, SIGPIPE, be ignored.
 */

/***************** TRANSPORT-INDEPENDENT INCLUDES *****************************/

#ifdef GLNXI64
#define _XOPEN_SOURCE 600
#include <features.h>
#include <unistd.h>
#endif

#include <ctype.h>
#include <string.h>

#include "tmwtypes.h"
#include "mex.h"
#include "extsim.h"
#include "extutil.h"


/***************** TRANSPORT-DEPENDENT INCLUDES *******************************/

#ifdef WIN32
  /* WINDOWS */
# include <winsock.h>
#else
  /* UNIX */
# include <signal.h>
# include <sys/time.h>       /* linux */
# include <sys/types.h>     /* linux */
# include <sys/socket.h>
# include <netinet/in.h>    /* linux */
# include <arpa/inet.h>     /* linux */
# include <netdb.h>
#endif

#include "ext_tcpip_utils.c"


/***************** DEFINE USER DATA HERE **************************************/

typedef struct UserData_tag {
    SOCKET   commSock;  /* 2-way socket for communication */
    char     *hostName;
    uint16_T port;
} UserData;


/***************** PRIVATE FUNCTIONS ******************************************/


/***************** VISIBLE FUNCTIONS ******************************************/

/* Function: ExtTargetPktPending ===============================================
 * Abstract:
 *  Returns true, via the 'pending' arg, if data is pending on the comm line.
 *  Returns false otherwise.  If the timeout is 0, do simple polling (i.e.,
 *  return immediately).  Otherwise, wait the specified amount of seconds.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure (reaching
 *  a nonzero timeout is considered a failure).
 */
PUBLIC boolean_T ExtTargetPktPending(
    const ExternalSim *ES,
    boolean_T         *pending,
    long int          timeOutSecs,
    long int          timeOutUSecs)
{
    UserData *userData = (UserData *)esGetUserData(ES);

    return(SocketDataPending(
        userData->commSock,pending,timeOutSecs,timeOutUSecs));
} /* end ExtTargetPktPending */


/* Function: ExtGetTargetPkt ===================================================
 * Abstract:
 *  Attempts to get the specified number of bytes from the comm line.  The
 *  number of bytes read is returned via the 'nBytesGot' parameter.
 *  EXT_NO_ERROR is returned on success, EXT_ERROR is returned on failure.
 *
 * NOTES:
 *  o it is not an error for 'nBytesGot' to be returned as 0
 *  o it is o.k. for this function to block if no data is available (e.g.,
 *    a recv call on a blocking socket)
 */
PUBLIC boolean_T ExtGetTargetPkt(
    const ExternalSim *ES,
    const int         nBytesToGet,
    int               *nBytesGot, /* out */
    char              *dst)       /* out */
{
    UserData *userData = (UserData *)esGetUserData(ES);

    return(SocketDataGet(userData->commSock,nBytesToGet,nBytesGot,dst));
} /* end ExtGetTargetPkt */


/* Function: ExtSetTargetPkt ===================================================
 * Abstract:
 *  Sets (sends) the specified number of bytes on the comm line.  As long as
 *  an error does not occur, this function is guaranteed to set the requested
 *  number of bytes.  The number of bytes set is returned via the 'nBytesSet'
 *  parameter.  EXT_NO_ERROR is returned on success, EXT_ERROR is returned on
 *  failure.
 *
 * NOTES:
 *  o it is o.k. for this function to block if no room is available (e.g.,
 *    a send call on a blocking socket)
 */
PUBLIC boolean_T ExtSetTargetPkt(
    const ExternalSim *ES,
    const int         nBytesToSet,
    const char        *src,
    int               *nBytesSet) /* out */
{
    UserData *userData = (UserData *)esGetUserData(ES);
    
    return(SocketDataSet(userData->commSock,nBytesToSet,src,nBytesSet));
} /* end ExtSetTargetPkt */


/* Function: ExtCloseConnection ================================================
 * Abstract:
 *  Close the connection with the target.  In some cases, this may be 
 *  trivial (e.g., shared memory, serial cable).  In the case of sockets it
 *  takes a little work.
 *
 * NOTES:
 *  o It is assumed that this function is always successful.
 *  o It is possible that user data will be NULL (due to a shutdown
 *    caused by an error early in the connect process).
 */
PUBLIC void ExtCloseConnection(ExternalSim *ES)
{
    UserData *userData = (UserData *)esGetUserData(ES);

    if (userData == NULL) goto EXIT_POINT;

    if (userData->commSock != INVALID_SOCKET) {
        close(userData->commSock);
    }

#ifdef WIN32   
    WSACleanup();
#endif

EXIT_POINT:
    return;
} /* end ExtCloseConnection */


/* Function: ExtOpenConnection =================================================
 * Abstract:
 *  Open the connection with the target.  In some cases, this may be 
 *  trivial (e.g., shared memory, serial cable).  In the case of sockets it
 *  takes a little work.  We must:
 *      o create sockets
 *      o initiate a connection with the target (connect)
 *
 * NOTES:
 *  o If an error is detected, set the error string via esSetError(ES)
 *    and return.
 *
 *  o O.K. for this function to block (it is assumed that the connection
 *    procedure will complete "quickly")
 */
PUBLIC void ExtOpenConnection(ExternalSim *ES)
{
    struct sockaddr_in sa;
    char               *hostName;
    UserData           *userData = (UserData *)esGetUserData(ES);
    uint16_T           port      = userData->port;
    boolean_T          verbosity = esGetVerbosity(ES);
    struct hostent     *hp       = NULL;
    
    /*
     * Packet socket.  Used for sending packets back and forth from target
     * such as start simulation (EXT_MODEL_START - down), set_param response
     * (EXT_SETPARAM_RESPONSE - up) and parameter downloads
     * (EXT_SETPARAM - down).
     */
    SOCKET commSock = INVALID_SOCKET;

    /*
     * Initialize sockets.
     */
#ifdef WIN32
    {
        WSADATA data;
  
        if (WSAStartup((MAKEWORD(1,1)), &data)) {
            esSetError(ES, "WSAStartup() call failed.\n");
            goto EXIT_POINT;
        }
    }
#else 
    signal(SIGPIPE, SIG_IGN);
#endif

    /*
     * Default to local host name, if hostname not specified.
     */
    if (userData->hostName == NULL) {
        userData->hostName = (char *)calloc(256, sizeof(char));
        if (userData->hostName == NULL) {
            esSetError(ES, "Memory allocation error.");
            goto EXIT_POINT;
        }
      
        if (gethostname(userData->hostName, 256) == SOCK_ERR) {
            esSetError(ES, "Error determining local host name.");
            goto EXIT_POINT;
        }
    }
    hostName = userData->hostName;
 
    /*
     * Lookup target network name.
     */
    if (!isdigit(*hostName)) {
        /* Try gethostbyname first for speed*/
        if ((hp = gethostbyname(hostName)) == NULL) {
            unsigned long addr;

            if (( (int_T) (addr = inet_addr(hostName)) == -1) ||
                ((hp = gethostbyaddr((void*)&addr,sizeof(addr),
                                     AF_INET)) == NULL)) {
                esSetError(ES, 
                    "gethostbyname() and gethostbyaddr() calls failed.\n");
                goto EXIT_POINT;
            }
        }
    } else {
        /* Try gethostbyaddr first for speed*/
        unsigned long addr;
        
        if (( (int_T) (addr = inet_addr(hostName)) == -1) ||
            ((hp = gethostbyaddr((void*)&addr,sizeof(addr),AF_INET)) == NULL)) {
            if ((hp = gethostbyname(hostName)) == NULL) {
                esSetError(ES, 
                    "gethostbyaddr() and gethostbyname() calls failed.\n");
                goto EXIT_POINT;
            }
        }
    }
  
    memcpy((char *)&sa.sin_addr,(char *)hp->h_addr,hp->h_length);
    sa.sin_family = hp->h_addrtype;
    sa.sin_port   = htons(port);

    if (verbosity) {
        mexPrintf("target name      : %s\n", hp->h_name);
        mexPrintf("target IP address: %s\n", inet_ntoa(sa.sin_addr));
        mexPrintf("target TCP port  : %d\n", ntohs(sa.sin_port));
    }
  
    /*
     * Create the sockets & make connections.
     */
    commSock = socket(PF_INET,SOCK_STREAM,0);
    if (commSock == INVALID_SOCKET) {
        esSetError(ES, "socket() call failed for comm socket.\n");
        goto EXIT_POINT;
    }

    if (connect(commSock, (struct sockaddr *)&sa, sizeof(sa)) == SOCK_ERR) {
        char tmp[1024];
        
        sprintf(tmp,
            "Unable to establish TCP connection with real-time target '%s' "
            "for the external mode comm socket.  Verify that your real-time "
            "target is serving on port '%d'.\n", hp->h_name,
            ntohs(sa.sin_port));
        esSetError(ES, tmp);
        goto EXIT_POINT;
    }

    /*
     * Store the socket in the user data.
     */
    userData->commSock = commSock;

EXIT_POINT:
    return;
} /* end ExtOpenConnection */


/* Function: ExtUserDataCreate =================================================
 * Abstract:
 *  Create the user data.
 */
PUBLIC UserData *ExtUserDataCreate()
{
    UserData *ud = (UserData *)calloc(1, sizeof(UserData));
    if (ud != NULL) {
        ud->commSock = INVALID_SOCKET;
    }
    return(ud);
} /* end ExtUserDataCreate */


/* Function: ExtUserDataDestroy ================================================
 * Abstract:
 *  Destroy the user data.
 */
PUBLIC void ExtUserDataDestroy(UserData *userData)
{
    if (userData != NULL) {
        free(userData->hostName);
        free(userData);
    }
} /* end ExtUserDataDestroy */


/* Function: ExtProcessArgs ====================================================
 * Abstract:
 *  Process the arguments specified by the user in the 'Target Interface'
 *  panel of the 'External Mode Control' dialog.  In the case of
 *  this TCPIP example the args are:
 *      o hostname
 *      o verbosity
 *      o tcpip port number
 *
 *  Store values of settings into the userdata.
 *
 * NOTES: 
 *  o This function is only called as part of the connect procedure
 *    (EXT_CONNECT).
 *
 *  o If an error is detected, set the error string via esSetError(ES)
 *    and return.
 */
PUBLIC void ExtProcessArgs(
    ExternalSim   *ES,
    int           nrhs,
    const mxArray *prhs[])
{
    UserData *userData = (UserData *)esGetUserData(ES);

    assert(userData->hostName == NULL);

    /* ... Argument 1 - host name */
    if (nrhs >= 1 && !mxIsEmpty(prhs[0])) {
        /* host name specified */
        const mxArray *mat = prhs[0];
        int_T         len  = mxGetN(mat) + 1;

        if (mxGetM(mat) != 1) {
            esSetError(ES, "Expected 1xN string array for host name\n");
            goto EXIT_POINT;
        }

        userData->hostName = (char *)calloc(len, sizeof(char));
        if (userData->hostName == NULL) {
            esSetError(ES, "Memory allocation error.");
            goto EXIT_POINT;
        }

        if (mxGetString(mat, userData->hostName, len)) {
            esSetError(ES, "Error converting matlab string to C string.");
            goto EXIT_POINT;
        }
    } /* else default to local host in ExtOpenConnection */
  
    /* ... Argument 2 - verbosity */
    if(nrhs >= 2) {
        boolean_T     verbosity;
        const mxArray *mat = prhs[1];
        int_T         m    = mxGetM(mat);
        int_T         n    = mxGetN(mat);

        const char msg[] =
            "Verbosity argument must be a real, scalar, integer value in the "
            "range: [0-1].";

        /* verify that we've got a real, scalar integer */
        if (!mxIsNumeric(mat) || mxIsComplex(mat) || mxIsSparse(mat) ||
            !mxIsDouble(mat) || (!(m ==1 && n ==1)) || !IS_INT(*mxGetPr(mat))) {
            esSetError(ES, msg);
            goto EXIT_POINT;
        }
        verbosity = (boolean_T) *(mxGetPr(mat));

        /* verify that it's 0 or 1 */
        if ((verbosity != 0) && (verbosity != 1)) {
            esSetError(ES, msg);
            goto EXIT_POINT;
        }
        
        esSetVerbosity(ES, verbosity);
    }
  
    /* ... Argument 3 - TCP port value */
    if (nrhs >= 3) {
        uint16_T      port;
        const mxArray *mat = prhs[2];
        int_T         m    = mxGetM(mat);
        int_T         n    = mxGetN(mat);

        const char msg[] = 
            "Port argument must be a real, scalar, integer value in the range: "
            "[256-65535].";

        /* verify that we've got a real, scalar integer */
        if (!mxIsNumeric(mat) || mxIsComplex(mat) || mxIsSparse(mat) ||
            !mxIsDouble(mat) || (!(m ==1 && n ==1)) || !IS_INT(*mxGetPr(mat))) {
            esSetError(ES, msg);
            goto EXIT_POINT;
        }
        port = (uint16_T) *(mxGetPr(mat));

        /* check port range */
        if (port < 256 || port > 65535) {
            esSetError(ES, msg);
            goto EXIT_POINT;
        }

        userData->port = port;
    } else {
        /* use default */
        userData->port = (SERVER_PORT_NUM);
    }

EXIT_POINT:
    return;
} /* end ExtProcessArgs */


/* [EOF] ext_tcpip_transport.c */
