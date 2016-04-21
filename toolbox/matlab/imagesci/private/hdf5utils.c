/*
 * hdf5utils.c --- Contains functions used by hdf5infoc.c and
 * hdf5readc.c for reading and getting information on HDF5 files.
 *
 * Copyright 1984-2002 The MathWorks, Inc. 
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:59:51 $ */

/* Main HDF5 library header files */
#include "hdf5.h"

/* MATLAB API header file */
#include "mex.h"
#include "hdf5utils.h"

/*
 * Node for storing ids on lists
 */
struct node {
    hid_t idnum;
    struct node *previous;
    struct node *next;
};

typedef struct node NodeType;

/*
 * Contains information about an ID list
 */
typedef struct 
{
    NodeType    list;
    void        (*idCloseFcn)(hid_t);
    char        *name;
} ListInfo;

/*
 * The array of various ID lists
 */
static ListInfo listArray[Num_ID_Lists];

/*
 * Initializes ID lists
 */
void InitializeLists(void)
{
    listArray[DatatypeList].list.idnum    = -1;
    listArray[DatatypeList].list.next     = NULL;
    listArray[DatatypeList].list.previous = NULL;
    listArray[DatatypeList].idCloseFcn    = close_datatype;
    listArray[DatatypeList].name          = "Datatype";
    
    listArray[DataspaceList].list.idnum    = -1;
    listArray[DataspaceList].list.next     = NULL;
    listArray[DataspaceList].list.previous = NULL;
    listArray[DataspaceList].idCloseFcn    = close_dataspace;
    listArray[DataspaceList].name          = "Dataspace";
    
    listArray[DatasetList].list.idnum    = -1;
    listArray[DatasetList].list.next     = NULL;
    listArray[DatasetList].list.previous = NULL;
    listArray[DatasetList].idCloseFcn    = close_dataset;
    listArray[DatasetList].name          = "Dataset";
    
    listArray[AttributeList].list.idnum    = -1;
    listArray[AttributeList].list.next     = NULL;
    listArray[AttributeList].list.previous = NULL;
    listArray[AttributeList].idCloseFcn    = close_attribute;
    listArray[AttributeList].name          = "Attribute";

    listArray[GroupList].list.idnum    = -1;
    listArray[GroupList].list.next     = NULL;
    listArray[GroupList].list.previous = NULL;
    listArray[GroupList].idCloseFcn    = close_group;
    listArray[GroupList].name          = "Group";

    listArray[FileList].list.idnum    = -1;
    listArray[FileList].list.next     = NULL;
    listArray[FileList].list.previous = NULL;
    listArray[FileList].idCloseFcn    = close_file;
    listArray[FileList].name          = "File";
}

/*
 * Adds a node at the beginning of a given list
 */
static void AddNodeToList(NodeType *list, NodeType *new)
{
    new->next = list->next;
    new->previous = list;
    list->next = new;
    if (new->next != NULL)
    {
        new->next->previous = new;
    }
}

/*
 * Deletes a node from a given list and frees the node memory
 */
static void DeleteNodeFromList(NodeType *node)
{
    node->previous->next = node->next;
    if (node->next != NULL)
    {
        node->next->previous = node->previous;
    }
    free((void *) node);
}

/*
 * Finds a node in a list, given the value
 */
static NodeType *FindNodeInList(NodeType *list, hid_t match)
{
    NodeType *current;
    int found = 0;

    current = list->next;
    while (current != NULL)
    {
        if (current->idnum == match)
        {
            found = 1;
            break;
        }
        else
        {
            current = current->next;
        }
    }

    if (found == 0)
    {
        current = NULL;
    }
    return(current);
}

/*
 * Adds an open identifier to the proper ID list
 */
int AddIDToList(hid_t id, IDList list)
{
    NodeType *listHead = &(listArray[list].list);
    NodeType *newNode = NULL;
    int result = 1;

    newNode = (NodeType *) malloc(sizeof(*newNode));
    if (newNode != NULL)
    {
        newNode->idnum = id;
        AddNodeToList(listHead, newNode);
    }
    else
    {
        mexWarnMsgTxt("Out of memory in HDF5 MEX gateway.");
        result = -1;
    }

    return(result);
}

/*
 * Deletes an identifier from an ID list
 */
void DeleteIDFromList(hid_t id, IDList list)
{
    NodeType *match_node;
    NodeType *listHead = &(listArray[list].list);

    match_node = FindNodeInList(listHead, id);
    if (match_node != NULL)
    {
        DeleteNodeFromList(match_node);
    }
}

/*
 * Closes all of the identifiers on the list
 */
static void CleanupList(ListInfo *listInfo)
{
    NodeType *list = &(listInfo->list);

    while (list->next != NULL)
    {
        (*listInfo->idCloseFcn)(list->next->idnum);
	/* Isn't this redundant?  
        DeleteNodeFromList(list->next);
        */
    }
}
    
/*
 * Error handler- takes in an error message, cleans up,
 * and then errors out
 */

void errHandler(char *errmsg) {
    /*
     * Free any memory that was allocated
     */

    /*
     * Close all identifiers first
     */
    h5MexAtExit();
    
    /*
     * Error away...
     */
    mexErrMsgTxt(errmsg);
}


/*
 * Operator for H5Giterate.  Populates group structure, given the
 * number of members for each member type.
 */
herr_t populate_group_info(hid_t loc_id, const char *member_name, 
                                ginfo_ptr ginfo)
{
    H5G_stat_t statbuf;
    char *buf;
    hid_t dset_id;


    H5Gget_objinfo(loc_id, member_name, false, &statbuf);
    switch (statbuf.type) {
      case H5G_GROUP:
        buf = mxMalloc((strlen(member_name) + 1) * sizeof(char));
        strcpy(buf, member_name);
	ginfo->nlink[ginfo->current_group] = statbuf.nlink;
        ginfo->objno[ginfo->current_group] = (unsigned long *) mxMalloc( 2 * sizeof(unsigned long));
	ginfo->objno[ginfo->current_group][0] = statbuf.objno[0];
	ginfo->objno[ginfo->current_group][1] = statbuf.objno[1];	
        ginfo->group_names[ginfo->current_group++] = buf;
        break;
      case H5G_DATASET:
        buf = mxMalloc((strlen(member_name) + 1) * sizeof(char));
	strcpy(buf, member_name);
	dset_id = open_dataset(loc_id, member_name);
	ginfo->datatype_class[ginfo->current_dataset] = get_datatype(dset_id, false);
        close_dataset(dset_id);
	ginfo->dataset_names[ginfo->current_dataset++] = buf;
        break;
      case H5G_TYPE:
        buf = mxMalloc((strlen(member_name) + 1) * sizeof(char));
        strcpy(buf, member_name);
        ginfo->named_datatype_names[ginfo->current_datatype++] = buf;
        break;
      case H5G_LINK:
        buf = mxMalloc((strlen(member_name) + 1) * sizeof(char));
        strcpy(buf, member_name);
        ginfo->link_names[ginfo->current_link++] = buf;
        break;
      default:
        errHandler("Unable to identify object");
    }

    return 0;
}

