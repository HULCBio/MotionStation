/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_svr_custom_transport.c     $Revision: 1.1.6.3 $
 *
 * Abstract:
 *  Target-side, transport-dependent external mode functions and defs.  This
 *  template file should be used as a starting point for implementing other
 *  transport mechanisms:
 *
 *    1. Modify the functions in the 'Visible Functions' and
 *       'Transport-dependent Includes' sections.  Note that all of these, as
 *       well as the 'UserData' definition, must exist.
 *    2. Modify the target template makefiles to build the new transport
 *       layer into the target.
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
 *
 * The files relating to target-side external mode are:
 *  <target>_main.c
 *      The main program harness for the generated code.  There is a different
 *      main.c for each target (i.e., grt_main.c for grt, rt_main.c for
 *      VXWORKS, etc).  This program controls the execution of the model.
 *      When compiled for external mode, this program contains the
 *      external mode "instrumentation" (i.e., function calls) into External
 *      Mode to enable data uploading and downloading.
 *
 *      [THIS FILE SHOULD NOT NEED TO BE MODIFIED FOR DIFFERENT TRANSPORT
 *       MECHANISMS] 
 *
 *  ext_svr.c
 *      The server for external mode.  This file is the interface between the
 *      model and external mode and essentially contains the boilerplate
 *      code for external mode.  It generally contains:
 *          o transport-independent functions (wrappers) for external mode
 *            communication
 *          o function dispatch for some of the more involved external mode
 *            tasks (i.e., dispatch for setting params, etc).
 *      The code is transport-independent (i.e., should not have to change
 *      whether using sockets, shared memory, etc).  Note that updown.c
 *      is the module that takes care of most of the detailed, dirty work
 *      such as decoding the set param packet and installing the new
 *      parameter values into the parameter struct (rtP).
 *
 *      [THIS FILE SHOULD NOT NEED TO BE MODIFIED FOR DIFFERENT TRANSPORT
 *       MECHANISMS] 
 *
 *  ext_svr_custom_transport.c
 *      This file. Transport-dependent external mode code (e.g., set bytes on
 *      host, get bytes from host, etc).
 *
 *      [THIS FILE NEEDS TO BE MODIFIED TO IMPLEMENT VARIOUS DATA TRANSPORT
 *       MECHANISMS]
 *
 *  ext_custom_utils.c
 *      Definitions that are specific to the implemented transport mechanism
 *      and that are required on both the host and the target.
 *
 *      [THIS FILE NEEDS TO BE MODIFIED TO IMPLEMENT VARIOUS DATA TRANSPORT
 *       MECHANISMS]
 *
 *  updown.c
 *      Transport-independent guts of external mode.  Most direct interaction
 *      with target memory occurs in this file.  For example:
 *          o decode set param packet & install new param values into
 *            parameter array
 *          o Add data to upload buffers.
 *          o Monitor triggers and change trigger state.
 *          o and on, and on, and on....
 *
 *      [THIS FILE SHOULD NOT NEED TO BE MODIFIED FOR DIFFERENT TRANSPORT
 *       MECHANISMS] 
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

/***************** TRANSPORT-INDEPENDENT INCLUDES *****************************
 *                                                                            *
 * THESE INCLUDES ARE INDEPENDENT OF THE TRANSPORT IMPLEMENTATION AND SHOULD  *
 * NOT BE REMOVED WHEN IMPLEMENTING A NEW TRANSPORT LAYER.                    *
 *                                                                            *
 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "updown_util.h"
#include "tmwtypes.h"
#include "ext_types.h"
#include "ext_share.h"

/***************** TRANSPORT-DEPENDENT INCLUDES *******************************
 *                                                                            *
 * THESE INCLUDES ARE SPECIFIC TO THE TRANSPORT IMPLEMENTATION AND WOULD BE   *
 * MODIFIED WHEN IMPLEMENTING A NEW TRANSPORT LAYER.                          *
 *                                                                            *
 ******************************************************************************/

