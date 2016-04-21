/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_svr_transport.c     $Revision: 1.1.6.5 $
 *
 * Abstract:
 *  Target-side, transport-dependent external mode functions and defs.  This    
 *  example file implements host/target communication using serial
 *  communication.  To implement a custom transport layer, use the template
 *  in ext_svr_custom_transport.c.
 *
 * Functionality supplied by this module includes:
 *
 *      o definition of user data
 *      o is host packet pending
 *      o get bytes from host comm line
 *      o set bytes on host comm line
 *      o close connection with host
 *      o open connection with host
 *      o create user data
 *      o destroy user data
 *      o process command line arguments
 *      o initialize external mode
 *      o terminate external mode
 */


/*
 * Explanation of the EXT_BLOCKING:
 *
 * Depending on the implementation of the main program (e.g., grt_main.c,
 * rt_main.c), the EXT_BLOCKING flag must be set to either 0 or 1.  Let's
 * look at two examples:
 *
 *   grt_main.c (grt):
 *   grt_main is a real-time template that essentially runs a simulation - in
 *   non-real-time - in a single thread.  As seen in grt, the calls to the
 *   upload & pkt servers are "in the loop".  If any function related to
 *   external mode were to block, the real-time code would be prevented from
 *   running.  In this case, we prevent blocking and poll instead.
 *
 *   rt_main.c (tornado/vxworks):
 *   rt_main.c is a full blown, real-time, multi-tasking target.  The
 *   upload and pkt servers are called via background (low priority) tasks.
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

/*
 *  grt - single thread (See "Explanation of the EXT_BLOCKING" above)
 */
# define EXT_BLOCKING (0)

#include "ext_serial_port.h"
#include "ext_serial_pkt.h"
#include "ext_serial_utils.c"


/***************** DEFINE USER DATA HERE **************************************/

typedef struct ExtUserData_tag {
    boolean_T     waitForStartPkt;
    int16_T       port;
    int32_T       baud;
    ExtSerialPort *portDev;
} ExtUserData;


/***************** PRIVATE FUNCTIONS ******************************************/


/***************** VISIBLE FUNCTIONS ******************************************/

/* Function: ExtInit ===========================================================
 * Abstract:
 *  Called once at program startup to do any initialization related to external
 *  mode.  For the serial example, there is very little to do.  EXT_NO_ERROR is
 *  returned on success, EXT_ERROR on failure.
 *
 * NOTES:
 *  o This function should not block.
 */
boolean_T ExtInit(ExtUserData *UD)
{
    boolean_T error = EXT_NO_ERROR;

    UD->portDev = ExtOpenSerialConnection(UD->port,UD->baud);
    if (UD->portDev == NULL) {
        fprintf(stderr,"ExtOpenSerialConnection() call failed.\n");
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

EXIT_POINT:
    return(error);
} /* end ExtInit */


/* Function: ExtOpenConnection =================================================
 * Abstract:
 *  Called when the target is not currently connected to the host, this 
 *  function attempts to open the connection.  In some cases, this may be
 *  trivial (e.g., shared memory, serial cable).  Whether or not the connection
 *  was made is returned by reference via the 'outConnectionMade' arg.
 *
 *  Returns EXT_NO_ERROR on success, EXT_ERROR otherwise.
 *
 * NOTES:
 *  o blocks if EXT_BLOCKING == 1, poll for pending connections otherwise.  When
 *    polling, there may be no open requests pending.  In this case, this 
 *    function returns without making the connection.  This is NOT an error.
 */
boolean_T ExtOpenConnection(ExtUserData *UD, boolean_T *outConnectionMade)
{
    *outConnectionMade = (UD->portDev == NULL) ? false : true;

    return(EXT_NO_ERROR);
} /* end ExtOpenConnection */


/* Function: ExtCloseConnection ================================================
 * Abstract:
 *  Called when the target needs to disconnect from the host (disconnect
 *  procedure is initiated by the host).
 */
void ExtCloseConnection(ExtUserData *UD)
{
    ExtClearSerialConnection();
} /* end ExtCloseConnection */


/* Function: ExtShutDown =======================================================
 * Abstract:
 *  Called when the target program is terminating.
 */
void ExtShutDown(ExtUserData *UD)
{
    if (UD->portDev != NULL) {
        if (ExtCloseSerialConnection(UD->portDev) != EXT_NO_ERROR) {
            fprintf(stderr, "ExtCloseSerialConnection() returned an error.\n");
        }
	UD->portDev = NULL;
    }
} /* end ExtShutDown */


/* Function: ExtProcessArgs ====================================================
 * Abstract:
 *  Process the arguments specified by the user when invoking the target
 *  program.  In the case of this serial example the args handled by external
 *  mode are:
 *      o -port #
 *          specify comm port number
 *      
 *      o -baud #
 *          specify comm port baud rate
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
const char_T *ExtProcessArgs(ExtUserData  *UD,
                             const int_T  argc,
                             const char_T *argv[])
{
    char_T       tmpstr[2];
    const char_T *error          = NULL;
    int_T        count           = 1;
    int16_T      port            = 1;
    uint32_T     baud            = (uint32_T)57600;
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
        else if ((strcmp(option, "-port") == 0) && (count != argc)) {
            /* 
             * -port option
             */
            const char_T *portStr = argv[count++];

            if ((sscanf(portStr,"%d%1s", &port, tmpstr) != 1) ||
		(port < 1) || (port > 32)) {
                
                error = "port must be in range: 1 to 32\n";
                goto EXIT_POINT;
            }

            argv[count-2] = NULL;
            argv[count-1] = NULL;
        }
        else if ((strcmp(option, "-baud") == 0) && (count != argc)) {
            /* 
             * -baud option
             */
            uint_T       i;
            const char_T *baudStr     = argv[count++];
            uint_T       numBaudRates = sizeof(baudRates)/sizeof(uint32_T);

            /* Read the baud rate string into an integer. */
            if (sscanf(baudStr,"%d%1s", &baud, tmpstr) != 1) {
                error = baudRatesStr;
                goto EXIT_POINT;
            }

            /* Does the baud rate match any of the acceptable baud rates? */
            for (i=0 ; i<numBaudRates ; i++) {
                if (baud == baudRates[i]) break;
            }
            if (i == numBaudRates) {
                error = baudRatesStr;
                goto EXIT_POINT;
            }

            argv[count-2] = NULL;
            argv[count-1] = NULL;
        }
    }

    /*
     * Store local parse settings into external mode user data.
     */
    assert(UD != NULL);
    UD->waitForStartPkt = waitForStartPkt;
    UD->port            = port;
    UD->baud            = baud;
    UD->portDev         = NULL;

