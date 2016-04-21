/* File:     xpcapiconst.h
 * Abstract: Constants defined for use in the xPC Target C API.
 * $Revision: 1.8.4.5 $ $Date: 2004/03/02 03:03:29 $
 */
/* Copyright 2000-2004 The MathWorks, Inc. */

#ifndef _XPCAPICONST_H_
#define _XPCAPICONST_H_

#define MAX_ERR_MSG_LENGTH 50
#define MAX_SCOPES         30
#define MAX_SIGNALS        10

/* Communication definitions */
#define COMMTYP_RS232       1
#define COMMTYP_TCPIP       2

/* Scope Definitions */
#define SCTYPE_NONE        0
#define SCTYPE_HOST        1
#define SCTYPE_TARGET      2
#define SCTYPE_FILE        3

#define TRIGMD_FREERUN     0
#define TRIGMD_SOFTWARE    1
#define TRIGMD_SIGNAL      2
#define TRIGMD_SCOPE       3
#define TRIGMD_SCEND       4

#define TRIGSLOPE_EITHER   0
#define TRIGSLOPE_RISING   1
#define TRIGSLOPE_FALLING  2

#define SCMODE_NUMERICAL   0
#define SCMODE_REDRAW      1
#define SCMODE_SLIDING     2
#define SCMODE_ROLLING     3

#define SCST_WAITTOSTART   0
#define SCST_WAITFORTRIG   1
#define SCST_ACQUIRING     2
#define SCST_FINISHED      3
#define SCST_INTERRUPTED   4
#define SCST_PREACQUIRING  5

/* Data Logging Definitions */
#define LGMOD_TIME         0
#define LGMOD_VALUE        1


typedef enum ErrorValues_tag {
    ENOERR               =   0,
    EINVPORT             =   1,
    ENOFREEPORT          =   2,
    EPORTCLOSED          =   3,
    EINVCOMMTYP          =   4,

    EINVCOMPORT          =   5,
    ECOMPORTISOPEN       =   6,
    ECOMPORTACCFAIL      =   7,
    ECOMPORTWRITE        =   8,
    ECOMPORTREAD         =   9,
    ECOMTIMEOUT          =  10,
    EINVBAUDRATE         =  11,

    EWSNOTREADY          =  12,
    EINVWSVER            =  13,
    EWSINIT              =  14,

    ESOCKOPEN            =  15,
    ETCPCONNECT          =  16,
    EINVADDR             =  17,

    EFILEOPEN            =  18,
    EWRITEFILE           =  19,

    ETCPREAD             =  20,
    ETCPWRITE            =  21,
    ETCPTIMEOUT          =  22,

    EPINGPORTOPEN        =  23,
    EPINGSOCKET          =  24,
    EPINGCONNECT         =  25,

    EINVTFIN             =  26,
    EINVTS               =  27,
    EINVARGUMENT         =  28,

    ELOGGINGDISABLED     =  29,
    ETETLOGDISABLED      =  30,
    EINVLGMODE           =  31,
    EINVLGINCR           =  32,
    EINVLGDATA           =  33,
    ENODATALOGGED        =  34,

    EINVSTARTVAL         =  35,
    EINVNUMSAMP          =  36,
    EINVDECIMATION       =  37,
    ETOOMANYSAMPLES      =  38,
    EINVLOGID            =  39,

    ESTOPSIMFIRST        =  40,
    ESTARTSIMFIRST       =  41,
    ERUNSIMFIRST         =  42,
    EUSEDYNSCOPE         =  43,

    ETOOMANYSCOPES       =  44,
    EINVSCTYPE           =  45,
    ESCTYPENOTTGT        =  46,
    EINVSCIDX            =  47,
    ESTOPSCFIRST         =  48,

    EINVSIGIDX           =  49,
    EINVPARIDX           =  50,
    ENOMORECHANNELS      =  51,

    EINVTRIGMODE         =  52,
    EINVTRIGSLOPE        =  53,

    EINVTRSCIDX          =  54,

    EINVNUMSIGNALS       =  55,
    EPARNOTFOUND         =  56,
    ESIGNOTFOUND         =  57,

    ENOSPACE             =  58,
    EMEMALLOC            =  59,
    ETGTMEMALLOC         =  60,
    EPARSIZMISMATCH      =  61,

    ELOADAPPFIRST        = 101,
    EUNLOADAPPFIRST      = 102,

    EINVALIDMODEL        = 151,
    EINVNUMPARAMS        = 152,

    EINVFILENAME         = 201,

    EFILEREAD            = 211,
    EFILEWRITE           = 212,
    EFILERENAME          = 213,

    EINVXPCVERSION       = 801,

    EINTERNAL            = 999,
} xPCErrorValue;
#endif /* _XPCAPICONST_H_ */
