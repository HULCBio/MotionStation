/*
 * cdfwritec.c
 *
 * Writes data to a CDF (Common Data Format) file.
 *
 * Calls the CDF library which is distributed by the National Space Science
 * Data Center and available from
 * ftp://nssdcftp.gsfc.nasa.gov/standards/cdf/dist/cdf27/unix/cdf27-dist-all.tar.gz 
 * 
 * Copyright 1984-2001 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:50 $
 */
#include "mex.h"
#include "cdf.h"
#include "cdfutils.h"
#include <string.h>

long get_datatype(const mxArray *var_value);
void * get_data(long data_type, const mxArray *var_val, bool *free_buf);
void write_global_attribute(mxArray *cdfAttributeNames, mxArray *global_attribute, char *attrName);
void write_var_attribute(mxArray *cdfAttributeNames, mxArray *var_attribute, char *attrName);
void write_global_attrs(const mxArray *global_attrib);
void write_var_attrs(const mxArray *var_attrib);
long get_dimensions(const mxArray *first_var_val, long *numDims, const int *pdim, long *dimSizes);
void free_mem(CDFstatus success, void *buf, bool free_buf);
bool is_vector(const mxArray *first_var_val);

/*
 * Does the mxArray contain vector data?
 */
bool is_vector(const mxArray *first_var_val) {
    int numDims;
    int i;
    const int *pdim;
    int numDimsWithMoreThanOneEl = 0;

    numDims = mxGetNumberOfDimensions(first_var_val);
    pdim    = mxGetDimensions(first_var_val);

    for (i = 0; i < numDims; i++) {
	numDimsWithMoreThanOneEl += (*pdim++ > 1);
        if (numDimsWithMoreThanOneEl > 1) return(false);
    }
    return(true);
}

/*
 * Converts the mxClassID to a datatype for the variable
 * that will be written to the CDF
 */
long get_datatype(const mxArray *var_value) {
    mxClassID classID;
    long data_type;
    
    classID = mxGetClassID(var_value);
    
    switch (classID) {
      case mxCHAR_CLASS:
        data_type = CDF_UCHAR;
        break;
      case mxDOUBLE_CLASS:
        data_type = CDF_DOUBLE;
        break;
      case mxSINGLE_CLASS:
        data_type = CDF_FLOAT;
        break;
      case mxINT8_CLASS:
        data_type = CDF_BYTE;
        break;
      case mxUINT8_CLASS:
        data_type = CDF_UINT1;
        break;
      case mxINT16_CLASS:
        data_type = CDF_INT2;
        break;
      case mxUINT16_CLASS:
        data_type = CDF_UINT2;
        break;
      case mxINT32_CLASS:
        data_type = CDF_INT4;
        break;
      case mxUINT32_CLASS:
        data_type = CDF_UINT4;
        break;
/********
      case mxOBJECT_CLASS:
	if (strcmp(mxGetClassName(var_value), "cdfepoch") == 0)
	{
	    data_type = CDF_EPOCH;
	    break;
	}
      default:
        CDFlib(CLOSE_, CDF_, NULL_);
	mxErrMsgTxt("Cannot determine proper CDF datatype from MATLAB value");
	break;	 
********/
      default:
	if (strcmp(mxGetClassName(var_value), "cdfepoch") == 0)
	{
	    data_type = CDF_EPOCH;
	    break;
	}
        else
        {
            CDFlib(CLOSE_, CDF_, NULL_);
	    mxErrMsgTxt("Cannot determine proper CDF datatype from MATLAB value");
	    break;	 
        }
    }
    return data_type;
}

/*
 * Given the datatype and mxArray, return a buf of the data
 * in the format that CDFlib likes it.  (column-major)
 */
