/*
 *  dspflip_rt.h
 *
 *  Abstract: Header file for run-time library helper functions 
 *  for the flip block.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.4.2 $ $Date: 2004/04/12 23:11:52 $
 */

#ifndef dspflip_rt_h
#define dspflip_rt_h

#include "dsp_rt.h"

#ifdef DSPFLIP_EXPORTS
#define DSPFLIP_EXPORT EXPORT_FCN
#else
#define DSPFLIP_EXPORT MWDSP_IDECL
#endif

/*
 * ====================================================
 * Function Arguments:
 * ====================================================
 *
 * All arguments need to be defined, except in the case of an
 * 'inplace' flip, for which the input signal (*u) is not used
 * (for inplace operations, the input and output signals use 
 * the same memory space).
 *
 *   u               = pointer to the input signal
 *   y               = pointer to the output signal 
 *   numRows         = number of rows in the input signal
 *   numCols         = number of columns in the input signal
 *   bytesPerElement = size of DType in bytes
 *
 *
 * ====================================================
 * Library usage
 * ====================================================
 *
 * Three factors determine which function should be called: input size,
 * flip direction, and whether or not the flip needs to use an inplace
 * algorithm.  
 * 
 * Not all combinations map to one of the below functions.  For the rest,
 * either no action needs to be taken, or a simple copy of inputs to outputs
 * is sufficient.
 *
 * Functions in this library are named as follows.
 *
 * Format : MWDSP_Flip{Vector|MatrixCol|MatrixRow}{IP|OP}
 *            -OR-
 *          MWDSP_FlipCopyInputToOutput
 *
 * MWDSP     = MathWorks DSP Blockset
 * Flip      = name of the block
 * Vector    = vector input, flip along vector length
 * MatrixCol = matrix input, flip along columns
 * MatrixRow = matrix input, flip along rows
 * IP        = flip is 'inplace'
 * OP        = flip is not 'inplace'
 *
 * The following combinations require calling MWDSP_FlipCopyInputToOutput:
 *    Column flip, not inplace, scalar input
 *    Column flip, not inplace, row vector input
 *    Row flip,    not inplace, scalar input
 *    Row flip,    not inplace, column vector input
 * The following combinations require no function call:
 *    Column flip, inplace, scalar input
 *    Column flip, inplace, row vector input
 *    Row flip,    inplace, scalar input
 *    Row flip,    inplace, column vector input
 * Note that an unoriented (1D) vector never has row/column input vs.
 * row/column flip dirirection conflict (there is no distinction
 * between row and column)  
 *
 * This code is data type independent.
 */

/* MWDSP_FlipCopyInputToOutput
 * DESCRIPTION: Copies input data directly to output. 
 * This is used for the special cases listed above.
 *
 * This is a macro definition so that the overhead of a 
 * function call is not required.
 */
#define MWDSP_FlipCopyInputToOutput(u,y,numRows,numCols,bytesPerElement) \
  memcpy(y,u,numRows*numCols*bytesPerElement)

/* MWDSP_FlipVectorIP
 * DESCRIPTION: Reverses the order of the input vector data
 * using an inplace algorithm. 
 *
 * Note that the input signal pointer (member of the MWDSP_Flip_ArgsCache
 * structure) is not used.
 */
DSPFLIP_EXPORT void MWDSP_FlipVectorIP(byte_T  *y,
                               int_T  numRows,
                               int_T  numCols,
                               int_T  bytesPerElement);


/* MWDSP_FlipVectorOP
 * DESCRIPTION: Copies the input vector data to the output buffer,
 * reversing the order in the process.
 */
DSPFLIP_EXPORT void MWDSP_FlipVectorOP(const byte_T *u,
                               byte_T       *y,
                               int_T       numRows,
                               int_T       numCols,
                               int_T       bytesPerElement);


/* MWDSP_FlipMatrixColIP
 * DESCRIPTION: Reverses the order of each column of data of the
 * input matrix using an inplace algorithm. 
 * 
 * Note that the input signal pointer (member of the MWDSP_Flip_ArgsCache
 * structure) is not used. 
 */
DSPFLIP_EXPORT void MWDSP_FlipMatrixColIP(byte_T  *y,
                                  int_T  numRows,
                                  int_T  numCols,
                                  int_T  bytesPerElement);


/* MWDSP_FlipMatrixColOP
 * DESCRIPTION: Copies each column of data of the input matrix to
 * the output buffer, reversing the order in the process.
 */
DSPFLIP_EXPORT void MWDSP_FlipMatrixColOP(const byte_T *u,
                                  byte_T       *y,
                                  int_T       numRows,
                                  int_T       numCols,
                                  int_T       bytesPerElement);


/* MWDSP_FlipMatrixRowIP
 * DESCRIPTION: Reverses the order of each row of data of the
 * input matrix using an inplace algorithm. 
 * 
 * Note that the input signal pointer (member of the MWDSP_Flip_ArgsCache
 * structure) is not used. 
 */
DSPFLIP_EXPORT void MWDSP_FlipMatrixRowIP(byte_T  *y,
                                  int_T  numRows,
                                  int_T  numCols,
                                  int_T  bytesPerElement);


/* MWDSP_FlipMatrixRowOP
 * DESCRIPTION: Copies each row of data of the input matrix to
 * the output buffer, reversing the order in the process.
 */
DSPFLIP_EXPORT void MWDSP_FlipMatrixRowOP(const byte_T *u,
                                  byte_T       *y,
                                  int_T       numRows,
                                  int_T       numCols,
                                  int_T       bytesPerElement);


#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspflip/flip_vector_ip_rt.c"
#include "dspflip/flip_vector_op_rt.c"
#include "dspflip/flip_matrix_row_op_rt.c"
#include "dspflip/flip_matrix_row_ip_rt.c"
#include "dspflip/flip_matrix_col_op_rt.c"
#include "dspflip/flip_matrix_col_ip_rt.c"
#endif

#endif /* dspflip_rt_h */

/* [EOF] dspflip_rt.h */
