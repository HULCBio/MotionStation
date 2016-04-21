/*
 * CHECKINPUT MEX-file.  See checkinput.m for usage.
 *
 * Copyright 1993-2004 The MathWorks, Inc.
 * $Revision: 1.1.4.1 $  $Date: 2004/01/23 20:59:44 $
 */

#include <string.h>
#include <ctype.h>
#include "checkinput_mex.h"

#define MAX_CLASSNAME_LENGTH       (mxMAXNAM)
#define MAX_ATTRIBUTE_LENGTH       (63)
#define MAX_FUNCTION_NAME_LENGTH   (mxMAXNAM)
#define MAX_VARIABLE_NAME_LENGTH   (mxMAXNAM)
#define MAX_MESSAGE_TAIL_LENGTH    (63)
#define MAX_MNEMONIC_LENGTH        (63)
#define MAX_ALLOWED_CLASSES_LENGTH (127)

static
bool isReal(const mxArray *A)
{
    return (! mxIsComplex(A));
}

/*
 * Returns true if A is two-dimensional with size(A,1) == 1 or size(A,2) == 1.
 * Also returns true if A is two-dimensional and 0-by-0.
 */
static
bool isVector(const mxArray *A)
{
    return ( (mxGetNumberOfDimensions(A) == 2) &&
             ( ( (mxGetM(A) == 1) || (mxGetN(A) == 1) ) || 
               ( (mxGetM(A) == 0) && (mxGetN(A) == 0) ) ) );
}

/*
 * Returns true if A is two-dimensional with size(A,1) == 1.  Also returns
 * true if A is two-dimensional and 0-by-0.
 */
static
bool isRow(const mxArray *A)
{
    return ( (mxGetNumberOfDimensions(A) == 2) && 
             ( (mxGetM(A) == 1) || 
               ( (mxGetM(A) == 0) && (mxGetN(A) == 0) ) ) );
}

/*
 * Returns true if A is two-dimensional with size(A,2) == 1.  Also returns
 * true if A is two-dimensional and 0-by-0.
 */
static
bool isColumn(const mxArray *A)
{
    return ( (mxGetNumberOfDimensions(A) == 2) && 
             ( (mxGetN(A) == 1) || 
               ( (mxGetM(A) == 0) && (mxGetN(A) == 0) ) ) );
}

static
bool isScalar(const mxArray *A)
{
    return (mxGetNumberOfElements(A) == 1);
}

static
bool isTwoDimensional(const mxArray *A)
{
    return (mxGetNumberOfDimensions(A) == 2);
}

static
bool isNonSparse(const mxArray *A)
{
    return (! mxIsSparse(A));
}

static
bool isNonEmpty(const mxArray *A)
{
    return (! mxIsEmpty(A));
}

/*
 * isInteger returns true if A contains only real integers.
 * It returns true if A is empty.
 */
static
bool isInteger(const mxArray *A)
{
    bool result;
    int numel = mxGetNumberOfElements(A);

    /*
     * TEMPORARY: return true if input is sparse.  Need to fix this.
     */
    if (mxIsSparse(A))
    {
        return(true);
    }

    if (mxIsComplex(A))
    {
        /*
         * It is possible, using the builtin function COMPLEX, to construct
         * a real-valued array that fools MATLAB's ISREAL function, as well
         * as the API function mxIsComplex().  This is a pathological case
         * and arguably a bug in COMPLEX, and I'm going to ignore it here.
         * -SLE, August 28, 2003
         */
        result = false;
    }
    else
    {
        switch (mxGetClassID(A))
        {
          case mxDOUBLE_CLASS:
            result = chkInteger((double *) mxGetData(A), numel);
            break;
            
          case mxSINGLE_CLASS:
            result = chkInteger((float *) mxGetData(A), numel);
            break;
            
          case mxUINT8_CLASS:
          case mxUINT16_CLASS:
          case mxUINT32_CLASS:
          case mxUINT64_CLASS:
          case mxINT8_CLASS:
          case mxINT16_CLASS:
          case mxINT32_CLASS:
          case mxINT64_CLASS:
          case mxLOGICAL_CLASS:
            /* Intentional fall-through cases. */
            result = true;
            break;
            
          default:
            /* Unrecognized class; assume false. */
            result = false;
        }
    }
    
    return(result);
}

