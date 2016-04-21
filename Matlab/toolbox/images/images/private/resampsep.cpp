/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $  $Date: 2003/08/01 18:11:26 $
 */

/*
 * Defines the MEX function for separable resamplers.  MATLAB function
 * syntax:
 *
 *   B = resampsep( A, M, tdims_A, tdims_B, fsize_A, fsize_B, F, R );
 *
 * resampsep() is an example of a resample_fcn as decribed in
 * makeresampler.m.
 */

/* 
 * Implementation remarks:
 * -----------------------
 * 
 * Iterator example: Path through a 4 x 3 x 2 array
 * 
 *    0   4   8           12  16  20
 *    1   5   9           13  17  21
 *    2   6  10           14  18  22
 *    3   7  11           15  19  23
 * 
 * 
 * Computing array offset from permuted and restructured cumulative
 * product array
 * 
 *   The basic idea is to perform all permutations, and as many 
 *   multiplications as possible, up front, before starting the processing 
 *   loops.  So we translate array subscripts to offsets in an unusual order.
 *   The essence is to construct the cumulative product of the array 
 *   dimensions, shifted forward with a one inserted at the front, then take
 *   its dot product with the subscript array.  However, we partition this
 *   dot product into contributions from transform dimensions and 
 *   contributions from other dimensions, permute the former, and compute
 *   the dot products at different times.
 *   
 *   Output array example:
 *     
 *     size_B = [300 400   3   7  10]
 *   
 *     tdims_B = [2 1 5]
 *   
 *   Cumulative product of sizes, with 1 inserted at the front:
 *   
 *     cp = [1   300   300*400  300*400*3   300*400*3*7]
 *   
 *   Transform dimensions: Take the 2nd, 1st, and 5th elements of cp:
 *   
 *     oCon->cpTrans = [300  1  300*400*3*7]
 *     
 *   Other dimensions: Take what's left, in order:
 *   
 *     oCon->cpOther = [300*400   300*400*3]
 *     
 *   Total output offset:
 *   
 *     (sum over k)( oCon->cpTrans[k] * oTransIt->subs[k] )
 *     
 *     + (sum over j)( oCon->cpOther[j] * otherIt->subs[j] )
 *   
 *   The sums are computed in Subs2Offset(), which is very simple and efficient
 *   because of all the work done up front.
 *   
 *   In ResampSep(), the outer loop goes over the transform dimensions and
 *   the inner loop goes over the other dimensions, so we compute and save
 *   the transform dimension contributions before starting the inner loop.
 *   
 *   The input array offsets are handled using the same general idea. But the
 *   contribution of the other dimensions to the offset is re-used from the
 *   output array computation.  And the transform dimension contributions are
 *   computed in the (innermost) convolution loop.
 *
 */

static char rcsid[] = "$Id: resampsep.cpp,v 1.1.6.3 2003/08/01 18:11:26 batserve Exp $";

#include "mex.h"
#include "matrix.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "iptutil.h"
#include "resampsep.h"

/*===================== Array Count Utility ====================*/

int  ResampSep::GetCount( const mxArray* A )
{
    const int  n = mxGetNumberOfDimensions(A);
    const int* d = mxGetDimensions(A); /* Elements of size(A) */

    int i;
    int count = d[0];
    for( i = 1; i < n; i++ )
    {
        count *= d[i];
    }

    return count;
}

/*================ Cumulative Product Utility ===================*/
/*
 * Return the cumulative products of the sizes of an mxArray,
 * with a one inserted at the front.
 */
int*  ResampSep::GetCumProd( const mxArray* A )
{
    int         k;
    int         n = mxGetNumberOfDimensions(A);
    const int*  d = mxGetDimensions(A);

    int*        cumprod = (int *)mxCalloc(n + 1, sizeof(int));

    cumprod[0] = 1;
    for( k = 0; k < n; k++ )
    {
        cumprod[k+1] = d[k] * cumprod[k];;
    }

    return cumprod;
}

