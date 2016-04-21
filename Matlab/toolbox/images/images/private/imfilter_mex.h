// $Revision: 1.2.4.2 $
// Copyright 1993-2003 The MathWorks, Inc.

#ifndef _IMFILTER_MEX_H
#define _IMFILTER_MEX_H

#include <string.h>
#include "mex.h"
#include "neighborhood.h"
#include "typeconv.h"
#include "mwippl.h"
#include "iptutil_cpp.h"

#define CONV 2
#define SAME 4
#define FULL 8

#define R 0
#define I 1

class Filter
{

  private:

    //Member variables
    //////////////////

    MwIppl        *fMwIppl;
    bool           fUseIPPL;
    int            fFlags;
    const mxArray *fInSize;
    const mxArray *fKernel;
    const mxArray *fPadImage;
    const mxArray *fNonZeroKernel;
    const mxArray *fConn;
    const mxArray *fStart;

    //Pointers to IPPL methods

    ippiFilter32f_8u_C1R_T  ippiFilter32f_8u_C1R;   //float kernel
    ippiFilter32f_16s_C1R_T ippiFilter32f_16s_C1R;
    ippiFilter_32f_C1R_T    ippiFilter_32f_C1R;

    //Other IPPL methods to consider:
    //ippiConvFull_8u_C1R_T   ippiConvFull_8u_C1R;    //full convolution
    //ippiConvFull_16s_C1R_T  ippiConvFull_16s_C1R;
    //ippiConvFull_32f_C1R_T  ippiConvFull_32f_C1R;
    //ippiConvValid_8u_C1R_T  ippiConvValid_8u_C1R;   //valid convolution
    //ippiConvValid_16s_C1R_T ippiConvValid_16s_C1R;
    //ippiConvValid_32f_C1R_T ippiConvValid_32f_C1R;
    //ippiFilter_8u_C1R_T     ippiFilter_8u_C1R;      //32 bit int kernel
    //ippiFilter_16s_C1R_T    ippiFilter_16s_C1R;

    //Methods
    /////////

    int update_linear_index(int     *current_pos,
                            int32_T *image_size,
                            int     *padded_cumprod, 
                            int      num_dims,
                            int32_T *start);

    bool useIPPL(void);

    //Templetized methods
    /////////////////////

