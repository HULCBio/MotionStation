/*
 * cdfreadc.c
 *
 * Returns data from a CDF (Common Data Format) file.
 *
 * Calls the CDF library which is distributed by the National Space Science
 * Data Center and available from
 * ftp://nssdcftp.gsfc.nasa.gov/standards/cdf/dist/cdf27/unix/cdf27-dist-all.tar.gz 
 * 
 * Copyright 1984-2001 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:47 $
 */


#include "mex.h"
#include "cdf.h"
#include "cdfutils.h"
#include <string.h>

mxArray * read_variable(const mxArray *, const mxArray *);
mxArray * read_numeric_record(const mxArray *);
mxArray * read_string_record(const mxArray *);


void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[] )

{

    CDFid fid;
    CDFstatus success;

    const mxArray *records, *slices;

    char *filename;
    char *var_name;
    char err_text[CDF_STATUSTEXT_LEN + 1];

 
    if (nrhs != 4) {
        mexErrMsgTxt("Incorrect number of input arguments.");
    } else if (nlhs > 1) {
	mexErrMsgTxt("Too many output arguments."); 
    } 

    /* prhs[0] - filename */
    filename = (char *) mxMalloc((CDF_PATHNAME_LEN + 1) * sizeof(char));
    if (filename == NULL)
        mexErrMsgTxt("Couldn't allocate space for filename buffer.");

    if ((!mxIsChar(prhs[0])) || 
        (mxGetString(prhs[0], filename, (CDF_PATHNAME_LEN + 1)))) {

        mexErrMsgTxt("Invalid file name.");

    }

    /* prhs[1] - Variable name */
    var_name = (char *) mxMalloc((CDF_VAR_NAME_LEN + 1) * sizeof(char));
    if (var_name == NULL)
        mexErrMsgTxt("Couldn't allocate space for variable name buffer.");
    
    if ((!mxIsChar(prhs[1])) || 
        (mxGetString(prhs[1], var_name, (CDF_VAR_NAME_LEN + 1)))) {
        
        mexErrMsgTxt("Invalid variable name.");
        
    }

    /* prhs[2] - Records */
    if (!mxIsDouble(prhs[2]))
        mexErrMsgTxt("Record values must be a vector of doubles.");
    else
        records = prhs[2];

    /* prhs[3] - Slices */
    slices = prhs[3];

    if ((!mxIsDouble(slices)) || (mxGetN(slices) != 3))
        mexErrMsgTxt("Slice values must be an m-by-3 array of doubles.");


    /* Open CDF. */
    success = CDFlib(OPEN_, CDF_, filename, &fid,
                     SELECT_, CDF_zMODE_, zMODEon2,
                     NULL_);

    if (success < CDF_WARN) {

        /* Don't call the msg_handler routine because it isn't necessary to
         * to close the file. */
        CDFlib(SELECT_, CDF_STATUS_, success,
               GET_, STATUS_TEXT_, err_text,
               NULL_);
        mexErrMsgTxt(err_text);

    } else if (success != CDF_OK) {

        msg_handler(success);

    }


    /* Select variable. */
    success = CDFlib(SELECT_, zVAR_NAME_, var_name,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);


    /* Read the variable. */
    plhs[0] = read_variable(records, slices);


    /* Close CDF. */
    success = CDFlib(CLOSE_, CDF_, NULL_);
    

    /* Clean up. */
    mxFree(filename);
    mxFree(var_name);

}


mxArray * read_variable(const mxArray *rec_nums, const mxArray *slices) {

    CDFstatus success;

    mxArray *record, *variable;

    double num_records, *p_rec_nums;
    long data_type;
    long p;

    num_records = ((mxGetM(rec_nums) > 1) ? mxGetM(rec_nums) 
                                          : mxGetN(rec_nums));

    /* Create output array. */
    variable = mxCreateCellMatrix((int) num_records, 1);

    /* Get the data. */
    p_rec_nums = mxGetPr(rec_nums);
    for (p = 0; p < num_records; p++) {

        success = CDFlib(SELECT_, zVAR_RECNUMBER_, ((long) (p_rec_nums[p])),
                         GET_, zVAR_DATATYPE_, &data_type,
                         NULL_);

        if (success != CDF_OK)
            msg_handler(success);

        if ((data_type == CDF_CHAR) || (data_type == CDF_UCHAR))
            record = read_string_record(slices);
        else
            record = read_numeric_record(slices);

        mxSetCell(variable, p, record);

    }

    return variable;

}