/*==================== Iterator utilities ====================== */

Iterator*  ResampSep::NewIterator( const int ndims, const int* size )
{
    int k;

    Iterator* i = (Iterator*)mxCalloc(1, sizeof(*i));
    i->length = 1;
    i->size = (int*)mxCalloc(ndims,sizeof(int));
    i->subs = (int*)mxCalloc(ndims,sizeof(int));

    i->ndims  = ndims;
    i->offset = 0;
    for( k = 0; k < ndims; k++ )
    {
        i->subs[k] = 0;
        i->size[k] = size[k];
        i->length *= size[k];
    }
    return i;
}
/*
 *
 *
 */
void  ResampSep::DestroyIterator(Iterator* i)
{
    if( i != NULL )
    {
        mxFree(i->size);
        mxFree(i->subs);
        mxFree(i);
    }
}
/*
 *
 *
 */
inline void ResampSep::IncrementIterator(Iterator* i)
{
    int done = 0;
    int k = 0;
    while( !done && k < i->ndims )
    {
        (i->subs[k])++;
        if( i->subs[k] < i->size[k] )
            done = 1;
        else
            i->subs[k++] = 0;
    }
    (i->offset)++;
}
/*
 *
 *
 */
inline int ResampSep::DoneIterating(const Iterator* i)
{
    return i->offset >= i->length;
}
/*
 *
 *
 */
void ResampSep::ResetIterator(Iterator* i)
{
    int k;
    i->offset = 0;
    for( k = 0; k < i->ndims; k++ )
    {
        i->subs[k] = 0;
    }
}

/*====================== Config related methods ====================*/

/*
 *
 *
 */
Config* ResampSep::NewConfig( const mxArray* fsize, const mxArray* tdims )
{
    int k, j;
    int* cumprod;
    int* isTrans;

    Config* c = (Config*)mxCalloc(1,sizeof(*c));

    c->ndims  = GetCount(fsize);
    c->nTrans = GetCount(tdims);
    c->nOther = (c->ndims) - (c->nTrans);

    c->size    = (int*)mxCalloc(c->ndims, sizeof(int));
    c->tdims   = (int*)mxCalloc(c->nTrans,sizeof(int));
    c->tsize   = (int*)mxCalloc(c->nTrans,sizeof(int));
    c->cpTrans = (int*)mxCalloc(c->nTrans,sizeof(int));
    c->osize   = (int*)mxCalloc(c->nOther,sizeof(int));
    c->cpOther = (int*)mxCalloc(c->nOther,sizeof(int));

    isTrans = (int*)mxCalloc(c->ndims,sizeof(int));
    cumprod = (int*)mxCalloc(1 + c->ndims,sizeof(int));
    cumprod[0] = 1;
    for( k = 0; k < c->ndims; k++ )
    {
        c->size[k] = (int)((mxGetPr(fsize))[k]);
        cumprod[k+1] = cumprod[k] * c->size[k];
    }

    c->tlength = 1;
    for( k = 0; k < c->nTrans; k++ )
    {
        /* Subtract one to change to zero-based indexing */
        c->tdims[k]   = -1 + (int)((mxGetPr(tdims))[k]);
        c->tsize[k]   = c->size[c->tdims[k]];
        c->cpTrans[k] = cumprod[c->tdims[k]];
        isTrans[c->tdims[k]] = 1;
        (c->tlength) *= (c->tsize[k]);
    }

    /*
     * c->cpTrans contains the cumulative product components corresponding
     * to the transform dimensions, listed in the same order as c->tdims.
     * isTrans is 1 for all transform dimensions and 0 for the others.
     * Now copy the remaining sizes to c->osize and the remaining
     * cumulative product components to c->cpOther.
     */

    j = 0;
    for( k = 0; k < c->ndims; k++ )
    {
        if( !isTrans[k] )
        {
            c->osize[j]   = c->size[k];
            c->cpOther[j] = cumprod[k];
            j++;
        }
    }

    mxFree(cumprod);
    mxFree(isTrans);

    return c;
}


