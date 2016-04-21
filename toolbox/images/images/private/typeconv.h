//
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.1 $
//

// This file contains C++ helper functions for converting between
// different data types.

#ifndef TYPE_CONV_H
#define TYPE_CONV_H

#include "mex.h"

//////////////////////////////////////////////////////////////////////////////
// Set max/min value operators
//////////////////////////////////////////////////////////////////////////////

//Maximum values

//Operations on the logical class on the MAC must be handled using custom
//code because mxLogical on the MAC is defined as uint8_T (due to the fact
//that size(bool) = 4 on the MAC, while size(bool) is equal to 1 everywhere
//else). Because on the MAC mxLogical = uint8_T, it is not possible to
//overload methods based on these two types.
#if !defined(__APPLE__) 
inline void setMax(mxLogical *outPtr)
{
    *outPtr = true;
}
#endif
inline void setMax(uint8_T *outPtr)
{
    *outPtr = MAX_uint8_T;
}
inline void setMax(uint16_T *outPtr)
{
    *outPtr = MAX_uint16_T;
}
inline void setMax(uint32_T *outPtr)
{
    *outPtr = MAX_uint32_T;
}
inline void setMax(int8_T *outPtr)
{
    *outPtr = MAX_int8_T;
}
inline void setMax(int16_T *outPtr)
{
    *outPtr = MAX_int16_T;
}
inline void setMax(int32_T *outPtr)
{
    *outPtr = MAX_int32_T;
}

//Minimum values
#if !defined(__APPLE__)
inline void setMin(mxLogical *outPtr)
{
    *outPtr = false;
}
#endif
inline void setMin(uint8_T *outPtr)
{
    *outPtr = MIN_uint8_T;
}
inline void setMin(uint16_T *outPtr)
{
    *outPtr = MIN_uint16_T;
}
inline void setMin(uint32_T *outPtr)
{
    *outPtr = MIN_uint32_T;
}
inline void setMin(int8_T *outPtr)
{
    *outPtr = MIN_int8_T;
}
inline void setMin(int16_T *outPtr)
{
    *outPtr = MIN_int16_T;
}
inline void setMin(int32_T *outPtr)
{
    *outPtr = MIN_int32_T;
}

//////////////////////////////////////////////////////////////////////////////
// Saturate and cast operators
//////////////////////////////////////////////////////////////////////////////
template <typename _T1, typename _T2>
inline void saturateTmpl(_T1 *outPtr, _T2 inVal, _T1 minVal, _T1 maxVal)
{
    if(inVal > maxVal)
    {
        setMax(outPtr);
    }
    else if(inVal < minVal) 
    {
        setMin(outPtr);
    }
    else
    {
        *outPtr = (_T1)inVal;
    }
}

//int2int saturation
inline void saturate(int8_T *outPtr, int16_T inVal)
{
    saturateTmpl(outPtr,inVal,MIN_int8_T,MAX_int8_T);
};

inline void saturate(int16_T *outPtr, int32_T inVal)
{
    saturateTmpl(outPtr,inVal,MIN_int16_T,MAX_int16_T);
};

//double2logical
#if !defined(__APPLE__)
inline void saturate(mxLogical *outPtr, double inVal)
{
    *outPtr = (inVal >= 0.5);
};
#endif

//double2int saturation
inline void saturate(uint8_T *outPtr, double inVal)
{
    saturateTmpl(outPtr,inVal,MIN_uint8_T,MAX_uint8_T);
};

inline void saturate(int8_T *outPtr, double inVal)
{
    saturateTmpl(outPtr,inVal,MIN_int8_T,MAX_int8_T);
};

inline void saturate(uint16_T *outPtr, double inVal)
{
    saturateTmpl(outPtr,inVal,MIN_uint16_T,MAX_uint16_T);
};

inline void saturate(int16_T *outPtr, double inVal)
{
    saturateTmpl(outPtr,inVal,MIN_int16_T,MAX_int16_T);
};

inline void saturate(uint32_T *outPtr, double inVal)
{
    saturateTmpl(outPtr,inVal,MIN_uint32_T,MAX_uint32_T);
};

inline void saturate(int32_T *outPtr, double inVal)
{
    saturateTmpl(outPtr,inVal,MIN_int32_T,MAX_int32_T);
};

//these are here to make writing of a generic code easier
inline void saturate(float *outPtr, double inVal)
{
    *outPtr = (float)inVal;
};

inline void saturate(double *outPtr, double inVal)
{
    *outPtr = inVal;
};

//////////////////////////////////////////////////////////////////////////////
// Round and cast operators
//////////////////////////////////////////////////////////////////////////////
template<typename _T>
inline void roundAndCastIntTmpl(_T *outPtr, double inVal)
{
    if(inVal < 0.0)
    {
        *outPtr = (_T)(inVal-0.5);
    }
    else if(inVal > 0.0)
    {
        *outPtr = (_T)(inVal+0.5);
    }
    else
    {
        *outPtr = (_T)(inVal);
    }
}

template<typename _T>
inline void roundAndCastUIntTmpl(_T *outPtr, double inVal)
{
    *outPtr = (_T)(inVal+0.5);
}

