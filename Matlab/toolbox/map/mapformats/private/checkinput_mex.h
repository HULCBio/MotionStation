/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.4.2 $  $Date: 2004/01/28 17:49:26 $
 */

#include <math.h>
#include "mex.h"

/*
 * int64_T is not defined for HPUX and SOL2
 * redefine as int64_t if this symbol is defined,
 * else revert to int32_T
 */
#ifndef int64_T
#ifdef int64_t
#define int64_T int64_t
#else
#define int64_T int32_T
#endif
#endif

#ifndef uint64_T
#ifdef uint64_t
#define uint64_T uint64_t
#else
#define uint64_T uint32_T
#endif
#endif

/*
 * chkInteger returns true if all elements of the input array are 
 * finite integers.
 */
template<typename _T1>
bool chkInteger(const _T1 *ptr, int num_elements)
{
    bool result = true;

    if (ptr != NULL)
    {
        for (int k = 0; k < num_elements; k++)
        {
            if (! mxIsFinite(ptr[k]) || (floor(ptr[k]) != ptr[k]))
            {
                result = false;
                break;
            }
        }
    }

    return(result);
}

/*
 * chkNonnegative returns true if all elements of the input array 
 * are nonnegative.
 */
template<typename _T1>
bool chkNonnegative(const _T1 *ptr, int num_elements)
{
    bool result = true;

    if (ptr != NULL)
    {
        for (int k = 0; k < num_elements; k++)
        {
            if (ptr[k] < (_T1) 0)
            {
                result = false;
                break;
            }
        }
    }

    return(result);
}

/*
 * chkPositive returns true if all elements of the input array
 * are positive.
 */
template<typename _T1>
bool chkPositive(const _T1 *ptr, int num_elements)
{
    bool result = true;

    if (ptr != NULL)
    {
        for (int k = 0; k < num_elements; k++)
        {
            if (ptr[k] <= (_T1) 0)
            {
                result = false;
                break;
            }
        }
    }
    
    return(result);
}

/*
 * chkNonnan returns true if no elements of the input array
 * are NaN.
 */
template<typename _T1>
bool chkNonnan(const _T1 *ptr, int num_elements)
{
    bool result = true;

    if (ptr != NULL)
    {
        for (int k = 0; k < num_elements; k++)
        {
            if (mxIsNaN((double) ptr[k]))
            {
                result = false;
                break;
            }
        }
    }

    return(result);
}

/*
 * chkFinite returns true if all elements of the input array
 * are finite.
 */
template<typename _T1>
bool chkFinite(const _T1 *ptr, int num_elements)
{
    bool result = true;

    if (ptr != NULL)
    {
        for (int k = 0; k < num_elements; k++)
        {
            if (! mxIsFinite((double) ptr[k]))
            {
                result = false;
                break;
            }
        }
    }

    return(result);
}

/*
 * chkNonzero returns true if any elements of the input array
 * are nonzero.  Returns false if the input array is empty.
 */
template<typename _T1>
bool chkNonzero(const _T1 *ptr, int num_elements)
{
    bool result = false;

    if (ptr != NULL)
    {
        for (int k = 0; k < num_elements; k++)
        {
            if ( (ptr[k] != (_T1) 0) )
            {
                result = true;
                break;
            }
        }
    }

    return(result);
}

/* When parity is 1, chkParityFloat returns true if all
 * elements of the input array are odd integers. If parity is 0,
 * it returns true if all elements are even integers.  
 * Parity must be set to 1 or 0.
 * The input type, _T1, must be an integer type.
 */
template<typename _T1>
bool chkParityInt(const _T1 *ptr, int num_elements, _T1 parity)
{
    bool result = true;
    parity = parity ? 0 : 1; // to be consistent with chkParityFloat

    if (ptr != NULL)
    {
        for (int k = 0; k < num_elements; k++)
        {
            if (ptr[k] & parity)
            {
                result = false;
                break;
            }
        }
    }

    return(result);
}

/* When parity is 1, chkParityFloat returns true if all
 * elements of the input array are odd integers. If parity is 0,
 * it returns true if all elements are even integers.  
 * Parity must be set to 1 or 0.
 * The input type, _T1, must be float or double.
 */
template<typename _T1>
bool chkParityFloat(const _T1 *ptr, int num_elements, _T1 parity)
{
    bool result = true;

    if (ptr != NULL)
    {
        for (int k = 0; k < num_elements; k++)
        {
            _T1 v  = ptr[k] + parity;
            _T1 vf = (_T1) floor((double) v);
            
            if ( (! mxIsFinite(v)) ||
                 (v != vf)         ||
                 (2.0 * floor(v / 2.0) != v) )
            {
                result = false;
                break;
            }
        }
    }

    return(result);
}