void * get_data(long data_type, const mxArray *var_val, bool *free_buf)
{
    void *buf;
    mxArray *mcm_prhs[2];    /* Arrays for mexCallMATLAB */
    mxArray *mcm_prhs2[2];
    mxArray *mcm_plhs[1];
    mxArray *mcm_plhs2[1];   /* For mexCallMATLAB */
    double partial_dims[2];  /* Array for the first reshape */
    const int *mdims;        /* The MATLAB dimensions of the variable value */
    mxArray *pa;	     /* Pointer to the mxArray which holds the 
                              * dimensions for the first rehape */
    double *pr;
    int charDims;
    double *epochbuf;        /* Buffer for epoch data */
    int i;

    switch(data_type) {

    case CDF_UCHAR:
	/*
	 * For character arrays, if you have multi-dimensional data, then 
         * jump through hoops.
	 */
	charDims = mxGetNumberOfDimensions(var_val);
	
	if (charDims > 2)
	{
	    int numChars = mxGetNumberOfElements(var_val);
	    /* 
	     * First, get the MATLAB array dimensions
	     */
	    mdims = mxGetDimensions(var_val);

	    /* 
	     * Set up a call to permute.  This handles the N-D char matrices.
             * pa is the pointer to the array of the indices that we pass to 
             * PERMUTE
             */

	    pa = mxCreateNumericMatrix(1, charDims, mxDOUBLE_CLASS, mxREAL);
	    pr = mxGetData(pa);
	    for (i = 0; i < charDims; i++)
	    {
		if (i < 2)
		    pr[i] = 2 - i;
		else
		    pr[i] = i + 1;
	    }

	    mcm_prhs[0] = (mxArray *) var_val;
	    mcm_prhs[1] = pa;
	    mexCallMATLAB(1, mcm_plhs2, 2, mcm_prhs, "permute");
	    
	    mxDestroyArray(pa);

	    /* 
	     * Now do a reshape, don't forget that this is column major.  
             * The reshape sets the string to be mdims x number_of_chars/mdims.
	     */
	    partial_dims[0] = (double) *mdims;
	    partial_dims[1] = numChars/(partial_dims[0]);

	    pa = mxCreateNumericMatrix(1, 2, mxDOUBLE_CLASS, mxREAL);
	    pr = mxGetData(pa);
	    for (i = 0; i < 2; i++)
	    {
		pr[i] = partial_dims[i];
	    }

	    mcm_prhs2[0] = mcm_plhs2[0];
	    mcm_prhs2[1] = pa;
	    mexCallMATLAB(1, mcm_plhs, 2, mcm_prhs2, "reshape");

	    mxDestroyArray(pa);

            /* +1 for null term */
	    buf = (char *) mxMalloc((numChars + 1) * sizeof(char));  
	    mxGetString(mcm_plhs[0], buf, numChars + 1);
	}
	else if (charDims == 2)
	{
	    /*
	     * Transpose because we are doing column-major writing
	     */
	    int numChars = mxGetNumberOfElements(var_val);
	    mcm_prhs[0] = (mxArray *) var_val;
	    mexCallMATLAB(1, mcm_plhs2, 1, mcm_prhs, "transpose");

            /* +1 for null term */
	    buf = (char *) mxMalloc((numChars + 1) * sizeof(char));  
	    mxGetString(mcm_plhs2[0], buf, numChars + 1);
	}
	else
	{
	    buf = (char *) mxMalloc((mxGetNumberOfElements(var_val) + 1) * sizeof(char)); 
	    mxGetString(var_val, buf, (mxGetNumberOfElements(var_val) + 1));
	}
	*free_buf = true;
	break;
    case CDF_DOUBLE:
        buf = (double *) mxGetPr(var_val);
	*free_buf = false;
	break;
    case CDF_FLOAT:
        buf = (float *) mxGetData(var_val);
	*free_buf = false;
	break;
    case CDF_BYTE:
        buf = (char *) mxGetData(var_val);
	*free_buf = false;	
	break;
    case CDF_UINT1:
        buf = (unsigned char *) mxGetData(var_val);
	*free_buf = false;
	break;
    case CDF_INT2:
        buf = (short *) mxGetData(var_val);
	*free_buf = false;
	break;
    case CDF_UINT2:
        buf = (unsigned short *) mxGetData(var_val);
	*free_buf = false;
	break;
    case CDF_INT4:
        buf = (int *) mxGetData(var_val);
	*free_buf = false;
	break;
    case CDF_UINT4:
        buf = (unsigned int *) mxGetData(var_val);
	*free_buf = false;
	break;
    case CDF_EPOCH:
	epochbuf = (double *) mxMalloc(mxGetNumberOfElements(var_val) * sizeof(double));
	
	/*
	 * If we have an array of cdfepoch objects, go element by element to 
         * get each data value.
	 */
	for (i = 0; i < mxGetNumberOfElements(var_val); i++)
	{
	    epochbuf[i] = (double) *(mxGetPr(mxGetField(var_val, i, "date")));
	}
	buf = epochbuf;
	*free_buf = true;
	break;
    default:
        CDFlib(CLOSE_, CDF_, NULL_);
	mxErrMsgTxt("Invalid datatype for CDF data export");
	break;
    }
    return buf;
}

