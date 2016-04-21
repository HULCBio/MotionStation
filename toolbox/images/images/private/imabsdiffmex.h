//
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.1 $
//

#ifndef IMABSDIFF_H
#define IMABSDIFF_H

#include "typeconv.h"
#include "iptutil_cpp.h"
#include "mwippl.h"

class AbsDiff
{
    //Class typedefs
    ////////////////
    typedef  void (AbsDiff::*iptipplAbsDiff8u_T)
        (uint8_T *,uint8_T *,uint8_T *);
    typedef  void (AbsDiff::*iptipplAbsDiff32f_T)
        (float *,float *,float *);

    //Variables
    ///////////

    //Pointers to either IPPL or IPT methods
    iptipplAbsDiff8u_T  iptipplAbsDiff8u;
    iptipplAbsDiff32f_T iptipplAbsDiff32f;

    //Pointers to IPPL methods
    ippiAbsDiff_8u_C1R_T  ippiAbsDiff_8u_C1R;
    ippiAbsDiff_32f_C1R_T ippiAbsDiff_32f_C1R;

    MwIppl     *fMwIppl;  //Support for IPPL
    
    mxClassID   fClassID;
    int         fNumElements;

    //Methods
    /////////

    //////////////////////////////////////////////////////////////////////////
    //Templetized methods
    //
    //Note:    
    //*Due to the limitations of the MS VC++ compiler, I am forced to create 
    // dummy variables that are passed into the C++ templates. MS compiler is
    // unable to accept explicit template declarations (i.e. every type 
    // passed into the template must also be a function parameter).
    //*VC++ fails with error: "Failed to specialize function template" when 
    // the method body resides outside of the class declaration.
    //////////////////////////////////////////////////////////////////////////

    template<typename _T1, typename _T2>
        void iptAbsDiffUIntOrFlP(_T1 *x_ptr, _T1 *y_ptr,
                                 _T1 *z_ptr, _T2  dummy)
        {
            _T2 absdiff;
    
            for(int k = 0; k < fNumElements; k++)
            {
                absdiff = *x_ptr - *y_ptr;
                absdiff = (absdiff < 0) ? -absdiff : absdiff;
                *z_ptr = (_T1)absdiff;
                x_ptr++;y_ptr++;z_ptr++;
            }
        }
    
    /////////////////////////////////////////////////////////////////////////
    //
    /////////////////////////////////////////////////////////////////////////
    template<typename _T1, typename _T2>
        void iptAbsDiffInt(_T1 *x_ptr, _T1 *y_ptr,
                           _T1 *z_ptr, _T2  dummy)
        {
            _T2 absdiff;
            
            for(int k = 0; k < fNumElements; k++)
            {
                absdiff = *x_ptr - *y_ptr;
                absdiff = (absdiff < 0) ? -absdiff : absdiff;
                saturate(z_ptr, absdiff);
                x_ptr++;y_ptr++,z_ptr++;
            }
        }

    /////////////////////////////////////////////////////////////////////////
    //
    /////////////////////////////////////////////////////////////////////////
    template<typename _T1, typename _T2>
        void ipplAbsDiff(_T1 *x_ptr, _T1 *y_ptr, 
                         _T1 *z_ptr, _T2 func_ptr)
        {
            // since we are not using the ROI functionality, and our
            // arrays can be multidimentional as oppose to Intel's 2D
            // ROIs, let's pretend that we have an image of height 1 
            IppiSize roiSize = {fNumElements, 1}; //{width, height}
            int step = roiSize.width*sizeof(_T1);
            
            IppStatus statusCode =
                (*func_ptr)(x_ptr,step,y_ptr,step,z_ptr,step,roiSize);
            
            fMwIppl->ipplCheckStatus(statusCode);
        }

    //The four methods below would have been unnecessary if there was
    //a better compiler support for assigning templetized methods to
    //a function pointer, (i.e. fcn_ptr = &some_template<type>). 
    void ipplAbsDiff(uint8_T  *x_ptr, uint8_T  *y_ptr, uint8_T  *z_ptr)
        {
            ipplAbsDiff(x_ptr,y_ptr,z_ptr,ippiAbsDiff_8u_C1R);
        };
    void ipplAbsDiff(float *x_ptr, float *y_ptr, float *z_ptr)
        {
            ipplAbsDiff(x_ptr,y_ptr,z_ptr,ippiAbsDiff_32f_C1R);
        };
    void iptAbsDiff(uint8_T *x_ptr, uint8_T *y_ptr, uint8_T *z_ptr)
        {
            iptAbsDiffUIntOrFlP((uint8_T *)x_ptr, (uint8_T *)y_ptr,
                                (uint8_T *)z_ptr, (int16_T)DUMMY);
        };

    void iptAbsDiff(float *x_ptr, float *y_ptr, float *z_ptr)
        {
            iptAbsDiffUIntOrFlP((float  *)x_ptr, (float *)y_ptr,
                                (float  *)z_ptr, (double)DUMMY);
        };

  public:

    AbsDiff();
    virtual ~AbsDiff();
    void evaluate(void *x_ptr, void *y_ptr, void *z_ptr);

    //Accessor methods
    //////////////////
    void setClassID(mxClassID classID);
    void setNumElements(int numElements);
};

#endif



