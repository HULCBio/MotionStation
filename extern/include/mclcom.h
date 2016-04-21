
#ifndef mclcom_h
#define mclcom_h

#ifndef _MCLCOM_TYPEDEFS_H_
#define _MCLCOM_TYPEDEFS_H_

#pragma warning( disable : 4115 ) /* named type definition in () from one of the MS headers */

#include <windows.h>
#include <string.h>
#include <malloc.h>
#include <stdio.h>
#include <stddef.h>
#include <objbase.h>
#include <assert.h>
#include "matrix.h"
#include "mex.h"
#include <float.h>

/* CLSID's of supported object types */
extern const GUID IID_Range;

// Structure used to pass supporting info for objects into CMCLModule Init method.
typedef struct _MCLOBJECT_MAP_ENTRY
{
	// Pointer to CLSID value
	const CLSID* pclsid;
	// Pointer to function responsible for registering the class
	HRESULT (__stdcall* pfnRegisterClass)(const GUID*, unsigned short, unsigned short, 
                                          const char*, const char*, const char*, const char*);
	// Pointer to function responsible for unregistering the class
	HRESULT (__stdcall* pfnUnregisterClass)(const char*, const char*);
	// Pointer to function responsible for returning an instance of the object's class factory
	HRESULT (__stdcall* pfnGetClassObject)(REFCLSID, REFIID, void**);
	// Class's friendly name
	const char* lpszFriendlyName;
	// Class's version independent ProgID
	const char* lpszVerIndProgID;
	// Class's ProgID
	const char* lpszProgID;
} _MCLOBJECT_MAP_ENTRY, *MCLOBJECT_MAP_ENTRY;

/* Max number of tabs for output */
#define MAX_TAB		128
/* Temp buffer length for formatting output */
#define MAX_PRINTBUFF_LEN   1024

/* Struct for passing data conversion flags */
typedef struct _MCLCONVERSION_FLAGS
{
    mwArrayFormat InputFmt;     /* Input array format */
    long nInputInd;             /* Input array format indirection flag */
    mwArrayFormat OutputFmt;    /* Output array format */
    long nOutputInd;            /* Output array format indirection flag */
    bool bAutoResize;           /* Auto-resize-output flag for Excel ranges */
    bool bTranspose;            /* Transpose-output flag */
    long nTransposeInd;         /* Transpose-output indirection flag */
    mxClassID nCoerceNumeric;   /* Coerce-all-numeric-input-to-type flag */
    mwDateFormat InputDateFmt;  /* Input date format */
    mxComplexity Complexity;    /* Input-is-complex flag */
    bool bReal;                 /* Copy-to-real/imag-buffer flag */
    bool bOutputAsDate;         /* Coerce-output-to-date flag */
    long nDateBias;             /* Date bias to use in date conversion */
} _MCLCONVERSION_FLAGS, *MCLCONVERSION_FLAGS;

/* Date bias from Variant to Matlab */
#define VARIANT_DATE_BIAS   693960

/* Error codes and messages for data conversion routines */
#define MCLCOM_E_INVALID_INPUT                  -1
#define MCLCOM_E_INVALID_INPUT_MSG              "Data conversion error: Invalid input"
#define MCLCOM_E_MEM_ALLOC                      -2
#define MCLCOM_E_MEM_ALLOC_MSG                  "Data conversion error: Unable to allocate memory"
#define MCLCOM_E_INVALID_VARIANT_DATA           -3
#define MCLCOM_E_INVALID_VARIANT_DATA_MSG       "Data conversion error: Invalid VARIANT data"
#define MCLCOM_E_ACCESS_VARIANT_DATA            -4
#define MCLCOM_E_ACCESS_VARIANT_DATA_MSG        "Data conversion error: Unable to access VARIANT data"
#define MCLCOM_E_UNSUPPORTED_VARIANT_TYPE       -5
#define MCLCOM_E_UNSUPPORTED_VARIANT_TYPE_MSG   "Data conversion error: Unsupported VARIANT type"
#define MCLCOM_E_UNSUPPORTED_MATLAB_TYPE        -6
#define MCLCOM_E_UNSUPPORTED_MATLAB_TYPE_MSG    "Data conversion error: Unsupported MATLAB type"
#define MCLCOM_E_COPY_ARRAY_FROM_OBJECT         -7
#define MCLCOM_E_COPY_ARRAY_FROM_OBJECT_MSG     "Data conversion error: Unable to copy array data from object"
#define MCLCOM_E_COPY_ARRAY_TO_OBJECT           -8
#define MCLCOM_E_COPY_ARRAY_TO_OBJECT_MSG       "Data conversion error: Unable to copy array data into object"
#define MCLCOM_E_APPLICATION                    -9
#define MCLCOM_E_APPLICATION_MSG                "Error: Excel Application not set"
#define MCLCOM_E_COMCREATE                      -10
#define MCLCOM_E_COMCREATE_MSG                  "Error: Unable to create COM object"
#define MCLCOM_E_COMPLEXSIZE                    -11
#define MCLCOM_E_COMPLEXSIZE_MSG                "Data conversion error: Real and imaginary parts must be same size and type"
#define MCLCOM_E_COMPLEXTYPE                    -12
#define MCLCOM_E_COMPLEXTYPE_MSG                "Data conversion error: Complex type only defined for numeric arrays"
#define MCLCOM_E_SPARSETYPE                     -13
#define MCLCOM_E_SPARSETYPE_MSG                 "Data conversion error: Sparse type only supported for arrays of type double or logical"
#define MCLCOM_E_SPARSEINDEXTYPE                -14
#define MCLCOM_E_SPARSEINDEXTYPE_MSG            "Data conversion error: Index arrays for sparse type must resolve to int32 type"
#define MCLCOM_E_SPARSEINDEX                    -15
#define MCLCOM_E_SPARSEINDEX_MSG                "Data conversion error: Invalid index or dimension for sparse array"
#define MCLCOM_E_SPARSESIZE                     -16
#define MCLCOM_E_SPARSESIZE_MSG                 "Data conversion error: Length of row index, column index, and array data must match for sparse array"
#define MCLCOM_E_UNEXPECTED                     -17
#define MCLCOM_E_UNEXPECTED_MSG                 "Data conversion error: Unexpected error thrown"
#define MCLCOM_E_UNKNOWN_ERROR_MSG              "Data conversion error: Unknown error"