/*
 * Write a global entry to the CDF.
 */
void write_global_attribute(mxArray *cdfAttributeNames, mxArray *global_attribute, char *attrName)
{
    int j;
    long *attrNum;
    mxArray *gEntry; 
    void *attrVal;
    CDFstatus success;
    bool free_me = false;
    long data_type;

    /*
     * Now we do the CDF attribute re-name
     */
    if (cdfAttributeNames != NULL)
    {
	for (j = 0; j < mxGetNumberOfElements(cdfAttributeNames); j+=2)
	{
	    char *mlAttribute;
	    mlAttribute = mxArrayToString(mxGetCell(cdfAttributeNames,j));

	    if (strcmp(mlAttribute, attrName) == 0)
	    {
		attrName = mxArrayToString(mxGetCell(cdfAttributeNames, j+1));
		free_me = true;
	    }
	    mxFree(mlAttribute);
	}
    }

    success = CDFlib(CREATE_, ATTR_, attrName, GLOBAL_SCOPE, &attrNum,
		     NULL_);

    if (success != CDF_OK)
    {
	if (success == ATTR_EXISTS)
	{
	    success = CDFlib(SELECT_, ATTR_NAME_, attrName,
			     NULL_);
	}else
	    msg_handler(success);
    }

    if (free_me)
	mxFree(attrName);

    /*
     * Now write out all of the entries for the global attribute 
     */		         	    	    
    for (j = 0; j < mxGetNumberOfElements(global_attribute); j++)
    {
	bool free_buf = false;

	gEntry = mxGetCell(global_attribute, j);
	
	data_type = get_datatype(gEntry);
	attrVal = get_data(data_type, gEntry, &free_buf);

	success = CDFlib(SELECT_, gENTRY_, j,
			 PUT_, gENTRY_DATA_, data_type, mxGetNumberOfElements(gEntry), attrVal,
			 NULL_);

	free_mem(success, attrVal, free_buf);
    }
}

/*
 * Write a variable entry to the CDF.
 */
