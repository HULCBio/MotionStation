/* $Revision: 1.1.6.1 $ */
#ifndef HDFVS_H
#define HDFVS_H

extern void hdfVS(int nlhs,
           mxArray *plhs[],
           int nrhs,
           const mxArray *prhs[],
           char *functionStr
    );

/*
 * Detach vdata_id and forget any setfields information that has been saved
 */ 
extern intn hdfVSDetachAndForget(
	int32 vdata_id
	);

#endif /* HDFVS_H */