/*
 * Operator for H5Aiterate.  Puts attribute names into ginfo struct.
 */
herr_t populate_attributes(hid_t loc_id, const char *attr_name, 
                           ginfo_ptr ginfo)
{
    char *buf;

    buf = mxMalloc((strlen(attr_name) + 1) * sizeof(char));
    strcpy(buf, attr_name);

    /*
     * Attributes cannot be shared, so don't worry about links.
     */
    ginfo->attribute_names[ginfo->current_attribute++] = buf;

    return 0;
}

/* 
 * Gets the dimensions for a given dataspace
 */
mxArray * get_dims(hid_t dataspace)
{
    hsize_t   size[H5S_MAX_RANK];
    int       ndims = H5Sget_simple_extent_dims(dataspace, size, NULL);
    mxArray  *dims;
    double *pa;
    int i;

    if (H5Sis_simple(dataspace)) {
	if (ndims == 0) {
            dims = NULL;
	} else {
	    /*
	     * This depends on the size of hsize_t
	     */
            dims = mxCreateNumericMatrix(1, ndims, mxDOUBLE_CLASS, mxREAL);
	    pa = (double *) mxGetData(dims);

	    for (i = 0; i < ndims; i++)
	    {
		pa[i] = (signed long) size[i];
	    }
	    /* Where do I destroy the dims array? */
	}
    } else {
        mexPrintf("Complex dataspace support not yet supported");
    }

    return dims;
}

/*
 * Determines whether or not the open datatype is an array
 */
bool is_array(hid_t datatype)
{
    return (H5Tget_class(datatype) == H5T_ARRAY);
}

/*
 * Determines whether or not the open datatype is a compound type
 */
bool is_compound(hid_t datatype)
{
    return (H5Tget_class(datatype) == H5T_COMPOUND);
}

/*
 * Determines whether or not the open datatype is an enum type
 */
bool is_enum(hid_t datatype)
{
    return (H5Tget_class(datatype) == H5T_ENUM);
}

/*
 * Determines whether or not the open datatype is a variable-length type
 */
bool is_vlen(hid_t datatype)
{
    return (H5Tget_class(datatype) == H5T_VLEN);
}

/*
 * Determines whether or not the open datatype is an atomic type
 */
bool is_atomic(hid_t datatype)
{
    return ((!is_string(datatype)) && (!is_compound(datatype)) && (!is_vlen(datatype)) && (!is_array(datatype)) && (!is_enum(datatype)));
}

/*
 * Determines whether or not the open datatype is a string type
 */
bool is_string(hid_t datatype)
{
    return (H5Tget_class(datatype) == H5T_STRING);
}

/*
 * Gets the number of elements in an attribute or dataset
 */
hsize_t get_num_elements(hid_t dataspace)
{
    hsize_t   size[H5S_MAX_RANK];
    int       ndims = H5Sget_simple_extent_dims(dataspace, size, NULL);
    hsize_t   nelems = 1;
    int	      i;

    if (H5Sis_simple(dataspace)) {
	if (ndims == 0) {
	    /*
	     * Then it is a scalar
	     */
            nelems = 1;
	} else 
	{
	    for (i = 0; i < ndims; i++)
	    {
		nelems = nelems * size[i];
	    }
	}
    } else {
        mexPrintf("Complex dataspace support not yet supported");
    }

    return nelems;
}

/*
 * Gets the number of members in an array.  Should be passed
 * MATLAB array rank and MATLAB array dimensions.
 */
int get_num_array_members(int num_array_dims, int *array_dims)
{
    int i;
    int num_members = 1;

    for (i = 0; i < num_array_dims; i++)
    {
	num_members *= array_dims[i];
    }

    return num_members;
}

/*
 * Get the maximum possible dimensions for a dataspace
 */
mxArray * get_max_dims(hid_t dataspace)
{
    hsize_t   maxsize[H5S_MAX_RANK];
    int       ndims = H5Sget_simple_extent_dims(dataspace, NULL, maxsize);
    mxArray  *max_dims;
    double   *mpa;
    int       i;

    if (H5Sis_simple(dataspace)) {
	if (ndims == 0) {
            max_dims = NULL;
	} else {
            /* MaxDims */
            max_dims = mxCreateNumericMatrix(1, ndims, mxDOUBLE_CLASS, mxREAL);
            mpa = (double *) mxGetData(max_dims);

	    for (i = 0; i < ndims; i++)
	    {
                mpa[i] = (signed long) maxsize[i];
	    }
	}
    } else {
        mexPrintf("Complex dataspace support not yet supported");
    }

    return max_dims;
}

/*
 * Gets the rank of a dataset
 */

int get_rank(hid_t dataspace)
{
    int ndims = H5Sget_simple_extent_dims(dataspace, NULL, NULL);
    return ndims;
}

/*
 * Get the base datatype for a compound, vlen, or array datatype.
 * When atomic datatypes are passed in, simply return that type.
 */

hid_t get_base_datatype(hid_t datatype_id)
{
    switch (H5Tget_class(datatype_id)) {
    case H5T_ENUM:   
    case H5T_COMPOUND:
    case H5T_VLEN:
    case H5T_ARRAY:
	return H5Tget_super(datatype_id);
	break;
    default:
	return datatype_id;
	break;
    }
}

/*
 * Given an HDF5 datatype on file, return the appropriate memory
 * datatype which is how the data should be read in.
 */