void write_var_attribute(mxArray *cdfAttributeNames, mxArray *var_attribute, char *attrName)
{
    int j;
    long *attrNum;
    void *attrVal;
    CDFstatus success;
    bool free_me = false;
    long data_type;

    mxArray *attrMValue;
    long varNum;
    int numElems;
    char *varName;
    mxArray *tmpArray;

    /*
     * Now we do the CDF attribute re-name
     */
    if (cdfAttributeNames != NULL)
    {
	for (j = 0; j < mxGetNumberOfElements(cdfAttributeNames); j+=2)
	{
	    char *mlAttribute;
	    mlAttribute = mxArrayToString(mxGetCell(cdfAttributeNames,j));

	    if (strcmp(mlAttribute, attrName) == 0)
	    {
		attrName = mxArrayToString(mxGetCell(cdfAttributeNames, j+1));
		free_me = true;
	    }
	    mxFree(mlAttribute);
	}
    }

    success = CDFlib(CREATE_, ATTR_, attrName, VARIABLE_SCOPE, &attrNum,
		     NULL_);

    if (success != CDF_OK)
    {
	if (success == ATTR_EXISTS)
	{
	    success = CDFlib(SELECT_, ATTR_NAME_, attrName,
			     NULL_);
	}else
	    msg_handler(success);
    }
    /*
     * Now write out all of the entries for the variable attribute 
     */		         	    	    
    numElems = mxGetNumberOfElements(var_attribute);
    for (j = 0; j < numElems/2; j++)
    {
	    bool free_buf = false;

	    attrMValue = mxGetCell(var_attribute, (2*j + 1)); 
	    tmpArray = mxGetCell(var_attribute, (2*j));
	    varName = mxArrayToString(tmpArray);

	    /*
             * Check varName here and get the varNum.
             */
	    success = CDFlib(GET_, zVAR_NUMBER_, varName, &varNum,
			     NULL_);

	    if (success != CDF_OK)
		msg_handler(success);

	    data_type = get_datatype(attrMValue);
	    attrVal = get_data(data_type, attrMValue, &free_buf); 

	    success = CDFlib(SELECT_, zVAR_, varNum,
			     SELECT_, ATTR_NAME_, attrName,
			     SELECT_, zENTRY_NAME_, varName,
			     PUT_, zENTRY_DATA_, data_type, 
                                   mxGetNumberOfElements(attrMValue), attrVal,
			     NULL_);

	    free_mem(success, attrVal, free_buf);
	    mxFree(varName);
    }
    if (free_me)
	mxFree(attrName);
}

/*
 * Write the global attributes for the CDF.  Takes in a global attribute 
 * struct.
 */
void write_global_attrs(const mxArray *global_attrib)
{
    if (global_attrib != NULL)
    {
	int i;
	mxArray *cdfAttributeNames = NULL; /* A cell array of CDF attribute 
                                              renames */

	for (i = 0; i < mxGetNumberOfFields(global_attrib); i++)
	{
	    const char *attrName;

	    attrName = mxGetFieldNameByNumber(global_attrib, i);
            if (strcmp(attrName, "CDFAttributeRename") == 0)
	    {
		cdfAttributeNames = mxGetField(global_attrib, 0, (const char *) attrName);
	    }
	}


	for (i = 0; i < mxGetNumberOfFields(global_attrib); i++)
	{
	    const char *attrName;
	    mxArray *fieldCell;

	    attrName = mxGetFieldNameByNumber(global_attrib, i);
	    
	    if (strcmp(attrName, "CDFAttributeRename") != 0)
	    {	
		fieldCell = mxGetField(global_attrib, 0, attrName);
		write_global_attribute(cdfAttributeNames, fieldCell, (char *) attrName);
	    }
	}
    }    
}

/*
 * Write out variable attributes for the CDF.  Takes in a variable attribute 
 * struct.
 */
void write_var_attrs(const mxArray *var_attrib)
{
    if (var_attrib != NULL)
    {
	mxArray *cdfAttributeNames = NULL; /* A cell array of CDF variable 
                                            * attribute renames */
	int i;

	for (i = 0; i < mxGetNumberOfFields(var_attrib); i++)
	{
	    const char *attrName;

	    attrName = mxGetFieldNameByNumber(var_attrib, i);
	    if (strcmp(attrName, "CDFAttributeRename") == 0)
	    {
		cdfAttributeNames = mxGetField(var_attrib, 0, (const char *) attrName);
	    }
	}

	for (i = 0; i < mxGetNumberOfFields(var_attrib); i++)
	{
	    const char *attrName;
	    mxArray *fieldCell;

	    attrName = mxGetFieldNameByNumber(var_attrib, i);
	    
	    if (strcmp(attrName, "CDFAttributeRename") != 0)
	    {	
		fieldCell = mxGetField(var_attrib, 0, attrName);
		write_var_attribute(cdfAttributeNames, fieldCell, (char *) attrName);
	    }
	}
    }    
}

