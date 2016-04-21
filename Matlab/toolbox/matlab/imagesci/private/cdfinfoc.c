/*
 * cdfinfoc.c
 *
 * Returns information about a CDF (Common Data Format) file.
 *
 * Calls the CDF library which is distributed by the National Space Science
 * Data Center and available from
 * ftp://nssdcftp.gsfc.nasa.gov/standards/cdf/dist/cdf27/unix/cdf27-dist-all.tar.gz 
 * 
 * Copyright 1984-2001 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:46 $
 */


#include "mex.h"
#include "cdf.h"
#include "cdfutils.h"
#include <string.h>

#define GLOBAL 0
#define VARIABLE 1
#define MAX_ML_FIELDNAME  (mxMAXNAM-1)

const char **   get_attr_names(long, long, int);
mxArray * get_cdf_props(void);
mxArray * get_entries(const char *, int);
mxArray * get_entry_data(int, long, long);
mxArray * get_global_attrs(void);
mxArray * get_var_attrs(void);
mxArray * get_var_details(void);
char *    translate_attr_name(char *, int);
void      int_to_str(int, char *);


void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[] )

{

    CDFid fid;
    CDFstatus success;

    char *filename;

    char err_text[CDF_STATUSTEXT_LEN + 1];

    mxArray *info;
    mxArray *cdf_props, *var_names, *g_attrs, *v_attrs;

    const char *info_fields[] = {"File",
                                 "Variables",
                                 "GlobalAttributes",
                                 "VariableAttributes"};


    if (nrhs != 1) {
	mexErrMsgTxt("One input argument required."); 
    } else if (nlhs > 1) {
	mexErrMsgTxt("Too many output arguments."); 
    } 

    /* Note: mxGetString returns 0 for success! */

    /* prhs[0] - filename */
    filename = (char *) mxMalloc((CDF_PATHNAME_LEN + 1) * sizeof(char));

    if ((!mxIsChar(prhs[0])) || 
        (mxGetString(prhs[0], filename, (CDF_PATHNAME_LEN + 1)))) {

        mexErrMsgTxt("Invalid file name.");

    }


    /* Open CDF. */
    success = CDFlib(OPEN_, CDF_, filename, &fid,
                     SELECT_, CDF_zMODE_, zMODEon2,
                     NULL_);

    mxFree(filename);

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


    /* Create structure for output. */
    info = mxCreateStructMatrix(1, 1, 4, info_fields);


    /* Read CDF file properties. */
    cdf_props = get_cdf_props();
    mxSetField(info, 0, "File", cdf_props);


    /* Get list of variables. */
    var_names = get_var_details();
    mxSetField(info, 0, "Variables", var_names);

    
    /* Read attributes. */
    g_attrs = get_global_attrs();
    v_attrs = get_var_attrs();

    mxSetField(info, 0, "GlobalAttributes", g_attrs);
    mxSetField(info, 0, "VariableAttributes", v_attrs);


    /* Close CDF. */
    success = CDFlib(CLOSE_, CDF_,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);


    plhs[0] = info;

}


mxArray * get_cdf_props(void) {

    CDFstatus success;

    mxArray *cdf_props;

    long comp_type = 0;
    long comp_pct = 0;
    long comp_parm[CDF_MAX_PARMS];
    long encoding = 0;
    long format= 0;
    long increment = 0;
    long majority = 0;
    long release = 0;
    long version = 0;

    int p;

    char *buf;

    const char *cdf_fields[] = {"Version",
                                "Release",
                                "Increment",
                                "Format",
                                "Compression",
                                "CompressionParam",
                                "CompressionPercent",
                                "Encoding",
                                "Majority",
                                "Copyright"};


    /* Create structure for metadata. */
    cdf_props = mxCreateStructMatrix(1, 1, 10, cdf_fields);
    buf = (char *) mxMalloc((CDF_COPYRIGHT_LEN + 1) * sizeof(char));

    /* Initialize buffer to hold the CDF parameters. */
    for (p = 0; p < CDF_MAX_PARMS; p++)
        comp_parm[p] = 0;

    /* Get the properties. */
    success = CDFlib(GET_, CDF_COMPRESSION_, &comp_type, comp_parm, &comp_pct,
                     GET_, CDF_COPYRIGHT_, buf,
                     GET_, CDF_ENCODING_, &encoding,
                     GET_, CDF_FORMAT_, &format,
                     GET_, CDF_INCREMENT_, &increment,
                     GET_, CDF_MAJORITY_, &majority,
                     GET_, CDF_RELEASE_, &release,
                     GET_, CDF_VERSION_, &version,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);


    /* Assign the properties to the output structure. */
    mxSetField(cdf_props, 0, "Compression", mxCreateScalarDouble(comp_type));
    mxSetField(cdf_props, 0, "CompressionParam", mxCreateScalarDouble(comp_parm[0]));
    mxSetField(cdf_props, 0, "CompressionPercent", mxCreateScalarDouble(comp_pct));
    mxSetField(cdf_props, 0, "Copyright", mxCreateString(buf));
    mxSetField(cdf_props, 0, "Encoding", mxCreateScalarDouble(encoding));
    mxSetField(cdf_props, 0, "Format", mxCreateScalarDouble(format));
    mxSetField(cdf_props, 0, "Increment", mxCreateScalarDouble(increment));
    mxSetField(cdf_props, 0, "Majority", mxCreateScalarDouble(majority));
    mxSetField(cdf_props, 0, "Release", mxCreateScalarDouble(release));
    mxSetField(cdf_props, 0, "Version", mxCreateScalarDouble(version));

    /* Clean up. */
    mxFree(buf);
    return cdf_props;
    
}


