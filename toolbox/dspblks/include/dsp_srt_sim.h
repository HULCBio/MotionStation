/* Simulation support header file for Statistics library 'Sort' block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/04/14 20:37:16 $
 */
#ifndef dsp_srt_sim_h
#define dsp_srt_sim_h

#include "dsp_sim.h"
#include "dspsrt_rt.h"

/*
 * Argument and function pointer caches:
 */

typedef struct {
    const void *u;        /* Input data pointer  */
    void       *y_val;    /* Output pointer to data when output mode is "value" or "value and indx"
                           * this pointer however points to indices when the o/p mode is "index"
                           */
    void       *y_indx;   /* Output pointer to indices*/
    void       *sort_in;  /* Pointer to DWork, temporary memory to store the input */
    int_T nSamps;         /* Number of Samples in input data*/
    int_T nChans;         /* Number of channels in input data*/
    int_T width;          /* width of input port */
    int32_T *indx;        /* DWork holding the sorted indices in ascending order temporarily */
} SrtArgsCache;  


typedef void (*SrtFcn)(SrtArgsCache *args);

typedef struct {
    SrtArgsCache Args;
    SrtFcn     SrtFcnPtr;    /* Pointer to function */
} SFcnCache;

extern void Srt_Asc_Val_R(SrtArgsCache *args); /* Output Values only in ascending order, data-type is real    single-precision  */
extern void Srt_Asc_Val_D(SrtArgsCache *args); /* Output Values only in ascending order, data-type is real    double-precision  */
extern void Srt_Asc_Val_C(SrtArgsCache *args); /* Output Values only in ascending order, data-type is complex single-precision  */
extern void Srt_Asc_Val_Z(SrtArgsCache *args); /* Output Values only in ascending order, data-type is complex double-precision  */

extern void Srt_Asc_Indx_R(SrtArgsCache *args); /* Output Indices only in ascending order, data-type is real    single-precision  */
extern void Srt_Asc_Indx_D(SrtArgsCache *args); /* Output Indices only in ascending order, data-type is real    double-precision  */
extern void Srt_Asc_Indx_C(SrtArgsCache *args); /* Output Indices only in ascending order, data-type is complex single-precision  */
extern void Srt_Asc_Indx_Z(SrtArgsCache *args); /* Output Indices only in ascending order, data-type is complex double-precision  */

extern void Srt_Asc_ValIndx_R(SrtArgsCache *args); /* Output Values & Indices in ascending order, data-type is real    single-precision  */
extern void Srt_Asc_ValIndx_D(SrtArgsCache *args); /* Output Values & Indices in ascending order, data-type is real    double-precision  */
extern void Srt_Asc_ValIndx_C(SrtArgsCache *args); /* Output Values & Indices in ascending order, data-type is complex single-precision  */
extern void Srt_Asc_ValIndx_Z(SrtArgsCache *args); /* Output Values & Indices in ascending order, data-type is complex double-precision  */

extern void Srt_Des_Val_R(SrtArgsCache *args); /* Output Values only in descending order, data-type is real    single-precision  */
extern void Srt_Des_Val_D(SrtArgsCache *args); /* Output Values only in descending order, data-type is real    double-precision  */
extern void Srt_Des_Val_C(SrtArgsCache *args); /* Output Values only in descending order, data-type is complex single-precision  */
extern void Srt_Des_Val_Z(SrtArgsCache *args); /* Output Values only in descending order, data-type is complex double-precision  */

extern void Srt_Des_Indx_R(SrtArgsCache *args); /* Output Indices only in descending order, data-type is real    single-precision  */
extern void Srt_Des_Indx_D(SrtArgsCache *args); /* Output Indices only in descending order, data-type is real    double-precision  */
extern void Srt_Des_Indx_C(SrtArgsCache *args); /* Output Indices only in descending order, data-type is complex single-precision  */
extern void Srt_Des_Indx_Z(SrtArgsCache *args); /* Output Indices only in descending order, data-type is complex double-precision  */

extern void Srt_Des_ValIndx_R(SrtArgsCache *args); /* Output Values & Indices in descending order, data-type is real    single-precision  */
extern void Srt_Des_ValIndx_D(SrtArgsCache *args); /* Output Values & Indices in descending order, data-type is real    double-precision  */
extern void Srt_Des_ValIndx_C(SrtArgsCache *args); /* Output Values & Indices in descending order, data-type is complex single-precision  */
extern void Srt_Des_ValIndx_Z(SrtArgsCache *args); /* Output Values & Indices in descending order, data-type is complex double-precision  */


#endif /* dsp_srt_sim.h */

/* [EOF] dsp_srt_sim.h  */

