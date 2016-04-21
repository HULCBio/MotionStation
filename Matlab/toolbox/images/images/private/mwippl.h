//
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.1 $
//

// This file contains definitions for a C++ MEX wraper around Intel's 
// Performance Primitives Library (IPPL).

#ifndef MW_IPPL_H
#define MW_IPPL_H

#include "ippdefs.h" //Holds definitions for IPPL data types
#include "mex.h"
#include "mwutil.h"

//The value _MSC_VER is defined by MSVC on all Windows platforms
#ifdef _MSC_VER
  #define LIBIPPI  "ippi20.dll"
  #define LIBIPPCV "ippcv20.dll"
  #define LIBIPPS  "ipps20.dll"
  #define LIBIPPAC "ippac20.dll"
  
  #define STDCALL  __stdcall

  //This flag is used by some of the IPT functions that take
  //advantage of the IPPL, e.g. imlincomb, imfilter 
  #ifndef __i386__
    #define __i386__ //It's automatically defined on i386 linux
  #endif
#else
  #define LIBIPPI  "libippi.so"
  #define LIBIPPCV "libippcv.so"
  #define LIBIPPS  "libipps.so"
  #define LIBIPPAC "libippac.so"

  #define STDCALL
#endif

//Define pointer types for IPPL methods
////////////////////////////////////////

//Support
/////////

typedef const IppLibraryVersion *(STDCALL *ippGetLibVersion_T)(void);
typedef const char *(STDCALL *ippGetStatusString_T)(IppStatus StsCode);

//Arithmetic
////////////

//Absolute difference
typedef IppStatus (STDCALL *ippiAbsDiff_8u_C1R_T)
    (const Ipp8u *,int,const Ipp8u *,int,Ipp8u *,int,IppiSize);
typedef IppStatus (STDCALL *ippiAbsDiff_32f_C1R_T)
    (const Ipp32f *,int,const Ipp32f *,int,Ipp32f *,int,IppiSize);

//Multiply
typedef IppStatus (STDCALL *ippiMul_8u_C1RSfs_T)
    (const Ipp8u *,int,const Ipp8u *,int,Ipp8u *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiMul_16s_C1RSfs_T)
    (const Ipp16s *,int,const Ipp16s *,int,Ipp16s *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiMul_32f_C1R_T)
    (const Ipp32f *,int,const Ipp32f *,int,Ipp32f *,int,IppiSize);
typedef IppStatus (STDCALL *ippiMulC_8u_C1RSfs_T)
    (const Ipp8u *,int,Ipp8u,Ipp8u *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiMulC_16s_C1RSfs_T)
    (const Ipp16s *,int,Ipp16s,Ipp16s *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiMulC_32f_C1R_T)
    (const Ipp32f *,int,Ipp32f,Ipp32f *,int,IppiSize);

//Divide
typedef IppStatus (STDCALL *ippiDiv_8u_C1RSfs_T)
    (const Ipp8u *,int,const Ipp8u *,int,Ipp8u *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiDiv_16s_C1RSfs_T)
    (const Ipp16s *,int,const Ipp16s *,int,Ipp16s *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiDiv_32f_C1R_T)
    (const Ipp32f *,int,const Ipp32f *,int,Ipp32f *,int,IppiSize);
typedef IppStatus (STDCALL *ippiDivC_8u_C1RSfs_T)
    (const Ipp8u *,int,Ipp8u,Ipp8u *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiDivC_16s_C1RSfs_T)
    (const Ipp16s *,int,Ipp16s,Ipp16s *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiDivC_32f_C1R_T)
    (const Ipp32f *,int,Ipp32f,Ipp32f *,int,IppiSize);

//Add
typedef IppStatus (STDCALL *ippiAdd_8u_C1RSfs_T)
    (const Ipp8u *,int,const Ipp8u *,int,Ipp8u *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiAdd_16s_C1RSfs_T)
    (const Ipp16s *,int,const Ipp16s *,int,Ipp16s *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiAdd_32f_C1R_T)
    (const Ipp32f *,int,const Ipp32f *,int,Ipp32f *,int,IppiSize);
typedef IppStatus (STDCALL *ippiAddC_8u_C1RSfs_T)
    (const Ipp8u *,int,Ipp8u,Ipp8u *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiAddC_16s_C1RSfs_T)
    (const Ipp16s *,int,Ipp16s,Ipp16s *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiAddC_32f_C1R_T)
    (const Ipp32f *,int,Ipp32f,Ipp32f *,int,IppiSize);

//Subtract
typedef IppStatus (STDCALL *ippiSub_8u_C1RSfs_T)
    (const Ipp8u *,int,const Ipp8u *,int,Ipp8u *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiSub_16s_C1RSfs_T)
    (const Ipp16s *,int,const Ipp16s *,int,Ipp16s *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiSub_32f_C1R_T)
    (const Ipp32f *,int,const Ipp32f *,int,Ipp32f *,int,IppiSize);
typedef IppStatus (STDCALL *ippiSubC_8u_C1RSfs_T)
    (const Ipp8u *,int,Ipp8u,Ipp8u *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiSubC_16s_C1RSfs_T)
    (const Ipp16s *,int,Ipp16s,Ipp16s *,int,IppiSize,int);
