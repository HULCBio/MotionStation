/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_svr_tcpip_transport.c     $Revision: 1.1.6.3 $
 *
 * Abstract:
 *  Target-side, transport-dependent external mode functions and defs.  This    
 *  example file implements host/target communication using TCPIP.  To implement
 *  a custom transport layer, use the template in ext_svr_custom_transport.c.
 *
 * Functionality supplied by this module includes:
 *
 *      o definition of user data
 *      o is host packet pending
 *      o get bytes from host via comm line
 *      o set bytes on host via comm line
 *      o close connection with host
 *      o open connection with host
 *      o create user data
 *      o destroy user data
 *      o process command line arguments
 *      o initialize external mode
 *      o terminate external mode
 */


/*
 * Explanation of EXT_BLOCKING:
 *
 * Depending on the implementation of the main program (e.g., grt_main.c,
 * rt_main.c), the EXT_BLOCKING flag must be set to either 0 or 1.  Let's
 * look at two examples:
 *
 *   grt_main.c (grt):
 *   grt_main is a real-time template that essentially runs a simulation - in
 *   non-real-time - in a single thread.  As seen in grt, the calls to the
 *   upload & packet servers are "in the loop".  If any function related to
 *   external mode were to block, the real-time code would be prevented from
 *   running.  In this case, we prevent blocking and poll instead.
 *
 *   rt_main.c (tornado/vxworks):
 *   rt_main.c is a full blown, real-time, multi-tasking target.  The
 *   upload and packet servers are called via background (low priority) tasks.
 *   In this case, it is o.k. for the transport function to block as the blocked
 *   tasks will simply be pre-empted in order to enable the model to run.  It
 *   is desirable to block instead of to poll to free up the cpu for any other
 *   potential work.
 */

/***************** TRANSPORT-INDEPENDENT INCLUDES *****************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "updown_util.h"
#include "tmwtypes.h"
#include "ext_types.h"
#include "ext_share.h"

/***************** TRANSPORT-DEPENDENT INCLUDES *******************************/

#ifdef WIN32
 /*WIN32 headers*/
# include <windows.h>

# ifdef __LCC__
#   include <winsock2.h>
#   include <errno.h>
# endif

#elif defined(VXWORKS)
 /*VxWorks headers*/
# include <selectLib.h>
# include <sockLib.h>
# include <inetLib.h>
# include <ioLib.h>
# include <taskLib.h>

/* tornado - full blown multi-tasking environment 
 *               (See "Explanation of the EXT_BLOCKING" above)
 */
# define EXT_BLOCKING (1)  

#else
/*UNIX headers*/
# include <sys/time.h>    /* linux */
# include <sys/types.h>   /* linux */ 
# include <sys/socket.h>
# include <netinet/in.h>  /* linux */
# include <arpa/inet.h>   /* linux */
# include <netdb.h>
# include <fcntl.h>       /* linux */
# include <errno.h>
# include <unistd.h>

/*
 *  grt - single thread (See "Explanation of the EXT_BLOCKING" above)
 */
# define EXT_BLOCKING (0)  

#endif

#if defined(IBM_RS) || defined(GLNX86)
#define IBM_GLNX_FIX (unsigned int *)
#else
#define IBM_GLNX_FIX
#endif

#if defined(SUN4)
#   undef inet_ntoa
#   undef inet_addr
#endif

#include "ext_tcpip_utils.c"


/***************** DEFINE USER DATA HERE **************************************/

typedef struct ExtUserData_tag {
    int_T     port;
    boolean_T waitForStartPkt;

    SOCKET    sFd;    /* socket to listen/accept on     */
    SOCKET    commFd; /* socket to send/receive packets */ 
} ExtUserData;


/***************** PRIVATE FUNCTIONS ******************************************/

