/* Simulation support header file for Statistics library 'Median' block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/04/14 20:37:52 $
 */
#ifndef dsp_mdn_sim_h
#define dsp_mdn_sim_h

#include "dsp_sim.h"
#include "dspsrt_rt.h"

/*
 * Argument and function pointer caches:
 */

typedef struct {
    const void *u;        /* Input data pointer  */
    void       *y;        /* Output data pointer */

    void       *sort_in;  /* Pointer to DWork, temporary memory to store the input */
    int_T nSamps;         /* Number of Samples in input data*/
    int_T nChans;         /* Number of channels in input data*/
    int32_T *indx;        /* DWork holding the sorted indices in ascending order temporarily */
} MdnArgsCache;  


typedef void (*MdnFcn)(MdnArgsCache *args);

typedef struct {
    MdnArgsCache Args;
    MdnFcn     MdnFcnPtr;    /* Pointer to function */
} SFcnCache;

extern void Mdn_R(MdnArgsCache *args); /* data-type is real    single-precision  */
extern void Mdn_D(MdnArgsCache *args); /* data-type is real    double-precision  */
extern void Mdn_C(MdnArgsCache *args); /* data-type is complex single-precision  */
extern void Mdn_Z(MdnArgsCache *args); /* data-type is complex double-precision  */

#endif /* dsp_mdn_sim.h */

/* [EOF] dsp_mdn_sim.h  */

