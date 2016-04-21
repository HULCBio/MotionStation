#ifndef __HDFWRITEC_H
#define  __HDFWRITEC_H

#include "mex.h"
#include "hdf5.h"

#define DEBUG false


typedef int hdf5type_t;

int HDF5TYPES_MAXLEN = 17;

enum hdf5types {
    H5ARRAY,
    H5ARRAY_UDD,
    H5ATTR,
    H5COMPOUND,
    H5COMPOUND_UDD,
    H5DATASET,
    H5DATATYPE,
    H5ENUM_UDD,
    H5GROUP,
    H5NATIVE,
    H5STRING_MULTIPLE,
    H5STRING_SINGLE,
    H5STRING_UDD,
    H5VLEN_UDD,
    H5UNKNOWN
};

typedef int stringFormat_t;

enum stringFormats {
    H5STR_NULLTERM,
    H5STR_NULLPAD,
    H5STR_SPACEPAD,
    H5STR_UNKNOWN
};

typedef struct DtypeNode {
    int               Rank;
    hsize_t *         Dims;
    hdf5type_t        Type;
    char *            Name;
    int               Size; /* In bytes. */
    int               Offset;
    struct DtypeNode *Next;
    struct DtypeNode *Child;
    hid_t             H5NativeType;
    int               EnumNumConstants;
    char **           EnumConstants;
    void *            EnumValues;
    stringFormat_t    StringFormat;
} DtypeNode;


typedef struct HDF5obj {
    char *      Name;
    hdf5type_t  Type;
    char *      Location;
    hid_t       Ptr;
} HDF5obj;


static bool mexAtExitIsSet = false;


void        addEnumConstantsToEnum(hid_t dtypeID, DtypeNode *dtypeInfo);

void        addFieldsToCompound(hid_t dtypeID, DtypeNode *dtypeInfo);

DtypeNode * buildArrayForCompoundDtypeInfo(const mxArray *datasetData);

DtypeNode * buildCompoundDtypeInfo(DtypeNode *childNode, 
                                   const mxArray *datasetData);

DtypeNode * buildUDDCompoundDtypeInfo(const mxArray *datasetData);

DtypeNode * buildDtypeInfo(const mxArray *datasetData);

DtypeNode * buildNativeDtypeInfo(const mxArray *datasetData);

DtypeNode * buildSubtypeInfo(const mxArray *datasetData);

void        closeFile(hid_t filePtr);

void        closeGroup(hid_t groupPtr);

void        closeObject(HDF5obj *objectPtr);

int         computeBufferSize(DtypeNode *info, const mxArray *data);

hid_t       createDataspace(const mxArray *datasetData);

hid_t       createGroup(hid_t parent, char *groupName);

hid_t       createHDF5File(char *filename);

void        createLocation(hid_t filePtr, mxArray *locationCell);

void        deleteDatatypeEnumConstants(DtypeNode *dtypeInfo);

void        deleteDtypeInfo(DtypeNode *dtypeInfo);

void        describeDtype(hid_t dtype);

void        describeDtypeInfo(DtypeNode *datatype);

void        describeHDF5obj(HDF5obj *object);

void        describeMLArray(const mxArray *array);

int         fillBuffer(void *buf, DtypeNode *info, const mxArray *data);

int         fillBufferH5ARRAY(uint8_T *buf, 
                              DtypeNode *info, 
                              mxArray *permutedData);

int         fillBufferH5ARRAY_UDD(uint8_T *buf, 
                                  DtypeNode *info, 
                                  mxArray *permutedData);

int         fillBufferH5COMPOUND(uint8_T *buf, 
                                 DtypeNode *info, 
                                 mxArray *permutedData);

int         fillBufferH5COMPOUND_UDD(uint8_T *buf, 
                                     DtypeNode *info, 
                                     mxArray *permutedData);

int         fillBufferH5NATIVE(uint8_T *buf, 
                               DtypeNode *info, 
                               mxArray *data);

int         fillBufferH5STRING_MULTIPLE(char *buf,
                                        DtypeNode *info,
                                        mxArray *data);

int         fillBufferH5STRING_SINGLE(char *buf,
                                      DtypeNode *info,
                                      mxArray *data);

int         fillBufferH5STRING_UDD(char *buf,
                                   DtypeNode *info,
                                   mxArray *data);

size_t      getArrayDtypeSize(DtypeNode *dtype);

size_t      getCompoundDtypeSize(DtypeNode *dtypeInfo);

mxArray *   getData(const mxArray *datasets, int datasetNumber);

char *      getDefaultName(void);

hsize_t *   getDims(const mxArray *value);

hsize_t     getEnumBufferSize(DtypeNode *dtypeInfo);

char *      getFilename(const mxArray *fileDetails);

hid_t       getHDF5Datatype(const mxArray *value);

char **     getHDF5EnumConstants(const mxArray *datasets, int datasetNumber);

char *      getLocationName(const mxArray *details);

mxArray *   getLocationCell(const mxArray *details);

size_t      getMaxStringLength(const mxArray *datasetData);

char *      getName(const mxArray *details);

hdf5type_t  getObjectType(const mxArray *details);

HDF5obj *   getObjectPtr(hid_t filePtr, 
                         char *objectStr, 
                         hdf5type_t objectType);

int         getRank(const mxArray *value);

char *      getString(const mxArray *stringArray);

stringFormat_t getStringFormat(const mxArray *datasetData);

hdf5type_t  getType(const mxArray *dataField);

hdf5type_t  getTypeForUDD(const mxArray *dataField);

void        getUDDObjectData(const mxArray *datasetData,
                             mxArray **subtypeData,
                             int idx);

void        getUDDObjectLength(const mxArray *datasetData,
                               mxArray **subtypeData,
                               int idx);

hsize_t     getUDDStringLength(const mxArray *datasetData);

char *      getWriteMode(const mxArray *fileDetails);

bool        isExistingDataset(hid_t groupPtr, char *nameStr);

bool        isUDD(const mxArray *dataField);

void *      makeDataBuffer(DtypeNode *info, const mxArray *datasetData);

hid_t       makeDatatype(DtypeNode *info);

DtypeNode * newDtypeNode(hdf5type_t typeID);

HDF5obj *   newHDF5obj(char *objectStr, hdf5type_t objectType);

hid_t       openFile(const mxArray *fileDetails);

hid_t       openGroup(hid_t filePtr, char *nameStr);

hid_t       openGroupFromCell(hid_t filePtr, mxArray *locationCell);

hid_t       openHDF5File(char *filename);

void        padStringBufferWithSpaces(char *buf, 
                                      int location, 
                                      DtypeNode *info);

void        padStringBufferWithNulls(char *buf, 
                                     int location, 
                                     DtypeNode *info);

void        permute(mxArray *in, mxArray **out);

void        printHDF5DtypeName(hid_t dtype_class);

void        printHdf5type(hdf5type_t type);

void        printDtypeDetails(DtypeNode *datatype);

void        setErrorPrinting(int debugState);

void        setHDF5EnumDatatypeProps(DtypeNode *dtypeInfo,
                                     const mxArray *datasetData,
                                     int idx);

void        writeAttribute(hid_t filePtr,
                           const mxArray *details,
                           const mxArray *attribute);

void        writeDataset(hid_t filePtr,
                         const mxArray *details,
                         const mxArray *dataset);

void        writeH5Attr(HDF5obj* object, 
                        const mxArray *attributeData, 
                        char *nameStr);

void        writeH5Dset(hid_t filePtr, 
                        const mxArray *datasetData, 
                        char *nameStr);

#endif /* __HDFWRITEC_H */
