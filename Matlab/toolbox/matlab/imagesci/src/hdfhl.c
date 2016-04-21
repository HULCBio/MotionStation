/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfhx.c --- support file for HDF.MEX
 *
 * This module supports a *portion* of the HDF HX interface.  The only public
 * function is hdfHX(), which is called by mexFunction().
 * hdfHX looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * access_id = hdf('HL', 'create', file_id, tag, ref, block_len, n_blocks)
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:10 $ */

static char rcsid[] = "$Id: hdfhl.c,v 1.1.6.1 2003/12/13 03:02:10 batserve Exp $";

#include <string.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfhl.h"

/*
 * hdfHLcreate
 * 
 * Purpose: gateway to HLcreate()
 *
 * MATLAB usage:
 * access_id = hdf('HL', 'create', file_id, tag, ref, block_len, n_blocks)
 */
static void hdfHLcreate(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 file_id;
    uint16 tag;
    uint16 ref;
    int32 block_len;
    int32 n_blocks;
    int32 access_id;
    intn status;

    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");
    block_len = (int32) haGetDoubleScalar(prhs[5], "Block length");
    n_blocks = (int32) haGetDoubleScalar(prhs[6], "Number of blocks");

    access_id = HLcreate(file_id, tag, ref, block_len, n_blocks);
    if (access_id != FAIL)
    {
        status = haAddIDToList(access_id, Access_ID_List);
        if (status == FAIL)
        {
            /* Failed to add access id to the list */
            /* This might cause data loss later, so don't allow it */
            Hendaccess(access_id);
            access_id = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar((double) access_id);
}
    

/*
 * hdfHL
 *
 * Purpose: Function switchyard for the HL part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which HL function to call
 * Outputs: none
 * Return:  none
 */
void hdfHL(int nlhs,
          mxArray *plhs[],
          int nrhs,
          const mxArray *prhs[],
          char *functionStr
          )
{
    void (*func)(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[]);

    if (strcmp(functionStr, "create") == 0)
    {
        func = hdfHLcreate;
    }
    else
    {
        mexErrMsgTxt("Unknown HL interface function.");
    }

    (*func)(nlhs, plhs, nrhs, prhs);
}

