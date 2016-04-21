#include "hdf5.h"
#include "mex.h"
#include "hdf5utils.h"

#define MAX_FILENAME_LEN   5000   /* Max length of an HDF5 filename that we allow */
#define MAX_DATASET_NAME   5000

/*
 * Forward declarations of functions within this file
 */
char *	  read_data(hid_t, hid_t, hid_t, int, int, int *, mxArray**);
mxArray * get_associated_attributes(char *, hid_t, char *);

static bool mexAtExitIsSet = false;

/*
 * This is the main entry point of the MEX-file
 */
void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[] )

{
    char       *filename;             /* name of HDF5 file */
    char       *datasetname;	      /* name of dataset or attribute */
    hid_t      fid;                   /* fid for opening the HDF5 file */
    bool       read_attribute_values; /* whether or not to read attribute values */
    char       *data_val;
    
    if (!mexAtExitIsSet)
    {
        H5dont_atexit();
	InitializeLists();
        mexAtExit(h5MexAtExit);
        mexAtExitIsSet = true;
    }

#if SUPPRESS_BACKTRACE
    /*
     * Turn off HDF5's automatic backtracing
     */
    H5Eset_auto(NULL, NULL);
#endif

    /*
     * Get filename and open it.
     */
    filename = (char *) mxMalloc((MAX_FILENAME_LEN + 1) * sizeof(char));
    datasetname = (char *) mxMalloc((MAX_DATASET_NAME + 1) * sizeof(char));
    if ((!mxIsChar(prhs[0])) || 
        (mxGetString(prhs[0], filename, (MAX_FILENAME_LEN + 1)))) {
        errHandler("Invalid file name.");
    }

    fid = open_file(filename, H5F_ACC_RDONLY, H5P_DEFAULT);

    /*
     * Get mode in which to open read file.  Default is 'eos'.
     */
    if (nrhs > 1)
    {
        if ((!mxIsChar(prhs[1])) || 
            (mxGetString(prhs[1], datasetname, (MAX_FILENAME_LEN + 1)))) {
	    errHandler("Invalid dataset name.");
        }
    }
 
    if (nrhs > 2)
    {
        if(!mxIsLogical(prhs[2]))
            errHandler("The third input argument to HDF5READC must be a logical array.");
        read_attribute_values = *(mxGetLogicals(prhs[2]));
    }else
    {
        read_attribute_values = true;
    }

    /*
     * If it's an attribute, read the attribute
     */
    if (!is_dataset(fid, datasetname))
    {

	if (is_attribute(fid, datasetname))
	{
	    hid_t     loc_id;
	    hid_t     attribute;
	    hid_t     aspace;
	    hid_t     atype;
	    char     *attr_val;
	    mxClassID mltype;
	    int       ndims;
	    hsize_t   size[H5S_MAX_RANK];
	    mxArray  *ml_attribute;
	    int       mlrank;
	    int      *mldims;
	    char     *attr_name;

	    loc_id = open_location(fid, datasetname);

	    if (loc_id < 0)
	    {
		errHandler("Not a valid dataset or attribute name");
	    }

	    attr_name = strrchr(datasetname, '/');
	    if (attr_name != NULL)
	    {
		attr_name = &attr_name[1];
	    }else
	    {
		errHandler("Attribute name must be a full pathname");
	    }

	    attribute = open_attribute(loc_id, attr_name);    
	    aspace =  get_dataspace(attribute, true);
	    atype = get_datatype(attribute, true);

	    mltype = HDF5_to_ML_datatype(atype);

	    /*
	     * Get the HDF5 dimensions of the dataset.  The mlrank and mldims
	     * reflect the dimensions of the MATLAB containers that will hold
	     * their HDF5 counterparts
	     */
	    ndims = H5Sget_simple_extent_dims(aspace, size, NULL);

	    mlrank = get_ml_rank(ndims);
	    mldims = get_ml_dims(mlrank, ndims, size);
	    
	    attr_val = read_attribute(attribute, aspace, atype, ndims, mlrank, mldims, &ml_attribute);

	    plhs[0] = convert_data_to_ML(aspace, atype, ndims, mlrank, mldims, ml_attribute, attr_val);
	    plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);

	    /*
	     * Close IDs
	     */
            mxFree(mldims);
	    close_attribute(attribute);
	    close_dataspace(aspace);
	    close_datatype(atype);
	}else
	{
	    char errmsg[500];
	    sprintf(errmsg,"%s is not an attribute or a dataset", datasetname);
	    errHandler(errmsg);
	}
    }
    else
    {
	hid_t    dataset;
	hid_t    dataspace;
	hid_t    datatype;
	int      ndims;
	hsize_t  size[H5S_MAX_RANK];
	int      mlrank;
	int     *mldims;
	mxArray *data;

	/*
	 * Get open identifiers to the dataset, dataspace, and datatype
	 */

	dataset = open_dataset(fid, datasetname);    
	dataspace = get_dataspace(dataset, false);
	datatype = get_datatype(dataset, false);

	/*
	 * Get the HDF5 dimensions of the dataset.  The mlrank and mldims
	 * reflect the dimensions of the MATLAB containers that will hold
	 * their HDF5 counterparts
	 */

	ndims = H5Sget_simple_extent_dims(dataspace, size, NULL);

	mlrank = get_ml_rank(ndims);
	mldims = get_ml_dims(mlrank, ndims, size);

	/*
	 * Read the dataset
	 */
        data_val = read_data(dataset, dataspace, datatype, ndims, mlrank, mldims, &data);
	
	plhs[0] = convert_data_to_ML(dataspace, datatype, ndims, mlrank, mldims, data, data_val);


	/*
	 * If we were told to read attributes of this dataset...
	 */

	if (read_attribute_values)
	{
	    plhs[1] = get_associated_attributes(filename, fid, datasetname);
	}else
	{
	    plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
	}

	/*
	 * Close identifiers
	 */
        mxFree(mldims);
	close_dataspace(dataspace);
	close_datatype(datatype);
	close_dataset(dataset);

    }
    close_file(fid);
    mxFree(filename);
    mxFree(datasetname);
}

