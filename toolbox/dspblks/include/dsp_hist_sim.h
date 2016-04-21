/* Simulation support header file for Statistics library 'Histogram' block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.4 $  $Date: 2002/04/14 20:39:23 $
 */
#ifndef dsp_hist_sim_h
#define dsp_hist_sim_h

#include "dsp_sim.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "dsphist_rt.h"

/*
 * Argument and function pointer caches:
 */
typedef union  {real_T D; real32_T R;} DblSgl;

typedef struct {
    const void *u_data;   /* Input data pointer  */
    void       *y;        /* Output data pointer */

    int_T nChans;       /* Number of channels of input data */       
    int_T nSamps;       /* Number of samples of input data */ 

    DblSgl umin;        /* Minimum value of input */
    DblSgl umax;        /* Maximum value of input */
    int_T  Nbins;       /* Number of bins*/
    DblSgl idelta;      /* Inverse of bin width */

    DblSgl scale; /* used only for normalized non-running mode , 
                   * for non-running mode = (1/nSamps)
                   * for running mode = 1/(nSamps * iteration_count) which is calculated dynamically at each time step. 
                   */
    void *h;        /* Pointer to D-Work containing bin count index */
    void *iter_cnt; /* Used only in Normalized running mode, points to D-Work keeping track of iteration count */
    boolean_T   reset;  /*whether reset event has occured or not*/
    boolean_T   norm;   /* whether we need normalization (norm = 1)  or not (norm = 0) */
    
} HistArgsCache;

typedef void (*HistFcn)(HistArgsCache *args);

extern void Hist_Nonrun_R(HistArgsCache *args);
extern void Hist_Nonrun_D(HistArgsCache *args);
extern void Hist_Nonrun_C(HistArgsCache *args);
extern void Hist_Nonrun_Z(HistArgsCache *args);

extern void Hist_Runrst_R(HistArgsCache *args);
extern void Hist_Runrst_D(HistArgsCache *args);
extern void Hist_Runrst_C(HistArgsCache *args);
extern void Hist_Runrst_Z(HistArgsCache *args);

extern void Hist_Runnorst_R(HistArgsCache *args);
extern void Hist_Runnorst_D(HistArgsCache *args);
extern void Hist_Runnorst_C(HistArgsCache *args);
extern void Hist_Runnorst_Z(HistArgsCache *args);

#ifdef __cplusplus
}
#endif

#endif /* dsp_hist_sim.h */

/* [EOF] dsp_hist_sim.h  */
