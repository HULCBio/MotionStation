/*
 * hdf5utils.h --- Include file for HDF5 mex-files
 *
 * Copyright 1984-2002 The MathWorks, Inc. 
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:59:52 $ */

#ifndef HDFUTILS_H
#define HDFUTILS_H

/*
 * Set this to be TRUE to suppress HDF5 lib debug info
 */

#define SUPPRESS_BACKTRACE true

/* 
 * Macro to compute the number of fieldnames that a info struct has
 */

#define GET_NUMBER_FIELDNAMES(ftype) sizeof(ftype) / sizeof(*ftype)

/*
 * The order of the lists in this enum must match the order 
 * of the listArray below.  Also, on mexAtExit() these lists
 * are cleaned up in the order in which they appear here.
 */

typedef enum
{
    DatatypeList = 0,
    DataspaceList,
    DatasetList,
    AttributeList,
    GroupList,
    FileList,
    Num_ID_Lists        /* This one should always be last */
} IDList;

/* 
 * Adds an open identifier to a given ID list
 */

extern int AddIDToList(hid_t id, IDList list);

/*
 * Deletes an identifier from the given ID list
 */
extern void DeleteIDFromList(hid_t id, IDList list);

/*
 * Initializes all ID lists
 */
void InitializeLists(void);

/*
 * The group_info struct contains all the relevant information about the
 * HDF5 objects within a given group.  This includes member groups, datasets,
 * named datatypes, softlinks, and the object names
 */
struct group_info {
    int num_groups;
    int current_group;
    int num_datasets;
    int current_dataset;
    int num_datatypes;
    int current_datatype;
    int num_links;
    int current_link;
    int num_attributes;
    int current_attribute;
    char **group_names;
    char **dataset_names;
    char **named_datatype_names;
    char **link_names;
    char **attribute_names;
    int *datatype_class;
    unsigned long **objno;
    unsigned *nlink;
};

/*
 * Some definitions since pointers to group_infos are used everywhere
 */
typedef struct group_info group_info;
typedef struct group_info * ginfo_ptr;

/*
 * Fieldnames for the Group Structure that is returned in the info struct
 */
static const char *group_fields[] = {"Filename",
                                     "Name",
                                     "Groups",
                                     "Datasets",
                                     "Datatypes",
                                     "Links",
                                     "Attributes"};

/*
 * Fieldnames for the Dataset Structure that is returned in the info struct
 */
static const char *dataset_fields[] = {"Filename",
                                       "Name",
                                       "Rank",
                                       "Datatype",
                                       "Dims",
                                       "MaxDims",
                                       "Layout",
                                       "Attributes",
                                       "Links",
                                       "Chunksize",
                                       "Fillvalue"};

/*
 * Fieldnames for the Datatype Structure that is returned in the info struct
 */
static const char *datatype_fields[] = {"Name",
                                        "Class",
                                        "Elements"};

/*
 * Fieldnames for the Link Structure that is returned in the info struct
 */
static const char *link_fields[] = {"Name",
                                    "IsHardLink",
                                    "Target"};

/*
 * Fieldnames for the Attribute Structure that is returned in the info struct, if
 * we are not reading in the actual values of the attributes
 */
static const char *attribute_no_value_fields[] = {"Filename",
						  "Name",
                                                  "Rank",
                                                  "Datatype",
                                                  "Dims",
                                                  "MaxDims"};

/*
 * Fieldnames for the Attribute Structure that is returned in the info struct, if
 * we are reading the values of the attributes.
 */
static const char *attribute_fields[] = {"Filename",
					 "Name",
                                         "Value"};

/*
 * error handler which cleans up and then calls mexErrMsgTxt on the
 * given error message
 */

void        errHandler(char *);   

/* 
 * Gets MATLAB array dims for a dataset, given HDF5 dims, MATLAB 
 * rank, and HDF5 size
 */

int      *  get_ml_dims(int, int, hsize_t *); 

/*
 * Gets MATLAB rank (i.e. num of dimensions
 */

int         get_ml_rank(int);

/*
 * Gets HDF5 dimensions
 */

mxArray *   get_dims(hid_t);

/*
 * Gets maximum HDF5 dimensions
 */
mxArray *   get_max_dims(hid_t);
int         get_num_array_members(int, int *);
int	    get_rank(hid_t);
extern void h5MexAtExit(void);
mxClassID   HDF5_to_ML_datatype(hid_t);
hsize_t     get_num_elements(hid_t);
char *	    read_attribute(hid_t, hid_t, hid_t, int, int, int *, mxArray**);

/*
 * These functions open an identifier or get an open identifier
 * and add them to the appropriate ID list
 */
hid_t	    get_datatype(hid_t, bool);
hid_t	    open_attribute(hid_t, const char *);
hid_t	    open_dataset(hid_t, const char *);
hid_t	    open_file(const char *, unsigned, hid_t);
hid_t	    open_group(hid_t, const char *);
hid_t	    get_dataspace(hid_t, bool);

/*
 * These close_* function close identifiers and remove them from
 * their proper ID lists
 */
void	    close_group(hid_t);
void	    close_dataspace(hid_t);
void	    close_datatype(hid_t);
void	    close_attribute(hid_t);
void	    close_dataset(hid_t);
void	    close_file(hid_t);

/*
 * These is_* functions verify whether or not something is a
 * type of HDF5 datatype/object
 */
bool	    is_dataset(hid_t, const char *);
bool	    is_attribute(hid_t, const char *);
bool	    is_array(hid_t);
bool	    is_compound(hid_t);
bool	    is_vlen(hid_t);
bool	    is_atomic(hid_t);
bool	    is_string(hid_t);
bool	    is_enum(hid_t);

/*
 * Opens a location in an HDF5 file given a fid and name of the location
 */
hid_t	    open_location(hid_t, const char *);

/*
 * Permutes an array to make it column-major
 */
mxArray *   permute(int, int*, mxArray *);

/*
 * Get all the information about the objects in a group
 */
herr_t	    populate_group_info(hid_t, const char *, ginfo_ptr);

/*
 * Get all of the information about the the attributes in a location
 */
herr_t	    populate_attributes(hid_t, const char *, ginfo_ptr);

/*
 * Get the base datatype, if any.
 */
hid_t	    get_base_datatype(hid_t);

/*
 * Get the memory datatype of the data that is to be read in
 */
hid_t       get_mem_dtype(hid_t);

/* 
 * These functions transform the serialized buffer of data into
 * appropriate MATLAB type stuff
 */

mxArray  * convert_data_to_ML(hid_t, hid_t, int, int, int *, mxArray*, char *);
mxArray  * get_string_from_buf(hid_t, int, int, char *);
mxArray  * get_numeric_array_from_buf(int, char *, hid_t, hid_t);
mxArray  * get_array_member(hid_t, hid_t, char *, int);
mxArray  * get_compound_element(hid_t, char *, int);
mxArray  * get_vlen_element(hid_t, char *, int, int);
mxArray  * get_atomic_from_buf(char *, int, int, hid_t);

#endif
