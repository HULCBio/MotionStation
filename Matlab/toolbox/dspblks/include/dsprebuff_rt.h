/*
 *  dsprebuff_rt.h
 *
 *  Abstract: Header file for DSP run-time library helper functions
 *  for the Buffer / UnBuffer block.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:12:14 $
 */

#ifndef dsprebuff_rt_h
#define dsprebuff_rt_h

#include "dsp_rt.h"

#ifdef DSPREBUFF_EXPORTS
#define DSPREBUFF_EXPORT EXPORT_FCN
#else
#define DSPREBUFF_EXPORT MWDSP_IDECL
#endif

/* Buffer / UnBuffer Blocks Implementation
 *
 * Run-time Function Descriptions: 
 *
 * The run-time functions are written as byte-shuffling functions
 * which are used by the Buffer/UnBuffer blocks.  There are three groups
 * of run-time functions.
 *
 * The first two groups are used when initial conditions are required.
 * The first group (input functions to copy inputs into internal state buffer memory)
 * are called when an input is ready to be handled.  The second group (output functions
 * to copy internal state buffer memory to output) are called when an output is ready
 * to be handled.  Thus two functions are called for cases requiring ICs.
 *
 * The third group (functions to copy inputs directly to outputs) are used only when
 * initial conditions are not needed.  Thus one function is called cases without ICs.
 *
 * Function Naming Conventions:
 *
 * MWDSP_Buf_<Algorithm>_[UL|OL][_1ch]
 *
 * All functions start with MWDSP_Buf to identify
 * themselves as buffer/unbuffer functions.
 * 
 * Algorithm may be one of the following:
 * 
 *   CopyFrame    - copy an input frame to internal state buffer memory
 *   CopyScalar   - a specialization of CopyFrame for scalar inputs
 * 
 *   OutputFrame  - output a data frame from internal state buffer memory
 *   OutputScalar - a specialization of OutputFrame for scalar outputs
 *
 * The other extensions are as follows:
 *
 *   UL  - copy function for buffer underlap
 *   OL  - copy function for buffer overlap (or no lap)
 *
 *   1ch - 1 channel input or output specialization
 * 
 */

/* Byte shuffling functions for copying data from input port to memory */

DSPREBUFF_EXPORT void MWDSP_Buf_CopyFrame_OL(
    const byte_T        *u,                 /* pointer to input data */   
          byte_T       **inBufPtr,          /* address to internal memory */
          byte_T        *memBase,           /* pointer to internal memory start address */
    const int_T          shiftPerElement,   /* shift size = log2(bytesPerElement) */
    const int_T          bufLenTimesBpe,    /* buffer length x bytesPerElement */
    const int_T          nChans,            /* number of channels */
    const int_T          F                  /* input frame size */
);

DSPREBUFF_EXPORT void MWDSP_Buf_CopyFrame_OL_1ch(
    const byte_T        *u,                  
          byte_T       **inBufPtr,
          byte_T        *memBase,
    const int_T          shiftPerElement,
    const int_T          bufLenTimesBpe,
    const int_T          F
);

DSPREBUFF_EXPORT void MWDSP_Buf_CopyScalar_OL(
    const byte_T        *u,                  
          byte_T       **inBufPtr,
          byte_T        *memBase,
    const int_T          shiftPerElement,
    const int_T          bufLenTimesBpe,
    const int_T          nChans
);

DSPREBUFF_EXPORT void MWDSP_Buf_CopyScalar_OL_1ch(
    const byte_T        *u,                  
          byte_T       **inBufPtr,
          byte_T        *memBase,
    const int_T          shiftPerElement,
    const int_T          bufLenTimesBpe
);

DSPREBUFF_EXPORT void MWDSP_Buf_CopyScalar_UL(
    const byte_T         *u,                /* pointer to input data */
          byte_T        **inBufPtr,         /* address to internal memory */    
          byte_T         *memBase,          /* pointer to internal memory start address */
    const int_T           shiftPerElement,  /* shift size = log2(bytesPerElement) */
    const int_T           bufLenTimesBpe,   /* buffer length x bytesPerElement */
    const int_T           nChans,           /* number of channels */
          int32_T        *ul_count,         /* underlap count */
    const int_T           N,                /* output frame size */
    const int_T           V                 /* underlap */
);