/* Function: PassiveSocketShutdown =============================================
 * Abstract:
 *  Perform graceful closing of a socket as outlined by:
 *
 * ("Unix Network Programming - Networking APIs:Sockets and XTI",
 *   Volume 1, 2nd edition, by W. Richard Stevens).
 *
 * Assume that the host is alive and well.  It responds to the
 * EXT_MODEL_SHUTDOWN packet sent by the target, or to Simulink's 
 * "Disconnect from target" menu item by initiating an active close
 * of the sockets.  We need to receive and acknowledge the EOF sent by TCP
 * as a result of the host's active close (i.e., the target needs to perform
 * a passive shutdown of the socket).  Note that the acknowledgement of the EOF
 * is implicit.  When recv returns a value of 0, it implies that the ACK was
 * sent to the host by TCP.
 *
 * NOTE: If the host is not alive and well, it is assumed that it shut
 *       down ungracefully.  In that event, a socket error should be
 *       detected.  Subsequent connection attempts that take place within
 *       the TIME_WAIT state may fail.
 *
 *       Data left in the sockets is thrown away.
 *
 *       It is assumed that the host is no longer sending data.  Furthermore,
 *       it assumes that the recv loop either finds a 0 return value
 *       (due to an active close on the host), or that recv() returns with
 *       an error (the host is not alive and well).  If these assumptions are
 *       invalid, either an infinite loop will occur or the socket will
 *       block indefinately.  That would be bad.
 */
PRIVATE void PassiveSocketShutdown(SOCKET sock)
{
    int_T     nGot;
    char_T    tmpBuf[50];
    boolean_T error = EXT_NO_ERROR;

    do {
        error = SocketDataGet(sock,50,&nGot,tmpBuf);
    } while ((nGot != 0) && (error == EXT_NO_ERROR));
    close(sock);
} /* end PassiveSocketShutdown */


/***************** VISIBLE FUNCTIONS ******************************************/

/* Function: ExtInit ===========================================================
 * Abstract:
 *  Called once at program startup to do any initialization related to external
 *  mode.  For the TCPIP, example, a socket is created to listen for
 *  connection requests from the host.  EXT_NO_ERROR is returned on success,
 *  EXT_ERROR on failure.
 *
 * NOTES:
 *  o This function should not block.
 */
