/*
 * dsp_g711_sim - Multimedia Blockset G711 simulation support functions
 *
 *  Copyright 2001-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:11:22 $
 */

#ifndef dsp_g711_sim_h
#define dsp_g711_sim_h

#include "dsp_sim.h"
#include "dspg711_rt.h" 

/*
 * G711 common argument cache, used during simulation only
 */
typedef struct {
    int_T       nElems;
    void        *outPtr;       /* Output data pointer                    */
    const void  *inPtr;        /* Input data pointer                     */
    void        *optTable;     /* Optional table for decoding/conversion */
} MWDSP_G711ArgsCache;

typedef enum {
    A_LAW,
    MU_LAW
} G711Type;

/*
 * G711 functions for simulation use only
 */

/* Functions for encoding to A-law and mu-law */
extern boolean_T dsp_g711_enc_a_sat(MWDSP_G711ArgsCache *args);
extern boolean_T dsp_g711_enc_a_wrap(MWDSP_G711ArgsCache *args);
extern boolean_T dsp_g711_enc_mu_sat(MWDSP_G711ArgsCache *args);
extern boolean_T dsp_g711_enc_mu_wrap(MWDSP_G711ArgsCache *args);

/* Functions for decoding from A-law and mu-law */
extern boolean_T dsp_g711_dec_a_or_mu(MWDSP_G711ArgsCache *args);

/* Functions for converting between A and mu laws */
extern boolean_T dsp_g711_cnv_a_mu(MWDSP_G711ArgsCache *args);
extern boolean_T dsp_g711_cnv_mu_a(MWDSP_G711ArgsCache *args);

#endif /* dsp_g711_sim_h */

/* [EOF] dsp_g711_sim.h */