hid_t get_mem_dtype(hid_t dtype)
{
    hid_t       mem_dtype;
    hid_t       mem_member_dtype;
    hid_t       member_dtype;
    H5T_class_t dclass = H5Tget_class(dtype);
    int         ndims;
    hsize_t     dims[H5S_MAX_RANK];
    size_t      dsize;
    hid_t       base_type;
    size_t      offset;
    hid_t      *memb = NULL;
    char      **name = NULL;
    int         num_members = 0;
    int         i;
    hid_t	packed_type;

    dsize = H5Tget_size(dtype);

    switch(dclass) {
        case H5T_INTEGER:
	    if (dsize <= sizeof(char)) {
		mem_dtype = H5Tcopy(H5T_NATIVE_SCHAR);
	    } else if (dsize <= sizeof(short)) {
		mem_dtype = H5Tcopy(H5T_NATIVE_SHORT);
	    } else if (dsize <= sizeof(int)) {
		mem_dtype = H5Tcopy(H5T_NATIVE_INT);
	    } else if (dsize <= sizeof(long)) {
		mem_dtype = H5Tcopy(H5T_NATIVE_LONG);
	    } else {
		mem_dtype = H5Tcopy(H5T_NATIVE_LLONG);
	    }

	    H5Tset_sign(mem_dtype, H5Tget_sign(dtype));
	    break;

        case H5T_FLOAT:
	    if (dsize <= sizeof(float)) {
		mem_dtype = H5Tcopy(H5T_NATIVE_FLOAT);
	    } else if (dsize <= sizeof(double)) {
		mem_dtype = H5Tcopy(H5T_NATIVE_DOUBLE);
	    } else {
		mem_dtype = H5Tcopy(H5T_NATIVE_LDOUBLE);
	    }
	    break;
	case H5T_STRING:
	    mem_dtype = H5Tcopy(dtype);
	    H5Tset_cset(mem_dtype, H5T_CSET_ASCII);
	    break;
	case H5T_VLEN:
	    member_dtype = H5Tget_super(dtype);
	    /*
	     * Actually, should merge these, because can have type that aren't
	     * atomic
	     */
	    mem_member_dtype = get_mem_dtype(member_dtype);

	    /* Copy the VL type */
	    mem_dtype = H5Tvlen_create(mem_member_dtype);

	    /* Close the temporary datatypes */
	    close_datatype(mem_member_dtype);
	    close_datatype(member_dtype);
	    break;
	case H5T_ARRAY:
	    /* Get the array information */
	    ndims = H5Tget_array_ndims(dtype);
	    H5Tget_array_dims(dtype, dims, NULL);

	    /* Get the array's base type and convert it to the printable version */
	    member_dtype = H5Tget_super(dtype);
	    mem_member_dtype = get_mem_dtype(member_dtype);

	    /* Copy the array */
	    mem_dtype = H5Tarray_create(mem_member_dtype, ndims, dims, NULL);

	    /* Close the temporary datatypes */
	    close_datatype(mem_member_dtype);
	    close_datatype(member_dtype);
	    break;
	case H5T_COMPOUND:
	    packed_type = H5Tcopy(dtype);
	    H5Tpack(packed_type);
	    num_members = H5Tget_nmembers(dtype);
	    
	    memb = mxCalloc((size_t) num_members, sizeof(hid_t));
	    name = mxCalloc((size_t) num_members, sizeof(char *));

	    /* 
             * Convert each member datatype
	     */ 
	    for (i = 0, dsize = 0; i < num_members; i++) {
		member_dtype = H5Tget_member_type(packed_type, i);

		memb[i] = get_mem_dtype(member_dtype);
		close_datatype(member_dtype);

		if (memb[i] < 0)
		{
                    if (memb && name) {
                        register int j;

                        for (j = 0; j < num_members; j++) {
                            if (memb[j] >= 0)
                                close_datatype(memb[j]);
                            if (name[j])
                                mxFree(name[j]);
                        }
                        mxFree(memb);
                        mxFree(name);
                    }
		    return mem_dtype;
		}

		/* Get the member name */
		name[i] = H5Tget_member_name(dtype, i);

		if (name[i] == NULL)
		{
		    /* clean up function */
		    if (memb && name) {
			register int j;
                    
			for (j = 0; j < num_members; j++) {
			    if (memb[j] >= 0)
				close_datatype(memb[j]);
                        
			    if (name[j])
				mxFree(name[j]);
			}
			mxFree(memb);
			mxFree(name);
		    }
		    return mem_dtype; /* Actually, should error here */
		}
		 dsize += H5Tget_size(memb[i]);
	    }

	    /*
	     * Now create the memory type 
	     */
	    mem_dtype = H5Tcreate(H5T_COMPOUND, dsize);

	    for (i = 0, offset = 0; i < num_members; i++) {
		H5Tinsert(mem_dtype, name[i], offset, memb[i]);
		offset += H5Tget_size(memb[i]);
	    }
	    close_datatype(packed_type);
	    break;
	case H5T_ENUM:

	    base_type = H5Tget_super(dtype);
	    num_members = H5Tget_nmembers(dtype);
	    mem_dtype = H5Tenum_create(get_mem_dtype(base_type));

	    for (i = 0; i < num_members; i++)
	    {
		hid_t errid;
		void *value = NULL; /* Let it be the biggest int possible */
		char *name;
                int num_val_bytes = sizeof(base_type);
                value = (void *) mxMalloc(num_val_bytes*num_members);

		/* 
                 * H5Tget_member_value reads in endian-specific data, so you
                 * have to convert 
                 */
		errid = H5Tget_member_value(dtype, i, value);
		errid = H5Tconvert(base_type, H5Tcopy(H5T_NATIVE_INT), num_val_bytes, value, NULL, H5P_DEFAULT); 
		name = H5Tget_member_name(dtype, i);
		errid = H5Tenum_insert(mem_dtype, name, value);
                mxFree(value);
	    }
	    close_datatype(base_type);

	    break;
	case H5T_REFERENCE:
	case H5T_OPAQUE:
	case H5T_BITFIELD:
	case H5T_TIME:
	default:
	    errHandler("Unsupported datatype");
	    break;
    }
    return mem_dtype;    
}

/*
 * Converts HDF5 datatypes into corresponding MATLAB datatypes for use with
 * the info and read function.
 */