long get_dimensions(const mxArray *first_var_val, long *numDims, const int *pdim, long *dimSizes)
{
	int dim_count;
	long numElements;

	/* 
	 * Check to see if you are dealing with strings because dimensionality
	 * is different with strings.
	 */
	if (mxIsChar(first_var_val))
	{
	    int cdf_dim_count = 0;
	    int num_chars_per_str;
	    
	    for (dim_count = 0; dim_count < *numDims; dim_count++)
	    {
		if (dim_count == 1)
		    num_chars_per_str = pdim[1];
		else
		{
		    dimSizes[cdf_dim_count] = pdim[dim_count];
		    cdf_dim_count++;
		}
	    }
	    /* 
	     * Need to subtract 1 because we took out a dimension which is 
             * actually numElements.
	     */
	    *numDims -= 1;
	    numElements = num_chars_per_str;
	}
        else{
	    
	    /* 
	     * If we have a scalar, the CDF numDims is 0, and if we have a 
             * vector, the CDF numDims is 1, contrary to MATLAB's always 
             * having 2 dimensions for either of those cases.
	     */
	    if (mxGetNumberOfElements(first_var_val) == 1)
		*numDims = 0;
	    else if (is_vector(first_var_val))
    	        *numDims = 1;	
	    
            /* Handle vector case first-- if we have a vector, it is
             * stored as a column vector, because CDF writing is COLUMN
             * MAJOR.
             */
            if (*numDims == 1)
            {
                /*
                 * The dimension size is the one which is NOT 1.
                 */
                if (pdim[0] == 1)
                    dimSizes[0] = pdim[1];
                else
                    dimSizes[0] = pdim[0];
            }else
            {
                /*
                 * Otherwise, just use MATLAB's numDims and dimensions.
                 */
                for (dim_count = 0; dim_count < *numDims; dim_count++)
                {
                    dimSizes[dim_count] = pdim[dim_count];
                }
            }
            numElements = 1; /* non-char types cannot have multiple values */
	}
	return numElements;
}

/*
 * Cleans up allocated memory buffer if boolean is set
 */
void free_mem(CDFstatus success, void *buf, bool free_buf)
{
    if (success != CDF_OK)
    {
	if (success < CDF_WARN)
	{
	    if (free_buf)
		mxFree(buf);
	}
	msg_handler(success);
    }
    if (free_buf)
	mxFree(buf);
}


/*
 * Main function
 */
void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[] )

