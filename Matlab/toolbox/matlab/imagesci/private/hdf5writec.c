#include "mex.h"
#include "hdf5.h"
#include "hdf5writec.h"

/* mexFunction - MATLAB-HDF5lib gateway.
 *
 * prhs[0] - File description struct with fields:
 *           .Filename (string)
 *           .WriteMode (string)
 *
 * prhs[1] - Cell array of dataset/attribute detail structures:
 *
 *         For datasets the following fields are required:
 *           .Location  (cell)   - The group hierarchy for the dataset
 *           .Name      (string)
 *
 *         For attributes the following fields are required:
 *           .AttachedTo (string) - The object the attribute describes
 *           .AttachType (string) - The object described (group, dataset, etc.)
 *           .Name       (string)
 *
 * prhs[n] - A Dataset or attribute (mxArray of arbitrary type)
 *
 * Datatype translation rules (MATLAB --> HDF5):
 *
 *   (1) If the data is numeric, the HDF5 dataset/attribute
 *       contains an appropriate HDF5 native datatype and the size of
 *       the dataspace is the same size as the array.  It is NOT an
 *       HDF5 array.
 *
 *   (2) If the data is a string, the HDF5 file contains a
 *       single element dataset, whose element is the null-terminated
 *       string.
 *
 *   (3) If the data is a cell array of strings, the HDF5 
 *       datatset/attrbute has an HDF5 string datatype.  The dataspace
 *       has the same size as the cell array.  The string elements are
 *       null-terminated, but all share the same maximum length.
 *
 *   (4) If the data is a cell array and all of the cells contain
 *       only numeric data, the HDF5 datatype is an array.  The elements
 *       of the array must be all numeric and have the same size and type.
 *       The dataspace of the array has the same dimensions of the cell
 *       array.  The datatype of the elements has the same dimensions as
 *       the first element.
 *
 *   (5) If the data is a structure array, the HDF5 datatype will
 *       be a compound type.  Individual fields in the structure will
 *       employ the same data translation rules for datatypes (e.g.,
 *       cells relate to strings or arrays, etc.).
 *
 *   (6) If the data is a UDD object, the HDF5 datatype will
 *       correspond to the type of the object.
 *       - For H5ENUM objects, the dataspace has the same dimensions
 *         as the UDD object's Data field.
 *       - For all other objects, the dataspace has the same
 *         dimensions as the array of HDF5 objects passed to the
 *         function.
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

    hid_t filePtr;
    int i;

    const mxArray *fileDetails = prhs[0];
    const mxArray *allDetails = prhs[1];
    const mxArray *details;
    const mxArray *data;

    /* Set up our relationship with the library. */
    setErrorPrinting(DEBUG);
    
    /* Open file. */
    filePtr = openFile(fileDetails);

    /* Create and write datasets and attributes. */
    for (i = 0; i < (nrhs - 2); i++)
    {
        details = mxGetCell(allDetails, i);
        data = prhs[i + 2];

        if (mxGetField(details, 0, "AttachedTo") != NULL)
            writeAttribute(filePtr, details, data);
        else
            writeDataset(filePtr, details, data);
    }    

    /* Close file. */
    closeFile(filePtr);

}



/* openFile - Open an existing file or create a new file.
 *
 * Inputs:
 *   fileDetails - Details about the file to open (MATLAB struct)
 *
 * Outputs:
 *   filePtr - HDF file pointer
 */
hid_t openFile(const mxArray *fileDetails)
{
    
    hid_t filePtr;
    char *filename;
    char *writeMode;

    filename = getFilename(fileDetails);
    if (filename == NULL)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:badFilename",
                          "openFile: Missing Filename.");

    writeMode = getWriteMode(fileDetails);
    if (writeMode == NULL)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:badWriteMode",
                          "openFile: Missing WriteMode.");

    if (!strncmp("overwrite", writeMode, 9))
    {
        filePtr = createHDF5File(filename);
    }
    else if (!strncmp("append", writeMode, 6))
    {
        filePtr = openHDF5File(filename);
    }
    else
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:badWriteMode",
                          "openFile: Bad value for WriteMode.");
    }

    mxFree(writeMode);
    mxFree(filename);

    return filePtr;

}



/* createHDF5File - Create a new HDF5 file or overwrite an existing file.
 *
 * Inputs:
 *   filenameMX - The name of the file to write
 *
 * Outputs:
 *   filePtr - HDF file pointer
 */
hid_t createHDF5File(char *filename)
{

    hid_t filePtr;

    if (DEBUG)
        mexPrintf("\n\ncreateHDF5File: Creating new file.\n");

    filePtr = H5Fcreate(filename, H5F_ACC_TRUNC, H5P_DEFAULT,
                        H5P_DEFAULT);

    if (filePtr <= 0)
    {
        mxFree(filename);
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:fileCreation",
                          "createHDF5File: Couldn't create file.");
    }

    return filePtr;

}



/* writeDataset - Write values from a MATLAB dataset to an HDF5 file.
 *
 * Inputs:
 *   filePtr - HDF file pointer
 *
 *   details - Information about the dataset
 *
 *   dataset - The dataset to write
 *
 * Outputs:
 *   None
 */
void writeDataset(hid_t filePtr,
                  const mxArray *details,
                  const mxArray *dataset)
{

    char *locationStr;
    mxArray *locationCell;
    char *nameStr;
    hid_t groupPtr;

    if (mxIsEmpty(dataset))
        return;

    /* Create Location. */
    locationCell = getLocationCell(details);
    if (locationCell == NULL)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:badLocationCell",
                          "writeDataset: No location cell array for dataset.");

    createLocation(filePtr, locationCell);
    
    /* Write the dataset. */
    groupPtr = openGroupFromCell(filePtr, locationCell);
    nameStr = getName(details);

    writeH5Dset(groupPtr, dataset, nameStr);

    H5Gclose(groupPtr);
    mxFree(nameStr);

}



/* getLocationName - Get where to write the dataset.
 *
 * Inputs:
 *   details - Details about the current dataset
 *
 * Outputs:
 *   A character array (dynamic) that contains the object location
 */
char * getLocationName(const mxArray *details)
{

    mxArray *field;

    if ((field = mxGetField(details, 0, "Location")) != NULL)
    {
        return getString(field);
    }
    else if ((field = mxGetField(details, 0, "AttachedTo")) != NULL)
    {
        return getString(field);
    }
    else
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:locationName",
                          "getLocationName: Unable to determine object location.");
    }
    
}



/* getName - Get the name of the dataset to write.
 *
 * Inputs:
 *   datasets - All of the datasets to write
 *
 *   datasetNumber - Index of the dataset to write
 *
 * Outputs:
 *   A character array (dynamic) that contains the dataset name
 */
char * getName(const mxArray *details)
{

    char *name;

    name = getString(mxGetField(details, 0, "Name"));

    if (name != NULL)
        return name;
    else
        return getDefaultName();

}



/* getString - Get a string from an mxArray.
 *
 * Inputs:
 *   stringArray - An mxArray containing a character array
 *
 * Outputs:
 *   A character array (dynamic memory) that contains the string
 */
char *getString(const mxArray *stringArray)
{

    int buflen;
    char *buffer;

    if (stringArray == NULL)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:invalidCharArray",
                          "getString: Invalid character array.");

    buflen = (mxGetM(stringArray) * mxGetN(stringArray) * sizeof(mxChar)) + 1;
    buffer = (char *) mxMalloc(buflen * sizeof(char));
    if (buffer == NULL)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:memoryAllocation",
                          "getString: Memory allocation error.");

    mxGetString(stringArray, buffer, buflen);
    return buffer;

}



/* closeFile - Close an open HDF5 file.
 *
 * Inputs:
 *   filePtr - HDF file pointer
 *
 * Outputs:
 *   None
 */
void closeFile(hid_t filePtr)
{

    if (H5Fclose(filePtr) < 0)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:fileClose",
                          "closeFile: Couldn't close file.");

}



/* writeAttribute - Write values from a MATLAB attribute to an HDF5 file.
 *
 * Inputs:
 *   filePtr - HDF file pointer
 *
 *   details - Details about the current attribute
 *
 *   attribute - The attributes to write
 *
 * Outputs:
 *   None
 */
void writeAttribute(hid_t filePtr,
                           const mxArray *details,
                           const mxArray *attribute)
{

    char *nameStr;
    char *objectStr;
    hdf5type_t objectType;
    HDF5obj *objectPtr;

    if (mxIsEmpty(attribute))
        return;

    /* Open object described by the attribute. */
    objectStr = getLocationName(details);
    objectType = getObjectType(details);
    objectPtr = getObjectPtr(filePtr, objectStr, objectType);
    
    /* Write the attribute. */
    nameStr = getName(details);
    if (attribute == NULL)
    {
        closeObject(objectPtr);
        mxFree(objectPtr);
        mxFree(objectStr);
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:attributeMissingValue",
                          "writeAttribute: Attriubte must have a value.");
    }

    writeH5Attr(objectPtr, attribute, nameStr);

    /* Clean up. */
    closeObject(objectPtr);
    mxFree(objectPtr);
    mxFree(objectStr);
    mxFree(nameStr);
    
}



/* getData - Get the data from a dataset or nested type.
 *
 * Inputs:
 *   objects - The dataset or nested type
 *
 *   objectNumber - The element to get from the dataset or type
 *
 * Outputs:
 *   Pointer to the data.  (Do not free this pointer.)
 *
 * NOTE:
 *   Use getUDDObjectData for UDD objects.
 */
mxArray * getData(const mxArray *objects, int objectNumber)
{

    mxArray *field;
    
    if ((field = mxGetField(objects, objectNumber, "Data")) != NULL)
    {
        return field;
    }
    else if ((field = mxGetField(objects, objectNumber, "Value")) != NULL)
    {
        return field;
    }
    else
    {
        return NULL;
    }

}



/* writeH5Dset - Write a dataset to the HDF5 file.
 *
 * Inputs:
 *   groupPtr - Pointer to the open HDF5 group for the dataset
 *
 *   datasetData - Pointer to the MATLAB data for the dataset
 *
 *   nameStr - Location of the dataset in the group
 *
 * Outputs:
 *   None
 */
void writeH5Dset(hid_t groupPtr, const mxArray *datasetData, char *nameStr)
{

    DtypeNode *dtypeInfo;
    hid_t dtypeID;
    hid_t dspaceID;
    hid_t dset_id;
    void *buf;

    /* It isn't possible to overwrite an existing dataset.  A new name
     * must be specified.  (True as of HDF5 rel. 1.4.2.) */
    if (isExistingDataset(groupPtr, nameStr))
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:datasetExists",
                          "writeH5Dset: Dataset names must be unique when appending data.");

    /* Create the datatype for the dataset. */
    if (mxIsNumeric(datasetData))
    {
        if (DEBUG)
            mexPrintf("writeH5Dset: Creating Native datatype.\n");
        dtypeInfo = buildNativeDtypeInfo(datasetData);
    }
    else
    {
        if (DEBUG)
            mexPrintf("writeH5Dset: Creating Composite datatype.\n");
        dtypeInfo = buildDtypeInfo(datasetData);
    }

    if (DEBUG)
        describeDtypeInfo(dtypeInfo);

    dtypeID = makeDatatype(dtypeInfo);
    if (dtypeID < 0)
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:datatypeCreation",
                          "writeH5Dset: Couldn't create dataset datatype.");
    }
    else
    {
        if (DEBUG)
            describeDtype(dtypeID);
    }

    /* Create the dataspace and dataset. */
    dspaceID = createDataspace(datasetData);
    if (dspaceID < 0)
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:dataspaceCreation",
                          "writeH5Dset: Couldn't create dataspace.");
    }

    if (DEBUG)
    {
        mexPrintf("writeH5Dset:\n");
        mexPrintf("  groupPtr = %p\n", groupPtr);
        mexPrintf("  nameStr = %s\n", nameStr);
        mexPrintf("  dtypeID = %d\n", (int) dtypeID);
        mexPrintf("  dspaceID = %d\n", (int) dspaceID);
    }

    dset_id = H5Dcreate(groupPtr, nameStr, dtypeID, dspaceID, H5P_DEFAULT);
    if (dset_id < 0)
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:datasetCreation",
                          "writeH5Dset: Couldn't create dataset.");
    }

    /* Create and fill data buffer. */
    buf = makeDataBuffer(dtypeInfo, datasetData);

    fillBuffer(buf, dtypeInfo, datasetData);

    /* Write the dataset. */
    H5Dwrite(dset_id, dtypeID, H5S_ALL, H5S_ALL, H5P_DEFAULT, buf);

    /* Clean up. */
    H5Dclose(dset_id);
    H5Sclose(dspaceID);
    H5Tclose(dtypeID);
    mxFree(buf);
    deleteDtypeInfo(dtypeInfo);

}



