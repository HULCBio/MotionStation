/* $Revision: 1.1.6.1 $ */
#ifndef HDFUTILS_H
#define HDFUTILS_H

#define EMPTY    mxCreateDoubleMatrix(0, 0, mxREAL)
#define EMPTYSTR haCreateEmptyString()
#define ZERO     mxCreateDoubleMatrix(1, 1, mxREAL)

/*
 * The order of the lists in this enum must match the order 
 * of the listArray below.  Also, on mexAtExit() these lists
 * are cleaned up in the order in which they appear here.  This
 * may be important.  For example, it is important to close access, GR,
 * and RI identifiers before closing file identifiers; otherwise,
 * file identifiers may fail to close properly.
 */
typedef enum
{
    RI_ID_List = 0,
    GR_ID_List,
    GD_Grid_List,
    GD_File_List,
    Annot_ID_List,
    AN_ID_List,
    SDS_ID_List,
    SD_ID_List,
    VSdata_ID_List,
    Vgroup_ID_List,
    Vfile_ID_List,
    Point_ID_List, 
    Pointfile_ID_List,
    Swath_ID_List,
    SWFile_ID_List,
    Access_ID_List,
    File_ID_List,
    Num_ID_Lists        /* This one should always be last */
} IDList;

extern intn haMakeUChar8First(void);

extern intn haMakeChar8First(void);

extern void haLibraryInitialized(void);

extern void haInitializeLists(void);

extern intn haAddIDToList(int32 id, IDList list);

extern void haDeleteIDFromList(int32 id, IDList list);

extern void haMexAtExit(void);

extern void haQuietCleanup(void);

extern void haPrintIDListInfo(void);

extern void haNarginChk(int nMin, int nMax, int nIn);

extern void haNargoutChk(int nMin, int nMax, int nOut);

extern int haStrcmpi(const char *str1, const char *str2);

extern int32 haGetEOSCompressionCode(const mxArray *inStr);

#define NUM_EOS_COMP_PARMS 4

extern void haGetEOSCompressionParameters(const mxArray *array, 
                                           intn compparm[NUM_EOS_COMP_PARMS]);

extern int32 haGetEOSMergeCode(const mxArray *inStr);

extern uint16_T haGetCompressFlag(const mxArray *inStr);

extern mxClassID haGetClassIDFromDataType(int32 data_type);

extern int32 haGetDataTypeFromClassID(mxClassID classID);

extern int32 haGetDataTypeSize(int32 data_type);

extern const char *haGetInterlaceString(int32 il);

extern int32 haGetInterlaceFlag(const mxArray *inStr);

extern intn haGetAccessMode(const mxArray *inStr);

extern int32 haGetDataType(const mxArray *inStr);

extern const char *haGetDataTypeString(int32 datatype);

extern int32 haGetFieldIndex(const mxArray *f);

extern intn haGetDirection(const mxArray *inStr);

extern double haGetDoubleScalar(const mxArray *A, char *name);

extern double haGetNonNegativeDoubleScalar(const mxArray *A, char *name);

extern int haGetNumberOfElements(int rank,const int *siz);

extern void haGetIntegerVector(const mxArray *V, int32 rank, const char *name, 
                               int32 *vec);

extern int32 haGetDimensions(const mxArray *rank, const mxArray *dimsizes, 
                             int32 *siz);

extern char *haGetString(const mxArray *A, char *name);

extern mxArray *haCreateDoubleScalar(double scalar);

extern int32 haGetCompType(const mxArray *s);

extern mxArray *haGetCompTypeString(int32 comp_type);

extern void haGetCompInfo(const mxArray *p, const mxArray *v,comp_info *cinfo);

extern const char *haGetNumberTypeString(int32 numbertype);

extern mxArray *haGenerateNumberTypeArray(int length, int32 *numbertype);

extern mxArray *haCreateCharArray(int32 rank,const int *siz,const char *data,
                                  int32 n);

extern int haSizeMatches(const mxArray *A,int32 rank,int *siz);

extern int haIsNULL(const mxArray *A);

extern mxArray *haCreateEmptyString(void);

/*
 * haMakeArrayFromHDFDataBuffer
 *
 * Purpose: Given a data buffer, HDF data type, and
 *          MATLAB ndims and size vectors, construct
 *          an mxArray from the data buffer.
 *          Automatically construct a MATLAB string
 *          from any of the HDF char data types.
 *
 * Inputs:  ndims       --- number of dimensions of MATLAB array
 *          siz         --- MATLAB array size vector
 *          data_type   --- HDF data type flag
 *          data        --- data buffer
 * Outputs: ok_to_free  --- boolean indicating whether the
 *                          calling function is allowed
 *                          to free the data buffer
 * Return:  mxArray     --- NULL if memory failure
 */
extern
mxArray *haMakeArrayFromHDFDataBuffer(int ndims, int siz[],
                                      int32 data_type, VOIDP data,
                                      bool *ok_to_free);

/*
 * haMakeHDFDataBuffer
 *
 * Purpose: Given desired number of elements and the
 *          HDF data type, allocate and return a buffer 
 *          of the appropriate size.
 *
 * Inputs:  num_elements --- number of data elements
 *          data_type    --- HDF data type flag
 * Outputs: none
 * Return:  allocated buffer (NULL if allocation fails)
 */
extern
VOIDP haMakeHDFDataBuffer(int32 num_elements, int32 data_type);

/*
 * haMakeHDFDataBufferFromCharArray
 *
 * Purpose: Given MATLAB char array, allocate a buffer of the desired
 *          HDF data type and copy/cast the char array data into it.
 *          Caller must free the buffer.
 */
extern
VOIDP haMakeHDFDataBufferFromCharArray(const mxArray *inStr, int32 datatype);

extern int32 haGetDimensions(const mxArray *rank, const mxArray *dimsizes, int32 *siz);
extern void haGetIntegerVector(const mxArray *V, int32 rank, const char *name, int32 *vec);
extern int haGetNumberOfElements(int rank,const int *siz);
extern int32 haGetCompType(const mxArray *s);
extern void haGetCompInfo(const mxArray *p, const mxArray *v,comp_info *cinfo);
extern mxArray *haCreateCharArray(int32 rank,const int *siz,const char *data,int32 n);
extern int haSizeMatches(const mxArray *A,int32 rank,int *siz);
extern mxArray *haGetCompTypeString(int32 comp_type);
extern int haIsNULL(const mxArray *A);
extern mxArray *haCreateEmptyString(void);

#endif /* HDFUTILS_H */