DSPREBUFF_EXPORT void MWDSP_Buf_CopyScalar_UL_1ch(
    const byte_T         *u,                  
          byte_T        **inBufPtr,
          byte_T         *memBase,
    const int_T           shiftPerElement,
    const int_T           bufLenTimesBpe,
          int32_T        *ul_count,
    const int_T           N,
    const int_T           V
);

/* Byte shuffling functions for copying data from memory to output port */

DSPREBUFF_EXPORT void MWDSP_Buf_OutputFrame(
          byte_T        *y,                 /* pointer to output*/
          byte_T       **outBufPtr,         /* address to output internal memory */
          byte_T        *memBase,           /* pointer to internal memory start address */
    const int_T          nChans,            /* number of channels */
    const int_T          shiftPerElement,   /* shift size = log2(bytesPerElement) */
    const int_T          bufLenTimesBpe,    /* buffer length x bytesPerElement */
    const int_T          N,                 /* output frame size */
    const int_T          VTimesBpe          /* V x bytesPerElement (V is the overlap,
                                               use a negative value for underlap) */
);

DSPREBUFF_EXPORT void MWDSP_Buf_OutputFrame_1ch(
          byte_T        *y,                  
          byte_T       **outBufPtr,
          byte_T        *memBase,
    const int_T          shiftPerElement,
    const int_T          bufLenTimesBpe,
    const int_T          N,
    const int_T          VTimesBpe
);

DSPREBUFF_EXPORT void MWDSP_Buf_OutputScalar(
          byte_T         *y,                  
          byte_T        **outBufPtr,
          byte_T         *memBase,
    const int_T           nChans,
    const int_T           shiftPerElement,
    const int_T           bufLenTimesBpe
);

DSPREBUFF_EXPORT void MWDSP_Buf_OutputScalar_1ch(
          byte_T         *y,                  
          byte_T        **outBufPtr,
          byte_T         *memBase,
    const int_T           shiftPerElement,
    const int_T           bufLenTimesBpe
);

/* byte shuffling functions for copying input 
   directly to output used in conditions not 
   requiring ICs */

DSPREBUFF_EXPORT void MWDSP_Buf_CopyInputToOutput(
    const byte_T *u,
    byte_T       *y,
    int32_T      *cnt,
    const int_T   bytesPerElement,
    const int_T   nBytesToCopy,
    const int_T   F,
    const int_T   N,
    const int_T   nChans
);

DSPREBUFF_EXPORT void MWDSP_Buf_CopyInputToOutput_1ch(
    const byte_T *u,
    byte_T       *y,
    int32_T      *cnt,
    const int_T   bytesPerElement,
    const int_T   nBytesToCopy,
    const int_T   F,
    const int_T   N
);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dsprebuff/buf_copy_frame_to_mem_OL_1ch_rt.c"
#include "dsprebuff/buf_copy_frame_to_mem_OL_rt.c"
#include "dsprebuff/buf_copy_input_to_output_1ch_rt.c"
#include "dsprebuff/buf_copy_input_to_output_rt.c"
#include "dsprebuff/buf_copy_scalar_to_mem_OL_1ch_rt.c"
#include "dsprebuff/buf_copy_scalar_to_mem_OL_rt.c"
#include "dsprebuff/buf_copy_scalar_to_mem_UL_1ch_rt.c"
#include "dsprebuff/buf_copy_scalar_to_mem_UL_rt.c"
#include "dsprebuff/buf_output_frame_1ch_rt.c"
#include "dsprebuff/buf_output_frame_rt.c"
#include "dsprebuff/buf_output_scalar_1ch_rt.c"
#include "dsprebuff/buf_output_scalar_rt.c"
#endif

#endif /* dsprebuff_rt_h */

/* [EOF] dsprebuff_rt.h */
