/*
 * Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: ext_transport.h     $Revision: 1.1.6.1 $
 *
 * Abstract:
 *  PUBLIC interface for ext_<mechanism>_transport.c.
 */

/********************* DO NOT CHANGE BELOW THIS LINE **************************
 *                                                                            *
 * The function prototypes below define the interface between ext_comm and    *
 * ext_custom.  They should not need to be changed.  Only the                 *
 * implementation of these functions in ext_<mechanism>_transport.c should    *
 * need to be modified.                                                       *
 *                                                                            *
 ******************************************************************************/

/*
 * Export the user data as an 'opaque' or 'incomplete' data type.  ext_comm
 * may reference it (i.e., pass pointers to it, but it can not dereference
 * the pointer).
 */
typedef struct UserData_tag UserData;

/*
 * Define the transport interface.
 */
extern boolean_T ExtTargetPktPending(
    const ExternalSim *ES,
    boolean_T         *pending,
    long int          timeOutSecs,
    long int          timeOutUSecs);

extern boolean_T ExtGetTargetPkt(
    const ExternalSim *ES,
    const int         nBytesToGet,
    int               *nBytesGot,
    char              *dst);

extern boolean_T ExtSetTargetPkt(
    const ExternalSim *ES,
    const int         nBytesToSet,
    const char        *src,
    int               *nBytesSet);

extern void ExtCloseConnection(ExternalSim *ES);

extern void ExtOpenConnection(ExternalSim *ES);

extern UserData *ExtUserDataCreate();

extern void ExtUserDataDestroy(UserData *userData);

extern void ExtProcessArgs(
    ExternalSim   *ES,
    int           nrhs,
    const mxArray *prhs[]);

