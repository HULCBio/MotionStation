/*
 * IMMULTMEX
 *
 * Z = IMMULTMEX(X,Y), where X and Y are numeric arrays of the same size 
 * and class, produces an array Z of the same size and class containing
 * X.*Y.  If the class is integer, the results are computed in 
 * double-precision elementwise and then truncated and rounded to fit in the
 * integer range.  X and Y must be real.
 *
 * $Revision: 1.1.6.3 $
 * Copyright 1993-2003 The MathWorks, Inc. All Rights Reserved.
 */

static char rcsid[] = "$Id: immultmex.cpp,v 1.1.6.3 2003/05/03 17:52:03 batserve Exp $";

#include "mex.h"
#include "immultmex.h"


//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
Multiply::Multiply()
{
    //Initialize class variables
    fMwIppl       = new MwIppl();
    fClassID      = mxUNKNOWN_CLASS;
    fNumElements  = -1;
    
    ippiMul_8u_C1RSfs = (ippiMul_8u_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiMul_8u_C1RSfs", ippI);
    ippiMul_16s_C1RSfs = (ippiMul_16s_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiMul_16s_C1RSfs", ippI);
    ippiMul_32f_C1R = (ippiMul_32f_C1R_T)
        fMwIppl->getMethodPointer("ippiMul_32f_C1R", ippI);

    //Assign proper function pointers
    iptipplMul8u = ippiMul_8u_C1RSfs ? 
        (iptipplMul8u_T)MPTR(Multiply::ipplMul) :
        (iptipplMul8u_T)MPTR(Multiply::iptMulInt);

    iptipplMul16s = ippiMul_16s_C1RSfs ? 
        (iptipplMul16s_T)MPTR(Multiply::ipplMul) :
        (iptipplMul16s_T)MPTR(Multiply::iptMulInt);

    iptipplMul32f = ippiMul_32f_C1R ? 
        (iptipplMul32f_T)MPTR(Multiply::ipplMul) :
        (iptipplMul32f_T)MPTR(Multiply::iptMulFlP);
};

//////////////////////////////////////////////////////////////////////////////
// Note:  The destructor will be called on matlab exit or
//        when using matlab's "clear" function
//////////////////////////////////////////////////////////////////////////////
Multiply::~Multiply()
{
    if(fMwIppl  != NULL) delete fMwIppl;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void Multiply::evaluate(void *x_ptr, void *y_ptr, void *z_ptr)
{
    mxAssert( (fClassID != mxUNKNOWN_CLASS),
              ERR_STRING("Multiply::fClassID","evaluate()"));
    mxAssert( (fNumElements != -1),
              ERR_STRING("Multiply::fNumElements","evaluate()"));

    switch(fClassID)
    {
      case(mxUINT8_CLASS):
        (*this.*iptipplMul8u)((uint8_T *)x_ptr, (uint8_T *)y_ptr,
                              (uint8_T *)z_ptr);
        break;

      case(mxINT8_CLASS):
        iptMulInt((int8_T *)x_ptr, (int8_T *)y_ptr, (int8_T *)z_ptr);
        break;

      case(mxUINT16_CLASS):
        iptMulInt((uint16_T *)x_ptr, (uint16_T *)y_ptr,(uint16_T *)z_ptr);
        break;

      case(mxINT16_CLASS):
        (*this.*iptipplMul16s)((int16_T *)x_ptr, (int16_T *)y_ptr,
                               (int16_T *)z_ptr);
        break;

      case(mxUINT32_CLASS):
        iptMulInt((uint32_T *)x_ptr, (uint32_T *)y_ptr, (uint32_T *)z_ptr);
        break;

      case(mxINT32_CLASS):
        iptMulInt((int32_T *)x_ptr, (int32_T *)y_ptr, (int32_T *)z_ptr);
        break;

      case(mxSINGLE_CLASS):
         (*this.*iptipplMul32f)((float *)x_ptr, (float *)y_ptr,
                                (float *)z_ptr);
        break;

      case(mxDOUBLE_CLASS):
        iptMulFlP((double *)x_ptr, (double *)y_ptr, (double *)z_ptr);
        break;

      default:
        //Should never get here
        mexErrMsgIdAndTxt("Images:immultmex:unsuppDataType", "%s",
                          "Unsupported data type.");
        break;
    }
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void Multiply::setClassID(mxClassID classID)
{
    fClassID = classID;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void Multiply::setNumElements(int numElements)
{
    fNumElements = numElements;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////

//Instantiate the class responsible for all the computations
Multiply multiply;

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 2)
    {    
        mexErrMsgIdAndTxt("Images:immultmex:invalidNumInputs",
                          "%s",
                          "IMMULTMEX requires two input arguments.");
    }

    const mxArray *X = prhs[0];
    const mxArray *Y = prhs[1];

    int ndims = mxGetNumberOfDimensions(X);
    mxClassID classID = mxGetClassID(X);

    const int *size_x = mxGetDimensions(X);
    const int *size_y = mxGetDimensions(Y);

    if (classID != mxGetClassID(Y))
    {
        mexErrMsgIdAndTxt("Images:immultmex:classMismatch",
                          "%s",
                          "X and Y must have the same class.");
    }
    if (ndims != mxGetNumberOfDimensions(Y))
    {
        mexErrMsgIdAndTxt("Images:immultmex:sizeMismatch",
                          "%s",
                          "X and Y must be the same size.");
    }
    for (int k = 0; k < ndims; k++)
    {
        if (size_x[k] != size_y[k])
        {
            mexErrMsgIdAndTxt("Images:immultmex:sizeMismatch",
                              "%s",
                              "X and Y must be the same size.");
        }
    }
   
    mxArray *Z = mxCreateNumericArray(ndims, size_x, classID, mxREAL);

    int num_elements = mxGetNumberOfElements(Z);

    void *x_ptr = mxGetData(X);
    void *y_ptr = mxGetData(Y);
    void *z_ptr = mxGetData(Z);

    multiply.setNumElements(num_elements);
    multiply.setClassID(classID);
    multiply.evaluate(x_ptr, y_ptr, z_ptr);

    plhs[0] = Z;
}