mxClassID HDF5_to_ML_datatype(hid_t datatype_id)
{
    hid_t base_type;
    mxClassID mltype;

    switch (H5Tget_class(datatype_id)) {
 	
    case H5T_INTEGER:
	if (H5Tequal(datatype_id, H5T_STD_I8BE)) {
	    return mxINT8_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_I8LE)) {
	    return mxINT8_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_I16BE)) {
	    return mxINT16_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_I16LE)) {
	    return mxINT16_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_I32BE)) {
	    return mxINT32_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_I32LE)) {
	    return mxINT32_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_I64BE)) {
	    return mxINT64_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_I64LE)) {
	    return mxINT64_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_U8BE)) {
	    return mxUINT8_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_U8LE)) {
	    return mxUINT8_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_U16BE)) {
	    return mxUINT16_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_U16LE)) {
	    return mxUINT16_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_U32BE)) {
	    return mxUINT32_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_U32LE)) {
	    return mxUINT32_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_U64BE)) {
	    return mxUINT64_CLASS;
	} else if (H5Tequal(datatype_id, H5T_STD_U64LE)) {
	    return mxUINT64_CLASS;
	} else {
	    errHandler("Encountered unknown integer type");
	}
	break;
    case H5T_FLOAT:
	if (H5Tequal(datatype_id, H5T_IEEE_F32BE)) {
	    return mxSINGLE_CLASS;
	} else if (H5Tequal(datatype_id, H5T_IEEE_F32LE)) {
	    return mxSINGLE_CLASS;
	} else if (H5Tequal(datatype_id, H5T_IEEE_F64BE)) {
	    return mxDOUBLE_CLASS;
	} else if (H5Tequal(datatype_id, H5T_IEEE_F64LE)) {
	    return mxDOUBLE_CLASS;
	} else {
	    errHandler("Encountered unknown float type");
	}
	break;

    case H5T_STRING:
	return mxCELL_CLASS;
	break;
    case H5T_ENUM:
	base_type = get_base_datatype(datatype_id);
	mltype = HDF5_to_ML_datatype(base_type);
	close_datatype(base_type);
	return mltype;
	break;
    case H5T_COMPOUND:
    case H5T_VLEN:
    case H5T_ARRAY:
	return mxCELL_CLASS;
	break;
    case H5T_BITFIELD:
    case H5T_OPAQUE:
    case H5T_REFERENCE:
    case H5T_TIME:
	errHandler("This datatype is not supported");
	break;
    default:
	errHandler("Encountered unknown datatype");
	break;
    }
    /*
     * We shouldn't ever get here
     */
    return mxUNKNOWN_CLASS;
}


/*
 * Free any open identifiers.
 */
void h5MexAtExit(void)
{
    int i;
    
    for (i = 0; i < Num_ID_Lists; i++)
    {
        if (listArray[i].list.next != NULL)
        {
	    CleanupList(&listArray[i]);
        }
    }

}

/*
 * Reads in an attribute into a buffer
 */

char * read_attribute(hid_t attribute, hid_t aspace, hid_t atype, int ndims, int mlrank, int *mldims, mxArray **ml_attribute)
{
    char     *attr_val;
    hid_t     mem_dtype;
    mxClassID mltype;
    hsize_t   nelems;
    size_t    num_bytes;

    if (is_array(atype) || is_compound(atype) || is_string(atype) || is_vlen(atype))
    {
	*ml_attribute = mxCreateCellArray(mlrank, (const int *) mldims);

	/*
	 * Allocate memory for the buffer which will be passed into H5Aread
	 * to store the complete data that is read.  This will be different
	 * when indexing is implemented.
	 */

	nelems = get_num_elements(aspace);
	num_bytes = H5Tget_size(atype);
	attr_val = mxMalloc(nelems * num_bytes);

    }else
    {
	/*
	 * Otherwise, if you have an atomic, non-string datatype, you
	 * can create the appropriate numeric matrix.         
	 */

	mltype = HDF5_to_ML_datatype(atype);
	*ml_attribute = mxCreateNumericArray(mlrank, (const int *) mldims, mltype, mxREAL);
	attr_val = mxGetData(*ml_attribute);
    }

    /*
     * Read the whole dang attribute into the buffer, which is a serialized buf.
     */    

    mem_dtype = get_mem_dtype(atype);
    H5Aread(attribute, mem_dtype, attr_val);  

    /*
     * Close all IDs
     */
    close_datatype(mem_dtype);
    return attr_val;
}
        
/*
 * open_attribute opens an attribute at a given location.  If
 * it errors if it can't find the attribute.
 */
hid_t open_attribute(hid_t loc_id, const char *attr_name)
{
    hid_t attr;
    attr = H5Aopen_name(loc_id, attr_name);
    if (attr < 0)
    {
	char errmsg[500];
	sprintf(errmsg, "Could not open attribute: %s", attr_name);
	errHandler(errmsg);
    }
    AddIDToList(attr, AttributeList);
    return attr;
}

/*
 * Closes an attribute and removes the identifier from the list
 */
void close_attribute(hid_t attribute)
{

    if (H5Aclose(attribute) < 0)
    {
	/* warn */
    }
    DeleteIDFromList(attribute, AttributeList);
}

/*
 * Opens a dataset.  Errors out if it could not open
 */      
hid_t open_dataset(hid_t loc_id, const char *dset_name)
{
    hid_t dset;
    dset = H5Dopen(loc_id, dset_name);
    if (dset < 0)
    {
	char errmsg[500];
	/*
	 * Do some sort of clean-up
	 */
	sprintf(errmsg, "Could not open dataset: %s", dset_name);
	errHandler(errmsg);
    }
    AddIDToList(dset, DatasetList);
    return dset;
}

/*
 * Closes a dataset identifier.
 */
void close_dataset(hid_t dataset)
{

    if (H5Dclose(dataset) < 0)
    {
	/* warn */
    }
    DeleteIDFromList(dataset, DatasetList);
}

/*
 * Gets a dataspace from either an attribute or a dataset, which is
 * specified by the boolean, isAttribute.  This is an open identifier
 * which is then placed on the list.
 */

hid_t get_dataspace(hid_t loc_id, bool isAttribute)
{
    hid_t dataspace;

    if (isAttribute)
    {
	dataspace = H5Aget_space(loc_id);
    }else
    {
	dataspace = H5Dget_space(loc_id);
    }

    AddIDToList(dataspace, DataspaceList);
    return dataspace;
}

/*
 * Closes a dataspace
 */
void close_dataspace(hid_t dataspace)
{

    if (H5Sclose(dataspace) < 0)
    {
	/* warn */
    }
    DeleteIDFromList(dataspace, DataspaceList);
}

/*
 * Open a file.  Errors out if it could not open.
 */
hid_t open_file(const char *filename, unsigned flags, hid_t access_id)
{
    hid_t fid;
    char errmsg[500];    

    fid = H5Fopen(filename, flags, access_id);

    if (fid <= 0)
    {
	if (H5Fis_hdf5(filename) <= 0)
	{
	    sprintf(errmsg, "Not a valid HDF5 file: %s", filename);
	}else
	{
	    sprintf(errmsg, "Unable to open file: %s", filename);
	}
        errHandler(errmsg);
    }

    AddIDToList(fid, FileList);
    return fid;
}

/*
 * Closes an open file identifier
 */
