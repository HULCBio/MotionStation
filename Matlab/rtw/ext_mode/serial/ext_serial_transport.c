/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_serial_transport.c     $Revision: 1.1.6.4 $
 *
 * Abstract:
 *  Host-side, transport-dependent external mode functions and defs.  This    
 *  example file implements host/target communication using serial
 *  communication.  To implement a custom transport layer, use the template
 *  in ext_custom_transport.c.
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
 */

/***************** TRANSPORT-INDEPENDENT INCLUDES *****************************/

#include <time.h>
#include "tmwtypes.h"
#include "mex.h"
#include "extsim.h"
#include "extutil.h"


/***************** TRANSPORT-DEPENDENT INCLUDES *******************************/

#include "ext_serial_port.h"
#include "ext_serial_pkt.h"
#include "ext_serial_utils.c"


/***************** DEFINE USER DATA HERE **************************************/

typedef struct UserData_tag {
    uint16_T      port;
    uint32_T      baud;
    ExtSerialPort *portDev;

} UserData;


/***************** PRIVATE FUNCTIONS ******************************************/


/***************** VISIBLE FUNCTIONS ******************************************/

/* Function: ExtTargetPktPending ===============================================
 * Abstract:
 *  Returns true, via the 'pending' arg, if data is pending on the comm line.
 *  Returns false otherwise.  If the timeout is 0, do simple polling (i.e.,
 *  return immediately).  Otherwise, wait the specified amount of seconds.
 *  The timeOutUSecs field is ignored for serial communication.
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
    time_t    startTime;
    time_t    currTime;
    double    timeLimit = (double)timeOutSecs;
    boolean_T error     = EXT_NO_ERROR;
    UserData  *userData = (UserData *)esGetUserData(ES);

    time(&startTime);

    /*
     * This loop is guaranteed to exit due to one of the following:
     *  1) ExtPktPending() receives an error.
     *  2) There is a pkt pending.
     *  3) There is no pkt pending and the timeout is exceeded.
     */
    while (1) {
        error = ExtPktPending(userData->portDev, pending);
        if (error != EXT_NO_ERROR) goto EXIT_POINT;

        if (*pending || !timeLimit) goto EXIT_POINT;

        time(&currTime);
        if (difftime(currTime, startTime) > timeLimit) {
            error = EXT_ERROR;
            goto EXIT_POINT;
        }
    }

  EXIT_POINT:
    return error;
} /* end ExtTargetPktPending */


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
    boolean_T error     = EXT_NO_ERROR;
    UserData  *userData = (UserData *)esGetUserData(ES);

    error = ExtSetPktWithACK(userData->portDev,
                             (char *)src,
                             (int)nBytesToSet,
                             EXTMODE_PACKET);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

    *nBytesSet = nBytesToSet;

  EXIT_POINT:
    return error;
} /* end ExtSetTargetPkt */


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

    return ExtGetPkt(userData->portDev, dst, nBytesToGet, nBytesGot);
} /* end ExtGetTargetPkt */

/* Function: ExtCloseConnection ================================================
 * Abstract:
 *  Close the connection with the target.
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

    if (userData->portDev != NULL) {
        if (ExtCloseSerialConnection(userData->portDev) != EXT_NO_ERROR) {
            esSetError(ES, "ExtCloseSerialConnection() returned an error.\n");
        }
	userData->portDev = NULL;
    }

EXIT_POINT:
    return;
} /* end ExtCloseConnection */


/* Function: ExtOpenConnection =================================================
 * Abstract:
 *  Open the connection with the target.
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
    UserData *userData = (UserData *)esGetUserData(ES);
    
    userData->portDev = ExtOpenSerialConnection(userData->port,userData->baud);
    if (userData->portDev == NULL) {
        esSetError(ES, "ExtOpenSerialConnection() returned an error.\n");
        goto EXIT_POINT;
    }

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

    if (ud != NULL) ud->portDev = NULL;

    return(ud);
} /* end ExtUserDataCreate */


/* Function: ExtUserDataDestroy ================================================
 * Abstract:
 *  Destroy the user data.
 */
PUBLIC void ExtUserDataDestroy(UserData *userData)
{
    if (userData != NULL) free(userData);

} /* end ExtUserDataDestroy */

/* Function: ExtProcessArgs ====================================================
 * Abstract:
 *  Process the arguments specified by the user in the 'Target Interface'
 *  panel of the 'External Mode Control' dialog.  In the case of
 *  this serial line example the args are:
 *      o verbosity
 *      o serial port number
 *      o serial baud rate
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

    /* ... Argument 1 - verbosity */
    if(nrhs >= 1) {
        boolean_T     verbosity;
        const mxArray *mat = prhs[0];
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
  
    /* ... Argument 2 - serial comm port value */
    if (nrhs >= 2) {
        uint16_T      port;
        const mxArray *mat = prhs[1];
        int_T         m    = mxGetM(mat);
        int_T         n    = mxGetN(mat);

        const char msg[] = 
            "Port argument must be a real, scalar, integer value in the range: "
            "[1-32].";

        /* verify that we've got a real, scalar integer */
        if (!mxIsNumeric(mat) || mxIsComplex(mat) || mxIsSparse(mat) ||
            !mxIsDouble(mat) || (!(m ==1 && n ==1)) || !IS_INT(*mxGetPr(mat))) {
            esSetError(ES, msg);
            goto EXIT_POINT;
        }
        port = (uint16_T) *(mxGetPr(mat));

        /* check port range */
        if ((port < 1) || (port > 32))
	{
	    esSetError(ES, msg);
	    goto EXIT_POINT;
	}

        userData->port = port;
    } else {
        /* use default */
        userData->port = 1;
    }

    /* ... Argument 3 - serial baud rate value */
    if (nrhs >= 3) {
        uint_T        i;
        uint32_T      baud;
        const mxArray *mat         = prhs[2];
        int_T         m            = mxGetM(mat);
        int_T         n            = mxGetN(mat);
        uint_T        numBaudRates = sizeof(baudRates)/sizeof(uint32_T);

        /* verify that we've got a real, scalar integer */
        if (!mxIsNumeric(mat) || mxIsComplex(mat) || mxIsSparse(mat) ||
            !mxIsDouble(mat) || (!(m ==1 && n ==1)) || !IS_INT(*mxGetPr(mat))) {
            esSetError(ES, baudRatesStr);
            goto EXIT_POINT;
        }
        baud = (uint32_T) *(mxGetPr(mat));

        /* Does the baud rate match any of the acceptable baud rates? */
        for (i=0 ; i<numBaudRates ; i++) {
            if (baud == baudRates[i]) break;
        }
        if (i == numBaudRates) {
            esSetError(ES, baudRatesStr);
             goto EXIT_POINT;
        }

        userData->baud = (uint32_T)baud;
    } else {
        /* use default */
        userData->baud = (uint32_T)57600;
    }

EXIT_POINT:
    return;
} /* end ExtProcessArgs */


/* [EOF] ext_serial_transport.c */
