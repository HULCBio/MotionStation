/*    
 *    Header file for matrix support in Communications blockset.
 *    Copyright 1996-2003 The MathWorks, Inc.
 *    $Revision: 1.1.6.2 $
 *    $Date: 2004/04/12 23:03:52 $
 *    Author: Mojdeh Shakeri
 */

#ifndef comm_mtrx_h
#define comm_mtrx_h

#include "simstruc.h" /* DimsInfo_T */


#define COMM_ERR_PORT_DIMS_NOT_MATCH_TRELLIS      \
  "Invalid dimensions are specified for the "     \
  "input or output port of the block. The port "  \
  "dimensions must be consistent with the data "  \
  "in the trellis structure."

#define COMM_ERR_PORT_DIMS_NOT_MATCH_WORD_SIZE      \
  "Invalid dimensions are specified for the "       \
  "input or output port of the block. The port "    \
  "dimensions must be consistent with the message " \
  "or codeword length."


/* General matrix errors */
#define COMM_ERR_ASSERT  "Fatal error."


#define COMM_ERR_NO_FRAME_BASED                          \
  "This block only accpets frame-based inputs." 

#define COMM_ERR_INVALID_N_D_ARRAY                       \
  "Invalid dimensions are specified for the input or "   \
  "output port of the block. The block does not accept " \
  "N-dimensional signals (n>2). "                         \


#define COMM_ERR_INVALID_MATRIX                         \
  "Invalid dimensions are specified for the input or "  \
  "output port of the block. The block accepts only "   \
  "1-D or 2-D vector signals. "                          \

#define COMM_ERR_INVALID_MULTI_CHANNEL                     \
  "Invalid dimensions are specified for the input or "     \
  "output port of the block. The block does not support "  \
  "multichannel frame signals. "

#define COMM_ERR_INVALID_PORT_BLOCK_SIZE                   \
  "Invalid dimensions are specified for the input or "     \
  "output port of the block. For sample-based signals, "   \
  "the block accepts one input symbol and generates "      \
  "one output symbol. "


typedef enum { UNKNOWN_DIMS = 0,
               SCALAR_2D_DIMS,
               VECTOR_1D_DIMS,
               COL_VECTOR_DIMS, /* [nx1] */
               ROW_VECTOR_DIMS, /* [1xn] */
               MATRIX_DIMS,     /* [mxn] matrix m > 1 && n > 1 */
               N_D_ARRAY_DIMS   /* [mxnxk] n-dimensional array */
} ssDimsType_T; 

typedef enum {
    IS_OUTPORT = 0,
    IS_INPORT
} PortType_T;


#define ssSetInputPortKnownWidthUnknownDims(S, port, w)      \
{                                                            \
  DECL_AND_INIT_DIMSINFO(l_info);                            \
  l_info.width   = w;                                        \
  l_info.numDims = DYNAMICALLY_SIZED;                        \
  if(!ssSetInputPortDimensionInfo(S, port, &l_info)) return; \
}

#define ssSetOutputPortKnownWidthUnknownDims(S, port, w)      \
{                                                             \
  DECL_AND_INIT_DIMSINFO(l_info);                             \
  l_info.width   = w;                                         \
  l_info.numDims = DYNAMICALLY_SIZED;                         \
  if(!ssSetOutputPortDimensionInfo(S, port, &l_info)) return; \
}

extern ssDimsType_T GetDimsInfoType(const DimsInfo_T *dimsInfo);

extern boolean_T    IsDimsInfoFullySet(const DimsInfo_T *thisInfo);

extern boolean_T    ssIsInputPortDimsInfoFullySet(SimStruct *S, 
                                                  int_T     port);

extern boolean_T    ssIsOutputPortDimsInfoFullySet(SimStruct *S, 
                                                   int_T     port);

extern boolean_T    CommGetOtherDimensions(SimStruct        *S,
                                           PortType_T       portType,
                                           int_T            thisFactor,
                                           const DimsInfo_T *thisInfo,
                                           int_T            otherFactor,
                                           DimsInfo_T       *otherInfo,
                                           boolean_T        frameData);

extern void         CommSetInputAndOutputPortDimsInfo(SimStruct        *S, 
                                                      int_T            port,
                                                      PortType_T       portType,
                                                      int_T            thisFactor,
                                                      const DimsInfo_T *thisInfo,
                                                      int_T            otherFactor);

extern void         CommCheckConvCodPortDimensions(SimStruct        *S,
                                                   PortType_T       port,
                                                   PortType_T       portType,
                                                   int_T            thisFactor,
                                                   const DimsInfo_T *thisInfo);

extern void         SetDefaultInputPortDimsWithKnownWidth(SimStruct *S,
                                                          int_T     port);

extern boolean_T    GetDefaultInputDimsIfPortDimsUnknown(SimStruct  *S,
                                                         int_T      port,
                                                         int_T      dataPortWidth,
                                                         DimsInfo_T *dInfo);

#endif /* comm_mtrx_h */