/* createGroup - Create a group within an HDF5 file.
 *
 * Inputs:
 *   parent - The root node of this location
 *
 *   groupNameString - The name of the group to create
 *
 * Outputs:
 *   The HDF5 identifier of the new group
 */
hid_t createGroup(hid_t parent, char *groupNameString)
{

    if (DEBUG)
        mexPrintf("createGroup: Making group \"%s\" at %d\n",
                  groupNameString, parent);

    return H5Gcreate(parent, groupNameString, 0);
}



/* closeGroup - Close a group within an HDF5 file.
 *
 * Inputs:
 *   groupPtr - The group to close
 *
 * Outputs:
 *   None
 */
void closeGroup(hid_t groupPtr)
{
    H5Gclose(groupPtr);
}



/* openHDF5File - Open/create an HDF5 file.
 *
 * Inputs:
 *   filenameMX - HDF5 file name (in an mxArray)
 *
 * Outputs:
 *   An HDF5 pointer to the new or existing file
 */
hid_t openHDF5File(char *filename)
{

    hid_t filePtr;

    filePtr = H5Fopen(filename, H5F_ACC_RDWR, H5P_DEFAULT);

    if (DEBUG)
        mexPrintf("\n\nopenHDF5File: Opening existing file.\n");

    if (filePtr <= 0)
    {
        mxFree(filename);
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:fileCreation",
                          "openHDF5File: Couldn't create file.");
    }

    return filePtr;

}



/* createDataspace - Create a container for the output data.
 *
 * Inputs:
 *   datasetData - The dataset or attribute for this dataspace
 *
 * Outputs:
 *   An HDF5 pointer to the new dataspace
 */
hid_t createDataspace(const mxArray *datasetData)
{

    hid_t dspaceID;
    hsize_t *dims;
    int rank;
    mxArray *subElement = NULL;

    /* ENUM dataspaces have all of the dataspace values in the one UDD
     * object.  As a result, we need to get the rank and dims for the 
     * UDD object's data, not the data that was passed in.  Consequently,
     * the data passed in must be 1-by-1. */
    if (getType(datasetData) == H5ENUM_UDD)
    {
        if (mxGetNumberOfElements(datasetData) > 1)
            mexErrMsgIdAndTxt("MATLAB:hdf5writec:enumCount",
                              "createDataspace: Only one ENUM object is allowed at a time");

        getUDDObjectData(datasetData, &subElement, 0);

        rank = getRank(subElement);
        dims = getDims(subElement);
    }
    else
    {
        rank = getRank(datasetData);
        dims = getDims(datasetData);
    }
    
    dspaceID = H5Screate_simple(rank, dims, NULL);

    if (DEBUG)
    {
        int i;
        mexPrintf("createDataspace: Creating a dataspace with dimensions [ ");
        for (i = 0; i < rank; i++)
            mexPrintf("%d ", (int) dims[i]);
        mexPrintf("]\n");
    }

    mxFree(dims);

    return dspaceID;
    
}



/* makeDataBuffer - Create an output buffer that will fill the dataspace.
 *
 * Inputs:
 *   info - Linked list describing the datatype for this buffer/subbuffer
 *
 *   datasetData - The part of the dataset or attribute for this buffer
 *
 * Outputs:
 *   A pointer to the new data buffer (dynamic)
 */
void * makeDataBuffer(DtypeNode *info, const mxArray *datasetData)
{
    
    int bufSize;
    void *buf;

    /* Traverse the input structure computing the buffer sized needed. */
    bufSize = computeBufferSize(info, datasetData);
    buf = mxMalloc(bufSize);

    if (buf == NULL)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:outputBufferCreation",
                          "makeDataBuffer: Couldn't create data buffer for dataset.");

    if (DEBUG)
        mexPrintf("makeDataBuffer: Allocated %d bytes for buffer.\n", bufSize);

    return buf;

}



/* fillBuffer - Add data to the output (dataspace) buffer.
 *
 * Inputs:
 *   buf - The destination buffer
 *
 *   info - Linked list describing the datatype for this buffer/subbuffer
 *
 *   datasetData - The part of the dataset or attribute for this buffer
 *
 * Outputs:
 *   The number of bytes this operation copied into the buffer
 */
int fillBuffer(void *buf, DtypeNode *info, const mxArray *datasetData)
{
    
    mxArray *permutedData = NULL;
    int bytesCopied;
    
    permute((mxArray *) datasetData, &permutedData);

    if (DEBUG)
        describeMLArray(permutedData);

    if (DEBUG)
    {
        mexPrintf("fillBuffer:\n");
        mexPrintf("  mxClassName = %s\n", mxGetClassName(permutedData));
        /* mexPrintf("  numElements = %d\n", numElements); */
        mexPrintf("  info->Size = %d\n", info->Size);
    }

    switch (info->Type)
    {
    case H5ARRAY:
        bytesCopied = fillBufferH5ARRAY(buf, info, permutedData);
        break;

    case H5ARRAY_UDD:
    case H5ENUM_UDD:
        bytesCopied = fillBufferH5ARRAY_UDD(buf, info, permutedData);
        break;

    case H5COMPOUND:
        bytesCopied = fillBufferH5COMPOUND(buf, info, permutedData);
        break;

    case H5COMPOUND_UDD:
        bytesCopied = fillBufferH5COMPOUND_UDD(buf, info, permutedData);
        break;

    case H5NATIVE:
        bytesCopied = fillBufferH5NATIVE(buf, info, permutedData);
        break;

    case H5STRING_MULTIPLE:
        bytesCopied = fillBufferH5STRING_MULTIPLE(buf, info, permutedData);
        break;

    case H5STRING_SINGLE:
        bytesCopied = fillBufferH5STRING_SINGLE(buf, info, permutedData);
        break;

    case H5STRING_UDD:
        bytesCopied = fillBufferH5STRING_UDD(buf, info, permutedData);
        break;

    case H5VLEN_UDD:
        bytesCopied = fillBufferH5VLEN_UDD(buf, info, permutedData);
        break;
            
    default:
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:unsupportedType",
                          "fillBuffer: Unsupported type.");
    }

    mxDestroyArray(permutedData);

    if (DEBUG)
        mexPrintf("  bytesCopied = %d\n", bytesCopied);

    return bytesCopied;
    
}



/* buildDtypeInfo - Create a linked list describing this datatype.
 *
 * Inputs:
 *   datasetData - The mxArray data to be examined
 *
 * Outputs:
 *   node - The linked list containing info on type, rank, and dimensions
 */
DtypeNode *buildDtypeInfo(const mxArray *datasetData)
{

    DtypeNode *dtypeInfo;
    hdf5type_t typeID;
    mxArray *subtypeData = NULL;
 
    typeID = getType(datasetData);
    dtypeInfo = newDtypeNode(typeID);

    if (DEBUG)
        mexPrintf("buildDtypeInfo: Created new dtypeInfo node (%p).\n",
                  dtypeInfo);

    switch (typeID)
    {
    case H5ARRAY:
        dtypeInfo->Rank = getRank(mxGetCell(datasetData, 0));
        dtypeInfo->Dims = getDims(mxGetCell(datasetData, 0));
        dtypeInfo->Child = buildDtypeInfo(mxGetCell(datasetData, 0));
        dtypeInfo->Size = getArrayDtypeSize(dtypeInfo);
        break;

    case H5ARRAY_UDD:
        getUDDObjectData(datasetData, &subtypeData, 0);
        dtypeInfo->Rank = getRank(subtypeData);
        dtypeInfo->Dims = getDims(subtypeData);
        dtypeInfo->Child = buildDtypeInfo(subtypeData);
        dtypeInfo->Size = getArrayDtypeSize(dtypeInfo);
        break;

    case H5COMPOUND:
        dtypeInfo->Rank = 1;
        dtypeInfo->Dims = mxMalloc(sizeof(size_t));
        dtypeInfo->Dims[0] = 1;
        dtypeInfo->Child = buildCompoundDtypeInfo(dtypeInfo, 
                                                     datasetData);
        dtypeInfo->Size = getCompoundDtypeSize(dtypeInfo);
        break;

    case H5COMPOUND_UDD:
        dtypeInfo->Rank = 1;
        dtypeInfo->Dims = mxMalloc(sizeof(size_t));
        dtypeInfo->Dims[0] = 1;
        dtypeInfo->Child = buildUDDCompoundDtypeInfo(datasetData);
        dtypeInfo->Size = getCompoundDtypeSize(dtypeInfo);
        break;

    case H5ENUM_UDD:
        getUDDObjectData(datasetData, &subtypeData, 0);
        dtypeInfo->Rank = 1;
        dtypeInfo->Dims = mxMalloc(sizeof(size_t));
        dtypeInfo->Dims[0] = 1;
        dtypeInfo->Child = buildDtypeInfo(subtypeData);
        dtypeInfo->Size = dtypeInfo->Child->Size;
        dtypeInfo->H5NativeType = dtypeInfo->Child->H5NativeType;
        setHDF5EnumDatatypeProps(dtypeInfo, datasetData, 0);
        break;

    case H5NATIVE:
        dtypeInfo->Rank = getRank(datasetData);
        dtypeInfo->Dims = getDims(datasetData);
        dtypeInfo->Size = (size_t) mxGetElementSize(datasetData);
        dtypeInfo->H5NativeType = getHDF5Datatype(datasetData);
        break;

    case H5STRING_MULTIPLE:
        dtypeInfo->Rank = 1;
        dtypeInfo->Dims = mxMalloc(sizeof(size_t));
        dtypeInfo->Dims[0] = 1;
        dtypeInfo->Size = getMaxStringLength(datasetData) + 1;
        dtypeInfo->StringFormat = H5STR_NULLTERM;
        break;

    case H5STRING_SINGLE:
        dtypeInfo->Rank = 1;
        dtypeInfo->Dims = mxMalloc(sizeof(size_t));
        dtypeInfo->Dims[0] = 1;
        dtypeInfo->Size = (size_t) mxGetNumberOfElements(datasetData) + 1;
        dtypeInfo->StringFormat = H5STR_NULLTERM;
        break;

    case H5STRING_UDD:
        dtypeInfo->Rank = 1;
        dtypeInfo->Dims = mxMalloc(sizeof(size_t));
        dtypeInfo->Dims[0] = 1;
        /* There's no need to look at all lengths, because the 
         * object contains information about the whole datatype. */
        dtypeInfo->Size = getUDDStringLength(datasetData);
        dtypeInfo->StringFormat = getStringFormat(datasetData);
        break;

    case H5VLEN_UDD:
        getUDDObjectData(datasetData, &subtypeData, 0);
        dtypeInfo->Rank = 1;
        dtypeInfo->Dims = mxMalloc(sizeof(size_t));
        dtypeInfo->Dims[0] = 1;
        dtypeInfo->Child = buildDtypeInfo(subtypeData);
        dtypeInfo->Size = sizeof(hvl_t);
        break;

    default:
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:unsupportedType",
                          "buildDtypeInfo: Unsupported datatype");
        break;
    }
    
    return dtypeInfo;

}