void ResampSep::DestroyConfig(Config* c)
{
    if( c != NULL )
    {
        mxFree(c->size);
        mxFree(c->tdims);
        mxFree(c->tsize);
        mxFree(c->cpTrans);
        mxFree(c->osize);
        mxFree(c->cpOther);
        mxFree(c);
    }
}

/*====================== Kernel related methods ====================*/


int ResampSep::IsKernelDefArray( const mxArray* C )
{
    return !( (mxGetClassID(C) != mxCELL_CLASS)
              || (GetCount(C) != 2)
              || (mxGetClassID(mxGetCell(C,0)) != mxDOUBLE_CLASS)
              || (mxGetClassID(mxGetCell(C,1)) != mxDOUBLE_CLASS)
              || (GetCount(mxGetCell(C,0)) != 1)
              || (mxGetScalar(mxGetCell(C,0)) <= 0.0)
              || (GetCount(mxGetCell(C,1)) < 2) );
}


Kernel* ResampSep::NewKernel( const mxArray* kernelDef )
{
    Kernel* k = NULL;



    if( kernelDef != NULL && IsKernelDefArray(kernelDef) )
    {
        int i;
        const mxArray* halfwidth    = mxGetCell(kernelDef,0);
        const mxArray* positiveHalf = mxGetCell(kernelDef,1);
        k = (Kernel *)mxCalloc(1,sizeof(Kernel));
        k->halfwidth = mxGetScalar(halfwidth);
        k->stride = (int)(ceil(2.0 * (k->halfwidth)));
        k->nSamplesInPositiveHalf = GetCount(positiveHalf);
        k->positiveHalf = 
            (double *)mxCalloc(k->nSamplesInPositiveHalf,sizeof(double));
        k->indexFactor = (k->nSamplesInPositiveHalf - 1) / k->halfwidth;
        for( i = 0; i < k->nSamplesInPositiveHalf; i++ )
        {
            k->positiveHalf[i] = (mxGetPr(positiveHalf))[i];
        }
    }
    else if( kernelDef == NULL || !mxIsEmpty(kernelDef) )
    {
        mxAssert(0, "Kernel definition must be either empty or a cell"
                 " array with form {halfWidth, positiveHalf}.");
    }

    return k;
}

void ResampSep::DestroyKernel( Kernel* k )
{
    if( k != NULL )
    {
       mxFree(k->positiveHalf);
       mxFree(k);
    }
}


/*
 * Apply bilinear interpolation to the resampling kernel if in range,
 * return zero otherwise.
 *
 * This function performs a lookup operation.  It computes the distance
 * from the new pixel to neighboring pixels and looks up a weight for that
 * distance in the interpolation kernel.  Interpolation kernel is
 * essentialy a lookup table.
 */

double ResampSep::EvaluateKernel( const Kernel* k, const double t )
{
    double result = 0.0;

    // To do: Decide which side should have equality. 
    // (We're doing a convolution.)
    if( -(k->halfwidth) < t && t <= (k->halfwidth) )
    {
        double x = k->indexFactor * fabs(t);
        int index = (int)x;  /* This is equivalent to (int)floor(x) if x>0 */
        if( index >= k->nSamplesInPositiveHalf - 1 )
        {
            result = k->positiveHalf[k->nSamplesInPositiveHalf - 1];
        }
        else
        {
            /* WJ Surprisingly, removing this operation, by replacing it with 
               result = k->positiveHalf[index]; did not provide much of a 
               speedup */
            double w1 = x - index;
            double w0 = 1.0 - w1;
            result = w0 * (k->positiveHalf[index]) + 
                     w1 * (k->positiveHalf[index + 1]);
        }
    }

    return result;
}