{

    CDFid fid;
    CDFstatus success;

    char *filename;        /* Name of file */
    char *var_name;        /* Name of variable */
    long data_type;        /* CDF datatype */
    double is_multifile;   /* Multifile or singlefile? */
    double is_appending;   /* Appending or overwriting? */
    char err_text[CDF_STATUSTEXT_LEN + 1];
    int i, j;              /* counters for for loops */
    long numDims;          /* number of CDF dimensions for zVar */
    long numElements;      /* number of elements for CDF zVar */
    static long *dimSizes;  /* CDF dimensions */
    long varNum;           /* CDF variable number */
    long rec_nums;         /* Number of records to write for this variable */
    long dimVarys[CDF_MAX_DIMS];      /* This needs to be an array */
    const int *pdim;       /* MATLAB dimensions for this variable */
    void *buf;             /* buffer that contains the data of anything to be 
                            * written to the CDF */

    const mxArray *padVal;
    mxArray *var_value;
    const mxArray *var_names;     /* names of variables to be written out */
    const mxArray *var_vals;      /* corresponding variable values to be 
                                     written out */
    const mxArray *var_pad_vals;  /* corresponding pad values */
    const mxArray *first_var_val; /* first value/record for a variable */
    const mxArray *global_attrib; /* global attribute struct */
    const mxArray *var_attrib;    /* variable attribute struct */

    /*
     * Parse inputs - check number of inputs, outputs and place
     * the RHS arguments into the proper variables
     */

    if (nrhs != 8) {
        mexErrMsgTxt("Incorrect number of input arguments.");
    } else if (nlhs > 0) {
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

    /* prhs[1] - Variable names in cell array */
    if (!mxIsCell(prhs[1]))
        mexErrMsgTxt("Variable names must be in a cell array");
    else
        var_names = prhs[1];

    /* prhs[2] - Variable values */
    if (!mxIsCell(prhs[2]))
        mexErrMsgTxt("Variable values must be in a cell array");
    else
        var_vals = prhs[2];

    /* prhs[3] - Variable pad values */
    if (!mxIsCell(prhs[3]))
        mexErrMsgTxt("Variable pad values must be in a cell array");
    else
        var_pad_vals = prhs[3];

    /* prhs[4] - Global Attribute struct */
    if (!mxIsStruct(prhs[4]))
        mexErrMsgTxt("'GlobalAttribStruct' must be a struct");
    else
        global_attrib = prhs[4];

    /* prhs[5] - Variable Attribute struct */
    if (!mxIsStruct(prhs[5]))
        mexErrMsgTxt("'VarAttribStruct' must be a struct");
    else
        var_attrib = prhs[5];

    /* prhs[6] - Whether or not to append */
    if ((!mxIsDouble(prhs[6])) || (mxGetNumberOfElements(prhs[6]) != 1))
        mexErrMsgTxt("'Append' option must be 1 or 0");
    else
        is_appending = *(mxGetPr(prhs[6]));

    /* prhs[7] - Whether or not to write out a multi-file CDF */

    if ((!mxIsDouble(prhs[7])) || (mxGetNumberOfElements(prhs[7]) != 1))
        mexErrMsgTxt("'Multifile' option must be 1 or 0");
    else
        is_multifile = *(mxGetPr(prhs[7]));

    /*
     * If we're appending, open the existing CDF
     */
    if (is_appending)
    {
        /* Open CDF. */
        success = CDFlib(OPEN_, CDF_, filename, &fid,
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

        success = CDFlib(SELECT_, CDF_zMODE_, zMODEon2,
                         NULL_);
    }else
    {
	/* Delete the existing CDF if it exists. */
	long format;

        success = CDFlib(OPEN_, CDF_, filename, &fid,
			 SELECT_, CDF_zMODE_, zMODEon2,
                         NULL_);

	if (success == CDF_OK) {
	    success = CDFlib(DELETE_, CDF_,
			     NULL_);
	}
        /*
         * Create a CDF.  Whether or not it is multifile is specified by the 
         * format variable.  It is stored as column-major with the encoding 
         * being the default HOST_ENCODING
         */
        if (is_multifile)
            format = MULTI_FILE;
        else
            format = SINGLE_FILE;

        success = CDFlib(CREATE_, CDF_, filename, 0, 0, &fid,
                         PUT_, CDF_ENCODING_, HOST_ENCODING,
	                       CDF_MAJORITY_, COLUMN_MAJOR,
	                       CDF_FORMAT_, format,
                         NULL_);
	
	if (success != CDF_OK) {
	    msg_handler(success);
	}
    }

    /* 
     * Write out the variables
     */
    for (i=0; i < mxGetNumberOfElements(var_names); i++)
    {
        /* Write the variable */
        var_name = (char *) mxMalloc((CDF_VAR_NAME_LEN + 1) * sizeof(char));
        if (var_name == NULL)
            mexErrMsgTxt("Couldn't allocate space for variable name buffer.");

        mxGetString(mxGetCell(var_names,i), var_name, CDF_VAR_NAME_LEN + 1);

        /* 
         * var_value is the value of the variable
	 * in the CDF.
         */
        var_value = mxGetCell(var_vals,i);
	rec_nums = mxGetNumberOfElements(var_value);

	if (rec_nums > 0)
	{
	    /* 
	     * Get the appropriate CDF datatype.  Datatype conformance was 
             * already checked in M
	     */
	    for (j = 0; j <rec_nums; j++)
	    {
		first_var_val = mxGetCell(var_value,j);
		if (!mxIsEmpty(first_var_val))
		    break;
	    }

	    if (mxIsEmpty(first_var_val))
	    {
		/* 
		 * Then you have a completely empty variable and should first
		 * try to create the variable based on the pad value
		 */
		mxArray *padVal = mxGetCell(var_pad_vals,i);
        
		if (padVal != NULL)
		{
		    data_type = get_datatype(padVal);
		    numDims = (long) mxGetNumberOfDimensions(padVal);
		    dimSizes = (long *) mxMalloc(numDims * sizeof(long));
		    numElements = get_dimensions(padVal, &numDims, mxGetDimensions(padVal), dimSizes);
		}else
		{
    		    /*
                     * Can't use get_datatype because it bombs out on empty
                     */
		    if (mxIsChar(first_var_val))
			data_type = CDF_UCHAR;
		    else
			data_type = CDF_DOUBLE;
		    numDims = 0;
		    numElements = 1;
		}
	    }else
	    {
		data_type = get_datatype(first_var_val);

		/*
                 * Get the dimensions so we can create the CDF zVar.  
                 * get_dimensions() changes these through the pointer
                 */
		numDims = (long) mxGetNumberOfDimensions(first_var_val);
		pdim = mxGetDimensions(first_var_val);
		dimSizes = (long *) mxMalloc(numDims * sizeof(long));

		numElements = get_dimensions(first_var_val, &numDims, pdim, 
                                             dimSizes);
	    }

            /*
             * Set the variances to be true for all the data
             */
            for (j = 0; j < numDims; j++)
            {
                dimVarys[j] = VARY;
            }

	    success = CDFlib(CREATE_, zVAR_, var_name, data_type, 
                                      numElements, numDims, dimSizes, VARY,
                                      dimVarys, &varNum,
			     NULL_);

	    if (success == VAR_EXISTS)
	    {
		/*
		 * If we are appending and the variable already exists, then 
                 * wipe out the old one.
		 */
		if (is_appending)
		{
		    success = CDFlib(GET_, zVAR_NUMBER_, var_name, &varNum,
				     NULL_);

		    success = CDFlib(SELECT_, zVAR_, varNum,
				     NULL_);
		    success = CDFlib(DELETE_, zVAR_,
				     NULL_);

                    for (j = 0; j < numDims; j++)
                    {
                        dimVarys[j] = VARY;
                    }

		    success = CDFlib(CREATE_, zVAR_, var_name, data_type, 
                                              numElements, numDims, dimSizes,
					      VARY, dimVarys, &varNum,
				     NULL_);

		}else
		    msg_handler(success);
	    }else if (success != CDF_OK)
		msg_handler(success);

	    /* 
	     * Get the pad value, if any.  If it is specified, you must
	     * write the pad value before the data.  Otherwise, you can
	     * just write out the variable, and the default will be
	     * used. */
	    padVal = mxGetCell(var_pad_vals,i);
        
	    if (padVal != NULL)
	    {
		void *buf;
		int data_type;
		bool free_buf = false;
		
		data_type = get_datatype(padVal);
		buf = get_data(data_type, padVal, &free_buf);

		success = CDFlib(PUT_, zVAR_PADVALUE_, buf,
				 NULL_);

		free_mem(success, buf, free_buf);
	    }    	
	    for (j = 0; j < rec_nums; j++)
	    {
		const mxArray *var_val;	    
		bool free_buf = false;

		var_val = mxGetCell(var_value, j);

		/* 
                 * Allocate the right kind of buffer for the type of data 
                 * we're writing out
                 */
		
		if (!mxIsEmpty(var_val))
		    buf = get_data(data_type, var_val, &free_buf);
		else
		    continue;

		if (buf == NULL)
		{
		    /* 
                     * Nothing to do because the pad value will already be 
                     * specified
                     */
		    continue;		
		}else
		{
		    /* Write one record at a time */
		    success = CDFlib(SELECT_, zVAR_RECNUMBER_, j,
				    SELECT_, zVAR_RECCOUNT_, 1,
				    SELECT_, zVAR_RECINTERVAL_, 1,
				    PUT_, zVAR_HYPERDATA_, buf,
				    NULL_);
		    free_mem(success, buf, free_buf);
		}	
	    }
	} /* if rec_nums > 0 */
    mxFree(var_name);
    mxFree(dimSizes);
    }

    /* Write out global attributes */
    write_global_attrs(global_attrib);

    /* Write variable attributes */
    write_var_attrs(var_attrib);

    /* Close CDF. */
    success = CDFlib(CLOSE_, CDF_, NULL_);
    
    /* Clean up. */
    mxFree(filename);
}

