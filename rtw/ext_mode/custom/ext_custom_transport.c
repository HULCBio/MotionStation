/*
 * Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: ext_custom_transport.c     $Revision: 1.1.6.1 $
 *
 * Abstract:
 *  Host-side, transport-dependent external mode functions and defs.  This
 *  template file should be used as a starting point for implementing other
 *  transport mechanisms:
 *
 *    1. Modify the functions in the 'Visible Functions' section.  Note that
 *       all of these functions, as well as the 'UserData' definition, must
 *       exist.
 *    2. Modify the 'Transport-Dependent Includes' section of for any include
 *       files needed by the specific transport implementation.
 *    3. Modify makefile.nt and makefile.unix to build the new transport
 *       mex-file.
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
 * The files relating to host-side external mode are:
 *  ext_main.c
 *      The mex file interface to Simulink.  This gets/sets packet flags
 *      and data from/to Simulink and dispatches as approriate to ext_comm.c.
 *
 *      [THIS FILE SHOULD NOT NEED TO BE MODIFIED]
 *
 *  ext_comm.c
 *      Transport-independent external mode functions.  Handles external mode
 *      tasks and dispatches all transport-specific tasks (e.g. TCPIP, serial,
 *      etc.) to this file.
 *
 *      [THIS FILE SHOULD NOT NEED TO BE MODIFIED FOR DIFFERENT TRANSPORT
 *       MECHANISMS] 
 *
 *  ext_custom_transport.c
 *      This file.  Transport-dependent implementation of the mandatory
 *      support functions (e.g., set bytes, get bytes, open connection, etc).
 *
 *      [THIS FILE NEEDS TO BE MODIFIED TO IMPLEMENT VARIOUS DATA TRANSPORT
 *       MECHANISMS]
 *
 *  <matlabroot>/rtw/c/src/ext_mode/custom/ext_custom_utils.c
 *      Defininitions that are specific to the implemented transport mechanism
 *      and that are required on both the host and the target.
 *
 *      [THIS FILE NEEDS TO BE MODIFIED TO IMPLEMENT VARIOUS DATA TRANSPORT
 *       MECHANISMS]
 *
 *  ext_convert.c
 *      Conversion routines from host to target and vice versa.  All conversion
 *      is done on the host.  The target always sends and receives data in
 *      it's native format.
 *
 *      [THIS FILE DOES NOT NEED TO BE CUSTOMIZED FOR VARIOUS TRANSPORT
 *       MECHANISMS, BUT DOES NEED TO BE CUSTOMIZED FOR THE INTENDED TARGET.
 *       FOR EXAMPLE, IF THE TARGET REPRESENTS FLOATS IN TI FORMAT, THEN
 *       EXT_CONVERT MUST BE MODIFIED TO PERFORM A TI TO IEEE CONVERSION.
 *       THE CONVERSION ROUTINES IN THIS FILE ARE CALLED BOTH FROM
 *       EXT_COMM AND DIRECTLY FROM SIMULINK (VIA FUNCTION POINTERS)]
 *
 * For the target, see
 *  <matlabroot>/rtw/c/src/ext_mode/custom/ext_svr_custom_transport.c.
 */

/***************** TRANSPORT-INDEPENDENT INCLUDES *****************************
 *                                                                            *
 * THESE INCLUDES ARE INDEPENDENT OF THE TRANSPORT IMPLEMENTATION AND SHOULD  *
 * NOT BE REMOVED WHEN IMPLEMENTING A NEW TRANSPORT LAYER.                    *
 *                                                                            *
 ******************************************************************************/

#include "tmwtypes.h"
#include "mex.h"
#include "extsim.h"
#include "extutil.h"


/***************** TRANSPORT-DEPENDENT INCLUDES *******************************
 *                                                                            *
 * THESE INCLUDES ARE SPECIFIC TO THE TRANSPORT IMPLEMENTATION AND WOULD BE   *
 * MODIFIED WHEN IMPLEMENTING A NEW TRANSPORT LAYER.                          *
 *                                                                            *
 ******************************************************************************/

#include "ext_custom_utils.c"


/***************** DEFINE USER DATA HERE **************************************
 *                                                                            *
 * THE DEFINITION OF USER DATA IS SPECIFIC TO THE TRANSPORT IMPLEMENTATION.   *
 * IT IS EXPORTED AS AN 'OPAQUE' OR 'INCOMPLETE' TYPE IN EXT_TRANSORT.H.  SEE *
 * EXT_TRANSPORT.H FOR MORE INFO.                                             *
 *                                                                            *
 * NOTE THAT USERDATA MUST EXIST.  IF NOT NEEDED, DEFINE IT TO HAVE ONE DUMMY *
 * FIELD                                                                      *
 *                                                                            *
 ******************************************************************************/

typedef struct UserData_tag {
    int_T dummy;
} UserData;


/***************** PRIVATE FUNCTIONS ******************************************
 *                                                                            *
 *  THE FOLLOWING FUNCTIONS ARE SPECIFIC TO THIS MECHANISM EXAMPLE OF HOST-   *
 *  TARGET COMMUNICATION.  SEE THE 'VISIBLE FUNCTIONS' SECTION FOR THE        *
 *  GENERIC SET OF FUNCTIONS THAT ARE CALLED BY EXTERNAL MODE.  TO IMPLEMENT  *
 *  A CUSTOM VERSION OF EXTERNAL MODE (E.G. SHARED MEMORY, ETC) THE BODIES    *
 *  OF THE FUNCTIONS IN THE 'VISIBLE FUNCTIONS' SECTION MUST BE MODIFIED.     *
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
} /* end ExtOpenConnection */


/* Function: ExtUserDataCreate =================================================
 * Abstract:
 *  Create the user data.
 */
PUBLIC UserData *ExtUserDataCreate()
{
} /* end ExtUserDataCreate */


/* Function: ExtUserDataDestroy ================================================
 * Abstract:
 *  Destroy the user data.
 */
PUBLIC void ExtUserDataDestroy(UserData *userData)
{
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
} /* end ExtProcessArgs */


/* [EOF] ext_custom_transport.c */