/* makeDatatype - Build an HDF5 datatype from a hierarchical description.
 *
 * Inputs:
 *   dtypeInfo - A tree containing datatype details
 *
 * Outputs:
 *   The HDF5 identifier of the datatype
 */
hid_t makeDatatype(DtypeNode *dtypeInfo)
{

    hid_t dtypeID;

    switch (dtypeInfo->Type)
    {
    case H5ARRAY:
    case H5ARRAY_UDD:
        if (DEBUG)
            mexPrintf("makeDatatype: making H5ARRAY\n"); 

        return H5Tarray_create(makeDatatype(dtypeInfo->Child),
                               dtypeInfo->Rank,
                               dtypeInfo->Dims,
                               NULL);
        break;

    case H5COMPOUND:
    case H5COMPOUND_UDD:
        /* Create a new datatype with the same size as the compound type.
         * Then fill in the type's members (fields). */
        if (DEBUG)
            mexPrintf("makeDatatype: making H5COMPOUND with size %d\n",
                      dtypeInfo->Size);

        dtypeID = H5Tcreate(H5T_COMPOUND, (size_t) dtypeInfo->Size);
        if (dtypeID < 0)
            mexErrMsgIdAndTxt("MATLAB:hdf5writec:compoundTypeCreation",
                              "makeDatatype: Couldn't create compound datatype.");

        addFieldsToCompound(dtypeID, dtypeInfo);
        H5Tpack(dtypeID);
        return dtypeID;
        
        break;

    case H5ENUM_UDD:
        if (DEBUG)
            mexPrintf("makeDatatype: making H5ENUM\n"); 

        dtypeID = H5Tcreate(H5T_ENUM, dtypeInfo->Size);
        if (dtypeID < 0)
            mexErrMsgIdAndTxt("MATLAB:hdf5writec:enumTypeCreation",
                              "makeDatatype: Couldn't create enum datatype.");

        addEnumConstantsToEnum(dtypeID, dtypeInfo);
        return dtypeID;
        break;

    case H5NATIVE:
        if (DEBUG)
            mexPrintf("makeDatatype: making H5NATIVE\n"); 

        return H5Tcopy(dtypeInfo->H5NativeType);
        break;

    case H5STRING_UDD:
    case H5STRING_MULTIPLE:
    case H5STRING_SINGLE:
        if (DEBUG)
            mexPrintf("makeDatatype: making H5STRING\n"); 

        dtypeID = H5Tcopy(H5T_C_S1);
        if (dtypeID < 0)
            mexErrMsgIdAndTxt("MATLAB:hdf5writec:stringTypeCreation",
                              "makeDatatype: Couldn't create string datatype.");

        H5Tset_size(dtypeID, dtypeInfo->Size);

        switch (dtypeInfo->StringFormat)
        {
        case H5STR_NULLTERM:
            H5Tset_strpad(dtypeID, H5T_STR_NULLTERM);
            break;
        case H5STR_NULLPAD:
            H5Tset_strpad(dtypeID, H5T_STR_NULLPAD);
            break;
        case H5STR_SPACEPAD:
            H5Tset_strpad(dtypeID, H5T_STR_SPACEPAD);
            break;
        }

        return dtypeID;        
        break;

    case H5VLEN_UDD:
        if (DEBUG)
            mexPrintf("makeDatatype: making H5VLEN\n"); 

        return H5Tvlen_create(makeDatatype(dtypeInfo->Child));
        break;

    default:
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:unsupportedType",
                          "makeDatatype: Unsupported datatype");
        break;
    }
    
}



/* getRank - Get the number of HDF5 dimensions of the datatype/dataset.
 *
 * Inputs:
 *   value - The dataset, attribute, or datatype to examine
 *
 * Outputs:
 *   The HDF5 rank
 *
 * NOTE:
 *   HDF5 considers scalar and vector data to have rank 1.
 */
int getRank(const mxArray *value)
{

    int numDims = mxGetNumberOfDimensions(value);

    if ((numDims == 2) &&
        ((mxGetM(value) == mxGetNumberOfElements(value)) ||
         (mxGetN(value) == mxGetNumberOfElements(value))))
    {
        return 1;
    } else {
        return numDims;
    }
    
}



/* getDims - Get the dimensions of a datatype/dataset/attribute.
 *
 * Inputs:
 *   value - The dataset, attribute, or datatype to examine
 *
 * Outputs:
 *   An array (dynamic) of the size of each dimension
 *
 * NOTE:
 *   The length of the array is given by getDims().
 */
hsize_t *getDims(const mxArray *value)
{

    int i;
    int rank;
    const int *ml_dims;
    hsize_t *dims;

    if (mxIsChar(value))
    {
        if (DEBUG)
            mexPrintf("getDims: Character\n");

        dims = (hsize_t *) mxMalloc(sizeof(hsize_t));
        dims[0] = 1;
    }
    else if ((mxGetNumberOfDimensions(value) == 2) &&
        ((mxGetM(value) == mxGetNumberOfElements(value)) ||
         (mxGetN(value) == mxGetNumberOfElements(value))))
    {
        if (DEBUG)
            mexPrintf("getDims: Vector\n");

        /* Simple vector. */
        dims = (hsize_t *) mxMalloc(sizeof(hsize_t));
        dims[0] = mxGetNumberOfElements(value);

    }
    else
    {
        if (DEBUG)
            mexPrintf("getDims: Other Shape\n");

        /* Other shape. */
        rank = mxGetNumberOfDimensions(value);
        ml_dims = mxGetDimensions(value);

        dims = (hsize_t *) mxMalloc(rank * sizeof(hsize_t));

        for (i = 0; i < rank; i++)
            dims[i] = (hsize_t) ml_dims[i];
    }

    return dims;

}



/* getType - Determine the HDF5 mapping of MATLAB data.
 *
 * Inputs:
 *   dataField - The mxArray data to be examined
 *
 * Outputs:
 *   A constant representing the HDF5 type
 */
hdf5type_t getType(const mxArray *dataField)
{

    if (mxIsNumeric(dataField))
    {
        return H5NATIVE;
    }
    else if (mxIsChar(dataField))
    {
        return H5STRING_SINGLE;
    }
    else if (mxIsCell(dataField))
    {
        if (mxIsChar(mxGetCell(dataField, 0)))
            return H5STRING_MULTIPLE;
        else
            return H5ARRAY;
    }
    else if (mxIsStruct(dataField))
    {
        return H5COMPOUND;
    }
    else if (isUDD(dataField))
    {
        return getTypeForUDD(dataField);
    }
    else
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:unsupportedType",
                          "getType: Unsupported data type.");
    }

}



/* newDtypeNode - Create a new node to describe a datatype.
 *
 * Inputs:
 *   typeID - A constant representing the HDF5 type
 *
 * Outputs:
 *   A new, initialized node (dynamic) to use in a datatype tree
 */
DtypeNode *newDtypeNode(hdf5type_t typeID)
{
    DtypeNode *node;

    node = (DtypeNode *) mxMalloc(sizeof(DtypeNode));
    
    if (node == NULL)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:memoryAllocation",
                          "newDtypeNode: Couldn't create temporary datatype structure.");
    
    node->Rank = 0;
    node->Dims = NULL;
    node->Type = typeID;
    node->Name = NULL;
    node->Size = 0;
    node->Offset = 0;
    node->Next = NULL;
    node->Child = NULL;
    node->H5NativeType = H5UNKNOWN;
    node->EnumNumConstants = 0;
    node->EnumConstants = NULL;
    node->EnumValues = NULL;
    
    return node;

}



/* getHDF5Datatype - Map a MATLAB numeric type to an HDF5 "native" type.
 *
 * Inputs:
 *   value - The element to examine
 *
 * Outputs:
 *   The HDF5 identifier that mapped from the MATLAB type
 */
hid_t getHDF5Datatype(const mxArray *value)
{
    
    mxClassID ml_type;
    int x = 1;

    ml_type = mxGetClassID(value);

    if (ml_type == mxUNKNOWN_CLASS)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:unsupportedType",
                          "getHDF5Datatype: Unknown datatype.");

    else 
    {
        if (*(char *)&x != 1) /* See _C Programming FAQs_ by Steve Summit, FAQ 20.9 */
        {

            /* Big Endian */

            if (ml_type == mxLOGICAL_CLASS)
                return H5T_STD_U8BE;
            
            else if (ml_type == mxDOUBLE_CLASS)
                return H5T_IEEE_F64BE;
            
            else if (ml_type == mxSINGLE_CLASS)
                return H5T_IEEE_F32BE;
            
            else if (ml_type == mxINT8_CLASS)
                return H5T_STD_I8BE;
            
            else if (ml_type == mxUINT8_CLASS)
                return H5T_STD_U8BE;
            
            else if (ml_type == mxINT16_CLASS)
                return H5T_STD_I16BE;
            
            else if (ml_type == mxUINT16_CLASS)
                return H5T_STD_U16BE;
            
            else if (ml_type == mxINT32_CLASS)
                return H5T_STD_I32BE;
            
            else if (ml_type == mxUINT32_CLASS)
                return H5T_STD_U32BE;
            
            else if (ml_type == mxINT64_CLASS)
                return H5T_STD_I64BE;
            
            else if (ml_type == mxUINT64_CLASS)
                return H5T_STD_U64BE;
        
            else
            {
                if (DEBUG)
                    mexPrintf("The type was: %d\n", (int) ml_type);
                mexErrMsgIdAndTxt("MATLAB:hdf5writec:unsupportedType",
                                  "getHDF5Datatype: Could not determine MATLAB type."); 
            }

        } else {

            /* Little Endian */
            
            if (ml_type == mxLOGICAL_CLASS)
                return H5T_STD_U8LE;
            
            else if (ml_type == mxDOUBLE_CLASS)
                return H5T_IEEE_F64LE;
            
            else if (ml_type == mxSINGLE_CLASS)
                return H5T_IEEE_F32LE;
            
            else if (ml_type == mxINT8_CLASS)
                return H5T_STD_I8LE;
            
            else if (ml_type == mxUINT8_CLASS)
                return H5T_STD_U8LE;
            
            else if (ml_type == mxINT16_CLASS)
                return H5T_STD_I16LE;
            
            else if (ml_type == mxUINT16_CLASS)
                return H5T_STD_U16LE;
            
            else if (ml_type == mxINT32_CLASS)
                return H5T_STD_I32LE;
            
            else if (ml_type == mxUINT32_CLASS)
                return H5T_STD_U32LE;
            
            else if (ml_type == mxINT64_CLASS)
                return H5T_STD_I64LE;
            
            else if (ml_type == mxUINT64_CLASS)
                return H5T_STD_U64LE;
        
            else
            {
                if (DEBUG)
                    mexPrintf("The type was: %d\n", (int) ml_type);
                mexErrMsgIdAndTxt("MATLAB:hdf5writec:unsupportedType",
                                  "getHDF5Datatype: Could not determine MATLAB type."); 
            }

        }
    }
}



/* computeBufferSize - Get the number of bytes to copy a dataset/datatype.
 *
 * Inputs:
 *   info - Linked list describing the datatype for this buffer/subbuffer
 *
 *   data - The dataset, attribute, or subtype
 *
 * Outputs:
 *   Size of the output buffer in bytes
 */
int computeBufferSize(DtypeNode *info, const mxArray *data)
{

    int nElements = mxGetNumberOfElements(data);

    switch (getType(data))
    {
    case H5ARRAY:
    case H5ARRAY_UDD:
    case H5COMPOUND:
    case H5COMPOUND_UDD:
    case H5NATIVE:
    case H5STRING_MULTIPLE:
    case H5STRING_UDD:
    case H5VLEN_UDD:
        return nElements * info->Size;
        break;

    case H5ENUM_UDD:
        return getEnumBufferSize(info);

    case H5STRING_SINGLE:
        return info->Size;
        break;

    default:
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:unsupportedType",
                          "computeBufferSize: Unsupported type.");
    }

}



