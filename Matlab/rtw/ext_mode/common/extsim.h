/* Copyright 1994-2004 The MathWorks, Inc.
 *
 * File    : extsim.h     $Revision: 1.13.6.4.2.1 $
 * Abstract:
 *      Real-Time Workshop external simulation data structure.
 */

#ifndef __EXTSTRUC__
#define __EXTSTRUC__

#if defined(SL_INTERNAL)
/* SimStruct being used within Simulink itself */
#undef MATLAB_MEX_FILE
#include "m_dispatcher.h"
#else
#define Mfh_MATLAB_fn void *
#endif

#include "ext_share.h"

typedef struct ExternalSim_tag ExternalSim;

typedef void (*TargetToHostDataTypeFcn) (
    ExternalSim  *ESim,
    void         *dst,
    const char   *src,
    const int    nEls,
    const int    dType); /* internal Simulink data type id */

typedef void (*HostToTargetDataTypeFcn)(
    ExternalSim  *ESim,
    char         *dst,
    const void   *src,
    const int    nEls,
    const int    dType); /* internal Simulink data type id */

typedef void (*GenericExtFcn) ( /*any fcn requiring only ESim and mxArray args*/
    ExternalSim   *ESim,
    int_T         nrhs,
    const mxArray *prhs[]);

typedef int (*DTypeSizeFcn) (
    const ExternalSim *ESim,
    const int         dType);

typedef void (*MexFuncGateWayFcn) (
    int           nlhs, 
    mxArray       *plhs[],
    int           nrhs,
    const mxArray *prhs[]);

#define EXTSIM_VERSION (sizeof(ExternalSim)*10000 + 200)


typedef enum {
    EXTMODE_UNCONNECTED,    /* must be 0 */
    EXTMODE_CONNECTED,
    EXTMODE_DISCONNECT_REQUESTED,
    EXTMODE_DISCONNECT_PENDING,
    EXTMODE_DISCONNECT_CONFIRMED
} ConnectionStatus;


struct ExternalSim_tag {
    /*
     * Common info.
     */
    int version; 
    
    const char *modelName;             /* the name of the model               */
    const void *bd;                    /* ptr to block diagram - internal use */
    uint32_T   targetModelCheckSum[4]; /* 128 bit model checksum              */

    TargetSimStatus targetSimStatus;   /* status of target */
    
    ExtModeAction action;   /* action flag - determines current operation */
    boolean_T     verbose;  /* verbose mode?                              */

    ConnectionStatus connectionStatus;

    char errMsg[1024];   /* msg to display upon error from an external
                          * call.  Empty ('\0') if no error.           */

    void *userData;      /* externally allocated and freed (e.g., ext_comm.c) */

    struct {
        const char *buf;     /* communication buffer - used for downloads    */
        int        nBytes;   /* size of communication buffer - in host bytes */
    } commBuf;

    /*
     * Reception of target packets.
     */
    struct {
        int_T         pending;
        ExtModeAction pkt;

        int  bufSize;        /* allocated size of the buffer                   */
        char *buf;           /* the buffer                                     */
        int  nBytesInBuffer; /* number of valid bytes in buffer                */
        int  nBytesNeeded;   /* nbytes needed until we can process this buffer */

        /*
         * Function (implemented in ext_comm) that retrieves the pkt
         * from the target.
         */
        GenericExtFcn recvIncomingPktFcn;
    } incomingPkt;

    /*
     * Target data represention.
     */
    struct {
        boolean_T intOnly;                /* target built with integer only flag? */
        boolean_T swapBytes;              /* change byte order? */
        uint8_T   hostBytesPerTargetByte; /* Number of host bytes per target
                                           * byte.  A byte is not always 8 bits
                                           * (see compiler for C30/C40).
                                           */

        uint32_T  numDataTypes;  /* Number of data types in use in Simulink
                                  * model.  This is a read only field outsize of
                                  * Simulink (used for consistency check).  This
                                  * is NOT the number of registeted data types,
                                  * but the number of data types that are in use
                                  * in a model!
                                  */

        uint32_T *dataTypeSizes; /* Size (on the target, in target bytes) of
                                  * each data type in use.
                                  */

        /*
         * Data Conversion functions for built-in Simulink Data Types.
         */
        TargetToHostDataTypeFcn  doubleTargetToHostFcn;
        HostToTargetDataTypeFcn  doubleHostToTargetFcn;