Kernel** ResampSep::CreateKernelset( const int nTrans, const mxArray* K )
{
    int j;
    const int singleton = (GetCount(K) == 1);
    const mxArray* sharedKernelDef = NULL;
    Kernel** kernelset = (Kernel**)mxCalloc(nTrans,sizeof(Kernel*));
    if( !mxIsEmpty(K) && mxGetClassID(K) != mxCELL_CLASS )
    {
        mexErrMsgIdAndTxt("Images:resampsep:inputKMustBeEmptyOrCellArray",
                          "%s","K (interpolating kernel array) should be"
                          " either empty or a cell array.");
    }

    if( singleton || mxIsEmpty(K) || IsKernelDefArray(K) )
    {
        /* Non-null K0 => All kernels are the same. */
        sharedKernelDef = (singleton ? mxGetCell(K,0) : K);
    }

    for( j = 0; j < nTrans; j++ )
    {
        kernelset[j] =
            (sharedKernelDef != NULL ? NewKernel(sharedKernelDef) :
             NewKernel(mxGetCell(K,j)));
    }
    return kernelset;
}

void ResampSep::DestroyKernels( const int nTrans, Kernel* kernelset[] )
{
    int j;
    for( j = 0; j < nTrans; j++ )
    {
        DestroyKernel(kernelset[j]);
    }

    mxFree(kernelset);
}

/*=========================== Pad Method helper function ===================*/

PadMethod ResampSep::PadMethodFromString( const mxArray* padmethod )
{
    const char* usage =
        "padmethod must be 'fill', 'bound', 'replicate',"
        " 'circular', or 'symmetric'.";
    
    char buf[32];
    if( mxGetString(padmethod, buf, 32) )
    {
        mexErrMsgIdAndTxt("Images:resampsep:badPadmethod",
                          "%s",usage);
    }

    if( strcmp(buf,"fill")      == 0 ) return Fill;
    if( strcmp(buf,"bound")     == 0 ) return Bound;
    if( strcmp(buf,"replicate") == 0 ) return Replicate;
    if( strcmp(buf,"circular")  == 0 ) return Circular;
    if( strcmp(buf,"symmetric") == 0 ) return Symmetric;

    mexErrMsgIdAndTxt("Images:resampsep:badPadMethod",
                      "%s",usage);
    return Replicate;
}

/*========================== Convolver related methods =====================*/

Convolver* ResampSep::NewConvolver( const Config* iCon, const mxArray* K,
                                    const PadMethod padmethod  )
{
    int k, j;
    Convolver* c = (Convolver*)mxCalloc(1,sizeof(*c));

    c->padmethod  = padmethod;
    c->ndims      = iCon->nTrans;
    c->size       = (int*)mxCalloc(c->ndims, sizeof(int));
    c->tsize      = (int*)mxCalloc(c->ndims, sizeof(int));
    c->cumsum     = (int*)mxCalloc(c->ndims + 1, sizeof(int));
    c->cumprod    = (int*)mxCalloc(c->ndims + 1, sizeof(int));
    c->weights    = (double**)mxCalloc(c->ndims, sizeof(double*));
    c->tsub       = (int**)mxCalloc(c->ndims, sizeof(int*));
    c->kernelset  = CreateKernelset(c->ndims, K);

    c->cumprod[0] = 1;
    c->cumsum[0]  = 0;
    for( k = 0; k < c->ndims; k++ )
    {
        c->size[k] = (c->kernelset[k] == NULL ? 1 : c->kernelset[k]->stride);
        c->tsize[k] = iCon->tsize[k];
        c->cumsum[k+1]  = c->size[k] + c->cumsum[k];
        c->cumprod[k+1] = c->size[k] * c->cumprod[k];
    }

    c->weight_data = (double*)mxCalloc(c->cumsum[c->ndims],sizeof(double));
    c->tsub_data   = (int*)mxCalloc(c->cumsum[c->ndims],sizeof(int));
    for( k = 0; k < c->ndims; k++ )
    {
        c->weights[k] = &(c->weight_data[c->cumsum[k]]);
        c->tsub[k]    = &(c->tsub_data[c->cumsum[k]]);
    }

    c->nPoints     = c->cumprod[c->ndims];
    c->useFill     = (int*)mxCalloc(c->nPoints,sizeof(int));
    c->subs        = (int**)mxCalloc(c->nPoints, sizeof(int*));
    c->subs_data   = (int*)mxCalloc((c->nPoints) * (c->ndims),sizeof(int));
    for( j = 0; j < c->nPoints; j++ )
    {
        c->subs[j] = &(c->subs_data[j * (c->ndims)]);
    }

    c->lo = (double*)mxCalloc(c->ndims,sizeof(double));
    c->hi = (double*)mxCalloc(c->ndims,sizeof(double));
    for( k = 0; k < c->ndims; k++ )
    {
        double h = ( (c->kernelset[k] != NULL && padmethod == Fill) ?
                      c->kernelset[k]->halfwidth : 0.5 );
        if( c->tsize[k] >= 1)
        {
            c->lo[k] = -h;
            c->hi[k] = (c->tsize[k] - 1) + h;
        }
        else /* Never in bounds if tsize is zero. */
        {
            c->lo[k] =  1;
            c->hi[k] = -1;
        }
    }

    c->localIt   = NewIterator(c->ndims, c->size);

    return c;
}


