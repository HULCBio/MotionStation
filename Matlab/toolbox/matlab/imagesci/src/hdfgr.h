/* $Revision: 1.1.6.1 $ */
#ifndef HDFGR_H
#define HDFGR_H

#ifdef USE_GR
extern void hdfGR(int nlhs,
           mxArray *plhs[],
           int nrhs,
           const mxArray *prhs[],
           char *functionStr
    );
#endif /* USE_GR */

#endif /* HDFGR_H */