/* permute - Permute the first two dimensions of a MATLAB matrix.
 *
 * Inputs:
 *   in - The matrix to permute
 *
 *   out - (See below)
 *
 * Outputs:
 *   out - The permuted matrix (RHS argument) - Do not destroy this array.
 */
void permute(mxArray *in, mxArray **out)
{

    /* Permute just the first two dimensions. */
    
    int ndims, i;
    mxArray *ml_dims;
    double *data;
    mxArray *plhs[1];
    mxArray *prhs[2];

    ndims = mxGetNumberOfDimensions(in);
    ml_dims = mxCreateDoubleMatrix(ndims, 1, mxREAL);
    data = mxGetPr(ml_dims);

    data[0] = 2;
    data[1] = 1;
    for (i = 2; i < ndims; i++)
        data[i] = i + 1;

    prhs[0] = in;
    prhs[1] = ml_dims;

    mexCallMATLAB(1, plhs, 2, prhs, "permute");
    *out = plhs[0];

    mxDestroyArray(ml_dims);

}



/* getObjectType - Determine the HDF5 type of a file part.
 *
 * Inputs:
 *   details - A MATLAB struct with field named "AttachType"
 *
 * Outputs:
 *   A constant representing the HDF5 type
 */
hdf5type_t getObjectType(const mxArray *details)
{

    hdf5type_t typeID;
    char *objectTypeStr = getString(mxGetField(details, 0, "AttachType"));

    if (!strncmp("dataset", objectTypeStr, 7))
    {
        typeID = H5DATASET;
    }
    else if (!strncmp("datatype", objectTypeStr, 8))
    {
        typeID = H5DATATYPE;
    }
    else if (!strncmp("group", objectTypeStr, 5))
    {
        typeID = H5GROUP;
    }
    else
    {
        mxFree(objectTypeStr);
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:unsupportedType",
                          "getObjectType: Unsupported object type for attribute.");
    }

    mxFree(objectTypeStr);
    return typeID;

}



/* getObjectPtr - Open a pointer to an HDF5 object.
 *
 * Inputs:
 *   filePtr - The parent HDF5 object's pointer (usually the file)
 *
 *   objectStr - The relative path to the the object to open
 *
 *   objectType - A constant representing the HDF5 type
 *
 * Outputs:
 *   A data structure containing details about the opened HDF5 object
 */
HDF5obj * getObjectPtr(hid_t filePtr, 
                       char *objectStr, 
                       hdf5type_t objectType)
{

    HDF5obj *objectPtr;

    objectPtr = newHDF5obj(objectStr, objectType);
    if (objectPtr == NULL)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:memoryAllocation",
                          "getObjectPtr: Couldn't create HDF5OBJ structure.");

    switch (objectType)
    {
    case H5DATASET:
        objectPtr->Ptr = H5Dopen(filePtr, objectStr);
        break;
    case H5DATATYPE:
        objectPtr->Ptr = H5Topen(filePtr, objectStr);
        break;
    case H5GROUP:
        objectPtr->Ptr = H5Gopen(filePtr, objectStr);
        break;
    }

    return objectPtr;

}



/* writeH5Attr - Write an attribute to an HDF5 file.
 *
 * Inputs:
 *   object - A data structure containing details about an HDF5 object
 *
 *   attributeData - A MATLAB structure containing the data to write
 *
 *   nameStr - The name of the attribute
 *
 * Outputs:
 *   None
 */
void writeH5Attr(HDF5obj* object, const mxArray *attributeData, char *nameStr)
{

    DtypeNode *dtypeInfo;
    hid_t dtypeID;
    hid_t dspaceID;
    hid_t attrID;
    void *buf;

    /* Create the datatype for the attribute. */
    dtypeInfo = buildDtypeInfo(attributeData);
    dtypeID = makeDatatype(dtypeInfo);
    if (dtypeID < 0)
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:datatypeCreation",
                          "writeH5Attr: Couldn't create attribute datatype.");
    }

    /* Create the dataspace and dataset. */
    dspaceID = createDataspace(attributeData);
    if (dspaceID < 0)
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:dataspaceCreation",
                          "writeH5Attr: Couldn't create dataspace.");
    }

    attrID = H5Acreate(object->Ptr, nameStr, dtypeID, 
                        dspaceID, H5P_DEFAULT);
    if (attrID < 0)
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:datasetCreation",
                          "writeH5Attr: Couldn't create attribute.");
    }

    /* Create and fill data buffer. */
    buf = makeDataBuffer(dtypeInfo, attributeData);
    fillBuffer(buf, dtypeInfo, attributeData);

    /* Write the dataset. */
    H5Awrite(attrID, dtypeID, buf);

    /* Clean up. */
    H5Aclose(attrID);
    H5Sclose(dspaceID);
    H5Tclose(dtypeID);
    mxFree(buf);
    deleteDtypeInfo(dtypeInfo);

}



/* closeObject - Close an open HDF5 object.
 *
 * Inputs:
 *   objectPtr - A data structure containing details about an HDF5 object
 *
 * Outputs:
 *   None
 *
 * NOTE:
 *   This function does not free the object's dynamic memory.
 */
void closeObject(HDF5obj *objectPtr)
{

    switch (objectPtr->Type)
    {
    case H5DATASET:
        H5Dclose(objectPtr->Ptr);
        break;
    case H5DATATYPE:
        H5Tclose(objectPtr->Ptr);
        break;
    case H5GROUP:
        H5Gclose(objectPtr->Ptr);
        break;
    }

}



/* newHDF5obj - Create a data structure describing an HDF5 object.
 *
 * Inputs:
 *   objectStr - The name of the object
 *
 *   objectType - A constant with the type of the HDF5 object
 *
 * Outputs:
 *   A data structure (dynamic) containing details about an HDF5 object
 */
HDF5obj * newHDF5obj(char *objectStr, hdf5type_t objectType)
{

    HDF5obj *object;

    object = (HDF5obj *) mxMalloc(sizeof(HDF5obj));
    if (object == NULL)
        return object;

    object->Type = objectType;
    object->Name = objectStr;

    if (DEBUG)
        describeHDF5obj(object);

    return object;

}



/* getMaxStringLength - Find the max length of a string in a dataset.
 *
 * Inputs:
 *   datasetData - A cell array of strings containing the dataset
 *
 * Outputs:
 *   The length of the longest string
 */
size_t getMaxStringLength(const mxArray *datasetData)
{

    int i, numCells;
    int strLength;
    int maxLength = 0;
    mxArray *cellPtr;

    numCells = mxGetNumberOfElements(datasetData);
    for (i = 0; i < numCells; i++)
    {
        cellPtr = mxGetCell(datasetData, i);
        strLength = mxGetNumberOfElements(cellPtr);
        maxLength = ((strLength > maxLength) ? strLength : maxLength);
    }
    
    return (size_t) maxLength;

}



/* deleteDtypeInfo - Recursively clean up a datatype descriptor.
 *
 * Inputs:
 *   dtypeInfo - Linked list describing a datatype
 *
 * Outputs:
 *   None
 */
void deleteDtypeInfo(DtypeNode *dtypeInfo)
{

    if (DEBUG)
        mexPrintf("deleteDtypeInfo: Deleting node %p\n", dtypeInfo);

    if (dtypeInfo == NULL)
        return;

    /* Delete all children before deleting the node. */
    if (dtypeInfo->Child != NULL)
        deleteDtypeInfo(dtypeInfo->Child);

    /* Delete neighbors before deleting the node. */
    if (dtypeInfo->Next != NULL)
        deleteDtypeInfo(dtypeInfo->Next);

    /* Clean up this node's members. */
    mxFree(dtypeInfo->Dims);
    mxFree(dtypeInfo->Name);

    if (dtypeInfo->EnumValues != NULL)
        mxFree(dtypeInfo->EnumValues);

    if (dtypeInfo->EnumConstants != NULL)
        deleteDatatypeEnumConstants(dtypeInfo);

    /* Finally, delete this node. */
    mxFree(dtypeInfo);
    dtypeInfo = NULL;

}



/* deleteDatatypeEnumConstants - Clean up enum values in a datatype descriptor.
 *
 * Inputs:
 *   dtypeInfo - Linked list describing a datatype
 *
 * Outputs:
 *   None
 */
void deleteDatatypeEnumConstants(DtypeNode *dtypeInfo)
{

    int i;

    if ((dtypeInfo == NULL) || (dtypeInfo->EnumConstants == NULL))
        return;

    for (i = 0; i < dtypeInfo->EnumNumConstants; i++)
    {
        if (dtypeInfo->EnumConstants[i] != NULL)
        {
            mxFree(dtypeInfo->EnumConstants[i]);
            dtypeInfo->EnumConstants[i] = NULL;
        }
    }

}



/* getCompoundDtypeSize - Compute the size of a compound datatype.
 *
 * Inputs:
 *   dtypeInfo - Linked list describing a datatype
 *
 * Outputs:
 *   The size of the compound datatype in bytes
 */
size_t getCompoundDtypeSize(DtypeNode *dtypeInfo)
{
    /* Traverse the datatype's children, adding the sizes together. */
    size_t totalSize = 0;
    DtypeNode *tmp;

    tmp = dtypeInfo->Child;
    while (tmp != NULL)
    {
        totalSize += tmp->Size;
        tmp = tmp->Next;
    }

    return totalSize;
}



/* getArrayDtypeSize - Compute the size of a array datatype.
 *
 * Inputs:
 *   dtypeInfo - Linked list describing a datatype
 *
 * Outputs:
 *   The size of the array datatype in bytes
 */
size_t getArrayDtypeSize(DtypeNode *dtypeInfo)
{
    /* Traverse the datatype's children, adding the sizes together. */
    size_t totalElements = 1;
    int i;

    for (i = 0; i < dtypeInfo->Rank; i++)
    {
        totalElements *= dtypeInfo->Dims[i];
    }

    return totalElements * dtypeInfo->Child->Size;
}



/* buildCompoundDtypeInfo - Get information about a compound datatype.
 *
 * Inputs:
 *   parentNode - Linked list describing the datatype for the parent type
 *
 *   datasetData - The MATLAB structure containing the parent type's data
 *
 * Outputs:
 *   A linked list (dynamic) describing the datatypes of the subtypes
 */
DtypeNode * buildCompoundDtypeInfo(DtypeNode *parentNode, 
                                   const mxArray *datasetData)
{
    /* Create a linked list of the compound type's subtypes, creating
     * the subtype info along the way. */
    
    DtypeNode *firstChild;
    DtypeNode *newNode;
    DtypeNode *tmp;
    const mxArray *fieldPtr;
    int i, numFields;
    const char *fieldName;
    int fieldNameLength;
    int offset;

    /* Build the first subtype. */
    offset = 0;
    fieldPtr = mxGetFieldByNumber(datasetData, 0, 0);

    /* Allow the conveninece case where arrays in compound types are
     * specified without using cell arrays. */
    if ((mxIsNumeric(fieldPtr)) && 
        (mxGetNumberOfElements(fieldPtr) != 1))
    {
        firstChild = buildArrayForCompoundDtypeInfo(fieldPtr);
    } 
    else
    {
        firstChild = buildDtypeInfo(fieldPtr);
    }

    tmp = firstChild;
    tmp->Offset = offset;
    offset += tmp->Size;

    /* Build the other subtypes. */
    numFields = mxGetNumberOfFields(datasetData);
    for (i = 1; i < numFields; i++)
    {
        fieldPtr = mxGetFieldByNumber(datasetData, 0, i);

        /* Allow the conveninece case where arrays in compound types are
         * specified without using cell arrays. */
        if ((mxIsNumeric(fieldPtr)) && 
            (mxGetNumberOfElements(fieldPtr) != 1))
        {
            newNode = buildArrayForCompoundDtypeInfo(fieldPtr);
        } 
        else
        {
            newNode = buildDtypeInfo(fieldPtr);
        }

        newNode->Offset = offset;
        offset += newNode->Size;

        tmp->Next = newNode;
        tmp = newNode;
    }

    /* Set the names. */
    tmp = firstChild;
    for (i = 0; i < numFields; i++)
    {
        fieldName = mxGetFieldNameByNumber(datasetData, i);
        fieldNameLength = strlen(fieldName);

        tmp->Name = (char *) mxMalloc(sizeof(char) * fieldNameLength + 1);
        strncpy(tmp->Name, fieldName, fieldNameLength);
        tmp->Name[fieldNameLength] = '\0';

        tmp = tmp->Next;
    }

    return firstChild;

}