/*
 * isFinite returns true if A contains only finite values (and no NaNs).
 * isFinite returns true if A is empty.
 */
static
bool isFinite(const mxArray *A)
{
    bool result;
    int numel = mxGetNumberOfElements(A);

    /*
     * TEMPORARY: return true if input is sparse.  Need to fix this.
     */
    if (mxIsSparse(A))
    {
        return(true);
    }

    switch (mxGetClassID(A))
    {
      case mxDOUBLE_CLASS:
        result = ( chkFinite((double *) mxGetData(A), numel) &&
                   chkFinite((double *) mxGetImagData(A), numel) );
        break;

      case mxSINGLE_CLASS:
        result = ( chkFinite((float *) mxGetData(A), numel) &&
                   chkFinite((float *) mxGetImagData(A), numel) );
        break;

      case mxUINT8_CLASS:
      case mxUINT16_CLASS:
      case mxUINT32_CLASS:
      case mxUINT64_CLASS:
      case mxINT8_CLASS:
      case mxINT16_CLASS:
      case mxINT32_CLASS:
      case mxINT64_CLASS:
      case mxLOGICAL_CLASS:
        /* Intentional fall-through cases. */
        result = true;
        break;

      default:
        /* Unrecognized class; assume false. */
        result = false;
    }

    return(result);
}

/*
 * isNonNaN returns true if A contains no NaNs.
 * isNonNaN returns true if A is empty.
 */
static
bool isNonNaN(const mxArray *A)
{
    int numel = mxGetNumberOfElements(A);
    bool result;

    /*
     * TEMPORARY: return true if input is sparse.  Need to fix this.
     */
    if (mxIsSparse(A))
    {
        return(true);
    }

    switch (mxGetClassID(A))
    {
      case mxDOUBLE_CLASS:
        result = ( chkNonnan((double *) mxGetData(A), numel) &&
                   chkNonnan((double *) mxGetImagData(A), numel) );
        break;
        
      case mxSINGLE_CLASS:
        result = ( chkNonnan((float *) mxGetData(A), numel) &&
                   chkNonnan((float *) mxGetImagData(A), numel) );
        break;
        
      case mxUINT8_CLASS:
      case mxUINT16_CLASS:
      case mxUINT32_CLASS:
      case mxUINT64_CLASS:
      case mxINT8_CLASS:
      case mxINT16_CLASS:
      case mxINT32_CLASS:
      case mxINT64_CLASS:
      case mxLOGICAL_CLASS:
        /* Intentional fall-through cases. */
        result = true;
        break;

      default:
        /* Unrecognized class; assume false. */
        result = false;
    }

    return(result);
}

/*
 * isNonnegative returns true if A contains no negative values.
 * It returns true if A is empty.  Since there is no well-defined
 * ordering relationship in Z-space, it returns false if A is
 * complex.
 */
static
bool isNonnegative(const mxArray *A)
{
    bool result;
    
    /*
     * TEMPORARY: return true if input is sparse.  Need to fix this.
     */
    if (mxIsSparse(A))
    {
        return(true);
    }

    if (mxIsComplex(A))
    {
        /*
         * It is possible, using the builtin function COMPLEX, to construct
         * a real-valued array that fools MATLAB's ISREAL function, as well
         * as the API function mxIsComplex().  This is a pathological case
         * and arguably a bug in COMPLEX, and I'm going to ignore it here.
         * -SLE, August 28, 2003
         */
        result = false;
    }
    else
    {
        switch (mxGetClassID(A))
        {
          case mxDOUBLE_CLASS:
            result = chkNonnegative((double *) mxGetData(A), mxGetNumberOfElements(A));
            break;
            
          case mxSINGLE_CLASS:
            result = chkNonnegative((float *) mxGetData(A), mxGetNumberOfElements(A));
            break;
            
          case mxINT8_CLASS:
            result = chkNonnegative((int8_T *) mxGetData(A), mxGetNumberOfElements(A));
            break;
            
          case mxINT16_CLASS:
            result = chkNonnegative((int16_T *) mxGetData(A), mxGetNumberOfElements(A));
            break;
            
          case mxINT32_CLASS:
            result = chkNonnegative((int32_T *) mxGetData(A), mxGetNumberOfElements(A));
            break;
            
          case mxINT64_CLASS:
            result = chkNonnegative((int64_T *) mxGetData(A), mxGetNumberOfElements(A));
            break;
            
          case mxUINT8_CLASS:
          case mxUINT16_CLASS:
          case mxUINT32_CLASS:
          case mxUINT64_CLASS:
          case mxLOGICAL_CLASS:
            /* Intentional fall-through cases. */
            result = true;
            break;

          default:
            /* Unrecognized class; assume false. */
            result = false;
        }
    }
    
    return(result);
}
    
