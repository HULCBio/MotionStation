//
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $
//

#ifndef RESAMPSEP_H
#define RESAMPSEP_H

#include "typeconv.h"
#include "resampsep_types.h"

//////////////////////////////////////////////////////////////////////////////
// ResampSep CLASS
//////////////////////////////////////////////////////////////////////////////
class ResampSep
{

  private:   

    //Member variables
    ///////////////////

    int        *f_cumprodM;
    Config     *f_iCon;
    Config     *f_oCon;
    Convolver  *f_convolver;
    Iterator   *f_oTransIt;
    Iterator   *f_otherIt;
    int        *f_cpFill;
    double     *f_p;
    double     *f_vReal;
    double     *f_vImag;

    const mxArray    *f_F;
    const mxArray    *f_M;
    const mxArray    *f_A;
    
    //Methods
    /////////
    
    int         GetCount( const mxArray* A );
    int        *GetCumProd( const mxArray* A );

    Iterator   *NewIterator( const int ndims, const int* size );
    void        DestroyIterator(Iterator* i);
    inline void IncrementIterator(Iterator* i);
    inline int  DoneIterating(const Iterator* i);
    void        ResetIterator(Iterator* i);

    Config     *NewConfig( const mxArray* fsize, const mxArray* tdims );
    void        DestroyConfig(Config* c);

    int         IsKernelDefArray( const mxArray* C );
    Kernel     *NewKernel( const mxArray* kernelDef );
    void        DestroyKernel( Kernel* k );
    double      EvaluateKernel( const Kernel* k, const double t );
    Kernel    **CreateKernelset( const int nTrans, const mxArray* K );
    void        DestroyKernels( const int nTrans, Kernel* kernelset[] );

    PadMethod   PadMethodFromString( const mxArray* padmethod );

    Convolver  *NewConvolver( const Config* iCon, const mxArray* K,
                              const PadMethod padmethod  );
    void        DestroyConvolver( Convolver* c);
    inline int  UseConvolution( const Convolver* c, const double* p );
    int         AdjustSubscript( const int subscript, const int tsize, 
                                 const PadMethod padMethod );
    void        InitConvolver( Convolver* c, const double* p );
    double      Convolve( const Convolver* c, double* v );


    int        *CreateCPFill( const int nOther, const mxArray* F );

    inline int  Subs2Offset( const int ndims, const int* cumprod, 
                             const int* subs );

