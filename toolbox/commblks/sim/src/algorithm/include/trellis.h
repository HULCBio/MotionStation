/*    
 *    This file contains trellis structure definition.
 *
 *    Copyright 1996-2003 The MathWorks, Inc.
 *    $Revision: 1.1.6.2 $
 *    $Date: 2004/04/12 23:03:49 $
 *    Author: Mojdeh Shakeri
 */

#ifndef trellis_h
#define trellis_h

typedef struct Trellis_tag{
    int    uNumBits;      /* Number of input bits              */
    int    cNumBits;      /* Number of output bits             */
    int    numStates;     /* Number of states                  */
    int    uNumAlphabets; /* (1 << uNumBits)                   */
    int    numBranches;   /* numStates * uNumAlphabet;         */
    int    *nextState;    /* width = numStates * uNumAlphabet; */
    int    *output;       /* width = numStates * uNumAlphabet; */
}Trellis_T;

#endif /* trellis_h */