void close_file(hid_t file)
{

    H5Fclose(file);
    DeleteIDFromList(file, FileList);
}

/*
 * Open a datatype.  Errors out if it could not open.
 */
hid_t get_datatype(hid_t loc_id, bool isAttribute)
{
    hid_t dtype;

    if (isAttribute)
    {    
	dtype = H5Aget_type(loc_id);
    }else
    {
	dtype = H5Dget_type(loc_id);
    }

    AddIDToList(dtype, DatatypeList);
    return dtype;
}

/*
 * Closes an open datatype identifier
 */

void close_datatype(hid_t datatype)
{

    if (H5Tclose(datatype) < 0)
    {
	/* warn */
    }
    DeleteIDFromList(datatype, DatatypeList);
}


/*
 * Open a group.  Errors out if it could not open.
 */
hid_t open_group(hid_t loc_id, const char *group_name)
{
    hid_t group;
    
    group = H5Gopen(loc_id, group_name);

    if (group <= 0)
    {
	char errmsg[500];

	sprintf(errmsg, "Unable to open group: %s", group_name);
        errHandler(errmsg);
    }

    AddIDToList(group, GroupList);
    return group;
}

/*
 * Closes an open group identifier
 */
void close_group(hid_t group)
{

    if (H5Gclose(group) < 0)
    {
	/* warn */
    }
    DeleteIDFromList(group, GroupList);
}

/*
 * Determines whether or not a full pathname is a dataset.  fid
 * is an open identifier to the HDF5 file
 */
bool is_dataset(hid_t fid, const char *datasetname)
{    hid_t id;

    /*
     * Note: We don't want to call open_dataset here, because
     * we don't want to error out if it isn't a dataset.  We
     * are just checking to see if it is a dataset.
     */
    id = H5Dopen(fid, datasetname);

    if (id < 0)
    {
	return false;
    }else
    {
	H5Dclose(id);
	return true;
    }
}

/*
 * Determines whether or not a full pathname is an attribute.  fid
 * is an open identifier to the HDF5 file
 */
bool is_attribute(hid_t fid, const char *datasetname)
{
    hid_t attr_id;
    hid_t loc_id;  /* Place to open the attribute */
    char *last_sep_ptr;
    char *location;
    char *attributename;
    int   namelen;
    int   tmp;

    namelen = strlen(datasetname);

    last_sep_ptr = strrchr(datasetname, '/');
    if (last_sep_ptr == NULL)
    {
	errHandler("Attribute name must contain the full pathname");
    }

    attributename = &last_sep_ptr[1];
    
    tmp = last_sep_ptr - datasetname;
    location = mxMalloc(((tmp + 1) * sizeof(char) + 1));
    strncpy(location, datasetname, (tmp + 1));
    location[tmp+1] = 0;

    /*
     * Note: In this function, we don't want to use our open/close
     * routines with the errHandler calls, because we are simply
     * checking the validity of whether or not something is an attribute.
     */

    if (is_dataset(fid, location))
    {
	loc_id = H5Dopen(fid, location);
    }
    else
    {
	/*
	 * If it isn't a dataset, it has to be a group
	 */
	loc_id = H5Gopen(fid, location);
	if (loc_id < 0)
	{
	    mxFree(location);
	    return false;
	}
    }
    attr_id = H5Aopen_name(loc_id, attributename);

    if (attr_id < 0)
    {
	mxFree(location);
	H5Gclose(loc_id);
	return false;
    }else
    {
	H5Aclose(attr_id);
	H5Gclose(loc_id);
	mxFree(location);
	return true;
    }
}

/*
 * This function takes in an mxArray and calls MATLAB to permute
 * the data.  What is returned is an mxArray with different
 * dimensionality.  This is for converting row-column data that
 * HDF5 returns into column-major MATLAB data.  The caller should
 * destroy the input mxArray.
 */
mxArray * permute(int ndims, int* dims, mxArray *ml_attr_val)
{
    int      p;
    mxArray *mcm_prhs[2];
    mxArray *mcm_plhs[1];
    double  *pr_mcm_prhs;

    mcm_prhs[0] = ml_attr_val;
    mcm_prhs[1] = mxCreateDoubleMatrix(1, ndims, mxREAL);
    pr_mcm_prhs = mxGetPr(mcm_prhs[1]);

    /* Create the new dimension order */

    pr_mcm_prhs[0] = 2;
    pr_mcm_prhs[1] = 1;

    for (p = 2; p < ndims; p++)
    {
	pr_mcm_prhs[p] = p + 1;
    }
    mexCallMATLAB(1, mcm_plhs, 2, mcm_prhs, "permute");

    mxDestroyArray(mcm_prhs[1]);
    /* mxDestroyArray(mcm_prhs[0]); */
    /* prhs[0] currently gets destroyed outside of call to permute */

    return mcm_plhs[0];
}

/*
 * This function takes in a file id and a full pathname to a
 * dataset or attribute.  It then splits apart the string and
 * returns an id to the open location (be it a dataset or group.)
 * The caller should check and see if the loc_id is okay.
 */
hid_t open_location(hid_t fid, const char *fullpathname)
{
    int   namelen;
    char *last_sep_ptr;
    int   locationlen;
    char *location;
    hid_t loc_id;

    /* Move the splitting to another function? */
    namelen = strlen(fullpathname);

    last_sep_ptr = strrchr(fullpathname, '/');
    if (last_sep_ptr == NULL)
    {
	errHandler("Name must contain the full pathname");
    }
    
    locationlen = last_sep_ptr - fullpathname;
    location = mxMalloc(((locationlen + 1) * sizeof(char) + 1));
    strncpy(location, fullpathname, (locationlen + 1));
    location[locationlen + 1] = 0;

    if (is_dataset(fid, location))
    {
	loc_id = open_dataset(fid, location);
    }
    else
    {
	/*
	 * If it isn't a dataset, it has to be a group
	 */
	loc_id = open_group(fid, location);
    }
    mxFree(location);
    return loc_id;
}


/*
 * Returns number of dimensions suitable for passing into mxCreate*
 * functions based on the number of HDF5 dimensions
 */

int get_ml_rank(int h5_rank)
{
    int mlrank;

    if (h5_rank < 2)
    {
	mlrank = 2;
    }else
    {
	mlrank = h5_rank;
    }

    return mlrank;
}

/*
 * Returns dimensions suitable for passing into mxCreate* functions
 * based on HDF5 dataset/array dimensions
 */