mxArray * get_var_details(void) {
    
    CDFstatus success;
    
    mxArray *cell;
    int NUM_COLS = 6;  /* Cell array columns. */

    mxArray *sizes;
    
    long num_vars;
    long datatype;
    long num_dims, dim_sizes[CDF_MAX_DIMS], dim_vary[CDF_MAX_DIMS];
    long num_rec, rec_vary;
    long sparse_rec;

    long p;
    int q;
    
    char *name;
    char vary_str[CDF_MAX_DIMS + 3];
    double *pr;

    /* Create a container for the output. */
    success = CDFlib(GET_, CDF_NUMzVARS_, &num_vars,
                     NULL_);
    
    if (success != CDF_OK)
        msg_handler(success);

    cell = mxCreateCellMatrix(num_vars, NUM_COLS);

    name = (char *) mxMalloc((CDF_VAR_NAME_LEN + 1) * sizeof(char));

 
    /* Get zVariable properties. */
    for (p = 0; p < num_vars; p++) {

        success = CDFlib(SELECT_, zVAR_, p,
                         GET_, zVAR_DATATYPE_, &datatype,
                         GET_, zVAR_DIMSIZES_, dim_sizes,
                         GET_, zVAR_DIMVARYS_, dim_vary,
                         GET_, zVAR_NAME_, name,
                         GET_, zVAR_NUMDIMS_, &num_dims,
                         GET_, zVAR_NUMRECS_, &num_rec,
                         GET_, zVAR_RECVARY_, &rec_vary,
                         GET_, zVAR_SPARSERECORDS_, &sparse_rec,
                         NULL_);

        if (success != CDF_OK)
            msg_handler(success);


        /* Process sizes. */
        sizes = mxCreateDoubleMatrix(1, ((num_dims > 1) ? num_dims : 2), mxREAL);
        pr = mxGetPr(sizes);
        for (q = 0; q < num_dims; q++)
            pr[q] = dim_sizes[q];
        
        if (num_dims == 0) {
            pr[0] = 1;
            pr[1] = 1;
        } else if (num_dims == 1)
            pr[1] = 1;

        /* Process Variances. */
        vary_str[0] = ((rec_vary == VARY) ? 'T' : 'F');
        vary_str[1] = '/';

        for (q = 0; q < num_dims; q++)
            vary_str[q + 2] = ((dim_vary[q] == VARY) ? 'T' : 'F');

        vary_str[q + 2] = 0;


        /* Assign data to cell array. */
        mxSetCell(cell, p, mxCreateString(name));
        mxSetCell(cell, num_vars + p, sizes);
        mxSetCell(cell, num_vars*2 + p, mxCreateScalarDouble(num_rec));
        mxSetCell(cell, num_vars*3 + p, mxCreateScalarDouble(datatype));
        mxSetCell(cell, num_vars*4 + p, mxCreateString(vary_str));
        mxSetCell(cell, num_vars*5 + p, mxCreateScalarDouble(sparse_rec));

    }

    mxFree(name);
    return cell;
   
}


