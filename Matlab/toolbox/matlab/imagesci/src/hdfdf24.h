/* $Revision: 1.1.6.1 $ */
#ifndef HDFDF24_H
#define HDFDF24_H

/*
 * hdfDF24
 *
 * Purpose: Function switchyard for the DF24 part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which DF24 function to call
 * Outputs: none
 * Return:  none
 */
extern void hdfDF24(int nlhs,
             mxArray *plhs[],
             int nrhs,
             const mxArray *prhs[],
             char *functionStr
    );

#endif /* HDFDF24_H */