int * get_ml_dims(int mlrank, int ndims, hsize_t *h5_dims)
{
    int *mldims = (int *) mxMalloc(mlrank * sizeof(int));
    
    /*
     * Make this column-wise, because everything will
     * be permuted to look like how it does in the HDF5
     * file
     */
    if (ndims == 0)
    {
	mldims[0] = 1;
	mldims[1] = 1;
    }else if (ndims == 1)
    {
	mldims[0] = (int) h5_dims[0];
	mldims[1] = 1;
    }else
    {
	/*
	 * Again, we do trickery with the dimensions because we
	 * know that they will be permuted before being passed back
	 * to MATLAB
	 */
	int counter;
	for (counter = 0; counter < mlrank; counter++)
	{
	    mldims[counter] = (int) h5_dims[mlrank-counter-1];
	}
    }
    return mldims;
}


/*
 * This basically just copies over a scalar atomic type as an mxArray*.
 */
mxArray * get_atomic_from_buf(char * data_val, int index, int nbytes_to_copy, hid_t datatype)
{
    mxClassID mltype;
    mxArray  *member;
    void     *member_pr;

    mltype = HDF5_to_ML_datatype(datatype);

    member = mxCreateNumericMatrix(1, 1, mltype, mxREAL);
    member_pr = mxGetData(member);
    memcpy(member_pr, data_val+index, nbytes_to_copy);
    
    return member;
}

/*
 * Returns a numeric array, representing a single VL element,
 * which must then be stuffed into a cell array.
 */

mxArray * get_vlen_element(hid_t datatype, char *data_val, int index, int extra_index){
    hvl_t    *vl_data_val;
    mxArray  *element;
    void     *element_pr;
    int       nmembers;
    int       mdims[2];
    mxClassID mltype;
    hid_t     base_datatype;
    int       num_bytes_to_copy;
    int       vl_index;
    int       index_into_data_val = 0;
    int       ecounter;     /* Each member of the VL datatype is an array. */

    mxArray*  mcm_prhs[1];  /* Used for mexCallMATLAB */
    mxArray*  mcm_plhs[1];

    /*
     * In order to access the data correctly, cast the bytes to
     * hvl_t things
     */

    vl_data_val = (hvl_t *) data_val;
    vl_index = index + extra_index;
    nmembers = vl_data_val[vl_index].len;

    mdims[0] = 1;
    mdims[1] = nmembers;

    base_datatype = H5Tget_super(datatype);
    num_bytes_to_copy = nmembers * H5Tget_size(base_datatype);

    /*
     * Need to test if this is okay with enums...
     */
    if (is_atomic(base_datatype) || is_enum(base_datatype))
    {    
	mltype = HDF5_to_ML_datatype(base_datatype);
	element = mxCreateNumericArray(2, mdims, mltype, mxREAL);
	element_pr = mxGetData(element);
	memcpy(element_pr, vl_data_val[vl_index].p, num_bytes_to_copy);
    
    }else if (is_array(base_datatype))
    {
	/* Convert index from VL index into byte index...
	*/

	element = mxCreateCellArray(2, mdims);

	for (ecounter = 0; ecounter < nmembers; ecounter++)
	{
	    mxSetCell(element, ecounter, get_array_member(base_datatype, H5Tget_super(base_datatype), (char *) vl_data_val[vl_index].p, ecounter * H5Tget_size(base_datatype)));
	}
    }else if (is_vlen(base_datatype))
    {
	/* 
         * This means we have vlens of vlens
	*/
	element = mxCreateCellArray(2, mdims);

	for (ecounter = 0; ecounter < nmembers; ecounter++)
	{
	    mxSetCell(element, ecounter, get_vlen_element(base_datatype, (char *) vl_data_val[vl_index].p, ecounter, 0));
	}
    }else if (is_compound(base_datatype))
    {
	element = mxCreateCellArray(2, mdims);

	for (ecounter = 0; ecounter < nmembers; ecounter++)
	{
	    mxSetCell(element, ecounter, get_compound_element(base_datatype, (char *) vl_data_val[vl_index].p, ecounter * H5Tget_size(base_datatype)));
	}	
    }else if (is_string(base_datatype))
    {
	element = mxCreateCellArray(2, mdims);

	for (ecounter = 0; ecounter < nmembers; ecounter++)
	{
	    mxSetCell(element, ecounter, get_string_from_buf(base_datatype, vl_data_val[vl_index].len, ecounter * H5Tget_size(base_datatype), (char *) vl_data_val[vl_index].p));
	}	
    }
    
    close_datatype(base_datatype);

    /*
     * Now wrap everything up in an h5vlen
     */
    mcm_prhs[0] = element;

    mexCallMATLAB(1, mcm_plhs, 1, mcm_prhs, "hdf5.h5vlen");
    mxDestroyArray(element);
    return mcm_plhs[0];
}

/*
 * Returns an hdf5.h5compound, given a data buffer and the compound type
 * and an index into the buffer
 */
mxArray * get_compound_element(hid_t datatype, char* data_val, int index_into_buffer)
{
    mxArray *element;
    int      mcounter;  /* member counter */
    int      nmembers;  /* num members in compound datatype */
    int      edims[2];  /* dimensions of the element */
    size_t   offset;    /* num bytes to the offset for each member */
    hid_t    packed_dtype;

    mxArray *mcmplhs[1]; /* Used for mexCallMATLAB */

    packed_dtype = H5Tcopy(datatype);
    H5Tpack(packed_dtype);

    nmembers = H5Tget_nmembers(packed_dtype);

    edims[0] = nmembers;
    edims[1] = 1;

    mexCallMATLAB(1, mcmplhs, 0, NULL, "hdf5.h5compound");
    element = mcmplhs[0];

    for (mcounter = 0, offset = 0; mcounter < nmembers; mcounter++)
    {
	hid_t    tmptype;
	hid_t    mtype;     /* member datatype */
	mxArray *member;    /* member */
	int      index;	    /* num of bytes in the data_val buf to start pointing
			     * at for the next member read */
	int nbytes_to_copy; /* number of bytes to copy */
	
	mxArray *mm_prhs[3];

	offset = H5Tget_member_offset(packed_dtype, mcounter);
	tmptype = H5Tget_member_type(packed_dtype, mcounter);
	mtype = get_mem_dtype(tmptype);
	
	index = index_into_buffer + offset;
	nbytes_to_copy = H5Tget_size(mtype);
	
	if (is_atomic(mtype) || is_enum(mtype))
	{
	    member = get_atomic_from_buf(data_val, index, nbytes_to_copy, mtype);
	}else if (is_string(mtype))
	{
	    member = get_string_from_buf(mtype, nbytes_to_copy, index, data_val);
	}else if (is_array(mtype))
	{
	    hid_t base_mtype = H5Tget_super(mtype);
	    member = get_array_member(mtype, base_mtype, data_val, index);
	    close_datatype(base_mtype);

	}else if (is_compound(mtype))
	{
	    /* Now you are dealing with a nested compound type as a member of
             * this compound type.  This recursive call should be 
             * straightforward, so long as index is correct.
	     */
	    
	    member = get_compound_element(mtype, data_val, index);
	}else if (is_vlen(mtype))
	{
	    member = get_vlen_element(mtype, data_val + index, 0, 0);
	}else
	{
	    errHandler("Date/time as compound elements not yet implemented");
	}

	/*
	 * Can't free member_name, because we use it when setting the .Name field
	 */
	mm_prhs[0] = element;
	mm_prhs[1] = mxCreateString(H5Tget_member_name(datatype, mcounter));
	mm_prhs[2] = member;
	mexCallMATLAB(0, NULL, 3, mm_prhs, "addMember");
	close_datatype(tmptype);
	close_datatype(mtype);
    } 
    return element;
}

