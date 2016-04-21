/*
 * Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: ext_tcpip_transport.c     $Revision: 1.1.6.1 $
 *
 * Absract:
 *  External mode shared data structures and functions used by the external
 *  communication, mex link, and generated code.  This file is for definitions
 *  related to custom external mode implementations (e.g., sockets, serial).
 *  See ext_share.h for definitions common to all implementations of external
 *  mode (ext_share.h should NOT be modified).
 */

/***************** TRANSPORT-DEPENDENT DEFS AND INCLUDES **********************/

#ifdef WIN32
  /* WINDOWS */
# define close closesocket
# define SOCK_ERR SOCKET_ERROR
#else
  /* UNIX, VXWORKS */
# define INVALID_SOCKET -1
# define SOCK_ERR (-1)

  typedef int SOCKET;
#endif

#define SERVER_PORT_NUM  (17725)   /* sqrt(pi)*10000 */


/***************** PRIVATE FUNCTIONS ******************************************/

/* Function: SocketDataPending =================================================
 * Abstract:
 *  Returns true, via the 'pending' arg, if data is pending on the comm line.
 *  Returns false otherwise.  If the timeout is 0, do simple polling (i.e.,
 *  return immediately).  Otherwise, wait the specified amount of time.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure (reaching
 *  a nonzero timeout is considered a failure).
 */
PRIVATE boolean_T SocketDataPending(
    const SOCKET sock,
    boolean_T    *outPending,
    long int     timeOutSecs,
    long int     timeOutUSecs)
{
    fd_set          ReadFds;
    int             pending;
    struct timeval  tval;
    boolean_T       error          = EXT_NO_ERROR;
    const int       timeOutOccured = 0;
    const boolean_T useTimeOut     = (boolean_T)((timeOutSecs != 0) || 
                                        (timeOutUSecs != 0));
    
    FD_ZERO(&ReadFds);
    FD_SET(sock, &ReadFds);

    tval.tv_sec  = timeOutSecs;
    tval.tv_usec = timeOutUSecs;

    pending = select(sock + 1, &ReadFds, NULL, NULL, &tval);
    if ((pending == SOCK_ERR) || (useTimeOut && (pending == timeOutOccured))) {
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

EXIT_POINT:
    *outPending = ((boolean_T)(pending == 1));
    return(error);    
} /* end SocketDataPending */ 


/* Function: SocketDataGet =====================================================
 * Abstract:
 *  Attempts to gets the specified number of bytes from the specified socket. 
 *  The number of bytes read is returned via the 'nBytesGot' parameter.
 *  EXT_NO_ERROR is returned on success, EXT_ERROR is returned on failure.
 *
 * NOTES:
 *  o it is not an error for 'nBytesGot' to be returned as 0
 *  o this function blocks if no data is available
 */
PRIVATE boolean_T SocketDataGet(
    const SOCKET sock,
    const int_T  nBytesToGet,
    int_T        *nBytesGot, /* out */
    char_T       *dst)       /* out */
{
    int_T     nRead;
    boolean_T error = EXT_NO_ERROR;
   
    nRead = recv(sock, dst, nBytesToGet, 0);
    if (nRead == SOCK_ERR) {
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

EXIT_POINT:
    if (error) {
        nRead = 0;
    }
    *nBytesGot = nRead;
    return(error);
} /* end SocketDataGet */ 


/* Function: SocketDataSet =====================================================
 * Abstract:
 *  Sets (sends) the specified number of bytes on the specified socket.  As long
 *  as an error does not occur, this function is guaranteed to set the requested
 *  number of bytes.  The number of bytes set is returned via the 'nBytesSet'
 *  parameter.  EXT_NO_ERROR is returned on success, EXT_ERROR is returned on
 *  failure.
 *
 * NOTES:
 *  o this function blocks if tcpip's send buffer doesn't have room for all
 *    of the data to be sent
 */
PRIVATE boolean_T SocketDataSet(
    const SOCKET sock,
    const int_T  nBytesToSet,
    const char_T *src,
    int_T        *nBytesSet) /* out */
{
    int_T     nSent;    
    boolean_T error = EXT_NO_ERROR;
    
#ifndef VXWORKS
    nSent = send(sock, src, nBytesToSet, 0);
#else
    /*
     * VXWORKS send prototype does not have src as const.  This suppresses
     * the compiler warning.
     */
    nSent = send(sock, (char_T *)src, nBytesToSet, 0);
#endif
    if (nSent == SOCK_ERR) {
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

EXIT_POINT:
    *nBytesSet = nSent;
    return(error);
} /* end SocketDataSet */


/* [EOF] ext_tcpip_utils.c */
