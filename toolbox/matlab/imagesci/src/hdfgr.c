/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfgr.c --- support file for HDF.MEX
 *
 * This module supports the HDF GR interface.  The only public
 * function is hdfGR(), which is called by mexFunction().
 * hdfGR looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * [name, data_type, count, status] = hdf('GR', 'attrinfi', grid/riid, 
 *              attr_idx)
 *
 * ri_id = hdf('GR', 'create', gr_id, name, ncomp, data_type, interlace,
 *            [width height])
 *         interlace can be 'pixel', 'line', or 'component'
 *         data_type is a string
 *
 * status = hdf('GR', 'end', gr_id)
 *
 * status = hdf('GR', 'endaccess', ri_id)
 *
 * [ndatasets, nattributes, status] = hdf('GR', 'fileinfo', gr_id)
 *
 * attr_index = hdf('GR', 'findattr', gr_id/ri_id, name)
 *
 * [A, status] = hdf('GR', 'getattr', id, attr_index)
 *
 * [name, ncomp, data_type, interlace, size, nattrs, status] =
 *          hdf('GR', 'getiminfo', ri_id)
 *          interlace is returned as 'pixel', 'line', or 'component'
 *
 * pal_id = hdf('GR', 'getlutid', ri_id, lut_index)
 *
 * [ncomp, data_type, interlace, num_entries, status] = 
 *               hdf('GR', 'getlutinfo', pal_id)
 *
 * ref = hdf('GR', 'idtoref', ri_id)
 *
 * gs_index = hdf('GR', 'nametoindex', gr_id, name)
 *
 * [I, status] = hdf('GR','readimage',ri_id,start,stride,edge)
 *
 * [lut, status] = hdf('GR', 'readlut', pal_id)
 *
 * gs_index = hdf('GR', 'reftoindex', gr_id, ref)
 *
 * status = hdf('GR','reqimageil',ri_id,interlace)
 *          interlace can be 'pixel', 'line', or 'component'
 *
 * status = hdf('GR','reqlutil',ri_id,interlace)
 *          interlace can be 'pixel', 'line', or 'component'
 *
 * ri_id = hdf('GR', 'select', gr_id, gr_index)
 *
 * status = hdf('GR', 'setaccesstype', ri_id, access_mode)
 *          access_mode can be 'serial' or 'parallel'
 *
 * status = hdf('GR', 'setattr', [gr_id or ri_id], name, A)
 *
 * status = hdf('GR', 'setcompress', ri_id, compress_type, [params])
 * 
 * status = hdf('GR', 'setexternalfile', ri_id, filename, offset)
 *
 * gr_id = hdf('GR', 'start', file_id)
 *
 * status = hdf('GR', 'writeimage', ri_id, start, stride, edge, data)
 *
 * status = hdf('GR', 'writelut', pal_id, LUT, interlace)
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:02 $ */

static char rcsid[] = "$Id: hdfgr.c,v 1.1.6.1 2003/12/13 03:02:02 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* Multifile GR interface header file */
#include "mfgr.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfgr.h"

#ifdef USE_GR

/* 
 * The GR interface lets a caller set the interlace to be used
 * on the next read or write.  The MATLAB gateway has to know
 * what the requested is so that the mxArray dimensions can be
 * set properly.  However, there is no HDF API function to query
 * the requested interlace.  Therefore, when an interlace request
 * goes through the gateway, the gateway must remember it.
 */
#define UNINITIALIZED (-1)
static int32 NextReadImageInterlace = UNINITIALIZED;
static int32 NextReadLutInterlace = UNINITIALIZED;

/*
 * hdfGRattrinfo
 *
 * Purpose: gateway to GRattrinfo()
 *
 * MATLAB usage:
 * [name, data_type, count, status] = hdf('GR', 'attrinfi', grid/riid, 
 *              attr_idx)
 */
static void hdfGRattrinfo(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 id;
    int32 attr_index;
    char name[MAX_GR_NAME];
    int32 data_type;
    const char *data_type_str;
    int32 count;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 4, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Identifier");
    attr_index = (int32) haGetDoubleScalar(prhs[3], "Attribute index");

    status = GRattrinfo(id, attr_index, name, &data_type, &count);
   
    data_type_str = haGetDataTypeString(data_type);

    plhs[0] = mxCreateString(name);
   
    if (nlhs > 1)
    {
        plhs[1] = mxCreateString(data_type_str);
    }

    if (nlhs > 2)
    {
        plhs[2] = haCreateDoubleScalar((double) count);
    }

    if (nlhs > 3)
    {
        plhs[3] = haCreateDoubleScalar((double) status);
    }
}
    

/*
 * hdfGRcreate
 *
 * Purpose: gateway to GRcreate()
 *
 * MATLAB usage:
 * ri_id = hdf('GR', 'create', gr_id, name, ncomp, data_type, interlace,
 *            [width height])
 *         interlace can be 'pixel', 'line', or 'component'
 *         data_type is a string
 */