typedef IppStatus (STDCALL *ippiSubC_32f_C1R_T)
    (const Ipp32f *,int,Ipp32f,Ipp32f *,int,IppiSize);

//Filter using 32 bit integer kernel
typedef IppStatus (STDCALL *ippiFilter_8u_C1R_T)
    (const Ipp8u* pSrc, int srcStep, Ipp8u* pDst, int dstStep,
     IppiSize dstRoiSize, const Ipp32s* pKernel, IppiSize kernelSize, 
     IppiPoint anchor, int divisor);
typedef IppStatus (STDCALL *ippiFilter_16s_C1R_T)
    (const Ipp16s* pSrc, int srcStep, Ipp16s* pDst, int dstStep, 
     IppiSize dstRoiSize, const Ipp32s* pKernel,
     IppiSize kernelSize, IppiPoint anchor, int divisor );

//Filter using float kernel
typedef IppStatus (STDCALL *ippiFilter32f_8u_C1R_T)
    ( const Ipp8u* pSrc, int srcStep, Ipp8u* pDst, int dstStep,
      IppiSize dstRoiSize, const Ipp32f* pKernel,
      IppiSize kernelSize, IppiPoint anchor );

typedef IppStatus (STDCALL *ippiFilter32f_16s_C1R_T)
    ( const Ipp16s* pSrc, int srcStep, Ipp16s* pDst, int dstStep,
      IppiSize dstRoiSize, const Ipp32f* pKernel,
      IppiSize kernelSize, IppiPoint anchor );

typedef IppStatus (STDCALL *ippiFilter_32f_C1R_T)
    ( const Ipp32f* pSrc, int srcStep, Ipp32f* pDst, int dstStep,
      IppiSize dstRoiSize, const Ipp32f* pKernel,
      IppiSize kernelSize, IppiPoint anchor );

//2D full convolution
typedef IppStatus (STDCALL *ippiConvFull_8u_C1R_T)
    ( const Ipp8u* pSrc1, int src1Step, IppiSize Src1Size, 
      const Ipp8u* pSrc2, int src2Step, IppiSize Src2Size,
      Ipp8u* pDst, int dstStep, int divisor );

typedef IppStatus (STDCALL *ippiConvFull_16s_C1R_T)
    ( const Ipp16s* pSrc1, int src1Step, IppiSize Src1Size, 
      const Ipp16s* pSrc2, int src2Step, IppiSize Src2Size,
      Ipp16s* pDst, int dstStep, int divisor );

typedef IppStatus (STDCALL *ippiConvFull_32f_C1R_T)
    ( const Ipp32f* pSrc1, int src1Step, IppiSize Src1Size, 
      const Ipp32f* pSrc2, int src2Step, IppiSize Src2Size,
      Ipp32f* pDst, int dstStep );

//2D valid convolution
typedef IppStatus (STDCALL *ippiConvValid_8u_C1R_T)
    ( const Ipp8u* pSrc1, int src1Step, IppiSize Src1Size, 
      const Ipp8u* pSrc2, int src2Step, IppiSize Src2Size,
      Ipp8u* pDst, int dstStep, int divisor );

typedef IppStatus (STDCALL *ippiConvValid_16s_C1R_T)
    ( const Ipp16s* pSrc1, int src1Step, IppiSize Src1Size, 
      const Ipp16s* pSrc2, int src2Step, IppiSize Src2Size,
      Ipp16s* pDst, int dstStep, int divisor );

typedef IppStatus (STDCALL *ippiConvValid_32f_C1R_T)
    ( const Ipp32f* pSrc1, int src1Step, IppiSize Src1Size, 
      const Ipp32f* pSrc2, int src2Step, IppiSize Src2Size,
      Ipp32f* pDst, int dstStep );

//New libraries should be added between the start and end markers
typedef enum
{
    ippStart, //start marker for looping

    ippCV,    //Computer Vision
    ippS,     //Signal
    ippI,     //Image
    ippAC,    //AC lib

    ippEnd    //endMarker for looping
} libindex_T;

#define LIB_NAME_LENGTH 150
#define MAX_NUM_LIBS 15  //There are 9 libs in IPPL v2.0

typedef struct libinfo_tag //Struct for managing IPPL libraries
{
    char  libName[LIB_NAME_LENGTH];
    void *libPointer;
} libinfo_T;

class MwIppl
{

  private:
    //Variables
    ///////////
    libinfo_T fLibInfo[MAX_NUM_LIBS];
    bool      fIpplEnabled;

    //Methods
    /////////
    ippGetStatusString_T  ippGetStatusString;
    ippGetLibVersion_T    ippGetLibVersion;

  protected:

    //Methods
    /////////
    virtual bool isIpplEnabled(void);

  public:

    MwIppl();
    virtual ~MwIppl();

    //Methods
    /////////
    void   ipplCheckStatus(IppStatus statusCode);
    void  *getMethodPointer(const char *methodName, libindex_T libIndex);
    bool   getLibraryInfo(libindex_T libIndex, mxArray **mxInfo);
};

#endif //ifndef MW_IPPL_H