/* addFieldsToCompound - Add HDF5 subtypes to an HDF5 compound type.
 *
 * Inputs:
 *   dtypeID - An HDF5 compound datatype
 *
 *   dtypeInfo - A linked list describing the compound datatype
 *
 * Outputs:
 *   None
 */
void addFieldsToCompound(hid_t dtypeID, DtypeNode *dtypeInfo)
{
    int offset = 0;
    int fieldNum = 0;
    DtypeNode *tmp;
    hid_t tmp_id;
    herr_t status;
    
    tmp = dtypeInfo->Child;
    while (tmp != NULL)
    {

        tmp_id = makeDatatype(tmp);
        if (tmp_id < 0)
        {
            if (DEBUG)
            {
                mexPrintf("Couldn't create datatype:\n");
                mexPrintf("  Name: %s\n", tmp->Name);
                mexPrintf("  Offset: %d\n", tmp->Offset);
                mexPrintf("  Dtype: %d\n", tmp_id);
            }
            mexErrMsgIdAndTxt("MATLAB:hdf5writec:subtypeCreation",
                              "addFieldsToCompound: Couldn't create subtype for compound type.");
        }

        if (DEBUG)
        {
            mexPrintf("addFieldsToCompound: Inserting field into %d\n", 
                      dtypeID);
            mexPrintf("  Name: %s\n", tmp->Name);
            mexPrintf("  Offset: %d\n", tmp->Offset);
            mexPrintf("  Dtype: %d\n", tmp_id);
        }

        status = H5Tinsert(dtypeID, tmp->Name, tmp->Offset, tmp_id);
        if (status < 0)
        {
            if (DEBUG)
            {
                mexPrintf("Trouble inserting field:\n");
                mexPrintf("  Name: %s\n", tmp->Name);
                mexPrintf("  Offset: %d\n", tmp->Offset);
                mexPrintf("  Dtype: %d\n", tmp_id);
            }
            mexErrMsgIdAndTxt("MATLAB:hdf5writec:subtypeInsertion",
                              "addFieldsToCompound: Couldn't insert field into compound type.");
        }

        tmp = tmp->Next;

    }

}



/* describeDtypeInfo - Print information about the datatype linked list.
 *
 * Inputs:
 *   datatype - A linked list describing a datatype
 *
 * Outputs:
 *   None
 *
 * NOTE:
 *   This is a debugging function.
 */
void describeDtypeInfo(DtypeNode *dtypeInfo)
{
    
    int i;
    DtypeNode *relative;
  
    printDtypeDetails(dtypeInfo);
    
    if (dtypeInfo->Child != NULL)
    {
        mexPrintf("\n");
        mexPrintf("Child of %p\n", dtypeInfo);
        describeDtypeInfo(dtypeInfo->Child);
    }

    relative = dtypeInfo->Next;
    while (relative != NULL)
    {
        mexPrintf("\n");
        mexPrintf("Neighbor of %p\n", dtypeInfo);
        printDtypeDetails(relative);

        if (relative->Child != NULL)
        {
            mexPrintf("\n");
            mexPrintf("Child of %p\n", relative);
            describeDtypeInfo(relative->Child);
        }
        relative = relative->Next;
    }

}



/* describeDtypeInfo - Print basic information about the datatype linked list.
 *
 * Inputs:
 *   datatype - A linked list describing a datatype
 *
 * Outputs:
 *   None
 *
 * NOTE:
 *   This is a debugging function.
 */
void printDtypeDetails(DtypeNode *dtypeInfo)
{

    int i;

    if (dtypeInfo == NULL)
    {
        mexPrintf("Datatype node is empty.\n");
        return;
    }

    mexPrintf("Datatype details for %p\n", dtypeInfo);
    mexPrintf("  Rank: %d\n", dtypeInfo->Rank);

    mexPrintf("  Dims: [ ");
    for (i = 0; i < dtypeInfo->Rank; i++)
        mexPrintf("%d ", dtypeInfo->Dims[i]);
    mexPrintf("]\n");

    mexPrintf("  Type: ");
    printHdf5type(dtypeInfo->Type);
    mexPrintf("\n");

    mexPrintf("  Name: %s\n", dtypeInfo->Name);
    mexPrintf("  Size: %d\n", dtypeInfo->Size);
    mexPrintf("  Next: %p\n", dtypeInfo->Next);
    mexPrintf("  Child: %p\n", dtypeInfo->Child);
    mexPrintf("  H5NativeType: %d\n", (int) dtypeInfo->H5NativeType);

    if (dtypeInfo->Type == H5ENUM_UDD)
    {
        for (i = 0; i < dtypeInfo->EnumNumConstants; i++)
            mexPrintf("    Enum # %d: %d = %s\n", i, 
                      ((int32_T *) dtypeInfo->EnumValues)[i],
                      dtypeInfo->EnumConstants[i]);
    }
    
}



/* printHdf5type - Print the type of the HDF5 object.
 *
 * Inputs:
 *   type - A constant representing the HDF5 type.
 *
 * Ouputs:
 *   None
 *
 * NOTE:
 *   This is a debugging function.
 */
void printHdf5type(hdf5type_t type)
{

    switch (type)
    {
    case H5ARRAY:
        mexPrintf("H5ARRAY");
        break;

    case H5ARRAY_UDD:
        mexPrintf("H5ARRAY_UDD");
        break;

    case H5COMPOUND:
        mexPrintf("H5COMPOUND");
        break;

    case H5COMPOUND_UDD:
        mexPrintf("H5COMPOUND_UDD");
        break;

    case H5DATASET:
        mexPrintf("H5DATASET");
        break;

    case H5DATATYPE:
        mexPrintf("H5DATATYPE");
        break;

    case H5ENUM_UDD:
        mexPrintf("H5ENUM_UDD");
        break;

    case H5GROUP:
        mexPrintf("H5GROUP");
        break;

    case H5NATIVE:
        mexPrintf("H5NATIVE");
        break;

    case H5STRING_MULTIPLE:
        mexPrintf("H5STRING_MULTIPLE");
        break;

    case H5STRING_SINGLE:
        mexPrintf("H5STRING_SINGLE");
        break;

    case H5VLEN_UDD:
        mexPrintf("H5VLEN_UDD");
        break;
    }

}



/* buildNativeDtypeInfo - Create datatype info about a native dataset.
 *
 * Inputs:
 *   datasetData - A MATLAB array of numeric data
 *
 * Outputs:
 *   A linked list describing the datatype
 */
DtypeNode *buildNativeDtypeInfo(const mxArray *datasetData)
{

    DtypeNode *dtypeInfo;
    hdf5type_t typeID;
 
    typeID = getType(datasetData);

    dtypeInfo = newDtypeNode(typeID);
    dtypeInfo->Rank = 1;
    dtypeInfo->Dims = mxMalloc(sizeof(size_t));
    dtypeInfo->Dims[0] = 1;

    dtypeInfo->Size = (size_t) mxGetElementSize(datasetData);
    dtypeInfo->H5NativeType = getHDF5Datatype(datasetData);

    return dtypeInfo;

}



/* buildArrayForCompoundDtypeInfo - Get datatype info for an array
 *   nested inside a compound type.
 *
 * Inputs:
 *   datasetData - A MATLAB array containing the nested array
 *
 * Outputs:
 *   A linked list describing the datatype
 */
DtypeNode *buildArrayForCompoundDtypeInfo(const mxArray *datasetData)
{
    
    DtypeNode *dtypeInfo;
 
    dtypeInfo = newDtypeNode(H5ARRAY);
    dtypeInfo->Rank = getRank(datasetData);
    dtypeInfo->Dims = getDims(datasetData);
    dtypeInfo->Child = buildDtypeInfo(datasetData);
    dtypeInfo->Size = getArrayDtypeSize(dtypeInfo);

    return dtypeInfo;

}



/* describeDtype - Describe an HDF5 datatype.
 *
 * Inputs:
 *   dtype - An HDF5 datatype identifier
 *
 * Ouputs:
 *   None
 *
 * NOTE:
 *   This is a debugging function.
 */
void describeDtype(hid_t dtype)
{

    int i, nmembers;
    char *member_name;

    mexPrintf("\n");
    mexPrintf("HDF5 datatype details for datatype %d\n", dtype);

    mexPrintf("  Class: ");
    printHDF5DtypeName(dtype);
    mexPrintf("\n");

    mexPrintf("  Size: %d\n", H5Tget_size(dtype));

    mexPrintf("  Type: ");
    if (H5Tcommitted(dtype) > 0)
        mexPrintf("Named\n");
    else if (H5Tcommitted(dtype) == 0)
        mexPrintf("Transient\n");
    else
        mexPrintf("Unknown\n");

    if (H5Tget_super(dtype) > 0)
    {
        mexPrintf("  Subclass: Yes (");
        printHDF5DtypeName(dtype);
        mexPrintf(")\n");
    }
    else
        mexPrintf("  Subclass: No\n");

    nmembers = H5Tget_nmembers(dtype);
    for (i = 0; i < nmembers; i++)
    {
        mexPrintf("  Field %d --\n", i);
        mexPrintf("   Offset: %d\n", H5Tget_member_offset(dtype, i));

        member_name = H5Tget_member_name(dtype, i);
        mexPrintf("   Name: %s\n", member_name);
        free(member_name);

        mexPrintf("   Type: ");
        printHDF5DtypeName(H5Tget_member_class(dtype, i));
        mexPrintf("\n");
    }
}



/* printHDF5DtypeName - Print the name of an HDF5 datatype.
 *
 * Inputs:
 *   dtype_class - An HDF5 datatype identifier
 *
 * Ouputs:
 *   None
 *
 * NOTE:
 *   This is a debugging function.
 */
void printHDF5DtypeName(hid_t dtype_class)
{

    switch (dtype_class)
    {
    case H5T_INTEGER:
        mexPrintf("H5T_INTEGER");
        break;
    case H5T_FLOAT:
        mexPrintf("H5T_FLOAT");
        break;
    case H5T_TIME:
        mexPrintf("H5T_TIME");
        break;
    case H5T_STRING:
        mexPrintf("H5T_STRING");
        break;
    case H5T_BITFIELD:
        mexPrintf("H5T_BITFIELD");
        break;
    case H5T_OPAQUE:
        mexPrintf("H5T_OPAQUE");
        break;
    case H5T_COMPOUND:
        mexPrintf("H5T_COMPOUND");
        break;
    case H5T_REFERENCE:
        mexPrintf("H5T_REFERENCE");
        break;
    case H5T_ENUM:
        mexPrintf("H5T_ENUM");
        break;
    case H5T_VLEN:
        mexPrintf("H5T_VLEN");
        break;
    case H5T_ARRAY:
        mexPrintf("H5T_ARRAY");
        break;
    default:
        mexPrintf("Unknown (%d)", dtype_class);
        break;
    }

}



/* isUDD - Determine if data is a UDD object.
 *
 * Inputs:
 *   dataField - A MATLAB array
 *
 * Outputs:
 *   True if the object is a UDD object, false otherwise
 */
