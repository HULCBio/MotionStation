/* Copyright 1984-2002 The MathWorks, Inc. */

/*
 * HDF.MEX
 *
 * This MEX-file is a gateway to the HDF (Hierarchical Data Format)
 * API.  The HDF API is divided into several groups of functions, known
 * as interfaces (e.g. the "H", "DFR8", and "DF24" interfaces).  HDF.MEX
 * provides a way for the MATLAB user to call HDF API routines.
 *
 * The general syntax is:
 *
 *   [out1, out2, ...] = hdf(INTERFACE, FUNCNAME, in1, in2, ...)
 *
 * INTERFACE is a string that identifies the particular HDF interface
 * to use, and FUNCNAME is a string that identifies the particular
 * API function to call.  For example, the MATLAB equivalent of this
 * C call to the H interface function Hclose:
 *
 *    status = Hclose(file_id);
 *
 * is:
 *
 *    status = hdf('H', 'close', file_id);
 *
 * The following interfaces are available:  H, HE, DF24, DFR8.
 * There is also an ML interface that controls some aspects of the 
 * HDF.MEX gateway behavior.
 *
 * Implementation notes:  mexFunction() in hdf.c served as the interface 
 * switchyard.  It looks at the first input argument and passes control 
 * off to another module.  For example, if the H interface is specified, 
 * mexFunction() will call hdfH(), which is the only public function in
 * the module hdfh.c.  hdfH() looks at the second input argument to
 * determine which of the private functions in hdfh.c to call.  As
 * currently coded this scheme relies on two strcmp chains, but performance
 * doesn't seem to be an issue.
 *
 * hdfutils.c contains several utility routines shared by all the other
 * hdf*.c modules.  These utility routines generally are prefixed by
 * ha, as in haGetDoubleScalar().
 */

/* $Revision: 1.1.6.1 $ */

static char rcsid[] = "$Id: hdf.c,v 1.1.6.1 2003/12/13 03:01:48 batserve Exp $";
 
#include <string.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

/* Individual interface modules */
#include "hdfan.h"
#include "hdfdf24.h"
#include "hdfdfr8.h"
#include "hdfgr.h"
#include "hdfh.h"
#include "hdfhd.h"
#include "hdfhe.h"
#include "hdfhl.h"
#include "hdfhx.h"
#include "hdfml.h"
#include "hdfpt.h"
#include "hdfsd.h"
#include "hdfv.h"
#include "hdfvf.h"
#include "hdfvh.h"
#include "hdfvs.h"
#include "hdfpt.h"
#include "hdfsw.h"
#include "hdfeh.h"
#include "hdfgd.h"

static bool mexAtExitIsSet = false;

void mexFunction(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[])
{
    char *apiStr;
    char *functionStr;
    int i;
    typedef void (API_FCN)(int nlhs, mxArray *plhs[], 
                           int nrhs, const mxArray *prhs[], 
                           char *functionString);
	/* Table of the HDF API's */
	struct {
        char *name;
		API_FCN *fcn;
    }  HDF_Api[] = {
        {"H",    hdfH}, 
#ifdef USE_HL
        {"HL",   hdfHL}, 
#endif /* USE_HL */
        {"HX",   hdfHX}, 
        {"HE",   hdfHE}, 
        {"HD",   hdfHD}, 
#ifdef USE_GR
    /*
     * The HDF GR library in 4.1r3 has some bugs in it that
     * made it not usable for the image file-format functionality
     * in MATLAB 5.  Don't enable the GR gateway until we get
     * some bug fixes from NCSA.
     */
        {"GR",   hdfGR}, 
#endif /* USE_GR */
        {"DFR8", hdfDFR8}, 
        {"DF24", hdfDF24}, 
        {"SD",   hdfSD}, 
        {"V",    hdfV}, 
        {"VF",   hdfVF}, 
        {"VS",   hdfVS}, 
        {"VH",   hdfVH}, 
        {"AN",   hdfAN}, 
        {"PT",   hdfPT}, 
        {"SW",   hdfSW}, 
        {"GD",   hdfGD},
        {"EH",   hdfEH},
        {"ML",   hdfML}, 
    };
    int NumberOfApis = sizeof(HDF_Api) / sizeof(*HDF_Api);

    bool apiFound = false;

    if (! mexAtExitIsSet)
    {
        HDdont_atexit();
        HIstart();
        haInitializeLists();
        haRegJPGHandler();
        mexAtExit(haMexAtExit);
        mexAtExitIsSet = true;
    }

    if (nrhs < 2)
    {
        mexErrMsgTxt("At least two input arguments required.");
    }

    apiStr = haGetString(prhs[0], "Interface identifier");

    functionStr = haGetString(prhs[1], "Function identifier");

    for (i=0; i<NumberOfApis; i++) 
	{
        if (strcmp(apiStr, HDF_Api[i].name) == 0)
        {
            (*(HDF_Api[i].fcn))(nlhs,plhs,nrhs,prhs,functionStr);
            apiFound = true;
            break;
        }
    }

    haLibraryInitialized();

    mxFree(apiStr);
    mxFree(functionStr);

    if (! apiFound)
        mexErrMsgTxt("Invalid or unsupported HDF interface specified.");


}