        TargetToHostDataTypeFcn  singleTargetToHostFcn;
        HostToTargetDataTypeFcn  singleHostToTargetFcn;

        TargetToHostDataTypeFcn  int8TargetToHostFcn;
        HostToTargetDataTypeFcn  int8HostToTargetFcn;

        TargetToHostDataTypeFcn  uint8TargetToHostFcn;
        HostToTargetDataTypeFcn  uint8HostToTargetFcn;

        TargetToHostDataTypeFcn  int16TargetToHostFcn;
        HostToTargetDataTypeFcn  int16HostToTargetFcn;

        TargetToHostDataTypeFcn  uint16TargetToHostFcn;
        HostToTargetDataTypeFcn  uint16HostToTargetFcn;

        TargetToHostDataTypeFcn  int32TargetToHostFcn;
        HostToTargetDataTypeFcn  int32HostToTargetFcn;

        TargetToHostDataTypeFcn  uint32TargetToHostFcn;
        HostToTargetDataTypeFcn  uint32HostToTargetFcn;

        TargetToHostDataTypeFcn  boolTargetToHostFcn;
        HostToTargetDataTypeFcn  boolHostToTargetFcn;
    } TargetDataInfo;

    /*
     * Callbacks into Simulink to query data type info.
     * NOTE:
     *  These functions are generally not valid until after both
     *  EXT_CONNECT_RESPONSE packets are processed by the host
     *  (Simulink).
     */
    struct {
        DTypeSizeFcn sizeOfTargetDataType;  /* Return size of data type on
                                             * target:
                                             *  target format/target bytes */
        
        DTypeSizeFcn sizeOfDataType;        /* Return size of data type on host (Simulink)
                                             *  (Simulink). */
    } DTypeFcn;

    /* "shortcut" for calling mexfile */
    MexFuncGateWayFcn mexFunc;
    Mfh_MATLAB_fn *   mexFuncHandle;
};


/*==============================================================================
 * Public access methods for external use (e.g., ext_comm.c).  
 *
 * NOTE: Fields that do not have access macros should not be used 
 *       externally (e.g., by ext_comm.c)!
 *============================================================================*/

/*
 * Common fields.
 */
#define esSetVersion(ESim, val)  ((ESim)->version = (val))

#define esSetModelName(ESim, val)  ((ESim)->modelName = (val))

#define esGetModelName(ESim)  ((ESim)->modelName)

#define esSetTargetModelCheckSum(ESim, el, val)  \
    ((ESim)->targetModelCheckSum[(el)] = (val))

#define esSetTargetSimStatus(ESim, val) ((ESim)->targetSimStatus = (val))

#define esGetTargetSimStatus(ESim)  ((ESim)->targetSimStatus)

#define esGetAction(ESim)  ((ESim)->action)

#define esSetVerbosity(ESim, val)  ((ESim)->verbose = (val))

#define esGetVerbosity(ESim)  ((ESim)->verbose)

#define esGetConnectionStatus(ESim) ((ESim)->connectionStatus)

#define esSetError(ESim, str)  ((void)strcpy((ESim)->errMsg, (str)))

#define esGetError(ESim)  ((ESim)->errMsg)

#define esClearError(ESim)  ((*(ESim)->errMsg) = '\0')

#define esIsErrorClear(ESim)  ((*(ESim)->errMsg) == '\0')

#define esSetUserData(ESim, val)  ((ESim)->userData = (val))

#define esGetUserData(ESim)  ((ESim)->userData)

#define esGetCommBuf(ESim)  ((ESim)->commBuf.buf)

#define esGetCommBufSize(ESim)  ((ESim)->commBuf.nBytes)

#define esSetIncomingPktPending(ESim, val)  ((ESim)->incomingPkt.pending = (val))

#define esSetIncomingPkt(ESim, val)  ((ESim)->incomingPkt.pkt = (val))

#define esGetIncomingPktDataBufSize(ESim)  ((ESim)->incomingPkt.bufSize)

#define esGetIncomingPktDataBuf(ESim) ((ESim)->incomingPkt.buf)

#define esSetIncomingPktDataNBytesInBuf(ESim, val) \
    ((ESim)->incomingPkt.nBytesInBuffer = (val))

#define esGetIncomingPktDataNBytesInBuf(ESim) \
    ((ESim)->incomingPkt.nBytesInBuffer)