/*
 * isPositive returns true if A contains only positive values.
 * It returns true if A is empty.  Since there is no well-defined
 * ordering relationship in Z-space, it returns false if A is
 * complex.
 */
static
bool isPositive(const mxArray *A)
{
    bool result;
    int numel = mxGetNumberOfElements(A);

    /*
     * TEMPORARY: return true if input is sparse.  Need to fix this.
     */
    if (mxIsSparse(A))
    {
        return(true);
    }

    if (mxIsComplex(A))
    {
        /*
         * It is possible, using the builtin function COMPLEX, to construct
         * a real-valued array that fools MATLAB's ISREAL function, as well
         * as the API function mxIsComplex().  This is a pathological case
         * and arguably a bug in COMPLEX, and I'm going to ignore it here.
         * -SLE, August 28, 2003
         */
        result = false;
    }
    else
    {
        switch (mxGetClassID(A))
        {
          case mxDOUBLE_CLASS:
            result = chkPositive((double *) mxGetData(A), numel);
            break;
            
          case mxSINGLE_CLASS:
            result = chkPositive((float *) mxGetData(A), numel);
            break;
            
          case mxUINT8_CLASS:
            result = chkPositive((uint8_T *) mxGetData(A), numel);
            break;
            
          case mxUINT16_CLASS:
            result = chkPositive((uint16_T *) mxGetData(A), numel);
            break;
            
          case mxUINT32_CLASS:
            result = chkPositive((uint32_T *) mxGetData(A), numel);
            break;
            
          case mxUINT64_CLASS:
            result = chkPositive((uint64_T *) mxGetData(A), numel);
            break;
            
          case mxINT8_CLASS:
            result = chkPositive((int8_T *) mxGetData(A), numel);
            break;
            
          case mxINT16_CLASS:
            result = chkPositive((int16_T *) mxGetData(A), numel);
            break;
            
          case mxINT32_CLASS:
            result = chkPositive((int32_T *) mxGetData(A), numel);
            break;
            
          case mxINT64_CLASS:
            result = chkPositive((int64_T *) mxGetData(A), numel);
            break;
            
          case mxLOGICAL_CLASS:
            result = chkPositive(mxGetLogicals(A), numel);
            break;
            
          default:
            /* Unrecognized class; assume false. */
            result = false;
        }
    }

    return(result);
}

/*
 * isNonzero returns true if A contains no zeros.  It returns
 * true if A is empty.
 */