void ResampSep::DestroyConvolver( Convolver* c)
{
    if( c != NULL )
    {
        mxFree(c->size);
        mxFree(c->tsize);
        mxFree(c->cumprod);
        mxFree(c->cumsum);
        mxFree(c->weights);
        mxFree(c->tsub);
        mxFree(c->subs);
        mxFree(c->weight_data);
        mxFree(c->tsub_data);
        mxFree(c->useFill);
        mxFree(c->subs_data);
        mxFree(c->lo);
        mxFree(c->hi);
        DestroyKernels(c->ndims,c->kernelset);
        DestroyIterator(c->localIt);
        mxFree(c);
    }
}

inline
int ResampSep::UseConvolution( const Convolver* c, const double* p )
{
    if( c->padmethod == Fill || c->padmethod == Bound )
    {
        int k;
        for( k = 0; k < c->ndims; k++ )
        {
            if( !(c->lo[k] <= p[k] && p[k] < c->hi[k]) ) return 0;
        }
    }

    return 1;
}

/*
 * Adjust subscript according to the pad method. If a sub falls
 * outside the interval [0 tsize-1], follow a rule to adjust it to
 * fall within the interval or (if padMethod == Fill) set it to -1.
 * Also, adjust the subscript to -1 in the case of an empty input
 * array.
 */


int ResampSep::AdjustSubscript( const int subscript, const int tsize, 
                                const PadMethod padMethod )
{
    int sub = subscript;
    int tsize2;

    if( tsize <= 0 ) return -1; // Avoid potential zero-divide with
                                // empty input array

    switch( padMethod )
    {
     case Fill:
        sub = (sub < 0 ? -1 : (sub >= tsize ? -1 : sub));
        break;

     case Bound:
     case Replicate:
        sub = (sub < 0 ? 0 : (sub >= tsize ? tsize - 1 : sub));
        break;

     case Circular:
        sub = (sub >= 0 ? sub % tsize : tsize - 1 - ((-sub - 1) % tsize) );
        break;

     case Symmetric:
        tsize2 = 2 * tsize;
        sub = (sub >= 0 ? sub % (tsize2) : 
               tsize2 - 1 - ((-sub - 1) % tsize2) );
        sub = (sub >= tsize ? (tsize2) - sub - 1  : sub);
        break;
    }

    return sub;
}

/*
 * Given a specific point, p, construct subscript and weight arrays
 * needed to compute the value of the convolution at a single point.
 * (Use Convolve() to perform the actual computation.)
 * Set up nearest-neighbor for each dimension with a null kernel.
 * Adjust the subscripts to fall within the interval [0 tsize[k]]
 * or set to -1. A null kernel signifies nearest-neighbor interpolation.
 */

