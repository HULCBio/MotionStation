//
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $
//

#ifndef IMMULTMEX_H
#define IMMULTMEX_H

#include "mwippl.h"
#include "typeconv.h"
#include "iptutil_cpp.h"

class Multiply
{
  private:   

    //Member typedefs
    //////////////////
    typedef void (Multiply::*iptipplMul8u_T)
        (uint8_T *x_ptr, uint8_T *y_ptr, uint8_T *z_ptr);
    typedef void (Multiply::*iptipplMul16s_T)
        (int16_T *x_ptr, int16_T *y_ptr, int16_T *z_ptr);
    typedef void (Multiply::*iptipplMul32f_T)
        (float *x_ptr, float *y_ptr, float *z_ptr);

    //Variables
    ///////////
    
    MwIppl    *fMwIppl;
    mxClassID  fClassID;
    int        fNumElements;

    //Pointers to IPPL methods
    ippiMul_8u_C1RSfs_T   ippiMul_8u_C1RSfs;
    ippiMul_16s_C1RSfs_T  ippiMul_16s_C1RSfs;
    ippiMul_32f_C1R_T     ippiMul_32f_C1R;

    //Pointers to either IPPL or IPT methods
    iptipplMul8u_T        iptipplMul8u;
    iptipplMul16s_T       iptipplMul16s;
    iptipplMul32f_T       iptipplMul32f;

    //Templetized methods
    /////////////////////

    template<typename _T>
        void iptMulFlP(_T *x_ptr, _T *y_ptr, _T *z_ptr)
        {
            for(int k = 0; k < fNumElements; k++)
            {
                *z_ptr = (_T)(*x_ptr)*(*y_ptr);
                
                x_ptr++;y_ptr++;z_ptr++;
            }
        }
    
    ///////////////////////////////////////////////////////////////////////////
    //
    ///////////////////////////////////////////////////////////////////////////
    template<typename _T>
        void iptMulInt(_T *x_ptr, _T *y_ptr, _T *z_ptr)
        {
            for(int k = 0; k < fNumElements; k++)
            {
                saturateRoundAndCast(z_ptr, (*x_ptr)*((double)(*y_ptr)));
        
                x_ptr++;y_ptr++;z_ptr++;
            }
        }
    
    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    template<typename _T1, typename _T2>
        void ipplMul(_T1 *x_ptr, _T1 *y_ptr, _T1 *z_ptr, _T2 func_ptr)
        {
            IppiSize roiSize = {fNumElements, 1};
            int step         = roiSize.width*sizeof(_T1);
            int scaleFactor  = 0; 
            
            IppStatus statusCode = (*func_ptr)
                (x_ptr,step,y_ptr,step,z_ptr,step,roiSize,scaleFactor);
            
            fMwIppl->ipplCheckStatus(statusCode);
        }

    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    void ipplMul(uint8_T *x_ptr, uint8_T *y_ptr, uint8_T *z_ptr)
        {
            ipplMul(x_ptr, y_ptr, z_ptr, ippiMul_8u_C1RSfs);
        }

    void ipplMul(int16_T *x_ptr, int16_T *y_ptr, int16_T *z_ptr)
        {
            ipplMul(x_ptr, y_ptr, z_ptr, ippiMul_16s_C1RSfs);
        }

    void ipplMul(float *x_ptr, float *y_ptr, float *z_ptr)
        {
            IppiSize roiSize = {fNumElements, 1};
            int step = roiSize.width*sizeof(float);
            
            IppStatus statusCode = (*ippiMul_32f_C1R)
                (x_ptr,step,y_ptr,step,z_ptr,step,roiSize);
            
            fMwIppl->ipplCheckStatus(statusCode);
        }
    
  public:
    
    Multiply();
    virtual ~Multiply();
    void evaluate(void *x_ptr, void *y_ptr, void *z_ptr);
    
    //Accessor methods
    //////////////////
    void setClassID(mxClassID classID);
    void setNumElements(int numElements);
};

#endif
