//////////////////////////////////////////////////////////////////////////////
// IMABSDIFF.MEX
//
// Z = IMABSDIFF(X,Y), where X and Y are numeric arrays of the same size 
// and class, produces an array Z of the same size and class containing
// ABS(X-Y).  If the class is integer, the results are computed in 
// double-precision elementwise and then truncated and rounded to fit in the
// integer range.  X and Y must be real.
//
// $Revision: 1.1.6.1 $
// Copyright 1993-2003 The MathWorks, Inc. All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////

static char rcsid[] = "$Id: imabsdiffmex.cpp,v 1.1.6.1 2003/05/03 17:51:57 batserve Exp $";

#include "mex.h"
#include "mwippl.h"
#include "imabsdiffmex.h"

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
AbsDiff::AbsDiff()
{
    //Initialize class variables
    fMwIppl       = new MwIppl();
    fClassID      = mxUNKNOWN_CLASS;
    fNumElements  = -1;

    
    ippiAbsDiff_8u_C1R = (ippiAbsDiff_8u_C1R_T)
        fMwIppl->getMethodPointer("ippiAbsDiff_8u_C1R", ippCV);
    ippiAbsDiff_32f_C1R = (ippiAbsDiff_32f_C1R_T)
        fMwIppl->getMethodPointer("ippiAbsDiff_32f_C1R", ippCV);

    //Assign proper function pointers
    //Note:
    //* MS VC++ and Solaris compilers are unable to resolve these method
    //  pointer assignments unless explicit casts are used.
    iptipplAbsDiff8u = (ippiAbsDiff_8u_C1R) ? 
        (iptipplAbsDiff8u_T)MPTR(AbsDiff::ipplAbsDiff) :
        (iptipplAbsDiff8u_T)MPTR(AbsDiff::iptAbsDiff);

    iptipplAbsDiff32f = (ippiAbsDiff_32f_C1R) ? 
        (iptipplAbsDiff32f_T)MPTR(AbsDiff::ipplAbsDiff) : 
        (iptipplAbsDiff32f_T)MPTR(AbsDiff::iptAbsDiff);

};

//////////////////////////////////////////////////////////////////////////////
// Note: The destructor will be called on matlab exit or
//       when using matlab's "clear" function
//////////////////////////////////////////////////////////////////////////////
AbsDiff::~AbsDiff()
{
    if(fMwIppl) delete fMwIppl;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void AbsDiff::evaluate(void *x_ptr, void *y_ptr, void *z_ptr)
{
    mxAssert( (fClassID != mxUNKNOWN_CLASS),
              ERR_STRING("AbsDiff::fClassID","evaluate()"));
    mxAssert( (fNumElements != -1), 
              ERR_STRING("AbsDiff::fNumElements","evaluate()"));

    switch(fClassID)
    {
      case(mxLOGICAL_CLASS):
      case(mxUINT8_CLASS):
        (*this.*iptipplAbsDiff8u)((uint8_T *)x_ptr, (uint8_T *)y_ptr,
                                  (uint8_T *)z_ptr);
        break;
      case(mxINT8_CLASS):
        iptAbsDiffInt((int8_T  *)x_ptr, (int8_T  *)y_ptr,
                      (int8_T  *)z_ptr, (int16_T)DUMMY);
        break;
      case(mxUINT16_CLASS):
        iptAbsDiffUIntOrFlP((uint16_T *)x_ptr, (uint16_T *)y_ptr,
                            (uint16_T *)z_ptr, (int32_T)DUMMY);
        break;
      case(mxINT16_CLASS):
        iptAbsDiffInt((int16_T *)x_ptr, (int16_T *)y_ptr,
                      (int16_T *)z_ptr, (int32_T)DUMMY);
        break;
      case(mxUINT32_CLASS):
        iptAbsDiffUIntOrFlP((uint32_T *)x_ptr, (uint32_T *)y_ptr,
                            (uint32_T *)z_ptr, (double)DUMMY);
        break;
      case(mxINT32_CLASS):
        iptAbsDiffInt((int32_T *)x_ptr, (int32_T *)y_ptr,
                      (int32_T *)z_ptr, (double)DUMMY);
        break;
      case(mxSINGLE_CLASS):
        (*this.*iptipplAbsDiff32f)((float *)x_ptr, (float *)y_ptr,
                                   (float *)z_ptr);
        break;
      case(mxDOUBLE_CLASS):
        iptAbsDiffUIntOrFlP((double *)x_ptr, (double *)y_ptr,
                            (double *)z_ptr, (double)DUMMY);
        break;
      default:
        //Should never get here
        mexErrMsgIdAndTxt("Images:imabsdiff:unsupportedDataType", "%s",
                          "Unsupported data type.");
        break;
    }
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void AbsDiff::setClassID(mxClassID classID)
{
    fClassID = classID;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void AbsDiff::setNumElements(int numElements)
{
    fNumElements = numElements;
}

//////////////////////////////////////////////////////////////////////////////
// MEX Function
//////////////////////////////////////////////////////////////////////////////

//Instantiate the class responsible for all the computations
AbsDiff absDiff;

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    if (nrhs < 2)
    {
        mexErrMsgIdAndTxt("Images:imabsdiff:tooFewInputs", "%s",
                          "Too few inputs.");
    }
    if (nrhs > 2)
    {
        mexErrMsgIdAndTxt("Images:imabsdiff:tooManyInputs", "%s",
                          "Too many inputs.");
    }

    const mxArray *X = prhs[0];
    const mxArray *Y = prhs[1];

    if (!( mxIsNumeric(X) || mxIsLogical(X) ) || 
        mxIsComplex(X))
    {
        mexErrMsgIdAndTxt("Images:imabsdiff:invalidX", "%s",
                          "X must be a real numeric or logical array.");
    }
    if (!( mxIsNumeric(Y) || mxIsLogical(X) ) || 
        mxIsComplex(Y))
    {
        mexErrMsgIdAndTxt("Images:imabsdiff:invalidY", "%s", 
                     "Y must be a real numeric or logical array.");
    }
    
    int        ndims   = mxGetNumberOfDimensions(X);
    const int *size_x  = mxGetDimensions(X);
    const int *size_y  = mxGetDimensions(Y);
    mxClassID  classID = mxGetClassID(X);

    if (classID != mxGetClassID(Y))
    {
        mexErrMsgIdAndTxt("Images:imabsdiff:classMismatch", "%s",
                          "X and Y must have the same class.");
    }
    if (ndims != mxGetNumberOfDimensions(Y))
    {
        mexErrMsgIdAndTxt("Images:imabsdiff:sizeMismatch", "%s", 
                          "X and Y must be the same size.");
    }
    for (int k = 0; k < ndims; k++)
    {
        if (size_x[k] != size_y[k])
        {
            mexErrMsgIdAndTxt("Images:imabsdiff:sizeMismatch", "%s", 
                              "X and Y must be the same size.");
        }
    }
    
    mxArray *Z = mxCreateNumericArray(ndims, size_x, classID, mxREAL);

    int num_elements = mxGetNumberOfElements(Z);
    void *x_ptr = mxGetData(X);
    void *y_ptr = mxGetData(Y);
    void *z_ptr = mxGetData(Z);

    absDiff.setClassID(classID);
    absDiff.setNumElements(num_elements);
    absDiff.evaluate(x_ptr,y_ptr,z_ptr);

    plhs[0] = Z;
}