//Logicals
#if !defined(__APPLE__)
inline void roundAndCast(mxLogical *outPtr, double inVal)
{
    *outPtr = (inVal >= 0.5);
}
#endif

//For unsigned types
inline void roundAndCast(uint8_T *outPtr, double inVal)
{
    roundAndCastUIntTmpl(outPtr, inVal);
}

inline void roundAndCast(uint16_T *outPtr, double inVal)
{
    roundAndCastUIntTmpl(outPtr, inVal);
}

inline void roundAndCast(uint32_T *outPtr, double inVal)
{
    roundAndCastUIntTmpl(outPtr, inVal);
}

//For signed types
inline void roundAndCast(int8_T *outPtr, double inVal)
{
    roundAndCastIntTmpl(outPtr, inVal);
}

inline void roundAndCast(int16_T *outPtr, double inVal)
{
    roundAndCastIntTmpl(outPtr, inVal);
}

inline void roundAndCast(int32_T *outPtr, double inVal)
{
    roundAndCastIntTmpl(outPtr, inVal);
}

//For writing generic code
inline void roundAndCast(float *outPtr, double inVal)
{
    *outPtr = (float)inVal;
}

inline void roundAndCast(double *outPtr, double inVal)
{
    *outPtr = inVal;
}

//////////////////////////////////////////////////////////////////////////////
// Saturate, round and cast operators
//////////////////////////////////////////////////////////////////////////////

template<typename _T>
inline void saturateRoundAndCastTmpl(_T *outPtr, double inVal,
                                     _T min_val, _T max_val)
{
    if(inVal > max_val)
    {
        *outPtr = max_val;
    }
    else if (inVal < min_val)
    {
        *outPtr = min_val;
    } 
    else
    {
        roundAndCast(outPtr, inVal);
    }
};

//For unsigned types
#if !defined(__APPLE__)
inline void saturateRoundAndCast(mxLogical *outPtr, double inVal)
{
    *outPtr = (inVal >= 0.5);
}
#endif
inline void saturateRoundAndCast(uint8_T *outPtr, double inVal)
{
    saturateRoundAndCastTmpl(outPtr, inVal, MIN_uint8_T, MAX_uint8_T);
}

inline void saturateRoundAndCast(uint16_T *outPtr, double inVal)
{
    saturateRoundAndCastTmpl(outPtr, inVal, MIN_uint16_T, MAX_uint16_T);
}

inline void saturateRoundAndCast(uint32_T *outPtr, double inVal)
{
    saturateRoundAndCastTmpl(outPtr, inVal, MIN_uint32_T, MAX_uint32_T);
}

//For signed types
inline void saturateRoundAndCast(int8_T *outPtr, double inVal)
{
    saturateRoundAndCastTmpl(outPtr, inVal, MIN_int8_T, MAX_int8_T);
}

inline void saturateRoundAndCast(int16_T *outPtr, double inVal)
{
    saturateRoundAndCastTmpl(outPtr, inVal, MIN_int16_T, MAX_int16_T);
}

inline void saturateRoundAndCast(int32_T *outPtr, double inVal)
{
    saturateRoundAndCastTmpl(outPtr, inVal, MIN_int32_T, MAX_int32_T);
}

//For generic code
inline void saturateRoundAndCast(float *outPtr, double inVal)
{
    *outPtr = (float)inVal;
}

inline void saturateRoundAndCast(double *outPtr, double inVal)
{
    *outPtr = inVal;
}

//////////////////////////////////////////////////////////////////////////////
// These operators perform a complete/safe conversion from double to other 
// types.  The steps in conversion include removal of NaNs, saturation,
// rounding and casting, all done appropriately for the given type.
//////////////////////////////////////////////////////////////////////////////
template<typename _T>
inline void convert2TypeTmpl(_T *outPtr, double inVal)
{
    if(mxIsNaN(inVal))
    {
        *outPtr = 0;
    }
    else
    {
        saturateRoundAndCast(outPtr, inVal);
    }
};

//Logicals
#if !defined(__APPLE__)
inline void convert2Type(mxLogical *outPtr, double inVal)
{
    convert2TypeTmpl(outPtr, inVal);
}
#endif
//For unsigned types
inline void convert2Type(uint8_T *outPtr, double inVal)
{
    convert2TypeTmpl(outPtr, inVal);
}

inline void convert2Type(int8_T *outPtr, double inVal)
{
    convert2TypeTmpl(outPtr, inVal);
}

inline void convert2Type(uint16_T *outPtr, double inVal)
{
    convert2TypeTmpl(outPtr, inVal);
}

//For signed types
inline void convert2Type(int16_T *outPtr, double inVal)
{
    convert2TypeTmpl(outPtr, inVal);
}

inline void convert2Type(uint32_T *outPtr, double inVal)
{
    convert2TypeTmpl(outPtr, inVal);
}

inline void convert2Type(int32_T *outPtr, double inVal)
{
    convert2TypeTmpl(outPtr, inVal);
}

//For generic code
inline void convert2Type(float *outPtr, double inVal)
{
    *outPtr = (float)inVal;
}

inline void convert2Type(double *outPtr, double inVal)
{
    *outPtr = inVal;
}

#endif