    //////////////////////////////////////////////////////////////////////////
    //  ndim_filter performs N-dimensional filtering on input buffer inBuf
    /////////////////////////////////////////////////////////////////////////
    template<typename _T1>
        void ndim_filter(_T1 *inBuf, _T1 *outBuf)
        {
            int i;
            
            // The neighborhood and neighborhood walker is used to reflect 
            // the neighborhood for convolution and to calculate the filter
            // offset values.            
            Neighborhood_T nhood;
            NeighborhoodWalker_T walker;
            
            const int *padSize    = mxGetDimensions(fPadImage); 
            int32_T   *inSize     = (int32_T *)mxGetData(fInSize);
            int        numInDims  = mxGetNumberOfElements(fInSize);
            int        numPadDims = mxGetNumberOfDimensions(fPadImage);
            
            // Do convolution only if specified by the user, otherwise, do
            // correlation. If doing convolution, the center needs to 
            // be placed "opposite" of where we want it after the 
            // reflection.
            int centerLoc;
            if( fFlags & FULL )
            {
                centerLoc = (fFlags & CONV) ? NH_CENTER_UL : NH_CENTER_LR;
            }
            else 
            {
                centerLoc = (fFlags & CONV) ? NH_CENTER_MIDDLE_ROUNDUP : 
                    NH_CENTER_MIDDLE_ROUNDDOWN;
            }
            nhood = nhMakeNeighborhood(fConn, centerLoc);
            if(fFlags & CONV) nhReflectNeighborhood(nhood);
    
            walker = nhMakeNeighborhoodWalker(nhood,padSize,
                                              numPadDims,0);

            int32_T *filter_offsets = nhGetWalkerNeighborOffsets(walker);
            
            int *padded_cumprod = (int *)mxMalloc(sizeof(int)*
                                                  (numPadDims+1));
            
            //Assuming at least one pixel in image. This works for 
            //empty inputs too.
            int num_image_pixels = 1;
            padded_cumprod[0] = 1;
            
            for(i=0; i < numPadDims; i++)
            {
                padded_cumprod[i+1] = padded_cumprod[i]*padSize[i];
            }
            
            for(i=0; i < numInDims; i++)
            {
                num_image_pixels *= inSize[i];
            }
            
            /* Initialize current position */
            int *current_pos = (int *) mxMalloc(sizeof(int)*
                                                numPadDims);

            int32_T *start = (int32_T *)mxGetData(fStart);
            memcpy(current_pos,start,numPadDims*sizeof(uint32_T));
            int32_T p = sub_to_ind(current_pos,padded_cumprod,
                                   numPadDims);
            
            // Convolve
            int     numKernElem    = mxGetNumberOfElements(fNonZeroKernel);
            double *nonZeroKernel  = mxGetPr(fNonZeroKernel);
            for(i=0; i<num_image_pixels; i++)
            {
                double sum = 0;
                for(int j=0; j < numKernElem; j++)
                {
                    sum += inBuf[ p+filter_offsets[j] ]*nonZeroKernel[j];
                }
                saturateRoundAndCast(&outBuf[i],sum);
                
                p = update_linear_index(current_pos,inSize,padded_cumprod,
                                        numPadDims,start);
            }
    
            // Clean up
            nhDestroyNeighborhood(nhood);
            nhDestroyNeighborhoodWalker(walker);
            mxFree(padded_cumprod);
            mxFree(current_pos); 
        }

    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    template<typename _T1, typename _T2>
        void ipplFilterFlpKern(_T1 *inBuf, _T1 *outBuf, _T2 funcPtr)
        {
            double *dblKernel = (double *)mxGetData(fKernel);
            int kRows = mxGetM(fKernel);
            int kCols = mxGetN(fKernel);
            
            int numKernelElements = kRows*kCols;                  
            float *fltKernel = (float *)mxCalloc(numKernelElements, 
                                                 sizeof(float));
            
            //Repackage the kernel into a float array
            if(fFlags & CONV)
            {
                for (int j=0; j<numKernelElements; j++)
                {                    
                    fltKernel[j] = (float)dblKernel[j];
                }
            }
            else
            {   //rotate the kernel by 180 degrees to get correlation
                for (int j=0; j<numKernelElements; j++)
                {                    
                    fltKernel[j] = (float)dblKernel[numKernelElements-j-1];
                }
            }
            
            //IN DIMS
            IppiSize kernelSize = {kRows, kCols};
            int inRows = mxGetM(fPadImage);
            int inCols = mxGetN(fPadImage);
            
            //OUT DIMS
            int32_T  *inSize  = (int32_T *)mxGetData(fInSize);
            int outRows = inSize[0];
            int outCols = inSize[1];
            
            //Intel's anchor point with respect to UL corner of the kernel.
            //Notice that for 'same' conv or corr, the anchor in some of 
            //the cases may be outside of the kernel dimensions; although 
            //I don't believe that Intel software developers intended
            //their code being used with such inputs, the resulting
            //matrices match the desired Matlab output.  For full correlation
            //and convolution, it will always work out to be the lower 
            //right corner of the kernel.
            IppiPoint anchor = {inRows - outRows, inCols-outCols};
            
            IppiSize dstRoiSize = {outRows, outCols};                  
            int srcStep = inRows*sizeof(_T1);
            int dstStep = dstRoiSize.width*sizeof(_T1);
            
            //Invoke Intel's code
            IppStatus statusCode = (*funcPtr)
                (inBuf,srcStep,outBuf,dstStep,
                 dstRoiSize,fltKernel,kernelSize,
                 anchor);

            fMwIppl->ipplCheckStatus(statusCode);

            if (fltKernel) mxFree(fltKernel);
        }

  public:

    Filter();
    virtual ~Filter();

    void setInSize(const mxArray *inSize);
    void setFlags(const mxArray *kernel);
    void setKernel(const mxArray *kernel);
    void setPadImage(const mxArray *padImage);
    void setNonZeroKernel(const mxArray *nonZeroKernel);
    void setConn(const mxArray *conn);
    void setStart(const mxArray *start);

    mxArray *evaluate(void);
};

#endif