EXIT_POINT:
    return(error);
} /* end ExtProcessArgs */


/* Function: ExtWaitForStartPktFromHost ========================================
 * Abstract:
 *  Return true if the model should not start executing until told to do so
 *  by the host.
 */
boolean_T ExtWaitForStartPktFromHost(ExtUserData *UD)
{
    return(UD->waitForStartPkt);
} /* end ExtWaitForStartPktFromHost */


/* Function: ExtUserDataCreate =================================================
 * Abstract:
 *  Create the user data.
 */
ExtUserData *ExtUserDataCreate(void)
{
    static ExtUserData UD;

    return &UD;
} /* end ExtUserDataCreate */


/* Function: ExtUserDataDestroy ================================================
 * Abstract:
 *  Destroy the user data.
 */
void ExtUserDataDestroy(ExtUserData *UD)
{
} /* end ExtUserDataDestroy */


/* Function: ExtUserDataSetPort ================================================
 * Abstract:
 *  Set the port in the external mode user data structure.
 */
#ifdef VXWORKS
void ExtUserDataSetPort(ExtUserData *UD, const int_T port)
{
    UD->port = port;
} /* end ExtUserDataSetPort */
#endif


/* Function: ExtGetHostPkt =====================================================
 * Abstract:
 *  Attempts to get the specified number of bytes from the comm line.  The number
 *  of bytes read is returned via the 'nBytesGot' parameter.  EXT_NO_ERROR is
 *  returned on success, EXT_ERROR is returned on failure.
 *
 * NOTES:
 *  o it is not an error for 'nBytesGot' to be returned as 0
 *  o blocks if no data available and EXT_BLOCKING == 1, polls otherwise
 *  o not guaranteed to read total requested number of bytes
 */
boolean_T ExtGetHostPkt(
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

        error = ExtPktPending(UD->portDev, &pending);
        if (error != EXT_NO_ERROR) goto EXIT_POINT;

        if (!pending) {
            *nBytesGot = 0;
            goto EXIT_POINT;
        }
    }
#endif

    error = ExtGetPkt(UD->portDev, dst, nBytesToGet, nBytesGot);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

  EXIT_POINT:
    return error;
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
boolean_T ExtSetHostPkt(
    const ExtUserData *UD,
    const int         nBytesToSet,
    const char        *src,
    int               *nBytesSet) /* out */
{
    boolean_T error = EXT_NO_ERROR;

    error = ExtSetPktWithACK(UD->portDev,
                             (char *)src,
                             (int)nBytesToSet,
                             EXTMODE_PACKET);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

    *nBytesSet = nBytesToSet;

  EXIT_POINT:
    return(error);
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
void ExtModeSleep(
    const ExtUserData *UD,
    const long        sec,  /* # of secs to wait        */
    const long        usec) /* # of micros secs to wait */
{
    /* How do we do this for for serial connection? */

    /* Don't do this on a bareboard system. This is for when ext mode is in
     * a separate task. Then what? */
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
void ExtForceDisconnect(ExtUserData *UD)
{
    ExtSerialPortDisconnect(UD->portDev);
    UD->portDev = NULL;
}


/* [EOF] ext_svr_serial_transport.c */
