//
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $
//

#ifndef IMDIVMEX_H
#define IMDIVMEX_H

#include "mwippl.h"
#include "typeconv.h"
#include "iptutil_cpp.h"

class Divide
{
  private:  
 
    //Member typedefs
    //////////////////
    typedef void (Divide::*iptipplDiv8u_T)
        (uint8_T *x_ptr, uint8_T *y_ptr, uint8_T *z_ptr);
    typedef void (Divide::*iptipplDiv16s_T)
        (int16_T *x_ptr, int16_T *y_ptr, int16_T *z_ptr);
    typedef void (Divide::*iptipplDiv32f_T)
        (float *x_ptr, float *y_ptr, float *z_ptr);

    //Variables
    ///////////
    
    MwIppl    *fMwIppl;
    mxClassID  fClassID;
    int        fNumElements;

    //Pointers to IPPL methods
    ippiDiv_8u_C1RSfs_T   ippiDiv_8u_C1RSfs;
    ippiDiv_16s_C1RSfs_T  ippiDiv_16s_C1RSfs;
    ippiDiv_32f_C1R_T     ippiDiv_32f_C1R;

    //Pointers to either IPPL or IPT methods
    iptipplDiv8u_T        iptipplDiv8u;
    iptipplDiv16s_T       iptipplDiv16s;
    iptipplDiv32f_T       iptipplDiv32f;

    // Templetized methods
    ///////////////////////
    template<typename _T1, typename _T2>
        void iptDivFlP(_T1 *x_ptr, _T1 *y_ptr, _T2 *z_ptr)
        {
            double divisor;
            bool   zero_divide_warning; 
    
            zero_divide_warning = false;
    
            for(int k = 0; k < fNumElements; k++)
            {
                divisor = *y_ptr;
                if (divisor == 0.0)
                {
                    zero_divide_warning = true;
                }
        
                *z_ptr = (_T2)(*x_ptr)/divisor;
        
                x_ptr++;y_ptr++;z_ptr++;
            }
    
            if (zero_divide_warning)
            {
                mexWarnMsgIdAndTxt("MATLAB:divideByZero", "%s", 
                                   "Divide by zero.");
            }
        }

    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    template<typename _T>
        void iptDivInt(_T *x_ptr, _T *y_ptr, _T *z_ptr)
        {
            double divisor;
            bool   zeroDivWarn = false;
    
            for(int k = 0; k < fNumElements; k++)
            {
                divisor = *y_ptr;
        
                if (divisor == 0.0)
                {
                    zeroDivWarn = true;
                    //dividing by zero would result in Inf or NaN; 
                    //instead let's handle it before it happens
                    //and immediately move on
                    if(*x_ptr == 0) //NaN
                    {
                        *z_ptr = 0;
                    }
                    else //Inf
                    {
                        if(*x_ptr > 0) setMax(z_ptr);
                        else           setMin(z_ptr);
                    }
                }
                else
                {
                    saturateRoundAndCast(z_ptr, *x_ptr/divisor);
                }
        
                x_ptr++;y_ptr++;z_ptr++;
            }
    
            if (zeroDivWarn)
            {
                mexWarnMsgIdAndTxt("MATLAB:divideByZero", "%s", 
                                   "Divide by zero.");
            }
        }
    
    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    template<typename _T1, typename _T2>
        void ipplDiv(_T1 *x_ptr, _T1 *y_ptr, _T1 *z_ptr, _T2 func_ptr)
        {
            // since we are not using the ROI functionality, and our
            // arrays can be multidimentional as oppose to Intel's 2D
            // ROIs, let's pretend that we have an image of height 1 
            IppiSize roiSize = {fNumElements, 1};
            int step = roiSize.width*sizeof(_T1);
            //Found through experimentation, not documentation, that the 
            //scale factor is a number that's added to 1 to get the factor
            //by which the result is divided. Very intuitive, isn't it?
            int scaleFactor = 0; 
    
            IppStatus statusCode = (*func_ptr)
                (y_ptr,step,x_ptr,step,z_ptr,step,roiSize,scaleFactor);
    
            if(statusCode == ippStsDivByZero)
            {
                mexWarnMsgIdAndTxt("MATLAB:divideByZero", "%s", 
                                   "Divide by zero.");
            }
            else
            {
                fMwIppl->ipplCheckStatus(statusCode);
            }
        }

    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    void ipplDiv(uint8_T *x_ptr, uint8_T *y_ptr, uint8_T *z_ptr)
        {
            ipplDiv(x_ptr, y_ptr, z_ptr, ippiDiv_8u_C1RSfs);
        }

    void ipplDiv(int16_T *x_ptr, int16_T *y_ptr, int16_T *z_ptr)
        {
            ipplDiv(x_ptr, y_ptr, z_ptr, ippiDiv_16s_C1RSfs);
        }

    void ipplDiv(float *x_ptr, float *y_ptr, float *z_ptr)
        {
            IppiSize roiSize = {fNumElements, 1};
            int step = roiSize.width*sizeof(float);
            
            IppStatus statusCode = (*ippiDiv_32f_C1R)
                (y_ptr,step,x_ptr,step,z_ptr,step,roiSize);
            
            if(statusCode == ippStsDivByZero)
            {
                mexWarnMsgIdAndTxt("MATLAB:divideByZero", "%s", 
                                   "Divide by zero.");
            }
            else
            {
                fMwIppl->ipplCheckStatus(statusCode);
            }
        }

  public:
    
    Divide();
    virtual ~Divide();
    void evaluate(void *x_ptr, void *y_ptr, void *z_ptr);
    
    //Accessor methods
    //////////////////
    void setClassID(mxClassID classID);
    void setNumElements(int numElements);
};

#endif