#include "ext_custom_utils.c"


/***************** DEFINE USER DATA HERE **************************************
 *                                                                            *
 * THE DEFINITION OF EXTERNAL MODE'S USER DATA IS SPECIFIC TO THE TRANSPORT   *
 * IMPLEMENTATION.  IT IS EXPORTED AS AN 'OPAQUE' OR 'INCOMPLETE' TYPE IN     *
 * EXT_SVR_TRANSORT.H.  SEE EXT_SVR_TRANSPORT.H FOR MORE INFO.                *
 *                                                                            *
 * NOTE THAT USERDATA MUST EXIST.  IF NOT NEEDED, DEFINE IT TO HAVE ONE DUMMY *
 * FIELD                                                                      *
 *                                                                            *
 ******************************************************************************/

typedef struct ExtUserData_tag {
    int_T dummy;
} ExtUserData;


/***************** PRIVATE FUNCTIONS ******************************************
 *                                                                            *
 *  THE FOLLOWING FUNCTIONS ARE SPECIFIC TO THE CUSTOM IMPLEMENTATION OF      *
 *  HOST-TARGET COMMUNICATION.  SEE THE 'VISIBLE FUNCTIONS' SECTION FOR THE   *
 *  GENERIC SET OF FUNCTIONS THAT ARE CALLED BY EXTERNAL MODE.  TO IMPLEMENT  *
 *  A CUSTOM VERSION OF EXTERNAL MODE (E.G. SHARED MEMORY, SERIAL CABLE, ETC) *
 *  THE BODIES OF THE FUNCTIONS IN THE 'VISIBLE FUNCTIONS' SECTION MUST BE    *
 *  MODIFIED.                                                                 *
 *                                                                            *
 ******************************************************************************/

/*
 * Any private function common to the host and target should be defined in:
 *   <matlabroot>/rtw/c/src/ext_mode/custom/ext_custom_utils.c
 */


/***************** VISIBLE FUNCTIONS ******************************************
 *                                                                            *
 *  YOU MUST REPLACE EACH OF THE FOLLOWING FUNCTIONS TO IMPLEMENT A CUSTOM    *
 *  VERSION OF EXTERNAL MODE.                                                 *
 *                                                                            *
 *  ALSO SEE <MATLABROOT>/RTW/C/SRC/EXT_MODE/CUSTOM/EXT_CUSTOM_UTILS.C FOR    *
 *  ADDING DEFS FOR YOUR CUSTOM IMPLEMENTATION THAT ARE REQUIRED BY BOTH THE  *
 *  HOST AND THE TARGET.                                                      *
 *                                                                            *
 ******************************************************************************/


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
} /* end ExtOpenConnection */


/* Function: ExtCloseConnection ================================================
 * Abstract:
 *  Called when the target needs to disconnect from the host (disconnect
 *  procedure is initiated by the host).
 */
PUBLIC void ExtCloseConnection(ExtUserData *UD)
{
} /* end ExtCloseConnection */


/* Function: ExtShutDown =======================================================
 * Abstract:
 *  Called when the target program is terminating.
 */
PUBLIC void ExtShutDown(ExtUserData *UD)
{
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
} /* end ExtProcessArgs */


/* Function: ExtWaitForStartPktFromHost ========================================
 * Abstract:
 *  Return true if the model should not start executing until told to do so
 *  by the host.
 */
PUBLIC boolean_T ExtWaitForStartPktFromHost(ExtUserData *UD)
{
} /* end ExtWaitForStartPktFromHost */


/* Function: ExtUserDataCreate =================================================
 * Abstract:
 *  Create the user data.
 */
PUBLIC ExtUserData *ExtUserDataCreate(void)
{
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
} /* end ExtForceDisconnect */


/* [EOF] ext_svr_custom_transport.c */