mxArray * get_global_attrs(void) {

    CDFstatus success;
    
    mxArray *g_attrs, *values;

    int NUM_COLS = 2;
    const char **names;
    char real_name[CDF_ATTR_NAME_LEN + 1];
    long num_gAttrs, num_vAttrs;
    long num_gEntries;

    long p, count;

    success = CDFlib(GET_, CDF_NUMgATTRS_, &num_gAttrs,
                     GET_, CDF_NUMvATTRS_, &num_vAttrs,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);

    if (num_gAttrs < 1)
        return mxCreateStructMatrix(0, 0, 0, NULL);

    /* Find MATLAB-recognizable names for attributes. */
    names = get_attr_names((num_gAttrs + num_vAttrs), num_gAttrs, GLOBAL);
    
    /* Create a container for the attributes. */
    g_attrs = mxCreateStructMatrix(1, 1, num_gAttrs, names);

    /* Get each of the attributes. */
    count = 0;
    for (p = 0; p < (num_gAttrs + num_vAttrs); p++) {

        /* Determine if the current attribute number is gAttr or vAttr. */
        success = CDFlib(SELECT_, ATTR_, p,
                         GET_, ATTR_NUMgENTRIES_, &num_gEntries,
                         GET_, ATTR_NAME_, real_name,
                         NULL_);

        if (success == ILLEGAL_FOR_SCOPE)
            continue;
        else if (success != CDF_OK)
            msg_handler(success);


        /* Get the entries. */
        values = get_entries(real_name, GLOBAL);
        mxSetField(g_attrs, 0, names[count++], values);

    }

    return g_attrs;
    
}


mxArray * get_var_attrs(void) {

    CDFstatus success;
    
    mxArray *v_attrs, *values;

    int NUM_COLS = 2;
    const char **names;
    char real_name[CDF_ATTR_NAME_LEN + 1];
    long num_gAttrs, num_vAttrs;
    long num_zEntries;

    long p, count;

    success = CDFlib(GET_, CDF_NUMgATTRS_, &num_gAttrs,
                     GET_, CDF_NUMvATTRS_, &num_vAttrs,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);

    if (num_vAttrs < 1)
        return mxCreateStructMatrix(0, 0, 0, NULL);

    /* Find MATLAB-recognizable names for attributes. */
    names = get_attr_names((num_gAttrs + num_vAttrs), num_vAttrs, VARIABLE);

    /* Create a container for the attributes. */
    v_attrs = mxCreateStructMatrix(1, 1, num_vAttrs, names);

    /* Get each of the attributes. */
    count = 0;
    for (p = 0; p < (num_vAttrs + num_gAttrs); p++) {

        /* Determine if the current attribute number is gAttr or vAttr. */
        success = CDFlib(SELECT_, ATTR_, p,
                         GET_, ATTR_NUMzENTRIES_, &num_zEntries,
                         GET_, ATTR_NAME_, real_name,
                         NULL_);

        if (success == ILLEGAL_FOR_SCOPE)
            continue;
        else if (success != CDF_OK)
            msg_handler(success);

        /* Get the entries. */
        values = get_entries(real_name, VARIABLE);
        mxSetField(v_attrs, 0, names[count++], values);

    }

    return v_attrs;

}

const char ** get_attr_names(long total_attrs, long num_attrs, int attr_type) {
    
    CDFstatus success;
    
    const char **names;
    char *buf;

    long num_gEntries;
    long p, count;


    /* Create a buffer for the variables as they are read. */
    names = (const char **) mxMalloc(num_attrs * sizeof(char *));
    buf = (char *) mxMalloc((CDF_VAR_NAME_LEN + 1) * sizeof(char));

    if ((buf == NULL) || (names == NULL)) {
        CDFlib(CLOSE_, CDF_, NULL_);
        mexErrMsgTxt("Couldn't create buffer for variable names.\n");
    }

    count = 0;
    for (p = 0; p < total_attrs; p++) {

        /* Pick the next attribute. */
        success = CDFlib(SELECT_, ATTR_, p,
                         GET_, ATTR_NAME_, buf,
                         NULL_);

        if (success != CDF_OK)
            msg_handler(success);

        /* Determine if it is a global attribute. */
        num_gEntries = 0;
        success = CDFlib(GET_, ATTR_NUMgENTRIES_, &num_gEntries,
                         NULL_);

        /* Modify name as appropriate and assign it. */
        if (success == ILLEGAL_FOR_SCOPE) {

            if (attr_type == VARIABLE)
                names[count++] = translate_attr_name(buf, VARIABLE);

        } else if (success == CDF_OK) {

            if (attr_type == GLOBAL)
                names[count++] = translate_attr_name(buf, GLOBAL);

        } else {

            msg_handler(success);

        }

   }

    mxFree(buf);

    return names;
}