    //////////////////////////////////////////////////////////////////////////
    // Main resampling loop in a templetized form. 
    //
    // Resample using separable, shift-invariant kernels and arbitrary
    // numbers of input and output dimensions. (There is one resampling
    // kernel for each input transform dimension.)
    //
    // This function is implemented to include all offset computatations
    // (mainly calls to Subs2Offset) and access to the input (A), output (B),
    // and fill (F) arrays at the top level (rather than in function
    // calls). Therefore, it's the only place where we need to worry
    // about storage classes or imaginary parts.
    //////////////////////////////////////////////////////////////////////////
    template<typename _T>
        void resample(_T *ptrBr, _T *ptrBi)
        {
            mxClassID  mClassID = mxGetClassID(f_A);
            bool       bComplexA = mxIsComplex(f_A);
            bool       bComplexF = mxIsComplex(f_F);
            
            double    *ptrMr = mxGetPr(f_M);     /* Get pointer to M array */
            double    *ptrFr = mxGetPr(f_F);     /* Get pointer to F array */
            
            bool       bFempty = mxIsEmpty(f_F); /* For checking if 
                                                    we need to pad */
            
            _T        *ptrAr = (_T *)mxGetData(f_A); /* Get pointers to real
                                                        and imaginary parts */
            _T        *ptrAi;
            double    *ptrFi;


            if(bComplexA)
            {
                ptrAi = (_T *)mxGetImagData(f_A);
            }
            
            if(bComplexF)
            {
                ptrFi= mxGetPi(f_F);
            }
            
            
            /* Loop over the output transform space */
            for( ResetIterator(f_oTransIt); !DoneIterating(f_oTransIt);
                 IncrementIterator(f_oTransIt) )
            {
                int useConvolution = 0;
                
                /* Cache transform portion of the output offset */
                int oTransOffset = Subs2Offset(f_oCon->nTrans, 
                                               f_oCon->cpTrans,
                                               f_oTransIt->subs);
                
                /* Cache output transform portion of the offset into M */
                int mTransOffset = Subs2Offset(f_oCon->nTrans,
                                               f_cumprodM, 
                                               f_oTransIt->subs);
                
                if( !mxIsNaN(ptrMr[mTransOffset]) )
                {
                    // Extract from M the current point in input transform 
                    // space. (And subtract one to convert the values in M
                    // to a zero-based system.)
                    for( int k = 0; k < f_iCon->nTrans; k++ )
                    {
                        int mOffset = mTransOffset + k * (f_oCon->tlength);
                        f_p[k] =  -1.0 + ptrMr[mOffset];
                    }
                    useConvolution = UseConvolution(f_convolver,f_p);
                    
                    // If necessary, construct subscript and weight arrays 
                    // in the input transform space (Note that subscripts 
                    // are shifted as necessary to handle out-of-range 
                    // points.)
                    if( useConvolution ) InitConvolver( f_convolver, f_p );
                }
                
                // Loop over the non-transform output space, assigning one 
                // (scalar or complex) value on each pass
                for( ResetIterator(f_otherIt); !DoneIterating(f_otherIt);
                     IncrementIterator(f_otherIt) )
                {
                    int totalOutputOffset = oTransOffset
                        + Subs2Offset( f_oCon->nOther,
                                       f_oCon->cpOther,
                                       f_otherIt->subs );
                    double fReal = 0.0;
                    double fImag = 0.0;
                    double oReal = 0.0;
                    double oImag = 0.0;
                    
                    /* Get fill values from F now in case they're needed in
                       the convolution loop. */
                    if( !bFempty )
                    {
                        int fOffset = Subs2Offset(f_oCon->nOther,
                                                  f_cpFill,
                                                  f_otherIt->subs);
                        fReal = ptrFr[fOffset];
                        if( bComplexF ) fImag = ptrFi[fOffset];
                    }
                    
                    if( useConvolution )
                    {
                        int iOtherOffset = Subs2Offset(f_iCon->nOther, 
                                                       f_iCon->cpOther,
                                                       f_otherIt->subs);
                        
                        /* This is the convolution loop. */
                        for( int j = 0; j < f_convolver->nPoints; j++ )  
                        {
                            if( f_convolver->useFill[j] )
                            {
                                /* Mix fill values with image values near
                                   an edge (pad must be 'fill'). */
                                f_vReal[j] = fReal;
                                if( bComplexA ) f_vImag[j] = fImag;
                            }
                            else
                            {
                                int totalInputOffset = 
                                    iOtherOffset + 
                                    Subs2Offset(f_iCon->nTrans,
                                                f_iCon->cpTrans,
                                                f_convolver->subs[j]);
                                
                                f_vReal[j] = *(ptrAr + totalInputOffset);
                                
                                if( bComplexA ) 
                                    f_vImag[j] = *(ptrAi + totalInputOffset);
                            }
                        }
                        oReal = Convolve(f_convolver, f_vReal);
                        if( bComplexA ) 
                            oImag = Convolve(f_convolver, f_vImag);
                    }
                    else // if( useConvolution )
                    {
                        oReal = fReal;
                        oImag = fImag;
                    }
                    
                    convert2Type((ptrBr + totalOutputOffset), oReal);
                    
                    if( bComplexA )
                    {
                        convert2Type((ptrBi + totalOutputOffset), 
                                             oImag);
                    }
                }
            }
        }

  public:

    ResampSep(
        const mxArray*  A,       // Input array
        const mxArray*  M,       // Inverse mapping from output to input
        const mxArray*  tdims_A, // List of input transform dimensions
        const mxArray*  tdims_B, // List of output transform dimensions
        const mxArray*  fsize_A, // Full size of input array
        const mxArray*  fsize_B, // Full size of output block
        const mxArray*  F,       // Defines the fill values and dimensions iff 
                                 // non-empty
        const mxArray*  padstr,  // Method for defining values for points that
                                 // map outside A
        const mxArray*  K        // Interplating kernel cell array 
        );

    virtual ~ResampSep();

    mxArray* evaluate();
    
};


#endif