bool isUDD(const mxArray *dataField)
{
    
    if (strncmp(mxGetClassName(dataField), "hdf5", 4) == 0)
    {
        return true;
    }
    else
    {
        return false;
    }
    
}



/* getTypeForUDD - Determine the HDF5 mapping of MATLAB UDD data.
 *
 * Inputs:
 *   dataField - The UDD mxArray data to be examined
 *
 * Outputs:
 *   A constant representing the HDF5 type
 */
hdf5type_t getTypeForUDD(const mxArray *dataField)
{
    
    const char *className;

    className = mxGetClassName(dataField);
    
    if (!strncmp(className, "hdf5.h5array", 12))
        return H5ARRAY_UDD;
    else if (!strncmp(className, "hdf5.h5compound", 15))
        return H5COMPOUND_UDD;
    else if (!strncmp(className, "hdf5.h5enum", 11))
        return H5ENUM_UDD;
    else if (!strncmp(className, "hdf5.h5string", 13))
        return H5STRING_UDD;
    else if (!strncmp(className, "hdf5.h5vlen", 11))
        return H5VLEN_UDD;
    else
        return H5UNKNOWN;

}



/* getUDDObjectData - Get the "Data" field from a UDD object.
 * 
 * Inputs:
 *   datasetData - A UDD mxArray
 *
 *   subtypeData - (See below)
 *
 *   idx - Index of the element of "datasetData" to pull "Data" from
 *
 * Outputs:
 *   subtypeData (RHS) - The "Data" field of the UDD object
 *
 * NOTE:
 *   Do not destroy the return value.
 */
void getUDDObjectData(const mxArray *datasetData,
                      mxArray **subtypeData,
                      int idx)
{
    
    mxArray * prhs[2];
    mxArray * subsrefArg; /* A struct with fields 'Type' and 'Subs' */
    const char * fieldNames[2] = {"type", "subs"};
    mxArray * indexCell;
    mxArray * tmp = NULL;

    /* (1) Use mexCallMATLAB with SUBSREF to get the nth element
     *     from the UDD object. */
    subsrefArg = mxCreateStructMatrix(1, 1, 2, fieldNames);
    indexCell = mxCreateCellMatrix(1, 1);
    mxSetCell(indexCell, 0, mxCreateDoubleScalar(idx + 1));

    mxSetField(subsrefArg, 0, "type", mxCreateString("()"));
    mxSetField(subsrefArg, 0, "subs", indexCell);

    prhs[0] = (mxArray *) datasetData;
    prhs[1] = subsrefArg;
    mexCallMATLAB(1, &tmp, 2, prhs, "subsref");

    /* (2) Use mexCallMATLAB to get the "Data" field from step (1). */
    mxSetField(subsrefArg, 0, "type", mxCreateString("."));
    mxSetField(subsrefArg, 0, "subs", mxCreateString("Data"));

    prhs[0] = tmp;
    mexCallMATLAB(1, subtypeData, 2, prhs, "subsref");
    
}



/* getUDDObjectMemberNames - Get the "MemberNames" field from a UDD object.
 * 
 * Inputs:
 *   datasetData - A UDD mxArray
 *
 *   memberNamesCell - (See below)
 *
 *   idx - Index of the element of "datasetData" to pull "Data" from
 *
 * Outputs:
 *   memberNamesCell (RHS) - The "MemberNames" field of the UDD object
 *
 * NOTE:
 *   Do not destroy the return value.
 */
void getUDDObjectMemberNames(const mxArray *datasetData,
                             mxArray **memberNamesCell,
                             int idx)
{
    
    mxArray * prhs[2];
    mxArray * subsrefArg; /* A MATLAB struct with fields 'Type' and 'Subs' */
    const char * fieldNames[2] = {"type", "subs"};
    mxArray * indexCell;
    mxArray * tmp = NULL;

    /* Only compound types have a MemberNames field. */
    if (!isUDD(datasetData))
    {
        *memberNamesCell = NULL;
        return;
    }
    else if (getType(datasetData) != H5COMPOUND_UDD)
    {
        *memberNamesCell = NULL;
        return;
    }


    /* (1) Use mexCallMATLAB with SUBSREF to get the nth element
     *     from the UDD object. */
    subsrefArg = mxCreateStructMatrix(1, 1, 2, fieldNames);
    indexCell = mxCreateCellMatrix(1, 1);
    mxSetCell(indexCell, 0, mxCreateDoubleScalar(idx + 1));

    mxSetField(subsrefArg, 0, "type", mxCreateString("()"));
    mxSetField(subsrefArg, 0, "subs", indexCell);

    prhs[0] = (mxArray *) datasetData;
    prhs[1] = subsrefArg;
    mexCallMATLAB(1, &tmp, 2, prhs, "subsref");

    /* (2) Use mexCallMATLAB to get the "MemberNames" field from step (1). */
    mxSetField(subsrefArg, 0, "type", mxCreateString("."));
    mxSetField(subsrefArg, 0, "subs", mxCreateString("MemberNames"));

    prhs[0] = tmp;
    mexCallMATLAB(1, memberNamesCell, 2, prhs, "subsref");
    
}



/* buildUDDCompoundDtypeInfo - Get datatype info about compound UDD types
 *
 * Inputs:
 *   datasetData - A compound type UDD object
 *
 * Outputs:
 *   A linked list (dynamic) of the child datatypes of the UDD object
 */
DtypeNode * buildUDDCompoundDtypeInfo(const mxArray *datasetData)
{
    /* Create a linked list of the compound type's subtypes, creating
     * the subtype info along the way.
     * 
     * Inside the UDD object, the data for a compound object is stored
     * in a cell array. */
    
    DtypeNode *firstChild;
    DtypeNode *newNode;
    DtypeNode *tmp;
    mxArray *dataCellPtr = NULL;
    mxArray *namesCellPtr = NULL;
    int i, numCells;
    const char *memberName;
    int memberNameLength;
    int offset;

    /* Build the first subtype. */
    offset = 0;
    
    getUDDObjectData(datasetData, &dataCellPtr, 0);
    firstChild = buildDtypeInfo(mxGetCell(dataCellPtr, 0));

    tmp = firstChild;

    if (DEBUG)
        mexPrintf("buildUDDCompoundDtypeInfo: (before) Offset = %d\n", offset);

    tmp->Offset = offset;
    offset += tmp->Size;

    if (DEBUG)
        mexPrintf("buildUDDCompoundDtypeInfo: (after)  Offset = %d\n", offset);

    /* Build the other subtypes. */
    numCells = mxGetNumberOfElements(dataCellPtr);
    for (i = 1; i < numCells; i++)
    {
        newNode = buildDtypeInfo(mxGetCell(dataCellPtr, i));

        if (DEBUG)
            mexPrintf("buildUDDCompoundDtypeInfo: (before) Offset = %d\n", offset);
        
        newNode->Offset = offset;
        offset += newNode->Size;
        
        if (DEBUG)
            mexPrintf("buildUDDCompoundDtypeInfo: (after)  Offset = %d\n", offset);

        tmp->Next = newNode;
        tmp = newNode;
    }

    /* Set the names. */
    tmp = firstChild;
    getUDDObjectMemberNames(datasetData, &namesCellPtr, 0);

    for (i = 0; i < numCells; i++)
    {
        tmp->Name = getString(mxGetCell(namesCellPtr, i));

        if (DEBUG)
            mexPrintf("%s\t(len = %d)\n", tmp->Name, strlen(tmp->Name));

        tmp = tmp->Next;
    }

    return firstChild;
        
}



/* describeMLArray - Print details about a MATLAB array
 *
 * Inputs:
 *   array - A MATLAB array of arbitrary type
 *
 * Outputs:
 *   None
 *
 * NOTE:
 *   This is a debugging function.
 */
void describeMLArray(const mxArray *array)
{

    int i, numElements;
    const int *dims;

    mexPrintf("describeMLArray: Describing mxArray %p\n", array);
    
    if (mxIsEmpty(array))
    {
        mexPrintf("  Empty.\n");
        return;
    }

    mexPrintf("  Class = %s\n", mxGetClassName(array));
    
    numElements = mxGetNumberOfElements(array);
    dims = mxGetDimensions(array);
    mexPrintf("  Number of Elements: %d [ ", numElements);
    for (i = 0; i < mxGetNumberOfDimensions(array); i++)
    {
        mexPrintf("%d ", dims[i]);
    }
    mexPrintf("]\n");

    
}



/* getUDDStringLength - Get the length of a string in a UDD object.
 * 
 * Inputs:
 *   datasetData - A UDD mxArray
 *
 * Outputs:
 *   The size of the string in bytes.
 */
hsize_t getUDDStringLength(const mxArray *datasetData)
{
    
    mxArray * prhs[2];
    mxArray * subsrefArg; /* A MATLAB struct with fields 'Type' and 'Subs' */
    const char * fieldNames[2] = {"type", "subs"};
    mxArray * indexCell;
    mxArray * tmp1 = NULL;
    mxArray * tmp2 = NULL;

    /* (1) Use mexCallMATLAB with SUBSREF to get the first element
     *     from the UDD object. */
    subsrefArg = mxCreateStructMatrix(1, 1, 2, fieldNames);
    indexCell = mxCreateCellMatrix(1, 1);
    mxSetCell(indexCell, 0, mxCreateDoubleScalar(1));

    mxSetField(subsrefArg, 0, "type", mxCreateString("()"));
    mxSetField(subsrefArg, 0, "subs", indexCell);

    prhs[0] = (mxArray *) datasetData;
    prhs[1] = subsrefArg;
    mexCallMATLAB(1, &tmp1, 2, prhs, "subsref");

    /* (2) Use mexCallMATLAB to get the "Length" field from step (1). */
    mxSetField(subsrefArg, 0, "type", mxCreateString("."));
    mxSetField(subsrefArg, 0, "subs", mxCreateString("Length"));

    prhs[0] = tmp1;
    mexCallMATLAB(1, &tmp2, 2, prhs, "subsref");

    /* Return the length. */
    return (size_t) (mxGetPr(tmp2)[0]);

}



/* addEnumConstantsToEnum - Add enumeration values to the HDF5 type.
 *
 * Inputs:
 *   dtypeID - An HDF5 datatype identifier
 *
 *   dtypeInfo - A linked list with datatype details
 *
 * Outputs:
 *   None
 */
void addEnumConstantsToEnum(hid_t dtypeID, DtypeNode *dtypeInfo)
{

    int i;
    void *value;
    herr_t status;

    if (DEBUG)
        mexPrintf("addEnumConstantsToEnum:\n");

    for (i = 0; i < dtypeInfo->EnumNumConstants; i++)
    {
        /* Get the value to insert from the buffer of all values. */
        value = ((uint8_T *) (dtypeInfo->EnumValues)) + 
            i * dtypeInfo->Size;

        if (DEBUG)
        {
            mexPrintf("  adding %d: %d = %s\n", i, 
                      ((int32_T *) value)[0],
                      dtypeInfo->EnumConstants[i]); 
        }

        /* Insert the constants into the type. */
        status = H5Tenum_insert(dtypeID, dtypeInfo->EnumConstants[i], value);
        if (status < 0)
            mexErrMsgIdAndTxt("MATLAB:hdf5writec:enumInsertion",
                              "addEnumConstantsToEnum: Couldn't insert enumeration value into datatype.");
    }
}



/* setHDF5EnumDatatypeProps - Update the datatype info with Enum properties.
 *
 * Inputs:
 *   dtypeInfo - A linked list containing the Enum type's properties
 *
 *   uddEnumObjects - A MATLAB array of UDD Enum objects
 *
 *   idx - The element of uddEnumObjects to examine
 *
 * Outputs:
 *   None
 */
