/* 
 * dsp_ic_rt.h
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.12.4.2 $  $Date: 2004/04/12 23:11:23 $
 *
 * Abstract:
 *   Header file for initial condition copy functions
 */

#ifndef DSP_IC_RT_H
#define DSP_IC_RT_H

#include "dsp_rt.h"
#include <string.h>   /* For memcpy */

#ifdef DSPIC_EXPORTS
#define DSPIC_EXPORT EXPORT_FCN
#else
#define DSPIC_EXPORT MWDSP_IDECL
#endif

/*
 * Initial condition copy spec:
 *
 * Given:
 *   - ICs stored in a buffer area, of size [IC_rows IC_cols].
 *   - A destination buffer area, corresponding to a "matrix" of size
 *     [dst_rows dst_cols].
 *   - Each IC element is of size 'bytesPerElem'.
 *   - IC complexity and datatype matches destination buffer
 *     complexity and datatype.
 *
 * Case 1: Scalar IC
 *   If number of IC elements is 1, then the task is to copy the single
 *   IC element into each element of the destination buffer.  Use the
 *   function MWDSP_CopyScalarICs, specifying the number of elements in
 *   the destination area and the size of each element in bytes.
 *
 * Case 2: Column vector of IC elements (IC_rows == dst_rows)
 *   The task is to copy the same column vector into each column of
 *   the destination buffer.  Use the function MWDSP_CopyVectorICs,
 *   specifying the number of columns (channels) in the destination
 *   buffer and the total number of bytes in each column.
 *
 * Case 3: Row vector if IC elements (IC_cols == dst_cols)
 *   The task is to expand each IC element to fill each column of the
 *   destination buffer.  Use the function MWDSP_CopyChannelICs,
 *   specifying the number of channels in the destination buffer, the
 *   number of samples per channel, and the size of each element in bytes.
 *
 * Case 4: Matrix of ICs (IC_rows == dst_rows && IC_cols == dst_cols)
 *   The task is to copy each element of the IC matrix into the 
 *   corresponding element of the destination buffer.  Use the function
 *   MWDSP_CopyMatrixICs, specifying the total number of elements and
 *   the size of each element in bytes.
 *
 */

DSPIC_EXPORT void MWDSP_CopyScalarICs( byte_T       *dstBuff, 
                                 const byte_T *ICBuff, 
                                 int_T         numElems, 
                                 const int_T   bytesPerElem );

DSPIC_EXPORT void MWDSP_CopyVectorICs( byte_T       *dstBuff, 
                                 const byte_T *ICBuff, 
                                 int_T         numChans, 
                                 const int_T   bytesPerChan );


DSPIC_EXPORT void MWDSP_CopyChannelICs( byte_T       *dstBuff, 
                                  const byte_T *ICBuff, 
                                  int_T         numChans, 
                                  const int_T   sampsPerChan,
                                  const int_T   bytesPerElem );


DSPIC_EXPORT void MWDSP_CopyMatrixICs( byte_T       *dstBuff, 
                                 const byte_T *ICBuff, 
                                 const int_T   numElems, 
                                 const int_T   bytesPerElem );


/* 
 * The following code provides initial-condition handling support
 * specifically for the Integer Delay, Variable Integer Delay,
 * and the Variable Fractional Delay blocks in the DSP Blockset.
 *
 */
typedef struct {
    byte_T *ICPtr;
    byte_T *buffer;
    int_T   nChans;
    int_T   dWorkRows;
    int_T   dataPortWidth;
    int_T   bytesPerElement;
} MWDSP_DelayCopyICsArgs;

DSPIC_EXPORT void MWDSP_DelayCopyScalarICs(byte_T *buffer,
                              byte_T *ICPtr,
                              const int_T nChansXdWorkRows,
                              const int_T  bytesPerElement
                              );
DSPIC_EXPORT void MWDSP_DelayCopyVectorICs(byte_T *buffer,
                              byte_T *ICPtr,
                              int_T nChans,
                              const int_T dWorkRows,
                              const int_T bytesPerElement
                              );
DSPIC_EXPORT void MWDSP_DelayCopy3DSampMatrixICs(byte_T *buffer,
                                    byte_T *ICPtr,
                                    int_T nChans,
                                    const int_T dWorkRows,
                                    const int_T bytesPerElement,
                                    const int_T dataPortWidth
                                    );
DSPIC_EXPORT void MWDSP_DelayCopy3DFrameMatrixICs(byte_T *buffer,
                                     byte_T *ICPtr,
                                     int_T nChans,
                                     const int_T dWorkRows,
                                     const int_T bytesPerElement
                                     );

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspic/ic_copy_channel_rt.c"
#include "dspic/ic_copy_matrix_rt.c"
#include "dspic/ic_copy_scalar_rt.c"
#include "dspic/ic_copy_vector_rt.c"
#include "dspic/ic_old_copy_fcns_rt.c"
#endif

#endif /* DSP_IC_RT_H */

/* [EOF] dsp_ic_rt.h */