static
bool isNonzero(const mxArray *A)
{
    bool result;
    int numel = mxGetNumberOfElements(A);

    /*
     * TEMPORARY: return true if input is sparse.  Need to fix this.
     */
    if (mxIsSparse(A))
    {
        return(true);
    }

    if (mxIsComplex(A))
    {
        /*
         * Normally, a true return value from mxIsComplex implies that A 
         * has a nonzero imaginary part.  It is possible, using the builtin 
         * function COMPLEX, to construct a real-valued array that fools 
         * MATLAB's ISREAL function, as well as the API function mxIsComplex().  
         * This is a pathological case and arguably a bug in COMPLEX, and 
         * I'm going to ignore it here.
         * -SLE, August 28, 2003
         */
        result = false;
    }
    else
    {
        switch (mxGetClassID(A))
        {
          case mxDOUBLE_CLASS:
            result = chkNonzero((double *) mxGetData(A), numel);
            break;
            
          case mxSINGLE_CLASS:
            result = chkNonzero((float *) mxGetData(A), numel);
            break;
            
          case mxUINT8_CLASS:
            result = chkNonzero((uint8_T *) mxGetData(A), numel);
            break;
            
          case mxUINT16_CLASS:
            result = chkNonzero((uint16_T *) mxGetData(A), numel);
            break;
            
          case mxUINT32_CLASS:
            result = chkNonzero((uint32_T *) mxGetData(A), numel);
            break;
            
          case mxUINT64_CLASS:
            result = chkNonzero((uint64_T *) mxGetData(A), numel);
            break;
            
          case mxINT8_CLASS:
            result = chkNonzero((int8_T *) mxGetData(A), numel);
            break;
            
          case mxINT16_CLASS:
            result = chkNonzero((int16_T *) mxGetData(A), numel);
            break;
            
          case mxINT32_CLASS:
            result = chkNonzero((int32_T *) mxGetData(A), numel);
            break;
            
          case mxINT64_CLASS:
            result = chkNonzero((int64_T *) mxGetData(A), numel);
            break;
            
          case mxLOGICAL_CLASS:
            result = chkNonzero(mxGetLogicals(A), numel);
            break;
            
          default:
            /* Unrecognized class; assume false. */
            result = false;
        }
        
    }

    return(result);
}

/*
 * The Microsoft compiler doesn't like applying the "/" operator to bools,
 * so making an mxLogical version of the chkParityInt template in 
 * checkinput.h didn't work.  That's why we have a special version of 
 * chkParity for logicals here.
 * -SLE, August 29, 2003
 */
static
bool chkParityLogical(const mxLogical *ptr, int num_elements, bool parity)
{
    bool result = true;

    if (ptr != NULL)
    {
        for (int k = 0; k < num_elements; k++)
        {
            bool val = parity ? !ptr[k] : ptr[k];
            if (val)
            {
                result = false;
                break;
            }
        }
    }

    return(result);
}

/*
 * chkParity checks the parity of A. If parity is true it checks 
 * if the input is odd, otherwise it checks if it's even. See isEven 
 * and isOdd for further details.
 */
static
bool chkParity(const mxArray *A, bool parity)
{
    bool result;
    int numel = mxGetNumberOfElements(A);

    /*
     * TEMPORARY: return true if input is sparse.  Need to fix this.
     */
    if (mxIsSparse(A))
    {
        return(true);
    }

    if (mxIsComplex(A))
    {
        /*
         * It is possible, using the builtin function COMPLEX, to construct
         * a real-valued array that fools MATLAB's ISREAL function, as well
         * as the API function mxIsComplex().  This is a pathological case
         * and arguably a bug in COMPLEX, and I'm going to ignore it here.
         * -SLE, August 28, 2003
         */
        result = false;
    }
    else
    {
        switch (mxGetClassID(A))
        {
          case mxDOUBLE_CLASS:
            result = chkParityFloat((double *) mxGetData(A), numel, 
                                  (double)parity);
            break;

          case mxSINGLE_CLASS:
            result = chkParityFloat((float *) mxGetData(A), numel,
                                  (float)parity);
            break;

          case mxUINT8_CLASS:
            result = chkParityInt((uint8_T *) mxGetData(A), numel,
                                (uint8_T)parity);
            break;

          case mxUINT16_CLASS:
            result = chkParityInt((uint16_T *) mxGetData(A), numel,
                                (uint16_T)parity);
            break;

          case mxUINT32_CLASS:
            result = chkParityInt((uint32_T *) mxGetData(A), numel,
                                (uint32_T)parity);
            break;

          case mxUINT64_CLASS:
            result = chkParityInt((uint64_T *) mxGetData(A), numel,
                                (uint64_T)parity);
            break;

          case mxINT8_CLASS:
            result = chkParityInt((int8_T *) mxGetData(A), numel,
                                (int8_T)parity);
            break;

          case mxINT16_CLASS:
            result = chkParityInt((int16_T *) mxGetData(A), numel,
                                (int16_T)parity);
            break;

          case mxINT32_CLASS:
            result = chkParityInt((int32_T *) mxGetData(A), numel,
                                (int32_T)parity);
            break;

          case mxINT64_CLASS:
            result = chkParityInt((int64_T *) mxGetData(A), numel,
                                (int64_T)parity);
            break;

          case mxLOGICAL_CLASS:
            /*
             * TEMPORARY: return true if input is sparse.  Need
             * to fix this.
             */
            if (mxIsSparse(A))
            {
                result = true;
            }
            else
            {
                result = chkParityLogical(mxGetLogicals(A), numel, parity);
            }
            break;

          default:
            /* Unrecognized class; assume false. */
            result = false;
        }
    }

    return(result);
}