mxArray * read_numeric_record(const mxArray *slices) {

    CDFstatus success;

    long cdf_dims, *dim_indices, *dim_counts, *dim_intervals;
    int *mx_dim_counts;
    long data_type, num_elems, num_bytes;
    long majority;
    mxClassID classID;
    mxArray *mcm_prhs[2], *mcm_plhs[1];
    double *pr_mcm_prhs, *pr_slices;
    long tmp;
    long p;

    char *err_msg;
    void *data;
    mxArray *out;
    
    
    /* Get record details. */
    success = CDFlib(GET_, zVAR_NUMDIMS_, &cdf_dims,
                     GET_, zVAR_DATATYPE_, &data_type,
                     GET_, CDF_MAJORITY_, &majority,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);


    /* Get ready for a hyper read. */
    if (cdf_dims != 0) {

        /* Get values from slices mxArray. */
        pr_slices = mxGetPr(slices);

        dim_indices   = (long *) mxMalloc(cdf_dims * sizeof(long));
        dim_intervals = (long *) mxMalloc(cdf_dims * sizeof(long));
        dim_counts    = (long *) mxMalloc(cdf_dims * sizeof(long));
        mx_dim_counts = (int  *) mxMalloc(cdf_dims * sizeof(int));
        
        for (p = 0; p < cdf_dims; p++) {
            dim_indices[p]   = (long) pr_slices[p];
            dim_intervals[p] = (long) pr_slices[p + cdf_dims];
            dim_counts[p]    = (long) pr_slices[p + 2*cdf_dims];
        }

    } else {

        /* Scalar. */
        dim_indices   = (long *) mxMalloc(sizeof(long));
        dim_intervals = (long *) mxMalloc(sizeof(long));
        dim_counts    = (long *) mxMalloc(sizeof(long));
        mx_dim_counts = (int  *) mxMalloc(sizeof(int));

        dim_indices[0]   = 0;
        dim_intervals[0] = 1;
        dim_counts[0]    = 1;
        mx_dim_counts[0] = 1;

    }

    success = CDFlib(SELECT_, zVAR_RECINTERVAL_, 1,
                     SELECT_, zVAR_RECCOUNT_, 1,
                     SELECT_, zVAR_DIMINDICES_, dim_indices,
                     SELECT_, zVAR_DIMINTERVALS_, dim_intervals,
                     SELECT_, zVAR_DIMCOUNTS_, dim_counts,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);


    /* Create a container for the output. */
    success = CDFlib(GET_, DATATYPE_SIZE_, data_type, &num_bytes,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);

    /* Calculate the number of values. */
    num_elems = 1;
    for (p = 0; p < cdf_dims; p++)
        num_elems *= dim_counts[p];

    /* In row major mode, the data will be stored in opposite dimension
     * order from how MATLAB expects it.  Change the dim_counts array to
     * reflect this.
     *
     * This will be used when the mxArray is created.  */
    if (majority == ROW_MAJOR)
        for (p = 0; p < (cdf_dims/2); p++) {

            tmp = dim_counts[p];
            dim_counts[p] = dim_counts[(cdf_dims - p - 1)];
            dim_counts[(cdf_dims - p - 1)] = tmp;

        }
    
    /* Convert CDF storage class to mxArray classID. */
    switch (data_type) {
    case CDF_INT1:
    case CDF_BYTE:
        classID = mxINT8_CLASS;
        break;
        
    case CDF_UINT1:
        classID = mxUINT8_CLASS;
        break;
        
    case CDF_INT2:
        classID = mxINT16_CLASS;
        break;
        
    case CDF_UINT2:
        classID = mxUINT16_CLASS;
        break;
        
    case CDF_INT4:
        classID = mxINT32_CLASS;
        break;
        
    case CDF_UINT4:
        classID = mxUINT32_CLASS;
        break;

    case CDF_REAL4:
    case CDF_FLOAT:
        classID = mxSINGLE_CLASS;
        break;
        
    case CDF_REAL8:
    case CDF_DOUBLE:
    case CDF_EPOCH:
        classID = mxDOUBLE_CLASS;
        break;
        
    default:
        CDFlib(CLOSE_, CDF_, NULL_);
        
        err_msg = (char *) mxMalloc(40 * sizeof(char));
        sprintf(err_msg, "Unknown data format (%ld).\n", data_type);
        mexErrMsgTxt(err_msg);
        break;
    }

    
    /* Create the output array. */
    for (p = 0; p < cdf_dims; p++)
        mx_dim_counts[p] = (int) (dim_counts[p]);

    if (cdf_dims == 0) {
        mx_dim_counts[0] = dim_counts[0] = 1;
        out = mxCreateNumericArray(1, mx_dim_counts, classID, mxREAL);
    } else {
        out = mxCreateNumericArray(cdf_dims, mx_dim_counts, classID, mxREAL);
    }


    /* Read the data. */
    data = mxGetData(out);
    success = CDFlib(GET_, zVAR_HYPERDATA_, data,
                     NULL_); 
    
    if (success != CDF_OK)
        msg_handler(success);


    /* Permute the arrays if necessary. */
    if ((majority == ROW_MAJOR) && (cdf_dims > 1)) {

        mcm_prhs[0] = out;
        mcm_prhs[1] = mxCreateDoubleMatrix(1, cdf_dims, mxREAL);
        pr_mcm_prhs = mxGetPr(mcm_prhs[1]);

        /* Create the new dimension order: ndims(out):-1:1. */
        for (p = 0; p < cdf_dims; p++)
            pr_mcm_prhs[p] = (cdf_dims - p);

        mexCallMATLAB(1, mcm_plhs, 2, mcm_prhs, "permute");
        mxDestroyArray(out);
        out = mcm_plhs[0];

    }


    /* Clean up. */
    mxFree(dim_indices);
    mxFree(dim_intervals);
    mxFree(dim_counts);
    mxFree(mx_dim_counts);

    return out;

}