static void hdfGRcreate(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 gr_id;
    char *name;
    int32 ncomp;
    int32 data_type;
    int32 il;
    int32 dim_sizes[2];
    int32 ri_id;
    double *pr;
    intn status;

    haNarginChk(8, 8, nrhs);
    haNargoutChk(0, 1, nlhs);

    gr_id = (int32) haGetDoubleScalar(prhs[2], "GR identifier");

    name = haGetString(prhs[3], "Image name");

    ncomp = (int32) haGetDoubleScalar(prhs[4], "Number of components");
    data_type = haGetDataType(prhs[5]);
    il = haGetInterlaceFlag(prhs[6]);

    if ((mxGetM(prhs[7]) != 1) || (mxGetN(prhs[7]) != 2) ||
        !mxIsDouble(prhs[7]))
    {
        mexErrMsgTxt("SIZE must be a double 1-by-2 vector.");
    }
    pr = mxGetPr(prhs[7]);
    dim_sizes[0] = (int32) pr[0];
    dim_sizes[1] = (int32) pr[1];

    ri_id = GRcreate(gr_id, name, ncomp, data_type, il, dim_sizes);
    if (ri_id != FAIL)
    {
        status = haAddIDToList(ri_id, RI_ID_List);
        if (status == FAIL)
        {
            /* Failed to add ri_id to the list. */
            /* This could cause data loss later, so don't allow it. */
            GRendaccess(ri_id);
            ri_id = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar((double) ri_id);

    mxFree((void *) name);
}

    

/*
 * hdfGRend
 *
 * Purpose: gateway to GRend()
 *
 * MATLAB usage:
 * status = hdf('GR', 'end', gr_id)
 */
static void hdfGRend(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 gr_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    gr_id = (int32) haGetDoubleScalar(prhs[2], "GR identifier");
    status = GRend(gr_id);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(gr_id, GR_ID_List);
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGRendaccess
 *
 * Purpose: gateway to GRendaccess()
 *
 * MATLAB usage:
 * status = hdf('GR', 'endaccess', ri_id)
 */
static void hdfGRendaccess(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 r_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    r_id = (int32) haGetDoubleScalar(prhs[2], "GR raster identifier");
    status = GRendaccess(r_id);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(r_id, RI_ID_List);
    }

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGRfileinfo
 *
 * Purpose: gateway to GRfileinfo()
 *
 * MATLAB usage:
 * [ndatasets, nattributes, status] = hdf('GR', 'fileinfo', gr_id)
 */
static void hdfGRfileinfo(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 gr_id;
    int32 n_datasets;
    int32 n_attributes;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 3, nlhs);

    gr_id = (int32) haGetDoubleScalar(prhs[2], "GR identifier");
    status = GRfileinfo(gr_id, &n_datasets, &n_attributes);

    if (status == SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) n_datasets);
    }
    else
    {
        plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    }

    if (nlhs > 1)
    {
        if (status == SUCCEED)
        {
            plhs[1] = haCreateDoubleScalar((double) n_attributes);
        }
        else
        {
            plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 2)
    {
        plhs[2] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfGRfindattr
 *
 * Purpose: gateway to GRfindattr()
 *
 * MATLAB usage:
 * attr_index = hdf('GR', 'findattr', gr_id/ri_id, name)
 */
static void hdfGRfindattr(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 id;
    char *name;
    int32 attr_index;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Identifier");
    name = haGetString(prhs[3], "Attribute name");

    attr_index = GRfindattr(id, name);

    plhs[0] = haCreateDoubleScalar((double) attr_index);

    mxFree((void *) name);
}

/*
 * hdfGRgetattr
 *
 * Purpose: gateway to GRgetattr()
 *
 * MATLAB usage:
 * [A, status] = hdf('GR', 'getattr', id, attr_index)
 */
static void hdfGRgetattr(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 id;
    int32 attr_index;
    int32 count;
    int32 data_type;
    char name[MAX_GR_NAME];
    mxClassID classID;
    intn status;
    mxArray *A;
    int sizeA[2];
    char *buffer = NULL;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Identifier");
    attr_index = (int32) haGetDoubleScalar(prhs[3], "Attribute index");

    status = GRattrinfo(id, attr_index, name, &data_type, &count);
    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
    else
    {
        classID = haGetClassIDFromDataType(data_type);
        if (classID == mxCHAR_CLASS)
        {
            buffer = mxCalloc(count+1, sizeof(*buffer));
            status = GRgetattr(id, attr_index, (VOIDP) buffer);
            A = mxCreateString(buffer);
            mxFree((void *) buffer);
        }
        else
        {
            sizeA[0] = 1;
            sizeA[1] = count;
            A = mxCreateNumericArray(2, sizeA, classID, mxREAL);
            status = GRgetattr(id, attr_index, mxGetData(A));
        }

        plhs[0] = A;
    }
        
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
}


/*
 * hdfGRgetiminfo
 *
 * Purpose: gateway to GRgetiminfo()
 *
 * MATLAB usage:
 * [name, ncomp, data_type, interlace, size, nattrs, status] =
 *          hdf('GR', 'getiminfo', ri_id)
 *          interlace is returned as 'pixel', 'line', or 'component'
 */
static void hdfGRgetiminfo(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 ri_id;
    intn status;
    char name[MAX_GR_NAME];
    int32 ncomp;
    int32 data_type;
    int32 il;
    int32 dim_sizes[2];
    int32 nattrs;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 7, nlhs);

    ri_id = (int32) haGetDoubleScalar(prhs[2], "GR raster identifier");
    status = GRgetiminfo(ri_id, name, &ncomp, &data_type,
                         &il, dim_sizes, &nattrs);

    if (status == SUCCEED)
    {
        plhs[0] = mxCreateString(name);
    }
    {
        plhs[0] = mxCreateString("");
    }

    if (nlhs > 1)
    {
        if (status == SUCCEED)
        {
            plhs[1] = haCreateDoubleScalar((double) ncomp);
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }

    if (nlhs > 2)
    {
        if (status == SUCCEED)
        {
            plhs[2] = mxCreateString(haGetDataTypeString(data_type));
        }
        else
        {
            plhs[2] = EMPTY;
        }
    }

    if (nlhs > 3)
    {
        if (status == SUCCEED)
        {
            plhs[3] = mxCreateString(haGetInterlaceString(il));
        }
        else
        {
            plhs[3] = EMPTY;
        }
    }

    if (nlhs > 4)
    {
        if (status == SUCCEED)
        {
            plhs[4] = mxCreateDoubleMatrix(1, 2, mxREAL);
            mxGetPr(plhs[4])[0] = (double) dim_sizes[0];
            mxGetPr(plhs[4])[1] = (double) dim_sizes[1];
        }
        else
        {
            plhs[4] = EMPTY;
        }
    }

    if (nlhs > 5)
    {
        if (status == SUCCEED)
        {
            plhs[5] = haCreateDoubleScalar((double) nattrs);
        }
        else
        {
            plhs[5] = EMPTY;
        }
    }

    if (nlhs > 6)
    {
        plhs[6] = haCreateDoubleScalar((double) status);
    }
}

/* 
 * hdfGRgetlutid
 *
 * Purpose: gateway to GRgetlutid()
 *
 * MATLAB usage:
 * pal_id = hdf('GR', 'getlutid', ri_id, lut_index)
 */
static void hdfGRgetlutid(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 ri_id;
    int32 lut_index;
    int32 pal_id;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    ri_id = (int32) haGetDoubleScalar(prhs[2], "GR raster identifier");
    lut_index = (int32) haGetDoubleScalar(prhs[3], "Image index");

    pal_id = GRgetlutid(ri_id, lut_index);

    plhs[0] = haCreateDoubleScalar((double) pal_id);
}

/*
 * hdfGRgetlutinfo
 *
 * Purpose: gateway to GRgetlutinfo()
 *
 * MATLAB usage:
 * [ncomp, data_type, interlace, num_entries, status] = 
 *               hdf('GR', 'getlutinfo', pal_id)
 */
static void hdfGRgetlutinfo(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    int32 pal_id;
    int32 ncomp;
    int32 data_type;
    int32 il;
    int32 num_entries;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 5, nlhs);

    pal_id = (int32) haGetDoubleScalar(prhs[2], "Palette identifier");
    status = GRgetlutinfo(pal_id, &ncomp, &data_type, &il,
                          &num_entries);
    mexPrintf("ncomp = %d, data_type = %d, il = %d, num_entries = %d\n",
              ncomp, data_type, il, num_entries);

    if (status == SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) ncomp);
    }
    else
    {
        plhs[0] = EMPTY;
    }

    if (nlhs > 1)
    {
        if (status == SUCCEED)
        {
            plhs[1] = mxCreateString(haGetDataTypeString(data_type));
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }

    if (nlhs > 2)
    {
        if (status == SUCCEED)
        {
            plhs[2] = mxCreateString(haGetInterlaceString(il));
        }
        else
        {
            plhs[2] = EMPTY;
        }
    }

    if (nlhs > 3)
    {
        if (status == SUCCEED)
        {
            plhs[3] = haCreateDoubleScalar((double) num_entries);
        }
        else
        {
            plhs[3] = EMPTY;
        }
    }

    if (nlhs > 4)
    {
        plhs[4] = haCreateDoubleScalar((double) num_entries);
    }
}


/*
 * hdfGRidtoref
 *
 * Purpose: gateway to GRidtoref()
 *
 * MATLAB usage:
 * ref = hdf('GR', 'idtoref', ri_id)
 */
static void hdfGRidtoref(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 ri_id;
    uint16 ref;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    ri_id = (int32) haGetDoubleScalar(prhs[2], "GR raster identifier");
    ref = GRidtoref(ri_id);
    plhs[0] = haCreateDoubleScalar((double) ref);
}

/* 
 * hdfGRnametoindex
 *
 * Purpose: gateway to GRnametoindex()
 *
 * MATLAB usage:
 * gs_index = hdf('GR', 'nametoindex', gr_id, name)
 */
static void hdfGRnametoindex(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    int32 gr_id;
    char *name;
    int32 gs_index;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    gr_id = (int32) haGetDoubleScalar(prhs[2], "GR identifier");
    name = haGetString(prhs[3], "Image name");

    gs_index = GRnametoindex(gr_id, name);

    plhs[0] = haCreateDoubleScalar((double) gs_index);

    mxFree((void *) name);
}


/*
 * hdfGRreadimage
 *
 * Purpose: gateway to GRreadimage()
 *
 * MATLAB usage:
 * [I, status] = hdf('GR','readimage',ri_id,start,stride,edge)
 */
static void hdfGRreadimage(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 ri_id;
    int32 start[2];
    int32 stride[2];
    int32 edge[2];
    double *pr;
    char ri_name[MAX_GR_NAME];
    int32 ri_ncomp;
    int32 ri_data_type;
    int32 ri_dim_sizes[2];
    int32 ri_nattrs;
    int32 ri_il;
    int32 ncomp;
    int32 width;
    int32 height;
    int32 il;
    intn status;
    int output_size[3];
    bool unit_strides = true;
    mxArray *I;
    

    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);

    ri_id = (int32) haGetDoubleScalar(prhs[2], "GR raster identifier");

    /* Retrieve information about the raster image data set */
    status = GRgetiminfo(ri_id, ri_name, &ri_ncomp, &ri_data_type,
                         &ri_il, ri_dim_sizes, &ri_nattrs);
    if (status == FAIL)
    {
        mexErrMsgTxt("Invalid GR raster identifier.");
    }
    
    if (NextReadImageInterlace == UNINITIALIZED)
    {
        il = ri_il;
    }
    else
    {
        il = NextReadImageInterlace;
    }

    if (((mxGetM(prhs[3]) * mxGetN(prhs[3])) != 2) || !mxIsDouble(prhs[3]))
    {
        mexErrMsgTxt("START must be a 2-element double vector.");
    }
    pr = mxGetPr(prhs[3]);
    start[0] = (int32) pr[0];
    start[1] = (int32) pr[1];

    if (((mxGetM(prhs[4]) * mxGetN(prhs[4])) != 2) || !mxIsDouble(prhs[4]))
    {
        mexErrMsgTxt("STRIDE must be a 2-element double vector.");
    }
    pr = mxGetPr(prhs[4]);
    stride[0] = (int32) pr[0];
    stride[1] = (int32) pr[1];
    if ((stride[0] != 1) || (stride[1] != 1))
    {
        unit_strides = false;
    }
    if ((stride[0] < 1) || (stride[1] < 1))
    {
        mexErrMsgTxt("STRIDE values must be >= 1.");
    }

    if (((mxGetM(prhs[5]) * mxGetN(prhs[5])) != 2) || !mxIsDouble(prhs[5]))
    {
        mexErrMsgTxt("EDGE must be a 2-element double vector.");
    }
    pr = mxGetPr(prhs[5]);
    edge[0] = (int32) pr[0];
    edge[1] = (int32) pr[1];

    /* Figure out what the size of the output MATLAB array should be.
     * If interlace is 'pixel', ML array should be ncomp-by-width-by-height.
     * If interlace is 'line', ML array should be width-by-ncomp-by-height.
     * If interlace is 'component', ML array should be 
     * width-by-height-by-ncomp.
     */
    ncomp = ri_ncomp;
    width = (int32) ceil((double) edge[0] / (double) stride[0]);
    height = (int32) ceil((double) edge[1] / (double) stride[1]);
    switch (il)
    {
    case MFGR_INTERLACE_PIXEL:
        output_size[0] = ncomp;
        output_size[1] = width;
        output_size[2] = height;
        break;

    case MFGR_INTERLACE_LINE:
        output_size[0] = width;
        output_size[1] = ncomp;
        output_size[2] = height;
        break;

    case MFGR_INTERLACE_COMPONENT:
        output_size[0] = width;
        output_size[1] = height;
        output_size[2] = ncomp;
        break;

    default:
        mexErrMsgTxt("Unrecognized interlace.");
    }

    /* Create the output ML array */
    
    I = mxCreateNumericArray(3, output_size, 
                             haGetNumericClassIDFromDataType(ri_data_type),
                             mxREAL);

    /* Ready to try the read */
    status = GRreadimage(ri_id, start, stride, edge, mxGetData(I));
    if (status == FAIL)
    {
        mxDestroyArray(I);
        I = EMPTY;
    }

    plhs[0] = I;
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfGRreadlut
 *
 * Purpose: gateway to GRreadlut()
 *
 * MATLAB usage:
 * [lut, status] = hdf('GR', 'readlut', pal_id)
 */
static void hdfGRreadlut(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 pal_id;
    int32 data_type;
    int32 ncomp;
    int32 num_entries;
    int32 il;
    mxArray *A;
    int sizeA[2];
    mxClassID classA;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    pal_id = (int32) haGetDoubleScalar(prhs[2], "Palette identifier");
    
/***/    status = GRgetlutinfo(pal_id, &ncomp, &data_type, &il, &num_entries);
    status = SUCCEED;
    ncomp = 3;
    num_entries = 256;
    il = 0;
    data_type = DFNT_UINT8;
    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
    else
    {
        classA = haGetNumericClassIDFromDataType(data_type);
        if (NextReadLutInterlace == UNINITIALIZED)
        {
            NextReadLutInterlace = il;
        }
        switch (NextReadLutInterlace)
        {
        case MFGR_INTERLACE_PIXEL:
            sizeA[0] = ncomp;
            sizeA[1] = num_entries;
            break;

        case MFGR_INTERLACE_LINE:
            sizeA[0] = ncomp;
            sizeA[1] = num_entries;
            break;

        case MFGR_INTERLACE_COMPONENT:
            sizeA[0] = num_entries;
            sizeA[1] = ncomp;
            break;

        default:
            mexErrMsgTxt("Unrecognized or unsupported LUT interlace.");
        }

        A = mxCreateNumericArray(2, sizeA, classA, mxREAL);
        
        status = GRreadlut(pal_id, mxGetData(A));

        if (status == SUCCEED)
        {
            plhs[0] = A;
        }
        else
        {
            mxDestroyArray(A);
            plhs[0] = EMPTY;
        }
    }

    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
}
        

/*
 * hdfGRreftoindex
 *
 * Purpose: GRreftoindex()
 *
 * MATLAB usage:
 * gs_index = hdf('GR', 'reftoindex', gr_id, ref)
 */
static void hdfGRreftoindex(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    int32 gr_id;
    uint16 ref;
    int32 gs_index;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    gr_id = (int32) haGetDoubleScalar(prhs[2], "GR identifier");
    ref = (uint16) haGetDoubleScalar(prhs[3], "Reference number");

    gs_index = GRreftoindex(gr_id, ref);

    plhs[0] = haCreateDoubleScalar((double) gs_index);
}
    


/*
 * hdfGRreqimageil
 *
 * Purpose: gateway to GRreqimageil()
 *
 * MATLAB usage:
 * status = hdf('GR','reqimageil',ri_id,interlace)
 *          interlace can be 'pixel', 'line', or 'component'
 */
static void hdfGRreqimageil(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    int32 ri_id;
    int32 il;
    intn status;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    ri_id = (int32) haGetDoubleScalar(prhs[2], "GR raster identifier");
    il = haGetInterlaceFlag(prhs[3]);

    status = GRreqimageil(ri_id, il);
    if (status == SUCCEED)
    {
        NextReadImageInterlace = il;
    }

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGRreqlutil
 *
 * Purpose: gateway to GRreqlutil()
 *
 * MATLAB usage:
 * status = hdf('GR','reqlutil',ri_id,interlace)
 *          interlace can be 'pixel', 'line', or 'component'
 */
static void hdfGRreqlutil(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 ri_id;
    int32 il;
    intn status;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    ri_id = (int32) haGetDoubleScalar(prhs[2], "GR raster identifier");
    il = haGetInterlaceFlag(prhs[3]);

    status = GRreqlutil(ri_id, il);
    if (status == SUCCEED)
    {
        NextReadLutInterlace = il;
    }

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGRselect
 *
 * Purpose: gateway to GRselect()
 * 
 * MATLAB usage:
 * ri_id = hdf('GR', 'select', gr_id, gr_index)
 */
static void hdfGRselect(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 gr_id;
    int32 gr_index;
    int32 ri_id;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    gr_id = (int32) haGetDoubleScalar(prhs[2], "GR indentifier");
    gr_index = (int32) haGetDoubleScalar(prhs[3], "GR data-set index");

    ri_id = GRselect(gr_id, gr_index);
    if (ri_id != FAIL)
    {
        status = haAddIDToList(ri_id, RI_ID_List);
        if (status == FAIL)
        {
            /* Failed to add ri_id to the list. */
            /* This could cause data loss later, so don't allow it. */
            GRendaccess(ri_id);
            ri_id = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar((double) ri_id);
}

/*
 * hdfGRsetaccesstype
 *
 * Purpose: gateway to GRsetaccesstype()
 *
 * MATLAB usage:
 * status = hdf('GR', 'setaccesstype', ri_id, access_mode)
 *          access_mode can be 'serial' or 'parallel'
 */
static void hdfGRsetaccesstype(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 ri_id;
    uintn access_mode;
    char *access_mode_str;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    ri_id = (int32) haGetDoubleScalar(prhs[2], "GR raster identifier");
    access_mode_str = haGetString(prhs[3], "Access mode");

    if (strcmp(access_mode_str, "serial") == 0)
    {
        access_mode = DFACC_SERIAL;
    }
    else if (strcmp(access_mode_str, "parallel") == 0)
    {
        access_mode = DFACC_PARALLEL;
    }
    else
    {
        mexErrMsgTxt("Access mode must be 'serial' or 'parallel'.");
    }

    status = GRsetaccesstype(ri_id, access_mode);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree((void *) access_mode_str);
}

/*
 * hdfGRsetattr
 *
 * Purpose: gateway to GRsetattr()
 *
 * MATLAB usage:
 * status = hdf('GR', 'setattr', [gr_id or ri_id], name, A)
 */
static void hdfGRsetattr(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 id;
    char *name;
    char *buffer = NULL;
    const mxArray *A;
    int32 data_type;
    int32 count;
    VOIDP values;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Identifier");
    name = haGetString(prhs[3], "Name");
    A = prhs[4];
    data_type = haGetDataTypeFromClassID(mxGetClassID(A));
    count = mxGetM(A) * mxGetN(A);

    if (data_type == DFNT_CHAR8)
    {
        buffer = mxCalloc(sizeof(mxChar)*count+1, sizeof(*buffer));
        mxGetString(A, buffer, sizeof(mxChar)*count+1);
        values = (VOIDP) buffer;
        status = GRsetattr(id, name, data_type, strlen(buffer), values);
    }
    else
    {
        values = mxGetData(A);
        status = GRsetattr(id, name, data_type, count, values);
    }


    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree((void *) name);
    if (buffer != NULL)
    {
        mxFree((void *) buffer);
    }
}


/*
 * hdfGRsetcompress
 *
 * Purpose: gateway to GRsetcompress()
 *
 * MATLAB usage:
 * status = hdf('GR', 'setcompress', ri_id, compress_type, [params])
 */
static void hdfGRsetcompress(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    intn status;
    comp_info cinfo;
    int32 compressFlag;
    int32 ri_id;

    if (nrhs < 4)
    {
        mexErrMsgTxt("Too few input arguments.");
    }

    ri_id = (int32) haGetDoubleScalar(prhs[2], "GR raster indentifier");
    compressFlag = haGetCompressFlag(prhs[3]);

    if (compressFlag == COMP_JPEG)
    {
        haNarginChk(6, 6, nrhs);

        /* Arg4 is quality factor; number between 0 and 100 */
        cinfo.jpeg.quality = (intn) haGetDoubleScalar(prhs[4],
                                                      "JPEG quality factor");
        cinfo.jpeg.force_baseline =
            (intn) haGetDoubleScalar(prhs[5], "Force_baseline");
    }
    else
    {
        /* only JPEG takes additional parameters */
        if (nrhs > 4)
        {
            mexErrMsgTxt("Too many input arguments.");
        }
    }

    status = GRsetcompress(ri_id, compressFlag, &cinfo);

    plhs[0] = haCreateDoubleScalar((double) status);
}
        
/*
 * hdfGRsetexternalfile
 *
 * Purpose: gateway to GRsetexternalfile()
 *
 * MATLAB usage:
 * status = hdf('GR', 'setexternalfile', ri_id, filename, offset)
 */
static void hdfGRsetexternalfile(int nlhs,
                                 mxArray *plhs[],
                                 int nrhs,
                                 const mxArray *prhs[])
{
    int32 ri_id;
    char *filename;
    int32 offset;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    ri_id = (int32) haGetDoubleScalar(prhs[2], "GR raster identifier");
    filename = haGetString(prhs[3], "External filename");
    offset = (int32) haGetDoubleScalar(prhs[4], "Offset");

    status = GRsetexternalfile(ri_id, filename, offset);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree((void *) filename);
}

/*
 * hdfGRstart
 * 
 * Purpose: gateway to GRstart()
 *
 * MATLAB usage:
 * gr_id = hdf('GR', 'start', file_id)
 */
static void hdfGRstart(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 file_id;
    int32 gr_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    gr_id = GRstart(file_id);
    if (gr_id != FAIL)
    {
        status = haAddIDToList(gr_id, GR_ID_List);
        if (status == FAIL)
        {
            /* Failed to add gr_id to the list. */
            /* This might cause data loss later, so don't allow it. */
            GRend(gr_id);
            gr_id = FAIL;
        }
    }
    plhs[0] = haCreateDoubleScalar((double) gr_id);
}

/*
 * hdfGRwriteimage
 *
 * Purpose: gateway to GRwriteimage()
 *
 * MATLAB usage:
 * status = hdf('GR', 'writeimage', ri_id, start, stride, edge, data)
 */
static void hdfGRwriteimage(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 ri_id;
    int32 start[2];
    int32 stride[2];
    int32 edge[2];
    VOIDP data;
    intn status;
    double *pr;
    const int *arraysize;
    int dim1;
    int dim2;
    int dim3;
    int arraydims;
    char ri_name[MAX_GR_NAME];
    int32 ri_ncomp;
    int32 ri_data_type;
    int32 ri_dim_sizes[2];
    int32 ri_nattrs;
    int32 ri_il;
    int32 ncomp;
    int32 width;
    int32 height;
    int32 data_type;
    bool unit_strides = true;

    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);

    /*
     * NOTE: values in start, stride, and edge are reversed
     * before being passed to GRwriteimage.  This is to account
     * for the difference if element-ordering between MATLAB and
     * HDF.
     */

    ri_id = (int32) haGetDoubleScalar(prhs[2], "GR raster identifier");
    
    if (((mxGetM(prhs[3]) * mxGetN(prhs[3])) != 2) || !mxIsDouble(prhs[3]))
    {
        mexErrMsgTxt("START must be a 2-element double vector.");
    }
    pr = mxGetPr(prhs[3]);
    start[0] = (int32) pr[0];
    start[1] = (int32) pr[1];

    if (((mxGetM(prhs[4]) * mxGetN(prhs[4])) != 2) || !mxIsDouble(prhs[4]))
    {
        mexErrMsgTxt("STRIDE must be a 2-element double vector.");
    }
    pr = mxGetPr(prhs[4]);
    stride[0] = (int32) pr[0];
    stride[1] = (int32) pr[1];
    if ((stride[0] != 1) || (stride[1] != 1))
    {
        unit_strides = false;
    }

    if (((mxGetM(prhs[5]) * mxGetN(prhs[5])) != 2) || !mxIsDouble(prhs[5]))
    {
        mexErrMsgTxt("EDGE must be a 2-element double vector.");
    }
    pr = mxGetPr(prhs[5]);
    edge[0] = (int32) pr[0];
    edge[1] = (int32) pr[1];

    if (!mxIsNumeric(prhs[6]))
    {
        mexErrMsgTxt("DATA must be a numeric array.");
    }
    if (mxIsComplex(prhs[6]))
    {
        mexWarnMsgTxt("Ignoring imaginary part of DATA.");
    }

    arraydims = mxGetNumberOfDimensions(prhs[6]);
    if (arraydims > 3)
    {
        mexErrMsgTxt("DATA array should be 2-D or 3-D.");
    }
    arraysize = mxGetDimensions(prhs[6]);
    dim1 = arraysize[0];
    dim2 = arraysize[1];
    if (arraydims < 3)
    {
        dim3 = 1;
    }
    else
    {
        dim3 = arraysize[2];
    }

    /* Retrieve information about the raster image data set */
    status = GRgetiminfo(ri_id, ri_name, &ri_ncomp, &ri_data_type,
                         &ri_il, ri_dim_sizes, &ri_nattrs);
    if (status == FAIL)
    {
        mexErrMsgTxt("Invalid GR raster identifier.");
    }
    
    /* Interpretation of MATLAB array dimensions depends upon the
     * interlace of the raster image data set.  If the interlace
     * is PIXEL (0), the MATLAB array dimensions are interpreted
     * as ncomp-by-width-by-height.  If the interlace is LINE (1),
     * the MATLAB array dimensions are interpreted as 
     * width-by-ncomp-by-height.  If the interlace is COMPONENT (2),
     * the MATLAB array dimensions are interpreted as 
     * width-by-height-by-ncomp.
     */

    switch (ri_il)
    {
    case MFGR_INTERLACE_PIXEL:
        ncomp = dim1;
        width = dim2;
        height = dim3;
        break;

    case MFGR_INTERLACE_LINE:
        width = dim1;
        ncomp = dim2;
        height = dim3;
        break;

    case MFGR_INTERLACE_COMPONENT:
        width = dim1;
        height = dim2;
        ncomp = dim3;
        break;

    default:
        mexErrMsgTxt("Unknown interlace found in raster image data set.");
    }

    /* Make sure input data array is consistent with the */
    /* information already stored in the ri_id */
    if (ncomp != ri_ncomp)
    {
        mexErrMsgTxt("Number of components in DATA inconsistent with "
                     "raster image data set.");
    }
    data_type = haGetDataTypeFromClassID(mxGetClassID(prhs[6]));
    if (data_type != ri_data_type)
    {
        mexErrMsgTxt("DATA type is inconsistent with raster image data set.");
    }
    if (((start[0] + edge[0]) > width) ||
        ((start[1] + edge[1]) > height))
    {
        mexErrMsgTxt("DATA array is too small for given "
                     "START and EDGE values.");
    }

    data = mxGetData(prhs[6]);

    if (unit_strides)
    {
        /* HDF library reads with unit strides more efficiently
         * if you pass a NULL in for the stride vector
         */
        status = GRwriteimage(ri_id, start, NULL, edge, data);
    }
    else
    {
        status = GRwriteimage(ri_id, start, stride, edge, data);
    }

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGRwritelut
 *
 * Purpose: gateway to GRwritelut()
 *
 * MATLAB usage:
 * status = hdf('GR', 'writelut', pal_id, LUT, interlace)
 */
static void hdfGRwritelut(int nlhs,
                   mxArray *plhs[],
                   int nrhs,
                   const mxArray *prhs[])
{
    const mxArray *LUT;
    int32 il;
    int32 ncomp;
    int32 num_entries;
    const int *sizeLUT;
    int32 data_type;
    int32 pal_id;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    pal_id = (int32) haGetDoubleScalar(prhs[2], "Palette identifier");

    LUT = prhs[3];
    if (!mxIsNumeric(LUT))
    {
        mexErrMsgTxt("LUT must be a numeric array.");
    }
    sizeLUT = mxGetDimensions(LUT);
    data_type = haGetDataTypeFromClassID(mxGetClassID(LUT));
    
    il = haGetInterlaceFlag(prhs[4]);

    switch (il)
    {
    case MFGR_INTERLACE_PIXEL:
        ncomp = sizeLUT[0];
        num_entries = sizeLUT[1];
        break;

    case MFGR_INTERLACE_LINE:
        ncomp = sizeLUT[0];
        num_entries = sizeLUT[1];
        break;

    case MFGR_INTERLACE_COMPONENT:
        ncomp = sizeLUT[1];
        num_entries = sizeLUT[0];
        break;

    default:
        mexErrMsgTxt("Unrecognized or unsupported INTERLACE.");
    }

    status = GRwritelut(pal_id, ncomp, data_type, il, num_entries,
                        mxGetData(LUT));

    plhs[0] = haCreateDoubleScalar((double) status);
}



/*
 * hdfGR
 *
 * Purpose: Function switchyard for the GR part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which GR function to call
 * Outputs: none
 * Return:  none
 */
void hdfGR(int nlhs,
           mxArray *plhs[],
           int nrhs,
           const mxArray *prhs[],
           char *functionStr
           )
{
    void (*func)(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[]);

    if (strcmp(functionStr, "attrinfo") == 0)
    {
        func = hdfGRattrinfo;
    }
    else if (strcmp(functionStr, "create") == 0)
    {
        func = hdfGRcreate;
    }
    else if (strcmp(functionStr, "end") == 0)
    {
        func = hdfGRend;
    }
    else if (strcmp(functionStr, "endaccess") == 0)
    {
        func = hdfGRendaccess;
    }
    else if (strcmp(functionStr, "fileinfo") == 0)
    {
        func = hdfGRfileinfo;
    }
    else if (strcmp(functionStr, "findattr") == 0)
    {
        func = hdfGRfindattr;
    }
    else if (strcmp(functionStr, "getattr") == 0)
    {
        func = hdfGRgetattr;
    }
    else if (strcmp(functionStr, "getiminfo") == 0)
    {
        func = hdfGRgetiminfo;
    }
    else if (strcmp(functionStr, "getlutid") == 0)
    {
        func = hdfGRgetlutid;
    }
    else if (strcmp(functionStr, "getlutinfo") == 0)
    {
        func = hdfGRgetlutinfo;
    }
    else if (strcmp(functionStr, "idtoref") == 0)
    {
        func = hdfGRidtoref;
    }
    else if (strcmp(functionStr, "nametoindex") == 0)
    {
        func = hdfGRnametoindex;
    }
    else if (strcmp(functionStr, "readimage") == 0)
    {
        func = hdfGRreadimage;
    }
    else if (strcmp(functionStr, "readlut") == 0)
    {
        func = hdfGRreadlut;
    }
    else if (strcmp(functionStr, "reftoindex") == 0)
    {
        func = hdfGRreftoindex;
    }
    else if (strcmp(functionStr, "reqimageil") == 0)
    {
        func = hdfGRreqimageil;
    }
    else if (strcmp(functionStr, "reqlutil") == 0)
    {
        func = hdfGRreqlutil;
    }
    else if (strcmp(functionStr, "select") == 0)
    {
        func = hdfGRselect;
    }
    else if (strcmp(functionStr, "setaccesstype") == 0)
    {
        func = hdfGRsetaccesstype;
    }
    else if (strcmp(functionStr, "setattr") == 0)
    {
        func = hdfGRsetattr;
    }
    else if (strcmp(functionStr, "setcompress") == 0)
    {
        func = hdfGRsetcompress;
    }
    else if (strcmp(functionStr, "setexternalfile") == 0)
    {
        func = hdfGRsetexternalfile;
    }
    else if (strcmp(functionStr, "start") == 0)
    {
        func = hdfGRstart;
    }
    else if (strcmp(functionStr, "writeimage") == 0)
    {
        func = hdfGRwriteimage;
    }
    else if (strcmp(functionStr, "writelut") == 0)
    {
        func = hdfGRwritelut;
    }
    else
    {
        mexErrMsgTxt("Unknown HDF GR interface function.");
    }

    (*func)(nlhs, plhs, nrhs, prhs);
}
#else
void hdfGR(int nlhs,
           mxArray *plhs[],
           int nrhs,
           const mxArray *prhs[],
           char *functionStr
           )
{
    /* stub */
}
#endif /* USE_GR */
