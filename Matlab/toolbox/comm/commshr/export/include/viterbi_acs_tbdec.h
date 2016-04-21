/*    
 *    Header file for the helper file viterbi_acs_tbdec.c 
 *    required for Add, Compare, Select and Traceback
 *    Decoding operations in the Communications Blockset.
 *    This file is required to implement Viterbi algorithm.
 *
 *    Copyright 1996-2003 The MathWorks, Inc.
 *    $Revision: 1.1.6.1 $ $Date: 2003/07/30 02:48:08 $
 */

#ifndef viterbi_acs_tbd_h
#define viterbi_acs_tbd_h

#include "tmwtypes.h"

/* Function declaration */
int_T addCompareSelect(uint32_T        numStates,
                       real_T         *pTempMet,
                       const int_T     alpha,
                       real_T         *pBMet,
                       real_T         *pStateMet,
                       uint32_T       *pTbState,
                       uint32_T       *pTbInput,
                       int_T          *pTbPtr,
                       uint32_T       *pNxtStates,
                       uint32_T       *pOutputs);

int_T tracebackDecoding(      int_T    *pTbPtr, 
                              uint32_T  minState, 
                        const int_T     tbLen, 
                              uint32_T *pTbInput, 
                              uint32_T *pTbState, 
                              uint32_T  numStates);

#endif /*viterbi_acs_tbd_h*/

/* EOF */

    