/*
 * Returns an hdf5.h5array which is a single member of an array type
 */
mxArray * get_array_member(hid_t datatype, hid_t base_datatype, char* data_val, int index){
    
    mxArray *data;
    mxArray *permuted_data;
    mxArray *mcm_prhs[1];
    mxArray *mcm_plhs[1];

    if (is_array(base_datatype) || is_compound(base_datatype) || is_vlen(base_datatype) || is_string(base_datatype))
    {

	int arank, mlrank;
	hsize_t adims[H5S_MAX_RANK];
	int *mldims;
	hsize_t num_bytes;
	int nelems;
	int ecounter;

	/*
	 * Then you will be returning a CELL ARRAY of the dimensions of
	 * the array.  When you get down to the bottom layer, it will enter
	 * the else-clause, and a numeric array will be formed
	 */
	num_bytes = H5Tget_size(datatype);
	arank = H5Tget_array_ndims(datatype);
	H5Tget_array_dims(datatype, adims, NULL); 

	mlrank = get_ml_rank(arank);
	mldims = get_ml_dims(mlrank, arank, adims);

	nelems = get_num_array_members(mlrank, mldims);
   		    
	data = mxCreateCellArray(mlrank, (const int *) mldims);
    
	if (is_compound(base_datatype))
	{
	    for (ecounter = 0; ecounter < nelems; ecounter++)
	    {
		mxSetCell(data, ecounter, get_compound_element(base_datatype, data_val, (ecounter * H5Tget_size(base_datatype) + index)));
	    }
	}else if (is_vlen(base_datatype))
	{
	    for (ecounter = 0; ecounter < nelems; ecounter++)
	    {
		hvl_t * vl_data_val = (hvl_t *) data_val;
		int extra_index;

		extra_index = nelems * (index / ((long) num_bytes));
		mxSetCell(data, ecounter, get_vlen_element(base_datatype, data_val, ecounter, extra_index));
	    }	
	}
	else if (is_string(base_datatype))
	{
	    for (ecounter = 0; ecounter < nelems; ecounter++)
	    {
		mxSetCell(data, ecounter, get_string_from_buf(base_datatype, H5Tget_size(base_datatype), ecounter * H5Tget_size(base_datatype) + index, data_val));
	    }
	}
	else
	{
	    for (ecounter = 0; ecounter < nelems; ecounter++)
	    {
		mxSetCell(data, ecounter, get_array_member(base_datatype, H5Tget_super(base_datatype), data_val, (ecounter * H5Tget_size(base_datatype)) + (index)));
	    }
	}
	permuted_data = permute(mlrank, mldims, data);
	mxFree(mldims);
	mxDestroyArray(data);
    }else
    {
	/* 
	 * When you get here, this means that we are dealing with a dataset of
	 * type ARRAY where the underlying base type is an atomic numeric.  This
	 * corresponds to a cell array of numeric arrays in MATLAB.
	 */
        
	permuted_data = get_numeric_array_from_buf(index, data_val, datatype, base_datatype);
	/*
	 * No need to permute, because we do it correctly in 
         * get_numeric_array_from_buf
	 */
    }

    mcm_prhs[0] = permuted_data;

    mexCallMATLAB(1, mcm_plhs, 1, mcm_prhs, "hdf5.h5array");
    mxDestroyArray(permuted_data);

    return mcm_plhs[0];
}


/*
 * Given the length of the string, the appropriate index into the buffer,
 * and the data buffer, returns an mxArray * which is a MATLAB char array.
 * Make sure that data_val* isn't necessarily a pointer to where the data
 * starts, but to where the string data in question starts
 */

mxArray * get_string_from_buf(hid_t datatype, int string_length, int index, char *data_val)
{
    mxArray *mcm_plhs[1];
    mxArray *mcm_prhs[2];
    mxArray *mm_prhs[2];

    char *temp_str;
    temp_str = mxMalloc(string_length * sizeof(char) + 1);

    memcpy(temp_str, data_val + index, string_length);
    temp_str[string_length] = 0;
    
    /* Type of padding */
    switch(H5Tget_strpad(datatype))
    {
	mxArray *tmpArray[1];
	
	case H5T_STR_NULLTERM:
	    mcm_prhs[0] = mxCreateString(temp_str);
	    mcm_prhs[1] = mxCreateString("nullterm");
	    break;
	case H5T_STR_NULLPAD:
	    mcm_prhs[0] = mxCreateString(temp_str);
	    mcm_prhs[1] = mxCreateString("nullpad");
	    break;
	case H5T_STR_SPACEPAD:
    	    /*
	     * If strpad, then do a deblank- don't use strrchr!
	     */

	    tmpArray[0] = mxCreateString(temp_str);
	    mexCallMATLAB(1, mcm_prhs, 1, tmpArray, "deblank");
	    mxDestroyArray(tmpArray[0]);
	    mcm_prhs[1] = mxCreateString("spacepad");
	    break;
	default:
	    mcm_prhs[0] = mxCreateString(temp_str);
	    mcm_prhs[1] = mxCreateString("nullterm");
	    break;
    } 

    mexCallMATLAB(1, mcm_plhs, 2, mcm_prhs, "hdf5.h5string");
    mxDestroyArray(mcm_prhs[0]);
    mxDestroyArray(mcm_prhs[1]);

    /*
     * Set the length
     */
    mm_prhs[0] = mcm_plhs[0];
    mm_prhs[1] = mxCreateDoubleScalar(string_length);
    mexCallMATLAB(0, NULL, 2, mm_prhs, "setLength");

    mxFree(temp_str);
    mxDestroyArray(mm_prhs[1]);
    return mm_prhs[0];
}