PUBLIC boolean_T ExtInit(ExtUserData *UD)
{
    int                sockStatus;     
    struct sockaddr_in serverAddr;
    int_T              sFdAddSize = sizeof(struct sockaddr_in);
    int_T              option     = 1;     
    int_T              port       = UD->port;
    boolean_T          error      = EXT_NO_ERROR;
    SOCKET             sFd        = INVALID_SOCKET;
        
#ifdef WIN32
    WSADATA data;
  
    if (WSAStartup((MAKEWORD(1,1)),&data)) {
        fprintf(stderr,"WSAStartup() call failed.\n");
        error = EXT_ERROR;
        goto EXIT_POINT;
    }
#endif
  
    /*
     * Create a TCP-based socket.
     */
    memset((char *) &serverAddr,0,sFdAddSize);
    serverAddr.sin_family      = AF_INET;
    serverAddr.sin_port        = htons((uint16_T)port);
    serverAddr.sin_addr.s_addr = htonl(INADDR_ANY);
  
    sFd = socket(AF_INET, SOCK_STREAM, 0);
    if (sFd == INVALID_SOCKET) {
        fprintf(stderr,"socket() call failed.\n");
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

    /*
     * Listening socket should always use the SO_REUSEADDR option
     * ("Unix Network Programming - Networking APIs:Sockets and XTI",
     *   Volume 1, 2nd edition, by W. Richard Stevens).
     */
    sockStatus = 
        setsockopt(sFd,SOL_SOCKET,SO_REUSEADDR,(char*)&option,sizeof(option));
    if (sockStatus == SOCK_ERR) {
        fprintf(stderr,"setsocketopt() call failed.\n");
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

    sockStatus = 
        bind(sFd, (struct sockaddr *) &serverAddr, sFdAddSize);
    if (sockStatus == SOCK_ERR) {
        fprintf(stderr,"bind() call failed: %s\n", strerror(errno));
        error = EXT_ERROR;
        goto EXIT_POINT;
    }
  
    sockStatus = listen(sFd, 2);
    if (sockStatus == SOCK_ERR) {
        fprintf(stderr,"listen() call failed.\n");
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

EXIT_POINT:
    UD->commFd = INVALID_SOCKET;

    if (error == EXT_ERROR) {
        if (sFd != INVALID_SOCKET) {
            close(sFd);
        }
        UD->sFd = INVALID_SOCKET;
    } else {
        UD->sFd = sFd;
    }
    return(error);
} /* end ExtInit */


/* Function: ExtOpenConnection =================================================
 * Abstract:
 *  Called when the target is not currently connected to the host, this 
 *  function attempts to open the connection.  In some cases, this may be
 *  trivial (e.g., shared memory, serial cable).  Whether or not the connection
 *  was made is returned by reference via the 'outConnectionMade' arg.
 *
 *  In the case of sockets, this is a passive operation in that the host
 *  initiates contact, the target simply listens for connection requests.
 *
 *  Returns EXT_NO_ERROR on success, EXT_ERROR otherwise.
 *
 * NOTES:
 *  o blocks if EXT_BLOCKING == 1, poll for pending connections otherwise.  When
 *    polling, there may be no open requests pending.  In this case, this 
 *    function returns without making the connection.  This is NOT an error.
 */
PUBLIC boolean_T ExtOpenConnection(
    ExtUserData *UD,
    boolean_T   *outConnectionMade)
{
    struct sockaddr_in clientAddr;
    int_T              sFdAddSize     = sizeof(struct sockaddr_in);
    boolean_T          connectionMade = FALSE; /* assume */
    boolean_T          error          = EXT_NO_ERROR;
    SOCKET             commFd         = INVALID_SOCKET;
    const SOCKET       sFd            = UD->sFd;

#if EXT_BLOCKING == 0
    /* Prevent blocking - poll */
    {
        boolean_T pending;
        
        error = SocketDataPending(sFd, &pending, 0, 0);
        if (error) goto EXIT_POINT;

        if (!pending) goto EXIT_POINT;
    }
#endif

    /*
     * Wait to accept a connection on the comm socket.
     */
    commFd = accept(sFd, (struct sockaddr *)&clientAddr,
                    IBM_GLNX_FIX &sFdAddSize);
    if (commFd == INVALID_SOCKET) {
        fprintf(stderr,"accept() for comm socket failed.\n");
        error = EXT_ERROR;
        goto EXIT_POINT;
    } else {
#ifdef VERBOSE
        printf("\n\naccepted new client %s - comm socket.\n",
            inet_ntoa(clientAddr.sin_addr));
#endif
    }

    connectionMade = TRUE;

EXIT_POINT:
    if (error != EXT_NO_ERROR) {
        if (commFd != INVALID_SOCKET) {
            close(commFd);
        }

        UD->commFd = INVALID_SOCKET;
    } else {
        UD->commFd = commFd;
    }
    
    *outConnectionMade = connectionMade;
    return(error);
} /* end ExtOpenConnection */


/* Function: ExtCloseConnection ================================================
 * Abstract:
 *  Called when the target needs to disconnect from the host (disconnect
 *  procedure is initiated by the host).
 */
PUBLIC void ExtCloseConnection(ExtUserData *UD)
{
    if (UD->commFd != INVALID_SOCKET) {
        PassiveSocketShutdown(UD->commFd);
    }

    UD->commFd = INVALID_SOCKET;
} /* end ExtCloseConnection */


/* Function: ExtShutDown =======================================================
 * Abstract:
 *  Called when the target program is terminating.
 */
PUBLIC void ExtShutDown(ExtUserData *UD)
{
    ExtCloseConnection(UD);
    close(UD->sFd);

#ifdef WIN32
    WSACleanup();
#endif
} /* end ExtShutDown */


/* Function: ExtProcessArgs ====================================================
 * Abstract:
 *  Process the arguments specified by the user when invoking the target
 *  program.  In the case of this TCPIP example the args handled by external
 *  mode are:
 *      o -port #
 *          specify tcpip port number
 *      
 *      o -w
 *          wait for a start packet from the target before starting to execute
 *          the real-time model code
 *
 *  If any unrecognized options are encountered, ignore them.
 *
 *  Store values of settings into the userdata.
 *
 * NOTES:
 *  o An error string is returned on failure, NULL is returned on success.
 *    If an error is returned, it is displayed by ext_svr with the following
 *    pre-fix:
 *
 *      "\nError processing External Mode command line arguments:\n");
 *
 *    It is assumed that printf exists on the target.
 *
 *  o IMPORTANT!!!
 *    As the arguments are processed, their strings must be NULL'd out in
 *    the argv array.  ext_svr will search argv when this function returns,
 *    and if any non-NULL entries are encountered an "unrecognized option" 
 *    packet will be displayed.
 */
PUBLIC const char_T *ExtProcessArgs(
    ExtUserData   *UD,
    const int_T   argc,
    const char_T  *argv[])
{
    char_T       tmpstr[2];
    const char_T *error          = NULL;
    int_T        count           = 1;
    int_T        port            = SERVER_PORT_NUM;
    boolean_T    waitForStartPkt = FALSE;

    while(count < argc) {
        const char_T *option = argv[count++];

        if (option == NULL) continue;
        
        if (strcmp(option, "-w") == 0) {
            /* 
             * -w (wait for packet from host) option
             */
            waitForStartPkt = TRUE;

            argv[count-1] = NULL;
        }
#ifndef VXWORKS
          else if ((strcmp(option, "-port") == 0) && (count != argc)) {
            /* 
             * -port option
             */
            const char_T *portStr = argv[count++];

            if ((sscanf(portStr,"%d%1s", &port, tmpstr) != 1) ||
                ((port < 255) || (port > 65535)) ) {
                
                error = "port must be in range: 256 to 65535\n";
                goto EXIT_POINT;
            }

            argv[count-2] = NULL;
            argv[count-1] = NULL;
        }
#endif
    }

    /*
     * Store local parse settings into external mode user data.
     */
    assert(UD != NULL);
    UD->port            = port;
    UD->waitForStartPkt = waitForStartPkt;

EXIT_POINT:
    return(error);
} /* end ExtProcessArgs */


/* Function: ExtWaitForStartPktFromHost ========================================
 * Abstract:
 *  Return true if the model should not start executing until told to do so
 *  by the host.
 */
PUBLIC boolean_T ExtWaitForStartPktFromHost(ExtUserData *UD)
{
    return(UD->waitForStartPkt);
} /* end ExtWaitForStartPktFromHost */

/* Function: ExtUserDataCreate =================================================
 * Abstract:
 *  Create the user data.
 */
PUBLIC ExtUserData *ExtUserDataCreate(void)
{
    static ExtUserData UD;

    return &UD;
} /* end ExtUserDataCreate */


/* Function: ExtUserDataDestroy ================================================
 * Abstract:
 *  Destroy the user data.
 */
PUBLIC void ExtUserDataDestroy(ExtUserData *UD)
{
} /* end ExtUserDataDestroy */


/* Function: ExtUserDataSetPort ================================================
 * Abstract:
 *  Set the port in the external mode user data structure.
 */
#ifdef VXWORKS
PUBLIC void ExtUserDataSetPort(ExtUserData *UD, const int_T port)
{
    UD->port = port;
} /* end ExtUserDataSetPort */
#endif


/* Function: ExtGetHostPkt =====================================================
 * Abstract:
 *  Attempts to get the specified number of bytes from the comm line.  The
 *  number of bytes read is returned via the 'nBytesGot' parameter.
 *  EXT_NO_ERROR is returned on success, EXT_ERROR is returned on failure.
 *
 * NOTES:
 *  o it is not an error for 'nBytesGot' to be returned as 0
 *  o blocks if no data available and EXT_BLOCKING == 1, polls otherwise
 *  o not guaranteed to read total requested number of bytes
 */
PUBLIC boolean_T ExtGetHostPkt(
    const ExtUserData *UD,
    const int         nBytesToGet,
    int               *nBytesGot, /* out */
    char              *dst)       /* out */
{
    boolean_T error = EXT_NO_ERROR;

#if EXT_BLOCKING == 0
    /* Prevent blocking - poll */
    {
        boolean_T pending;
        
        error = SocketDataPending(UD->commFd, &pending, 0, 0);
        if (error) goto EXIT_POINT;

        if (!pending) {
            *nBytesGot = 0;
            goto EXIT_POINT;
        }
    }
#endif

    error = SocketDataGet(UD->commFd,nBytesToGet,nBytesGot,dst);
    if (error) goto EXIT_POINT;

EXIT_POINT:
    return(error);
} /* end ExtGetHostPkt */


/* Function: ExtSetHostPkt =====================================================
 * Abstract:
 *  Sets (sends) the specified number of bytes on the comm line.  As long as
 *  an error does not occur, this function is guaranteed to set the requested
 *  number of bytes.  The number of bytes set is returned via the 'nBytesSet'
 *  parameter.  EXT_NO_ERROR is returned on success, EXT_ERROR is returned on
 *  failure.
 *
 * NOTES:
 *  o it is always o.k. for this function to block if no room is available
 */
PUBLIC boolean_T ExtSetHostPkt(
    const ExtUserData *UD,
    const int         nBytesToSet,
    const char        *src,
    int               *nBytesSet) /* out */
{
    return(SocketDataSet(UD->commFd,nBytesToSet,src,nBytesSet));
} /* end ExtSetHostPkt */


/* Function: ExtModeSleep ======================================================
 * Abstract:
 *  Called by grt_main, ert_main, and grt_malloc_main to "pause" (hopefully in
 *  a way that does not hog the CPU) execution.  
 *
 *  In this TCPIP example, we simply do a select with an appropriate time
 *  out on the sFd socket.  The process will pause for the specified time,
 *  or until data (or a request connect) arrives on sFd.
 *
 */
#ifndef VXWORKS
PUBLIC void ExtModeSleep(
    const ExtUserData *UD,
    const long        sec,  /* # of secs to wait        */
    const long        usec) /* # of micros secs to wait */
{
    struct timeval tval;
    fd_set         ReadFds;
    
    tval.tv_sec  = sec;
    tval.tv_usec = usec;

    FD_ZERO(&ReadFds);
    FD_SET(UD->sFd, &ReadFds);
    (void)select(UD->sFd + 1, &ReadFds, NULL, NULL, &tval);
} /* end ExtModeSleep */
#endif


/* Function: ExtForceDisconnect ================================================
 * Abstract:
 *  Called by rt_UploadServerWork() in ext_svr.c when there is an extmode
 *  communication error (e.g. a tcp/ip disconnection between the host and target
 *  caused by a cable problem or extremely high network traffic).  In this case,
 *  we want the target to disconnect from the host even if it can't communicate
 *  with the host because we assume that the communication problem caused the
 *  host to disconnect.  This function will perform all steps necessary to
 *  shutdown the communication and leave the target in a state ready to be
 *  reconnected.
 */
PUBLIC void ExtForceDisconnect(ExtUserData *UD)
{
    if (UD->commFd != INVALID_SOCKET) {
        close(UD->commFd);
    }

    UD->commFd = INVALID_SOCKET;
} /* end ExtForceDisconnect */


/* [EOF] ext_svr_tcpip_transport.c */
