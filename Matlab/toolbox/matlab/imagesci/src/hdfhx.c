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
 * access_id = hdf('HX', 'create', file_id, tag, ref, extern_name,
 *                 offset, length)
 *
 * status = hdf('HX','setdir',pathname);
 *
 * status = hdf('HX','setcreatedir',pathname);
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:12 $ */

static char rcsid[] = "$Id: hdfhx.c,v 1.1.6.1 2003/12/13 03:02:12 batserve Exp $";

#include <string.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfhx.h"

/*
 * hdfHXsetdir
 *
 * Purpose: gateway to HXsetdir()
 *
 * MATLAB usage:
 * status = hdf('HX','setdir',pathname);
 *
 */
static void hdfHXsetdir(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    char *pathname;
    int32 status;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    pathname = haGetString(prhs[2], "Pathname");
    status = HXsetdir(pathname);
    mxFree(pathname);
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfHXsetcreatedir
 *
 * Purpose: gateway to HXsetcreatedir()
 *
 * MATLAB usage:
 * status = hdf('HX','setcreatedir',pathname);
 *
 */
static void hdfHXsetcreatedir(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    char *pathname;
    int32 status;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    pathname = haGetString(prhs[2], "Pathname");
    status = HXsetcreatedir(pathname);
    mxFree(pathname);
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfHXcreate
 *
 * Purpose: gateway to HXcreate()
 *
 * MATLAB usage:
 * access_id = hdf('HX', 'create', file_id, tag, ref, extern_name,
 *                 offset, length)
 */
static void hdfHXcreate(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 file_id;
    uint16 tag;
    uint16 ref;
    char *extern_name;
    int32 offset;
    int32 length;
    int32 H_id;
    intn status;

    haNarginChk(8, 8, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");
    extern_name = haGetString(prhs[5], "External filename");
    offset = (int32) haGetDoubleScalar(prhs[6], "Offset");
    length = (int32) haGetDoubleScalar(prhs[7], "Length");

    H_id = HXcreate(file_id, tag, ref, extern_name, offset, length);
    if (H_id != FAIL)
    {
        status = haAddIDToList(H_id, Access_ID_List);
        if (status == FAIL)
        {
            /* Failed to add access id to the list. */
            /* This might cause data loss later, so we don't allow it. */
            Hendaccess(H_id);
            H_id = FAIL;
        }
    }
    mxFree(extern_name);
    plhs[0] = haCreateDoubleScalar((double) H_id);
}
    

/*
 * hdfHX
 *
 * Purpose: Function switchyard for the HX part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which HX function to call
 * Outputs: none
 * Return:  none
 */
void hdfHX(int nlhs,
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
        func = hdfHXcreate;
    }
    else if(strcmp(functionStr, "setdir") == 0)
    {
        func = hdfHXsetdir;
    }
    else if(strcmp(functionStr, "setcreatedir") == 0)
    {
        func = hdfHXsetcreatedir;
    }
    else
    {
        mexErrMsgTxt("Unknown HX interface function.");
    }

    (*func)(nlhs, plhs, nrhs, prhs);
}