mxArray * read_string_record(const mxArray *slices) {

    CDFstatus success;

    long cdf_dims, *dim_indices, *dim_counts, *dim_intervals;
    long data_type, num_elems, num_bytes, prod_sizes;
    long majority;
    long p;

    int mx_num_dims, mx_dim_sizes[CDF_MAX_DIMS + 1];
    int tmp;
    mxArray *mcm_prhs[2], *mcm_plhs[1];
    double *pr_mcm_prhs, *pr_slices;

    char *data;
    mxChar *p_data;
    mxArray *out;
    
    
    /* Get record details. */
    success = CDFlib(GET_, zVAR_NUMDIMS_, &cdf_dims,
                     GET_, zVAR_DATATYPE_, &data_type,
                     GET_, zVAR_NUMELEMS_, &num_elems,
                     GET_, CDF_MAJORITY_, &majority,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);


    /* Get ready for a hyper read. */
    if (cdf_dims != 0) {
        
        /* Get values from slices mxArray. */
        pr_slices = mxGetPr(slices);

        dim_indices   = (long *) mxMalloc(cdf_dims * sizeof(long));
        dim_intervals = (long *) mxMalloc(cdf_dims * sizeof(long));
        dim_counts    = (long *) mxMalloc(cdf_dims * sizeof(long));

        for (p = 0; p < cdf_dims; p++) {
            dim_indices[p]   = (long) pr_slices[p];
            dim_intervals[p] = (long) pr_slices[p + cdf_dims];
            dim_counts[p]    = (long) pr_slices[p + 2*cdf_dims];
        }

    } else {

        /* Scalar. */
        dim_indices   = mxMalloc(sizeof(long));
        dim_intervals = mxMalloc(sizeof(long));
        dim_counts    = mxMalloc(sizeof(long));

        dim_indices[0]   = 0;
        dim_intervals[0] = 1;
        dim_counts[0]    = 1;

    }

    success = CDFlib(SELECT_, zVAR_RECCOUNT_, 1,
                     SELECT_, zVAR_RECINTERVAL_, 1,
                     SELECT_, zVAR_DIMINDICES_, dim_indices,
                     SELECT_, zVAR_DIMINTERVALS_, dim_intervals,
                     SELECT_, zVAR_DIMCOUNTS_, dim_counts,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);


    /* Create a container for the output. */
    /* For character types, the number of elements for a given hyper read
     * is (num_elems * prod(dim_counts(:))). */
    success = CDFlib(GET_, DATATYPE_SIZE_, data_type, &num_bytes,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);

    prod_sizes = 1;
    for (p = 0; p < cdf_dims; p++)
        prod_sizes *= dim_counts[p];

    data = (char *) mxMalloc(num_bytes * num_elems * prod_sizes);


    /* Read the data. */
    success = CDFlib(GET_, zVAR_HYPERDATA_, data,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);

    
    /* Create the output string. */
    mx_num_dims = (int) cdf_dims + 1;

    if (cdf_dims == 0)
    {
        mx_num_dims = 2;
        mx_dim_sizes[0] = 1;
        mx_dim_sizes[1] = (int) num_elems;
        
        out = mxCreateCharArray(mx_num_dims, mx_dim_sizes);
        p_data = (mxChar *) mxGetData(out);
        
        /* CDF stores chars with one byte, while MATLAB stores them with
         * two.  Expand the char buffer before assigning to the mxArray. */
        for (p = 0; p < (prod_sizes * num_elems); p++)
            p_data[p] = (mxChar) (data[p]);
        
        mcm_prhs[0] = out;
        
    } else if ((majority == ROW_MAJOR) && (cdf_dims > 0)) {

        /* Before creating the character mxArray, get the correct dimension
         * values.  The CDF library always gives the dimension value as one
         * less than we expect it, and (in row major mode) the last
         * dimension is expressed in the num_elems value. */
        for (p = 0; p < cdf_dims; p++)
            mx_dim_sizes[p] = (int) (dim_counts[p]);

        mx_dim_sizes[p] = (int) num_elems;

        
        out = mxCreateCharArray(mx_num_dims, mx_dim_sizes);
        p_data = (mxChar *) mxGetData(out);

        /* CDF stores chars with one byte, while MATLAB stores them with
         * two.  Expand the char buffer before assigning to the mxArray. */
        for (p = 0; p < (prod_sizes * num_elems); p++)
            p_data[p] = (mxChar) (data[p]);

        mcm_prhs[0] = out;

        /* Reshape the CDF data to reflect how it is actually stored. */
        for (p = 0; p < (mx_num_dims/2); p++) {

            tmp = mx_dim_sizes[p];
            mx_dim_sizes[p] = mx_dim_sizes[mx_num_dims - p - 1];
            mx_dim_sizes[mx_num_dims - p - 1] = tmp;

        }

        mxSetDimensions(out, mx_dim_sizes, mx_num_dims);

        /* Create the new dimension order: 
         *   [ndims(out), 1, (ndims(out) - 1):-1:2]. */
        mcm_prhs[1] = mxCreateDoubleMatrix(1, mx_num_dims, mxREAL);

        pr_mcm_prhs = mxGetPr(mcm_prhs[1]);
        pr_mcm_prhs[0] = mx_num_dims;
        pr_mcm_prhs[1] = 1;

        for (p = 2; p < mx_num_dims; p++)
            pr_mcm_prhs[p] = (mx_num_dims - p + 1);

        /* Permute. */
        mexCallMATLAB(1, mcm_plhs, 2, mcm_prhs, "permute");

        mxDestroyArray(out);
        out = mcm_plhs[0];

    } else if ((majority == COLUMN_MAJOR) && (cdf_dims > 0)) {

        /* In column major mode, it suffices to reshape the data as it is
         * represented in memory and then permute the first two
         * dimensions. */

        mx_dim_sizes[0] = (int) num_elems;
        
        for (p = 1; p <= cdf_dims; p++)
            mx_dim_sizes[p] = (int) (dim_counts[p - 1]);

        
        out = mxCreateCharArray(mx_num_dims, mx_dim_sizes);
        p_data = (mxChar *) mxGetData(out);

        /* CDF stores chars with one byte, while MATLAB stores them with
         * two.  Expand the char buffer before assigning to the mxArray. */
        for (p = 0; p < (prod_sizes * num_elems); p++)
            p_data[p] = (mxChar) (data[p]);

        mcm_prhs[0] = out;

        /* Create the new dimension order: 
         *   [2, 1, 3:ndims(out)]. */
        mcm_prhs[1] = mxCreateDoubleMatrix(1, mx_num_dims, mxREAL);

        pr_mcm_prhs = mxGetPr(mcm_prhs[1]);
        pr_mcm_prhs[0] = 2;
        pr_mcm_prhs[1] = 1;

        for (p = 2; p < mx_num_dims; p++)
            pr_mcm_prhs[p] = (p + 1);

        /* Permute. */
        mexCallMATLAB(1, mcm_plhs, 2, mcm_prhs, "permute");

        mxDestroyArray(out);
        out = mcm_plhs[0];

    } 


    /* Clean up. */
    mxFree(dim_indices);
    mxFree(dim_intervals);
    mxFree(dim_counts);

    return out;

}