void ResampSep::InitConvolver( Convolver* c, const double* p )
{
    int k;

    for( k = 0; k < c->ndims; k++ )
    {
        int s0;
        int j;
        int s;

        // Either use the kernel or simply round p[k] for nearest
        // neighbor resampling.
        if(c->kernelset[k] != NULL)
        {
            /*
             * Translate the kernel so that its center is at center, then
             * return the lowest integer for which the kernel is defined.
             */
            s0 = (int)(ceil(p[k] - c->kernelset[k]->halfwidth));

            for( j = 0; j < c->size[k]; j++ )
            {
                s = s0 + j;

                /* use the kernel */
                c->weights[k][j] = EvaluateKernel(c->kernelset[k], p[k] - s);
                c->tsub[k][j] = AdjustSubscript( s, c->tsize[k],
                                                 c->padmethod );
            }
        }
        else
        {
            /* use MATLAB-Compatible Rounding Function */
	    /* this used to be (int)floor(p[k]+0.5); */
            s0 = (p[k] < 0.0 ? (int)(p[k]-0.5) : (int)(p[k] + 0.5));

            for( j = 0; j < c->size[k]; j++ )
            {
                s = s0 + j;

                // Set the single weight to unity for nearest 
                // neighbor resampling.
                c->weights[k][j] = 1.0;
                c->tsub[k][j] = AdjustSubscript( s, c->tsize[k], 
                                                 c->padmethod );
            }
        }
    }

    /* Save the outer product set of c->tsub in t->localsubs */
    for( ResetIterator(c->localIt); !DoneIterating(c->localIt); 
         IncrementIterator(c->localIt) )
    {
        int k;
        c->useFill[c->localIt->offset] = 0;
        for( k = 0; k < c->ndims; k++ )
        {
            int s = c->tsub[k][c->localIt->subs[k]];
            c->subs[c->localIt->offset][k] = s;

            /* Turn on useFill if the adjusted subscript is less than
               one in any of the dimensions. */
            if( s == -1 ) c->useFill[c->localIt->offset] = 1;
        }
    }
}

/*
 * Convolve
 *
 * Logically, v is a multidimensional array of input samples with
 * size given by c->size. Loop over each dimension of v from highest
 * to lowest and apply the weights, collapsing v successively until 
 * the weighted sum is fully accumluated in v[0].
 * (This function takes advantage of the separability of the
 * resampling kernels.)
 */

double ResampSep::Convolve( const Convolver* c, double* v )
{
    int k;
    for( k = c->ndims - 1; k >= 0; k-- )
    {
        int     n = c->size[k];
        double* w = c->weights[k];

        // Use the cumulative size product to iterate over the first
        // k-1 dimensions of v -- all the uncollapsed dimensions except 
        // for the highest. (For each value of q we visit a different 
        // point in this subspace.)
        int s = c->cumprod[k];
        int q;
        for( q = 0; q < s; q++ )
        {
            // Take the inner product of the k-th weight array and a (1-D) 
            // profile across the highest (i.e., k-th) uncollapsed dimension
            // of v.  Re-use memory by storing the result back in the first 
            // element of the profile.
            double t = 0.0;
            int r;
            for( r = 0; r < n; r++ )
            {
                t += w[r] * v[q + r * s];
            }
            v[q] = t;
        }
    }

    /* After repeated iterations, everything is collapsed into the */
    /* first element of v. It is now zero-dimensional (a scalar).  */
    return v[0];
}


/*======= Special 'Cumulative Product' for the Fill Value Array ============*/