char * read_data(hid_t dataset, hid_t dataspace, hid_t datatype, int ndims, int mlrank, int *mldims, mxArray **data)
{
    hid_t     mem_dtype;
    mxClassID mltype;
    char *data_val;
    hsize_t nbytes;

    if (is_array(datatype) || is_compound(datatype) || is_string(datatype) || is_vlen(datatype))
    {
	*data = mxCreateCellArray(mlrank, (const int *) mldims);
	/*
	 * Allocate memory for the buffer which will be passed into H5Dread
	 * to store the complete data that is read.  This will be different
	 * when indexing is implemented.
	 */
	
	nbytes = H5Dget_storage_size(dataset);
	data_val = mxMalloc(nbytes);

    }else
    {
	/*
	 * Otherwise, if you have an atomic, non-string datatype, you
	 * can create the appropriate numeric matrix.
	 */

	mltype = HDF5_to_ML_datatype(datatype);

	*data = mxCreateNumericArray(mlrank, (const int *) mldims, mltype, mxREAL);
	data_val = mxGetData(*data);
    }

    /*
     * Read the whole dang dataset into the buffer, which is a serialized buf.
     */    
    mem_dtype = get_mem_dtype(datatype);
    H5Dread(dataset, mem_dtype, H5S_ALL, H5S_ALL, H5P_DEFAULT, data_val);  

    /*
     * Close all IDs
     */
    close_datatype(mem_dtype);
      
    return data_val;
}

/*
 * This functions returns an Attribute Structure of the various attributes
 * associated with the dataset whose name is passed in
 */

mxArray * get_associated_attributes(char * filename, hid_t fid, char * datasetname)
{
    mxArray *attribute_structure; /* attribute structure to be returned */
    hid_t dset;          /* dataset in question */
    struct group_info attribute_info = {0,0,0,0,0,0,0,0,0,0,NULL, NULL, NULL, NULL, NULL, NULL}; /* info struct */
    int j, i;

    /*
     * Get number of attributes and their names
     */

    /*
     * Make sure you can't get an attribute here
     */
    dset = open_dataset(fid, datasetname);
    attribute_info.num_attributes = H5Aget_num_attrs(dset);

    if (attribute_info.num_attributes > 0)
    {
	int num_attribute_fields;
	herr_t status;

	attribute_info.attribute_names = (char **) mxMalloc(attribute_info.num_attributes * sizeof(char *));
	status = H5Aiterate(dset, NULL, populate_attributes, &attribute_info);
	num_attribute_fields = GET_NUMBER_FIELDNAMES(attribute_fields);

	attribute_structure = mxCreateStructMatrix(1, attribute_info.num_attributes,
						num_attribute_fields,
						attribute_fields);

	for (j = 0; j < attribute_info.num_attributes; j++)
	{
	    hid_t attribute;
	    hid_t aspace;
	    hid_t atype;
	    char *fullname_attribute;		    
	    mxArray *ml_attribute;
	    char *attr_val;
	    mxClassID mltype;
	    int ndims;
	    hsize_t size[H5S_MAX_RANK];
	    int mlrank;
	    int *mldims;

	    mxSetField(attribute_structure, j, "Filename", mxCreateString(filename));

	    /*
	     * Need to allocate enough space for the directory name, the slash, and
	     * the attribute name and null.
	     */

	    fullname_attribute = (char *) mxMalloc(((strlen(datasetname) + strlen(attribute_info.attribute_names[j]) + 1 + 1) * sizeof(char)));
	    strcpy(fullname_attribute, datasetname);
	    strcat(fullname_attribute, "/");
	    strcat(fullname_attribute, attribute_info.attribute_names[j]);
	
	    mxSetField(attribute_structure, j, "Name", mxCreateString(fullname_attribute));
	    attribute = open_attribute(dset, attribute_info.attribute_names[j]);
	    aspace = get_dataspace(attribute, true);
	    /*
	     * Set value.  First, get datatype, and dataspace.
	    */
	    atype = get_datatype(attribute, true);
	    mltype = HDF5_to_ML_datatype(atype);

	    /*
	     * Get the HDF5 dimensions of the dataset.  The mlrank and mldims
	     * reflect the dimensions of the MATLAB containers that will hold
	     * their HDF5 counterparts
	     */

	    ndims = H5Sget_simple_extent_dims(aspace, size, NULL);

	    mlrank = get_ml_rank(ndims);
	    mldims = get_ml_dims(mlrank, ndims, size);
	    
	    attr_val = read_attribute(attribute, aspace, atype, ndims, mlrank, mldims, &ml_attribute);

	    mxSetField(attribute_structure, j, "Value", convert_data_to_ML(aspace, atype, ndims, mlrank, mldims, ml_attribute, attr_val));

	    /*
	     * Close all of the ids
	     */
	    close_datatype(atype);
	    H5Tclose(aspace);
	    close_attribute(attribute);
	    mxFree(fullname_attribute);
	
	}

	/* Free memory */
	
	for (i = 0; i < attribute_info.num_attributes; i++)
	{
	    mxFree(attribute_info.attribute_names[i]);
	}

	if (attribute_info.attribute_names != NULL)
	{
	    mxFree(attribute_info.attribute_names);
	}

	
    }else
    {
	attribute_structure = mxCreateDoubleMatrix(0, 0, mxREAL);
    }
    close_dataset(dset);
    return attribute_structure;
}

