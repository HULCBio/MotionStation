/*
 *  dsp_filtstruct_sim.h
 *
 *  Abstract: Header file for DSP filter simulation library argument structure.
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.7.4.2 $ $Date: 2004/04/12 23:11:19 $
 */

#ifndef dsp_filtstruct_sim_h
#define dsp_filtstruct_sim_h

/* version.h indirectly includes tmwtypes.h
 * after compiler switch automagic
 */
#include "version.h"

/*
 * ====================================================
 * Argument cache:
 * ====================================================
 *
 * This structure defines the arguments that are used with each of the
 * public simulation filter functions.
 *
 * All member arguments need to be defined with the following exceptions:
 *
 * [1] In the case of only one set of filter coefficients, cPtr1
 *     should point to these coefficients.  The second coefficient pointer
 *     cPtr2 and the number of coefficients numCoef2 will be ignored in
 *     this case by the corresponding run-time functions.
 *
 * [2] In the case of biquad filters, the following elements need not be
 *     specified:
 *      - numStates, assumed to be 2 times the number of sections.
 *      - numCoef2
 *      - cPtr2 (for biquad-4 and biquad-5)
 *
 * [3] In the case of lattice filters, the numStates element need not be
 *     specified as it is assumed to be equal to the order of the filter.
 *
 * Note: For biquad-6 filters, cPtr2 points to an array containing the
 *       inverses of the first denominator coefficient in each section.
 *       The client is responsible for creating and filling this array
 *       prior to calling the biquad-6 routines.
 *
 */

typedef struct {
    void       *inPtr;              /* input signal */
    void       *outPtr;             /* output signal */
    void       *statePtr;           /* Pointer to filter states */
    int_T       numStates;          /* number of states per channel */
    int_T       sampsPerChan;       /* equals frame size or 1 (if sample based) */
    int_T       numChans;           /* number of channels */
    void       *cPtr1;              /* Pointer to first set of filter coeffs */
    int_T       numCoef1;           /* number of filter coefficients or biquad sections in first set */
    void       *cPtr2;              /* Pointer to second set of filter coeffs (if needed) */
                                    /* For biquad-6, pointer to a vector of inverse a0s */
    int_T       numCoef2;           /* number of filter coefficients in second set (if needed) */
    boolean_T   isOne_fpf;          /* denotes whether the filter change is once per frame      */
                                    /* (isOne_fpf is true) or once per sample (isOne_fpf is false) */
    int_T       coeff1portwidth;    /* acutal port width of Numerator   coefficient port */
    int_T       coeff2portwidth;    /* acutal port width of Denominator coefficient port */
    void       *scaledInPtr;        /* In the case when input is real but there is a scalar complex numerator coeff. 
                                        we need to scale (multiply) the input by numerator and the resultant will be 
                                        a complex vector, need a DWork to store that, 'scaledInPtr' is the pointer to that DWork*/
    int_T      *DF_CurrIndx;        /* Used only in the case of Allpole DF and IIR DF1 structure */
} DSPSIM_FilterArgsCache;

#endif  /* dsp_filtstruct_sim_h */

/* [EOF] dsp_filtstruct_sim.h */