/*
 * isEven returns true if A contains only even integers.  It returns
 * true if A is empty.  It returns false if A is complex.
 */
static
bool isOdd(const mxArray *A)
{
    return(chkParity(A,true));
}

/*
 * isOdd returns true if A contains only odd integers.  It returns
 * true if A is empty.  It returns false if A is complex.
 */
static
bool isEven(const mxArray *A)
{
    return(chkParity(A,false));
}

/*
 * The attribute table contains the information necessary to check the requested
 * attributes and to issue the appropriate error message and error message ID
 * if the check fails.  For example, if this is a table entry:
 *
 *    {"vector",      IsVector,         "expectedVector",      "a vector"},
 *
 * and the caller includes 'vector' in the list of attributes to be checked,
 * checking will be done by passing the input array to the function IsVector.  If
 * the input array does have the required attribute, then an error message will be
 * issued.  "expectedVector" is used as part of the error message ID, and "a vector"
 * will be used at the end of the error message as part of the phrase 
 * "to be a vector."
 *
 * If you add to the attribute list, please update the attribute list in checkinput.m.
 *
 * The maximum allowed length of a mnemonic string is MAX_MNEMONIC_LENGTH.
 * The maximum allowed length of a message tail string is MAX_MESSAGE_TAIL_LENGTH.
 */
typedef bool (AttributeFunction)(const mxArray *A);

struct {
    char *name;
    AttributeFunction *attrfcn;
    char *mnemonic;
    char *message_tail;
} attribute_table[] = {
    {"real",        isReal,           "expectedReal",        "real"},
    {"vector",      isVector,         "expectedVector",      "a vector"},
    {"row",         isRow,            "expectedRow",         "a row vector"},
    {"column",      isColumn,         "expectedColumn",      "a column vector"},
    {"scalar",      isScalar,         "expectedScalar",      "a scalar"},
    {"twod",        isTwoDimensional, "expected2D",          "two-dimensional"},
    {"2d",          isTwoDimensional, "expected2D",          "two-dimensional"},
    {"nonsparse",   isNonSparse,      "expectedNonsparse",   "nonsparse"},
    {"nonempty",    isNonEmpty,       "expectedNonempty",    "nonempty"},
    {"integer",     isInteger,        "expectedInteger",     "integer-valued"},
    {"nonnegative", isNonnegative,    "expectedNonnegative", "nonnegative"},
    {"positive",    isPositive,       "expectedPositive",    "positive"},
    {"nonnan",      isNonNaN,         "expectedNonNaN",      "non-NaN"},
    {"finite",      isFinite,         "expectedFinite",      "finite"},
    {"nonzero",     isNonzero,        "expectedNonZero",     "nonzero"},
    {"even",        isEven,           "expectedEven",        "even"},
    {"odd",         isOdd,            "expectedOdd",         "odd"}
};

static 
int attribute_table_size = sizeof(attribute_table) / sizeof(*attribute_table);

/*
 * isValidClass returns true if class name of A is in class_list, which
 * is a cell array of strings.  class_list may contain the string 'numeric',
 * which is accepted as a shortcut for the list of class names 'double', 'single',
 * 'uint8', 'uint16', 'uint32', 'int8', 'int16', 'int32'.  This shortcut
 * may need to be removed or renamed since MATLAB now has int64 and uint64
 * numeric arrays.
 */