mxArray * get_entries(const char *name, int attr_type) {

    CDFstatus success;

    mxArray *value;

    long num_entries, max_entry;
    long data_type, num_elts;
    long p, count;

    char *buf;


    /* Select attribute. */
    success = CDFlib(SELECT_, ATTR_NAME_, name,
                     NULL_);

    if (success != CDF_OK)
        msg_handler(success);


    /* Find number of entries and create a cell array for the output. */
    if (attr_type == GLOBAL) {

        success = CDFlib(GET_, ATTR_NUMgENTRIES_, &num_entries,
                         GET_, ATTR_MAXgENTRY_, &max_entry,
                         NULL_);

        if (success != CDF_OK)
            msg_handler(success);

        value = mxCreateCellMatrix(num_entries, 1);
        
    } else {

        success = CDFlib(GET_, ATTR_NUMzENTRIES_, &num_entries,
                         GET_, ATTR_MAXzENTRY_, &max_entry,
                         NULL_);

        if (success != CDF_OK)
            msg_handler(success);

        value = mxCreateCellMatrix(num_entries, 2);

    }

    
    /* Get the entry values. */
    if (attr_type == GLOBAL) {

        count = 0;
        for (p = 0; p <= max_entry; p++) {
            
            /* Look for the next entry. */
            success = CDFlib(SELECT_, gENTRY_, p,
                             CONFIRM_, gENTRY_EXISTENCE_, p,
                             NULL_);
            
            if (success == NO_SUCH_ENTRY)
                continue;
            else if (success != CDF_OK)
                msg_handler(success);
            
            /* Get the data from the entry. */
            success = CDFlib(GET_, gENTRY_DATATYPE_, &data_type,
                             GET_, gENTRY_NUMELEMS_, &num_elts,
                             NULL_);

            if (success != CDF_OK)
                msg_handler(success);

            mxSetCell(value, count, get_entry_data(GLOBAL,
                                                   data_type, num_elts));

            count++;

        }
            
    } else {

        /* Create a buffer for variable names. */
        buf = (char *) mxMalloc((CDF_VAR_NAME_LEN + 1) * sizeof(char));

        count = 0;
        for (p = 0; p <= max_entry; p++) {

            /* Look for the next entry. */
            success = CDFlib(SELECT_, zENTRY_, p,
                             CONFIRM_, zENTRY_EXISTENCE_, p,
                             NULL_);
            
            if (success == NO_SUCH_ENTRY)
                continue;
            else if (success != CDF_OK)
                msg_handler(success);
            
            /* Get the data from the entry. */
            success = CDFlib(GET_, zENTRY_DATATYPE_, &data_type,
                             GET_, zENTRY_NUMELEMS_, &num_elts,
                             NULL_);

            if (success != CDF_OK)
                msg_handler(success);

            /* Get the name of the current variable.
             *
             * "p" is the number of the variable in the CDF that
             * corresponds to the current entry (i.e. the entry with value
             * 3 describes the variable with value 3). */
            success = CDFlib(SELECT_, zVAR_, p,
                             GET_, zVAR_NAME_, buf,
                             NULL_);

            if (success != CDF_OK)
                msg_handler(success);

            /* Set the cells to have the MATLAB name and the entry. */
            mxSetCell(value, count, mxCreateString(buf));
            mxSetCell(value, (num_entries + count), 
                      get_entry_data(VARIABLE, data_type, num_elts));

            count++;

        }

        mxFree(buf);

    }

    return value;
}

