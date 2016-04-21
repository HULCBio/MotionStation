//
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $
//

#ifndef IMLINCOMBC_H
#define IMLINCOMBC_H

#include "mwippl.h"
#include "typeconv.h"
#include "iptutil_cpp.h"

//Types returned by useIPPL method which determines if IPPL should be used
typedef enum
{
    opAdd,
    opSubRfL,
    opSubLfR,
    opAddC,
    opSubC,
    opNone
} operation_T;


class LinComb
{
  private:   

    //Member variables
    //////////////////
    
    MwIppl    *fMwIppl;
    mxClassID  fInputClassID;
    mxClassID  fOutputClassID;
    int        fNumElements;
    int        fNumImages;
    int        fNumScalars;

    //Pointers to IPPL methods
    ippiAdd_8u_C1RSfs_T    ippiAdd_8u_C1RSfs;
    ippiAdd_16s_C1RSfs_T   ippiAdd_16s_C1RSfs;
    ippiAdd_32f_C1R_T      ippiAdd_32f_C1R;

    ippiAddC_8u_C1RSfs_T   ippiAddC_8u_C1RSfs;
    ippiAddC_16s_C1RSfs_T  ippiAddC_16s_C1RSfs;
    ippiAddC_32f_C1R_T     ippiAddC_32f_C1R;

    ippiSub_8u_C1RSfs_T    ippiSub_8u_C1RSfs;
    ippiSub_16s_C1RSfs_T   ippiSub_16s_C1RSfs;
    ippiSub_32f_C1R_T      ippiSub_32f_C1R;

    ippiSubC_8u_C1RSfs_T   ippiSubC_8u_C1RSfs;
    ippiSubC_16s_C1RSfs_T  ippiSubC_16s_C1RSfs;
    ippiSubC_32f_C1R_T     ippiSubC_32f_C1R;

    bool                   bUseIPPL;

    //Methods
    /////////

    void        checkCellTypes(const mxArray *images);
    void        checkSizeAndClassMatch(const mxArray *images);
    bool        isSameSize(const mxArray *array1, const mxArray *array2);
    mxClassID   getOutputClassID(const mxArray *output_class_array);
    operation_T useIPPL(double *scalars);

    //Templetized methods
    /////////////////////

    template<typename _T1, typename _T2>
        void iptLinCombIntOut(double *scalars, _T1 **inputImages,
                              _T2 *outputImage)
        {
            double offset = (fNumScalars == fNumImages) ? 0.0 : 
                scalars[fNumScalars - 1];
            
            for (int k = 0; k < fNumElements; k++)
            {
                double output_value = 0.0;
                
                for (int p = 0; p < fNumImages; p++)
                {
                    output_value += scalars[p]*(*(inputImages[p] + k));
                }
                
                output_value += offset;
                
                convert2Type(outputImage, output_value);
                
                outputImage++;
            }
        }

    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    template<typename _T1, typename _T2>
        void iptLinCombFlPOut(double *scalars, _T1 **inputImages,
                              _T2 *outputImage)
        {
            double offset = (fNumScalars == fNumImages) ? 0.0 : 
                scalars[fNumScalars - 1];
            
            for (int k = 0; k < fNumElements; k++)
            {
                double output_value = 0.0;
                
                for (int p = 0; p < fNumImages; p++)
                {
                    output_value += scalars[p]*(*(inputImages[p] + k));
                }
                
                output_value += offset;
                *outputImage = (_T2)output_value;
                
                outputImage++;
            }
        }

    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    template<typename _T1, typename _T2>
        void ipplArithInt(_T1 *x_ptr, _T1 *y_ptr, _T1 *z_ptr, _T2 func_ptr)
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
    template<typename _T1, typename _T2>
        void ipplArithFlP(_T1 *x_ptr, _T1 *y_ptr, _T1 *z_ptr, _T2 func_ptr)
        {
            IppiSize roiSize = {fNumElements, 1};
            int step         = roiSize.width*sizeof(_T1);
            
            IppStatus statusCode = (*func_ptr)
                (x_ptr,step,y_ptr,step,z_ptr,step,roiSize);
            
            fMwIppl->ipplCheckStatus(statusCode);
        }

    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    template<typename _T1, typename _T2>
        void ipplArithCInt(_T1 *x_ptr, double value, _T1 *z_ptr, _T2 func_ptr)
        {
            IppiSize roiSize = {fNumElements, 1};
            int step         = roiSize.width*sizeof(_T1);
            int scaleFactor  = 0; 
            _T1 constant;

            saturateRoundAndCast(&constant, value);
            
            IppStatus statusCode = (*func_ptr)
                (x_ptr,step,constant,z_ptr,step,roiSize,scaleFactor);
            
            fMwIppl->ipplCheckStatus(statusCode);
        }

    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    template<typename _T1, typename _T2>
        void ipplArithCFlP(_T1 *x_ptr, _T1 value, _T1 *z_ptr, _T2 func_ptr)
        {
            IppiSize roiSize = {fNumElements, 1};
            int step         = roiSize.width*sizeof(_T1);
            
            IppStatus statusCode = (*func_ptr)
                (x_ptr,step,value,z_ptr,step,roiSize);
            
            fMwIppl->ipplCheckStatus(statusCode);
        }
    
    //////////////////////////////////////////////////////////////////////////
    //
    //////////////////////////////////////////////////////////////////////////
    template<typename _T>
        void castInputAndEvaluate(double *scalars, _T **inputImages,
                                  void *outputImage)
        {
            switch(fOutputClassID)
            {
              case(mxUINT8_CLASS):
                iptLinCombIntOut(scalars,inputImages,(uint8_T *)outputImage);
                break;
                
              case(mxINT8_CLASS):
                iptLinCombIntOut(scalars, inputImages,(int8_T *)outputImage);
                break;
                
              case(mxUINT16_CLASS):
                iptLinCombIntOut(scalars,inputImages,(uint16_T *)outputImage);
                break;       

              case(mxINT16_CLASS):
                iptLinCombIntOut(scalars,inputImages,(int16_T *)outputImage);
                break;
                
              case(mxUINT32_CLASS):
                iptLinCombIntOut(scalars,inputImages,(uint32_T *)outputImage);
                break;

              case(mxINT32_CLASS):
                iptLinCombIntOut(scalars,inputImages,(int32_T *)outputImage);
                break;

              case(mxSINGLE_CLASS):
                iptLinCombFlPOut(scalars, inputImages, (float *)outputImage);
                break;
                
              case(mxDOUBLE_CLASS):
                iptLinCombFlPOut(scalars,inputImages,(double *)outputImage);
                break;
                
              default:
                //Should never get here
                mexErrMsgIdAndTxt("Images:imlincombc:unsuppDataType", "%s",
                                  "Unsupported data type.");
                break;
            }
            
        }
        
  public:
    
    LinComb();
    virtual ~LinComb();

    mxClassID checkInputs(int nlhs, mxArray *plhs[], int nrhs, 
                          const mxArray *prhs[]);

    void evaluate(double *scalars, void **inputImages, void *outputImage);
    
    //Accessor methods
    //////////////////
    void setInputClassID(mxClassID classID);
    void setOutputClassID(mxClassID classID);
    void setNumElements(int numElements);
    void setNumImages(int numImages);
    void setNumScalars(int numScalars);
};

#endif