static 
bool isValidClass(const mxArray *A, const mxArray *class_list)
{
    char buffer[MAX_CLASSNAME_LENGTH + 1];
    int k;
    bool result = false;
    const char *A_class_name = mxGetClassName(A);

    for (k = 0; k < mxGetNumberOfElements(class_list); k++)
    {
        mxGetString(mxGetCell(class_list, k), buffer, MAX_CLASSNAME_LENGTH + 1);
        if (strcmp(buffer, "numeric") == 0)
        {
            if ( (strcmp(A_class_name, "double") == 0) ||
                 (strcmp(A_class_name, "single") == 0) || 
                 (strcmp(A_class_name, "uint8") == 0)  || 
                 (strcmp(A_class_name, "uint16") == 0) || 
                 (strcmp(A_class_name, "uint32") == 0) || 
                 (strcmp(A_class_name, "int8") == 0)   || 
                 (strcmp(A_class_name, "int16") == 0)  || 
                 (strcmp(A_class_name, "int32") == 0)     )
            {
                result = true;
                break;
            }
        }
        else if (strcmp(A_class_name, buffer) == 0)
        {
            result = true;
            break;
        }
    }

    return(result);
}

#define MAX_ORDINAL_LENGTH (12)

/*
 * NumToOrdinal(uint32_T number, char buffer[]) converts a positive integer to an
 * ordinal string (e.g., first, second, thirteenth, twentieth, 51st, 113th),
 * storing the result in buffer.  Numbers from 1 to 20 are converted to their
 * full English ordinal names.  Numbers greater than 20 are converted to a string
 * consisting of decimal digits followed by a two-character suffix.
 * 
 * The caller is responsible for ensuring that buffer has sufficient allocated space
 * to hold the result.  13 bytes (MAX_ORDINAL_LENGTH + 1) is sufficient space to 
 * convert all positive unsigned 32-bit numbers.
 */
static
void numToOrdinal(uint32_T number, char buffer[])
{
    char *ordinal_table[] = {
        "first", "second", "third", "fourth", "fifth", "sixth", "seventh",
        "eighth", "ninth", "tenth", "eleventh", "twelfth", "thirteenth",
        "fourteenth", "fifteenth", "sixteenth", "seventeenth", "eighteenth",
        "nineteenth", "twentieth"
    };
    unsigned int ordinal_table_size = sizeof(ordinal_table) / sizeof(*ordinal_table);

    char *early_century_suffix_table[] = {
        "th",   /* 500th */
        "st",   /* 501st */
        "nd",   /* 502nd */
        "rd",   /* 503rd */
        "th",   /* 504th */
        "th",   /* 505th */
        "th",   /* 506th */
        "th",   /* 507th */
        "th",   /* 508th */
        "th",   /* 509th */
        "th",   /* 510th */
        "th",   /* 511th */
        "th",   /* 512th */
        "th",   /* 513th */
        "th",   /* 514th */
        "th",   /* 515th */
        "th",   /* 516th */
        "th",   /* 517th */
        "th",   /* 518th */
        "th"    /* 519th */
    };
    unsigned int early_century_suffix_table_size = sizeof(early_century_suffix_table) /
        sizeof(*early_century_suffix_table);

    char *suffix_table[] = {
        "th",   /* 520th */
        "st",   /* 521st */
        "nd",   /* 522nd */
        "rd",   /* 523rd */
        "th",   /* 524th */
        "th",   /* 525th */
        "th",   /* 526th */
        "th",   /* 527th */
        "th",   /* 528th */
        "th"    /* 529th */
    };
    int suffix_table_size = sizeof(suffix_table) / sizeof(*suffix_table);

    mxAssert(suffix_table_size == 10, "Suffix table must have ten entries.");
    mxAssert(number >= 1, "number must be positive.");

    if (number <= ordinal_table_size)
    {
        strcpy(buffer, ordinal_table[number-1]);
    }
    else if ((number % 100) < early_century_suffix_table_size)
    {
        /* number is less than 20 greater than a multiple of 100. */
        int p = number % 100;
        sprintf(buffer, "%d%s", number, early_century_suffix_table[p]);
    }
    else
    {
        /* number is 20 or more greater than a multiple of 100. */
        int ones_digit = number % 10;
        sprintf(buffer, "%d%s", number, suffix_table[ones_digit]);
    }
}