int* ResampSep::CreateCPFill( const int nOther, const mxArray* F )
{
    /*
     * Prepare for efficient computation of offsets into the fill
     * array F. Create a special cumulative product array for F.
     * Its length is nOther (which may be greater than NDIMS(F)) and
     * elements corresponding to a value of 1 in SIZE(F) are set to zero.
     * The result can be multiplied (dot product via Subs2Offset) with
     * a set of non-transform subscripts to produce the correct offset into F.
     */

    const int   ndims_F = mxGetNumberOfDimensions(F);
    const int*  size_F  = mxGetDimensions(F);
    int*  cpFill  = (int*)mxCalloc( nOther, sizeof(int) );

    int partialprod = 1;
    int k;
    for( k = 0; k < ndims_F && k < nOther; k++ )
    {
        if( size_F[k] == 1 )
            cpFill[k] = 0;
        else
            cpFill[k] = partialprod;

        partialprod *= size_F[k];
    }

    for( k = ndims_F; k < nOther; k++ )
    {
        cpFill[k] = 0;
    }

    return cpFill;
}

/*========================== Subs2Offset =========================*/

/*
 * The cumulative product values in cumprod must be pre-ordered
 * to be consistent with the order of the subscripts in subs.
 */

int ResampSep::Subs2Offset( const int ndims, const int* cumprod, 
                            const int* subs )
{
    int offset = 0;
    int k;

    mxAssert(ndims > 0,       "");
    mxAssert(subs    != NULL, "");
    mxAssert(cumprod != NULL, "");

    for (k = 0; k < ndims; k++)
    {
        offset += subs[k] * cumprod[k];
    }

    return offset;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
mxArray* ResampSep::evaluate()
{
    mxClassID mClassID  = mxGetClassID(f_A);
    bool      bComplexA = mxIsComplex(f_A);


    //Allocate space for the output array and get pointer to its data
    mxArray    *B = mxCreateNumericArray(f_oCon->ndims, 
                                         f_oCon->size,
                                         mClassID,
                                         (bComplexA?mxCOMPLEX:mxREAL) );
    void *ptrBr = mxGetData(B);

    void *ptrBi = NULL;
    if(bComplexA) ptrBi = mxGetImagData(B);


    switch(mClassID)
    {
      case(mxLOGICAL_CLASS):
        resample((uint8_T *)ptrBr, (uint8_T *)ptrBi);
        break;

      case(mxUINT8_CLASS):
        resample((uint8_T *)ptrBr, (uint8_T *)ptrBi);
        break;

      case(mxINT8_CLASS):
        resample((int8_T *)ptrBr, (int8_T *)ptrBi);
        break;

      case(mxUINT16_CLASS):
        resample((uint16_T *)ptrBr, (uint16_T *)ptrBi);
        break;

      case(mxINT16_CLASS):
        resample((int16_T *)ptrBr, (int16_T *)ptrBi);
        break;

      case(mxUINT32_CLASS):
        resample((uint32_T *)ptrBr, (uint32_T *)ptrBi);
        break;

      case(mxINT32_CLASS):
        resample((int32_T *)ptrBr, (int32_T *)ptrBi);        
        break;

      case(mxSINGLE_CLASS):
        resample((float *)ptrBr, (float *)ptrBi);
        break;

      case(mxDOUBLE_CLASS):
        resample((double *)ptrBr, (double *)ptrBi);
        break;

      default:
        //Should never get here
        mexErrMsgIdAndTxt("Images:resampsep:unsuppDataType", "%s",
                          "Unsupported data type.");
        break;
    }

    return(B);
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
ResampSep::ResampSep( 
        const mxArray*  A,
        const mxArray*  M,
        const mxArray*  tdims_A,
        const mxArray*  tdims_B,
        const mxArray*  fsize_A,
        const mxArray*  fsize_B,
        const mxArray*  F,
        const mxArray*  padstr,
        const mxArray*  K
        )
{
    /* Working objects and storage:
     *   cumprodM    Cumulative product array for computing offsets into M
     *   iCon:       Configuration of input dimensions
     *   oCon:       Configuration of output dimensions
     *   convolver:  Weights and subscripts needed for convolution
     *   oTransIt:   Iterator for output transform space
     *   otherIt:    Iterator for non-transform space
     *   cpFill:     Cumulative products for computing offsets into the 
     *               fill array
     *   p:          Current point in input transform space
     *   vReal:      Input values to be used in convolution (real parts)
     *   vImag:      Input values to be used in convolution (imaginary parts)
     *
     * Return value:
     *   B:          Output array (allocated in the main routine)
     */

    f_cumprodM  = GetCumProd(M);
    f_iCon      = NewConfig( fsize_A, tdims_A );
    f_oCon      = NewConfig( fsize_B, tdims_B );
    f_convolver = NewConvolver( f_iCon, K, PadMethodFromString(padstr) );
    f_oTransIt  = NewIterator( f_oCon->nTrans, f_oCon->tsize );
    f_otherIt   = NewIterator( f_oCon->nOther, f_oCon->osize );
    f_cpFill    = CreateCPFill( f_oCon->nOther, F );
    f_p         = (double*)mxCalloc( f_iCon->nTrans, sizeof(double) );
    f_vReal     = (double*)mxCalloc( f_convolver->nPoints,
                                     sizeof(double) );
    f_vImag     = (double*)mxCalloc( f_convolver->nPoints, 
                                     sizeof(double) );


    f_M = M;
    f_F = F;
    f_A = A;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
ResampSep::~ResampSep()
{
    mxFree(f_cumprodM);
    DestroyConfig(f_iCon);
    DestroyConfig(f_oCon);
    DestroyConvolver(f_convolver);
    DestroyIterator(f_oTransIt);
    DestroyIterator(f_otherIt);
    mxFree(f_cpFill);
    mxFree(f_p);
    mxFree(f_vReal);
    mxFree(f_vImag);
}

/*========================== mexFunction ===========================*/

extern "C"
void mexFunction( int nlhs, mxArray       *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    const mxArray* A       = prhs[0];  // Input array
    const mxArray* M       = prhs[1];  // Inverse mapping from output to input
    const mxArray* tdims_A = prhs[2];  // List of input transform dimensions
    const mxArray* tdims_B = prhs[3];  // List of output transform dimensions
    const mxArray* fsize_A = prhs[4];  // Full size of input array
    const mxArray* fsize_B = prhs[5];  // Full size of output block
    const mxArray* F       = prhs[6];  // Fill value array
    const mxArray* R       = prhs[7];  // Resampler

    const mxArray* rdata;   // Resampler's data struct
    const mxArray* padstr;  // Pad method string
    const mxArray* K;       // Interplating kernel cell array

    if( nrhs != 8 )
    {
        mexErrMsgIdAndTxt("Images:resampsep:eightInputsAreRequired",
                          "%s","Eight input arguments are required.");
    }
    else if( nlhs > 1 )
    {
        mexErrMsgIdAndTxt("Images:resampsep:tooManyOutputs",
                          "%s","Too many output arguments.");
    }

    if( !mxIsStruct(R) )
    {
        mexErrMsgIdAndTxt("Images:resampsep:inputRMustBeStruct",
                          "%s","R must be a struct.");
    }

    if( (rdata = mxGetField(R,0,"rdata")) == NULL )
    {
        mexErrMsgIdAndTxt("Images:resampsep:missingRdataFieldInR",
                          "%s","R must have an rdata field.");
    }

    if( !mxIsStruct(rdata) )
    {
        mexErrMsgIdAndTxt("Images:resampsep:rdataMustBeAStruct",
                          "%s","R.rdata must be a struct.");
    }

    if( (padstr = mxGetField(R,0,"padmethod")) == NULL )
    {
        mexErrMsgIdAndTxt("Images:resampsep:missingPadmethodFieldInR",
                          "%s","R must have a padmethod field.");
    }

    if( (K = mxGetField(rdata,0,"K")) == NULL )
    {
         mexErrMsgIdAndTxt("Images:resampsep:rdataMustHaveKField",
                           "%s","R.rdata must have a K (interpolating kernel)"
                           " field.");
    }


    //Instantiate the class
    ResampSep resampSep( A, M, tdims_A, tdims_B, fsize_A, 
                         fsize_B, F, padstr, K );

    plhs[0] = resampSep.evaluate();

}