#endif //_MCLCOM_TYPEDEFS_H_

#ifdef __cplusplus
    extern "C" {
#endif


/* 
   Aquire global lock. Returns 0 for successful aquisition, -1 otherwise.
   If the global mutex is not initialized, or if the wait function fails,
   -1 is returned.
*/
extern int mclRequestGlobalLock(void);


/* 
   Release global lock. Returns 0. If the global mutex is not initialized,
   -1 is returned.
*/
extern int mclReleaseGlobalLock(void);


extern bool mclIsApplicationFlagSet(void);

extern  int mclmxArray2Variant(const mxArray* px, VARIANT* pvar, const MCLCONVERSION_FLAGS flags);

extern  int mclVariant2mxArray(const VARIANT* pvar, mxArray** ppx, const MCLCONVERSION_FLAGS flags);

extern  bool mclisVisualBasicDefault( const VARIANT *v );

extern  int mclPackVariantList(VARIANT* pVar, bool bIndFlag, ...);

extern  int mclUnpackVariantList(VARIANT* pVar, bool bIndFlag, int nStartAt, bool bAutoResize, ...);

extern  int mclMatlabDate2VariantDate(VARIANT* pVar, long nBias);

extern HRESULT mclGetConversionFlags(IMWFlags* pFlags, MCLCONVERSION_FLAGS flags);

extern void mclInitConversionFlags(MCLCONVERSION_FLAGS flags);

extern HRESULT mclSetApplication(IDispatch* pApp);

extern HRESULT mclCopyVariantToObject(VARIANT* pvar, IDispatch** ppDisp, bool bAutoResize);

extern int mclVarNumberOfElements(const VARIANT* pvar, bool* bsa);

extern bool mclIsArray(const VARIANT* pvar);

extern void mclReportError(int nRet);


/* Converts an mxArray to a Variant */
extern int mclmxArray2Variant(const mxArray* px, VARIANT* pvar, const MCLCONVERSION_FLAGS flags);


/* Converts a Variant to an mxArray */
extern int mclVariant2mxArray(const VARIANT* pvar, mxArray** ppx, const MCLCONVERSION_FLAGS flags);


extern int mclVarNumberOfElements(const VARIANT* pvar, bool* bsa);


extern bool mclIsArray(const VARIANT* pvar);


/* 
   If input VARIANT is VT_EMPTY or VT_ERROR && v->scode == DISP_E_PARAMNOTFOUND, returns true.
   Returns false otherwise. If input variant is *|VT_BYREF and reference is NULL, returns true.
   If input variant pointer is NULL, returns true.
*/
extern bool mclisVisualBasicDefault( const VARIANT *v );


/* Extracts a MCLCONVERSION_FLAGS struct from an IMWFlags pointer */
extern HRESULT mclGetConversionFlags(IMWFlags* pFlags, MCLCONVERSION_FLAGS flags);


/* Initializes a MCLCONVERSION_FLAGS struct to default values */
extern void mclInitConversionFlags(MCLCONVERSION_FLAGS flags);


/* Reports a data conversion error */
extern void mclReportError(int nRet);


/* Sets the application-registered flag. Verifies that the input
   pointer is from the MS Excel application. */
extern HRESULT mclSetApplication(IDispatch* pApp);


/* 
   Processes a variable length argument list of VARIANT* types into a single
   VARIANT array returned in the pVar argument. Elements are added to the array
   if they represent valid input based on mclisVisualBasicDefault(...) == false.
   If the bIndFlag parameter is set to true, VariantCopyInd() is called, producing
   a deep copy of any VT_BYREF data and returning the dereferenced version of the 
   data. Otherwise VariantCopy() is called on all args. The input variable argument 
   list must be terminated with a NULL pointer value. If no qualifying input args
   are supplied, then pVar is returned as VT_EMPTY. The return value is the number 
   of qualifying arguments processed.
*/
extern int mclPackVariantList(VARIANT* pVar, bool bIndFlag, ...);


/* 
   Unpacks an array of Variants into individule Variants supplied on the variable
   argument list. If the bIndFlag parameter is set to true, VariantCopyInd() is called, 
   producing a deep copy of any VT_BYREF data and returning the dereferenced version of 
   the data. Otherwise VariantCopy() is called on all args. The input variable argument 
   list must be terminated with a NULL pointer value. The return value is the number 
   of array elements processed.
*/
extern int mclUnpackVariantList(VARIANT* pVar, bool bIndFlag, int nStartAt, bool bAutoResize, ...);


/* 
   Converts a variant from Matlab to a COM DATE type. Valid Variant types for input
   to this function are VT_R8(|VT_BYREF), VT_BSTR(|VT_BYREF), VT_VARIANT|VT_BYREF, 
   VT_DISPATCH(|VT_BYREF), or arrays of these types. For VT_R8, the value is decremented 
   by nBias, and then converted to VT_DATE. For VT_BSTR, an attempt is made to 
   coerce the Variant to a VT_DATE with no decrementing. For object types, an
   attempt is made to extract the variant data from it, then this data is converted.
   If successful, the new data is copied back to the object. This function returns
   the number of Items processed.
*/
extern int mclMatlabDate2VariantDate(VARIANT* pVar, long nBias);


/* Copies a variant into an object */
extern HRESULT mclCopyVariantToObject(VARIANT* pvar, IDispatch** ppDisp, bool bAutoResize);


/* Prints the contents of an mxArray to the screen */
extern void mclPrintmxArray(const mxArray* px, int nTabs, bool bMexFlag, bool bToScreen, void(*pfn)(const char*, va_list));


/* Prints the contents of an mxArray to the screen and/or a file */
extern void mclPrintmxArray(const mxArray* px, int nTabs, bool bMexFlag, bool bToScreen, void(*pfn)(const char*, va_list));


/* Prints the contents of a Variant to the screen */
extern void mclPrintVariant(VARIANT var, int nTabs, bool bMexFlag, bool bToScreen, void(*pfn)(const char*, va_list));


/* Register the component in the registry. */
extern HRESULT mclRegisterServer(const char* szModuleName,     /* DLL module handle */
                          REFCLSID clsid,               /* Class ID */
                          REFGUID libid,                /* GUID of TypeLib */
                          unsigned short wMajorRev,     /* Major rev of type lib */
                          unsigned short wMinorRev,     /* Minor rev of type lib */
                          const char* szFriendlyName,   /* Friendly Name */
                          const char* szVerIndProgID,   /* Programmatic */
                          const char* szProgID,         /* IDs */
                          const char* szThreadingModel); /* ThreadingModel */


/* Remove the component from the registry. */
extern HRESULT mclUnregisterServer(REFCLSID clsid,             /* Class ID */
                            const char* szVerIndProgID, /* Programmatic */
                            const char* szProgID);       /* IDs */


/* Register a MatLab XL component */
extern HRESULT mclRegisterMatLabXLComponent(const char* szModuleName,     /* DLL module handle */
                                     REFCLSID clsid,               /* Class ID */
                                     REFGUID libid,                /* GUID of TypeLib */
                                     unsigned short wMajorRev,     /* Major rev of type lib */
                                     unsigned short wMinorRev,     /* Minor rev of type lib */
                                     const char* szFriendlyName,   /* Friendly Name */
                                     const char* szVerIndProgID,   /* Programmatic */
                                     const char* szProgID);         /* IDs */


/* Unregister a MatLab XL component */
extern HRESULT mclUnRegisterMatLabXLComponent(REFCLSID clsid,             /* Class ID */
                                       const char* szVerIndProgID, /* Programmatic */
                                       const char* szProgID);       /* IDs */

#ifdef __cplusplus
    }	/* extern "C" */
#endif

#endif /* mclcom_h */
