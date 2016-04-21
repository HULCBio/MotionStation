/*    
 *    Header file for frame support capability in CDMA Reference blockset.
 *
 *    Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *    $Revision: 1.4 $ $Date: 2002/04/14 16:33:24 $
 */

#ifndef cdma_frm_header
#define cdma_frm_header

#include "simstruc.h"

/* Error messages */
#define CDMA_ERROR_SAMPLE_2D_SIGNAL                         \
    "Only sample-based 1-D and frame-based 2-D signals are allowed."

#define CDMA_ERROR_MULTI_CHAN_SIGNAL                       \
  "The block does not support multichannel frame signals."

#define CDMA_ERROR_INVALID_SIGNAL_WIDTH                    \
  "Invalid dimensions are specified for the input or "     \
  "output port of the block."


boolean_T cdmaSetAllPortsDimensions(SimStruct           *S,
                                    int                 portIdx,
                                    const DimsInfo_T    *dimsInfo,
                                    boolean_T           isInput,
                                    int                 *inWidths,
                                    int                 numInportsToSet,
                                    int                 *outWidths,
                                    int                 numOutportsToSet,
                                    int                 firstInPortToSet);
                                                                    
#endif