static
void convertToUpperCase(char *str)
{
    for (unsigned int k = 0; k < strlen(str); k++)
    {
        str[k] = toupper(str[k]);
    }
}
 
static
void attributeError(const mxArray *function_name,
                    const mxArray *variable_name,
                    const mxArray *variable_position,
                    const char    *mnemonic,
                    const char    *message_tail)
{
    char message_fmt[] = "Function %s expected its %s input, %s, to be %s.";
    char function_name_string[MAX_FUNCTION_NAME_LENGTH + 1];
    char variable_name_string[MAX_VARIABLE_NAME_LENGTH + 1];
    char variable_position_string[MAX_ORDINAL_LENGTH + 1];
    char message[sizeof(message_fmt) + sizeof(function_name_string) +
                 sizeof(variable_name_string) + sizeof(variable_position_string) +
                 MAX_MESSAGE_TAIL_LENGTH];

    char message_ID_fmt[] = "map:%s:%s";
    char message_ID[sizeof(message_ID_fmt) + MAX_FUNCTION_NAME_LENGTH + 
                    MAX_MNEMONIC_LENGTH + 1];

    mxAssert(strlen(message_tail) <= MAX_MESSAGE_TAIL_LENGTH,
             "message_tail string is too long.");

    mxAssert(strlen(mnemonic) <= MAX_MNEMONIC_LENGTH,
             "mnemonic string is too long.");

    /*
     * Construct message ID.
     */
    mxGetString(function_name, function_name_string, MAX_FUNCTION_NAME_LENGTH + 1);
    sprintf(message_ID, message_ID_fmt, function_name_string, mnemonic);

    /*
     * Construct message.
     */
    convertToUpperCase(function_name_string);
    mxGetString(variable_name, variable_name_string, MAX_VARIABLE_NAME_LENGTH + 1);
    numToOrdinal((int) mxGetScalar(variable_position), variable_position_string);
    sprintf(message, message_fmt, function_name_string, variable_position_string,
            variable_name_string, message_tail);

    mexErrMsgIdAndTxt(message_ID, message);
}

static 
void checkAttributes(const mxArray *A, const mxArray *attribute_list,
                     const mxArray *function_name, const mxArray *variable_name,
                     const mxArray *variable_position)
{
    char buffer[MAX_ATTRIBUTE_LENGTH + 1];
    int num_attributes = mxGetNumberOfElements(attribute_list);
    int p;
    int q;

    for (p = 0; p < num_attributes; p++)
    {
        bool found = false;
        mxGetString(mxGetCell(attribute_list, p), buffer, MAX_ATTRIBUTE_LENGTH + 1);
        for (q = 0; q < attribute_table_size; q++)
        {
            if (strcmp(buffer, attribute_table[q].name) == 0)
            {
                found = true;
                if (! attribute_table[q].attrfcn(A))
                {
                    attributeError(function_name, variable_name, variable_position,
                                   attribute_table[q].mnemonic,
                                   attribute_table[q].message_tail);
                }
                break;
            }
        }

        if (! found)
        {
            mexWarnMsgIdAndTxt("map:checkinput:attributeNotFound",
                               "Failed to find attribute in list.");
        }
    }
}