void setHDF5EnumDatatypeProps(DtypeNode *dtypeInfo,
                              const mxArray *uddEnumObjects,
                              int idx)
{

    mxArray * prhs[2];
    mxArray * subsrefArg; /* A MATLAB struct with fields 'Type' and 'Subs' */
    const char * fieldNames[2] = {"type", "subs"};
    mxArray * indexCell;
    mxArray * firstUddObject = NULL;
    char ** names;
    int i, numConstants;
    size_t valueSize;
    void *values;
    void *dataPtr;

    mxArray *EnumNames = NULL;
    mxArray *EnumValues = NULL;

    /* Get at the UDD object's properties. */
    subsrefArg = mxCreateStructMatrix(1, 1, 2, fieldNames);
    indexCell = mxCreateCellMatrix(1, 1);
    mxSetCell(indexCell, 0, mxCreateDoubleScalar(idx + 1));

    mxSetField(subsrefArg, 0, "type", mxCreateString("()"));
    mxSetField(subsrefArg, 0, "subs", indexCell);

    prhs[0] = (mxArray *) uddEnumObjects;
    prhs[1] = subsrefArg;

    mexCallMATLAB(1, &firstUddObject, 2, prhs, "subsref");

    prhs[0] = firstUddObject;

    mxSetField(subsrefArg, 0, "type", mxCreateString("."));
    mxSetField(subsrefArg, 0, "subs", mxCreateString("EnumNames"));
    mexCallMATLAB(1, &EnumNames, 2, prhs, "subsref");
    
    mxSetField(subsrefArg, 0, "subs", mxCreateString("EnumValues"));
    mexCallMATLAB(1, &EnumValues, 2, prhs, "subsref");

    if (DEBUG)
    {
        describeMLArray(EnumNames);
        describeMLArray(EnumValues);
    }

    /* Set the number of constants. */
    numConstants = mxGetNumberOfElements(EnumValues);
    dtypeInfo->EnumNumConstants = numConstants;
    
    /* Set the constants' names. */
    names = (char **) mxMalloc(numConstants * sizeof(char *));

    if (DEBUG)
        mexPrintf("setHDF5EnumDatatypeProps:\n");

    for (i = 0; i < numConstants; i++)
    {
        names[i] = getString(mxGetCell(EnumNames, i));

        if (DEBUG)
            mexPrintf("  %s\n", names[i]);
    }

    /* Set the constants' values. */
    dataPtr = mxGetData(EnumValues);
    valueSize = mxGetElementSize(EnumValues);
    values = mxMalloc(numConstants * valueSize);

    memcpy(values, mxGetData(EnumValues), valueSize * numConstants);

    /* Set the datatype descriptions. */
    dtypeInfo->EnumConstants = names;
    dtypeInfo->EnumValues = values;

}



/* getEnumBufferSize - Compute space needed to store an Enum dataset/type.
 *
 * Inputs:
 *   dtypeInfo - A linked list of datatype details
 *
 * Outputs:
 *   The number of bytes needed to store this dataset or type
 */
hsize_t getEnumBufferSize(DtypeNode *dtypeInfo)
{

    int i;
    int numElements = 1;

    for (i = 0; i < dtypeInfo->Child->Rank; i++)
    {
        numElements *= dtypeInfo->Child->Dims[i];
    }

    return (size_t) numElements * dtypeInfo->Child->Size;

}



/* fillBufferH5ARRAY - Fill buffer with array data from ML type.
 *
 * Inputs:
 *   buf - The buffer to fill
 *
 *   info - A linked list describing the datatype
 *
 *   data - The dataset/subtype to put in the buffer
 *
 * Outputs:
 *   The number of bytes copied
 */
int fillBufferH5ARRAY(uint8_T *buf, DtypeNode *info, mxArray *data)
{

    int bytesCopied = 0;
    int i;
    int numElements;
    mxArray *subElement = NULL;

    /* Fill the buffer by recursively filling the elements of the
     * array into the appropriate place in the buffer. */

    numElements = mxGetNumberOfElements(data);
    
    if (mxIsCell(data))
    {
        /* Input is a dataset containing array data. */
        if (DEBUG)
            mexPrintf("  Dataset of array data.\n");
        
        for (i = 0; i < numElements; i++)
        {
            subElement = mxGetCell(data, i);
            bytesCopied += fillBuffer(buf + bytesCopied,
                                      info->Child,
                                      subElement);
            
            if (DEBUG)
                mexPrintf("  Filled %d bytes\n", bytesCopied);
            
        }
    }
    else if (mxIsNumeric(data))
    {
        /* Input is an array within a compound type. */
        if (DEBUG)
            mexPrintf("  Array within compound type.\n");
        
        memcpy(buf, mxGetData(data), info->Size);
        bytesCopied = info->Size;
    }
    else
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:badArrayClass",
                          "fillBuffer: Inappropriate class for array data.");
    }

    return bytesCopied;

}



/* fillBufferH5ARRAY_UDD - Fill buffer with array/enum data from UDD type.
 *
 * Inputs:
 *   buf - The buffer to fill
 *
 *   info - A linked list describing the datatype
 *
 *   data - The dataset/subtype to put in the buffer
 *
 * Outputs:
 *   The number of bytes copied
 */
int fillBufferH5ARRAY_UDD(uint8_T *buf, DtypeNode *info, mxArray *data)
{

    int bytesCopied = 0;
    int i;
    int numElements;
    mxArray *subElement = NULL;

    /* Fill the buffer by recursively filling the elements of the
     * array/enum into the appropriate place in the buffer. */

    numElements = mxGetNumberOfElements(data);

    for (i = 0; i < numElements; i++)
    {
        getUDDObjectData(data, &subElement, i);
        bytesCopied += fillBuffer(buf + bytesCopied,
                                  info->Child,
                                  subElement);
        
        if (DEBUG)
            mexPrintf("  Filled %d bytes\n", bytesCopied);
    }
    
    return bytesCopied;

}



/* fillBufferH5COMPOUND - Fill buffer with compound data from ML type.
 *
 * Inputs:
 *   buf - The buffer to fill
 *
 *   info - A linked list describing the datatype
 *
 *   data - The dataset/subtype to put in the buffer
 *
 * Outputs:
 *   The number of bytes copied
 */
int fillBufferH5COMPOUND(uint8_T *buf, DtypeNode *info, mxArray *data)
{

    int bytesCopied = 0;
    int i, j;
    int numElements;
    int numSubElements;
    mxArray *subElement = NULL;
    DtypeNode *tmp;

    /* Fill the buffer by copying the mxArray fields into the buffer
     * at their offsets. */

    numElements = mxGetNumberOfElements(data);

    for (i = 0; i < numElements; i++)
    {
        tmp = info->Child;
        numSubElements = mxGetNumberOfFields(data);
        for (j = 0; j < numSubElements; j++)
        {
            subElement = mxGetFieldByNumber(data, i, j);
            bytesCopied += fillBuffer(buf + bytesCopied,
                                      tmp,
                                      subElement);
            tmp = tmp->Next;
        }
    }

    return bytesCopied;

}



/* fillBufferH5COMPOUND_UDD - Fill buffer with compound data from UDD type.
 *
 * Inputs:
 *   buf - The buffer to fill
 *
 *   info - A linked list describing the datatype
 *
 *   data - The dataset/subtype to put in the buffer
 *
 * Outputs:
 *   The number of bytes copied
 */
int fillBufferH5COMPOUND_UDD(uint8_T *buf, DtypeNode *info, mxArray *data)
{
    
    int bytesCopied = 0;
    int i, j;
    int numElements;
    int numSubElements;
    mxArray *subElement = NULL;
    DtypeNode *tmp;

    /* Fill the buffer by recursively copying the UDD object's data
     * fields into the buffer at the appropriate place. */

    numElements = mxGetNumberOfElements(data);

    for (i = 0; i < numElements; i++)
    {
        tmp = info->Child;
        
        /* Get a pointer to the UDD object's data.
         * For the compound type, it's a cell array. */
        getUDDObjectData(data, &subElement, i);
        if (DEBUG)
            describeMLArray(subElement);
        
        numSubElements = mxGetNumberOfElements(subElement);;
        for (j = 0; j< numSubElements; j++)
        {
            bytesCopied += fillBuffer(buf + bytesCopied,
                                      tmp,
                                      mxGetCell(subElement, j));
            tmp = tmp->Next;
        }
    }

    return bytesCopied;

}



/* fillBufferH5NATIVE - Fill buffer with numeric data from ML array.
 *
 * Inputs:
 *   buf - The buffer to fill
 *
 *   info - A linked list describing the datatype
 *
 *   data - The dataset/subtype to put in the buffer
 *
 * Outputs:
 *   The number of bytes copied
 */
int fillBufferH5NATIVE(uint8_T *buf, DtypeNode *info, mxArray *data)
{
    
    int numElements;

    /* Fill the buffer by copying the mxArray data straight to the
     * output buffer. */

    numElements = mxGetNumberOfElements(data);

    memcpy(buf,
           mxGetData(data), 
           numElements * info->Size);
    
    return (numElements * info->Size);

}



/* fillBufferH5STRING_MULTIPLE - Fill buffer with a ML string dataset.
 *
 * Inputs:
 *   buf - The buffer to fill
 *
 *   info - A linked list describing the datatype
 *
 *   data - The dataset to put in the buffer
 *
 * Outputs:
 *   The number of bytes copied
 */
int fillBufferH5STRING_MULTIPLE(char *buf, DtypeNode *info, mxArray *data)
{
    
    int i, j;
    int numElements;
    int numSubElements;
    mxArray *cellPtr;
    char *dataPr;
    
    /* Copy each cell into the buffer.
       Add \0 and offset correctly. */

    numElements = mxGetNumberOfElements(data);
    for (i = 0; i < numElements; i++)
    {
        cellPtr = mxGetCell(data, i);
        numSubElements = mxGetNumberOfElements(cellPtr);
        dataPr = (char *) mxGetData(cellPtr);
        
        /* numSubElements is the number of characters in the string. */
        for (j = 0; (j < numSubElements) && (j < info->Size); j++)
        {
            buf[i * info->Size + j] = dataPr[2 * j];
        }
        buf[i * info->Size + j] = '\0';
    }

    return (numElements * info->Size);

}



/* fillBufferH5STRING_SINGLE - Fill buffer with a ML string.
 *
 * Inputs:
 *   buf - The buffer to fill
 *
 *   info - A linked list describing the datatype
 *
 *   data - The dataset/subtype to put in the buffer
 *
 * Outputs:
 *   The number of bytes copied
 */
int fillBufferH5STRING_SINGLE(char *buf, DtypeNode *info, mxArray *data)
{

    int i;
    int numElements;
    char *dataPr;

    /* Fill the buffer by copying every other byte from the string. */

    dataPr = (char *) mxGetData(data);
    
    numElements = mxGetNumberOfElements(data);
    for (i = 0; i < numElements; i++)
    {
        buf[i] = dataPr[2 * i];
    }
    buf[i] = '\0';
    
    return (numElements + 1);

}



/* fillBufferH5STRING_UDD - Fill buffer with a string dataset in UDD.
 *
 * Inputs:
 *   buf - The buffer to fill
 *
 *   info - A linked list describing the datatype
 *
 *   data - The dataset/subtype to put in the buffer
 *
 * Outputs:
 *   The number of bytes copied
 */
int fillBufferH5STRING_UDD(char *buf, DtypeNode *info, mxArray *data)
{

    int i, j;
    int numElements;
    int numSubElements;
    char *dataPr;
    mxArray *subElement = NULL;

    /* Copy each object's "Data" field into the buffer.
       Offset correctly and terminate. */

    numElements = mxGetNumberOfElements(data);
    for (i = 0; i < numElements; i++)
    {
        subElement = NULL;
        getUDDObjectData(data, &subElement, i);
        numSubElements = mxGetNumberOfElements(subElement);
        dataPr = (char *) mxGetData(subElement);
        
        /* numSubElements is the number of characters in the string. */
        for (j = 0; (j < numSubElements) && (j < info->Size); j++)
        {
            buf[i * info->Size + j] = dataPr[2 * j];
        }

        switch (info->StringFormat)
        {
        case H5STR_NULLTERM:
            buf[i * info->Size + j] = '\0';
            break;
        case H5STR_NULLPAD:
            padStringBufferWithNulls(buf + i * info->Size, j, info);
            break;
        case H5STR_SPACEPAD:
            padStringBufferWithSpaces(buf + i * info->Size, j, info);
            break;
        }

    }
    
    return (numElements * info->Size);

}