#define esSetIncomingPktDataNBytesNeeded(ESim, val) \
    ((ESim)->incomingPkt.nBytesNeeded = (val))

#define esGetIncomingPktDataNBytesNeeded(ESim) \
    ((ESim)->incomingPkt.nBytesNeeded)

#define esSetRecvIncomingPktFcn(ESim, fcn) \
    ((ESim)->incomingPkt.recvIncomingPktFcn = fcn)


/*
 * Target data representation fields.
 */
#define esSetIntOnly(ESim, val)  ((ESim)->TargetDataInfo.intOnly = (val))

#define esGetIntOnly(ESim)  ((ESim)->TargetDataInfo.intOnly)

#define esSetSwapBytes(ESim, val)  ((ESim)->TargetDataInfo.swapBytes = (val))

#define esGetSwapBytes(ESim)  ((ESim)->TargetDataInfo.swapBytes)

#define esSetHostBytesPerTargetByte(ESim, val)  \
  ((ESim)->TargetDataInfo.hostBytesPerTargetByte = (val))

#define esGetHostBytesPerTargetByte(ESim)  \
  ((ESim)->TargetDataInfo.hostBytesPerTargetByte)

#define esGetNumDataTypes(ESim)  ((ESim)->TargetDataInfo.numDataTypes)

#define esSetDataTypeSize(ESim, idx, val)  \
    assert((idx)<esGetNumDataTypes(ESim)); \
    ((ESim)->TargetDataInfo.dataTypeSizes[(idx)] = (val));

#define esGetDataTypeSize(ESim, idx)  \
    ((ESim)->TargetDataInfo.dataTypeSizes[(idx)]);

#define esSetDoubleTargetToHostFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.doubleTargetToHostFcn = (fcn))

#define esSetDoubleHostToTargetFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.doubleHostToTargetFcn = (fcn))

#define esSetSingleTargetToHostFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.singleTargetToHostFcn = (fcn))

#define esSetSingleHostToTargetFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.singleHostToTargetFcn = (fcn))

#define esSetInt8TargetToHostFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.int8TargetToHostFcn = (fcn))

#define esSetInt8HostToTargetFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.int8HostToTargetFcn = (fcn))

#define esSetUInt8TargetToHostFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.uint8TargetToHostFcn = (fcn))

#define esSetUInt8HostToTargetFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.uint8HostToTargetFcn = (fcn))

#define esSetInt16TargetToHostFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.int16TargetToHostFcn = (fcn))

#define esSetInt16HostToTargetFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.int16HostToTargetFcn = (fcn))

#define esSetUInt16TargetToHostFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.uint16TargetToHostFcn = (fcn))

#define esSetUInt16HostToTargetFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.uint16HostToTargetFcn = (fcn))

#define esSetInt32TargetToHostFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.int32TargetToHostFcn = (fcn))

#define esSetInt32HostToTargetFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.int32HostToTargetFcn = (fcn))

#define esSetUInt32TargetToHostFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.uint32TargetToHostFcn = (fcn))

#define esSetUInt32HostToTargetFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.uint32HostToTargetFcn = (fcn))

#define esSetBoolTargetToHostFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.boolTargetToHostFcn = (fcn))

#define esSetBoolHostToTargetFcn(ESim, fcn) \
    ((ESim)->TargetDataInfo.boolHostToTargetFcn = (fcn))

#define esGetSizeOfTargetDataTypeFcn(ESim) \
    ((ESim)->DTypeFcn.sizeOfTargetDataType)

#define esGetSizeOfDataTypeFcn(ESim) \
    ((ESim)->DTypeFcn.sizeOfDataType)

#define esSetMexFuncGateWayFcn(ESim, fcn) \
    ((ESim)->mexFunc = (fcn))

#define esSetMexFuncHandle(ESim, fcn) \
    ((ESim)->mexFuncHandle = (fcn))


/*==============================================================================
 * Utility functions.
 *============================================================================*/
#define IS_ALIGNED(address, size) \
    (boolean_T)((((unsigned int)address)%(size)) == 0)

#define IS_INT(val) ((((int_T)(val))) == (val))


/*==============================================================================
 * Public access methods for internal use only.  These cannot be used by
 * ext_comm.c, ext_convert.c, ...!
 *============================================================================*/
#if !defined(MATLAB_MEX_FILE)

/*
 * Common fields.
 */
#define esSetBdPtr(ESim, val) ((ESim)->bd = ((const void *)(val)))

