//////////////////////////////////////////////////////////////////////////////
// IMDIVMEX.MEX
//
// Z = IMDIVMEX(X,Y), where X and Y are numeric or logical arrays of the 
// same size and class, produces an array Z of the same size and class 
// containing X./Y, unless X is logical, in which case Z is double.  If the 
// class is integer, the results are computed in double-precision elementwise 
// and then truncated and rounded to fit in the integer range.  X and Y must 
// be real.
//
// $Revision: 1.1.6.4 $
// Copyright 1993-2003 The MathWorks, Inc. All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////

static char rcsid[] = "$Id: imdivmex.cpp,v 1.1.6.4 2003/05/03 17:51:59 batserve Exp $";

#include "mex.h"
#include "imdivmex.h"

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
Divide::Divide()
{
    //Initialize class variables
    fMwIppl       = new MwIppl();
    fClassID      = mxUNKNOWN_CLASS;
    fNumElements  = -1;

    ippiDiv_8u_C1RSfs = (ippiDiv_8u_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiDiv_8u_C1RSfs", ippI);
    ippiDiv_16s_C1RSfs = (ippiDiv_16s_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiDiv_16s_C1RSfs", ippI);
    ippiDiv_32f_C1R = (ippiDiv_32f_C1R_T)
        fMwIppl->getMethodPointer("ippiDiv_32f_C1R", ippI);

    //Assign proper function pointers
    iptipplDiv8u = ippiDiv_8u_C1RSfs ? 
        (iptipplDiv8u_T)MPTR(Divide::ipplDiv) :
        (iptipplDiv8u_T)MPTR(Divide::iptDivInt);

    iptipplDiv16s = ippiDiv_16s_C1RSfs ? 
        (iptipplDiv16s_T)MPTR(Divide::ipplDiv) :
        (iptipplDiv16s_T)MPTR(Divide::iptDivInt);

    iptipplDiv32f = ippiDiv_32f_C1R ? 
        (iptipplDiv32f_T)MPTR(Divide::ipplDiv) :
        (iptipplDiv32f_T)MPTR(Divide::iptDivFlP);
};

//////////////////////////////////////////////////////////////////////////////
// Note:  The destructor will be called on matlab exit or
//        when using matlab's "clear" function
//////////////////////////////////////////////////////////////////////////////
Divide::~Divide()
{
    if(fMwIppl  != NULL) delete fMwIppl;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void Divide::evaluate(void *x_ptr, void *y_ptr, void *z_ptr)
{
    mxAssert( (fClassID != mxUNKNOWN_CLASS),
              ERR_STRING("Divide::fClassID","evaluate()"));
    mxAssert( (fNumElements != -1),
              ERR_STRING("Divide::fNumElements","evaluate()"));

    switch(fClassID)
    {
      case(mxLOGICAL_CLASS):
        iptDivFlP((uint8_T *)x_ptr, (uint8_T *)y_ptr, (double *)z_ptr);
        break;

      case(mxUINT8_CLASS):
        (*this.*iptipplDiv8u)((uint8_T *)x_ptr, (uint8_T *)y_ptr,
                              (uint8_T *)z_ptr);
        break;

      case(mxINT8_CLASS):
        iptDivInt((int8_T *)x_ptr, (int8_T *)y_ptr, (int8_T *)z_ptr);
        break;

      case(mxUINT16_CLASS):
        iptDivInt((uint16_T *)x_ptr, (uint16_T *)y_ptr, (uint16_T *)z_ptr);
        break;

      case(mxINT16_CLASS):
         (*this.*iptipplDiv16s)((int16_T *)x_ptr, (int16_T *)y_ptr,
                                (int16_T *)z_ptr);
        break;

      case(mxUINT32_CLASS):
        iptDivInt((uint32_T *)x_ptr, (uint32_T *)y_ptr, (uint32_T *)z_ptr);
        break;

      case(mxINT32_CLASS):
        iptDivInt((int32_T *)x_ptr, (int32_T *)y_ptr, (int32_T *)z_ptr);
        break;

      case(mxSINGLE_CLASS):
         (*this.*iptipplDiv32f)((float *)x_ptr,(float *)y_ptr,(float *)z_ptr);
        break;

      case(mxDOUBLE_CLASS):
        iptDivFlP((double *)x_ptr,(double *)y_ptr,(double *)z_ptr);
        break;

      default:
        //Should never get here
        mexErrMsgIdAndTxt("Images:imdivmex:unsuppDataType", "%s",
                          "Unsupported data type.");
        break;
    }
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void Divide::setClassID(mxClassID classID)
{
    fClassID = classID;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void Divide::setNumElements(int numElements)
{
    fNumElements = numElements;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////

//Instantiate the class responsible for all the computations
Divide cDivide;

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    if (nrhs < 2)
    {
        mexErrMsgIdAndTxt("Images:imdivide:tooFewInputs", "%s",
                          "Too few inputs.");
    }
    if (nrhs > 2)
    {
        mexErrMsgIdAndTxt("Images:imdivide:tooManyInputs", "%s", 
                          "Too many inputs.");
    }

    const mxArray *X = prhs[0];
    const mxArray *Y = prhs[1];
    
    int        ndims     = mxGetNumberOfDimensions(X);
    const int *size_x    = mxGetDimensions(X);
    const int *size_y    = mxGetDimensions(Y);
    mxClassID  inClassID = mxGetClassID(X);

    if (inClassID !=  mxGetClassID(Y))
    {
        mexErrMsgIdAndTxt("Images:imdivide:mismatchedClass",
                          "%s",
                          "X and Y must have the same class.");
    }
    if (ndims != mxGetNumberOfDimensions(Y))
    {
        mexErrMsgIdAndTxt("Images:imdivide:mismatchedSize",
                          "%s",
                          "X and Y must be the same size.");
    }
    for (int k = 0; k < ndims; k++)
    {
        if (size_x[k] != size_y[k])
        {
            mexErrMsgIdAndTxt("Images:imdivide:mismatchedSize",
                              "%s",
                              "X and Y must be the same size.");
        }
    }

    mxClassID outClassID = mxIsLogical(X) ? mxDOUBLE_CLASS : inClassID;
    mxArray *Z = mxCreateNumericArray(ndims, size_x, outClassID, mxREAL);

    int   num_elements = mxGetNumberOfElements(Z);
    void *x_ptr = mxGetData(X);
    void *y_ptr = mxGetData(Y);
    void *z_ptr = mxGetData(Z);

    cDivide.setClassID(inClassID);
    cDivide.setNumElements(num_elements);
    cDivide.evaluate(x_ptr, y_ptr, z_ptr);

    //Return the output
    plhs[0] = Z;
}