static
void constructAllowedClassesString(const mxArray *class_list, char *buffer, int buffer_length)
{
    char class_string[MAX_CLASSNAME_LENGTH + 1];
    int class_string_length;
    int room_left = buffer_length;
    char numeric_class_string[] = 
        "double, single, uint8, uint16, uint32, "
        "int8, int16, int32";
    int numeric_class_string_length;

    /*
     * Fill the buffer with '\0' characters and decrement room_left to
     * guarantee that the constructed string will be terminated by
     * '\0' when we are done.
     */
    memset(buffer, '\0', buffer_length);
    room_left--;

    for (int k = 0; k < mxGetNumberOfElements(class_list); k++)
    {
        mxGetString(mxGetCell(class_list, k), class_string, MAX_CLASSNAME_LENGTH + 1);
        if (strcmp(class_string, "numeric") == 0)
        {
            numeric_class_string_length = strlen(numeric_class_string);
            strncpy(buffer, numeric_class_string, room_left);
            buffer += numeric_class_string_length;
            room_left -= numeric_class_string_length;
        }
        else
        {
            class_string_length = strlen(class_string);
            strncpy(buffer, class_string, room_left);
            buffer += class_string_length;
            room_left -= class_string_length;
        }
        
        if ((room_left > 2) && (k < (mxGetNumberOfElements(class_list) - 1)))
        {
            strncpy(buffer, ", ", room_left);
            buffer += 2;
            room_left -= 2;
        }
        else if (room_left <= 0)
        {
            break;
        }
    }
}
            
static
void classError(const mxArray *A, 
                const mxArray *class_list, 
                const mxArray *function_name,
                const mxArray *variable_name,
                const mxArray *variable_position)
{
    char message_fmt[] = 
        "Function %s expected its %s input, %s,\n"
        "to be one of these types:\n\n"
        "  %s\n\n"
        "Instead its type was %s.";
    char function_name_string[MAX_FUNCTION_NAME_LENGTH + 1];
    char variable_name_string[MAX_VARIABLE_NAME_LENGTH + 1];
    char variable_position_string[MAX_ORDINAL_LENGTH + 1];
    char allowed_classes_string[MAX_ALLOWED_CLASSES_LENGTH + 1];
    char input_class[MAX_CLASSNAME_LENGTH + 1];
    char message[sizeof(message_fmt) + sizeof(function_name_string) +
                 sizeof(variable_name_string) + sizeof(variable_position_string) +
                 sizeof(allowed_classes_string) + MAX_CLASSNAME_LENGTH + 1];

    char message_ID_fmt[] = "map:%s:invalidType";
    char message_ID[sizeof(message_ID_fmt) + MAX_FUNCTION_NAME_LENGTH + 1];

    /*
     * Construct message ID.
     */
    mxGetString(function_name, function_name_string, MAX_FUNCTION_NAME_LENGTH);
    sprintf(message_ID, message_ID_fmt, function_name_string);

    /*
     * Construct message.
     */
    convertToUpperCase(function_name_string);
    mxGetString(variable_name, variable_name_string, MAX_VARIABLE_NAME_LENGTH + 1);
    numToOrdinal((int) mxGetScalar(variable_position), variable_position_string);
    constructAllowedClassesString(class_list, allowed_classes_string, 
                                  MAX_ALLOWED_CLASSES_LENGTH + 1);

    /*
     * If the length the class name string is exactly MAX_CLASSNAME_LENGTH, then strncpy
     * won't put a trailing '\0' character into input_class.  So put a '\0' at the
     * end of the allocated space for input_class.
     */
    input_class[MAX_CLASSNAME_LENGTH] = '\0';
    strncpy(input_class, mxGetClassName(A), MAX_CLASSNAME_LENGTH);
    sprintf(message, message_fmt, function_name_string, variable_position_string,
            variable_name_string, allowed_classes_string, input_class);

    mexErrMsgIdAndTxt(message_ID, message);
}

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const mxArray *A;
    const mxArray *class_list;
    const mxArray *attribute_list;
    const mxArray *function_name;
    const mxArray *variable_name;
    const mxArray *variable_position;

    mxAssert(nrhs == 6, "Expected six input arguments.");

    A                 = prhs[0];
    class_list        = prhs[1];
    attribute_list    = prhs[2];
    function_name     = prhs[3];
    variable_name     = prhs[4];
    variable_position = prhs[5];

    mxAssert(mxIsCell(class_list), "class_list must be a cell array.");
    mxAssert(mxIsCell(attribute_list), "attribute_list must be a cell array.");
    
    if (! isValidClass(A, class_list))
    {
        classError(A, class_list, function_name, variable_name, variable_position);
    }

    checkAttributes(A, attribute_list, function_name, variable_name, variable_position);
}