/*
 * Creates a MATLAB numeric array from a buffer of H5T_ARRAY datatype whose
 * base type is a non-string atomic type.  Add an assert to this effect...
 */
mxArray * get_numeric_array_from_buf(int index, char *data_val, hid_t datatype, hid_t base_datatype)
{
    mxArray     *permuted_array;
    mxArray     *array_data;
    signed long *array_data_pr;
    hsize_t     *adims;
    int         *mldims;
    int          arank;
    mxClassID    mltype;
    int          mlrank;
    int          num_bytes;

    arank = H5Tget_array_ndims(datatype);
    adims = (hsize_t *) mxMalloc(arank * sizeof(hsize_t));
    H5Tget_array_dims(datatype, adims, NULL); 

    mlrank = get_ml_rank(arank);
    mldims = get_ml_dims(mlrank, arank, adims);

    mltype = HDF5_to_ML_datatype(base_datatype);

    array_data = mxCreateNumericArray(mlrank, (const int *) mldims, mltype, mxREAL);
    array_data_pr = mxGetData(array_data);
    
    num_bytes = H5Tget_size(datatype);
    memcpy(array_data_pr, data_val+index, num_bytes);

    permuted_array = permute(mlrank, mldims, array_data);

    mxFree(adims);
    mxFree(mldims);
    mxDestroyArray(array_data);
    
    return permuted_array;
} 

/*
 * Converts the serial data byte buffer into meaningful MATLAB stuff
 */

mxArray * convert_data_to_ML(hid_t dataspace, hid_t datatype, int ndims, int mlrank, int *mldims, mxArray* data, char *data_val)
{
    /*
     * nelems is the number of ELEMENTS in the dataset.  num_bytes is the
     * number of bytes of the DATATYPE of the dataset.
     */

    mxArray *permuted_data;
    hsize_t  nelems;
    hsize_t  num_bytes;
    mxArray *mcm_plhs[1];
    mxArray *mcm_prhs[1];

    nelems = get_num_elements(dataspace);
    num_bytes = H5Tget_size(datatype);

    if (is_string(datatype))
    {
	/* For each dataset element, create a string from the data and then
	 * stuff it into the cell array
	 */
	int ecounter; /* element counter */	
	for (ecounter = 0; ecounter < nelems; ecounter++)
	{
	    mxArray *string;
	    int      index = ecounter * num_bytes;

	    string = get_string_from_buf(datatype, (int) num_bytes, index, data_val);

	    mxSetCell(data, ecounter, string);
	}
    }else if (is_compound(datatype))
    {
	int    ecounter;    /* element counter */
	hid_t  packed_type; /* packed datatype to remove padding from compound */
	int    num_members;
	int    m;

	packed_type = H5Tcopy(datatype);
	H5Tpack(packed_type);

/*	 
	num_bytes = H5Tget_size(packed_type);
*/	
	num_members = H5Tget_nmembers(packed_type);
	for (m = 0, num_bytes = 0; m < num_members; m++)
	{
	    hid_t mtype;
	    mtype = H5Tget_member_type(packed_type, m);
	    num_bytes += H5Tget_size(mtype);
	    close_datatype(mtype);
	}

	for (ecounter = 0; ecounter < nelems; ecounter++)
	{
	    mxSetCell(data, ecounter, get_compound_element(packed_type, data_val, ecounter * num_bytes));
	}
	close_datatype(packed_type);
    }else if (is_array(datatype))
    {
	int   ecounter;
	hid_t base_datatype;
	
	/*
	 * base_datatype is what the present array is composed of
	 */
	base_datatype = get_base_datatype(datatype);

	for (ecounter = 0; ecounter < nelems; ecounter++)
	{
	    mxSetCell(data, ecounter, get_array_member(datatype, base_datatype, data_val, ecounter * num_bytes));
	}

	close_datatype(base_datatype);
    }else if (is_vlen(datatype))
    {
	int ecounter;

	for(ecounter=0; ecounter < nelems; ecounter++) {	    
	    mxSetCell(data, ecounter, get_vlen_element(datatype, data_val, ecounter, 0));
	}
    }

    if (nelems == 1)
    {
	permuted_data = data;
    }else
    {
	permuted_data = permute(mlrank, mldims, data);
	mxDestroyArray(data);
    }

    if (!is_atomic(datatype) &&  (!is_enum(datatype)))
    {
	mcm_prhs[0] = permuted_data;
	mexCallMATLAB(1, mcm_plhs, 1, mcm_prhs, "cell2mat");
	mxDestroyArray(permuted_data);
	return mcm_plhs[0];
    }else if (is_enum(datatype))
    {
	/*
	 * Now that we have the permuted data, we need to wrap it up into
	 * an hdf5.h5enum.
	 */
	mxArray *mm_prhs[3];
	mxArray *mm_plhs[1];
	int      enum_counter;
	int      num_enum_members;
	int      edims[2];
	void    *mm_prhs2_pr;
	hid_t    base_type;
	hid_t    mem_dtype;

	mm_prhs[0] = permuted_data;
	mem_dtype = get_mem_dtype(datatype);

	num_enum_members = H5Tget_nmembers(mem_dtype);
	edims[0] = 1;
	edims[1] = num_enum_members;
	mm_prhs[1] = mxCreateCellArray(2, edims);
	base_type = H5Tget_super(mem_dtype);
	mm_prhs[2] = mxCreateNumericArray(2, edims, HDF5_to_ML_datatype(base_type), mxREAL);
	mm_prhs2_pr = (char *) mxGetData(mm_prhs[2]);

	for (enum_counter = 0; enum_counter < num_enum_members; enum_counter++)
	{
	    hsize_t value; /* Just go for the biggest int there could be */
	    hid_t err_id;

	    mxSetCell(mm_prhs[1], enum_counter, mxCreateString(H5Tget_member_name(mem_dtype, enum_counter)));
	    err_id = H5Tget_member_value(mem_dtype, enum_counter, &value);
	    memcpy((char *) mm_prhs2_pr + (H5Tget_size(base_type) * enum_counter), &value, H5Tget_size(base_type));
	    
	}

	mexCallMATLAB(1, mm_plhs, 3, mm_prhs, "hdf5.h5enum");
	close_datatype(base_type);
	close_datatype(mem_dtype);
	return mm_plhs[0]; 	
    }else
    {
	return permuted_data;
    }
}