#define esGetBdPtr(ESim) ((const slBlockDiagram *)(ESim)->bd)

#define esSetAction(ESim, val)  ((ESim)->action = (val))

#define esSetConnectionStatus(ESim,val) ((ESim)->connectionStatus = (val))

#define esSetCommBuf(ESim, val)  ((ESim)->commBuf.buf = (const char *)(void *)(val))

#define esSetCommBufSize(ESim, val)  ((ESim)->commBuf.nBytes = (val))

/*
 * Reception of incoming packets.
 */
#define esGetIncomingPktPending(ESim)  ((ESim)->incomingPkt.pending)

#define esGetIncomingPkt(ESim)  ((ESim)->incomingPkt.pkt)

#define esGetRecvIncomingPktFcn(ESim)  ((ESim)->incomingPkt.recvIncomingPktFcn)

#define esSetIncomingPktDataBufSize(ESim, val)  \
    ((ESim)->incomingPkt.bufSize = (val))

#define esSetIncomingPktDataBuf(ESim, val)  \
    ((ESim)->incomingPkt.buf = (val))


/*
 * Target data representation fields.
 */
#define esSetNumDataTypes(ESim, val)  ((ESim)->TargetDataInfo.numDataTypes = (val));

#define esGetDoubleTargetToHostFcn(ESim) \
    ((ESim)->TargetDataInfo.doubleTargetToHostFcn)

#define esGetDoubleHostToTargetFcn(ESim) \
    ((ESim)->TargetDataInfo.doubleHostToTargetFcn)

#define esGetSingleTargetToHostFcn(ESim) \
    ((ESim)->TargetDataInfo.singleTargetToHostFcn)

#define esGetSingleHostToTargetFcn(ESim) \
    ((ESim)->TargetDataInfo.singleHostToTargetFcn)

#define esGetInt8TargetToHostFcn(ESim) \
    ((ESim)->TargetDataInfo.int8TargetToHostFcn)

#define esGetInt8HostToTargetFcn(ESim) \
    ((ESim)->TargetDataInfo.int8HostToTargetFcn)

#define esGetUInt8TargetToHostFcn(ESim) \
    ((ESim)->TargetDataInfo.uint8TargetToHostFcn)

#define esGetUInt8HostToTargetFcn(ESim) \
    ((ESim)->TargetDataInfo.uint8HostToTargetFcn)

#define esGetInt16TargetToHostFcn(ESim) \
    ((ESim)->TargetDataInfo.int16TargetToHostFcn)

#define esGetInt16HostToTargetFcn(ESim) \
    ((ESim)->TargetDataInfo.int16HostToTargetFcn)

#define esGetUInt16TargetToHostFcn(ESim) \
    ((ESim)->TargetDataInfo.uint16TargetToHostFcn)

#define esGetUInt16HostToTargetFcn(ESim) \
    ((ESim)->TargetDataInfo.uint16HostToTargetFcn)

#define esGetInt32TargetToHostFcn(ESim) \
    ((ESim)->TargetDataInfo.int32TargetToHostFcn)

#define esGetInt32HostToTargetFcn(ESim) \
    ((ESim)->TargetDataInfo.int32HostToTargetFcn)

#define esGetUInt32TargetToHostFcn(ESim) \
    ((ESim)->TargetDataInfo.uint32TargetToHostFcn)

#define esGetUInt32HostToTargetFcn(ESim) \
    ((ESim)->TargetDataInfo.uint32HostToTargetFcn)

#define esGetBoolTargetToHostFcn(ESim) \
    ((ESim)->TargetDataInfo.boolTargetToHostFcn)

#define esGetBoolHostToTargetFcn(ESim) \
    ((ESim)->TargetDataInfo.boolHostToTargetFcn)

/* Callbacks into Simulink to query data type info. */
#define esSetSizeOfTargetDataTypeFcn(ESim, fcn) \
    ((ESim)->DTypeFcn.sizeOfTargetDataType = (fcn))

#define esSetSizeOfDataTypeFcn(ESim, fcn) \
    ((ESim)->DTypeFcn.sizeOfDataType = (fcn))

#define esGetMexFuncGateWayFcn(ESim) \
    ((ESim)->mexFunc)

#define esGetMexFuncHandle(ESim) \
    ((ESim)->mexFuncHandle)

#endif /* !MATLAB_MEX_FILE */

#endif /* __EXTSTRUC__ */