mxArray * get_entry_data(int attr_type, long data_type, long num_elts) {

    CDFstatus success;

    mxArray *out;

    long num_bytes;
    mxClassID classID;

    char *err_msg;
    void *buf;


    /* Find size of the data. */
    CDFlib(GET_, DATATYPE_SIZE_, data_type, &num_bytes,
           NULL_);
    
    /* Convert CDF storage class to mxArray class. */
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
        classID = mxDOUBLE_CLASS;
        break;
        
    case CDF_EPOCH:
        /* Send EPOCH data back as strings. */
        classID = mxCHAR_CLASS;
        break;

    case CDF_CHAR:
    case CDF_UCHAR:
        break;
        
    default:
        CDFlib(CLOSE_, CDF_, NULL_);
        
        err_msg = (char *) mxMalloc(40 * sizeof(char));
        sprintf(err_msg, "Unknown data format (%ld).\n", data_type);
        mexErrMsgTxt(err_msg);
        break;
    }
    
    /* Read the elements. */
    switch (data_type) {
    case CDF_CHAR:
    case CDF_UCHAR:

        /* Character arrays must have an extra element for EOS. */
        buf = (char *) mxMalloc((num_elts + 1) * num_bytes);

        if (attr_type == GLOBAL)
            success = CDFlib(GET_, gENTRY_DATA_, buf,
                             NULL_);
        else
            success = CDFlib(GET_, zENTRY_DATA_, buf,
                             NULL_);

        if (success != CDF_OK)
            msg_handler(success);
        
        ((char *) buf)[num_elts] = '\0';
        
        out = mxCreateString(buf);
        break;

    case CDF_EPOCH:

        buf = (void *) mxMalloc(num_elts * num_bytes);

        if (attr_type == GLOBAL)
            success = CDFlib(GET_, gENTRY_DATA_, buf,
                             NULL_);
        else
            success = CDFlib(GET_, zENTRY_DATA_, buf,
                             NULL_);

        out = epoch_to_ML_datestr(((double *) buf)[0]);
        break;

    default:
        
        out = mxCreateNumericMatrix(1, num_elts, classID, mxREAL);
        buf = mxGetData(out);

        if (attr_type == GLOBAL)
            success = CDFlib(GET_, gENTRY_DATA_, buf,
                             NULL_);
        else
            success = CDFlib(GET_, zENTRY_DATA_, buf,
                             NULL_);

        break;
        
    }

    return out;
}


char * translate_attr_name(char *attr, int attr_type) {

    /* The schema for translating CDF attribute names to valid field names
     * for a MATLAB structure is:
     *
     * (1) Remove any leading characters which MATLAB does not allow.
     * (2) Replace any other illegal characters with underscores ('_').
     * (3) If there are no characters left after parsing, start the name
     *     with 'v' for variable attributes or 'g' for global attributes.
     * (4) If the name is longer than either (a) 27 characters (if modified)
     *     or (b) 31 characters (if unmodified), then keep the first 27
     *     characters.
     * (5) If the name was modified, append '_nnn' to the name, where "nnn"
     *     is the attribute's internal CDF number.
     */

    CDFstatus success;

    char * out;
    char num_str[4];

    int modified;
    long attr_num;
    int len;
    int p, count;

    count = 0;
    modified = 0;
    len = strlen(attr);

    out = (char *) mxMalloc((MAX_ML_FIELDNAME + 1) * sizeof(char));

    for (p = 0; p < len; p++) {
        
        /* Remove disallowed characters. */
        if (!(((attr[p] >= 'A') && (attr[p] <= 'Z')) ||
              ((attr[p] >= 'a') && (attr[p] <= 'z')) ||
              ((attr[p] >= '0') && (attr[p] <= '9') && (count > 0)) ||
              ((attr[p] == '_') && (count > 0)))) {

            if (count == 0) {

                /* Omit leading characters. */

            } else {

                /* Replace disallowed chars with underscore. */
                out[count++] = '_';

            }            

            modified = 1;
            continue;

        }

        /* Put the character. */
        out[count++] = attr[p];

        /* Check if at end of allowable MATLAB field name. */
        if (count > MAX_ML_FIELDNAME) {

            modified = 1;
            break;

        }

    }

    /* Append attribute number if necessary. */
    if (modified) {

        /* Get the attribute number for this variable. */
        success = CDFlib(GET_, ATTR_NUMBER_, attr, &attr_num,
                         NULL_);

        if (success != CDF_OK)
            msg_handler(success);

        /* Prepend with "v" or "g" if the attribute name is empty. */
        if (count == 0) {
            if (attr_type == VARIABLE)
                out[count++] = 'v';
            else
                out[count++] = 'g';
        }

        /* Replace the last four valid values with "_nnn". */
        if (count < (MAX_ML_FIELDNAME - 4))
            count += 4;
        else
            count = MAX_ML_FIELDNAME;

        out[count - 4] = '_';

        int_to_str(((int) attr_num), num_str);
        len = strlen(num_str);

        for (p = 0; p < (3 - len); p++)
            out[count - 3 + p] = '0';

        for (p = 0; p < len; p++)
            out[count - len + p] = num_str[p];
        
    }

    /* Put the EOS delimiter. */
    out[count] = '\0';

    return out;
}


/* Based on itoa() from Kernighan and Ritchie (1988), p. 64 */
void int_to_str(int n, char *s) {

    int c, i, j;

    if (n > 999)
        n %= 1000;

    i = 0;

    do {
        s[i++] = n % 10 + '0';
    } while ((n /= 10) > 0);

    s[i] = '\0';

    /* Reverse it. */
    for (i = 0, j = strlen(s) - 1; i < j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}