/* fillBufferH5VLEN_UDD - Fill buffer with a vlen dataset in UDD.
 *
 * Inputs:
 *   buf - The buffer to fill
 *
 *   info - A linked list describing the datatype
 *
 *   data - The dataset/subtype to put in the buffer
 *
 * Outputs:
 *   The number of bytes copied
 */
int fillBufferH5VLEN_UDD(hvl_t *buf, DtypeNode *info, mxArray *data)
{

    int bytesCopied = 0;
    int i;
    int numElements;
    int numSubElements;
    mxArray *subElement = NULL;
    hvl_t *vlenStruct;

    /* Fill the buffer by creating new hvl_t structs, setting
     * their "len" property, allocating a sub-buffer for each
     * vlen's data elements, and filling the sub-buffers. */
    
    numElements = mxGetNumberOfElements(data);
    for (i = 0; i < numElements; i++)
    {
        /* Get the current dataset/datatype element. */
        subElement = NULL;
        getUDDObjectData(data, &subElement, i);
        numSubElements = mxGetNumberOfElements(subElement);
        
        /* Create the new hvl_t struct, which will point to the
         * vlen data. */
        vlenStruct = (hvl_t *) mxMalloc(sizeof(hvl_t));
        
        /* Create the sub-buffers which will contain the actual
         * data of the vlen arrays. */
        vlenStruct->p = makeDataBuffer(info->Child, subElement);
        vlenStruct->len = (size_t) numSubElements;
        
        /* Fill the sub-buffers. */
        fillBuffer(vlenStruct->p, info->Child, subElement);
        
        /* Copy the hvl_t struct into the output buffer. */
        memcpy(buf + i, vlenStruct, sizeof(hvl_t));
        mxFree(vlenStruct);
        bytesCopied += sizeof(hvl_t);
    }

    return bytesCopied;

}



/* getFilename - Get the output filename from a MATLAB struct.
 *
 * Inputs:
 *   fileDetails - MATLAB struct containing filename, writemode, etc.
 *
 * Outputs:
 *   A string (dynamic) containing the filename
 */
char *getFilename(const mxArray *fileDetails)
{

    mxArray *fieldPtr;

    if (!mxIsStruct(fileDetails))
        return NULL;

    fieldPtr = mxGetField(fileDetails, 0, "Filename");

    if (fieldPtr != NULL)
        return getString(fieldPtr);
    else
        return NULL;

}



/* getWriteMode - Get the output mode from a MATLAB struct.
 *
 * Inputs:
 *   fileDetails - MATLAB struct containing filename, writemode, etc.
 *
 * Outputs:
 *   A string (dynamic) containing the WriteMode value
 */
char *getWriteMode(const mxArray *fileDetails)
{

    mxArray *fieldPtr;

    if (!mxIsStruct(fileDetails))
        return NULL;

    fieldPtr = mxGetField(fileDetails, 0, "WriteMode");

    if (fieldPtr != NULL)
        return getString(fieldPtr);
    else
        return NULL;

}



/* getDefaultName - Return an empty name.
 *
 * Inputs:
 *   None
 *
 * Outputs:
 *   A empty string (dynamic)
 */
char *getDefaultName(void)
{

    char *name;
    
    name = (char *) mxMalloc(sizeof(char));

    if (name == NULL)
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:memoryAllocation",
                          "getDefaultName: Memory allocation error.");

    name[0] = '\0';
    return name;
}



/* isExistingDataset - Find if a datset already exists.
 *
 * Inputs:
 *   groupPtr - Pointer to the open group for the potential dataset
 *
 *   nameStr - Location of the dataset in the group
 *
 * Outputs:
 *   True if the dataset already exists.  False otherwise.
 */
bool isExistingDataset(hid_t groupPtr, char *nameStr)
{

    hid_t dsetPtr = H5Dopen(groupPtr, nameStr);

    if (dsetPtr < 0)
        return false;
    else
    {
        H5Dclose(dsetPtr);
        return true;
    }


}



/* setErrorPrinting - Set how HDF5 errors should be displayed.
 *
 * Inputs:
 *   debugState - A flag specifying the debug state.
 *
 * Outputs:
 *   None
 */
void setErrorPrinting(int debugState)
{

    /* Turn off HDF5 error messages if debugging is off. */
    if (~debugState)
        H5Eset_auto(NULL, NULL);

}



/* openGroup - Open an HDF5 group.
 *
 * Inputs:
 *   filePtr - HDF5 pointer to an open HDF5 file
 *
 *   nameStr - Name of the HDF group to open
 *
 * Outputs:
 *   An HDF5 pointer to the group
 */
hid_t openGroup(hid_t filePtr, char *nameStr)
{
    
    hid_t groupPtr = H5Gopen(filePtr, nameStr);

    if (groupPtr < 0)
    {
        mexErrMsgIdAndTxt("MATLAB:hdf5writec:groupCreation",
                          "openGroup: Couldn't open group.");
    }
    else
    {
        return groupPtr;
    }

}



/* padStringBufferWithNull - Add null characters to end a string.
 *
 * Inputs:
 *   buf - The character buffer
 *
 *   location - The current end of the string
 *
 *   info - Datatype details (including string length)
 *
 * Outputs:
 *   None
 */
void padStringBufferWithNulls(char *buf, int location, DtypeNode *info)
{

    int i;

    for (i = location; i < info->Size; i++)
        buf[i] = '\0';

}



/* padStringBufferWithNull - Add space characters to end a string.
 *
 * Inputs:
 *   buf - The character buffer
 *
 *   location - The current end of the string
 *
 *   info - Datatype details (including string length)
 *
 * Outputs:
 *   None
 */
void padStringBufferWithSpaces(char *buf, int location, DtypeNode *info)
{

    int i;

    for (i = location; i < info->Size; i++)
        buf[i] = ' ';

}


/* getStringFormat - Determine the format of a UDD string type.
 *
 * Inputs:
 *   data - A UDD string object
 *
 * Outputs:
 *   A constant representing the format of the string type
 */
stringFormat_t getStringFormat(const mxArray *datasetData)
{
    
    mxArray * prhs[2];
    mxArray * subsrefArg; /* A struct with fields 'Type' and 'Subs' */
    const char * fieldNames[2] = {"type", "subs"};
    mxArray * indexCell;
    mxArray * tmp = NULL;
    mxArray * plhs[1];
    char *padding;
    stringFormat_t format;

    /* (1) Use mexCallMATLAB with SUBSREF to get the nth element
     *     from the UDD object. */
    subsrefArg = mxCreateStructMatrix(1, 1, 2, fieldNames);
    indexCell = mxCreateCellMatrix(1, 1);
    mxSetCell(indexCell, 0, mxCreateDoubleScalar(1));
    
    mxSetField(subsrefArg, 0, "type", mxCreateString("()"));
    mxSetField(subsrefArg, 0, "subs", indexCell);

    prhs[0] = (mxArray *) datasetData;
    prhs[1] = subsrefArg;
    mexCallMATLAB(1, &tmp, 2, prhs, "subsref");

    /* (2) Use mexCallMATLAB to get the "Padding" field from step (1). */
    mxSetField(subsrefArg, 0, "type", mxCreateString("."));
    mxSetField(subsrefArg, 0, "subs", mxCreateString("Padding"));

    prhs[0] = tmp;
    mexCallMATLAB(1, plhs, 2, prhs, "subsref");

    padding = getString(plhs[0]);
    if (strncmp(padding, "spacepad", 8) == 0)
        format = H5STR_SPACEPAD;
    else if (strncmp(padding, "nullterm", 8) == 0)
        format = H5STR_NULLTERM;
    else if (strncmp(padding, "nullpad", 7) == 0)
        format = H5STR_NULLPAD;
    else
        format = H5STR_UNKNOWN;

    mxFree(padding);

    return format;

}



/* getLocationCell - Get the group hierarchy cell array.
 *
 * Inputs:
 *   details - A MATLAB structure with "Location" field.
 *
 * Outputs:
 *   An mxArray containing a cell array of the group hierarchy (top-down).
 */
mxArray * getLocationCell(const mxArray *details)
{
    mxArray *cellArray;

    if ((cellArray = mxGetField(details, 0, "Location")) != NULL)
        return cellArray;
    else
        return mxGetField(details, 0, "AttachedTo");

}



/* createLocation - Create a hierarchy of groups.
 *
 * Inputs: 
 *   filePtr - An HDF identifier containing the top-level for the hierarchy,
 *             usually the pointer to the file or root group.
 *
 *   locationCell - Cell array containing the group hierarchy (top-down).
 *
 * Outputs:
 *   None
 */
void createLocation(hid_t filePtr, mxArray *locationCell)
{

    hid_t parentPtr = -1;
    hid_t resultPtr = -1;
    int i, numCells;
    char *groupName;

    parentPtr = filePtr;

    numCells = mxGetNumberOfElements(locationCell);

    if (DEBUG)
        if (numCells == 0)
            mexPrintf("createLocation: Target dataset is the root group.\n");

    for (i = 0; i < numCells; i++)
    {
        /* Try opening the group to see if it exists. */
        groupName = getString(mxGetCell(locationCell, i));
        resultPtr = H5Gopen(parentPtr, groupName);

        if (resultPtr < 0)
            resultPtr = createGroup(parentPtr, groupName);

        /* Close the parent group if it's not the filePtr. */
        if (parentPtr != filePtr)
            closeGroup(parentPtr);

        /* Move on to the next subgroup. */
        mxFree(groupName);
        parentPtr = resultPtr;
            
    }

    /* Close the last group. */
    if (resultPtr >= 0)
        closeGroup(resultPtr);

}



/* openGroupFromCell - Open a group given a hierarchy cell array.
 *
 * Inputs:
 *   filePtr - An HDF identifier containing the top-level for the hierarchy,
 *             usually the pointer to the file or root group.
 *
 *   locationCell - Cell array containing the group hierarchy (top-down).
 *
 * Outputs:
 *   An HDF identifier of the deepest group in the hierarchy.
 */
hid_t openGroupFromCell(hid_t filePtr, mxArray *locationCell)
{

    hid_t parentPtr = -1;
    hid_t resultPtr = filePtr;
    int i, numCells;
    char *groupName;

    parentPtr = filePtr;

    numCells = mxGetNumberOfElements(locationCell);

    if (DEBUG)
        if (numCells == 0)
            mexPrintf("openGroupFromCell: Target dataset is the root group.\n");

    for (i = 0; i < numCells; i++)
    {
        /* Try opening the group to see if it exists. */
        groupName = getString(mxGetCell(locationCell, i));
        resultPtr = H5Gopen(parentPtr, groupName);

        if (resultPtr < 0)
            return -1;

        /* Close the parent group if it's not the filePtr. */
        if (parentPtr != filePtr)
            closeGroup(parentPtr);

        /* Move on to the subgroup. */
        mxFree(groupName);
        parentPtr = resultPtr;
            
    }

    /* Return the last group. */
    return resultPtr;
    
}



/* describeHDF5obj - A debug function that dumps an HDF5obj type.
 *
 * Inputs:
 *   object - The HDF5obj object to describe.
 *
 * Outputs:
 *   None
 */
void describeHDF5obj(HDF5obj *object)
{
    mexPrintf("HDF5obj details for object %p:\n", object);
    mexPrintf("  Type = %d\n", object->Type);
    mexPrintf("  Name = %s\n", object->Name);
}
